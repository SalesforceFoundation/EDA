/*
    Copyright (c) 2020, Salesforce.org
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
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
* @group 
* @group-content ../../ApexDocContent/Contacts.htm
* @description Test class for SRVC_Contact_PreventDeletion
*/
@isTest
private class SRVC_Contact_PreventDeletion_TEST {

    /**************************************************************************************************************************
    * @description Helper method to create Contact with child records
    */
    private static Contact createContactWithChildRecordsHelper() {

        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                          Prevent_Contact_Deletion__c = true));

        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(1);
        insert contacts;

        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);
        addrs[0].Parent_Account__c = contacts[0].AccountId;
        addrs[0].MailingCity__c = 'Boston';
        addrs[0].Parent_Contact__c = contacts[0].id;
        insert addrs[0];

        Term__c term = UTIL_UnitTestData_TEST.getTerm(acc.Id, 'Fall');
        insert term;

        Course__c course = UTIL_UnitTestData_TEST.getCourse('Biology', acc.Id);
        insert course;

        Affiliation__c affiliation = UTIL_UnitTestData_TEST.getAffiliation(contacts[0].Id, acc.Id, false);
        insert affiliation;

        Application__c applicant = UTIL_UnitTestData_TEST.getApplication(acc.Id, contacts[0].Id, term.Id);
        insert applicant;

        Application__c applicantPreparer = UTIL_UnitTestData_TEST.getApplication(acc.Id, null, term.Id);
        applicantPreparer.Preparer__c = contacts[0].Id;
        insert applicantPreparer;

        Attendance_Event__c attendance = UTIL_UnitTestData_TEST.getAttendanceEvent(contacts[0].Id, null, null, null);
        insert attendance;

        Id credentialRecTypeId = UTIL_Describe_API.getCredentialAttributeRecType();
        Attribute__c credentialAttribute = UTIL_UnitTestData_TEST.getAttribute('TestCred2', contacts[0].Id,  credentialRecTypeId);
        insert credentialAttribute;

        Case caseRecord = UTIL_UnitTestData_TEST.getCase(contacts[0].Id, 'School Violation', 'New');
        insert caseRecord;

        Language__c language = UTIL_UnitTestData_TEST.createLanguage('Spanish');

        Contact_Language__c contactLanguage = UTIL_UnitTestData_TEST.createContactLanguage(language.Id, contacts[0].Id, false);

        Course_Offering__c courseOffering = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);
        courseOffering.Faculty__c = contacts[0].Id;
        update courseOffering;

        Course_Enrollment__c courseCxn = UTIL_UnitTestData_TEST.getCourseConnection(contacts[0].Id, courseOffering.Id);
        insert courseCxn;

        Education_History__c eduHis = UTIL_UnitTestData_Test.getEduHistory(acc.Id, contacts[0].Id);
        insert eduHis;

        Term_Grade__c termGrade = UTIL_UnitTestData_TEST.getTermGrade(contacts[0].Id,  courseOffering.Id, courseCxn.Id);
        insert termGrade;

        Program_Enrollment__c programEnrollment = UTIL_UnitTestData_TEST.getProgramEnrollment(acc.Id);
        programEnrollment.Contact__c = contacts[0].Id;
        insert programEnrollment;

        Test__c testRecord = UTIL_UnitTestData_TEST.getTest('SAT', System.today(), contacts[0].Id);
        insert testRecord;

        Behavior_Involvement__c behInvolvement = UTIL_UnitTestData_TEST.getBehaviorInvolvementRecord(contacts[0].Id, caseRecord.Id, 'Reporter');
        insert behInvolvement;
        
        return contacts[0];

    }

    /**************************************************************************************************************************
    * @description Tests getInstance() of SRVC_Contact_PreventDeletion
    */
    @isTest
    static void testGetInstance() {

        SRVC_Contact_PreventDeletion srvcConPreventDeleteInstance = SRVC_Contact_PreventDeletion.getInstance();
        System.assertEquals(SRVC_Contact_PreventDeletion.instance, srvcConPreventDeleteInstance);
        System.assertNotEquals(NULL, srvcConPreventDeleteInstance);

        srvcConPreventDeleteInstance = SRVC_Contact_PreventDeletion.getInstance();
        System.assertEquals(SRVC_Contact_PreventDeletion.instance, srvcConPreventDeleteInstance);
    }

    /**************************************************************************************************************************
    * @description Tests Prevent Deletion for Contacts with STUB_ContactsWithChildRelationships
    */
    @isTest
    static void testPreventDeletionForContactsWithChildrenUsingSTUB() {

        SRVC_Contact_PreventDeletion.instance = new STUB_ContactsWithChildRelationships();
     
        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(1);
        contacts[0].Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

        Map<Id, Contact> contactById = new Map<Id, Contact>((List<Contact>)contacts);

        Test.startTest();
            List<Contact> contactsWithErrorsList = SRVC_Contact_PreventDeletion.getInstance().PreventDeletionForContacts(
                contactById
            );
        Test.stopTest();

        System.assertEquals(contactById.values().size(), contactsWithErrorsList.size());

        for (Contact contactToCheck : contactsWithErrorsList) {
            System.assert(contactById.get(contactToCheck.Id) != null);
        }
    }

    /**************************************************************************************************************************
    * @description Tests Prevent Deletion for Contacts with STUB_ContactsWithNoChildRelationships
    */
    @isTest
    static void testPreventDeletionForContactsWithNoChildrenUsingSTUB() {

        SRVC_Contact_PreventDeletion.instance = new STUB_ContactsWithNoChildRelationships();

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(1);
        contacts[0].Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

        Map<Id, Contact> contactById = new Map<Id, Contact>((List<Contact>)contacts);

        Test.startTest();
            List<Contact> contactsWithErrorsList = SRVC_Contact_PreventDeletion.getInstance().PreventDeletionForContacts(
                contactById
            );
        Test.stopTest();
        
        // Ensure contactsWithErrorsList is empty
        System.assertEquals(0, contactsWithErrorsList.size());

    }

    /**************************************************************************************************************************
    * @description Positive tests for preventDeletionForContacts method using Contact with Child records
    */
    @isTest
    static void positiveTestForPreventDeletionForContacts() {

        Contact contactWithChildRecords = SRVC_Contact_PreventDeletion_TEST.createContactWithChildRecordsHelper();
        Map<Id, Contact> contactById  = new map<Id, Contact>();
        contactById.put(contactWithChildRecords.Id, contactWithChildRecords);

        Test.startTest();
            List<contact> contactErroredList = SRVC_Contact_PreventDeletion.getInstance().preventDeletionForContacts(contactById);
        Test.stopTest();
        
        // Ensure contactsWithErrorsList is not empty
        System.assertEquals(1, contactErroredList.size());
    }

    /**************************************************************************************************************************
    * @description Negative tests for preventDeletionForContacts method with No Child records
    */
    @isTest
    static void negativeTestForPreventDeletionForContacts() {

        List<Contact> contactWithNoChildRecord = UTIL_UnitTestData_TEST.getMultipleTestContacts(1);
        contactWithNoChildRecord[0].Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

        Map<Id, Contact> contactById  = new map<Id, Contact>(contactWithNoChildRecord);

        Test.startTest();
            List<contact> contactErroredList = SRVC_Contact_PreventDeletion.getInstance().preventDeletionForContacts(contactById);
        Test.stopTest();
        
        // Ensure contactsWithErrorsList is empty
        System.assertEquals(0, contactErroredList.size());
    }

    /**************************************************************************************************************************
    * @description Positive tests for ContactsAndChildRelationships method
    */
    @isTest
    static void positiveTestForGetContactsAndChildRelationships() {

        Contact contactWithChildRecords = SRVC_Contact_PreventDeletion_TEST.createContactWithChildRecordsHelper();

        Set<Id> contactIdSet = new Set<Id>();
        contactIdSet.add(contactWithChildRecords.Id);

        Test.startTest();
            List<Contact> contactsWithChildRecords = SRVC_Contact_PreventDeletion.getInstance().getContactsAndChildRelationships(contactIdSet);
        Test.stopTest();
        
        // Ensure child records are retrieved
        System.assertEquals(1, contactsWithChildRecords[0].Addresses__r.size());
        System.assertEquals(1, contactsWithChildRecords[0].Affl_Accounts__r.size());
        System.assertEquals(1, contactsWithChildRecords[0].Affl_Accounts__r.size());
        System.assertEquals(1, contactsWithChildRecords[0].Applications_Preparer__r.size());
        System.assertEquals(1, contactsWithChildRecords[0].Attendance_Events__r.size());
        System.assertEquals(1, contactsWithChildRecords[0].Attributes__r.size());
        System.assertEquals(1, contactsWithChildRecords[0].Behavior_Involvements__r.size());
        System.assertEquals(1, contactsWithChildRecords[0].Contact_Languages__r.size());
        System.assertEquals(1, contactsWithChildRecords[0].Courses_Taught__r.size());
        System.assertEquals(1, contactsWithChildRecords[0].Education_History__r.size());
        System.assertEquals(1, contactsWithChildRecords[0].Program_Enrollments__r.size());
        System.assertEquals(1, contactsWithChildRecords[0].Student_Course_Enrollments__r.size());
        System.assertEquals(1, contactsWithChildRecords[0].Term_Grades__r.size());
        System.assertEquals(1, contactsWithChildRecords[0].Tests__r.size());
    }

    /**************************************************************************************************************************
    * @description Negative tests for ContactsAndChildRelationships method
    */
    @isTest
    static void negativeTestForGetContactsAndChildRelationships() {

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(1);
        insert contacts;

        Map<Id, Contact> contactById  = new map<Id, Contact>(contacts);
        Set<Id> contactIdSet = contactById.keySet();

        Test.startTest();
            List<contact> contactsWithChildRecords = SRVC_Contact_PreventDeletion.getInstance().getContactsAndChildRelationships(contactIdSet);
        Test.stopTest();

        System.assertEquals(0, contactsWithChildRecords[0].Addresses__r.size());
        System.assertEquals(0, contactsWithChildRecords[0].Affl_Accounts__r.size());
        System.assertEquals(0, contactsWithChildRecords[0].Affl_Accounts__r.size());
        System.assertEquals(0, contactsWithChildRecords[0].Applications_Preparer__r.size());
        System.assertEquals(0, contactsWithChildRecords[0].Attendance_Events__r.size());
        System.assertEquals(0, contactsWithChildRecords[0].Attributes__r.size());
        System.assertEquals(0, contactsWithChildRecords[0].Behavior_Involvements__r.size());
        System.assertEquals(0, contactsWithChildRecords[0].Contact_Languages__r.size());
        System.assertEquals(0, contactsWithChildRecords[0].Courses_Taught__r.size());
        System.assertEquals(0, contactsWithChildRecords[0].Education_History__r.size());
        System.assertEquals(0, contactsWithChildRecords[0].Program_Enrollments__r.size());
        System.assertEquals(0, contactsWithChildRecords[0].Student_Course_Enrollments__r.size());
        System.assertEquals(0, contactsWithChildRecords[0].Term_Grades__r.size());
        System.assertEquals(0, contactsWithChildRecords[0].Tests__r.size());
    }

    /**************************************************************************************************************************
    * @description positive test for ContactHasChildRecords method
    */
    @isTest
    static void positiveTestForContactHasChildRecords() {

        Contact contactWithChildRecords = SRVC_Contact_PreventDeletion_TEST.createContactWithChildRecordsHelper();

        Contact con = [SELECT Id,
                       (SELECT ID FROM Addresses__r LIMIT 1),
                       (SELECT ID FROM Affl_Accounts__r LIMIT 1),
                       (SELECT ID FROM Applications_Applicant__r LIMIT 1),
                       (SELECT ID FROM Applications_Preparer__r LIMIT 1),
                       (SELECT ID FROM Attendance_Events__r LIMIT 1),
                       (SELECT ID FROM Attributes__r LIMIT 1),
                       (SELECT ID FROM Behavior_Involvements__r LIMIT 1),
                       (SELECT ID FROM Contact_Languages__r LIMIT 1),
                       (SELECT ID FROM Courses_Taught__r LIMIT 1),
                       (SELECT ID FROM Education_History__r LIMIT 1),
                       (SELECT ID FROM Program_Enrollments__r LIMIT 1),
                       (SELECT ID FROM Student_Course_Enrollments__r LIMIT 1),
                       (SELECT ID FROM Term_Grades__r LIMIT 1),
                       (SELECT ID FROM Tests__r LIMIT 1)
                      FROM CONTACT WHERE Id =: contactWithChildRecords.Id];

        Test.startTest();
            Boolean contactHasChildren = SRVC_Contact_PreventDeletion.getInstance().contactHasChildRecords(con);
        Test.stopTest();
        
        // Ensure contactHasChildren is true
        System.assertEquals(true, contactHasChildren);
    }

    /**************************************************************************************************************************
    * @description Negative test for ContactHasChildRecords method
    */
    @isTest
    static void negativeTestForContactHasChildRecords() {

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(1);

        Test.startTest();
            Boolean contactHasChildren = SRVC_Contact_PreventDeletion.getInstance().contactHasChildRecords(contacts[0]);
        Test.stopTest();
        
        // Ensure contactHasChildren is false
        System.assertEquals(false, contactHasChildren);
    }

    /**************************************************************************************************************************************
    * STUB class which extends SRVC_Contact_PreventDeletion, overrides getContactsAndChildRelationships and contactHasChildRecords method
    */
    private class STUB_ContactsWithChildRelationships extends SRVC_Contact_PreventDeletion {

        @TestVisible
        protected override List<Contact> getContactsAndChildRelationships(set<Id> contactIdSet) {
            List<Contact> contactsList = new List<Contact>();
            for (Id eachContactId: contactIdSet) {
                Contact con = new Contact(Id = eachContactId, LastName = eachContactId);
                contactsList.add(con);
            }
            return contactsList;
        }

        @TestVisible
        protected override Boolean contactHasChildRecords(Contact con) {
            return true;
        }
    }

    /***************************************************************************************************************************************
    * STUB class which extends SRVC_Contact_PreventDeletion, overrides getContactsAndChildRelationships and contactHasChildRecords method
    */
    private class STUB_ContactsWithNoChildRelationships extends SRVC_Contact_PreventDeletion {

        @TestVisible
        protected override List<Contact> getContactsAndChildRelationships(set<Id> contactIdSet) {
            List<Contact> contactsList = new List<Contact>();
            for (Id eachContactId: contactIdSet) {
                Contact con = new Contact(Id = eachContactId, LastName = eachContactId);
                contactsList.add(con);
            }
            return contactsList;
        }

        @TestVisible
        protected override Boolean contactHasChildRecords(Contact con) {
            return false;
        }
    }
}