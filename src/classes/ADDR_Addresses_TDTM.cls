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
    * parents and Contacts when an Address is changed.
    * @param listNew the list of Addresses from trigger new. 
    * @param listOld the list of Addresses from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Addresses 
    * @return dmlWrapper.  
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> listNew, List<SObject> listOld, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
   
        // STRATEGY
        // when an Address is created or modified, we need to consider three other objects we may need to update:
        // - the parent parent, if it is marked Default_Address__c
        // - any other Addresses that should no longer be Default
        // - the parent Contact, if it is marked Default_Address__c
            
        // prevent recursion
        if (!hasRunAddrTrigger) {
	        // first go through all new/modified Addresses, and collect the list of parents to consider.
	        // map of parents, and their default Address 
	        map<Id, Address__c> mapParentIdAddr = new map<Id, Address__c>(); 
	
	        // AFTER DELETE
	        if (triggerAction == TDTM_Runnable.Action.AfterDelete) {
	            for (SObject so : listOld) {
	                ID parentAccId = ((Address__c)so).Parent_Account__c;
	                ID parentConId = ((Address__c)so).Parent_Contact__c;
	                if (parentAccId != null) {
	                    mapParentIdAddr.put(parentAccId, null);
	                } else if(parentConId != null) {
	                    mapParentIdAddr.put(parentConId, null);
	                }
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
		                // a new address that is marked default or seasonal needs to propogate to the parent
		                if (addr.Default_Address__c || ADDR_Seasonal_UTIL.isSeasonalAddr(addr)) {
		                    if(addr.Parent_Account__c != null) {
		                        mapParentIdAddr.put(addr.Parent_Account__c, addr);
		                    } else if(addr.Parent_Contact__c != null) {
		                        mapParentIdAddr.put(addr.Parent_Contact__c, addr);
		                    }
		                }
		            }
		            
		            // AFTER UPDATE
		            if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
		                // an address that is marked default needs to propogate to the parent
		                if ((addr.Default_Address__c && (addr.Default_Address__c != addrOld.Default_Address__c)) 
		                || ADDR_Seasonal_UTIL.isSeasonalChanged(addr, addrOld)) { // any seasonal address also need to be considered
		                    if(addr.Parent_Account__c != null) {
                                mapParentIdAddr.put(addr.Parent_Account__c, addr);
                            } else if(addr.Parent_Contact__c != null) {
                                mapParentIdAddr.put(addr.Parent_Contact__c, addr);
                            }
		                } else if (ADDR_Addresses_UTIL.isAddressChanged(addr, addrOld, true)) {
		                    if (addr.Default_Address__c) {
		                        if(addr.Parent_Account__c != null) {
	                                mapParentIdAddr.put(addr.Parent_Account__c, addr);
	                            } else if(addr.Parent_Contact__c != null) {
	                                mapParentIdAddr.put(addr.Parent_Contact__c, addr);
	                            }
		                    }    
		                } 
		            }
		            // moving to the next item
		            i++;            
		        }
		
		        // BEFORE INSERT & BEFORE UPDATE
		        if (triggerAction == TDTM_Runnable.Action.BeforeInsert || triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
		            
		            // enforce address records created only as children of parents
		            verifyAddrAccContactChildOnly((list<Address__c>)listNew);
		            
		            // enforce Seasonal Addresses don't overlap
		            ADDR_Seasonal_UTIL.verifyAddrSeasonalNoOverlap((list<Address__c>)listNew);
		            
		            return null;    
		        }
	        }
	
	        // AFTER INSERT & AFTER UPDATE & AFTER DELETE
	        // now we have which parents to consider, and which to only use for Address Override updates.
	        hasRunAddrTrigger = true;
	 
	        if (mapParentIdAddr.size() > 0) {  
	            DmlWrapper dmlWrapper = refreshCurrentAccAddress(mapParentIdAddr, triggerAction);
	            processDml(dmlWrapper, mapParentIdAddr);
	        }

	        deleteEmptyAddrs(listNew, triggerAction);
        }
        return null;
    }
    
    private void processDml(DmlWrapper dmlWrapper, map<Id, Address__c> mapParentIdAddr) {
        // we must process dmlWrapper ourselves, so we can extract out the appropriate errors
        // that might occur updating contacts and parents, and associating those errors with 
        // the correct addresses.
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
    * @description The main routine for finding the appropriate address to currently use for the parent.  
    * Prioritizes the Optional mapped Address as the Default address, as well as checking to see if there 
    *is a seasonal address that should be used instead.
    * @param mapParentIdAddr a map of parent Id to the parent's default Address.
    * @param dmlWrapper to hold the objects that get updated
    * @param isCalcParentInfoOnly if set, then this routine will return the map of parentId to ParentInfo,
    * and not do any changes to dmlWrapper. 
    * @return map<Id, ParentInfo> a map of parent Id to the ParentInfo object for the parent  
    ********************************************************************************************************/
    public static DmlWrapper refreshCurrentAccAddress(map<Id, Address__c> mapParentIdAddr, TDTM_Runnable.Action triggerAction) {
        
        // assumptions:
        // called after all modifications saved to db
        // so either from a scheduled job,
        // or in the Address AfterUpdate trigger, AFTER any related objects updated
        //
        // strategy:
        // for each parent, get all its addresses (query)
        // for each parent, find all its contacts (query)
        // for each parent, find its current seasonal or default address (loop calculation)
        // for each parent, update its billing fields with seasonal current/default
        // for each parent addr, clear its Default field if it isn't default

        DmlWrapper dmlWrapper = new DmlWrapper();
        
        // get all Addresses by parent, that might need updating
        list<Id> listParentId = new list<Id>(mapParentIdAddr.keySet());
        map<Id, list<Address__c>> mapParentIdListAddrs = ADDR_Addresses_UTIL.getMapParentIdListAddrs(listParentId);
       
        // for each parent, find the current address to use (seasonal vs default)
        map<Id, ParentInfo> mapParentIdParentInfo = new map<Id, ParentInfo>();
        for (Id parentId : listParentId) {
            // create a ParentInfo for each        
            ParentInfo ParentInfo = new ParentInfo();
            ParentInfo.parentId = parentId;
            mapParentIdParentInfo.put(parentId, ParentInfo);

            // if there is a provided Default address, use it over all other defaults.
            Address__c addr = mapParentIdAddr.get(parentId);
            if (addr != null && addr.Default_Address__c) 
                ParentInfo.addrDefault = addr;

            // go through the Acc addresses storing the default and any seasonal  
            if (mapParentIdListAddrs.get(parentId) != null) {         
                for (Address__c addrAcc : mapParentIdListAddrs.get(parentId)) { 
                    
                    if (ParentInfo.addrDefault == null && addrAcc.Default_Address__c)
                       ParentInfo.addrDefault = addrAcc;
                    
                    if (ADDR_Seasonal_UTIL.isSeasonalAddr(addrAcc)) {
                        Date startDate = ADDR_Seasonal_UTIL.getStartOrEndDateOfAddrSeasonal(addrAcc, true);
                        Date endDate = ADDR_Seasonal_UTIL.getStartOrEndDateOfAddrSeasonal(addrAcc, false);
                        Date dtToday = System.today();
                        if (dtToday >= startDate && dtToday < endDate) {
                            ParentInfo.addrSeasonal = addrAcc;
                        }
                    }
                }
            }
        
        	// finally, if no default found, create an empty default
            if (ParentInfo.addrDefault == null) {
                Address__c addrEmpty = new Address__c();
                if(UTIL_Describe.isObjectIdThisType(parentId, 'Account')) {
                    addrEmpty.Parent_Account__c = parentId;
                } else if(UTIL_Describe.isObjectIdThisType(parentId, 'Contact')) {
                    addrEmpty.Parent_Contact__c = parentId;
                }
                ParentInfo.addrDefault = addrEmpty;
            }
        }
        
        // lists of objects to update
        list<SObject> listParentUpdate = new list<SObject>();
        list<Address__c> listAddrUpdate = new list<Address__c>();
        
        // now go through each parent, and do all the work!
        for (Id parentId : listParentId) {
            
            // pick the address to use
            ParentInfo ParentInfo = mapParentIdParentInfo.get(parentId);
            Address__c addrDefault = ParentInfo.addrDefault;
            Address__c addr = ParentInfo.addrSeasonal;
            if (addr == null) 
                addr = addrDefault;

            // update parent's Billing address fields
            if(UTIL_Describe.isObjectIdThisType(parentId, 'Account')) {
	            Account acc = new Account(Id = parentId);
	            ADDR_Addresses_UTIL.copyAddressAddrSObj(addr, acc, 'Billing', null);
	            // If the address was deleted, it cannot be the override any more
	            if(triggerAction != null && triggerAction == TDTM_Runnable.Action.AfterDelete) {
	                acc.is_Address_Override__c = false;
	            }
	            listParentUpdate.add(acc);
            } else if(UTIL_Describe.isObjectIdThisType(parentId, 'Contact')) {
                Contact contact = new Contact(Id = parentId);
                ADDR_Addresses_UTIL.copyAddressAddrSObj(addr, contact, 'Mailing', null);
                // If the address was deleted, it cannot be the override any more
                if(triggerAction != null && triggerAction == TDTM_Runnable.Action.AfterDelete) {
                    contact.is_Address_Override__c = false;
                }
                listParentUpdate.add(contact);
            }
            
            // check other addresses on this parent that are no longer the default
            if (mapParentIdListAddrs != null && mapParentIdListAddrs.size() > 0 && mapParentIdListAddrs.get(parentId) != null) {
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
        }  
                    
        if (listParentUpdate.size() > 0) {
            UTIL_Debug.debug('**** listParentUpdate: ' + listParentUpdate);
            dmlWrapper.objectsToUpdate.addAll((List<SObject>)listParentUpdate);
        }
        if (listAddrUpdate.size() > 0) {
            UTIL_Debug.debug('**** listAddrUpdate: ' + listAddrUpdate);
            dmlWrapper.objectsToUpdate.addAll((List<SObject>)listAddrUpdate);
        }
        
        return dmlWrapper;
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
    private void verifyAddrAccContactChildOnly(list<Address__c> listAddr) {       
        set<Id> setAccId = new set<Id>();
        for (Address__c addr : listAddr) {
            if (addr.Parent_Account__c != null) {
                setAccId.add(addr.Parent_Account__c);
            }
        }       
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, RecordTypeId from Account where Id in :setAccId]);
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