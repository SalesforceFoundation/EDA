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

    private static ID orgRecTypeID;
    private static ID householdRecTypeID;

    public static void setup() {
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID()));

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Primary Business Organization'));	
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = 'Primary Household'));
        insert mappings;

        orgRecTypeID = UTIL_Describe_API.getBizAccRecTypeID();
        householdRecTypeID = UTIL_Describe_API.getHhAccRecTypeID();
    }

    @isTest
    private static void createPrimaryAffl() {		
        AFFL_MultiRecordType_TEST.setup();

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Verify default household account has been created for the contact
        contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
        System.assertNotEquals(null, contact.Account.ID);
        System.assertEquals(null, contact.Primary_Household__c);

        //Manually create an Affiliation to the household, since we are not automatically doing so any more
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert new Affiliation__c(Contact__c = contact.ID, Account__c = contact.Account.ID, Primary__c = true);

        //Verify the primary household field was populated
        contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
        System.assertNotEquals(null, contact.Primary_Household__c);

        //Create account of Business Organization record type
        Account bizOrg1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert bizOrg1;

        //Create another key affiliation, this time to a biz org
        Affiliation__c bizAffl1 = new Affiliation__c(Contact__c = contact.ID, Account__c = bizOrg1.ID, Primary__c = true);
        AFFL_ContactAccChange_TEST.resetAfflFlags(); 
        Test.startTest();
        insert bizAffl1;
        Test.stopTest();

        //The business organization lookup should point to the account that is part of the affiliation we created
        bizAffl1 = [select Affiliation_Type__c from Affiliation__c where Account__c = :bizOrg1.ID];
        System.assertEquals('Business Organization', bizAffl1.Affiliation_Type__c);

        contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
        System.assertEquals(bizOrg1.ID, Contact.Primary_Organization__c);

        //Create second account of the same record type
        Account bizOrg2 = new Account(Name='Toys Inc', RecordTypeId = orgRecTypeID);
        insert bizOrg2;

        //Create second primary affiliation
        Affiliation__c bizAffl2 = new Affiliation__c(Contact__c = contact.ID, Account__c = bizOrg2.ID, Primary__c = true);
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert bizAffl2;

        //The previous affiliation should not be the primary any more
        bizAffl1 = [select Primary__c from Affiliation__c where ID = :bizAffl1.ID];
        System.assertEquals(false, bizAffl1.Primary__c);

        //The business organization lookup should point to the account that is part of the second affiliation we created
        contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
        System.assertEquals(bizOrg2.ID, Contact.Primary_Organization__c);

        //  Test addition of a new affiliation with the same Account doesn't erase the Primary field on Contact

        // Insert another primary Affiliaiton on the Contact with same Account 
        Affiliation__c bizAffl3 = new Affiliation__c(Contact__c = contact.Id, Account__c = bizOrg2.ID, Primary__c = true);
        insert bizAffl3;            

        // Verify Primary Buisness Organization on the Contact is not erased         
        Contact updatedContact = [SELECT Id, Primary_Organization__c FROM Contact WHERE Id = :contact.Id]; 
        System.assertEquals(bizOrg2.ID, updatedContact.Primary_Organization__c);  
    }

    @isTest
    private static void noDuplicateAffl() {
        AFFL_MultiRecordType_TEST.setup();

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Create account of Business Organization record type
        Account bizOrg1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert bizOrg1;

        //Create primary affiliation
        Affiliation__c bizAffl1 = new Affiliation__c(Contact__c = contact.ID, Account__c = bizOrg1.ID, Primary__c = true);
        Test.startTest();
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert bizAffl1;
        Test.stopTest();

        //Verify only one Affiliation record to the business account exists. Github #159.
        List<Affiliation__c> affls = [select ID from Affiliation__c where Contact__c = :contact.ID and Account__c = :bizOrg1.ID];
        System.assertEquals(1, affls.size());
    }

    @isTest
    private static void deletePrimaryAffl() {		
        AFFL_MultiRecordType_TEST.setup();

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Verify default household account has been created for the contact
        contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
        System.assertNotEquals(null, contact.Account.ID);
        System.assertEquals(null, contact.Primary_Household__c);

        //Manually create an Affiliation to the household, since we are not automatically doing so any more.
        insert new Affiliation__c(Contact__c = contact.ID, Account__c = contact.Account.ID, Primary__c = true);

        //Verify the primary household field was populated
        contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
        System.assertNotEquals(null, contact.Primary_Household__c);

        //Craete account of Business Organization record type
        Account acc1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert acc1;

        //Create primary Business affiliation
        Affiliation__c affl1 = new Affiliation__c(Contact__c = contact.ID, Account__c = acc1.ID, Primary__c = true);
        Test.startTest();
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert affl1;
        Test.stopTest();

        //Verify Primary Organization lookup field points to the account we just created
        contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
        System.assertEquals(acc1.ID, Contact.Primary_Organization__c);

        //Delete Business affiliation
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        delete affl1;

        //Verify Primary Organization lookup field has been cleared
        contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
        System.assertEquals(null, Contact.Primary_Organization__c);
    }

    @isTest
    private static void makePrimaryAfflNonPrimary() {		
        AFFL_MultiRecordType_TEST.setup();

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Verify default household account has been created for the contact
        contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
        System.assertNotEquals(null, contact.Account.ID);
        ID parentAccountId = contact.Account.ID;
        System.assertEquals(null, contact.Primary_Household__c);

        //Manually create an Affiliation to the household, since we are not automatically doing so any more.
        Affiliation__c affl = new Affiliation__c(Contact__c = contact.ID, Account__c = contact.Account.ID, Primary__c = true);
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert affl;

        //Verify the primary household field was populated
        contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
        System.assertNotEquals(null, contact.Primary_Household__c);

        //Make the affiliation not primary
        affl.Primary__c = false;
        Test.startTest();
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        update affl;
        Test.stopTest();

        //Verify Primary_Household__c field has been cleared
        contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
        System.assertEquals(null, contact.Primary_Household__c);

        //Verify the contact is still the child of the same account
        System.assertEquals(parentAccountId, contact.Account.ID);
    }

    @isTest
    private static void makeNonPrimaryAfflPrimary() {
        AFFL_MultiRecordType_TEST.setup();

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Create account of Business Organization record type
        Account acc1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert acc1;

        //Create non-primary Business affiliation
        Affiliation__c affl1 = new Affiliation__c(Contact__c = contact.ID, Account__c = acc1.ID, Primary__c = false);
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert affl1;

        //Verify Primary Organization lookup field is blank
        contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
        System.assertEquals(null, Contact.Primary_Organization__c);

        //Make the business affiliation primary
        affl1.Primary__c = true;
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        Test.startTest();
        update affl1;
        Test.stopTest();

        //Verify key affl field has been populated
        contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
        System.assertEquals(acc1.ID, Contact.Primary_Organization__c);

        //No other affiliation should have been created (bug W-008631)
        List<Affiliation__c> affls = [select ID from Affiliation__c where Contact__c = :contact.ID];
        System.assertEquals(1, affls.size());
    }

    @isTest
    private static void makeNonPrimaryAfflPrimaryWhenAnotherPrimaryExists() {		
        AFFL_MultiRecordType_TEST.setup();

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Create 2 accounts of Business Organization record type
        Account acc1 = new Account(Name='Acme1', RecordTypeId = orgRecTypeID);
        Account acc2 = new Account(Name='Acme2', RecordTypeId = orgRecTypeID);
        insert new Account[] {acc1, acc2};

        //Create primary Business affiliation
        Affiliation__c affl1 = new Affiliation__c(Contact__c = contact.ID, Account__c = acc1.ID, Primary__c = true);
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert affl1;

        //Verify key affl field has been populated
        contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
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
        List<Affiliation__c> affls = [SELECT Account__c, Primary__c FROM Affiliation__c WHERE Contact__c = :contact.ID ORDER BY Primary__c ASC];
        System.assertEquals(affls[0].Account__c, acc1.ID);
        System.assertEquals(affls[0].Primary__c, false);
        System.assertEquals(affls[1].Account__c, acc2.ID);
        System.assertEquals(affls[1].Primary__c, true);

        //Verify key affl field has been updated
        contact = [SELECT Primary_Organization__c FROM Contact WHERE ID = :contact.ID];
        System.assertEquals(acc2.ID, Contact.Primary_Organization__c);
    }

    @isTest
    private static void createPrimaryAfflWhenAnotherPrimaryExists() {        
        AFFL_MultiRecordType_TEST.setup();

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Create 2 accounts of Business Organization record type
        Account acc1 = new Account(Name='Acme1', RecordTypeId = orgRecTypeID);
        Account acc2 = new Account(Name='Acme2', RecordTypeId = orgRecTypeID);
        insert new Account[] {acc1, acc2};

        //Create primary Business affiliation
        Affiliation__c affl1 = new Affiliation__c(Contact__c = contact.ID, Account__c = acc1.ID, Primary__c = true);
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert affl1;

        //Create second primary Business affiliation
        Affiliation__c affl2 = new Affiliation__c(Contact__c = contact.ID, Account__c = acc2.ID, Primary__c = true);
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        Test.startTest();
        insert affl2;
        Test.stopTest();

        //Verify only one Affiliation record to the second business account exists. Github #177.
        List<Affiliation__c> affls = [select ID from Affiliation__c where Contact__c = :contact.ID and Account__c = :acc2.ID];
        System.assertEquals(1, affls.size());

    }

    @isTest
    private static void autoCreateProgramEnrollment() {		
        AFFL_MultiRecordType_TEST.setup();

        //Turn on Academic Record auto-creation for Business Organization mapping - doesn't make a lot of sense for this type, but just for testing 
        Affl_Mappings__c bizOrgMapping = [select Auto_Program_Enrollment__c from Affl_Mappings__c where Name = 'Business Organization'];
        bizOrgMapping.Auto_Program_Enrollment__c = true;
        bizOrgMapping.Auto_Program_Enrollment_Role__c = 'Student';
        bizOrgMapping.Auto_Program_Enrollment_Status__c = 'Current';
        update bizOrgMapping;

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Craete account of Business Organization record type
        Account acc = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert acc;

        //Create Business affiliation
        Affiliation__c affl = new Affiliation__c(Contact__c = contact.ID, Account__c = acc.ID, Role__c = 'Student', Status__c = 'Current');
        Test.startTest();
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert affl;
        Test.stopTest();

        //Verify Progran Enrollment record has been created
        List<Program_Enrollment__c> programEnrollments = [select ID, Contact__c from Program_Enrollment__c where Affiliation__c = :affl.ID];
        System.assertEquals(1, programEnrollments.size());
        System.assertEquals(contact.ID, programEnrollments[0].Contact__c);
    }

    @isTest
    private static void autoCreateProgramEnrollmentDifferentRole() {
        AFFL_MultiRecordType_TEST.setup();

        //Turn on Academic Record auto-creation for Business Organization mapping - doesn't make a lot of sense for this type, but just for testing
        Affl_Mappings__c bizOrgMapping = [select Auto_Program_Enrollment__c from Affl_Mappings__c where Name = 'Business Organization'];
        bizOrgMapping.Auto_Program_Enrollment__c = true;
        bizOrgMapping.Auto_Program_Enrollment_Role__c = 'Student';
        bizOrgMapping.Auto_Program_Enrollment_Status__c = 'Current';
        update bizOrgMapping;

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Craete account of Business Organization record type
        Account acc = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert acc;

        //Create Business affiliation
        Affiliation__c affl = new Affiliation__c(Contact__c = contact.ID, Account__c = acc.ID, Role__c = 'Teacher', Status__c = 'Current');
        Test.startTest();
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert affl;
        Test.stopTest();

        //Verify Program Enrollment record has not been created
        List<Program_Enrollment__c> programEnrollments = [select ID, Contact__c from Program_Enrollment__c where Affiliation__c = :affl.ID];
        System.assertEquals(0, programEnrollments.size());
    }


/*********************************************************************************************************
* @description
* Enable Affiliation Type Enforcement and make Affiliation-Account mapping mismatch
* Make sure Affiliation is not created and a custom exception is thrown
*/

    @isTest
    private static void incorrectAfflMappingsAfflTypeEnforced() {
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = true));

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organizations', Primary_Affl_Field__c = 'Primary Business Organization'));
        insert mappings;

        List<Account> testAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe.getBizAccRecTypeID());
        insert testAccounts;

        Test.startTest();
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson', Primary_Organization__c = testAccounts[0].Id);
        Database.SaveResult result = Database.insert(contact, false);
        Test.stopTest();

        //Assert
        List<Affiliation__c> assertAffls = [select ID from Affiliation__c];
        System.assertEquals(0, assertAffls.size());

        System.assertEquals(false, result.success);
        System.assertEquals(Label.afflAccoutMappingError, result.errors[0].message);
    }

/*********************************************************************************************************
* @description
* This method ensures there is no NPE when a primay affiliation 
* with no contact is deleted
*/
    @isTest
    private static void affiliationDeleteNPECheck() {        

        AFFL_MultiRecordType_TEST.setup();

        // Insert a business account
        Account bizAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, orgRecTypeID)[0];
        insert bizAcc;

        // Insert a contact
        Contact contact = UTIL_UnitTestData_API.getContact();
        insert contact;

        //Insert a primary affiliation
        Affiliation__c affl = new Affiliation__c(Contact__c = contact.Id, Account__c = bizAcc.Id, Primary__c = true);
        insert affl;

        //Verify 1 affiliation is created
        List<Affiliation__c> affiliationList = [SELECT Id, Name, Contact__c, Primary__c FROM Affiliation__c 
                                                WHERE Contact__c = :contact.Id 
                                                AND Account__c = :bizAcc.Id] ;
                                                
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
        List<Affiliation__c> allAffiliationList = [SELECT Id, Name, Primary__c FROM Affiliation__c 
                                                   WHERE Contact__c = :contact.Id 
                                                   AND Account__c = :bizAcc.Id] ;

        System.assertEquals(0, allAffiliationList.size()); 

    }

/*********************************************************************************************************
* @description
* This method ensures concurrent updates to multiple affiliation records as Primary populates correct  
* Primary fields on related Contact
*/
    @isTest
    private static void multipleAffiliationUpdates() {        

        AFFL_MultiRecordType_TEST.setup();

        // Insert Accounts       
        Account bizAcc1 = UTIL_UnitTestData_API.getMultipleTestAccounts(1, orgRecTypeID)[0];
        Account bizAcc2 = UTIL_UnitTestData_API.getMultipleTestAccounts(1, orgRecTypeID)[0];
        Account hhAcc1 = UTIL_UnitTestData_API.getMultipleTestAccounts(1, householdRecTypeID)[0];
        Account hhAcc2 = UTIL_UnitTestData_API.getMultipleTestAccounts(1, householdRecTypeID)[0];

        insert new Account[] {bizAcc1, bizAcc2, hhAcc1, hhAcc2};

        // Insert a Contact
        Contact contact1 = UTIL_UnitTestData_API.getContact();
        Contact contact2 = UTIL_UnitTestData_API.getContact();
        insert new Contact[] {contact1, contact2};

        //Insert primary and non-primary Affiliations
        Affiliation__c affl1 = UTIL_UnitTestData_TEST.getAffiliation(contact1.Id, bizAcc1.Id, True);
        Affiliation__c affl2 = UTIL_UnitTestData_TEST.getAffiliation(contact1.Id, bizAcc2.Id, False);
        Affiliation__c affl3 = UTIL_UnitTestData_TEST.getAffiliation(contact1.Id, hhAcc1.Id, True);
        Affiliation__c affl4 = UTIL_UnitTestData_TEST.getAffiliation(contact1.Id, hhAcc2.Id, False);

        Affiliation__c affl5 = UTIL_UnitTestData_TEST.getAffiliation(contact2.Id, bizAcc1.Id, True);
        Affiliation__c affl6 = UTIL_UnitTestData_TEST.getAffiliation(contact2.Id, bizAcc2.Id, False);
        Affiliation__c affl7 = UTIL_UnitTestData_TEST.getAffiliation(contact2.Id, hhAcc1.Id, True);
        Affiliation__c affl8 = UTIL_UnitTestData_TEST.getAffiliation(contact2.Id, hhAcc2.Id, False);

        insert new Affiliation__c[] {affl1, affl2, affl3, affl4,
                                     affl5, affl6, affl7, affl8};

        for (Contact eachCon: [SELECT Id, Primary_Organization__c, Primary_Household__c FROM Contact]) {

            // Ensure Primary fields on Contact are populated
            System.assertEquals(eachCon.Primary_Organization__c, bizAcc1.Id);
            System.assertEquals(eachCon.Primary_Household__c, hhAcc1.Id);
        }
        // Make non-primary Affliations as primary
        Test.startTest();
            List<Affiliation__c> afflList = new List<Affiliation__c>();
            for (Affiliation__c eachAffl : [SELECT Id, Primary__c FROM Affiliation__c WHERE Primary__c = False]) {
                eachAffl.Primary__c = True;
                afflList.add(eachAffl);           
            }
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
        for (Affiliation__c eachAffl : [SELECT Id, Primary__c FROM Affiliation__c WHERE (Contact__c = :contact1.Id OR Contact__c = :contact2.Id) AND 
                                        (Account__c = :bizAcc1.Id OR
                                         Account__c = :hhAcc1.Id )]) {                                       
            System.assertEquals(eachAffl.Primary__c, False);
        }                                   
    }

/*********************************************************************************************************
* @description
* This bulk test method ensures Multiple affiliations to the same Business Organization don't
* prevent Primary fields on Contacts from updating
*/

    @isTest
    private static void bulkAffiliationUpdates() { 

        AFFL_MultiRecordType_TEST.setup();

        List<Account> accList = new List<Account>();

        // Insert a Business Account
        Account bizAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, orgRecTypeID)[0];
        accList.add(bizAcc);

        // Insert a Household Account
        Account hhAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, householdRecTypeID)[0];
        accList.add(hhAcc);

        // Insert multiple contacts
        List<Contact> conList = UTIL_UnitTestData_Test.getMultipleTestContacts(3);
        insert conList;

        // Insert 3 Primay Business Affiliations
        List<Affiliation__c> afflList = new List<Affiliation__c>();
        for (Contact each: conList) {
            Affiliation__c affl = UTIL_UnitTestData_TEST.getAffiliation(each.Id, bizAcc.Id, True);
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
        Affiliation__c afflBizAcc = UTIL_UnitTestData_TEST.getAffiliation(contact2.Id, bizAcc.Id, False);
        Affiliation__c afflAcad = UTIL_UnitTestData_TEST.getAffiliation(contact2.Id, hhAcc.Id, TRUE);
        newAfflList.add(afflBizAcc);
        newAfflList.add(afflAcad);
        insert newAfflList;

        // Ensure Primary Organization is NULL and household affiliation is populated
        Contact con = [SELECT Id, Primary_Organization__c, Primary_Household__c FROM Contact WHERE Id = :contact2.Id];
        System.assertEquals(NULL, con.Primary_Organization__c);
        System.assertEquals(hhAcc.Id ,con.Primary_Household__c);

        // Insert Affiliations on the Contacts with the same Account as the Primary Organization
        // Change the Primary Academic Affiliation to non-primary
        test.startTest();
            List<Affiliation__c> afflListNew = new List<Affiliation__c>();
            for (Contact each: conList) {
                Affiliation__c affl1 = UTIL_UnitTestData_TEST.getAffiliation(each.Id, bizAcc.Id, True);
                afflListNew.add(affl1);
            }
            Affiliation__c afflBiz = UTIL_UnitTestData_TEST.getAffiliation(contact2.Id, bizAcc.Id, True);
            Affiliation__c hhAffl1 = UTIL_UnitTestData_TEST.getAffiliation(contact2.Id, hhAcc.Id, TRUE);
            Affiliation__c hhAffl2 = UTIL_UnitTestData_TEST.getAffiliation(contact2.Id, hhAcc.Id, False);
            afflListNew.add(hhAffl1);
            afflListNew.add(hhAffl2);
            afflListNew.add(afflBiz);

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

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = ( String.isNotBlank(namespace) ) ? namespace + '__' : '';

        // insert custom api field name as an affiliation mapping    
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = prefix + 'Primary_Organization__c'));
        insert mappings;

        orgRecTypeID = UTIL_Describe_API.getBizAccRecTypeID();

        // Insert a business account
        Account bizAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, orgRecTypeID)[0];
        insert bizAcc;

        // Insert a contact with business account as Primary business organization
        Contact contact = UTIL_UnitTestData_API.getContact();
        insert contact;           

        test.startTest(); 
            //Insert an affiliation
            Affiliation__c affl = new Affiliation__c(Contact__c = contact.Id, Account__c = bizAcc.Id, Primary__c = true);
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

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = ( String.isNotBlank(namespace) ) ? namespace + '__' : '';

        // Insert custom api field name as an affiliation mapping
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = prefix + 'Primary_Organization__c'));
        insert mappings;

        orgRecTypeID = UTIL_Describe_API.getBizAccRecTypeID();

        // Insert a business account
        Account bizAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, orgRecTypeID)[0];
        insert bizAcc;

        // Insert a contact with business account as Primary business organization
        Contact contact = UTIL_UnitTestData_API.getContact();
        insert contact;

        // Insert an affiliation
        Affiliation__c affiliation = new Affiliation__c(Contact__c = contact.Id, Account__c = bizAcc.Id, Primary__c = true);
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

        // Insert custom api field name as an affiliation mapping    
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business_Organization', Primary_Affl_Field__c = 'Primary Business Organization'));
        insert mappings;

        orgRecTypeID = UTIL_Describe_API.getBizAccRecTypeID();

        // Insert a business account
        Account bizAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, orgRecTypeID)[0];
        insert bizAcc;

        // Insert a contact with business account as Primary business organization
        Contact contact = UTIL_UnitTestData_API.getContact();
        insert contact;

        // Insert an affiliation
        Affiliation__c affiliation = new Affiliation__c(Contact__c = contact.Id, Account__c = bizAcc.Id, Primary__c = true);
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

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = ( String.isNotBlank(namespace) ) ? namespace + '__' : '';

        // Insert custom api field name as an affiliation mapping
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business_Organization', Primary_Affl_Field__c = prefix + 'Primary_Organization__c'));
        insert mappings;

        orgRecTypeID = UTIL_Describe_API.getBizAccRecTypeID();

        // Insert a business account
        Account bizAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, orgRecTypeID)[0];
        insert bizAcc;

        // Insert a contact with business account as Primary business organization
        Contact contact = UTIL_UnitTestData_API.getContact();
        insert contact;

        // Insert an affiliation
        Affiliation__c affiliation = new Affiliation__c(Contact__c = contact.Id, Account__c = bizAcc.Id, Primary__c = true);
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

    // Test getPrimaryAffiliationLookupAPIFromAffiliationType method of AFFL_MultiRecordTypeMapper
    @isTest
    private static void getPrimaryAffiliationLookupAPIFromAffiliationTypeTest() {

        AFFL_MultiRecordType_TEST.setup();

        Test.startTest();
            AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
            String primaryAfflLookupAPIName = afflMapper.getPrimaryAffiliationLookupAPIFromAffiliationType('Business Organization');
        Test.stopTest();

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = ( String.isNotBlank(namespace) ) ? namespace + '__' : '';

        System.assertEquals(prefix + 'Primary_Organization__c', primaryAfflLookupAPIName);

    }

    // Negative test for getPrimaryAffiliationLookupAPIFromAffiliationType method of AFFL_MultiRecordTypeMapper
    @isTest
    private static void getPrimaryAffiliationLookupAPIFromAffiliationTypeNegativeTest() {

        AFFL_MultiRecordType_TEST.setup();

        Test.startTest();
            AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
            String primaryAfflLookupAPIName = afflMapper.getPrimaryAffiliationLookupAPIFromAffiliationType('Test Organization xyz');
        Test.stopTest();

        System.assertEquals(null, primaryAfflLookupAPIName);
    }

    // Null test for getPrimaryAffiliationLookupAPIFromAffiliationType method of AFFL_MultiRecordTypeMapper
    @isTest
    private static void getPrimaryAffiliationLookupAPIFromAffiliationTypeNullTest() {

        AFFL_MultiRecordType_TEST.setup();

        Test.startTest();
            AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
            String primaryAfflLookupAPIName = afflMapper.getPrimaryAffiliationLookupAPIFromAffiliationType(null);
        Test.stopTest();

        System.assertEquals(null, primaryAfflLookupAPIName);

    }

    // Positive test for getContactFieldFromSettings method of AFFL_MultiRecordTypeMapper
    @isTest
    private static void getContactFieldFromSettingsPoitiveTest() {

        AFFL_MultiRecordType_TEST.setup();

        Test.startTest();
            AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
            String contactFieldFromSettings = afflMapper.getContactFieldFromSettings('Business Organization');
        Test.stopTest();

        System.assertEquals('Primary Business Organization', contactFieldFromSettings);

    }
    
    // Negative test for getContactFieldFromSettings method of AFFL_MultiRecordTypeMapper
    @isTest
    private static void getContactFieldFromSettingsNegativeTest() {

        AFFL_MultiRecordType_TEST.setup();

        Test.startTest();
            AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
            String contactFieldFromSettings = afflMapper.getContactFieldFromSettings('Test1234');
        Test.stopTest();

        System.assertEquals(null, contactFieldFromSettings);

    }

    // Positive test for getPrimaryAffiliationLookupAPI method of AFFL_MultiRecordTypeMapper using Label name
    @isTest
    private static void getPrimaryAffiliationLookupAPIPoitiveLabelTest() {

        AFFL_MultiRecordType_TEST.setup();

        Test.startTest();
            AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
            String primaryAfflLookupAPIName = afflMapper.getPrimaryAffiliationLookupAPI('Primary Business Organization');
        Test.stopTest();
        
        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';
        
        System.assertEquals(prefix + 'Primary_Organization__c', primaryAfflLookupAPIName);
       
    }
    
    // Positive test for getPrimaryAffiliationLookupAPI method of AFFL_MultiRecordTypeMapper using API name
    @isTest
    private static void getPrimaryAffiliationLookupAPIPoitiveAPITest() {

        AFFL_MultiRecordType_TEST.setup();
        
        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';
        String lookupAPI = prefix + 'Primary_Organization__c';

        Test.startTest();
            AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
            String primaryAfflLookupAPIName = afflMapper.getPrimaryAffiliationLookupAPI(lookupAPI);
        Test.stopTest();

        
        System.assertEquals(prefix + 'Primary_Organization__c', primaryAfflLookupAPIName);
       
    }
    
    // Negative test for getPrimaryAffiliationLookupAPI method of AFFL_MultiRecordTypeMapper
    @isTest
    private static void getPrimaryAffiliationLookupAPINegativeTest() {

        AFFL_MultiRecordType_TEST.setup();

        Test.startTest();
            AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
            String primaryAfflLookupAPIName = afflMapper.getPrimaryAffiliationLookupAPI('Test1234');
        Test.stopTest();

        System.assertEquals(null, primaryAfflLookupAPIName);
       
    }

}
