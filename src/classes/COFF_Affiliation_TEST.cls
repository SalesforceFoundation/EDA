/*
    Copyright (c) 2015, Salesforce.org
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
* @date 2015
* @group Course Offering
* @group-content ../../ApexDocContent/CourseOfferings.htm
* @description Tests specific to Course Offering.
*/
@isTest
public with sharing class COFF_Affiliation_TEST {

    private static Account university;
    private static Account dpt;
    private static Course__c course;
    private static Term__c term;
    private static Contact faculty;

    private static void setup() {
        //Create university
        university = new Account(Name = 'Advanced University');
        insert university;

        //Create department
        dpt = new Account(Name = 'Biology Department', Parent = university);
        insert dpt;

        //Create Course
        course = new Course__c(Course_ID__c = 'Biology 101', Account__c = dpt.Id, Credit_Hours__c = 40,
        Description__c = 'Intro to Biology');
        insert course;

        //Create Term
        term = new Term__c(Account__c = university.Id, Start_Date__c = System.today() + 5, End_Date__c = System.today() + 90);
        insert term;

        //Create faculty member
        faculty = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert faculty;
    }

    private static void enableCourseConnections() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Enable_Course_Connections__c = true,
                Faculty_RecType__c = UTIL_Describe.getFacultyConnectionRecType()
            )
        );
    }

    private static Boolean recordTypesExist() {
        return (UTIL_Describe.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId') && UTIL_Describe.getFacultyConnectionRecType() != null);
    }

    /*********************************************************************************************************
    * @description Verifies that an Affiliation to the Department is automatically created when a Course Offering
    * with a value in the Faculty field is created and that Contact did not already have an Affiliation to that
    * Department.
    */
    @isTest
    public static void newCourseOffering() {
        setup();

        //Create Course Offering with Faculty member
        Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID,
        Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
        Test.startTest();
        insert offering;
        Test.stopTest();

        //Since no previous Affl to the Dpt existed, an Affl should have been automatically created for the faculty member
        List<Affiliation__c> affls = [select Contact__c, Account__c, Role__c, StartDate__c, EndDate__c from Affiliation__c
        where Contact__r.Id = :faculty.Id and Role__c = 'Faculty'];
        System.assertEquals(1, affls.size());
        System.assertEquals('Faculty', affls[0].Role__c);
        System.assertEquals(term.Start_Date__c, affls[0].StartDate__c);
        System.assertEquals(term.End_Date__c, affls[0].EndDate__c);

        //A Course Enrollment should have been automatically created
        List<Course_Enrollment__c> enrolls = [select Contact__c, Course_Offering__c, Affiliation__c from Course_Enrollment__c
        where Contact__r.Id = :faculty.Id];
        System.assertEquals(1, enrolls.size());
        //The Course Enrollment should have been linked to the Affiliation that was automatically created
        System.assertEquals(affls[0].ID, enrolls[0].Affiliation__c);

        //If a new Course Offering is created under the same Department and is taught by the same Faculty member, no additional
        //Affiliation should be created.
        Course_Offering__c offering2 = new Course_Offering__c(Section_ID__c = 'BIO-101 Summer 16', Course__c = course.ID,
        Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
        insert offering2;
        affls = [select Contact__c, Account__c, Role__c, StartDate__c, EndDate__c from Affiliation__c
        where Contact__r.Id = :faculty.Id and Role__c = 'Faculty'];
        System.assertEquals(1, affls.size());
    }

    @isTest
    public static void addFacultyToOfferingNoPrevAffl() {
        setup();
        List<Affiliation__c> affls = [select ID from Affiliation__c];
        Integer afflsSize1 = affls.size();

        //Create Course Offering without Faculty member
        Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID,
        Term__c = term.Id, Capacity__c = 200);
        insert offering;

        //No affiliation should have been created
        affls = [select ID from Affiliation__c];
        System.assertEquals(afflsSize1, affls.size());

        //Add faculty to offering
        offering.Faculty__c = faculty.Id;
        Test.startTest();
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, false);
        update offering;
        Test.stopTest();

        //An Affiliation should have been automatically created for the faculty member, if no Affiliation to that Department
        //already existed.
        affls = [select Contact__c, Account__c, Role__c, StartDate__c, EndDate__c from Affiliation__c
        where Contact__r.Id = :faculty.Id and Role__c = 'Faculty'];
        System.assertEquals(1, affls.size());
        System.assertEquals('Faculty', affls[0].Role__c);
        System.assertEquals(term.Start_Date__c, affls[0].StartDate__c);
        System.assertEquals(term.End_Date__c, affls[0].EndDate__c);

        //A Course Enrollment should have been automatically created
        List<Course_Enrollment__c> enrolls = [select Contact__c, Course_Offering__c, Affiliation__c from Course_Enrollment__c
        where Contact__r.Id = :faculty.Id];
        System.assertEquals(1, enrolls.size());
        //The Course Enrollment should have been linked to the Affiliation that was automatically created
        System.assertEquals(affls[0].ID, enrolls[0].Affiliation__c);
    }

    @isTest
    public static void addFacultyToOfferingPrevAffl() {
        setup();

        //Create affiliation from faculty member to dpt
        Affiliation__c affl = new Affiliation__c(Account__c = dpt.ID, Contact__c = faculty.ID);
        insert affl;

        List<Affiliation__c> affls = [select Id from Affiliation__c];
        Integer afflsSize1 = affls.size();

        //Create Course Offering without Faculty member
        Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID,
        Term__c = term.Id, Capacity__c = 200);
        insert offering;

        //No new affiliations should have been created
        affls = [select Id from Affiliation__c];
        System.assertEquals(afflsSize1, affls.size());

        //Add faculty to offering
        offering.Faculty__c = faculty.Id;
        Test.startTest();
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, false);
        update offering;
        Test.stopTest();

        //Still no new affiliations should have been created
        affls = [select Id from Affiliation__c];
        System.assertEquals(afflsSize1, affls.size());

        //A Course Enrollment should have been automatically created
        List<Course_Enrollment__c> enrolls = [select Contact__c, Course_Offering__c, Affiliation__c from Course_Enrollment__c
        where Contact__r.Id = :faculty.Id];
        System.assertEquals(1, enrolls.size());
        //The Course Enrollment should be linked to the existing Affiliation that already existed (and wasn't automatically created)
        System.assertEquals(affls[0].Id, enrolls[0].Affiliation__c);
    }

    @isTest
    public static void changeFaculty() {
        setup();

        //Create Course Offering with Faculty member
        Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID,
        Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
        insert offering;

        //Since no previous Affl to the Dpt existed, an Affl should have been automatically created for the faculty member
        List<Affiliation__c> affls = [select Contact__c, Account__c, Role__c, StartDate__c, EndDate__c from Affiliation__c
        where Contact__r.Id = :faculty.Id and Role__c = 'Faculty'];
        System.assertEquals(1, affls.size());

        //A Course Enrollment should have been automatically created
        List<Course_Enrollment__c> enrolls = [select Contact__c, Course_Offering__c, Affiliation__c from Course_Enrollment__c
        where Contact__r.Id = :faculty.Id];
        System.assertEquals(1, enrolls.size());

        //Create second faculty member
        Contact faculty2 = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert faculty2;

        //Update Offering
        offering.Faculty__c = faculty2.Id;
        Test.startTest();
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, false);        
        update offering;
        Test.stopTest();

        //The affiliation should have been updated to point to the second faculty member
        affls = [select Contact__c, Account__c, Role__c, StartDate__c, EndDate__c from Affiliation__c
        where Contact__r.Id = :faculty2.Id and Role__c = 'Faculty' and ID = :affls[0].ID];
        System.assertEquals(1, affls.size());
        System.assertEquals('Faculty', affls[0].Role__c);
        System.assertEquals(term.Start_Date__c, affls[0].StartDate__c);
        System.assertEquals(term.End_Date__c, affls[0].EndDate__c);

        //The Course Enrollment of the old Faculty member should have been deleted
        enrolls = [select ID from Course_Enrollment__c where Contact__r.Id = :faculty.Id];
        System.assertEquals(0, enrolls.size());

        //A Course Enrollment should have been automatically created for the new Faculty
        List<Course_Enrollment__c> newEnrolls = [select Contact__c, Course_Offering__c, Affiliation__c from Course_Enrollment__c
        where Contact__r.Id = :faculty2.Id];
        System.assertEquals(1, newEnrolls.size());
        //The Course Enrollment should have been linked to the Affiliation that was automatically created
        System.assertEquals(affls[0].ID, newEnrolls[0].Affiliation__c);


    }

    @isTest
    public static void changeFacultyWithCourseConnEnabled() {
        if (recordTypesExist()) {
            enableCourseConnections();
            setup();

            //Create Course Offering with Faculty member
            Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID,
            Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
            insert offering;

            //A Course Enrollment should have been automatically created
            List<Course_Enrollment__c> enrolls = [select Contact__c, Course_Offering__c, Affiliation__c from Course_Enrollment__c
            where Contact__r.Id = :faculty.Id];
            System.assertEquals(1, enrolls.size());

            //Since no previous Affl to the Dpt existed, an Affl should have been automatically created for the faculty member
            List<Affiliation__c> affls = [select Contact__c, Account__c, Role__c from Affiliation__c
            where Contact__c = :faculty.Id and Role__c = 'Faculty'];
            System.assertEquals(1, affls.size());

            //Create second faculty member
            Contact faculty2 = new Contact(FirstName = 'Test', LastName = 'Testerson');
            insert faculty2;

            //Update Offering
            offering.Faculty__c = faculty2.Id;
            Test.startTest();
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, false);
            update offering;
            Test.stopTest();

            //A new affiliation should have been created for the new Faculty
            affls = [select Contact__c, Account__c, Role__c, (select Id from Course_Enrollment__r) from Affiliation__c
            where Contact__c = :faculty2.Id and Role__c = 'Faculty'];
            System.assertEquals(1, affls.size());
            System.assertEquals('Faculty', affls[0].Role__c);
            System.assertEquals(1, affls[0].Course_Enrollment__r.size());

            //The Course Enrollment of the old Faculty member should not have been deleted and should not be primary
            enrolls = [select Id, Primary__c from Course_Enrollment__c where Contact__r.Id = :faculty.Id];
            System.assertEquals(1, enrolls.size());
            System.assertEquals(false, enrolls[0].Primary__c);

            //A Course Enrollment should have been automatically created for the new Faculty
            List<Course_Enrollment__c> newEnrolls = [select Contact__c, Course_Offering__c, Affiliation__c, Primary__c from Course_Enrollment__c
            where Contact__r.Id = :faculty2.Id];
            System.assertEquals(1, newEnrolls.size());
            System.assertEquals(true, newEnrolls[0].Primary__c);
            //The Course Enrollment should have been linked to the new Affiliation that was automatically created
            System.assertEquals(affls[0].Id, newEnrolls[0].Affiliation__c);
        }
    }

    @isTest
    public static void setFacultyToExistingConnWithCourseConnEnabled() {
        if (recordTypesExist()) {
            enableCourseConnections();
            setup();

            //Create Course Offering with Faculty member
            Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID,
            Term__c = term.Id, Capacity__c = 200);
            insert offering;

            Course_Enrollment__c enroll = new Course_Enrollment__c(Contact__c = faculty.Id,
                                                                    Account__c = dpt.Id,
                                                                    Course_Offering__c = offering.Id,
                                                                    Primary__c = false);
            enroll.put('RecordTypeId', UTIL_Describe.getFacultyConnectionRecType());
            insert enroll;

            //Update Offering
            offering.Faculty__c = faculty.Id;
            Test.startTest();
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, false);
            update offering;
            Test.stopTest();

            //The Course Enrollment of the Faculty member should not have been created but marked primary
            List<Course_Enrollment__c> enrolls = [select Id, Primary__c from Course_Enrollment__c where Contact__r.Id = :faculty.Id];
            System.assertEquals(1, enrolls.size());
            System.assertEquals(true, enrolls[0].Primary__c);
        }
    }

    @isTest
    public static void changeFacultyToExistingConnWithCourseConnEnabled() {
        if (recordTypesExist()) {
            enableCourseConnections();
            setup();

            //Create Course Offering with Faculty member
            Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID,
            Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
            insert offering;

            //Create second faculty member
            Contact faculty2 = new Contact(FirstName = 'Test', LastName = 'Testerson');
            insert faculty2;

            //Create second Course Enrollment
            Course_Enrollment__c enroll = new Course_Enrollment__c(Contact__c = faculty2.Id,
                                                                    Account__c = dpt.Id,
                                                                    Course_Offering__c = offering.Id,
                                                                    Primary__c = false);
            enroll.put('RecordTypeId', UTIL_Describe.getFacultyConnectionRecType());
            insert enroll;

            //Update Offering
            offering.Faculty__c = faculty2.Id;
            Test.startTest();
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, false);
            update offering;
            Test.stopTest();

            //The Course Enrollment of the Faculty member should not have been created but marked primary
            List<Course_Enrollment__c> enrolls = [select Id, Primary__c from Course_Enrollment__c where Contact__r.Id = :faculty2.Id];
            System.assertEquals(1, enrolls.size());
            System.assertEquals(true, enrolls[0].Primary__c);
        }
    }

    @isTest
    public static void facultyMadeNull() {
        setup();

        //Create Course Offering with Faculty member
        Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID,
        Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
        insert offering;

        //An Affiliation should have been automatically created for the faculty member
        List<Affiliation__c> affls = [select Contact__c, Account__c, Role__c, StartDate__c, EndDate__c from Affiliation__c
        where Contact__r.Id = :faculty.Id and Role__c = 'Faculty'];
        System.assertEquals(1, affls.size());

        //A Course Enrollment should have been automatically created
        List<Course_Enrollment__c> enrolls = [select Contact__c, Course_Offering__c, Affiliation__c from Course_Enrollment__c
        where Contact__r.Id = :faculty.Id];
        System.assertEquals(1, enrolls.size());
        //The Course Enrollment should have been linked to the Affiliation that was automatically created
        System.assertEquals(affls[0].ID, enrolls[0].Affiliation__c);

        //Update Offering
        offering.Faculty__c = null;
        Test.startTest();
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, false);
        update offering;
        Test.stopTest();

        //The affiliation should have been deleted
        affls = [select Contact__c, Account__c, Role__c, StartDate__c, EndDate__c from Affiliation__c where ID = :affls[0].ID];
        System.assertEquals(0, affls.size());

        //The Course Enrollment should have been deleted
        enrolls = [select ID from Course_Enrollment__c where Contact__r.Id = :faculty.Id];
        System.assertEquals(0, enrolls.size());
    }

    @isTest
    public static void facultyMadeNullWhenOtherEnrollmentsExist() {
        setup();

        // Create first Course Offering with Faculty member
        Course_Offering__c firstOffering = new Course_Offering__c(Section_Id__c = 'BIO-101 Spring 16 - 1', Course__c = course.Id,
        Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
        insert firstOffering;
            
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, false);
        //Create second Course Offering with Faculty member
        Course_Offering__c secondOffering = new Course_Offering__c(Section_Id__c = 'BIO-101 Spring 16 - 2', Course__c = course.Id,
        Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
        insert secondOffering;

        //An Affiliation should have been automatically created for the faculty member
        List<Affiliation__c> affls = [select Id, (select Id from Course_Enrollment__r) from Affiliation__c where Contact__r.Id = :faculty.Id and Role__c = 'Faculty'];
        System.assertEquals(1, affls.size());

        // The affiliation should have two Course Enrollments
        System.assertEquals(2, affls[0].Course_Enrollment__r.size());

        // Two Course Enrollments should have been automatically created
        List<Course_Enrollment__c> enrolls = [select Contact__c, Course_Offering__c, Affiliation__c from Course_Enrollment__c
        where Contact__r.Id = :faculty.Id];
        System.assertEquals(2, enrolls.size());
        //The Course Enrollments should have been linked to the Affiliation that was automatically created
        System.assertEquals(affls[0].Id, enrolls[0].Affiliation__c);
        System.assertEquals(affls[0].Id, enrolls[1].Affiliation__c);

        // Update first Offering
        firstOffering.Faculty__c = null;
        Test.startTest();
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, false);
        update firstOffering;
        Test.stopTest();

        // The affiliation should not have been deleted
        affls = [select Id, (select Id from Course_Enrollment__r) from Affiliation__c where Id = :affls[0].Id];
        System.assertEquals(1, affls.size());

        // The affiliation should have one Course Enrollment
        System.assertEquals(1, affls[0].Course_Enrollment__r.size());

        // One Course Enrollment should have been deleted
        enrolls = [select Id from Course_Enrollment__c where Contact__r.Id = :faculty.Id];
        System.assertEquals(1, enrolls.size());
    }

    @isTest
    public static void deleteMultipleCourseOfferingsWithFaculty() {
        setup();

        // Create first Course Offering with Faculty member
        Course_Offering__c firstOffering = new Course_Offering__c(Section_Id__c = 'BIO-101 Spring 16 - 1', Course__c = course.Id,
        Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
        insert firstOffering;

        //Create second Course Offering with Faculty member
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, false);
        Course_Offering__c secondOffering = new Course_Offering__c(Section_Id__c = 'BIO-101 Spring 16 - 2', Course__c = course.Id,
        Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
        insert secondOffering;

        //An Affiliation should have been automatically created for the faculty member
        List<Affiliation__c> affls = [select Id, (select Id from Course_Enrollment__r) from Affiliation__c where Contact__r.Id = :faculty.Id and Role__c = 'Faculty'];
        System.assertEquals(1, affls.size());

        // The affiliation should have two Course Enrollments
        System.assertEquals(2, affls[0].Course_Enrollment__r.size());

        // Two Course Enrollments should have been automatically created
        List<Course_Enrollment__c> enrolls = [select Contact__c, Course_Offering__c, Affiliation__c from Course_Enrollment__c
        where Contact__r.Id = :faculty.Id];
        System.assertEquals(2, enrolls.size());
        //The Course Enrollments should have been linked to the Affiliation that was automatically created
        System.assertEquals(affls[0].Id, enrolls[0].Affiliation__c);
        System.assertEquals(affls[0].Id, enrolls[1].Affiliation__c);

        Test.startTest();
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, false);
        delete new List<Course_Offering__c>{
            firstOffering,
            secondOffering
        };
        Test.stopTest();

        // The two Course Enrollments should have been deleted
        enrolls = [select Contact__c, Course_Offering__c, Affiliation__c from Course_Enrollment__c
        where Contact__r.Id = :faculty.Id];
        System.assertEquals(0, enrolls.size());

        // The affiliation should have been deleted
        affls = [select Id, (select Id from Course_Enrollment__r) from Affiliation__c where Id = :affls[0].Id];
        System.assertEquals(0, affls.size());
    }

    @isTest
    public static void facultyMadeNullWithCourseConnEnabled() {
        if (recordTypesExist()) {
            enableCourseConnections();
            setup();

            //Create Course Offering with Faculty member
            Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.Id,
            Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
            insert offering;

            //A Course Enrollment should have been automatically created
            List<Course_Enrollment__c> enrolls = [select Contact__c, Course_Offering__c, Primary__c, Affiliation__c from Course_Enrollment__c
            where Contact__r.Id = :faculty.Id];
            System.assertEquals(1, enrolls.size());
            System.assertEquals(true, enrolls[0].Primary__c);
            //The Course Enrollment should have been linked to the Affiliation that was automatically created

            //An Affiliation should have been automatically created for the faculty member
            List<Affiliation__c> affls = [select Contact__c, Account__c, Role__c from Affiliation__c
            where Contact__c = :faculty.Id and Role__c = 'Faculty'];
            System.assertEquals(1, affls.size());

            System.assertEquals(affls[0].ID, enrolls[0].Affiliation__c);

            //Update Offering
            offering.Faculty__c = null;
            Test.startTest();
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, false);
            update offering;
            Test.stopTest();

            //The affiliation should still exist
            affls = [select Contact__c, Account__c, Role__c, StartDate__c, EndDate__c from Affiliation__c where Id = :affls[0].Id];
            System.assertEquals(1, affls.size());

            //The Course Enrollment should have been marked as not Primary
            enrolls = [select Id, Primary__c from Course_Enrollment__c where Id = :enrolls[0].Id];
            System.assertEquals(false, enrolls[0].Primary__c);
        }
    }

    @isTest
    public static void deleteCourseOffering() {
        setup();

        //Create Course Offering with Faculty member
        Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.Id,
        Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
        insert offering;

        //An Affiliation should have been automatically created for the faculty member
        List<Affiliation__c> affls = [select Contact__c, Account__c, Role__c, StartDate__c, EndDate__c from Affiliation__c
        where Contact__r.Id = :faculty.Id and Role__c = 'Faculty'];
        System.assertEquals(1, affls.size());

        //A Course Enrollment should have been automatically created
        List<Course_Enrollment__c> enrolls = [select Contact__c, Course_Offering__c, Affiliation__c from Course_Enrollment__c
        where Contact__r.Id = :faculty.Id];
        System.assertEquals(1, enrolls.size());
        //The Course Enrollment should have been linked to the Affiliation that was automatically created
        System.assertEquals(affls[0].Id, enrolls[0].Affiliation__c);

        Test.startTest();
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, false);        
        delete offering;
        Test.stopTest();

        //The affiliation should have been deleted
        affls = [select Contact__c, Account__c, Role__c, StartDate__c, EndDate__c from Affiliation__c where Id = :affls[0].Id];
        System.assertEquals(0, affls.size());

        //The Course Enrollment should have been deleted
        enrolls = [select Id from Course_Enrollment__c where Contact__r.Id = :faculty.Id];
        System.assertEquals(0, enrolls.size());
    }

    @isTest
    public static void testGetAfflsForContact() {
        setup();

        Contact faculty1 = new Contact(FirstName = 'Test', LastName = 'Testerson1');
        Contact faculty2 = new Contact(FirstName = 'Test', LastName = 'Testerson2');
        Contact faculty3 = new Contact(FirstName = 'Test', LastName = 'Testerson3');
        Contact faculty4 = new Contact(FirstName = 'Test', LastName = 'Testerson4');
        insert new Contact[]{faculty1, faculty2, faculty3, faculty4};

        Account dpt1 = new Account(Name = 'English Department', Parent = university);
        Account dpt2 = new Account(Name = 'CS Department', Parent = university);
        Account dpt3 = new Account(Name = 'Math Department', Parent = university);
        Account dpt4 = new Account(Name = 'Law Department', Parent = university);
        insert new Account[]{dpt1, dpt2, dpt3, dpt4};

        Affiliation__c aff1 = new Affiliation__c(Contact__c = faculty1.ID, Account__c = dpt1.ID);
        Affiliation__c aff2 = new Affiliation__c(Contact__c = faculty4.ID, Account__c = dpt1.ID);
        Affiliation__c aff3 = new Affiliation__c(Contact__c = faculty2.ID, Account__c = dpt2.ID);
        Affiliation__c aff4 = new Affiliation__c(Contact__c = faculty4.ID, Account__c = dpt3.ID);
        Affiliation__c aff5 = new Affiliation__c(Contact__c = faculty1.ID, Account__c = dpt2.ID);
        Affiliation__c aff6 = new Affiliation__c(Contact__c = faculty3.ID, Account__c = dpt1.ID);
        Affiliation__c aff7 = new Affiliation__c(Contact__c = faculty1.ID, Account__c = dpt4.ID);
        Affiliation__c aff8 = new Affiliation__c(Contact__c = faculty2.ID, Account__c = dpt3.ID);
        insert new Affiliation__c[]{aff1, aff2, aff3, aff4, aff5, aff6, aff7, aff8};

        COFF_Affiliation_TDTM tdtm = new COFF_Affiliation_TDTM();
        Map<ID, List<Affiliation__c>> facultyIDtoAffls = tdtm.getAfflsForContact(new ID[]{faculty1.ID, faculty2.ID, faculty3.ID, faculty4.ID});

        Set<Affiliation__c> faculty1Affls = new Set<Affiliation__c>(facultyIDtoAffls.get(faculty1.ID));
        Set<Affiliation__c> faculty2Affls = new Set<Affiliation__c>(facultyIDtoAffls.get(faculty2.ID));
        Set<Affiliation__c> faculty3Affls = new Set<Affiliation__c>(facultyIDtoAffls.get(faculty3.ID));
        Set<Affiliation__c> faculty4Affls = new Set<Affiliation__c>(facultyIDtoAffls.get(faculty4.ID));
        System.assertEquals(true, faculty1Affls.contains(aff1));
        System.assertEquals(true, faculty1Affls.contains(aff5));
        System.assertEquals(true, faculty1Affls.contains(aff7));
        System.assertEquals(true, faculty2Affls.contains(aff3));
        System.assertEquals(true, faculty2Affls.contains(aff8));
        System.assertEquals(true, faculty3Affls.contains(aff6));
        System.assertEquals(true, faculty4Affls.contains(aff2));
        System.assertEquals(true, faculty4Affls.contains(aff4));
    }

    @isTest
    public static void testAfflToDptExists() {
        setup();

        //dpt is the parent Account of course
        insert new Affiliation__c(Contact__c = faculty.ID, Account__c = dpt.ID);

        //Create Course Offering with Faculty member
        Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID,
        Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
        insert offering;

        //An Affiliation from the faculty member to the Department should already exist
        offering = [select Faculty__c, Course__r.Account__c from Course_Offering__c where ID = :offering.ID];
        COFF_Affiliation_TDTM tdtm = new COFF_Affiliation_TDTM();
        Map<ID, List<Affiliation__c>> facultyIDtoAffls = tdtm.getAfflsForContact(new ID[]{faculty.ID});
        Affiliation__c afflToDpt = tdtm.affiliationToAccount(offering, facultyIDtoAffls);
        System.assertNotEquals(null, afflToDpt.Id);
    }

    @isTest
    public static void newCourseOfferingNoDates() {
        setup();

        //Create Course Offering
        Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID,
        Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
        Test.startTest();
        insert offering;
        Test.stopTest();

        //Since no dates were entered for the Course Offering, the dates from the parent term should have been copied
        offering = [select Start_Date__c, End_Date__c from Course_Offering__c where ID = :offering.ID];
        System.assertEquals(System.today() + 5, offering.Start_Date__c);
        System.assertEquals(System.today() + 90, offering.End_Date__c);
    }

    @isTest
    public static void newCourseOfferingWithDates() {
        setup();

        //Create Course Offering
        Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID,
        Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200, Start_Date__c = System.today() + 10,
        End_Date__c = System.today() + 100);
        Test.startTest();
        insert offering;
        Test.stopTest();

        //The dates entered when creating the Course Offering should not have been overridden
        offering = [select Start_Date__c, End_Date__c from Course_Offering__c where ID = :offering.ID];
        System.assertEquals(System.today() + 10, offering.Start_Date__c);
        System.assertEquals(System.today() + 100, offering.End_Date__c);
    }

    @isTest
    public static void testUpdateConnectionsOnFacultyChangeUpdateExisting() {
        setup();
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, true);

        //Create Course Offering with Faculty member
        Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID,
        Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
        insert offering;

        Course_Enrollment__c conn = new Course_Enrollment__c(Contact__c = faculty.Id, Course_Offering__c = offering.Id);
        if (UTIL_Describe.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) {
            conn.put('RecordTypeId', UTIL_Describe.getFacultyConnectionRecType());
        }
        insert conn;

        Contact faculty2 = new Contact(FirstName = 'Test', LastName = 'Testerson2');
        insert faculty2;

        Course_Enrollment__c conn2 = new Course_Enrollment__c(Contact__c = faculty2.Id, Course_Offering__c = offering.Id);
        if (UTIL_Describe.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) {
            conn2.put('RecordTypeId', UTIL_Describe.getFacultyConnectionRecType());
        }
        insert conn2;

        List<Id> outdatedFaculty = new List<Id>{faculty.Id};
        List<Id> updatedFaculty = new List<Id>{faculty2.Id};
        Set<Id> offerings = new Set<Id>{offering.Id};

        List<SObject> objectsToInsert = new List<SObject>();
        List<SObject> objectsToUpdate = new List<SObject>();

        COFF_Affiliation_TDTM cls = new COFF_Affiliation_TDTM();

        Test.startTest();
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, false);
        cls.updateConnectionsOnFacultyChange(outdatedFaculty, updatedFaculty, offerings, objectsToInsert, objectsToUpdate);
        Test.stopTest();

        System.assertEquals(2, objectsToUpdate.size());
        System.assertEquals(0, objectsToInsert.size());
        System.assertEquals(objectsToUpdate[0].get('Primary__c'), true);
        System.assertEquals(objectsToUpdate[1].get('Primary__c'), false);
    }

    @isTest
    public static void testUpdateConnectionsOnFacultyChangeInsertNew() {
        setup();

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, true);

        //Create Course Offering with Faculty member
        Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID,
        Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
        insert offering;

        Course_Enrollment__c conn = new Course_Enrollment__c(Contact__c = faculty.Id, Course_Offering__c = offering.Id);
        if (UTIL_Describe.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) {
            conn.put('RecordTypeId', UTIL_Describe.getFacultyConnectionRecType());
        }
        insert conn;

        Contact faculty2 = new Contact(FirstName = 'Test', LastName = 'Testerson2');
        insert faculty2;

        List<Id> outdatedFaculty = new List<Id>{faculty.Id};
        List<Id> updatedFaculty = new List<Id>{faculty2.Id};
        Set<Id> offerings = new Set<Id>{offering.Id};

        List<SObject> objectsToInsert = new List<SObject>();
        List<SObject> objectsToUpdate = new List<SObject>();

        COFF_Affiliation_TDTM cls = new COFF_Affiliation_TDTM();

        Test.startTest();
        cls.updateConnectionsOnFacultyChange(outdatedFaculty, updatedFaculty, offerings, objectsToInsert, objectsToUpdate);
        Test.stopTest();

        System.assertEquals(1, objectsToUpdate.size());
        System.assertEquals(1, objectsToInsert.size());
        System.assertEquals(objectsToInsert[0].get('Primary__c'), true);
        System.assertEquals(objectsToUpdate[0].get('Primary__c'), false);
    }

    @isTest
    public static void testUpdateConnectionsOnFacultyRemove() {
        setup();

        //Create Course Offering with Faculty member
        Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID,
        Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
        insert offering;

        List<Id> removedFacultyIds = new List<Id>{faculty.Id};
        Set<Id> offsWithRemovedFaculty = new Set<Id>{offering.Id};

        List<SObject> objectsToUpdate = new List<SObject>();

        COFF_Affiliation_TDTM cls = new COFF_Affiliation_TDTM();

        Test.startTest();
        cls.updateConnectionsOnFacultyRemove(removedFacultyIds, offsWithRemovedFaculty, objectsToUpdate);
        Test.stopTest();

        System.assertEquals(1, objectsToUpdate.size());
        System.assertEquals(objectsToUpdate[0].get('Primary__c'), false);
    }

    @isTest
    public static void testUpdateConnectionsOnFacultyAddInsertNew() {
        setup();

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, true);

        //Create Course Offering with Faculty member
        Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID,
        Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
        insert offering;

        List<Course_Offering__c> offerings = new List<Course_Offering__c>{offering};

        List<SObject> objectsToInsert = new List<SObject>();
        List<SObject> objectsToUpdate = new List<SObject>();

        COFF_Affiliation_TDTM cls = new COFF_Affiliation_TDTM();

        Test.startTest();
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, false);
        cls.updateConnectionsOnFacultyAdd(offerings, objectsToInsert, objectsToUpdate);
        Test.stopTest();

        System.assertEquals(0, objectsToUpdate.size());
        System.assertEquals(1, objectsToInsert.size());
        System.assertEquals(objectsToInsert[0].get('Primary__c'), true);
    }

    @isTest
    public static void testUpdateConnectionsOnFacultyAddUpdateExisting() {
        setup();

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, true);

        //Create Course Offering with Faculty member
        Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID,
        Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
        insert offering;

        Course_Enrollment__c conn = new Course_Enrollment__c(Contact__c = faculty.Id, Course_Offering__c = offering.Id);
        if (UTIL_Describe.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) {
            conn.put('RecordTypeId', UTIL_Describe.getFacultyConnectionRecType());
        }
        insert conn;

        List<Course_Offering__c> offerings = new List<Course_Offering__c>{offering};

        List<SObject> objectsToInsert = new List<SObject>();
        List<SObject> objectsToUpdate = new List<SObject>();

        COFF_Affiliation_TDTM cls = new COFF_Affiliation_TDTM();

        Test.startTest();
        cls.updateConnectionsOnFacultyAdd(offerings, objectsToInsert, objectsToUpdate);
        Test.stopTest();

        System.assertEquals(1, objectsToUpdate.size());
        System.assertEquals(0, objectsToInsert.size());
        System.assertEquals(objectsToUpdate[0].get('Primary__c'), true);
    }

    @isTest
    public static void testUpdateMultipleConnectionsOnFacultyAddUpdateExisting() {
        setup();

        //Create Course Offerings with same Faculty member
        List<Course_Offering__c> offerings = new List<Course_Offering__c>();
        Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID,
        Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
        Course_Offering__c offering2 = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID,
        Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
        offerings.add(offering);
        offerings.add(offering2);
        insert offerings;

        Contact newFaculty = new Contact(FirstName = 'Test2', LastName = 'Test2');
        insert newFaculty;

        Course_Enrollment__c conn = [SELECT Id, Contact__c FROM Course_Enrollment__c WHERE Course_Offering__c = :offering2.Id LIMIT 1];

        Test.startTest();
        offering2.Faculty__c = newFaculty.Id;
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, false);
        update offering2;
        Test.stopTest();

        //assert
        List<Course_Enrollment__c> resultConns = [SELECT Id, Contact__c FROM Course_Enrollment__c WHERE Course_Offering__c = :offering2.Id];
        //course offering still has only one course connection
        system.assertEquals(1, resultConns.size());
        //the faculty of course offering is changed to new faculty
        system.assertEquals(newFaculty.Id, resultConns[0].Contact__c);
        //course offering has a different course connection
        system.assertNotEquals(conn.Id, resultConns[0].Id);
    }
}