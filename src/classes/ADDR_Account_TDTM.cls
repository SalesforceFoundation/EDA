/*
    Copyright (c) 2014, Salesforce.org
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
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
* @date 2014
* @group Addresses
* @group-content ../../ApexDocContent/Addresses.htm
* @description Trigger Handler on Account for Address management. Creates Address__c record from Account.
*/
public class ADDR_Account_TDTM extends TDTM_Runnable {
    
    /* @description static flag to prevent recursive call */
    public static boolean alreadyRunAfterInsert = false;
    public static boolean alreadyRunAfterUpdate = false;
    
    public static void turnOff() {
        alreadyRunAfterInsert = true;
        alreadyRunAfterUpdate = true;
    }
    
    public static void turnOn() {
        alreadyRunAfterInsert = false;
        alreadyRunAfterUpdate = false;
    }
    
    /*******************************************************************************************************
    * @description Trigger Handler on Account that handles Address management.
    * @param listNew the list of Accounts from trigger new. 
    * @param listOld the list of Accounts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Accounts 
    * @return dmlWrapper.  
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
            
        DmlWrapper dmlWrapper = new DmlWrapper();
            
        if(!alreadyRunAfterInsert || !alreadyRunAfterUpdate) {
	        
	        //Turn off other address triggers
            ADDR_Contact_TDTM.turnOff();
            ADDR_Addresses_TDTM.turnOff();
        
	        List<Account> newAddrInfoAccs = new List<Account>();      
	        List<Account> accsAddrInfoCleared = new List<Account>();
	                
	        // AFTER INSERT
	        if (!alreadyRunAfterInsert && triggerAction == TDTM_Runnable.Action.AfterInsert) {
	            Integer i = 0;        
		        for (SObject so : listNew) {
		            Account acc = (Account)so;
	                // for new accounts that are using address management, create the address object.
	                if (UTIL_CustomSettingsFacade.getSettings().Accounts_Addresses_Enabled__c != null && acc.RecordTypeId != null
	                && UTIL_CustomSettingsFacade.getSettings().Accounts_Addresses_Enabled__c.contains(acc.RecordTypeId)) {
	                    if (!ADDR_Addresses_UTIL.isAccAddressEmpty(acc)) {
	                        UTIL_Debug.debug('***Account should have Address record created after insert');
	                        newAddrInfoAccs.add(acc);
	                    }
	                }
	                i++;
		        }
	            alreadyRunAfterInsert = true;
	        }
		    
	        // AFTER UPDATE
	        if (!alreadyRunAfterUpdate && triggerAction == TDTM_Runnable.Action.AfterUpdate) {  
	            Integer i = 0;        
	            for (SObject so : listNew) {
	                Account acc = (Account)so;
	                Account accOld = (Account)listOld[i];
	                Boolean isHousehold = acc.RecordTypeId == UTIL_Describe.getHhAccRecTypeID();
	                Boolean accAddrEnabledForRecType = UTIL_CustomSettingsFacade.getSettings().Accounts_Addresses_Enabled__c != null && acc.RecordTypeId != null
                                                       && UTIL_CustomSettingsFacade.getSettings().Accounts_Addresses_Enabled__c.contains(acc.RecordTypeId);
	                
	                if (isHousehold || accAddrEnabledForRecType) {
	                    
	                    // if the address info has been removed
	                    if(!ADDR_Addresses_UTIL.isAccAddressEmpty(accOld) && ADDR_Addresses_UTIL.isAccAddressEmpty(acc)) {
	                        UTIL_Debug.debug('****Account address info cleared');
	                        accsAddrInfoCleared.add(acc);
	                        
	                    // if the address changed, remember the account we want to add a new address for    
	                    } else if (ADDR_Addresses_UTIL.isAccountAddressChanged(acc, accOld)) {
	                        UTIL_Debug.debug('****Account address info has changed. New account info: ' + JSON.serializePretty(acc));
	                        UTIL_Debug.debug('****Old account info: '  + JSON.serializePretty(accOld));
	                        newAddrInfoAccs.add(acc);
	                    }
	                }
	            i++;
	            }
	            alreadyRunAfterUpdate = true;
	        }
	
	        // create any new Address objects
	        if (newAddrInfoAccs.size() > 0)
	            processAccsWithNewInfo(newAddrInfoAccs, dmlWrapper);
	        
	        // handle accs with address info removed
	        if(accsAddrInfoCleared.size() > 0)
	            addrInfoDeleted(accsAddrInfoCleared, dmlWrapper);
        }
        return dmlWrapper;    
    }
    
    /*******************************************************************************************************
    * @description for each Account, create a new default address and add it to dmlWrapper
    * @param ListAcc a List of Accounts
    * @param dmlWrapper to hold the Addresses that need creating
    * @return void
    ********************************************************************************************************/
    private void processAccsWithNewInfo(List<Account> ListAcc, DmlWrapper dmlWrapper) {
        List<Address__c> ListAddr = new List<Address__c>();
        for (Account acc : ListAcc) {
            Address__c addr = new Address__c();
            addr.Parent_Account__c = acc.Id;
            addr.Default_Address__c = true;
            addr.Latest_Start_Date__c = system.today();
            addr.Latest_End_Date__c = null;
            ADDR_Addresses_UTIL.copyAddressStdSObjAddr(acc, 'Billing', addr, null);            
            ListAddr.add(addr);
            UTIL_Debug.debug('****New address record: ' + JSON.serializePretty(addr));
        }
        //since coming from an account address, there is no Address Type, so exclude it from the match testing.
        ADDR_Addresses_UTIL.NonDupeAddrs nonDupeAddrs = ADDR_Addresses_UTIL.getNonDuplicateAddresses(ListAddr, false);
        UTIL_Debug.debug('****processAccsWithNewInfo nonDupeAddrs: ' + JSON.serializePretty(nonDupeAddrs));
        nonDupeAddrs.performDml();
        
        //Get map of Accounts to their new addresses
        List<ID> newAddrsParentAccountIDs = new List<ID>();
        Map<ID, Address__c> newAddrsParentAccountIdToAddrMap = new Map<ID, Address__c>();
        for(Address__c addr : nonDupeAddrs.newAddrs) {
            if(addr.Parent_Account__c != null) {
                UTIL_Debug.debug('****Putting new address with parent Account in map');
	            newAddrsParentAccountIDs.add(addr.Parent_Account__c);
	            newAddrsParentAccountIdToAddrMap.put(addr.Parent_Account__c, addr);  
            }
        }
        
        UTIL_Debug.debug('****newAddrsParentAccountIDs: ' + JSON.serializePretty(newAddrsParentAccountIDs));
        
        //Get map of Accounts to their update addresses
        List<ID> updatedAddrsParentAccountIDs = new List<ID>();
        Map<ID, Address__c> updatedAddrsParentAccountIdToAddrMap = new Map<ID, Address__c>();
        for(Address__c addr : nonDupeAddrs.updatedAddrs) {
            if(addr.Parent_Account__c != null) {
                UTIL_Debug.debug('****Putting updated address with parent Account in map');
                updatedAddrsParentAccountIDs.add(addr.Parent_Account__c);
                updatedAddrsParentAccountIdToAddrMap.put(addr.Parent_Account__c, addr);  
            }
        }
        
        UTIL_Debug.debug('****updatedAddrsParentAccountIDs: ' + JSON.serializePretty(updatedAddrsParentAccountIDs));
        
        if(newAddrsParentAccountIDs.size() > 0) {
	        //We need to re-query because we are in the "after" part of the trigger. We cannot change it to before because
	        //we need the Account ID to have a value when populating the addr.Parent_Account__c field above.
	        List<Account> parentAccs = [select recordTypeID, Current_Address__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude,
	            (select Default_Address__c, Latest_Start_Date__c, Latest_End_Date__c from Account.Addresses__r),
	            (select is_Address_Override__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude 
	               from Account.Contacts)
	            from Account where ID in :newAddrsParentAccountIDs];
	        UTIL_Debug.debug('****parentAccs with addrs: ' + JSON.serializePretty(parentAccs));
	        
	        for(Account acc : parentAccs) {
	            Address__c childAddr = newAddrsParentAccountIdToAddrMap.get(acc.Id);
	            //uncheck the old default address
	            if(childAddr.Default_Address__c)
	                ADDR_Addresses_UTIL.uncheckDefaultOtherAddrs(childAddr, acc.Addresses__r, dmlWrapper);
	            //link the account to the new default
	            if(childAddr != null) {
	                UTIL_Debug.debug('****Linking current address with Account');
	                acc.Current_Address__c = childAddr.Id;
	                dmlWrapper.objectsToUpdate.add(acc);
	            }
	            //update child contacts, if it's a household and it's not override
	            if(acc.RecordTypeId == UTIL_Describe.getHhAccRecTypeID()) {
	                for(Contact contact : acc.Contacts) {
	                    if(!contact.is_Address_Override__c) {
	                        UTIL_Debug.debug('****Copying address info to child contact from Account with new address: ' + JSON.serializePretty(acc));
		                    ADDR_Addresses_UTIL.copyAddressStdSObj(acc, 'Billing', contact, 'Mailing');
		                    contact.Current_Address__c = childAddr.Id;
		                    dmlWrapper.objectsToUpdate.add(contact);
	                    }
	                } 
	            }
	        }
        }
        
        //Update child Contacts of those Accounts whose Addreses were just updated, if they are in a Household
        if(nonDupeAddrs.updatedAddrs.size() > 0) {
            List<Account> parentAccs = [select recordTypeID, Current_Address__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude,
                (select Default_Address__c, Latest_Start_Date__c, Latest_End_Date__c from Account.Addresses__r),
                (select is_Address_Override__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude 
                   from Account.Contacts)
                from Account where ID in :updatedAddrsParentAccountIDs];
            
            for(Account acc : parentAccs) {
                Address__c childAddr = updatedAddrsParentAccountIdToAddrMap.get(acc.Id);
                //uncheck the old default address
                if(childAddr.Default_Address__c)
                    ADDR_Addresses_UTIL.uncheckDefaultOtherAddrs(childAddr, acc.Addresses__r, dmlWrapper);
                //link the account to the new default
                if(childAddr != null) {
                    UTIL_Debug.debug('****Linking current address with Account');
                    acc.Current_Address__c = childAddr.Id;
                    dmlWrapper.objectsToUpdate.add(acc);
                }
                //update child contacts, if it's a household and it's not override
                if(acc.RecordTypeId == UTIL_Describe.getHhAccRecTypeID()) {
	                for(Contact contact : acc.Contacts) {
	                    UTIL_Debug.debug('****Copying address info to child contact from updated Account: ' + JSON.serializePretty(acc));
	                    if(!contact.is_Address_Override__c) {
	                        ADDR_Addresses_UTIL.copyAddressStdSObj(acc, 'Billing', contact, 'Mailing');
	                        dmlWrapper.objectsToUpdate.add(contact);
	                    }
	                }
                }
            }
        }
    }
    
    private void addrInfoDeleted(List<Account> accsAddrInfoCleared, DmlWrapper dmlWrapper) {
        
        //We need to re-query before we are in the "after" part of the trigger
        List<Account> accs = [select recordTypeID, Current_Address__c,
                (select Default_Address__c, Latest_Start_Date__c, Latest_End_Date__c from Account.Addresses__r),
                (select is_Address_Override__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude 
                    from Account.Contacts)
            from Account where ID in :accsAddrInfoCleared];
        
        //Gather the IDs of those addresses that were children of the account
        Set<ID> oldCurrentAddrIDs = new Set<ID>();
        for(Account acc : accs) {
            if(acc.Current_Address__c != null) // get all current addrs
                oldCurrentAddrIDs.add(acc.Current_Address__c);
        }
        
        for(Account acc : accs) {
            
            //Clear Current_Address__c field from accs
            acc.Current_Address__c = null;
            dmlWrapper.objectsToUpdate.add(acc);
            
            //Clear Default_Address__c field from these child addrs
	        for(Address__c addr : acc.Addresses__r) {
	            if(oldCurrentAddrIDs.contains(addr.ID)) {
		            UTIL_Debug.debug('****Settings Default_Address__c to false.');
		            addr.Default_Address__c = false;
		            dmlWrapper.objectsToUpdate.add(addr);
	            }
	        }
	        
	        //Clear address info from children contacts without override
	        if(acc.recordTypeID == UTIL_Describe.getHhAccRecTypeID()) {
	            for(Contact contact : acc.Contacts) {
	                if(!contact.is_Address_Override__c) {
	                   contact.Current_Address__c = null;
	                   ADDR_Addresses_UTIL.clearAddrInfo(contact);
	                   dmlWrapper.objectsToUpdate.add(contact);
	                }
	            }
	        }
        }
    }
}