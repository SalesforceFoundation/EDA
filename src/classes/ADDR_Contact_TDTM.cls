/*
    Copyright (c) 2016, Salesforce.org
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
 
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2016
* @group Addresses
* @group-content ../../ApexDocContent/Addresses.htm
* @description Trigger Handler on Contact for Address management. 
*/
public class ADDR_Contact_TDTM extends TDTM_Runnable {
    
    /* @description static flag to prevent recursive call */
    public static boolean alreadyRunBefore = false;
    public static boolean alreadyRunAfter = false;
    
    private static List<Contact> newContactsList;
    
    /*******************************************************************************************************
    * @description Trigger Handler on Contact that handles Address Management.
    *
    *   Rules:
    *       inserting new contact
    *           if parent Account is Household --> create new Address as child of Account. If not override, make it default and 
                                                   propagate to children without override
    *           else --> create new Address as child of Contact
    *
    *       updating an existing contact
    *           if parent Account is Household --> create new Address as child of Account. If not override, make it default and
                                                   propagate to children without override
    *           else --> create new Address as child of Contact
    *
    * @param listNew the list of Contacts from trigger new. 
    * @param listOld the list of Contacts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Contacts 
    * @return dmlWrapper.  
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        DmlWrapper dmlWrapper = new DmlWrapper();
        
        // prevent recursion
        if (!alreadyRunBefore && !alreadyRunAfter) {
            
            //Turn off other address triggers
            ADDR_Account_TDTM.alreadyRunBefore = true;
            ADDR_Account_TDTM.alreadyRunAfter = true;
            ADDR_Addresses_TDTM.alreadyRunBefore = true;
            ADDR_Addresses_TDTM.alreadyRunAfter = true;
            
	        //To query additional fields (RecordTypeId, to know if parent is Hosehold) in parent Account
	        if(newContactsList == null) {
	           newContactsList = [select Account.RecordTypeId, is_Address_Override__c, Primary_Address_Type__c, Current_Address__c, 
	                   Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry, 
	                   Account.BillingLatitude, Account.BillingLongitude,
	                   MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude 
	                   from Contact where ID in :listNew];
	        }

	        //List of Contacts from which an Address record needs to be created.
            List<Contact> contactsCreateAddrFrom = new List<Contact>();
            //List of Contact IDs that need their address info propagated to the parent and all siblings without override
            List<Contact> contactsAddrPropagate = new List<Contact>();  
	        //List of Contact IDs that need their address info deletion propagated to the parent and all siblings without override
            List<Contact> contactsAddrPropagateDelete = new List<Contact>();  
	        //Map of Adress IDs to Boolean, with the Boolean representing if the Address needs its Latest Date fields updated.
	        Map<Id, boolean> addrIdsOverride = new Map<Id, boolean>();
	        //List of Contacts that need to have their address info pulled from the parent Household (if they unchecked the override field, for example)
            List<Contact> contactsAddrGetFromHh = new List<Contact>();
	        //List of Contacts that have had their address information cleared. List is not the same as contactsAddrGetFromHh, because in this case, 
	        //if it's not an override, address info has to be deleted from the Hosehould.
	        List<Contact> contactsAddrInfoCleared = new List<Contact>();
	        //List of Contacts that have been created without address info
	        List<Contact> contactsAddrInfoReset = new List<Contact>(); //TODO: why is this different from the contactsAddrGetFromHh list?!?
	        
	        if(!alreadyRunBefore && (triggerAction == TDTM_Runnable.Action.BeforeInsert || triggerAction == TDTM_Runnable.Action.BeforeUpdate)) {
	            Integer i = 0;
	            for (Contact contact : newContactsList) {
	                Boolean childOfHousehold = contact.Account.RecordTypeID == UTIL_Describe.getHhAccRecTypeID();
	                Contact contactOld = listOld == null ? null : (Contact)listOld[i];
                    Boolean childOfHouseholdOld = listOld == null ? null : contactOld.Account.RecordTypeID == UTIL_Describe.getHhAccRecTypeID();
                    Boolean addrInfoChanged = listOld == null ? null : ADDR_Addresses_UTIL.isContactAddressChanged(contact, contactOld);
                    Boolean addrInfoCleared = listOld == null ? null : !ADDR_Addresses_UTIL.iscontactAddressEmpty(contactOld) && ADDR_Addresses_UTIL.iscontactAddressEmpty(contact);
                    
	                // BEFORE INSERT
	                if (triggerAction == TDTM_Runnable.Action.BeforeInsert) {
	                    //Children of Household               
	                    if (childOfHousehold) {
	                        if (contact.is_Address_Override__c) {
	                            // address needs latest start/end dates updated
	                            addrIdsOverride.put(contact.Current_Address__c, true);
	                        } else { 
	                            //Address record needs to be created as child of parent Account (can be done in the Before cuz we already have the ID to populate Parent_Account__c)
	                            contactsCreateAddrFrom.add(contact);
	                            //Address needs to be copied to parent Household, and all siblings that don't have an override.
	                            contactsAddrPropagate.add(contact);
	                        }
	                        if (ADDR_Addresses_UTIL.isContactAddressEmpty(contact)) {
	                           // if the contact has no address specified, pick up the HH default.
	                           contactsAddrInfoReset.add(contact);
	                        }
	                    } //If parent is not a Household, Address record creation done in the afterInsert. 
	                }
	                
	                // BEFORE UPDATE
                    if (triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
                        if(childOfHousehold) {
                            // if Account changes... 
                            if (contactOld != null && contact.AccountId != contactOld.AccountId) {
                                // if no override, refill from the Default Address
                                if (!contact.is_Address_Override__c && !addrInfoChanged) {
                                    contactsAddrInfoReset.add(contact);
                                } else {
                                     //Address record needs to be created as child of parent Account (can be done in the Before cuz we already have the ID to populate Parent_Account__c)
                                     contactsCreateAddrFrom.add(contact);
                                     //Address needs to be copied to parent Household, and all siblings that don't have an override.
                                     contactsAddrPropagate.add(contact);
                                }
                            } else {    
                                // if they are changing to a new Current Address, refill from it.
                                if (contact.Current_Address__c != contactOld.Current_Address__c && contact.Current_Address__c != null) {
                                    contactsAddrGetFromHh.add(contact);
                                    if (contact.is_Address_Override__c)
                                        // track which address's need their dates updated
                                        addrIdsOverride.put(contact.Current_Address__c, true);                    
                                }
                                
                                // if they are clearing isAddressOverride, refill from the Default Address
                                if (contact.is_Address_Override__c != contactOld.is_Address_Override__c && !contact.is_Address_Override__c) {
                                    contactsAddrInfoReset.add(contact);
                                    if (contactOld.Current_Address__c != null)
                                        // track which address's need their dates updated
                                        addrIdsOverride.put(contactOld.Current_Address__c, false);
                                }
                                
                                // TODO???
                                // if MailingAddress fields changed, update the existing address object or create a new one.
                                // this is handled in the next block, since we do it for both new contacts and updated contacts.
                            }
                        }
                    }
                    i++;
	            }
	            alreadyRunBefore = true;
	        } 
	        
	        if(!alreadyRunAfter && (triggerAction == TDTM_Runnable.Action.AfterInsert || triggerAction == TDTM_Runnable.Action.AfterUpdate)) {
	            Integer i = 0;
                for (Contact contact : newContactsList) {
                    Boolean childOfHousehold = contact.Account.RecordTypeID == UTIL_Describe.getHhAccRecTypeID();
                    Contact contactOld = listOld == null ? null : (Contact)listOld[i];
                    Boolean childOfHouseholdOld = listOld == null ? null : contactOld.Account.RecordTypeID == UTIL_Describe.getHhAccRecTypeID();
                    Boolean addrInfoChanged = listOld == null ? null : ADDR_Addresses_UTIL.isContactAddressChanged(contact, contactOld);
                    Boolean addrInfoCleared = listOld == null ? null : !ADDR_Addresses_UTIL.iscontactAddressEmpty(contactOld) && ADDR_Addresses_UTIL.iscontactAddressEmpty(contact);
                    
		            // AFTER INSERT
	                if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
	                    // for new Contacts that are using address management and are not children of Household, create the address object. We do it in the after, 
	                    // so that the Parent_Contact__c field in Address can point back to the Contact.
	                    if (UTIL_CustomSettingsFacade.getSettings().Contacts_Addresses_Enabled__c == true && !childOfHousehold) {
	                        contactsCreateAddrFrom.add(contact);
	                    }
	                }
	                
	                // AFTER UPDATE
	                if (triggerAction == TDTM_Runnable.Action.AfterUpdate) { 
	                    //If Contact Addresses are enabled, and the Contact is not the child of a HH 
	                    if (!childOfHousehold && UTIL_CustomSettingsFacade.getSettings().Contacts_Addresses_Enabled__c == true && addrInfoChanged) {
	                        contactsCreateAddrFrom.add(contact);
	                    } else if (childOfHousehold) {
	                        // if the address info has been removed
	                        if(addrInfoCleared) {                         
	                            contactsAddrInfoCleared.add(contact);
	                            //if the contact was not override, but pointing to the default Address instead
	                            if(!contact.is_Address_Override__c) {
	                                contactsAddrPropagateDelete.add(contact);
	                            }
	                        // if the address changed, remember the Contact we want to add a new address for    
	                        } else if (addrInfoChanged) { 
	                            contactsCreateAddrFrom.add(contact);
	                        }
	                        // if the Contact has been changed to a different household
	                        if(contact.AccountID != contactOld.AccountID) {
	                            contactsAddrGetFromHh.add(contact);
	                        }
	                    }
	                }
	                i++;   
                }
                alreadyRunAfter = true;
	        }
	        
	        // set the mailing address for contacts who specify an address lookup or override
	        if (contactsAddrGetFromHh.size() > 0) {
	            setConAddrFromLookup(contactsAddrGetFromHh);
	        }
	        
	        // reset the mailing address for contacts who no longer have an address override
	        if (contactsAddrInfoReset.size() > 0) {
	            resetConAddr(contactsAddrInfoReset, dmlWrapper);
	        }
	        
	        // update the Latest date fields on any address overrides
	        if (addrIdsOverride.size() > 0) 
	            ADDR_Addresses_UTIL.updateAddrIsOverride(addrIdsOverride, dmlWrapper);
	
	        // create any new Address objects
	        if (contactsCreateAddrFrom.size() > 0)
	            createAddrFromContact(contactsCreateAddrFrom);
	        
	        // handle Contacts with address info removed
	        if(contactsAddrInfoCleared.size() > 0)
	            addrInfoDeleted(contactsAddrInfoCleared, dmlWrapper);
        
            // propagate address info to parent Household and and siblings without override
            if(contactsAddrPropagate.size() > 0)
                propagateAddrInfo(contactsAddrPropagate, dmlWrapper);
                
            // propagate address info deletion to parent Household and and siblings without override
            if(contactsAddrPropagateDelete.size() > 0)
                propagateAddrInfoDelete(contactsAddrPropagateDelete, dmlWrapper);
        }
                            
        return dmlWrapper;
    }
    
    private void propagateAddrInfo(List<Contact> contactsAddrPropagate, DmlWrapper dmlWrapper) {
        //Create map to use when excluding contacts in trigger from propagation, below
        Map<ID, Contact> contactsMap = new Map<ID, Contact>(contactsAddrPropagate);
        
        List<ID> parentAccIDs = new List<ID>();
        //Gather all parent Acc IDs
        for(Contact contact : contactsAddrPropagate) {
            parentAccIDs.add(Contact.AccountId);
        }
        //Query for parent Acc and sibling Contacts
        List<Account> parentAccsWithChildren = Database.query(getParentAccsWithChildrenQuery(parentAccIDs));
        for(Account acc : parentAccsWithChildren) {
            List<Contact> children = acc.Contacts;
            //Find the original Contact, that is part of the trigger
            Contact originalContact;
            //TODO: a for loop inside a for loop - not efficient
            for(Contact child : children) {
                if(contactsMap.containsKey(child.ID)) {
                    originalContact = child;
                    break;
                }
            }
            //Copy Address info to parent and siblings
            if(originalContact != null) {
	            //Copy address info to parent Account

	            ADDR_Addresses_UTIL.copyAddressStdSObj(originalContact, 'Mailing', acc, 'Billing');
	            DmlWrapper.objectsToUpdate.add(acc);
	            //Copy address info to each sibling - we need to exclude the one the trigger is running on!
	            for(Contact contact : acc.Contacts) {
	                if(contact.ID != originalContact.ID) {
	                   ADDR_Addresses_UTIL.copyAddressStdSObj(originalContact, 'Mailing', contact, 'Mailing');
	                   DmlWrapper.objectsToUpdate.add(contact);
	                }
	            }
            }
        } 
    }
    
    private String getParentAccsQuery(List<ID> accIDs) {
        String query = getAccAddrFieldsQuery();
        query += ' from Account where Id IN :accIDs';
        return query;
    }
    
    private String getParentAccsWithChildrenQuery(List<ID> accIDs) {
        String query = getAccAddrFieldsQuery();
        query += ' (select  MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Account.Contacts)';  
        query +=  ' from Account where Id IN :accIDs';
        return query;
    }
    
    private String getAccAddrFieldsQuery() {
        String query = 'select BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude';     
        if (ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled)
            query += ', BillingCountryCode, BillingStateCode ';
        return query;
    }
    
    private void propagateAddrInfoDelete(List<Contact> contactsAddrPropagate, DmlWrapper dmlWrapper) {
        //Create map to use when excluding contacts in trigger from propagation, below
        Map<ID, Contact> contactsMap = new Map<ID, Contact>(contactsAddrPropagate);
        
        List<ID> parentAccIDs = new List<ID>();
        //Gather all parent Acc IDs
        for(Contact contact : contactsAddrPropagate) {
            parentAccIDs.add(Contact.AccountId);
        }
        //Query for parent Acc and sibling Contacts
        List<Account> parentAccsWithChildren = Database.query(getParentAccsWithChildrenQuery(parentAccIDs));
        for(Account acc : parentAccsWithChildren) {
            List<Contact> children = acc.Contacts;
            //Find the original Contact, that is part of the trigger
            Contact originalContact;
            //TODO: a for loop inside a for loop - not efficient
            for(Contact child : children) {
                if(contactsMap.containsKey(child.ID)) {
                    originalContact = child;
                    break;
                }
            }
            //Clear Address info from parent and siblings
            if(originalContact != null) {
                //Clear address info from parent Account
                ADDR_Addresses_UTIL.clearAddrInfo(acc);
                dmlWrapper.objectsToUpdate.add(acc);
                //Clear address info from each sibling - we need to exclude the one the trigger is running on!
                for(Contact contact : acc.Contacts) {
                    if(contact.ID != originalContact.ID) {
                       ADDR_Addresses_UTIL.clearAddrInfo(contact);
                       DmlWrapper.objectsToUpdate.add(contact);
                    }
                }
            }
        }
    }
    
    /*******************************************************************************************************
    * @description for each Contact, create a new default address and add it to dmlWrapper
    * @param Listcontact a List of Contacts
    * @param dmlWrapper to hold the Addresses that need creating
    * @return void
    ********************************************************************************************************/
    private void createAddrFromContact(List<Contact> listContact) {
        
        List<Address__c> newAddrs = new List<Address__c>();
        for (Contact contact : listContact) {
            Address__c addr = new Address__c();
            if(contact.Account.RecordTypeId == UTIL_Describe.getHhAccRecTypeID()) {
                UTIL_Debug.debug('****Creating address as child of Account');
                addr.Parent_Account__c = contact.AccountId;
            } else {
                UTIL_Debug.debug('****Creating address as child of Contact');
                addr.Parent_Contact__c = contact.Id;    
            }
            addr.Default_Address__c = !contact.is_Address_Override__c;
            addr.Latest_Start_Date__c = system.today();
            addr.Latest_End_Date__c = null;
            ADDR_Addresses_UTIL.copyAddressStdSObjAddr(contact, 'Mailing', addr, null);            
            newAddrs.add(addr);
        }
        UTIL_Debug.debug('****Address records to create: ' + JSON.serializePretty(newAddrs));
        
        //since coming from an Contact address, there is no Address Type, so exclude it from the match testing.
        ADDR_Addresses_UTIL.NonDupeAddrs nonDupeAddrs = ADDR_Addresses_UTIL.getNonDuplicateAddresses(newAddrs, false);
        nonDupeAddrs.performDml();
        
        //Match each Contact or Account with each new address
        List<ID> parentContactIDs = new List<ID>();
        List<ID> parentAccountIDs = new List<ID>();
        Map<ID, Address__c> parentContactIdToAddrMap = new Map<ID, Address__c>();
        Map<ID, Address__c> parentAccountIdToAddrMap = new Map<ID, Address__c>();
        for(Address__c addr : nonDupeAddrs.newAddrs) {
            if(addr.Parent_Contact__c != null) {
               UTIL_Debug.debug('****Putting address with parent Contact in map');
               parentContactIDs.add(addr.Parent_Contact__c);
               parentContactIdToAddrMap.put(addr.Parent_Contact__c, addr);  
            } else if(addr.Parent_Account__c != null) {
               UTIL_Debug.debug('****Putting address with parent Account in map');
               parentAccountIDs.add(addr.Parent_Account__c);
               parentAccountIdToAddrMap.put(addr.Parent_Account__c, addr); 
            }
        }
        
        //We need to re-query because we are in the "after" part of the trigger. We cannot change it to the "before" because
        //we need the Contact ID field to have a value when populating the addr.Parent_Contact__c field above.
        List<Account> parentAccounts = [select Current_Address__c, (select ID from Account.Contacts) from Account where ID in :parentAccountIDs];
        List<Contact> parentContacts = [select is_Address_Override__c, Current_Address__c from Contact where ID in :parentContactIDs];
        
        List<SObject> parentsToUpdate = new List<SObject>();
        
        for(Account acc : parentAccounts) {
            Address__c childAddr = parentAccountIdToAddrMap.get(acc.Id);
            if(childAddr != null) {
                UTIL_Debug.debug('****Linking current address with Account');
                acc.Current_Address__c = childAddr.Id;
                parentsToUpdate.add(acc);
                if(acc.Contacts != null) {
	                UTIL_Debug.debug('****Linking current address with children of the Account');
	                for(Contact contact : acc.Contacts) {
	                    contact.Current_Address__c = childAddr.Id;
                        parentsToUpdate.add(contact);
	                }
                }
            }
        }
        
        for(Contact contact : parentContacts) {
            Address__c childAddr = parentContactIdToAddrMap.get(contact.Id);
            if(childAddr != null && !contact.is_Address_Override__c) {
                UTIL_Debug.debug('****Linking current address with Contact');
                contact.Current_Address__c = childAddr.Id;
                parentsToUpdate.add(contact);
            }
        }
        
        update parentsToUpdate;
    }
    
    /*******************************************************************************************************
    * @description for each contact, refresh its mailing address from its Address lookup
    * @param listCon the list of Contacts to update
    * @return void  
    ********************************************************************************************************/
    private void setConAddrFromLookup(List<Contact> listCon) {
        Set<Id> setAddrId = new Set<Id>();
        for (Contact contact : listCon) {
            if (contact.Current_Address__c != null)
              setAddrId.add(contact.Current_Address__c);
        }
    
        Map<Id, Address__c> mapAddrIdAddr = new Map<Id, Address__c>([select Id, Address_Type__c, MailingStreet__c, MailingStreet2__c, MailingCity__c, MailingState__c, 
            Geolocation__Latitude__s, Geolocation__Longitude__s, MailingPostalCode__c, MailingCountry__c from Address__c where Id in :setAddrId]);
            
        for (Contact contact : listCon) {
            Address__c addr = mapAddrIdAddr.get(contact.Current_Address__c);
            if (addr != null) {
                contact.Primary_Address_Type__c = addr.Address_Type__c;
                UTIL_Debug.debug('****Refreshing address info in Contact from default address: ' + JSON.serializePretty(addr));
                ADDR_Addresses_UTIL.copyAddressAddrSObj(addr, contact, 'Mailing', 'Primary_Address_Type__c', null);
            }
        }
    }
    
    /*******************************************************************************************************
    * @description
    * @param
    * @param 
    * @return void  
    ********************************************************************************************************/
    private void addrInfoDeleted(List<Contact> contactsAddrInfoCleared, DmlWrapper dmlWrapper) {
        List<ID> oldCurrentAddrIDs = new List<ID>();
        
        //We need to re-query before we are in the "after" part of the trigger
        List<Contact> contacts = [select is_Address_Override__c, Current_Address__c, AccountID, Account.RecordTypeId
                                  from Contact where ID in :contactsAddrInfoCleared];
        List<ID> accToUpdateIDs = new List<ID>();
        
        // clear Current_Address__c field from Contacts
        for(Contact contact : contacts) {
            if(contact.Current_Address__c != null) // get all current addrs
                oldCurrentAddrIDs.add(contact.Current_Address__c);
            contact.Current_Address__c = null;
            contact.is_Address_Override__c = false;
            dmlWrapper.objectsToUpdate.add(contact);
            
            // if contact belongs to household and its address is not an override (it's the default), clear address info from parent account
	        if(contact.Account.RecordTypeId == UTIL_Describe.getHhAccRecTypeID() && !contact.is_Address_Override__c) {
	            accToUpdateIDs.add(contact.AccountID);
	        }
        }
        
    }
    
    /*******************************************************************************************************
    * @description Finds each Contact's HH current address (either Default or Seasonal) and updates 
    * the contact's address fields
    * @param listCon list of Contacts 
    * @return void  
    ********************************************************************************************************/
    private void resetConAddr(List<Contact> listCon, DmlWrapper dmlWrapper) {
        if (listCon == null || listCon.size() == 0) return;
        
        Map<Id, Address__c> mapAccIdAddr = new Map<Id, Address__c>();
        for (Contact contact : listCon) 
            mapAccIdAddr.put(contact.AccountId, null);
                
        // get the default and seasonal address for each HH
        Map<Id, ADDR_Addresses_TDTM.ParentInfo> mapAccIdHHInfo = ADDR_Addresses_TDTM.refreshCurrentAccAddress(mapAccIdAddr, dmlWrapper, null);
        
        // reset the Contact's address fields with the appropriate address
        for (Contact contact : listCon) {
            ADDR_Addresses_TDTM.ParentInfo hhinfo = mapAccIdHHInfo.get(contact.AccountId);
            UTIL_Debug.debug('****Household address info: ' + JSON.serializePretty(hhinfo));
            if (hhinfo != null) {
                Address__c addr = hhinfo.addrSeasonal;
                if (addr == null)
                  addr = hhinfo.addrDefault;
                if (addr != null) {
                    contact.Primary_Address_Type__c = addr.Address_Type__c;
                    contact.Current_Address__c = addr.Id;
                    ADDR_Addresses_UTIL.copyAddressAddrSObj(addr, contact, 'Mailing', 'Primary_Address_Type__c', null);
                }              
            }
        }       
    }
}