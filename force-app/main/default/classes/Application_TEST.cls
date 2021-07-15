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
    @TestSetup
    static void makeData() {
        List<Account> academicAccount = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getAcademicAccRecTypeID()
        );
        insert academicAccount;

        Contact student = UTIL_UnitTestData_TEST.getContact();
        insert student;
    }
    /**************************************************************************************************************************
     ****************************************************** UNIT TESTS *********************************************************
     **************************************************************************************************************************/

    /********************************************************
     * @description Should fail to insert an application with a due date prior to the open date
     *********************************************************/
    @isTest
    static void newApplicationWithDueBeforeOpen() {
        Account academicAccount = [SELECT Id FROM Account LIMIT 1];
        Contact student = [SELECT Id FROM Contact LIMIT 1];

        Application__c invalidApplication = new Application__c(
            Applicant__c = student.Id,
            Applying_To__c = academicAccount.Id,
            Due_Date__c = System.today().addDays(-10),
            Open_Date__c = System.today()
        );

        Test.startTest();
        Database.SaveResult insertResult = Database.insert(invalidApplication, false);
        Test.stopTest();

        System.assertEquals(false, insertResult.isSuccess(), 'Should have failed due to invalid date range');
        System.assertEquals(
            Label.stgErrorAppDueDate,
            insertResult.getErrors()[0].getMessage(),
            'The operation failed with the wrong message'
        );
    }

    /********************************************************
     * @description Should fail to update an application setting the due date prior to the open date
     *********************************************************/
    @isTest
    static void applicationDueBeforeOpen() {
        Account academicAccount = [SELECT Id FROM Account LIMIT 1];
        Contact student = [SELECT Id FROM Contact LIMIT 1];

        Application__c openEndedApplication = new Application__c(
            Applicant__c = student.Id,
            Applying_To__c = academicAccount.Id,
            Open_Date__c = System.today()
        );
        insert openEndedApplication;

        Test.startTest();
        openEndedApplication.Due_Date__c = System.today().addDays(-10);
        Database.SaveResult updateResult = Database.update(openEndedApplication, false);
        Test.stopTest();

        System.assertEquals(false, updateResult.isSuccess(), 'Should have failed due to invalid date range');
        System.assertEquals(
            Label.stgErrorAppDueDate,
            updateResult.getErrors()[0].getMessage(),
            'The operation failed with the wrong message'
        );
    }

    /********************************************************
     * @description Should succeed to insert an application with just one date set
     *********************************************************/
    @isTest
    static void newApplicationWithJustOneDate() {
        Account academicAccount = [SELECT Id FROM Account LIMIT 1];
        Contact student = [SELECT Id FROM Contact LIMIT 1];

        Application__c pastDueApplication = new Application__c(
            Applicant__c = student.Id,
            Applying_To__c = academicAccount.Id,
            Due_Date__c = System.today().addDays(-10)
        );
        Application__c openEndedApplication = new Application__c(
            Applicant__c = student.Id,
            Applying_To__c = academicAccount.Id,
            Open_Date__c = System.today().addDays(-10)
        );

        Test.startTest();
        Database.SaveResult[] insertResults = Database.insert(
            new List<Application__c>{ pastDueApplication, openEndedApplication },
            false
        );
        Test.stopTest();

        for (Database.SaveResult insertResult : insertResults) {
            System.assertEquals(true, insertResult.isSuccess(), 'Should have passed due to having a blank date field');
        }
    }
}
