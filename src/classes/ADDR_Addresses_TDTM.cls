/*
    Copyright (c) 2014, Salesforce.com Foundation
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Salesforce.com Foundation nor the names of
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
* @author Salesforce.com Foundation 
* @date 2014 
* @group Address Management
* @group-content ../../ApexDocContent/Addresses.htm
* @description trigger handler on Address object to support propagating addresses 
*/
public class ADDR_Addresses_TDTM extends TDTM_Runnable {

    /*******************************************************************************************************
    * @description static flag to prevent recursive call 
    */
    public static boolean hasRunAddrTrigger = false;

    /*******************************************************************************************************
    * @description map from Country name to Country Code
    */
    private static Map<String, String> validCountriesByLabel = new Map<String, String>();

    /*******************************************************************************************************
    * @description map from State name to State Code
    */
    private static Map<String, String> validStatesByLabel = new Map<String, String>();

    /*******************************************************************************************************
    * @description map from Country Code to Country Name
    */
    private static Map<String, String> validCountriesByCode = new Map<String, String>();
    
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
            
        // STRATEGY
        // when an Address is created or modified, we need to consider three other objects we may need to update:
        // - the Address's HH Account, if it is marked Default_Address
        // - any other HH Addresses that should no longer be Default
        // - the HH Contacts, if the Address is Default, or a contact specifies it in Address_Override
        //
        // So a change to the Address to become Default, or a change in its Address fields
        // will require visiting all the HH Accounts, and deciding whether we are propagating the change
        // to all related objects, or just to Contacts who are using the Address as their override.
        //
            
        // prevent recursion
        if (hasRunAddrTrigger) {
            //UTIL_Debug.debug('DJH**** stop Addr Trigger recursion');
            return null;
        }

        // first go through all new/modified Addresses, and collect the list of HH Accounts to consider.
        map<Id, Address__c> mapAccIdAddr = new map<Id, Address__c>(); // map of HH Accounts, and their default Address 
        map<Id, Address__c> mapAddrIdAddr = new map<Id, Address__c>(); // map of changed Addresses who need to only update any contact overrides.     

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
	                   addr.Latest_Start_Date__c = system.today();
	                   addr.Latest_End_Date__c = null;
	               }
	            }
	            
	            // BEFORE UPDATE
	            if (triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
	                if (addr.Default_Address__c != addrOld.Default_Address__c) {
	                   // when an address changes Default, we update its latest date fields
	                    if (addr.Default_Address__c) {
	                       addr.Latest_Start_Date__c = system.today();
	                       addr.Latest_End_Date__c = null;
	                    } else {
	                       addr.Latest_End_Date__c = system.today();                        
	                    }
	                }
	            }
	
	            // AFTER INSERT
	            if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
	                // a new address that is marked default or seasonal needs to propogate to the household
	                if (addr.Default_Address__c || isSeasonalAddr(addr)) 
	                    mapAccIdAddr.put(addr.Parent_Account__c, addr);
	            }
	            
	            // AFTER UPDATE
	            if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
	                // an address that is marked default needs to propogate to the household
	                if ((addr.Default_Address__c && (addr.Default_Address__c != addrOld.Default_Address__c)) 
	                    // any seasonal address also need to be considered
	                    || isSeasonalChanged(addr, addrOld)) {
	                    mapAccIdAddr.put(addr.Parent_Account__c, addr);
	                } else if (isAddressChanged(addr, addrOld, true)) {
	                    if (addr.Default_Address__c)
	                        mapAccIdAddr.put(addr.Parent_Account__c, addr);
	                    else    // address changed, but not default, still need to update any contacts using it as an override
	                        mapAddrIdAddr.put(addr.Id, addr);      
	                } 
	            }
	            
	            // moving to the next item
	            i++;            
	        }
	
	        // BEFORE INSERT & BEFORE UPDATE
	        if (triggerAction == TDTM_Runnable.Action.BeforeInsert ||
	           triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
	            // enforce only HH Accounts are being used
	            verifyAddrHHAccOnly((list<Address__c>)listNew);
	            
	            // enforce Seasonal Addresses don't overlap
	            verifyAddrSeasonalNoOverlap((list<Address__c>)listNew);
	            
	            return null;    
	        }
        }

        // AFTER INSERT & AFTER UPDATE & AFTER DELETE
        // now we have which HH Accounts to consider, and which to only use for Address Override updates.
        hasRunAddrTrigger = true;
        
        DmlWrapper dmlWrapper = new DmlWrapper();        
        
        if (mapAccIdAddr.size() > 0)        
            refreshCurrentHHAddress(mapAccIdAddr, dmlWrapper, false);
       
        if (mapAddrIdAddr.size() > 0) 
            updateAddrOverrides(mapAddrIdAddr, dmlWrapper);        
        
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
        
        return null;
    }
    
    
    /*******************************************************************************************************
    * @description The main routine for finding the appropriate address to currently use for the
    * household and its contacts.  Prioritizes the Optional mapped Address as the Default
    * address, as well as checking to see if there is a seasonal address that should be used instead.
    * @param mapAccIdAddr a map of Account Id to the Account's default Address.
    * @param dmlWrapper to hold the objects that get updated
    * @param isCalcHHInfoOnly if set, then this routine will return the map of HHId to HHInfo,
    * and not do any changes to dmlWrapper. 
    * @return map<Id, HHInfo> a map of Account Id to the HHInfo object for the account  
    ********************************************************************************************************/
    public static map<Id, HHInfo> refreshCurrentHHAddress(map<Id, Address__c> mapAccIdAddr, DmlWrapper dmlWrapper, boolean isCalcHHInfoOnly) {
        
        // assumptions:
        // called after all modifications saved to db
        // so either from a scheduled job,
        // or in the Address AfterUpdate trigger, AFTER any related objects updated
        //
        // strategy:
        // for each hh, get all its addresses (query)
        // for each hh, find all its contacts (query)
        // for each hh, find its current seasonal or default address (loop calculation)
        // for each hh, update its billing fields with seasonal current/default
        // for each hh addr, clear its Default field if it isn't default
        // for each hh contact, if no override, update mailing fields with seasonal current/default
        //

        // get all Addresses by HH, that might need updating
        list<Id> listAccId = new list<Id>(mapAccIdAddr.keySet());
        map<Id, list<Address__c>> mapAccIdListAddrHH = getMapAccIdListAddrHH(listAccId);
       
        // for each hh, find the current address to use (seasonal vs default)
        map<Id, HHInfo> mapAccIdHHInfo = new map<Id, HHInfo>();
        for (Id accId : listAccId) {
            // create a HHInfo for each household        
            HHInfo hhinfo = new HHInfo();
            hhinfo.accId = accId;
            mapAccIdHHInfo.put(accId, hhinfo);

            // if there is a provided Default address, use it over all other defaults.
            Address__c addr = mapAccIdAddr.get(accId);
            if (addr != null && addr.Default_Address__c) 
                hhinfo.addrDefault = addr;

            // go through the hh addresses storing the default and any seasonal  
            if (mapAccIdListAddrHH.get(accId) != null) {         
                for (Address__c addrHH : mapAccIdListAddrHH.get(accId)) { 
                    
                    if (hhinfo.addrDefault == null && addrHH.Default_Address__c)
                       hhinfo.addrDefault = addrHH;
                    
                    if (isSeasonalAddr(addrHH)) {
                        Date dtStart = dtStartOrEndOfAddrSeasonal(addrHH, true);
                        Date dtEnd = dtStartOrEndOfAddrSeasonal(addrHH, false);
                        Date dtToday = system.today();
                        if (dtToday >= dtStart && dtToday < dtEnd) {
                            hhinfo.addrSeasonal = addrHH;
                        }                        
                    }      
                }
            }
        
        	// finally, if no default found, create an empty default
            if (hhinfo.addrDefault == null) {
                Address__c addrEmpty = new Address__c();
                addrEmpty.Parent_Account__c = accId;
                hhinfo.addrDefault = addrEmpty;
            }
        }
        
        // some callers just need the HHInfo for each HH Account.
        if (isCalcHHInfoOnly)
            return mapAccIdHHInfo;

        // get all Contacts by HH, that might need updating
        // note that if we have an organizational account, our query will not pick up any contacts (by design!)
        map<Id, list<Contact>> mapAccIdListCon = new map<Id, list<Contact>>(); 
        set<Id> setHHId =  mapAccIdAddr.keySet();
        list<Contact> listCon = [select Id, is_Address_Override__c, Current_Address__c, AccountId 
            from Contact where 
                (Account.SYSTEM_AccountType__c = :CAO_Constants.HH_ACCOUNT_PROCESSOR or Account.SYSTEM_AccountType__c = :CAO_Constants.ADM_ACCOUNT_PROCESSOR)
                 and AccountId != null and AccountId in :setHHId];
        for (Contact con : listCon) {
            list<Contact> listConHH = mapAccIdListCon.get(con.AccountId);
            if (listConHH == null) {
                listConHH = new list<Contact>();
                mapAccIdListCon.put(con.AccountId, listConHH);
            }
            listConHH.add(con);
        }
        
        // lists of objects to update
        list<Account> listAccUpdate = new list<Account>();
        list<Address__c> listAddrUpdate = new list<Address__c>();
        list<Contact> listConUpdate = new list<Contact>();
        
        // now go through each HH, and do all the work!
        for (Id accId : listAccId) {
            
            // pick the address to use
            HHInfo hhinfo = mapAccIdHHInfo.get(accId);
            Address__c addrDefault = hhinfo.addrDefault;
            Address__c addr = hhinfo.addrSeasonal;
            if (addr == null) 
                addr = addrDefault;

            // update HH Account's Billing address fields
            Account acc = new Account(Id = accId);
            copyAddressAddrSObj(addr, acc, 'Billing', null);
            listAccUpdate.add(acc);
            
            // check other addresses on this household that are no longer the default
            if (mapAccIdListAddrHH != null && mapAccIdListAddrHH.size() > 0 && mapAccIdListAddrHH.get(accId) != null) {
                for (Address__c addrHH : mapAccIdListAddrHH.get(accId)) {
                    if (addrHH.Id == addrDefault.Id)
                        continue;
                    if (addrHH.Default_Address__c) {
                        addrHH.Default_Address__c = false;
                        addrHH.Latest_End_Date__c = system.today();
                        listAddrUpdate.add(addrHH);
                    }   
                }
            }

            // check the Contacts on this household
            if (mapAccIdListCon != null && mapAccIdListCon.size() > 0) {
                for (Contact con : mapAccIdListCon.get(accId)) {
                	// detect that the contact's current address was deleted.
	                // and if so clear any override flag so it will get the default address.
	                if (con.Current_Address__c == null)
	                   con.is_Address_Override__c = false;
                    if (con.is_Address_Override__c == false || con.Current_Address__c == addr.Id) {
                        con.Current_Address__c = addr.Id;
                        copyAddressAddrSObj(addr, con, 'Mailing', 'Primary_Address_Type__c');
                        listConUpdate.add(con);
                    }   
                }
            }
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
        
        return mapAccIdHHInfo;
    }
        
    /*******************************************************************************************************
    * @description helper class to keep track of the default and seasonal address for a household
    */ 
    public class HHInfo {
        public Id accId;              
        public Address__c addrDefault;      
        public Address__c addrSeasonal;        
    }

    /*******************************************************************************************************
    * @description utility to return the current StartDate or EndDate of a Seasonal Address
    * @param addr the Address to look at
    * @param fStart whether to return the StartDate or EndDate
    * @return Date
    */ 
    private static Date dtStartOrEndOfAddrSeasonal(Address__c addr, boolean fStart) {    
        integer startMonth = integer.valueOf(addr.Seasonal_Start_Month__c);
        integer startDay = integer.valueOf(addr.Seasonal_Start_Day__c);
        integer endMonth = integer.valueOf(addr.Seasonal_End_Month__c);
        integer endDay = integer.valueOf(addr.Seasonal_End_Day__c);
        Date dtStart;
        Date dtEnd;
        Date dtToday = system.today();
        //seasonal address is contained within a single year
        if (startMonth <= endMonth) { 
            dtStart = date.newInstance(dtToday.year(), startMonth, startDay);
            dtEnd = date.newInstance(dtToday.year(), endMonth, endDay);
        //seasonal address overlaps the year, and this month is past the start month
        } else if (startMonth <= dtToday.month()){
            dtStart = date.newInstance(dtToday.year(), startMonth, startDay);
            dtEnd = date.newInstance(dtToday.year()+1, endMonth, endDay);
        //seasonal address overlaps the year, and this month is before the start month
        } else {
            dtStart = date.newInstance(dtToday.year()-1, startMonth, startDay);
            dtEnd = date.newInstance(dtToday.year(), endMonth, endDay);
        }
        return (fStart ? dtStart : dtEnd);
    }
    
    /*******************************************************************************************************
    * @description utility to see if the address has seasonal fields set
    * @param addr the Address to look at
    * @return boolean
    */ 
    private static boolean isSeasonalAddr(Address__c addr) {
        return (addr.Seasonal_Start_Month__c != null && addr.Seasonal_Start_Day__c != null &&
           addr.Seasonal_End_Month__c != null && addr.Seasonal_End_Day__c != null);
    }
    
    /*******************************************************************************************************
    * @description utility to see if the address has only a subset of its seasonal fields set
    * @param addr the Address to look at
    * @return boolean
    */ 
    private static boolean isPartialSeasonalAddr(Address__c addr) {
        integer cParts = 0;
        if (addr.Seasonal_Start_Month__c != null) cParts++;
        if (addr.Seasonal_Start_Day__c != null) cParts++;
        if (addr.Seasonal_End_Month__c != null) cParts++;
        if (addr.Seasonal_End_Day__c != null) cParts++;
        return (cParts > 0 && cParts < 4);
    }
    
    /*******************************************************************************************************
    * @description for the map of addresses, update any contact's mailing fields that are using the address as an override.
    * @param mapAddrIdAddr a map of Address Id's to Addresses
    * @dmlWrapper to hold the Contacts to update
    * @return void
    */ 
    private void updateAddrOverrides(map<Id, Address__c> mapAddrIdAddr, DmlWrapper dmlWrapper) {        
        list<Contact> listCon = [select Id, is_Address_Override__c, Current_Address__c from Contact where is_Address_Override__c = true and Current_Address__c in :mapAddrIdAddr.keyset()];
        for (Contact con : listCon) {
            Address__c addr = mapAddrIdAddr.get(con.Current_Address__c);
            copyAddressAddrSObj(addr, con, 'Mailing', 'npe01__Primary_Address_Type__c');
            dmlWrapper.objectsToUpdate.add(con);            
        }
    }
    
    /*******************************************************************************************************
    * @description utility to create a map of HH Account Id to a list of Addresses in that HH, given a list of HH Account Id.
    * @param listAccId the list of Account Id's
    * @return map<Id, list<Address__c>> map that contains the Addresses for each HH Account Id
    */ 
    private static map<Id, list<Address__c>> getMapAccIdListAddrHH(list<Id> listAccId) {
        map<Id, list<Address__c>> mapAccIdListAddrHH = new map<Id, list<Address__c>>();  
        list<Address__c> listAddrOther = [select Id, Default_Address__c, Parent_Account__c, Address_Type__c,
            MailingStreet__c, MailingStreet2__c, MailingCity__c, MailingState__c, MailingPostalCode__c, MailingCountry__c, 
            Seasonal_Start_Month__c, Seasonal_Start_Day__c, Seasonal_End_Month__c, Seasonal_End_Day__c, Geolocation__Latitude__s, Geolocation__Longitude__s
            from Address__c 
            where Parent_Account__c in :listAccId
            order by Default_Address__c desc, LastModifiedDate asc]; // ordering needed by cleanupAccountAddresses().
        for (Address__c addr : listAddrOther) {
            list<Address__c> listAddrHH = mapAccIdListAddrHH.get(addr.Parent_Account__c);
            if (listAddrHH == null) {
                listAddrHH = new list<Address__c>();
                mapAccIdListAddrHH.put(addr.Parent_Account__c, listAddrHH);
            }
            listAddrHH.add(addr);
        }
        return mapAccIdListAddrHH;
    }
 
    /*******************************************************************************************************
    * @description utility to compare two address objects seasonal fields
    * @param addrNew the new version of the Address
    * @param addrOld the old version of the Address
    * @return boolean. true if any of the seasonal fields have changed on the Address
    */ 
    private boolean isSeasonalChanged(Address__c addrNew, Address__c addrOld) {
        if (addrNew == null || addrOld == null) 
           return false;        
        return (
           addrNew.Seasonal_Start_Month__c != addrOld.Seasonal_Start_Month__c ||
           addrNew.Seasonal_Start_Day__c != addrOld.Seasonal_Start_Day__c ||
           addrNew.Seasonal_End_Month__c != addrOld.Seasonal_End_Month__c ||
           addrNew.Seasonal_End_Day__c != addrOld.Seasonal_End_Day__c);
    }
    
    /*******************************************************************************************************
    * @description utility to compare two address objects address fields
    * @param addrNew the new version of the Address
    * @param addrOld the old version of the Address
    * @param includeAddressType whether to include comparing the AddressType field
    * @return boolean. true if any of the fields fields have changed on the Address
    */ 
    public static boolean isAddressChanged(Address__c addrNew, Address__c addrOld, boolean includeAddressType) {
        if (addrNew == null || addrOld == null) 
           return false;        
        return (
           !equalsCaseSensitive(addrNew.MailingStreet__c, addrOld.MailingStreet__c) ||
           !equalsCaseSensitive(addrNew.MailingStreet2__c, addrOld.MailingStreet2__c) ||
           !equalsCaseSensitive(addrNew.MailingCity__c, addrOld.MailingCity__c) ||
           !equalsCaseSensitive(addrNew.MailingState__c, addrOld.MailingState__c) ||
           !equalsCaseSensitive(addrNew.MailingPostalCode__c, addrOld.MailingPostalCode__c) ||
           !equalsCaseSensitive(addrNew.MailingCountry__c, addrOld.MailingCountry__c) ||
           (includeAddressType && (!equalsCaseSensitive(addrNew.Address_Type__c, addrOld.Address_Type__c))));
    }

    /*******************************************************************************************************
    * @description Returns whether two strings are equal, using a case sensitve comparison
    * @param str1 The first string
    * @param str2 The second string
    * @return boolean 
    ********************************************************************************************************/
    public static boolean equalsCaseSensitive(string str1, string str2) {
        if (str1 == null)
            return str2 == null;
        if (str2 == null)
            return false;
        return str1.equals(str2);
    }

    /*******************************************************************************************************
    * @description Compare two address objects address fields and support fuzzy matching; our definition of 
    * fuzzy is: only one field has changed, ignoring whitespace and letter casing changes.
    * @param addrNew the new version of the Address
    * @param addrOld the old version of the Address
    * @param includeAddressType whether to include comparing the AddressType field
    * @return boolean true if no more than one of the fields have changed on the Address, ignoring whitespace and case changes
    */     
    private static boolean isAddressMatchFuzzy(Address__c addrNew, Address__c addrOld, boolean includeAddressType) {
        if (addrNew == null || addrOld == null) 
           return false;     
           
        integer cChange = 0;
        if (strCleanup(addrNew.MailingStreet__c) != strCleanup(addrOld.MailingStreet__c) && addrOld.MailingStreet__c != null)
            cChange++;
        if (strCleanup(addrNew.MailingStreet2__c) != strCleanup(addrOld.MailingStreet2__c) && addrOld.MailingStreet2__c != null)
            cChange++;
        if (strCleanup(addrNew.MailingCity__c) != strCleanup(addrOld.MailingCity__c) && addrOld.MailingCity__c != null)
            cChange++;
        if (strCleanup(addrNew.MailingState__c) != strCleanup(addrOld.MailingState__c) && addrOld.MailingState__c != null)
            cChange++;
        if (strCleanup(addrNew.MailingPostalCode__c) != strCleanup(addrOld.MailingPostalCode__c) && addrOld.MailingPostalCode__c != null)
            cChange++;
        if (strCleanup(addrNew.MailingCountry__c) != strCleanup(addrOld.MailingCountry__c) && addrOld.MailingCountry__c != null)
            cChange++;
        if (includeAddressType && strCleanup(addrNew.Address_Type__c) != strCleanup(addrOld.Address_Type__c) && addrOld.Address_Type__c != null)
            cChange++;
        return cChange <= 1;
    }

    /*******************************************************************************************************
    * @description utility to remove all whitespace and to lowercase the string
    * @param str the string to clean up
    * @return string
    */ 
    private static string strCleanup(string str) {
        if (str != null) {
            str = str.replace(' ', '');
            str = str.toLowerCase();
        } else {
            str = '';
        }
        return str;
    }

    /*******************************************************************************************************
    * @description utility to create the month and day strings to a decimal we can use in comparisons.
    * @param m the month ordinal as a string
    * @param d the day ordinal as a string
    * @return decimal
    */ 
    private static decimal decimalOfMonthDay(string m, string d) {
        if (integer.valueOf(d) < 10)
            return decimal.valueOf(m + '.0' + d);
        else
            return decimal.valueOf(m + '.' + d);
    }
    
    /*******************************************************************************************************
    * @description utility to see if two seasonal addresses overlap
    * @param addr1 an Address
    * @param addr2 an Address
    * @return boolean. true if the seasonal fields of the two addresses overlap
    */ 
    public static boolean isSeasonalOverlap(Address__c addr1, Address__c addr2) {
        if (addr1 == null || addr2 == null) 
            return false;        
        if (!isSeasonalAddr(addr1) || !isSeasonalAddr(addr2))
            return false;
            
        // we don't need to know what year or month we are currently in, but
        // we need to take into account days (since we could be in the same month).
        // to make this easy to compare, we convert month & day to be a decimal of month.day.  
        // eg., 3.01 for Feb 1st and 3.28 for Feb 28th.
        decimal start1 = decimalOfMonthDay(addr1.Seasonal_Start_Month__c, addr1.Seasonal_Start_Day__c);
        decimal end1 = decimalOfMonthDay(addr1.Seasonal_End_Month__c, addr1.Seasonal_End_Day__c);
        decimal start2 = decimalOfMonthDay(addr2.Seasonal_Start_Month__c, addr2.Seasonal_Start_Day__c);
        decimal end2 = decimalOfMonthDay(addr2.Seasonal_End_Month__c, addr2.Seasonal_End_Day__c);
                
        // now we see if the ranges are increasing (Jan '14 - March '14), or decreasing (Nov 14' - Feb '15),
        boolean range1Increases = start1 < end1;
        boolean range2Increases = start2 < end2;

        // we can now tell if there is overlap simply by looking at three scenarios: 
        // 1. both ranges increase, make sure start1 not in range2, and start2 not in range1.
        if (range1Increases && range2Increases) {
            return (start1 >= start2 && start1 <= end2) || (start2 >= start1 && start2 <= end1);
        }    
        // 2. one range increases, one range decreases, make sure end1 not in range2, and end2 not in range1.
        else if (range1Increases != range2Increases) {
            return (end1 >= start2 && end1 <= end2) || (end2 >= start1 && end2 <= end1);
        }
        // 3. both ranges decrease, always implies an overlap of the new year!
        else {
            return true;
        }
    }

    /*******************************************************************************************************
    * @description verify that the account for each Address is a HH account or an Organizational account if enabled.
    * Adds an Error to each Address object that has an illegal account.
    * @param listAddr a list of Addresses to verify
    * @return void. 
    */ 
    private void verifyAddrHHAccOnly(list<Address__c> listAddr) {       
        set<Id> setAccId = new set<Id>();
        for (Address__c addr : listAddr) {
            if (addr.Parent_Account__c != null) {
                setAccId.add(addr.Parent_Account__c);
            }
        }       
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, SYSTEM_AccountType__c from Account where Id in :setAccId]);
        for (Address__c addr : listAddr) {
            if (addr.Parent_Account__c == null) {
                // with TDTM, have to use addError, not throw an exception, or the error will just get logged but not passed to Salesforce to stop its DML.
                addr.addError(Label.addrHHAccountOnly);
            } else {
                Account acc = mapAccIdAcc.get(addr.Parent_Account__c);
                if ( (acc.SYSTEM_AccountType__c != CAO_Constants.HH_ACCOUNT_PROCESSOR) &&
                    (!UTIL_CustomSettingsFacade.getSettings().Organizational_Account_Addresses_Enabled__c)) {
                    // with TDTM, have to use addError, not throw an exception, or the error will just get logged but not passed to Salesforce to stop its DML.
                    addr.addError(Label.addrHHAccountOnly);
                }
            }
        }       
    }
    
    /*******************************************************************************************************
    * @description verify that any seasonal addresses don't overlap
    * Adds an Error to each Address object that has an illegal seasonal fields
    * @param listAddr a list of Addresses to verify
    * @return void. 
    */ 
    private void verifyAddrSeasonalNoOverlap(list<Address__c> listAddr) { 
        
        // first get just the seasonal addresses
        list<Address__c> listAddrS = new list<Address__c>();
        for (Address__c addr : listAddr) {
            if (isSeasonalAddr(addr)) {
                listAddrS.add(addr);
            } else if (isPartialSeasonalAddr(addr)) {
                addr.addError(Label.addrSeasonalPartial);                
            }
        }      
        
        // if none are seasonal, we can bail out
        if (listAddrS.size() == 0)
           return;

        // protect against overlaps within the set being inserted or updated
        for (Address__c addr : listAddrS) {
            for (Address__c addr2 : listAddrS) {
                if (addr == addr2)
                    continue;
                if (addr.Parent_Account__c != addr2.Parent_Account__c)
                    continue;  
                if (isSeasonalOverlap(addr, addr2)) {
                    addr.addError(Label.addrSeasonalOverlap);
                }
            }
        }

        // now check for overlaps within each household's saved addresses
        list<Id> listAccId = new list<Id>();
        for (Address__c addr : listAddrS) {
            listAccId.add(addr.Parent_Account__c);
        }        
        map<Id, list<Address__c>> mapAccIdListAddrHH = getMapAccIdListAddrHH(listAccId);        
        
        for (Address__c addr : listAddrS) {
            for (Address__c addr2 : mapAccIdListAddrHH.get(addr.Parent_Account__c)) {
                if (addr.id == addr2.id)
                   continue;
                if (isSeasonalOverlap(addr, addr2)) {
                    addr.addError(Label.addrSeasonalOverlap);
                    break;
                }
            }
        }
    }
    
    /*******************************************************************************************************
    * @description routine the scheduled batch job calls to update households with the specified Seasonal addresses
    * @param listAddr a list of Addresses to update
    * @return void
    */ 
    public static void batchSeasonalUpdate(list<Address__c> listAddr) {
        if (listAddr == null || listAddr.size() == 0) return;
        
        map<Id, Address__c> mapAccIdAddr = new map<Id, Address__c>();
        for (Address__c addr : listAddr) 
            mapAccIdAddr.put(addr.Parent_Account__c, addr);
        
        // must manually set our semaphore, so when we update contacts and households, they don't try to create additional addresses
        hasRunAddrTrigger = true;       

        Dmlwrapper dmlWrapper = new Dmlwrapper();
        refreshCurrentHHAddress(mapAccIdAddr, dmlWrapper, false);
        TDTM_TriggerHandler.processDML(dmlWrapper);
    }
    
    /*******************************************************************************************************
    * @description For the list of Addresses, sees if there is already an existing Address in the Account that
    * matches. Creates only unique addresses from their respective household, and mark any existing matches 
    * as Default if the caller specifies it on the new address.
    * @param listAddr a list of Addresses to update
    * @param dmlWrapper the Addresses to update
    * @param includeAddressType whether to include comparing the AddressType field
    * @return void
    */ 
    public static void createNonDuplicateAddresses(list<Address__c> listAddr, DmlWrapper dmlWrapper, boolean includeAddressType) {  
        
        map<Address__c, Address__c> mapAddrDupAddr= findDuplicateAddresses(listAddr);
        for (Address__c addrNew : listAddr) {
            Address__c addrDup = mapAddrDupAddr.get(addrNew);
            if (addrDup != null) {
                // if it is a fuzzy match, not exact, then we want to update the existing address.
                if (isAddressChanged(addrNew, addrDup, includeAddressType)) {
                    copyAddressObj(addrNew, addrDup);
                    if (addrNew.Default_Address__c)
                        addrDup.Default_Address__c = true;
                    dmlWrapper.objectsToUpdate.add(addrDup);
                } else if (addrNew.Default_Address__c && !addrDup.Default_Address__c) {
                    addrDup.Default_Address__c = true;
                    dmlWrapper.objectsToUpdate.add(addrDup);
               }
            } else {
                dmlWrapper.objectsToInsert.add(addrNew);
            }       
        }   
    }
    
    /*******************************************************************************************************
    * @description for the given addresses, find if they have a match, and return a map that
    * has null for no match, and the matching address if there is a match.
    * @param listAddr a list of Addresses to update
    * @return map<Address__c, Address__c>
    */ 
    public static map<Address__c, Address__c> findDuplicateAddresses(list<Address__c> listAddr) {      
        // for each address, create a map of HHId to lists of Addresses
        list<Id> listAccId = new list<Id>();
        for (Address__c addr : listAddr)
           listAccId.add(addr.Parent_Account__c);
        map<Id, list<Address__c>> mapAccIdListAddrHH = getMapAccIdListAddrHH(listAccId);
        boolean tryFuzzy = UTIL_CustomSettingsFacade.getSettings().Simple_Address_Change_Treated_as_Update__c;
        
        // create our map for returning information in
        map<Address__c, Address__c> mapAddrDupAddr = new map<Address__c, Address__c>();
        
        // now compare our Addresses to the existing Addresses
        for (Address__c addr : listAddr) {
            list<Address__c> listAddrHH = mapAccIdListAddrHH.get(addr.Parent_Account__c);
            boolean hasMatch = false;
            if (listAddrHH != null) {
                Address__c addrMatch = null;
                for (Address__c addrHH : listAddrHH) {
                	// only include address type in the test if the new one isn't empty.
                    if (!isAddressChanged(addr, addrHH, addr.Address_Type__c != null)) {
                        // found exact match, record it and bail out
                        addrMatch = addrHH;
                        break;
                    }
                    if (tryFuzzy && isAddressMatchFuzzy(addr, addrHH, addr.Address_Type__c != null)) {
                        // found fuzzy match, remember it and continue searching
                        addrMatch = addrHH;
                        continue;
                    }
                }
                if (addrMatch != null) {
                    hasMatch = true;
                    mapAddrDupAddr.put(addr, addrMatch);
                }
            }
            if (!hasMatch)
                mapAddrDupAddr.put(addr, null);
        }
        
        return mapAddrDupAddr;               
    }
    
    /*******************************************************************************************************
    * @description utility to see if the address has only a subset of its seasonal fields set
    * @param addr the Address to look at
    * @return boolean
    */ 
    public static void handleMultilineStreet(Address__c addr) {
    
        if (addr.MailingStreet__c == null)
            return;
        
        // handle CR NL
        integer ich = addr.MailingStreet__c.indexOf('\r\n');
        if (ich > -1) {
            addr.MailingStreet2__c = addr.MailingStreet__c.substring(ich+2);
            addr.MailingStreet__c = addr.MailingStreet__c.left(ich);
            return;
        }
        
        // handle just NL
        ich = addr.MailingStreet__c.indexOf('\n');
        if (ich > -1) {
            addr.MailingStreet2__c = addr.MailingStreet__c.substring(ich+1);
            addr.MailingStreet__c = addr.MailingStreet__c.left(ich);
            return;
        }
    }
    
    /*******************************************************************************************************
    * @description utility to see if the address has only a subset of its seasonal fields set
    * @param addr the Address to look at
    * @return boolean
    */ 
    public static string getMultilineStreet(Address__c addr) {
        string str = addr.MailingStreet__c;
        if (addr.MailingStreet2__c != null && addr.MailingStreet2__c.length() > 0)
            str += '\r\n' + addr.MailingStreet2__c;
        return str;
    }
    
    /*******************************************************************************************************
    * @description Utility to copy Address fields between to Address objects.
    * @param addrSrc the source Address
    * @param addrSrc the destination Address
    * @return void
    */ 
    public static void copyAddressObj(Address__c addrSrc, Address__c addrDst) {
        addrDst.MailingStreet__c = addrSrc.MailingStreet__c;
        addrDst.MailingStreet2__c = addrSrc.MailingStreet2__c;
        addrDst.MailingCity__c = addrSrc.MailingCity__c;
        addrDst.MailingState__c = addrSrc.MailingState__c;
        addrDst.MailingPostalCode__c = addrSrc.MailingPostalCode__c;
        addrDst.MailingCountry__c = addrSrc.MailingCountry__c;
        addrDst.Geolocation__Latitude__s = addrSrc.Geolocation__Latitude__s;
        addrDst.Geolocation__Longitude__s = addrSrc.Geolocation__Longitude__s;
        if (addrSrc.Address_Type__c != null)
            addrDst.Address_Type__c = addrSrc.Address_Type__c;
    }

    /*******************************************************************************************************
    * @description Utility to copy Address fields between Contacts and Accounts (or vice-versa).
    * Handles instances where State and Country picklists are enabled, and multiline street addresses.
    * @param sobjSrc the source Contact or Account
    * @param strFieldPrefixSrc the address fields to copy from, ie., Mailing, Other, Shipping, Billing
    * @param sobjDst the destination Contact or Account
    * @param strFieldPrefixDst the address fields to copy to, ie., Mailing, Other, Shipping, Billing
    * @return void
    */ 
    public static void copyAddressStdSObj(sobject sobjSrc, string strFieldPrefixSrc, sobject sobjDst, string strFieldPrefixDst) {
        sobjDst.put(strFieldPrefixDst + 'Street', sobjSrc.get(strFieldPrefixSrc + 'Street'));
        sobjDst.put(strFieldPrefixDst + 'City', sobjSrc.get(strFieldPrefixSrc + 'City'));
        sobjDst.put(strFieldPrefixDst + 'PostalCode', sobjSrc.get(strFieldPrefixSrc + 'PostalCode'));
        sobjDst.put(strFieldPrefixDst + 'State', sobjSrc.get(strFieldPrefixSrc + 'State'));
        sobjDst.put(strFieldPrefixDst + 'Country', sobjSrc.get(strFieldPrefixSrc + 'Country'));
        sobjDst.put(strFieldPrefixDst + 'Latitude', sobjSrc.get(strFieldPrefixSrc + 'Latitude'));
        sobjDst.put(strFieldPrefixDst + 'Longitude', sobjSrc.get(strFieldPrefixSrc + 'Longitude'));
        
        if (isStateCountryPicklistsEnabled) {
            sobjDst.put(strFieldPrefixDst + 'StateCode', sobjSrc.get(strFieldPrefixSrc + 'StateCode'));
            sobjDst.put(strFieldPrefixDst + 'CountryCode', sobjSrc.get(strFieldPrefixSrc + 'CountryCode'));
        }    
    }

    /*******************************************************************************************************
    * @description utility to copy Address fields from a Contact or Account to an Address object.
    * Handles instances where State and Country picklists are enabled, and multiline street addresses.
    * @param sobjSrc the source Contact or Account
    * @param strFieldPrefixSrc the address fields to copy from, ie., Mailing, Other, Shipping, Billing
    * @param addr the Address object to copy to
    * @param strAddrType if not null, copy to address.Address_Type__c
    * @return void
    */ 
    public static void copyAddressStdSObjAddr(sobject sobjSrc, string strFieldPrefixSrc, Address__c addr, string strAddrType) {
        addr.MailingStreet__c = (string)sobjSrc.get(strFieldPrefixSrc + 'Street');
        handleMultilineStreet(addr);
        addr.MailingCity__c = (string)sobjSrc.get(strFieldPrefixSrc + 'City');
        addr.MailingPostalCode__c = (string)sobjSrc.get(strFieldPrefixSrc + 'PostalCode');
        addr.MailingState__c = (string)sobjSrc.get(strFieldPrefixSrc + 'State');
        addr.MailingCountry__c = (string)sobjSrc.get(strFieldPrefixSrc + 'Country');
        addr.Geolocation__Latitude__s = (decimal)sobjSrc.get(strFieldPrefixSrc + 'Latitude');
        addr.Geolocation__Longitude__s = (decimal)sobjSrc.get(strFieldPrefixSrc + 'Longitude');
        
        // try to find state and country by code if they aren't specified?
        if (isStateCountryPicklistsEnabled) {

            // lookup country if needed, by country code
            string strCountryCode = (string)sobjSrc.get(strFieldPrefixSrc + 'CountryCode');
            if (addr.MailingCountry__c == null && strCountryCode != null) {
                addr.MailingCountry__c = validCountriesByCode.get(strCountryCode);
            }
            
            // lookup state if needed, by country code and state code.
            string strStateCode = (string)sobjSrc.get(strFieldPrefixSrc + 'StateCode');
            if (addr.MailingState__c == null && strCountryCode != null && strStateCode != null) {
                // assume it's a valid statecode
                addr.MailingState__c = strStateCode;
            }
        }
        
        // if specified, also include Address Type
        if (strAddrType != null) 
            addr.Address_Type__c = strAddrType;
    }

    /*******************************************************************************************************
    * @description Utility to copy Address fields from an Address object to a Contact or Account.
    * Handles instances where State and Country picklists are enabled, and multiline street addresses.
    * @param addr the Address object to copy from
    * @param sobjDst the destination Contact or Account
    * @param strFieldPrefix the address fields to copy to, ie., Mailing, Other, Shipping, Billing
    * @param strFieldAddrType an optional Address Type field on sobjDst to copy to 
    * @return void
    */ 
    public static void copyAddressAddrSObj(Address__c addr, sobject sobjDst, string strFieldPrefix, string strFieldAddrType) {
        sobjDst.put(strFieldPrefix + 'Street', getMultilineStreet(addr));
        sobjDst.put(strFieldPrefix + 'City', addr.MailingCity__c);
        sobjDst.put(strFieldPrefix + 'PostalCode', addr.MailingPostalCode__c);        
        sobjDst.put(strFieldPrefix + 'Latitude', addr.Geolocation__Latitude__s);
        sobjDst.put(strFieldPrefix + 'Longitude', addr.Geolocation__Longitude__s); 

        if (!isStateCountryPicklistsEnabled) {
            sobjDst.put(strFieldPrefix + 'State', addr.MailingState__c);
            sobjDst.put(strFieldPrefix + 'Country', addr.MailingCountry__c);
        } else {
            if (addr.MailingCountry__c != null) {
                if (validCountriesByLabel.containsKey(addr.MailingCountry__c)) {
                    sobjDst.put(strFieldPrefix + 'Country', addr.MailingCountry__c);
                    sobjDst.put(strFieldPrefix + 'CountryCode', validCountriesByLabel.get(addr.MailingCountry__c));
                } else if (validCountriesByCode.containsKey(addr.MailingCountry__c.toUpperCase())) {
                    sobjDst.put(strFieldPrefix + 'CountryCode', addr.MailingCountry__c.toUpperCase());
                    sobjDst.put(strFieldPrefix + 'Country', validCountriesByCode.get(addr.MailingCountry__c.toUpperCase()));
                } else {
                    // allow the invalid country to be placed in the country field, so Salesforce will generate the error.
                    sobjDst.put(strFieldPrefix + 'Country', addr.MailingCountry__c);
                }
            }
            if (addr.MailingState__c != null) {             
                if (validStatesByLabel.containsKey(addr.MailingState__c)) {
                    sobjDst.put(strFieldPrefix + 'State', addr.MailingState__c);
                    sobjDst.put(strFieldPrefix + 'StateCode', validStatesByLabel.get(addr.MailingState__c));
                } else {
                    // too expensive for us to create the map of CountryCode|StateCode to StateLabel
                    // so we will just try to save any state that isn't a label as a code.
                    sobjDst.put(strFieldPrefix + 'StateCode', addr.MailingState__c.toUpperCase());
                }
            }
        }
        
        if (strFieldAddrType != null)
            sobjDst.put(strFieldAddrType, addr.Address_Type__c);
    }

    /*******************************************************************************************************
    * @description specifies whether state and country picklists are enabled in this org.
    * @return true if enabled
    */ 
    public static Boolean isStateCountryPicklistsEnabled {
        get {
            if (isStateCountryPicklistsEnabled == null)
                isStateCountryPicklistsEnabled = initValidStateCountryCodes();
            return isStateCountryPicklistsEnabled;
        }
        private set;
    }

    /*******************************************************************************************************
    * @description utility to determine if the "State and Country Picklist" field feature is enabled in Salesforce
    * @return true if enabled; Fills 4 sets<> with a list of value codes and labels for each field
    */ 
    private static Boolean initValidStateCountryCodes() {

        // If State & Country Picklists are enabled in the org, build maps of the
        // valid Labels and Codes for each field to use for validation
        map<String, Schema.SObjectField> acctFields = Account.getSobjectType().getDescribe().fields.getMap();
        boolean isCodesEnabled = acctFields.containsKey('BillingCountryCode');
        if (isCodesEnabled) {
            list<Schema.Picklistentry> countryPLValues = acctFields.get('BillingCountryCode').getDescribe().getPicklistValues();
            for (Schema.Picklistentry p : countryPLValues) {
                if (p.isActive()) { 
                    validCountriesByLabel.put(p.getLabel(), p.getValue()); 
                    validCountriesByCode.put(p.getValue(), p.getLabel());
                }
            }
            list<Schema.Picklistentry> statePLValues = acctFields.get('BillingStateCode').getDescribe().getPicklistValues();
            for (Schema.Picklistentry p : statePLValues) {
                if (p.isActive()) { 
                    validStatesByLabel.put(p.getLabel(), p.getValue());
                    // we can't have a map of valid StateCodes, because they are not unique.
                    // ideally we would have a map of CountryCode + StateCode -> StateLabel
                    // but Salesforce provides us no way of figuring out picklist dependencies efficiently. 
                }
            }
        }
        return isCodesEnabled;
    }
    
}