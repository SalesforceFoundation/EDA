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
* @date 2019
* @group Course Offering
* @group-content ../../ApexDocContent/CourseOfferings.htm
* @description Tests for COFF_CannotDelete_TDTM.
*/
@isTest
private with sharing class COFF_CannotDelete_TEST {
    @isTest
    private static void testPreventCourseOfferingDeletion() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                                                Prevent_Course_Offering_Deletion__c = true));
        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        Account bioProgram = new Account(Name = 'Biology Program');
        insert bioProgram;

        Contact[] contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(6);
        insert contacts;

        Course__c course = new Course__c(Name = 'Biology', Account__c = bioProgram.Id);
        insert course;

        Term__c term = new Term__c(Name = 'Fall', Account__c = bioProgram.Id);
        insert term;

        List<Course_Offering__c> courseOfferings = new List<Course_Offering__c>{
            new Course_Offering__c(Name = 'Bio Intro 101', Course__c = course.Id, Term__c = term.Id),
            new Course_Offering__c(Name = 'Bio Intro 102', Course__c = course.Id, Term__c = term.Id),
    		new Course_Offering__c(Name = 'Bio Intro 103', Course__c = course.Id, Term__c = term.Id),
			new Course_Offering__c(Name = 'Bio Intro 104', Course__c = course.Id, Term__c = term.Id),
            new Course_Offering__c(Name = 'Bio Intro 105', Course__c = course.Id, Term__c = term.Id),
            new Course_Offering__c(Name = 'Bio Intro 106', Course__c = course.Id, Term__c = term.Id),
            new Course_Offering__c(Name = 'Bio Intro 107', Course__c = course.Id, Term__c = term.Id)
        };
        insert courseOfferings;

        List<Course_Enrollment__c> courseConnections = new List<Course_Enrollment__c>{
            new Course_Enrollment__c(Contact__c = contacts[0].Id, Course_Offering__c = courseOfferings[0].Id),
            new Course_Enrollment__c(Contact__c = contacts[1].Id, Course_Offering__c = courseOfferings[1].Id),
            new Course_Enrollment__c(Contact__c = contacts[3].Id, Course_Offering__c = courseOfferings[3].Id)
        };
        insert courseConnections;

        List<Course_Offering_Schedule__c> courseOfferingSchedules = new List<Course_Offering_Schedule__c>{
            new Course_Offering_Schedule__c(Course_Offering__c = courseOfferings[0].Id),
            new Course_Offering_Schedule__c(Course_Offering__c = courseOfferings[1].Id),
            new Course_Offering_Schedule__c(Course_Offering__c = courseOfferings[2].Id),
            new Course_Offering_Schedule__c(Course_Offering__c = courseOfferings[5].Id)
        };
     	insert courseOfferingSchedules;

        List<Term_Grade__c> termGrades = new List<Term_Grade__c>{
            new Term_Grade__c(Course_Connection__c = courseConnections[0].Id),
            new Term_Grade__c(Course_Connection__c = courseConnections[1].Id),
            new Term_Grade__c(Course_Connection__c = courseConnections[2].Id)
        };
        insert termGrades;

		Test.startTest();
        Database.DeleteResult[] results = Database.delete(courseOfferings, false);
        Test.stopTest();
        UTIL_Debug.debug('****Delete results: ' + JSON.serializePretty(results));

        //Verifies only 1 Course Offering was deleted
        List<Course_Offering__c> returnCourseOfferings = [SELECT Id FROM Course_Offering__c WHERE Id IN :courseOfferings];
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

    @isTest
    private static void testAllowCourseOfferingDeletion() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                                                Prevent_Course_Offering_Deletion__c = false));
        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        Account bioProgram = new Account(Name = 'Biology Program');
        insert bioProgram;

        Contact[] contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(6);
        insert contacts;

        Course__c course = new Course__c(Name = 'Biology', Account__c = bioProgram.Id);
        insert course;

        Term__c term = new Term__c(Name = 'Fall', Account__c = bioProgram.Id);
        insert term;

        List<Course_Offering__c> courseOfferings = new List<Course_Offering__c>{
            new Course_Offering__c(Name = 'Bio Intro 101', Course__c = course.Id, Term__c = term.Id),
            new Course_Offering__c(Name = 'Bio Intro 102', Course__c = course.Id, Term__c = term.Id),
    		new Course_Offering__c(Name = 'Bio Intro 103', Course__c = course.Id, Term__c = term.Id),
			new Course_Offering__c(Name = 'Bio Intro 104', Course__c = course.Id, Term__c = term.Id),
            new Course_Offering__c(Name = 'Bio Intro 105', Course__c = course.Id, Term__c = term.Id),
            new Course_Offering__c(Name = 'Bio Intro 106', Course__c = course.Id, Term__c = term.Id),
            new Course_Offering__c(Name = 'Bio Intro 107', Course__c = course.Id, Term__c = term.Id)
        };
        insert courseOfferings;

        List<Course_Enrollment__c> courseConnections = new List<Course_Enrollment__c>{
            new Course_Enrollment__c(Contact__c = contacts[0].Id, Course_Offering__c = courseOfferings[0].Id),
            new Course_Enrollment__c(Contact__c = contacts[1].Id, Course_Offering__c = courseOfferings[1].Id),
            new Course_Enrollment__c(Contact__c = contacts[3].Id, Course_Offering__c = courseOfferings[3].Id)
        };
        insert courseConnections;

        List<Course_Offering_Schedule__c> courseOfferingSchedules = new List<Course_Offering_Schedule__c>{
            new Course_Offering_Schedule__c(Course_Offering__c = courseOfferings[0].Id),
            new Course_Offering_Schedule__c(Course_Offering__c = courseOfferings[1].Id),
            new Course_Offering_Schedule__c(Course_Offering__c = courseOfferings[2].Id),
            new Course_Offering_Schedule__c(Course_Offering__c = courseOfferings[5].Id)
        };
     	insert courseOfferingSchedules;

        List<Term_Grade__c> termGrades = new List<Term_Grade__c>{
            new Term_Grade__c(Course_Connection__c = courseConnections[0].Id),
            new Term_Grade__c(Course_Connection__c = courseConnections[1].Id),
            new Term_Grade__c(Course_Connection__c = courseConnections[2].Id)
        };
        insert termGrades;

		Test.startTest();
        Database.DeleteResult[] results = Database.delete(courseOfferings, false);
        Test.stopTest();
        UTIL_Debug.debug('****Delete results: ' + JSON.serializePretty(results));

        //Verifies all Course Offerings were deleted
        List<Course_Offering__c> returnCourseOfferings = [SELECT Id FROM Course_Offering__c WHERE Id IN :courseOfferings];
        System.assertEquals(0, returnCourseOfferings.size());
    }
}