/*
    Copyright (c) 2020, Salesforce.org
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
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
* @group 
* @group-content ../../ApexDocContent/
* @description Test class for SRVC_UniqueRecord
*/
@isTest
private class SRVC_UniqueRecord_TEST {

    private static Id generateFakeAccountId() {
        return UTIL_UnitTestData_Test.getFakeId(Account.SObjectType);
    }

    private static Id generateFakeContactId() {  
        return UTIL_UnitTestData_Test.getFakeId(Contact.SObjectType);
    }

    // Tests getInstance()
    @isTest
    static void testGetInstance() {
        SRVC_UniqueRecord srvcUniqueRecordInstance = SRVC_UniqueRecord.getInstance();
        System.assertEquals(SRVC_UniqueRecord.instance, srvcUniqueRecordInstance);
        System.assertNotEquals(NULL, srvcUniqueRecordInstance);

        srvcUniqueRecordInstance = SRVC_UniqueRecord.getInstance();
        System.assertEquals(SRVC_UniqueRecord.instance, srvcUniqueRecordInstance);
    }

    // NULL test for Unique Record Functionality
    @isTest
    private static void getUniqueRecordsNULLTest() {

        Test.startTest();
            List<SObject> uniqueList = SRVC_UniqueRecord.getInstance().getUniqueRecords(NULL);
        Test.stopTest();

        // Ensure empty list is returned
        System.assertEquals(NULL, uniqueList);
    }

    // Empty List test for Unique Record Functionality
    @isTest
    private static void getUniqueRecordsEmptyTest() {

        Test.startTest();
            List<Account> accounts = new List<Account>();
            List<SObject> uniqueList = SRVC_UniqueRecord.getInstance().getUniqueRecords(accounts);
        Test.stopTest();

        // Ensure empty list is returned
        System.assertEquals(0, uniqueList.size());

    }

    // Test Unique Record Functionality with list size one
    @isTest
    private static void getUniqueRecordsSingleRecordTest() {

        List<Account> testAccounts = new List<Account>();

        Account testAccount = new Account();
        testAccount.Id = SRVC_UniqueRecord_TEST.generateFakeAccountId();
        testAccount.Name = 'test unique Service';

        testAccounts.add(testAccount);

        Test.startTest();
            List<SObject> uniqueList = SRVC_UniqueRecord.getInstance().getUniqueRecords(testAccounts);
        Test.stopTest();

        // Ensure the list is returned
        System.assertEquals(1, uniqueList.size());
    }

    // Test for Unique Record Functionality with no record ids
    @isTest
    private static void uniqueRecordFunctionalityWithNoIdsTest() {

        List<SObject> duplicateList = new List<SObject>();

        Contact duplicateCon1 = new Contact();
        duplicateCon1.firstName = 'Doe';

        Contact duplicateCon2 = new Contact();
        duplicateCon2.lastName = 'Night';

        Contact duplicateCon3 = new Contact();
        duplicateCon3.HIPAA__c = TRUE;

        duplicateList.add(duplicateCon1);
        duplicateList.add(duplicateCon2);
        duplicateList.add(duplicateCon3);

        System.assertEquals(3, duplicateList.size());

        Test.startTest();
            List<SObject> uniqueList = SRVC_UniqueRecord.getInstance().getUniqueRecords(duplicateList);
        Test.stopTest();

        // Ensure records are not merged
        System.assertEquals(3, uniqueList.size());
    }
 
    // Test for Unique Record Functionality with a records having Ids and a few not having Ids
    @isTest
    private static void uniqueRecordFunctionalityIdsTest() {

        List<SObject> duplicateList = new List<SObject>();

        Contact duplicateCon1 = new Contact();
        duplicateCon1.Id = SRVC_UniqueRecord_TEST.generateFakeContactId();
        duplicateCon1.firstName = 'Doe';

        Contact duplicateCon2 = new Contact();
        duplicateCon2.Id = duplicateCon1.Id;
        duplicateCon2.lastName = 'Night';

        Contact duplicateCon3 = new Contact();
        duplicateCon3.HIPAA__c = TRUE;
        
        Contact duplicateCon4 = new Contact();
        duplicateCon4.FERPA__c = TRUE;

        duplicateList.add(duplicateCon1);
        duplicateList.add(duplicateCon2);
        duplicateList.add(duplicateCon3);
        duplicateList.add(duplicateCon4);

        System.assertEquals(4, duplicateList.size());

        Test.startTest();
            List<SObject> uniqueList = SRVC_UniqueRecord.getInstance().getUniqueRecords(duplicateList);
        Test.stopTest();

        // Ensure only 2 are merged
        System.assertEquals(3, uniqueList.size());
    }
    
    // Test for Unique Record Functionality with a record having Ids and a 2 records not having Ids
    @isTest
    private static void uniqueRecordFunctionalityIds2Test() {

        List<SObject> duplicateList = new List<SObject>();

        Contact duplicateCon1 = new Contact();
        duplicateCon1.Id = SRVC_UniqueRecord_TEST.generateFakeContactId();
        duplicateCon1.firstName = 'Doe';

        Contact duplicateCon2 = new Contact();
        duplicateCon2.HIPAA__c = TRUE;

        Contact duplicateCon3 = new Contact();
        duplicateCon3.FERPA__c = TRUE;

        duplicateList.add(duplicateCon1);
        duplicateList.add(duplicateCon2);
        duplicateList.add(duplicateCon3);

        System.assertEquals(3, duplicateList.size());

        Test.startTest();
            List<SObject> uniqueList = SRVC_UniqueRecord.getInstance().getUniqueRecords(duplicateList);

        Test.stopTest();

        // Ensure no records are merged
        System.assertEquals(3, uniqueList.size());
    }

    // Test for Unique Record Functionality
    @isTest
    private static void uniqueRecordFunctionalityWithNoRelatedRecordsTest() {

        Id testContactId = SRVC_UniqueRecord_TEST.generateFakeContactId();

        List<SObject> duplicateList = new List<SObject>();

        Contact duplicateCon1 = new Contact();
        duplicateCon1.Id = testContactId;
        duplicateCon1.firstName = 'Doe';

        Contact duplicateCon2 = new Contact();
        duplicateCon2.Id = testContactId;
        duplicateCon2.lastName = 'Night';

        Contact duplicateCon3 = new Contact();
        duplicateCon3.Id = testContactId;
        duplicateCon3.HIPAA__c = TRUE;

        duplicateList.add(duplicateCon1);
        duplicateList.add(duplicateCon2);
        duplicateList.add(duplicateCon3);

        System.assertEquals(3, duplicateList.size());

        Test.startTest();
            List<SObject> uniqueList = SRVC_UniqueRecord.getInstance().getUniqueRecords(duplicateList);
        Test.stopTest();

        // Ensure records are merged
        System.assertEquals(1, uniqueList.size());

        Contact uniqueContact = (Contact)uniqueList[0];

        System.assertEquals('Doe', uniqueContact.firstName);
        System.assertEquals('Night', uniqueContact.lastName);
        System.assertEquals(TRUE, uniqueContact.HIPAA__c);
    }

    // Test for Unique Record Functionality with related records
    @isTest
    private static void uniqueRecordFunctionalityWithRelatedRecordsTest() {

        Contact testContact = UTIL_UnitTestData_TEST.getContact();
        testContact.HIPAA__c = TRUE;
        insert testContact;

        List<SObject> duplicateList = new List<SObject>();

        Account parentAccount = [SELECT Id, (SELECT Id, HIPAA__c FROM Contacts) FROM Account];
        System.assert(parentAccount.Contacts != NULL);
        System.assertEquals(TRUE, parentAccount.Contacts[0].HIPAA__c);

        Account duplicateAccount1 = new Account();
        duplicateAccount1.Id = parentAccount.Id;
        duplicateAccount1.Phone = '123';
        duplicateList.add(duplicateAccount1);

        Account duplicateAccount2 = new Account();
        duplicateAccount2.Id = parentAccount.Id;
        duplicateAccount2.website = '123@sf.com';
        duplicateList.add(duplicateAccount2);

        Account duplicateAccount3 = new Account();
        duplicateAccount3.Id = parentAccount.Id;
        duplicateAccount3.description = 'test description';
        duplicateList.add(duplicateAccount3);

        System.assertEquals(3, duplicateList.size());
        Test.startTest();
            List<SObject> uniqueList = SRVC_UniqueRecord.getInstance().getUniqueRecords(duplicateList);
        Test.stopTest();

        // Ensure records are merged
        System.assertEquals(1, uniqueList.size());

        Account uniqueAccount = (Account)uniqueList[0];

        System.assertEquals(parentAccount.Id, uniqueAccount.Id);
        System.assertEquals('test description', uniqueAccount.description);
        System.assertEquals('123@sf.com', uniqueAccount.website);
        System.assertEquals('123', uniqueAccount.Phone);

    }
    
    // Test for Unique Record Functionality with multiple SOBJect types
    @isTest
    private static void uniqueRecordFunctionalityWithMultipleSObjectTypesTest() {

        Id testContactId = SRVC_UniqueRecord_TEST.generateFakeContactId();
        Id testAccountId = SRVC_UniqueRecord_TEST.generateFakeAccountId();

        List<SObject> duplicateList = new List<SObject>();

        Contact duplicateCon1 = new Contact();
        duplicateCon1.Id = testContactId;
        duplicateCon1.firstName = 'Doe';

        Contact duplicateCon2 = new Contact();
        duplicateCon2.Id = testContactId;
        duplicateCon2.lastName = 'Night';

        Contact duplicateCon3 = new Contact();
        duplicateCon3.Id = testContactId;
        duplicateCon3.HIPAA__c = TRUE;

        Account duplicateAccount1 = new Account();
        duplicateAccount1.Id = testAccountId;
        duplicateAccount1.Name = 'test unique Service';

        Account duplicateAccount2 = new Account();
        duplicateAccount2.Id = testAccountId;
        duplicateAccount2.Description = 'test description';

        Account duplicateAccount3 = new Account();
        duplicateAccount3.Id = testAccountId;
        duplicateAccount3.Website = 'www.test@sf.com';

        duplicateList.add(duplicateCon1);
        duplicateList.add(duplicateCon2);
        duplicateList.add(duplicateCon3);
        duplicateList.add(duplicateAccount1);
        duplicateList.add(duplicateAccount2);
        duplicateList.add(duplicateAccount3);

        System.assertEquals(6, duplicateList.size());
        Test.startTest();
            List<SObject> uniqueList = SRVC_UniqueRecord.getInstance().getUniqueRecords(duplicateList);
        Test.stopTest();

        System.assertEquals(2, uniqueList.size());
    }

    // Test for Unique Record Functionality with related records
    @isTest
    private static void filterRecordsForIdsTest() {

        List<SObject> duplicateList = new List<SObject>();

        Contact duplicateCon1 = new Contact();
        duplicateCon1.Id = SRVC_UniqueRecord_TEST.generateFakeContactId();
        duplicateCon1.firstName = 'Doe';

        Contact duplicateCon2 = new Contact();
        duplicateCon2.Id = duplicateCon1.Id;
        duplicateCon2.lastName = 'Night';

        Contact duplicateCon3 = new Contact();
        duplicateCon3.HIPAA__c = TRUE;

        Contact duplicateCon4 = new Contact();
        duplicateCon4.FERPA__c = TRUE;

        duplicateList.add(duplicateCon1);
        duplicateList.add(duplicateCon2);
        duplicateList.add(duplicateCon3);
        duplicateList.add(duplicateCon4);

        Test.startTest();
            Map<SRVC_UniqueRecord.KEYS, List<SObject>> returnMap = SRVC_UniqueRecord.getInstance().filterRecordsForIds(duplicateList);
        Test.stopTest();

        System.assert(returnMap.get(SRVC_UniqueRecord.KEYS.WITHIDS).size() == 2);
        System.assert(returnMap.get(SRVC_UniqueRecord.KEYS.WITHOUTIDS).size() == 2);
    }

    // Test for Unique Record Functionality with related records
    @isTest
    private static void combineRecordsTest() {

        Contact testContact = new Contact();
        testContact.Id = SRVC_UniqueRecord_TEST.generateFakeContactId();
        testContact.firstName = 'Doe';

        SObject sObjectConRecord = testContact.getSObjectType().newSobject(testContact.Id);

        System.assert( ((Contact)sObjectConRecord).firstName == NULL );

        Test.startTest();
            SObject combinedRecord = SRVC_UniqueRecord.getInstance().combineRecords(testContact, sObjectConRecord);
        Test.stopTest();

        System.assert( ((Contact)sObjectConRecord).firstName == 'Doe' );
    }

    // Test for Unique Record Functionality with related records
    @isTest
    private static void getUniqueRecordsByIdsTest() {

        List<SObject> duplicateList = new List<SObject>();

        Contact duplicateCon1 = new Contact();
        duplicateCon1.Id = SRVC_UniqueRecord_TEST.generateFakeContactId();
        duplicateCon1.firstName = 'Doe';

        Contact duplicateCon2 = new Contact();
        duplicateCon2.Id = duplicateCon1.Id;
        duplicateCon2.lastName = 'Night';

        duplicateList.add(duplicateCon1);
        duplicateList.add(duplicateCon2);

        System.assertEquals(2, duplicateList.size());

        Test.startTest();
            List<SObject> combinedRecords = SRVC_UniqueRecord.getInstance().getUniqueRecordsByIds(duplicateList);
        Test.stopTest();

        System.assertEquals(1, combinedRecords.size());
    }

    // Test for Unique Record Functionality with related records
    @isTest
    private static void getUniqueRecordsByIdsWith1RecordTest() {

        List<SObject> duplicateList = new List<SObject>();

        Contact duplicateCon1 = new Contact();
        duplicateCon1.Id = SRVC_UniqueRecord_TEST.generateFakeContactId();
        duplicateCon1.firstName = 'Doe';

        duplicateList.add(duplicateCon1);

        System.assertEquals(1, duplicateList.size());

        Test.startTest();
            List<SObject> combinedRecords = SRVC_UniqueRecord.getInstance().getUniqueRecordsByIds(duplicateList);
        Test.stopTest();

        System.assertEquals(1, combinedRecords.size());
    }

}