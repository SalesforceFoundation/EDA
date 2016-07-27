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
    public static boolean alreadyRunBefore = false;
    public static boolean alreadyRunAfter = false;
    
    /*******************************************************************************************************
    * @description Trigger Handler on Address that handles address management.  Updates the appropriate
    * parents and Contacts when an Address is changed.
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
        // when a default Address is created or modified, we need to consider three other objects we may need to update:
        // - the parent Account, if not null
        // - the parent Contact, if not null
        // - any other Addresses that should no longer be Default
         
        //Turn off other address triggers
        ADDR_Account_TDTM.alreadyRunBefore = true;
        ADDR_Account_TDTM.alreadyRunAfter = true;
        ADDR_Contact_TDTM.alreadyRunBeforeInsert = true;
        ADDR_Contact_TDTM.alreadyRunBeforeUpdate = true;
        ADDR_Contact_TDTM.alreadyRunAfterInsert = true;
        ADDR_Contact_TDTM.alreadyRunAfterUpdate = true;
        
        if(!alreadyRunBefore && (triggerAction == TDTM_Runnable.Action.BeforeInsert || triggerAction == TDTM_Runnable.Action.BeforeUpdate)) {
            Integer i = 0;
            for (SObject so : listNew) {
                Address__c addr = (Address__c)so;
                Address__c addrOld = listOld == null? null : (Address__c)listOld[i];
                // BEFORE INSERT
                if (triggerAction == TDTM_Runnable.Action.BeforeInsert) {
                   // when an address is marked Default, we update its latest date fields
                   if (addr.Default_Address__c) {
                       UTIL_Debug.debug('****Address created as default: ' + JSON.serializePretty(addr));
                       addr.Latest_Start_Date__c = System.today();
                       addr.Latest_End_Date__c = null;
                   }
                }
                
                // BEFORE UPDATE
                if (triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
                    if (addr.Default_Address__c != addrOld.Default_Address__c) {
                       // when an address changes Default, we update its latest date fields
                        if (addr.Default_Address__c) {
                           UTIL_Debug.debug('****Address updated to default');
                           addr.Latest_Start_Date__c = System.today();
                           addr.Latest_End_Date__c = null;
                        } else {
                           UTIL_Debug.debug('****Address updated to not default');
                           addr.Latest_End_Date__c = System.today();                        
                        }
                    }
                }
                i++;
            }
                
            // enforce address records created only as children of parents
            verifyAddrAccContactChildOnly((List<Address__c>)listNew);
            
            // enforce Seasonal Addresses don't overlap
            ADDR_Seasonal_UTIL.verifyAddrSeasonalNoOverlap((List<Address__c>)listNew);
            
            alreadyRunBefore = true;
            
            return null;
        }

        if(!alreadyRunAfter && (triggerAction == TDTM_Runnable.Action.AfterInsert || triggerAction == 
        TDTM_Runnable.Action.AfterUpdate || triggerAction == TDTM_Runnable.Action.AfterDelete)) {
	        
	        // map of parents, and their default Address
            Map<Id, Address__c> mapParentIdAddr = new Map<Id, Address__c>();
        
	        Integer i = 0;        
            for (SObject so : listNew) {
                Address__c addr = (Address__c)so;
                Address__c addrOld = (listOld != null) ? (Address__c)listOld[i] : null;
                
		        // AFTER INSERT
	            if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
	                // a new address that is marked default or seasonal needs to propogate to the parent
	                if (addr.Default_Address__c || ADDR_Seasonal_UTIL.isSeasonalAddr(addr)) {
	                    UTIL_Debug.debug('****Address that needs to propagate to parent Account: ' + JSON.serializePretty(addr));
	                    putAddrInMap(addr, mapParentIdAddr);
	                }
	            }
	            
	            // AFTER UPDATE
	            if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
	                Boolean changed = ADDR_Addresses_UTIL.isAddressChanged(addr, addrOld, true);
	                UTIL_Debug.debug('****Address record changed: ' + changed);
	                
	                // an address that is marked default needs to propogate to the parent
	                if ((addr.Default_Address__c && (addr.Default_Address__c != addrOld.Default_Address__c)) 
	                // any seasonal address also need to be considered
	                || ADDR_Seasonal_UTIL.isSeasonalChanged(addr, addrOld)) { 
	                    UTIL_Debug.debug('****Address changed to default: ' + JSON.serializePretty(addr));
	                    putAddrInMap(addr, mapParentIdAddr);
	                } else if (changed && addr.Default_Address__c) {
	                    UTIL_Debug.debug('****Address info updated');
	                    putAddrInMap(addr, mapParentIdAddr);    
	                } 
	            }
		        
		        // AFTER DELETE
		        if (triggerAction == TDTM_Runnable.Action.AfterDelete) {
		            // first go through all new/modified Addresses, and collect the list of parents to consider. 
	                ID parentAccId = ((Address__c)addrOld).Parent_Account__c;
	                ID parentConId = ((Address__c)addrOld).Parent_Contact__c;
	                if (parentAccId != null) {
	                    mapParentIdAddr.put(parentAccId, null);
	                } else if(parentConId != null) {
	                    mapParentIdAddr.put(parentConId, null);
	                }
		        }
            }
	        
	        // AFTER INSERT & AFTER UPDATE & AFTER DELETE
            // now we have which parents to consider, and which to only use for Address Override updates.
            if (mapParentIdAddr.size() > 0) {  
                refreshCurrentAccAddress(mapParentIdAddr, dmlWrapper, triggerAction);
                UTIL_Debug.debug('****DmlWrapper to process: ' + JSON.serializePretty(dmlWrapper));
                processDml(dmlWrapper, mapParentIdAddr);
            }
            
            deleteEmptyAddrs(listNew, triggerAction);
            
            alreadyRunAfter = true;
        }

        return dmlWrapper;
    }
    
    private void putAddrInMap(Address__c addr, Map<Id, Address__c> mapParentIdAddr) {
        if(addr.Parent_Account__c != null) {
            UTIL_Debug.debug('****This address if the child of an Account: ' + JSON.serializePretty(addr));
            mapParentIdAddr.put(addr.Parent_Account__c, addr);
        } else if(addr.Parent_Contact__c != null) {
            UTIL_Debug.debug('****This address if child of a Contact: ' + JSON.serializePretty(addr));
            mapParentIdAddr.put(addr.Parent_Contact__c, addr);
        }
    }
    
    private void processDml(DmlWrapper dmlWrapper, Map<Id, Address__c> mapParentIdAddr) {
        // we must process dmlWrapper ourselves, so we can extract out the appropriate errors that might occur updating contacts 
        // and parents, and associating those errors with the correct addresses.
        UTIL_Debug.debug('***Addresses DmlWrapper to process: ' + JSON.serializePretty(dmlWrapper));
        ERR_Handler.Errors errors = TDTM_TriggerHandler.processDMLWithRollback(dmlWrapper, false);
        if (errors.errorsExist) {
            for (Error__c error : errors.errorRecords) {
                ID objId = ERR_Handler.getErrorObjectId(error);
                UTIL_Debug.debug(LoggingLevel.WARN, '**** Address TDTM error on object: ' + objId);
                if (UTIL_Describe.isObjectIdThisType(objId, 'Account') || UTIL_Describe.isObjectIdThisType(objId, 'Contact')) {
                    Address__c addr = mapParentIdAddr.get(objId);
                    addr.addError(error.Full_Message__c);
                    UTIL_Debug.debug(LoggingLevel.WARN, '**** Address: ' + addr + ' message: ' + error.Full_Message__c);
                }
            }
        }
    }
    
    private void deleteEmptyAddrs(List<SObject> listNew, TDTM_Runnable.Action triggerAction) {
        // hack to detect empty addresses and delete them after we've propagated the change to parent
        if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
             List<Address__c> listAddr = new List<Address__c>();
             for (SObject so : listNew) {
                 Address__c addr = (Address__c)so;
                 if (ADDR_Addresses_UTIL.isAddressEmpty(addr))
                    listAddr.add(new Address__c(Id = addr.Id));
             }
             if (listAddr.size() > 0) {
                UTIL_Debug.debug('****Deleting empty addresses: ' + JSON.serializePretty(listAddr));
                delete listAddr; 
             }
        }
    }
    
    /*******************************************************************************************************
    * @description The main routine for finding the appropriate address to currently use for the parent.  
    * Prioritizes the Optional mapped Address as the Default address, as well as checking to see if there 
    * is a seasonal address that should be used instead.
    * @param mapParentIdAddr a map of parent Id to the parent's default Address.
    * @param dmlWrapper to hold the objects that get updated
    * @param isCalcParentInfoOnly if set, then this routine will return the map of parentId to ParentInfo,
    * and not do any changes to dmlWrapper. 
    * @return Map<Id, ParentInfo> a map of parent Id to the ParentInfo object for the parent  
    ********************************************************************************************************/
    public static Map<Id, ParentInfo> refreshCurrentAccAddress(Map<Id, Address__c> mapParentIdAddr, DmlWrapper dmlWrapper, 
    TDTM_Runnable.Action triggerAction) {
        
        // assumptions:
        // called after all modifications saved to db, either from a scheduled job,
        // or in the Address AfterUpdate trigger, AFTER any related objects updated.
        //
        // strategy:
        // for each parent, get all its addresses (query)
        // for each parent, if hh, find all its contacts (query)
        // for each parent, find its current seasonal or default address (loop calculation)
        // for each parent, update its address fields with seasonal current/default
        // for each parent addr, clear its Default field if it isn't default
        // for each hh contact, if no override, update mailing fields with seasonal current/default
        
        // get all Addresses by parent, that might need updating
        List<Id> listParentId = new List<Id>(mapParentIdAddr.keySet());
        Map<Id, List<Address__c>> mapParentIdListAddrs = ADDR_Addresses_UTIL.getMapParentIdListAddrs(listParentId);
       
        // for each parent, find the current address to use (seasonal vs default)
        Map<Id, ParentInfo> mapParentIdParentInfo = new Map<Id, ParentInfo>();
        for (Id parentId : listParentId) {
            // create a ParentInfo for each        
            ParentInfo parentInfo = new ParentInfo();
            parentInfo.parentId = parentId;
            mapParentIdParentInfo.put(parentId, parentInfo);

            // if there is a provided Default address, use it over all other defaults.
            Address__c addr = mapParentIdAddr.get(parentId);
            if (addr != null && addr.Default_Address__c) {
                UTIL_Debug.debug('****Using existing default');
                parentInfo.addrDefault = addr;
            }

            // go through the Acc addresses storing the default and any seasonal          
            storeDefaultSeasonal(parentId, parentInfo, mapParentIdListAddrs);
                    
        	// finally, if no default found, create an empty default
            createDefaultIfNoneExists(parentId, parentInfo);
        }
        
        // get all Contacts by HH, that might need updating
        Map<Id, list<Contact>> mapAccIdListCon = new Map<Id, list<Contact>>(); 
        Set<Id> setHHId =  mapParentIdAddr.keySet();
        list<Contact> listCon = [select Id, is_Address_Override__c, Current_Address__c, AccountId from Contact where 
        AccountId != null and Account.RecordTypeId = :UTIL_CustomSettingsFacade.getSettings().Household_Addresses_RecType__c 
        and AccountId in :setHHId];
        UTIL_Debug.debug('***Household contacts that need updating: ' + JSON.serializePretty(listCon));
        for (Contact con : listCon) {
            list<Contact> listConHH = mapAccIdListCon.get(con.AccountId);
            if (listConHH == null) {
                listConHH = new list<Contact>();
                mapAccIdListCon.put(con.AccountId, listConHH);
            }
            listConHH.add(con);
        }
        
        // lists of objects to update
        List<SObject> listParentUpdate = new List<SObject>();
        List<Address__c> listAddrUpdate = new List<Address__c>();
        list<Contact> listConUpdate = new list<Contact>();
        
        // now go through each parent, and do all the work!
        for (Id parentId : listParentId) {
            
            // pick the address to use
            ParentInfo ParentInfo = mapParentIdParentInfo.get(parentId);
            Address__c addrDefault = ParentInfo.addrDefault;
            Address__c addr = ParentInfo.addrSeasonal;
            if (addr == null) 
                addr = addrDefault;
            //UTIL_Debug.debug('****Address to propagate: ' + JSON.serializePretty(addr));

            // update parents' address fields
            listParentUpdate.addAll(updateParentsAddresses(parentId, addr, triggerAction, dmlWrapper));
            
            // check other addresses on this parent that are no longer the default
            listAddrUpdate.addAll(uncheckOldDefaultAddrs(parentId, mapParentIdListAddrs, addrDefault));
            
            // check the Contacts on this household
            listConUpdate.addAll(copyAddressToContact(parentId, addr, mapAccIdListCon, dmlWrapper));
            
        }  
                    
        if (listParentUpdate.size() > 0) {
            UTIL_Debug.debug('**** listParentUpdate: ' + JSON.serializePretty(listParentUpdate));
            dmlWrapper.objectsToUpdate.addAll((List<SObject>)listParentUpdate);
        }
        if (listAddrUpdate.size() > 0) {
            UTIL_Debug.debug('**** listAddrUpdate: ' + JSON.serializePretty(listAddrUpdate));
            dmlWrapper.objectsToUpdate.addAll((List<SObject>)listAddrUpdate);
        }
        if (listConUpdate.size() > 0) {
            UTIL_Debug.debug('**** listConUpdate: ' + JSON.serializePretty(listConUpdate));
            dmlWrapper.objectsToUpdate.addAll((List<SObject>)listConUpdate);
        }
        
        return mapParentIdParentInfo;
    }
    
    private static void storeDefaultSeasonal(ID parentId, ParentInfo parentInfo, 
    Map<Id, List<Address__c>> mapParentIdListAddrs) {
        if (mapParentIdListAddrs.get(parentId) != null) {
	        for (Address__c addrAcc : mapParentIdListAddrs.get(parentId)) { 
          
	            if (ParentInfo.addrDefault == null && addrAcc.Default_Address__c)
	               ParentInfo.addrDefault = addrAcc;
	            
	            if (ADDR_Seasonal_UTIL.isSeasonalAddr(addrAcc)) {
	                Date startDate = ADDR_Seasonal_UTIL.getStartOrEndDateOfAddrSeasonal(addrAcc, true);
	                Date endDate = ADDR_Seasonal_UTIL.getStartOrEndDateOfAddrSeasonal(addrAcc, false);
	                Date dtToday = System.today();
	                if (dtToday >= startDate && dtToday < endDate) {
	                    parentInfo.addrSeasonal = addrAcc;
	                }
	            }
	        }
        }
    }
    
    private static void createDefaultIfNoneExists(ID parentId, ParentInfo parentInfo) {
        if (parentInfo.addrDefault == null) {
            Address__c addrEmpty = new Address__c();
            if(UTIL_Describe.isObjectIdThisType(parentId, 'Account')) {
                UTIL_Debug.debug('***Creating address as child of Account');
                addrEmpty.Parent_Account__c = parentId;
            } else if(UTIL_Describe.isObjectIdThisType(parentId, 'Contact')) {
                UTIL_Debug.debug('***Creating address as child of Contact');
                addrEmpty.Parent_Contact__c = parentId;
            }
            ParentInfo.addrDefault = addrEmpty;
        }
    }
    
    private static List<SObject> updateParentsAddresses(ID parentId, Address__c addr, 
    TDTM_Runnable.Action triggerAction, DmlWrapper dmlWrapper) {
        UTIL_Debug.debug('****Parent ID: ' + parentId);
        UTIL_Debug.debug('****Address to propagate to parent: ' + JSON.serializePretty(addr));
        
        List<SObject> listParentUpdate = new List<SObject>();
        
        if(UTIL_Describe.isObjectIdThisType(parentId, 'Account')) {
            UTIL_Debug.debug('****Updating address info in Account: ' + JSON.serializePretty(addr));
            Account acc = new Account(Id = parentId);
            ADDR_Addresses_UTIL.copyAddressAddrSObj(addr, acc, 'Billing', null, dmlWrapper);
            // If the address was deleted, it cannot be the override any more
            if(triggerAction != null && triggerAction == TDTM_Runnable.Action.AfterDelete)
                acc.is_Address_Override__c = false;
            listParentUpdate.add(acc);
        } else if(UTIL_Describe.isObjectIdThisType(parentId, 'Contact')) {
            UTIL_Debug.debug('****Updating address info in Contact: ' + JSON.serializePretty(addr));
            Contact contact = new Contact(Id = parentId);
            ADDR_Addresses_UTIL.copyAddressAddrSObj(addr, contact, 'Mailing', null, dmlWrapper);
            // If the address was deleted, it cannot be the override any more
            if(triggerAction != null && triggerAction == TDTM_Runnable.Action.AfterDelete)
                contact.is_Address_Override__c = false;
            listParentUpdate.add(contact);
        } else {
            UTIL_Debug.debug('****Unknown type');
        }
        
        return listParentUpdate;
    }

    private static List<Address__c> uncheckOldDefaultAddrs(Id parentId, Map<Id, List<Address__c>> mapParentIdListAddrs, 
    Address__c addrDefault) {
        List<Address__c> listAddrUpdate = new List<Address__c>();
        
        if (mapParentIdListAddrs != null && mapParentIdListAddrs.size() > 0 
        && mapParentIdListAddrs.get(parentId) != null) {
            for (Address__c childAddr : mapParentIdListAddrs.get(parentId)) {
                if (childAddr.Id == addrDefault.Id) {
                    UTIL_Debug.debug('****Default_Address__c not set to false because this address is the new default.');
                    continue;
                }
                if (childAddr.Default_Address__c) {
                    UTIL_Debug.debug('****Setting Default_Address__c to false.');
                    childAddr.Default_Address__c = false;
                    childAddr.Latest_End_Date__c = System.today();
                    listAddrUpdate.add(childAddr);
                }   
            }
        }
        return listAddrUpdate;
    }
    
    private static List<Contact> copyAddressToContact(ID parentId, Address__c addr, Map<ID, List<Contact>> mapAccIdListCon, 
    DmlWrapper dmlWrapper) {
        List<Contact> listConUpdate = new List<Contact>();
        
        if (mapAccIdListCon != null && mapAccIdListCon.size() > 0) {
            for (Contact con : mapAccIdListCon.get(parentId)) {
                // detect that the contact's current address was deleted.
                // and if so clear any override flag so it will get the default address.
                if (con.Current_Address__c == null)
                   con.is_Address_Override__c = false;
                if (con.is_Address_Override__c == false || con.Current_Address__c == addr.Id) {  
                    con.Current_Address__c = addr.Id;
                    ADDR_Addresses_UTIL.copyAddressAddrSObj(addr, con, 'Mailing', 'Primary_Address_Type__c', dmlWrapper);
                    listConUpdate.add(con);
                }   
            }
        }
        return listConUpdate;
    }
        
    /*******************************************************************************************************
    * @description helper class to keep track of the default and seasonal address for a household
    */ 
    public class ParentInfo {
        public Id parentId;              
        public Address__c addrDefault;      
        public Address__c addrSeasonal;        
    }

    /*******************************************************************************************************
    * @description verify that the parent for each Address has Multi-Address enabled.
    * Adds an Error to each Address object that has an illegal parent.
    * @param listAddr a list of Addresses to verify
    * @return void. 
    */ 
    private void verifyAddrAccContactChildOnly(List<Address__c> listAddr) {       
        Set<Id> setAccId = new Set<Id>();
        for (Address__c addr : listAddr) {
            if (addr.Parent_Account__c != null) {
                setAccId.add(addr.Parent_Account__c);
            }
        }       
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, RecordTypeId from Account where Id in :setAccId]);
        for (Address__c addr : listAddr) {
            if (addr.Parent_Account__c == null && addr.Parent_Contact__c == null) {
                // with TDTM, have to use addError, not throw an exception, or the error will just get logged but not passed to Salesforce to stop its DML.
                addr.addError(Label.addrValidParentObjects);
            } else if(addr.Parent_Account__c != null) {
                Account acc = mapAccIdAcc.get(addr.Parent_Account__c);
                if (UTIL_CustomSettingsFacade.getSettings().Accounts_Addresses_Enabled__c == null || 
                !UTIL_CustomSettingsFacade.getSettings().Accounts_Addresses_Enabled__c.contains(acc.RecordTypeId)) {
                    // with TDTM, have to use addError, not throw an exception, or the error will just get logged but not passed to Salesforce to stop its DML.
                    addr.addError(Label.addrNotEnabled);
                }
            } else if(addr.Parent_Contact__c != null && UTIL_CustomSettingsFacade.getSettings().Contacts_Addresses_Enabled__c == false) {
                // with TDTM, have to use addError, not throw an exception, or the error will just get logged but not passed to Salesforce to stop its DML.
                    addr.addError(Label.addrNotEnabled);
            }
        }       
    }
}