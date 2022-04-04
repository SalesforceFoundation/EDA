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
 * @group Affiliations
 * @group-content ../../ApexDocContent/Affiliations.htm
 * @description Tests specific to Affiliation Management.
 */
@isTest
public with sharing class AFFL_MultiRecordType_TEST {
    private static Integer numberOfTestRecords = 5;
    //Trigger-specific recursion flags
    static final TDTM_ProcessControl.registeredTrigger BEFORE_INSERT_RECURSION = TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_Before_Insert;
    static final TDTM_ProcessControl.registeredTrigger AFTER_INSERT_RECURSION = TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_After_Insert;
    static final TDTM_ProcessControl.registeredTrigger AFTER_UPDATE_RECURSION = TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_After_Update;

    //Special recursion flags
    static final TDTM_ProcessControl.registeredTrigger AFFILIATION_MADE_PRIMARY_RECURSION = TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary;

    //Cross-trigger recursion flags. Potential antipattern.
    //NOTE: Evaluate if we can improve this
    static final TDTM_ProcessControl.registeredTrigger CONTACT_PRIMARY_AFFILIATION_UPDATED_RECURSION = TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_keyAfflLookupUpdated;

    /**************************************************************************
     * INTEGRATION TESTS
     **************************************************************************/
    private static void createPrimaryAffl() {
        List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(
            false
        );
        String bizOrgAcctName = affiliationMappingWrapperList[1].getAccountRecordTypeName();

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Verify default household account has been created for the contact
        contact = [SELECT Account.ID, Primary_Household__c FROM Contact WHERE ID = :Contact.ID];
        System.assertNotEquals(null, contact.Account.ID);
        System.assertEquals(null, contact.Primary_Household__c);
        //Manually create an Affiliation to the household, since we are not automatically doing so any more
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert new Affiliation__c(Contact__c = contact.ID, Account__c = contact.Account.ID, Primary__c = true);

        //Verify the primary household field was populated
        contact = [SELECT Account.ID, Primary_Household__c FROM Contact WHERE ID = :Contact.ID];
        System.assertNotEquals(null, contact.Primary_Household__c);

        //Create account of Business Organization record type
        Account bizOrg1 = new Account(Name = 'Acme', RecordTypeId = UTIL_Describe.getBizAccRecTypeID());
        insert bizOrg1;

        //Create another key affiliation, this time to a biz org
        Affiliation__c bizAffl1 = new Affiliation__c(
            Contact__c = contact.ID,
            Account__c = bizOrg1.ID,
            Primary__c = true
        );
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        Test.startTest();
        insert bizAffl1;
        Test.stopTest();

        //The business organization lookup should point to the account that is part of the affiliation we created
        bizAffl1 = [SELECT Affiliation_Type__c FROM Affiliation__c WHERE Account__c = :bizOrg1.ID];
        System.assertEquals(bizOrgAcctName, bizAffl1.Affiliation_Type__c);

        contact = [SELECT Primary_Organization__c FROM Contact WHERE ID = :contact.ID];
        System.assertEquals(bizOrg1.ID, Contact.Primary_Organization__c);

        //Create second account of the same record type
        Account bizOrg2 = new Account(Name = 'Toys Inc', RecordTypeId = UTIL_Describe.getBizAccRecTypeID());
        insert bizOrg2;

        //Create second primary affiliation
        Affiliation__c bizAffl2 = new Affiliation__c(
            Contact__c = contact.ID,
            Account__c = bizOrg2.ID,
            Primary__c = true
        );
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert bizAffl2;

        //The previous affiliation should not be the primary any more
        bizAffl1 = [SELECT Primary__c FROM Affiliation__c WHERE ID = :bizAffl1.ID];
        System.assertEquals(false, bizAffl1.Primary__c);

        //The business organization lookup should point to the account that is part of the second affiliation we created
        contact = [SELECT Primary_Organization__c FROM Contact WHERE ID = :contact.ID];
        System.assertEquals(bizOrg2.ID, Contact.Primary_Organization__c);

        //  Test addition of a new affiliation with the same Account doesn't erase the Primary field on Contact

        // Insert another primary Affiliaiton on the Contact with same Account
        Affiliation__c bizAffl3 = new Affiliation__c(
            Contact__c = contact.Id,
            Account__c = bizOrg2.ID,
            Primary__c = true
        );
        insert bizAffl3;

        // Verify Primary Buisness Organization on the Contact is not erased
        Contact updatedContact = [SELECT Id, Primary_Organization__c FROM Contact WHERE Id = :contact.Id];
        System.assertEquals(bizOrg2.ID, updatedContact.Primary_Organization__c);
    }

    @isTest
    private static void noDuplicateAffl() {
        AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(false);

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Create account of Business Organization record type
        Account bizOrg1 = new Account(Name = 'Acme', RecordTypeId = UTIL_Describe.getBizAccRecTypeID());
        insert bizOrg1;

        //Create primary affiliation
        Affiliation__c bizAffl1 = new Affiliation__c(
            Contact__c = contact.ID,
            Account__c = bizOrg1.ID,
            Primary__c = true
        );
        Test.startTest();
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert bizAffl1;
        Test.stopTest();

        //Verify only one Affiliation record to the business account exists. Github #159.
        List<Affiliation__c> affls = [
            SELECT ID
            FROM Affiliation__c
            WHERE Contact__c = :contact.ID AND Account__c = :bizOrg1.ID
        ];
        System.assertEquals(1, affls.size());
    }

    @isTest
    private static void deletePrimaryAffl() {
        AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(false);

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Verify default household account has been created for the contact
        contact = [SELECT Account.ID, Primary_Household__c FROM Contact WHERE ID = :Contact.ID];
        System.assertNotEquals(null, contact.Account.ID);
        System.assertEquals(null, contact.Primary_Household__c);

        //Manually create an Affiliation to the household, since we are not automatically doing so any more.
        insert new Affiliation__c(Contact__c = contact.ID, Account__c = contact.Account.ID, Primary__c = true);

        //Verify the primary household field was populated
        contact = [SELECT Account.ID, Primary_Household__c FROM Contact WHERE ID = :Contact.ID];
        System.assertNotEquals(null, contact.Primary_Household__c);

        //Craete account of Business Organization record type
        Account acc1 = new Account(Name = 'Acme', RecordTypeId = UTIL_Describe.getBizAccRecTypeID());
        insert acc1;

        //Create primary Business affiliation
        Affiliation__c affl1 = new Affiliation__c(Contact__c = contact.ID, Account__c = acc1.ID, Primary__c = true);
        Test.startTest();
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert affl1;
        Test.stopTest();

        //Verify Primary Organization lookup field points to the account we just created
        contact = [SELECT Primary_Organization__c FROM Contact WHERE ID = :contact.ID];
        System.assertEquals(acc1.ID, Contact.Primary_Organization__c);

        //Delete Business affiliation
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        delete affl1;

        //Verify Primary Organization lookup field has been cleared
        contact = [SELECT Primary_Organization__c FROM Contact WHERE ID = :contact.ID];
        System.assertEquals(null, Contact.Primary_Organization__c);
    }

    @isTest
    private static void makePrimaryAfflNonPrimary() {
        AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(false);

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Verify default household account has been created for the contact
        contact = [SELECT Account.ID, Primary_Household__c FROM Contact WHERE ID = :Contact.ID];
        System.assertNotEquals(null, contact.Account.ID);
        ID parentAccountId = contact.Account.ID;
        System.assertEquals(null, contact.Primary_Household__c);

        //Manually create an Affiliation to the household, since we are not automatically doing so any more.
        Affiliation__c affl = new Affiliation__c(
            Contact__c = contact.ID,
            Account__c = contact.Account.ID,
            Primary__c = true
        );
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert affl;

        //Verify the primary household field was populated
        contact = [SELECT Account.ID, Primary_Household__c FROM Contact WHERE ID = :Contact.ID];
        System.assertNotEquals(null, contact.Primary_Household__c);

        //Make the affiliation not primary
        affl.Primary__c = false;
        Test.startTest();
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        update affl;
        Test.stopTest();

        //Verify Primary_Household__c field has been cleared
        contact = [SELECT Account.ID, Primary_Household__c FROM Contact WHERE ID = :Contact.ID];
        System.assertEquals(null, contact.Primary_Household__c);

        //Verify the contact is still the child of the same account
        System.assertEquals(parentAccountId, contact.Account.ID);
    }

    @isTest
    private static void updatePrimaryAffiliationRecordType_FieldNames() {
        AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(false);
        Test.startTest();
        updatePrimaryAfflAccountRecordType();
        Test.stopTest();
    }

    /*
     * Ensure account record type changes are appropriated reflected upon contact fields/affiliations.
     * Test Scenario: T-3938997
     */
    private static void updatePrimaryAfflAccountRecordType() {
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        Account affiliatedBizAcct = new Account(Name = 'Acme', RecordTypeId = UTIL_Describe.getBizAccRecTypeID());
        Account affiliatedHHAcct = new Account(Name = 'Acme', RecordTypeId = UTIL_Describe.getHhAccRecTypeID());
        insert new List<Account>{ affiliatedBizAcct, affiliatedHHAcct };

        contact.Primary_Organization__c = affiliatedBizAcct.Id;
        contact.Primary_Household__c = affiliatedHHAcct.Id;
        update contact;

        affiliatedHHAcct.RecordTypeId = UTIL_Describe.getBizAccRecTypeID();
        update affiliatedHHAcct;

        contact = [SELECT Id, Primary_Household__c, Primary_Organization__c FROM Contact WHERE Id = :contact.Id];
        System.assertEquals(affiliatedHHAcct.Id, contact.Primary_Organization__c);
        System.assertEquals(null, contact.Primary_Household__c);

        Affiliation__c initialBizAffl = [
            SELECT Id, Primary__c, Affiliation_Type__c
            FROM Affiliation__c
            WHERE Contact__c = :contact.Id AND Account__c = :affiliatedBizAcct.Id
        ];

        Affiliation__c finalBizAffl = [
            SELECT Id, Primary__c, Affiliation_Type__c
            FROM Affiliation__c
            WHERE Contact__c = :contact.Id AND Account__c = :affiliatedHHAcct.Id
        ];

        System.assertEquals('Business Organization', initialBizAffl.Affiliation_Type__c);
        System.assertEquals('Business Organization', finalBizAffl.Affiliation_Type__c);
        System.assertEquals(false, initialBizAffl.Primary__c);
        System.assertEquals(true, finalBizAffl.Primary__c);
    }

    @isTest
    private static void makeNonPrimaryAfflPrimary() {
        AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(false);

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Create account of Business Organization record type
        Account acc1 = new Account(Name = 'Acme', RecordTypeId = UTIL_Describe.getBizAccRecTypeID());
        insert acc1;

        //Create non-primary Business affiliation
        Affiliation__c affl1 = new Affiliation__c(Contact__c = contact.ID, Account__c = acc1.ID, Primary__c = false);
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert affl1;

        //Verify Primary Organization lookup field is blank
        contact = [SELECT Primary_Organization__c FROM Contact WHERE ID = :contact.ID];
        System.assertEquals(null, Contact.Primary_Organization__c);

        //Make the business affiliation primary
        affl1.Primary__c = true;
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        Test.startTest();
        update affl1;
        Test.stopTest();

        //Verify key affl field has been populated
        contact = [SELECT Primary_Organization__c FROM Contact WHERE ID = :contact.ID];
        System.assertEquals(acc1.ID, Contact.Primary_Organization__c);

        //No other affiliation should have been created (bug W-008631)
        List<Affiliation__c> affls = [SELECT ID FROM Affiliation__c WHERE Contact__c = :contact.ID];
        System.assertEquals(1, affls.size());
    }

    @isTest
    private static void makeNonPrimaryAfflPrimaryWhenAnotherPrimaryExists() {
        AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(false);

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Create 2 accounts of Business Organization record type
        Account acc1 = new Account(Name = 'Acme1', RecordTypeId = UTIL_Describe.getBizAccRecTypeID());
        Account acc2 = new Account(Name = 'Acme2', RecordTypeId = UTIL_Describe.getBizAccRecTypeID());
        insert new List<Account>{ acc1, acc2 };

        //Create primary Business affiliation
        Affiliation__c affl1 = new Affiliation__c(Contact__c = contact.ID, Account__c = acc1.ID, Primary__c = true);
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert affl1;

        //Verify key affl field has been populated
        contact = [SELECT Primary_Organization__c FROM Contact WHERE ID = :contact.ID];
        System.assertEquals(acc1.ID, Contact.Primary_Organization__c);

        //Create non-primary Business affiliation
        Affiliation__c affl2 = new Affiliation__c(Contact__c = contact.ID, Account__c = acc2.ID, Primary__c = false);
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert affl2;

        //Made the second business affiliation primary
        affl2.Primary__c = true;
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        Test.startTest();
        update affl2;
        Test.stopTest();

        //The second affiliation should be the only primary so order by Primary ASC
        //to ensure we recieve the Primary = True as the second record. Verify
        //its affiliiation with acc2.
        List<Affiliation__c> affls = [
            SELECT Account__c, Primary__c
            FROM Affiliation__c
            WHERE Contact__c = :contact.ID
            ORDER BY Primary__c ASC
        ];
        System.assertEquals(affls[0].Account__c, acc1.ID);
        System.assertEquals(affls[0].Primary__c, false);
        System.assertEquals(affls[1].Account__c, acc2.ID);
        System.assertEquals(affls[1].Primary__c, true);

        //Verify key affl field has been updated
        contact = [SELECT Primary_Organization__c FROM Contact WHERE ID = :contact.ID];
        System.assertEquals(acc2.ID, Contact.Primary_Organization__c);
    }

    /* Ensure additional affiliations created render previous affiliations as non-primary.
     *  Test Scenario: T-3938989
     */
    @isTest
    private static void createPrimaryAfflWhenAnotherPrimaryExists() {
        AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(false);

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Create 2 accounts of Business Organization record type
        Account primaryAcct = new Account(Name = 'Acme1', RecordTypeId = UTIL_Describe.getBizAccRecTypeID());
        Account secondaryAcct = new Account(Name = 'Acme2', RecordTypeId = UTIL_Describe.getBizAccRecTypeID());
        insert new List<Account>{ primaryAcct, secondaryAcct };

        //Create primary Business affiliation
        Affiliation__c primaryAffiliation = new Affiliation__c(
            Contact__c = contact.ID,
            Account__c = primaryAcct.ID,
            Primary__c = true
        );
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert primaryAffiliation;

        primaryAffiliation = [SELECT Id, Account__c, Primary__c FROM Affiliation__c WHERE Id = :primaryAffiliation.Id];
        System.assertEquals(true, primaryAffiliation.Primary__c);

        //Create second primary Business affiliation
        Affiliation__c secondaryAffiliation = new Affiliation__c(
            Contact__c = contact.ID,
            Account__c = secondaryAcct.ID,
            Primary__c = true
        );
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        Test.startTest();
        insert secondaryAffiliation;
        Test.stopTest();

        Map<ID, Affiliation__c> allAffiliations = new Map<ID, Affiliation__c>(
            [SELECT Id, Account__c, Primary__c FROM Affiliation__c]
        );

        System.assertNotEquals(null, allAffiliations.get(primaryAffiliation.Id));
        System.assertEquals(false, allAffiliations.get(primaryAffiliation.Id).Primary__c);
        System.assertNotEquals(null, allAffiliations.get(secondaryAffiliation.Id));
        System.assertEquals(true, allAffiliations.get(secondaryAffiliation.Id).Primary__c);
    }

    @isTest
    private static void autoCreateProgramEnrollment() {
        List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(
            false
        );

        AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper bizOrgMappingWrapper = affiliationMappingWrapperList[1];
        String bizOrgRecordTypeName = bizOrgMappingWrapper.getAccountRecordTypeName();

        //Turn on Academic Record auto-creation for Business Organization mapping, which we are using as an arbitrary record type for testing.
        Affl_Mappings__c bizOrgMapping = bizOrgMappingWrapper.getAffiliationMapping();
        bizOrgMapping.Auto_Program_Enrollment__c = true;
        bizOrgMapping.Auto_Program_Enrollment_Role__c = AffiliationTestSetupFactory_TEST.PROG_ENROLL_ROLE_STUDENT;
        bizOrgMapping.Auto_Program_Enrollment_Status__c = AffiliationTestSetupFactory_TEST.PROG_ENROLL_STATUS_CURRENT;
        update bizOrgMapping;

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Craete account of Business Organization record type
        Account acc = new Account(Name = 'Acme', RecordTypeId = UTIL_Describe.getBizAccRecTypeID());
        insert acc;

        //Create Business affiliation
        Affiliation__c affl = new Affiliation__c(
            Contact__c = contact.ID,
            Account__c = acc.ID,
            Role__c = AffiliationTestSetupFactory_TEST.PROG_ENROLL_ROLE_STUDENT,
            Status__c = AffiliationTestSetupFactory_TEST.PROG_ENROLL_STATUS_CURRENT
        );

        Test.startTest();
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert affl;
        Test.stopTest();
        //Verify Progran Enrollment record has been created
        List<Program_Enrollment__c> programEnrollments = [
            SELECT ID, Contact__c
            FROM Program_Enrollment__c
            WHERE Affiliation__c = :affl.ID
        ];
        System.assertEquals(1, programEnrollments.size());
        System.assertEquals(contact.ID, programEnrollments[0].Contact__c);
    }

    @isTest
    private static void autoCreateProgramEnrollmentDifferentRole() {
        List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(
            false
        );

        AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper bizOrgMappingWrapper = affiliationMappingWrapperList[1];
        String bizOrgRecordTypeName = bizOrgMappingWrapper.getAccountRecordTypeName();

        //Turn on Academic Record auto-creation for Business Organization mapping, which we are using as an arbitrary record type for testing.
        Affl_Mappings__c bizOrgMapping = bizOrgMappingWrapper.getAffiliationMapping();
        bizOrgMapping.Auto_Program_Enrollment__c = true;
        bizOrgMapping.Auto_Program_Enrollment_Role__c = AffiliationTestSetupFactory_TEST.PROG_ENROLL_ROLE_STUDENT;
        bizOrgMapping.Auto_Program_Enrollment_Status__c = AffiliationTestSetupFactory_TEST.PROG_ENROLL_STATUS_CURRENT;
        update bizOrgMapping;

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Craete account of Business Organization record type
        Account acc = new Account(Name = 'Acme', RecordTypeId = UTIL_Describe.getBizAccRecTypeID());
        insert acc;

        //Create Business affiliation
        Affiliation__c affl = new Affiliation__c(
            Contact__c = contact.ID,
            Account__c = acc.ID,
            Role__c = 'Teacher',
            Status__c = AffiliationTestSetupFactory_TEST.PROG_ENROLL_STATUS_CURRENT
        );

        Test.startTest();
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert affl;
        Test.stopTest();

        //Verify Program Enrollment record has not been created
        List<Program_Enrollment__c> programEnrollments = [
            SELECT ID, Contact__c
            FROM Program_Enrollment__c
            WHERE Affiliation__c = :affl.ID
        ];
        System.assertEquals(0, programEnrollments.size());
    }

    /*********************************************************************************************************
     * @description
     * This method ensures there is no NPE when a primay affiliation
     * with no contact is deleted
     */
    @isTest
    private static void affiliationDeleteNPECheck() {
        AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(false);

        // Insert a business account
        Account bizAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe.getBizAccRecTypeID())[0];
        insert bizAcc;

        // Insert a contact
        Contact contact = UTIL_UnitTestData_API.getContact();
        insert contact;

        //Insert a primary affiliation
        Affiliation__c affl = new Affiliation__c(Contact__c = contact.Id, Account__c = bizAcc.Id, Primary__c = true);
        insert affl;

        //Verify 1 affiliation is created
        List<Affiliation__c> affiliationList = [
            SELECT Id, Name, Contact__c, Primary__c
            FROM Affiliation__c
            WHERE Contact__c = :contact.Id AND Account__c = :bizAcc.Id
        ];

        System.assertEquals(1, affiliationList.size());
        System.assertEquals(true, affiliationList[0].Primary__c);

        // Clear the value of contact on affiliation
        affiliationList[0].Contact__c = null;
        update affiliationList;

        // delete affiliation
        Test.startTest();

        delete affiliationList;

        Test.stopTest();

        //Verify affiliation is deleted and no NPE
        List<Affiliation__c> allAffiliationList = [
            SELECT Id, Name, Primary__c
            FROM Affiliation__c
            WHERE Contact__c = :contact.Id AND Account__c = :bizAcc.Id
        ];

        System.assertEquals(0, allAffiliationList.size());
    }

    /*********************************************************************************************************
     * @description
     * This method ensures concurrent updates to multiple affiliation records as Primary populates correct
     * Primary fields on related Contact
     */
    @isTest
    private static void multipleAffiliationUpdates() {
        AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(false);

        // Insert Accounts
        Account bizAcc1 = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe.getBizAccRecTypeID())[0];
        Account bizAcc2 = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe.getBizAccRecTypeID())[0];
        Account hhAcc1 = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe.getCustomHHAccRecTypeID())[0];
        Account hhAcc2 = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe.getCustomHHAccRecTypeID())[0];

        insert new List<Account>{ bizAcc1, bizAcc2, hhAcc1, hhAcc2 };

        // Insert a Contact
        Contact contact1 = UTIL_UnitTestData_API.getContact();
        Contact contact2 = UTIL_UnitTestData_API.getContact();
        insert new List<Contact>{ contact1, contact2 };

        //Insert primary and non-primary Affiliations
        Affiliation__c affl1 = UTIL_UnitTestData_TEST.getAffiliation(contact1.Id, bizAcc1.Id, true);
        Affiliation__c affl2 = UTIL_UnitTestData_TEST.getAffiliation(contact1.Id, bizAcc2.Id, false);
        Affiliation__c affl3 = UTIL_UnitTestData_TEST.getAffiliation(contact1.Id, hhAcc1.Id, true);
        Affiliation__c affl4 = UTIL_UnitTestData_TEST.getAffiliation(contact1.Id, hhAcc2.Id, false);

        Affiliation__c affl5 = UTIL_UnitTestData_TEST.getAffiliation(contact2.Id, bizAcc1.Id, true);
        Affiliation__c affl6 = UTIL_UnitTestData_TEST.getAffiliation(contact2.Id, bizAcc2.Id, false);
        Affiliation__c affl7 = UTIL_UnitTestData_TEST.getAffiliation(contact2.Id, hhAcc1.Id, true);
        Affiliation__c affl8 = UTIL_UnitTestData_TEST.getAffiliation(contact2.Id, hhAcc2.Id, false);

        insert new List<Affiliation__c>{ affl1, affl2, affl3, affl4, affl5, affl6, affl7, affl8 };

        for (Contact eachCon : [SELECT Id, Primary_Organization__c, Primary_Household__c FROM Contact]) {
            // Ensure Primary fields on Contact are populated
            System.assertEquals(eachCon.Primary_Organization__c, bizAcc1.Id);
            System.assertEquals(eachCon.Primary_Household__c, hhAcc1.Id);
        }

        // Make non-primary Affliations as primary
        List<Affiliation__c> afflList = new List<Affiliation__c>();
        for (Affiliation__c eachAffl : [SELECT Id, Primary__c FROM Affiliation__c WHERE Primary__c = FALSE]) {
            eachAffl.Primary__c = true;
            afflList.add(eachAffl);
        }

        Test.startTest();
        if (afflList.size() > 0) {
            update afflList;
        }
        Test.stopTest();

        for (contact conAfterUpdate : [SELECT Id, Primary_Organization__c, Primary_Household__c FROM Contact]) {
            // Ensure Primary fields on Contact are populated with new Accounts
            System.assertEquals(conAfterUpdate.Primary_Organization__c, bizAcc2.Id);
            System.assertEquals(conAfterUpdate.Primary_Household__c, hhAcc2.Id);
        }
        // Ensure old Affliations are made non-primary
        for (Affiliation__c eachAffl : [
            SELECT Id, Primary__c
            FROM Affiliation__c
            WHERE
                (Contact__c = :contact1.Id
                OR Contact__c = :contact2.Id)
                AND (Account__c = :bizAcc1.Id
                OR Account__c = :hhAcc1.Id)
        ]) {
            System.assertEquals(eachAffl.Primary__c, false);
        }
    }

    /*********************************************************************************************************
     * @description
     * This bulk test method ensures Multiple affiliations to the same Business Organization don't
     * prevent Primary fields on Contacts from updating
     */
    @isTest
    private static void bulkAffiliationUpdates() {
        AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(false);

        List<Account> accList = new List<Account>();

        // Insert a Business Account
        Account bizAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe.getBizAccRecTypeID())[0];
        accList.add(bizAcc);

        // Insert a Household Account
        Account hhAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe.getCustomHHAccRecTypeID())[0];
        accList.add(hhAcc);

        // Insert multiple contacts
        List<Contact> conList = UTIL_UnitTestData_Test.getMultipleTestContacts(3);
        insert conList;

        // Insert 3 Primay Business Affiliations
        List<Affiliation__c> afflList = new List<Affiliation__c>();
        for (Contact each : conList) {
            Affiliation__c affl = UTIL_UnitTestData_TEST.getAffiliation(each.Id, bizAcc.Id, true);
            afflList.add(affl);
        }
        insert afflList;

        // Verify Primary Buisness Organization is populated on the Contact
        for (Contact eachContact : [SELECT Id, Primary_Organization__c FROM Contact]) {
            System.assertEquals(bizAcc.Id, eachContact.Primary_Organization__c);
        }

        // Insert a contact
        Contact contact2 = UTIL_UnitTestData_API.getContact();
        insert contact2;

        // Insert 1 non-primary business affiliation and 1 primary household affiliation
        List<Affiliation__c> newAfflList = new List<Affiliation__c>();
        Affiliation__c afflBizAcc = UTIL_UnitTestData_TEST.getAffiliation(contact2.Id, bizAcc.Id, false);
        Affiliation__c afflAcad = UTIL_UnitTestData_TEST.getAffiliation(contact2.Id, hhAcc.Id, true);
        newAfflList.add(afflBizAcc);
        newAfflList.add(afflAcad);
        insert newAfflList;

        // Ensure Primary Organization is NULL and household affiliation is populated
        Contact con = [SELECT Id, Primary_Organization__c, Primary_Household__c FROM Contact WHERE Id = :contact2.Id];
        System.assertEquals(null, con.Primary_Organization__c);
        System.assertEquals(hhAcc.Id, con.Primary_Household__c);

        // Insert Affiliations on the Contacts with the same Account as the Primary Organization
        // Change the Primary Academic Affiliation to non-primary
        List<Affiliation__c> afflListNew = new List<Affiliation__c>();
        for (Contact each : conList) {
            Affiliation__c affl1 = UTIL_UnitTestData_TEST.getAffiliation(each.Id, bizAcc.Id, true);
            afflListNew.add(affl1);
        }
        Affiliation__c afflBiz = UTIL_UnitTestData_TEST.getAffiliation(contact2.Id, bizAcc.Id, true);
        Affiliation__c hhAffl1 = UTIL_UnitTestData_TEST.getAffiliation(contact2.Id, hhAcc.Id, true);
        Affiliation__c hhAffl2 = UTIL_UnitTestData_TEST.getAffiliation(contact2.Id, hhAcc.Id, false);
        afflListNew.add(hhAffl1);
        afflListNew.add(hhAffl2);
        afflListNew.add(afflBiz);

        test.startTest();
        upsert afflListNew;
        test.stopTest();

        // Verify Primary Buisness Organization on Contacts are not erased
        for (Contact eachContact : [SELECT Id, Primary_Organization__c FROM Contact]) {
            System.assertEquals(bizAcc.Id, eachContact.Primary_Organization__c);
        }

        // Ensure Primary Household are populated
        Contact conAfterUpdate = [SELECT Id, Primary_Household__c FROM Contact WHERE Id = :contact2.Id];
        System.assertEquals(hhAcc.Id, conAfterUpdate.Primary_Household__c);
    }

    // Test the usage of custom API field name for affiliation mapping for multi-language support
    @isTest
    private static void customFieldAPIInMappings() {
        AffiliationTestSetupFactory_TEST.setupMappingsByNameAndApiName(false);

        // Insert a business account
        Account bizAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe.getBizAccRecTypeID())[0];
        insert bizAcc;

        // Insert a contact with business account as Primary business organization
        Contact contact = UTIL_UnitTestData_API.getContact();
        insert contact;

        Affiliation__c affl = new Affiliation__c(Contact__c = contact.Id, Account__c = bizAcc.Id, Primary__c = true);
        test.startTest();
        //Insert an affiliation
        insert affl;
        test.stopTest();

        //Verify Primary Organization is populated
        Contact updatedContact = [SELECT Id, Primary_Organization__c FROM Contact WHERE Id = :contact.Id];

        System.assertEquals(bizAcc.Id, updatedContact.Primary_Organization__c);
    }

    /* Test deletion of an Affiliation clears the Primary Affiliation field on its Contact when Affiliation Mappings
     have Label for Account Record Types and APIs for Primary Affiliation fields. */

    @isTest
    private static void testAfflDeletionWithLabelForRecTypeAndAPINameForPrimaryAfflFields() {
        AffiliationTestSetupFactory_TEST.setupMappingsByNameAndApiName(false);

        // Insert a business account
        Account bizAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe.getBizAccRecTypeID())[0];
        insert bizAcc;

        // Insert a contact with business account as Primary business organization
        Contact contact = UTIL_UnitTestData_API.getContact();
        insert contact;

        // Insert an affiliation
        Affiliation__c affiliation = new Affiliation__c(
            Contact__c = contact.Id,
            Account__c = bizAcc.Id,
            Primary__c = true
        );
        insert affiliation;

        // Verify Primary Organization lookup field points to the account we just created
        contact = [SELECT Primary_Organization__c FROM Contact WHERE Id = :contact.Id];
        System.assertEquals(bizAcc.ID, Contact.Primary_Organization__c);

        Test.startTest();
        delete affiliation;
        Test.stopTest();

        // Verify Primary Organization lookup field has been cleared
        contact = [SELECT Primary_Organization__c FROM Contact WHERE Id = :contact.Id];
        System.assertEquals(null, Contact.Primary_Organization__c);
    }

    /* Test deletion of an Affiliation clears the Primary Affiliation field on its Contact when Affiliation Mappings
     have API names for Account Record Types and Labels for Primary Affiliation fields. */

    @isTest
    private static void testAfflDeletionWithAPIForRecTypeAndLabelForPrimaryAfflFields() {
        AffiliationTestSetupFactory_TEST.setupMappingsByDevNameAndLabel(false);

        // Insert a business account
        Account bizAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe.getBizAccRecTypeID())[0];
        insert bizAcc;

        // Insert a contact with business account as Primary business organization
        Contact contact = UTIL_UnitTestData_API.getContact();
        insert contact;

        // Insert an affiliation
        Affiliation__c affiliation = new Affiliation__c(
            Contact__c = contact.Id,
            Account__c = bizAcc.Id,
            Primary__c = true
        );
        insert affiliation;

        // Verify Primary Organization lookup field points to the account we just created
        contact = [SELECT Primary_Organization__c FROM Contact WHERE Id = :contact.Id];
        System.assertEquals(bizAcc.ID, Contact.Primary_Organization__c);

        Test.startTest();
        delete affiliation;
        Test.stopTest();

        // Verify Primary Organization lookup field has been cleared
        contact = [SELECT Primary_Organization__c FROM Contact WHERE Id = :contact.Id];
        System.assertEquals(null, Contact.Primary_Organization__c);
    }

    /* Test deletion of an Affiliation clears the Primary Affiliation field on its Contact when Affiliation Mappings
     have API names for Account Record Types and API for Primary Affiliation fields. */

    @isTest
    private static void testAfflDeletionWithAPIForRecTypeAndAPIForPrimaryAfflFields() {
        AffiliationTestSetupFactory_TEST.setupMappingsByDevNameAndApiName(false);

        // Insert a business account
        Account bizAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe.getBizAccRecTypeID())[0];
        insert bizAcc;

        // Insert a contact with business account as Primary business organization
        Contact contact = UTIL_UnitTestData_API.getContact();
        insert contact;

        // Insert an affiliation
        Affiliation__c affiliation = new Affiliation__c(
            Contact__c = contact.Id,
            Account__c = bizAcc.Id,
            Primary__c = true
        );
        insert affiliation;

        // Verify Primary Organization lookup field points to the account we just created
        contact = [SELECT Primary_Organization__c FROM Contact WHERE Id = :contact.Id];
        System.assertEquals(bizAcc.ID, Contact.Primary_Organization__c);

        Test.startTest();
        delete affiliation;
        Test.stopTest();

        // Verify Primary Organization lookup field has been cleared
        contact = [SELECT Primary_Organization__c FROM Contact WHERE Id = :contact.Id];
        System.assertEquals(null, Contact.Primary_Organization__c);
    }

    /* Test to ensure users can create Contacts and Affiliations when Affiliation Record Type Enforced is enabled in EDA Settings
     and Affilation Mappings have Record Type Names for Account Record Type */
    @isTest
    private static void affiliationRecordTypeEnforceWAPINamesForAccRecType() {
        AffiliationTestSetupFactory_TEST.setupMappingsByDevNameAndLabel(false);
        AffiliationTestSetupFactory_TEST.enableAffiliationRecordTypeEnforcement();

        List<Account> testAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe.getBizAccRecTypeID()
        );
        insert testAccounts;

        // Ensure Accounts are inserted
        List<Account> accountsInserted = [SELECT Id FROM Account];
        System.assert(accountsInserted.size() == 1);

        // Insert 4 Contacts
        List<Contact> contactsToBeInserted = UTIL_UnitTestData_TEST.getMultipleTestContacts(3);
        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Primary_Organization__c = testAccounts[0].Id;
        contactsToBeInserted.add(testContact);
        insert contactsToBeInserted;

        // Ensure 4 Contacts are inserted
        List<Contact> contactsInserted = [SELECT Id FROM Contact];
        System.assertEquals(contactsInserted.size(), 4);

        // Ensure only 1 affiliation is created for testContact
        List<Affiliation__c> affiliationsBeforeInserted = [SELECT Id, Contact__c FROM Affiliation__c];
        System.assertEquals(1, affiliationsBeforeInserted.size());
        System.assertEquals(testContact.Id, affiliationsBeforeInserted[0].Contact__c);

        // Create 1 affiliaton each for a Contact
        List<Affiliation__c> affiliationsToBeInserted = new List<Affiliation__c>();
        for (Contact each : contactsInserted) {
            Affiliation__c affl = UTIL_UnitTestData_TEST.getAffiliation(each.Id, accountsInserted[0].Id, false);
            affiliationsToBeInserted.add(affl);
        }

        Test.startTest();
        insert affiliationsToBeInserted;
        Test.stopTest();

        // Ensure 4 new Affiliations are inserted
        List<Affiliation__c> affiliationsInserted = [SELECT Id FROM Affiliation__c];
        System.assertEquals(5, affiliationsInserted.size());
    }

    /* Test to ensure users can create Contacts and Affiliations when Affiliation Record Type Enforced is enabled in EDA Settings
     and Affiliation Mappings have Record Type Labels for Account Record Type */

    @isTest
    private static void affiliationRecordTypeEnforceWLabelsForAccRecType() {
        AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(false);
        AffiliationTestSetupFactory_TEST.enableAffiliationRecordTypeEnforcement();

        List<Account> testAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe.getBizAccRecTypeID()
        );
        insert testAccounts;

        // Ensure Accounts are inserted
        List<Account> accountsInserted = [SELECT Id FROM Account];
        System.assert(accountsInserted.size() == 1);

        // Insert 4 Contacts
        List<Contact> contactsToBeInserted = UTIL_UnitTestData_TEST.getMultipleTestContacts(3);
        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Primary_Organization__c = testAccounts[0].Id;
        contactsToBeInserted.add(testContact);
        insert contactsToBeInserted;

        // Ensure 4 Contacts are inserted
        List<Contact> contactsInserted = [SELECT Id FROM Contact];
        System.assertEquals(contactsInserted.size(), 4);

        // Ensure only 1 affiliation is created for testContact
        List<Affiliation__c> affiliationsBeforeInserted = [SELECT Id, Contact__c FROM Affiliation__c];
        System.assertEquals(1, affiliationsBeforeInserted.size());
        System.assertEquals(testContact.Id, affiliationsBeforeInserted[0].Contact__c);

        // Create 1 affiliation each for a Contact
        List<Affiliation__c> affiliationsToBeInserted = new List<Affiliation__c>();

        for (Contact each : contactsInserted) {
            Affiliation__c affl = UTIL_UnitTestData_TEST.getAffiliation(each.Id, accountsInserted[0].Id, false);
            affiliationsToBeInserted.add(affl);
        }

        Test.startTest();
        insert affiliationsToBeInserted;
        Test.stopTest();

        // Ensure 4 new Affiliations are inserted
        List<Affiliation__c> affiliationsInserted = [SELECT Id FROM Affiliation__c];
        System.assertEquals(5, affiliationsInserted.size());
    }

    /* Test to ensure users can create Contacts and Affiliations when Affiliation Record Type Enforced is enabled in EDA Settings
     and Affiliation Mappings have API names for Account Record Type and primary Affiliaiton Fields */

    @isTest
    private static void affiliationRecordTypeEnforceWAPINamesForAccRecTypeAndPrimaryAffl() {
        AffiliationTestSetupFactory_TEST.setupMappingsByDevNameAndApiName(false);
        AffiliationTestSetupFactory_TEST.enableAffiliationRecordTypeEnforcement();

        List<Account> testAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe.getBizAccRecTypeID()
        );
        insert testAccounts;

        // Ensure Accounts are inserted
        List<Account> accountsInserted = [SELECT Id FROM Account];
        System.assert(accountsInserted.size() == 1);

        // Insert 4 Contacts
        List<Contact> contactsToBeInserted = UTIL_UnitTestData_TEST.getMultipleTestContacts(3);
        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Primary_Organization__c = testAccounts[0].Id;
        contactsToBeInserted.add(testContact);
        insert contactsToBeInserted;

        // Ensure 4 Contacts are inserted
        List<Contact> contactsInserted = [SELECT Id FROM Contact];
        System.assertEquals(contactsInserted.size(), 4);

        // Ensure only 1 affiliation is created for testContact
        List<Affiliation__c> affiliationsBeforeInserted = [SELECT Id, Contact__c FROM Affiliation__c];
        System.assertEquals(1, affiliationsBeforeInserted.size());
        System.assertEquals(testContact.Id, affiliationsBeforeInserted[0].Contact__c);

        // Create 1 affiliation each for a Contact
        List<Affiliation__c> affiliationsToBeInserted = new List<Affiliation__c>();
        for (Contact each : contactsInserted) {
            Affiliation__c affl = UTIL_UnitTestData_TEST.getAffiliation(each.Id, accountsInserted[0].Id, false);
            affiliationsToBeInserted.add(affl);
        }

        Test.startTest();
        insert affiliationsToBeInserted;
        Test.stopTest();

        // Ensure 4 new Affiliations are inserted
        List<Affiliation__c> affiliationsInserted = [SELECT Id FROM Affiliation__c];
        System.assertEquals(5, affiliationsInserted.size());
    }

    /* Test to ensure users can create Contacts and Affiliations when Affiliation Record Type Enforced is enabled in EDA Settings
     and Affiliation Mappings have Labels for Account Record Type and APIs for Primary Affiliaiton Fields */
    @isTest
    private static void affiliationRecordTypeEnforceWLabelsForAccRecTypeAndAPIForPrimaryAffl() {
        AffiliationTestSetupFactory_TEST.setupMappingsByNameAndApiName(false);
        AffiliationTestSetupFactory_TEST.enableAffiliationRecordTypeEnforcement();

        List<Account> testAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe.getBizAccRecTypeID()
        );
        insert testAccounts;

        // Ensure Accounts are inserted
        List<Account> accountsInserted = [SELECT Id FROM Account];
        System.assert(accountsInserted.size() == 1);

        // Insert 4 Contacts
        List<Contact> contactsToBeInserted = UTIL_UnitTestData_TEST.getMultipleTestContacts(3);
        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Primary_Organization__c = testAccounts[0].Id;
        contactsToBeInserted.add(testContact);
        insert contactsToBeInserted;

        // Ensure 4 Contacts are inserted
        List<Contact> contactsInserted = [SELECT Id FROM Contact];
        System.assertEquals(contactsInserted.size(), 4);

        // Ensure only 1 affiliation is created for testContact
        List<Affiliation__c> affiliationsBeforeInserted = [SELECT Id, Contact__c FROM Affiliation__c];
        System.assertEquals(1, affiliationsBeforeInserted.size());
        System.assertEquals(testContact.Id, affiliationsBeforeInserted[0].Contact__c);

        // Create 1 affiliation each for a Contact
        List<Affiliation__c> affiliationsToBeInserted = new List<Affiliation__c>();
        for (Contact each : contactsInserted) {
            Affiliation__c affl = UTIL_UnitTestData_TEST.getAffiliation(each.Id, accountsInserted[0].Id, false);
            affiliationsToBeInserted.add(affl);
        }

        Test.startTest();
        insert affiliationsToBeInserted;
        Test.stopTest();

        // Ensure 4 new Affiliations are inserted
        List<Affiliation__c> affiliationsInserted = [SELECT Id FROM Affiliation__c];
        System.assertEquals(5, affiliationsInserted.size());
    }

    /**************************************************************************
     * Unit TESTS
     *************************************************************************/

    /****************************************
     * handleAfterInsert
     ****************************************/

    /**
     * @description helper class for initialization of tests for handleAfterInsert
     */
    private class HandleAfterInsertValidData {
        public AFFL_MultiRecordType_TDTM tdtmClass;
        public TDTM_Runnable.DmlWrapper dmlWrapper;
        public Account accountToTest;
        public Contact contactToTest;
        public Affiliation__c affiliation;

        public HandleAfterInsertValidData() {
            this.tdtmClass = new AFFL_MultiRecordType_TDTM();
            this.dmlWrapper = new TDTM_Runnable.DmlWrapper();
            this.contactToTest = UTIL_UnitTestData_TEST.getUniqueContact(1);
            insert contactToTest;

            Id businessOrganizationRecordTypeId = UTIL_Describe.getBizAccRecTypeID();
            this.accountToTest = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, businessOrganizationRecordTypeId)[0];
            insert this.accountToTest;

            this.affiliation = new Affiliation__c(
                Id = UTIL_UnitTestData_TEST.getFakeId(Affiliation__c.SObjectType),
                Account__c = this.accountToTest.Id,
                Contact__c = this.contactToTest.Id,
                Primary__c = true
            );
        }
    }

    /**
     * @description Tests handleAfterInsert appropriately calls createProgramEnrollmentIfNecessary
     */
    private static void handleAfterInsertValid() {
        HandleAfterInsertValidData testData = new HandleAfterInsertValidData();
        AFFL_MultiRecordType_TDTM.afflMapper = new AFFL_MultiRecordTypeMapper_STUB(true);
        Formula.recalculateFormulas(new List<Affiliation__c>{ testData.affiliation });

        List<SObject> newList = new List<SObject>();
        newList.add(testData.affiliation);

        Test.startTest();
        TDTM_Runnable.DMLWrapper dmlWrapperReturned = testData.tdtmClass.handleAfterInsert(
            newList,
            testData.dmlWrapper
        );
        Test.stopTest();

        System.assertEquals(
            true,
            testData.tdtmClass.isAfterInsertRecursion(),
            'After insert recursion for should be active for AFFL_MultiRecordType_TDTM.'
        );

        System.assertEquals(
            1,
            dmlWrapperReturned.objectsToInsert.size(),
            'The DMLWrapper should contain a single program enrollment to insert.'
        );

        for (SObject sObjectRetrieved : dmlWrapperReturned.objectsToInsert) {
            Program_Enrollment__c programEnrollment = (Program_Enrollment__c) sObjectRetrieved;

            System.assertEquals(
                testData.affiliation.Account__c,
                programEnrollment.Account__c,
                'The Account of the created Program Enrollment should match the provided Affiliation\'s.'
            );
            System.assertEquals(
                testData.affiliation.Contact__c,
                programEnrollment.Contact__c,
                'The Contact of the created Program Enrollment should match the provided Affiliation\'s.'
            );
            System.assertEquals(
                testData.affiliation.Id,
                programEnrollment.Affiliation__c,
                'The Affiliation of the created Program Enrollment should be the provided Affiliation\'s.'
            );
        }
    }

    /**
     * @description Tests handleAfterInsert appropriately calls createProgramEnrollmentIfNecessary and does not create a Program Enrollment
     */
    private static void handleAfterInsertInvalid() {
        HandleAfterInsertValidData testData = new HandleAfterInsertValidData();
        AFFL_MultiRecordType_TDTM.afflMapper = new AFFL_MultiRecordTypeMapper_STUB(false);
        Formula.recalculateFormulas(new List<Affiliation__c>{ testData.affiliation });

        List<SObject> newList = new List<SObject>();
        newList.add(testData.affiliation);

        Test.startTest();
        TDTM_Runnable.DMLWrapper dmlWrapperReturned = testData.tdtmClass.handleAfterInsert(
            newList,
            testData.dmlWrapper
        );
        Test.stopTest();

        System.assertEquals(
            true,
            testData.tdtmClass.isAfterInsertRecursion(),
            'After insert recursion for should be active for AFFL_MultiRecordType_TDTM.'
        );

        System.assertEquals(true, dmlWrapperReturned.objectsToInsert.isEmpty(), 'The DMLWrapper should be empty.');
    }

    /**
     * @description Tests handleAfterInsert only sets after insert recursion on an empty new list
     */
    private static void handleAfterInsertNewListEmpty() {
        AFFL_MultiRecordType_TDTM tdtmClass = new AFFL_MultiRecordType_TDTM();
        TDTM_Runnable.DmlWrapper dmlWrapper = new TDTM_Runnable.DmlWrapper();

        List<SObject> newList = new List<SObject>();

        Test.startTest();
        TDTM_Runnable.DMLWrapper dmlWrapperReturned = tdtmClass.handleAfterInsert(newList, dmlWrapper);
        Test.stopTest();

        System.assertEquals(
            true,
            tdtmClass.isAfterInsertRecursion(),
            'After insert recursion for should be active for AFFL_MultiRecordType_TDTM.'
        );

        System.assertEquals(true, dmlWrapperReturned.objectsToInsert.isEmpty(), 'The DMLWrapper should be empty.');
    }

    /**
     * @description Tests handleAfterInsert only sets after insert recursion on a null new list
     */
    private static void handleAfterInsertNewListNull() {
        AFFL_MultiRecordType_TDTM tdtmClass = new AFFL_MultiRecordType_TDTM();
        TDTM_Runnable.DmlWrapper dmlWrapper = new TDTM_Runnable.DmlWrapper();

        List<SObject> newList = null;
        tdtmClass.setAfterInsertRecursion();

        Test.startTest();
        TDTM_Runnable.DMLWrapper dmlWrapperReturned = tdtmClass.handleAfterInsert(newList, dmlWrapper);
        Test.stopTest();

        System.assertEquals(true, dmlWrapperReturned.objectsToInsert.isEmpty(), 'The DMLWrapper should be empty.');
    }

    /**
     * @description Tests handleAfterInsert does nothing on an after insert recursion
     */
    private static void handleAfterInsertNewListAfterInsertRecursion() {
        AFFL_MultiRecordType_TDTM tdtmClass = new AFFL_MultiRecordType_TDTM();
        TDTM_Runnable.DmlWrapper dmlWrapper = new TDTM_Runnable.DmlWrapper();

        List<SObject> newList = null;

        Test.startTest();
        TDTM_Runnable.DMLWrapper dmlWrapperReturned = tdtmClass.handleAfterInsert(newList, dmlWrapper);
        Test.stopTest();

        System.assertEquals(
            false,
            tdtmClass.isAfterInsertRecursion(),
            'After insert recursion for should be inactive for AFFL_MultiRecordType_TDTM.'
        );

        System.assertEquals(true, dmlWrapperReturned.objectsToInsert.isEmpty(), 'The DMLWrapper should be empty.');
    }

    /****************************************
     * processAfflDeletedValid
     ****************************************/

    /**
     * @description helper class for initialization of tests for processAfflDeleted
     */
    private class ProcessAfflDeletedValidData {
        public AFFL_MultiRecordType_TDTM tdtmClass;
        public TDTM_Runnable.DmlWrapper dmlWrapper;
        public Id fakeAccountId;
        public String primaryAffiliationFieldAPIName;
        public Contact testContact;
        public Affiliation__c affiliation;

        public ProcessAfflDeletedValidData() {
            this.tdtmClass = new AFFL_MultiRecordType_TDTM();
            this.dmlWrapper = new TDTM_Runnable.DmlWrapper();
            this.primaryAffiliationFieldAPIName = AffiliationTestSetupFactory_TEST.getBusinessOrganizationFieldApiName();
            this.fakeAccountId = UTIL_UnitTestData_TEST.getFakeId(Account.SObjectType);

            Id fakeContactId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
            this.testContact = new Contact(Id = fakeContactId, FirstName = 'Test');
            testContact.put(this.primaryAffiliationFieldAPIName, fakeAccountId);

            this.affiliation = new Affiliation__c(
                Account__c = fakeAccountId,
                Contact__c = fakeContactId,
                Primary__c = true
            );
        }
    }

    /**
     * @description Tests processAfflDeleted appropriately clears the primary affiliation field
     */
    private static void processAfflDeletedValid() {
        ProcessAfflDeletedValidData testData = new ProcessAfflDeletedValidData();

        Test.startTest();
        Contact contactReturned = testData.tdtmClass.processAfflDeleted(
            testData.affiliation,
            testData.testContact,
            testData.primaryAffiliationFieldAPIName,
            testData.dmlWrapper
        );
        Test.stopTest();

        System.assertEquals(
            null,
            contactReturned.get(testData.primaryAffiliationFieldAPIName),
            'Contact Primary Affiliation Field api name should be set to null on deletion.'
        );
        System.assertEquals(
            true,
            testData.dmlWrapper.objectsToUpdate.contains(contactReturned),
            'The Contact should be added to the DMLWrapper.'
        );
    }

    /**
     * @description Tests processAfflDeleted does not run on recursion
     */
    private static void processAfflDeletedRecursion() {
        ProcessAfflDeletedValidData testData = new ProcessAfflDeletedValidData();

        TDTM_ProcessControl.setRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_keyAfflLookupUpdated,
            true
        );

        Test.startTest();
        Contact contactReturned = testData.tdtmClass.processAfflDeleted(
            testData.affiliation,
            testData.testContact,
            testData.primaryAffiliationFieldAPIName,
            testData.dmlWrapper
        );
        Test.stopTest();

        System.assertEquals(null, contactReturned, 'Method should make no changes to the Contact on recursion.');
        System.assertEquals(
            false,
            testData.dmlWrapper.objectsToUpdate.contains(contactReturned),
            'Method should make no changes to the DMLWrapper on recursion.'
        );
    }

    /**
     * @description Tests processAfflDeleted does not run for non-primary affiliations
     */
    private static void processAfflDeletedNonPrimaryAffiliation() {
        ProcessAfflDeletedValidData testData = new ProcessAfflDeletedValidData();
        testData.affiliation.Primary__c = false;

        Test.startTest();
        Contact contactReturned = testData.tdtmClass.processAfflDeleted(
            testData.affiliation,
            testData.testContact,
            testData.primaryAffiliationFieldAPIName,
            testData.dmlWrapper
        );
        Test.stopTest();

        System.assertEquals(
            null,
            contactReturned,
            'Method should make no changes to the Contact on non-primary affiliations.'
        );
        System.assertEquals(
            false,
            testData.dmlWrapper.objectsToUpdate.contains(contactReturned),
            'Method should make no changes to the DMLWrapper on non-primary affiliations.'
        );
    }

    /**
     * @description Tests processAfflDeleted does not run for contacts when a primary affiliation field is not supplied
     */
    private static void processAfflDeletedNullAffiliationField() {
        ProcessAfflDeletedValidData testData = new ProcessAfflDeletedValidData();
        testData.primaryAffiliationFieldAPIName = null;

        Test.startTest();
        Contact contactReturned = testData.tdtmClass.processAfflDeleted(
            testData.affiliation,
            testData.testContact,
            testData.primaryAffiliationFieldAPIName,
            testData.dmlWrapper
        );
        Test.stopTest();

        System.assertEquals(
            null,
            contactReturned,
            'Method should make no changes to the Contact on a null primary affiliation field.'
        );
        System.assertEquals(
            false,
            testData.dmlWrapper.objectsToUpdate.contains(contactReturned),
            'Method should make no changes to the DMLWrapper on a null primary affiliation field.'
        );
    }

    /**
     * @description Tests processAfflDeleted does not run for contacts when the contact is null
     */
    private static void processAfflDeletedNullContact() {
        ProcessAfflDeletedValidData testData = new ProcessAfflDeletedValidData();

        Test.startTest();
        Contact contactReturned = testData.tdtmClass.processAfflDeleted(
            testData.affiliation,
            null,
            testData.primaryAffiliationFieldAPIName,
            testData.dmlWrapper
        );
        Test.stopTest();

        System.assertEquals(null, contactReturned, 'Method should make no changes to the Contact on a null contact.');
        System.assertEquals(
            false,
            testData.dmlWrapper.objectsToUpdate.contains(contactReturned),
            'Method should make no changes to the DMLWrapper on a null contact.'
        );
    }

    /**
     * @description Tests processAfflDeleted does not run for contacts when the affiliation account does not match the contact account
     */
    private static void processAfflDeletedDifferentContactPrimaryAffiliationAccount() {
        ProcessAfflDeletedValidData testData = new ProcessAfflDeletedValidData();
        Id differentFakeAccountId = UTIL_UnitTestData_TEST.getFakeId(Account.SObjectType);
        testData.affiliation = new Affiliation__c(
            Account__c = differentFakeAccountId,
            Contact__c = testData.testContact.Id,
            Primary__c = true
        );

        Test.startTest();
        Contact contactReturned = testData.tdtmClass.processAfflDeleted(
            testData.affiliation,
            testData.testContact,
            testData.primaryAffiliationFieldAPIName,
            testData.dmlWrapper
        );
        Test.stopTest();

        System.assertEquals(
            null,
            contactReturned,
            'Method should make no changes to the Contact on an unmatched account.'
        );
        System.assertEquals(
            false,
            testData.dmlWrapper.objectsToUpdate.contains(contactReturned),
            'Method should make no changes to the DMLWrapper on an unmatched account.'
        );
    }

    /****************************************
     * queryAfflLookupFields
     ****************************************/

    /**
     * @description Tests queryAfflLookupFields for multiple affiliations
     */
    private static void queryAfflLookupFields() {
        AFFL_MultiRecordType_TDTM tdtmClass = new AFFL_MultiRecordType_TDTM();

        //Setup Accounts
        Id businessOrganizationRecordTypeId = UTIL_Describe.getBizAccRecTypeID();
        Id householdAccountId = UTIL_Describe.getCustomHHAccRecTypeID();

        List<Account> businessOrganizationAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            AFFL_MultiRecordType_TEST.numberOfTestRecords,
            businessOrganizationRecordTypeId
        );
        List<Account> householdAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            AFFL_MultiRecordType_TEST.numberOfTestRecords,
            householdAccountId
        );

        List<Account> accountsToInsert = new List<Account>();
        accountsToInsert.addAll(businessOrganizationAccounts);
        accountsToInsert.addAll(householdAccounts);
        //Saving time on the dml operation adds up
        insert accountsToInsert;

        //Setup Contacts
        List<Contact> contactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(
            AFFL_MultiRecordType_TEST.numberOfTestRecords
        );

        for (Integer i = 0; i < AFFL_MultiRecordType_TEST.numberOfTestRecords; i++) {
            Contact contactToInsert = contactList[i];
            contactToInsert.Primary_Household__c = householdAccounts[i].Id;
            contactToInsert.Primary_Organization__c = businessOrganizationAccounts[i].Id;
        }

        insert contactList;
        Map<Id, Contact> insertedContactsByIds = new Map<Id, Contact>(contactList);

        //Mock Affiliations
        List<Affiliation__c> affiliationList = new List<Affiliation__c>();

        for (Integer i = 0; i < AFFL_MultiRecordType_TEST.numberOfTestRecords; i++) {
            Affiliation__c businessAffiliation = new Affiliation__c(
                Contact__c = contactList[i].Id,
                Account__c = businessOrganizationAccounts[i].Id,
                Primary__c = true
            );
            affiliationList.add(businessAffiliation);

            Affiliation__c householdAffiliation = new Affiliation__c(
                Contact__c = contactList[i].Id,
                Account__c = householdAccounts[i].Id,
                Primary__c = true
            );
            affiliationList.add(householdAffiliation);
        }

        List<SObject> affiliationAsSObjectList = affiliationList;

        //Set up affiliation mappings on household and business organization
        //This is done later to cause it not to interfere with our data setup so the unit test detects unexpected behavior better.
        AffiliationTestSetupFactory_TEST.setupMappingsByDevNameAndApiName(false);

        Test.startTest();
        Map<Id, Contact> returnedContactsByIds = tdtmClass.queryAfflLookupFields(affiliationAsSObjectList);
        Test.stopTest();

        System.assertEquals(
            insertedContactsByIds.size(),
            returnedContactsByIds.size(),
            'Number of returned contacts should match the number inserted.'
        );

        for (Contact returnedContact : returnedContactsByIds.values()) {
            Contact insertedContact = insertedContactsByIds.get(returnedContact.Id);

            System.assertNotEquals(null, insertedContact, 'A contact should be returned for each inserted contact.');
            System.assertEquals(
                returnedContact.Primary_Household__c,
                insertedContact.Primary_Household__c,
                'The Primary Household field should be queried and match that of the inserted Contact.'
            );
            System.assertEquals(
                returnedContact.Primary_Organization__c,
                insertedContact.Primary_Organization__c,
                'The Primary Organization field should be queried and match that of the inserted Contact.'
            );
        }
    }

    /****************************************
     * populateKeyAffls
     ****************************************/

    /**
     * @description helper class for initialization of tests for populateKeyAffls
     */
    private class PopulateKeyAfflsValidData {
        public AFFL_MultiRecordType_TDTM tdtmClass;
        public TDTM_Runnable.DmlWrapper dmlWrapper;
        public Id fakeAccountId;
        public String primaryAffiliationFieldAPIName;
        public Contact testContact;
        public Affiliation__c affiliation;

        public PopulateKeyAfflsValidData() {
            this.tdtmClass = new AFFL_MultiRecordType_TDTM();
            this.dmlWrapper = new TDTM_Runnable.DmlWrapper();
            this.primaryAffiliationFieldAPIName = AffiliationTestSetupFactory_TEST.getBusinessOrganizationFieldApiName();
            this.fakeAccountId = UTIL_UnitTestData_TEST.getFakeId(Account.SObjectType);

            Id fakeContactId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
            this.testContact = new Contact(Id = fakeContactId, FirstName = 'Test');
            testContact.put(this.primaryAffiliationFieldAPIName, fakeAccountId);

            this.affiliation = new Affiliation__c(
                Account__c = fakeAccountId,
                Contact__c = fakeContactId,
                Primary__c = true
            );
        }
    }

    /**
     * @description Tests populateKeyAffls appropriately sets the primary affiliation field
     */
    private static void populateKeyAfflsValid() {
        PopulateKeyAfflsValidData testData = new PopulateKeyAfflsValidData();

        Test.startTest();
        Contact contactReturned = testData.tdtmClass.populateKeyAffls(
            testData.affiliation,
            testData.primaryAffiliationFieldAPIName,
            testData.testContact,
            testData.dmlWrapper
        );
        Test.stopTest();

        System.assertEquals(
            testData.affiliation.Account__c,
            (Id) contactReturned.get(testData.primaryAffiliationFieldAPIName),
            'Contact Primary Affiliation Field api name should be set to the Affiliation\'s Account.'
        );
        System.assertEquals(
            true,
            testData.dmlWrapper.objectsToUpdate.contains(contactReturned),
            'The Contact should be added to the DMLWrapper.'
        );
    }

    /**
     * @description Tests populateKeyAffls does not run on recursion
     */
    private static void populateKeyAfflsRecursion() {
        PopulateKeyAfflsValidData testData = new PopulateKeyAfflsValidData();

        TDTM_ProcessControl.setRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_keyAfflLookupUpdated,
            true
        );

        Test.startTest();
        Contact contactReturned = testData.tdtmClass.populateKeyAffls(
            testData.affiliation,
            testData.primaryAffiliationFieldAPIName,
            testData.testContact,
            testData.dmlWrapper
        );
        Test.stopTest();

        System.assertEquals(null, contactReturned, 'Method should make no changes to the Contact on recursion.');
        System.assertEquals(
            false,
            testData.dmlWrapper.objectsToUpdate.contains(contactReturned),
            'Method should make no changes to the DMLWrapper on recursion.'
        );
    }

    /**
     * @description Tests populateKeyAffls does not run for contacts when a primary affiliation field is not supplied
     */
    private static void populateKeyAfflsNullAffiliationField() {
        PopulateKeyAfflsValidData testData = new PopulateKeyAfflsValidData();
        testData.primaryAffiliationFieldAPIName = null;

        Test.startTest();
        Contact contactReturned = testData.tdtmClass.populateKeyAffls(
            testData.affiliation,
            testData.primaryAffiliationFieldAPIName,
            testData.testContact,
            testData.dmlWrapper
        );
        Test.stopTest();

        System.assertEquals(
            null,
            contactReturned,
            'Method should make no changes to the Contact on a null primary affiliation field.'
        );
        System.assertEquals(
            false,
            testData.dmlWrapper.objectsToUpdate.contains(contactReturned),
            'Method should make no changes to the DMLWrapper on a null primary affiliation field.'
        );
    }

    /****************************************
     * uncheckOtherPrimariesSameType
     ****************************************/

    /**
     * @description Tests uncheckOtherPrimariesSameType for multiple affiliations
     */
    private static void uncheckOtherPrimariesSameType() {
        AFFL_MultiRecordType_TDTM tdtmClass = new AFFL_MultiRecordType_TDTM();
        TDTM_Runnable.DmlWrapper dmlWrapper = new TDTM_Runnable.DmlWrapper();

        //Setup Accounts
        Id businessOrganizationRecordTypeId = UTIL_Describe.getBizAccRecTypeID();
        Id householdAccountId = UTIL_Describe.getCustomHHAccRecTypeID();

        List<Account> businessOrganizationAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            AFFL_MultiRecordType_TEST.numberOfTestRecords,
            businessOrganizationRecordTypeId
        );
        List<Account> householdAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            AFFL_MultiRecordType_TEST.numberOfTestRecords,
            householdAccountId
        );

        List<Account> accountsToInsert = new List<Account>();
        accountsToInsert.addAll(businessOrganizationAccounts);
        accountsToInsert.addAll(householdAccounts);
        //Saving time on the dml operation adds up
        insert accountsToInsert;

        //Setup Contacts
        List<Contact> contactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(
            AFFL_MultiRecordType_TEST.numberOfTestRecords
        );

        for (Integer i = 0; i < AFFL_MultiRecordType_TEST.numberOfTestRecords; i++) {
            Contact contactToInsert = contactList[i];
            contactToInsert.Primary_Household__c = householdAccounts[i].Id;
            contactToInsert.Primary_Organization__c = businessOrganizationAccounts[i].Id;
        }

        insert contactList;
        Map<Id, Contact> insertedContactsByIds = new Map<Id, Contact>(contactList);

        //Setup Initial Primary Affiliations
        List<Affiliation__c> oldPrimaryAffiliationList = new List<Affiliation__c>();

        for (Integer i = 0; i < AFFL_MultiRecordType_TEST.numberOfTestRecords; i++) {
            Affiliation__c businessAffiliation = new Affiliation__c(
                Contact__c = contactList[i].Id,
                Account__c = businessOrganizationAccounts[i].Id,
                Primary__c = true
            );
            oldPrimaryAffiliationList.add(businessAffiliation);

            Affiliation__c householdAffiliation = new Affiliation__c(
                Contact__c = contactList[i].Id,
                Account__c = householdAccounts[i].Id,
                Primary__c = true
            );
            oldPrimaryAffiliationList.add(householdAffiliation);
        }
        insert oldPrimaryAffiliationList;
        Map<Id, Affiliation__c> oldPrimaryAffiliationsById = new Map<Id, Affiliation__c>(oldPrimaryAffiliationList);

        //Setup new primary affiliations
        List<Affiliation__c> newPrimaryAffiliationList = new List<Affiliation__c>();

        for (Integer i = 0; i < AFFL_MultiRecordType_TEST.numberOfTestRecords; i++) {
            Integer nextSafeInteger = math.mod(i, 5);
            Affiliation__c businessAffiliation = new Affiliation__c(
                Contact__c = contactList[i].Id,
                Account__c = businessOrganizationAccounts[nextSafeInteger].Id,
                Primary__c = true
            );
            newPrimaryAffiliationList.add(businessAffiliation);

            Affiliation__c householdAffiliation = new Affiliation__c(
                Contact__c = contactList[i].Id,
                Account__c = householdAccounts[nextSafeInteger].Id,
                Primary__c = true
            );
            newPrimaryAffiliationList.add(householdAffiliation);
        }
        //Recalculate formulas in memory!
        Formula.recalculateFormulas(newPrimaryAffiliationList);

        Test.startTest();
        List<Affiliation__c> uncheckedAffiliations = tdtmClass.uncheckOtherPrimariesSameType(
            newPrimaryAffiliationList,
            dmlWrapper
        );
        Test.stopTest();

        System.assertEquals(
            oldPrimaryAffiliationList.size(),
            uncheckedAffiliations.size(),
            'Number of returned affiliations should match the number unchecked.'
        );

        for (Affiliation__c uncheckedAffiliation : uncheckedAffiliations) {
            Affiliation__c originalAffiliation = oldPrimaryAffiliationsById.get(uncheckedAffiliation.Id);
            System.assertNotEquals(null, originalAffiliation, 'Each old primary affiliation should be modified.');
            System.assertEquals(
                false,
                originalAffiliation.Primary__c,
                'Each old primary affiliation should have its Primary field set to false.'
            );
        }
    }

    /****************************************
     * createProgramEnrollmentIfNecessary
     ****************************************/

    /**
     * @description helper class for initialization of tests for createProgramEnrollmentIfNecessary
     */
    private class CreateProgramEnrollmentValidData {
        public AFFL_MultiRecordType_TDTM tdtmClass;
        public TDTM_Runnable.DmlWrapper dmlWrapper;
        public Account accountToTest;
        public Contact contactToTest;
        public Affiliation__c affiliation;

        public CreateProgramEnrollmentValidData() {
            this.tdtmClass = new AFFL_MultiRecordType_TDTM();
            this.dmlWrapper = new TDTM_Runnable.DmlWrapper();
            this.contactToTest = UTIL_UnitTestData_TEST.getUniqueContact(1);
            insert contactToTest;

            Id businessOrganizationRecordTypeId = UTIL_Describe.getBizAccRecTypeID();
            this.accountToTest = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, businessOrganizationRecordTypeId)[0];
            insert this.accountToTest;

            this.affiliation = new Affiliation__c(
                Id = UTIL_UnitTestData_TEST.getFakeId(Affiliation__c.SObjectType),
                Account__c = this.accountToTest.Id,
                Contact__c = this.contactToTest.Id,
                Primary__c = true
            );
        }
    }

    /**
     * @description Tests createProgramEnrollmentIfNecessary for valid data requiring a program enrollment be created
     */
    private static void createProgramEnrollmentIfNecessaryValidData() {
        CreateProgramEnrollmentValidData testData = new CreateProgramEnrollmentValidData();
        AFFL_MultiRecordType_TDTM.afflMapper = new AFFL_MultiRecordTypeMapper_STUB(true);
        Formula.recalculateFormulas(new List<Affiliation__c>{ testData.affiliation });

        Test.startTest();
        Program_Enrollment__c programEnrollmentCreated = testData.tdtmClass.createProgramEnrollmentIfNecessary(
            testData.affiliation,
            testData.dmlWrapper
        );
        Test.stopTest();

        System.assertNotEquals(
            null,
            programEnrollmentCreated,
            'A Program Enrollment should be created for the associated Affiliation.'
        );
        System.assertEquals(
            testData.affiliation.Id,
            programEnrollmentCreated.Affiliation__c,
            'The Program Enrollment\'s Affiliation should match the provided Affiliation\'s.'
        );
        System.assertEquals(
            testData.affiliation.Account__c,
            programEnrollmentCreated.Account__c,
            'The Program Enrollment\'s Account should match the Affiliation\'s.'
        );
        System.assertEquals(
            testData.affiliation.Contact__c,
            programEnrollmentCreated.Contact__c,
            'The Program Enrollment\'s Contact should match the Affiliation\'s.'
        );
    }

    /**
     * @description Tests createProgramEnrollmentIfNecessary for when a Program Enrollment is not needed
     */
    private static void createProgramEnrollmentIfNecessaryNotNeeded() {
        CreateProgramEnrollmentValidData testData = new CreateProgramEnrollmentValidData();
        AFFL_MultiRecordType_TDTM.afflMapper = new AFFL_MultiRecordTypeMapper_STUB(false);
        Formula.recalculateFormulas(new List<Affiliation__c>{ testData.affiliation });

        Test.startTest();
        Program_Enrollment__c programEnrollmentCreated = testData.tdtmClass.createProgramEnrollmentIfNecessary(
            testData.affiliation,
            testData.dmlWrapper
        );
        Test.stopTest();

        System.assertEquals(
            null,
            programEnrollmentCreated,
            'A Program Enrollment should not be created when the mapper specifies it should not.'
        );
    }

    /**
     * @description Tests createProgramEnrollmentIfNecessary for when the affiliation type is null
     */
    private static void createProgramEnrollmentIfNecessaryNoAffiliationType() {
        CreateProgramEnrollmentValidData testData = new CreateProgramEnrollmentValidData();
        AFFL_MultiRecordType_TDTM.afflMapper = new AFFL_MultiRecordTypeMapper_STUB(true);

        Test.startTest();
        Program_Enrollment__c programEnrollmentCreated = testData.tdtmClass.createProgramEnrollmentIfNecessary(
            testData.affiliation,
            testData.dmlWrapper
        );
        Test.stopTest();

        System.assertEquals(
            null,
            programEnrollmentCreated,
            'A Program Enrollment should not be created when the affiliation type is null.'
        );
    }

    /**
     * @description Tests createProgramEnrollmentIfNecessary for when the affiliation is null
     */
    private static void createProgramEnrollmentIfNecessaryNullAffiliation() {
        CreateProgramEnrollmentValidData testData = new CreateProgramEnrollmentValidData();
        AFFL_MultiRecordType_TDTM.afflMapper = new AFFL_MultiRecordTypeMapper_STUB(true);

        Test.startTest();
        Program_Enrollment__c programEnrollmentCreated = testData.tdtmClass.createProgramEnrollmentIfNecessary(
            null,
            testData.dmlWrapper
        );
        Test.stopTest();

        System.assertEquals(
            null,
            programEnrollmentCreated,
            'A Program Enrollment should not be created when the affiliation type is null.'
        );
    }

    /****************************************
     * RECURSION TESTS
     ****************************************/

    /**
     * @description Tests setBeforeInsertRecursion
     */
    @isTest
    static void setBeforeInsertRecursion() {
        AFFL_MultiRecordType_TDTM tdtmClass = new AFFL_MultiRecordType_TDTM();

        Test.startTest();
        tdtmClass.setBeforeInsertRecursion();
        Test.stopTest();

        Boolean beforeInsert = TDTM_ProcessControl.getRecursionFlag(BEFORE_INSERT_RECURSION);

        System.assertEquals(
            true,
            beforeInsert,
            'Before Insert recursion flag should be active for AFFL_MultiRecordType_TDTM.'
        );
    }

    /**
     * @description Tests isBeforeInsertRecursion
     */
    @isTest
    static void isBeforeInsertRecursion() {
        AFFL_MultiRecordType_TDTM tdtmClass = new AFFL_MultiRecordType_TDTM();
        tdtmClass.setBeforeInsertRecursion();

        Test.startTest();
        Boolean beforeInsert = tdtmClass.isBeforeInsertRecursion();
        Test.stopTest();

        System.assertEquals(
            true,
            beforeInsert,
            'Before Insert recursion flag should be active for AFFL_MultiRecordType_TDTM.'
        );
    }

    /**
     * @description Tests unsetBeforeInsertRecursion
     */
    @isTest
    static void unsetBeforeInsertRecursion() {
        AFFL_MultiRecordType_TDTM tdtmClass = new AFFL_MultiRecordType_TDTM();

        tdtmClass.setBeforeInsertRecursion();

        Test.startTest();
        tdtmClass.unsetBeforeInsertRecursion();
        Test.stopTest();

        Boolean beforeInsert = tdtmClass.isBeforeInsertRecursion();

        System.assertEquals(
            false,
            beforeInsert,
            'Before Insert recursion flag should be inactive for AFFL_MultiRecordType_TDTM.'
        );
    }

    /**
     * @description Tests setAfterInsertRecursion
     */
    @isTest
    static void setAfterInsertRecursion() {
        AFFL_MultiRecordType_TDTM tdtmClass = new AFFL_MultiRecordType_TDTM();

        Test.startTest();
        tdtmClass.setAfterInsertRecursion();
        Test.stopTest();

        Boolean afterInsert = TDTM_ProcessControl.getRecursionFlag(AFTER_INSERT_RECURSION);

        System.assertEquals(
            true,
            afterInsert,
            'After Insert recursion flag should be active for AFFL_MultiRecordType_TDTM.'
        );
    }

    /**
     * @description Tests isAfterInsertRecursion
     */
    @isTest
    static void isAfterInsertRecursion() {
        AFFL_MultiRecordType_TDTM tdtmClass = new AFFL_MultiRecordType_TDTM();
        tdtmClass.setAfterInsertRecursion();

        Test.startTest();
        Boolean afterInsert = tdtmClass.isAfterInsertRecursion();
        Test.stopTest();

        System.assertEquals(
            true,
            afterInsert,
            'After Insert recursion flag should be active for AFFL_MultiRecordType_TDTM.'
        );
    }

    /**
     * @description Tests unsetAfterInsertRecursion
     */
    @isTest
    static void unsetAfterInsertRecursion() {
        AFFL_MultiRecordType_TDTM tdtmClass = new AFFL_MultiRecordType_TDTM();

        tdtmClass.setAfterInsertRecursion();

        Test.startTest();
        tdtmClass.unsetAfterInsertRecursion();
        Test.stopTest();

        Boolean afterInsert = tdtmClass.isAfterInsertRecursion();

        System.assertEquals(
            false,
            afterInsert,
            'After Insert recursion flag should be inactive for AFFL_MultiRecordType_TDTM.'
        );
    }

    /**
     * @description Tests setAfterUpdateRecursion
     */
    @isTest
    static void setAfterUpdateRecursion() {
        AFFL_MultiRecordType_TDTM tdtmClass = new AFFL_MultiRecordType_TDTM();

        Test.startTest();
        tdtmClass.setAfterUpdateRecursion();
        Test.stopTest();

        Boolean afterUpdate = TDTM_ProcessControl.getRecursionFlag(AFTER_UPDATE_RECURSION);

        System.assertEquals(
            true,
            afterUpdate,
            'After Update recursion flag should be active for AFFL_MultiRecordType_TDTM.'
        );
    }

    /**
     * @description Tests isAfterUpdateRecursion
     */
    @isTest
    static void isAfterUpdateRecursion() {
        AFFL_MultiRecordType_TDTM tdtmClass = new AFFL_MultiRecordType_TDTM();
        tdtmClass.setAfterUpdateRecursion();

        Test.startTest();
        Boolean afterUpdate = tdtmClass.isAfterUpdateRecursion();
        Test.stopTest();

        System.assertEquals(
            true,
            afterUpdate,
            'After Update recursion flag should be active for AFFL_MultiRecordType_TDTM.'
        );
    }

    /**
     * @description Tests unsetAfterUpdateRecursion
     */
    @isTest
    static void unsetAfterUpdateRecursion() {
        AFFL_MultiRecordType_TDTM tdtmClass = new AFFL_MultiRecordType_TDTM();

        tdtmClass.setAfterUpdateRecursion();

        Test.startTest();
        tdtmClass.unsetAfterUpdateRecursion();
        Test.stopTest();

        Boolean afterUpdate = tdtmClass.isAfterUpdateRecursion();

        System.assertEquals(
            false,
            afterUpdate,
            'After Update recursion flag should be inactive for AFFL_MultiRecordType_TDTM.'
        );
    }

    /**
     * @description Tests setAffiliationMadePrimaryRecursion
     */
    @isTest
    static void setAffiliationMadePrimaryRecursion() {
        AFFL_MultiRecordType_TDTM tdtmClass = new AFFL_MultiRecordType_TDTM();

        Test.startTest();
        tdtmClass.setAffiliationMadePrimaryRecursion();
        Test.stopTest();

        Boolean affiliationMadePrimary = TDTM_ProcessControl.getRecursionFlag(AFFILIATION_MADE_PRIMARY_RECURSION);

        System.assertEquals(
            true,
            affiliationMadePrimary,
            'Affiliation Made Primary recursion flag should be active for AFFL_MultiRecordType_TDTM.'
        );
    }

    /**
     * @description Tests isAffiliationMadePrimaryRecursion
     */
    @isTest
    static void isAffiliationMadePrimaryRecursion() {
        AFFL_MultiRecordType_TDTM tdtmClass = new AFFL_MultiRecordType_TDTM();
        tdtmClass.setAffiliationMadePrimaryRecursion();

        Test.startTest();
        Boolean affiliationMadePrimary = tdtmClass.isAffiliationMadePrimaryRecursion();
        Test.stopTest();

        System.assertEquals(
            true,
            affiliationMadePrimary,
            'Affiliation Made Primary recursion flag should be active for AFFL_MultiRecordType_TDTM.'
        );
    }

    /**
     * @description Tests resetAffiliationMadePrimaryRecursion
     */
    @isTest
    static void resetAffiliationMadePrimaryRecursion() {
        AFFL_MultiRecordType_TDTM tdtmClass = new AFFL_MultiRecordType_TDTM();

        tdtmClass.setAffiliationMadePrimaryRecursion();

        Test.startTest();
        tdtmClass.resetAffiliationMadePrimaryRecursion();
        Test.stopTest();

        Boolean affiliationMadePrimary = tdtmClass.isAffiliationMadePrimaryRecursion();

        System.assertEquals(
            false,
            affiliationMadePrimary,
            'Affiliation Made Primary recursion flag should be inactive for AFFL_MultiRecordType_TDTM.'
        );
    }

    /**
     * @description Tests isContactPrimaryAffiliationUpdatedRecursion
     */
    @isTest
    static void isContactPrimaryAffiliationUpdatedRecursion() {
        AFFL_MultiRecordType_TDTM tdtmClass = new AFFL_MultiRecordType_TDTM();
        TDTM_ProcessControl.setRecursionFlag(CONTACT_PRIMARY_AFFILIATION_UPDATED_RECURSION, true);

        Test.startTest();
        Boolean contactPrimaryAffiliationUpdatedRecursion = tdtmClass.isContactPrimaryAffiliationUpdatedRecursion();
        Test.stopTest();

        System.assertEquals(
            true,
            contactPrimaryAffiliationUpdatedRecursion,
            'Contact Primary Affiliation Updated recursion flag should be active for AFFL_MultiRecordType_TDTM.'
        );
    }

    /**************************************************************************
     * STUBS
     **************************************************************************/

    /**
     * @description Stubs the AFFL_MultiRecordTypeMapper to mock behavior of needsProgramEnrollment
     */
    public class AFFL_MultiRecordTypeMapper_STUB extends AFFL_MultiRecordTypeMapper {
        Boolean programEnrollmentNeeded;

        public AFFL_MultiRecordTypeMapper_STUB(Boolean programEnrollmentNeeded) {
            this.programEnrollmentNeeded = programEnrollmentNeeded;
        }

        public override Boolean needsProgramEnrollment(Affiliation__c affl) {
            return programEnrollmentNeeded;
        }
    }
}
