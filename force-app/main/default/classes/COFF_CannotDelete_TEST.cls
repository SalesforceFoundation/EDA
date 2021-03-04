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

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORSå
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
* @group Course Offering
* @group-content ../../ApexDocContent/CourseOfferings.htm
* @description Tests for COFF_CannotDelete_TDTM.
*/
@isTest
private with sharing class COFF_CannotDelete_TEST {
    /*********************************************************************************************************
    * @description Test method to test the following:
    * (1) If Prevent_Course_Offering_Deletion__c is enabled in Hierarchy Settings, and a Course Offering
    * has child records, it cannot be deleted.
    * (2) If Prevent_Course_Offering_Deletion__c is enabled in Hierarchy Settings, and a Course Offering
    * does not have any child records, it can be deleted.
    */
    @isTest
    private static void testPreventCourseOfferingDeletion() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                        Prevent_Course_Offering_Deletion__c = true));

        Contact[] contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(6);
        insert contacts;

        List<Course_Offering__c> courseOfferings = new List<Course_Offering__c>();
        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(NULL, NULL);
        Course_Offering__c courseOffering2 = UTIL_UnitTestdata_TEST.createCourseOffering(NULL, NULL);
        Course_Offering__c courseOffering3 = UTIL_UnitTestdata_TEST.createCourseOffering(NULL, NULL);
        Course_Offering__c courseOffering4 = UTIL_UnitTestdata_TEST.createCourseOffering(NULL, NULL);
        Course_Offering__c courseOffering5 = UTIL_UnitTestdata_TEST.createCourseOffering(NULL, NULL);
        Course_Offering__c courseOffering6 = UTIL_UnitTestdata_TEST.createCourseOffering(NULL, NULL);
        Course_Offering__c courseOffering7 = UTIL_UnitTestdata_TEST.createCourseOffering(NULL, NULL);
        courseOfferings.add(courseOffering1);
        courseOfferings.add(courseOffering2);
        courseOfferings.add(courseOffering3);
        courseOfferings.add(courseOffering4);
        courseOfferings.add(courseOffering5);
        courseOfferings.add(courseOffering6);
        courseOfferings.add(courseOffering7);

        List<Course_Enrollment__c> courseConnections = new List<Course_Enrollment__c>();
        Course_Enrollment__c courseConnection1 = UTIL_UnitTestdata_TEST.getCourseConnection(contacts[0].Id, courseOfferings[0].Id);
        Course_Enrollment__c courseConnection2 = UTIL_UnitTestdata_TEST.getCourseConnection(contacts[1].Id, courseOfferings[1].Id);
        Course_Enrollment__c courseConnection3 = UTIL_UnitTestdata_TEST.getCourseConnection(contacts[3].Id, courseOfferings[3].Id);
		courseConnections.add(courseConnection1);
        courseConnections.add(courseConnection2);
        courseConnections.add(courseConnection3);
        insert courseConnections;

        List<Course_Offering_Schedule__c> courseOfferingSchedules = new List<Course_Offering_Schedule__c>();
        Course_Offering_Schedule__c courseOfferingSchedule1 = UTIL_UnitTestdata_TEST.createCourseOfferingSchedule(courseOfferings[0].Id);
        Course_Offering_Schedule__c courseOfferingSchedule2 = UTIL_UnitTestdata_TEST.createCourseOfferingSchedule(courseOfferings[1].Id);
        Course_Offering_Schedule__c courseOfferingSchedule3 = UTIL_UnitTestdata_TEST.createCourseOfferingSchedule(courseOfferings[2].Id);
        Course_Offering_Schedule__c courseOfferingSchedule4 = UTIL_UnitTestdata_TEST.createCourseOfferingSchedule(courseOfferings[5].Id);
        courseOfferingSchedules.add(courseOfferingSchedule1);
        courseOfferingSchedules.add(courseOfferingSchedule2);
        courseOfferingSchedules.add(courseOfferingSchedule3);
        courseOfferingSchedules.add(courseOfferingSchedule4);
     	insert courseOfferingSchedules;

        List<Term_Grade__c> termGrades = new List<Term_Grade__c>();
        Term_Grade__c termGrade1 = UTIL_UnitTestData_TEST.getTermGrade(NULL, NULL, courseConnections[0].Id);
        Term_Grade__c termGrade2 = UTIL_UnitTestData_TEST.getTermGrade(NULL, NULL, courseConnections[1].Id);
        Term_Grade__c termGrade3 = UTIL_UnitTestData_TEST.getTermGrade(NULL, NULL, courseConnections[2].Id);
        termGrades.add(termGrade1);
        termGrades.add(termGrade2);
        termGrades.add(termGrade3);
        insert termGrades;

		Test.startTest();
        Database.DeleteResult[] results = Database.delete(courseOfferings, false);
        Test.stopTest();

        //Verifies only 1 Course Offering was deleted
        List<Course_Offering__c> returnCourseOfferings = [SELECT Id
                                                          FROM Course_Offering__c
                                                          WHERE Id IN :courseOfferings];
        System.assertEquals(5, returnCourseOfferings.size());

        //Verifies Course Offering with Course Connection was not deleted
        System.assertEquals(false, results[3].success);
        System.assertEquals(Label.CannotDelete, results[3].errors[0].message);

        //Verifies Course Offering with Course Offering Schedule was not deleted
        System.assertEquals(false, results[5].success);
        System.assertEquals(Label.CannotDelete, results[5].errors[0].message);

        //Verifies Course Offering with Term Grade and Course Connection was not deleted
        System.assertEquals(false, results[0].success);
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);

         //Verifies Course Offering with Term Grade and Course Offering Schedule was not deleted
        System.assertEquals(false, results[2].success);
        System.assertEquals(Label.CannotDelete, results[2].errors[0].message);

        //Verifies Course Offering with Term Grade, Course Connection, and Course Offering Schedule was not deleted
        System.assertEquals(false, results[1].success);
        System.assertEquals(Label.CannotDelete, results[1].errors[0].message);
    }

    /*********************************************************************************************************
    * @description Test method to test the following:
    * (1) If Prevent_Course_Offering_Deletion__c is disabled in Hierarchy Settings, and a Course Offering
    * has child records, it can be deleted.
    * (2) If Prevent_Course_Offering_Deletion__c is disabled in Hierarchy Settings, and a Course Offering
    * does not have any child records, it can be deleted.
    */
    @isTest
    private static void testAllowCourseOfferingDeletion() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                        Prevent_Course_Offering_Deletion__c = false));

        Contact[] contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(6);
        insert contacts;

        List<Course_Offering__c> courseOfferings = new List<Course_Offering__c>();
        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(NULL, NULL);
        Course_Offering__c courseOffering2 = UTIL_UnitTestdata_TEST.createCourseOffering(NULL, NULL);
        Course_Offering__c courseOffering3 = UTIL_UnitTestdata_TEST.createCourseOffering(NULL, NULL);
        Course_Offering__c courseOffering4 = UTIL_UnitTestdata_TEST.createCourseOffering(NULL, NULL);
        Course_Offering__c courseOffering5 = UTIL_UnitTestdata_TEST.createCourseOffering(NULL, NULL);
        Course_Offering__c courseOffering6 = UTIL_UnitTestdata_TEST.createCourseOffering(NULL, NULL);
        Course_Offering__c courseOffering7 = UTIL_UnitTestdata_TEST.createCourseOffering(NULL, NULL);
        courseOfferings.add(courseOffering1);
        courseOfferings.add(courseOffering2);
        courseOfferings.add(courseOffering3);
        courseOfferings.add(courseOffering4);
        courseOfferings.add(courseOffering5);
        courseOfferings.add(courseOffering6);
        courseOfferings.add(courseOffering7);

		List<Course_Enrollment__c> courseConnections = new List<Course_Enrollment__c>();
        Course_Enrollment__c courseConnection1 = UTIL_UnitTestdata_TEST.getCourseConnection(contacts[0].Id, courseOfferings[0].Id);
        Course_Enrollment__c courseConnection2 = UTIL_UnitTestdata_TEST.getCourseConnection(contacts[1].Id, courseOfferings[1].Id);
        Course_Enrollment__c courseConnection3 = UTIL_UnitTestdata_TEST.getCourseConnection(contacts[3].Id, courseOfferings[3].Id);
		courseConnections.add(courseConnection1);
        courseConnections.add(courseConnection2);
        courseConnections.add(courseConnection3);
        insert courseConnections;

        List<Course_Offering_Schedule__c> courseOfferingSchedules = new List<Course_Offering_Schedule__c>();
        Course_Offering_Schedule__c courseOfferingSchedule1 = UTIL_UnitTestdata_TEST.createCourseOfferingSchedule(courseOfferings[0].Id);
        Course_Offering_Schedule__c courseOfferingSchedule2 = UTIL_UnitTestdata_TEST.createCourseOfferingSchedule(courseOfferings[1].Id);
        Course_Offering_Schedule__c courseOfferingSchedule3 = UTIL_UnitTestdata_TEST.createCourseOfferingSchedule(courseOfferings[2].Id);
        Course_Offering_Schedule__c courseOfferingSchedule4 = UTIL_UnitTestdata_TEST.createCourseOfferingSchedule(courseOfferings[5].Id);
        courseOfferingSchedules.add(courseOfferingSchedule1);
        courseOfferingSchedules.add(courseOfferingSchedule2);
        courseOfferingSchedules.add(courseOfferingSchedule3);
        courseOfferingSchedules.add(courseOfferingSchedule4);
     	insert courseOfferingSchedules;

		List<Term_Grade__c> termGrades = new List<Term_Grade__c>();
        Term_Grade__c termGrade1 = UTIL_UnitTestData_TEST.getTermGrade(NULL, NULL, courseConnections[0].Id);
        Term_Grade__c termGrade2 = UTIL_UnitTestData_TEST.getTermGrade(NULL, NULL, courseConnections[1].Id);
        Term_Grade__c termGrade3 = UTIL_UnitTestData_TEST.getTermGrade(NULL, NULL, courseConnections[2].Id);
        termGrades.add(termGrade1);
        termGrades.add(termGrade2);
        termGrades.add(termGrade3);
        insert termGrades;

		Test.startTest();
        Database.DeleteResult[] results = Database.delete(courseOfferings, false);
        Test.stopTest();

        //Verifies all Course Offerings were deleted
        List<Course_Offering__c> returnCourseOfferings = [SELECT Id
                                                          FROM Course_Offering__c
                                                          WHERE Id IN :courseOfferings];
        System.assertEquals(0, returnCourseOfferings.size());
    }
}