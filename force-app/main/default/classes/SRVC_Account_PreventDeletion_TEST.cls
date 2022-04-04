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
 * @date 2022
 * @group
 * @group-content ../../ApexDocContent/Accounts.htm
 * @description Test class for SRVC_Account_PreventDeletion
 */
@isTest
private class SRVC_Account_PreventDeletion_TEST {
    /**************************************************************************************************************************
     * @description Helper method to create Account with child records
     */
    private static Account createAccountWithChildRecordsHelper() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getBizAccRecTypeID(),
                Prevent_Account_Deletion__c = true
            )
        );

        return UTIL_UnitTestData_TEST.createTestAccountWithMultipleRelations();
    }

    /**************************************************************************************************************************
     * @description Tests getInstance() and constructor of SRVC_Account_PreventDeletion
     */
    @isTest
    static void testGetInstance() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getBizAccRecTypeID(),
                Prevent_Account_Deletion__c = true
            )
        );

        SRVC_Account_PreventDeletion srvcAccountPreventDeleteInstance = SRVC_Account_PreventDeletion.getInstance();
        System.assertEquals(SRVC_Account_PreventDeletion.instance, srvcAccountPreventDeleteInstance);
        System.assertNotEquals(null, srvcAccountPreventDeleteInstance);

        srvcAccountPreventDeleteInstance = SRVC_Account_PreventDeletion.getInstance();
        System.assertEquals(SRVC_Account_PreventDeletion.instance, srvcAccountPreventDeleteInstance);
        System.assertEquals(true, srvcAccountPreventDeleteInstance.enabledPreventAccountDeletion);
    }

    /**************************************************************************************************************************
     * @description Tests that isAccountDeletionPreventionEnabled is returning true when prevent deletion is enabled
     */
    @isTest
    static void shouldDetectEnabledPreventDeletionSetting() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getBizAccRecTypeID(),
                Prevent_Account_Deletion__c = true
            )
        );

        SRVC_Account_PreventDeletion srvcAccountPreventDeleteInstance = SRVC_Account_PreventDeletion.getInstance();
        System.assertEquals(true, srvcAccountPreventDeleteInstance.isAccountDeletionPreventionEnabled());
    }

    /**************************************************************************************************************************
     * @description Tests that isAccountDeletionPreventionEnabled is returning false when prevent deletion is disabled
     */
    @isTest
    static void shouldDetectDisabledPreventDeletionSetting() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getBizAccRecTypeID(),
                Prevent_Account_Deletion__c = false
            )
        );

        SRVC_Account_PreventDeletion srvcAccountPreventDeleteInstance = SRVC_Account_PreventDeletion.getInstance();
        System.assertEquals(false, srvcAccountPreventDeleteInstance.isAccountDeletionPreventionEnabled());
    }

    /**************************************************************************************************************************
     * @description Tests Prevent Deletion for Accounts with STUB_AccountsWithChildRelationships
     */
    @isTest
    static void shouldPreventDeletionForAccountsWithChildrenUsingSTUB() {
        SRVC_Account_PreventDeletion.instance = new STUB_AccountsWithChildRelationships();

        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        accounts[0].Id = UTIL_UnitTestData_TEST.getFakeId(Account.sObjectType);

        Map<Id, Account> accountsById = new Map<Id, Account>((List<Account>) accounts);

        Test.startTest();
        List<Account> accountsWithRelations = SRVC_Account_PreventDeletion.getInstance()
            .getAccountsAndChildRelationships(accountsById.keySet());
        List<Account> accountsWithErrorsList = SRVC_Account_PreventDeletion.getInstance()
            .preventDeletionForAccounts(accountsById, accountsWithRelations);
        Test.stopTest();

        System.assertEquals(accountsById.values().size(), accountsWithErrorsList.size());

        for (Account accountToCheck : accountsWithErrorsList) {
            System.assert(accountsById.get(accountToCheck.Id) != null);
        }
    }

    /**************************************************************************************************************************
     * @description Tests Prevent Deletion for Accounts with STUB_AccountsWithNoChildRelationships
     */
    @isTest
    static void shouldPreventDeletionForAccountsWithNoChildrenUsingSTUB() {
        SRVC_Account_PreventDeletion.instance = new STUB_AccountsWithNoChildRelationships();

        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        accounts[0].Id = UTIL_UnitTestData_TEST.getFakeId(Account.sObjectType);

        Map<Id, Account> accountById = new Map<Id, Account>((List<Account>) accounts);

        Test.startTest();
        List<Account> accountsWithRelations = SRVC_Account_PreventDeletion.getInstance()
            .getAccountsAndChildRelationships(accountById.keySet());
        List<Account> accountsWithErrorsList = SRVC_Account_PreventDeletion.getInstance()
            .preventDeletionForAccounts(accountById, accountsWithRelations);
        Test.stopTest();

        // Ensure accountsWithErrorsList is empty
        System.assertEquals(0, accountsWithErrorsList.size());
    }

    /**************************************************************************************************************************
     * @description Positive tests for preventDeletionForAccounts method using Account with Child records
     */
    @isTest
    static void shouldPreventDeletionForAccountsWithRelations() {
        Account accountWithChildRecords = SRVC_Account_PreventDeletion_TEST.createAccountWithChildRecordsHelper();
        Map<Id, Account> accountById = new Map<Id, Account>();
        accountById.put(accountWithChildRecords.Id, accountWithChildRecords);

        Test.startTest();
        List<Account> accountsWithRelations = SRVC_Account_PreventDeletion.getInstance()
            .getAccountsAndChildRelationships(accountById.keySet());
        List<account> accountErroredList = SRVC_Account_PreventDeletion.getInstance()
            .preventDeletionForAccounts(accountById, accountsWithRelations);
        Test.stopTest();

        // Ensure accountsWithErrorsList is not empty
        System.assertEquals(1, accountErroredList.size());
    }

    /**************************************************************************************************************************
     * @description Negative tests for preventDeletionForAccounts method with No Child records
     */
    @isTest
    static void shouldNotPreventDeletionForAccountsWithNoRelations() {
        List<Account> accountWithNoChildRecord = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        accountWithNoChildRecord[0].Id = UTIL_UnitTestData_TEST.getFakeId(Account.sObjectType);

        Map<Id, Account> accountById = new Map<Id, Account>(accountWithNoChildRecord);

        Test.startTest();
        List<Account> accountsWithRelations = SRVC_Account_PreventDeletion.getInstance()
            .getAccountsAndChildRelationships(accountById.keySet());
        List<account> accountErroredList = SRVC_Account_PreventDeletion.getInstance()
            .preventDeletionForAccounts(accountById, accountsWithRelations);
        Test.stopTest();

        // Ensure accountsWithErrorsList is empty
        System.assertEquals(0, accountErroredList.size());
    }

    /**************************************************************************************************************************
     * @description Positive tests for AccountsAndChildRelationships method
     */
    @isTest
    static void shouldGetAccountsAndChildRelationships() {
        Account accountWithChildRecords = SRVC_Account_PreventDeletion_TEST.createAccountWithChildRecordsHelper();

        Set<Id> accountIdSet = new Set<Id>();
        accountIdSet.add(accountWithChildRecords.Id);

        Test.startTest();
        List<Account> accountsWithChildRecords = SRVC_Account_PreventDeletion.getInstance()
            .getAccountsAndChildRelationships(accountIdSet);
        Test.stopTest();

        // Ensure child records are retrieved
        System.assertEquals(1, accountsWithChildRecords[0].Addresses__r.size());
        System.assertEquals(1, accountsWithChildRecords[0].Affl_Contacts__r.size());
        System.assertEquals(1, accountsWithChildRecords[0].Attributes__r.size());
        System.assertEquals(1, accountsWithChildRecords[0].Courses__r.size());
        System.assertEquals(1, accountsWithChildRecords[0].Education_History__r.size());
        System.assertEquals(1, accountsWithChildRecords[0].Facilities__r.size());
        System.assertEquals(1, accountsWithChildRecords[0].Household_Members__r.size());
        System.assertEquals(1, accountsWithChildRecords[0].Organization_Members__r.size());
        System.assertEquals(1, accountsWithChildRecords[0].Program_Enrollments__r.size());
        System.assertEquals(1, accountsWithChildRecords[0].Program_Plans__r.size());
        System.assertEquals(1, accountsWithChildRecords[0].Terms__r.size());
        System.assertEquals(1, accountsWithChildRecords[0].Time_Blocks__r.size());
    }

    /**************************************************************************************************************************
     * @description Negative tests for AccountsAndChildRelationships method
     */
    @isTest
    static void shouldNotGetChildRelationshipsForEmptyAccounts() {
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        insert accounts;

        Map<Id, Account> accountById = new Map<Id, Account>(accounts);
        Set<Id> accountIdSet = accountById.keySet();

        Test.startTest();
        List<account> accountsWithChildRecords = SRVC_Account_PreventDeletion.getInstance()
            .getAccountsAndChildRelationships(accountIdSet);
        Test.stopTest();

        System.assertEquals(0, accountsWithChildRecords[0].Addresses__r.size());
        System.assertEquals(0, accountsWithChildRecords[0].Affl_Contacts__r.size());
        System.assertEquals(0, accountsWithChildRecords[0].Attributes__r.size());
        System.assertEquals(0, accountsWithChildRecords[0].Courses__r.size());
        System.assertEquals(0, accountsWithChildRecords[0].Course_Enrollments__r.size());
        System.assertEquals(0, accountsWithChildRecords[0].Education_History__r.size());
        System.assertEquals(0, accountsWithChildRecords[0].Facilities__r.size());
        System.assertEquals(0, accountsWithChildRecords[0].Household_Members__r.size());
        System.assertEquals(0, accountsWithChildRecords[0].Organization_Members__r.size());
        System.assertEquals(0, accountsWithChildRecords[0].Program_Enrollments__r.size());
        System.assertEquals(0, accountsWithChildRecords[0].Program_Plans__r.size());
        System.assertEquals(0, accountsWithChildRecords[0].Terms__r.size());
        System.assertEquals(0, accountsWithChildRecords[0].Time_Blocks__r.size());
    }

    /**************************************************************************************************************************
     * @description positive test for AccountHasChildRecords method
     */
    @isTest
    static void shouldHaveChildRecordsForAccountWithChildRelations() {
        Account accountWithChildRecords = SRVC_Account_PreventDeletion_TEST.createAccountWithChildRecordsHelper();

        Account acc = [
            SELECT
                ID,
                (SELECT ID FROM Account.Addresses__r LIMIT 1),
                (SELECT ID FROM Account.Affl_Contacts__r LIMIT 1),
                (SELECT ID FROM Account.Attributes__r LIMIT 1),
                (SELECT ID FROM Account.Courses__r LIMIT 1),
                (SELECT ID FROM Account.Course_Enrollments__r LIMIT 1),
                (SELECT ID FROM Account.Education_History__r LIMIT 1),
                (SELECT ID FROM Account.Facilities__r LIMIT 1),
                (SELECT ID FROM Account.Household_Members__r LIMIT 1),
                (SELECT ID FROM Account.Organization_Members__r LIMIT 1),
                (SELECT ID FROM Account.Program_Enrollments__r LIMIT 1),
                (SELECT ID FROM Account.Program_Plans__r LIMIT 1),
                (SELECT ID FROM Account.Terms__r LIMIT 1),
                (SELECT ID FROM Account.Time_Blocks__r LIMIT 1)
            FROM Account
            WHERE ID = :accountWithChildRecords.Id
        ];

        Test.startTest();
        Boolean accountHasChildren = SRVC_Account_PreventDeletion.getInstance().hasChildRecords(acc);
        Test.stopTest();

        // Ensure accountHasChildren is true
        System.assertEquals(true, accountHasChildren);
    }

    /**************************************************************************************************************************
     * @description Negative test for AccountHasChildRecords method
     */
    @isTest
    static void shouldNotHaveChildRecordsForEmptyAccounts() {
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        );

        Test.startTest();
        Boolean accountHasChildren = SRVC_Account_PreventDeletion.getInstance().hasChildRecords(accounts[0]);
        Test.stopTest();

        // Ensure accountHasChildren is false
        System.assertEquals(false, accountHasChildren);
    }

    /**************************************************************************************************************************
     * @description Positive tests for accountWasMerged method using Account with MasterRecordId
     */
    @isTest
    static void shouldReturnTrueWhenAccountWasMerged() {
        Account accountWithChildRecords = SRVC_Account_PreventDeletion_TEST.createAccountWithChildRecordsHelper();
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            2,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        insert accounts[1]; //Use the second account as master to avoid duplicate error
        merge accounts[1] accountWithChildRecords;
        Account mergeLoserAccount = [
            SELECT Id, MasterRecordId
            FROM Account
            WHERE Id = :accountWithChildRecords.Id
            ALL ROWS
        ];

        Test.startTest();
        Boolean accountWasMerged = SRVC_Account_PreventDeletion.getInstance().wasMerged(mergeLoserAccount);
        Test.stopTest();

        // Ensure accountWasMerged is true
        System.assertEquals(true, accountWasMerged);
    }

    /**************************************************************************************************************************
     * @description Negative tests for accountWasMerged method using Account without MasterRecordId
     */
    @isTest
    static void shouldReturnFalseWhenAccountNotMerged() {
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            2,
            UTIL_Describe_API.getBizAccRecTypeID()
        );

        Test.startTest();
        Boolean accountWasMerged = SRVC_Account_PreventDeletion.getInstance().wasMerged(accounts[0]);
        Test.stopTest();

        // Ensure accountWasMerged is false
        System.assertEquals(false, accountWasMerged);
    }

    /**************************************************************************************************************************
     * @description Tests Prevent Deletion for merged accounts with STUB_MergedAccounts
     */
    @isTest
    static void shouldNotPreventDeletionForMergedAccountsUsingSTUB() {
        SRVC_Account_PreventDeletion.instance = new STUB_MergedAccounts();

        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        accounts[0].Id = UTIL_UnitTestData_TEST.getFakeId(Account.sObjectType);

        Map<Id, Account> accountById = new Map<Id, Account>((List<Account>) accounts);

        Test.startTest();
        List<Account> accountsWithRelations = SRVC_Account_PreventDeletion.getInstance()
            .getAccountsAndChildRelationships(accountById.keySet());
        List<Account> accountsWithErrorsList = SRVC_Account_PreventDeletion.getInstance()
            .PreventDeletionForAccounts(accountById, accountsWithRelations);
        Test.stopTest();

        //Ensure prevent deletion did not mark any account
        System.assertEquals(0, accountsWithErrorsList.size());
    }

    /**************************************************************************************************************************************
     * STUB class which extends SRVC_Account_PreventDeletion, overrides getAccountsAndChildRelationships and hasChildRecords method
     */
    private virtual class STUB_AccountsWithChildRelationships extends SRVC_Account_PreventDeletion {
        @TestVisible
        public override List<Account> getAccountsAndChildRelationships(Set<Id> accountIdSet) {
            List<Account> accountsList = new List<Account>();
            for (Id eachAccountId : accountIdSet) {
                Account acc = new Account(Id = eachAccountId, Name = eachAccountId);
                accountsList.add(acc);
            }
            return accountsList;
        }

        @TestVisible
        public override Boolean hasChildRecords(Account acc) {
            return true;
        }
    }

    /***************************************************************************************************************************************
     * STUB class which extends SRVC_Account_PreventDeletion, overrides getAccountsAndChildRelationships and hasChildRecords method
     */
    private virtual class STUB_AccountsWithNoChildRelationships extends SRVC_Account_PreventDeletion {
        @TestVisible
        public override List<Account> getAccountsAndChildRelationships(Set<Id> accountIdSet) {
            List<Account> accountsList = new List<Account>();
            for (Id eachAccountId : accountIdSet) {
                Account acc = new Account(Id = eachAccountId, Name = eachAccountId);
                accountsList.add(acc);
            }
            return accountsList;
        }

        @TestVisible
        public override Boolean hasChildRecords(Account acc) {
            return false;
        }
    }

    /**************************************************************************************************************************************
     * STUB class which extends STUB_AccountsWithChildRelationships, overrides wasMerged method to simulate merging
     */
    private virtual class STUB_MergedAccounts extends STUB_AccountsWithChildRelationships {
        @TestVisible
        protected override Boolean wasMerged(Account acc) {
            return true;
        }
    }
}
