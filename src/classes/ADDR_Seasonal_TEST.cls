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
* @description Tests specific to Seasonal Address Management. 
*/

@isTest
private with sharing class ADDR_Seasonal_TEST {
    
    /*********************************************************************************************************
    @description
        insert new seasonal addresses to Account w/ existing default addresses  
    verify:
        contact's && hh address matches new seasonal
        old default addresses still marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewSeasonalAddr() {        
        // this creates a default Address for each Account
        ADDR_Addresses_TEST.createTestDataAccs(2);

        // create additional addresses
        ADDR_Addresses_TEST.initTestAddr(2);
        for (Integer i = 0; i < 2; i++) {
            ADDR_Addresses_TEST.listAddrs[i].Parent_Account__c = ADDR_Addresses_TEST.listAccs[i].Id;
            ADDR_Addresses_TEST.listAddrs[i].Default_Address__c = false;
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(-1).month());
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Day__c = '1';
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(1).month());
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Day__c = '28';
            ADDR_Addresses_TEST.listAddrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            ADDR_Addresses_TEST.listAddrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        insert ADDR_Addresses_TEST.listAddrs;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();
        
        // verify Account address is new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c
        from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            system.assert(acc.BillingStreet.contains('New Seasonal Street'));
            system.assert(acc.BillingCity.contains('New Seasonal City'));
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
        
        // verify the previous addresses still are Default
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(2 * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            system.assertEquals(!fSeasonal, addr.Default_Address__c);
        }        
    }
    
    /*********************************************************************************************************
    @description
        insert new seasonal addresses to HH w/ existing default addresses  
    verify:
        contact's && hh address matches new seasonal
        old default addresses still marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewSeasonalAddrWithYear() {
        // this creates a default Address for each Account
        ADDR_Addresses_TEST.createTestDataAccs(2);

        // create additional addresses
        ADDR_Addresses_TEST.initTestAddr(2);
        for (Integer i = 0; i < 2; i++) {
            ADDR_Addresses_TEST.listAddrs[i].Parent_Account__c = ADDR_Addresses_TEST.listAccs[i].Id;
            ADDR_Addresses_TEST.listAddrs[i].Default_Address__c = false;
            
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Year__c = System.today().addYears(-1).year();
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(-1).month());
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Day__c = '1';
            
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Year__c = System.today().addYears(1).year();
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(1).month());
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Day__c = '28';
            
            ADDR_Addresses_TEST.listAddrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            ADDR_Addresses_TEST.listAddrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        insert ADDR_Addresses_TEST.listAddrs;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();
        
        // verify Account address is new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c 
        from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            system.assert(acc.BillingStreet.contains('New Seasonal Street'));
            system.assert(acc.BillingCity.contains('New Seasonal City'));
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
        
        // verify the previous addresses still are Default
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, 
        Latest_End_Date__c from Address__c];
        system.assertEquals(2 * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            UTIL_Debug.debug('****Is seasonal: ' + fSeasonal);
            system.assertEquals(!fSeasonal, addr.Default_Address__c);
        }        
    }

    /*********************************************************************************************************
    @description
        insert new seasonal addresses, not current, to HH w/ existing default addresses  
    verify:
        contact's && hh address stay with default
        old default addresses still marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewSeasonalAddrNotCurrent() {
        // this creates a default Address for each Account
        ADDR_Addresses_TEST.createTestDataAccs(2);

        // create additional addresses
        ADDR_Addresses_TEST.initTestAddr(2);
        for (Integer i = 0; i < 2; i++) {
            ADDR_Addresses_TEST.listAddrs[i].Parent_Account__c = ADDR_Addresses_TEST.listAccs[i].Id;
            ADDR_Addresses_TEST.listAddrs[i].Default_Address__c = false;
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(1).month());
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Day__c = '1';
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(2).month());
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Day__c = '28';
            ADDR_Addresses_TEST.listAddrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            ADDR_Addresses_TEST.listAddrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        insert ADDR_Addresses_TEST.listAddrs;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();
        
        // verify Account address is new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c
        from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            system.assert(!acc.BillingStreet.contains('New Seasonal Street'));
            system.assert(!acc.BillingCity.contains('New Seasonal City'));
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
        
        // verify the previous addresses still are Default
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(2 * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            system.assertEquals(!fSeasonal, addr.Default_Address__c);
        }        
    }

    /*********************************************************************************************************
    @description
        update seasonal addresses to current, on HH w/ existing default addresses  
    verify:
        contact's && hh address updated to seasonal address
        old default addresses still marked default
    **********************************************************************************************************/            
    @isTest
    public static void updateSeasonalAddr() {        
        // this creates a default Address for each Account
        ADDR_Addresses_TEST.createTestDataAccs(2);
 
        // create additional seasonal addresses not current
        ADDR_Addresses_TEST.initTestAddr(2);
        for (Integer i = 0; i < 2; i++) {
            ADDR_Addresses_TEST.listAddrs[i].Parent_Account__c = ADDR_Addresses_TEST.listAccs[i].Id;
            ADDR_Addresses_TEST.listAddrs[i].Default_Address__c = false;
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(1).month());
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Day__c = '1';
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(2).month());
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Day__c = '28';
            ADDR_Addresses_TEST.listAddrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            ADDR_Addresses_TEST.listAddrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert ADDR_Addresses_TEST.listAddrs;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // now make them current
        for (Integer i = 0; i < 2; i++) {
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(-1).month());
        }
        Test.startTest();
        update ADDR_Addresses_TEST.listAddrs;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;                
        Test.stopTest();
        
        // verify Account address is new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c
        from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            system.assert(acc.BillingStreet.contains('New Seasonal Street'));
            system.assert(acc.BillingCity.contains('New Seasonal City'));
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
        
        // verify the previous addresses still are Default
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, 
        Latest_End_Date__c from Address__c];
        system.assertEquals(2 * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            system.assertEquals(!fSeasonal, addr.Default_Address__c);
        }        
    }
    
    /*********************************************************************************************************
    @description
        create multiple seasonal address that overlap with eachother  
    verify:
        overlap detected, seasonal addresses don't save
    **********************************************************************************************************/            
    @isTest
    public static void insertSeasonalAddrWithOverlap() {        
        // this creates a default Address for each Account
        ADDR_Addresses_TEST.createTestDataAccs(2);

        // create additional seasonal addresses not current
        ADDR_Addresses_TEST.initTestAddr(2 * 2);
        for (Integer i = 0; i < 2 * 2; i++) {
            Integer iacc = i < 2 ? i : i-2;
            if (math.mod(i, 2) == 0) {
                ADDR_Addresses_TEST.listAddrs[i].Parent_Account__c = ADDR_Addresses_TEST.listAccs[iacc].Id;
                ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(1).month());
                ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Day__c = '1';
                ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(3).month());
                ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Day__c = '28';
            } else {
                ADDR_Addresses_TEST.listAddrs[i].Parent_Account__c = ADDR_Addresses_TEST.listAccs[iacc-1].Id;
                ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(-1).month());
                ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Day__c = '1';
                ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(2).month());
                ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Day__c = '28';            
            }
            ADDR_Addresses_TEST.listAddrs[i].Default_Address__c = false;
            ADDR_Addresses_TEST.listAddrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            ADDR_Addresses_TEST.listAddrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        try {
            insert ADDR_Addresses_TEST.listAddrs;
        } catch (Exception ex) {
            system.assert(ex.getMessage().contains(Label.addrSeasonalOverlap));
            return;
        }
        system.assert(false); //we shouldn't get here!
        
    }

    /*********************************************************************************************************
    @description
        create multiple seasonal address that overlap with eachother  
    verify:
        overlap detected
    **********************************************************************************************************/            
    @isTest
    public static void testSeasonalAddrOverlapLogic() {        
        Address__c a1 = new Address__c();
        Address__c a2 = new Address__c();

        // test both increasing ranges, no overlap
        a1.Seasonal_Start_Month__c = '1';
        a1.Seasonal_Start_Day__c = '29';
        a1.Seasonal_End_Month__c = '3';
        a1.Seasonal_End_Day__c = '28';     
        a2.Seasonal_Start_Month__c = '4';
        a2.Seasonal_Start_Day__c = '1';
        a2.Seasonal_End_Month__c = '6';
        a2.Seasonal_End_Day__c = '28';
        system.assertEquals(false, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        system.assertEquals(false, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));
        
        // test both increasing ranges, with overlap
        a2.Seasonal_Start_Month__c = '2';
        a2.Seasonal_End_Month__c = '6';
        system.assertEquals(true, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        system.assertEquals(true, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));
        
        // test one increasing range, one decreasing range, no overlap
        a1.Seasonal_Start_Month__c = '3';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '5';
        a1.Seasonal_End_Day__c = '28';
        a2.Seasonal_Start_Month__c = '11';
        a2.Seasonal_Start_Day__c = '1';
        a2.Seasonal_End_Month__c = '2';
        a2.Seasonal_End_Day__c = '28';
        system.assertEquals(false, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        system.assertEquals(false, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));

        // test one increasing range, one decreasing range, with overlap
        a2.Seasonal_Start_Month__c = '11';
        a2.Seasonal_Start_Day__c = '1';
        a2.Seasonal_End_Month__c = '4';
        a2.Seasonal_End_Day__c = '28';
        system.assertEquals(true, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        system.assertEquals(true, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));

        // test both decreasing ranges, always overlap
        a1.Seasonal_Start_Month__c = '9';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '2';
        a1.Seasonal_End_Day__c = '28';
        a2.Seasonal_Start_Month__c = '12';
        a2.Seasonal_Start_Day__c = '1';
        a2.Seasonal_End_Month__c = '3';
        a2.Seasonal_End_Day__c = '28';
        system.assertEquals(true, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        system.assertEquals(true, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));
        
        // test both increasing ranges in the same month, no overlap
        a1.Seasonal_Start_Month__c = '2';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '2';
        a1.Seasonal_End_Day__c = '10';
        a2.Seasonal_Start_Month__c = '2';
        a2.Seasonal_Start_Day__c = '11';
        a2.Seasonal_End_Month__c = '2';
        a2.Seasonal_End_Day__c = '28';
        system.assertEquals(false, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        system.assertEquals(false, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));

        // test both increasing ranges in the same month, with overlap
        a1.Seasonal_Start_Month__c = '2';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '2';
        a1.Seasonal_End_Day__c = '10';
        a2.Seasonal_Start_Month__c = '2';
        a2.Seasonal_Start_Day__c = '10';
        a2.Seasonal_End_Month__c = '2';
        a2.Seasonal_End_Day__c = '28';
        system.assertEquals(true, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        system.assertEquals(true, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));

        // test one increasing range, one decreasing range in the same month, no overlap
        a1.Seasonal_Start_Month__c = '2';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '2';
        a1.Seasonal_End_Day__c = '10';
        a2.Seasonal_Start_Month__c = '2';
        a2.Seasonal_Start_Day__c = '11';
        a2.Seasonal_End_Month__c = '1';
        a2.Seasonal_End_Day__c = '28';
        system.assertEquals(false, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        system.assertEquals(false, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));
    }
    
    /*********************************************************************************************************
    @description
        create multiple seasonal address that overlap with eachother  
    verify:
        overlap detected
    **********************************************************************************************************/            
    @isTest
    public static void testSeasonalAddrOverlapLogicCurrentMonth() {
        Address__c a1 = new Address__c();
        Address__c a2 = new Address__c();
        
        // test one increasing range, one decreasing range in the same month, with overlap
        a1.Seasonal_Start_Month__c = String.valueOf(System.today().month());
        a1.Seasonal_Start_Day__c = '1'; 
        a1.Seasonal_End_Month__c = String.valueOf(System.today().month());
        a1.Seasonal_End_Day__c = '10';  //1st of current month to 10th of current month
        
        a2.Seasonal_Start_Month__c = String.valueOf(System.today().month());
        a2.Seasonal_Start_Day__c = '11'; 
        a2.Seasonal_End_Month__c = String.valueOf(System.today().month());
        a2.Seasonal_End_Day__c = '1';   //11th of current month to 1st of current month (overlaps year)
        system.assertEquals(true, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        system.assertEquals(true, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));
    }
    
    /*********************************************************************************************************
    @description
        create multiple seasonal address that overlap with eachother  
    verify:
        overlap detected
    **********************************************************************************************************/            
    @isTest
    public static void testSeasonalAddrOverlapLogicNextMonth() {
        Address__c a1 = new Address__c();
        Address__c a2 = new Address__c();
        
        // test one increasing range, one decreasing range in the same month, with overlap
        a1.Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(1).month());
        a1.Seasonal_Start_Day__c = '1'; 
        a1.Seasonal_End_Month__c = String.valueOf(System.today().addMonths(1).month());
        a1.Seasonal_End_Day__c = '10';  //1st of next month to 10th of next month
        
        a2.Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(1).month());
        a2.Seasonal_Start_Day__c = '11'; 
        a2.Seasonal_End_Month__c = String.valueOf(System.today().addMonths(1).month());
        a2.Seasonal_End_Day__c = '1';   //11th of next month to 1st of next month(overlaps year)
        system.assertEquals(true, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        system.assertEquals(true, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));
    }
    
    /*********************************************************************************************************
    @description
        create multiple seasonal address that overlap with eachother  
    verify:
        overlap detected
    **********************************************************************************************************/            
    @isTest
    public static void testSeasonalAddrOverlapLogicPreviousMonth() {
        Address__c a1 = new Address__c();
        Address__c a2 = new Address__c();
        
        // test one increasing range, one decreasing range in the same month, with overlap
        a1.Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(-1).month());
        a1.Seasonal_Start_Day__c = '1'; 
        a1.Seasonal_End_Month__c = String.valueOf(System.today().addMonths(-1).month());
        a1.Seasonal_End_Day__c = '10';  //1st of previous month to 10th of previous month
        
        a2.Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(-1).month());
        a2.Seasonal_Start_Day__c = '11'; 
        a2.Seasonal_End_Month__c = String.valueOf(System.today().addMonths(-1).month());
        a2.Seasonal_End_Day__c = '1';   //11th of previous month to 1st of previous month(overlaps year)
        system.assertEquals(true, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        system.assertEquals(true, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));
    }
    
    /*********************************************************************************************************
    @description
        create multiple seasonal address that overlap existing seasonal addresses  
    verify:
        overlap detected, seasonal addresses don't save
    **********************************************************************************************************/            
    @isTest
    public static void insertSeasonalAddrOverlapExisting() {        
        // this creates a default Address for each Account
        ADDR_Addresses_TEST.createTestDataAccs(2);

        // create additional seasonal addresses not current
        ADDR_Addresses_TEST.initTestAddr(2);
        Date dtTest = Date.newInstance(system.today().year(), 6, 1);
        
        for (Integer i = 0; i < 2; i++) {
            ADDR_Addresses_TEST.listAddrs[i].Parent_Account__c = ADDR_Addresses_TEST.listAccs[i].Id;
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Month__c = string.valueOf(dtTest.addMonths(1).month());
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Day__c = '1';
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Month__c = string.valueOf(dtTest.addMonths(3).month());
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Day__c = '28';
            ADDR_Addresses_TEST.listAddrs[i].Default_Address__c = false;
            ADDR_Addresses_TEST.listAddrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            ADDR_Addresses_TEST.listAddrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert ADDR_Addresses_TEST.listAddrs;
        
        // create additional seasonal addresses that overlap existing seasonal addresses
        ADDR_Addresses_TEST.initTestAddr(2);
        for (Integer i = 0; i < 2; i++) {
            ADDR_Addresses_TEST.listAddrs[i].Parent_Account__c = ADDR_Addresses_TEST.listAccs[i].Id;
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Month__c = string.valueOf(dtTest.addMonths(2).month());
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Day__c = '1';
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Month__c = string.valueOf(dtTest.addMonths(4).month());
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Day__c = '28';
            ADDR_Addresses_TEST.listAddrs[i].Default_Address__c = false;
            ADDR_Addresses_TEST.listAddrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            ADDR_Addresses_TEST.listAddrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        try {
            insert ADDR_Addresses_TEST.listAddrs;
        } catch (Exception ex) {
            system.assert(ex.getMessage().contains(Label.addrSeasonalOverlap));
            return;
        }
        system.assert(false); //we shouldn't get here!
        
    }

    /*********************************************************************************************************
    @description
        create multiple partial seasonal address  
    verify:
        partial seasonal detected, seasonal addresses don't save
    **********************************************************************************************************/            
    @isTest
    public static void insertPartialSeasonalAddr() {        
        // this creates a default Address for each Account
        ADDR_Addresses_TEST.createTestDataAccs(2);

        // create additional seasonal addresses not current
        ADDR_Addresses_TEST.initTestAddr(2);
        for (Integer i = 0; i < 2; i++) {
            ADDR_Addresses_TEST.listAddrs[i].Parent_Account__c = ADDR_Addresses_TEST.listAccs[i].Id;
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(1).month());
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Day__c = '1';
            ADDR_Addresses_TEST.listAddrs[i].Default_Address__c = false;
            ADDR_Addresses_TEST.listAddrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            ADDR_Addresses_TEST.listAddrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        try {
            insert ADDR_Addresses_TEST.listAddrs;
        } catch (Exception ex) {
            system.assert(ex.getMessage().contains(Label.addrSeasonalPartial));
            return;
        }
        system.assert(false); //we shouldn't get here!
        
    }
    
    /*********************************************************************************************************
    @description
        create multiple seasonal address with only either start or end year
    verify:
        partial seasonal detected, seasonal addresses don't save
    **********************************************************************************************************/            
    @isTest
    public static void insertPartialSeasonalYearAddr() {        
        // this creates a default Address for each Account
        ADDR_Addresses_TEST.createTestDataAccs(2);

        // create additional seasonal addresses not current
        ADDR_Addresses_TEST.initTestAddr(2);
        for (Integer i = 0; i < 2; i++) {
            ADDR_Addresses_TEST.listAddrs[i].Parent_Account__c = ADDR_Addresses_TEST.listAccs[i].Id;
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(1).month());
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Day__c = '1';
            if(math.mod(i, 2) == 0) {
                ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Year__c = Decimal.valueOf(system.today().year());
            } else {
                ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Year__c = Decimal.valueOf(system.today().year());
            }
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(2).month());
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Day__c = '20';
            ADDR_Addresses_TEST.listAddrs[i].Default_Address__c = false;
            ADDR_Addresses_TEST.listAddrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            ADDR_Addresses_TEST.listAddrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        try {
            insert ADDR_Addresses_TEST.listAddrs;
        } catch (Exception ex) {
            system.assert(ex.getMessage().contains(Label.addrSeasonalPartialYear));
            return;
        }
        system.assert(false); //we shouldn't get here!
        
    }

    /*********************************************************************************************************
    @description
        schedule a seasonal address update 
    verify:
        contact's && hh address matches new seasonal
        old default addresses still marked default
    **********************************************************************************************************/            
    @isTest
    public static void scheduleSeasonalAddrUpdate() {        
        // this creates a default Address for each Account
        ADDR_Addresses_TEST.createTestDataAccs(2);

        // create additional addresses
        ADDR_Addresses_TEST.initTestAddr(2);
        for (Integer i = 0; i < 2; i++) {
            ADDR_Addresses_TEST.listAddrs[i].Parent_Account__c = ADDR_Addresses_TEST.listAccs[i].Id;
            ADDR_Addresses_TEST.listAddrs[i].Default_Address__c = false;
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Month__c = string.valueOf(system.today().month());
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_Start_Day__c = string.valueOf(system.today().day());
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(1).month());
            ADDR_Addresses_TEST.listAddrs[i].Seasonal_End_Day__c = '28';
            ADDR_Addresses_TEST.listAddrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            ADDR_Addresses_TEST.listAddrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        
        // Hack!  by setting our trigger handler as run,
        // we can insert the new seasonal addresses but not have them processed.
        // this way we can test the scheduled job!
        ADDR_Addresses_TDTM.hasRunAddrTrigger = true;
        insert ADDR_Addresses_TEST.listAddrs;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;

        //Schedule the job just for test coverage purposes. But we still have to manually run the
        //batch, as batch jobs run from a scheduled job don't actually run after stopTest, as described
        //at https://salesforce.stackexchange.com/questions/36806/does-test-stoptest-ensure-a-system-schedule-database-batchable-completes-in-a
        STG_InstallScript.scheduleJobIfNotScheduled('Seasonal Addresses Update', '0 15 0 * * ?', 'ADDR_Seasonal_SCHED');
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name = 'Seasonal Addresses Update'];
        // Verify the expressions are the same
        System.assertEquals('0 15 0 * * ?', ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        System.assert(String.valueOf(ct.NextFireTime).contains('00:15:00'));
        
        // run the scheduled batch directly
        ADDR_Seasonal_BATCH batch = new ADDR_Seasonal_BATCH();
        Test.startTest(); 
        Database.executeBatch(batch);
        Test.stopTest();
        
        // verify Account address is new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c 
        from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            system.assert(acc.BillingStreet.contains('New Seasonal Street'));
            system.assert(acc.BillingCity.contains('New Seasonal City'));
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
        
        // verify the previous addresses still are Default
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, 
        Latest_End_Date__c from Address__c];
        system.assertEquals(2 * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            system.assertEquals(!fSeasonal, addr.Default_Address__c);
        }        
    }
    
    @isTest
    public static void testSeasonalStartEndYearCurrent() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(
            Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID(), 
            Accounts_Addresses_Enabled__c = UTIL_Describe.getAdminAccRecTypeID() + ';', 
            Simple_Address_Change_Treated_as_Update__c = true));
              
        //Create Account with Address info
        Account acc = new Account(Name = 'Testerson', RecordTypeID = UTIL_Describe.getAdminAccRecTypeID(), BillingStreet = '123 Default', 
        BillingCity = 'Chicago', BillingState = 'IL');
        insert acc;

                
        //Address flagged as default should have been created
        Address__c defaultAddress = [select ID, Default_Address__c from Address__c where Parent_Account__c = : acc.ID];
        System.assertEquals(true, defaultAddress.Default_Address__c);
        
        //Create seasonal Address with start and end year that include the current date
        Address__c seasonalAddress = new Address__c(Parent_Account__c = acc.ID, MailingStreet__c = '123 Seasonal', MailingCity__c = 'Seattle', 
            MailingState__c = 'WA', Seasonal_Start_Day__c = String.valueOf(system.today().addDays(-1).day()), 
            Seasonal_Start_Month__c = String.valueOf(system.today().addMonths(-1).month()), Seasonal_Start_Year__c = system.today().addYears(-1).year(), 
            Seasonal_End_Day__c = String.valueOf(system.today().addDays(1).day()), Seasonal_End_Month__c = String.valueOf(system.today().addMonths(1).month()), 
            Seasonal_End_Year__c = system.today().addYears(1).year());
        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        insert seasonalAddress;
        Test.stopTest();
        
        //Seasonal Address should have been copied to the Account      
        acc = [select BillingStreet, BillingCity, BillingState from Account where ID = :acc.ID];
        System.assertEquals('123 Seasonal', acc.BillingStreet);
        System.assertEquals('Seattle', acc.BillingCity);
        System.assertEquals('WA', acc.BillingState);
    }
    
    @isTest
    public static void testSeasonalStartEndYearFromAcc() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(
            Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID(), 
            Accounts_Addresses_Enabled__c = UTIL_Describe.getAdminAccRecTypeID() + ';', 
            Simple_Address_Change_Treated_as_Update__c = true));
              
        //Create Account without Address info
        Account acc = new Account(Name = 'Testerson', RecordTypeID = UTIL_Describe.getAdminAccRecTypeID());
        insert acc;
        
        //Create seasonal Address with start and end year.
        Address__c seasonalAddress = new Address__c(Parent_Account__c = acc.ID, MailingStreet__c = '123 Seasonal', MailingCity__c = 'Seattle', 
            MailingState__c = 'WA', Seasonal_Start_Day__c = String.valueOf(system.today().addDays(-1).day()), 
            Seasonal_Start_Month__c = String.valueOf(system.today().addMonths(-1).month()), Seasonal_Start_Year__c = system.today().year(), 
            Seasonal_End_Day__c = String.valueOf(system.today().addDays(1).day()), Seasonal_End_Month__c = String.valueOf(system.today().addMonths(1).month()), 
            Seasonal_End_Year__c = system.today().year());
        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert seasonalAddress; 
        
        //No NPE should have been thrown. Github #197.
        
        //Create second seasonal Address with start and end year.
        Address__c seasonalAddress2 = new Address__c(Parent_Account__c = acc.ID, MailingStreet__c = '123 Seasonal', MailingCity__c = 'Seattle', 
            MailingState__c = 'WA', Seasonal_Start_Day__c = String.valueOf(system.today().addDays(-1).day()), 
            Seasonal_Start_Month__c = String.valueOf(system.today().addMonths(-1).month()), Seasonal_Start_Year__c = system.today().addYears(1).year(), 
            Seasonal_End_Day__c = String.valueOf(system.today().addDays(1).day()), Seasonal_End_Month__c = String.valueOf(system.today().addMonths(1).month()), 
            Seasonal_End_Year__c = system.today().addYears(1).year());
        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        insert seasonalAddress2;
        Test.stopTest();
        
        //Second address should have been successfully saved, without overlap error. Github #196.
        List<Address__c> addrs = [select ID from Address__c where Parent_Account__c = :acc.ID];
        System.assertEquals(2, addrs.size());
    }
    
    @isTest
    public static void testSeasonalStartEndYearUpdateInfo() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(
            Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID(), 
            Accounts_Addresses_Enabled__c = UTIL_Describe.getAdminAccRecTypeID() + ';', 
            Simple_Address_Change_Treated_as_Update__c = true));
              
        //Create Account with Address info
        Account acc = new Account(Name = 'Testerson', RecordTypeID = UTIL_Describe.getAdminAccRecTypeID(), BillingStreet = '123 Default', 
        BillingCity = 'Chicago', BillingState = 'IL');
        insert acc;
                
        //Address flagged as default should have been created
        Address__c defaultAddress = [select ID, Default_Address__c from Address__c where Parent_Account__c = : acc.ID];
        System.assertEquals(true, defaultAddress.Default_Address__c);
        
        //Create seasonal Address with start and end year that include the current date
        Address__c seasonalAddress = new Address__c(Parent_Account__c = acc.ID, MailingStreet__c = '123 Seasonal', MailingCity__c = 'Seattle', 
            MailingState__c = 'WA', Seasonal_Start_Day__c = String.valueOf(system.today().addDays(-1).day()), 
            Seasonal_Start_Month__c = String.valueOf(system.today().addMonths(-1).month()), Seasonal_Start_Year__c = system.today().addYears(-1).year(), 
            Seasonal_End_Day__c = String.valueOf(system.today().addDays(1).day()), Seasonal_End_Month__c = String.valueOf(system.today().addMonths(1).month()), 
            Seasonal_End_Year__c = system.today().addYears(1).year());
        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert seasonalAddress;
        
        //Modify seasonal Address info
        seasonalAddress.MailingStreet__c = 'New Seasonal Address';
        seasonalAddress.MailingCity__c = 'Portland';
        seasonalAddress.MailingState__c = 'OR';
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update seasonalAddress;
        Test.stopTest();
        
        //Changes should have been copied to Account    
        acc = [select BillingStreet, BillingCity, BillingState from Account where ID = :acc.ID];
        System.assertEquals('New Seasonal Address', acc.BillingStreet);
        System.assertEquals('Portland', acc.BillingCity);
        System.assertEquals('OR', acc.BillingState);
    }
    
    @isTest
    public static void testSeasonalStartEndYearUpdateDates() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(
            Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID(), 
            Accounts_Addresses_Enabled__c = UTIL_Describe.getAdminAccRecTypeID() + ';', 
            Simple_Address_Change_Treated_as_Update__c = true));
              
        //Create Contact with Address info
        Account acc = new Account(Name = 'Testerson', RecordTypeID = UTIL_Describe.getAdminAccRecTypeID(), BillingStreet = '123 Default', 
        BillingCity = 'Chicago', BillingState = 'IL');
        insert acc;
                
        //Address flagged as default should have been created
        Address__c defaultAddress = [select ID, Default_Address__c from Address__c where Parent_Account__c = : acc.ID];
        System.assertEquals(true, defaultAddress.Default_Address__c);
        
        //Create seasonal Address with start and end year that include the current date
        Address__c seasonalAddress = new Address__c(Parent_Account__c = acc.ID, MailingStreet__c = '123 Seasonal', MailingCity__c = 'Seattle', 
            MailingState__c = 'WA', Seasonal_Start_Day__c = String.valueOf(system.today().addDays(-1).day()), 
            Seasonal_Start_Month__c = String.valueOf(system.today().addMonths(-1).month()), Seasonal_Start_Year__c = system.today().addYears(-1).year(), 
            Seasonal_End_Day__c = String.valueOf(system.today().addDays(1).day()), Seasonal_End_Month__c = String.valueOf(system.today().addMonths(1).month()), 
            Seasonal_End_Year__c = system.today().addYears(1).year());
        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert seasonalAddress;
        
        //Modify seasonal Address dates so it doesn't include today
        seasonalAddress.Seasonal_Start_Year__c = system.today().addYears(1).year();
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update seasonalAddress;
        Test.stopTest();
        
        //Account should have reverted to default address        
        acc = [select BillingStreet, BillingCity, BillingState from Account where ID = :acc.ID];
        System.assertEquals('123 Default', acc.BillingStreet);
        System.assertEquals('Chicago', acc.BillingCity);
        System.assertEquals('IL', acc.BillingState);
    }
    
    @isTest
    public static void testSeasonalStartEndYearDelete() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(
            Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID(), 
            Accounts_Addresses_Enabled__c = UTIL_Describe.getAdminAccRecTypeID() + ';', 
            Simple_Address_Change_Treated_as_Update__c = true));
              
        //Create Contact with Address info
        Account acc = new Account(Name = 'Testerson', RecordTypeID = UTIL_Describe.getAdminAccRecTypeID(), BillingStreet = '123 Default', 
        BillingCity = 'Chicago', BillingState = 'IL');
        insert acc;
                
        //Address flagged as default should have been created
        Address__c defaultAddress = [select ID, Default_Address__c from Address__c where Parent_Account__c = : acc.ID];
        System.assertEquals(true, defaultAddress.Default_Address__c);
        
        //Create seasonal Address with start and end year that include the current date
        Address__c seasonalAddress = new Address__c(Parent_Account__c = acc.ID, MailingStreet__c = '123 Seasonal', MailingCity__c = 'Seattle', 
            MailingState__c = 'WA', Seasonal_Start_Day__c = String.valueOf(system.today().addDays(-1).day()), 
            Seasonal_Start_Month__c = String.valueOf(system.today().addMonths(-1).month()), Seasonal_Start_Year__c = system.today().addYears(-1).year(), 
            Seasonal_End_Day__c = String.valueOf(system.today().addDays(1).day()), Seasonal_End_Month__c = String.valueOf(system.today().addMonths(1).month()), 
            Seasonal_End_Year__c = system.today().addYears(1).year());
        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert seasonalAddress;
        
        //Delete seasonal Address
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        delete seasonalAddress;
        Test.stopTest();
        
        //Account should have reverted to default address
        acc = [select BillingStreet, BillingCity, BillingState from Account where ID = :acc.ID];
        System.assertEquals('123 Default', acc.BillingStreet);
        System.assertEquals('Chicago', acc.BillingCity);
        System.assertEquals('IL', acc.BillingState);
    }
}