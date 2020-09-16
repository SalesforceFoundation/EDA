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
    * @description Test method to verify getAffiliationsToCreate() returns list of affiliations to create
    ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationsToCreateTestPositive() {
        
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
    * @description Test method to verify getAffiliationsToCreate() returns list of affiliations to create
    ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationsToCreateForContactTestPositive() {
        
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
    * @description Test method to verify getAffiliationsToCreate() returns list of affiliations to create
    ***************************************************************************************************************************/
 
    @isTest
    private static void getAffiliationsToCreateForContactNegativeTestWithSObjectException() {
        
        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';
        
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>(); // change Primary_Affl_Field__c to boolean, date, int
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

        System.assertEquals(0, affiliationsToCreate.size());

    }
   
    @isTest
    private static void getAffiliationsToCreateOrUpdateBulkPositiveTest() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';
        
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = prefix + 'Primary_Organization__c'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = prefix + 'Primary_Household__c'));
        insert mappings;
        
        Account businesssAccount = new Account(Id = UTIL_UnitTestData_TEST.getFakeId(Account.sObjectType), RecordTypeId = UTIL_Describe_API.getBizAccRecTypeID());

        Contact oldContact1 = UTIL_UnitTestData_TEST.getContact();
        oldContact1.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);
        
        Contact oldContact2 = UTIL_UnitTestData_TEST.getContact();
        oldContact2.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);
        
        List<Contact> oldContactList = new List<Contact> {oldContact1, oldContact2};

        Map<Id, Contact> oldContactMap = new Map<Id, Contact>(oldContactList);

        Contact newContact1 = oldContact1.clone(true);
        newContact1.Primary_Organization__c = businesssAccount.Id;
        
        Contact newContact2 = oldContact2.clone(true);
        newContact2.Primary_Organization__c = businesssAccount.Id;
        
        List<Contact> newContactList = new List<Contact> {newContact1, newContact2};
        
        Map<Id, Contact> newContactMap = new Map<Id, Contact>(newContactList);
        
        Test.startTest();
            SRVC_Contact_PrimaryAffiliations.AffiliationsToInsertAndUpdate afflsToInsertUpdate = SRVC_Contact_PrimaryAffiliations.getInstance().getAffiliationsToCreateOrUpdate(newContactMap, oldContactMap, MAPR_PrimaryAffiliations.getInstance().getModelsFromSettings());
        Test.stopTest();
        
        System.assertEquals(2, afflsToInsertUpdate.getAffiliationListToInsertClone().size());
        System.assertEquals(0, afflsToInsertUpdate.getAffiliationListToUpdateClone().size());

    }
}