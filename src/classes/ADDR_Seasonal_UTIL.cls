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
* @description Seasonal addresses utility methods.
*/
public with sharing class ADDR_Seasonal_UTIL {
    
    /*******************************************************************************************************
    * @description utility to return the current StartDate or EndDate of a Seasonal Address
    * @param addr the Address to look at
    * @param returnStartDate whether to return the StartDate or EndDate
    * @return Date
    */ 
    public static Date getStartOrEndDateOfAddrSeasonal(Address__c addr, Boolean returnStartDate) {    
        integer startYear = Integer.valueOf(addr.Seasonal_Start_Year__c);
        integer startMonth = Integer.valueOf(addr.Seasonal_Start_Month__c);
        integer startDay = Integer.valueOf(addr.Seasonal_Start_Day__c);
        
        integer endYear = Integer.valueOf(addr.Seasonal_End_Year__c);
        integer endMonth = Integer.valueOf(addr.Seasonal_End_Month__c);
        integer endDay = Integer.valueOf(addr.Seasonal_End_Day__c);
        
        Date startDate;
        Date endDate;
        Date dtToday = System.today();
        
        //start and end year have been provided (we don't allow providing only start or only end - addrSeasonalPartialYear error)
        if(startYear != null && endYear != null) {
            startDate = Date.newInstance(startYear, startMonth, startDay);
            endDate = Date.newInstance(endYear, endMonth, endDay);
        //start and end year have not been provided
        } else {
            //seasonal address is contained within a single year
            if (startMonth < endMonth ||(startMonth == endMonth && startDay <= endDay)) {
                UTIL_Debug.debug('****Seasonal address contained within a single year');
                startDate = Date.newInstance(dtToday.year(), startMonth, startDay);
                endDate = Date.newInstance(dtToday.year(), endMonth, endDay);
            //seasonal address overlaps the year, and current month is past the start month
            } else if (startMonth <= dtToday.month()){
                UTIL_Debug.debug('****seasonal address overlaps the year, and current month is past the start month');
                startDate = Date.newInstance(dtToday.year(), startMonth, startDay);
                endDate = Date.newInstance(dtToday.year()+1, endMonth, endDay);
            //seasonal address overlaps the year, and current month is before the start month
            } else {
                UTIL_Debug.debug('****seasonal address overlaps the year, and current month is before the start month');
                startDate = Date.newInstance(dtToday.year()-1, startMonth, startDay);
                endDate = Date.newInstance(dtToday.year(), endMonth, endDay);
            }
        }
        //to return the start or end date, depending on the second parameter passed to the method
        return (returnStartDate ? startDate : endDate);
    }
    
    /*******************************************************************************************************
    * @description utility to see if the address has seasonal fields set
    * @param addr the Address to look at
    * @return Boolean
    */ 
    public static Boolean isSeasonalAddr(Address__c addr) {
        return (addr.Seasonal_Start_Month__c != null && addr.Seasonal_Start_Day__c != null &&
           addr.Seasonal_End_Month__c != null && addr.Seasonal_End_Day__c != null);
    }
    
    /*******************************************************************************************************
    * @description utility to see if the address has only a subset of its seasonal fields set
    * @param addr the Address to look at
    * @return Boolean
    */ 
    private static Boolean isPartialSeasonalAddr(Address__c addr) {
        integer cParts = 0;
        if (addr.Seasonal_Start_Month__c != null) cParts++;
        if (addr.Seasonal_Start_Day__c != null) cParts++;
        if (addr.Seasonal_End_Month__c != null) cParts++;
        if (addr.Seasonal_End_Day__c != null) cParts++;
        return (cParts > 0 && cParts < 4);
    }
    
     /*******************************************************************************************************
    * @description utility to compare two address objects seasonal fields
    * @param addrNew the new version of the Address
    * @param addrOld the old version of the Address
    * @return Boolean. true if any of the seasonal fields have changed on the Address
    */ 
    public static Boolean isSeasonalChanged(Address__c addrNew, Address__c addrOld) {
        if (addrNew == null || addrOld == null) 
           return false;        
        return (
           addrNew.Seasonal_Start_Year__c != addrOld.Seasonal_Start_Year__c ||
           addrNew.Seasonal_End_Year__c != addrOld.Seasonal_End_Year__c ||
           addrNew.Seasonal_Start_Month__c != addrOld.Seasonal_Start_Month__c ||
           addrNew.Seasonal_Start_Day__c != addrOld.Seasonal_Start_Day__c ||
           addrNew.Seasonal_End_Month__c != addrOld.Seasonal_End_Month__c ||
           addrNew.Seasonal_End_Day__c != addrOld.Seasonal_End_Day__c || 
           ADDR_Addresses_UTIL.isAddressChanged(addrNew, addrOld, false));
    }
    
    /*******************************************************************************************************
    * @description utility to see if two seasonal addresses overlap
    * @param addr1 an Address
    * @param addr2 an Address
    * @return Boolean. true if the seasonal fields of the two addresses overlap
    */ 
    public static Boolean isSeasonalOverlap(Address__c addr1, Address__c addr2) {
        if (addr1 == null || addr2 == null) 
            return false;        
        if (!isSeasonalAddr(addr1) || !isSeasonalAddr(addr2))
            return false;

        //If only one of the addresses has start and end year but the other one doesn't, we can safely remove the 
        //start and end year from the one that has them for the seasonal overlap comparison (we do not accept seasonal 
        //addresses with only start or only end year). The one that doesn't have start and end year is valid every single
        //year.
        Integer startYear1 = (addr1.Seasonal_Start_Year__c == null ? System.today().year() : Integer.valueOf(addr1.Seasonal_Start_Year__c));
        Integer endYear1 = (addr1.Seasonal_End_Year__c == null ? System.today().year() : Integer.valueOf(addr1.Seasonal_End_Year__c));
        Integer startYear2 = (addr2.Seasonal_Start_Year__c == null ? System.today().year() : Integer.valueOf(addr2.Seasonal_Start_Year__c));
        Integer endYear2 = (addr2.Seasonal_End_Year__c == null ? System.today().year() : Integer.valueOf(addr2.Seasonal_End_Year__c));
        
        Date start1 = Date.newInstance(startYear1, Integer.valueOf(addr1.Seasonal_Start_Month__c), Integer.valueOf(addr1.Seasonal_Start_Day__c));
        Date end1 = Date.newInstance(endYear1, Integer.valueOf(addr1.Seasonal_End_Month__c), Integer.valueOf(addr1.Seasonal_End_Day__c));
        Date start2 = Date.newInstance(startYear2, Integer.valueOf(addr2.Seasonal_Start_Month__c), Integer.valueOf(addr2.Seasonal_Start_Day__c));
        Date end2 = Date.newInstance(endYear2, Integer.valueOf(addr2.Seasonal_End_Month__c), Integer.valueOf(addr2.Seasonal_End_Day__c));
         
        UTIL_Debug.debug('****Start date 1: ' + start1);
        UTIL_Debug.debug('****End date 1: ' + end1);
        UTIL_Debug.debug('****Start date 2 : ' + start2);
        UTIL_Debug.debug('****End date 2: ' + end2);
        
        Boolean isOverlap = false;
        //   date1 start contained in date2     -   date2 start contained in date1
        if ((start1 >= start2 && start1 <= end2) || (start2 >= start1 && start2 <= end1) 
        //  date2 end contained in date1, overlapping year - date1 end contained in date2, overlapping year 
        || (end2 < start2 && end2 >= start1) || (end1 < start1 && end1 >= start2)
        // both date1 and date2 overlap the year, and one of them overlaps the other
        || (end1 < start1 && end2 < start2 && (end2 >= end1 && end2 <= start1 || end1 >= end2 && end1 <= start2))) {
            isOverlap = true;
        }
        
        return isOverlap;
    }
    
     /*******************************************************************************************************
    * @description verify that any seasonal addresses don't overlap
    * Adds an Error to each Address object that has an illegal seasonal fields
    * @param listAddr a list of Addresses to verify
    * @return void. 
    */ 
    public static void verifyAddrSeasonalNoOverlap(List<Address__c> listAddr) { 
        
        // first get just the seasonal addresses
        List<Address__c> listAddrS = new List<Address__c>();
        for (Address__c addr : listAddr) {
            //either both start and year year are set or neither are
            if((addr.Seasonal_Start_Year__c != null && addr.Seasonal_End_Year__c == null) || (addr.Seasonal_Start_Year__c == null && addr.Seasonal_End_Year__c != null)) {
                addr.addError(Label.addrSeasonalPartialYear);
            }
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
                if ((addr.Parent_Account__c != null && addr.Parent_Account__c != addr2.Parent_Account__c) || 
                    (addr.Parent_Contact__c != null && addr.Parent_Contact__c != addr2.Parent_Contact__c))
                    continue;  
                Boolean isSeasonalOverlap = isSeasonalOverlap(addr, addr2);
                UTIL_Debug.debug('****Is Seasonal Overlap: ' + isSeasonalOverlap);
                if (isSeasonalOverlap) {
                    addr.addError(Label.addrSeasonalOverlap);
                }
            }
        }

        // now check for overlaps within each parent's saved addresses      
        Map<Id, List<Address__c>> mapAccIdListAddrs = ADDR_Addresses_UTIL.getParentIdToAddrs(listAddrS);
        
        for (Address__c addr : listAddrS) {
            if(mapAccIdListAddrs != null && mapAccIdListAddrs.size() > 0) {
                List<Address__c> childrenAddr;
                if(addr.Parent_Account__c != null)
                    childrenAddr = mapAccIdListAddrs.get(addr.Parent_Account__c);
                else if(addr.Parent_Contact__c != null)
                    childrenAddr = mapAccIdListAddrs.get(addr.Parent_Contact__c);
                for (Address__c addr2 : childrenAddr) {
                    if (addr.id == addr2.id)
                       continue;
                    Boolean isSeasonalOverlap = isSeasonalOverlap(addr, addr2);
                    UTIL_Debug.debug('****Is Seasonal Overlap: ' + isSeasonalOverlap);
                    if (isSeasonalOverlap) {
                        addr.addError(Label.addrSeasonalOverlap);
                        break;
                    }
                }
            }
        }
    }
    
    /*******************************************************************************************************
    * @description routine the scheduled batch job calls to update accounts with the specified Seasonal addresses
    * @param listAddr a list of Addresses to update
    * @return void
    */ 
    public static void batchSeasonalUpdate(List<Address__c> listAddr) {
        if (listAddr == null || listAddr.size() == 0) return;
        
        Map<Id, Address__c> mapAccIdAddr = new Map<Id, Address__c>();
        for (Address__c addr : listAddr) {
            if(addr.Parent_Account__c != null) {
                mapAccIdAddr.put(addr.Parent_Account__c, addr);
            } else if(addr.Parent_Contact__c != null) {
                mapAccIdAddr.put(addr.Parent_Contact__c, addr);
            }
        }
        
        // must manually set our semaphores, so when we update contacts and households, they don't try to create additional addresses
        ADDR_Account_TDTM.turnOff();
        ADDR_Contact_TDTM.turnOff();

        TDTM_Runnable.Dmlwrapper dmlWrapper = new TDTM_Runnable.Dmlwrapper();
        ADDR_Addresses_TDTM.refreshParentAndSiblings(mapAccIdAddr, dmlWrapper, null);

        // Process DML. Wewant to parse the errors so the allOrNone boolean is set to false
        ERR_Handler.Errors errors = TDTM_TriggerHandler.processDML(dmlWrapper, false); 

        // process results for an error otherwise we can assume success
        if (errors.errorsExist) {
            for (Error__c error : errors.errorRecords) {
                ID objId = ERR_Handler.getErrorObjectId(error);

                Address__c addr = mapAccIdAddr.get(objId);
                addr.addError(error.Full_Message__c);
            }
        }

    }
}