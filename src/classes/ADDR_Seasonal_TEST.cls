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
    @description Insert new current Seasonal Address record to an existing Account with existing default Address
    * record.
    * Verify:
    * - New current Seasonal Address record is created.
    * - Account's billing fields are updated to match the mailing fields from the newly created Seasonal Address record.
    * - Previous existing default Address is still marked as default. 
    **********************************************************************************************************/
    @isTest
    private static void insertNewCurrentSeasonalAddressOnExistingAccountWithDefaultAddress() {
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> newAddrList = accsAddrs.addrs;

        newAddrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            newAddrList[i].Parent_Account__c = accsAddrs.accs[i].Id;
            newAddrList[i].Default_Address__c = False;
            newAddrList[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(-1).month());
            newAddrList[i].Seasonal_Start_Day__c = '1';
            newAddrList[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(1).month());
            newAddrList[i].Seasonal_End_Day__c = '28';
            newAddrList[i].MailingStreet__c = 'New Seasonal Street' + i;
            newAddrList[i].MailingCity__c = 'New Seasonal City' + i;
            newAddrList[i].MailingCounty__c = 'New Seasonal County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert newAddrList;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();

        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet,
                                                                    BillingCity, Billing_County__c, Current_Address__c
                                                                    FROM Account]);

        for (Account acc : accountsById.values()) {
            System.assert(acc.BillingStreet.contains('New Seasonal Street'));
            System.assert(acc.BillingCity.contains('New Seasonal City'));
            System.assert(acc.Billing_County__c.contains('New Seasonal County'));
            System.assertNotEquals(Null, acc.Current_Address__c);
        }

        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                        Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c
                                        FROM Address__c];
        System.assertEquals(4, addrList.size());
        for (Address__c addr : addrList) {
            if (addr.MailingStreet__c.contains('New Seasonal Street')) {
                System.assertEquals(False, addr.Default_Address__c); 
            } else {
                System.assertEquals(True, addr.Default_Address__c);
            }
        }
    }

    /*********************************************************************************************************
    @description Insert new current Seasonal Address record with Year to an existing Account with existing default Address
    * record.
    * Verify:
    * - New current Seasonal Address record is created.
    * - Account's billing fields are updated to match the mailing fields from the newly created Seasonal Address record.
    * - Previous existing default Address is still marked as default. 
    **********************************************************************************************************/
    @isTest
    private static void insertNewCurrentSeasonalAddressWithYearOnExistingAccountWithDefaultAddress() {
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> newAddrList = accsAddrs.addrs;

        newAddrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            newAddrList[i].Parent_Account__c = accsAddrs.accs[i].Id;
            newAddrList[i].Default_Address__c = False;
            newAddrList[i].Seasonal_Start_Year__c = System.today().addYears(-1).year();
            newAddrList[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(-1).month());
            newAddrList[i].Seasonal_Start_Day__c = '1';
            newAddrList[i].Seasonal_End_Year__c = System.today().addYears(1).year();
            newAddrList[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(1).month());
            newAddrList[i].Seasonal_End_Day__c = '28';
            newAddrList[i].MailingStreet__c = 'New Seasonal Street' + i;
            newAddrList[i].MailingCity__c = 'New Seasonal City' + i;
            newAddrList[i].MailingCounty__c = 'New Seasonal County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert newAddrList;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();

        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                    BillingCity, Billing_County__c, Current_Address__c
                                                                    FROM Account]);
        for (Account acc : accountsById.values()) {
            System.assert(acc.BillingStreet.contains('New Seasonal Street'));
            System.assert(acc.BillingCity.contains('New Seasonal City'));
            System.assert(acc.Billing_County__c.contains('New Seasonal County'));
            System.assertNotEquals(Null, acc.Current_Address__c);
        }

        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c, Parent_Account__c
                                        FROM Address__c];
        System.assertEquals(4, addrList.size());
        for (Address__c addr : addrList) {
            if (addr.MailingStreet__c.contains('New Seasonal Street')) {
                System.assertEquals(False, addr.Default_Address__c); 
            } else {
                System.assertEquals(True, addr.Default_Address__c);
            }
        }
    }

    /*********************************************************************************************************
    @description Insert new non current Seasonal Address record to an existing Account with existing default Address
    * record.
    * Verify:
    * - New non current Season Address record is created.
    * - Account's billing fields are not updated.
    * - Previous existing default Address is still marked as default. 
    **********************************************************************************************************/
    @isTest
    private static void insertNewNonCurrentSeasonalAddressOnExistingAccountWithDefaultAddress() {
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> newAddrList = accsAddrs.addrs;

        newAddrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            newAddrList[i].Parent_Account__c = accsAddrs.accs[i].Id;
            newAddrList[i].Default_Address__c = false;
            newAddrList[i].Seasonal_Start_Month__c = String.valueOf(system.today().addMonths(1).month());
            newAddrList[i].Seasonal_Start_Day__c = '1';
            newAddrList[i].Seasonal_End_Month__c = String.valueOf(system.today().addMonths(2).month());
            newAddrList[i].Seasonal_End_Day__c = '28';
            newAddrList[i].MailingStreet__c = 'New Seasonal Street' + i;
            newAddrList[i].MailingCity__c = 'New Seasonal City' + i;
            newAddrList[i].MailingCounty__c = 'New Seasonal County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert newAddrList;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();

        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, Current_Address__c
                                                                FROM Account]);

        for (Account acc : accountsById.values()) {
            System.assert(!acc.BillingStreet.contains('New Seasonal Street'));
            System.assert(!acc.BillingCity.contains('New Seasonal City'));
            System.assert(!acc.Billing_County__c.contains('New Seasonal County'));
            System.assertNotEquals(Null, acc.Current_Address__c);
        }

        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c,
                                        Parent_Account__c
                                        FROM Address__c];
        System.assertEquals(4, addrList.size());
        for (Address__c addr : addrList) {
            if (addr.MailingStreet__c.contains('New Seasonal Street')) {
                System.assertEquals(False, addr.Default_Address__c);
            } else {
                System.assertEquals(True, addr.Default_Address__c);
            }
        }
    }

    /*********************************************************************************************************
    @description Update existing non current Seasonal Address record to current Seasonal Address record.  
    * Verify:
    * - Account's billing fields are updated to match the mailing fields for the recently updated current
    * Seasonal Address records. 
    * - No new Address record is created. 
    * - Previous existing default Address record is still marked as default. 
    **********************************************************************************************************/
    @isTest
    private static void updateNonCurrentToCurrentSeasonalAddress() {
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> newAddrList = accsAddrs.addrs;
        
        newAddrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            newAddrList[i].Parent_Account__c = accsAddrs.accs[i].Id;
            newAddrList[i].Default_Address__c = False;
            newAddrList[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(1).month());
            newAddrList[i].Seasonal_Start_Day__c = '1';
            newAddrList[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(2).month());
            newAddrList[i].Seasonal_End_Day__c = '28';
            newAddrList[i].MailingStreet__c = 'New Seasonal Street' + i;
            newAddrList[i].MailingCity__c = 'New Seasonal City' + i;
            newAddrList[i].MailingCounty__c = 'New Seasonal County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert newAddrList;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();

        for (Integer i = 0; i < 2; i++) {
            newAddrList[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(-1).month());
        }
        Test.startTest();
        update newAddrList;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();

        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, Current_Address__c
                                                                FROM Account]);

        for (Account acc : accountsById.values()) {
            System.assert(acc.BillingStreet.contains('New Seasonal Street'));
            System.assert(acc.BillingCity.contains('New Seasonal City'));
            System.assert(acc.Billing_County__c.contains('New Seasonal County'));
            System.assertNotEquals(Null, acc.Current_Address__c);
        }

        //Verify the previous default Address record is still marked as default
        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c, Parent_Account__c
                                        FROM Address__c];
        System.assertEquals(4, addrList.size());
        for (Address__c addr : addrList) {
            if (addr.MailingStreet__c.contains('New Seasonal Street')) {
                System.assertEquals(False, addr.Default_Address__c);
            } else {
                System.assertEquals(True, addr.Default_Address__c);
            }
        }
    }

    /*********************************************************************************************************
    @description Insert multiple where one of the Seasonal Address record is non current,
    * and the rest are current Seasonal Address records that overlaps the start/end month. 
    * Verify:
    * - Overlap detected and Season Address records aren't inserted. 
    **********************************************************************************************************/
    @isTest
    private static void insertSeasonalAddressWithOverlapLogic() {
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> newAddrList = accsAddrs.addrs;

        newAddrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(4);
        for (Integer i = 0; i < 4; i++) {
            Integer iacc = i < 2 ? i : i-2;
            //This populates only the 1st Address record with non current start month 
            if (math.mod(i, 2) == 0) {
                newAddrList[i].Parent_Account__c = accsAddrs.accs[iacc].Id;
                newAddrList[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(1).month());
                newAddrList[i].Seasonal_Start_Day__c = '1';
                newAddrList[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(3).month());
                newAddrList[i].Seasonal_End_Day__c = '28';
            } else {
                //This populates the rest of Seasonal Address records with current start month
                newAddrList[i].Parent_Account__c = accsAddrs.accs[iacc-1].Id;
                newAddrList[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(-1).month());
                newAddrList[i].Seasonal_Start_Day__c = '1';
                newAddrList[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(2).month());
                newAddrList[i].Seasonal_End_Day__c = '28';
            }
            newAddrList[i].Default_Address__c = False;
            newAddrList[i].MailingStreet__c = 'New Seasonal Street' + i;
            newAddrList[i].MailingCity__c = 'New Seasonal City' + i;
            newAddrList[i].MailingCounty__c = 'New Seasonal County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        try {
            insert newAddrList;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(Label.addrSeasonalOverlap));
            return;
        }
        System.assert(False); 
    }

    /*********************************************************************************************************
    @description Update existing Seasonal Address records's start/end month that overlaps with each other. 
    * Verify:
    * - Overlap is detected. 
    **********************************************************************************************************/
    @isTest
    private static void updateSeasonalAddressRecordsWithOverlapLogic() {
        Address__c a1 = new Address__c();
        Address__c a2 = new Address__c();

        //Test both increasing ranges, no overlap
        a1.Seasonal_Start_Month__c = '1';
        a1.Seasonal_Start_Day__c = '29';
        a1.Seasonal_End_Month__c = '3';
        a1.Seasonal_End_Day__c = '28';
        a2.Seasonal_Start_Month__c = '4';
        a2.Seasonal_Start_Day__c = '1';
        a2.Seasonal_End_Month__c = '6';
        a2.Seasonal_End_Day__c = '28';
        System.assertEquals(False, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        System.assertEquals(False, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));

        //Test both increasing ranges, with overlap
        a2.Seasonal_Start_Month__c = '2';
        a2.Seasonal_End_Month__c = '6';
        System.assertEquals(True, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        System.assertEquals(True, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));

        //Test one increasing range, one decreasing range, no overlap
        a1.Seasonal_Start_Month__c = '3';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '5';
        a1.Seasonal_End_Day__c = '28';
        a2.Seasonal_Start_Month__c = '11';
        a2.Seasonal_Start_Day__c = '1';
        a2.Seasonal_End_Month__c = '2';
        a2.Seasonal_End_Day__c = '28';
        System.assertEquals(False, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        System.assertEquals(False, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));

        //Test one increasing range, one decreasing range, with overlap
        a2.Seasonal_Start_Month__c = '11';
        a2.Seasonal_Start_Day__c = '1';
        a2.Seasonal_End_Month__c = '4';
        a2.Seasonal_End_Day__c = '28';
        System.assertEquals(True, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        System.assertEquals(True, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));

        //Test both decreasing ranges, always overlap
        a1.Seasonal_Start_Month__c = '9';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '2';
        a1.Seasonal_End_Day__c = '28';
        a2.Seasonal_Start_Month__c = '12';
        a2.Seasonal_Start_Day__c = '1';
        a2.Seasonal_End_Month__c = '3';
        a2.Seasonal_End_Day__c = '28';
        System.assertEquals(True, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        System.assertEquals(True, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));

        //Test both increasing ranges in the same month, no overlap
        a1.Seasonal_Start_Month__c = '2';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '2';
        a1.Seasonal_End_Day__c = '10';
        a2.Seasonal_Start_Month__c = '2';
        a2.Seasonal_Start_Day__c = '11';
        a2.Seasonal_End_Month__c = '2';
        a2.Seasonal_End_Day__c = '28';
        System.assertEquals(False, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        System.assertEquals(False, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));

        //Test both increasing ranges in the same month, with overlap
        a1.Seasonal_Start_Month__c = '2';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '2';
        a1.Seasonal_End_Day__c = '10';
        a2.Seasonal_Start_Month__c = '2';
        a2.Seasonal_Start_Day__c = '10';
        a2.Seasonal_End_Month__c = '2';
        a2.Seasonal_End_Day__c = '28';
        System.assertEquals(True, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        System.assertEquals(True, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));

        //Test one increasing range, one decreasing range in the same month, no overlap
        a1.Seasonal_Start_Month__c = '2';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '2';
        a1.Seasonal_End_Day__c = '10';
        a2.Seasonal_Start_Month__c = '2';
        a2.Seasonal_Start_Day__c = '11';
        a2.Seasonal_End_Month__c = '1';
        a2.Seasonal_End_Day__c = '28';
        System.assertEquals(False, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        System.assertEquals(False, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));
    }

    /*********************************************************************************************************
    @description Insert multiple Seasonal Address with current month that overlaps with each other.
    * Verify:
    * - Overlap is detected. 
    **********************************************************************************************************/
    @isTest
    private static void insertCurrentMonthSeasonalAddressWithOverlapLogic() {
        Address__c a1 = new Address__c();
        Address__c a2 = new Address__c();

        //Test one increasing range, one decreasing range in the same month, with overlap
        a1.Seasonal_Start_Month__c = String.valueOf(System.today().month());
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = String.valueOf(System.today().month());
        a1.Seasonal_End_Day__c = '10';  //1st of current month to 10th of current month

        a2.Seasonal_Start_Month__c = String.valueOf(System.today().month());
        a2.Seasonal_Start_Day__c = '11';
        a2.Seasonal_End_Month__c = String.valueOf(System.today().month());
        a2.Seasonal_End_Day__c = '1';   //11th of current month to 1st of current month (overlaps year)
        System.assertEquals(True, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        System.assertEquals(True, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));
    }

    /*********************************************************************************************************
    @description Insert multiple Seasonal Address with next month that overlaps with each other. 
    * Verify:
    * - Overlap is detected. 
    **********************************************************************************************************/
    @isTest
    private static void insertNextMonthSeasonalAddressWithOverlapLogic() {
        Address__c a1 = new Address__c();
        Address__c a2 = new Address__c();

        //Test one increasing range, one decreasing range in the same month, with overlap
        a1.Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(1).month());
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = String.valueOf(System.today().addMonths(1).month());
        a1.Seasonal_End_Day__c = '10';  //1st of next month to 10th of next month

        a2.Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(1).month());
        a2.Seasonal_Start_Day__c = '11';
        a2.Seasonal_End_Month__c = String.valueOf(System.today().addMonths(1).month());
        a2.Seasonal_End_Day__c = '1';   //11th of next month to 1st of next month(overlaps year)
        System.assertEquals(True, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        System.assertEquals(True, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));
    }

    /*********************************************************************************************************
    @description Insert multiple Seasonal Address with previous month that overlaps with each other. 
    * Verify:
    * - Overlap is detected. 
    **********************************************************************************************************/
    @isTest
    private static void insertPreviousMonthSeasonalAddressWithOverlapLogic() {
        Address__c a1 = new Address__c();
        Address__c a2 = new Address__c();

        //Test one increasing range, one decreasing range in the same month, with overlap
        a1.Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(-1).month());
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = String.valueOf(System.today().addMonths(-1).month());
        a1.Seasonal_End_Day__c = '10';  //1st of previous month to 10th of previous month

        a2.Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(-1).month());
        a2.Seasonal_Start_Day__c = '11';
        a2.Seasonal_End_Month__c = String.valueOf(System.today().addMonths(-1).month());
        a2.Seasonal_End_Day__c = '1';   //11th of previous month to 1st of previous month(overlaps year)
        System.assertEquals(True, ADDR_Seasonal_UTIL.isSeasonalOverlap(a1, a2));
        System.assertEquals(True, ADDR_Seasonal_UTIL.isSeasonalOverlap(a2, a1));
    }

    /*********************************************************************************************************
    @description Insert non current Seasonal Address record that overlaps with an existing non current Seasonal
    * Address record. 
    * Verify:
    * - Overlap is detected and Address record is not inserted. 
    **********************************************************************************************************/
    @isTest
    private static void insertNonCurrentSeasonalAddressOverlapExistingNonCurrentSeasonAddress() {
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> newAddrList = accsAddrs.addrs;

        //Create additional Seasonal Address records that's not current
        newAddrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        Date todaysDate = Date.newInstance(System.today().year(), 6, 1);

        for (Integer i = 0; i < 2; i++) {
            newAddrList[i].Parent_Account__c = accsAddrs.accs[i].Id;
            newAddrList[i].Seasonal_Start_Month__c = String.valueOf(todaysDate.addMonths(1).month());
            newAddrList[i].Seasonal_Start_Day__c = '1';
            newAddrList[i].Seasonal_End_Month__c = String.valueOf(todaysDate.addMonths(3).month());
            newAddrList[i].Seasonal_End_Day__c = '28';
            newAddrList[i].Default_Address__c = False;
            newAddrList[i].MailingStreet__c = 'New Seasonal Street' + i;
            newAddrList[i].MailingCity__c = 'New Seasonal City' + i;
            newAddrList[i].MailingCounty__c = 'New Seasonal County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert newAddrList;

        //Create additional non current Seasonal Address records that overlap existing non current Seasonal Address records 
        newAddrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            newAddrList[i].Parent_Account__c = accsAddrs.accs[i].Id;
            newAddrList[i].Seasonal_Start_Month__c = String.valueOf(todaysDate.addMonths(2).month());
            newAddrList[i].Seasonal_Start_Day__c = '1';
            newAddrList[i].Seasonal_End_Month__c = String.valueOf(todaysDate.addMonths(4).month());
            newAddrList[i].Seasonal_End_Day__c = '28';
            newAddrList[i].Default_Address__c = False;
            newAddrList[i].MailingStreet__c = 'New Seasonal Street' + i;
            newAddrList[i].MailingCity__c = 'New Seasonal City' + i;
            newAddrList[i].MailingCounty__c = 'New Seasonal County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        try {
            insert newAddrList;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(Label.addrSeasonalOverlap));
            return;
        }
        System.assert(False);
    }

    /*********************************************************************************************************
    @description Insert non current partial Seasonal Address records to an Account with existing Address records. 
    * Verify:
    * - Partial Seasonal record is detected and it is not created. 
    **********************************************************************************************************/
    @isTest
    private static void insertPartialSeasonalAddress() {
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> addrList = accsAddrs.addrs;

        //Create additional non current Seasonal Address records
        addrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrList[i].Parent_Account__c = accsAddrs.accs[i].Id;
            addrList[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(1).month());
            addrList[i].Seasonal_Start_Day__c = '1';
            addrList[i].Default_Address__c = False;
            addrList[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrList[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        try {
            insert addrList;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(Label.addrSeasonalPartial));
            return;
        }
        System.assert(False);
    }

    /*********************************************************************************************************
    @description Insert non current partial Seasonal Address record with year to an Account with existing
    * Address record.
    * Verify:
    * - Partial Seasonal record is detected and it is not created. 
    **********************************************************************************************************/
    @isTest
    private static void insertPartialSeasonalYearAddress() {
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> addrList = accsAddrs.addrs;

        //Create additional not current Seasonal Address record 
        addrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrList[i].Parent_Account__c = accsAddrs.accs[i].Id;
            addrList[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(1).month());
            addrList[i].Seasonal_Start_Day__c = '1';
            if (math.mod(i, 2) == 0) {
                addrList[i].Seasonal_Start_Year__c = Decimal.valueOf(System.today().year());
            } else {
                addrList[i].Seasonal_End_Year__c = Decimal.valueOf(System.today().year());
            }
            addrList[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(2).month());
            addrList[i].Seasonal_End_Day__c = '20';
            addrList[i].Default_Address__c = False;
            addrList[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrList[i].MailingCity__c = 'New Seasonal City' + i;
            addrList[i].MailingCounty__c = 'New Seasonal County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        try {
            insert addrList;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(Label.addrSeasonalPartialYear));
            return;
        }
        System.assert(False);
    }

    /*********************************************************************************************************
    @description Create new non current Seasonal Address records to existing Accounts and Contacts with existing
    * default Address records. Schedule and calls ADDR_Seasonal_SCHED and ADDR_Seasonal_BATCH classes. 
    * Verify:
    * - Contact's mailing fields are updated to match the mailing fields from the new Seasonal Address record. 
    * - Account's billing fields are updated to match the mailing fields from the new Seasonal Address record.
    * - Previous default Address records are still marked as default. 
    **********************************************************************************************************/
    @isTest
    private static void scheduleNewNonCurrentSeasonalAddress() {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c(Accounts_Addresses_Enabled__c = UTIL_Describe.getCustomAdminAccRecTypeID() + ';',
                                                                Contacts_Addresses_Enabled__c = True,
                                                                Simple_Address_Change_Treated_as_Update__c = True);
                                                                UTIL_CustomSettings_API.getSettingsForTests(hs);

        UTIL_UnitTestData_TEST.AccsWithAddrs accsWithAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> accAddrList = accsWithAddrs.addrs;

        //Creates a default Address records for each Contact
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactWithAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);
        List<Address__c> conAddrList = contactWithAddrs.addrs;

        //Create additional non default Address records for each Account, with non current seasonal information
        List<Address__c> accNewAddrsList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            accNewAddrsList[i].Parent_Account__c = accsWithAddrs.accs[i].Id;
            accNewAddrsList[i].Default_Address__c = False;
            accNewAddrsList[i].Seasonal_Start_Month__c = String.valueOf(System.today().month());
            accNewAddrsList[i].Seasonal_Start_Day__c = String.valueOf(System.today().day());
            accNewAddrsList[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(1).month());
            accNewAddrsList[i].Seasonal_End_Day__c = '28';
            accNewAddrsList[i].MailingStreet__c = 'New Seasonal Street' + i;
            accNewAddrsList[i].MailingCity__c = 'New Seasonal City' + i;
            accNewAddrsList[i].MailingCounty__c = 'New Seasonal County' + i;
        }

        //Create additional non default Address records for each Contact, with non current seasonal information
        List<Address__c> conNewAddrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            conNewAddrList[i].Parent_Contact__c = contactWithAddrs.contacts[i].Id;
            conNewAddrList[i].Default_Address__c = False;
            conNewAddrList[i].Seasonal_Start_Month__c = String.valueOf(System.today().month());
            conNewAddrList[i].Seasonal_Start_Day__c = String.valueOf(System.today().day());
            conNewAddrList[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(1).month());
            conNewAddrList[i].Seasonal_End_Day__c = '28';
            conNewAddrList[i].MailingStreet__c = 'New Seasonal Street' + i;
            conNewAddrList[i].MailingCity__c = 'New Seasonal City' + i;
            conNewAddrList[i].MailingCounty__c = 'New Seasonal County' + i;
        }
        
        //Contains the list of new Seasonal Address for Accounts and Contacts to create 
        List<Address__c> allNewAddrList = new List<Address__c>(accNewAddrsList);
        allNewAddrList.addAll(conNewAddrList);

        //Hack! By setting our trigger handler as run,
        //we can insert the new seasonal addresses but not have them processed. 
        //This way we can test the scheduled job!
        ADDR_Addresses_TDTM.turnoff();
        insert allNewAddrList;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();

        //Schedule the job just for test coverage purposes. But we still have to manually run the
        //batch, as batch jobs run from a scheduled job don't actually run after stopTest, as described
        //at https://salesforce.stackexchange.com/questions/36806/does-test-stoptest-ensure-a-system-schedule-database-batchable-completes-in-a
        STG_InstallScript.scheduleJobIfNotScheduled('Seasonal Addresses Update', '0 15 0 * * ?', 'ADDR_Seasonal_SCHED');
        //Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name = 'Seasonal Addresses Update'];
        //Verify the expressions are the same
        System.assertEquals('0 15 0 * * ?', ct.CronExpression);
        //Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        //Verify the next time the job will run
        System.assert(String.valueOf(ct.NextFireTime).contains('00:15:00'));

        //Run the scheduled batch directly
        ADDR_Seasonal_BATCH batch = new ADDR_Seasonal_BATCH();
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, Current_Address__c
                                                                FROM Account]);
        for (Account acc : accountsById.values()) {
            System.assert(acc.BillingStreet.contains('New Seasonal Street'));
            System.assert(acc.BillingCity.contains('New Seasonal City'));
            System.assert(acc.Billing_County__c.contains('New Seasonal County'));
            System.assertNotEquals(Null, acc.Current_Address__c);
        }

        //Verify the previous default Address records are still marked as default
        accAddrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                            Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c
                            FROM Address__c 
                            WHERE Id in :accAddrList];
        System.assertEquals(2, accAddrList.size());
        for (Address__c addr : accAddrList) {
            if (addr.MailingStreet__c.contains('New Seasonal Street')) {
                System.assertEquals(False, addr.Default_Address__c);
            } else {
                System.assertEquals(True, addr.Default_Address__c);
            }
        }

        Map<Id, Contact> contactsById = new Map<Id, Contact>([SELECT Id, Name, MailingStreet, 
                                                                MailingCity, Mailing_County__c, is_Address_Override__c, 
                                                                Current_Address__c
                                                                FROM Contact]);
        for (Contact con : contactsById.values()) {
            System.assert(con.MailingStreet.contains('New Seasonal Street'));
            System.assert(con.MailingCity.contains('New Seasonal City'));
            System.assert(con.Mailing_County__c.contains('New Seasonal County'));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }

        //Verify the previous default Address reocrds are still marked as default 
        conAddrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                            Parent_Contact__c, Latest_Start_Date__c, Latest_End_Date__c
                            FROM Address__c 
                            WHERE Id IN :conAddrList];
        System.assertEquals(2, conAddrList.size());
        for (Address__c addr : conAddrList) {
            if (addr.MailingStreet__c.contains('New Seasonal Street')) {
                System.assertEquals(False, addr.Default_Address__c);
            } else {
                System.assertEquals(True, addr.Default_Address__c);
            }
        }
    }

    /*********************************************************************************************************
    @description Create new current Seasonal Address records to existing Accounts and Contacts with existing 
    * default Address records. Schedule and calls ADDR_Seasonal_SCHED and ADDR_Seasonal_BATCH classes.
    * Verify:
    * - Contact's mailing fields are updated to match the mailing fields from the new Seasonal Address record. 
    * - Account's billing fields are updated to match the mailing fields from the new Seasonal Address record.
    * - Previous default Address records are still marked as default. 
    **********************************************************************************************************/
    @isTest
    private static void scheduleNewCurrentSeasonalAddress() {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c(Accounts_Addresses_Enabled__c = UTIL_Describe.getCustomAdminAccRecTypeID() + ';',
                                                                Contacts_Addresses_Enabled__c = True,
                                                                Simple_Address_Change_Treated_as_Update__c = True);
                                                                UTIL_CustomSettings_API.getSettingsForTests(hs);

        //Creates a default Address for each Account record
        UTIL_UnitTestData_TEST.AccsWithAddrs accsWithAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> addrListForAcc = accsWithAddrs.addrs;

        //Creates a default Address for each Contact record 
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsWithAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);
        List<Address__c> addrListForCon = contactsWithAddrs.addrs;

        //Create additional Address for each Account record, with seasonal information to expire tomorrow
        List<Address__c> newAddrsListForAccounts = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            newAddrsListForAccounts[i].Parent_Account__c = accsWithAddrs.accs[i].Id;
            newAddrsListForAccounts[i].Default_Address__c = False;
            newAddrsListForAccounts[i].Seasonal_Start_Month__c = String.valueOf(System.today().addDays(-31).month());
            newAddrsListForAccounts[i].Seasonal_Start_Day__c = String.valueOf(System.today().addDays(-31).day());
            newAddrsListForAccounts[i].Seasonal_End_Month__c = String.valueOf(System.today().addDays(1).month());
            newAddrsListForAccounts[i].Seasonal_End_Day__c = String.valueOf(System.today().addDays(1).day());
            newAddrsListForAccounts[i].MailingStreet__c = 'New Seasonal Street' + i;
            newAddrsListForAccounts[i].MailingCity__c = 'New Seasonal City' + i;
            newAddrsListForAccounts[i].MailingCounty__c = 'New Seasonal County' + i;
        }

        //Create additional Address for each Contact record, with seasonal information to expire tomorrow
        List<Address__c> newAddrsListForContacts = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            newAddrsListForContacts[i].Parent_Contact__c = contactsWithAddrs.contacts[i].Id;
            newAddrsListForContacts[i].Default_Address__c = False;
            newAddrsListForContacts[i].Seasonal_Start_Month__c = String.valueOf(System.today().addDays(-31).month());
            newAddrsListForContacts[i].Seasonal_Start_Day__c = String.valueOf(System.today().addDays(-31).day());
            newAddrsListForContacts[i].Seasonal_End_Month__c = String.valueOf(System.today().addDays(1).month());
            newAddrsListForContacts[i].Seasonal_End_Day__c = String.valueOf(System.today().addDays(1).day());
            newAddrsListForContacts[i].MailingStreet__c = 'New Seasonal Street' + i;
            newAddrsListForContacts[i].MailingCity__c = 'New Seasonal City' + i;
            newAddrsListForContacts[i].MailingCounty__c = 'New Seasonal County' + i;
        }  

        List<Address__c> allNewAddrList = new List<Address__c>(newAddrsListForAccounts);
        allNewAddrList.addAll(newAddrsListForContacts);

        //We want the processing to run on the new addresses from the trigger to set the addresses as current
        insert allNewAddrList;

        //Verify seasonal mailing fields on Address record are populated on the Account billing fields 
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, Current_Address__c
                                                                FROM Account]);
        for (Account acc : accountsById.values()) {
            System.assert(acc.BillingStreet.contains('New Seasonal Street'));
            System.assert(acc.BillingCity.contains('New Seasonal City'));
            System.assert(acc.Billing_County__c.contains('New Seasonal County'));
            System.assertNotEquals(Null, acc.Current_Address__c);
        }

        //Verify seasonal mailing fields on Address record are populated on the Contact mailing fields 
        Map<Id, Contact> contactsById = new Map<Id, Contact>([SELECT Id, Name, MailingStreet, 
                                                                MailingCity, Mailing_County__c, Current_Address__c,
                                                                is_Address_Override__c
                                                                FROM Contact]);
        for (Contact con : contactsById.values()) {
            System.assert(con.MailingStreet.contains('New Seasonal Street'));
            System.assert(con.MailingCity.contains('New Seasonal City'));
            System.assert(con.Mailing_County__c.contains('New Seasonal County'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }

        //Set End date to today for scheduled job and batch testing
        for (Address__c seasAddr : allNewAddrList ) {
            seasAddr.Seasonal_End_Day__c = String.valueOf(System.today().day()); 
            seasAddr.Seasonal_End_Month__c = String.valueOf(System.today().month());
        }

        // Turn off triggers because we need to update the addresses to test the batch 
        ADDR_Addresses_TDTM.turnOff();
        update allNewAddrList;
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

        accountsById = new Map<Id, Account>([SELECT Id, Name, Current_Address__c, 
                                                Current_Address__r.Default_Address__c, Current_Address__r.MailingStreet__c
                                                FROM Account]);
        for (Account acc : accountsById.values()) {
            if (acc.Current_Address__r.MailingStreet__c.contains('New Seasonal Street')) {
                System.assertEquals(False, acc.Current_Address__r.Default_Address__c);
            } else {
                System.assertEquals(True, acc.Current_Address__r.Default_Address__c);
            }
        }

        contactsById = new map<Id, Contact>([SELECT Id, Name, Current_Address__c, 
                                                Current_Address__r.Default_Address__c, Current_Address__r.MailingStreet__c, is_Address_Override__c
                                                FROM Contact]);
        for (Contact con : contactsById.values()) {
            System.assertEquals(False, con.is_Address_Override__c);
            if (con.Current_Address__r.MailingStreet__c.contains('New Seasonal Street')) {
                System.assertEquals(True, con.Current_Address__r.Default_Address__c);
            } else {
                System.assertEquals(True, con.Current_Address__r.Default_Address__c);
            }
        }
    }
	
    /*********************************************************************************************************
    @description Create new current Seasonal Address records to an existing Account with existing 
    * default Address records. 
    * Verify:
    * - Account's billing fields are updated to match the mailing fields from the new Seasonal Address record.
    **********************************************************************************************************/
    @isTest
    private static void insertCurrentSeasonalAddressWithStartEndYear() {
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getCustomAdminAccRecTypeID(),
                                                                                Accounts_Addresses_Enabled__c = UTIL_Describe.getCustomAdminAccRecTypeID() + ';',
                                                                                Simple_Address_Change_Treated_as_Update__c = True));
        
        UTIL_UnitTestData_TEST.AccsWithAddrs accWithAddrList = UTIL_UnitTestData_TEST.createTestAccsAddrs(1, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Account> accList = accWithAddrList.accs; 

        //Create seasonal Address record with start and end year that include the current date
        List<Address__c> seasonalAddrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);
        for (Integer i=0; i<seasonalAddrList.size(); i++) {
            seasonalAddrList[i].Parent_Account__c = accList[0].Id; 
            seasonalAddrList[i].MailingStreet__c = '123 Seasonal'; 
            seasonalAddrList[i].MailingCity__c = 'Seattle'; 
            seasonalAddrList[i].MailingCounty__c = 'Bergen'; 
            seasonalAddrList[i].MailingState__c = 'Washington'; 
            seasonalAddrList[i].MailingCountry__c = 'United States';
            seasonalAddrList[i].Seasonal_Start_Day__c = String.valueOf(System.today().addDays(-1).day()); 
            seasonalAddrList[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(-1).month()); 
            seasonalAddrList[i].Seasonal_Start_Year__c = System.today().addYears(-1).year(); 
            seasonalAddrList[i].Seasonal_End_Day__c = String.valueOf(System.today().addDays(1).day()); 
            seasonalAddrList[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(1).month()); 
            seasonalAddrList[i].Seasonal_End_Year__c = System.today().addYears(1).year(); 
                
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert seasonalAddrList;
        Test.stopTest();

        //Seasonal Address should have been copied to the Account
        accList = [SELECT BillingStreet, BillingCity, Billing_County__c, 
                    BillingState 
                    FROM Account 
                    WHERE Id IN :accList];
        for (Account acc : accList) {
            System.assertEquals('123 Seasonal', acc.BillingStreet);
            System.assertEquals('Seattle', acc.BillingCity);
            System.assertEquals('Bergen', acc.Billing_County__c);
            System.assertEquals('Washington', acc.BillingState);
        }
    }
	
    /*********************************************************************************************************
    @description Create new 2 non current Seasonal Address records to an Account with existing Address records. 
    * Verify:
    * - Only 2 Address records are created and associated to the Account. 
    * - Account billing fields are updated with the Seasonal Address based on the month this test method is ran. 
    **********************************************************************************************************/
    @isTest
    private static void insertNewNonCurrentSeasonalAddressOnAccWithoutAddresses() {
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getCustomAdminAccRecTypeID(),
                                                                                Accounts_Addresses_Enabled__c = UTIL_Describe.getCustomAdminAccRecTypeID() + ';',
                                                                                Simple_Address_Change_Treated_as_Update__c = True));
        
        List<Account> accList = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe.getCustomAdminAccRecTypeID());
        insert accList; 
        
        List<Address__c> seasonalAddrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);
        for (Integer i=0; i<seasonalAddrList.size(); i++) {
            seasonalAddrList[i].Parent_Account__c = accList[0].Id; 
            seasonalAddrList[i].MailingStreet__c = '123 Seasonal'; 
            seasonalAddrList[i].MailingCity__c = 'Austin'; 
            seasonalAddrList[i].MailingCounty__c = 'Bergen'; 
            seasonalAddrList[i].MailingState__c = 'Texas'; 
            seasonalAddrList[i].MailingCountry__c = 'United States';
            seasonalAddrList[i].Seasonal_Start_Day__c = '1'; 
            seasonalAddrList[i].Seasonal_Start_Month__c = '1';
            seasonalAddrList[i].Seasonal_Start_Year__c = System.today().year(); 
            seasonalAddrList[i].Seasonal_End_Day__c = '31'; 
            seasonalAddrList[i].Seasonal_End_Month__c = '5';
            seasonalAddrList[i].Seasonal_End_Year__c = System.today().year(); 
                
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert seasonalAddrList;
        
        List<Address__c> seasonalAddrList2 = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);
        for (Integer i=0; i<seasonalAddrList2.size(); i++) {
            seasonalAddrList2[i].Parent_Account__c = accList[0].Id; 
            seasonalAddrList2[i].MailingStreet__c = '123 Seasonal'; 
            seasonalAddrList2[i].MailingCity__c = 'Seattle'; 
            seasonalAddrList2[i].MailingCounty__c = 'Bergen'; 
            seasonalAddrList2[i].MailingState__c = 'Washington'; 
            seasonalAddrList2[i].MailingCountry__c = 'United States';
            seasonalAddrList2[i].Seasonal_Start_Day__c = '1'; 
            seasonalAddrList2[i].Seasonal_Start_Month__c = '6';
            seasonalAddrList2[i].Seasonal_Start_Year__c = System.today().year(); 
            seasonalAddrList2[i].Seasonal_End_Day__c = '31'; 
            seasonalAddrList2[i].Seasonal_End_Month__c = '7';
            seasonalAddrList2[i].Seasonal_End_Year__c = System.today().year();    
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert seasonalAddrList2;
        Test.stopTest();
        
        //Second address should have been successfully saved, without overlap error. Github #196.
        List<Address__c> addrList = [SELECT ID 
                                        FROM Address__c 
                                        WHERE Parent_Account__c IN :accList];
        System.assertEquals(2, addrList.size());
    }
	
    /*********************************************************************************************************
    @description Update existing current Seasonal Address record's mailing fields. 
    * Verify:
    * - No new seasonal Address record is created.  
    * - Account billing fields are updated to match the mailing fields recently updated from Seasonal Address.
    * - Previous default Address record is still marked as default. 
    **********************************************************************************************************/
    @isTest
    private static void updateCurrentSeasonalAddressMailingFields() {
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getCustomAdminAccRecTypeID(),
                                                                                Accounts_Addresses_Enabled__c = UTIL_Describe.getCustomAdminAccRecTypeID() + ';',
                                                                                Simple_Address_Change_Treated_as_Update__c = True)); 
        
        UTIL_UnitTestData_TEST.AccsWithAddrs accWithAddrList = UTIL_UnitTestData_TEST.createTestAccsAddrs(1, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Account> accList = accWithAddrList.accs; 
        
        //Create seasonal Address record with start and end year that include the current date
        List<Address__c> seasonalAddrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);
        for (Integer i=0; i<seasonalAddrList.size(); i++) {
            seasonalAddrList[i].Parent_Account__c = accList[0].Id; 
            seasonalAddrList[i].MailingStreet__c = '123 Seasonal'; 
            seasonalAddrList[i].MailingCity__c = 'Seattle'; 
            seasonalAddrList[i].MailingCounty__c = 'Bergen'; 
            seasonalAddrList[i].MailingState__c = 'Washington'; 
            seasonalAddrList[i].MailingCountry__c = 'United States';
            seasonalAddrList[i].Seasonal_Start_Day__c = String.valueOf(System.today().addDays(-1).day()); 
            seasonalAddrList[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(-1).month()); 
            seasonalAddrList[i].Seasonal_Start_Year__c = System.today().addYears(-1).year(); 
            seasonalAddrList[i].Seasonal_End_Day__c = String.valueOf(System.today().addDays(1).day()); 
            seasonalAddrList[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(1).month()); 
            seasonalAddrList[i].Seasonal_End_Year__c = System.today().addYears(1).year(); 
                
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert seasonalAddrList;
        
        //Modify seasonal Address fields
        seasonalAddrList[0].MailingStreet__c = 'New Seasonal Address';
        seasonalAddrList[0].MailingCity__c = 'Portland';
        seasonalAddrList[0].MailingState__c = 'Oregon';
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update seasonalAddrList;
        Test.stopTest();

        //Changes should have been copied to Account
        accList = [SELECT BillingStreet, BillingCity, BillingState 
                    FROM Account 
                    WHERE Id IN :accList];
        System.assertEquals('New Seasonal Address', accList[0].BillingStreet);
        System.assertEquals('Portland', accList[0].BillingCity);
        System.assertEquals('Oregon', accList[0].BillingState);
        
        List<Address__c> addrList = [SELECT Id, MailingStreet__c, Default_Address__c
                                        FROM Address__c]; 
        System.assertEquals(2, addrList.size()); 
        for (Address__c addr : addrList) {
            if (addr.MailingStreet__c.contains('Street')) {
                System.assertEquals(True, addr.Default_Address__c); 
            }
        }
    }
	
    /*********************************************************************************************************
    @description Update existing current Seasonal Address record's start year. 
    * Verify:
    * - No new seasonal Address record is created.  
    * - Account billing fields are updated to match the mailing fields of the default non Seasonal Address record. 
    * - Previous default Address record is still marked as default. 
    **********************************************************************************************************/
    @isTest
    private static void updateCurrentSeasonalAddressStartYear() {
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getCustomAdminAccRecTypeID(),
                                                                                Accounts_Addresses_Enabled__c = UTIL_Describe.getCustomAdminAccRecTypeID() + ';',
                                                                                Simple_Address_Change_Treated_as_Update__c = True));
        
        UTIL_UnitTestData_TEST.AccsWithAddrs accWithAddrList = UTIL_UnitTestData_TEST.createTestAccsAddrs(1, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Account> accList = accWithAddrList.accs; 
        
        //Create seasonal Address record with start and end year that include the current date
        List<Address__c> seasonalAddrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);
        for (Integer i=0; i<seasonalAddrList.size(); i++) {
            seasonalAddrList[i].Parent_Account__c = accList[0].Id; 
            seasonalAddrList[i].MailingStreet__c = '123 Seasonal'; 
            seasonalAddrList[i].MailingCity__c = 'Seattle'; 
            seasonalAddrList[i].MailingCounty__c = 'Bergen'; 
            seasonalAddrList[i].MailingState__c = 'Washington'; 
            seasonalAddrList[i].MailingCountry__c = 'United States';
            seasonalAddrList[i].Seasonal_Start_Day__c = String.valueOf(System.today().addDays(-1).day()); 
            seasonalAddrList[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(-1).month()); 
            seasonalAddrList[i].Seasonal_Start_Year__c = System.today().addYears(-1).year(); 
            seasonalAddrList[i].Seasonal_End_Day__c = String.valueOf(System.today().addDays(1).day()); 
            seasonalAddrList[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(1).month()); 
            seasonalAddrList[i].Seasonal_End_Year__c = System.today().addYears(1).year(); 
                
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert seasonalAddrList;

        //Modify Sesonal Start Year so it doesn't start this year 
        seasonalAddrList[0].Seasonal_Start_Year__c = System.today().addYears(1).year();
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update seasonalAddrList;
        Test.stopTest();

        //Account should have reverted to default address
        accList = [SELECT BillingStreet, BillingCity, Billing_County__c 
                    FROM Account 
                    WHERE Id IN :accList];
        System.assert(accList[0].BillingStreet.contains('Street'));
        System.assert(accList[0].BillingCity.contains('City'));
        System.assert(accList[0].Billing_County__c.contains('County'));
    }
	
    /*********************************************************************************************************
    @description Delete existing current Seasonal Address record.  
    * Verify:
    * - Seasonal Address record is deleted. 
    * - Account billing fields are updated to match the mailing fields of the default non Seasonal Address record. 
    * - Previous default Address record is still marked as default. 
    **********************************************************************************************************/
    @isTest
    private static void deleteCurrentSeasonalAddress() {
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getCustomAdminAccRecTypeID(),
                                                                                Accounts_Addresses_Enabled__c = UTIL_Describe.getCustomAdminAccRecTypeID() + ';',
                                                                                Simple_Address_Change_Treated_as_Update__c = True));
        
        UTIL_UnitTestData_TEST.AccsWithAddrs accWithAddrList = UTIL_UnitTestData_TEST.createTestAccsAddrs(1, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Account> accList = accWithAddrList.accs; 
        
        //Create seasonal Address record with start and end year that include the current date
        List<Address__c> seasonalAddrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);
        for (Integer i=0; i<seasonalAddrList.size(); i++) {
            seasonalAddrList[i].Parent_Account__c = accList[0].Id; 
            seasonalAddrList[i].MailingStreet__c = '123 Seasonal'; 
            seasonalAddrList[i].MailingCity__c = 'Seattle'; 
            seasonalAddrList[i].MailingCounty__c = 'Bergen'; 
            seasonalAddrList[i].MailingState__c = 'Washington'; 
            seasonalAddrList[i].MailingCountry__c = 'United States';
            seasonalAddrList[i].Seasonal_Start_Day__c = String.valueOf(System.today().addDays(-1).day()); 
            seasonalAddrList[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(-1).month()); 
            seasonalAddrList[i].Seasonal_Start_Year__c = System.today().addYears(-1).year(); 
            seasonalAddrList[i].Seasonal_End_Day__c = String.valueOf(System.today().addDays(1).day()); 
            seasonalAddrList[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(1).month()); 
            seasonalAddrList[i].Seasonal_End_Year__c = System.today().addYears(1).year(); 
                
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert seasonalAddrList;
        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        delete seasonalAddrList;
        Test.stopTest();

        //Account should have reverted to default address
        accList = [SELECT BillingStreet, BillingCity, Billing_County__c 
                    FROM Account 
                    WHERE Id IN :accList];
        System.assert(accList[0].BillingStreet.contains('Street'));
        System.assert(accList[0].BillingCity.contains('City'));
        System.assert(accList[0].Billing_County__c.contains('County'));
    }
	
    /*********************************************************************************************************
    @description Create new current Seasonal Address record for a Contact who has an existing default Address record.
    * Verify:
    * - Seasonal Address record is created. 
    * - Account billing fields are updated to match the mailing fields of the newly created current Seasonal Address record. 
    * - Previous default Address record is still marked as default. 
    **********************************************************************************************************/
    @isTest
    private static void insertNewCurrentSeasonalAddressForContact() {
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getCustomAdminAccRecTypeID(),
                                                                                Contacts_Addresses_Enabled__c = True,
                                                                                Simple_Address_Change_Treated_as_Update__c = True));

        Contact contact = UTIL_UnitTestData_TEST.getContact(); 
        contact.LastName = 'newSeasonalAddr';
        contact.MailingStreet = '123 Main St';
        contact.MailingCity = 'Austin';
        contact.Mailing_County__c = 'Bergen'; 
        contact.MailingState = 'Texas';
        contact.MailingCountry = 'United States';
        insert Contact;

        //Address record should have been created as child of Contact
        List<Address__c> addrList = [SELECT Parent_Contact__c, Parent_Account__c, MailingStreet__c, 
                                    MailingCity__c, MailingCounty__c, MailingState__c 
                                    FROM Address__c];
        System.assertEquals(1, addrList.size());
        System.assertEquals(contact.Id, addrList[0].Parent_Contact__c);
        System.assertEquals(Null, addrList[0].Parent_Account__c);
        System.assertEquals('123 Main St', addrList[0].MailingStreet__c);
        System.assertEquals('Austin', addrList[0].MailingCity__c);
        System.assertEquals('Bergen', addrList[0].MailingCounty__c);
        System.assertEquals('Texas', addrList[0].MailingState__c);
        
        
        //Create seasonal Address record with start and end year that include the current date
        List<Address__c> seasonalAddrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);
        for (Integer i=0; i<seasonalAddrList.size(); i++) {
            seasonalAddrList[i].Parent_Contact__c = contact.Id; 
            seasonalAddrList[i].MailingStreet__c = '50 Fremont St'; 
            seasonalAddrList[i].MailingCity__c = 'SF'; 
            seasonalAddrList[i].MailingCounty__c = 'Suffolk'; 
            seasonalAddrList[i].MailingState__c = 'California'; 
            seasonalAddrList[i].MailingCountry__c = 'United States';
            seasonalAddrList[i].Seasonal_Start_Day__c = String.valueOf(System.today().day()); 
            seasonalAddrList[i].Seasonal_Start_Month__c = String.valueOf(System.today().month()); 
            seasonalAddrList[i].Seasonal_Start_Year__c = System.today().year()-1; 
            seasonalAddrList[i].Seasonal_End_Day__c = String.valueOf(System.today().day()); 
            seasonalAddrList[i].Seasonal_End_Month__c = String.valueOf(System.today().month()); 
            seasonalAddrList[i].Seasonal_End_Year__c = System.today().year()+1; 
                
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert seasonalAddrList;
        Test.stopTest();
        
        contact = [SELECT MailingStreet, MailingCity, MailingState, 
                    Mailing_County__c, Current_Address__c 
                    FROM Contact 
                    WHERE Id = :contact.Id];
        System.assertEquals('50 Fremont St', contact.MailingStreet);
        System.assertEquals('SF', contact.MailingCity);
        System.assertEquals('Suffolk', contact.Mailing_County__c);
        System.assertEquals('California', contact.MailingState);
        System.assertEquals(seasonalAddrList[0].Id, contact.Current_Address__c);
        
        addrList = [SELECT Id, MailingStreet__c, Default_Address__c
                        FROM Address__c];
        System.assertEquals(2, addrList.size());
        for (Address__c addr : addrList) {
            if (addr.MailingStreet__c.contains('50 Fremont St')) {
                System.assertEquals(False, addr.Default_Address__c); 
            } else {
                System.assertEquals(True, addr.Default_Address__c); 
            }
        }
    }
	
    /*********************************************************************************************************
    @description Create a 2nd current Seasonal overlap Address record on a Contact. 
    * Verify:
    * - Unable to create the 2nd current overal seasonal Address record. 
    **********************************************************************************************************/
    @isTest
    private static void insert2ndCurrentSeasonalOverlapAddressOnContact() {
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getCustomAdminAccRecTypeID(),
                                                                                Contacts_Addresses_Enabled__c = True,
                                                                                Simple_Address_Change_Treated_as_Update__c = True));
        Contact contact = UTIL_UnitTestData_TEST.getContact(); 
        contact.LastName = 'newSeasonalAddr';
        insert Contact;
        
        //Create seasonal Address record with start and end year that include the current date
        List<Address__c> seasonalAddrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);
        for (Integer i=0; i<seasonalAddrList.size(); i++) {
            seasonalAddrList[i].Parent_Contact__c = contact.Id; 
            seasonalAddrList[i].MailingStreet__c = '123 Main St'; 
            seasonalAddrList[i].MailingCity__c = 'Chicago'; 
            seasonalAddrList[i].MailingCounty__c = 'Suffolk'; 
            seasonalAddrList[i].MailingState__c = 'IL'; 
            seasonalAddrList[i].MailingCountry__c = 'United States';
            seasonalAddrList[i].Seasonal_Start_Day__c = String.valueOf(System.today().day()); 
            seasonalAddrList[i].Seasonal_Start_Month__c = String.valueOf(System.today().month()); 
            seasonalAddrList[i].Seasonal_Start_Year__c = System.today().year()-1; 
            seasonalAddrList[i].Seasonal_End_Day__c = String.valueOf(System.today().day()); 
            seasonalAddrList[i].Seasonal_End_Month__c = String.valueOf(System.today().month()); 
            seasonalAddrList[i].Seasonal_End_Year__c = System.today().year()+1; 
                
        }
        insert seasonalAddrList;

        List<Address__c> addrList = [SELECT Parent_Contact__c, Parent_Account__c, MailingStreet__c, 
                                        MailingCity__c, MailingState__c, Default_Address__c
                                        FROM Address__c];
        System.assertEquals(1, addrList.size());
        System.assertEquals(contact.Id, addrList[0].Parent_Contact__c);
        System.assertEquals(Null, addrList[0].Parent_Account__c);
        System.assertEquals('123 Main St', addrList[0].MailingStreet__c);
        System.assertEquals('Chicago', addrList[0].MailingCity__c);
        System.assertEquals('IL', addrList[0].MailingState__c);
        System.assertEquals(False, addrList[0].Default_Address__c);
        
        
        //Create seasonal Address record with start and end year that include the current date
        List<Address__c> seasonalAddrList2 = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);
        for (Integer i=0; i<seasonalAddrList.size(); i++) {
            seasonalAddrList2[i].Parent_Contact__c = contact.Id; 
            seasonalAddrList2[i].MailingStreet__c = '50 Fremont St'; 
            seasonalAddrList2[i].MailingCity__c = 'SF'; 
            seasonalAddrList2[i].MailingCounty__c = 'Bergen'; 
            seasonalAddrList2[i].MailingState__c = 'CA'; 
            seasonalAddrList2[i].MailingCountry__c = 'United States';
            seasonalAddrList2[i].Seasonal_Start_Day__c = String.valueOf(System.today().day()); 
            seasonalAddrList2[i].Seasonal_Start_Month__c = String.valueOf(System.today().month()); 
            seasonalAddrList2[i].Seasonal_Start_Year__c = System.today().year()-2; 
            seasonalAddrList2[i].Seasonal_End_Day__c = String.valueOf(System.today().day()); 
            seasonalAddrList2[i].Seasonal_End_Month__c = String.valueOf(System.today().month()); 
            seasonalAddrList2[i].Seasonal_End_Year__c = System.today().year()+2; 
                
        }
        ADDR_Addresses_TDTM.turnOn();

        Test.startTest();
        try {
            insert seasonalAddrList2;
        } catch(System.DmlException e) {
            System.assertEquals(True, e.getMessage().contains(System.Label.addrSeasonalOverlap));
            return;
        }
        System.assertEquals(False, True);
    }
}