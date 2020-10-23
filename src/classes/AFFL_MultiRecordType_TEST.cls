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

/**************************************************************************
* SETUP
**************************************************************************/

    /**************************************************************************
    * @description Sets up hierarchy settings and affiliation mappings for
    * tests using record type name and contact field api name
    * @return The affiliation mapping wrappers set up for the tests.
    **************************************************************************/
    public static List<AffiliationMappingWrapper> setupMappingsByDevNameAndApiName() {
        List<AffiliationMappingWrapper> affiliationMappingWrapperList =
            AFFL_MultiRecordType_TEST.getAfflMappingWrapperByDevNameAndApiName();

        return AFFL_MultiRecordType_TEST.commonSetup(affiliationMappingWrapperList);
    }

    /**************************************************************************
    * @description Sets up hierarchy settings and affiliation mappings for
    * tests using record type name and contact field label
    * @return The affiliation mapping wrappers set up for the tests.
    **************************************************************************/
    public static List<AffiliationMappingWrapper> setupMappingsByDevNameAndLabel() {
        List<AffiliationMappingWrapper> affiliationMappingWrapperList =
            AFFL_MultiRecordType_TEST.getAfflMappingWrapperByDevNameAndLabel();

        return AFFL_MultiRecordType_TEST.commonSetup(affiliationMappingWrapperList);
    }

    /**************************************************************************
    * @description Sets up hierarchy settings and affiliation mappings for
    * tests using record type name and contact field api name
    * @return The affiliation mapping wrappers set up for the tests.
    **************************************************************************/
    public static List<AffiliationMappingWrapper> setupMappingsByNameAndApiName() {
        List<AffiliationMappingWrapper> affiliationMappingWrapperList =
            AFFL_MultiRecordType_TEST.getAfflMappingWrapperByNameAndApiName();

        return AFFL_MultiRecordType_TEST.commonSetup(affiliationMappingWrapperList);
    }

    /**************************************************************************
    * @description Sets up hierarchy settings and affiliation mappings for
    * tests using record type name and contact field label
    * @return The affiliation mapping wrappers set up for the tests.
    **************************************************************************/
    public static List<AffiliationMappingWrapper> setupMappingsByNameAndLabel() {
        List<AffiliationMappingWrapper> affiliationMappingWrapperList =
            AFFL_MultiRecordType_TEST.getAfflMappingWrapperByNameAndLabel();

        return AFFL_MultiRecordType_TEST.commonSetup(affiliationMappingWrapperList);
    }

    /**************************************************************************
    * @description Sets up hierarchy settings and affiliation mappings for
    * tests using provided affiliation wrapper mappings common to all setup
    * scenarios
    * @param affiliationMappingWrapperList The wrapper mappings to set up
    * the test with
    * @return The affiliation mapping wrappers set up for the tests.
    **************************************************************************/
    private static List<AffiliationMappingWrapper> commonSetup(
        List<AffiliationMappingWrapper> affiliationMappingWrapperList
    ) {
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(
            Account_Processor__c = affiliationMappingWrapperList[0].getAccountRecordTypeId()
        ));

        affiliationMappingWrapperList = AFFL_MultiRecordType_TEST.populateRecordTypeNamesForWrappers(
            affiliationMappingWrapperList
        );

        insert AFFL_MultiRecordType_TEST.createAffiliationMappings(
            affiliationMappingWrapperList
        );

        return affiliationMappingWrapperList;
    }

    /**************************************************************************
    * @description Gets the account record type developer name to contact field
    * api name wrappers for test setup and sets old id values for backward
    * compatibility
    * @return the list of account record type to contact label pairings to use
    * for further setup with the intended record type id for the account
    * processor as the first element.
    **************************************************************************/
    private static List<AfflMappingWrapperByDevNameAndApiName> getAfflMappingWrapperByDevNameAndApiName() {
        List<AfflMappingWrapperByDevNameAndApiName> wrapperList =
            new List<AfflMappingWrapperByDevNameAndApiName>();

        List<String> contactPrimaryAffiliationFieldApiNameList = 
            AFFL_MultiRecordType_TEST.getContactPrimaryAffiliationFieldApiNames();

        wrapperList.add(
            new AfflMappingWrapperByDevNameAndApiName(
                UTIL_Describe_API.getHhAccRecTypeID(),
                contactPrimaryAffiliationFieldApiNameList[0]
            )
        );

        wrapperList.add(
            new AfflMappingWrapperByDevNameAndApiName(
                UTIL_Describe_API.getBizAccRecTypeID(),
                contactPrimaryAffiliationFieldApiNameList[1]
            )
        );

        return wrapperList;
    }

    /**************************************************************************
    * @description Gets the account record type developer name to contact label
    * wrappers for test setup and sets old id values for backward compatibility
    * @return the list of account record type to contact label pairings to use
    * for further setup with the intended record type id for the account
    * processor ashe first element.
    **************************************************************************/
    private static List<AfflMappingWrapperByDevNameAndLabel> getAfflMappingWrapperByDevNameAndLabel() {
        List<AfflMappingWrapperByDevNameAndLabel> wrapperList =
            new List<AfflMappingWrapperByDevNameAndLabel>();

        List<String> contactPrimaryAffiliationFieldNameList = 
            AFFL_MultiRecordType_TEST.getContactPrimaryAffiliationFieldLabels();

        wrapperList.add(
            new AfflMappingWrapperByDevNameAndLabel(
                UTIL_Describe_API.getHhAccRecTypeID(),
                contactPrimaryAffiliationFieldNameList[0]
            )
        );

        wrapperList.add(
            new AfflMappingWrapperByDevNameAndLabel(
                UTIL_Describe_API.getBizAccRecTypeID(),
                contactPrimaryAffiliationFieldNameList[1]
            )
        );

        return wrapperList;
    }

    /**************************************************************************
    * @description Gets the account record type name to contact field api name
    * wrappers for test setup and sets old id values for backward compatibility
    * @return the list of account record type to contact label pairings to use
    * for further setup with the intended record type id for the account
    * processor as the first element.
    **************************************************************************/
    private static List<AfflMappingWrapperByNameAndApiName> getAfflMappingWrapperByNameAndApiName() {
        List<AfflMappingWrapperByNameAndApiName> wrapperList =
            new List<AfflMappingWrapperByNameAndApiName>();

        List<String> contactPrimaryAffiliationFieldApiNameList = 
            AFFL_MultiRecordType_TEST.getContactPrimaryAffiliationFieldApiNames();

        wrapperList.add(
            new AfflMappingWrapperByNameAndApiName(
                UTIL_Describe_API.getHhAccRecTypeID(),
                contactPrimaryAffiliationFieldApiNameList[0]
            )
        );

        wrapperList.add(
            new AfflMappingWrapperByNameAndApiName(
                UTIL_Describe_API.getBizAccRecTypeID(),
                contactPrimaryAffiliationFieldApiNameList[1]
            )
        );

        return wrapperList;
    }

    /**************************************************************************
    * @description Gets the account record type name to contact label wrappers
    * for test setup and sets old id values for backward compatibility
    * @return the list of account record type to contact label pairings to use
    * for further setup with the intended record type id for the account
    * processor ashe first element.
    **************************************************************************/
    private static List<AfflMappingWrapperByNameAndLabel> getAfflMappingWrapperByNameAndLabel() {
        List<AfflMappingWrapperByNameAndLabel> wrapperList =
            new List<AfflMappingWrapperByNameAndLabel>();

        List<String> contactPrimaryAffiliationFieldNameList = 
            AFFL_MultiRecordType_TEST.getContactPrimaryAffiliationFieldLabels();

        wrapperList.add(
            new AfflMappingWrapperByNameAndLabel(
                UTIL_Describe_API.getHhAccRecTypeID(),
                contactPrimaryAffiliationFieldNameList[0]
            )
        );

        wrapperList.add(
            new AfflMappingWrapperByNameAndLabel(
                UTIL_Describe_API.getBizAccRecTypeID(),
                contactPrimaryAffiliationFieldNameList[1]
            )
        );

        return wrapperList;
    }

    /**************************************************************************
    * @description Initializes the mappings based on the affiliation mapping
    * wrappers passed to it
    * @param affiliationMappingWrapperList The list of account record type ids to get
    * mappings for.
    * @return The List of Affiliation Mappings to insert.
    **************************************************************************/
    private static List<AffiliationMappingWrapper> populateRecordTypeNamesForWrappers(
        List<AffiliationMappingWrapper> affiliationMappingWrapperList
    ) {
        System.assertEquals(false, affiliationMappingWrapperList.size() < 2,
            '2 Account Record Types were not found for affiliation mappings');
            
        Map<Id, Schema.RecordTypeInfo> accountRecordTypeInfosByIds =
            AFFL_MultiRecordType_TEST.getIdToAccountRecordTypesMap();

        for(AffiliationMappingWrapper affiliationMappingWrapper : affiliationMappingWrapperList) {
            affiliationMappingWrapper.setRecordTypeNamesFromId(accountRecordTypeInfosByIds);
        }

        return affiliationMappingWrapperList;
    }

    /**************************************************************************
    * @description Get record type infos for an account
    * @return The List of Affiliation Mappings to insert.
    **************************************************************************/
    private static Map<Id, Schema.RecordTypeInfo> getIdToAccountRecordTypesMap() {
        Schema.DescribeSObjectResult accountDescribe =
            UTIL_Describe.getObjectDescribe('Account');

        return accountDescribe.getRecordTypeInfosByID();
    }

    /**************************************************************************
    * @description Creates affiliation mappings from wrappers, setting the
    * related mapping to the wrapper for later reference
    * @param affiliationMappingWrapperList The list of mapping wrappers to
    * create mappings for
    * @return The affiliation mappings created 
    **************************************************************************/
    private static List<Affl_Mappings__c> createAffiliationMappings(
        List<AffiliationMappingWrapper> affiliationMappingWrapperList
    ) {
        List<Affl_Mappings__c> affiliationMappingSettings = new List<Affl_Mappings__c>();

        for(AffiliationMappingWrapper affiliationMappingWrapper : affiliationMappingWrapperList) {
            affiliationMappingWrapper.setAffiliationMapping();
            affiliationMappingSettings.add(
                affiliationMappingWrapper.getAffiliationMapping()
            );
        }

        return affiliationMappingSettings;
    }

/**************************************************************************
* UTILITIES
**************************************************************************/



    /**************************************************************************
    * @description Gets the contact primary affiliation field labels with the 
    * household field as the first index and the business organization field
    * as the second index
    * @return the list of contact primary affiliation field labels
    **************************************************************************/
    private static List<String> getContactPrimaryAffiliationFieldLabels() {
        List<String> fieldLabelList = new List<String>();

        fieldLabelList.add(
            AFFL_MultiRecordType_TEST.getHouseholdFieldLabel()
        );
        fieldLabelList.add(
            AFFL_MultiRecordType_TEST.getBusinessOrganizationFieldLabel()
        );

        return fieldLabelList;
    }

    /**************************************************************************
    * @description Gets the contact primary affiliation field label for
    * Business Organization
    * @return the contact primary affiliation field labels for Business
    * Organization
    **************************************************************************/
    private static String getBusinessOrganizationFieldLabel() {
        return 'Primary Business Organization';
    }

    /**************************************************************************
    * @description Gets the contact primary affiliation field labels for
    * Household
    * @return the contact primary affiliation field labels for Household
    **************************************************************************/
    private static String getHouseholdFieldLabel() {
        return 'Primary Household';
    }

    /**************************************************************************
    * @description Gets the contact primary affiliation namespaced api names
    * with the household field as the first index and the business
    * organization field as the second index
    * @return the list of contact primary affiliation local field names
    **************************************************************************/
    private static List<String> getContactPrimaryAffiliationFieldApiNames() {
        List<String> fieldApiNameList = new List<String>();

        fieldApiNameList.add(
            AFFL_MultiRecordType_TEST.getHouseholdFieldApiName()
        );
        fieldApiNameList.add(
            AFFL_MultiRecordType_TEST.getBusinessOrganizationFieldApiName()
        );
        
        return fieldApiNameList;
    }

    /**************************************************************************
    * @description Gets the contact primary affiliation field api name for
    * Business Organization
    * @return the contact primary affiliation field api name for Business
    * Organization
    **************************************************************************/
    private static String getBusinessOrganizationFieldApiName() {
        return UTIL_Namespace.StrTokenNSPrefix('Primary_Organization__c');
    }

    /**************************************************************************
    * @description Gets the contact primary affiliation field api name for
    * Household
    * @return the contact primary affiliation field api name for Household
    **************************************************************************/
    private static String getHouseholdFieldApiName() {
        return UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c');
    }

    /**************************************************************************
    * @description Enables affiliation record type enforcement to true,
    * assuming settings have been initialized. Leverages caching of the
    * settings.
    **************************************************************************/
    private static void enableAffiliationRecordTypeEnforcement() {
        UTIL_CustomSettings_API.getSettings().Affiliation_Record_Type_Enforced__c = true;
    }

/**************************************************************************
* TESTS
**************************************************************************/
    private static void createPrimaryAffl() {		
        List<AffiliationMappingWrapper> affiliationMappingWrapperList =
            AFFL_MultiRecordType_TEST.setupMappingsByNameAndLabel();
        String bizOrgAcctName = affiliationMappingWrapperList[1].getAccountRecordTypeName();

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
        Account bizOrg1 = new Account(Name='Acme', RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());
        insert bizOrg1;

        //Create another key affiliation, this time to a biz org
        Affiliation__c bizAffl1 = new Affiliation__c(Contact__c = contact.ID, Account__c = bizOrg1.ID, Primary__c = true);
        AFFL_ContactAccChange_TEST.resetAfflFlags(); 
        Test.startTest();
        insert bizAffl1;
        Test.stopTest();

        //The business organization lookup should point to the account that is part of the affiliation we created
        bizAffl1 = [SELECT Affiliation_Type__c FROM Affiliation__c WHERE Account__c = :bizOrg1.ID];
        System.assertEquals(bizOrgAcctName, bizAffl1.Affiliation_Type__c);

        contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
        System.assertEquals(bizOrg1.ID, Contact.Primary_Organization__c);

        //Create second account of the same record type
        Account bizOrg2 = new Account(Name='Toys Inc', RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());
        insert bizOrg2;

        //Create second primary affiliation
        Affiliation__c bizAffl2 = new Affiliation__c(Contact__c = contact.ID, Account__c = bizOrg2.ID, Primary__c = true);
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        insert bizAffl2;

        //The previous affiliation should not be the primary any more
        bizAffl1 = [SELECT Primary__c FROM Affiliation__c WHERE ID = :bizAffl1.ID];
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
        AFFL_MultiRecordType_TEST.setupMappingsByNameAndLabel();

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Create account of Business Organization record type
        Account bizOrg1 = new Account(Name='Acme', RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());
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
        AFFL_MultiRecordType_TEST.setupMappingsByNameAndLabel();

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
        Account acc1 = new Account(Name='Acme', RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());
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
        AFFL_MultiRecordType_TEST.setupMappingsByNameAndLabel();

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
        AFFL_MultiRecordType_TEST.setupMappingsByNameAndLabel();

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Create account of Business Organization record type
        Account acc1 = new Account(Name='Acme', RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());
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
        AFFL_MultiRecordType_TEST.setupMappingsByNameAndLabel();

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Create 2 accounts of Business Organization record type
        Account acc1 = new Account(Name='Acme1', RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());
        Account acc2 = new Account(Name='Acme2', RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());
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
        AFFL_MultiRecordType_TEST.setupMappingsByNameAndLabel();

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Create 2 accounts of Business Organization record type
        Account acc1 = new Account(Name='Acme1', RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());
        Account acc2 = new Account(Name='Acme2', RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());
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
        List<AffiliationMappingWrapper> affiliationMappingWrapperList =
            AFFL_MultiRecordType_TEST.setupMappingsByNameAndLabel();

        AffiliationMappingWrapper bizOrgMappingWrapper = affiliationMappingWrapperList[1];
        String bizOrgRecordTypeName = bizOrgMappingWrapper.getAccountRecordTypeName();

        //Turn on Academic Record auto-creation for Business Organization mapping, which we are using as an arbitrary record type for testing.
        Affl_Mappings__c bizOrgMapping = bizOrgMappingWrapper.getAffiliationMapping();
        bizOrgMapping.Auto_Program_Enrollment__c = true;
        bizOrgMapping.Auto_Program_Enrollment_Role__c = 'Student';
        bizOrgMapping.Auto_Program_Enrollment_Status__c = 'Current';
        update bizOrgMapping;

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Craete account of Business Organization record type
        Account acc = new Account(Name='Acme', RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());
        insert acc;

        //Create Business affiliation
        Affiliation__c affl = new Affiliation__c(Contact__c = contact.ID, Account__c = acc.ID, Role__c = 'Student', Status__c = 'Current');

        Test.startTest();
            AFFL_ContactAccChange_TEST.resetAfflFlags();
            insert affl;
        Test.stopTest();
        //Verify Progran Enrollment record has been created
        List<Program_Enrollment__c> programEnrollments = [SELECT ID, Contact__c FROM Program_Enrollment__c WHERE Affiliation__c = :affl.ID];
        System.assertEquals(1, programEnrollments.size());
        System.assertEquals(contact.ID, programEnrollments[0].Contact__c);
    }

    @isTest
    private static void autoCreateProgramEnrollmentDifferentRole() {
        List<AffiliationMappingWrapper> affiliationMappingWrapperList =
            AFFL_MultiRecordType_TEST.setupMappingsByNameAndLabel();

        AffiliationMappingWrapper bizOrgMappingWrapper = affiliationMappingWrapperList[1];
        String bizOrgRecordTypeName = bizOrgMappingWrapper.getAccountRecordTypeName();

        //Turn on Academic Record auto-creation for Business Organization mapping, which we are using as an arbitrary record type for testing.
        Affl_Mappings__c bizOrgMapping = bizOrgMappingWrapper.getAffiliationMapping();
        bizOrgMapping.Auto_Program_Enrollment__c = true;
        bizOrgMapping.Auto_Program_Enrollment_Role__c = 'Student';
        bizOrgMapping.Auto_Program_Enrollment_Status__c = 'Current';
        update bizOrgMapping;

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Craete account of Business Organization record type
        Account acc = new Account(Name='Acme', RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());
        insert acc;

        //Create Business affiliation
        Affiliation__c affl = new Affiliation__c(Contact__c = contact.ID, Account__c = acc.ID, Role__c = 'Teacher', Status__c = 'Current');

        Test.startTest();
            AFFL_ContactAccChange_TEST.resetAfflFlags();
            insert affl;
        Test.stopTest();

        //Verify Program Enrollment record has not been created
        List<Program_Enrollment__c> programEnrollments = [SELECT ID, Contact__c FROM Program_Enrollment__c WHERE Affiliation__c = :affl.ID];
        System.assertEquals(0, programEnrollments.size());
    }

    /*********************************************************************************************************
    * @description
    * This method ensures there is no NPE when a primay affiliation 
    * with no contact is deleted
    */
    @isTest
    private static void affiliationDeleteNPECheck() {        

        AFFL_MultiRecordType_TEST.setupMappingsByNameAndLabel();

        // Insert a business account
        Account bizAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
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

        AFFL_MultiRecordType_TEST.setupMappingsByNameAndLabel();

        // Insert Accounts
        Account bizAcc1 = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        Account bizAcc2 = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        Account hhAcc1 = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getHhAccRecTypeID())[0];
        Account hhAcc2 = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getHhAccRecTypeID())[0];

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

        AFFL_MultiRecordType_TEST.setupMappingsByNameAndLabel();

        List<Account> accList = new List<Account>();

        // Insert a Business Account
        Account bizAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        accList.add(bizAcc);

        // Insert a Household Account
        Account hhAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getHhAccRecTypeID())[0];
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
        AFFL_MultiRecordType_TEST.setupMappingsByNameAndApiName();

        // Insert a business account
        Account bizAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
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
        AFFL_MultiRecordType_TEST.setupMappingsByNameAndApiName();

        // Insert a business account
        Account bizAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
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
        AFFL_MultiRecordType_TEST.setupMappingsByDevNameAndLabel();

        // Insert a business account
        Account bizAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
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
        AFFL_MultiRecordType_TEST.setupMappingsByDevNameAndApiName();

        // Insert a business account
        Account bizAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
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
        List<AffiliationMappingWrapper> affiliationMappingWrapperList =
            AFFL_MultiRecordType_TEST.setupMappingsByNameAndLabel();
        String bizOrgRecordTypeName = affiliationMappingWrapperList[1].getAccountRecordTypeName();

        Test.startTest();
            AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
            String primaryAfflLookupAPIName = afflMapper.getPrimaryAffiliationLookupAPIFromAffiliationType(bizOrgRecordTypeName);
        Test.stopTest();

        String bizOrgPrimaryAfflFieldApiName =
            AFFL_MultiRecordType_TEST.getBusinessOrganizationFieldApiName();

        System.assertEquals(bizOrgPrimaryAfflFieldApiName, primaryAfflLookupAPIName);

    }

    // Negative test for getPrimaryAffiliationLookupAPIFromAffiliationType method of AFFL_MultiRecordTypeMapper
    @isTest
    private static void getPrimaryAffiliationLookupAPIFromAffiliationTypeNegativeTest() {

        AFFL_MultiRecordType_TEST.setupMappingsByNameAndLabel();

        Test.startTest();
            AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
            String primaryAfflLookupAPIName = afflMapper.getPrimaryAffiliationLookupAPIFromAffiliationType('Test Organization xyz');
        Test.stopTest();

        System.assertEquals(null, primaryAfflLookupAPIName);
    }

    // Null test for getPrimaryAffiliationLookupAPIFromAffiliationType method of AFFL_MultiRecordTypeMapper
    @isTest
    private static void getPrimaryAffiliationLookupAPIFromAffiliationTypeNullTest() {
        AFFL_MultiRecordType_TEST.setupMappingsByNameAndLabel();

        Test.startTest();
            AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
            String primaryAfflLookupAPIName = afflMapper.getPrimaryAffiliationLookupAPIFromAffiliationType(null);
        Test.stopTest();

        System.assertEquals(null, primaryAfflLookupAPIName);
    }

    // Positive test for getContactFieldFromSettings method of AFFL_MultiRecordTypeMapper
    @isTest
    private static void getContactFieldFromSettingsPoitiveTest() {
        List<AffiliationMappingWrapper> affiliationMappingWrapperList =
            AFFL_MultiRecordType_TEST.setupMappingsByNameAndLabel();
        String bizOrgName = affiliationMappingWrapperList[1].getAccountRecordTypeName();
        String bizOrgContactFieldLabel = AFFL_MultiRecordType_TEST.getBusinessOrganizationFieldLabel();

        Test.startTest();
            AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
            String contactFieldFromSettings = afflMapper.getContactFieldFromSettings(bizOrgName);
        Test.stopTest();

        System.assertEquals(bizOrgContactFieldLabel, contactFieldFromSettings);

    }
    
    // Negative test for getContactFieldFromSettings method of AFFL_MultiRecordTypeMapper
    @isTest
    private static void getContactFieldFromSettingsNegativeTest() {

        AFFL_MultiRecordType_TEST.setupMappingsByNameAndLabel();

        Test.startTest();
            AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
            String contactFieldFromSettings = afflMapper.getContactFieldFromSettings('Test1234');
        Test.stopTest();

        System.assertEquals(null, contactFieldFromSettings);

    }

    // Positive test for getPrimaryAffiliationLookupAPI method of AFFL_MultiRecordTypeMapper using Label name
    @isTest
    private static void getPrimaryAffiliationLookupAPIPoitiveLabelTest() {
        AFFL_MultiRecordType_TEST.setupMappingsByNameAndLabel();
        String bizOrgContactFieldLabel = AFFL_MultiRecordType_TEST.getBusinessOrganizationFieldLabel();
        String bizOrgContactFieldApiName = AFFL_MultiRecordType_TEST.getBusinessOrganizationFieldApiName();

        Test.startTest();
            AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
            String primaryAfflLookupAPIName = afflMapper.getPrimaryAffiliationLookupAPI(bizOrgContactFieldLabel);
        Test.stopTest();
        
        System.assertEquals(bizOrgContactFieldApiName, primaryAfflLookupAPIName);
    }

    /* Test to ensure users can create Contacts and Affilaitons when Affiliation Record Type Enforced is enabled in EDA Settings
       and Affilation Mappings have Record Type Names for Account Record Type */
    @isTest
    private static void affiliationRecordTypeEnforceWAPINamesForAccRecType() {
        AFFL_MultiRecordType_TEST.setupMappingsByDevNameAndLabel();
        AFFL_MultiRecordType_TEST.enableAffiliationRecordTypeEnforcement();

        List<Account> testAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe.getBizAccRecTypeID());
        insert testAccounts;

        // Ensure Accounts are inserted
        List<Account> accountsInserted = [SELECT Id FROM Account];
        System.assert(accountsInserted.size() == 1);

        Test.startTest();
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
            for (Contact each: contactsInserted) {
                Affiliation__c affl = UTIL_UnitTestData_TEST.getAffiliation(each.Id, accountsInserted[0].Id, False);
                affiliationsToBeInserted.add(affl);   
            }
            insert affiliationsToBeInserted;

        Test.stopTest();

        // Ensure 4 new Affiliations are inserted
        List<Affiliation__c> affiliationsInserted = [SELECT Id FROM Affiliation__c];
        System.assertEquals(5, affiliationsInserted.size());
    }
    
    /* Test to ensure users can create Contacts and Affilaitons when Affiliation Record Type Enforced is enabled in EDA Settings
       and Affilaiton Mappings have Record Type Labels for Account Record Type */

    @isTest
    private static void affiliationRecordTypeEnforceWLabelsForAccRecType() {
        AFFL_MultiRecordType_TEST.setupMappingsByNameAndLabel();
        AFFL_MultiRecordType_TEST.enableAffiliationRecordTypeEnforcement();

        List<Account> testAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe.getBizAccRecTypeID());
        insert testAccounts;

        // Ensure Accounts are inserted
        List<Account> accountsInserted = [SELECT Id FROM Account];
        System.assert(accountsInserted.size() == 1);

        Test.startTest();
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

            // Create 1 affilaiton each for a Contact
            List<Affiliation__c> affiliationsToBeInserted = new List<Affiliation__c>();
    
            for (Contact each: contactsInserted) {
                Affiliation__c affl = UTIL_UnitTestData_TEST.getAffiliation(each.Id, accountsInserted[0].Id, False);
                affiliationsToBeInserted.add(affl);   
            }
            insert affiliationsToBeInserted;

        Test.stopTest();

        // Ensure 4 new Affiliations are inserted
        List<Affiliation__c> affiliationsInserted = [SELECT Id FROM Affiliation__c];
        System.assertEquals(5, affiliationsInserted.size());
    }

    /* Test to ensure users can create Contacts and Affilaitons when Affiliation Record Type Enforced is enabled in EDA Settings
       and Affilaiton Mappings have API names for Account Record Type and primary Affiliaiton Fields */

    @isTest
    private static void affiliationRecordTypeEnforceWAPINamesForAccRecTypeAndPrimaryAffl() {
        AFFL_MultiRecordType_TEST.setupMappingsByDevNameAndApiName();
        AFFL_MultiRecordType_TEST.enableAffiliationRecordTypeEnforcement();

        List<Account> testAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe.getBizAccRecTypeID());
        insert testAccounts;

        // Ensure Accounts are inserted
        List<Account> accountsInserted = [SELECT Id FROM Account];
        System.assert(accountsInserted.size() == 1);

        Test.startTest();
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

            // Create 1 affilaiton each for a Contact
            List<Affiliation__c> affiliationsToBeInserted = new List<Affiliation__c>();
            for (Contact each: contactsInserted) {
                Affiliation__c affl = UTIL_UnitTestData_TEST.getAffiliation(each.Id, accountsInserted[0].Id, False);
                affiliationsToBeInserted.add(affl);   
            }
            insert affiliationsToBeInserted;

        Test.stopTest();

        // Ensure 4 new Affiliations are inserted
        List<Affiliation__c> affiliationsInserted = [SELECT Id FROM Affiliation__c];
        System.assertEquals(5, affiliationsInserted.size());
    }

    /* Test to ensure users can create Contacts and Affilaitons when Affiliation Record Type Enforced is enabled in EDA Settings
       and Affilaiton Mappings have Labels for Account Record Type and APIs for Primary Affiliaiton Fields */

    @isTest
    private static void affiliationRecordTypeEnforceWLabelsForAccRecTypeAndAPIForPrimaryAffl() {
        AFFL_MultiRecordType_TEST.setupMappingsByNameAndApiName();
        AFFL_MultiRecordType_TEST.enableAffiliationRecordTypeEnforcement();

        List<Account> testAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe.getBizAccRecTypeID());
        insert testAccounts;

        // Ensure Accounts are inserted
        List<Account> accountsInserted = [SELECT Id FROM Account];
        System.assert(accountsInserted.size() == 1);

        Test.startTest();
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

            // Create 1 affilaiton each for a Contact
            List<Affiliation__c> affiliationsToBeInserted = new List<Affiliation__c>();
            for (Contact each: contactsInserted) {
                Affiliation__c affl = UTIL_UnitTestData_TEST.getAffiliation(each.Id, accountsInserted[0].Id, False);
                affiliationsToBeInserted.add(affl);   
            }
            insert affiliationsToBeInserted;

        Test.stopTest();

        // Ensure 4 new Affiliations are inserted
        List<Affiliation__c> affiliationsInserted = [SELECT Id FROM Affiliation__c];
        System.assertEquals(5, affiliationsInserted.size());
    }

    // This method tests getValidAccRecordTypesInMappings() of AFFL_MultiRecordTypeMapper class by passing Record Names Labels from affiliation mappings
    @isTest
    private static void testGetValidAccRecordTypesInMappingsMethodwithLabels() {
        List<AffiliationMappingWrapper> affiliationMappingWrapperList =
            AFFL_MultiRecordType_TEST.getAfflMappingWrapperByNameAndLabel();

        affiliationMappingWrapperList = AFFL_MultiRecordType_TEST.populateRecordTypeNamesForWrappers(
            affiliationMappingWrapperList
        );

        List<String> accRecTypeLabelList = new List<String>();
        for(AffiliationMappingWrapper affiliationMappingWrapper : affiliationMappingWrapperList) {
            accRecTypeLabelList.add(affiliationMappingWrapper.getAccountRecordTypeName());
        }

        Test.startTest();
           AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
           List<String> matchingRecordTypeList = afflMapper.getValidAccRecordTypesInMappings(accRecTypeLabelList);
        Test.stopTest();

        // Ensure List has all mappings
        System.assertEquals(accRecTypeLabelList.size(), matchingRecordTypeList.size());

    }

    // This method tests getValidAccRecordTypesInMappings() of AFFL_MultiRecordTypeMapper class by passing Record Names list from affiliation mappings
    @isTest
    private static void testGetValidAccRecordTypesInMappingsMethodwithAPIs() {
        List<AffiliationMappingWrapper> affiliationMappingWrapperList =
            AFFL_MultiRecordType_TEST.setupMappingsByDevNameAndLabel();

        // Construct a list of Account Record Type Names
        List<String> accRecTypeDevNameList = new List<String>();
        for(AffiliationMappingWrapper affiliationMappingWrapper : affiliationMappingWrapperList) {
            accRecTypeDevNameList.add(affiliationMappingWrapper.getAccountRecordTypeDeveloperName());
        }

        Test.startTest();
           AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
           List<String> matchingRecordTypeList = afflMapper.getValidAccRecordTypesInMappings(accRecTypeDevNameList);
        Test.stopTest();

        // Ensure List has all mappings
        System.assertEquals(affiliationMappingWrapperList.size(), matchingRecordTypeList.size());

    }

    /* This method tests getValidAccRecordTypesInMappings() of AFFL_MultiRecordTypeMapper class by passing 
     both Record type Names and Labels list from affiliation mappings */
    @isTest
    private static void testGetValidAccRecordTypesInMappingsMethodwithAPIAndLabels() {
        List<AffiliationMappingWrapper> affiliationMappingWrapperList =
            AFFL_MultiRecordType_TEST.setupMappingsByNameAndApiName();

        // Construct a list of Account Record Type Names and Labels
        List<String> accRecTypeLabelList = new List<String>();

        for(AffiliationMappingWrapper affiliationMappingWrapper : affiliationMappingWrapperList) {
            accRecTypeLabelList.add( affiliationMappingWrapper.getAccountRecordTypeName() );
        }

        Test.startTest();
           AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
           List<String> matchingRecordTypeList = afflMapper.getValidAccRecordTypesInMappings(accRecTypeLabelList);
        Test.stopTest();

        // Ensure List has all mappings
        System.assertEquals(affiliationMappingWrapperList.size(), matchingRecordTypeList.size());

    }

    /* This method tests getValidPrimaryAfflFields() of AFFL_MultiRecordTypeMapper class by passing 
     both API names for Primary Affiliation Fields */
    @isTest
    private static void testsGetValidPrimaryAfflFields() {
        List<AffiliationMappingWrapper> affiliationMappingWrapperList =
            AFFL_MultiRecordType_TEST.setupMappingsByNameAndApiName();

        List<Affl_Mappings__c> allMappings = [SELECT ID FROM Affl_Mappings__c];
        System.assertEquals(affiliationMappingWrapperList.size(), allMappings.size());

        // Construct a list of primary Affiliation field API Names
        List<String> primaryFieldsList =
            AFFL_MultiRecordType_TEST.getContactPrimaryAffiliationFieldApiNames();

        Test.startTest();
           AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
           List<String> validPrimaryFieldList = afflMapper.getValidPrimaryAfflFields(primaryFieldsList);
        Test.stopTest();

        // Ensure List has both mappings
        System.assertEquals(affiliationMappingWrapperList.size(), validPrimaryFieldList.size());

    }

    /* This method tests getValidprimaryAfflFields() of AFFL_MultiRecordTypeMapper class by passing 
      labels for Primary Affiliation Fields */
    @isTest
    private static void testsGetValidPrimaryAfflFieldsWithLabels() {
        // Construct a list of primary Affiliation field Labels
        List<String> primaryFieldsList =
            AFFL_MultiRecordType_TEST.getContactPrimaryAffiliationFieldLabels();

        Test.startTest();
           AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
           List<String> validPrimaryFieldList = afflMapper.getValidPrimaryAfflFields(primaryFieldsList);
        Test.stopTest();

        // Ensure List has all mappings
        System.assertEquals(primaryFieldsList.size(), validPrimaryFieldList.size());
    }

    /* This method tests getValidPrimaryAfflFields() of AFFL_MultiRecordTypeMapper class by passing 
    both label and API names for Primary Affiliation Fields */
    @isTest
    private static void testsGetValidPrimaryAfflFieldsWithLabelsAndAPI() {
        //Note custom setup
        List<AffiliationMappingWrapper> wrapperList =
            new List<AffiliationMappingWrapper>();

        List<String> contactPrimaryAffiliationFieldApiNameList = 
            AFFL_MultiRecordType_TEST.getContactPrimaryAffiliationFieldApiNames();
        List<String> contactPrimaryAffiliationFieldLabelList = 
            AFFL_MultiRecordType_TEST.getContactPrimaryAffiliationFieldLabels();
        String bizOrgContactFieldApiName =
            AFFL_MultiRecordType_TEST.getBusinessOrganizationFieldApiName();
        String householdContactFieldLabel =
            AFFL_MultiRecordType_TEST.getHouseholdFieldLabel();

        wrapperList.add(
            new AfflMappingWrapperByNameAndApiName(
                UTIL_Describe_API.getHhAccRecTypeID(),
                contactPrimaryAffiliationFieldApiNameList[0]
            )
        );

        wrapperList.add(
            new AfflMappingWrapperByNameAndLabel(
                UTIL_Describe_API.getBizAccRecTypeID(),
                contactPrimaryAffiliationFieldLabelList[1]
            )
        );

        wrapperList = AFFL_MultiRecordType_TEST.commonSetup(wrapperList);
        //Custom setup ended
        
        List<Affl_Mappings__c> allMappings = [SELECT Id from Affl_Mappings__c];
        System.assertEquals(wrapperList.size(), allMappings.size());

        // Construct a list of primary Affiliation field Labels and API names
        List<String> primaryFieldsList = new List<String>();
        primaryFieldsList.add(bizOrgContactFieldApiName);
        primaryFieldsList.add(householdContactFieldLabel);

        Test.startTest();
            AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
            List<String> validPrimaryFieldList = afflMapper.getValidPrimaryAfflFields(primaryFieldsList);
        Test.stopTest();

        // Ensure List has all mappings
        System.assertEquals(wrapperList.size(), validPrimaryFieldList.size());

    }
    
    // Positive test for getPrimaryAffiliationLookupAPI method of AFFL_MultiRecordTypeMapper using API name
    @isTest
    private static void getPrimaryAffiliationLookupAPIPoitiveAPITest() {
        AFFL_MultiRecordType_TEST.setupMappingsByNameAndLabel();

        String bizOrgContactFieldApiName =
            AFFL_MultiRecordType_TEST.getBusinessOrganizationFieldApiName();

        Test.startTest();
            AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
            String primaryAfflLookupAPIName =
                afflMapper.getPrimaryAffiliationLookupAPI(bizOrgContactFieldApiName);
        Test.stopTest();

        
        System.assertEquals(bizOrgContactFieldApiName, primaryAfflLookupAPIName);
    }
    
    // Negative test for getPrimaryAffiliationLookupAPI method of AFFL_MultiRecordTypeMapper
    @isTest
    private static void getPrimaryAffiliationLookupAPINegativeTest() {

        AFFL_MultiRecordType_TEST.setupMappingsByNameAndLabel();

        Test.startTest();
            AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
            String primaryAfflLookupAPIName = afflMapper.getPrimaryAffiliationLookupAPI('Test1234');
        Test.stopTest();

        System.assertEquals(null, primaryAfflLookupAPIName);

    }

/**************************************************************************
* INNER CLASS MODELS
**************************************************************************/

private abstract class AffiliationMappingWrapper {
    Id accountRecordTypeId;
    String accountRecordTypeDeveloperName;
    String accountRecordTypeName;
    Affl_Mappings__c affiliationMapping;
    String contactFieldApiName;
    String contactFieldLabel;

    /**************************************************************************
    * @description Gets the account record type Id for the mapping
    * @return The account record type Id for the mapping
    **************************************************************************/
    public Id getAccountRecordTypeId() {
        return this.accountRecordTypeId;
    }

    /**************************************************************************
    * @description Gets the underlying affiliation mapping
    * @return The underlying affiliation mapping
    **************************************************************************/
    public Affl_Mappings__c getAffiliationMapping() {
        return this.affiliationMapping;
    }

    /**************************************************************************
    * @description Gets the account record type developer name for the mapping
    * @return The account record type developer name for the mapping
    **************************************************************************/
    public String getAccountRecordTypeDeveloperName() {
        return this.accountRecordTypeDeveloperName;
    }

    /**************************************************************************
    * @description Gets the account record type name for the mapping
    * @return The account record type name for the mapping
    **************************************************************************/
    public String getAccountRecordTypeName() {
        return this.accountRecordTypeName;
    }

    /**************************************************************************
    * @description Sets the account record type name for the mapping
    * @param accountRecordTypeName the new account record type name for the
    * mapping
    **************************************************************************/
    public void setAccountRecordTypeName(String accountRecordTypeName) {
        this.accountRecordTypeName = accountRecordTypeName;
    }

    /**************************************************************************
    * @description Gets the contact field label for the mapping
    * @return The contact field label for the mapping
    **************************************************************************/
    public String getContactFieldLabel() {
        return this.contactFieldLabel;
    }

    /**************************************************************************
    * @description Sets the record name from its id and the map of account
    * record type infos
    **************************************************************************/
    public void setRecordTypeNamesFromId(Map<Id, Schema.RecordTypeInfo> accountRecordTypeInfosByIds) {
        if( String.isBlank( this.getAccountRecordTypeId() ) ) {
            return;
        }

        this.accountRecordTypeName =
            accountRecordTypeInfosByIds.get(this.accountRecordTypeId).getName();
        this.accountRecordTypeDeveloperName =
            accountRecordTypeInfosByIds.get(this.accountRecordTypeId).getDeveloperName();
    }

    public virtual void setAffiliationMapping() {}
}

    private class AfflMappingWrapperByDevNameAndApiName extends AffiliationMappingWrapper {
        /**************************************************************************
        * @description Creates a mapping wrapper using contact field api name,
        * account record type developer name, and account record type Id
        * @param accountRecordTypeId The record type id to use for the
        * mapping
        * @param contactFieldApiName The api name of the contact field to use for
        * the mapping
        **************************************************************************/
        public AfflMappingWrapperByDevNameAndApiName(
            Id accountRecordTypeId,
            String contactFieldApiName
        ) {
            this.accountRecordTypeId = accountRecordTypeId;
            this.contactFieldApiName = contactFieldApiName;
        }
        /**************************************************************************
        * @description Sets the wrapper's mapping to one created by account name
        * and contact field label.
        **************************************************************************/
        public override void setAffiliationMapping() {
            this.affiliationMapping = new Affl_Mappings__c(
                Name = this.accountRecordTypeName,
                Account_Record_Type__c = this.accountRecordTypeDeveloperName,
                Primary_Affl_Field__c = this.contactFieldApiName
            );
        }
    }

    private class AfflMappingWrapperByDevNameAndLabel extends AffiliationMappingWrapper {
        /**************************************************************************
        * @description Creates a mapping wrapper using contact field label, account
        * record type developer name, and account record type Id
        * @param accountRecordTypeId The record type id to use for the
        * mapping
        * @param contactFieldLabel The label of the contact field to use for the
        * mapping
        **************************************************************************/
        public AfflMappingWrapperByDevNameAndLabel(
            Id accountRecordTypeId,
            String contactFieldLabel
        ) {
            this.accountRecordTypeId = accountRecordTypeId;
            this.contactFieldLabel = contactFieldLabel;
        }
        /**************************************************************************
        * @description Sets the wrapper's mapping to one created by account name
        * and contact field label.
        **************************************************************************/
        public override void setAffiliationMapping() {
            this.affiliationMapping = new Affl_Mappings__c(
                Name = this.accountRecordTypeName,
                Account_Record_Type__c = this.accountRecordTypeDeveloperName,
                Primary_Affl_Field__c = this.contactFieldLabel
            );
        }
    }

    private class AfflMappingWrapperByNameAndApiName extends AffiliationMappingWrapper {
        /**************************************************************************
        * @description Creates a mapping wrapper using contact field api name,
        * account record type name, and account record type Id
        * @param accountRecordTypeId The record type id to use for the
        * mapping
        * @param contactFieldApiName The api name of the contact field to use for
        * the mapping
        **************************************************************************/
        public AfflMappingWrapperByNameAndApiName(
            Id accountRecordTypeId,
            String contactFieldApiName
        ) {
            this.accountRecordTypeId = accountRecordTypeId;
            this.contactFieldApiName = contactFieldApiName;
        }
        /**************************************************************************
        * @description Sets the wrapper's mapping to one created by account name
        * and contact field label.
        **************************************************************************/
        public override void setAffiliationMapping() {
            this.affiliationMapping = new Affl_Mappings__c(
                Name = this.accountRecordTypeName,
                Account_Record_Type__c = this.accountRecordTypeName,
                Primary_Affl_Field__c = this.contactFieldApiName
            );
        }
    }

    private class AfflMappingWrapperByNameAndLabel extends AffiliationMappingWrapper {
        /**************************************************************************
        * @description Creates a mapping wrapper using contact field label, account
        * record type name, and account record type Id
        * @param accountRecordTypeId The record type id to use for the
        * mapping
        * @param contactFieldLabel The label of the contact field to use for the
        * mapping
        **************************************************************************/
        public AfflMappingWrapperByNameAndLabel(
            Id accountRecordTypeId,
            String contactFieldLabel
        ) {
            this.accountRecordTypeId = accountRecordTypeId;
            this.contactFieldLabel = contactFieldLabel;
        }
        /**************************************************************************
        * @description Sets the wrapper's mapping to one created by account name
        * and contact field label.
        **************************************************************************/
        public override void setAffiliationMapping() {
            this.affiliationMapping = new Affl_Mappings__c(
                Name = this.accountRecordTypeName,
                Account_Record_Type__c = this.accountRecordTypeName,
                Primary_Affl_Field__c = this.contactFieldLabel
            );
        }
    }
}