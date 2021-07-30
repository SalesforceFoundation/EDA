/*
    Copyright (c) 2021, Salesforce.org
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
 * @group Contacts
 * @group-content ../../ApexDocContent/Contacts.htm
 * @description Test class for logic that prevents application due date to be prior to the open date.
 */
@isTest
private with sharing class Application_TEST {
    /**************************************************************************************************************************
     ****************************************************** UNIT TESTS *********************************************************
     **************************************************************************************************************************/

    /********************************************************
     * @description Should fail to insert an application with a due date prior to the open date
     *********************************************************/
    @isTest
    static void shouldFailInsertWhenApplicationDueDateIsBeforeOpenDate() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Application_Window_Validation__c = true)
        );
        Account academicAccount = getAcademicAccount();
        Contact student = getStudent();

        Application__c invalidApplication = new Application__c(
            Applicant__c = student.Id,
            Applying_To__c = academicAccount.Id,
            Due_Date__c = System.today().addDays(-10),
            Open_Date__c = System.today()
        );

        Test.startTest();
        Database.SaveResult insertResult = Database.insert(invalidApplication, false);
        Test.stopTest();

        System.assertEquals(false, insertResult.isSuccess(), 'Insert should have failed due to invalid date range');
        System.assertEquals(
            Label.stgErrorAppDueDate,
            insertResult.getErrors()[0].getMessage(),
            'Should fail with the Open/Due Date validation error message'
        );
    }

    /********************************************************
     * @description Should fail to update an application when setting the due date prior to the open date
     *********************************************************/
    @isTest
    static void shouldFailUpdateWhenApplicationDueDateIsBeforeOpenDate() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Application_Window_Validation__c = true)
        );
        Account academicAccount = getAcademicAccount();
        Contact student = getStudent();

        Application__c openEndedApplication = new Application__c(
            Applicant__c = student.Id,
            Applying_To__c = academicAccount.Id,
            Open_Date__c = System.today()
        );
        insert openEndedApplication;

        openEndedApplication.Due_Date__c = System.today().addDays(-10);

        Test.startTest();
        Database.SaveResult updateResult = Database.update(openEndedApplication, false);
        Test.stopTest();

        System.assertEquals(false, updateResult.isSuccess(), 'Update should have failed due to invalid date range');
        System.assertEquals(
            Label.stgErrorAppDueDate,
            updateResult.getErrors()[0].getMessage(),
            'Should fail with the Open/Due Date validation error message'
        );
    }

    /********************************************************
     * @description Should succeed to insert an application with just the due date set
     *********************************************************/
    @isTest
    static void shouldSucceedWhenApplicationHasOnlyDueDate() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Application_Window_Validation__c = true)
        );
        Account academicAccount = getAcademicAccount();
        Contact student = getStudent();

        Application__c pastDueApplication = new Application__c(
            Applicant__c = student.Id,
            Applying_To__c = academicAccount.Id,
            Due_Date__c = System.today()
        );

        Test.startTest();
        Database.SaveResult insertResult = Database.insert(pastDueApplication, false);
        Test.stopTest();

        System.assertEquals(
            true,
            insertResult.isSuccess(),
            'Insert should succeed since date fields are not compared due to only one of them being set'
        );
    }

    /********************************************************
     * @description Should succeed to insert an application with just the open date set
     *********************************************************/
    @isTest
    static void shouldSucceedWhenApplicationHasOnlyOpenDate() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Application_Window_Validation__c = true)
        );
        Account academicAccount = getAcademicAccount();
        Contact student = getStudent();

        Application__c openEndedApplication = new Application__c(
            Applicant__c = student.Id,
            Applying_To__c = academicAccount.Id,
            Open_Date__c = System.today()
        );

        Test.startTest();
        Database.SaveResult insertResult = Database.insert(openEndedApplication, false);
        Test.stopTest();

        System.assertEquals(
            true,
            insertResult.isSuccess(),
            'Insert should succeed since date fields are not compared due to only one of them being set'
        );
    }

    /********************************************************
     * @description Should succeed in inserting an application with a due date prior to the open date when the trigger is disabled
     *********************************************************/
    @isTest
    static void shouldSucceedInsertWhenTriggerDisabled() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Application_Window_Validation__c = false)
        );
        Account academicAccount = getAcademicAccount();
        Contact student = getStudent();

        Application__c invalidApplication = new Application__c(
            Applicant__c = student.Id,
            Applying_To__c = academicAccount.Id,
            Due_Date__c = System.today().addDays(-10),
            Open_Date__c = System.today()
        );

        Test.startTest();
        Database.SaveResult insertResult = Database.insert(invalidApplication, false);
        Test.stopTest();

        System.assertEquals(
            true,
            insertResult.isSuccess(),
            'Insert should have succeeded due to trigger being disabled'
        );
    }

    /********************************************************
     * @description Should succeed in updating an application when setting the due date prior to the open date when the trigger is disabled
     *********************************************************/
    @isTest
    static void shouldSucceedUpdateWhenTriggerDisabled() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Application_Window_Validation__c = false)
        );
        Account academicAccount = getAcademicAccount();
        Contact student = getStudent();

        Application__c openEndedApplication = new Application__c(
            Applicant__c = student.Id,
            Applying_To__c = academicAccount.Id,
            Open_Date__c = System.today()
        );
        insert openEndedApplication;

        openEndedApplication.Due_Date__c = System.today().addDays(-10);

        Test.startTest();
        Database.SaveResult updateResult = Database.update(openEndedApplication, false);
        Test.stopTest();

        System.assertEquals(
            true,
            updateResult.isSuccess(),
            'Update should have succeeded due to trigger being disabled'
        );
    }

    /********************************************************
     * @description Should succeed in updating an application when setting the due date prior to the open date when the trigger is disabled
     *********************************************************/
    @isTest
    static void shouldNotProceedWithEmptyList() {
        Application_TDTM handler = new Application_TDTM();
        TDTM_Runnable.DmlWrapper result = handler.run(
            new List<Application__c>(),
            null,
            TDTM_Runnable.Action.BeforeInsert,
            Application__c.getSobjectType().getDescribe()
        );
        System.assertNotEquals(null, result, 'Handler should have returned an empty DmlWrapper instance');
    }

    private static Account getAcademicAccount() {
        Account academicAccount = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe.getAcademicAccRecTypeID()
        )[0];
        insert academicAccount;
        return academicAccount;
    }

    private static Contact getStudent() {
        Contact student = UTIL_UnitTestData_TEST.getContact();
        insert student;
        return student;
    }
}
