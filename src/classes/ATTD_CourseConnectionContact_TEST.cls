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
* @group Attendance Events
* @group-content ../../ApexDocContent/AttendanceEvents.htm
* @description Tests specific to Attendance Events
*/
@isTest
public class ATTD_CourseConnectionContact_TEST {
	
    /*Insert Attendance Event when Course Connection matches Contact lookup field*/
    @isTest
    public static void insertAttendanceCourseConnectionContactMatch() {
        //Test data setup
        Contact testContact = UTIL_UnitTestData_TEST.getContact();
        insert testContact;
        
        Course_Enrollment__c testCourseConnection = UTIL_UnitTestData_TEST.getCourseConnection();
        testCourseConnection.Contact__c = testContact.Id;
        insert testCourseConnection;
        
        //Test run
        Attendance_Event__c testAttendanceEvent = UTIL_UnitTestData_TEST.getAttendanceEvent();
        testAttendanceEvent.Contact__c = testContact.Id;
        testAttendanceEvent.Course_Connection__c = testCourseConnection.Id;
        insert testAttendanceEvent;

        //Assert
        List<Attendance_Event__c> assertAttendanceEvents = [SELECT Id FROM Attendance_Event__c];
        system.assertEquals(1, assertAttendanceEvents.size());
        system.assertEquals(testAttendanceEvent.Id, assertAttendanceEvents[0].Id);
    }

    /*Update Attendance Event when Course Connection matches Contact lookup field*/
    @isTest
    public static void updateAttendanceCourseConnectionContactMatch() {
        //Test data setup
        Contact testContact = UTIL_UnitTestData_TEST.getContact();
        insert testContact;
        
        Course_Enrollment__c testCourseConnection = UTIL_UnitTestData_TEST.getCourseConnection();
        testCourseConnection.Contact__c = testContact.Id;
        insert testCourseConnection;
        
        //Test run
        Attendance_Event__c testAttendanceEvent = UTIL_UnitTestData_TEST.getAttendanceEvent();
        insert testAttendanceEvent;
        testAttendanceEvent.Contact__c = testContact.Id;
        testAttendanceEvent.Course_Connection__c = testCourseConnection.Id;
        update testAttendanceEvent;

        //Assert
        List<Attendance_Event__c> assertAttendanceEvents = [SELECT Id, Contact__c FROM Attendance_Event__c];
        system.assertEquals(1, assertAttendanceEvents.size());
        system.assertEquals(testAttendanceEvent.Id, assertAttendanceEvents[0].Id);
        system.assertEquals(testContact.Id, assertAttendanceEvents[0].Contact__c);
    }
    
    /*Insert Attendance Event when Course Connection does not match Contact lookup field and both filled out*/
    @isTest
    public static void insertAttendanceCourseConnectionContactMismatchBothFilled() {
        //Test data setup
        List<Contact> testContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert testContacts;
        
        Course_Enrollment__c testCourseConnection = UTIL_UnitTestData_TEST.getCourseConnection();
        testCourseConnection.Contact__c = testContacts[0].Id;
        insert testCourseConnection;
        
        //Test run
        Attendance_Event__c testAttendanceEvent = UTIL_UnitTestData_TEST.getAttendanceEvent();
        testAttendanceEvent.Contact__c = testContacts[1].Id;
        testAttendanceEvent.Course_Connection__c = testCourseConnection.Id;
        Database.saveResult results = Database.insert(testAttendanceEvent, false);

        //Assert
        List<Attendance_Event__c> assertAttendanceEvents = [SELECT Id FROM Attendance_Event__c];
        System.assertEquals(false, results.success);    
        System.assertEquals(0, assertAttendanceEvents.size());
        System.assertEquals(Label.AttendanceCourseConnectionContactMismatch, results.errors[0].message);
    }
    
    /*Update Attendance Event when Course Connection does not match Contact lookup field and both filled out*/
    @isTest
    public static void updateAttendanceCourseConnectionContactMismatchBothFilled() {
        //Test data setup
        List<Contact> testContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert testContacts;
        
        Course_Enrollment__c testCourseConnection = UTIL_UnitTestData_TEST.getCourseConnection();
        testCourseConnection.Contact__c = testContacts[0].Id;
        insert testCourseConnection;
        
        //Test run
        Attendance_Event__c testAttendanceEvent = UTIL_UnitTestData_TEST.getAttendanceEvent();
        testAttendanceEvent.Contact__c = testContacts[0].Id;
        testAttendanceEvent.Course_Connection__c = testCourseConnection.Id;
        insert testAttendanceEvent;
        testAttendanceEvent.Contact__c = testContacts[1].Id;
        Database.upsertResult results = Database.upsert(testAttendanceEvent, false); 

        //Assert
        List<Attendance_Event__c> assertAttendanceEvents = [SELECT Id, Contact__c FROM Attendance_Event__c];
        System.assertEquals(false, results.success);    
        System.assertEquals(testContacts[0].Id, assertAttendanceEvents[0].Contact__c);
        System.assertEquals(Label.AttendanceCourseConnectionContactMismatch, results.errors[0].message);
    }
    
    /*Insert Attendance Event when Course Connection does not match Contact lookup field and only Contact empty*/
    @isTest
    public static void insertAttendanceCourseConnectionEmptyContactMismatch() {
        //Test data setup
        List<Contact> testContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert testContacts;
        
        Course_Enrollment__c testCourseConnection = UTIL_UnitTestData_TEST.getCourseConnection();
        testCourseConnection.Contact__c = testContacts[0].Id;
        insert testCourseConnection;
        
        //Test run
        Attendance_Event__c testAttendanceEvent = UTIL_UnitTestData_TEST.getAttendanceEvent();
        testAttendanceEvent.Course_Connection__c = testCourseConnection.Id;
        Database.saveResult results = Database.insert(testAttendanceEvent, false);

        //Assert
        List<Attendance_Event__c> assertAttendanceEvents = [SELECT Id, Contact__c FROM Attendance_Event__c];
        System.assertEquals(true, results.success);    
        System.assertEquals(1, assertAttendanceEvents.size());
        System.assertEquals(testContacts[0].Id, assertAttendanceEvents[0].Contact__c);
    }
    
    /*Update Attendance Event when Course Connection does not match Contact lookup field and only Contact empty*/
    @isTest
    public static void updateAttendanceCourseConnectionEmptyContactMismatch() {
        //Test data setup
        List<Contact> testContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert testContacts;
        
        Course_Enrollment__c testCourseConnection = UTIL_UnitTestData_TEST.getCourseConnection();
        testCourseConnection.Contact__c = testContacts[0].Id;
        insert testCourseConnection;
        
        //Test run
        Attendance_Event__c testAttendanceEvent = UTIL_UnitTestData_TEST.getAttendanceEvent();
        testAttendanceEvent.Course_Connection__c = testCourseConnection.Id;
        testAttendanceEvent.Contact__c = testContacts[0].Id;
        insert testAttendanceEvent;
        testAttendanceEvent.Contact__c = null;
        Database.upsertResult results = Database.upsert(testAttendanceEvent, false); 

        //Assert
        List<Attendance_Event__c> assertAttendanceEvents = [SELECT Id, Contact__c FROM Attendance_Event__c];
        System.assertEquals(true, results.success);    
        System.assertEquals(1, assertAttendanceEvents.size());
        System.assertEquals(testContacts[0].Id, assertAttendanceEvents[0].Contact__c);
    }
    
    /*Insert Attendance Event when Course Connection does not match Contact lookup field and only Course Connection empty*/
    @isTest
    public static void insertAttendanceEmptyCourseConnectionContactMismatch() {
        //Test data setup
        List<Contact> testContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert testContacts;
        
        //Test run
        Attendance_Event__c testAttendanceEvent = UTIL_UnitTestData_TEST.getAttendanceEvent();
        testAttendanceEvent.Contact__c = testContacts[0].Id;
        Database.saveResult results = Database.insert(testAttendanceEvent, false);

        //Assert
        List<Attendance_Event__c> assertAttendanceEvents = [SELECT Id, Contact__c FROM Attendance_Event__c];
        System.assertEquals(true, results.success);    
        System.assertEquals(1, assertAttendanceEvents.size());
        System.assertEquals(testContacts[0].Id, assertAttendanceEvents[0].Contact__c);
    }
    
    /*Update Attendance Event when Course Connection does not match Contact lookup field and only Course Connection empty*/
    @isTest
    public static void updateAttendanceEmptyCourseConnectionContactMismatch() {
        //Test data setup
        List<Contact> testContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert testContacts;
        
        //Test run
        Attendance_Event__c testAttendanceEvent = UTIL_UnitTestData_TEST.getAttendanceEvent();
        testAttendanceEvent.Contact__c = testContacts[0].Id;
        insert testAttendanceEvent;
        testAttendanceEvent.Contact__c = testContacts[1].Id;
        Database.upsertResult results = Database.upsert(testAttendanceEvent, false);

        //Assert
        List<Attendance_Event__c> assertAttendanceEvents = [SELECT Id, Contact__c FROM Attendance_Event__c];
        System.assertEquals(true, results.success);    
        System.assertEquals(1, assertAttendanceEvents.size());
        System.assertEquals(testContacts[1].Id, assertAttendanceEvents[0].Contact__c);
    }
    
    /*Insert Attendance Event when Course Connection and Contact lookup field are both empty*/
    @isTest
    public static void insertAttendanceCourseConnectionContactBothEmpty() {
        //Test data setup
        
        //Test run
        Attendance_Event__c testAttendanceEvent = UTIL_UnitTestData_TEST.getAttendanceEvent();
        Database.saveResult results = Database.insert(testAttendanceEvent, false);

        //Assert
        List<Attendance_Event__c> assertAttendanceEvents = [SELECT Id, Contact__c FROM Attendance_Event__c];
        System.assertEquals(true, results.success);    
        System.assertEquals(1, assertAttendanceEvents.size());
    }
    
    /*Update Attendance Event when Course Connection and Contact lookup field are both empty*/
    @isTest
    public static void updateAttendanceCourseConnectionContactBothEmpty() {
        //Test data setup

        //Test run
        Attendance_Event__c testAttendanceEvent = UTIL_UnitTestData_TEST.getAttendanceEvent();
        testAttendanceEvent.Unexcused__c = false;
        insert testAttendanceEvent;
        testAttendanceEvent.Unexcused__c = true;
        Database.upsertResult results = Database.upsert(testAttendanceEvent, false);

        //Assert
        List<Attendance_Event__c> assertAttendanceEvents = [SELECT Id, Unexcused__c FROM Attendance_Event__c];
        System.assertEquals(true, results.success);    
        System.assertEquals(1, assertAttendanceEvents.size());
        System.assertEquals(true, assertAttendanceEvents[0].Unexcused__c);
    }
}