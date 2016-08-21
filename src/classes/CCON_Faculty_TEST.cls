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
* @group CourseEnrollments
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
    private static Contact faculty3;

    private static void setup() {
        // Enable Course Connections
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Enable_Course_Connections__c = true,
                Default_Faculty_RecordType_Id__c = UTIL_CustomSettingsFacade.getFacultyConnectionRecTypeID()
            )
        );

    	// Create university
    	university = new Account(Name = 'Advanced University');
    	insert university;

    	// Create department
    	dpt = new Account(Name = 'Biology Department', Parent = university);
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
    	faculty3 = new Contact(FirstName = 'Test3', LastName = 'Testerson3');

        // Insert objects together
    	insert new List<SObject>{
            offering,
            offering2,
            faculty,
            faculty2,
            faculty3
        };
    }

    /*********************************************************************************************************
    * @description Verifies that a new Course Connection was created with an Affiliation
    */
    @isTest
    public static void newCourseConnection() {
    	setup();

        // Create Course Connection
        Course_Enrollment__c conn = new Course_Enrollment__c(
            Contact__c = faculty.Id,
            Course_Offering__c = offering.Id,
            Primary__c = false,
            RecordTypeId = UTIL_CustomSettingsFacade.getFacultyConnectionRecTypeID()
        );

        Test.startTest();
        insert conn;
        Test.stopTest();

        conn = [SELECT Id, Affiliation__c FROM Course_Enrollment__c WHERE Id = :conn.Id];

        System.assertNotEquals(null, conn.Affiliation__c);

    }

    /*********************************************************************************************************
    * @description Verifies that an existing Course Connection that is marked as Primary is populated on the
    * Course Offering
    */
    @isTest
    public static void existingCourseConnectionMadePrimary() {
    	setup();

        // Create Course Connection
        Course_Enrollment__c conn = new Course_Enrollment__c(
            Contact__c = faculty.Id,
            Course_Offering__c = offering.Id,
            Primary__c = false,
            RecordTypeId = UTIL_CustomSettingsFacade.getFacultyConnectionRecTypeID()
        );

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

    /*********************************************************************************************************
    * @description Verifies that an existing Primary Course Connection that is marked as not Primary is
    * removed from the Course Offering.
    */
    @isTest
    public static void existingPrimaryCourseConnectionMadeMarkedNotPrimary() {
    	setup();

        // Create Course Connection
        Course_Enrollment__c conn = new Course_Enrollment__c(
            Contact__c = faculty.Id,
            Course_Offering__c = offering.Id,
            Primary__c = true,
            RecordTypeId = UTIL_CustomSettingsFacade.getFacultyConnectionRecTypeID()
        );

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

    /*********************************************************************************************************
    * @description Verifies that a new Course Connection that is created as Primary is populated on the
    * Course Offering
    */
    @isTest
    public static void newPrimaryCourseConnection() {
    	setup();

        // Create Primary Course Connection
        Course_Enrollment__c conn = new Course_Enrollment__c(
            Contact__c = faculty.Id,
            Course_Offering__c = offering.Id,
            Primary__c = true,
            RecordTypeId = UTIL_CustomSettingsFacade.getFacultyConnectionRecTypeID()
        );

        Test.startTest();
        insert conn;
        Test.stopTest();

        offering = [SELECT Id, Faculty__c FROM Course_Offering__c WHERE Id = :offering.Id];
        System.assertEquals(faculty.Id, offering.Faculty__c);
    }

    /*********************************************************************************************************
    * @description Verifies that an existing Course Connection that is marked as primary on a
    * Course Offering that already has a Primary Course Connection is marked Primary and the other is no
    * longer marked Primary.
    */
    @isTest
    public static void changePrimaryCourseConnection() {
    	setup();

        // Create Primary Course Connection
        Course_Enrollment__c conn = new Course_Enrollment__c(
            Contact__c = faculty.Id,
            Course_Offering__c = offering.Id,
            Primary__c = true,
            RecordTypeId = UTIL_CustomSettingsFacade.getFacultyConnectionRecTypeID()
        );
        // Create second Course Connection
        Course_Enrollment__c conn2 = new Course_Enrollment__c(
            Contact__c = faculty2.Id,
            Course_Offering__c = offering.Id,
            Primary__c = false,
            RecordTypeId = UTIL_CustomSettingsFacade.getFacultyConnectionRecTypeID()
        );
        insert new List<Course_Enrollment__c>{
            conn,
            conn2
        };

        // Check that the first faculty is Primary.
        offering = [SELECT Id, Faculty__c FROM Course_Offering__c WHERE Id = :offering.Id];
        System.assertEquals(faculty.Id, offering.Faculty__c);

        // Mark the second Course Connection as Primary.
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

    /*********************************************************************************************************
    * @description Verifies that an additional Affiliation is not created when one for the given Dept already.
    * The additional Connections should be linked to the existing Affiliation.
    */
    @isTest
    public static void newPrimaryCourseConnectionWhenAffiliationExists() {
    	setup();

        // Create Course Connection on first Course Offering, an Affiliation should be created
        Course_Enrollment__c conn = new Course_Enrollment__c(
            Contact__c = faculty.Id,
            Course_Offering__c = offering.Id,
            Primary__c = false,
            RecordTypeId = UTIL_CustomSettingsFacade.getFacultyConnectionRecTypeID()
        );

        insert conn;

        // Check that an Affilition was created.
        List<Affiliation__c> affls = [SELECT Id, Contact__c FROM Affiliation__c WHERE Contact__c = :faculty.Id];
        System.assertEquals(1, affls.size());

        // Create Second Course Connection on a different Course Offering in same Dept.
        // An Affiliation should not be created but instead the existing should be linked.
        Course_Enrollment__c conn2 = new Course_Enrollment__c(
            Contact__c = faculty.Id,
            Course_Offering__c = offering2.Id,
            Primary__c = true,
            RecordTypeId = UTIL_CustomSettingsFacade.getFacultyConnectionRecTypeID()
        );

        Test.startTest();
        insert conn2;
        Test.stopTest();

        // Check that an additional Affilition was not created.
        affls = [SELECT Id, Contact__c FROM Affiliation__c WHERE Contact__c = :faculty.Id];
        System.assertEquals(1, affls.size());

        //Check that the Affiliation Id is the same on both Course Connections. There should only be two.
        List<Course_Enrollment__c> conns = [SELECT Id, Affiliation__c FROM Course_Enrollment__c];
        System.assertEquals(2, conns.size());
        System.assertEquals(conns[0].Affiliation__c, conns[1].Affiliation__c);
    }
}