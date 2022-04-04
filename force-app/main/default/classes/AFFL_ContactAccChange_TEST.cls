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
 * @group Affiliations
 * @group-content ../../ApexDocContent/Affiliations.htm
 * @description Tests specific to changing Contact or Account in an Affiliation.
 */
@isTest
public with sharing class AFFL_ContactAccChange_TEST {
    private static ID orgRecTypeID;
    private static ID householdRecTypeID;
    private static Contact contact1;
    private static Contact contact2;
    private static Account bizOrg1;
    private static Account bizOrg2;
    private static Account householdOrg1;
    private static Affiliation__c bizAffl1;

    public static void resetAfflFlags() {
        TDTM_ProcessControl.resetRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_ContactChange_TDTM);

        TDTM_ProcessControl.resetRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_keyAfflLookupUpdated
        );
        TDTM_ProcessControl.resetRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Insert
        );
        TDTM_ProcessControl.resetRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Update
        );

        TDTM_ProcessControl.resetRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary
        );
        TDTM_ProcessControl.resetRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_Before_Insert
        );
        TDTM_ProcessControl.resetRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_After_Update
        );
    }

    private static void dataSetup() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getHhAccRecTypeID())
        );

        orgRecTypeID = UTIL_Describe_API.getBizAccRecTypeID();
        householdRecTypeID = UTIL_Describe.getHhAccRecTypeID();

        STG_InstallScript.insertMappings();

        contact1 = new Contact(FirstName = 'Test', LastName = 'Testerson');
        contact2 = new Contact(FirstName = 'Test2', LastName = 'Testerson2');
        insert new List<Contact>{ contact1, contact2 };

        //Create accounts of Business Organization record type
        bizOrg1 = new Account(Name = 'Acme', RecordTypeId = orgRecTypeID);
        bizOrg2 = new Account(Name = 'Acme2', RecordTypeId = orgRecTypeID);
        householdOrg1 = new Account(Name = 'AcmeHousehold2', RecordTypeId = householdRecTypeID);
        insert new List<Account>{ bizOrg1, bizOrg2, householdOrg1 };

        //Create primary affiliation
        bizAffl1 = new Affiliation__c(Contact__c = contact1.ID, Account__c = bizOrg1.ID, Primary__c = true);
        resetAfflFlags();
        insert bizAffl1;
    }

    private static void updatePrimaryBizOrgMappings() {
        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        //AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
        //Map<String, String> accRecTypeToContactLabel = afflMapper.accRecTypeToContactLabel;

        for (Affl_Mappings__c mapping : UTIL_CustomSettingsFacade.getAfflMappings()) {
            if (mapping.Primary_Affl_Field__c == 'Primary Business Organization') {
                mapping.Primary_Affl_Field__c = prefix + 'Primary_Organization__c';
            }
            update mapping;
        }
        //afflMapper.populateMaps();
    }

    @isTest
    private static void changeContact() {
        AFFL_ContactAccChange_TEST.dataSetup();
        Account bizAcct = [SELECT Id FROM Account WHERE ID = :bizOrg1.Id];

        //Confirm Primary Business Organization field has been populated in contact
        Contact con1 = [SELECT Primary_Organization__c FROM Contact WHERE ID = :contact1.ID];
        Contact con2 = [SELECT Primary_Organization__c FROM Contact WHERE ID = :contact2.ID];

        Affiliation__c affl1 = [
            SELECT Account__c
            FROM Affiliation__c
            WHERE Contact__c = :con1.ID AND Account__c = :bizAcct.ID
        ];

        System.assertEquals(con1.Primary_Organization__c, affl1.Account__c, 'Primary Org Does Not Match');

        //Update primary affiliation to point to a different contact
        affl1.Contact__c = con2.ID;

        //resetAfflFlags();

        Test.startTest();
        update affl1;
        Test.stopTest();

        //Confirm Primary Business Organization field has been cleared in contact
        Contact updatedContact = [SELECT Primary_Organization__c FROM Contact WHERE ID = :con1.ID];
        System.assertEquals(null, updatedContact.Primary_Organization__c);

        //Confirm Primary Business Organization field has been populated in contact2
        Contact updatedContact2 = [SELECT Primary_Organization__c FROM Contact WHERE ID = :con2.ID];
        System.assertEquals(affl1.Account__c, updatedcontact2.Primary_Organization__c);

        //Make sure we are not creating duplicate affiliations
        List<Affiliation__c> affls = [SELECT Id FROM Affiliation__c];
        System.assertEquals(1, affls.size());
    }

    @isTest
    private static void clearContact() {
        AFFL_ContactAccChange_TEST.dataSetup();
        Contact con = [SELECT Primary_Organization__c FROM Contact WHERE ID = :contact1.Id];
        Account bizAcct = [SELECT Id FROM Account WHERE ID = :bizOrg1.Id];
        Affiliation__c affl1 = [
            SELECT Account__c
            FROM Affiliation__c
            WHERE Contact__c = :con.ID AND Account__c = :bizAcct.ID
        ];

        //Clear contact
        affl1.Contact__c = null;
        Test.startTest();
        update affl1;
        Test.stopTest();

        //Confirm Primary Business Organization field has been cleared in contact
        Contact updatedContact = [SELECT Primary_Organization__c FROM Contact WHERE ID = :con.ID];
        System.assertEquals(null, updatedContact.Primary_Organization__c);
    }

    @isTest
    private static void changeAccountSameType() {
        AFFL_ContactAccChange_TEST.dataSetup();
        Contact con = [SELECT Primary_Organization__c FROM Contact WHERE ID = :contact1.Id];
        Account bizAcct1 = [SELECT Id FROM Account WHERE ID = :bizOrg1.Id];
        Account bizAcct2 = [SELECT Id FROM Account WHERE ID = :bizOrg2.Id];

        Affiliation__c affl1 = [
            SELECT Account__c
            FROM Affiliation__c
            WHERE Contact__c = :con.ID AND Account__c = :bizAcct1.ID
        ];

        //Change affiliation account
        affl1.Account__c = bizAcct2.ID;
        Test.startTest();
        update affl1;
        Test.stopTest();

        //Confirm primary field has been updated
        Contact updatedContact = [SELECT Primary_Organization__c FROM Contact WHERE ID = :con.Id];
        System.assertEquals(bizAcct2.ID, updatedContact.Primary_Organization__c);

        //Make sure we are not creating duplicate affiliations
        List<Affiliation__c> affls = [SELECT Id FROM Affiliation__c];
        System.assertEquals(1, affls.size());
    }

    @isTest
    private static void changeAccountDifferentType() {
        AFFL_ContactAccChange_TEST.dataSetup();
        Contact contact = [SELECT Primary_Organization__c FROM Contact WHERE ID = :contact1.Id];

        Account bizAcct1 = [SELECT Id FROM Account WHERE ID = :bizOrg1.Id];
        Account houseAcct1 = [SELECT Id FROM Account WHERE ID = :householdOrg1.Id];

        //Get primary affiliation
        Affiliation__c affl1 = [
            SELECT Account__c
            FROM Affiliation__c
            WHERE Contact__c = :contact.ID AND Account__c = :bizAcct1.ID
        ];

        //Change affiliation account
        affl1.Account__c = houseAcct1.ID;
        Test.startTest();
        update affl1;
        Test.stopTest();

        //Confirm primary field has been updated
        Contact updatedContact = [
            SELECT Primary_Organization__c, Primary_Household__c
            FROM Contact
            WHERE ID = :contact.ID
        ];
        System.assertEquals(null, updatedContact.Primary_Organization__c);
        System.assertEquals(householdOrg1.ID, updatedContact.Primary_Household__c);

        //Make sure we are not creating duplicate affiliations
        List<Affiliation__c> affls = [SELECT Id FROM Affiliation__c];
        System.assertEquals(1, affls.size());
    }

    @isTest
    private static void clearAccount() {
        AFFL_ContactAccChange_TEST.dataSetup();
        Contact contact = [SELECT Primary_Organization__c FROM Contact WHERE ID = :contact1.Id];
        Account bizAcct1 = [SELECT Id FROM Account WHERE ID = :bizOrg1.Id];
        Affiliation__c affl1 = [
            SELECT Account__c
            FROM Affiliation__c
            WHERE Contact__c = :contact.ID AND Account__c = :bizAcct1.ID
        ];

        //Clear affiliation account
        affl1.Account__c = null;
        Test.startTest();
        update affl1;
        Test.stopTest();

        //Confirm primary field has been cleared
        Contact updatedContact = [SELECT Primary_Organization__c FROM Contact WHERE ID = :contact.ID];
        System.assertEquals(null, updatedContact.Primary_Organization__c);
    }

    /* Test to check there is only one primary affiliation remains when Account on a Primary Affiliation 
       is changed to an Account whose record type is same as an already existing primary affiliations on the Contact
    */
    @isTest
    private static void updateAccToAnExistingAccTypeFromAffiliation() {
        AFFL_ContactAccChange_TEST.dataSetup();

        // Get a contact
        Contact testContact = [SELECT Id, Primary_Organization__c FROM Contact WHERE Id = :contact1.Id];

        // Get the business affiliation to above contact
        Affiliation__c primaryBusinessAfflOnContact = [
            SELECT Account__c
            FROM Affiliation__c
            WHERE Contact__c = :testContact.Id AND Account__c = :bizOrg1.Id
        ];

        // create 1 hh affiliation on the above contact
        Affiliation__c primaryHHAfflOnContact = UTIL_UnitTestData_TEST.getAffiliation(
            contact1.Id,
            householdOrg1.Id,
            true
        );
        insert primaryHHAfflOnContact;

        // update the primaryHHAfflOnContact to buizorg2
        test.startTest();
        primaryHHAfflOnContact.Account__c = bizOrg2.Id;
        update primaryHHAfflOnContact;
        test.stopTest();

        Affiliation__c afflUpdated = [
            SELECT Id, Primary__c
            FROM Affiliation__c
            WHERE Id = :primaryBusinessAfflOnContact.Id
        ];

        Affiliation__c primarHHAffilaitionUpdated = [
            SELECT Id, Primary__c
            FROM Affiliation__c
            WHERE Id = :primaryHHAfflOnContact.Id
        ];

        // Ensure only one of the affiliations is primary
        System.assertEquals(false, afflUpdated.Primary__c);
        System.assertEquals(true, primarHHAffilaitionUpdated.Primary__c);
    }

    /*
     *  Ensure contact primary affiliation updates existing affiliations(Primary).
     *  Test Scenario: T-3938994
     */
    @isTest
    private static void updateExistingContactPrimaryAfflField() {
        AFFL_ContactAccChange_TEST.dataSetup();
        Contact testContact = [SELECT Id, Primary_Organization__c FROM Contact WHERE Id = :contact1.Id];

        // Get the affiliations to above contact
        Integer nonActiveAfflsCount = [
            SELECT COUNT()
            FROM Affiliation__c
            WHERE Contact__c = :testContact.Id AND Primary__c = FALSE
        ];
        Integer activeAfflsCount = [
            SELECT COUNT()
            FROM Affiliation__c
            WHERE Contact__c = :testContact.Id AND Primary__c = TRUE
        ];
        System.assertEquals(1, activeAfflsCount);
        System.assertEquals(0, nonActiveAfflsCount);

        testContact = [SELECT Id, Primary_Organization__c FROM Contact WHERE Id = :contact1.Id];
        System.assertEquals(bizOrg1.Id, testContact.Primary_Organization__c);

        testContact.Primary_Organization__c = bizOrg2.Id;

        test.startTest();
        update testContact;
        test.stopTest();

        // Refresh affiliations for given contact
        nonActiveAfflsCount = [
            SELECT COUNT()
            FROM Affiliation__c
            WHERE Contact__c = :testContact.Id AND Primary__c = FALSE
        ];
        activeAfflsCount = [
            SELECT COUNT()
            FROM Affiliation__c
            WHERE Contact__c = :testContact.Id AND Primary__c = TRUE
        ];
        System.assertEquals(1, activeAfflsCount);
        System.assertEquals(1, nonActiveAfflsCount);
    }

    // Test to check the error when the Organization on an Affiliation is changed to an Account which is a part of Primary Affiliation on the same Contact
    @isTest
    private static void updateAccToAnExistingAcc() {
        AFFL_ContactAccChange_TEST.dataSetup();

        // Get the contact
        Contact testContact = [SELECT Id, Primary_Organization__c FROM Contact WHERE Id = :contact1.Id];

        // Get the primary business affiliation related to the Contact
        Affiliation__c primaryBusinessAfflOnContact = [
            SELECT Account__c
            FROM Affiliation__c
            WHERE Contact__c = :testContact.Id AND Account__c = :bizOrg1.Id
        ];

        // Create a primary household affiliation to the Contact
        Affiliation__c primaryHHAfflOnContact = UTIL_UnitTestData_TEST.getAffiliation(
            contact1.Id,
            householdOrg1.Id,
            true
        );
        insert primaryHHAfflOnContact;

        // Update the Organization on primary household affiliation to a business organization, assert error
        try {
            Test.startTest();
            primaryHHAfflOnContact.Account__c = bizOrg1.Id;
            update primaryHHAfflOnContact;
            Test.stopTest();
            System.assert(
                false,
                'Always throw an error when Account is updated to an Account which is part of other primary affiliation'
            );
        } catch (System.DmlException ex) {
            System.assertEquals(true, ex.getMessage().contains(Label.affiliationWithSameAccExists));
        }
    }

    // Tests createdIdToOtherPrimaryAfflsWithSameAccAndCon method on AFFL_AccChange_TDTM
    @isTest
    private static void createdIdToOtherPrimaryAfflsWithSameAccAndCon() {
        AFFL_ContactAccChange_TEST.dataSetup();

        // Get the contact
        Contact testContact = [SELECT Id, Primary_Organization__c FROM Contact WHERE Id = :contact1.Id];

        // Get the primary business affiliation related to the Contact
        Affiliation__c primaryBusinessAffl1 = [
            SELECT Account__c
            FROM Affiliation__c
            WHERE Contact__c = :testContact.Id AND Account__c = :bizOrg1.Id
        ];

        // Create primary affiliation
        Affiliation__c primaryHHAffl1 = UTIL_UnitTestData_TEST.getAffiliation(testContact.Id, householdOrg1.Id, true);
        insert primaryHHAffl1;

        // Change the Priamry Household instance to Primary Business Organization
        primaryHHAffl1.Account__c = bizOrg1.Id;
        List<Affiliation__c> affiliationList = new List<Affiliation__c>();
        affiliationList.add(primaryHHAffl1);

        Test.startTest();
        AFFL_AccChange_TDTM afflAccChange = new AFFL_AccChange_TDTM();
        Map<Id, List<Affiliation__c>> afflToOtherPrimaryAffiliations = afflAccChange.createdIdToOtherPrimaryAfflsWithSameAccAndCon(
            affiliationList
        );
        Test.stopTest();

        // Ensure there is an element in the returned list
        System.assertEquals(1, afflToOtherPrimaryAffiliations.get(primaryHHAffl1.Id).size());
    }

    // Bulk test createdIdToOtherPrimaryAfflsWithSameAccAndCon method on AFFL_AccChange_TDTM
    @isTest
    private static void createdIdToOtherPrimaryAfflsWithSameAccAndConBulk() {
        AFFL_ContactAccChange_TEST.dataSetup();

        // Get the contacts
        Contact testContact1 = [SELECT Id, Primary_Organization__c FROM Contact WHERE Id = :contact1.Id];
        Contact testContact2 = UTIL_UnitTestData_TEST.getContact();
        insert testContact2;

        // Get the primary business affiliation related to the Contact1
        Affiliation__c primaryBusinessAfflCon1 = [
            SELECT Account__c
            FROM Affiliation__c
            WHERE Contact__c = :testContact1.Id AND Account__c = :bizOrg1.Id
        ];

        List<Affiliation__c> affiliationsToInsert = new List<Affiliation__c>();
        // Create a primary HH affiliation for contact1
        Affiliation__c primaryHHAfflCon1 = new Affiliation__c(
            Contact__c = testContact1.ID,
            Account__c = householdOrg1.ID,
            Primary__c = true
        );
        affiliationsToInsert.add(primaryHHAfflCon1);

        // Create primary affiliation Business for Contact2
        Affiliation__c primaryBusinessAfflCon2 = UTIL_UnitTestData_TEST.getAffiliation(
            testContact2.Id,
            bizOrg1.Id,
            true
        );
        affiliationsToInsert.add(primaryBusinessAfflCon2);

        // Create primary HH affiliation for Conatct2
        Affiliation__c primaryHHAfflCon2 = new Affiliation__c(
            Contact__c = testContact2.ID,
            Account__c = householdOrg1.ID,
            Primary__c = true
        );
        affiliationsToInsert.add(primaryHHAfflCon2);

        insert affiliationsToInsert;

        // Change the Primary Household instance to Primary Business Organization for Conatct1 and Contact2
        primaryHHAfflCon1.Account__c = bizOrg1.Id;
        primaryHHAfflCon2.Account__c = bizOrg1.Id;

        // Add the to be updated affiliations to the list
        List<Affiliation__c> affiliationList = new List<Affiliation__c>();
        affiliationList.add(primaryHHAfflCon1);
        affiliationList.add(primaryHHAfflCon2);

        Test.startTest();
        AFFL_AccChange_TDTM afflAccChange = new AFFL_AccChange_TDTM();
        Map<Id, List<Affiliation__c>> afflToOtherPrimaryAffiliations = afflAccChange.createdIdToOtherPrimaryAfflsWithSameAccAndCon(
            affiliationList
        );
        Test.stopTest();

        // Ensure there is one element in the list for each of the Ids
        System.assertEquals(1, afflToOtherPrimaryAffiliations.get(primaryHHAfflCon1.Id).size());
        System.assertEquals(primaryBusinessAfflCon1.Id, afflToOtherPrimaryAffiliations.get(primaryHHAfflCon1.Id)[0].Id);
        System.assertEquals(1, afflToOtherPrimaryAffiliations.get(primaryHHAfflCon2.Id).size());
        System.assertEquals(primaryBusinessAfflCon2.Id, afflToOtherPrimaryAffiliations.get(primaryHHAfflCon2.Id)[0].Id);
    }

    /* Tests changing the Account on a Primary Affiliation to an Account of the same Record Type when API names are used for 
       'Contact Primary Affl Field ' in Affiliation Mappings will update the Primary Affiliation field on the Contact.
    */

    @isTest
    private static void changeAccountSameTypeWithMappingsWithAPINamesForPrimaryAffl() {
        AFFL_ContactAccChange_TEST.dataSetup();

        // Update Affiliation mapping to use API names for Primary_Affl_Field__c
        AFFL_ContactAccChange_TEST.updatePrimaryBizOrgMappings();

        Contact con = [SELECT Primary_Organization__c FROM Contact WHERE Id = :contact1.Id];
        Account bizAcct1 = [SELECT Id FROM Account WHERE Id = :bizOrg1.Id];
        Account bizAcct2 = [SELECT Id FROM Account WHERE Id = :bizOrg2.Id];

        Affiliation__c affl1 = [
            SELECT Account__c
            FROM Affiliation__c
            WHERE Contact__c = :con.Id AND Account__c = :bizAcct1.Id
        ];

        //Change affiliation account
        Test.startTest();
        affl1.Account__c = bizAcct2.Id;
        update affl1;
        Test.stopTest();

        //Confirm primary field has been updated
        Contact updatedContact = [SELECT Primary_Organization__c FROM Contact WHERE Id = :con.Id];
        System.assertEquals(bizAcct2.Id, updatedContact.Primary_Organization__c);

        //Make sure we are not creating duplicate affiliations
        List<Affiliation__c> affls = [SELECT Id FROM Affiliation__c];
        System.assertEquals(1, affls.size());
    }

    /* Tests changing the Account on a Primary Affiliation to an Account of a different Record Type when API names are used for 
       'Contact Primary Affl Field ' in Affiliation Mappings will update the Primary Affiliation field on the Contact.
    */

    @isTest
    private static void changeAccountDifferentTypeWithMappingsWithAPINamesForPrimaryAffl() {
        AFFL_ContactAccChange_TEST.dataSetup();

        // Update Affiliation mapping to use API names for Primary_Affl_Field__c
        AFFL_ContactAccChange_TEST.updatePrimaryBizOrgMappings();

        Contact contact = [SELECT Primary_Organization__c FROM Contact WHERE Id = :contact1.Id];

        Account bizAcct1 = [SELECT Id FROM Account WHERE Id = :bizOrg1.Id];
        Account houseAcct1 = [SELECT Id FROM Account WHERE Id = :householdOrg1.Id];

        //Get primary affiliation
        Affiliation__c affl1 = [
            SELECT Account__c
            FROM Affiliation__c
            WHERE Contact__c = :contact.Id AND Account__c = :bizAcct1.Id
        ];

        //Change affiliation account
        Test.startTest();
        affl1.Account__c = houseAcct1.Id;
        update affl1;
        Test.stopTest();

        //Confirm primary field has been updated
        Contact updatedContact = [
            SELECT Primary_Organization__c, Primary_Household__c
            FROM Contact
            WHERE ID = :contact.Id
        ];
        System.assertEquals(null, updatedContact.Primary_Organization__c);
        System.assertEquals(householdOrg1.Id, updatedContact.Primary_Household__c);

        //Make sure we are not creating duplicate affiliations
        List<Affiliation__c> affls = [SELECT Id FROM Affiliation__c];
        System.assertEquals(1, affls.size());
    }

    /* Tests clearing the Account on a Primary Affiliation when API names are used for 'Contact Primary Affl Field ' 
       in Affiliation Mappings will also clear the Primary Affiliation field on the Contact. 
    */

    @isTest
    private static void clearAccountWithMappingsWithAPINamesForPrimaryAffl() {
        AFFL_ContactAccChange_TEST.dataSetup();

        // Update Affiliation mapping to use API names for Primary_Affl_Field__c
        AFFL_ContactAccChange_TEST.updatePrimaryBizOrgMappings();

        Contact contact = [SELECT Primary_Organization__c FROM Contact WHERE Id = :contact1.Id];
        Account bizAcct1 = [SELECT Id FROM Account WHERE Id = :bizOrg1.Id];
        Affiliation__c affl1 = [
            SELECT Account__c
            FROM Affiliation__c
            WHERE Contact__c = :contact.Id AND Account__c = :bizAcct1.Id
        ];

        //Clear affiliation account
        Test.startTest();
        affl1.Account__c = null;
        update affl1;
        Test.stopTest();

        //Confirm primary field has been cleared
        Contact updatedContact = [SELECT Primary_Organization__c FROM Contact WHERE Id = :contact.Id];
        System.assertEquals(null, updatedContact.Primary_Organization__c);
    }

    /* Tests clearing the Contact on a Primary Affiliation when API names are used for 'Contact Primary Affl Field ' 
       in Affiliation Mappings will also clear the Primary Affiliation field on the Contact.
    */

    @isTest
    private static void clearContactWithAPINamesForPrimaryAffl() {
        AFFL_ContactAccChange_TEST.dataSetup();

        // Update Affiliation mapping to use API names for Primary_Affl_Field__c
        AFFL_ContactAccChange_TEST.updatePrimaryBizOrgMappings();

        Contact con = [SELECT Primary_Organization__c FROM Contact WHERE Id = :contact1.Id];
        Account bizAcct = [SELECT Id FROM Account WHERE Id = :bizOrg1.Id];
        Affiliation__c affl1 = [
            SELECT Account__c
            FROM Affiliation__c
            WHERE Contact__c = :con.Id AND Account__c = :bizAcct.Id
        ];

        //Clear contact
        Test.startTest();
        affl1.Contact__c = null;
        update affl1;
        Test.stopTest();

        //Confirm Primary Business Organization field has been cleared in contact
        Contact updatedContact = [SELECT Primary_Organization__c FROM Contact WHERE Id = :con.Id];
        System.assertEquals(null, updatedContact.Primary_Organization__c);
    }

    /* Tests changing the Contact on a Primary Affiliation to another Contact when API names are used for 
       'Contact Primary Affl Field' in Affiliation Mappings will updaclear te the Primary Affiliation field on the Contact
       and the value is populated in the new Contact.
    */

    @isTest
    private static void changeContactWithAPINamesForPrimaryAffl() {
        AFFL_ContactAccChange_TEST.dataSetup();

        // Update Affiliation mapping to use API names for Primary_Affl_Field__c
        AFFL_ContactAccChange_TEST.updatePrimaryBizOrgMappings();

        Account bizAcct = [SELECT Id FROM Account WHERE Id = :bizOrg1.Id];

        //Confirm Primary Business Organization field has been populated in contact
        Contact con1 = [SELECT Primary_Organization__c FROM Contact WHERE Id = :contact1.Id];
        Contact con2 = [SELECT Primary_Organization__c FROM Contact WHERE Id = :contact2.Id];

        Affiliation__c affl1 = [
            SELECT Account__c
            FROM Affiliation__c
            WHERE Contact__c = :con1.Id AND Account__c = :bizAcct.Id
        ];

        System.assertEquals(con1.Primary_Organization__c, affl1.Account__c, 'Primary Org Does Not Match');

        //Update primary affiliation to point to a different contact
        Test.startTest();
        affl1.Contact__c = con2.Id;
        update affl1;
        Test.stopTest();

        //Confirm Primary Business Organization field has been cleared in contact
        Contact updatedContact = [SELECT Primary_Organization__c FROM Contact WHERE Id = :con1.Id];
        System.assertEquals(null, updatedContact.Primary_Organization__c);

        //Confirm Primary Business Organization field has been populated in contact2
        Contact updatedContact2 = [SELECT Primary_Organization__c FROM Contact WHERE Id = :con2.Id];
        System.assertEquals(affl1.Account__c, updatedcontact2.Primary_Organization__c);

        //Make sure we are not creating duplicate affiliations
        List<Affiliation__c> affls = [SELECT Id FROM Affiliation__c];
        System.assertEquals(1, affls.size());
    }
}
