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
    
    // Test for Unique Record Functionlaity
    @isTest
    private static void uniqueRecordFunctionalityTest() {

        Contact testContact1 = UTIL_UnitTestData_TEST.getContact();
        insert testContact1;

        List<SObject> duplicateList = new List<SObject>();

        Contact duplicateCon1 = new Contact();
        duplicateCon1.Id = testContact1.Id;
        duplicateCon1.firstName = 'Doe';
        duplicateList.add(duplicateCon1);
  
        Contact duplicateCon2 = new Contact();
        duplicateCon2.Id = testContact1.Id;
        duplicateCon2.lastName = 'Night';
        duplicateList.add(duplicateCon2);

        Account parentAccount = [SELECT Id from Account];

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

        System.assertEquals(5, duplicateList.size());
        Test.startTest();
            List<SObject> uniqueList = SRVC_UniqueRecord.getUniqueRecords(duplicateList);
        Test.stopTest();
  
        // Ensure records are merged
        System.assertEquals(2, uniqueList.size());

    }

    // NULL test for Unique Record Functionlaity
    @isTest
    private static void getUniqueRecordsEmptyTest() {

        Test.startTest();
            List<SObject> uniqueList = SRVC_UniqueRecord.getUniqueRecords(NULL);
        Test.stopTest();

        // Ensure empty list is returned
        System.assertEquals(0, uniqueList.size());

    }

    // Test Unique Record Functionlaity with list size one
    @isTest
    private static void listSizeOneTest() {

        List<Account> accounts = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getAcademicAccRecTypeID());
        insert accounts;

        Test.startTest();
            List<SObject> uniqueList = SRVC_UniqueRecord.getUniqueRecords(accounts);
        Test.stopTest();

        // Ensure empty list is returned
        System.assertEquals(1, uniqueList.size());
    }
    
    // Test for createIdToSObjectMap method of SRVC_UniqueRecord class
    @isTest
    private static void createIdToSObjectMapTest() {
         List<Account> accounts = UTIL_UnitTestData_API.getMultipleTestAccounts(3, UTIL_Describe_API.getAcademicAccRecTypeID());
         insert accounts;

         Test.startTest();
            Map<Id, SObject> idToNewSObject = SRVC_UniqueRecord.createIdToSObjectMap(accounts);
         Test.stopTest();

         // Ensure map has 3 entries
         System.assertEquals(3, idToNewSObject.size());
    }
    
    // Test for getChildRelationshipNames method of SRVC_UniqueRecord class
    @isTest
    private static void getChildRelationshipNamesTest() {

        Account acc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getAcademicAccRecTypeID())[0];
        insert acc;

        Test.startTest();
            List<String> childRelationshipNames = SRVC_UniqueRecord.getChildRelationshipNames(acc);
        Test.stopTest();

        System.assert(childRelationshipNames.size() != 0);
        System.assert(childRelationshipNames.contains('Contacts'));
    }
    
    // Test for getUniqueRecordList method of SRVC_UniqueRecord class
    @isTest
    private static void getUniqueRecordListTest() {

        Account parentAccount = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getAcademicAccRecTypeID())[0];
        insert parentAccount;

        List<SObject> duplicateList = new List<SObject>();

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

        List<String> childRelationshipNames = SRVC_UniqueRecord.getChildRelationshipNames(duplicateAccount1);
        Map<Id, SObject> idToNewSObject = SRVC_UniqueRecord.createIdToSObjectMap(duplicateList);

       Test.startTest();
            List<SObject> uniqueList = SRVC_UniqueRecord.getUniqueRecordList(duplicateList, childRelationshipNames, idToNewSObject);
       Test.stopTest();

       System.assertEquals(1, uniqueList.size());
        
    }

}