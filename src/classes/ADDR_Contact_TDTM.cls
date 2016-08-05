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
    public static Boolean alreadyRunAfterInsert = false;
    public static Boolean alreadyRunAfterUpdate = false;
        
    public static void turnOff() {
        alreadyRunAfterInsert = true;
        alreadyRunAfterUpdate = true;
    }
    
    public static void turnOn() {
        alreadyRunAfterInsert = false;
        alreadyRunAfterUpdate = false;
    }
    
    /*******************************************************************************************************
    * @description Trigger Handler on Contact that handles Address Management.
    *
    *   Rules:
    *       inserting new contact
    *           if parent Account is Household --> create new Address as child of Account. If not override, make it default and 
                                                   propagate to children without override
    *           else && Contact addresses active --> create new Address as child of Contact
    *
    *       updating an existing contact
    *           if parent Account is Household --> create new Address as child of Account. If not override, make it default and
                                                   propagate to children without override
    *           else  && Contact addresses active --> create new Address as child of Contact
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
            
        if(!alreadyRunAfterInsert || !alreadyRunAfterUpdate) {
	    
	       //Turn off other address triggers
            ADDR_Account_TDTM.turnOff();
            ADDR_Addresses_TDTM.turnOff();

            Map<ID, ID> contactIDToAccRecTypeID;
            
	        //List of Contacts from which an Address record needs to be created.
	        List<Contact> contactsCreateAddrFrom = new List<Contact>();
	        
	        //List of Contact IDs that need their address info propagated to the parent and all siblings without override
	        List<Contact> contactsAddrPropagate = new List<Contact>();  
	        
	        //List of Contact IDs that need their address info deletion propagated to the parent and all siblings without override
	        List<Contact> contactsAddrPropagateDelete = new List<Contact>();  
	        
	        //Map of Adress IDs to Boolean, with the Boolean representing if the Address needs its Latest Date fields updated.
	        Map<Id, Boolean> addrIdsOverride = new Map<Id, Boolean>();
	        
	        //List of Contacts that need to have their address info pulled from the parent Household (if they unchecked the override field, for example)
	        List<Contact> contactsAddrGetFromHh = new List<Contact>();
	        
	        //List of Contacts that have had their address information cleared. List is not the same as contactsAddrGetFromHh, because in this case, 
	        //if it's not an override, address info has to be deleted from the Hosehould.
	        List<Contact> contactsAddrInfoCleared = new List<Contact>();
	        
	        //List of Contacts that need to have address info copied from parent Househod (for example, they have been created without address info)
	        List<Contact> contactsAddrInfoReset = new List<Contact>(); //This different from the contactsAddrGetFromHh list because contacts in 
	        //contactsAddrGetFromHh should have a value in their Current_Address__c field
	        
	        // AFTER INSERT
	        if (!alreadyRunAfterInsert && triggerAction == TDTM_Runnable.Action.AfterInsert) {
	            UTIL_Debug.debug('ADDR_Contact_TDTM after insert.');
	            alreadyRunAfterInsert = true;
	            
	            contactIDToAccRecTypeID = getContactIdToAccRecTypeId(listNew);
	            
	            for (SObject so : listNew) {
	                Contact contact = (Contact)so;
	                Boolean childOfHousehold = contactIDToAccRecTypeID.get(contact.ID) == UTIL_Describe.getHhAccRecTypeID();
		            
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
                    //For new Contacts that are using address management and are not children of Household, create the address object. We do it in the after, so that the 
                    //Parent_Contact__c field in Address can point back to the Contact.
                    } else if (!childOfHousehold &&  UTIL_CustomSettingsFacade.getSettings().Contacts_Addresses_Enabled__c == true && !ADDR_Addresses_UTIL.isContactAddressEmpty(contact)) {
		                UTIL_Debug.debug('****Address record should be created as child of Contact');
		                contactsCreateAddrFrom.add(contact);
		            }
	            }
	        }
	        
	        // AFTER UPDATE
	        if (!alreadyRunAfterUpdate && triggerAction == TDTM_Runnable.Action.AfterUpdate) {
	            UTIL_Debug.debug('****ADDR_Contact_TDTM after update.');
                alreadyRunAfterUpdate = true;
                
                //To know if a contact belongs to a household (if the parent account has Household record type) 
                contactIDToAccRecTypeID = getContactIdToAccRecTypeId(listNew);
            
	            Integer i = 0;
	            for (SObject so : listNew) {
	                Contact contact = (Contact)so;
	                UTIL_Debug.debug('****Contact after update: ' + JSON.serializePretty(contact));
	                Boolean childOfHousehold = contactIDToAccRecTypeID.get(contact.ID) == UTIL_Describe.getHhAccRecTypeID();
	                Contact contactOld = (Contact)listOld[i];
	                UTIL_Debug.debug('****ContactOld after update: ' + JSON.serializePretty(contactOld));
	                
	                Boolean addrInfoChanged = ADDR_Addresses_UTIL.isContactAddressChanged(contact, contactOld);
	                UTIL_Debug.debug('****addrInfoChanged after update: ' + addrInfoChanged);
	                
	                Boolean addrInfoCleared = !ADDR_Addresses_UTIL.iscontactAddressEmpty(contactOld) && ADDR_Addresses_UTIL.iscontactAddressEmpty(contact);
	                UTIL_Debug.debug('****addrInfoCleared after update: ' + addrInfoCleared);
	                
	                Boolean currentAddressChanged = contact.Current_Address__c != contactOld.Current_Address__c && contact.Current_Address__c != null;
	                UTIL_Debug.debug('****currentAddressChanged after update: ' + currentAddressChanged);
	                	                
	                // if they are changing to a new Current Address, but address info doesn't change, refill from it (both household and not household)
                    if (currentAddressChanged) { 
                        if(!addrInfoChanged) {
		                    UTIL_Debug.debug('****Contact switching current address');
		                    contactsAddrGetFromHh.add(contact);
		                    if(contact.is_Address_Override__c == true && contactOld.is_Address_Override__c == false)
		                        addrIdsOverride.put(contact.Current_Address__c, true);
                        }  else {
                            UTIL_Debug.debug('****Current address changed & address info also changed');
                        }
                    } else { 
			            //If Contact Addresses are enabled, and the Contact is not the child of a HH 
			            if(!childOfHousehold && UTIL_CustomSettingsFacade.getSettings().Contacts_Addresses_Enabled__c == true) {
			                if(addrInfoChanged && !addrInfoCleared && !currentAddressChanged) {
			                   UTIL_Debug.debug('****Non-household Contact addr info changed.'); 
			                   contactsCreateAddrFrom.add(contact);
			                } else if(addrInfoCleared) {
			                   UTIL_Debug.debug('****Non-household Contact addr info cleared.');
			                   contactsAddrInfoCleared.add(contact);
			                }
			            } else if(childOfHousehold) {
			                UTIL_Debug.debug('****Updated contact is child of household');
			                
			                // if the Contact has been changed to a different household
	                        if(contactOld != null && contact.AccountID != contactOld.AccountID && !currentAddressChanged) {
	                            UTIL_Debug.debug('****Updated household contact has been moved to different household');
	                            
	                            // if no override, refill from the Default Address
	                            if (!contact.is_Address_Override__c && !addrInfoChanged) {
	                                //Refilling address info from parent Household
	                                contactsAddrInfoReset.add(contact);
	                            
	                            //if override, create new Address record
	                            } else if(contact.is_Address_Override__c && !addrInfoChanged) {
	                                UTIL_Debug.debug('****Household contact has override --> create new Address in new household');
	                                //If Current_Address__c has been changed, address info needs to be retrieved from Current_Address__c
	                                /*if(contact.Current_Address__c != null && contact.Current_Address__c != contactOld.Current_Address__c && !contact.is_Address_Override__c) {
	                                    contactsAddrGetFromHh.add(contact);
	                                //Address record needs to be created as child of parent Account
	                                } else {*/                                   
	                                    contactsCreateAddrFrom.add(contact);
	                                //}
	                            }
			                //Contact not switching household
	                        } else {
	                            UTIL_Debug.debug('****Contact has not switched household');
				                // if the address changed  
				                if (addrInfoChanged && !addrInfoCleared && !currentAddressChanged) {
			                        UTIL_Debug.debug('****Household contact Addr info changed.'); 
			                        //create new Address as child of parent Account
			                        contactsCreateAddrFrom.add(contact);
			                        if(!contact.is_Address_Override__c)
			                            //Address needs to be copied to parent Household, and all siblings that don't have an override.
			                            contactsAddrPropagate.add(contact);
			                    
			                    // if the address info has been removed
			                    } else if (addrInfoCleared) {
				                    UTIL_Debug.debug('****Household contact Addr info cleared.');
				                    contactsAddrInfoCleared.add(contact);
				                    //if the contact was not override, but pointing to the default Address instead
				                    if(!contact.is_Address_Override__c)
				                        contactsAddrPropagateDelete.add(contact);
			                    
			                    // if they are clearing isAddressOverride, refill from the Default Address
				                } else if (!contact.is_Address_Override__c && contact.is_Address_Override__c != contactOld.is_Address_Override__c) {
		                            UTIL_Debug.debug('****is_Address_Override__c cleared');
		                            contactsAddrInfoReset.add(contact);
		                            if (contactOld.Current_Address__c != null) {
		                                // old current address (before clearing override) needs to have Latest_End_Date updated
		                                addrIdsOverride.put(contactOld.Current_Address__c, false);
		                                UTIL_Debug.debug('****There is an address to fill contact info from');
		                            }
		                        }	                        
			                }
			            }
                    }  
		            i++;
	            }
	        }

	        // set the mailing address for contacts who specify an address lookup or override
	        if(contactsAddrGetFromHh.size() > 0)
	            setConAddrFromLookup(contactsAddrGetFromHh, triggerAction, dmlWrapper);
	        
	        // reset the mailing address for contacts who no longer have an address override
	        if(contactsAddrInfoReset.size() > 0)
	            resetConAddrInfo(contactsAddrInfoReset, triggerAction, dmlWrapper);

	        // update the latest date fields on any address overrides
	        if(addrIdsOverride.size() > 0) 
	            ADDR_Addresses_UTIL.updateAddrIsOverride(addrIdsOverride, dmlWrapper);
	
	        // create any new Address objects
	        if(contactsCreateAddrFrom.size() > 0)
	            createAddrFromContact(contactsCreateAddrFrom, contactIDToAccRecTypeID, dmlWrapper);
	        
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
    
    private Map<ID, ID> getContactIdToAccRecTypeId(List<SObject> listNew) {
        Map<ID, ID> contactIDToAccRecTypeID = new Map<ID, ID>();
        Map<ID, ID> accIDToAccRecTypeID = new Map<ID, ID>();
        List<ID> accIDs = new List<ID>();
        for(SObject so : listNew) {
            Contact contact = (Contact)so;
            ID parentAccID = contact.AccountID;
            accIDs.add(parentAccID);
        }
        
        List<Account> parentAccs = [select ID, RecordTypeID from Account where ID in :accIDs];
        for(Account acc : parentAccs) {
            accIDToAccRecTypeID.put(acc.ID, acc.RecordTypeID);
        }
        
        for(SObject so : listNew) {
            Contact contact = (Contact)so;
            ID parentAccRecTypeID = accIDToAccRecTypeID.get(contact.AccountID);
            contactIDToAccRecTypeID.put(contact.ID, parentAccRecTypeID);
        }
        return contactIDToAccRecTypeID;
    }
    
    private void propagateAddrInfo(List<Contact> contactsAddrPropagate, DmlWrapper dmlWrapper) {
        //Create map to use when excluding contacts in trigger from propagation, below
        Map<ID, Contact> originalContactsMap = new Map<ID, Contact>();
        for(Contact contact : contactsAddrPropagate) {
            if(contact.ID != null) {
                originalContactsMap.put(contact.ID, contact);
            }
        }
        UTIL_Debug.debug('****OriginalContactsMap: ' + JSON.serializePretty(originalContactsMap));
        
        Set<ID> parentAccIDs = new Set<ID>();
        //Gather all parent Acc IDs
        for(Contact contact : contactsAddrPropagate) {
            parentAccIDs.add(Contact.AccountId);
        }
        UTIL_Debug.debug('****parentAccIDs: ' + parentAccIDs);
        //Query for parent Acc and sibling Contacts
        String query = getParentAccsWithChildrenQuery() + ' :parentAccIDs';
        UTIL_Debug.debug('****getParentAccsWithChildrenQuery: ' + query);
        List<Account> parentAccsWithChildren = Database.query(query);
        for(Account acc : parentAccsWithChildren) {
            List<Contact> children = acc.Contacts;
            //Find the original Contact, that is part of the trigger
            Contact originalContact;
            for(Contact child : children) {
                if(originalContactsMap.containsKey(child.ID)) {
                    originalContact = child;
                    break;
                }
            }
            //Copy Address info to parent and siblings
            if(originalContact != null) {
	            //Copy address info to parent Account
	            ADDR_Addresses_UTIL.copyAddressStdSObj(originalContact, 'Mailing', acc, 'Billing');
	            UTIL_Debug.debug('****Address info copied to parent Account: ' + JSON.serializePretty(acc));
	            DmlWrapper.objectsToUpdate.add(acc);
	            //Copy address info to each sibling - we need to exclude the one the trigger is running on!
	            for(Contact contact : acc.Contacts) {
	                if(contact.ID != originalContact.ID && !contact.is_Address_Override__c) {
	                   contact.Primary_Address_Type__c = originalContact.Primary_Address_Type__c;
	                   ADDR_Addresses_UTIL.copyAddressStdSObj(originalContact, 'Mailing', contact, 'Mailing');
	                   UTIL_Debug.debug('****Address info copied to sibling Contact: ' + JSON.serializePretty(contact));
	                   DmlWrapper.objectsToUpdate.add(contact);
	                }
	            }
            }
        } 
    }
    
    private String getParentAccsQuery() {
        String query = getAccAddrFieldsQuery();
        query += ' from Account where Id IN ';
        return query;
    }
    
    private String getParentAccsWithChildrenQuery() {
        String query = getAccAddrFieldsQuery();
        query += ', (select Current_Address__c, is_Address_Override__c, Primary_Address_Type__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Account.Contacts)';  
        query += ', (select Default_Address__c from Account.Addresses__r)';
        query +=  ' from Account where Id IN ';
        return query;
    }
    
    private String getAccAddrFieldsQuery() {
        String query = 'select Current_Address__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude';     
        if (ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled)
            query += ', BillingCountryCode, BillingStateCode ';
        return query;
    }
    
    private void propagateAddrInfoDelete(List<Contact> contactsAddrPropagate, DmlWrapper dmlWrapper) {
        //Create map to use when excluding contacts in trigger from propagation, below
        Map<ID, Contact> contactsMap = new Map<ID, Contact>();
        for(Contact contact : contactsAddrPropagate) {
            if(contact.ID != null) {
                contactsMap.put(contact.ID, contact);
            }
        }
        
        Set<ID> parentAccIDs = new Set<ID>();
        //Gather all parent Acc IDs
        for(Contact contact : contactsAddrPropagate) {
            parentAccIDs.add(Contact.AccountId);
        }
        //Query for parent Acc and sibling Contacts
        List<Account> parentAccsWithChildren = Database.query(getParentAccsWithChildrenQuery() + ' :parentAccIDs');
        for(Account acc : parentAccsWithChildren) {
            List<Contact> childContacts = acc.Contacts;
            //Find the original Contact, that is part of the trigger
            Contact originalContact;
            for(Contact childContact : childContacts) {
                if(contactsMap.containsKey(childContact.ID)) {
                    originalContact = childContact;
                    break;
                }
            }
            //Clear Address info from parent and siblings
            if(originalContact != null) {
                //Clear current_address field from original contact
                //originalContact.Current_Address__c = null; --> this is done in addrInfoDeleted!
                //dmlWrapper.objectsToUpdate.add(originalContact);
                //Clear address info from parent Account
                acc.Current_Address__c = null;
                ADDR_Addresses_UTIL.clearAddrInfo(acc);
                dmlWrapper.objectsToUpdate.add(acc);
                //Clear address info from each sibling - we need to exclude the one the trigger is running on!
                for(Contact contact : acc.Contacts) {
                    if(contact.ID != originalContact.ID && !contact.is_Address_Override__c) {
                       contact.Current_Address__c = null;
                       ADDR_Addresses_UTIL.clearAddrInfo(contact);
                       DmlWrapper.objectsToUpdate.add(contact);
                    }
                }
            }
            //Clear Default_Address__c field from address record that was the default
            List<Address__c> childAddrs = acc.Addresses__r;
            for(Address__c childAddr : childAddrs) {
                if(childAddr.Default_Address__c) {
                    childAddr.Default_Address__c = false;
                    dmlWrapper.objectsToUpdate.add(childAddr);
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
    private void createAddrFromContact(List<Contact> listContact, Map<ID, ID> contactIDToAccRecTypeID, DmlWrapper dmlWrapper) {
        
        List<Address__c> newAddrs = new List<Address__c>();
        for (Contact contact : listContact) {
            Address__c addr = new Address__c();
            if(contactIDToAccRecTypeID.get(contact.ID) == UTIL_Describe.getHhAccRecTypeID()) {
                UTIL_Debug.debug('****Creating address as child of Account');
                addr.Parent_Account__c = contact.AccountId;
            } else {
                UTIL_Debug.debug('****Creating address as child of Contact');
                addr.Parent_Contact__c = contact.Id;    
            }
            addr.Default_Address__c = !contact.is_Address_Override__c;
            addr.Latest_Start_Date__c = System.today();
            addr.Latest_End_Date__c = null;
            addr.Address_Type__c = contact.Primary_Address_Type__c;
            ADDR_Addresses_UTIL.copyAddressStdSObjAddr(contact, 'Mailing', addr, null);            
            newAddrs.add(addr);
        }
        UTIL_Debug.debug('****Address records to create: ' + JSON.serializePretty(newAddrs));
        
        //since coming from an Contact address, there is no Address Type, so exclude it from the match testing.
        ADDR_Addresses_UTIL.NonDupeAddrs nonDupeAddrs = ADDR_Addresses_UTIL.getNonDuplicateAddresses(newAddrs, false);
        //UTIL_Debug.debug('****Non-duplicate address records to create: ' + JSON.serializePretty(nonDupeAddrs));
        nonDupeAddrs.performDml();
        
        //Match each Contact or Account with each new address
        List<ID> parentContactIDs = new List<ID>();
        List<ID> parentAccountIDs = new List<ID>();
        Map<ID, Address__c> parentContactIdToAddrMap = new Map<ID, Address__c>();
        Map<ID, Address__c> parentAccountIdToAddrMap = new Map<ID, Address__c>();
        for(Address__c addr : nonDupeAddrs.newAddrs) {
            if(addr.Parent_Contact__c != null) {
               UTIL_Debug.debug('****Putting new address with parent Contact in map');
               parentContactIDs.add(addr.Parent_Contact__c);
               parentContactIdToAddrMap.put(addr.Parent_Contact__c, addr);  
            } else if(addr.Parent_Account__c != null) {
               UTIL_Debug.debug('****Putting new address with parent Account in map');
               parentAccountIDs.add(addr.Parent_Account__c);
               parentAccountIdToAddrMap.put(addr.Parent_Account__c, addr); 
            }
        }
        
        //Putting updated addresses in data structure, to be able to uncheck other defaults (below)
        for(Address__c addr : nonDupeAddrs.updatedAddrs) {
            if(addr.Parent_Contact__c != null) {
               UTIL_Debug.debug('****Putting updated address with parent Contact in map');
               parentContactIDs.add(addr.Parent_Contact__c);
               parentContactIdToAddrMap.put(addr.Parent_Contact__c, addr);  
            } else if(addr.Parent_Account__c != null) {
               UTIL_Debug.debug('****Putting updated address with parent Account in map');
               parentAccountIDs.add(addr.Parent_Account__c);
               parentAccountIdToAddrMap.put(addr.Parent_Account__c, addr); 
            }
        }
        
        //We need to re-query because we are in the "after" part of the trigger. We cannot change it to the "before" because
        //we need the Contact ID field to have a value when populating the addr.Parent_Contact__c field above.
        List<Account> parentAccounts = [select Current_Address__c, (select ID from Account.Contacts),
                                        (select Default_Address__c, Latest_Start_Date__c, Latest_End_Date__c from Account.Addresses__r)
                                        from Account where ID in :parentAccountIDs];
        List<Contact> parentContacts = [select is_Address_Override__c, Current_Address__c,
                                        (select Default_Address__c, Latest_Start_Date__c, Latest_End_Date__c from Contact.Addresses__r)
                                        from Contact where ID in :parentContactIDs];
                
        for(Account acc : parentAccounts) {
            Address__c childAddr = parentAccountIdToAddrMap.get(acc.Id);
            if(childAddr != null) {
                if(childAddr.Default_Address__c)
                    ADDR_Addresses_UTIL.uncheckDefaultOtherAddrs(childAddr, acc.Addresses__r, dmlWrapper);
                UTIL_Debug.debug('****Linking current address with Account');
                acc.Current_Address__c = childAddr.Id;
                dmlWrapper.objectsToUpdate.add(acc);
                if(acc.Contacts != null) {
	                UTIL_Debug.debug('****Linking children of the Account with current address: ' + childAddr.Id);
	                for(Contact contact : acc.Contacts) {
	                    contact.Current_Address__c = childAddr.Id;
                        dmlWrapper.objectsToUpdate.add(contact);
	                }
                }
            }
        }
        
        for(Contact contact : parentContacts) {
            Address__c childAddr = parentContactIdToAddrMap.get(contact.Id);
            if(childAddr != null && !contact.is_Address_Override__c) {
                if(childAddr.Default_Address__c)
                    ADDR_Addresses_UTIL.uncheckDefaultOtherAddrs(childAddr, contact.Addresses__r, dmlWrapper);
                UTIL_Debug.debug('****Linking Contact with current address: ' + childAddr.Id);
                contact.Current_Address__c = childAddr.Id;
                dmlWrapper.objectsToUpdate.add(contact);
            }
        }
    }
    
    /*******************************************************************************************************
    * @description for each contact, refresh its mailing address from its Address lookup
    * @param listCon the list of Contacts to update
    * @return void  
    ********************************************************************************************************/
    private void setConAddrFromLookup(List<Contact> listCon, TDTM_Runnable.Action triggerAction, DmlWrapper dmlWrapper) {
        Set<Id> setAddrId = new Set<Id>();
        for (Contact contact : listCon) {
            if (contact.Current_Address__c != null)
              setAddrId.add(contact.Current_Address__c);
        }
    
        Map<Id, Address__c> mapAddrIdAddr = new Map<Id, Address__c>([select Id, Address_Type__c, MailingStreet__c, MailingStreet2__c, MailingCity__c, MailingState__c, 
            Geolocation__Latitude__s, Geolocation__Longitude__s, MailingPostalCode__c, MailingCountry__c, 
            (select is_Address_Override__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Address__c.Contacts1__r)
            from Address__c where Id in :setAddrId]);
            
        for (Contact contact : listCon) {
            Address__c addr = mapAddrIdAddr.get(contact.Current_Address__c);           
            if (addr != null) {
                UTIL_Debug.debug('****Refreshing address info in Contact from Current_Address__c: ' + JSON.serializePretty(addr)); 
                //if(triggerAction == TDTM_Runnable.Action.AfterInsert || triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                    Map<ID, Contact> childContacts = new Map<ID, Contact>(addr.Contacts1__r);
                    //Getting the queried contact, because we cannot dml on the same records that were part of the trigger
                    Contact childContact = childContacts.get(contact.ID);
                    if(childContact != null) {
                        childContact.Primary_Address_Type__c = addr.Address_Type__c;
                        ADDR_Addresses_UTIL.copyAddressAddrSObj(addr, childContact, 'Mailing', 'Primary_Address_Type__c', null);
                        UTIL_Debug.debug('****Contact after copying addr info from Current_Address__c: ' + JSON.serializePretty(childContact));
                        dmlWrapper.objectsToUpdate.add(childContact);
                    }
                /*} else {
                    contact.Primary_Address_Type__c = addr.Address_Type__c;
                    ADDR_Addresses_UTIL.copyAddressAddrSObj(addr, contact, 'Mailing', 'Primary_Address_Type__c', null);
                }
                addr.Latest_End_Date__c = System.today();*/
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
        
        //We need to re-query because we are in the "after" part of the trigger
        List<Contact> contacts = [select is_Address_Override__c, Current_Address__c, AccountID, Account.RecordTypeId,
                                    (select Default_Address__c, Latest_Start_Date__c, Latest_End_Date__c from Contact.Addresses__r)
                                    from Contact where ID in :contactsAddrInfoCleared];
        List<ID> accToUpdateIDs = new List<ID>();
        
        for(Contact contact : contacts) {
            // clear Default_Address__c from Address, if set
            List<Address__c> childAddrs = contact.Addresses__r;
            if(childAddrs != null && childAddrs.size() > 0) {
                for(Address__c childAddr : childAddrs) {
                    if(childAddr.Default_Address__c) {
                        UTIL_Debug.debug('****Setting Default_Address__c to false in addrInfoDeleted');
                        childAddr.Default_Address__c = false;
                        dmlWrapper.objectsToUpdate.add(childAddr);
                    }
                }
            }
            // clear Current_Address__c && is_Address_Override__c field from Contacts
            if(contact.Current_Address__c != null) // get all current addrs
                oldCurrentAddrIDs.add(contact.Current_Address__c);
            contact.Current_Address__c = null;
            contact.is_Address_Override__c = false;
            dmlWrapper.objectsToUpdate.add(contact);
            
            // address clearing propagation in case of a Household is done separately
        }
    }
    
    /*******************************************************************************************************
    * @description Finds each Contact's HH current address (either Default or Seasonal) and updates 
    * the contact's address fields
    * @param listCon list of Contacts 
    * @return void  
    ********************************************************************************************************/
    private void resetConAddrInfo(List<Contact> listCon, TDTM_Runnable.Action triggerAction, DmlWrapper dmlWrapper) {
        //Get all parent account IDs together so we can query their address fields
        List<ID> parentAccIDs = new List<ID>();
        for(Contact contact : listCon) {
            if(contact.AccountID != null) {
                parentAccIDs.add(contact.AccountID);
            }
        }
        UTIL_Debug.debug('****parentAccIDs in resetConAddrInfo: ' + parentAccIDs);
        
        String query = getParentAccsWithChildrenQuery() + ' :parentAccIDs';
        UTIL_Debug.debug('****resetConAddrInfo query: ' + query);
        
        List<Account> parentAccs = Database.query(query);
        UTIL_Debug.debug('****parentAccs in resetConAddrInfo: ' + JSON.serializePretty(parentAccs));
        
        Map<ID, Account> parentAccsMap = new Map<ID, Account>(parentAccs); 
        
        //Copy address info from each parent account to each child contact
        for(Contact contact : listCon) {
            if(contact.AccountID != null) {
                Account acc = parentAccsMap.get(contact.AccountID);
                UTIL_Debug.debug('****Account after calling copyAddressStdSObj on reset: ' + JSON.serializePretty(acc));
                
                if(triggerAction == TDTM_Runnable.Action.AfterInsert || triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                    //We need to get the contact we have just queried - cannot update the one in the after part of the trigger
                    for(Contact childContact : acc.Contacts) {
                        if(childContact.Id == contact.Id) {                
	                        ADDR_Addresses_UTIL.copyAddressStdSObj(acc, 'Billing', childContact, 'Mailing');
	                        UTIL_Debug.debug('****Contact after calling copyAddressStdSObj on reset: ' + JSON.serializePretty(childContact));
	                        dmlWrapper.objectsToUpdate.add(childContact);
                        }
                    }
                } else {
                    ADDR_Addresses_UTIL.copyAddressStdSObj(acc, 'Billing', contact, 'Mailing');  
                }
            }
        }   
    }
}