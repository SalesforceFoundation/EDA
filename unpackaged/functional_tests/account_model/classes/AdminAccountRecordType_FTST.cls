/*
    Copyright (c) 2009, Salesforce.org
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
 * @date 2021
 * @group Accounts
 * @description Unmanaged functional tests for Admin Account Record Type
 */

@isTest
 public with sharing class AdminAccountRecordType_FTST {

    private static hed__Hierarchy_Settings__c createSettings() {
        hed__Hierarchy_Settings__c orgSettings = hed.UTIL_CustomSettings_API.getOrgSettings();
        hed.UTIL_CustomSettings_API.getSettingsForTests(orgSettings);
        return orgSettings;
    }


    /**
     * @description T-3904097: When an Account Owner is updated on a Contact with a default Administrative Account Record Type,
     * the Associated Account should update with same Owner.
    */
    @isTest
    private static void test_updateOwnerAccountSync() {
        createSettings();

        // Create a single new User
        User tempUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');

        //Create a Contact
        Contact con = hed.UTIL_UnitTestData_API.getContact();
        insert con;
        con = [SELECT Id, OwnerId, AccountId FROM Contact WHERE Id = :con.Id LIMIT 1];

        Test.startTest();
        con.OwnerId = tempUser.Id;
        update con;
        Test.stopTest();

        System.runAs(tempUser) {
            Account acct = [SELECT Id, OwnerId FROM Account WHERE Id = :con.AccountId LIMIT 1];
            System.assertEquals(
                acct.OwnerId,
                tempUser.Id,
                'The Account owner should be the same as the new Contact Owner'
            );
        }
    }


    /********************************************************************************************************
     * @description T-5134364 Validate that when creating contact
     * Account created in association with Contact is of the Administrative Account Record Type
     */
    @isTest
    private static void createContactWithDefaultAccountModelAdmin() {
        hed.UTIL_CustomSettings_API.getSettingsForTests(
            new hed__Hierarchy_Settings__c(hed__Account_Processor__c = hed.UTIL_Describe_API.getAdminAccRecTypeID())
        );

        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');
        System.runAs(testUser) {
            Test.startTest();
            Contact testContact = hed.UTIL_UnitTestData_API.getContact();
            insert testContact;
            Test.stopTest();

            List<Contact> insertedContacts = [SELECT Id, AccountId FROM Contact WHERE Id = :testContact.Id];
            System.assertEquals(1, insertedContacts.size(), 'One and only one contact should be created.');

            List<Account> insertedAccounts = [
                SELECT Id, RecordTypeId
                FROM Account
                WHERE Id = :insertedContacts[0].AccountId
            ];
            System.assertEquals(1, insertedAccounts.size(), 'One and only one account should be created.');
            System.assertEquals(
                hed.UTIL_Describe_API.getAdminAccRecTypeID(),
                insertedAccounts[0].RecordTypeId,
                'The Account created in association with Contact should be of the Administrative Account Record Type'
            );
        }
    }
}
