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
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;

        // create additional addresses
        addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = accsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = false;
            addrs[i].Seasonal_Start_Month__c = String.valueOf(system.today().addMonths(-1).month());
            addrs[i].Seasonal_Start_Day__c = '1';
            addrs[i].Seasonal_End_Month__c = String.valueOf(system.today().addMonths(1).month());
            addrs[i].Seasonal_End_Day__c = '28';
            addrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert addrs;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();

        // verify Account address is new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState,
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c
        from Account]);

        for (Account acc : mapAccIdAcc.values()) {
            system.assert(acc.BillingStreet.contains('New Seasonal Street'));
            system.assert(acc.BillingCity.contains('New Seasonal City'));
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
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;

        // create additional addresses
        addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = accsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = false;

            addrs[i].Seasonal_Start_Year__c = System.today().addYears(-1).year();
            addrs[i].Seasonal_Start_Month__c = String.valueOf(system.today().addMonths(-1).month());
            addrs[i].Seasonal_Start_Day__c = '1';

            addrs[i].Seasonal_End_Year__c = System.today().addYears(1).year();
            addrs[i].Seasonal_End_Month__c = String.valueOf(system.today().addMonths(1).month());
            addrs[i].Seasonal_End_Day__c = '28';

            addrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert addrs;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();

        // verify Account address is new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState,
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c
        from Account]);

        for (Account acc : mapAccIdAcc.values()) {
            system.assert(acc.BillingStreet.contains('New Seasonal Street'));
            system.assert(acc.BillingCity.contains('New Seasonal City'));
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
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;

        // create additional addresses
        addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = accsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = false;
            addrs[i].Seasonal_Start_Month__c = String.valueOf(system.today().addMonths(1).month());
            addrs[i].Seasonal_Start_Day__c = '1';
            addrs[i].Seasonal_End_Month__c = String.valueOf(system.today().addMonths(2).month());
            addrs[i].Seasonal_End_Day__c = '28';
            addrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert addrs;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();

        // verify Account address is new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState,
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c
        from Account]);

        for (Account acc : mapAccIdAcc.values()) {
            system.assert(!acc.BillingStreet.contains('New Seasonal Street'));
            system.assert(!acc.BillingCity.contains('New Seasonal City'));
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
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;

        // create additional seasonal addresses not current
        addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = accsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = false;
            addrs[i].Seasonal_Start_Month__c = String.valueOf(system.today().addMonths(1).month());
            addrs[i].Seasonal_Start_Day__c = '1';
            addrs[i].Seasonal_End_Month__c = String.valueOf(system.today().addMonths(2).month());
            addrs[i].Seasonal_End_Day__c = '28';
            addrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert addrs;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();

        // now make them current
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Seasonal_Start_Month__c = String.valueOf(system.today().addMonths(-1).month());
        }
        Test.startTest();
        update addrs;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();

        // verify Account address is new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState,
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c
        from Account]);

        for (Account acc : mapAccIdAcc.values()) {
            system.assert(acc.BillingStreet.contains('New Seasonal Street'));
            system.assert(acc.BillingCity.contains('New Seasonal City'));
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
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;

        // create additional seasonal addresses not current
        addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2 * 2);
        for (Integer i = 0; i < 2 * 2; i++) {
            Integer iacc = i < 2 ? i : i-2;
            if (math.mod(i, 2) == 0) {
                addrs[i].Parent_Account__c = accsAddrs.accs[iacc].Id;
                addrs[i].Seasonal_Start_Month__c = String.valueOf(system.today().addMonths(1).month());
                addrs[i].Seasonal_Start_Day__c = '1';
                addrs[i].Seasonal_End_Month__c = String.valueOf(system.today().addMonths(3).month());
                addrs[i].Seasonal_End_Day__c = '28';
            } else {
                addrs[i].Parent_Account__c = accsAddrs.accs[iacc-1].Id;
                addrs[i].Seasonal_Start_Month__c = String.valueOf(system.today().addMonths(-1).month());
                addrs[i].Seasonal_Start_Day__c = '1';
                addrs[i].Seasonal_End_Month__c = String.valueOf(system.today().addMonths(2).month());
                addrs[i].Seasonal_End_Day__c = '28';
            }
            addrs[i].Default_Address__c = false;
            addrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        try {
            insert addrs;
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
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;

        // create additional seasonal addresses not current
        addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        Date dtTest = Date.newInstance(system.today().year(), 6, 1);

        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = accsAddrs.accs[i].Id;
            addrs[i].Seasonal_Start_Month__c = String.valueOf(dtTest.addMonths(1).month());
            addrs[i].Seasonal_Start_Day__c = '1';
            addrs[i].Seasonal_End_Month__c = String.valueOf(dtTest.addMonths(3).month());
            addrs[i].Seasonal_End_Day__c = '28';
            addrs[i].Default_Address__c = false;
            addrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert addrs;

        // create additional seasonal addresses that overlap existing seasonal addresses
        addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = accsAddrs.accs[i].Id;
            addrs[i].Seasonal_Start_Month__c = String.valueOf(dtTest.addMonths(2).month());
            addrs[i].Seasonal_Start_Day__c = '1';
            addrs[i].Seasonal_End_Month__c = String.valueOf(dtTest.addMonths(4).month());
            addrs[i].Seasonal_End_Day__c = '28';
            addrs[i].Default_Address__c = false;
            addrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        try {
            insert addrs;
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
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;

        // create additional seasonal addresses not current
        addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = accsAddrs.accs[i].Id;
            addrs[i].Seasonal_Start_Month__c = String.valueOf(system.today().addMonths(1).month());
            addrs[i].Seasonal_Start_Day__c = '1';
            addrs[i].Default_Address__c = false;
            addrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        try {
            insert addrs;
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
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;

        // create additional seasonal addresses not current
        addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = accsAddrs.accs[i].Id;
            addrs[i].Seasonal_Start_Month__c = String.valueOf(system.today().addMonths(1).month());
            addrs[i].Seasonal_Start_Day__c = '1';
            if(math.mod(i, 2) == 0) {
                addrs[i].Seasonal_Start_Year__c = Decimal.valueOf(system.today().year());
            } else {
                addrs[i].Seasonal_End_Year__c = Decimal.valueOf(system.today().year());
            }
            addrs[i].Seasonal_End_Month__c = String.valueOf(system.today().addMonths(2).month());
            addrs[i].Seasonal_End_Day__c = '20';
            addrs[i].Default_Address__c = false;
            addrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        try {
            insert addrs;
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
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c(
            Accounts_Addresses_Enabled__c = UTIL_Describe.getAdminAccRecTypeID() + ';',
            Contacts_Addresses_Enabled__c = true,
            Simple_Address_Change_Treated_as_Update__c = true);
        UTIL_CustomSettingsFacade.getSettingsForTests(hs);

        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getAdminAccRecTypeID());
        List<Address__c> accAddrs = accsAddrs.addrs;

        // this creates a default Address for each Contact
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);
        List<Address__c> conAddrs = contactsAddrs.addrs;

        // create additional Account addresses, with seasonal information
        List<Address__c> accAddrs2 = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            accAddrs2[i].Parent_Account__c = accsAddrs.accs[i].Id;
            accAddrs2[i].Default_Address__c = false;
            accAddrs2[i].Seasonal_Start_Month__c = String.valueOf(system.today().month());
            accAddrs2[i].Seasonal_Start_Day__c = String.valueOf(system.today().day());
            accAddrs2[i].Seasonal_End_Month__c = String.valueOf(system.today().addMonths(1).month());
            accAddrs2[i].Seasonal_End_Day__c = '28';
            accAddrs2[i].MailingStreet__c = 'New Seasonal Street' + i;
            accAddrs2[i].MailingCity__c = 'New Seasonal City' + i;
        }

        // create additional Contact addresses, with seasonal information
        List<Address__c> conAddrs2 = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            conAddrs2[i].Parent_Contact__c = contactsAddrs.contacts[i].Id;
            conAddrs2[i].Default_Address__c = false;
            conAddrs2[i].Seasonal_Start_Month__c = String.valueOf(system.today().month());
            conAddrs2[i].Seasonal_Start_Day__c = String.valueOf(system.today().day());
            conAddrs2[i].Seasonal_End_Month__c = String.valueOf(system.today().addMonths(1).month());
            conAddrs2[i].Seasonal_End_Day__c = '28';
            conAddrs2[i].MailingStreet__c = 'New Seasonal Street' + i;
            conAddrs2[i].MailingCity__c = 'New Seasonal City' + i;
        }

        List<Address__c> allNewAddrs = new List<Address__c>(accAddrs2);
        allNewAddrs.addAll(conAddrs2);

        // Hack!  by setting our trigger handler as run,
        // we can insert the new seasonal addresses but not have them processed.
        // this way we can test the scheduled job!
        ADDR_Addresses_TDTM.turnoff();
        insert allNewAddrs;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();

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
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c
        from Account]);

        for (Account acc : mapAccIdAcc.values()) {
            system.assert(acc.BillingStreet.contains('New Seasonal Street'));
            system.assert(acc.BillingCity.contains('New Seasonal City'));
            system.assertNotEquals(null, acc.Current_Address__c);
        }

        // verify the previous addresses still are Default
        accAddrs = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c
                    from Address__c where ID in :accAddrs];
        system.assertEquals(2, accAddrs.size());
        for (Address__c addr : accAddrs) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            system.assertEquals(!fSeasonal, addr.Default_Address__c);
        }

        // verify Contact address is new!
        map<Id, Contact> mapContactIdContact = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState,
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c
        from Contact]);

        for (Contact con : mapContactIdContact.values()) {
            system.assert(con.MailingStreet.contains('New Seasonal Street'));
            system.assert(con.MailingCity.contains('New Seasonal City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }

        // verify the previous addresses still are Default
        conAddrs = [select Id, Default_Address__c, MailingStreet__c, Parent_Contact__c, Latest_Start_Date__c, Latest_End_Date__c
                    from Address__c where ID in :conAddrs];
        system.assertEquals(2, conAddrs.size());
        for (Address__c addr : conAddrs) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            system.assertEquals(!fSeasonal, addr.Default_Address__c);
        }
    }


    /*********************************************************************************************************
    @description
        schedule a seasonal address update to test address expiration
    verify:
        contact's && hh address matches new seasonal upon insert
        address expires and default is reset
    **********************************************************************************************************/
    @isTest
    public static void scheduleSeasonalAddrExpire() {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c(
            Accounts_Addresses_Enabled__c = UTIL_Describe.getAdminAccRecTypeID() + ';',
            Contacts_Addresses_Enabled__c = true,
            Simple_Address_Change_Treated_as_Update__c = true);
        UTIL_CustomSettingsFacade.getSettingsForTests(hs);

        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getAdminAccRecTypeID());
        List<Address__c> accAddrs = accsAddrs.addrs;

        // this creates a default Address for each Contact
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);
        List<Address__c> conAddrs = contactsAddrs.addrs;

        // create additional Account addresses, with seasonal information to expire tomorrow
        List<Address__c> accAddrs2 = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            accAddrs2[i].Parent_Account__c = accsAddrs.accs[i].Id;
            accAddrs2[i].Default_Address__c = false;
            accAddrs2[i].Seasonal_Start_Month__c = String.valueOf(system.today().addDays(-31).month());
            accAddrs2[i].Seasonal_Start_Day__c = String.valueOf(system.today().addDays(-31).day());
            accAddrs2[i].Seasonal_End_Month__c = String.valueOf(system.today().addDays(1).month());
            accAddrs2[i].Seasonal_End_Day__c = String.valueOf(system.today().addDays(1).day());
            accAddrs2[i].MailingStreet__c = 'New Seasonal Street' + i;
            accAddrs2[i].MailingCity__c = 'New Seasonal City' + i;
        }

        // create additional Contact addresses, with seasonal information to expire tomorrow
        List<Address__c> conAddrs2 = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            conAddrs2[i].Parent_Contact__c = contactsAddrs.contacts[i].Id;
            conAddrs2[i].Default_Address__c = false;
            conAddrs2[i].Seasonal_Start_Month__c = String.valueOf(system.today().addDays(-31).month());
            conAddrs2[i].Seasonal_Start_Day__c = String.valueOf(system.today().addDays(-31).day());
            conAddrs2[i].Seasonal_End_Month__c = String.valueOf(system.today().addDays(1).month());
            conAddrs2[i].Seasonal_End_Day__c = String.valueOf(system.today().addDays(1).day());
            conAddrs2[i].MailingStreet__c = 'New Seasonal Street' + i;
            conAddrs2[i].MailingCity__c = 'New Seasonal City' + i;
        }  

        List<Address__c> allNewAddrs = new List<Address__c>(accAddrs2);
        allNewAddrs.addAll(conAddrs2);

        // We want the processing to run on the new addresses from the trigger to set the addresses as current
        insert allNewAddrs;

        //verify account seasonal address is set
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState,
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c
        from Account]);
        for (Account acc : mapAccIdAcc.values()) {
            system.assert(acc.BillingStreet.contains('New Seasonal Street'));
            system.assert(acc.BillingCity.contains('New Seasonal City'));
            system.assertNotEquals(null, acc.Current_Address__c);
        }

        // verify Contact address is set!
        map<Id, Contact> mapContactIdContact = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState,
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c
        from Contact]);

        for (Contact con : mapContactIdContact.values()) {
            system.assert(con.MailingStreet.contains('New Seasonal Street'));
            system.assert(con.MailingCity.contains('New Seasonal City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }

        // Set End date to today for scheduled job and batch testing
        for (Address__c seasAddr : allNewAddrs ) {
            seasAddr.Seasonal_End_Day__c = String.valueOf(system.today().day()); 
            seasAddr.Seasonal_End_Month__c = String.valueOf(system.today().month());
        }

        // Turn off triggers because we need to update the addresses to test the batch.
        ADDR_Addresses_TDTM.turnOff();
        update allNewAddrs;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();

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

        //verify account default address is set
        mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState,
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c, Current_Address__r.Default_Address__c
        from Account]);
        for (Account acc : mapAccIdAcc.values()) {
            system.assert( acc.Current_Address__r.Default_Address__c == true );
        }

        // verify Contact default address is set!
        mapContactIdContact = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState,
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c, Current_Address__r.Default_Address__c
        from Contact]);
        for (Contact con : mapContactIdContact.values()) {
            system.assert( con.Current_Address__r.Default_Address__c == true );
            system.assertEquals(false, con.is_Address_Override__c);
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
        BillingCity = 'Austin', BillingState = 'Texas', BillingCountry = 'United States');
        insert acc;


        //Address flagged as default should have been created
        Address__c defaultAddress = [select ID, Default_Address__c from Address__c where Parent_Account__c = : acc.ID];
        System.assertEquals(true, defaultAddress.Default_Address__c);

        //Create seasonal Address with start and end year that include the current date
        Address__c seasonalAddress = new Address__c(Parent_Account__c = acc.ID, MailingStreet__c = '123 Seasonal', MailingCity__c = 'Seattle',
            MailingState__c = 'Washington', MailingCountry__c = 'United States', Seasonal_Start_Day__c = String.valueOf(system.today().addDays(-1).day()),
            Seasonal_Start_Month__c = String.valueOf(system.today().addMonths(-1).month()), Seasonal_Start_Year__c = system.today().addYears(-1).year(),
            Seasonal_End_Day__c = String.valueOf(system.today().addDays(1).day()), Seasonal_End_Month__c = String.valueOf(system.today().addMonths(1).month()),
            Seasonal_End_Year__c = system.today().addYears(1).year());

        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert seasonalAddress;
        Test.stopTest();

        //Seasonal Address should have been copied to the Account
        acc = [select BillingStreet, BillingCity, BillingState from Account where ID = :acc.ID];
        System.assertEquals('123 Seasonal', acc.BillingStreet);
        System.assertEquals('Seattle', acc.BillingCity);
        System.assertEquals('Washington', acc.BillingState);
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
        Address__c seasonalAddress = new Address__c(
            Parent_Account__c = acc.ID,
            MailingStreet__c = '123 Seasonal',
            MailingCity__c = 'Austin',
            MailingState__c = 'Texas',
            MailingCountry__c = 'United States',
            Seasonal_Start_Day__c = '1',
            Seasonal_Start_Month__c = '1',
            Seasonal_Start_Year__c = system.today().year(),
            Seasonal_End_Day__c = '31',
            Seasonal_End_Month__c = '5',
            Seasonal_End_Year__c = system.today().year()
            );

        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert seasonalAddress;

        //No NPE should have been thrown. Github #197.

        //Create second seasonal Address with start and end year.
        Address__c seasonalAddress2 = new Address__c(
            Parent_Account__c = acc.ID,
            MailingStreet__c = '123 Seasonal',
            MailingCity__c = 'Seattle',
            MailingState__c = 'WA',
            Seasonal_Start_Day__c = '1',
            Seasonal_Start_Month__c = '6',
            Seasonal_Start_Year__c = system.today().year(),
            Seasonal_End_Day__c = '31',
            Seasonal_End_Month__c = '7', 
            Seasonal_End_Year__c = system.today().year()
            );

        ADDR_Contact_TEST.turnOnAllAddrTriggers();
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
        BillingCity = 'Austin', BillingState = 'Texas', BillingCountry = 'United States');
        insert acc;

        //Address flagged as default should have been created
        Address__c defaultAddress = [select ID, Default_Address__c from Address__c where Parent_Account__c = : acc.ID];
        System.assertEquals(true, defaultAddress.Default_Address__c);

        //Create seasonal Address with start and end year that include the current date
        Address__c seasonalAddress = new Address__c(Parent_Account__c = acc.ID, MailingStreet__c = '123 Seasonal', MailingCity__c = 'Seattle',
            MailingState__c = 'Washington', MailingCountry__c = 'United States', Seasonal_Start_Day__c = String.valueOf(system.today().addDays(-1).day()),
            Seasonal_Start_Month__c = String.valueOf(system.today().addMonths(-1).month()), Seasonal_Start_Year__c = system.today().addYears(-1).year(),
            Seasonal_End_Day__c = String.valueOf(system.today().addDays(1).day()), Seasonal_End_Month__c = String.valueOf(system.today().addMonths(1).month()),
            Seasonal_End_Year__c = system.today().addYears(1).year());

        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert seasonalAddress;

        //Modify seasonal Address info
        seasonalAddress.MailingStreet__c = 'New Seasonal Address';
        seasonalAddress.MailingCity__c = 'Portland';
        seasonalAddress.MailingState__c = 'Oregon';
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update seasonalAddress;
        Test.stopTest();

        //Changes should have been copied to Account
        acc = [select BillingStreet, BillingCity, BillingState from Account where ID = :acc.ID];
        System.assertEquals('New Seasonal Address', acc.BillingStreet);
        System.assertEquals('Portland', acc.BillingCity);
        System.assertEquals('Oregon', acc.BillingState);
    }

    @isTest
    public static void testSeasonalStartEndYearUpdateDates() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(
            Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID(),
            Accounts_Addresses_Enabled__c = UTIL_Describe.getAdminAccRecTypeID() + ';',
            Simple_Address_Change_Treated_as_Update__c = true));

        //Create Contact with Address info
        Account acc = new Account(Name = 'Testerson', RecordTypeID = UTIL_Describe.getAdminAccRecTypeID(), BillingStreet = '123 Default',
        BillingCity = 'Austin', BillingState = 'Texas', BillingCountry = 'United States');
        insert acc;

        //Address flagged as default should have been created
        Address__c defaultAddress = [select ID, Default_Address__c from Address__c where Parent_Account__c = : acc.ID];
        System.assertEquals(true, defaultAddress.Default_Address__c);

        //Create seasonal Address with start and end year that include the current date
        Address__c seasonalAddress = new Address__c(Parent_Account__c = acc.ID, MailingStreet__c = '123 Seasonal', MailingCity__c = 'Seattle',
            MailingState__c = 'Washington', MailingCountry__c = 'United States', Seasonal_Start_Day__c = String.valueOf(system.today().addDays(-1).day()),
            Seasonal_Start_Month__c = String.valueOf(system.today().addMonths(-1).month()), Seasonal_Start_Year__c = system.today().addYears(-1).year(),
            Seasonal_End_Day__c = String.valueOf(system.today().addDays(1).day()), Seasonal_End_Month__c = String.valueOf(system.today().addMonths(1).month()),
            Seasonal_End_Year__c = system.today().addYears(1).year());

        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert seasonalAddress;

        //Modify seasonal Address dates so it doesn't include today
        seasonalAddress.Seasonal_Start_Year__c = system.today().addYears(1).year();
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update seasonalAddress;
        Test.stopTest();

        //Account should have reverted to default address
        acc = [select BillingStreet, BillingCity, BillingState from Account where ID = :acc.ID];
        System.assertEquals('123 Default', acc.BillingStreet);
        System.assertEquals('Austin', acc.BillingCity);
        System.assertEquals('Texas', acc.BillingState);
    }

    @isTest
    public static void testSeasonalStartEndYearDelete() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(
            Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID(),
            Accounts_Addresses_Enabled__c = UTIL_Describe.getAdminAccRecTypeID() + ';',
            Simple_Address_Change_Treated_as_Update__c = true));

        //Create Contact with Address info
        Account acc = new Account(Name = 'Testerson', RecordTypeID = UTIL_Describe.getAdminAccRecTypeID(), BillingStreet = '123 Default',
        BillingCity = 'Austin', BillingState = 'Texas', BillingCountry = 'United States');
        insert acc;

        //Address flagged as default should have been created
        Address__c defaultAddress = [select ID, Default_Address__c from Address__c where Parent_Account__c = : acc.ID];
        System.assertEquals(true, defaultAddress.Default_Address__c);

        //Create seasonal Address with start and end year that include the current date
        Address__c seasonalAddress = new Address__c(Parent_Account__c = acc.ID, MailingStreet__c = '123 Seasonal', MailingCity__c = 'Seattle',
            MailingState__c = 'Washington', MailingCountry__c = 'United States', Seasonal_Start_Day__c = String.valueOf(system.today().addDays(-1).day()),
            Seasonal_Start_Month__c = String.valueOf(system.today().addMonths(-1).month()), Seasonal_Start_Year__c = system.today().addYears(-1).year(),
            Seasonal_End_Day__c = String.valueOf(system.today().addDays(1).day()), Seasonal_End_Month__c = String.valueOf(system.today().addMonths(1).month()),
            Seasonal_End_Year__c = system.today().addYears(1).year());

        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert seasonalAddress;

        //Delete seasonal Address
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        delete seasonalAddress;
        Test.stopTest();

        //Account should have reverted to default address
        acc = [select BillingStreet, BillingCity, BillingState from Account where ID = :acc.ID];
        System.assertEquals('123 Default', acc.BillingStreet);
        System.assertEquals('Austin', acc.BillingCity);
        System.assertEquals('Texas', acc.BillingState);
    }

    @isTest
    public static void newSeasonalAddrForContact() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(
            Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID(),
            Contacts_Addresses_Enabled__c = true,
            Simple_Address_Change_Treated_as_Update__c = true));

        Contact contact = new Contact(LastName = 'newSeasonalAddr', MailingStreet = '123 Main St', MailingCity = 'Austin', MailingState = 'Texas', MailingCountry = 'United States');
        insert Contact;

        //Address record should have been created as child of Contact
        List<Address__c> addrs = [select Parent_Contact__c, Parent_Account__c, MailingStreet__c, MailingCity__c, MailingState__c from Address__c];
        System.assertEquals(1, addrs.size());
        System.assertEquals(contact.ID, addrs[0].Parent_Contact__c);
        System.assertEquals(null, addrs[0].Parent_Account__c);
        System.assertEquals('123 Main St', addrs[0].MailingStreet__c);
        System.assertEquals('Austin', addrs[0].MailingCity__c);
        System.assertEquals('Texas', addrs[0].MailingState__c);

        //Create new seasonal address record on Contact that includes today
        Address__c seasonalAddr = new Address__c();
        seasonalAddr.Parent_Contact__c = contact.Id;
        seasonalAddr.MailingStreet__c = '50 Fremont St';
        seasonalAddr.MailingCity__c = 'SF';
        seasonalAddr.MailingState__c = 'California';
        seasonalAddr.MailingCountry__c = 'United States';
        seasonalAddr.Seasonal_Start_Day__c = String.valueOf(System.today().day());
        seasonalAddr.Seasonal_Start_Month__c = String.valueOf(System.today().month());
        seasonalAddr.Seasonal_Start_Year__c = System.today().year()-1;
        seasonalAddr.Seasonal_End_Day__c = String.valueOf(System.today().day());
        seasonalAddr.Seasonal_End_Month__c = String.valueOf(System.today().month());
        seasonalAddr.Seasonal_End_Year__c = System.today().year()+1;

        ADDR_Addresses_TDTM.turnOn();
        Test.startTest();
        insert seasonalAddr;
        Test.stopTest();

        contact = [select MailingStreet, MailingCity, MailingState, Current_Address__c from Contact where ID = :contact.ID];
        System.assertEquals('50 Fremont St', contact.MailingStreet);
        System.assertEquals('SF', contact.MailingCity);
        System.assertEquals('California', contact.MailingState);
        System.assertEquals(seasonalAddr.ID, contact.Current_Address__c);
    }

    @isTest
    public static void secondSeasonalAddrForContact() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(
            Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID(),
            Contacts_Addresses_Enabled__c = true,
            Simple_Address_Change_Treated_as_Update__c = true));

        Contact contact = new Contact(LastName = 'newSeasonalAddr');
        insert Contact;

        //Create new seasonal address record on Contact that includes today
        Address__c seasonalAddr = new Address__c();
        seasonalAddr.Parent_Contact__c = contact.Id;
        seasonalAddr.MailingStreet__c = '123 Main St';
        seasonalAddr.MailingCity__c = 'Chicago';
        seasonalAddr.MailingState__c = 'IL';
        seasonalAddr.Seasonal_Start_Day__c = String.valueOf(System.today().day());
        seasonalAddr.Seasonal_Start_Month__c = String.valueOf(System.today().month());
        seasonalAddr.Seasonal_Start_Year__c = System.today().year()-1;
        seasonalAddr.Seasonal_End_Day__c = String.valueOf(System.today().day());
        seasonalAddr.Seasonal_End_Month__c = String.valueOf(System.today().month());
        seasonalAddr.Seasonal_End_Year__c = System.today().year()+1;

        insert seasonalAddr;

        //Address record should have been created as child of Contact
        List<Address__c> addrs = [select Parent_Contact__c, Parent_Account__c, MailingStreet__c, MailingCity__c, MailingState__c from Address__c];
        System.assertEquals(1, addrs.size());
        System.assertEquals(contact.ID, addrs[0].Parent_Contact__c);
        System.assertEquals(null, addrs[0].Parent_Account__c);
        System.assertEquals('123 Main St', addrs[0].MailingStreet__c);
        System.assertEquals('Chicago', addrs[0].MailingCity__c);
        System.assertEquals('IL', addrs[0].MailingState__c);

        //Create new seasonal address record on Contact that overlaps the previous one
        Address__c seasonalAddr2 = new Address__c();
        seasonalAddr2.Parent_Contact__c = contact.Id;
        seasonalAddr2.MailingStreet__c = '50 Fremont St';
        seasonalAddr2.MailingCity__c = 'SF';
        seasonalAddr2.MailingState__c = 'CA';
        seasonalAddr2.Seasonal_Start_Day__c = String.valueOf(System.today().day());
        seasonalAddr2.Seasonal_Start_Month__c = String.valueOf(System.today().month());
        seasonalAddr2.Seasonal_Start_Year__c = System.today().year()-2;
        seasonalAddr2.Seasonal_End_Day__c = String.valueOf(System.today().day());
        seasonalAddr2.Seasonal_End_Month__c = String.valueOf(System.today().month());
        seasonalAddr2.Seasonal_End_Year__c = System.today().year()+2;

        ADDR_Addresses_TDTM.turnOn();

        Test.startTest();
        try {
            insert seasonalAddr2;
        } catch(System.DmlException e) {
            System.assertEquals(true, e.getMessage().contains(System.Label.addrSeasonalOverlap));
            return;
        }
        //we should never get here
        System.assertEquals(false, true);
    }
}