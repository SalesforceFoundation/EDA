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
 * @description T-3904097: When an Account Owner is updated on a Contact with a default Administrative Account Record Type,
 * the Associated Account should update with same Owner.
 */
@isTest
 public with sharing class AdminAccountRecordType_FTST {

    private static hed__Hierarchy_Settings__c createSettings() {
        hed__Hierarchy_Settings__c orgSettings = hed.UTIL_CustomSettings_API.getOrgSettings();
        hed.UTIL_CustomSettings_API.getSettingsForTests(orgSettings);
        return orgSettings;
    }

    /********************************************************************************************************
     * @description Validate that when updating the OwnerId of an existing Contact, the Account updates the
     *  OwnerId to the same updated value.
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

 }
 