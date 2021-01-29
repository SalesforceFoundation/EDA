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
* @group-content ../../ApexDocContent/
* @description Test class for ContactRelAutoCreateService
*/
@isTest 
private with sharing class ContactRelAutoCreateService_TEST {

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * ContactRelAutoCreateService class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        ContactRelAutoCreateService srvcConRelAutoCreate = ContactRelAutoCreateService.getInstance();
        System.assertEquals(ContactRelAutoCreateService.instance, srvcConRelAutoCreate, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, srvcConRelAutoCreate != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance() returns the existing instance of the 
    * ContactRelAutoCreateService class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        ContactRelAutoCreateService srvcConRelAutoCreateInstance1 = ContactRelAutoCreateService.getInstance();
        ContactRelAutoCreateService srvcConRelAutoCreateInstance2 = ContactRelAutoCreateService.getInstance();
 
        System.assertEquals(ContactRelAutoCreateService.instance, srvcConRelAutoCreateInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(srvcConRelAutoCreateInstance1, srvcConRelAutoCreateInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, srvcConRelAutoCreateInstance1 != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getRelationshipsToCreateForContactsTrue() returns a populated 
    * ContactsRelationshipsModel model for a list of Contact records with Relationship Auto Create mappings. 
    ***************************************************************************************************************************/
    @isTest 
    private static void getRelationshipsToCreateForContactsTrue(){
        ContactRelAutoCreateService.instance = new STUB_WithRelationshipsToCreate();

        List<Relationship_Auto_Create__c> conRelAutoCreateList = new List<Relationship_Auto_Create__c>();
        List<ContactRelAutoCreateMappingModel> conRelAutoCreateMappingList = new List<ContactRelAutoCreateMappingModel>();

        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        for (Contact con : contactsList){
            con.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
        }

        for (Integer i = 0; i < 5; i++){
            Relationship_Auto_Create__c contactRelAutoCreate = new Relationship_Auto_Create__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship_Auto_Create__c.SObjectType),
                                                                                               Name = 'ConReportToAutoCreate' + i, 
                                                                                               Object__c = 'Contact',
                                                                                               Field__c = 'ReportsToId', 
                                                                                               Relationship_Type__c = 'ContactTester' + i,
                                                                                               Campaign_Types__c = '');
        
            conRelAutoCreateList.add(contactRelAutoCreate);
        }

        for (Relationship_Auto_Create__c relAutoCreate : conRelAutoCreateList){
            Schema.DescribeFieldResult conFieldDescribe = UTIL_Describe.getFieldDescribe(relAutoCreate.Object__c, relAutoCreate.Field__c);
            ContactRelAutoCreateMappingModel conRelAutoCreateMapping = new ContactRelAutoCreateMappingModel(conFieldDescribe, relAutoCreate.Relationship_Type__c, relAutoCreate.Field__c);    

            conRelAutoCreateMappingList.add(conRelAutoCreateMapping);
        }
        
        Test.startTest();
        ContactsRelationshipsModel consRelsModel = ContactRelAutoCreateService.getInstance().getRelationshipsToCreateForContacts(contactsList, conRelAutoCreateMappingList);
        Test.stopTest();
    
        System.assertEquals(5, consRelsModel.contactIdsSet.size(), 'There should be 5 contacts with relationships to create.');
        System.assertEquals(15, consRelsModel.relatedContactIdSet.size(), 'There should be 15 related contacts associated with relationships to create.');
        System.assertEquals(15, consRelsModel.relationshipList.size(), 'There should be 15 relationships to be created.');
        System.assertEquals(5, consRelsModel.contactRelationshipsModelsByContactId.keySet().size(), 'There should be 5 ContactRelationships models associated with relationships to create.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getRelationshipsToCreateForContactsTrue() returns an empty ContactsRelationshipsModel
    * model for a list of Contact records without Relationship Auto Create mappings. 
    ***************************************************************************************************************************/
    @isTest 
    private static void getRelationshipsToCreateForContactsFalse(){
        ContactRelAutoCreateService.instance = new STUB_WithoutRelationshipsToCreate();

        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        for (Contact con : contactsList){
            con.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
        }

        Test.startTest();
        ContactsRelationshipsModel consRelsModel = ContactRelAutoCreateService.getInstance().getRelationshipsToCreateForContacts(contactsList, new List<ContactRelAutoCreateMappingModel>());
        Test.stopTest();

        System.assertEquals(true, consRelsModel.contactIdsSet.isEmpty(), 'There should be no contacts with relationships to create.');
        System.assertEquals(true, consRelsModel.relatedContactIdSet.isEmpty(), 'There should be no related contacts associated with relationships to create.');
        System.assertEquals(true, consRelsModel.relationshipList.isEmpty(), 'There should be no relationships to be created.');
        System.assertEquals(true, consRelsModel.contactRelationshipsModelsByContactId.keySet().isEmpty(), 'There should be no ContactRelationships models associated with relationships to create.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getRelationshipsToCreateForContactsTrue() returns a populated
    * ContactRelAutoCreateMappingModel model for a Contact record with Relationship Auto Create mappings. 
    ***************************************************************************************************************************/
    @isTest 
    private static void getRelationshipsToCreateForContactTrue(){
        ContactRelAutoCreateService.instance = new STUB_WithRelationshipsToCreate();
        List<ContactRelAutoCreateMappingModel> conRelAutoCreateMappingList = new List<ContactRelAutoCreateMappingModel>();
        List<Relationship_Auto_Create__c> conRelAutoCreateList = new List<Relationship_Auto_Create__c>();

        Contact con = new Contact(Id = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                  LastName = 'Testerson');

        for (Integer i = 0; i < 5; i++){
            Relationship_Auto_Create__c contactRelAutoCreate = new Relationship_Auto_Create__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship_Auto_Create__c.SObjectType),
                                                                                                Name = 'ConReportToAutoCreate' + i, 
                                                                                                Object__c = 'Contact',
                                                                                                Field__c = 'ReportsToId', 
                                                                                                Relationship_Type__c = 'ContactTester' + i,
                                                                                                Campaign_Types__c = '');
        
            conRelAutoCreateList.add(contactRelAutoCreate);
        }

        for (Relationship_Auto_Create__c relAutoCreate : conRelAutoCreateList){
            Schema.DescribeFieldResult conFieldDescribe = UTIL_Describe.getFieldDescribe(relAutoCreate.Object__c, relAutoCreate.Field__c);
            ContactRelAutoCreateMappingModel conRelAutoCreateMapping = new ContactRelAutoCreateMappingModel(conFieldDescribe, relAutoCreate.Relationship_Type__c, relAutoCreate.Field__c);    

            conRelAutoCreateMappingList.add(conRelAutoCreateMapping);
        }

        Test.startTest();
        ContactRelationshipsModel conRelationshipsModel = ContactRelAutoCreateService.getInstance().getRelationshipsToCreateForContact(con, conRelAutoCreateMappingList);
        Test.stopTest();

        System.assertEquals(con.Id, conRelationshipsModel.contactId, 'Model should be associated with current contact record.');
        System.assertEquals(3, conRelationshipsModel.relationshipByTypeByRelatedContactId.keySet().size(), 'There should be 3 mappings for relationship type by relationship by related contact.');
        System.assertEquals(3, conRelationshipsModel.relationshipList.size(), 'There should be 3 relationships to create for current contact.');

    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getRelationshipsToCreateForContactsTrue() returns an empty ContactRelationshipsModel
    * model for a Contact record without Relationship Auto Create mappings. 
    ***************************************************************************************************************************/
    @isTest 
    private static void getRelationshipsToCreateForContactFalse(){
        ContactRelAutoCreateService.instance = new STUB_WithoutRelationshipsToCreate();

        Contact con = new Contact(Id = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                  LastName = 'Testerson');

        Test.startTest();
        System.assertEquals(null, ContactRelAutoCreateService.getInstance().getRelationshipsToCreateForContact(con, new List<ContactRelAutoCreateMappingModel>()), 'ContactRelationshipsModel should be null.');
        Test.stopTest();
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getRelationshipsToCreateForUpdatedContact() returns a populated 
    * ContactRelationshipsModel model when a mapped Relationship Auto Create field on a Contact record is updated to a non null value.
    **************************************************************************************************************************/ 
    @isTest 
    private static void getRelationshipsToCreateForUpdatedContactWithNotNullChangeTrue(){
        ContactRelAutoCreateService.instance = new STUB_WithRelationshipsToCreate();

        List<Relationship_Auto_Create__c> conRelAutoCreateList = new List<Relationship_Auto_Create__c>();
        List<ContactRelAutoCreateMappingModel> conRelAutoCreateMappingList = new List<ContactRelAutoCreateMappingModel>();

        Id fakeConId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);

        Contact newCon = new Contact(Id = fakeConId,
                                     LastName = 'Testerson',
                                     ReportsToId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType));

        Contact oldCon = new Contact(Id = fakeConId,
                                     LastName = 'Testerson',
                                     ReportsToId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType));

        for (Integer i = 0; i < 5; i++){
            Relationship_Auto_Create__c contactRelAutoCreate = new Relationship_Auto_Create__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship_Auto_Create__c.SObjectType),
                                                                                                Name = 'ConReportToAutoCreate' + i, 
                                                                                                Object__c = 'Contact',
                                                                                                Field__c = 'ReportsToId', 
                                                                                                Relationship_Type__c = 'ContactTester' + i,
                                                                                                Campaign_Types__c = '');
        
            conRelAutoCreateList.add(contactRelAutoCreate);
        }

        for (Relationship_Auto_Create__c relAutoCreate : conRelAutoCreateList){
            Schema.DescribeFieldResult conFieldDescribe = UTIL_Describe.getFieldDescribe(relAutoCreate.Object__c, relAutoCreate.Field__c);
            ContactRelAutoCreateMappingModel conRelAutoCreateMapping = new ContactRelAutoCreateMappingModel(conFieldDescribe, relAutoCreate.Relationship_Type__c, relAutoCreate.Field__c);    

            conRelAutoCreateMappingList.add(conRelAutoCreateMapping);
        }

        Test.startTest();
        ContactRelationshipsModel conRelsModel = ContactRelAutoCreateService.getInstance().getRelationshipsToCreateForUpdatedContact(newCon, oldCon, conRelAutoCreateMappingList);
        Test.stopTest();

        System.assertEquals(newCon.Id, conRelsModel.contactId, 'Contact associated with model should be current contact.');
        System.assertEquals(3, conRelsModel.relationshipByTypeByRelatedContactId.size(), 'Model should have 5 relationship by type by related contact mappings.');
        System.assertEquals(3, conRelsModel.relationshipList.size(), 'Model should have 5 relationships for contact.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getRelationshipsToCreateForUpdatedContact() returns an empty 
    * ContactRelationshipsModel model when a mapped Relationship Auto Create field on a Contact record is updated to null.
    **************************************************************************************************************************/ 
    @isTest 
    private static void getRelationshipsToCreateForUpdatedContactWithNullChangeTrue(){
        //ContactRelAutoCreateService.instance = new STUB_WithRelationshipsToCreate();

        List<Relationship_Auto_Create__c> conRelAutoCreateList = new List<Relationship_Auto_Create__c>();
        List<ContactRelAutoCreateMappingModel> conRelAutoCreateMappingList = new List<ContactRelAutoCreateMappingModel>();

        Id fakeConId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);

        Contact newCon = new Contact(Id = fakeConId,
                                     LastName = 'Testerson',
                                     ReportsToId = null);

        Contact oldCon = new Contact(Id = fakeConId,
                                     LastName = 'Testerson',
                                     ReportsToId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType));

        for (Integer i = 0; i < 5; i++){
            Relationship_Auto_Create__c contactRelAutoCreate = new Relationship_Auto_Create__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship_Auto_Create__c.SObjectType),
                                                                                                Name = 'ConReportToAutoCreate' + i, 
                                                                                                Object__c = 'Contact',
                                                                                                Field__c = 'ReportsToId', 
                                                                                                Relationship_Type__c = 'ContactTester' + i,
                                                                                                Campaign_Types__c = '');
        
            conRelAutoCreateList.add(contactRelAutoCreate);
        }

        for (Relationship_Auto_Create__c relAutoCreate : conRelAutoCreateList){
            Schema.DescribeFieldResult conFieldDescribe = UTIL_Describe.getFieldDescribe(relAutoCreate.Object__c, relAutoCreate.Field__c);
            ContactRelAutoCreateMappingModel conRelAutoCreateMapping = new ContactRelAutoCreateMappingModel(conFieldDescribe, relAutoCreate.Relationship_Type__c, relAutoCreate.Field__c);    
            conRelAutoCreateMappingList.add(conRelAutoCreateMapping);
        }

        Test.startTest();
        ContactRelationshipsModel conRelsModel = ContactRelAutoCreateService.getInstance().getRelationshipsToCreateForUpdatedContact(newCon, oldCon, new List<ContactRelAutoCreateMappingModel>());
        Test.stopTest();

        System.assertEquals(newCon.Id, conRelsModel.contactId, 'Contact associated with model should be current contact.');
        System.assertEquals(true, conRelsModel.relationshipByTypeByRelatedContactId.isEmpty(), 'Model should have no relationship by type by related contact mappings.');
        System.assertEquals(true, conRelsModel.relationshipList.isEmpty(), 'Model should have no relationships for contact.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getRelationshipsToCreateForUpdatedContact() returns an empty 
    * ContactRelationshipsModel model for an updated Contact record without a change in a mapped Relationship Auto Create field.
    **************************************************************************************************************************/ 
    @isTest 
    private static void getRelationshipsToCreateForUpdatedContactWithoutChangeTrue(){
        ContactRelAutoCreateService.instance = new STUB_WithoutRelationshipsToCreate();

        List<Relationship_Auto_Create__c> conRelAutoCreateList = new List<Relationship_Auto_Create__c>();
        List<ContactRelAutoCreateMappingModel> conRelAutoCreateMappingList = new List<ContactRelAutoCreateMappingModel>();

        Id fakeConId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
        Id fakeReportsToConId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);

        Contact newCon = new Contact(Id = fakeConId,
                                     LastName = 'Testerson',
                                     ReportsToId = fakeReportsToConId);

        Contact oldCon = new Contact(Id = fakeConId,
                                     LastName = 'Testerson',
                                     ReportsToId = fakeReportsToConId);

        for (Integer i = 0; i < 5; i++){
            Relationship_Auto_Create__c contactRelAutoCreate = new Relationship_Auto_Create__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship_Auto_Create__c.SObjectType),
                                                                                                Name = 'ConReportToAutoCreate' + i, 
                                                                                                Object__c = 'Contact',
                                                                                                Field__c = 'ReportsToId', 
                                                                                                Relationship_Type__c = 'ContactTester' + i,
                                                                                                Campaign_Types__c = '');
        
            conRelAutoCreateList.add(contactRelAutoCreate);
        }

        for (Relationship_Auto_Create__c relAutoCreate : conRelAutoCreateList){
            Schema.DescribeFieldResult conFieldDescribe = UTIL_Describe.getFieldDescribe(relAutoCreate.Object__c, relAutoCreate.Field__c);
            ContactRelAutoCreateMappingModel conRelAutoCreateMapping = new ContactRelAutoCreateMappingModel(conFieldDescribe, relAutoCreate.Relationship_Type__c, relAutoCreate.Field__c);    

            conRelAutoCreateMappingList.add(conRelAutoCreateMapping);
        }

        Test.startTest();
        ContactRelationshipsModel conRelsModel = ContactRelAutoCreateService.getInstance().getRelationshipsToCreateForUpdatedContact(newCon, oldCon, new List<ContactRelAutoCreateMappingModel>());
        Test.stopTest();

        System.assertEquals(newCon.Id, conRelsModel.contactId, 'Contact associated with model should be current contact.');
        System.assertEquals(true, conRelsModel.relationshipByTypeByRelatedContactId.isEmpty(), 'Model should have no relationship by type by related contact mappings.');
        System.assertEquals(true, conRelsModel.relationshipList.isEmpty(), 'Model should have no relationships for contact.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getRelationshipsToCreateForUpdatedContact() returns an empty
    * ContactRelationshipsModel model for an updated Contact record without Relationship Auto Create mappings.
    **************************************************************************************************************************/ 
    @isTest 
    private static void getRelationshipsToCreateForUpdatedContactFalse(){
        ContactRelAutoCreateService.instance = new STUB_WithoutRelationshipsToCreate();

        Id fakeConId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);

        Contact newCon = new Contact(Id = fakeConId,
                                     LastName = 'Testerson',
                                     ReportsToId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType));

        Contact oldCon = new Contact(Id = fakeConId,
                                     LastName = 'Testerson',
                                     ReportsToId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType));

        Test.startTest();
        ContactRelationshipsModel conRelsModel = ContactRelAutoCreateService.getInstance().getRelationshipsToCreateForUpdatedContact(newCon, oldCon, new List<ContactRelAutoCreateMappingModel>());
        Test.stopTest();

        System.assertEquals(newCon.Id, conRelsModel.contactId, 'Contact associated with model should be current contact.');
        System.assertEquals(true, conRelsModel.relationshipByTypeByRelatedContactId.isEmpty(), 'Model should have no relationship by type by related contact mappings.');
        System.assertEquals(true, conRelsModel.relationshipList.isEmpty(), 'Model should have no relationships for contact.');
    }
    
    /**************************************************************************************************************************
    * @description Test method to verify that getRelationshipsToInsertFromModel returns a list of relationships with duplicates 
    * when a ContactsRelationshipsModel model is associated with relationships and duplicates are allowed.
    **************************************************************************************************************************/
    @isTest 
    private static void getRelationshipsToInsertFromModelTrueAllowDuplicatesTrue(){
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Allow_AutoCreated_Duplicates__c = true));

        ContactsRelationshipsModel contactRelationshipsModel = new ContactsRelationshipsModel();
        List<ContactRelationshipsModel> conRelsModelsList = new List<ContactRelationshipsModel>();

        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        for (Contact con : contactsList){
            Id conFakeId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
            Id relatedConFakeId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);

            con.Id = conFakeId;

            ContactRelationshipsModel conRelModel = new ContactRelationshipsModel(con.Id);

            Relationship__c motherRel1 = new Relationship__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship__c.SObjectType),
                                                          Contact__c = conRelModel.contactId,
                                                          RelatedContact__c = relatedConFakeId,
                                                          Status__c = 'Current',
                                                          Type__c = 'Mother');

            Relationship__c motherRel2 = new Relationship__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship__c.SObjectType),
                                                            Contact__c = conRelModel.contactId,
                                                            RelatedContact__c = relatedConFakeId,
                                                            Status__c = 'Current',
                                                            Type__c = 'Mother');

            Relationship__c motherRel3 = new Relationship__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship__c.SObjectType),
                                                            Contact__c = conRelModel.contactId,
                                                            RelatedContact__c = relatedConFakeId,
                                                            Status__c = 'Current',
                                                            Type__c = 'Mother');

            conRelModel.addRelationship(motherRel1);
            conRelModel.addRelationship(motherRel2);
            conRelModel.addRelationship(motherRel3);

            conRelsModelsList.add(conRelModel);
        }

        for (ContactRelationshipsModel conRelsModel : conRelsModelsList){
            contactRelationshipsModel.addContactRelationshipsModel(conRelsModel);   
        }
        
        Test.startTest();
        List<Relationship__c> relationshipsList = ContactRelAutoCreateService.getInstance().getRelationshipsToInsertFromModel(contactRelationshipsModel);
        System.assertEquals(15, relationshipsList.size(), 'Each contact relationships model should be associated with 3 duplicate relationships.'); 
        Test.stopTest();
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getRelationshipsToInsertFromModel returns a list of unique relationships when a
    * ContactsRelationshipsModel model is associated with relationships and duplicates are not allowed.
    **************************************************************************************************************************/
    @isTest 
    private static void getRelationshipsToInsertFromModelTrueAllowDuplicatesFalse(){
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Allow_AutoCreated_Duplicates__c = false));

        ContactsRelationshipsModel contactsRelationshipsModel = new ContactsRelationshipsModel();
        List<ContactRelationshipsModel> conRelsModelsList = new List<ContactRelationshipsModel>();
        List<Relationship__c> relationshipsList = new List<Relationship__c>();
        List<Relationship__c> duplicateRelationshipsList = new List<Relationship__c>();

        List<Contact> relatedContactsList = new List<Contact>();
        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(6);
        insert contactsList;

        for (Integer i = 0; i < 3; i++){
            relatedContactsList.add(contactsList[i]);
            contactsList.remove(i);
        }

        for (Integer i = 0; i < contactsList.size(); i++){
            Relationship__c motherRel1 = new Relationship__c(Contact__c = contactsList[i].Id,
                                                             RelatedContact__c = relatedContactsList[i].Id,
                                                             Status__c = 'Current',
                                                             Type__c = 'Mother');

            Relationship__c motherRel2 = new Relationship__c(Contact__c = contactsList[i].Id,
                                                             RelatedContact__c = relatedContactsList[i].Id,
                                                             Status__c = 'Current',
                                                             Type__c = 'Mother');
            duplicateRelationshipsList.add(motherRel1.clone());
            relationshipsList.add(motherRel1);
            relationshipsList.add(motherRel2);
        }

        insert relationshipsList;


        for (Relationship__c rel : duplicateRelationshipsList){
            ContactRelationshipsModel contactRelationshipsModel = new ContactRelationshipsModel(rel.Contact__c);
            contactRelationshipsModel.addRelationship(rel);
            conRelsModelsList.add(contactRelationshipsModel);

            contactsRelationshipsModel.addContactRelationshipsModel(contactRelationshipsModel);
        }
        
        Test.startTest();
        List<Relationship__c> relationshipsResultsList = ContactRelAutoCreateService.getInstance().getRelationshipsToInsertFromModel(contactsRelationshipsModel);
        Test.stopTest();

        System.assertEquals(0, relationshipsResultsList.size(), 'Duplicate relationships for each contact relationships model should be removed.'); 
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getRelationshipsToInsertFromModel returns an empty list when an empty
    * ContactsRelationshipsModel model is specified.
    **************************************************************************************************************************/
    @isTest 
    private static void getRelationshipsToInsertFromModelFalse(){
        ContactRelAutoCreateService.instance = new STUB_WithoutRelationshipsToCreate();

        Test.startTest();
        System.assertEquals(true, ContactRelAutoCreateService.getInstance().getRelationshipsToInsertFromModel(new ContactsRelationshipsModel()).isEmpty(), 'There should be no Relationship records to insert.');
        Test.stopTest();
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getDuplicateRelationship() returns False when there is no duplicate record
    * found in the list of existing Relationship records for a Contact.
    **************************************************************************************************************************/
    @isTest 
    private static void getDuplicateRelationshipFalse(){
        ContactsRelationshipsModel contactsRelationshipsModel = new ContactsRelationshipsModel();
        Contact testCon = UTIL_UnitTestData_TEST.getContact();

        Id conFakeId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
        Id relatedConFakeId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);

        testCon.Id = conFakeId;

        ContactRelationshipsModel conRelsModel = new ContactRelationshipsModel(testCon.Id);

        Relationship__c relToCompare = new Relationship__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship__c.SObjectType),
                                                           Contact__c = conRelsModel.contactId,
                                                           RelatedContact__c = relatedConFakeId,
                                                           Status__c = 'Current',
                                                           Type__c = 'Cousin');

        Relationship__c motherRel = new Relationship__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship__c.SObjectType),
                                                        Contact__c = conRelsModel.contactId,
                                                        RelatedContact__c = relatedConFakeId,
                                                        Status__c = 'Current',
                                                        Type__c = 'Mother');

        Relationship__c sisterRel = new Relationship__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship__c.SObjectType),
                                                        Contact__c = conRelsModel.contactId,
                                                        RelatedContact__c = relatedConFakeId,
                                                        Status__c = 'Current',
                                                        Type__c = 'Sister');

        conRelsModel.addRelationship(motherRel);
        conRelsModel.addRelationship(sisterRel);

        contactsRelationshipsModel.addContactRelationshipsModel(conRelsModel);   
        
        Test.startTest();
        System.assertEquals(null, ContactRelAutoCreateService.getInstance().getDuplicateRelationship(relToCompare, contactsRelationshipsModel), 'There should be no duplicate Relationship record in Contacts Relationships model.');
        Test.stopTest();
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getDuplicateRelationship() returns True when there is a duplicate record
    * found in the list of existing Relationship records for a Contact.
    **************************************************************************************************************************/
    @isTest 
    private static void getDuplicateRelationshipTrue(){
        ContactsRelationshipsModel contactsRelationshipsModel = new ContactsRelationshipsModel();
        Contact testCon = UTIL_UnitTestData_TEST.getContact();

        Id conFakeId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
        Id relatedConFakeId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);

        testCon.Id = conFakeId;

        ContactRelationshipsModel conRelsModel = new ContactRelationshipsModel(testCon.Id);

        Relationship__c motherRel1 = new Relationship__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship__c.SObjectType),
                                                        Contact__c = conRelsModel.contactId,
                                                        RelatedContact__c = relatedConFakeId,
                                                        Status__c = 'Current',
                                                        Type__c = 'Mother');

        Relationship__c motherRel2 = new Relationship__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship__c.SObjectType),
                                                        Contact__c = conRelsModel.contactId,
                                                        RelatedContact__c = relatedConFakeId,
                                                        Status__c = 'Current',
                                                        Type__c = 'Mother');

        conRelsModel.addRelationship(motherRel1);
        conRelsModel.addRelationship(motherRel2);

        contactsRelationshipsModel.addContactRelationshipsModel(conRelsModel);   
        
        Test.startTest();
        System.assertEquals(true, ContactRelAutoCreateService.getInstance().getDuplicateRelationship(motherRel1, contactsRelationshipsModel) != null, 'There should be a duplicate Relationship record for the Contacts Relationships model.');
        Test.stopTest();
    }


    /**************************************************************************************************************************
    ****************************************************** STUBS **************************************************************
    **************************************************************************************************************************/

    /************************************************************************************************************
    * @description Stub class to simulate positive responses from getRelationshipsToCreateForContacts and 
    * getRelationshipsToCreateForContact methods in ContactRelAutoCreateService.
    *************************************************************************************************************/ 
    private class STUB_WithRelationshipsToCreate extends ContactRelAutoCreateService {
        @TestVisible
        public override ContactsRelationshipsModel getRelationshipsToCreateForContacts(List<Contact> contactsList, List<ContactRelAutoCreateMappingModel> contactRelationShipAutoCreateMapModelsList){
            
            ContactsRelationshipsModel contactsRelsModel = new ContactsRelationshipsModel();
            
            List<ContactRelationshipsModel> conRelsModelsList = new List<ContactRelationshipsModel>();            
            Map<Id, Map<String, Relationship__c>> relationshipByTypeByRelatedContactId = new Map<Id, Map<String, Relationship__c>>();
            
            for (Contact con : contactsList){
                ContactRelationshipsModel conRelsModel = new ContactRelationshipsModel(con.Id);
                conRelsModelsList.add(conRelsModel);
            }

            for (ContactRelationshipsModel contactRelationshipsModel : conRelsModelsList){ // create 3 relationships per contact 

                Relationship__c wifeRel = new Relationship__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship__c.SObjectType),
                                                             Contact__c = contactRelationshipsModel.contactId,
                                                             RelatedContact__c = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                                             Status__c = 'Current',
                                                             Type__c = 'Wife');

                Relationship__c motherRel = new Relationship__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship__c.SObjectType),
                                                                Contact__c = contactRelationshipsModel.contactId,
                                                                RelatedContact__c = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                                                Status__c = 'Current',
                                                                Type__c = 'Mother');

                Relationship__c cousinRel = new Relationship__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship__c.SObjectType),
                                                                Contact__c = contactRelationshipsModel.contactId,
                                                                RelatedContact__c = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                                                Status__c = 'Current',
                                                                Type__c = 'Cousin');
                
                contactRelationshipsModel.addRelationship(wifeRel);
                contactRelationshipsModel.addRelationship(motherRel);
                contactRelationshipsModel.addRelationship(cousinRel);

                contactsRelsModel.addContactRelationshipsModel(contactRelationshipsModel);
            }

            return contactsRelsModel;
            
        }
        
        @TestVisible
        public override ContactRelationshipsModel getRelationshipsToCreateForContact(Contact currentCon, List<ContactRelAutoCreateMappingModel> contactRelationShipAutoCreateMapModelsList){            

            ContactRelationshipsModel conRelationshipsModel = new ContactRelationshipsModel(currentCon.Id);

            Relationship__c wifeRel = new Relationship__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship__c.SObjectType),
                                                          Contact__c = conRelationshipsModel.contactId,
                                                          RelatedContact__c = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                                          Status__c = 'Current',
                                                          Type__c = 'Wife');

            Relationship__c motherRel = new Relationship__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship__c.SObjectType),
                                                            Contact__c = conRelationshipsModel.contactId,
                                                            RelatedContact__c = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                                            Status__c = 'Current',
                                                            Type__c = 'Mother');

            Relationship__c cousinRel = new Relationship__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship__c.SObjectType),
                                                            Contact__c = conRelationshipsModel.contactId,
                                                            RelatedContact__c = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                                            Status__c = 'Current',
                                                            Type__c = 'Cousin');
                
            conRelationshipsModel.addRelationship(wifeRel);
            conRelationshipsModel.addRelationship(motherRel);
            conRelationshipsModel.addRelationship(cousinRel);

            return conRelationshipsModel;
        }

        @TestVisible 
        public override ContactRelationshipsModel getRelationshipsToCreateForUpdatedContact(Contact newContact, Contact oldContact, List<ContactRelAutoCreateMappingModel> contactRelationShipAutoCreateMapModelsList){
            ContactRelationshipsModel conRelationshipsModel = new ContactRelationshipsModel(newContact.Id);

            Relationship__c wifeRel = new Relationship__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship__c.SObjectType),
                                                          Contact__c = conRelationshipsModel.contactId,
                                                          RelatedContact__c = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                                          Status__c = 'Current',
                                                          Type__c = 'Wife');

            Relationship__c motherRel = new Relationship__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship__c.SObjectType),
                                                            Contact__c = conRelationshipsModel.contactId,
                                                            RelatedContact__c = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                                            Status__c = 'Current',
                                                            Type__c = 'Mother');

            Relationship__c cousinRel = new Relationship__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship__c.SObjectType),
                                                            Contact__c = conRelationshipsModel.contactId,
                                                            RelatedContact__c = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                                            Status__c = 'Current',
                                                            Type__c = 'Cousin');
                
            conRelationshipsModel.addRelationship(wifeRel);
            conRelationshipsModel.addRelationship(motherRel);
            conRelationshipsModel.addRelationship(cousinRel);

            return conRelationshipsModel;
        }
    }

    /************************************************************************************************************
    * @description Stub class to simulate negative responses from getRelationshipsToCreateForContacts and 
    * getRelationshipsToCreateForContact methods in ContactRelAutoCreateService.
    *************************************************************************************************************/ 
    private class STUB_WithoutRelationshipsToCreate extends ContactRelAutoCreateService {

        @TestVisible
        public override ContactsRelationshipsModel getRelationshipsToCreateForContacts(List<Contact> contactsList, List<ContactRelAutoCreateMappingModel> contactRelationShipAutoCreateMapModelsList){
            return new ContactsRelationshipsModel();
        }

        @TestVisible
        public override ContactRelationshipsModel getRelationshipsToCreateForContact(Contact contact, List<ContactRelAutoCreateMappingModel> contactRelationShipAutoCreateMapModelsList){
            return null;
        }

        @TestVisible 
        public override ContactRelationshipsModel getRelationshipsToCreateForUpdatedContact(Contact newContact, Contact oldContact, List<ContactRelAutoCreateMappingModel> contactRelationShipAutoCreateMapModelsList){
            return new ContactRelationshipsModel(newContact.Id);
        }

        @TestVisible
        public override List<Relationship__c> getRelationshipsToInsertFromModel(ContactsRelationshipsModel contactsRelationshipsModel){
            return new List<Relationship__c>();
        }
    }
}
