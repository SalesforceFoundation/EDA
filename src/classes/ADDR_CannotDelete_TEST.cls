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
    private static void addrCannotDeleteWithAccount() {
                
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
    private static void addrCannotDeleteWithContact() { 
                
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
    * @description Test method to test that when Prevent_Address_Deletion__c is disabled in Hierarchy Settings, 
    * and Address has a child Account record associated to it, the Address record can be deleted.
    */
    @isTest
    private static void addrCanDeleteWithAccount() {
                
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

        System.assert(returnAddresses.isEmpty());

        for (Database.DeleteResult result : results) {
            System.assertEquals(TRUE, result.isSuccess());
        }
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Address_Deletion__c is disabled in Hierarchy Settings, 
    * and Address has a child Contact record associated to it, the Address record can be deleted.
    */
    @isTest
    private static void addrCanDeleteWithContact() {
        
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

        
        System.assert(returnAddresses.isEmpty());

        for (Database.DeleteResult result : results) {
            System.assertEquals(TRUE, result.isSuccess());
        }
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Address_Deletion__c is enabled in Hierarchy Settings, 
    * and Address does not have a child Account or Contact record associated to it, the Address record can be deleted.
    */
    @isTest
    private static void addressCanDeleteWithoutChildrenPreventDeleteOn() {
                
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

        System.assert(returnAddresses.isEmpty());

        for (Database.DeleteResult result : results) {
            System.assertEquals(TRUE, result.isSuccess());
        }
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Address_Deletion__c is disabled in Hierarchy Settings, 
    * and Address does not have a child Account or Contact record associated to it, the Address record can be deleted.
    */
    @isTest
    private static void addressCanDeleteWithoutChildrenPreventDeleteOff() {
            
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

        System.assert(returnAddresses.isEmpty());

        for (Database.DeleteResult result : results) {
            System.assertEquals(TRUE, result.isSuccess());
        }
    }
}
