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
* make sure Terms cannot be deleted when they have Term Grade Associations.
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
    
    /*********************************************************************************************************
    * @description Test deletion of Terms with Term Grades
    */
    @isTest 
    static void testDeleteTermsWithTermGrades() {
        
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
    * @description Test deletion of Terms with no Term Grades
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

    /*********************************************************************************************************
    * @description Test deletion of Terms with Term Grades and preventing deletion setting is turned off
    */
    @isTest 
    static void testDeleteTermsWithTermGradesSettingOff() {  
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Prevent_Term_Deletion__c = TRUE));

        Term__c term = [SELECT Id FROM Term__c LIMIT 1];
               
        Test.startTest();
            delete term;
        Test.stopTest();
        
        List<Term__c> termsList = [SELECT Id FROM Term__c];      
        System.assertEquals(0, termsList.size());       
    }     
}