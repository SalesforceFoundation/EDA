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
    public static Boolean hasRunAddrTrigger = false;
    
    /*******************************************************************************************************
    * @description Trigger Handler on Contact that handles Address Management.
    *   Rules:
    *       inserting new contact - make their address a new default address, unless they say it is an override
    *       updating an existing contact - make their address a new default address, unless they say it is an override
    * @param listNew the list of Contacts from trigger new. 
    * @param listOld the list of Contacts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Contacts 
    * @return dmlWrapper.  
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        //To query additional fields in parent Account
        listNew = [select Account.RecordTypeId, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Current_Address__c, 
                   MailingLatitude, MailingLongitude, is_Address_Override__c, Primary_Address_Type__c from Contact where ID in :listNew];
            
        DmlWrapper dmlWrapper = new DmlWrapper();  
        List<Contact> listcontactCreateAddr = new List<Contact>();      
        List<Contact> listContactsAddrInfoCleared = new List<Contact>();
       
        Integer i = -1;        
        for (SObject so : listNew) {
            Contact contact = (Contact)so;
            i++;
            
            // BEFORE UPDATE
            if (triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
                manageHouseholdAddrs(contact, i, listOld, dmlWrapper);
            }
            
            // AFTER INSERT
            if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
                // for new Contacts that are using address management, create the address object.
                if (UTIL_CustomSettingsFacade.getSettings().Contacts_Addresses_Enabled__c == true) {
                    if (!ADDR_Addresses_UTIL.isContactAddressEmpty(contact))
                        listcontactCreateAddr.add(contact);
                }
            }
    
            // AFTER UPDATE
            if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                UTIL_Debug.debug('***Contact after update in ADDR class');
                // if address change is coming from the address trigger we don't want to create a new address   
                if (!ADDR_Addresses_TDTM.hasRunAddrTrigger) {
                    UTIL_Debug.debug('****Update NOT triggered from ADDR_Addresses_TDTM');
                    if (UTIL_CustomSettingsFacade.getSettings().Contacts_Addresses_Enabled__c == true) {
                        UTIL_Debug.debug('****Contact addresses enabled');
                        Contact contactOld = (Contact)listOld[i];
                        Boolean cleared = !ADDR_Addresses_UTIL.iscontactAddressEmpty(contactOld) && ADDR_Addresses_UTIL.iscontactAddressEmpty(contact);
                        UTIL_Debug.debug('****Address info has been cleared: ' + cleared);
                        // if the address info has been removed
                        if(cleared) {                         
                            listContactsAddrInfoCleared.add(contact);
                        // if the address changed, remember the Contact we want to add a new address for    
                        } else if (ADDR_Addresses_UTIL.isContactAddressChanged(contact, contactOld)) { 
                            listcontactCreateAddr.add(contact);
                        }
                    }
                }
            }                
        }

        // create any new Address objects
        if (listcontactCreateAddr.size() > 0)
            createAddrFromContact(listContactCreateAddr, dmlWrapper);
        
        // handle Contacts with address info removed
        if(listContactsAddrInfoCleared.size() > 0)
            addrInfoDeleted(listContactsAddrInfoCleared, dmlWrapper);
        
        hasRunAddrTrigger = true;
                            
        return dmlWrapper;
    }
    
    private DmlWrapper manageHouseholdAddrs(Contact con, Integer i, List<SObject> listOld, DmlWrapper dmlWrapper) {
        
        list<Contact> listConAddrSet = new list<Contact>(); 
        list<Contact> listConAddrCreate = new list<Contact>();
        list<Contact> listConAddrReset = new list<Contact>();
        
        map<Id, boolean> mapAddrIdIsOverride = new map<Id, boolean>();
        
        // there can be four different types of changes we need to consider
        // A. changes to isAddressOverride
        // B. changes to CurrentAddress
        // C. changes to MailingAddress fields
        // D. changes to Account (ie switching accounts)
        //
        // that leads to 16 permutations! 
        // (it's actually more permutations, since we need to take into account what
        // the change in isAddressOverride or CurrentAddress is).
        //
        // A,B,C       if (CurrentAddress) refill to it, else update/new address object     
        // A,!B,!C     if !isAddrOverride, refill contact from Default Address
        // A,!B,C      if isAddrOverride, update/new addr object and refresh CurrentAddress, else update/new address object
        // A,B,!C      if (CurrentAddress) refill to it, else refill from Default Address
        // !A,B,C      if (CurrentAddress) refill to it, else update/new address object
        // !A,!B,C     update/new address object
        // !A,B,!C     if (CurrentAddress) refill to it, else refill from Default Address
        // !A,!B,!C    nothing!
        // *,*,*,D     if no override, refill from Default Address, else update/new address object 
        //
        // simplifying this to some precedence rules:
        //     - if Account changes && no override && no MailingAddress field changes, refill from Default Address
        //     - if CurrentAddress changes to a new non-null value, refill to it.
        //     - if isAddressOverride changes to false, refill from Default Address
        //     - if MailingAddress field changes, update/new address object
        
        Contact conOld = (Contact)listOld[i];
        
        // new highest priority! if Account changes... 
        if (conOld != null && con.AccountId != conOld.AccountId) {
            // if no override, refill from the Default Address
            if (!con.is_Address_Override__c && !ADDR_Addresses_UTIL.isContactAddressChanged(con, conOld)) {
                listConAddrReset.add(con);
            } else { // create a new address on the account
                listConAddrCreate.add(con);    
            }
        } else {    
            // highest priority. if they are changing to a new Current Address, refill from it.
            if (con.Current_Address__c != conOld.Current_Address__c && con.Current_Address__c != null) {
                listConAddrSet.add(con);
                if (con.is_Address_Override__c)
                    // track which address's need their dates updated
                    mapAddrIdIsOverride.put(con.Current_Address__c, true);                    
            }
            
            // second priority.  if they are clearing isAddressOverride, refill from the Default Address
            if (con.is_Address_Override__c != conOld.is_Address_Override__c && !con.is_Address_Override__c) {
                listConAddrReset.add(con);
                if (conOld.Current_Address__c != null)
                    // track which address's need their dates updated
                    mapAddrIdIsOverride.put(conOld.Current_Address__c, false);
            }
            
            // third priority.  if MailingAddress fields changed, update the existing address object or create a new one.
            // this is handled in the next block, since we do it for both new contacts and updated contacts.
            
            // reset the mailing address for contacts who no longer have an address override
	        if (listConAddrReset.size() > 0) {
	            resetConAddr(listConAddrReset, dmlWrapper);
	            // to avoid pushing these address changes to the HH.
	            ADDR_Addresses_TDTM.hasRunAddrTrigger = true;
	        }
	        
	        // set the mailing address for contacts who specify an address lookup or override
	        if (listConAddrSet.size() > 0) {
	            setConAddrFromLookup(listConAddrSet);
	            // to avoid pushing these address changes to the HH.
	            ADDR_Addresses_TDTM.hasRunAddrTrigger = true;
	        }
    
	        // update the Latest date fields on any address overrides
	        if (mapAddrIdIsOverride.size() > 0) 
	            ADDR_Addresses_UTIL.updateAddrIsOverride(mapAddrIdIsOverride, dmlWrapper);
	            
	        // create any new Default Address objects
	        if (listConAddrCreate.size() > 0)
	            createAddrFromContact(listConAddrCreate, dmlWrapper);                              
        }
        return dmlWrapper;
    }
    
    /*******************************************************************************************************
    * @description for each Contact, create a new default address and add it to dmlWrapper
    * @param Listcontact a List of Contacts
    * @param dmlWrapper to hold the Addresses that need creating
    * @return void
    ********************************************************************************************************/
    private void createAddrFromContact(List<Contact> listContact, DmlWrapper dmlWrapper) {
        List<Address__c> listAddr = new List<Address__c>();
        for (Contact contact : listContact) {
            Address__c addr = new Address__c();
            if(contact.Account.RecordTypeId == UTIL_Describe.getHhAccRecTypeID()) {
                UTIL_Debug.debug('****Creating address as child of Account');
                addr.Parent_Account__c = contact.AccountId;
            } else {
                UTIL_Debug.debug('****Creating address as child of Contact');
                addr.Parent_Contact__c = contact.Id;    
            }
            addr.Default_Address__c = true;
            addr.Latest_Start_Date__c = system.today();
            addr.Latest_End_Date__c = null;
            ADDR_Addresses_UTIL.copyAddressStdSObjAddr(contact, 'Mailing', addr, null);            
            ListAddr.add(addr);
            UTIL_Debug.debug('****New address record: ' + JSON.serializePretty(addr));
        }
        //since coming from an Contact address, there is no Address Type, so exclude it from the match testing.
        List<Address__c> newAddrs = ADDR_Addresses_UTIL.createNonDuplicateAddresses(ListAddr, dmlWrapper, false);
        
        //Match each Contact or Account with each new address
        List<ID> parentContactIDs = new List<ID>();
        List<ID> parentAccountIDs = new List<ID>();
        Map<ID, Address__c> parentContactIdToAddrMap = new Map<ID, Address__c>();
        Map<ID, Address__c> parentAccountIdToAddrMap = new Map<ID, Address__c>();
        for(Address__c addr : newAddrs) {
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
        
        //We need to re-query before we are in the "after" part of the trigger. We cannot change it to before because
        //we need the Contact ID to have a value when populating the addr.Parent_Contact__c field above.
        List<Contact> parentContacts = [select is_Address_Override__c, Current_Address__c from Contact where ID in :parentContactIDs];
        List<Account> parentAccounts = [select Current_Address__c from Account where ID in :parentAccountIDs];
        List<SObject> parentsToUpdate = new List<SObject>();
        for(Contact contact : parentContacts) {
            Address__c childAddr = parentContactIdToAddrMap.get(contact.Id);
            if(childAddr != null && !contact.is_Address_Override__c) {
                contact.Current_Address__c = childAddr.Id;
                parentsToUpdate.add(contact);
            }
        }
        for(Account acc : parentAccounts) {
            Address__c childAddr = parentAccountIdToAddrMap.get(acc.Id);
            if(childAddr != null) {
                acc.Current_Address__c = childAddr.Id;
                parentsToUpdate.add(acc);
            }
        }
        update parentsToUpdate;
    }
    
    /*******************************************************************************************************
    * @description for each contact, refresh its mailing address from its Address lookup
    * @param listCon the list of Contacts to update
    * @return void  
    ********************************************************************************************************/
    private void setConAddrFromLookup(list<Contact> listCon) {
        set<Id> setAddrId = new set<Id>();
        for (Contact con : listCon) {
            if (con.Current_Address__c != null)
              setAddrId.add(con.Current_Address__c);
        }
    
        map<Id, Address__c> mapAddrIdAddr = new map<Id, Address__c>([select Id, Address_Type__c, MailingStreet__c, MailingStreet2__c, MailingCity__c, MailingState__c, 
            Geolocation__Latitude__s, Geolocation__Longitude__s, MailingPostalCode__c, MailingCountry__c from Address__c where Id in :setAddrId]);
            
        for (Contact con : listCon) {
            Address__c addr = mapAddrIdAddr.get(con.Current_Address__c);
            if (addr != null) {
                con.Primary_Address_Type__c = addr.Address_Type__c;
                UTIL_Debug.debug('****Refreshing address info in Contact from default address');
                ADDR_Addresses_UTIL.copyAddressAddrSObj(addr, con, 'Mailing', 'Primary_Address_Type__c', null);
            }
        }
    }
    
    /*******************************************************************************************************
    * @description
    * @param
    * @param 
    * @return void  
    ********************************************************************************************************/
    private void addrInfoDeleted(List<Contact> listContactsAddrInfoCleared, DmlWrapper dmlWrapper) {
        List<ID> oldCurrentAddrIDs = new List<ID>();
        
        //We need to re-query before we are in the "after" part of the trigger
        List<Contact> contacts = [select is_Address_Override__c, Current_Address__c, AccountID, Account.RecordTypeId
                                  from Contact where ID in :listContactsAddrInfoCleared];
        List<ID> accToUpdateIDs = new List<ID>();
        
        // clear Current_Address__c field from Contacts
        for(Contact contact : contacts) {
            if(contact.Current_Address__c != null) // get all current addrs
                oldCurrentAddrIDs.add(contact.Current_Address__c);
            contact.Current_Address__c = null;
            contact.is_Address_Override__c = false;
            dmlWrapper.objectsToUpdate.add(contact);
            
            // if contact belongs to household and its address it's not an override (it's the default), clear address info from parent account
	        if(contact.Account.RecordTypeId == UTIL_Describe.getHhAccRecTypeID() && !contact.is_Address_Override__c) {
	            accToUpdateIDs.add(contact.AccountID);
	        }
        }
        UTIL_Debug.debug('****Number of Contacts that need parent address info cleared: ' + accToUpdateIDs.size());
        
        // clear Default_Address__c field from child addrs, if necessary
        List<Address__c> addrs = [select Default_Address__c from Address__c where Default_Address__c = true and ID in :oldCurrentAddrIDs];
        if(addrs.size() > 0) {
	        for(Address__c addr : addrs) {
	            addr.Default_Address__c = false;
	            dmlWrapper.objectsToUpdate.add(addr);
	        }
        }
        
        // clear address info from parent Accounts, if necessary
        if(accToUpdateIDs.size() > 0) {
            String strSoql = 'select BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude'; 
            
            if (ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled)
                strSoql += ', BillingCountryCode, BillingStateCode ';
            strSoql += ' from Account where Id IN :accToUpdateIDs';
                
            List<Account> accsToUpdate = database.query(strSoql);
            UTIL_Debug.debug('****Clearing address info number of accounts: ' + accsToUpdate.size());
            for(Account acc : accsToUpdate) {
                acc.BillingStreet = null;
                acc.BillingCity = null;
                acc.BillingState = null;
                acc.BillingPostalCode = null;
                acc.BillingCountry = null;
                acc.BillingLatitude = null;
                acc.BillingLongitude = null;
                if (ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled) {
                    acc.BillingCountry = null;
                    acc.BillingState = null;   
                }
                dmlWrapper.objectsToUpdate.add(acc);
            }
        }
        
        //Don't run ADDR_Addresses_TDTM for these updated addresses
        ADDR_Addresses_TDTM.hasRunAddrTrigger = true;
    }
    
    /*******************************************************************************************************
    * @description Finds each Contact's HH current address (either Default or Seasonal) and updates 
    * the contact's address fields
    * @param listCon list of Contacts 
    * @return void  
    ********************************************************************************************************/
    private void resetConAddr(list<Contact> listCon, DmlWrapper dmlWrapper) {
        if (listCon == null || listCon.size() == 0) return;
        
        map<Id, Address__c> mapAccIdAddr = new map<Id, Address__c>();
        for (Contact con : listCon) 
            mapAccIdAddr.put(con.AccountId, null);
                
        // get the default and seasonal address for each HH
        map<Id, ADDR_Addresses_TDTM.ParentInfo> mapAccIdHHInfo = ADDR_Addresses_TDTM.refreshCurrentAccAddress(mapAccIdAddr, dmlWrapper, null);
        
        // reset the Contact's address fields with the appropriate address
        for (Contact con : listCon) {
            ADDR_Addresses_TDTM.ParentInfo hhinfo = mapAccIdHHInfo.get(con.AccountId);
            UTIL_Debug.debug('****Household address info: ' + JSON.serializePretty(hhinfo));
            if (hhinfo != null) {
                Address__c addr = hhinfo.addrSeasonal;
                if (addr == null)
                  addr = hhinfo.addrDefault;
                if (addr != null) {
                    con.Primary_Address_Type__c = addr.Address_Type__c;
                    con.Current_Address__c = addr.Id;
                    ADDR_Addresses_UTIL.copyAddressAddrSObj(addr, con, 'Mailing', 'Primary_Address_Type__c', null);
                }              
            }
        }       
    }
}