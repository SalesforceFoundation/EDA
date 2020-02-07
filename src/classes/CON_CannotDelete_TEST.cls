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
* @group Contacts
* @group-content ../../ApexDocContent/Contacts.htm
* @description Tests for CON_CannotDelete_TDTM.
*/
@isTest
private with sharing class CON_CannotDelete_TEST {
    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
    * Contact has an Address record associated to it, that it cannot be deleted.
    */
    @isTest
    private static void conCannotDeleteWithAddress() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = true));

        UTIL_UnitTestData_TEST.ContactsWithAddrs consAccsAddrs =
            UTIL_UnitTestData_TEST.createTestContactsAddrs(2);

        List<Contact> returnNewContacts = consAccsAddrs.contacts;


        List<Contact> queryContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :returnNewContacts];

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(queryContacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :queryContacts];

        //Verfies that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
    * Contact has an Affiliation record associated to it, that it cannot be deleted.
    */
    @isTest
    private static void conCannotDeleteWithAffiliation() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = true));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        List<Affiliation__c> affiliations = new List<Affiliation__c>{
            new Affiliation__c(Account__c = acc.Id, Contact__c = contacts[0].Id),
            new Affiliation__c(Account__c = acc.Id, Contact__c = contacts[1].Id)
        };
        insert affiliations;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
    * Contact has an Applicant Application record associated to it, that it cannot be deleted.
    */
    @isTest
    private static void conCannotDeleteWithApplicant() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = true));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        List<Application__c> applicants = new List<Application__c>{
            new Application__c(Applying_To__c = acc.Id, Applicant__c = contacts[0].Id),
            new Application__c(Applying_To__c = acc.Id, Applicant__c = contacts[1].Id)
        };
        insert applicants;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
    * Contact has an Preparer Application record associated to it, that it cannot be deleted.
    */
    @isTest
    private static void conCannotDeleteWithAppPreparer() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = true));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        List<Application__c> preparers = new List<Application__c>{
            new Application__c(Applying_To__c  = acc.Id, Applicant__c  = contacts[0].Id, Preparer__c = contacts[1].Id),
            new Application__c(Applying_To__c  = acc.Id, Applicant__c  = contacts[1].Id, Preparer__c = contacts[0].Id)
        };
        insert preparers;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
    * Contact has an Attendance record associated to it, that it cannot be deleted.
    */
    @isTest
    private static void conCannotDeleteWithAttendance() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = true));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        List<Attendance_Event__c> attendanceEvents = new List<Attendance_Event__c>{
            new Attendance_Event__c (Date__c = System.today(), Contact__c = contacts[0].Id),
            new Attendance_Event__c (Date__c = System.today(), Contact__c = contacts[1].Id)
        };
        insert attendanceEvents;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
    * Contact has a Credential Attribute record associated to it, that it cannot be deleted.
    */
    @isTest
    private static void conCannotDeleteWithAttributeCredentials() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = true));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Id credentialRecTypeId = UTIL_Describe_API.getCredentialAttributeRecType();
        List<Attribute__c> credentialsAttributes = new List<Attribute__c>{
            new Attribute__c (Name = 'TestCred1', Contact__c = contacts[0].Id, RecordTypeId = credentialRecTypeId),
            new Attribute__c (Name = 'TestCred2', Contact__c = contacts[1].Id, RecordTypeId = credentialRecTypeId)
        };
        insert credentialsAttributes;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
    * Contact has a Student Attribute record associated to it, that it cannot be deleted.
    */
    @isTest
    private static void conCannotDeleteWithAttributeStudent() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = true));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Id studentCharRecTypeId = UTIL_Describe_API.getStudentCharacteristicAttributeRecType();
        List<Attribute__c> studentCharAttributes = new List<Attribute__c>{
            new Attribute__c (Name = 'TestCred1', Contact__c = contacts[0].Id, RecordTypeId = studentCharRecTypeId),
            new Attribute__c (Name = 'TestCred2', Contact__c = contacts[1].Id, RecordTypeId = studentCharRecTypeId)
        };
        insert studentCharAttributes;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
    * Contact has a Behavior Involvement record associated to it, that it cannot be deleted.
    */
    @isTest
    private static void conCannotDeleteWithBehaviorInvolvement() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = true));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        List<Case> cases = new List<Case>{
            new Case(AccountId = acc.Id, Category__c = 'School Code of Conduct', Occurrence_Date__c = System.now()),
            new Case(AccountId = acc.Id, Category__c = 'School Code of Conduct', Occurrence_Date__c = System.now())
        };
        insert cases;

        List<Behavior_Involvement__c> behaviorInvolvements = new List<Behavior_Involvement__c>{
            new Behavior_Involvement__c(Case__c = cases[0].Id, Contact__c = contacts[0].Id, Role__c = 'Reporter'),
            new Behavior_Involvement__c(Case__c = cases[1].Id, Contact__c = contacts[1].Id, Role__c = 'Reporter')
        };
        insert behaviorInvolvements;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
    * Contact has a Contact Language record associated to it, that it cannot be deleted.
    */
    @isTest
    private static void conCannotDeleteWithConLanguage() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = true));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Language__c language = new Language__c(Name = 'Spanish');
        insert language;

        List<Contact_Language__c> contactLanguages = new List<Contact_Language__c>{
            new Contact_Language__c(Contact__c = contacts[0].Id, Language__c = language.Id),
            new Contact_Language__c(Contact__c = contacts[1].Id, Language__c = language.Id)
        };
        insert contactLanguages;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
    * Contact has a Course Offering record associated to it, that it cannot be deleted.
    */
    @isTest
    private static void conCannotDeleteWithCourseOffering() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = true));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = new Term__c(Name = 'Fall', Account__c = acc.Id);
        insert term;

        Course__c course = new Course__c(Name = 'Biology', Account__c = acc.Id);
        insert course;

        List<Course_Offering__c> courseOfferings = new List<Course_Offering__c>{
            new Course_Offering__c(Faculty__c = contacts[0].Id, Course__c = course.Id, Term__c = term.Id),
            new Course_Offering__c(Faculty__c = contacts[1].Id, Course__c = course.Id, Term__c = term.Id)
        };
        insert courseOfferings;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
    * Contact has a Student Course Connection record associated to it, that it cannot be deleted.
    */
    @isTest
    private static void conCannotDeleteWithStudentCourseCxn() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = true));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = new Term__c(Name = 'Fall', Account__c = acc.Id);
        insert term;

        Course__c course = new Course__c(Name = 'Biology', Account__c = acc.Id);
        insert course;

        Course_Offering__c courseOffering = new Course_Offering__c(Course__c = course.Id, Term__c = term.Id);
        insert courseOffering;

        Id studentCourseCxnRecTypeId = UTIL_Describe_API.getStudentConnectionRecType();
        List<Course_Enrollment__c> studentCourseCxns = new List<Course_Enrollment__c>{
            new Course_Enrollment__c(Course_Offering__c = courseOffering.Id, Status__c = 'Current', Contact__c = contacts[0].Id),
            new Course_Enrollment__c(Course_Offering__c = courseOffering.Id, Status__c = 'Current', Contact__c = contacts[1].Id)
        };
        insert studentCourseCxns;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
    * Contact has a Faculty Course Connection record associated to it, that it cannot be deleted.
    */
    @isTest
    private static void conCannotDeleteWithFacultyCourseCxn() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = true));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = new Term__c(Name = 'Fall', Account__c = acc.Id);
        insert term;

        Course__c course = new Course__c(Name = 'Biology', Account__c = acc.Id);
        insert course;

        Course_Offering__c courseOffering = new Course_Offering__c(Course__c = course.Id, Term__c = term.Id);
        insert courseOffering;

        Id studentCourseCxnRecTypeId = UTIL_Describe_API.getFacultyConnectionRecType();
        List<Course_Enrollment__c> studentCourseCxns = new List<Course_Enrollment__c>{
            new Course_Enrollment__c(Course_Offering__c = courseOffering.Id, Status__c = 'Current', Contact__c = contacts[0].Id),
            new Course_Enrollment__c(Course_Offering__c = courseOffering.Id, Status__c = 'Current', Contact__c = contacts[1].Id)
        };
        insert studentCourseCxns;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

	/*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
    * Contact has a Program Enrollment record associated to it, that it cannot be deleted.
    */
    @isTest
    private static void conCannotDeleteWithProgramEnrollment() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = true));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        List<Program_Enrollment__c> programEnrollments = new List<Program_Enrollment__c>{
            new Program_Enrollment__c(Account__c = acc.Id, Contact__c = contacts[0].Id),
            new Program_Enrollment__c(Account__c = acc.Id, Contact__c = contacts[1].Id)
        };
        insert programEnrollments;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
    * Contact has a Term Grade record associated to it, that it cannot be deleted.
    */
    @isTest
    private static void conCannotDeleteWithTermGrade() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = true));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = new Term__c(Name = 'Fall', Account__c = acc.Id);
        insert term;

        Course__c course = new Course__c(Name = 'Biology', Account__c = acc.Id);
        insert course;

        List<Course_Offering__c> courseOfferings = new List<Course_Offering__c>{
            new Course_Offering__c(Faculty__c = contacts[0].Id, Course__c = course.Id, Term__c = term.Id),
            new Course_Offering__c(Faculty__c = contacts[1].Id, Course__c = course.Id, Term__c = term.Id)
        };
        insert courseOfferings;

        List<Term_Grade__c> termGrades = new List<Term_Grade__c>{
            new Term_Grade__c(Course_Offering__c = courseOfferings[0].Id, Contact__c = contacts[0].Id),
            new Term_Grade__c(Course_Offering__c = courseOfferings[1].Id, Contact__c = contacts[1].Id)
        };
        insert termGrades;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
    * Contact has a Test record associated to it, that it cannot be deleted.
    */
    @isTest
    private static void conCannotDeleteWithTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = true));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;


        List<Test__c> tests = new List<Test__c>{
            new Test__c(Test_Type__c = 'SAT', Test_Date__c = System.today(), Contact__c = contacts[0].Id),
            new Test__c(Test_Type__c = 'SAT', Test_Date__c = System.today(), Contact__c = contacts[1].Id)
        };
        insert tests;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
    * Contact has an Address record associated to it, that it can be deleted.
    */
    @isTest
    private static void conCanDeleteWithAddress() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = false));

        UTIL_UnitTestData_TEST.ContactsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);

        List<Contact> returnNewContacts = consAccsAddrs.contacts;


        List<Contact> queryContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :returnNewContacts];

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(queryContacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :queryContacts];

        //Verfies that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());

    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
    * Contact has an Affiliation record associated to it, that it can be deleted.
    */
    @isTest
    private static void conCanDeleteWithAffiliation() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = false));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        List<Affiliation__c> affiliations = new List<Affiliation__c>{
            new Affiliation__c(Account__c = acc.Id, Contact__c = contacts[0].Id),
            new Affiliation__c(Account__c = acc.Id, Contact__c = contacts[1].Id)
        };
        insert affiliations;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that all of Contact the records were deleted
        System.assertEquals(0, returnContacts.size());

    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
    * Contact has an Applicant Application record associated to it, that it can be deleted.
    */
    @isTest
    private static void conCanDeleteWithApplicant() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = false));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        List<Application__c> applicants = new List<Application__c>{
            new Application__c(Applying_To__c = acc.Id, Applicant__c = contacts[0].Id),
            new Application__c(Applying_To__c = acc.Id, Applicant__c = contacts[1].Id)
        };
        insert applicants;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());

    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
    * Contact has an Preparer Application record associated to it, that it can be deleted.
    */
    @isTest
    private static void conCanDeleteWithAppPreparer() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = false));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        List<Application__c> preparers = new List<Application__c>{
            new Application__c(Applying_To__c  = acc.Id, Applicant__c  = contacts[0].Id, Preparer__c = contacts[1].Id),
            new Application__c(Applying_To__c  = acc.Id, Applicant__c  = contacts[1].Id, Preparer__c = contacts[0].Id)
        };
        insert preparers;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());

    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
    * Contact has an Attendance record associated to it, that it cannot be deleted.
    */
    @isTest
    private static void conCanDeleteWithAttendance() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = false));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        List<Attendance_Event__c> attendanceEvents = new List<Attendance_Event__c>{
            new Attendance_Event__c (Date__c = System.today(), Contact__c = contacts[0].Id),
            new Attendance_Event__c (Date__c = System.today(), Contact__c = contacts[1].Id)
        };
        insert attendanceEvents;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());

    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
    * Contact has a Credential Attribute record associated to it, that it can be deleted.
    */
    @isTest
    private static void conCanDeleteWithAttributeCredentials() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = false));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Id credentialRecTypeId = UTIL_Describe_API.getCredentialAttributeRecType();
        List<Attribute__c> credentialsAttributes = new List<Attribute__c>{
            new Attribute__c (Name = 'TestCred1', Contact__c = contacts[0].Id, RecordTypeId = credentialRecTypeId),
            new Attribute__c (Name = 'TestCred2', Contact__c = contacts[1].Id, RecordTypeId = credentialRecTypeId)
        };
        insert credentialsAttributes;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());

    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
    * Contact has a Student Attribute record associated to it, that it can be deleted.
    */
    @isTest
    private static void conCanDeleteWithAttributeStudent() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = false));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Id studentCharRecTypeId = UTIL_Describe_API.getStudentCharacteristicAttributeRecType();
        List<Attribute__c> studentCharAttributes = new List<Attribute__c>{
            new Attribute__c (Name = 'TestCred1', Contact__c = contacts[0].Id, RecordTypeId = studentCharRecTypeId),
            new Attribute__c (Name = 'TestCred2', Contact__c = contacts[1].Id, RecordTypeId = studentCharRecTypeId)
        };
        insert studentCharAttributes;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());

    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
    * Contact has a Behavior Involvement record associated to it, that it cannot be deleted.
    */
    @isTest
    private static void conCanDeleteWithBehaviorInvolvement() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = false));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        List<Case> cases = new List<Case>{
            new Case(AccountId = acc.Id, Category__c = 'School Code of Conduct', Occurrence_Date__c = System.now()),
            new Case(AccountId = acc.Id, Category__c = 'School Code of Conduct', Occurrence_Date__c = System.now())
        };
        insert cases;

        List<Behavior_Involvement__c> behaviorInvolvements = new List<Behavior_Involvement__c>{
            new Behavior_Involvement__c(Case__c = cases[0].Id, Contact__c = contacts[0].Id, Role__c = 'Reporter'),
            new Behavior_Involvement__c(Case__c = cases[1].Id, Contact__c = contacts[1].Id, Role__c = 'Reporter')
        };
        insert behaviorInvolvements;


        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());

    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
    * Contact has a Contact Language record associated to it, that it can be deleted.
    */
    @isTest
    private static void conCanDeleteWithConLanguage() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = false));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Language__c language = new Language__c(Name = 'Spanish');
        insert language;

        List<Contact_Language__c> contactLanguages = new List<Contact_Language__c>{
            new Contact_Language__c(Contact__c = contacts[0].Id, Language__c = language.Id),
            new Contact_Language__c(Contact__c = contacts[1].Id, Language__c = language.Id)
        };
        insert contactLanguages;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());

    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
    * Contact has a Course Offering record associated to it, that it can be deleted.
    */
    @isTest
    private static void conCanDeleteWithCourseOffering() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = false));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = new Term__c(Name = 'Fall', Account__c = acc.Id);
        insert term;

        Course__c course = new Course__c(Name = 'Biology', Account__c = acc.Id);
        insert course;

        List<Course_Offering__c> courseOfferings = new List<Course_Offering__c>{
            new Course_Offering__c(Faculty__c = contacts[0].Id, Course__c = course.Id, Term__c = term.Id),
            new Course_Offering__c(Faculty__c = contacts[1].Id, Course__c = course.Id, Term__c = term.Id)
        };
        insert courseOfferings;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());

    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
    * Contact has a Student Course Connection record associated to it, that it can be deleted.
    */
    @isTest
    private static void conCanDeleteWithStudentCourseCxn() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = false));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = new Term__c(Name = 'Fall', Account__c = acc.Id);
        insert term;

        Course__c course = new Course__c(Name = 'Biology', Account__c = acc.Id);
        insert course;

        Course_Offering__c courseOffering = new Course_Offering__c(Course__c = course.Id, Term__c = term.Id);
        insert courseOffering;

        Id studentCourseCxnRecTypeId = UTIL_Describe_API.getStudentConnectionRecType();
        List<Course_Enrollment__c> studentCourseCxns = new List<Course_Enrollment__c>{
            new Course_Enrollment__c(Course_Offering__c = courseOffering.Id, Status__c = 'Current', Contact__c = contacts[0].Id),
            new Course_Enrollment__c(Course_Offering__c = courseOffering.Id, Status__c = 'Current', Contact__c = contacts[1].Id)
        };
        insert studentCourseCxns;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());

    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
    * Contact has a Faculty Course Connection record associated to it, that it can be deleted.
    */
    @isTest
    private static void conCanDeleteWithFacultyCourseCxn() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = false));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = new Term__c(Name = 'Fall', Account__c = acc.Id);
        insert term;

        Course__c course = new Course__c(Name = 'Biology', Account__c = acc.Id);
        insert course;

        Course_Offering__c courseOffering = new Course_Offering__c(Course__c = course.Id, Term__c = term.Id);
        insert courseOffering;

        Id studentCourseCxnRecTypeId = UTIL_Describe_API.getFacultyConnectionRecType();
        List<Course_Enrollment__c> studentCourseCxns = new List<Course_Enrollment__c>{
            new Course_Enrollment__c(Course_Offering__c = courseOffering.Id, Status__c = 'Current', Contact__c = contacts[0].Id),
            new Course_Enrollment__c(Course_Offering__c = courseOffering.Id, Status__c = 'Current', Contact__c = contacts[1].Id)
        };
        insert studentCourseCxns;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());

    }

	/*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
    * Contact has a Program Enrollment record associated to it, that it can be deleted.
    */
    @isTest
    private static void conCanDeleteWithProgramEnrollment() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = false));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        List<Program_Enrollment__c> programEnrollments = new List<Program_Enrollment__c>{
            new Program_Enrollment__c(Account__c = acc.Id, Contact__c = contacts[0].Id),
            new Program_Enrollment__c(Account__c = acc.Id, Contact__c = contacts[1].Id)
        };
        insert programEnrollments;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());

    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
    * Contact has a Term Grade record associated to it, that it can be deleted.
    */
    @isTest
    private static void conCanDeleteWithTermGrade() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = false));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = new Term__c(Name = 'Fall', Account__c = acc.Id);
        insert term;

        Course__c course = new Course__c(Name = 'Biology', Account__c = acc.Id);
        insert course;

        List<Course_Offering__c> courseOfferings = new List<Course_Offering__c>{
            new Course_Offering__c(Faculty__c = contacts[0].Id, Course__c = course.Id, Term__c = term.Id),
            new Course_Offering__c(Faculty__c = contacts[1].Id, Course__c = course.Id, Term__c = term.Id)
        };
        insert courseOfferings;

        List<Term_Grade__c> termGrades = new List<Term_Grade__c>{
            new Term_Grade__c(Course_Offering__c = courseOfferings[0].Id, Contact__c = contacts[0].Id),
            new Term_Grade__c(Course_Offering__c = courseOfferings[1].Id, Contact__c = contacts[1].Id)
        };
        insert termGrades;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());

    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
    * Contact has a Test record associated to it, that it can be deleted.
    */
    @isTest
    private static void conCanDeleteWithTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = false));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;


        List<Test__c> tests = new List<Test__c>{
            new Test__c(Test_Type__c = 'SAT', Test_Date__c = System.today(), Contact__c = contacts[0].Id),
            new Test__c(Test_Type__c = 'SAT', Test_Date__c = System.today(), Contact__c = contacts[1].Id)
        };
        insert tests;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id
                                       FROM Contact
                                       WHERE Id IN :contacts];

        //Verfies that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());

    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings,and the
    * Contact record has different child records associated to it,then it cannot be deleted.
    */
    @isTest
    private static void cannotDelete() {
		UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = true));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        Contact[] contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = new Term__c(Name = 'Fall', Account__c = acc.Id);
        insert term;

        Course__c course = new Course__c(Name = 'Biology', Account__c = acc.Id);
        insert course;

        List<Affiliation__c> affiliations = new List<Affiliation__c>{
            new Affiliation__c(Account__c = acc.Id, Contact__c = contacts[0].Id),
            new Affiliation__c(Account__c = acc.Id, Contact__c = contacts[1].Id)
        };
        insert affiliations;

        List<Application__c> applicants = new List<Application__c>{
            new Application__c(Applying_To__c = acc.Id, Applicant__c = contacts[0].Id),
            new Application__c(Applying_To__c = acc.Id, Applicant__c = contacts[1].Id)
        };
        insert applicants;

        List<Attendance_Event__c> attendanceEvents = new List<Attendance_Event__c>{
            new Attendance_Event__c (Date__c = System.today(), Contact__c = contacts[0].Id),
            new Attendance_Event__c (Date__c = System.today(), Contact__c = contacts[1].Id)
        };
        insert attendanceEvents;

        Id credentialRecTypeId = UTIL_Describe_API.getCredentialAttributeRecType();
        List<Attribute__c> credentialsAttributes = new List<Attribute__c>{
            new Attribute__c (Name = 'TestCred1', Contact__c = contacts[0].Id, RecordTypeId = credentialRecTypeId),
            new Attribute__c (Name = 'TestCred2', Contact__c = contacts[1].Id, RecordTypeId = credentialRecTypeId)
        };
        insert credentialsAttributes;

        List<Case> cases = new List<Case>{
            new Case(ContactId = contacts[0].Id, AccountId = acc.Id, Category__c = 'School Code of Conduct', Occurrence_Date__c = System.now()),
            new Case(ContactId = contacts[1].Id, AccountId = acc.Id, Category__c = 'School Code of Conduct', Occurrence_Date__c = System.now())
        };
        insert cases;

       	Language__c language = new Language__c(Name = 'Spanish');
        insert language;

        List<Contact_Language__c> contactLanguages = new List<Contact_Language__c>{
            new Contact_Language__c(Contact__c = contacts[0].Id, Language__c = language.Id),
            new Contact_Language__c(Contact__c = contacts[1].Id, Language__c = language.Id)
        };
        insert contactLanguages;

        List<Course_Offering__c> courseOfferings = new List<Course_Offering__c>{
            new Course_Offering__c(Faculty__c = contacts[0].Id, Course__c = course.Id, Term__c = term.Id),
            new Course_Offering__c(Faculty__c = contacts[1].Id, Course__c = course.Id, Term__c = term.Id)
        };
        insert courseOfferings;

        List<Term_Grade__c> termGrades = new List<Term_Grade__c>{
            new Term_Grade__c(Course_Offering__c = courseOfferings[0].Id, Contact__c = contacts[0].Id),
            new Term_Grade__c(Course_Offering__c = courseOfferings[1].Id, Contact__c = contacts[1].Id)
        };
        insert termGrades;

        Id studentCourseCxnRecTypeId = UTIL_Describe_API.getStudentConnectionRecType();
        List<Course_Enrollment__c> studentCourseCxns = new List<Course_Enrollment__c>{
            new Course_Enrollment__c(Course_Offering__c = courseOfferings[0].Id, Status__c = 'Current', Contact__c = contacts[0].Id),
            new Course_Enrollment__c(Course_Offering__c = courseOfferings[1].Id, Status__c = 'Current', Contact__c = contacts[1].Id)
        };
        insert studentCourseCxns;

        List<Program_Enrollment__c> programEnrollments = new List<Program_Enrollment__c>{
            new Program_Enrollment__c(Account__c = acc.Id, Contact__c = contacts[0].Id),
            new Program_Enrollment__c(Account__c = acc.Id, Contact__c = contacts[1].Id)
        };
        insert programEnrollments;

        List<Test__c> tests = new List<Test__c>{
            new Test__c(Test_Type__c = 'SAT', Test_Date__c = System.today(), Contact__c = contacts[0].Id),
            new Test__c(Test_Type__c = 'SAT', Test_Date__c = System.today(), Contact__c = contacts[1].Id)
        };
        insert tests;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        //Verify that none of the Contact records were deleted
        List<Contact> returnContacts = [SELECT Id
                                        FROM Contact
                                        WHERE Id IN :contacts];
        System.assertEquals(2, contacts.size());
        System.assertEquals(false, results[0].success);
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
        System.assertEquals(false, results[1].success);
        System.assertEquals(Label.CannotDelete, results[1].errors[0].message);
    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and if
    * one of the Contact record has child records associated to it, then it should be deleted. The Contact record
    * that do not have any child related records should not be deleted.
    */
    @isTest
    private static void cannotDeleteSomeContacts() {
		UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = true));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        Contact[] contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = new Term__c(Name = 'Fall', Account__c = acc.Id);
        insert term;

        Course__c course = new Course__c(Name = 'Biology', Account__c = acc.Id);
        insert course;

        Affiliation__c affilliation = new Affiliation__c(Account__c = acc.Id, Contact__c = contacts[1].Id);
        insert affilliation;

        Application__c applicant = new Application__c(Applying_To__c = acc.Id, Applicant__c = contacts[1].Id);
        insert applicant;

        Attendance_Event__c attendance = new Attendance_Event__c(Date__c = System.today(), Contact__c = contacts[1].Id);
        insert attendance;

        Id credentialRecTypeId = UTIL_Describe_API.getCredentialAttributeRecType();
        Attribute__c credentialAttribute = new Attribute__c(Name = 'TestCred2', Contact__c = contacts[1].Id, RecordTypeId = credentialRecTypeId);
        insert credentialAttribute;

        Case caseRecord = new Case(ContactId = contacts[1].Id, AccountId = acc.Id, Category__c = 'School Code of Conduct', Occurrence_Date__c = System.now());
        insert caseRecord;

       	Language__c language = new Language__c(Name = 'Spanish');
        insert language;

        Contact_Language__c contactLanguage = new Contact_Language__c(Contact__c = contacts[1].Id, Language__c = language.Id);
        insert contactLanguage;

        Course_Offering__c courseOffering = new Course_Offering__c(Faculty__c = contacts[1].Id, Course__c = course.Id, Term__c = term.Id);
        insert courseOffering;

		Term_Grade__c termGrade = new Term_Grade__c(Course_Offering__c = courseOffering.Id, Contact__c = contacts[1].Id);
        insert termGrade;

        Course_Enrollment__c courseCxn = new Course_Enrollment__c(Course_Offering__c = courseOffering.Id, Status__c = 'Current', Contact__c = contacts[1].Id);
        insert courseCxn;

        Program_Enrollment__c programEnrollment = new Program_Enrollment__c(Account__c = acc.Id, Contact__c = contacts[1].Id);
        insert programEnrollment;

        Test__c testRecord = new Test__c(Test_Type__c = 'SAT', Test_Date__c = System.today(), Contact__c = contacts[1].Id);
        insert testRecord;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        //Verify that 1 of the Contact records was deleted
        List<Contact> returnContacts = [SELECT Id
                                        FROM Contact
                                        WHERE Id IN :contacts];
        System.assertEquals(true, results[0].success);
        System.assertEquals(false, results[1].success);
        System.assertEquals(Label.CannotDelete, results[1].errors[0].message);
    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings,and the
    * Contact record has different child records associated to it,then it can be deleted.
    */
    @isTest
    private static void canDelete() {
		UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = false));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = new Term__c(Name = 'Fall', Account__c = acc.Id);
        insert term;

        Course__c course = new Course__c(Name = 'Biology', Account__c = acc.Id);
        insert course;

        List<Affiliation__c> affiliations = new List<Affiliation__c>{
            new Affiliation__c(Account__c = acc.Id, Contact__c = contacts[0].Id),
            new Affiliation__c(Account__c = acc.Id, Contact__c = contacts[1].Id)
        };
        insert affiliations;

        List<Application__c> applicants = new List<Application__c>{
            new Application__c(Applying_To__c = acc.Id, Applicant__c = contacts[0].Id),
            new Application__c(Applying_To__c = acc.Id, Applicant__c = contacts[1].Id)
        };
        insert applicants;

        List<Attendance_Event__c> attendanceEvents = new List<Attendance_Event__c>{
            new Attendance_Event__c (Date__c = System.today(), Contact__c = contacts[0].Id),
            new Attendance_Event__c (Date__c = System.today(), Contact__c = contacts[1].Id)
        };
        insert attendanceEvents;

        Id credentialRecTypeId = UTIL_Describe_API.getCredentialAttributeRecType();
        List<Attribute__c> credentialsAttributes = new List<Attribute__c>{
            new Attribute__c (Name = 'TestCred1', Contact__c = contacts[0].Id, RecordTypeId = credentialRecTypeId),
            new Attribute__c (Name = 'TestCred2', Contact__c = contacts[1].Id, RecordTypeId = credentialRecTypeId)
        };
        insert credentialsAttributes;

        List<Case> cases = new List<Case>{
            new Case(AccountId = acc.Id, Category__c = 'School Code of Conduct', Occurrence_Date__c = System.now()),
            new Case(AccountId = acc.Id, Category__c = 'School Code of Conduct', Occurrence_Date__c = System.now())
        };
        insert cases;

        List<Behavior_Involvement__c> behaviorInvolvements = new List<Behavior_Involvement__c>{
            new Behavior_Involvement__c(Case__c = cases[0].Id, Contact__c = contacts[0].Id, Role__c = 'Reporter'),
            new Behavior_Involvement__c(Case__c = cases[1].Id, Contact__c = contacts[1].Id, Role__c = 'Reporter')
        };
        insert behaviorInvolvements;

       	Language__c language = new Language__c(Name = 'Spanish');
        insert language;

        List<Contact_Language__c> contactLanguages = new List<Contact_Language__c>{
            new Contact_Language__c(Contact__c = contacts[0].Id, Language__c = language.Id),
            new Contact_Language__c(Contact__c = contacts[1].Id, Language__c = language.Id)
        };
        insert contactLanguages;

        List<Course_Offering__c> courseOfferings = new List<Course_Offering__c>{
            new Course_Offering__c(Faculty__c = contacts[0].Id, Course__c = course.Id, Term__c = term.Id),
            new Course_Offering__c(Faculty__c = contacts[1].Id, Course__c = course.Id, Term__c = term.Id)
        };
        insert courseOfferings;

        List<Term_Grade__c> termGrades = new List<Term_Grade__c>{
            new Term_Grade__c(Course_Offering__c = courseOfferings[0].Id, Contact__c = contacts[0].Id),
            new Term_Grade__c(Course_Offering__c = courseOfferings[1].Id, Contact__c = contacts[1].Id)
        };
        insert termGrades;

        Id studentCourseCxnRecTypeId = UTIL_Describe_API.getStudentConnectionRecType();
        List<Course_Enrollment__c> studentCourseCxns = new List<Course_Enrollment__c>{
            new Course_Enrollment__c(Course_Offering__c = courseOfferings[0].Id, Status__c = 'Current', Contact__c = contacts[0].Id),
            new Course_Enrollment__c(Course_Offering__c = courseOfferings[1].Id, Status__c = 'Current', Contact__c = contacts[1].Id)
        };
        insert studentCourseCxns;

        List<Program_Enrollment__c> programEnrollments = new List<Program_Enrollment__c>{
            new Program_Enrollment__c(Account__c = acc.Id, Contact__c = contacts[0].Id),
            new Program_Enrollment__c(Account__c = acc.Id, Contact__c = contacts[1].Id)
        };
        insert programEnrollments;

        List<Test__c> tests = new List<Test__c>{
            new Test__c(Test_Type__c = 'SAT', Test_Date__c = System.today(), Contact__c = contacts[0].Id),
            new Test__c(Test_Type__c = 'SAT', Test_Date__c = System.today(), Contact__c = contacts[1].Id)
        };
        insert tests;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        //Verify that all Contact records were deleted
        List<Contact> returnContacts = [SELECT Id
                                        FROM Contact
                                        WHERE Id IN :contacts];
        System.assertEquals(0, returnContacts.size());
    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and if
    * one of the Contact record has child records associated to it, then it should be deleted. The Contact record
    * that do not have any child related records should be deleted.
    */
    @isTest
    private static void canDeleteAllContacts() {
		UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = false));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        Contact[] contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = new Term__c(Name = 'Fall', Account__c = acc.Id);
        insert term;

        Course__c course = new Course__c(Name = 'Biology', Account__c = acc.Id);
        insert course;

        Affiliation__c affilliation = new Affiliation__c(Account__c = acc.Id, Contact__c = contacts[1].Id);
        insert affilliation;

        Application__c applicant = new Application__c(Applying_To__c = acc.Id, Applicant__c = contacts[1].Id);
        insert applicant;

        Attendance_Event__c attendance = new Attendance_Event__c(Date__c = System.today(), Contact__c = contacts[1].Id);
        insert attendance;

        Id credentialRecTypeId = UTIL_Describe_API.getCredentialAttributeRecType();
        Attribute__c credentialAttribute = new Attribute__c(Name = 'TestCred2', Contact__c = contacts[1].Id, RecordTypeId = credentialRecTypeId);
        insert credentialAttribute;

       	Language__c language = new Language__c(Name = 'Spanish');
        insert language;

        Contact_Language__c contactLanguage = new Contact_Language__c(Contact__c = contacts[1].Id, Language__c = language.Id);
        insert contactLanguage;

        Course_Offering__c courseOffering = new Course_Offering__c(Faculty__c = contacts[1].Id, Course__c = course.Id, Term__c = term.Id);
        insert courseOffering;

		Term_Grade__c termGrade = new Term_Grade__c(Course_Offering__c = courseOffering.Id, Contact__c = contacts[1].Id);
        insert termGrade;

        Course_Enrollment__c courseCxn = new Course_Enrollment__c(Course_Offering__c = courseOffering.Id, Status__c = 'Current', Contact__c = contacts[1].Id);
        insert courseCxn;

        Program_Enrollment__c programEnrollment = new Program_Enrollment__c(Account__c = acc.Id, Contact__c = contacts[1].Id);
        insert programEnrollment;

        Test__c testRecord = new Test__c(Test_Type__c = 'SAT', Test_Date__c = System.today(), Contact__c = contacts[1].Id);
        insert testRecord;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(contacts, false);
        Test.stopTest();

        //Verify that all of the Contact records was deleted
        List<Contact> returnContacts = [SELECT Id
                                        FROM Contact
                                        WHERE Id IN :contacts];
        System.assertEquals(0, returnContacts.size());
        System.assertEquals(true, results[0].success);
        System.assertEquals(true, results[1].success);
    }
}