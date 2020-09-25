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
* @description Test class for SRVC_Contact_PrimaryAffiliations
*/
@isTest
private class SRVC_Contact_PrimaryAffiliations_TEST {

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * SRVC_Contact_PrimaryAffiliations class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        SRVC_Contact_PrimaryAffiliations primaryAfflSRVCInstance = SRVC_Contact_PrimaryAffiliations.getInstance();
        System.assertEquals(SRVC_Contact_PrimaryAffiliations.instance, primaryAfflSRVCInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, primaryAfflSRVCInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * SRVC_Contact_PrimaryAffiliations class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        SRVC_Contact_PrimaryAffiliations primaryAfflSRVCInstance1 = SRVC_Contact_PrimaryAffiliations.getInstance();
        SRVC_Contact_PrimaryAffiliations primaryAfflSRVCInstance2 = SRVC_Contact_PrimaryAffiliations.getInstance();

        System.assertEquals(SRVC_Contact_PrimaryAffiliations.instance, primaryAfflSRVCInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(primaryAfflSRVCInstance1, primaryAfflSRVCInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, primaryAfflSRVCInstance1 != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method for shouldCreateAffiliationsForUpdate()
    ***************************************************************************************************************************/
    @isTest
    private static void shouldCreateAffiliationsForUpdateFalseTest() {
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary, true);
        Test.startTest();
            Boolean shouldCreateAffiliations = SRVC_Contact_PrimaryAffiliations.getInstance().shouldCreateAffiliationsForUpdate();
        Test.stopTest();
        
        System.assertEquals(false, shouldCreateAffiliations);
    }

    /**************************************************************************************************************************
    * @description Test method for shouldCreateAffiliationsForUpdate()
    ***************************************************************************************************************************/
    @isTest
    private static void shouldCreateAffiliationsForUpdateTrueTest() {
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary, false);
        Test.startTest();
            Boolean shouldCreateAffiliations = SRVC_Contact_PrimaryAffiliations.getInstance().shouldCreateAffiliationsForUpdate();
        Test.stopTest();

        System.assertEquals(true, shouldCreateAffiliations);
    }

    /**************************************************************************************************************************
    * @description Test method to verify getAffiliationsToCreate() returns list of affiliations to create
    ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationsToCreatePositiveTest() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = prefix + 'Primary_Organization__c'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = prefix + 'Primary_Household__c'));
        insert mappings;

        Account businesssAccount = new Account(Id = UTIL_UnitTestData_TEST.getFakeId(Account.sObjectType), RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());

        Contact contact1 = UTIL_UnitTestData_TEST.getContact();
        contact1.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);
        contact1.Primary_Organization__c = businesssAccount.Id;

        Contact contact2 = UTIL_UnitTestData_TEST.getContact();
        contact2.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);
        contact2.Primary_Organization__c = businesssAccount.Id;

        List<Contact> contactList = new List<Contact> {contact1, contact2};

        Test.startTest();
            List<Affiliation__c> affiliationsToCreate = SRVC_Contact_PrimaryAffiliations.getInstance().getAffiliationsToCreate(contactList, MAPR_PrimaryAffiliations.getInstance().getModelsFromSettings());
        Test.stopTest();
        
        System.assertEquals(2, affiliationsToCreate.size());
        
    }

    /**************************************************************************************************************************
    * @description Test method to verify getAffiliationsToCreate() returns empty list of affiliations to create
    * when Primary Affiliaton field's value is null
    ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationsToCreateNegativeTestWithNULL() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = prefix + 'Primary_Organization__c'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = prefix + 'Primary_Household__c'));
        insert mappings;

        Account businesssAccount = new Account(Id = UTIL_UnitTestData_TEST.getFakeId(Account.sObjectType), RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());

        Contact contact1 = UTIL_UnitTestData_TEST.getContact();
        contact1.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

        Contact contact2 = UTIL_UnitTestData_TEST.getContact();
        contact2.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

        List<Contact> contactList = new List<Contact> {contact1, contact2};

        Test.startTest();
            List<Affiliation__c> affiliationsToCreate = SRVC_Contact_PrimaryAffiliations.getInstance().getAffiliationsToCreate(contactList, MAPR_PrimaryAffiliations.getInstance().getModelsFromSettings());
        Test.stopTest();

        System.assertEquals(0, affiliationsToCreate.size());

    }
    
    /**************************************************************************************************************************
    * @description Test method to verify getAffiliationsToCreate() returns empty list of affiliations to create
    * when Primary Affiliaton field's value is null
    ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationsToCreateNegativeTestWithTypeException() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Birthdate'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = prefix + 'Primary_Household__c'));
        insert mappings;

        Account businesssAccount = new Account(Id = UTIL_UnitTestData_TEST.getFakeId(Account.sObjectType), RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());

        Contact contact1 = UTIL_UnitTestData_TEST.getContact();
        contact1.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);
        contact1.Birthdate = System.today();

        Contact contact2 = UTIL_UnitTestData_TEST.getContact();
        contact2.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);
        contact2.Birthdate = System.today();

        List<Contact> contactList = new List<Contact> {contact1, contact2};

        Test.startTest();
            List<Affiliation__c> affiliationsToCreate = SRVC_Contact_PrimaryAffiliations.getInstance().getAffiliationsToCreate(contactList, MAPR_PrimaryAffiliations.getInstance().getModelsFromSettings());
        Test.stopTest();

        System.assertEquals(0, affiliationsToCreate.size());

    }

    /**************************************************************************************************************************
    * @description Test method to verify getAffiliationsToCreate() returns list of affiliations to create
    ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationsToCreateForContactPositiveTest() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = prefix + 'Primary_Organization__c'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = prefix + 'Primary_Household__c'));
        insert mappings;

        Account businesssAccount = new Account(Id = UTIL_UnitTestData_TEST.getFakeId(Account.sObjectType), RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());

        Contact contact1 = UTIL_UnitTestData_TEST.getContact();
        contact1.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);
        contact1.Primary_Organization__c = businesssAccount.Id;

        Test.startTest();
            List<Affiliation__c> affiliationsToCreate = SRVC_Contact_PrimaryAffiliations.getInstance().getAffiliationsToCreateForContact(contact1, MAPR_PrimaryAffiliations.getInstance().getModelsFromSettings());
        Test.stopTest();

        System.assertEquals(1, affiliationsToCreate.size());
        System.assertEquals(contact1.Id, affiliationsToCreate[0].Contact__c);
        System.assertEquals(businesssAccount.Id, affiliationsToCreate[0].Account__c);
        System.assertEquals(true, affiliationsToCreate[0].Primary__c);

    }

    /**************************************************************************************************************************
    * @description Test method to verify getAffiliationsToCreate() returns empty list of affiliations to create
    * when Primary Affiliation field's value is null
    ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationsToCreateForContactNegativeTest() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = prefix + 'Primary_Organization__c'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = prefix + 'Primary_Household__c'));
        insert mappings;

        Account businesssAccount = new Account(Id = UTIL_UnitTestData_TEST.getFakeId(Account.sObjectType), RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());

        Contact contact1 = UTIL_UnitTestData_TEST.getContact();
        contact1.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

        Test.startTest();
            List<Affiliation__c> affiliationsToCreate = SRVC_Contact_PrimaryAffiliations.getInstance().getAffiliationsToCreateForContact(contact1, MAPR_PrimaryAffiliations.getInstance().getModelsFromSettings());
        Test.stopTest();

        System.assertEquals(0, affiliationsToCreate.size());
    }

    /**************************************************************************************************************************
    * @description Test method to verify getAffiliationsToCreate() returns empty list when encountering a type exception
    ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationsToCreateForContactNegativeTestWithTypeException() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>(); // change Primary_Affl_Field__c to boolean, date, int
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Birthdate'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = prefix + 'Primary_Household__c'));
        insert mappings;

        Account businesssAccount = new Account(Id = UTIL_UnitTestData_TEST.getFakeId(Account.sObjectType), RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());

        Contact contact1 = UTIL_UnitTestData_TEST.getContact();
        contact1.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);
        contact1.Primary_Organization__c = businesssAccount.Id;
        contact1.Birthdate = System.today();

        Test.startTest();
            List<Affiliation__c> affiliationsToCreate = SRVC_Contact_PrimaryAffiliations.getInstance().getAffiliationsToCreateForContact(contact1, MAPR_PrimaryAffiliations.getInstance().getModelsFromSettings());
        Test.stopTest();

        System.assertEquals(0, affiliationsToCreate.size());

    }

    /**************************************************************************************************************************
    * @description Test method to verify getAffiliationsToCreate() returns empty list when encountering a String exception
    ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationsToCreateForContactNegativeTestWithStringException() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>(); // change Primary_Affl_Field__c to boolean, date, int
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Email'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = prefix + 'Primary_Household__c'));
        insert mappings;

        Account businesssAccount = new Account(Id = UTIL_UnitTestData_TEST.getFakeId(Account.sObjectType), RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());

        Contact contact1 = UTIL_UnitTestData_TEST.getContact();
        contact1.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);
        contact1.Primary_Organization__c = businesssAccount.Id;
        contact1.Email = 'Test@sf.com';

        Test.startTest();
            List<Affiliation__c> affiliationsToCreate = SRVC_Contact_PrimaryAffiliations.getInstance().getAffiliationsToCreateForContact(contact1, MAPR_PrimaryAffiliations.getInstance().getModelsFromSettings());
        Test.stopTest();

        System.assertEquals(0, affiliationsToCreate.size());

    }
    
    /**************************************************************************************************************************
    * @description Test method to verify getAffiliationsToCreateOrUpdate() returns affiliations to insert when 
    * ShouldCreateAffiliatons is true
    ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationsToCreateOrUpdateTestWithShouldCreateAffiliatonsTrue() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary, false);

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = prefix + 'Primary_Organization__c'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = prefix + 'Primary_Household__c'));
        insert mappings;

        Account businesssAccount = new Account(Id = UTIL_UnitTestData_TEST.getFakeId(Account.sObjectType), RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());

        Contact oldContact1 = UTIL_UnitTestData_TEST.getContact();
        oldContact1.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

        Contact oldContact2 = UTIL_UnitTestData_TEST.getContact();
        oldContact2.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

        Contact oldContact3 = UTIL_UnitTestData_TEST.getContact();
        oldContact3.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);
        oldContact3.Primary_Organization__c = businesssAccount.Id;

        List<Contact> oldContactList = new List<Contact> {oldContact1, oldContact2, oldContact3};

        Map<Id, Contact> oldContactMap = new Map<Id, Contact>(oldContactList);

        Contact newContact1 = oldContact1.clone(true);
        newContact1.Primary_Organization__c = businesssAccount.Id;

        Contact newContact2 = oldContact2.clone(true);
        newContact2.Primary_Organization__c = businesssAccount.Id;

        Contact newContact3 = oldContact3.clone(true);
        newContact3.Primary_Organization__c = null;

        List<Contact> newContactList = new List<Contact> {newContact1, newContact2, newContact3};

        Map<Id, Contact> newContactMap = new Map<Id, Contact>(newContactList);

        Test.startTest();
            SRVC_Contact_PrimaryAffiliations.AffiliationsToInsertAndUpdate afflsToInsertUpdate = SRVC_Contact_PrimaryAffiliations.getInstance().getAffiliationsToCreateOrUpdate(newContactMap, oldContactMap, MAPR_PrimaryAffiliations.getInstance().getModelsFromSettings());
        Test.stopTest();
    
        System.assertEquals(2, afflsToInsertUpdate.getAffiliationListToInsertClone().size());

    }

    /*****************************************************************************************************************************
    * @description Test method to verify getAffiliationsToCreateOrUpdate() returns affiliations to insert when Contact's
    * Primary Affiliaton field is populated in an update
    ******************************************************************************************************************************/
    @isTest
    private static void getAffiliationsToCreateOrUpdateForContactTestWithForInsert() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary, false);

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = prefix + 'Primary_Organization__c'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = prefix + 'Primary_Household__c'));
        insert mappings;

        Account businesssAccount = new Account(Id = UTIL_UnitTestData_TEST.getFakeId(Account.sObjectType), RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());
    
        Contact oldContact = UTIL_UnitTestData_TEST.getContact();
        oldContact.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

        Contact newContact = oldContact.clone(true);
        newContact.Primary_Organization__c = businesssAccount.Id;

        Test.startTest();
            SRVC_Contact_PrimaryAffiliations.AffiliationsToProcess afflsToProcess = SRVC_Contact_PrimaryAffiliations.getInstance().getAffiliationsToCreateOrUpdateForContact(newContact, oldContact, MAPR_PrimaryAffiliations.getInstance().getModelsFromSettings());
        Test.stopTest();

        System.assertEquals(1, afflsToProcess.getAffiliationListToInsertClone().size());
        System.assertEquals(0, afflsToProcess.getAccountIdSet().size());
        
    }

    /*****************************************************************************************************************************
    * @description Test method to verify getAffiliationsToCreateOrUpdate() returns affiliations to insert when Contact's
    * Primary Affiliaton field is updated
    ******************************************************************************************************************************/
    @isTest
    private static void getAffiliationsToCreateOrUpdateForContactTestWithForInsertWhenPrimaryFiledIsChanged() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary, false);

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = prefix + 'Primary_Organization__c'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = prefix + 'Primary_Household__c'));
        insert mappings;

        Account businesssAccount1 = new Account(Id = UTIL_UnitTestData_TEST.getFakeId(Account.sObjectType), RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());
        Account businesssAccount2 = new Account(Id = UTIL_UnitTestData_TEST.getFakeId(Account.sObjectType), RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());

        Contact oldContact = UTIL_UnitTestData_TEST.getContact();
        oldContact.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);
        oldContact.Primary_Organization__c = businesssAccount1.Id;

        Contact newContact = oldContact.clone(true);
        newContact.Primary_Organization__c = businesssAccount2.Id;

        Test.startTest();
            SRVC_Contact_PrimaryAffiliations.AffiliationsToProcess afflsToProcess = SRVC_Contact_PrimaryAffiliations.getInstance().getAffiliationsToCreateOrUpdateForContact(newContact, oldContact, MAPR_PrimaryAffiliations.getInstance().getModelsFromSettings());
        Test.stopTest();

        System.assertEquals(1, afflsToProcess.getAffiliationListToInsertClone().size());        
    }

    /**************************************************************************************************************************
    * @description Test method to verify getAffiliationsToCreateOrUpdateForContact() returns null
    * when String exception is encountered
    ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationsToCreateOrUpdateForContactTestForInsertWithStringException() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary, false);

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Email'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = prefix + 'Primary_Household__c'));
        insert mappings;

        Account businesssAccount = new Account(Id = UTIL_UnitTestData_TEST.getFakeId(Account.sObjectType), RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());

        Contact oldContact = UTIL_UnitTestData_TEST.getContact();
        oldContact.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

        Contact newContact = oldContact.clone(true);
        newContact.Email = 'test@sf.com';

        Test.startTest();
            SRVC_Contact_PrimaryAffiliations.AffiliationsToProcess afflsToProcess = SRVC_Contact_PrimaryAffiliations.getInstance().getAffiliationsToCreateOrUpdateForContact(newContact, oldContact, MAPR_PrimaryAffiliations.getInstance().getModelsFromSettings());
        Test.stopTest();

        System.assertEquals(null, afflsToProcess.affiliationsToInsertList);
        System.assertEquals(null, afflsToProcess.accountIdSet);
        
    }

    /**************************************************************************************************************************
    * @description Test method to verify getAffiliationsToCreateOrUpdateForContact() returns null
    * when type exception is encountered
    ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationsToCreateOrUpdateForContactTestForInsertWithTypeException() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary, false);

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Birthdate'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = prefix + 'Primary_Household__c'));
        insert mappings;

        Account businesssAccount = new Account(Id = UTIL_UnitTestData_TEST.getFakeId(Account.sObjectType), RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());

        Contact oldContact = UTIL_UnitTestData_TEST.getContact();
        oldContact.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

        Contact newContact = oldContact.clone(true);
        newContact.Birthdate = System.today();

        Test.startTest();
            SRVC_Contact_PrimaryAffiliations.AffiliationsToProcess afflsToProcess = SRVC_Contact_PrimaryAffiliations.getInstance().getAffiliationsToCreateOrUpdateForContact(newContact, oldContact, MAPR_PrimaryAffiliations.getInstance().getModelsFromSettings());
        Test.stopTest();

        System.assertEquals(null, afflsToProcess.affiliationsToInsertList);
        System.assertEquals(null, afflsToProcess.accountIdSet);

    }

    /**************************************************************************************************************************
    * @description Test method to verify getAffiliationsToCreateOrUpdateForContact() clears Primary Field on Affiliaton
    * when Primary Affiliation field is cleared on Contact
    ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationsToCreateOrUpdateForContactTestWithForUpdate() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary, false);

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = prefix + 'Primary_Organization__c'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = prefix + 'Primary_Household__c'));
        insert mappings;

        Account businesssAccount = new Account(Id = UTIL_UnitTestData_TEST.getFakeId(Account.sObjectType), RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());

        Contact oldContact = UTIL_UnitTestData_TEST.getContact();
        oldContact.Primary_Organization__c = businesssAccount.Id;
        oldContact.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

        Contact newContact = oldContact.clone(true);
        newContact.Primary_Organization__c = null;

        Test.startTest();
            SRVC_Contact_PrimaryAffiliations.AffiliationsToProcess afflsToProcess = SRVC_Contact_PrimaryAffiliations.getInstance().getAffiliationsToCreateOrUpdateForContact(newContact, oldContact, MAPR_PrimaryAffiliations.getInstance().getModelsFromSettings());
        Test.stopTest();

        System.assertEquals(0, afflsToProcess.getAffiliationListToInsertClone().size());
        System.assertEquals(1, afflsToProcess.getAccountIdSet().size());
        
    }

    /**************************************************************************************************************************
    * @description Test method to verify getAffiliationsToUpdateForContact() doesn't update Primary check box when there is
    * no change in Primary Affiliation's field on Contact
    ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationsToUpdateForContactTest() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary, false);

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = prefix + 'Primary_Organization__c'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = prefix + 'Primary_Household__c'));
        insert mappings;

        Account businesssAccount = new Account(Id = UTIL_UnitTestData_TEST.getFakeId(Account.sObjectType), RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());

        Contact oldContact = UTIL_UnitTestData_TEST.getContact();
        oldContact.Primary_Organization__c = businesssAccount.Id;
        oldContact.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

        Contact newContact = oldContact.clone(true);

        Test.startTest();
            Set<Id> accountIdSet = SRVC_Contact_PrimaryAffiliations.getInstance().getAffiliationsToUpdateForContact(newContact, oldContact, MAPR_PrimaryAffiliations.getInstance().getModelsFromSettings());
        Test.stopTest();

        System.assertEquals(true, accountIdSet.isEmpty());
        
    }
    
    /**************************************************************************************************************************
    * @description Test method to verify getAffiliationsToUpdateForContact() updates Primary check box when there is
    * Primary Affiliation's field on Contact is cleared
    ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationsToUpdateForContactTestWhenPrimaryFieldIsCleared() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary, false);

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = prefix + 'Primary_Organization__c'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = prefix + 'Primary_Household__c'));
        insert mappings;

        Account businesssAccount = new Account(Id = UTIL_UnitTestData_TEST.getFakeId(Account.sObjectType), RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());

        Contact oldContact = UTIL_UnitTestData_TEST.getContact();
        oldContact.Primary_Organization__c = businesssAccount.Id;
        oldContact.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

        Contact newContact = oldContact.clone(true);
        newContact.Primary_Organization__c = null;

        Test.startTest();
            Set<Id> accIdSet = SRVC_Contact_PrimaryAffiliations.getInstance().getAffiliationsToUpdateForContact(newContact, oldContact, MAPR_PrimaryAffiliations.getInstance().getModelsFromSettings());
        Test.stopTest();

        System.assertEquals(1, accIdSet.size());

    }
    
    /**************************************************************************************************************************
    * @description Test method to verify getAffiliationsToCreateOrUpdate() using DML return Affiliatons to update when 
    * Primary Affiliation field is cleared on Contact
    ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationsToCreateOrUpdateTestForUpdateUsingDML() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary, true);

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = prefix + 'Primary_Organization__c'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = prefix + 'Primary_Household__c'));
        insert mappings;

        Account businesssAccount = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert businesssAccount;

        Contact testContact = UTIL_UnitTestData_TEST.getContact();
        testContact.Primary_Organization__c = businesssAccount.Id;

        List<contact> contactList = new List<contact>();
        contactList.add(testContact);
        insert contactList;

        Contact newContact = testContact.clone(true);
        newContact.Primary_Organization__c = null;

        List<contact> newContactList = new List<contact>();
        newContactList.add(newContact);

        list<Affiliation__c> affliations = [SELECT Id, Primary__c, Contact__c, Account__c From Affiliation__c];

        System.assertEquals(1, affliations.size());
        System.assertEquals(true, affliations[0].Primary__c);
        System.assertEquals(businesssAccount.Id, affliations[0].Account__c);
        System.assertEquals(testContact.Id, affliations[0].Contact__c);

        Map<Id, Contact> contactById = new Map<Id, Contact>(contactList);
        Map<Id, Contact> newContactById = new Map<Id, Contact>(newContactList);

        Test.startTest();
            SRVC_Contact_PrimaryAffiliations.AffiliationsToInsertAndUpdate afflsToInsertUpdate = SRVC_Contact_PrimaryAffiliations.getInstance().getAffiliationsToCreateOrUpdate(newContactById, contactById, MAPR_PrimaryAffiliations.getInstance().getModelsFromSettings());
        Test.stopTest();

       System.assertEquals(1, afflsToInsertUpdate.getAffiliationListToUpdateClone().size());
       System.assertEquals(0, afflsToInsertUpdate.getAffiliationListToInsertClone().size());

    }
    
    /**************************************************************************************************************************
    * @description Test method to verify getAffiliationsToCreateOrUpdateForContact() using DML return Affiliatons to update
    * when Primary Affiliation field is cleared on Contact
    ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationsToCreateOrUpdateForContactTestForUpdateUsingDML() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary, true);

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = prefix + 'Primary_Organization__c'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = prefix + 'Primary_Household__c'));
        insert mappings;

        Account businesssAccount = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert businesssAccount;

        Contact testContact = UTIL_UnitTestData_TEST.getContact();
        testContact.Primary_Organization__c = businesssAccount.Id;

        insert testContact;

        Contact newContact = testContact.clone(true);
        newContact.Primary_Organization__c = null;

        list<Affiliation__c> affliations = [SELECT Id, Primary__c, Contact__c, Account__c From Affiliation__c];

        System.assertEquals(1, affliations.size());
        System.assertEquals(true, affliations[0].Primary__c);
        System.assertEquals(businesssAccount.Id, affliations[0].Account__c);
        System.assertEquals(testContact.Id, affliations[0].Contact__c);

        Test.startTest();
            SRVC_Contact_PrimaryAffiliations.AffiliationsToProcess afflsToProcess = SRVC_Contact_PrimaryAffiliations.getInstance().getAffiliationsToCreateOrUpdateForContact(newContact, testContact, MAPR_PrimaryAffiliations.getInstance().getModelsFromSettings());
        Test.stopTest();

       System.assertEquals(1, afflsToProcess.getAccountIdSet().size());
       System.assertEquals(0, afflsToProcess.getAffiliationListToInsertClone().size());

    }
    
    /**************************************************************************************************************************
    * @description Test method to verify getAffiliationsToUpdateMethod() using DML to update Affiliations
    ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationsToUpdateMethodTest() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary, true);

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = prefix + 'Primary_Organization__c'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = prefix + 'Primary_Household__c'));
        insert mappings;

        Account businesssAccount = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert businesssAccount;

        Set<Id> accIdSet = new Set<Id>();
        accIdSet.add(businesssAccount.Id);

        Contact testContact = UTIL_UnitTestData_TEST.getContact();
        testContact.Primary_Organization__c = businesssAccount.Id;

        insert testContact;

        List<Affiliation__c> affliations = [SELECT Id, Primary__c, Contact__c, Account__c From Affiliation__c];

        System.assertEquals(1, affliations.size());
        System.assertEquals(true, affliations[0].Primary__c);
        System.assertEquals(businesssAccount.Id, affliations[0].Account__c);
        System.assertEquals(testContact.Id, affliations[0].Contact__c);

        Map<Id, Set<Id>> accountIdsByContactIdSets = new Map<Id, Set<Id>>();
        accountIdsByContactIdSets.put(testContact.Id, accIdSet);
    
        Test.startTest();
            List<Affiliation__c> afflsToMakeNonPrimary = SRVC_Contact_PrimaryAffiliations.getInstance().getAffiliationsToUpdate(accountIdsByContactIdSets, accIdSet);
        Test.stopTest();

        System.assertEquals(affliations[0].Id, afflsToMakeNonPrimary[0].Id);
        System.assertEquals(false, afflsToMakeNonPrimary[0].Primary__c);
        System.assertEquals(businesssAccount.Id, afflsToMakeNonPrimary[0].Account__c);
        System.assertEquals(testContact.Id, afflsToMakeNonPrimary[0].Contact__c);
    }     
}