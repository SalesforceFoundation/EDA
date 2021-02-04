/*
    Copyright (c) 2019, Salesforce.org
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
* @date 2019
* @group Terms
* @group-content ../../ApexDocContent/Terms.htm
* @description Unit tests for TERM_CannotDelete_TDTM. These tests
* make sure Terms cannot be deleted when they have Term Grade or Course Offering or Application or Term associations.
*/


@isTest
private class TERM_CannotDelete_TEST {

    @testSetup
    static void dataSetup() {

        // Insert Account
        List<Account> academicAccount = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getAcademicAccRecTypeID());
        insert academicAccount;

        // Insert Term
        Term__c term = UTIL_UnitTestData_TEST.getTerm(academicAccount[0].Id, 'Spring 20');
        insert term;
    }

    /********************************************************************************************************************
    * @description Tests the deletion of Term with Course Offering and Term Grade when “Prevent Term Deletion” is enabled. 
    */
    @isTest
    static void testDeleteTermsWithTermGrades() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Prevent_Term_Deletion__c = TRUE));

        Term__c term = [SELECT Id FROM Term__c LIMIT 1];

        // Insert Course Offering
        Course_Offering__c courseOffering = UTIL_UnitTestData_TEST.createCourseOffering(NULL, term.Id);

        // Insert Contact
        Contact student = UTIL_UnitTestData_TEST.getContact();
        insert student;

        // Insert Course Connection
        Course_Enrollment__c courseConnection = UTIL_UnitTestData_TEST.getCourseConnection(student.Id, courseOffering.Id);
        insert courseConnection;

        // Insert Term Grade
        Term_Grade__c termGrade = UTIL_UnitTestData_TEST.getTermGradeWTermCourseConn(term.Id, courseConnection.Id);
        insert termGrade;

        try {
            Test.startTest();
                delete term;
            Test.stopTest();
        } catch (Exception error) {
            System.assert(error.getMessage().contains(Label.CannotDelete));
        }
    }

    /*********************************************************************************************************
    * @description Tests the deletion of Term without any related child records (Course Offering, Term Grade,
    * and Application) when “Prevent Term Deletion” is disabled. 
    */
    @isTest
    static void testDeleteTermsWithNoTermGrades() {
        Term__c term = [SELECT Id FROM Term__c LIMIT 1];

        Test.startTest();
            delete term;
        Test.stopTest();

        List<Term__c> termsList = [SELECT Id FROM Term__c];
        System.assertEquals(0, termsList.size());
    }

    /**********************************************************************************************************************
    * @description Tests the deletion of Term with Course Offering and Term Grade when “Prevent Term Deletion” is disabled. 
    */
    @isTest
    static void testDeleteTermsWithTermGradesSettingOff() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Prevent_Term_Deletion__c = FALSE));

        Term__c term = [SELECT Id FROM Term__c LIMIT 1];

        // Insert Course Offering
        Course_Offering__c courseOffering = UTIL_UnitTestData_TEST.createCourseOffering(NULL, term.Id);

        // Insert Contact
        Contact student = UTIL_UnitTestData_TEST.getContact();
        insert student;

        // Insert Course Connection
        Course_Enrollment__c courseConnection = UTIL_UnitTestData_TEST.getCourseConnection(student.Id, courseOffering.Id);
        insert courseConnection;

        // Insert Term Grade
        Term_Grade__c termGrade = UTIL_UnitTestData_TEST.getTermGradeWTermCourseConn(term.Id, courseConnection.Id);
        insert termGrade;

        Test.startTest();
            delete term;
        Test.stopTest();

        List<Term__c> termsList = [SELECT Id FROM Term__c];
        System.assertEquals(0, termsList.size());
    }

    /*********************************************************************************************************
    * @description Bulk test deletion of Term records with Course Offering, Term Grade, Application, Term when
    * “Prevent Term Deletion” is enabled.
    */
    @isTest
    static void testBulkDeleteSettingOn() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Prevent_Term_Deletion__c = TRUE));

        Account academicAccount = [Select Id FROM Account LIMIT 1];

        Term__c term1 = [SELECT Id FROM Term__c LIMIT 1];

        List<Term__c> termsToInsert = new List<Term__c>();

        Term__c term2 = UTIL_UnitTestData_TEST.getTerm(academicAccount.Id, 'Spring 18');
        Term__c term3 = UTIL_UnitTestData_TEST.getTerm(academicAccount.Id, 'Spring 19');
        Term__c term4 = UTIL_UnitTestData_TEST.getTerm(academicAccount.Id, 'Winter 21');
        Term__c term5 = UTIL_UnitTestData_TEST.getTerm(academicAccount.Id, 'Spring 21');
        term5.Parent_Term__c = term1.Id;
        Term__c term6 = UTIL_UnitTestData_TEST.getTerm(academicAccount.Id, 'Spring 22');

        termsToInsert.add(term2);
        termsToInsert.add(term3);
        termsToInsert.add(term4);
        termsToInsert.add(term5);
        termsToInsert.add(term6);

        insert termsToInsert;
        
        // Ensure there are 6 terms
        List<Term__c> termsBeforeDelete = [SELECT Id FROM TERM__c];
        System.assertEquals(6, termsBeforeDelete.size());

        // Insert Contact
        Contact student = UTIL_UnitTestData_TEST.getContact();
        insert student;

        // Insert Course Offering for Term 1
        Course_Offering__c courseOffering = UTIL_UnitTestData_TEST.createCourseOffering(NULL, term1.Id);

        // Insert a Course Connection
        Course_Enrollment__c courseConnection = UTIL_UnitTestData_TEST.getCourseConnection(student.Id, courseOffering.Id);
        insert courseConnection;

        // Insert Term Grade for Term 2
        List<Term_Grade__c> termGradesToInsert = new List<Term_Grade__c>();
        Term_Grade__c termGrade = UTIL_UnitTestData_TEST.getTermGradeWTermCourseConn(term2.Id, courseConnection.Id);
        termGradesToInsert.add(termGrade);

        // Insert Application for Term 3
        List<Application__c> applicaitonsToInsert = new List<Application__c>();
        Application__c application =  UTIL_UnitTestData_TEST.getApplication(academicAccount.Id, student.Id, term3.Id);
        applicaitonsToInsert.add(application);

        // Insert Course offering, Term Grades and Application for Term 4
        Course_Offering__c courseOffering2 = UTIL_UnitTestData_TEST.createCourseOffering(NULL, term4.Id);

        Term_Grade__c termGrade2 = UTIL_UnitTestData_TEST.getTermGradeWTermCourseConn(term4.Id, courseConnection.Id);
        termGradesToInsert.add(termGrade2);

        // Insert Term Grades
        insert termGradesToInsert;

        Application__c application2 =  UTIL_UnitTestData_TEST.getApplication(academicAccount.Id, student.Id, term4.Id);
        applicaitonsToInsert.add(application2);

        // Insert Applicaitons
        insert applicaitonsToInsert;

        Test.startTest();
            List<Term__c> termsToDelete = [SELECT Id FROM TERM__c WHERE Id != :term5.Id];
            System.assertEquals(5, termsToDelete.size());
            Database.DeleteResult[] results = Database.delete(termsToDelete, FALSE);
        Test.stopTest();

        // Ensure only 6 Term is deleted
        List<Term__c> termsAfterDelete = [SELECT Id FROM TERM__c];
        System.assertEquals(5, termsAfterDelete.size());
    }

    /**********************************************************************************************************************************************
    * @description Bulk test deletion of Term records with Course Offering, Term Grade, Application, Term when “Prevent Term Deletion” is disabled. 
    */
    @isTest 
    static void testBulkDeleteSettingOff() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Prevent_Term_Deletion__c = FALSE));

        Account academicAccount = [Select Id FROM Account LIMIT 1];

        Term__c term1 = [SELECT Id FROM Term__c LIMIT 1];

        List<Term__c> termsToInsert = new List<Term__c>();

        Term__c term2 = UTIL_UnitTestData_TEST.getTerm(academicAccount.Id, 'Spring 18');
        Term__c term3 = UTIL_UnitTestData_TEST.getTerm(academicAccount.Id, 'Spring 19');
        Term__c term4 = UTIL_UnitTestData_TEST.getTerm(academicAccount.Id, 'Spring 21');
        Term__c term5 = UTIL_UnitTestData_TEST.getTerm(academicAccount.Id, 'Spring 21');
        term5.parent_term__c = term1.Id;
        Term__c term6 = UTIL_UnitTestData_TEST.getTerm(academicAccount.Id, 'Spring 21');

        termsToInsert.add(term2);
        termsToInsert.add(term3);
        termsToInsert.add(term4);
        termsToInsert.add(term5);

        insert termsToInsert;

        // Insert Contact
        Contact student = UTIL_UnitTestData_TEST.getContact();
        insert student;

        // Insert Course Offering for Term 1
        Course_Offering__c courseOffering = UTIL_UnitTestData_TEST.createCourseOffering(NULL, term1.Id);

        // Insert a Course Connection
        Course_Enrollment__c courseConnection = UTIL_UnitTestData_TEST.getCourseConnection(student.Id, courseOffering.Id);
        insert courseConnection;

        // Insert Term Grade for Term 2
        List<Term_Grade__c> termGradesToInsert = new List<Term_Grade__c>();
        Term_Grade__c termGrade = UTIL_UnitTestData_TEST.getTermGradeWTermCourseConn(term2.Id, courseConnection.Id);
        termGradesToInsert.add(termGrade);

        // Insert Application for Term 3
        List<Application__c> applicaitonsToInsert = new List<Application__c>();
        Application__c application =  UTIL_UnitTestData_TEST.getApplication(academicAccount.Id, student.Id, term3.Id);
        applicaitonsToInsert.add(application);

        // Insert Course offering, Term Grades and Application for Term 4
        Course_Offering__c courseOffering2 = UTIL_UnitTestData_TEST.createCourseOffering(NULL, term4.Id);

        Term_Grade__c termGrade2 = UTIL_UnitTestData_TEST.getTermGradeWTermCourseConn(term4.Id, courseConnection.Id);
        termGradesToInsert.add(termGrade2);

        // Insert Term Grades
        insert termGradesToInsert;

        Application__c application2 =  UTIL_UnitTestData_TEST.getApplication(academicAccount.Id, student.Id, term4.Id);
        applicaitonsToInsert.add(application2);

        // Insert Applicaitons
        insert applicaitonsToInsert;

        Test.startTest();
            List<Term__c> termsToDelete = [SELECT Id FROM TERM__c];
            Database.DeleteResult[] results = Database.delete(termsToDelete, FALSE);
        Test.stopTest();

        // Ensure all Terms are deleted
        List<Term__c> termsAfterDelete = [SELECT Id FROM TERM__c];
        System.assertEquals(0, termsAfterDelete.size());
    }

    /***********************************************************************************************************
    * @description Tests the deletion of Term with Term as child record when "Prevent Term Deletion" is enabled
    */
    @isTest
    static void testDeleteTermsWithTerms() {
        
        // Enable Prevent Term Deletion Cusotm Settings
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Prevent_Term_Deletion__c = TRUE));

        // Insert Account
        List<Account> academicAccount = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getAcademicAccRecTypeID());
        insert academicAccount;
        
        // Get term1
        Term__c term1 = [SELECT Id, Parent_Term__c FROM TERM__c];

        // Insert Term2 and Term3
        List<Term__c> termsToInsert = new  List<Term__c>();
        Term__c term2 = UTIL_UnitTestData_TEST.getTerm(academicAccount[0].Id, 'Fall 19');
        Term__c term3 = UTIL_UnitTestData_TEST.getTerm(academicAccount[0].Id, 'Fall 18');
        termsToInsert.add(term2);
        termsToInsert.add(term3);
        insert termsToInsert;
        
        // Make term2 parent of term3
        term3.Parent_Term__c = term2.Id;
        update term3;
       
        // Ensure there are 3 terms
        List<Term__c> termsBeforeDelete = [SELECT Id FROM TERM__c];
        System.assertEquals(3, termsBeforeDelete.size());

        // Test deleting Term1 and Term2
        Test.startTest();
            List<Term__c> termsToDelete = [SELECT Id FROM TERM__c WHERE Id != :term3.Id];
            System.assertEquals(2, termsToDelete.size());
            Database.DeleteResult[] results = Database.delete(termsToDelete, FALSE);
        Test.stopTest();

        // Ensure only term1 is deleted
        List<Term__c> termsAfterDelete = [SELECT Id FROM TERM__c];
        System.assertEquals(2, termsAfterDelete.size());
    }
}