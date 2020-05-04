/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group Addresses
* @group-content ../../ApexDocContent/Addresses.htm
* @description Tests for ADDR_CannotDelete_TDTM.
*/

@isTest
private class ADDR_CannotDelete_TEST {
    /*********************************************************************************************************
    * @description Retrieves the record type Ids for Household and Administrator Accounts. 
    */
    public static String hhAccRecordTypeID = UTIL_Describe.getHhAccRecTypeID(); 
    public static String adminAccRecordTypeID = UTIL_Describe.getAdminAccRecTypeID();

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Address_Deletion__c is enabled in Hierarchy Settings, and
    * Address has a child Account record associated to it, the Address record cannot be deleted.
    */
    @isTest 
    private static void cannotDeleteWithAccount() {
                
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Account_Processor__c = ADDR_CannotDelete_TEST.hhAccRecordTypeID,
                                                            Prevent_Address_Deletion__c = TRUE));

        UTIL_UnitTestData_TEST.AccsWithAddrs addrsWithRelatedAcc = UTIL_UnitTestData_TEST.createTestAccsAddrs(5, ADDR_CannotDelete_TEST.hhAccRecordTypeID);

        List<Address__c> addrsWithChildAccount = addrsWithRelatedAcc.addrs; 
        
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(addrsWithChildAccount, FALSE);
        Test.stopTest();

        List<Address__c> returnAddresses = [
            SELECT Id
            FROM Address__c
            WHERE Id IN :addrsWithChildAccount
        ];

        System.assertEquals(addrsWithChildAccount.size(), returnAddresses.size());

        for (Database.DeleteResult result : results) {
            System.assertEquals(Label.CannotDelete, result.errors[0].message);
        }
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Address_Deletion__c is enabled in Hierarchy Settings, and
    * Address has a child Contact record associated to it, the Address record cannot be deleted.
    */
    @isTest
    private static void cannotDeleteWithContact() { 
                
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Prevent_Address_Deletion__c = TRUE));

        UTIL_UnitTestData_TEST.ContactsWithAddrs addrsWithRelatedContact = UTIL_UnitTestData_TEST.createTestContactsAddrs(5);

        List<Address__c> addrsWithChildContact = addrsWithRelatedContact.addrs; 

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(addrsWithChildContact, FALSE);
        Test.stopTest();

        List<Address__c> returnAddresses = [
            SELECT Id
            FROM Address__c
            WHERE Id IN :addrsWithChildContact
        ];

        System.assertEquals(addrsWithChildContact.size(), returnAddresses.size());

        for (Database.DeleteResult result : results) {
            System.assertEquals(Label.CannotDelete, result.errors[0].message);
        }
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Address_Deletion__c is enabled in Hierarchy Settings, and
    * Address has both Account and Contact child records associated to it, the Address record cannot be deleted.
    */
    @isTest 
    private static void cannotDeleteWithAccountAndContact() {
                
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Account_Processor__c = ADDR_CannotDelete_TEST.hhAccRecordTypeID,
                                                            Prevent_Address_Deletion__c = TRUE));

        UTIL_UnitTestData_TEST.AccsWithAddrs addrsWithRelatedAcc = UTIL_UnitTestData_TEST.createTestAccsAddrs(5, ADDR_CannotDelete_TEST.hhAccRecordTypeID);
        UTIL_UnitTestData_TEST.ContactsWithAddrs addrsWithRelatedContact = UTIL_UnitTestData_TEST.createTestContactsAddrs(5);

        List<Address__c> addrsWithChildRecords = new List<Address__c>();
        addrsWithChildRecords.addAll(addrsWithRelatedAcc.addrs); 
        addrsWithChildRecords.addAll(addrsWithRelatedContact.addrs);
        
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(addrsWithChildRecords, FALSE);
        Test.stopTest();

        List<Address__c> returnAddresses = [
            SELECT Id
            FROM Address__c
            WHERE Id IN :addrsWithChildRecords
        ];

        System.assertEquals(addrsWithChildRecords.size(), returnAddresses.size());

        for (Database.DeleteResult result : results) {
            System.assertEquals(Label.CannotDelete, result.errors[0].message);
        }
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Address_Deletion__c is disabled in Hierarchy Settings, 
    * and Address has a child Account record associated to it, the Address record can be deleted.
    */
    @isTest
    private static void canDeleteWithAccount() {
                
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Account_Processor__c = ADDR_CannotDelete_TEST.adminAccRecordTypeID,
                                                            Prevent_Address_Deletion__c = FALSE));

        UTIL_UnitTestData_TEST.AccsWithAddrs addrsWithRelatedAcc = UTIL_UnitTestData_TEST.createTestAccsAddrs(5, ADDR_CannotDelete_TEST.adminAccRecordTypeID);

        List<Address__c> addrsWithChildAccount = addrsWithRelatedAcc.addrs; 

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(addrsWithChildAccount, FALSE);
        Test.stopTest();

        List<Address__c> returnAddresses = [
            SELECT Id
            FROM Address__c
            WHERE Id IN :addrsWithChildAccount];

        System.assertEquals(TRUE, returnAddresses.isEmpty());

        for (Database.DeleteResult result : results) {
            System.assertEquals(TRUE, result.isSuccess());
        }
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Address_Deletion__c is disabled in Hierarchy Settings, 
    * and Address has a child Contact record associated to it, the Address record can be deleted.
    */
    @isTest
    private static void canDeleteWithContact() {
        
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Prevent_Address_Deletion__c = FALSE));

        UTIL_UnitTestData_TEST.ContactsWithAddrs addrsWithRelatedContact = UTIL_UnitTestData_TEST.createTestContactsAddrs(5);

        List<Address__c> addrsWithChildContact = addrsWithRelatedContact.addrs; 
        
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(addrsWithChildContact, FALSE);
        Test.stopTest();

        List<Address__c> returnAddresses = [
            SELECT Id
            FROM Address__c
            WHERE Id IN :addrsWithChildContact
        ];

        System.assertEquals(TRUE, returnAddresses.isEmpty());

        for (Database.DeleteResult result : results) {
            System.assertEquals(TRUE, result.isSuccess());
        }
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Address_Deletion__c is disabled in Hierarchy Settings,
    * and Address has both Account and Contact child records associated to it, the Address record can be deleted.
    */
    @isTest 
    private static void canDeleteWithAccountAndContact() {
                
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Account_Processor__c = ADDR_CannotDelete_TEST.hhAccRecordTypeID,
                                                            Prevent_Address_Deletion__c = FALSE));

        UTIL_UnitTestData_TEST.AccsWithAddrs addrsWithRelatedAcc = UTIL_UnitTestData_TEST.createTestAccsAddrs(5, ADDR_CannotDelete_TEST.hhAccRecordTypeID);
        UTIL_UnitTestData_TEST.ContactsWithAddrs addrsWithRelatedContact = UTIL_UnitTestData_TEST.createTestContactsAddrs(5);

        List<Address__c> addrsWithChildRecords = new List<Address__c>();
        addrsWithChildRecords.addAll(addrsWithRelatedAcc.addrs); 
        addrsWithChildRecords.addAll(addrsWithRelatedContact.addrs);
        
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(addrsWithChildRecords, FALSE);
        Test.stopTest();

        List<Address__c> returnAddresses = [
            SELECT Id
            FROM Address__c
            WHERE Id IN :addrsWithChildRecords
        ];

        System.assertEquals(TRUE, returnAddresses.isEmpty());

        for (Database.DeleteResult result : results) {
            System.assertEquals(TRUE, result.isSuccess());
        }
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Address_Deletion__c is enabled in Hierarchy Settings, 
    * and Address does not have a child Account or Contact record associated to it, the Address record can be deleted.
    */
    @isTest
    private static void canDeleteWithoutChildrenPreventDeleteOn() {
                
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Account_Processor__c = ADDR_CannotDelete_TEST.adminAccRecordTypeID,
                                                            Prevent_Address_Deletion__c = TRUE));

        
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, ADDR_CannotDelete_TEST.adminAccRecordTypeID);
        insert accounts;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(1);
        insert contacts;

        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(6);

        for (Integer index = 0; index < 3; index++) {
            addresses[index].Parent_Account__c = accounts[0].Id;
        }

        for (Integer index = 3; index < 6; index++) {
            addresses[index].Parent_Contact__c = contacts[0].Id;
        }
        
        insert addresses;
        
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(addresses, FALSE);
        Test.stopTest();

        List<Address__c> returnAddresses = [
            SELECT Id
            FROM Address__c
            WHERE Id IN :addresses
        ];

        System.assertEquals(TRUE, returnAddresses.isEmpty());

        for (Database.DeleteResult result : results) {
            System.assertEquals(TRUE, result.isSuccess());
        }
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Address_Deletion__c is disabled in Hierarchy Settings, 
    * and Address does not have a child Account or Contact record associated to it, the Address record can be deleted.
    */
    @isTest
    private static void canDeleteWithoutChildrenPreventDeleteOff() {
            
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Account_Processor__c = ADDR_CannotDelete_TEST.hhAccRecordTypeID,
                                                            Prevent_Address_Deletion__c = FALSE));

        
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, ADDR_CannotDelete_TEST.hhAccRecordTypeID);
        insert accounts;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(1);
        insert contacts;

        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(6);

        for (Integer index = 0; index < 3; index++) {
            addresses[index].Parent_Account__c = accounts[0].Id;
        }

        for (Integer index = 3; index < 6; index++) {
            addresses[index].Parent_Contact__c = contacts[0].Id;
        }
        
        insert addresses;
        
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(addresses, FALSE);
        Test.stopTest();

        List<Address__c> returnAddresses = [
            SELECT Id
            FROM Address__c
            WHERE Id IN :addresses
        ];

        System.assertEquals(TRUE, returnAddresses.isEmpty());

        for (Database.DeleteResult result : results) {
            System.assertEquals(TRUE, result.isSuccess());
        }
    }

    /*********************************************************************************************************
    * @description Test method for the hasChildRecords() method in ADDR_CannotDelete_TDTM to test that TRUE is
    * returned when an Address record has child records of only type Contact.
    */
    @isTest
    private static void hasChildContactRecordsIsTrue() {

        UTIL_UnitTestData_TEST.ContactsWithAddrs addrsWithRelatedContact = UTIL_UnitTestData_TEST.createTestContactsAddrs(5);

        List<Address__c> addrsWithChildContact = addrsWithRelatedContact.addrs; 

        List<Address__c> returnAddresses = [
            SELECT Id, 
                (SELECT Id FROM Address__c.Contacts1__r)
            FROM Address__c
            WHERE Id IN :addrsWithChildContact
        ];

        ADDR_CannotDelete_TDTM addrCannotDeleteClass = new ADDR_CannotDelete_TDTM();

        for (Address__c addr : returnAddresses) {
            System.assertEquals(TRUE, addrCannotDeleteClass.hasChildRecords(addr));
        }
    }

    /*********************************************************************************************************
    * @description Test method for the hasChildRecords() method in ADDR_CannotDelete_TDTM to test that TRUE is
    * returned when an Address record has child records of only type Account.
    */
    @isTest
    private static void hasChildAccountRecordsIsTrue() {

        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Account_Processor__c = ADDR_CannotDelete_TEST.hhAccRecordTypeID));

        UTIL_UnitTestData_TEST.AccsWithAddrs addrsWithRelatedAcc = UTIL_UnitTestData_TEST.createTestAccsAddrs(5, ADDR_CannotDelete_TEST.hhAccRecordTypeID);
        
        List<Address__c> addrsWithChildAcc = addrsWithRelatedAcc.addrs; 

        List<Address__c> returnAddresses = [
            SELECT Id, 
                (SELECT Id FROM Address__c.Accounts__r)
            FROM Address__c
            WHERE Id IN :addrsWithChildAcc
        ];

        ADDR_CannotDelete_TDTM addrCannotDeleteClass = new ADDR_CannotDelete_TDTM();

        for (Address__c addr : returnAddresses) {
            System.assertEquals(TRUE, addrCannotDeleteClass.hasChildRecords(addr));
        }
    }

    /*********************************************************************************************************
    * @description Test method for the hasChildRecords() method in ADDR_CannotDelete_TDTM to test that TRUE is
    * returned when an Address record has both Contact and Account child records.
    */
    @isTest
    private static void hasChildContactAndAccountRecordsIsTrue() {

        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Account_Processor__c = ADDR_CannotDelete_TEST.hhAccRecordTypeID));

        UTIL_UnitTestData_TEST.AccsWithAddrs addrsWithRelatedAcc = UTIL_UnitTestData_TEST.createTestAccsAddrs(5, ADDR_CannotDelete_TEST.hhAccRecordTypeID);
        UTIL_UnitTestData_TEST.ContactsWithAddrs addrsWithRelatedContact = UTIL_UnitTestData_TEST.createTestContactsAddrs(5);

        List<Address__c> addrsWithChildRecords = new List<Address__c>();
        addrsWithChildRecords.addAll(addrsWithRelatedAcc.addrs); 
        addrsWithChildRecords.addAll(addrsWithRelatedContact.addrs);

        List<Address__c> returnAddresses = [
            SELECT Id, 
                (SELECT Id FROM Address__c.Contacts1__r),
                (SELECT Id FROM Address__c.Accounts__r)
            FROM Address__c
            WHERE Id IN :addrsWithChildRecords
        ];

        ADDR_CannotDelete_TDTM addrCannotDeleteClass = new ADDR_CannotDelete_TDTM();
        
        for (Address__c addr : returnAddresses) {
            System.assertEquals(TRUE, addrCannotDeleteClass.hasChildRecords(addr));
        }
    }

    /*********************************************************************************************************
    * @description Test method for the hasChildRecords() method in ADDR_CannotDelete_TDTM to test that FALSE
    * is returned for an Address record with no child records.
    */
    @isTest
    private static void hasChildRecordsIsFalse() {

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(1);
        insert contacts;

        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(5);

        for (Integer index = 0; index < 5; index++) {
            addresses[index].Parent_Contact__c = contacts[0].Id;
        }
        
        insert addresses;

        List<Address__c> returnAddresses = [
            SELECT Id, 
                (SELECT Id FROM Address__c.Contacts1__r)
            FROM Address__c
            WHERE Id IN :addresses
        ];

        ADDR_CannotDelete_TDTM addrCannotDeleteClass = new ADDR_CannotDelete_TDTM();

        for (Address__c addr : returnAddresses) {
            System.assertEquals(FALSE, addrCannotDeleteClass.hasChildRecords(addr));
        }
    }
}
