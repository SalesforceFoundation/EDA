/*
    Copyright (c) 2014, Salesforce.org
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
* @date 2014 
* @group Addresses
* @group-content ../../ApexDocContent/Addresses.htm
* @description Trigger handler on Address object to support propagating addresses.
*/
public class ADDR_Addresses_TDTM extends TDTM_Runnable {

    /* @description static flag to prevent recursive call */
    public static boolean hasRunAddrTrigger = false;
    
    /*******************************************************************************************************
    * @description Trigger Handler on Address that handles address management.  Updates the appropriate
    * Accounts and Contacts when an Address is changed.
    * @param listNew the list of Addresses from trigger new. 
    * @param listOld the list of Addresses from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Addresses 
    * @return dmlWrapper.  
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        DmlWrapper dmlWrapper = new DmlWrapper();
            
        // STRATEGY
        // when an Address is created or modified, we need to consider three other objects we may need to update:
        // - the parent Account, if it is marked Default_Address__c
        // - any other Addresses that should no longer be Default
        // - the parent Contact, if it is marked Default_Address__c
            
        // prevent recursion
        if (hasRunAddrTrigger) {
            return null;
        }

        // first go through all new/modified Addresses, and collect the list of  Accounts to consider.
        map<Id, Address__c> mapAccIdAddr = new map<Id, Address__c>(); // map of Accounts, and their default Address 
        map<Id, Address__c> mapAddrIdAddr = new map<Id, Address__c>(); // map of changed Addresses who need to only update any contact overrides     

		if (triggerAction == TDTM_Runnable.Action.AfterDelete) {
            for (SObject so : listOld) {
                ID accId = ((Address__c)so).Parent_Account__c;
                if (accId != null)
                    mapAccIdAddr.put(accId, null);
            }
        } else {
	        integer i = 0;        
	        for (SObject so : listNew) {
	            Address__c addr = (Address__c)so;
	            Address__c addrOld = (listOld != null) ? (Address__c)listOld[i] : null;
	            
	            // BEFORE INSERT
	            if (triggerAction == TDTM_Runnable.Action.BeforeInsert) {
	               // when an address is marked Default, we update its latest date fields
	               if (addr.Default_Address__c) { 
	                   addr.Latest_Start_Date__c = System.today();
	                   addr.Latest_End_Date__c = null;
	               }
	            }
	            
	            // BEFORE UPDATE
	            if (triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
	                if (addr.Default_Address__c != addrOld.Default_Address__c) {
	                   // when an address changes Default, we update its latest date fields
	                    if (addr.Default_Address__c) {
	                       addr.Latest_Start_Date__c = System.today();
	                       addr.Latest_End_Date__c = null;
	                    } else {
	                       addr.Latest_End_Date__c = System.today();                        
	                    }
	                }
	            }
	
	            // AFTER INSERT
	            if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
	                // a new address that is marked default or seasonal needs to propogate to the account
	                if (addr.Default_Address__c || ADDR_Seasonal_UTIL.isSeasonalAddr(addr)) 
	                    mapAccIdAddr.put(addr.Parent_Account__c, addr);
	            }
	            
	            // AFTER UPDATE
	            if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
	                // an address that is marked default needs to propogate to the account
	                if ((addr.Default_Address__c && (addr.Default_Address__c != addrOld.Default_Address__c)) 
	                    // any seasonal address also need to be considered
	                    || ADDR_Seasonal_UTIL.isSeasonalChanged(addr, addrOld)) {
	                    mapAccIdAddr.put(addr.Parent_Account__c, addr);
	                } else if (ADDR_Addresses_UTIL.isAddressChanged(addr, addrOld, true)) {
	                    if (addr.Default_Address__c)
	                        mapAccIdAddr.put(addr.Parent_Account__c, addr);
	                    else  // address changed, but not default, still need to update any contacts using it as an override
	                        mapAddrIdAddr.put(addr.Id, addr);      
	                } 
	            }
	            // moving to the next item
	            i++;            
	        }
	
	        // BEFORE INSERT & BEFORE UPDATE
	        if (triggerAction == TDTM_Runnable.Action.BeforeInsert || triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
	            
	            // enforce address records created only as children of Accounts
	            verifyAddrAccChildOnly((list<Address__c>)listNew);
	            
	            // enforce Seasonal Addresses don't overlap
	            ADDR_Seasonal_UTIL.verifyAddrSeasonalNoOverlap((list<Address__c>)listNew);
	            
	            return null;    
	        }
        }

        // AFTER INSERT & AFTER UPDATE & AFTER DELETE
        // now we have which Accounts to consider, and which to only use for Address Override updates.
        hasRunAddrTrigger = true;
 
        if (mapAccIdAddr.size() > 0)        
            refreshCurrentAccAddress(mapAccIdAddr, dmlWrapper, false);       
        
        processDml(dmlWrapper, mapAccIdAddr, mapAddrIdAddr);
        
        deleteEmptyAddrs(listNew, triggerAction);
        
        return null;
    }
    
    private void processDml(DmlWrapper dmlWrapper, map<Id, Address__c> mapAccIdAddr, map<Id, Address__c> mapAddrIdAddr) {
        // we must process dmlWrapper ourselves, so we can extract out the appropriate errors
        // that might occur updating contacts and accounts, and associating those errors with 
        // the correct addresses.
        ERR_Handler.Errors errors = TDTM_TriggerHandler.processDMLWithRollback(dmlWrapper, false);
        if (errors.errorsExist) {
            for (Error__c error : errors.errorRecords) {
                ID objId = ERR_Handler.getErrorObjectId(error);
                UTIL_Debug.debug(LoggingLevel.WARN, '**** Address TDTM error on object: ' + objId);
                if (UTIL_Describe.isObjectIdThisType(objId, 'Account')) {
                    Address__c addr = mapAccIdAddr.get(objId);
                    addr.addError(error.Full_Message__c);
                    UTIL_Debug.debug(LoggingLevel.WARN, '**** Address: ' + addr + ' message: ' + error.Full_Message__c);
                }
                else if (UTIL_Describe.isObjectIdThisType(objId, UTIL_Namespace.StrTokenNSPrefix('Address__c'))) {
                    Address__c addr = mapAddrIdAddr.get(objId);
                    addr.addError(error.Full_Message__c);
                    UTIL_Debug.debug(LoggingLevel.WARN, '**** Address: ' + addr + ' message: ' + error.Full_Message__c);
                }
            }
        }
    }
    
    private void deleteEmptyAddrs(List<SObject> listNew, TDTM_Runnable.Action triggerAction) {
        // hack to detect empty addresses and delete them after we've propagated the change to all contacts and account
        if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
             List<Address__c> listAddr = new list<Address__c>();
             for (SObject so : listNew) {
                 Address__c addr = (Address__c)so;
                 if (ADDR_Addresses_UTIL.isAddressEmpty(addr))
                    listAddr.add(new Address__c(Id = addr.Id));
             }
             if (listAddr.size() > 0)
                delete listAddr; 
        }
    }
    
    /*******************************************************************************************************
    * @description The main routine for finding the appropriate address to currently use for the
    * account and its contacts.  Prioritizes the Optional mapped Address as the Default
    * address, as well as checking to see if there is a seasonal address that should be used instead.
    * @param mapAccIdAddr a map of Account Id to the Account's default Address.
    * @param dmlWrapper to hold the objects that get updated
    * @param isCalcAccInfoOnly if set, then this routine will return the map of AccId to AccInfo,
    * and not do any changes to dmlWrapper. 
    * @return map<Id, AccInfo> a map of Account Id to the AccInfo object for the account  
    ********************************************************************************************************/
    public static map<Id, AccInfo> refreshCurrentAccAddress(map<Id, Address__c> mapAccIdAddr, DmlWrapper dmlWrapper, 
    boolean isCalcAccInfoOnly) {
        
        // assumptions:
        // called after all modifications saved to db
        // so either from a scheduled job,
        // or in the Address AfterUpdate trigger, AFTER any related objects updated
        //
        // strategy:
        // for each Acc, get all its addresses (query)
        // for each Acc, find all its contacts (query)
        // for each Acc, find its current seasonal or default address (loop calculation)
        // for each Acc, update its billing fields with seasonal current/default
        // for each Acc addr, clear its Default field if it isn't default

        // get all Addresses by Acc, that might need updating
        list<Id> listAccId = new list<Id>(mapAccIdAddr.keySet());
        map<Id, list<Address__c>> mapAccIdListAddrs = ADDR_Addresses_UTIL.getmapAccIdListAddrs(listAccId);
       
        // for each Acc, find the current address to use (seasonal vs default)
        map<Id, AccInfo> mapAccIdAccInfo = new map<Id, AccInfo>();
        for (Id accId : listAccId) {
            // create a AccInfo for each        
            AccInfo AccInfo = new AccInfo();
            AccInfo.accId = accId;
            mapAccIdAccInfo.put(accId, AccInfo);

            // if there is a provided Default address, use it over all other defaults.
            Address__c addr = mapAccIdAddr.get(accId);
            if (addr != null && addr.Default_Address__c) 
                AccInfo.addrDefault = addr;

            // go through the Acc addresses storing the default and any seasonal  
            if (mapAccIdListAddrs.get(accId) != null) {         
                for (Address__c addrAcc : mapAccIdListAddrs.get(accId)) { 
                    
                    if (AccInfo.addrDefault == null && addrAcc.Default_Address__c)
                       AccInfo.addrDefault = addrAcc;
                    
                    if (ADDR_Seasonal_UTIL.isSeasonalAddr(addrAcc)) {
                        Date startDate = ADDR_Seasonal_UTIL.getStartOrEndDateOfAddrSeasonal(addrAcc, true);
                        Date endDate = ADDR_Seasonal_UTIL.getStartOrEndDateOfAddrSeasonal(addrAcc, false);
                        Date dtToday = System.today();
                        if (dtToday >= startDate && dtToday < endDate) {
                            AccInfo.addrSeasonal = addrAcc;
                        }
                    }
                }
            }
        
        	// finally, if no default found, create an empty default
            if (AccInfo.addrDefault == null) {
                Address__c addrEmpty = new Address__c();
                addrEmpty.Parent_Account__c = accId;
                AccInfo.addrDefault = addrEmpty;
            }
        }
        
        // some callers just need the AccInfo for each HH Account.
        if (isCalcAccInfoOnly)
            return mapAccIdAccInfo;

        // get all Contacts by HH, that might need updating
        // note that if we have an organizational account, our query will not pick up any contacts (by design!)
        /*map<Id, list<Contact>> mapAccIdListCon = new map<Id, list<Contact>>(); 
        set<Id> setHHId =  mapAccIdAddr.keySet();
        list<Contact> listCon = [select Id, is_Address_Override__c, Current_Address__c, AccountId 
            from Contact where 
                (Account.RecordTypeId = :UTIL_Describe.getHhAccRecTypeID() or Account.RecordTypeId = :UTIL_Describe.getAdminAccRecTypeID())
                 and AccountId != null and AccountId in :setHHId];
        for (Contact con : listCon) {
            list<Contact> listConHH = mapAccIdListCon.get(con.AccountId);
            if (listConHH == null) {
                listConHH = new list<Contact>();
                mapAccIdListCon.put(con.AccountId, listConHH);
            }
            listConHH.add(con);
        }*/
        
        // lists of objects to update
        list<Account> listAccUpdate = new list<Account>();
        list<Address__c> listAddrUpdate = new list<Address__c>();
        list<Contact> listConUpdate = new list<Contact>();
        
        // now go through each Account, and do all the work!
        for (Id accId : listAccId) {
            
            // pick the address to use
            AccInfo AccInfo = mapAccIdAccInfo.get(accId);
            Address__c addrDefault = AccInfo.addrDefault;
            Address__c addr = AccInfo.addrSeasonal;
            if (addr == null) 
                addr = addrDefault;

            // update Account's Billing address fields
            Account acc = new Account(Id = accId);
            ADDR_Addresses_UTIL.copyAddressAddrSObj(addr, acc, 'Billing', null);
            listAccUpdate.add(acc);
            
            // check other addresses on this account that are no longer the default
            if (mapAccIdListAddrs != null && mapAccIdListAddrs.size() > 0 && mapAccIdListAddrs.get(accId) != null) {
                for (Address__c addrAcc : mapAccIdListAddrs.get(accId)) {
                    if (addrAcc.Id == addrDefault.Id)
                        continue;
                    if (addrAcc.Default_Address__c) {
                        addrAcc.Default_Address__c = false;
                        addrAcc.Latest_End_Date__c = System.today();
                        listAddrUpdate.add(addrAcc);
                    }   
                }
            }

            // check the Contacts on this household
            /*if (mapAccIdListCon != null && mapAccIdListCon.size() > 0) {
                for (Contact con : mapAccIdListCon.get(accId)) {
                	// detect that the contact's current address was deleted.
	                // and if so clear any override flag so it will get the default address.
	                if (con.Current_Address__c == null)
	                   con.is_Address_Override__c = false;
                    if (con.is_Address_Override__c == false || con.Current_Address__c == addr.Id) {  
                        con.Current_Address__c = addr.Id;
                        ADDR_Addresses_UTIL.copyAddressAddrSObj(addr, con, 'Mailing', 'Primary_Address_Type__c');
                        listConUpdate.add(con);
                    }   
                }
            }*/
        }  
                    
        if (listAccUpdate.size() > 0) {
            //UTIL_Debug.debug('DJH**** listAccUpdate: ' + listAccUpdate);
            dmlWrapper.objectsToUpdate.addAll((List<SObject>)listAccUpdate);
        }
        if (listAddrUpdate.size() > 0) {
            //UTIL_Debug.debug('DJH**** listAddrUpdate: ' + listAddrUpdate);
            dmlWrapper.objectsToUpdate.addAll((List<SObject>)listAddrUpdate);
        }
        if (listConUpdate.size() > 0) {
            //UTIL_Debug.debug('DJH**** listConUpdate: ' + listConUpdate);
            dmlWrapper.objectsToUpdate.addAll((List<SObject>)listConUpdate);
        }
        
        return mapAccIdAccInfo;
    }
        
    /*******************************************************************************************************
    * @description helper class to keep track of the default and seasonal address for a household
    */ 
    public class AccInfo {
        public Id accId;              
        public Address__c addrDefault;      
        public Address__c addrSeasonal;        
    }

    /*******************************************************************************************************
    * @description verify that the account for each Address has Multi-Address enabled.
    * Adds an Error to each Address object that has an illegal account.
    * @param listAddr a list of Addresses to verify
    * @return void. 
    */ 
    private void verifyAddrAccChildOnly(list<Address__c> listAddr) {       
        set<Id> setAccId = new set<Id>();
        for (Address__c addr : listAddr) {
            if (addr.Parent_Account__c != null) {
                setAccId.add(addr.Parent_Account__c);
            }
        }       
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, RecordTypeId from Account where Id in :setAccId]);
        for (Address__c addr : listAddr) {
            if (addr.Parent_Account__c == null) {
                // with TDTM, have to use addError, not throw an exception, or the error will just get logged but not passed to Salesforce to stop its DML.
                addr.addError(Label.addrHhAdmAccountOnly);
            } else {
                Account acc = mapAccIdAcc.get(addr.Parent_Account__c);
                if (UTIL_CustomSettingsFacade.getSettings().Accounts_Addresses_Enabled__c == null || 
                !UTIL_CustomSettingsFacade.getSettings().Accounts_Addresses_Enabled__c.contains(acc.RecordTypeId)) {
                    // with TDTM, have to use addError, not throw an exception, or the error will just get logged but not passed to Salesforce to stop its DML.
                    addr.addError(Label.addrAccountTypeEnabled);
                }
            }
        }       
    }
}