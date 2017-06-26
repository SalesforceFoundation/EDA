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
    
    /* @description Flag to prevent recursive call on insert */
    public static Boolean alreadyRunAfterInsert = false;
    /* @description Flag to prevent recursive call on update */
    public static Boolean alreadyRunAfterUpdate = false;
    /* @description Flag used to indicate if this class is running as a result of an automatic Account creation caused by a Contact insert/update */
    public static Boolean afterAutomaticAccInsert = false;
    
    /*******************************************************************************************************
    * @description Turns class off.
    * @return void
    ********************************************************************************************************/
    public static void turnOff() {
        alreadyRunAfterInsert = true;
        alreadyRunAfterUpdate = true;
    }
    
    /*******************************************************************************************************
    * @description Turns class on.
    * @return void
    ********************************************************************************************************/
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
	        Map<ID, ID> contactIdParentIdAddrPropagate = new Map<ID, ID>();
	        
	        //List of Contact IDs that need their address info deletion propagated to the parent and all siblings without override
	        List<Contact> contactsAddrPropagateDelete = new List<Contact>();
	        
	        //Map of Address IDs to Boolean, with the Boolean representing if the Address needs its Latest Date fields updated.
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
	            alreadyRunAfterInsert = true;
	            
	            contactIDToAccRecTypeID = getContactIdToAccRecTypeId(listNew);
	            	            
	            for (SObject so : listNew) {
	                Contact contact = (Contact)so;
	                Boolean childOfHousehold = contactIDToAccRecTypeID.get(contact.ID) != null &&
	                                           contactIDToAccRecTypeID.get(contact.ID) == UTIL_CustomSettingsFacade.getSettings().Household_Addresses_RecType__c;
		            
		            if (childOfHousehold) {
		                if (ADDR_Addresses_UTIL.isContactAddressEmpty(contact)) {
                           // if the contact has no address specified, pick up the HH default.
                           contactsAddrInfoReset.add(contact);
                        } else { //address info not empty
	                        if (contact.is_Address_Override__c) {
	                            //create non-default address record
	                            contactsCreateAddrFrom.add(contact);
	                        } else {
	                            //Address record needs to be created as child of parent Account (can be done in the Before cuz we already have the ID to populate Parent_Account__c)
	                            contactsCreateAddrFrom.add(contact);
	                            //Address needs to be copied to parent Household, and all siblings that don't have an override.
	                            contactIdParentIdAddrPropagate.put(contact.ID, contact.AccountID);
	                        }
		                }
                    //For new Contacts that are using address management and are not children of Household, create the address object. We do it in the after, so that the
                    //Parent_Contact__c field in Address can point back to the Contact.
                    } else if (!childOfHousehold && UTIL_CustomSettingsFacade.getSettings().Contacts_Addresses_Enabled__c == true
                    && !ADDR_Addresses_UTIL.isContactAddressEmpty(contact) && !afterAutomaticAccInsert) {
		                contactsCreateAddrFrom.add(contact);
		            }
	            }
	        }
	        
	        // AFTER UPDATE
	        if (!alreadyRunAfterUpdate && triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                alreadyRunAfterUpdate = true;
                
                //To know if a contact belongs to a household (if the parent account has Household record type)
                contactIDToAccRecTypeID = getContactIdToAccRecTypeId(listNew);
            
	            Integer i = 0;
	            for (SObject so : listNew) {
	                Contact contact = (Contact)so;
	                Boolean childOfHousehold = contactIDToAccRecTypeID.get(contact.ID) != null &&
	                                           contactIDToAccRecTypeID.get(contact.ID) == UTIL_CustomSettingsFacade.getSettings().Household_Addresses_RecType__c;
	                Contact contactOld = (Contact)listOld[i];
	                
	                Boolean addrInfoChanged = ADDR_Addresses_UTIL.isContactAddressChanged(contact, contactOld);
	                Boolean addrInfoCleared = !ADDR_Addresses_UTIL.iscontactAddressEmpty(contactOld) && ADDR_Addresses_UTIL.iscontactAddressEmpty(contact);
	                Boolean currentAddressChanged = contact.Current_Address__c != contactOld.Current_Address__c && contact.Current_Address__c != null;
	                	                
	                // if they are changing to a new Current Address, but address info doesn't change, refill from it (both household and not household)
                    if (currentAddressChanged) {
                        if(!addrInfoChanged) {
		                    contactsAddrGetFromHh.add(contact);
		                    if(contact.is_Address_Override__c == true && contactOld.is_Address_Override__c == false)
		                        addrIdsOverride.put(contact.Current_Address__c, true);
                        }  else {
                            UTIL_Debug.debug('****Current address changed & address info also changed');
                        }
                    } else {
			            //If Contact Addresses are enabled, and the Contact is not the child of a HH
			            if(!childOfHousehold && UTIL_CustomSettingsFacade.getSettings().Contacts_Addresses_Enabled__c == true) {
			                //Non-household Contact addr info changed
			                if(addrInfoChanged && !addrInfoCleared && !currentAddressChanged) {
			                   contactsCreateAddrFrom.add(contact);
			                //Non-household Contact addr info cleared
			                } else if(addrInfoCleared) {
			                   contactsAddrInfoCleared.add(contact);
			                }
			            } else if(childOfHousehold) {
			                
			                // if the Contact has been changed to a different household
	                        if(contactOld != null && contact.AccountID != contactOld.AccountID && !currentAddressChanged) {
	                            
	                            // if no override, refill from the Default Address
	                            if (!contact.is_Address_Override__c) {
	                                //Refilling address info from parent Household (unless parent account address info is empty),
	                                //and unless we are coming from the automatic parent Account creation.
	                                if(!afterAutomaticAccInsert) {
	                                   contactsAddrInfoReset.add(contact);
	                                } else {
	                                   contactsCreateAddrFrom.add(contact);
	                                }
	                            
	                            //if override, create new Address record in new household
	                            } else if(contact.is_Address_Override__c && !addrInfoChanged) {
	                                contactsCreateAddrFrom.add(contact);
	                            }
			                //Contact not switching household
	                        } else {
				                // if household Contact addr info changed
				                if (addrInfoChanged && !addrInfoCleared && !currentAddressChanged) {
			                        //create new Address as child of parent Account
			                        contactsCreateAddrFrom.add(contact);
			                        if(!contact.is_Address_Override__c)
			                            //Address needs to be copied to parent Household, and all siblings that don't have an override.
			                            contactIdParentIdAddrPropagate.put(contact.ID, contact.AccountID);
			                    
			                    // if household Contact addr info cleare
			                    } else if (addrInfoCleared) {
				                    contactsAddrInfoCleared.add(contact);
				                    //if the contact was not override, but pointing to the default Address instead
				                    if(!contact.is_Address_Override__c)
				                        contactsAddrPropagateDelete.add(contact);
			                    
			                    // if they are clearing isAddressOverride, refill from the Default Address
				                } else if (!contact.is_Address_Override__c && contact.is_Address_Override__c != contactOld.is_Address_Override__c) {
		                            contactsAddrInfoReset.add(contact);
		                            // if tthere is an address to fill contact info from
		                            if (contactOld.Current_Address__c != null) {
		                                // old current address (before clearing override) needs to have Latest_End_Date updated
		                                addrIdsOverride.put(contactOld.Current_Address__c, false);
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
	            createAddrsFromContacts(contactsCreateAddrFrom, contactIDToAccRecTypeID, dmlWrapper);
	        
	        // handle Contacts with address info removed
	        if(contactsAddrInfoCleared.size() > 0)
	            addrInfoDeleted(contactsAddrInfoCleared, dmlWrapper);
	    
	        // propagate address info to parent Household and and siblings without override
	        if(contactIdParentIdAddrPropagate.size() > 0)
	            propagateAddrInfo(contactIdParentIdAddrPropagate);
	            
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
    
    private static void propagateAddrInfo(Map<ID, ID> contactIdParentIdAddrPropagate) {
            
        //Create map to use when excluding contacts in trigger from propagation, below
        Set<ID> originalContactIDs = contactIdParentIdAddrPropagate.keySet();
        
        Set<ID> parentAccIDs = new Set<ID>();
        //Gather all parent Acc IDs
        for(ID accId : contactIdParentIdAddrPropagate.values()) {
            parentAccIDs.add(accId);
        }
        
        List<Account> accountsToUpdate = new List<Account>();
        List<Contact> contactsToUpdate = new List<Contact>();
        
        //Query for parent Acc and sibling Contacts
        String query = ADDR_Addresses_UTIL.getParentAccsWithChildrenQuery() + ' :parentAccIDs';
        List<Account> parentAccsWithChildren = Database.query(query);
        for(Account acc : parentAccsWithChildren) {
            List<Contact> children = acc.Contacts;
            //Find the original Contact, that is part of the trigger
            Contact originalContact;
            for(Contact child : children) {
                if(originalContactIDs.contains(child.ID)) {
                    originalContact = child;
                    break;
                }
            }
            //Copy Address info to parent and siblings, if it's different
            if(originalContact != null && !ADDR_Addresses_UTIL.isContactAccAddrInfoSame(originalContact, acc)) {
	            
	            //Copy address info to parent Account
	            ADDR_Addresses_UTIL.copyAddressStdSObj(originalContact, 'Mailing', acc, 'Billing');
	            accountsToUpdate.add(acc);
	            
	            //Copy address info to each sibling - we need to exclude the one the trigger is running on!
	            for(Contact contact : acc.Contacts) {
	                if(contact.ID != originalContact.ID && !contact.is_Address_Override__c) {
	                   contact.Primary_Address_Type__c = originalContact.Primary_Address_Type__c;
	                   ADDR_Addresses_UTIL.copyAddressStdSObj(originalContact, 'Mailing', contact, 'Mailing');
	                   contactsToUpdate.add(contact);
	                }
	            }
	        //If the address info is the same, just update the Current_Address__c field in the original contact
            } else if(originalContact != null && ADDR_Addresses_UTIL.isContactAccAddrInfoSame(originalContact, acc)) {
                originalContact.Current_Address__c = acc.Current_Address__c;
                contactsToUpdate.add(originalContact);
            }
        }
        //explicitly doing the update, because if we put the records in DmlWrapper we get a "duplicate id in list" error due to
        //the method updateAccountPrimaryContact in ACCT_IndividualAccounts_TDTM also putting them there.
        List<SObject> objectsToUpdate = new List<SObject>();
        objectsToUpdate.addAll((List<SObject>)accountsToUpdate);
        objectsToUpdate.addAll((List<SObject>)contactsToUpdate);
        update objectsToUpdate;
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
        List<Account> parentAccsWithChildren = Database.query(ADDR_Addresses_UTIL.getParentAccsWithChildrenQuery() + ' :parentAccIDs');
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
                //No need to clear current_address field from original contact --> this is done in addrInfoDeleted!
                
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
    private void createAddrsFromContacts(List<Contact> listContact, Map<ID, ID> contactIDToAccRecTypeID, DmlWrapper dmlWrapper) {
        Set<ID> originalContactIDs = new Set<ID>();
        for(Contact contact : listContact) {
            originalContactIDs.add(contact.ID);
        }
        
        List<Address__c> newAddrs = new List<Address__c>();
        for (Contact contact : listContact) {
            Address__c addr = new Address__c();
            //Creating address as child of Account
            if(UTIL_CustomSettingsFacade.getSettings().Household_Addresses_RecType__c != null
            && contactIDToAccRecTypeID.get(contact.ID) == UTIL_CustomSettingsFacade.getSettings().Household_Addresses_RecType__c) {
                addr.Parent_Account__c = contact.AccountId;
            //Creating address as child of Contact
            } else {
                addr.Parent_Contact__c = contact.Id;
            }
            addr.Default_Address__c = !contact.is_Address_Override__c;
            addr.Latest_Start_Date__c = System.today();
            addr.Latest_End_Date__c = null;
            addr.Address_Type__c = contact.Primary_Address_Type__c;
            ADDR_Addresses_UTIL.copyAddressStdSObjAddr(contact, 'Mailing', addr, null);
            newAddrs.add(addr);
        }
        
        //Since coming from an Contact address, there is no Address Type, so exclude it from the match testing.
        //De-duplicate Address records.
        ADDR_Addresses_UTIL.NonDupeAddrs nonDupeAddrs = ADDR_Addresses_UTIL.getNonDuplicateAddresses(newAddrs, false);
        nonDupeAddrs.performDml();
        
        //Match each Contact or Account with each new address
        List<ID> parentContactIDs = new List<ID>();
        List<ID> parentAccountIDs = new List<ID>();
        Map<ID, Address__c> parentContactIdToAddrMap = new Map<ID, Address__c>();
        Map<ID, Address__c> parentAccountIdToAddrMap = new Map<ID, Address__c>();
        
        for(Address__c addr : nonDupeAddrs.newAddrs) {
            //Putting new address with parent Contact in map
            if(addr.Parent_Contact__c != null) {
               parentContactIDs.add(addr.Parent_Contact__c);
               parentContactIdToAddrMap.put(addr.Parent_Contact__c, addr);

            //Putting new address with parent Account in map
            } else if(addr.Parent_Account__c != null) {
               parentAccountIDs.add(addr.Parent_Account__c);
               parentAccountIdToAddrMap.put(addr.Parent_Account__c, addr);
            }
        }
        
        //Putting updated addresses in data structure, to be able to uncheck other defaults (below)
        for(Address__c addr : nonDupeAddrs.updatedAddrs) {
            //Putting updated address with parent Contact in map
            if(addr.Parent_Contact__c != null && addr.Default_Address__c) {
               parentContactIDs.add(addr.Parent_Contact__c);
               parentContactIdToAddrMap.put(addr.Parent_Contact__c, addr);

            //Putting updated address with parent Account in map
            } else if(addr.Parent_Account__c != null && addr.Default_Address__c) {
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
        
        List<Account> accountsToUpdate = new List<Account>();
        List<Contact> contactsToUpdate = new List<Contact>();
              
        for(Account acc : parentAccounts) {
            Address__c childAddr = parentAccountIdToAddrMap.get(acc.Id);
            if(childAddr != null) {
                if(childAddr.Default_Address__c) {
                    ADDR_Addresses_UTIL.uncheckDefaultOtherAddrs(childAddr, acc.Addresses__r, dmlWrapper);
	                //Linking Account with Address
	                acc.Current_Address__c = childAddr.Id;
	                accountsToUpdate.add(acc);
                }
                if(acc.Contacts != null) {
	                for(Contact contact : acc.Contacts) {
	                    //Linking children of the Account with Address.
	                    if(childAddr.Default_Address__c || originalContactIDs.contains(contact.ID)) {
	                       contact.Current_Address__c = childAddr.Id;
                           contactsToUpdate.add(contact);
	                    }
	                }
                }
            }
        }
        
        for(Contact contact : parentContacts) {
            Address__c childAddr = parentContactIdToAddrMap.get(contact.Id);
            if(childAddr != null && !contact.is_Address_Override__c) {
                if(childAddr.Default_Address__c)
                    ADDR_Addresses_UTIL.uncheckDefaultOtherAddrs(childAddr, contact.Addresses__r, dmlWrapper);
                //Linking Contact with current address.
                contact.Current_Address__c = childAddr.Id;
                contactsToUpdate.add(contact);
            }
        }
        //explicitly doing the update, because if we put the records in DmlWrapper we get a "duplicate id in list" error due to
        //the method propagateAddrInfo also updating the same records.
        List<SObject> objectsToUpdate = new List<SObject>();
        objectsToUpdate.addAll((List<SObject>)accountsToUpdate);
        objectsToUpdate.addAll((List<SObject>)contactsToUpdate);
        update objectsToUpdate;
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
                //Refreshing address info in Contact from Current_Address__c.
                Map<ID, Contact> childContacts = new Map<ID, Contact>(addr.Contacts1__r);
                //Getting the queried contact, because we cannot dml on the same records that were part of the trigger
                Contact childContact = childContacts.get(contact.ID);
                if(childContact != null) {
                    childContact.Primary_Address_Type__c = addr.Address_Type__c;
                    ADDR_Addresses_UTIL.copyAddressAddrSObj(addr, childContact, 'Mailing', 'Primary_Address_Type__c', null);
                    dmlWrapper.objectsToUpdate.add(childContact);
                }
            }
        }
    }

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
                        //Setting Default_Address__c to false in addrInfoDeleted.
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
        Set<ID> parentAccIDs = new Set<ID>();
        for(Contact contact : listCon) {
            if(contact.AccountID != null) {
                parentAccIDs.add(contact.AccountID);
            }
        }
        
        List<Account> parentAccs = Database.query(ADDR_Addresses_UTIL.getParentAccsWithChildrenQuery() + ' :parentAccIDs');
        
        Map<ID, Account> parentAccsMap = new Map<ID, Account>(parentAccs);
        
        //Copy address info from each parent account to each child contact
        for(Contact contact : listCon) {
            if(contact.AccountID != null) {
                Account acc = parentAccsMap.get(contact.AccountID);
                
                if(triggerAction == TDTM_Runnable.Action.AfterInsert || triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                    //We need to get the contact we have just queried - cannot update the one in the after part of the trigger
                    for(Contact childContact : acc.Contacts) {
                        if(childContact.Id == contact.Id) {
                            if(!ADDR_Addresses_UTIL.isAccAddressEmpty(acc)) {
	                            ADDR_Addresses_UTIL.copyAddressStdSObj(acc, 'Billing', childContact, 'Mailing');
                            }
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