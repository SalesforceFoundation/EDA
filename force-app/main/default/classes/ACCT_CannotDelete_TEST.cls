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
 * @group Accounts
 * @group-content ../../ApexDocContent/Accounts.htm
 * @description Tests for ACCT_CannotDelete_TDTM.
 */
@isTest
public with sharing class ACCT_CannotDelete_TEST {
    /*********************************************************************************************************
     * @description Retrieves the Business Account record type Id.
     */
    public static String bizAccRecordTypeId = UTIL_Describe_API.getBizAccRecTypeID();

    /**************************************************************************************************************************
     ****************************************************** FUNCTIONAL TESTS ***************************************************
     **************************************************************************************************************************/

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is enabled in Hierarchy Settings, and
     * Account has an Address record associated to it, that it cannot be deleted.
     */
    @isTest
    public static void accCannotDeleteWithAddress() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = true)
        );

        UTIL_UnitTestData_TEST.AccsWithAddrs accWithAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(
            2,
            bizAccRecordTypeId
        );

        List<Account> returnNewAccounts = accWithAddrs.accs;
        List<Address__c> returnNewAddresses = accWithAddrs.addrs;
        System.assertEquals(2, returnNewAddresses.size());
        System.assertNotEquals(null, returnNewAddresses[0].Parent_Account__c);

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(returnNewAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :returnNewAccounts];

        System.assertEquals(2, returnAccounts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is enabled in Hierarchy Settings, and
     * Account has an Affiliation record associated to it, that it cannot be deleted.
     */
    @isTest
    public static void accCannotDeleteWithAffiliation() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = true)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Contact> newContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        newContacts[0].LastName = 'Willy';
        newContacts[0].AccountId = newAccounts[0].Id;
        newContacts[1].LastName = 'Jones';
        newContacts[1].AccountId = newAccounts[1].Id;
        insert newContacts;

        Map<String, Contact> lastNameByContact = new Map<String, Contact>();

        for (Contact c : newContacts) {
            lastNameByContact.put(c.LastName, c);
        }

        List<Affiliation__c> affiliations = new List<Affiliation__c>{
            new Affiliation__c(
                Contact__c = lastNameByContact.get('Willy').Id,
                Account__c = lastNameByContact.get('Willy').AccountId,
                Role__c = 'Student'
            ),
            new Affiliation__c(
                Contact__c = lastNameByContact.get('Jones').Id,
                Account__c = lastNameByContact.get('Jones').AccountId,
                Role__c = 'Student'
            )
        };
        insert affiliations;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(2, returnAccounts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is enabled in Hierarchy Settings, and
     * Account has an Attribute record associated to it, that it cannot be deleted.
     */
    @isTest
    private static void accCannotDeleteWithAttribute() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = true)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Attribute__c> attributes = new List<Attribute__c>{
            new Attribute__c(Name = 'Attribute1', Agency__c = newAccounts[0].Id),
            new Attribute__c(Name = 'Attribute2', Agency__c = newAccounts[1].Id)
        };
        insert attributes;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(2, returnAccounts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is enabled in Hierarchy Settings, and
     * Account has a Course record associated to it, that it cannot be deleted.
     */
    @isTest
    public static void accCannotDeleteWithCourse() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = true)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Course__c> courses = new List<Course__c>{
            new Course__c(Name = 'Course1', Account__c = newAccounts[0].Id),
            new Course__c(Name = 'Course2', Account__c = newAccounts[1].Id)
        };
        insert courses;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(2, returnAccounts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is enabled in Hierarchy Settings, and
     * if a Contact's Primary_Household__c field is populated with the Account, then the Account cannot be deleted.
     */
    @isTest
    public static void accCannotDeleteWithContactHousehold() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = true)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Contact> newContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        newContacts[0].LastName = 'Willy';
        newContacts[0].Primary_Household__c = newAccounts[0].Id;
        newContacts[1].LastName = 'Jones';
        newContacts[1].Primary_Household__c = newAccounts[1].Id;
        insert newContacts;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(2, returnAccounts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is enabled in Hierarchy Settings, and
     * if a Contact's Primary_Organization__c field is populated with the Account, then the Account cannot be deleted.
     */
    @isTest
    public static void accCannotDeleteWithContactBusinessOrg() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = true)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Contact> newContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        newContacts[0].LastName = 'Willy';
        newContacts[0].Primary_Organization__c = newAccounts[0].Id;
        newContacts[1].LastName = 'Jones';
        newContacts[1].Primary_Organization__c = newAccounts[1].Id;
        insert newContacts;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(2, returnAccounts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is enabled in Hierarchy Settings, and
     * Account has a Course Connection record associated to it, that it cannot be deleted.
     */
    @isTest
    public static void accCannotDeleteWithCourseConnection() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = true)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Contact> newContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        newContacts[0].LastName = 'Willy';
        newContacts[0].AccountId = newAccounts[0].Id;
        newContacts[1].LastName = 'Jones';
        newContacts[1].AccountId = newAccounts[1].Id;
        insert newContacts;

        List<Course__c> courses = new List<Course__c>{
            new Course__c(Name = 'Course1', Account__c = newAccounts[0].Id),
            new Course__c(Name = 'Course2', Account__c = newAccounts[1].Id)
        };
        insert courses;

        List<Term__c> terms = new List<Term__c>{
            new Term__c(Name = 'Fall', Account__c = newAccounts[0].Id),
            new Term__c(Name = 'Spring', Account__c = newAccounts[1].Id)
        };
        insert terms;

        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(courses[0].Id, terms[0].Id);
        Course_Offering__c courseOffering2 = UTIL_UnitTestData_TEST.createCourseOffering(courses[1].Id, terms[1].Id);

        List<Course_Enrollment__c> courseEnrollments = new List<Course_Enrollment__c>();
        Course_Enrollment__c courseConnection1 = UTIL_UnitTestData_TEST.getCourseConnection(
            newContacts[0].Id,
            courseOffering1.Id
        );
        Course_Enrollment__c courseConnection2 = UTIL_UnitTestData_TEST.getCourseConnection(
            newContacts[1].Id,
            courseOffering2.Id
        );
        courseConnection1.Account__c = newAccounts[0].Id;
        courseConnection2.Account__c = newAccounts[1].Id;
        courseEnrollments.add(courseConnection1);
        courseEnrollments.add(courseConnection2);
        insert courseEnrollments;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(2, returnAccounts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /************************************************************************************************************
     * @description Bulk test method to test if Prevent_Account_Deletion__c is enabled in Hierarchy Settings, and
     * Account has a Education History record associated to it, that it cannot be deleted.
     */
    @isTest
    public static void accCannotDeleteWithEducationHistoryBULK() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = true)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            2,
            UTIL_Describe.getAcademicAccRecTypeID()
        );
        insert newAccounts;

        Education_History__c educationHistory1 = UTIL_UnitTestData_TEST.getEduHistory(newAccounts[0].Id, null);
        Education_History__c educationHistory2 = UTIL_UnitTestData_TEST.getEduHistory(newAccounts[0].Id, null);
        Education_History__c educationHistory3 = UTIL_UnitTestData_TEST.getEduHistory(newAccounts[1].Id, null);
        Education_History__c educationHistory4 = UTIL_UnitTestData_TEST.getEduHistory(newAccounts[1].Id, null);

        insert new List<Education_History__c>{
            educationHistory1,
            educationHistory2,
            educationHistory3,
            educationHistory4
        };

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(2, returnAccounts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
        System.assertEquals(Label.CannotDelete, results[1].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is enabled in Hierarchy Settings, and
     * Account has a Facility record associated to it, that it cannot be deleted.
     */
    @isTest
    public static void accCannotDeleteWithFacility() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = true)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Facility__c> facilities = new List<Facility__c>{
            new Facility__c(Name = 'MeetingRoom1', Account__c = newAccounts[0].Id),
            new Facility__c(Name = 'MeetingRoom2', Account__c = newAccounts[1].Id)
        };
        insert facilities;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(2, returnAccounts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is enabled in Hierarchy Settings, and
     * Account has a Program Enrollment record associated to it, that it cannot be deleted.
     */
    @isTest
    public static void accCannotDeleteWithProgramEnrollment() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = true)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Contact> newContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        newContacts[0].LastName = 'Willy';
        newContacts[0].AccountId = newAccounts[0].Id;
        newContacts[1].LastName = 'Jones';
        newContacts[1].AccountId = newAccounts[1].Id;
        insert newContacts;

        Program_Enrollment__c programEnrollment1 = UTIL_UnitTestData_TEST.getProgramEnrollment(newAccounts[0].Id);
        Program_Enrollment__c programEnrollment2 = UTIL_UnitTestData_TEST.getProgramEnrollment(newAccounts[1].Id);
        insert new List<SObject>{ programEnrollment1, programEnrollment2 };

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(2, returnAccounts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is enabled in Hierarchy Settings, and
     * Account has a Program Plan record associated to it, that it cannot be deleted.
     */
    @isTest
    public static void accCannotDeleteWithProgramPlan() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = true)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Program_Plan__c> programPlans = new List<Program_Plan__c>{
            new Program_Plan__c(Name = 'Plan1', Account__c = newAccounts[0].Id),
            new Program_Plan__c(Name = 'Plan2', Account__c = newAccounts[1].Id)
        };
        insert programPlans;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(2, returnAccounts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is enabled in Hierarchy Settings, and
     * Account has a Term record associated to it, that it cannot be deleted.
     */
    @isTest
    public static void accCannotDeleteWithTerm() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = true)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Term__c> terms = new List<Term__c>{
            new Term__c(Name = 'Fall', Account__c = newAccounts[0].Id),
            new Term__c(Name = 'Spring', Account__c = newAccounts[1].Id)
        };
        insert terms;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(2, returnAccounts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is enabled in Hierarchy Settings, and
     * Account has a Time Block record associated to it, that it cannot be deleted.
     */
    @isTest
    public static void accCannotDeleteWithTimeBlock() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = true)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Time_Block__c> timeBlocks = new List<Time_Block__c>{
            new Time_Block__c(Name = '1stTimeBlock', Educational_Institution__c = newAccounts[0].Id),
            new Time_Block__c(Name = '2ndTimeBlock', Educational_Institution__c = newAccounts[1].Id)
        };
        insert timeBlocks;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(2, returnAccounts.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is disabled in Hierarchy Settings, and
     * Account has an Address record associated to it, that it can be deleted.
     */
    @isTest
    private static void accCanDeleteWithAddress() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = false)
        );

        UTIL_UnitTestData_TEST.AccsWithAddrs accWithAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(
            2,
            bizAccRecordTypeId
        );

        List<Account> returnNewAccounts = accWithAddrs.accs;
        List<Address__c> returnNewAddresses = accWithAddrs.addrs;
        System.assertEquals(2, returnNewAddresses.size());
        System.assertNotEquals(null, returnNewAddresses[0].Parent_Account__c);

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(returnNewAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :returnNewAccounts];

        System.assertEquals(0, returnAccounts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is disabled in Hierarchy Settings, and
     * Account has an Affiliation record associated to it, that it can be deleted.
     */
    @isTest
    private static void accCanDeleteWithAffiliation() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = false)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Contact> newContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        newContacts[0].LastName = 'Willy';
        newContacts[0].AccountId = newAccounts[0].Id;
        newContacts[1].LastName = 'Jones';
        newContacts[1].AccountId = newAccounts[1].Id;
        insert newContacts;

        Map<String, Contact> lastNameByContact = new Map<String, Contact>();

        for (Contact c : newContacts) {
            lastNameByContact.put(c.LastName, c);
        }

        List<Affiliation__c> affiliations = new List<Affiliation__c>{
            new Affiliation__c(
                Contact__c = lastNameByContact.get('Willy').Id,
                Account__c = lastNameByContact.get('Willy').AccountId,
                Role__c = 'Student'
            ),
            new Affiliation__c(
                Contact__c = lastNameByContact.get('Jones').Id,
                Account__c = lastNameByContact.get('Jones').AccountId,
                Role__c = 'Student'
            )
        };
        insert affiliations;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(0, returnAccounts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is disabled in Hierarchy Settings, and
     * Account has an Attribute record associated to it, that it can be deleted.
     */
    @isTest
    private static void accCanDeleteWithAttribute() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = false)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Attribute__c> attributes = new List<Attribute__c>{
            new Attribute__c(Name = 'Attribute1', Agency__c = newAccounts[0].Id),
            new Attribute__c(Name = 'Attribute2', Agency__c = newAccounts[1].Id)
        };
        insert attributes;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(0, returnAccounts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is disabled in Hierarchy Settings, and
     * Account has an Attribute record associated to it , that it can be deleted.
     */
    @isTest
    private static void accCanDeleteWithCourse() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = false)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Course__c> courses = new List<Course__c>{
            new Course__c(Name = 'Course1', Account__c = newAccounts[0].Id),
            new Course__c(Name = 'Course2', Account__c = newAccounts[1].Id)
        };
        insert courses;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(0, returnAccounts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is disabled in Hierarchy Settings, and
     * if a Contact's Primary_Household__c field is populated with the Account, then the Account can be deleted.
     */
    @isTest
    private static void accCanDeleteWithContactHousehold() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = false)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Contact> newContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        newContacts[0].LastName = 'Willy';
        newContacts[0].Primary_Household__c = newAccounts[0].Id;
        newContacts[1].LastName = 'Jones';
        newContacts[1].Primary_Household__c = newAccounts[1].Id;
        insert newContacts;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(0, returnAccounts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is disabled in Hierarchy Settings, and
     * if a Contact's Primary_Organization__c field is populated with the Account, then the Account can be deleted.
     */
    @isTest
    public static void accCanDeleteWithContactBusinessOrg() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = false)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Contact> newContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        newContacts[0].LastName = 'Willy';
        newContacts[0].Primary_Organization__c = newAccounts[0].Id;
        newContacts[1].LastName = 'Jones';
        newContacts[1].Primary_Organization__c = newAccounts[1].Id;
        insert newContacts;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(0, returnAccounts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is disabled in Hierarchy Settings, and
     * Account has a Course Connection record associated to it, that it can be deleted.
     */
    @isTest
    public static void accCanDeleteWithCourseConnection() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = false)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Contact> newContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        newContacts[0].LastName = 'Willy';
        newContacts[0].AccountId = newAccounts[0].Id;
        newContacts[1].LastName = 'Jones';
        newContacts[1].AccountId = newAccounts[1].Id;
        insert newContacts;

        List<Course__c> courses = new List<Course__c>{
            new Course__c(Name = 'Course1', Account__c = newAccounts[0].Id),
            new Course__c(Name = 'Course2', Account__c = newAccounts[1].Id)
        };
        insert courses;

        List<Term__c> terms = new List<Term__c>{
            new Term__c(Name = 'Fall', Account__c = newAccounts[0].Id),
            new Term__c(Name = 'Spring', Account__c = newAccounts[1].Id)
        };
        insert terms;

        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(courses[0].Id, terms[0].Id);
        Course_Offering__c courseOffering2 = UTIL_UnitTestData_TEST.createCourseOffering(courses[1].Id, terms[1].Id);

        Course_Enrollment__c courseConnection1 = UTIL_UnitTestData_TEST.getCourseConnection(
            newContacts[0].Id,
            courseOffering1.Id
        );
        Course_Enrollment__c courseConnection2 = UTIL_UnitTestData_TEST.getCourseConnection(
            newContacts[1].Id,
            courseOffering2.Id
        );
        courseConnection1.Account__c = newAccounts[0].Id;
        courseConnection2.Account__c = newAccounts[1].Id;
        insert new List<SObject>{ courseConnection1, courseConnection2 };

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(0, returnAccounts.size());
    }

    /*********************************************************************************************************
     * @description Bulk test method to test if Prevent_Account_Deletion__c is enabled in Hierarchy Settings, and
     * Account has a Education History record associated to it, that it can be deleted.
     */
    @isTest
    public static void accCanDeleteWithEducationHistoryBULK() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = false)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            2,
            UTIL_Describe.getAcademicAccRecTypeID()
        );
        insert newAccounts;

        Education_History__c educationHistory1 = UTIL_UnitTestData_TEST.getEduHistory(newAccounts[0].Id, null);
        Education_History__c educationHistory2 = UTIL_UnitTestData_TEST.getEduHistory(newAccounts[0].Id, null);
        Education_History__c educationHistory3 = UTIL_UnitTestData_TEST.getEduHistory(newAccounts[1].Id, null);
        Education_History__c educationHistory4 = UTIL_UnitTestData_TEST.getEduHistory(newAccounts[1].Id, null);

        insert new List<Education_History__c>{
            educationHistory1,
            educationHistory2,
            educationHistory3,
            educationHistory4
        };

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(0, returnAccounts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is disabled in Hierarchy Settings, and
     * Account has a Facility record associated to it, that it can be deleted.
     */
    @isTest
    public static void accCanDeleteWithFacility() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = false)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Facility__c> facilities = new List<Facility__c>{
            new Facility__c(Name = 'MeetingRoom1', Account__c = newAccounts[0].Id),
            new Facility__c(Name = 'MeetingRoom2', Account__c = newAccounts[1].Id)
        };
        insert facilities;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(0, returnAccounts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is disabled in Hierarchy Settings, and
     * Account has a Program Enrollment record associated to it, that it can be deleted.
     */
    @isTest
    public static void accCanDeleteWithProgramEnrollment() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = false)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Contact> newContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        newContacts[0].LastName = 'Willy';
        newContacts[0].AccountId = newAccounts[0].Id;
        newContacts[1].LastName = 'Jones';
        newContacts[1].AccountId = newAccounts[1].Id;
        insert newContacts;

        Program_Enrollment__c programEnrollment1 = UTIL_UnitTestData_TEST.getProgramEnrollment(newAccounts[0].Id);
        Program_Enrollment__c programEnrollment2 = UTIL_UnitTestData_TEST.getProgramEnrollment(newAccounts[1].Id);
        insert new List<SObject>{ programEnrollment1, programEnrollment2 };

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(0, returnAccounts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is disabled in Hierarchy Settings, and
     * Account has a Program Plan record associated to it, that it can be deleted.
     */
    @isTest
    public static void accCanDeleteWithProgramPlan() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = false)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Program_Plan__c> programPlans = new List<Program_Plan__c>{
            new Program_Plan__c(Name = 'Plan1', Account__c = newAccounts[0].Id),
            new Program_Plan__c(Name = 'Plan2', Account__c = newAccounts[1].Id)
        };
        insert programPlans;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(0, returnAccounts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is disabled in Hierarchy Settings, and
     * Account has a Term record associated to it, that it can be deleted.
     */
    @isTest
    public static void accCanDeleteWithTerm() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = false)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Term__c> terms = new List<Term__c>{
            new Term__c(Name = 'Fall', Account__c = newAccounts[0].Id),
            new Term__c(Name = 'Spring', Account__c = newAccounts[1].Id)
        };
        insert terms;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(0, returnAccounts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is disabled in Hierarchy Settings, and
     * Account has a Time Block record associated to it, that it can be deleted.
     */
    @isTest
    public static void accCanDeleteWithTimeBlock() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = false)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        insert newAccounts;

        List<Time_Block__c> timeBlocks = new List<Time_Block__c>{
            new Time_Block__c(Name = '1stTimeBlock', Educational_Institution__c = newAccounts[0].Id),
            new Time_Block__c(Name = '2ndTimeBlock', Educational_Institution__c = newAccounts[1].Id)
        };
        insert timeBlocks;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(0, returnAccounts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is enabled in Hierarchy Settings, and
     * Account has some child record associated to it, that it cannot be deleted.
     */
    @isTest
    public static void cannotDelete() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = true)
        );

        STG_InstallScript.insertMappings();

        Contact c = UTIL_UnitTestData_TEST.getContact();
        insert c;

        Account[] accs = UTIL_UnitTestData_TEST.getMultipleTestAccounts(5, UTIL_Describe_API.getBizAccRecTypeID());
        insert accs;

        Affiliation__c affl = new Affiliation__c(Contact__c = c.ID, Account__c = accs[0].ID);
        Program_Enrollment__c programEnroll = new Program_Enrollment__c(Contact__c = c.ID, Account__c = accs[1].ID);
        Course_Enrollment__c courseEnroll = new Course_Enrollment__c(Contact__c = c.ID, Account__c = accs[2].ID);
        Program_Plan__c programPlan = new Program_Plan__c(Account__c = accs[4].Id);
        insert new List<SObject>{ affl, programEnroll, courseEnroll, programPlan };

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(accs, false);
        Test.stopTest();

        UTIL_Debug.debug('****Delete results: ' + JSON.serializePretty(results));

        //Verify only acc4 was successfully deleted
        accs = [SELECT ID FROM Account WHERE ID IN :accs];
        System.assertEquals(4, accs.size());

        System.assertEquals(false, results[0].success);
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
        System.assertEquals(false, results[1].success);
        System.assertEquals(Label.CannotDelete, results[1].errors[0].message);
        System.assertEquals(false, results[2].success);
        System.assertEquals(Label.CannotDelete, results[2].errors[0].message);
        System.assertEquals(true, results[3].success);
        System.assertEquals(false, results[4].success);
        System.assertEquals(Label.CannotDelete, results[4].errors[0].message);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is enabled in Hierarchy Settings, and
     * Account has some child record associated to it, that it cannot be deleted.
     */
    @isTest
    public static void cannotDeleteSomeAccounts() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = true)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        newAccounts[0].Name = 'Willy BusinessOrg';
        newAccounts[1].Name = 'Jones BusinessOrg';
        insert newAccounts;

        Map<String, Id> accNameById = new Map<String, Id>();
        for (Account a : newAccounts) {
            accNameById.put(a.Name, a.Id);
        }

        List<Contact> newContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        newContacts[0].LastName = 'Willy';
        newContacts[0].AccountId = newAccounts[0].Id;
        newContacts[0].Primary_Household__c = newAccounts[0].Id;
        newContacts[0].Primary_Organization__c = newAccounts[0].Id;
        newContacts[1].LastName = 'Jones';
        newContacts[1].AccountId = newAccounts[1].Id;
        insert newContacts;

        Map<String, Contact> lastNameByContact = new Map<String, Contact>();
        for (Contact c : newContacts) {
            lastNameByContact.put(c.LastName, c);
        }

        Affiliation__c affiliation = new Affiliation__c(
            Contact__c = lastNameByContact.get('Willy').Id,
            Account__c = lastNameByContact.get('Willy').AccountId,
            Role__c = 'Student'
        );
        insert affiliation;

        Address__c addr = new Address__c(
            Parent_Account__c = lastNameByContact.get('Willy').AccountId,
            MailingCity__c = 'Boston'
        );
        insert addr;

        Attribute__c attr = new Attribute__c(Name = 'Attr1', Agency__c = lastNameByContact.get('Willy').AccountId);
        insert attr;

        Course__c course = new Course__c(Name = 'Bio101', Account__c = lastNameByContact.get('Willy').AccountId);
        insert course;

        Facility__c facility = new Facility__c(
            Name = 'MeetingRoom1',
            Account__c = lastNameByContact.get('Willy').AccountId
        );
        insert facility;

        Program_Enrollment__c pe = new Program_Enrollment__c(
            Contact__c = lastNameByContact.get('Willy').Id,
            Account__c = lastNameByContact.get('Willy').AccountId
        );
        insert pe;

        Program_Plan__c pl = new Program_Plan__c(Account__c = lastNameByContact.get('Willy').AccountId);
        insert pl;

        Term__c term = new Term__c(Name = 'Fall', Account__c = lastNameByContact.get('Willy').AccountId);
        insert term;

        Time_Block__c timeBlock = new Time_Block__c(
            Name = 'TimeB',
            Educational_Institution__c = lastNameByContact.get('Willy').AccountId
        );
        insert timeBlock;

        Education_History__c educationHistory = UTIL_UnitTestData_TEST.getEduHistory(
            lastNameByContact.get('Willy').AccountId,
            null
        );
        insert educationHistory;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id, Name FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(1, returnAccounts.size());
        System.assertEquals('Willy BusinessOrg', returnAccounts[0].Name);
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is enabled in Hierarchy Settings, and
     * Account has some child record associated to it, that it can be deleted.
     */
    @isTest
    public static void canDelete() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = false)
        );

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        newAccounts[0].Name = 'Willy BusinessOrg';
        newAccounts[1].Name = 'Jones BusinessOrg';
        insert newAccounts;

        Map<String, Id> accNameById = new Map<String, Id>();
        for (Account a : newAccounts) {
            accNameById.put(a.Name, a.Id);
        }

        List<Contact> newContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        newContacts[0].LastName = 'Willy';
        newContacts[0].AccountId = newAccounts[0].Id;
        newContacts[0].Primary_Household__c = newAccounts[0].Id;
        newContacts[0].Primary_Organization__c = newAccounts[0].Id;
        newContacts[1].LastName = 'Jones';
        newContacts[1].AccountId = newAccounts[1].Id;
        insert newContacts;

        Map<String, Contact> lastNameByContact = new Map<String, Contact>();
        for (Contact c : newContacts) {
            lastNameByContact.put(c.LastName, c);
        }

        Affiliation__c affiliation = new Affiliation__c(
            Contact__c = lastNameByContact.get('Willy').Id,
            Account__c = lastNameByContact.get('Willy').AccountId,
            Role__c = 'Student'
        );
        insert affiliation;

        Address__c addr = new Address__c(
            Parent_Account__c = lastNameByContact.get('Willy').AccountId,
            MailingCity__c = 'Boston'
        );
        insert addr;

        Attribute__c attr = new Attribute__c(Name = 'Attr1', Agency__c = lastNameByContact.get('Willy').AccountId);
        insert attr;

        Course__c course = new Course__c(Name = 'Bio101', Account__c = lastNameByContact.get('Willy').AccountId);
        insert course;

        Facility__c facility = new Facility__c(
            Name = 'MeetingRoom1',
            Account__c = lastNameByContact.get('Willy').AccountId
        );
        insert facility;

        Education_History__c educationHistory = UTIL_UnitTestData_TEST.getEduHistory(
            lastNameByContact.get('Willy').AccountId,
            null
        );
        insert educationHistory;

        Program_Enrollment__c pe = new Program_Enrollment__c(
            Contact__c = lastNameByContact.get('Willy').Id,
            Account__c = lastNameByContact.get('Willy').AccountId
        );
        insert pe;

        Program_Plan__c pl = new Program_Plan__c(Account__c = lastNameByContact.get('Willy').AccountId);
        insert pl;

        Term__c term = new Term__c(Name = 'Fall', Account__c = lastNameByContact.get('Willy').AccountId);
        insert term;

        Time_Block__c timeBlock = new Time_Block__c(
            Name = 'TimeB',
            Educational_Institution__c = lastNameByContact.get('Willy').AccountId
        );
        insert timeBlock;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(newAccounts, false);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id, Name FROM Account WHERE Id IN :newAccounts];

        System.assertEquals(0, returnAccounts.size());
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is enabled in Hierarchy Settings, and
     * Account has some child record associated to it, that it can be merged.
     */
    @isTest
    public static void canMergeAccounts() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = true)
        );

        Account duplicateAccount = UTIL_UnitTestData_TEST.createTestAccountWithMultipleRelations();

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        Account masterAccount = newAccounts[1];
        masterAccount.Name = 'Jones BusinessOrg';
        insert masterAccount;

        Test.startTest();
        Database.MergeResult results = Database.merge(masterAccount, duplicateAccount.Id, false);
        Test.stopTest();

        System.assertEquals(true, results.isSuccess());
        System.assertEquals(true, results.getMergedRecordIds().contains(duplicateAccount.Id));

        List<Account> returnAccounts = [
            SELECT Id, Name
            FROM Account
            WHERE Id = :masterAccount.Id OR Id = :duplicateAccount.Id
        ];

        System.assertEquals(1, returnAccounts.size());
        System.assertEquals(masterAccount.Name, returnAccounts[0].Name);

        Account winnerAccount = [
            SELECT
                ID,
                (SELECT ID FROM Account.Addresses__r LIMIT 1),
                (SELECT ID FROM Account.Affl_Contacts__r LIMIT 1),
                (SELECT ID FROM Account.Attributes__r LIMIT 1),
                (SELECT ID FROM Account.Courses__r LIMIT 1),
                (SELECT ID FROM Account.Course_Enrollments__r LIMIT 1),
                (SELECT ID FROM Account.Education_History__r LIMIT 1),
                (SELECT ID FROM Account.Facilities__r LIMIT 1),
                (SELECT ID FROM Account.Household_Members__r LIMIT 1),
                (SELECT ID FROM Account.Organization_Members__r LIMIT 1),
                (SELECT ID FROM Account.Program_Enrollments__r LIMIT 1),
                (SELECT ID FROM Account.Program_Plans__r LIMIT 1),
                (SELECT ID FROM Account.Terms__r LIMIT 1),
                (SELECT ID FROM Account.Time_Blocks__r LIMIT 1)
            FROM Account
            WHERE ID = :masterAccount.Id
        ];

        System.assertEquals(1, winnerAccount.Addresses__r.size(), 'There should be 1 merged address');
        System.assertEquals(1, winnerAccount.Attributes__r.size(), 'There should be 1 merged attribute');
        System.assertEquals(1, winnerAccount.Courses__r.size(), 'There should be 1 merged course');
        System.assertEquals(1, winnerAccount.Facilities__r.size(), 'There should be 1 merged facility');
        System.assertEquals(1, winnerAccount.Program_Plans__r.size(), 'There should be 1 merged plan');
        System.assertEquals(1, winnerAccount.Education_History__r.size(), 'There should be 1 merged education history');
        System.assertEquals(1, winnerAccount.Program_Enrollments__r.size(), 'There should be 1 merged enrollment');
        System.assertEquals(1, winnerAccount.Terms__r.size(), 'There should be 1 merged term');
        System.assertEquals(1, winnerAccount.Time_Blocks__r.size(), 'There should be 1 merged time block');
    }

    /*********************************************************************************************************
     * @description Test method to test if Prevent_Account_Deletion__c is disable in Hierarchy Settings, and
     * Account has some child record associated to it, that it can be merged.
     */
    @isTest
    public static void canMergeAccountsWhenPreventDeletionDisabled() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = false)
        );

        Account duplicateAccount = UTIL_UnitTestData_TEST.createTestAccountWithMultipleRelations();

        List<Account> newAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, bizAccRecordTypeId);
        Account masterAccount = newAccounts[1];
        masterAccount.Name = 'Jones BusinessOrg';
        insert masterAccount;

        Test.startTest();
        Database.MergeResult results = Database.merge(masterAccount, duplicateAccount.Id, false);
        Test.stopTest();

        System.assertEquals(true, results.isSuccess());
        System.assertEquals(true, results.getMergedRecordIds().contains(duplicateAccount.Id));

        List<Account> returnAccounts = [
            SELECT Id, Name
            FROM Account
            WHERE Id = :masterAccount.Id OR Id = :duplicateAccount.Id
        ];

        System.assertEquals(1, returnAccounts.size());
        System.assertEquals(masterAccount.Name, returnAccounts[0].Name);

        Account winnerAccount = [
            SELECT
                ID,
                (SELECT ID FROM Account.Addresses__r LIMIT 1),
                (SELECT ID FROM Account.Affl_Contacts__r LIMIT 1),
                (SELECT ID FROM Account.Attributes__r LIMIT 1),
                (SELECT ID FROM Account.Courses__r LIMIT 1),
                (SELECT ID FROM Account.Course_Enrollments__r LIMIT 1),
                (SELECT ID FROM Account.Education_History__r LIMIT 1),
                (SELECT ID FROM Account.Facilities__r LIMIT 1),
                (SELECT ID FROM Account.Household_Members__r LIMIT 1),
                (SELECT ID FROM Account.Organization_Members__r LIMIT 1),
                (SELECT ID FROM Account.Program_Enrollments__r LIMIT 1),
                (SELECT ID FROM Account.Program_Plans__r LIMIT 1),
                (SELECT ID FROM Account.Terms__r LIMIT 1),
                (SELECT ID FROM Account.Time_Blocks__r LIMIT 1)
            FROM Account
            WHERE ID = :masterAccount.Id
        ];

        System.assertEquals(1, winnerAccount.Addresses__r.size(), 'There should be 1 merged address');
        System.assertEquals(1, winnerAccount.Attributes__r.size(), 'There should be 1 merged attribute');
        System.assertEquals(1, winnerAccount.Courses__r.size(), 'There should be 1 merged course');
        System.assertEquals(1, winnerAccount.Facilities__r.size(), 'There should be 1 merged facility');
        System.assertEquals(1, winnerAccount.Program_Plans__r.size(), 'There should be 1 merged plan');
        System.assertEquals(1, winnerAccount.Education_History__r.size(), 'There should be 1 merged education history');
        System.assertEquals(1, winnerAccount.Program_Enrollments__r.size(), 'There should be 1 merged enrollment');
        System.assertEquals(1, winnerAccount.Terms__r.size(), 'There should be 1 merged term');
        System.assertEquals(1, winnerAccount.Time_Blocks__r.size(), 'There should be 1 merged time block');
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
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Account;

        ACCT_CannotDelete_TDTM accCannotDeleteTDTM = new ACCT_CannotDelete_TDTM();
        TDTM_Runnable.DmlWrapper dmlWrapperReturned = accCannotDeleteTDTM.run(null, null, testAction, objResult);

        System.assertEquals(0, dmlWrapperReturned.objectsToDelete.size());
    }

    /****************************************************************************************************************
     * @description Positive test for run method to verify accountPreventedFromDeletionList has the records prevented
     * from Deletion when Prevent Account Deletion Custom Settings is enabled
     */
    @isTest
    private static void runMethodPositiveTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = true)
        );

        TDTM_Runnable.Action testBeforeAction = TDTM_Runnable.Action.BeforeDelete;
        TDTM_Runnable.Action testAfterAction = TDTM_Runnable.Action.AfterDelete;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Account;

        Account acc = UTIL_UnitTestData_TEST.createTestAccountWithMultipleRelations();

        List<SObject> oldList = new List<SObject>{ acc };

        Map<Id, Account> accountById = new Map<Id, Account>();
        accountById.put(acc.Id, acc);

        ACCT_CannotDelete_TDTM accCannotDeleteTDTM = new ACCT_CannotDelete_TDTM();

        Test.startTest();
        accCannotDeleteTDTM.run(null, oldList, testBeforeAction, objResult);
        List<Account> accountsWithChildRelations = ACCT_CannotDelete_TDTM.accountsWithChildRelations;
        accCannotDeleteTDTM.run(null, oldList, testAfterAction, objResult);
        Test.stopTest();

        // verify before handler retrieved account with relations
        System.assertEquals(oldList.size(), accountsWithChildRelations.size());
        List<Account> deletionPreventedAccountList = SRVC_Account_PreventDeletion.getInstance()
            .preventDeletionForAccounts(accountById, accountsWithChildRelations);

        // verify deletionPreventedAccountList is not empty
        System.assertEquals(1, deletionPreventedAccountList.size());
        // verify after handler cleared accountsWithChildRelations static var
        System.assertEquals(null, ACCT_CannotDelete_TDTM.accountsWithChildRelations);
    }

    /************************************************************************************************************************
     * @description Negative test for run method to verify accountPreventedFromDeletionList has no records that are prevented
     * from Deletion when Prevent Account Deletion Custom Settings is disabled
     */
    @isTest
    private static void runMethodNegativeTestWithCustomSettingsDisabled() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = false)
        );

        TDTM_Runnable.Action testBeforeAction = TDTM_Runnable.Action.BeforeDelete;
        TDTM_Runnable.Action testAfterAction = TDTM_Runnable.Action.AfterDelete;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Account;

        Account acc = UTIL_UnitTestData_TEST.createTestAccountWithMultipleRelations();

        List<SObject> oldList = new List<SObject>{ acc };

        Map<Id, Account> accountById = new Map<Id, Account>();

        ACCT_CannotDelete_TDTM accCannotDeleteTDTM = new ACCT_CannotDelete_TDTM();

        Test.startTest();
        accCannotDeleteTDTM.run(null, oldList, testBeforeAction, objResult);
        List<Account> accountsWithChildRelations = ACCT_CannotDelete_TDTM.accountsWithChildRelations;
        accCannotDeleteTDTM.run(null, oldList, testAfterAction, objResult);
        Test.stopTest();

        // verify before handler didn't retrieve any accounts with relations
        System.assertEquals(null, accountsWithChildRelations);

        List<Account> deletionPreventedAccountList = SRVC_Account_PreventDeletion.getInstance()
            .preventDeletionForAccounts(accountById, new List<Account>());

        // Verify deletionPreventedAccountList is empty
        System.assertEquals(0, deletionPreventedAccountList.size());
        // verify after handler cleared accountsWithChildRelations static var
        System.assertEquals(null, ACCT_CannotDelete_TDTM.accountsWithChildRelations);
    }

    /*************************************************************************************************************************
     * @description Negative test for run method to verify accountPreventedFromDeletionList has no records that are prevented
     * from Deletion when Prevent Account Deletion Custom Settings is enabled.
     */
    @isTest
    static void runMethodNegativeTestWithNoChildren() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = true)
        );

        TDTM_Runnable.Action testBeforeAction = TDTM_Runnable.Action.BeforeDelete;
        TDTM_Runnable.Action testAfterAction = TDTM_Runnable.Action.AfterDelete;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Account;

        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, bizAccRecordTypeId);
        insert accounts;

        List<SObject> oldList = new List<SObject>((List<SObject>) accounts);

        Map<Id, Account> accountById = new Map<Id, Account>((List<Account>) oldList);

        ACCT_CannotDelete_TDTM accCannotDeleteTDTM = new ACCT_CannotDelete_TDTM();

        Test.startTest();
        accCannotDeleteTDTM.run(null, oldList, testBeforeAction, objResult);
        List<Account> accountsWithChildRelations = ACCT_CannotDelete_TDTM.accountsWithChildRelations;
        accCannotDeleteTDTM.run(null, oldList, testAfterAction, objResult);
        Test.stopTest();

        List<Account> deletionPreventedAccountList = SRVC_Account_PreventDeletion.getInstance()
            .preventDeletionForAccounts(accountById, accountsWithChildRelations);

        // Verify deletionPreventedAccountList is empty
        System.assertEquals(0, deletionPreventedAccountList.size());
    }

    /********************************************************************************************************************************
     * @description Tests handleBeforeDelete method of ACCT_CannotDelete_TDTM when Prevent Account Deletion Custom Settings is enabled
     * and Account having child records
     */
    @isTest
    private static void handleBeforeDeleteMethodWithCustomSettingsEnabledPositiveTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = true)
        );
        Account acc = UTIL_UnitTestData_TEST.createTestAccountWithMultipleRelations();
        List<Account> accounts = new List<Account>{ acc };

        ACCT_CannotDelete_TDTM accCanNotDeleteTDTM = new ACCT_CannotDelete_TDTM();
        Test.startTest();
        List<Account> accountsWithChildRelations = accCanNotDeleteTDTM.handleBeforeDelete(accounts);
        Test.stopTest();

        // Verify accountsWithChildRelations is not empty
        System.assertEquals(1, accountsWithChildRelations.size());
    }

    /*******************************************************************************************************************************************
     * @description positive test for handleBeforeDelete method of ACCT_CannotDelete_TDTM when Prevent Account Deletion Custom Settings is enabled
     * with no CHild records for Account
     */
    @isTest
    private static void handleBeforeDeleteMethodWithCustomSettingsEnabledNoRelationsPositiveTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = bizAccRecordTypeId, Prevent_Account_Deletion__c = true)
        );

        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, bizAccRecordTypeId);
        insert accounts;

        ACCT_CannotDelete_TDTM accCanNotDeleteTDTM = new ACCT_CannotDelete_TDTM();
        Test.startTest();
        List<Account> accountsWithChildRelations = accCanNotDeleteTDTM.handleBeforeDelete((List<SObject>) accounts);
        Test.stopTest();

        // Verify accountsWithChildRelations is empty
        System.assertEquals(1, accountsWithChildRelations.size());
    }

    /*************************************************************************************************************
     * @description Tests locateAccountPreventDeletionService method of ACCT_CannotDelete_TDTM
     */
    @isTest
    private static void locateAccountPreventDeletionServiceTest() {
        ACCT_CannotDelete_TDTM accCanNotDeleteTDTM = new ACCT_CannotDelete_TDTM();
        Test.startTest();
        SRVC_Account_PreventDeletion accPreventDeleteInstance = accCanNotDeleteTDTM.locateAccountPreventDeletionService();
        Test.stopTest();

        SRVC_Account_PreventDeletion srvcInstance = SRVC_Account_PreventDeletion.getInstance();

        System.assertEquals(srvcInstance, accPreventDeleteInstance);
    }
}
