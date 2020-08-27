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
* @description Tests specific to Administrative Account Address Management. 
*/

@isTest
public with sharing class ADDR_AdminAcc_TEST {
    
    /*@description Set up of Hierarchy Settings leverage by test methods*/
    private static void configSettings() {
        Id customAdminRecType = UTIL_Describe.getCustomAdminAccRecTypeID();
        
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c(Accounts_Addresses_Enabled__c = customAdminRecType + ';',
                                                                Simple_Address_Change_Treated_as_Update__c = True);
        UTIL_CustomSettingsFacade.getSettingsForTests(hs);
    }
        
    /*********************************************************************************************************
    @description Account's default Address mailing fields are updated. 
    * Verify:
    * - The billing address fields on the Account are updated with the recently updated mailing fields from the 
    * default Address record. 
    **********************************************************************************************************/            
    @isTest 
    private static void updateDefaultAddressMailingFields() {
        configSettings();
        
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> addrList = accsAddrs.addrs;
        
        for (Integer i = 0; i < addrList.size(); i++) {
            Address__c addr = addrList[i];
            addr.MailingStreet__c = 'New Street' + i;
            addr.MailingCity__c = 'New City' + i;
            addr.MailingCounty__c = 'New County' + i;
        }
        Test.startTest();
        update addrList;
        Test.stopTest();

        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, BillingStreet, BillingCity, 
                                                                Billing_County__c, Current_Address__c
                                                                FROM Account]);
        for (Account acc : accountsById.values()) {
            System.assert(acc.BillingStreet.contains('New Street'));
            System.assert(acc.BillingCity.contains('New City'));
            System.assert(acc.Billing_County__c.contains('New County'));
            System.assertNotEquals(Null, acc.Current_Address__c);
        }
    }
    
    /*********************************************************************************************************
    @description Account's default Address record is deleted. 
    * Verify: 
    * - The billing address fields on the Account are cleared. 
    **********************************************************************************************************/            
    @isTest 
    private static void deleteDefaultAddressRecord() {
        configSettings();
        
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> addrList = accsAddrs.addrs;
        Test.startTest();
        delete addrList;
        Test.stopTest();

        //Verify that the Account billing address fields are cleared
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, BillingStreet, BillingCity, 
                                                                Billing_County__c, Current_Address__c 
                                                                FROM Account]);
        for (Account acc : accountsById.values()) {
            System.assertEquals(Null, acc.BillingStreet);
            System.assertEquals(Null, acc.BillingCity);
            System.assertEquals(Null, acc.Billing_County__c);
        }
    }

    /*********************************************************************************************************
    @description Account's Current_Address__c is set with a non default Address record. Delete the Address record
    * that is set on Current_Address__c. 
    * Verify:
    * - The Current_Address__c is autopopulated with an Address record that is marked as default. 
    * - The billing address fields on the Account is populated with the mailing fields from the default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void deleteNonDefaultAddress() {
        configSettings();
        
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> addrList = accsAddrs.addrs;
        
        addrList = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        for (Integer i = 0; i < addrList.size(); i++) {
            addrList[i].Parent_Account__c = accsAddrs.accs[i].Id;
            addrList[i].Default_Address__c = False;
            addrList[i].MailingStreet__c = 'override' + i;
            addrList[i].MailingCity__c = 'override' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert addrList;
        
        //Set the Accounts' Current_Address__c field with the additional Address records created
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            Account acc = accsAddrs.accs[i];
            acc.Current_Address__c = addrList[i].Id;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        update accsAddrs.accs;        
        
        //Delete the Address records on Current_Address__c
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        delete addrList;
        Test.stopTest();

        //Verify that the Account address fields went back to the default
        Map<Id, Account> accountsById  = new Map<Id, Account>([SELECT Id, BillingStreet, BillingCity, 
                                                                Billing_County__c, Current_Address__c 
                                                                FROM Account]);
        for (Account acc : accountsById .values()) {
            System.assert(acc.BillingStreet.contains('Street'));
            System.assert(acc.BillingCity.contains('City')); 
            System.assert(acc.Billing_County__c.contains('County')); 
            System.assertNotEquals(Null, acc.Current_Address__c);                
        }
    }

    /*********************************************************************************************************
    @description Account's default Address record is marked as non default. 
    * Verify:
    * - The billing address fields on the Account record should be cleared out. 
    **********************************************************************************************************/            
    @isTest
    private static void updateDefaultAddressToNonDefault() {
        configSettings();
        
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> addrList = accsAddrs.addrs;
        
        for (Integer i = 0; i < addrList.size(); i++) {
            Address__c addr = addrList[i];
            addr.Default_Address__c = False;
        }
        Test.startTest();
        update addrList;
        Test.stopTest();

        //Verify that the Account and Contacts don't share the same address and it's new for the Account!
        Map<Id, Account> accountsById  = new Map<Id, Account>([SELECT Id, BillingStreet, BillingCity, 
                                                                Billing_County__c, Current_Address__c 
                                                                FROM Account]);
        for (Account acc : accountsById .values()) {
            System.assertEquals(Null, acc.BillingStreet); 
            System.assertEquals(Null, acc.BillingCity); 
            System.assertEquals(Null, acc.Billing_County__c);
            System.assertEquals(Null, acc.Current_Address__c); 
        }
    }

    /*********************************************************************************************************
    @description Account's Current_Address__c is set to a non default Address record and update existing default
    * Address record's mailing fields. 
    * Verify: 
    * - The billing address fields on the Account is updated with updated mailing fields of the existing default
    * Address record.  
    **********************************************************************************************************/            
    @isTest
    private static void updateDefaultAddressMailingFieldsWithExistingNonDefaultOverrideAddress() {
        configSettings();
        
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> addrList = accsAddrs.addrs;
        
        //Create new non-default address
        Address__c addrNew = new Address__c();
        addrNew.MailingStreet__c = 'street override';
        addrNew.MailingCity__c = 'city override';
        addrNew.MailingCounty__c = 'county override';
        addrNew.Default_Address__c = False;
        //Assign it to the second account
        addrNew.Parent_Account__c = accsAddrs.accs[1].Id;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert addrNew;
        
        accsAddrs.accs[1].Current_Address__c = addrNew.Id;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        update accsAddrs.accs[0];

        //Update the default Address records' mailing fields for both Accounts
        addrList[0].MailingStreet__c = 'New Street';
        addrList[0].MailingCity__c = 'New City';
        addrList[0].MailingCounty__c = 'New County';
        addrList[1].MailingStreet__c = 'New Street';
        addrList[1].MailingCity__c = 'New City';
        addrList[1].MailingCounty__c = 'New County';
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update addrList;
        Test.stopTest();
        
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, BillingStreet, BillingCity, 
                                                                Billing_County__c, Current_Address__c 
                                                                FROM Account]);
        //Verify that the billing address on the Account was updated to match the updated mailing fields on their Address records
        for (Account acc : accountsById.values()) {         
            System.assert(acc.BillingStreet.contains('New Street'));
            System.assert(acc.BillingCity.contains('New City'));
            System.assert(acc.Billing_County__c.contains('New County'));
            System.assertNotEquals(Null, acc.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Account has an existing default Address record. A second Address record is created and is set
    * as the default Address record. 
    * Verify: 
    * - The second Address record is now the default Address record. 
    * - The billing address fields on the Account is now updated with the second Address record's mailing fields. 
    * - The first Address record's Default_Address__c is cleared. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNewDefaultAddressOnExistingAccountWithExistingDefaultAddress() {
        configSettings();
        
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> addrList = accsAddrs.addrs;
        
        //Create additional addresses
        addrList = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            addrList[i].Parent_Account__c = accsAddrs.accs[i].Id;
            addrList[i].Default_Address__c = True;
            addrList[i].MailingStreet__c = 'New Default Street' + i;
            addrList[i].MailingCity__c = 'New Default City' + i;
            addrList[i].MailingCounty__c = 'New Default County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert addrList;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();        
        Test.stopTest();
        
        List<Address__c> addrQuery = [SELECT Id, Default_Address__c 
                                        FROM Address__c 
                                        WHERE Id IN :addrList];
        System.assertEquals(True, addrQuery[0].Default_Address__c); 
        System.assertEquals(2, addrQuery.size()); 
        
        //Verify that the billing address fields on the Account are updated with the new Address mailing fields 
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, BillingStreet, BillingCity, 
                                                                Billing_County__c, Current_Address__c 
                                                                FROM Account]);
        for (Account acc : accountsById.values()) {
            System.assert(acc.BillingStreet.contains('New Default Street'));
            System.assert(acc.BillingCity.contains('New Default City'));
            System.assert(acc.Billing_County__c.contains('New Default County'));
            System.assertNotEquals(Null, acc.Current_Address__c);
        }
        
        //Verify previous Address records Default_Adress__c is cleared
        //and verify latest start date and latest end date appropriately set.
        List<Address__c> returnAddrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                            Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c 
                                            FROM Address__c];
        System.assertEquals(4, returnAddrList.size());
        for (Address__c addr : returnAddrList) {
            if (addr.MailingStreet__c.contains('New Default Street')) {
                System.assertEquals(True, addr.Default_Address__c); 
                System.assertEquals(System.today(), addr.Latest_Start_Date__c);
                System.assertEquals(Null, addr.Latest_End_Date__c);
            }
            if (addr.MailingStreet__c.startsWith('Street')) {
                System.assertEquals(False, addr.Default_Address__c); 
                System.assertEquals(System.today(), addr.Latest_End_Date__c);        
            }
        }   
    }
    
    /*********************************************************************************************************
    @description Account has existing default Address record. A second default Address record is created. Update 
    * the original/first Address record's Default_Address__c and set it to true. 
    * Verify: 
    * - The original/first Address record is not the default Address record for the Account. 
    * - The billing address fields on the Account is reset to the original/first Address record's mailing fields. 
    * - The second Address record is no longer set as the default Address record for the Account. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNewDefaultAddressAndResetOriginalDefaultAddress() {
        configSettings();
        
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> originalAddrList = accsAddrs.addrs;
        
        //Create additional addresses
        ADDR_Addresses_TDTM.addressIdsInserted = new Set<Id>();
        List<Address__c> addrs = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            addrs[i].Parent_Account__c = accsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = True;
            addrs[i].MailingStreet__c = 'New Default Street' + i;
            addrs[i].MailingCity__c = 'New Default City' + i;
            addrs[i].MailingCounty__c = 'New Default County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert addrs;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        
        //Update original default Address records' mailing fields and set its Default_Address__c to true
        //added this extra set to test fix where we didn't use the correct default
        ADDR_Addresses_TDTM.addressIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            originalAddrList[i].Default_Address__c = True;
            originalAddrList[i].MailingStreet__c = 'Original Default Street' + i;
            originalAddrList[i].MailingCity__c = 'Original Default City' + i;
            originalAddrList[i].MailingCounty__c = 'Original Default County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update originalAddrList;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();
        
        //Verify the additional addresses got Default cleared
        //Verify latest start date and latest end date appropriately set
        List<Address__c> returnAddrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                            Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c 
                                            FROM Address__c];
        System.assertEquals(4, returnAddrList.size());
        for (Address__c addr : returnAddrList) {
            if (addr.MailingStreet__c.contains('New Default Street')) {
                System.assertEquals(False, addr.Default_Address__c); 
                System.assertEquals(System.today(), addr.Latest_Start_Date__c);
                System.assertEquals(System.today(), addr.Latest_End_Date__c);
            } else if (addr.MailingStreet__c.contains('Original Default Street')) {
                System.assertEquals(True, addr.Default_Address__c);
                System.assertEquals(Null, addr.Latest_End_Date__c);
            } else {
                System.assertEquals(System.today(), addr.Latest_End_Date__c);
            }
        }     
    }

    /*********************************************************************************************************
    @description Account has an existing default Address record. Account's billing fields are updated multiple times. 
    * Verify:
    * - New Address records are created for each time the billing fields are updated. 
    * - The newly created Address record is set as the default Address record for the Account. 
    * - The original default Address record is no longer marked as the default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void updateAdminAcctBillingFieldsXTimes() {
        configSettings();

        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(4, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> addrList = accsAddrs.addrs;
        
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = 'Direct Street Edit';
            accsAddrs.accs[i].BillingCity = 'Direct City Edit';
            accsAddrs.accs[i].Billing_County__c = 'Direct County Edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        update accsAddrs.accs;

        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = 'another Street Edit';
            accsAddrs.accs[i].BillingCity = 'another City Edit';
            accsAddrs.accs[i].Billing_County__c = 'another County Edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        update accsAddrs.accs;

        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = 'final Street Edit';
            accsAddrs.accs[i].BillingCity = 'final City Edit';
            accsAddrs.accs[i].Billing_County__c = 'final County Edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update accsAddrs.accs;
        Test.stopTest();
        
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, BillingStreet, BillingCity, 
                                                                Billing_County__c, Current_Address__c 
                                                                FROM Account]);
        for (Account acc : accountsById.values()) {
            System.assert(acc.BillingStreet.contains('final Street Edit'));
            System.assert(acc.BillingCity.contains('final City Edit'));
            System.assert(acc.Billing_County__c.contains('final County Edit'));
            System.assertNotEquals(Null, acc.Current_Address__c);
        }

        //Verify the previous addresses got Default cleared
        List<Address__c> returnAddrList = [SELECT Id, Default_Address__c, MailingStreet__c, Parent_Account__c 
                                            FROM Address__c];
        //Each set of edits created a new address record
        System.assertEquals(16, returnAddrList.size());
        for (Address__c addr : returnAddrList) {
            if (addr.MailingStreet__c.contains('final Street Edit')) {
                System.assertEquals(True, addr.Default_Address__c); 
            } else {
                System.assertEquals(False, addr.Default_Address__c); 
            }
        }                
    }

    /*********************************************************************************************************
    @description Account's billing address fields are updated. 
    * Verify:
    * - New Address record is created its Default_Address__c is set to true. 
    * - The original Address record is no longer marked as teh default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void updateAdminAccBillingFieldsOnce() {
        configSettings();
                
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> addrList = accsAddrs.addrs;
        
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = 'Direct Street Edit';
            accsAddrs.accs[i].BillingCity = 'Direct City Edit';
            accsAddrs.accs[i].Billing_County__c = 'Direct County Edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update accsAddrs.accs;
        Test.stopTest();
        
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet,
                                                                BillingCity, Billing_County__c, Current_Address__c 
                                                                FROM Account]);
        System.assertEquals('Direct Street Edit', accountsById.values()[0].BillingStreet);
        System.assertEquals('Direct City Edit', accountsById.values()[0].BillingCity);
        System.assertEquals('Direct County Edit', accountsById.values()[0]. Billing_County__c);
        System.assertEquals('Direct Street Edit', accountsById.values()[1].BillingStreet);
        System.assertEquals('Direct City Edit', accountsById.values()[1].BillingCity);
        System.assertEquals('Direct County Edit', accountsById.values()[1].Billing_County__c);
        
        List<Address__c> returnAddrList = [SELECT Id, Default_Address__c, MailingStreet__c, Parent_Account__c 
                                            FROM Address__c];
        System.assertEquals(4, returnAddrList.size());
        for (Address__c addr : returnAddrList) {
            if (addr.MailingStreet__c.contains('Direct Street Edit')) {
                System.assertEquals(True, addr.Default_Address__c);
            } else {
                System.assertEquals(False, addr.Default_Address__c); 
            }
        }
    }

    /*********************************************************************************************************
    @description Account's billing address fields are updated - format only or single billing fields. 
    * Verify: 
    * - No new Address records were created. 
    **********************************************************************************************************/            
    @isTest
    private static void updateAdminAccBillingFieldsForSimpleAddressTreatedUpdate() {
        configSettings();
        
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> addrList = accsAddrs.addrs;
        
        //Modify some of the Account billing address fields. Treat the update to the Account's 
        //billing address fields as an update instead of new Address. 
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = 'Direct Street Edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();
        update accsAddrs.accs;
            
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingState = 'Washington';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();    
        update accsAddrs.accs;
        
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].Billing_County__c = 'Bergen';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();    
        update accsAddrs.accs;
        
        //Added extra space and updated casing
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].Billing_County__c = 'bergen ';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();    
        update accsAddrs.accs;
        
        //Whitespace and casing should not count as a real edit
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = ' direct street  edit ';  
            accsAddrs.accs[i].BillingState = 'Oregon';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();    
        update accsAddrs.accs;
        
        //Only change casing 
        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();    
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = ' DIRECT STREET  EDIT ';  
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update accsAddrs.accs;
        Test.stopTest();
        
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, BillingStreet, Current_Address__c 
                                                                FROM Account]);
        for (Account acc : accountsById.values()) {
            System.assert(acc.BillingStreet.equals('DIRECT STREET  EDIT'));
            System.assertNotEquals(Null, acc.Current_Address__c);
        }

        //Verify that no new Address record was created
        List<Address__c> returnAddrList = [SELECT Id, Default_Address__c, MailingStreet__c, Parent_Account__c 
                                            FROM Address__c 
                                            WHERE Parent_Account__c IN :accsAddrs.accs];
        System.assertEquals(2, returnAddrList.size());
        for (Address__c addr : returnAddrList) {
            System.assert(addr.MailingStreet__c.equals('DIRECT STREET  EDIT'));
        }
        
        //Test that changing the case from the account updates all addresses
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            Account acc = accsAddrs.accs[i];
            acc.BillingStreet = 'direct street  edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();    
        update accsAddrs.accs;
        
        //Verify the billing address Account fields
        accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, Current_Address__c 
                                                FROM Account]);
        for (Account acc : accountsById.values()) {
            System.assert(acc.BillingStreet.equals('direct street  edit'));
            System.assertNotEquals(Null, acc.Current_Address__c);
        }

        //Verify that no new address was created
        returnAddrList = [SELECT Id, Default_Address__c, MailingStreet__c
                            FROM Address__c];
        System.assertEquals(2, returnAddrList.size());
        for (Address__c addr : returnAddrList) {
            System.assert(addr.MailingStreet__c.equals('direct street  edit'));
        }                   
    }

    /*********************************************************************************************************
    @description Create an Address with no Account or Contact parent record. 
    * Verify: 
    * - Runtime error. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNewAddressWithoutParentRecord() {
        configSettings();
        
        List<Address__c> addrList = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        for (Integer i = 0; i < addrList.size(); i++) {
            System.assertEquals(Null, addrList[i].Parent_Account__c);
        }
        
        try {
            insert addrList;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(Label.addrValidParentObjects));
            return;
        }
        System.assert(False);
    }
 
    /*********************************************************************************************************
    @description Account's billing address fields are updated with existing Address record's mailing fields. 
    * Verify:
    * - No new duplicate Address records are created. 
    **********************************************************************************************************/            
    @isTest
    private static void updateAdminAccountBillingFieldsWithDuplicateValues() {
        configSettings();
            
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> addrList = accsAddrs.addrs;
        
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = addrList[i].MailingStreet__c;
            accsAddrs.accs[i].BillingCity = addrList[i].MailingCity__c;
            accsAddrs.accs[i].Billing_County__c = addrList[i].MailingCounty__c;
            accsAddrs.accs[i].BillingState = addrList[i].MailingState__c;
            accsAddrs.accs[i].BillingPostalCode = addrList[i].MailingPostalCode__c;
            accsAddrs.accs[i].BillingCountry = addrList[i].MailingCountry__c;
        }     
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update accsAddrs.accs;
        Test.stopTest();
        
        //Verify that we don't have new Addresses
        List<Address__c> returnAddrList = [SELECT Id 
                                            FROM Address__c];
        System.assertEquals(2, returnAddrList.size());
    }

    /*********************************************************************************************************
    @description Account has an existing default Address record. Create new non default Address record. Update 
    * Account's billing address fields to match the mailing fields from the new non default Address record. 
    * Verify:
    * - New non default Address record was created when a new none duplicate Address is inserted.  
    * - The new non default Address record is now set as the default Address record when the Account's billing 
    * address fields were updated to match the mailing fields from the new Address record. This did not create 
    * an additional duplicate Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void updateAdminAccountBillingFieldsWithNonDefaultAddressMailingFields() {
        configSettings();
        
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> addrList = accsAddrs.addrs;
        
        addrList = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            addrList[i].Parent_Account__c = accsAddrs.accs[i].Id;
            addrList[i].Default_Address__c = False;
            addrList[i].MailingStreet__c = 'New Street' + i;
            addrList[i].MailingCity__c = 'New City' + i;
            addrList[i].MailingCounty__c = 'New County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert addrList;
        
        List<Address__c> numOfAddrs = [SELECT Id 
                                        FROM Address__c]; 
        System.assertEquals(4, numOfAddrs.size()); 
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = addrList[i].MailingStreet__c;
            accsAddrs.accs[i].BillingCity = addrList[i].MailingCity__c;
            accsAddrs.accs[i].Billing_County__c = addrList[i].MailingCounty__c;
            accsAddrs.accs[i].BillingState = addrList[i].MailingState__c;
            accsAddrs.accs[i].BillingPostalCode = addrList[i].MailingPostalCode__c;
            accsAddrs.accs[i].BillingCountry = addrList[i].MailingCountry__c;
        }        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update accsAddrs.accs;
        Test.stopTest();
        
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, Current_Address__c 
                                                                FROM Account]);
        for (Account acc : accountsById.values()) {
            System.assert(acc.BillingStreet.contains('New Street'));
            System.assert(acc.BillingCity.contains('New City'));
            System.assert(acc.Billing_County__c.contains('New County'));
            System.assertNotEquals(Null, acc.Current_Address__c);
        }
        
        List<Address__c> allAddrsList = [SELECT Id, Default_Address__c, MailingStreet__c
                                            FROM Address__c];
        System.assertEquals(4, allAddrsList.size());
        for (Address__c addr : allAddrsList) {
            if (addr.MailingStreet__c.contains('New Street')) {
                System.assertEquals(True, addr.Default_Address__c);
            }
        }
    }

    /*********************************************************************************************************
    @description New Account is created and its billing address fields are filled out - specifically filling out 
    * BillingStreet field with multiline street value. 
    * Verify: 
    * - New default Address record and multiline street value is populated to MailingStreet__c and MailingStreet2__c.
    **********************************************************************************************************/            
    @isTest
    private static void updateAdminAccountBillingStreetWithMultilineStreetValue() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Accounts_Addresses_Enabled__c = 
                                                                    UTIL_Describe.getCustomAdminAccRecTypeID() + ';'));

        List<Account> accList = UTIL_UnitTestData_API.getMultipleTestAccounts(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        for (Account acc : accList) {
            acc.BillingStreet = 'new street\r\nsecond line';
            acc.BillingCity = 'new city';
        } 
        Test.startTest();
        insert accList; 
        Test.stopTest();       
        
        //Verify MailingStreet__c and MailingStreet2__c fields on Address record are populated
        List<Address__c> returnAddrList = [SELECT Id, MailingStreet__c, MailingStreet2__c, 
                                            Formula_MailingStreetAddress__c, Default_Address__c
                                            FROM Address__c];
        System.assertEquals(2, returnAddrList.size());
        for (Address__c addr : returnAddrList) {
            System.assertEquals('new street', addr.MailingStreet__c);
            System.assertEquals('second line', addr.MailingStreet2__c);
            System.assertEquals(True, addr.Default_Address__c);
            System.assertEquals('new street<br>second line<br>new city,', addr.Formula_MailingStreetAddress__c);
        }

        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                Current_Address__c 
                                                                FROM Account]);
        for (Account acc : accountsById.values()) {
            System.assertEquals('new street\r\nsecond line', acc.BillingStreet);
            System.assertNotEquals(Null, acc.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Account has an existing default Address record. A new default Address record with multi street
    * line is created for the Account record. 
    * Verify: 
    * - Account is updated properly where MailingStreet__c and MailingStreet2__c
    * from the new default Address record is set to the billing street field on the Account record. 
    * - The new default Address record is now set as the Current_Address__c on the Account record and its billing
    * address fields are updated properly. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNewDefaultMultilineStreetAddressOnExistingAccWithExistingDefaultAddress() {
        configSettings();
                
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        List<Address__c> addrList = accsAddrs.addrs;
        
        addrList = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            addrList[i].Parent_Account__c = accsAddrs.accs[i].Id;
            addrList[i].Default_Address__c = True;
            addrList[i].MailingStreet__c = 'New Default Street';
            addrList[i].MailingStreet2__c = 'Second Line';
            addrList[i].MailingCity__c = 'New Default City' + i;
            addrList[i].MailingCounty__c = 'New Default County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert addrList;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();        
        Test.stopTest();
        
        Map<Id, Account> accIdByAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet
                                                                FROM Account]);
        for (Account acc : accIdByAcc.values()) {
            System.assertEquals('New Default Street\r\nSecond Line', acc.BillingStreet);
        }
    }

    /*********************************************************************************************************
    @description Account's billing fields are cleared. 
    * Verify: 
    * - No new Address records are created. 
    * - Account's billing fields and Current_Address__c are blank. 
    * - The existing Address records are no longer set as default Address records. 
    **********************************************************************************************************/            
    @isTest
    private static void clearAdminAccountBillingFields() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Accounts_Addresses_Enabled__c = 
                                                                    UTIL_Describe.getCustomAdminAccRecTypeID() + ';'));
                
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(4, UTIL_Describe.getCustomAdminAccRecTypeID());
        
        List<Address__c> addrList = accsAddrs.addrs;
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = Null;
            accsAddrs.accs[i].BillingCity = Null;
            accsAddrs.accs[i].Billing_County__c = Null;
            accsAddrs.accs[i].BillingState = Null;
            accsAddrs.accs[i].BillingPostalCode = Null;
            accsAddrs.accs[i].BillingCountry = Null;
            if (ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled) {
                accsAddrs.accs[i].put('BillingStateCode', Null);
                accsAddrs.accs[i].put('BillingCountryCode', Null);
            }             
        }

        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update accsAddrs.accs;
        Test.stopTest();
        
        addrList = [SELECT Default_Address__c 
                    FROM Address__c];
        System.assertEquals(4, addrList.size());
        //Verify existing default Address record is updated to be non-default
        for (Integer i = 0; i < addrList.size(); i++) {
            System.assertEquals(False, addrList[i].Default_Address__c);
        }            
        
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, Current_Address__c 
                                                                FROM Account]);
        for (Account acc : accountsById.values()) {
            System.assertEquals(Null, acc.Current_Address__c);
        }
    }
}