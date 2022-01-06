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
    /**************************************************************************************************************************
     ****************************************************** FUNCTIONAL TESTS ***************************************************
     **************************************************************************************************************************/

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
     * Contact has an Address record associated to it, that it cannot be deleted.
     */
    @isTest
    private static void conCannotDeleteWithAddress() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = true
            )
        );

        UTIL_UnitTestData_TEST.ContactsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);

        List<Contact> returnNewContacts = consAccsAddrs.contacts;

        List<Contact> queryContacts = [SELECT Id FROM Contact WHERE Id IN :returnNewContacts];

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(queryContacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :queryContacts];

        //Verify that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
     * Contact has an Affiliation record associated to it, that it cannot be deleted.
     */
    @isTest
    private static void conCannotDeleteWithAffiliation() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = true
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Affiliation__c affiliation1 = UTIL_UnitTestData_TEST.getAffiliation(contacts[0].Id, acc.Id, false);
        Affiliation__c affiliation2 = UTIL_UnitTestData_TEST.getAffiliation(contacts[1].Id, acc.Id, false);

        insert new List<Affiliation__c>{ affiliation1, affiliation2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnedContactsList = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that none of the Contact records were deleted
        System.assertEquals(2, returnedContactsList.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
     * Contact has an Applicant Application record associated to it, that it cannot be deleted.
     */
    @isTest
    private static void conCannotDeleteWithApplicant() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = true
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = UTIL_UnitTestData_TEST.getTerm(acc.Id, 'Spring 2020');

        Application__c application1 = UTIL_UnitTestData_TEST.getApplication(acc.Id, contacts[0].Id, term.Id);
        Application__c application2 = UTIL_UnitTestData_TEST.getApplication(acc.Id, contacts[1].Id, term.Id);

        insert new List<Application__c>{ application1, application2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
     * Contact has an Preparer Application record associated to it, that it cannot be deleted.
     */
    @isTest
    private static void conCannotDeleteWithAppPreparer() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = true
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = UTIL_UnitTestData_TEST.getTerm(acc.Id, 'Spring 2020');

        Application__c application1 = UTIL_UnitTestData_TEST.getApplication(acc.Id, contacts[0].Id, term.Id);
        application1.Preparer__c = contacts[1].Id;
        Application__c application2 = UTIL_UnitTestData_TEST.getApplication(acc.Id, contacts[1].Id, term.Id);
        application2.Preparer__c = contacts[0].Id;

        insert new List<Application__c>{ application1, application2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
     * Contact has an Attendance record associated to it, that it cannot be deleted.
     */
    @isTest
    private static void conCannotDeleteWithAttendance() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = true
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Attendance_Event__c attendanceEvent1 = UTIL_UnitTestData_TEST.getAttendanceEvent();
        attendanceEvent1.Date__c = System.today();
        attendanceEvent1.Contact__c = contacts[0].Id;

        Attendance_Event__c attendanceEvent2 = UTIL_UnitTestData_TEST.getAttendanceEvent();
        attendanceEvent2.Date__c = System.today();
        attendanceEvent2.Contact__c = contacts[1].Id;

        insert new List<Attendance_Event__c>{ attendanceEvent1, attendanceEvent2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
     * Contact has a Credential Attribute record associated to it, that it cannot be deleted.
     */
    @isTest
    private static void conCannotDeleteWithAttributeCredentials() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = true
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Id credentialRecTypeId = UTIL_Describe_API.getCredentialAttributeRecType();

        Attribute__c attribute1 = UTIL_UnitTestData_TEST.getAttribute('TestCred1', contacts[0].Id, credentialRecTypeId);
        Attribute__c attribute2 = UTIL_UnitTestData_TEST.getAttribute('TestCred2', contacts[1].Id, credentialRecTypeId);

        insert new List<Attribute__c>{ attribute1, attribute2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
     * Contact has a Student Attribute record associated to it, that it cannot be deleted.
     */
    @isTest
    private static void conCannotDeleteWithAttributeStudent() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = true
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Id studentCharRecTypeId = UTIL_Describe_API.getStudentCharacteristicAttributeRecType();

        Attribute__c attribute1 = UTIL_UnitTestData_TEST.getAttribute(
            'TestCred1',
            contacts[0].Id,
            studentCharRecTypeId
        );
        Attribute__c attribute2 = UTIL_UnitTestData_TEST.getAttribute(
            'TestCred2',
            contacts[1].Id,
            studentCharRecTypeId
        );

        insert new List<Attribute__c>{ attribute1, attribute2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
     * Contact has a Behavior Involvement record associated to it, that it cannot be deleted.
     */
    @isTest
    private static void conCannotDeleteWithBehaviorInvolvement() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = true
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Case case1 = UTIL_UnitTestData_TEST.getCase(null, 'School Code of Conduct', 'Current');
        case1.AccountId = acc.Id;
        Case case2 = UTIL_UnitTestData_TEST.getCase(null, 'School Code of Conduct', 'Current');
        case2.AccountId = acc.Id;

        insert new List<case>{ case1, case2 };

        Behavior_Involvement__c behaviorInvolvement1 = UTIL_UnitTestData_TEST.getBehaviorInvolvementRecord(
            contacts[0].Id,
            case1.Id,
            'Reporter'
        );
        Behavior_Involvement__c behaviorInvolvement2 = UTIL_UnitTestData_TEST.getBehaviorInvolvementRecord(
            contacts[1].Id,
            case2.Id,
            'Reporter'
        );

        insert new List<Behavior_Involvement__c>{ behaviorInvolvement1, behaviorInvolvement2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
     * Contact has a Contact Language record associated to it, that it cannot be deleted.
     */
    @isTest
    private static void conCannotDeleteWithConLanguage() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = true
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Language__c language = UTIL_UnitTestData_TEST.createLanguage('Italian');

        Contact_Language__c contactLanguage1 = UTIL_UnitTestData_TEST.createContactLanguage(
            language.Id,
            contacts[0].Id,
            false
        );
        Contact_Language__c contactLanguage2 = UTIL_UnitTestData_TEST.createContactLanguage(
            language.Id,
            contacts[1].Id,
            false
        );

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
     * Contact has a Course Offering record associated to it, that it cannot be deleted.
     */
    @isTest
    private static void conCannotDeleteWithCourseOffering() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = true
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = UTIL_UnitTestData_TEST.getTerm(acc.Id, 'Fall');
        insert term;

        Course__c course = UTIL_UnitTestData_TEST.getCourse('Biology', acc.Id);
        insert course;

        Course_Offering__c courseOfferings1 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);
        courseOfferings1.Faculty__c = contacts[0].Id;

        Course_Offering__c courseOfferings2 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);
        courseOfferings2.Faculty__c = contacts[1].Id;

        update new List<Course_Offering__c>{ courseOfferings1, courseOfferings2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
     * Contact has a Student Course Connection record associated to it, that it cannot be deleted.
     */
    @isTest
    private static void conCannotDeleteWithStudentCourseCxn() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = true
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = UTIL_UnitTestData_TEST.getTerm(acc.Id, 'Fall');
        insert term;

        Course__c course = UTIL_UnitTestData_TEST.getCourse('Biology', acc.Id);
        insert course;

        Course_Offering__c courseOffering = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);

        Id studentCourseCxnRecTypeId = UTIL_Describe_API.getStudentConnectionRecType();

        Course_Enrollment__c studentCourseCxn1 = UTIL_UnitTestData_TEST.getCourseConnection(
            contacts[0].Id,
            courseOffering.Id
        );
        studentCourseCxn1.Status__c = 'Current';

        Course_Enrollment__c studentCourseCxn2 = UTIL_UnitTestData_TEST.getCourseConnection(
            contacts[1].Id,
            courseOffering.Id
        );
        studentCourseCxn2.Status__c = 'Current';

        insert new List<Course_Enrollment__c>{ studentCourseCxn1, studentCourseCxn2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
     * Contact has an Education History record associated to it, that it cannot be deleted.
     */
    @isTest
    private static void conCannotDeleteWithEduHistory() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Prevent_Contact_Deletion__c = true));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Education_History__c eduHis = UTIL_UnitTestData_Test.getEduHistory(null, contacts[0].Id);
        insert eduHis;

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that only one of the Contact records was deleted
        System.assertEquals(1, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
     * Contact has a Faculty Course Connection record associated to it, that it cannot be deleted.
     */
    @isTest
    private static void conCannotDeleteWithFacultyCourseCxn() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = true
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = UTIL_UnitTestData_TEST.getTerm(acc.Id, 'Fall');
        insert term;

        Course__c course = UTIL_UnitTestData_TEST.getCourse('Biology', acc.Id);
        insert course;

        Course_Offering__c courseOffering = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);

        Id studentCourseCxnRecTypeId = UTIL_Describe_API.getFacultyConnectionRecType();

        Course_Enrollment__c studentCourseCxn1 = UTIL_UnitTestData_TEST.getCourseConnection(
            contacts[0].Id,
            courseOffering.Id
        );
        studentCourseCxn1.Status__c = 'Current';

        Course_Enrollment__c studentCourseCxn2 = UTIL_UnitTestData_TEST.getCourseConnection(
            contacts[1].Id,
            courseOffering.Id
        );
        studentCourseCxn2.Status__c = 'Current';

        insert new List<Course_Enrollment__c>{ studentCourseCxn1, studentCourseCxn2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
     * Contact has a Program Enrollment record associated to it, that it cannot be deleted.
     */
    @isTest
    private static void conCannotDeleteWithProgramEnrollment() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = true
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Program_Enrollment__c programEnrollment1 = UTIL_UnitTestData_TEST.getProgramEnrollment(acc.Id);
        programEnrollment1.Contact__c = contacts[0].Id;

        Program_Enrollment__c programEnrollment2 = UTIL_UnitTestData_TEST.getProgramEnrollment(acc.Id);
        programEnrollment2.Contact__c = contacts[1].Id;

        insert new List<Program_Enrollment__c>{ programEnrollment1, programEnrollment2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
     * Contact has a Term Grade record associated to it, that it cannot be deleted.
     */
    @isTest
    private static void conCannotDeleteWithTermGrade() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = true
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = UTIL_UnitTestData_TEST.getTerm(acc.Id, 'Fall');
        insert term;

        Course__c course = UTIL_UnitTestData_TEST.getCourse('Biology', acc.Id);
        insert course;

        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);
        Course_Offering__c courseOffering2 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);

        courseOffering1.Faculty__c = contacts[0].Id;
        courseOffering2.Faculty__c = contacts[1].Id;

        List<Course_Offering__c> courseOfferings = new List<Course_Offering__c>();
        courseOfferings.add(courseOffering1);
        courseOfferings.add(courseOffering2);
        update courseOfferings;

        Term_Grade__c termGrade1 = UTIL_UnitTestData_TEST.getTermGrade(contacts[0].Id, courseOfferings[0].Id, null);
        Term_Grade__c termGrade2 = UTIL_UnitTestData_TEST.getTermGrade(contacts[1].Id, courseOfferings[1].Id, null);

        insert new List<Term_Grade__c>{ termGrade1, termGrade2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
     * Contact has a Test record associated to it, that it cannot be deleted.
     */
    @isTest
    private static void conCannotDeleteWithTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = true
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Test__c testRecord1 = UTIL_UnitTestData_TEST.getTest('SAT', System.today(), contacts[0].Id);
        Test__c testRecord2 = UTIL_UnitTestData_TEST.getTest('SAT', System.today(), contacts[1].Id);

        insert new List<Test__c>{ testRecord1, testRecord2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that none of the Contact records were deleted
        System.assertEquals(2, returnContacts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
     * Contact has an Address record associated to it, that it can be deleted.
     */
    @isTest
    private static void conCanDeleteWithAddress() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = false
            )
        );

        UTIL_UnitTestData_TEST.ContactsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);

        List<Contact> returnNewContacts = consAccsAddrs.contacts;

        List<Contact> queryContacts = [SELECT Id FROM Contact WHERE Id IN :returnNewContacts];

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(queryContacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :queryContacts];

        //Verify that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
     * Contact has an Affiliation record associated to it, that it can be deleted.
     */
    @isTest
    private static void conCanDeleteWithAffiliation() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = false
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Affiliation__c affiliation1 = UTIL_UnitTestData_TEST.getAffiliation(contacts[0].Id, acc.Id, false);
        Affiliation__c affiliation2 = UTIL_UnitTestData_TEST.getAffiliation(contacts[1].Id, acc.Id, false);

        insert new List<Affiliation__c>{ affiliation1, affiliation2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that all of Contact the records were deleted
        System.assertEquals(0, returnContacts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
     * Contact has an Applicant Application record associated to it, that it can be deleted.
     */
    @isTest
    private static void conCanDeleteWithApplicant() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = false
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = UTIL_UnitTestData_TEST.getTerm(acc.Id, 'Fall');
        insert term;

        Application__c applicant1 = UTIL_UnitTestData_TEST.getApplication(acc.Id, contacts[0].Id, term.Id);
        Application__c applicant2 = UTIL_UnitTestData_TEST.getApplication(acc.Id, contacts[1].Id, term.Id);

        insert new List<Application__c>{ applicant1, applicant2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
     * Contact has an Preparer Application record associated to it, that it can be deleted.
     */
    @isTest
    private static void conCanDeleteWithAppPreparer() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = false
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = UTIL_UnitTestData_TEST.getTerm(acc.Id, 'Fall');
        insert term;

        Application__c applicant1 = UTIL_UnitTestData_TEST.getApplication(acc.Id, contacts[0].Id, term.Id);
        applicant1.Preparer__c = contacts[1].Id;
        Application__c applicant2 = UTIL_UnitTestData_TEST.getApplication(acc.Id, contacts[1].Id, term.Id);
        applicant2.Preparer__c = contacts[0].Id;

        insert new List<Application__c>{ applicant1, applicant2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and
     * Contact has an Attendance record associated to it, that it cannot be deleted.
     */
    @isTest
    private static void conCanDeleteWithAttendance() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = false
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Attendance_Event__c attendanceEvent1 = UTIL_UnitTestData_TEST.getAttendanceEvent();
        attendanceEvent1.Date__c = System.today();
        attendanceEvent1.Contact__c = contacts[0].Id;

        Attendance_Event__c attendanceEvent2 = UTIL_UnitTestData_TEST.getAttendanceEvent();
        attendanceEvent2.Date__c = System.today();
        attendanceEvent2.Contact__c = contacts[1].Id;

        insert new List<Attendance_Event__c>{ attendanceEvent1, attendanceEvent2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
     * Contact has a Credential Attribute record associated to it, that it can be deleted.
     */
    @isTest
    private static void conCanDeleteWithAttributeCredentials() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = false
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Id credentialRecTypeId = UTIL_Describe_API.getCredentialAttributeRecType();
        Attribute__c credentialAttribute1 = UTIL_UnitTestData_TEST.getAttribute(
            'TestCred1',
            contacts[0].Id,
            credentialRecTypeId
        );
        Attribute__c credentialAttribute2 = UTIL_UnitTestData_TEST.getAttribute(
            'TestCred2',
            contacts[1].Id,
            credentialRecTypeId
        );

        insert new List<Attribute__c>{ credentialAttribute1, credentialAttribute2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
     * Contact has a Behavior Involvement record associated to it, that it cannot be deleted.
     */
    @isTest
    private static void conCanDeleteWithBehaviorInvolvement() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = false
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Case case1 = UTIL_UnitTestData_TEST.getCase(null, 'School Code of Conduct', 'Current');
        case1.AccountId = acc.Id;
        Case case2 = UTIL_UnitTestData_TEST.getCase(null, 'School Code of Conduct', 'Current');
        case2.AccountId = acc.Id;

        insert new List<case>{ case1, case2 };

        Behavior_Involvement__c behaviorInvolvement1 = UTIL_UnitTestData_TEST.getBehaviorInvolvementRecord(
            contacts[0].Id,
            case1.Id,
            'Reporter'
        );
        Behavior_Involvement__c behaviorInvolvement2 = UTIL_UnitTestData_TEST.getBehaviorInvolvementRecord(
            contacts[1].Id,
            case2.Id,
            'Reporter'
        );

        insert new List<Behavior_Involvement__c>{ behaviorInvolvement1, behaviorInvolvement2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
     * Contact has a Contact Language record associated to it, that it can be deleted.
     */
    @isTest
    private static void conCanDeleteWithConLanguage() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = false
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Language__c language = UTIL_UnitTestData_TEST.createLanguage('Spanish');
        Contact_Language__c contactLanguage1 = UTIL_UnitTestData_TEST.createContactLanguage(
            language.Id,
            contacts[0].Id,
            false
        );
        Contact_Language__c contactLanguage2 = UTIL_UnitTestData_TEST.createContactLanguage(
            language.Id,
            contacts[1].Id,
            false
        );

        update new List<Contact_Language__c>{ contactLanguage1, contactLanguage2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
     * Contact has a Course Offering record associated to it, that it can be deleted.
     */
    @isTest
    private static void conCanDeleteWithCourseOffering() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = false
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = UTIL_UnitTestData_TEST.getTerm(acc.Id, 'Fall');
        insert term;

        Course__c course = UTIL_UnitTestData_TEST.getCourse('Biology', acc.Id);
        insert course;

        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);
        courseOffering1.Faculty__c = contacts[0].Id;
        update courseOffering1;

        Course_Offering__c courseOffering2 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);
        courseOffering2.Faculty__c = contacts[1].Id;
        update courseOffering2;

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
     * Contact has a Student Course Connection record associated to it, that it can be deleted.
     */
    @isTest
    private static void conCanDeleteWithStudentCourseCxn() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = false
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = UTIL_UnitTestData_TEST.getTerm(acc.Id, 'Fall');
        insert term;

        Course__c course = UTIL_UnitTestData_TEST.getCourse('Biology', acc.Id);
        insert course;

        Course_Offering__c courseOffering = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);

        Id studentCourseCxnRecTypeId = UTIL_Describe_API.getStudentConnectionRecType();

        Course_Enrollment__c studentCourseCxn1 = UTIL_UnitTestData_TEST.getCourseConnection(
            contacts[0].Id,
            courseOffering.Id
        );
        studentCourseCxn1.Status__c = 'Current';

        Course_Enrollment__c studentCourseCxn2 = UTIL_UnitTestData_TEST.getCourseConnection(
            contacts[1].Id,
            courseOffering.Id
        );
        studentCourseCxn2.Status__c = 'Current';

        insert new List<Course_Enrollment__c>{ studentCourseCxn1, studentCourseCxn2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
     * Contact has a Faculty Course Connection record associated to it, that it can be deleted.
     */
    @isTest
    private static void conCanDeleteWithFacultyCourseCxn() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = false
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = UTIL_UnitTestData_TEST.getTerm(acc.Id, 'Fall');
        insert term;

        Course__c course = UTIL_UnitTestData_TEST.getCourse('Biology', acc.Id);
        insert course;

        Course_Offering__c courseOffering = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);

        Id studentCourseCxnRecTypeId = UTIL_Describe_API.getFacultyConnectionRecType();
        Course_Enrollment__c studentCourseCxn1 = UTIL_UnitTestData_TEST.getCourseConnection(
            contacts[0].Id,
            courseOffering.Id
        );
        studentCourseCxn1.Status__c = 'Current';

        Course_Enrollment__c studentCourseCxn2 = UTIL_UnitTestData_TEST.getCourseConnection(
            contacts[1].Id,
            courseOffering.Id
        );
        studentCourseCxn2.Status__c = 'Current';

        insert new List<Course_Enrollment__c>{ studentCourseCxn1, studentCourseCxn2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
     * Contact has a Program Enrollment record associated to it, that it can be deleted.
     */
    @isTest
    private static void conCanDeleteWithProgramEnrollment() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = false
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Program_Enrollment__c programEnrollment1 = UTIL_UnitTestData_TEST.getProgramEnrollment(acc.Id);
        programEnrollment1.Contact__c = contacts[0].Id;

        Program_Enrollment__c programEnrollment2 = UTIL_UnitTestData_TEST.getProgramEnrollment(acc.Id);
        programEnrollment2.Contact__c = contacts[1].Id;

        insert new List<Program_Enrollment__c>{ programEnrollment1, programEnrollment2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
     * Contact has a Term Grade record associated to it, that it can be deleted.
     */
    @isTest
    private static void conCanDeleteWithTermGrade() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = false
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = UTIL_UnitTestData_TEST.getTerm(acc.Id, 'Fall');
        insert term;

        Course__c course = UTIL_UnitTestData_TEST.getCourse('Biology', acc.Id);
        insert course;

        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);
        courseOffering1.Faculty__c = contacts[0].Id;

        Course_Offering__c courseOffering2 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);
        courseOffering2.Faculty__c = contacts[1].Id;

        List<Course_Offering__c> courseOfferings = new List<Course_Offering__c>();
        courseOfferings.add(courseOffering1);
        courseOfferings.add(courseOffering2);

        update courseOfferings;

        Term_Grade__c termGrade1 = UTIL_UnitTestData_TEST.getTermGrade(contacts[0].Id, courseOfferings[0].Id, null);
        Term_Grade__c termGrade2 = UTIL_UnitTestData_TEST.getTermGrade(contacts[1].Id, courseOfferings[1].Id, null);

        insert new List<Term_Grade__c>{ termGrade1, termGrade2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and
     * Contact has a Test record associated to it, that it can be deleted.
     */
    @isTest
    private static void conCanDeleteWithTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = false
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Test__c testRecord1 = UTIL_UnitTestData_TEST.getTest('SAT', System.today(), contacts[0].Id);
        Test__c testRecord2 = UTIL_UnitTestData_TEST.getTest('SAT', System.today(), contacts[1].Id);

        insert new List<Test__c>{ testRecord1, testRecord2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        //Verify that all of Contact records were deleted
        System.assertEquals(0, returnContacts.size());
    }

    /**************************************************************************************************************************
     * @description Test if contacts can be merged when prevent deletion is enabled
     */
    @isTest
    static void conCanMerge() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Prevent_Contact_Deletion__c = true));

        Contact contactWithChildRecords = UTIL_UnitTestData_TEST.createTestContactWithMultipleRelations();
        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts[1]; //Use the second contact as master to avoid duplicate error

        Test.startTest();
        merge contacts[1] contactWithChildRecords;
        Test.stopTest();

        // Ensure loser contact is deleted
        List<Contact> mergeLoserContacts = [
            SELECT Id, MasterRecordId, IsDeleted
            FROM Contact
            WHERE Id = :contactWithChildRecords.Id
            ALL ROWS
        ];
        System.assertEquals(1, mergeLoserContacts.size(), 'There should be 1 merge loser contact');
        System.assertEquals(true, mergeLoserContacts[0].IsDeleted, 'The merge loser contact should be deleted');
        System.assertEquals(
            contacts[1].Id,
            mergeLoserContacts[0].MasterRecordId,
            'MasterRecordId should contain winner contact id'
        );

        Contact mergeWinnerContact = [
            SELECT
                ID,
                (SELECT ID FROM Addresses__r LIMIT 1),
                (SELECT ID FROM Applications_Applicant__r LIMIT 1),
                (SELECT ID FROM Applications_Preparer__r LIMIT 1),
                (SELECT ID FROM Attendance_Events__r LIMIT 1),
                (SELECT ID FROM Attributes__r LIMIT 1),
                (SELECT ID FROM Contact_Languages__r LIMIT 1),
                (SELECT ID FROM Education_History__r LIMIT 1),
                (SELECT ID FROM Program_Enrollments__r LIMIT 1),
                (SELECT ID FROM Term_Grades__r LIMIT 1),
                (SELECT ID FROM Tests__r LIMIT 1)
            FROM Contact
            WHERE ID = :contacts[1].Id
        ];
        System.assertEquals(1, mergeWinnerContact.Addresses__r.size(), 'There should be 1 merged address');
        System.assertEquals(
            1,
            mergeWinnerContact.Applications_Applicant__r.size(),
            'There should be 1 merged applicant'
        );
        System.assertEquals(1, mergeWinnerContact.Applications_Preparer__r.size(), 'There should be 1 merged preparer');
        System.assertEquals(1, mergeWinnerContact.Attendance_Events__r.size(), 'There should be 1 merged attendance');
        System.assertEquals(1, mergeWinnerContact.Attributes__r.size(), 'There should be 1 merged attribute');
        System.assertEquals(1, mergeWinnerContact.Contact_Languages__r.size(), 'There should be 1 merged language');
        System.assertEquals(
            1,
            mergeWinnerContact.Education_History__r.size(),
            'There should be 1 merged education history'
        );
        System.assertEquals(1, mergeWinnerContact.Program_Enrollments__r.size(), 'There should be 1 merged enrollment');
        System.assertEquals(1, mergeWinnerContact.Term_Grades__r.size(), 'There should be 1 merged term grades');
        System.assertEquals(1, mergeWinnerContact.Tests__r.size(), 'There should be 1 merged test');
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is enabled in Hierarchy Settings,and the
     * Contact record has different child records associated to it,then it cannot be deleted.
     */
    @isTest
    private static void cannotDelete() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = true
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = UTIL_UnitTestData_TEST.getTerm(acc.Id, 'Fall');
        insert term;

        Course__c course = UTIL_UnitTestData_TEST.getCourse('Biology', acc.Id);
        insert course;

        Affiliation__c affiliation1 = UTIL_UnitTestData_TEST.getAffiliation(contacts[0].Id, acc.Id, false);
        Affiliation__c affiliation2 = UTIL_UnitTestData_TEST.getAffiliation(contacts[1].Id, acc.Id, false);

        insert new List<Affiliation__c>{ affiliation1, affiliation2 };

        Application__c application1 = UTIL_UnitTestData_TEST.getApplication(acc.Id, contacts[0].Id, term.Id);
        Application__c application2 = UTIL_UnitTestData_TEST.getApplication(acc.Id, contacts[1].Id, term.Id);

        insert new List<Application__c>{ application1, application2 };

        Attendance_Event__c attendanceEvent1 = UTIL_UnitTestData_TEST.getAttendanceEvent();
        attendanceEvent1.Date__c = System.today();
        attendanceEvent1.Contact__c = contacts[0].Id;

        Attendance_Event__c attendanceEvent2 = UTIL_UnitTestData_TEST.getAttendanceEvent();
        attendanceEvent2.Date__c = System.today();
        attendanceEvent2.Contact__c = contacts[1].Id;

        insert new List<Attendance_Event__c>{ attendanceEvent1, attendanceEvent2 };

        Id credentialRecTypeId = UTIL_Describe_API.getCredentialAttributeRecType();

        Attribute__c attribute1 = UTIL_UnitTestData_TEST.getAttribute('TestCred1', contacts[0].Id, credentialRecTypeId);
        Attribute__c attribute2 = UTIL_UnitTestData_TEST.getAttribute('TestCred2', contacts[1].Id, credentialRecTypeId);

        insert new List<Attribute__c>{ attribute1, attribute2 };

        Language__c language = UTIL_UnitTestData_TEST.createLanguage('Spanish');

        Contact_Language__c contactLanguage1 = UTIL_UnitTestData_TEST.createContactLanguage(
            language.Id,
            contacts[0].Id,
            false
        );
        Contact_Language__c contactLanguage2 = UTIL_UnitTestData_TEST.createContactLanguage(
            language.Id,
            contacts[1].Id,
            false
        );

        Course_Offering__c courseOfferings1 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);
        courseOfferings1.Faculty__c = contacts[0].Id;

        Course_Offering__c courseOfferings2 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);
        courseOfferings2.Faculty__c = contacts[1].Id;

        update new List<Course_Offering__c>{ courseOfferings1, courseOfferings2 };

        Education_History__c eduHis1 = UTIL_UnitTestData_Test.getEduHistory(acc.Id, contacts[0].Id);
        Education_History__c eduHis2 = UTIL_UnitTestData_Test.getEduHistory(acc.Id, contacts[1].Id);
        insert new List<Education_History__c>{ eduHis1, eduHis2 };

        Term_Grade__c termGrade1 = UTIL_UnitTestData_TEST.getTermGrade(contacts[0].Id, courseOfferings1.Id, null);
        Term_Grade__c termGrade2 = UTIL_UnitTestData_TEST.getTermGrade(contacts[1].Id, courseOfferings2.Id, null);

        insert new List<Term_Grade__c>{ termGrade1, termGrade2 };

        Course_Enrollment__c studentCourseCxn1 = UTIL_UnitTestData_TEST.getCourseConnection(
            contacts[0].Id,
            courseOfferings1.Id
        );
        studentCourseCxn1.Status__c = 'Current';

        Course_Enrollment__c studentCourseCxn2 = UTIL_UnitTestData_TEST.getCourseConnection(
            contacts[1].Id,
            courseOfferings2.Id
        );
        studentCourseCxn2.Status__c = 'Current';

        insert new List<Course_Enrollment__c>{ studentCourseCxn1, studentCourseCxn2 };

        Program_Enrollment__c programEnrollment1 = UTIL_UnitTestData_TEST.getProgramEnrollment(acc.Id);
        programEnrollment1.Contact__c = contacts[0].Id;

        Program_Enrollment__c programEnrollment2 = UTIL_UnitTestData_TEST.getProgramEnrollment(acc.Id);
        programEnrollment2.Contact__c = contacts[1].Id;

        insert new List<Program_Enrollment__c>{ programEnrollment1, programEnrollment2 };

        Test__c testRecord1 = UTIL_UnitTestData_TEST.getTest('SAT', System.today(), contacts[0].Id);
        Test__c testRecord2 = UTIL_UnitTestData_TEST.getTest('SAT', System.today(), contacts[1].Id);

        insert new List<Test__c>{ testRecord1, testRecord2 };

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        //Verify that none of the Contact records were deleted
        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];
        System.assertEquals(2, contacts.size());
        System.assertEquals(false, results[0].success);
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
        System.assertEquals(false, results[1].success);
        System.assertEquals(Label.CannotDelete, results[1].errors[0].message);
    }

    /******************************************************************************************************************
     * @description Test method to test when Prevent_Contact_Deletion__c is enabled in Hierarchy Settings, and if
     * one of the Contact records has child records associated to it, then it should not be deleted. The Contact records
     * that do not have any child related records should be deleted.
     */
    @isTest
    private static void cannotDeleteSomeContacts() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = true
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = UTIL_UnitTestData_TEST.getTerm(acc.Id, 'Fall');
        insert term;

        Course__c course = UTIL_UnitTestData_TEST.getCourse('Biology', acc.Id);
        insert course;

        Affiliation__c affiliation = UTIL_UnitTestData_TEST.getAffiliation(contacts[1].Id, acc.Id, false);
        insert affiliation;

        Application__c applicant = UTIL_UnitTestData_TEST.getApplication(acc.Id, contacts[1].Id, term.Id);
        insert applicant;

        Attendance_Event__c attendance = UTIL_UnitTestData_TEST.getAttendanceEvent();
        attendance.Date__c = System.today();
        insert attendance;

        Id credentialRecTypeId = UTIL_Describe_API.getCredentialAttributeRecType();

        Attribute__c attribute1 = UTIL_UnitTestData_TEST.getAttribute('TestCred2', contacts[1].Id, credentialRecTypeId);

        Language__c language = UTIL_UnitTestData_TEST.createLanguage('Spanish');

        Contact_Language__c contactLanguage = UTIL_UnitTestData_TEST.createContactLanguage(
            language.Id,
            contacts[1].Id,
            false
        );

        Course_Offering__c courseOffering = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);
        courseOffering.Faculty__c = contacts[1].Id;
        update courseOffering;

        Education_History__c eduHis = UTIL_UnitTestData_Test.getEduHistory(acc.Id, contacts[1].Id);
        insert eduHis;

        Term_Grade__c termGrade = UTIL_UnitTestData_TEST.getTermGrade(contacts[1].Id, courseOffering.Id, null);
        insert termGrade;

        Course_Enrollment__c courseCxn = UTIL_UnitTestData_TEST.getCourseConnection(contacts[1].Id, courseOffering.Id);
        courseCxn.Status__c = 'Current';
        insert courseCxn;

        Program_Enrollment__c programEnrollment = UTIL_UnitTestData_TEST.getProgramEnrollment(acc.Id);
        programEnrollment.Contact__c = contacts[1].Id;

        Test__c testRecord = UTIL_UnitTestData_TEST.getTest('SAT', System.today(), contacts[1].Id);
        insert testRecord;

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        //Verify that 1 of the Contact records was deleted
        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];
        System.assertEquals(true, results[0].success);
        System.assertEquals(false, results[1].success);
        System.assertEquals(Label.CannotDelete, results[1].errors[0].message);
    }

    /**********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings,and the
     * Contact record has different child records associated to it, then it can be deleted.
     */
    @isTest
    private static void canDelete() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = false
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = UTIL_UnitTestData_TEST.getTerm(acc.Id, 'Fall');
        insert term;

        Course__c course = UTIL_UnitTestData_TEST.getCourse('Biology', acc.Id);
        insert course;

        Affiliation__c affiliation1 = UTIL_UnitTestData_TEST.getAffiliation(contacts[0].Id, acc.Id, false);
        Affiliation__c affiliation2 = UTIL_UnitTestData_TEST.getAffiliation(contacts[1].Id, acc.Id, false);

        insert new List<Affiliation__c>{ affiliation1, affiliation2 };

        Application__c application1 = UTIL_UnitTestData_TEST.getApplication(acc.Id, contacts[0].Id, term.Id);
        Application__c application2 = UTIL_UnitTestData_TEST.getApplication(acc.Id, contacts[1].Id, term.Id);

        insert new List<Application__c>{ application1, application2 };

        Attendance_Event__c attendanceEvent1 = UTIL_UnitTestData_TEST.getAttendanceEvent();
        attendanceEvent1.Date__c = System.today();
        attendanceEvent1.Contact__c = contacts[0].Id;

        Attendance_Event__c attendanceEvent2 = UTIL_UnitTestData_TEST.getAttendanceEvent();
        attendanceEvent2.Date__c = System.today();
        attendanceEvent2.Contact__c = contacts[1].Id;

        insert new List<Attendance_Event__c>{ attendanceEvent1, attendanceEvent2 };

        Id credentialRecTypeId = UTIL_Describe_API.getCredentialAttributeRecType();

        Attribute__c attribute1 = UTIL_UnitTestData_TEST.getAttribute('TestCred1', contacts[0].Id, credentialRecTypeId);
        Attribute__c attribute2 = UTIL_UnitTestData_TEST.getAttribute('TestCred2', contacts[1].Id, credentialRecTypeId);

        insert new List<Attribute__c>{ attribute1, attribute2 };

        Case case1 = UTIL_UnitTestData_TEST.getCase(null, 'School Code of Conduct', 'Current');
        case1.AccountId = acc.Id;
        Case case2 = UTIL_UnitTestData_TEST.getCase(null, 'School Code of Conduct', 'Current');
        case2.AccountId = acc.Id;

        insert new List<case>{ case1, case2 };
        Behavior_Involvement__c beh1 = UTIL_UnitTestData_TEST.getBehaviorInvolvementRecord(
            contacts[0].Id,
            case1.Id,
            'Reporter'
        );
        Behavior_Involvement__c beh2 = UTIL_UnitTestData_TEST.getBehaviorInvolvementRecord(
            contacts[1].Id,
            case2.Id,
            'Reporter'
        );

        insert new List<Behavior_Involvement__c>{ beh1, beh2 };

        Language__c language = UTIL_UnitTestData_TEST.createLanguage('Spanish');

        Contact_Language__c contactLanguage1 = UTIL_UnitTestData_TEST.createContactLanguage(
            language.Id,
            contacts[0].Id,
            false
        );
        Contact_Language__c contactLanguage2 = UTIL_UnitTestData_TEST.createContactLanguage(
            language.Id,
            contacts[1].Id,
            false
        );
        Course_Offering__c courseOfferings1 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);
        courseOfferings1.Faculty__c = contacts[0].Id;

        Course_Offering__c courseOfferings2 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);
        courseOfferings2.Faculty__c = contacts[1].Id;

        update new List<Course_Offering__c>{ courseOfferings1, courseOfferings2 };

        Education_History__c eduHis1 = UTIL_UnitTestData_Test.getEduHistory(acc.Id, contacts[0].Id);
        Education_History__c eduHis2 = UTIL_UnitTestData_Test.getEduHistory(acc.Id, contacts[1].Id);
        insert new List<Education_History__c>{ eduHis1, eduHis2 };

        Term_Grade__c termGrade1 = UTIL_UnitTestData_TEST.getTermGrade(contacts[0].Id, courseOfferings1.Id, null);
        Term_Grade__c termGrade2 = UTIL_UnitTestData_TEST.getTermGrade(contacts[1].Id, courseOfferings2.Id, null);

        insert new List<Term_Grade__c>{ termGrade1, termGrade2 };

        Id studentCourseCxnRecTypeId = UTIL_Describe_API.getStudentConnectionRecType();

        Course_Enrollment__c studentCourseCxn1 = UTIL_UnitTestData_TEST.getCourseConnection(
            contacts[0].Id,
            courseOfferings1.Id
        );
        studentCourseCxn1.Status__c = 'Current';

        Course_Enrollment__c studentCourseCxn2 = UTIL_UnitTestData_TEST.getCourseConnection(
            contacts[1].Id,
            courseOfferings2.Id
        );
        studentCourseCxn2.Status__c = 'Current';

        insert new List<Course_Enrollment__c>{ studentCourseCxn1, studentCourseCxn2 };

        Program_Enrollment__c programEnrollment1 = UTIL_UnitTestData_TEST.getProgramEnrollment(acc.Id);
        programEnrollment1.Contact__c = contacts[0].Id;

        Program_Enrollment__c programEnrollment2 = UTIL_UnitTestData_TEST.getProgramEnrollment(acc.Id);
        programEnrollment2.Contact__c = contacts[1].Id;

        insert new List<Program_Enrollment__c>{ programEnrollment1, programEnrollment2 };

        Test__c testRecord1 = UTIL_UnitTestData_TEST.getTest('SAT', System.today(), contacts[0].Id);
        Test__c testRecord2 = UTIL_UnitTestData_TEST.getTest('SAT', System.today(), contacts[1].Id);

        insert new List<Test__c>{ testRecord1, testRecord2 };
        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        //Verify that all Contact records were deleted
        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];

        System.assertEquals(0, returnContacts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Contact_Deletion__c is disabled in Hierarchy Settings, and if
     * one of the Contact record has child records associated to it, then it should be deleted. The Contact record
     * that do not have any child related records should be deleted.
     */
    @isTest
    private static void canDeleteAllContacts() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Prevent_Contact_Deletion__c = false
            )
        );

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Term__c term = UTIL_UnitTestData_TEST.getTerm(acc.Id, 'Fall');
        insert term;

        Course__c course = UTIL_UnitTestData_TEST.getCourse('Biology', acc.Id);
        insert course;

        Affiliation__c affiliation = UTIL_UnitTestData_TEST.getAffiliation(contacts[1].Id, acc.Id, false);
        insert affiliation;

        Application__c applicant = UTIL_UnitTestData_TEST.getApplication(acc.Id, contacts[1].Id, term.Id);
        insert applicant;

        Attendance_Event__c attendance = UTIL_UnitTestData_TEST.getAttendanceEvent();
        attendance.Date__c = System.today();
        attendance.Contact__c = contacts[0].Id;
        insert attendance;

        Id credentialRecTypeId = UTIL_Describe_API.getCredentialAttributeRecType();
        Attribute__c credentialAttribute = UTIL_UnitTestData_TEST.getAttribute(
            'TestCred2',
            contacts[1].Id,
            credentialRecTypeId
        );
        insert credentialAttribute;

        Language__c language = UTIL_UnitTestData_TEST.createLanguage('Spanish');

        Contact_Language__c contactLanguage = UTIL_UnitTestData_TEST.createContactLanguage(
            language.Id,
            contacts[1].Id,
            false
        );

        Course_Offering__c courseOffering = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);
        courseOffering.Faculty__c = contacts[1].Id;
        update courseOffering;

        Education_History__c eduHis = UTIL_UnitTestData_Test.getEduHistory(acc.Id, contacts[1].Id);
        insert eduHis;

        Term_Grade__c termGrade = UTIL_UnitTestData_TEST.getTermGrade(contacts[1].Id, courseOffering.Id, null);
        insert termGrade;

        Course_Enrollment__c courseCxn = UTIL_UnitTestData_TEST.getCourseConnection(contacts[1].Id, courseOffering.Id);
        courseCxn.Status__c = 'Current';
        insert courseCxn;

        Program_Enrollment__c programEnrollment = UTIL_UnitTestData_TEST.getProgramEnrollment(acc.Id);
        programEnrollment.Contact__c = contacts[1].Id;
        insert programEnrollment;

        Test__c testRecord = UTIL_UnitTestData_TEST.getTest('SAT', System.today(), contacts[1].Id);
        insert testRecord;

        Test.startTest();
        List<Database.DeleteResult> results = Database.delete(contacts, false);
        Test.stopTest();

        //Verify that all of the Contact records was deleted
        List<Contact> returnContacts = [SELECT Id FROM Contact WHERE Id IN :contacts];
        System.assertEquals(0, returnContacts.size());
        System.assertEquals(true, results[0].success);
        System.assertEquals(true, results[1].success);
    }

    /**************************************************************************************************************************
     ****************************************************** UNIT TESTS *********************************************************
     **************************************************************************************************************************/

    /*************************************************************************************************************
     * @description NULL test for run method to verify new DmlWrapper(); is returned when oldList is null
     */
    @isTest
    private static void runMethodNULLTest() {
        TDTM_Runnable.Action testAction = TDTM_Runnable.Action.BeforeDelete;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Contact;

        CON_CannotDelete_TDTM ConCannotDeleteTDTM = new CON_CannotDelete_TDTM();
        TDTM_Runnable.DmlWrapper dmlWrapperReturned = ConCannotDeleteTDTM.run(null, null, testAction, objResult);

        System.assertEquals(0, dmlWrapperReturned.objectsToDelete.size());
    }

    /****************************************************************************************************************
     * @description Positive test for run method to verify contactPreventedFromDeletionList has the records prevented
     * from Deletion when Prevent Contact Deletion Custom Settings is enabled
     */
    @isTest
    private static void runMethodPositiveTest() {
        SRVC_Contact_PreventDeletion.instance = new STUB_deletionPreventionContactList();

        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Prevent_Contact_Deletion__c = true));

        TDTM_Runnable.Action testBeforeAction = TDTM_Runnable.Action.BeforeDelete;
        TDTM_Runnable.Action testAfterAction = TDTM_Runnable.Action.AfterDelete;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Contact;

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(1);
        insert contacts;

        Term__c term = new Term__c(Name = 'Fall', Account__c = acc.Id);
        insert term;

        Course__c course = new Course__c(Name = 'Biology', Account__c = acc.Id);
        insert course;

        Affiliation__c affiliation = new Affiliation__c(Account__c = acc.Id, Contact__c = contacts[0].Id);
        insert affiliation;

        Education_History__c eduHis = UTIL_UnitTestData_Test.getEduHistory(acc.Id, contacts[0].Id);
        insert eduHis;

        List<SObject> oldList = new List<SObject>((List<SObject>) contacts);

        Map<Id, Contact> contactById = new Map<Id, Contact>(contacts);

        CON_CannotDelete_TDTM ConCannotDeleteTDTM = new CON_CannotDelete_TDTM();

        Test.startTest();
        ConCannotDeleteTDTM.run(null, oldList, testBeforeAction, objResult);
        List<Contact> contactsWithChildRelations = CON_CannotDelete_TDTM.contactsWithChildRelations;
        ConCannotDeleteTDTM.run(null, oldList, testAfterAction, objResult);
        Test.stopTest();

        // verify before handler retrieved contact with relations
        System.assertEquals(oldList.size(), contactsWithChildRelations.size());
        List<Contact> deletionPreventedContactList = SRVC_Contact_PreventDeletion.getInstance()
            .preventDeletionForContacts(contactById, contactsWithChildRelations);

        // verify deletionPreventedContactList is not empty
        System.assertEquals(1, deletionPreventedContactList.size());
        // verify after handler cleared contactsWithChildRelations static var
        System.assertEquals(null, CON_CannotDelete_TDTM.contactsWithChildRelations);
    }

    /************************************************************************************************************************
     * @description Negative test for run method to verify contactPreventedFromDeletionList has no records that are prevented
     * from Deletion when Prevent Contact Deletion Custom Settings is disabled
     */
    @isTest
    private static void runMethodNegativeTestWithCustomSettingsDisabled() {
        SRVC_Contact_PreventDeletion.instance = new STUB_DeletionPreventionContactList();

        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Prevent_Contact_Deletion__c = false));

        TDTM_Runnable.Action testBeforeAction = TDTM_Runnable.Action.BeforeDelete;
        TDTM_Runnable.Action testAfterAction = TDTM_Runnable.Action.AfterDelete;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Contact;

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(1);
        insert contacts;

        Term__c term = new Term__c(Name = 'Fall', Account__c = acc.Id);
        insert term;

        Course__c course = new Course__c(Name = 'Biology', Account__c = acc.Id);
        insert course;

        Affiliation__c affiliation = new Affiliation__c(Account__c = acc.Id, Contact__c = contacts[0].Id);
        insert affiliation;

        Education_History__c eduHis = UTIL_UnitTestData_Test.getEduHistory(acc.Id, contacts[0].Id);
        insert eduHis;

        List<SObject> oldList = new List<SObject>((List<SObject>) contacts);

        Map<Id, Contact> contactById = new Map<Id, Contact>();

        CON_CannotDelete_TDTM ConCannotDeleteTDTM = new CON_CannotDelete_TDTM();

        Test.startTest();
        ConCannotDeleteTDTM.run(null, oldList, testBeforeAction, objResult);
        List<Contact> contactsWithChildRelations = CON_CannotDelete_TDTM.contactsWithChildRelations;
        ConCannotDeleteTDTM.run(null, oldList, testAfterAction, objResult);
        Test.stopTest();

        // verify before handler didn't retrieve any contacts with relations
        System.assertEquals(null, contactsWithChildRelations);

        List<Contact> deletionPreventedContactList = SRVC_Contact_PreventDeletion.getInstance()
            .preventDeletionForContacts(contactById, new List<Contact>());

        // Verify deletionPreventedContactList is empty
        System.assertEquals(0, deletionPreventedContactList.size());
        // verify after handler cleared contactsWithChildRelations static var
        System.assertEquals(null, CON_CannotDelete_TDTM.contactsWithChildRelations);
    }

    /*************************************************************************************************************************
     * @description Negative test for run method to verify contactPreventedFromDeletionList has no records that are prevented
     * from Deletion when Prevent Contact Deletion Custom Settings is enabled.
     */
    @isTest
    static void runMethodNegativeTestWithNoChildren() {
        SRVC_Contact_PreventDeletion.instance = new STUB_deletionPreventionContactList();

        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Prevent_Contact_Deletion__c = true));

        TDTM_Runnable.Action testBeforeAction = TDTM_Runnable.Action.BeforeDelete;
        TDTM_Runnable.Action testAfterAction = TDTM_Runnable.Action.AfterDelete;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Contact;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(1);
        insert contacts;

        List<SObject> oldList = new List<SObject>((List<SObject>) contacts);

        Map<Id, Contact> contactById = new Map<Id, Contact>((List<Contact>) oldList);

        CON_CannotDelete_TDTM ConCannotDeleteTDTM = new CON_CannotDelete_TDTM();

        Test.startTest();
        ConCannotDeleteTDTM.run(null, oldList, testBeforeAction, objResult);
        List<Contact> contactsWithChildRelations = CON_CannotDelete_TDTM.contactsWithChildRelations;
        ConCannotDeleteTDTM.run(null, oldList, testAfterAction, objResult);
        Test.stopTest();

        List<Contact> deletionPreventedContactList = SRVC_Contact_PreventDeletion.getInstance()
            .preventDeletionForContacts(contactById, contactsWithChildRelations);

        // Verify deletionPreventedContactList is empty
        System.assertEquals(0, deletionPreventedContactList.size());
    }

    /********************************************************************************************************************************
     * @description Tests handleBeforeDelete method of CON_CannotDelete_TDTM when Prevent Contact Deletion Custom Settings is enabled
     * and Contact having child records
     */
    @isTest
    private static void handleBeforeDeleteMethodWithCustomSettingsEnabledPositiveTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Prevent_Contact_Deletion__c = true));
        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(1);
        insert contacts;

        Term__c term = new Term__c(Name = 'Fall', Account__c = acc.Id);
        insert term;

        Course__c course = new Course__c(Name = 'Biology', Account__c = acc.Id);
        insert course;

        Affiliation__c affiliation = new Affiliation__c(Account__c = acc.Id, Contact__c = contacts[0].Id);
        insert affiliation;

        Education_History__c eduHis = UTIL_UnitTestData_Test.getEduHistory(acc.Id, contacts[0].Id);
        insert eduHis;

        CON_CannotDelete_TDTM conCanNotDeleteTDTM = new CON_CannotDelete_TDTM();
        Test.startTest();
        List<Contact> contactsWithChildRelations = conCanNotDeleteTDTM.handleBeforeDelete(contacts);
        Test.stopTest();

        // Verify contactsWithChildRelations is not empty
        System.assertEquals(1, contactsWithChildRelations.size());
    }

    /*******************************************************************************************************************************************
     * @description positive test for handleBeforeDelete method of CON_CannotDelete_TDTM when Prevent Contact Deletion Custom Settings is enabled
     * with no CHild records for Contact
     */
    @isTest
    private static void handleBeforeDeleteMethodWithCustomSettingsEnabledNoRelationsPositiveTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Prevent_Contact_Deletion__c = true));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(1);
        insert contacts;

        CON_CannotDelete_TDTM conCanNotDeleteTDTM = new CON_CannotDelete_TDTM();
        Test.startTest();
        List<Contact> contactsWithChildRelations = conCanNotDeleteTDTM.handleBeforeDelete((List<SObject>) contacts);
        Test.stopTest();

        // Verify contactsWithChildRelations is empty
        System.assertEquals(1, contactsWithChildRelations.size());
    }

    /************************************************************************************************************************
     * @description Tests handleBeforeDelete method of CON_CannotDelete_TDTM with Prevent Deletion Custom Settings disabled
     */
    @isTest
    private static void handleBeforeDeleteMethodWIthCustomSettingsDisabledTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Prevent_Contact_Deletion__c = false));

        List<SObject> testContactlist = UTIL_UnitTestData_TEST.getMultipleTestContacts(10);

        CON_CannotDelete_TDTM conCanNotDeleteTDTM = new CON_CannotDelete_TDTM();
        Test.startTest();
        List<Contact> contactsWithChildRelations = conCanNotDeleteTDTM.handleBeforeDelete(testContactlist);
        Test.stopTest();

        // Verify contactsWithChildRelations is null
        System.assertEquals(null, contactsWithChildRelations);
    }

    /*************************************************************************************************************
     * @description Tests locateContactPreventDeletionService method of CON_CannotDelete_TDTM
     */
    @isTest
    private static void locateContactPreventDeletionServiceTest() {
        CON_CannotDelete_TDTM conCanNotDeleteTDTM = new CON_CannotDelete_TDTM();
        Test.startTest();
        SRVC_Contact_PreventDeletion conPreventDeleteInstance = conCanNotDeleteTDTM.locateContactPreventDeletionService();
        Test.stopTest();

        SRVC_Contact_PreventDeletion srvcInstance = SRVC_Contact_PreventDeletion.getInstance();

        System.assertEquals(srvcInstance, conPreventDeleteInstance);
    }

    /*************************************************************************************************************
     * @description Positive tests for isContactDeletionPreventionEnabled method of CON_CannotDelete_TDTM
     */
    @isTest
    private static void isContactDeletionPreventionEnabledPositiveTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Prevent_Contact_Deletion__c = true));
        Test.startTest();
        CON_CannotDelete_TDTM conPreventDeleteInstance = new CON_CannotDelete_TDTM();
        Test.stopTest();

        Boolean isContactDeletionPreventionEnabled = conPreventDeleteInstance.isContactDeletionPreventionEnabled();

        // Verify isContactDeletionPreventionEnabled is true
        System.assertEquals(true, isContactDeletionPreventionEnabled);
    }

    /*************************************************************************************************************
     * @description Negative tests for isContactDeletionPreventionEnabled method of CON_CannotDelete_TDTM
     */
    @isTest
    private static void isContactDeletionPreventionEnabledNegativeTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Prevent_Contact_Deletion__c = false));
        Test.startTest();
        CON_CannotDelete_TDTM conPreventDeleteInstance = new CON_CannotDelete_TDTM();
        Test.stopTest();

        Boolean isContactDeletionPreventionEnabled = conPreventDeleteInstance.isContactDeletionPreventionEnabled();

        System.assertEquals(false, isContactDeletionPreventionEnabled);
    }

    /**************************************************************************************************************************
     ****************************************************** STUB CLASS *********************************************************
     **************************************************************************************************************************/

    /*************************************************************************************************************
     * STUB class which extends SRVC_Contact_PreventDeletion
     */
    private class STUB_DeletionPreventionContactList extends SRVC_Contact_PreventDeletion {
        @TestVisible
        List<Contact> deletionPreventedContactList = new List<Contact>();

        public override List<Contact> preventDeletionForContacts(
            Map<Id, Contact> contactById,
            List<Contact> contactWithChildRecordsList
        ) {
            deletionPreventedContactList = super.preventDeletionForContacts(contactById, contactWithChildRecordsList);
            return deletionPreventedContactList;
        }
    }
}
