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
* @group Course Offerings
* @group-content ../../ApexDocContent/CourseOfferings.htm
* @description Unit tests for COFF_PreventUpdate_TDTM. These tests
* make sure Course on a Course Offering record do not change when 
* Term Grades are assocaited with it.
*/


@isTest
private class COFF_PreventUpdate_TEST {
    
    @testSetup
    static void dataSetup() {
        
        // Insert an Account
        List<Account> department = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getAcademicAccRecTypeID());
        insert department;
        
        // Insert a Course
        Course__c course = new Course__c(Course_ID__c = 'Biology 101', Account__c = department[0].Id);
        insert course;
        
        //Insert a contact
        Contact con = UTIL_UnitTestData_TEST.getContact();
        insert con;
        
        // Insert a Course Offering
        UTIL_UnitTestData_TEST.createCourseOffering(NULL, NULL);
        
    
    }
    
    // Test update of Course with no Term Grades associated with Course Offering record
    
    @isTest 
    static void testWithNoTermGrade() {
    
        Course_Offering__c courseOffering = [SELECT Id, Course__c FROM Course_Offering__c LIMIT 1];
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        courseOffering.Course__c = course.Id;
        
        Test.startTest();
            update courseoffering;
        Test.stopTest();
        
        System.assertEquals(courseOffering.Course__c, course.Id);      
    }
    
    // Test error when Course is updated with Term Grades associated with Course Offering record
    
    @isTest 
    static void testWithTermGrade() {
        
        Course_Offering__c courseOffering = [SELECT Id, Course__c FROM Course_Offering__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];        
        Course__c course = [SELECT Id FROM Course__c LIMIT 1];
        
        // Insert Course Connection
        course_Enrollment__c courseEnrollment = UTIL_UnitTestData_TEST.getCourseConnection(con.Id, courseOffering.Id);
        insert courseEnrollment;
        
        // Insert Term Grade
        Term_Grade__c termGrade = UTIL_UnitTestData_TEST.getTermGrade(con.Id, courseOffering.Id, courseEnrollment.Id);
        insert termGrade;
         
        try {
            Test.startTest();
                courseOffering.course__c = course.Id;
                update courseoffering;
            Test.stopTest();    
        } catch(Exception error) {
              System.assert(error.getMessage().contains(Label.CannotChangeCourse));               
        }    
    }
    
}