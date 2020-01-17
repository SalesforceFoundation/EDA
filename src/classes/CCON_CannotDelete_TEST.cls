/*
	Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group Course Enrollments
* @group-content ../../ApexDocContent/CourseEnrollments.htm
* @description Tests for CCON_CannotDelete_TDTM.
*/
@isTest
private with sharing class CCON_CannotDelete_TEST {
    /*********************************************************************************************************
    * @description Test method to test the following:
    * (1) If Prevent_Course_Connection_Deletion__c is enabled in Hierarchy Settings, and a Course Connection
    * has child records, it should not be deleted.
    * (2) If Prevent_Course_Connection_Deletion__c is enabled in Hierarchy Settings, and a Course Connection
    * does not have any child records, it can be deleted.
    */
    @isTest
    private static void testPreventDeletionCourseConnectionLogic() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
        																		Prevent_Course_Connection_Deletion__c = true));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        Contact[] contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(6);
        insert contacts;

        Course_Offering__c courseOffering = UTIL_UnitTestData_TEST.createCourseOffering(NULL, NULL);

        List<Course_Enrollment__c> courseConnections = new List<Course_Enrollment__c>();
        Course_Enrollment__c courseConnection1 = UTIL_UnitTestdata_TEST.getCourseConnection(contacts[0].Id, courseOffering.Id);
        Course_Enrollment__c courseConnection2 = UTIL_UnitTestdata_TEST.getCourseConnection(contacts[1].Id, courseOffering.Id);
        Course_Enrollment__c courseConnection3 = UTIL_UnitTestdata_TEST.getCourseConnection(contacts[2].Id, courseOffering.Id);
        Course_Enrollment__c courseConnection4 = UTIL_UnitTestdata_TEST.getCourseConnection(contacts[3].Id, courseOffering.Id);
        Course_Enrollment__c courseConnection5 = UTIL_UnitTestdata_TEST.getCourseConnection(contacts[4].Id, courseOffering.Id);
        courseConnections.add(courseConnection1);
        courseConnections.add(courseConnection2);
        courseConnections.add(courseConnection3);
        courseConnections.add(courseConnection4);
        courseConnections.add(courseConnection5);
        insert courseConnections;

        List<Term_Grade__c> termGrades = new List<Term_Grade__c>();
        Term_Grade__c termGrade1 = UTIL_UnitTestData_TEST.getTermGrade(contacts[0].Id, courseOffering.Id, courseConnections[0].Id);
        Term_Grade__c termGrade2 = UTIL_UnitTestData_TEST.getTermGrade(contacts[2].Id, courseOffering.Id, courseConnections[2].Id);
        termGrades.add(termGrade1);
        termGrades.add(termGrade2);

        List<Attendance_Event__c> attendanceEvents = new List<Attendance_Event__c>();
        Attendance_Event__c attendanceEvent1 = UTIL_UnitTestData_TEST.getAttendanceEvent(contacts[1].Id, courseConnections[1].Id, NULL, NULL);
        Attendance_Event__c attendanceEvent2 = UTIL_UnitTestData_TEST.getAttendanceEvent(contacts[2].Id, courseConnections[2].Id, NULL, NULL);
        attendanceEvents.add(attendanceEvent1);
        attendanceEvents.add(attendanceEvent2);

        insert termGrades;
        insert attendanceEvents;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(courseConnections, false);
        Test.stopTest();


        //Verifies only 2 Course Connection was deleted
        List<Course_Enrollment__c> returnCourseConnections = [SELECT Id
                                                              FROM Course_Enrollment__c
                                                              WHERE Id IN :courseConnections];
        System.assertEquals(3, returnCourseConnections.size());

        //Verifies Course Connection with Term Grade was not deleted
        System.assertEquals(false, results[0].success);
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);

        //Verifies Course Connection with Attendance Event was not deleted
        System.assertEquals(false, results[1].success);
        System.assertEquals(Label.CannotDelete, results[1].errors[0].message);

        //Verifies Course Connection with Attendance Event and Term Grade was not deleted.
        System.assertEquals(false, results[2].success);
        System.assertEquals(Label.CannotDelete, results[2].errors[0].message);

    }

    /*********************************************************************************************************
    * @description Test method to test the following:
    * (1) If Prevent_Course_Connection_Deletion__c is disabled in Hierarchy Settings, and a Course Connection
    * has child records, it can be deleted.
    * (2) If Prevent_Course_Connection_Deletion__c is disabled in Hierarchy Settings, and a Course Connection
    * does not have any child records, it can be deleted.
    */
    @isTest
    private static void testAllowDeletionOfCourseConnection() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
        																		Prevent_Course_Connection_Deletion__c = false));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        Contact[] contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(6);
        insert contacts;

        Course_Offering__c courseOffering = UTIL_UnitTestData_TEST.createCourseOffering(NULL, NULL);

        List<Course_Enrollment__c> courseConnections = new List<Course_Enrollment__c>();
        Course_Enrollment__c courseConnection1 = UTIL_UnitTestdata_TEST.getCourseConnection(contacts[0].Id, courseOffering.Id);
        Course_Enrollment__c courseConnection2 = UTIL_UnitTestdata_TEST.getCourseConnection(contacts[1].Id, courseOffering.Id);
        Course_Enrollment__c courseConnection3 = UTIL_UnitTestdata_TEST.getCourseConnection(contacts[2].Id, courseOffering.Id);
        Course_Enrollment__c courseConnection4 = UTIL_UnitTestdata_TEST.getCourseConnection(contacts[3].Id, courseOffering.Id);
        Course_Enrollment__c courseConnection5 = UTIL_UnitTestdata_TEST.getCourseConnection(contacts[4].Id, courseOffering.Id);
        courseConnections.add(courseConnection1);
        courseConnections.add(courseConnection2);
        courseConnections.add(courseConnection3);
        courseConnections.add(courseConnection4);
        courseConnections.add(courseConnection5);
        insert courseConnections;

		List<Term_Grade__c> termGrades = new List<Term_Grade__c>();
        Term_Grade__c termGrade1 = UTIL_UnitTestData_TEST.getTermGrade(contacts[0].Id, courseOffering.Id, courseConnections[0].Id);
        Term_Grade__c termGrade2 = UTIL_UnitTestData_TEST.getTermGrade(contacts[2].Id, courseOffering.Id, courseConnections[2].Id);
        termGrades.add(termGrade1);
        termGrades.add(termGrade2);

        List<Attendance_Event__c> attendanceEvents = new List<Attendance_Event__c>();
        Attendance_Event__c attendanceEvent1 = UTIL_UnitTestData_TEST.getAttendanceEvent(contacts[1].Id, courseConnections[1].Id, NULL, NULL);
        Attendance_Event__c attendanceEvent2 = UTIL_UnitTestData_TEST.getAttendanceEvent(contacts[2].Id, courseConnections[2].Id, NULL, NULL);
        attendanceEvents.add(attendanceEvent1);
        attendanceEvents.add(attendanceEvent2);

        insert termGrades;
        insert attendanceEvents;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(courseConnections, false);
        Test.stopTest();

        //Verifies only all Course Connections were deleted
        List<Course_Enrollment__c> returnCourseConnections = [SELECT Id
                                                              FROM Course_Enrollment__c
                                                              WHERE Id IN :courseConnections];
        System.assertEquals(0, returnCourseConnections.size());
    }
}