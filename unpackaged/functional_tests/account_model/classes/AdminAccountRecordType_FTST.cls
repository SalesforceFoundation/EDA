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
 * @date 2011 (1.x)
 * @group Accounts
 * @group-content ../../ApexDocContent/Accounts.htm
 * @description Implements Household or Administrative account model - controls syncing within the model i.e.,
 * 1) It ensures that when the owner of a Primary Contact record that has an Administrative or
 * Household Account is updated, the owner of the Account is also updated.
 * 2) It also ensures that when a Primary Contact is moved from an Administrative or Household Account,
 * the first remaining Contact on the Account becomes the Account's Primary Contact.
 * 3) When the name of a Contact used to name an Account changes, the Account's name is updated using the
 * Account Naming Format specified on the Systems tab in EDA Settings. These behaviors apply to all Accounts
 * with the Administrative or Household Account Record Type specified on the "Accounts and Contacts" tab in "EDA Settings.”
 */

@isTest
 public with sharing class AdminAccountRecordType_FTST {

    /********************************************************************************************************
     * @description Validate that when updating the OwnerId of an existing Contact, the Account updates the
     *  OwnerId to the same updated value.
     */
    @isTest
    private static void test_updateOwnerAccountSync() {

        //Ensure Admin Account model
        hed__UTIL_CustomSettingsFacade.getSettingsForTests(
            new hed__Hierarchy_Settings__c(hed__Account_Processor__c = hed__UTIL_Describe_API.getAdminAccRecTypeID())
        );

        // Create a single new User
        Id sysAdminProfileId = hed__UTIL_Profile.getInstance().getProfileIds(hed__UTIL_Profile.SYSTEM_ADMINISTRATOR)[0];
        User tempUser = new User(
            LastName = 'TestSysAdminUserA',
            Email = 'test_insertAsOtherUser@email.npsp',
            ProfileId = sysAdminProfileId,
            isActive = true,
            UserName = 'test_insertAsOtherUser@email.npsp',
            Alias = 'tu08534',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1'
        );
        insert tempUser;

        Id currUserId = UserInfo.getUserId();
        Contact con = hed__UTIL_UnitTestData_TEST.getContact();
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
 