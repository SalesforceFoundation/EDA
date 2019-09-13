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
* @group Course Enrollments
* @group-content ../../ApexDocContent/CourseEnrollments.htm
* @description Unit tests for CCON_PreventUpdate_TDTM. These tests
* make sure Contact or Course Offering on a Course Connection do not
* change when Term Grades or Attendance Events are assocaited to it.
*/


@isTest
private class CCON_PreventUpdate_TEST {
    
    @testSetup
    static void dataSetup() {
    
        //Insert a contact
        Contact con = UTIL_UnitTestData_TEST.getContact();
        insert con;
        
        // Insert a Course Offering
        Course_offering__c courseOffering = UTIL_UnitTestData_TEST.createCourseOffering(NULL, NULL);
        
        // Insert Course Connection
        Course_Enrollment__c courseEnrollment = UTIL_UnitTestData_TEST.getCourseConnection(con.Id, courseOffering.Id);
        insert courseEnrollment;
        
    }
    
    // Test Contact and Course Offering updates with no related records on Course Connection 
    
    @isTest 
    static void testUpdateCourseConnWithNoRelatedRecords() {
    
        //Insert a contact
        Contact newCon = UTIL_UnitTestData_TEST.getUniqueContact(01);
        insert newCon;
        
        // Insert a Course Offering
        Course_offering__c newCourseOffering = UTIL_UnitTestData_TEST.createCourseOffering(NULL, NULL);
        
        Course_Enrollment__c courseEnrollment = [SELECT Id, Contact__c, Course_Offering__c FROM Course_Enrollment__c LIMIT 1];
        courseEnrollment.Contact__c = newCon.Id;
        courseEnrollment.Course_offering__c = newCourseOffering.Id;
        Test.startTest();
            update courseEnrollment;
        Test.stopTest();    
        
        System.assertEquals(courseEnrollment.Contact__c, newCon.Id);
        System.assertEquals(courseEnrollment.Course_offering__c, newCourseOffering.Id);
    
    }
    
    // Test Contact and Course Offering updates with Term Grades related to the Course Connection 
    
    @isTest 
    static void testUpdateCourseConnWithTermGrade() {
    
        Course_Enrollment__c courseEnrollment = [SELECT Id, Contact__c, Course_Offering__c FROM Course_Enrollment__c LIMIT 1];
        Course_offering__c courseOffering = [SELECT Id FROM Course_Offering__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        courseEnrollment.Course_Offering__c = courseOffering.Id;
        update courseEnrollment;
        
        // Insert Term Grade
        Term_Grade__c termGrade = UTIL_UnitTestData_TEST.getTermGrade(con.Id, courseOffering.Id, courseEnrollment.Id);
        insert termGrade;
        
        //Insert a contact
        Contact newCon = UTIL_UnitTestData_TEST.getUniqueContact(02);
        insert newCon;
        
        // Insert a Course Offering
        Course_offering__c newCourseOffering = UTIL_UnitTestData_TEST.createCourseOffering(NULL, NULL);
        
        courseEnrollment.Course_Offering__c = newCourseOffering.Id;
        courseEnrollment.Contact__c = newCon.Id;
        try {
            Test.startTest();
                update courseEnrollment;
            Test.stopTest();    
        } catch (Exception error) {
            System.assert(error.getMessage().contains(Label.CannotChangeContactAndCourseOffering));      
        }
    }
    
    // Test Contact and Course Offering updates with Attendance Events related to the Course Connection 
    
    @isTest 
    static void testUpdateCourseConnWithAttendance() {
    
        Course_Enrollment__c courseEnrollment = [SELECT Id, Contact__c, Course_Offering__c FROM Course_Enrollment__c LIMIT 1];
        Course_offering__c courseOffering = [SELECT Id FROM Course_Offering__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        courseEnrollment.Course_Offering__c = courseOffering.Id;
        update courseEnrollment;
        
        // Insert Attendance Event
        Attendance_Event__c AttendanceEvent = UTIL_UnitTestData_TEST.getAttendanceEvent();
        AttendanceEvent.Contact__c = con.Id;
        AttendanceEvent.Course_Connection__c = courseEnrollment.Id;
        insert AttendanceEvent;
        
        //Insert a contact
        Contact newCon = UTIL_UnitTestData_TEST.getUniqueContact(03);
        insert newCon;
        
        // Insert a Course Offering
        Course_offering__c newCourseOffering = UTIL_UnitTestData_TEST.createCourseOffering(NULL, NULL);
        
        courseEnrollment.Course_offering__c = newCourseOffering.Id;
        courseEnrollment.Contact__c = newCon.Id;
        try {
            Test.startTest();
                update courseEnrollment;
            Test.stopTest();    
        } catch (Exception error) {
            System.assert(error.getMessage().contains(Label.CannotChangeContactAndCourseOffering));      
        }
    }
    
    // Test Contact and Course Offering updates with Term Grades and Attendance Events related to the Course Connection 
     
    @isTest 
    static void testUpdateCourseConnWithRelatedRecords() {
    
        Course_Enrollment__c courseEnrollment = [SELECT Id, Contact__c, Course_Offering__c FROM Course_Enrollment__c LIMIT 1];
        Course_offering__c courseOffering = [SELECT Id FROM Course_Offering__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        courseEnrollment.Course_Offering__c = courseOffering.Id;
        update courseEnrollment;
        
        // Insert Term Grade
        Term_Grade__c termGrade = UTIL_UnitTestData_TEST.getTermGrade(con.Id, courseOffering.Id, courseEnrollment.Id);
        insert termGrade;
        
        // Insert Attendance Event
        Attendance_Event__c AttendanceEvent = UTIL_UnitTestData_TEST.getAttendanceEvent();
        AttendanceEvent.Contact__c = con.Id;
        AttendanceEvent.Course_Connection__c = courseEnrollment.Id;
        insert AttendanceEvent;
        
        //Insert a contact
        Contact newCon = UTIL_UnitTestData_TEST.getUniqueContact(04);
        insert newCon;
        
        // Insert a Course Offering
        Course_offering__c newCourseOffering = UTIL_UnitTestData_TEST.createCourseOffering(NULL, NULL);
        
        courseEnrollment.Course_offering__c = newCourseOffering.Id;
        courseEnrollment.Contact__c = newCon.Id;
        try {
            Test.startTest();
                update courseEnrollment;
            Test.stopTest();    
        } catch (Exception error) {
            System.assert(error.getMessage().contains(Label.CannotChangeContactAndCourseOffering));      
        }
    }
        
}