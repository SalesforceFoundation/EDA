/*
    Copyright (c) 2016, Salesforce.org
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
* @date 2016
* @group Course Enrollments
* @group-content ../../ApexDocContent/CourseEnrollments.htm
* @description Tests specific to Course Connections
*/
@isTest
public with sharing class CCON_Faculty_TEST {

    private static Account university;
    private static Account dpt;
    private static Course__c course;
    private static Term__c term;
    private static Course_Offering__c offering;
    private static Course_Offering__c offering2;
    private static Contact faculty;
    private static Contact faculty2;

    private static void setup() {
        STG_InstallScript.insertMappings();
        // Create university
        university = new Account(Name = 'Advanced University', RecordTypeId = UTIL_Describe.getAcademicAccRecTypeID());
        insert university;

        // Create department
        dpt = new Account(Name = 'Biology Department', Parent = university, RecordTypeId = UTIL_Describe.getDepAccRecTypeID());
        insert dpt;

        // Create Course
        course = new Course__c(Course_ID__c = 'Biology 101', Account__c = dpt.Id, Credit_Hours__c = 40,
        Description__c = 'Intro to Biology');
        insert course;

        // Create Term
        term = new Term__c(Account__c = university.Id, Start_Date__c = System.today() + 5, End_Date__c = System.today() + 90);
        insert term;

        // Create Course Offerings without Faculty member
        offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16 - 1', Course__c = course.Id,
        Term__c = term.Id, Capacity__c = 200);

        // Create Course Offerings without Faculty member
        offering2 = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16 - 2', Course__c = course.Id,
        Term__c = term.Id, Capacity__c = 200);

        // Create some faculty members
        faculty = new Contact(FirstName = 'Test', LastName = 'Testerson');
        faculty2 = new Contact(FirstName = 'Test2', LastName = 'Testerson2');

        // Insert objects together
        insert new List<SObject>{
            offering,
            offering2,
            faculty,
            faculty2
        };
    }

    private static void enableCourseConnections() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Enable_Course_Connections__c = true,
                Faculty_RecType__c = UTIL_Describe_API.getFacultyConnectionRecType()
            )
        );
    }

    /*********************************************************************************************************
    * @description Verifies that a new Course Connection was created with an Affiliation
    */
    @isTest
    public static void newCourseConnection() {
        // Do not run test if record types do not exist
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) {
            enableCourseConnections();
            setup();

            // Create Course Connection
            Course_Enrollment__c conn = new Course_Enrollment__c(
                Contact__c = faculty.Id,
                Course_Offering__c = offering.Id,
                Primary__c = false
            );
            conn.put('RecordTypeId', UTIL_Describe_API.getFacultyConnectionRecType());

            Test.startTest();
            insert conn;
            Test.stopTest();

            conn = [SELECT Id, Affiliation__c FROM Course_Enrollment__c WHERE Id = :conn.Id];

            System.assertNotEquals(null, conn.Affiliation__c);
        }

    }

    /*********************************************************************************************************
    * @description Verifies that a Course Connection is assigned to the oldest Affiliation if multiple
    * Affiliations to an Account exist.
    */
    @isTest
    public static void newCourseConnectionExistingAffiliations() {
        // Do not run test if record types do not exist
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) {
            enableCourseConnections();
            setup();

            // Create another department
            Account dpt2 = new Account(Name = 'Math Department', Parent = university);
            insert dpt2;

            // Create an Affiliation manually, different Account
            Affiliation__c affl = new Affiliation__c(
                Contact__c = faculty.Id,
                Account__c = dpt2.Id,
                Role__c = 'Faculty'
            );
            insert affl;

            // Create Course Connection
            Course_Enrollment__c conn = new Course_Enrollment__c(
                Contact__c = faculty.Id,
                Course_Offering__c = offering.Id,
                Primary__c = false
            );
            conn.put('RecordTypeId', UTIL_Describe_API.getFacultyConnectionRecType());

            insert conn;

            // Check that an Affiliation was created.
            conn = [SELECT Id, Affiliation__c FROm Course_Enrollment__c WHERE Id = :conn.Id];
            System.assertNotEquals(null, conn.Affiliation__c);

            // Create another Affiliation manually, Same Account
            Affiliation__c affl2 = new Affiliation__c(
                Contact__c = faculty.Id,
                Account__c = dpt.Id,
                Role__c = 'Faculty'
            );

            insert affl2;

            // Check that there are three Affiliations
            List <Affiliation__c> affls = [SELECT Id, Contact__c FROM Affiliation__c WHERE Contact__c = :faculty.Id];
            System.assertEquals(3, affls.size());

            // Create another Course Connection
            Course_Enrollment__c conn2 = new Course_Enrollment__c(
                Contact__c = faculty.Id,
                Course_Offering__c = offering2.Id,
                Primary__c = false
            );
            conn2.put('RecordTypeId', UTIL_Describe_API.getFacultyConnectionRecType());

            Test.startTest();
            insert conn2;
            Test.stopTest();

            // Check that there are still three Affiliations
            affls = [SELECT Id, Contact__c FROM Affiliation__c WHERE Contact__c = :faculty.Id];
            System.assertEquals(3, affls.size());

            // Check that the second Course Connection got the oldest existing Affiliation for the matching Account
            conn2 = [SELECT Id, Affiliation__c FROm Course_Enrollment__c WHERE Id = :conn2.Id];
            System.assertEquals(conn.Affiliation__c, conn2.Affiliation__c);
        }

    }

    /*********************************************************************************************************
    * @description Verifies that an existing Course Connection that is marked as Primary is populated on the
    * Course Offering
    */
    @isTest
    public static void existingCourseConnectionMadePrimary() {
        // Do not run test if record types do not exist
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) {
            enableCourseConnections();
            setup();

            // Create Course Connection
            Course_Enrollment__c conn = new Course_Enrollment__c(
                Contact__c = faculty.Id,
                Course_Offering__c = offering.Id,
                Primary__c = false
            );
            conn.put('RecordTypeId', UTIL_Describe_API.getFacultyConnectionRecType());

            insert conn;

            // Check that Faculty is not set on Course Offering.
            offering = [SELECT Id, Faculty__c FROM Course_Offering__c WHERE Id = :offering.Id];
            System.assertEquals(null, offering.Faculty__c);

            // Mark Course Connection as Primary.
            conn.Primary__c = true;
            Test.startTest();
            update conn;
            Test.stopTest();

            offering = [SELECT Id, Faculty__c FROM Course_Offering__c WHERE Id = :offering.Id];
            System.assertEquals(faculty.Id, offering.Faculty__c);
        }
    }

    /*********************************************************************************************************
    * @description Verifies that an existing Primary Course Connection that is marked as not Primary is
    * removed from the Course Offering.
    */
    @isTest
    public static void existingPrimaryCourseConnectionMarkedNotPrimary() {
        // Do not run test if record types do not exist
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) {
            enableCourseConnections();
            setup();

            // Create Course Connection
            Course_Enrollment__c conn = new Course_Enrollment__c(
                Contact__c = faculty.Id,
                Course_Offering__c = offering.Id,
                Primary__c = true
            );
            conn.put('RecordTypeId', UTIL_Describe_API.getFacultyConnectionRecType());

            insert conn;

            // Check that Faculty is set on Course Offering.
            offering = [SELECT Id, Faculty__c FROM Course_Offering__c WHERE Id = :offering.Id];
            System.assertEquals(faculty.Id, offering.Faculty__c);

            // Mark Course Connection as not Primary.
            conn.Primary__c = false;
            Test.startTest();
            update conn;
            Test.stopTest();

            // Verify faculty is not set on Course Offering.
            offering = [SELECT Id, Faculty__c FROM Course_Offering__c WHERE Id = :offering.Id];
            System.assertNotEquals(faculty.Id, offering.Faculty__c);
        }

    }

    /*********************************************************************************************************
    * @description Verifies that a new Course Connection that is created as Primary is populated on the
    * Course Offering
    */
    @isTest
    public static void newPrimaryCourseConnection() {
        // Do not run test if record types do not exist
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) {
            enableCourseConnections();
            setup();

            // Create Primary Course Connection
            Course_Enrollment__c conn = new Course_Enrollment__c(
                Contact__c = faculty.Id,
                Course_Offering__c = offering.Id,
                Primary__c = true
            );
            conn.put('RecordTypeId', UTIL_Describe_API.getFacultyConnectionRecType());

            Test.startTest();
            insert conn;
            Test.stopTest();

            offering = [SELECT Id, Faculty__c FROM Course_Offering__c WHERE Id = :offering.Id];
            System.assertEquals(faculty.Id, offering.Faculty__c);
        }
    }

    /*********************************************************************************************************
    * @description Verifies that an existing Course Connection that is marked as primary on a
    * Course Offering that already has a Primary Course Connection is marked Primary and the other is no
    * longer marked Primary.
    */
    @isTest
    public static void changePrimaryCourseConnection() {
        // Do not run test if record types do not exist
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) {
            enableCourseConnections();
            setup();

            // Create Primary Course Connection
            Course_Enrollment__c conn = new Course_Enrollment__c(
                Contact__c = faculty.Id,
                Course_Offering__c = offering.Id,
                Primary__c = true
            );
            conn.put('RecordTypeId', UTIL_Describe_API.getFacultyConnectionRecType());
            // Create second Course Connection
            Course_Enrollment__c conn2 = new Course_Enrollment__c(
                Contact__c = faculty2.Id,
                Course_Offering__c = offering.Id,
                Primary__c = false
            );
            conn2.put('RecordTypeId', UTIL_Describe_API.getFacultyConnectionRecType());
            insert new List<Course_Enrollment__c>{
                conn,
                conn2
            };

            // Check that the first faculty is Primary.
            offering = [SELECT Id, Faculty__c FROM Course_Offering__c WHERE Id = :offering.Id];
            System.assertEquals(faculty.Id, offering.Faculty__c);

            // Mark the second Course Connection as Primary.
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, false);
            conn2.Primary__c = true;
            Test.startTest();
            update conn2;
            Test.stopTest();

            // Check that the first Course Connection is not marked Primary.
            conn = [SELECT Id, Primary__c FROm Course_Enrollment__c WHERE Id = :conn.Id];
            System.assertEquals(false, conn.Primary__c);

            // Check that the second faculty is Primary.
            offering = [SELECT Id, Faculty__c FROM Course_Offering__c WHERE Id = :offering.Id];
            System.assertEquals(faculty2.Id, offering.Faculty__c);
        }
    }

    /*********************************************************************************************************
    * @description Verifies that an additional Affiliation is not created when one for the given Dept already
    * exists. The additional Connections should be linked to the existing Affiliation.
    */
    @isTest
    public static void newPrimaryCourseConnectionWhenAffiliationExists() {
        // Do not run test if record types do not exist
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) {
            enableCourseConnections();
            setup();

            // Create Course Connection on first Course Offering, an Affiliation should be created
            Course_Enrollment__c conn = new Course_Enrollment__c(
                Contact__c = faculty.Id,
                Course_Offering__c = offering.Id,
                Primary__c = false
            );
            conn.put('RecordTypeId', UTIL_Describe_API.getFacultyConnectionRecType());

            insert conn;

            // Check that an Affiliation was created.
            List<Affiliation__c> affls = [SELECT Id, Contact__c FROM Affiliation__c WHERE Contact__c = :faculty.Id];
            System.assertEquals(1, affls.size());

            // Create Second Course Connection on a different Course Offering in same Dept.
            // An Affiliation should not be created but instead the existing should be linked.
            Course_Enrollment__c conn2 = new Course_Enrollment__c(
                Contact__c = faculty.Id,
                Course_Offering__c = offering2.Id,
                Primary__c = true
            );
            conn2.put('RecordTypeId', UTIL_Describe_API.getFacultyConnectionRecType());

            Test.startTest();
            insert conn2;
            Test.stopTest();

            // Check that an additional Affiliation was not created.
            affls = [SELECT Id, Contact__c FROM Affiliation__c WHERE Contact__c = :faculty.Id];
            System.assertEquals(1, affls.size());

            //Check that the Affiliation Id is the same on both Course Connections. There should only be two.
            List<Course_Enrollment__c> conns = [SELECT Id, Affiliation__c FROM Course_Enrollment__c];
            System.assertEquals(2, conns.size());
            System.assertEquals(conns[0].Affiliation__c, conns[1].Affiliation__c);
        }
    }

    /*********************************************************************************************************
    * @description Verifies that an additional Affiliation is not created when two Course Connections with the
    * same Faculty and Department are inserted at the same time.
    */
    @isTest
    public static void multipleNewPrimaryCourseConnectionsForSameFaculty() {
        // Do not run test if record types do not exist
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) {
            enableCourseConnections();
            setup();

            Id facultyRecordTypeId = UTIL_Describe_API.getFacultyConnectionRecType();

            // Create two Course Connections on different Course Offerings in same Dept.
            // Since both are for the same Faculty member, only one affiliation is created.
            Course_Enrollment__c conn = new Course_Enrollment__c(
                Contact__c = faculty.Id,
                Course_Offering__c = offering.Id,
                Primary__c = false
            );
            conn.put('RecordTypeId', facultyRecordTypeId);

            Course_Enrollment__c conn2 = new Course_Enrollment__c(
                Contact__c = faculty.Id,
                Course_Offering__c = offering2.Id,
                Primary__c = true
            );
            conn2.put('RecordTypeId', facultyRecordTypeId);

            Test.startTest();
            insert new List<Course_Enrollment__c>{ conn, conn2 };
            Test.stopTest();

            // Check that only one Affiliation was created.
            List<Affiliation__c> affls = [SELECT Id, Contact__c FROM Affiliation__c WHERE Contact__c = :faculty.Id];
            System.assertEquals(1, affls.size());

            //Check that the Affiliation Id is the same on both Course Connections. There should only be two.
            List<Course_Enrollment__c> conns = [SELECT Id, Affiliation__c FROM Course_Enrollment__c];
            System.assertEquals(2, conns.size());
            System.assertEquals(conns[0].Affiliation__c, conns[1].Affiliation__c);
        }
    }

    /*********************************************************************************************************
    * @description Verifies that when a Course Connection is removed the related Affiliation is also removed.
    * The Affiliation should be removed because there will only be one Course Connection related to it.
    */
    @isTest
    public static void deletePrimaryCourseConnection() {
        // Do not run test if record types do not exist
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) {
            enableCourseConnections();
            setup();

            // Create Course Connection
            Course_Enrollment__c conn = new Course_Enrollment__c(
                Contact__c = faculty.Id,
                Course_Offering__c = offering.Id,
                Primary__c = true
            );
            conn.put('RecordTypeId', UTIL_Describe_API.getFacultyConnectionRecType());

            insert conn;

            // Check that an Affiliation was created.
            List<Affiliation__c> affls = [SELECT Id, Contact__c FROM Affiliation__c WHERE Contact__c = :faculty.Id];
            System.assertEquals(1, affls.size());

            Test.startTest();
            delete conn;
            Test.stopTest();

            // Check that an Affiliation was removed.
            affls = [SELECT Id, Contact__c FROM Affiliation__c WHERE Contact__c = :faculty.Id];
            System.assertEquals(0, affls.size());

            offering = [SELECT Faculty__c FROM Course_Offering__c WHERE Id = :offering.Id];
            System.assertEquals(null, offering.Faculty__c);
        }
    }

    /*********************************************************************************************************
    * @description Verifies that when a Course Connection is removed the related Affiliation is not removed.
    * The Affiliation should not be removed because there will still be one additional Course Connection related to it.
    */
    @isTest
    public static void deleteCourseConnectionKeepAffiliation() {
        // Do not run test if record types do not exist
        if (UTIL_Describe_API.isValidField(UTIL_Namespace.StrTokenNSPrefix('Course_Enrollment__c'),'RecordTypeId')) {
            enableCourseConnections();
            setup();

            // Create first Course Connection
            Course_Enrollment__c conn1 = new Course_Enrollment__c(
                Contact__c = faculty.Id,
                Course_Offering__c = offering.Id,
                Primary__c = false
            );
            conn1.put('RecordTypeId', UTIL_Describe_API.getFacultyConnectionRecType());
            insert conn1;

            // Create second Course Connection
            Course_Enrollment__c conn2 = new Course_Enrollment__c(
                Contact__c = faculty.Id,
                Course_Offering__c = offering2.Id,
                Primary__c = false
            );
            conn2.put('RecordTypeId', UTIL_Describe_API.getFacultyConnectionRecType());

            insert conn2;

            // Check that an Affiliation was created. Only one should have been created.
            List<Affiliation__c> affls = [SELECT Id, Contact__c, (SELECT Id FROM Course_Enrollment__r) FROM Affiliation__c WHERE Contact__c = :faculty.Id];
            System.assertEquals(1, affls.size());
            System.assertEquals(2, affls[0].Course_Enrollment__r.size());

            Test.startTest();
            delete conn1;
            Test.stopTest();

            // Check that an Affiliation was not removed and now there is one Course Connection related to it.
            affls = [SELECT Id, Contact__c, (SELECT Id FROM Course_Enrollment__r) FROM Affiliation__c WHERE Contact__c = :faculty.Id];
            System.assertEquals(1, affls.size());
            System.assertEquals(1, affls[0].Course_Enrollment__r.size());
        }
    }

    @isTest
    public static void testGetAffiliations() {
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, true);
        setup();

        Affiliation__c affl = new Affiliation__c(Contact__c = faculty.Id, Account__c = dpt.Id, Role__c = 'Faculty');
        insert affl;

        Course_Enrollment__c conn = new Course_Enrollment__c(Contact__c = faculty.Id,
                                                             Course_Offering__c = offering.Id,
                                                             Affiliation__c = affl.Id);
        insert conn;

        Set<Id> afflIds = new Set<Id>{affl.Id};

        CCON_Faculty_TDTM cls = new CCON_Faculty_TDTM();

        Test.startTest();
        Map<Id, Affiliation__c> afflMap = cls.getAffiliations(afflIds);
        Test.stopTest();

        System.assertEquals(true, afflMap.containsKey(affl.Id));
    }

    @isTest
    public static void testGetContactIdAccountIdAffiliationsList() {
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.COFF_Affiliation_TDTM, true);
        setup();

        Affiliation__c affl = new Affiliation__c(Contact__c = faculty.Id, Account__c = dpt.Id, Role__c = 'Faculty');
        insert affl;

        Set<Id> contactIds = new Set<Id>{faculty.Id};

        CCON_Faculty_TDTM cls = new CCON_Faculty_TDTM();

        Test.startTest();
        Map<Id, Map<Id, List<Affiliation__c>>> contactAccountAfflMap = cls.getContactIdAccountIdAffiliationsList(contactIds);
        Test.stopTest();

        System.assertEquals(true, contactAccountAfflMap.containsKey(faculty.Id));
        System.assertEquals(true, contactAccountAfflMap.get(faculty.Id).containsKey(dpt.Id));
        System.assertEquals(affl.Id, contactAccountAfflMap.get(faculty.Id).get(dpt.Id)[0].Id);
    }
}