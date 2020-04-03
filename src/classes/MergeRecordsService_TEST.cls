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
* @description Test class for MergeRecordsService
*/
@isTest
private class MergeRecordsService_TEST {
    // Test merging of records
    @isTest
    private static void testMergeRecordsMethod() {

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
            List<SObject> mergedList = MergeRecordsService.mergeDuplicateRecords(duplicateList);
        Test.stopTest();
        
        // Ensure records are merged
        System.assertEquals(2, mergedList.size());
        
    }
}