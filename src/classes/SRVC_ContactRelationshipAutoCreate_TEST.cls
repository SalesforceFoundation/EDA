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
* @description Test class for SRVC_ContactRelationshipAutoCreate
*/
@isTest 
public with sharing class SRVC_ContactRelationshipAutoCreate_TEST {

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * SRVC_ContactRelationshipAutoCreate class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        SRVC_ContactRelationshipAutoCreate srvcConRelAutoCreate = SRVC_ContactRelationshipAutoCreate.getInstance();
        System.assertEquals(SRVC_ContactRelationshipAutoCreate.instance, srvcConRelAutoCreate, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, srvcConRelAutoCreate != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance() returns the existing instance of the 
    * SRVC_ContactRelationshipAutoCreate class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        SRVC_ContactRelationshipAutoCreate srvcConRelAutoCreateInstance1 = SRVC_ContactRelationshipAutoCreate.getInstance();
        SRVC_ContactRelationshipAutoCreate srvcConRelAutoCreateInstance2 = SRVC_ContactRelationshipAutoCreate.getInstance();
 
        System.assertEquals(SRVC_ContactRelationshipAutoCreate.instance, srvcConRelAutoCreateInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(srvcConRelAutoCreateInstance1, srvcConRelAutoCreateInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, srvcConRelAutoCreateInstance1 != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getRelationshipsToCreateForContactsTrue() returns a MODL_ContactsRelationships
    * model for a list of Contact records with MODL_ConRelationshipAutoCreateMapping. 
    ***************************************************************************************************************************/
    @isTest 
    private static void getRelationshipsToCreateForContactsTrue(){
        SRVC_ContactRelationshipAutoCreate.instance = new STUB_WithRelationshipsToCreate();

        List<Relationship_Auto_Create__c> conRelAutoCreateList = new List<Relationship_Auto_Create__c>();
        List<MODL_ConRelationshipAutoCreateMapping> conRelAutoCreateMappingList = new List<MODL_ConRelationshipAutoCreateMapping>();

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
            MODL_ConRelationshipAutoCreateMapping conRelAutoCreateMapping = new MODL_ConRelationshipAutoCreateMapping(conFieldDescribe, relAutoCreate.Relationship_Type__c, String.valueOf(relAutoCreate));    
            conRelAutoCreateMappingList.add(conRelAutoCreateMapping);
        }
        
        Test.startTest();
        MODL_ContactsRelationships consRelsModel = SRVC_ContactRelationshipAutoCreate.getInstance().getRelationshipsToCreateForContacts(contactsList, conRelAutoCreateMappingList);
        Test.stopTest();
    
        System.assertEquals(5, consRelsModel.contactIdsSet.size(), 'There should be 5 contacts with relationships to create.');
        System.assertEquals(15, consRelsModel.relatedContactIdSet.size(), 'There should be 15 related contacts associated with relationships to create.');
        //System.assertEquals(15, consRelsModel.relationshipList.size(), 'There should be 15 relationships to be created.');
        System.assertEquals(true, consRelsModel.relationshipList.isEmpty(), 'There should be no relationships to be created.');
        System.assertEquals(5, consRelsModel.contactRelationshipsModelsByContactId.keySet().size(), 'There should be 5 ContactRelationships models associated with relationships to create.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getRelationshipsToCreateForContactsTrue() returns an empty MODL_ContactsRelationships
    * model for a list of Contact records without existing MODL_ConRelationshipAutoCreateMapping. 
    ***************************************************************************************************************************/
    @isTest 
    private static void getRelationshipsToCreateForContactsFalse(){
        SRVC_ContactRelationshipAutoCreate.instance = new STUB_WithoutRelationshipsToCreate();

        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        for (Contact con : contactsList){
            con.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
        }

        Test.startTest();
        MODL_ContactsRelationships consRelsModel = SRVC_ContactRelationshipAutoCreate.getInstance().getRelationshipsToCreateForContacts(contactsList, new List<MODL_ConRelationshipAutoCreateMapping>());
        Test.stopTest();

        System.assertEquals(true, consRelsModel.contactIdsSet.isEmpty(), 'There should be no contacts with relationships to create.');
        System.assertEquals(true, consRelsModel.relatedContactIdSet.isEmpty(), 'There should be no related contacts associated with relationships to create.');
        System.assertEquals(true, consRelsModel.relationshipList.isEmpty(), 'There should be no relationships to be created.');
        System.assertEquals(true, consRelsModel.contactRelationshipsModelsByContactId.keySet().isEmpty(), 'There should be no ContactRelationships models associated with relationships to create.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getRelationshipsToCreateForContactsTrue() returns asdfsadfasdfasdfasdfsdfasdf an empty MODL_ContactRelationships
    * model for a Contact record without existing MODL_ConRelationshipAutoCreateMapping. 
    ***************************************************************************************************************************/
    @isTest 
    private static void getRelationshipsToCreateForContactTrue(){
        SRVC_ContactRelationshipAutoCreate.instance = new STUB_WithRelationshipsToCreate();
        List<MODL_ConRelationshipAutoCreateMapping> conRelAutoCreateMappingList = new List<MODL_ConRelationshipAutoCreateMapping>();

        Contact con = new Contact(Id = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                  LastName = 'Testerson');

        // TODO: start here
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getRelationshipsToCreateForContactsTrue() returns an empty MODL_ContactRelationships
    * model for a Contact record without existing MODL_ConRelationshipAutoCreateMapping. 
    ***************************************************************************************************************************/
    @isTest 
    private static void getRelationshipsToCreateForContactFalse(){
        SRVC_ContactRelationshipAutoCreate.instance = new STUB_WithoutRelationshipsToCreate();

        Contact con = new Contact(Id = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                  LastName = 'Testerson');

        Test.startTest();
        System.assertEquals(null, SRVC_ContactRelationshipAutoCreate.getInstance().getRelationshipsToCreateForContact(con, new List<MODL_ConRelationshipAutoCreateMapping>()), 'ContactRelationshipsModel should be null.');
        Test.stopTest();
    }

    /**************************************************************************************************************************
    ****************************************************** STUBS **************************************************************
    **************************************************************************************************************************/

    /************************************************************************************************************
    * @description Stub class to simulate positive responses from getRelationshipsToCreateForContacts and 
    * getRelationshipsToCreateForContact methods in SRVC_ContactRelationshipAutoCreate.
    *************************************************************************************************************/ 
    private class STUB_WithRelationshipsToCreate extends SRVC_ContactRelationshipAutoCreate {
        @TestVisible
        public override MODL_ContactsRelationships getRelationshipsToCreateForContacts(List<Contact> contactsList, List<MODL_ConRelationshipAutoCreateMapping> contactRelationShipAutoCreateMapModelsList){
            
            MODL_ContactsRelationships contactsRelsModel = new MODL_ContactsRelationships();
            
            List<MODL_ContactRelationships> conRelsModelsList = new List<MODL_ContactRelationships>();            
            Map<Id, Map<String, Relationship__c>> relationshipByTypeByRelatedContactId = new Map<Id, Map<String, Relationship__c>>();
            
            for (Integer i = 0; i < 5; i++){ // create 5 contactRelationshipsmodels
                Id fakeConId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
                MODL_ContactRelationships conRelsModel = new MODL_ContactRelationships(fakeConId);
                conRelsModelsList.add(conRelsModel);
            }

            for (MODL_ContactRelationships contactRelationshipsModel : conRelsModelsList){ // create 3 relationships per contact 

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

                contactsRelsModel.addContactRelationshipsModel(contactRelationshipsModel); // add current model to CONTACTSRelationshipSModel
            }

            return contactsRelsModel;
            
        }
        
        // @TestVisible
        // public override MODL_ContactRelationships getRelationshipsToCreateForContact(Contact contact, List<MODL_ConRelationshipAutoCreateMapping> contactRelationShipAutoCreateMapModelsList){
        //     List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        //     for (Contact con : contactsList){
        //         con.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
        //     }
            
        //     Id fakeConId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
        //     MODL_ContactRelationships conRelationshipsModel = new MODL_ContactRelationships(fakeConId);

        //     return conRelationshipsModel;
        // }
    }

    /************************************************************************************************************
    * @description Stub class to simulate negative responses from getRelationshipsToCreateForContacts and 
    * getRelationshipsToCreateForContact methods in SRVC_ContactRelationshipAutoCreate.
    *************************************************************************************************************/ 
    private class STUB_WithoutRelationshipsToCreate extends SRVC_ContactRelationshipAutoCreate {

        @TestVisible
        public override MODL_ContactsRelationships getRelationshipsToCreateForContacts(List<Contact> contactsList, List<MODL_ConRelationshipAutoCreateMapping> contactRelationShipAutoCreateMapModelsList){
            return new MODL_ContactsRelationships();
        }

        @TestVisible
        public override MODL_ContactRelationships getRelationshipsToCreateForContact(Contact contact, List<MODL_ConRelationshipAutoCreateMapping> contactRelationShipAutoCreateMapModelsList){
            return null;
        }
    }
}
