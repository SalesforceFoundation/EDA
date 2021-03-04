/*
    Copyright (c) 2020 Salesforce.org
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
* @date 2020
* @group Contact Relationships
* @group-content ../../ApexDocContent/Relationships.htm
* @description Testing for the Contact Relationship trigger functionality.
*/
@isTest
private with sharing class REL_Relationships_Con_TEST {

    /*********************************************************************************************************
    ****************************** RELATIONSHIP AUTO CREATION FUNCTIONAL TESTS *******************************
    *********************************************************************************************************/

    /*********************************************************************************************************
    * @description Test to verify that inserting a Contact record without an Auto Creation mapping does not
    * generate a relationship or reciprocal relationship record.
    *********************************************************************************************************/
    @isTest 
    private static void insertContactWithoutRelationshipAutoCreate(){

        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);

        Test.startTest();
        insert contactsList;
        Test.stopTest();

        List<Relationship__c> relationshipResultsList = [SELECT Id, 
                                                                Contact__c,
                                                                RelatedContact__c,
                                                                Status__c,
                                                                Type__c
                                                        FROM Relationship__c
                                                        WHERE Contact__c IN :contactsList
                                                        OR RelatedContact__c IN :contactsList];

        System.assertEquals(true, relationshipResultsList.isEmpty(), 'There should be no auto created relationship records.');
    }

    /*********************************************************************************************************
    * @description Test to verify that inserting a Contact record with invalid Auto Creation 
    * mappings results in an error when Contact is created and all fields associated with invalid mappings are populated.
    *********************************************************************************************************/
    @isTest 
    private static void insertContactWithInvalidRelationshipsAutoCreate(){
        List<Relationship_Auto_Create__c> relAutoCreateList = new List<Relationship_Auto_Create__c>();

        Relationship_Auto_Create__c relAutoCreateInValid1 = new Relationship_Auto_Create__c(Name = 'ConReportToAutoCreateInvalid1', 
                                                                                         Object__c = 'Contact',
                                                                                         Field__c = 'FirstName', 
                                                                                         Relationship_Type__c = 'Testee',
                                                                                         Campaign_Types__c = '');

        Relationship_Auto_Create__c relAutoCreateInValid2 = new Relationship_Auto_Create__c(Name = 'ConReportToAutoCreateInvalid2', 
                                                                                         Object__c = 'Contact',
                                                                                         Field__c = 'LastName', 
                                                                                         Relationship_Type__c = 'Tester',
                                                                                         Campaign_Types__c = '');

        relAutoCreateList.add(relAutoCreateInValid1);
        relAutoCreateList.add(relAutoCreateInValid2);
        insert relAutoCreateList;

        List<Relationship_Lookup__c> relationshipLookupsList = new List<Relationship_Lookup__c>();
        Relationship_Lookup__c testerRelationshipLookup = new Relationship_Lookup__c(Name = 'Tester', 
                                                                                   Male__c = 'Testee-Male',
                                                                                   Female__c = 'Testee-Female', 
                                                                                   Neutral__c = 'Testee');

        Relationship_Lookup__c testeeRelationshipLookup = new Relationship_Lookup__c(Name = 'Testee', 
                                                                                   Male__c = 'Tester-Male',
                                                                                   Female__c = 'Tester-Female', 
                                                                                   Neutral__c = 'Tester');

        relationshipLookupsList.add(TesterRelationshipLookup);
        relationshipLookupsList.add(TesteeRelationshipLookup);
        insert relationshipLookupsList;

        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        for (Integer i = 0; i < contactsList.size(); i++){
            contactsList[i].FirstName = 'Test';
            contactsList[i].LastName = 'Contact ' + i;
        }

        Test.startTest();
        try{
            insert contactsList;
        } catch (DmlException e){
            System.assertEquals(true, e.getMessage().contains(Label.AutoCreateFieldError), 'Inserting a Contact with invalid Auto Create mappings should display an error.');
        }
        Test.stopTest();

        List<Relationship__c> relationshipResultsList = [SELECT Id, 
                                                                Contact__c,
                                                                RelatedContact__c,
                                                                Status__c,
                                                                Type__c
                                                        FROM Relationship__c
                                                        WHERE Contact__c IN :contactsList];

        System.assertEquals(true, relationshipResultsList.isEmpty(), 'No Contact records should be inserted when invalid Auto Create mappings.');
    }

    /*********************************************************************************************************
    * @description Test to verify that inserting a Contact record with invalid Auto Creation 
    * mappings results in an error even when Contact is created and all fields associated with invalid mappings are not populated.
    *********************************************************************************************************/
    @isTest 
    private static void insertContactWithInvalidRelationshipsAutoCreateUnpopulated(){
        List<Relationship_Auto_Create__c> relAutoCreateList = new List<Relationship_Auto_Create__c>();

        Relationship_Auto_Create__c relAutoCreateInValid1 = new Relationship_Auto_Create__c(Name = 'ConReportToAutoCreateInvalid1', 
                                                                                         Object__c = 'Contact',
                                                                                         Field__c = 'FirstName', 
                                                                                         Relationship_Type__c = 'Testee',
                                                                                         Campaign_Types__c = '');

        Relationship_Auto_Create__c relAutoCreateInValid2 = new Relationship_Auto_Create__c(Name = 'ConReportToAutoCreateInvalid2', 
                                                                                         Object__c = 'Contact',
                                                                                         Field__c = 'Birthdate', 
                                                                                         Relationship_Type__c = 'Tester',
                                                                                         Campaign_Types__c = '');

        relAutoCreateList.add(relAutoCreateInValid1);
        relAutoCreateList.add(relAutoCreateInValid2);
        insert relAutoCreateList;

        List<Relationship_Lookup__c> relationshipLookupsList = new List<Relationship_Lookup__c>();
        Relationship_Lookup__c testerRelationshipLookup = new Relationship_Lookup__c(Name = 'Tester', 
                                                                                   Male__c = 'Testee-Male',
                                                                                   Female__c = 'Testee-Female', 
                                                                                   Neutral__c = 'Testee');

        Relationship_Lookup__c testeeRelationshipLookup = new Relationship_Lookup__c(Name = 'Testee', 
                                                                                   Male__c = 'Tester-Male',
                                                                                   Female__c = 'Tester-Female', 
                                                                                   Neutral__c = 'Tester');

        relationshipLookupsList.add(TesterRelationshipLookup);
        relationshipLookupsList.add(TesteeRelationshipLookup);
        insert relationshipLookupsList;

        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        for (Integer i = 0; i < contactsList.size(); i++){
            contactsList[i].LastName = 'Contact ' + i;
        }

        Test.startTest();
        try{
            insert contactsList;
        } catch (DmlException e){
            System.assertEquals(true, e.getMessage().contains(Label.AutoCreateFieldError), 'Inserting a Contact with invalid Auto Create mappings should display an error even when mapped fields are not populated.');
        }
        Test.stopTest();

        List<Relationship__c> relationshipResultsList = [SELECT Id, 
                                                                Contact__c,
                                                                RelatedContact__c,
                                                                Status__c,
                                                                Type__c
                                                        FROM Relationship__c
                                                        WHERE Contact__c IN :contactsList];

        System.assertEquals(true, relationshipResultsList.isEmpty(), 'No Contact records should be inserted when invalid Auto Create mappings.');
    }

    /*********************************************************************************************************
    * @description Test to verify that inserting a Contact record with both valid and invalid Auto Creation 
    * mappings results in an error when Contact is created and field associated with invalid mapping is populated.
    *********************************************************************************************************/
    @isTest 
    private static void insertContactWithValidAndInvalidRelationshipsAutoCreateInvalidPopulated(){
        List<Relationship_Auto_Create__c> relAutoCreateList = new List<Relationship_Auto_Create__c>();

        Relationship_Auto_Create__c relAutoCreateInvalid = new Relationship_Auto_Create__c(Name = 'ConReportToAutoCreateInvalid', 
                                                                                         Object__c = 'Contact',
                                                                                         Field__c = 'LastName', 
                                                                                         Relationship_Type__c = 'Testee',
                                                                                         Campaign_Types__c = '');

        Relationship_Auto_Create__c relAutoCreateValid = new Relationship_Auto_Create__c(Name = 'ConReportToAutoCreateValid', 
                                                                                         Object__c = 'Contact',
                                                                                         Field__c = 'ReportsToId', 
                                                                                         Relationship_Type__c = 'Tester',
                                                                                         Campaign_Types__c = '');

        relAutoCreateList.add(relAutoCreateInvalid);
        relAutoCreateList.add(relAutoCreateValid);
        insert relAutoCreateList;

        List<Relationship_Lookup__c> relationshipLookupsList = new List<Relationship_Lookup__c>();
        Relationship_Lookup__c testerRelationshipLookup = new Relationship_Lookup__c(Name = 'Tester', 
                                                                                   Male__c = 'Testee-Male',
                                                                                   Female__c = 'Testee-Female', 
                                                                                   Neutral__c = 'Testee');

        Relationship_Lookup__c testeeRelationshipLookup = new Relationship_Lookup__c(Name = 'Testee', 
                                                                                   Male__c = 'Tester-Male',
                                                                                   Female__c = 'Tester-Female', 
                                                                                   Neutral__c = 'Tester');

        relationshipLookupsList.add(TesterRelationshipLookup);
        relationshipLookupsList.add(TesteeRelationshipLookup);
        insert relationshipLookupsList;
        
        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        for (Integer i = 0; i < contactsList.size(); i++){
            contactsList[i].FirstName = 'Test';
            contactsList[i].LastName = 'Contact ' + i;
        }

        Test.startTest();
        try{
            insert contactsList;
        } catch (DmlException e){
            System.assertEquals(true, e.getMessage().contains(Label.AutoCreateFieldError), 'Inserting a Contact with invalid Auto Create mappings should display an error.');
        }
        Test.stopTest();

        List<Relationship__c> relationshipResultsList = [SELECT Id, 
                                                                Contact__c,
                                                                RelatedContact__c,
                                                                Status__c,
                                                                Type__c
                                                        FROM Relationship__c
                                                        WHERE Contact__c IN :contactsList];

        System.assertEquals(true, relationshipResultsList.isEmpty(), 'No Contact records should be inserted when invalid Auto Create mappings.');
    }

    /*********************************************************************************************************
    * @description Test to verify that inserting a Contact record with both valid and invalid Auto Creation 
    * mappings results in an error even when Contact is created and field associated with invalid mapping is not populated.
    *********************************************************************************************************/
    @isTest 
    private static void insertContactWithValidAndInvalidRelationshipsAutoCreateInvalidUnpopulated(){
        Contact reportContact = UTIL_UnitTestData_TEST.getMultipleTestContacts(1)[0];
        insert reportContact;
        
        List<Relationship_Auto_Create__c> relAutoCreateList = new List<Relationship_Auto_Create__c>();

        Relationship_Auto_Create__c relAutoCreateInvalid = new Relationship_Auto_Create__c(Name = 'ConReportToAutoCreateInvalid', 
                                                                                         Object__c = 'Contact',
                                                                                         Field__c = 'FirstName', 
                                                                                         Relationship_Type__c = 'Testee',
                                                                                         Campaign_Types__c = '');

        Relationship_Auto_Create__c relAutoCreateValid = new Relationship_Auto_Create__c(Name = 'ConReportToAutoCreateValid', 
                                                                                         Object__c = 'Contact',
                                                                                         Field__c = 'ReportsToId', 
                                                                                         Relationship_Type__c = 'Tester',
                                                                                         Campaign_Types__c = '');

        relAutoCreateList.add(relAutoCreateInvalid);
        relAutoCreateList.add(relAutoCreateValid);
        insert relAutoCreateList;

        List<Relationship_Lookup__c> relationshipLookupsList = new List<Relationship_Lookup__c>();
        Relationship_Lookup__c testerRelationshipLookup = new Relationship_Lookup__c(Name = 'Tester', 
                                                                                   Male__c = 'Testee-Male',
                                                                                   Female__c = 'Testee-Female', 
                                                                                   Neutral__c = 'Testee');

        Relationship_Lookup__c testeeRelationshipLookup = new Relationship_Lookup__c(Name = 'Testee', 
                                                                                   Male__c = 'Tester-Male',
                                                                                   Female__c = 'Tester-Female', 
                                                                                   Neutral__c = 'Tester');

        relationshipLookupsList.add(TesterRelationshipLookup);
        relationshipLookupsList.add(TesteeRelationshipLookup);
        insert relationshipLookupsList;
        
        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        for (Integer i = 0; i < contactsList.size(); i++){
            contactsList[i].LastName = 'Contact ' + i;
            contactsList[i].ReportsToId = reportContact.Id;
        }

        Test.startTest();
        try{
            insert contactsList;
        } catch (DmlException e){
            System.assertEquals(true, e.getMessage().contains(Label.AutoCreateFieldError), 'Inserting a Contact with invalid Auto Create mappings should display an error.');
        }
        Test.stopTest();

        List<Relationship__c> relationshipResultsList = [SELECT Id, 
                                                                Contact__c,
                                                                RelatedContact__c,
                                                                Status__c,
                                                                Type__c
                                                        FROM Relationship__c
                                                        WHERE Contact__c IN :contactsList];

        System.assertEquals(true, relationshipResultsList.isEmpty(), 'No Contact records should be inserted when invalid Auto Create mappings.');
    }

    /*********************************************************************************************************
    * @description Test to verify that when Relationship Auto Creation is enabled, inserting a Contact record 
    * with an Auto Creation mapped field populated generates the expected relationship  and reciprocal 
    * reciprocal relationship records.
    *********************************************************************************************************/
    @isTest
    private static void insertContactWithRelationshipAutoCreateFieldPopulated() {
        Relationship_Auto_Create__c contactReportToRelAutoCreate = new Relationship_Auto_Create__c(Name = 'ConReportToAutoCreate', 
                                                                                                   Object__c = 'Contact',
                                                                                                   Field__c = 'ReportsToId', 
                                                                                                   Relationship_Type__c = 'Tester',
                                                                                                   Campaign_Types__c = '');

        insert contactReportToRelAutoCreate;

        List<Relationship_Lookup__c> relationshipLookupsList = new List<Relationship_Lookup__c>();
        Relationship_Lookup__c testerRelationshipLookup = new Relationship_Lookup__c(Name = 'Tester', 
                                                                                   Male__c = 'Testee-Male',
                                                                                   Female__c = 'Testee-Female', 
                                                                                   Neutral__c = 'Testee');

        Relationship_Lookup__c testeeRelationshipLookup = new Relationship_Lookup__c(Name = 'Testee', 
                                                                                   Male__c = 'Tester-Male',
                                                                                   Female__c = 'Tester-Female', 
                                                                                   Neutral__c = 'Tester');

        relationshipLookupsList.add(TesterRelationshipLookup);
        relationshipLookupsList.add(TesteeRelationshipLookup);
        insert relationshipLookupsList;

        List<Contact> relatedContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        for (Integer i = 0; i < relatedContactsList.size(); i++){
            relatedContactsList[i].FirstName = 'Test';
            relatedContactsList[i].LastName = 'Related ' + i; 
        }
        insert relatedContactsList;
        
        Map<Id, Contact> relatedContactsById = new Map<Id, Contact>();
        for (Contact con : relatedContactsList){
            relatedContactsById.put(con.Id, con);
        }

        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        for (Integer i = 0; i < contactsList.size(); i++){
            contactsList[i].FirstName = 'Test';
            contactsList[i].LastName = 'Contact ' + i;
            contactsList[i].ReportsToId = relatedContactsList[i].Id;
        }

        Test.startTest();
        insert contactsList;
        Test.stopTest();

        Map<Id, Contact> contactsById = new Map<Id, Contact>();
        for (Contact con : contactsList){
            contactsById.put(con.Id, con);
        }

        List<Relationship__c> relationshipResultsList = [SELECT Id, 
                                                                Contact__c,
                                                                RelatedContact__c,
                                                                Status__c,
                                                                Type__c
                                                        FROM Relationship__c
                                                        WHERE Contact__c IN :contactsList
                                                        OR Contact__c IN :relatedContactsList];

        Map<Id, Relationship__c> relationshipsByContactId = new Map<Id, Relationship__c>();
        for (Relationship__c rel : relationshipResultsList){
            relationshipsByContactId.put(rel.Contact__c, rel);
        }

        Map<Id, List<Relationship__c>> relationshipsListByContactId = new Map<Id, List<Relationship__c>>();
        for (Relationship__c rel : relationshipResultsList){
            List<Relationship__c> associatedRelationshipsList;

            if (contactsById.containsKey(rel.Contact__c)){
                associatedRelationshipsList = relationshipsListByContactId.get(rel.Contact__c);
            } else {
                associatedRelationshipsList = relationshipsListByContactId.get(rel.relatedContact__c);
            }
            
            if (associatedRelationshipsList == null){
                associatedRelationshipsList = new List<Relationship__c>();
            }

            associatedRelationshipsList.add(rel);
            relationshipsListByContactId.put(rel.Contact__c, associatedRelationshipsList);
        }

        System.assertEquals(10, relationshipResultsList.size(), 'There should be 10 auto created relationship records.');

        for (Id contactId : relationshipsListByContactId.keySet()){
            System.assertEquals(2, relationshipsListByContactId.get(contactId).size(), 'Each contact should be associated with 1 relationship and 1 reciprocal relationship.');
        }

        for (Relationship__c rel : relationshipsByContactId.values()){
            System.assertEquals(true, relationshipsByContactId.containsKey(rel.RelatedContact__c), 'Each relationship has a corresponding reciprocal relationship record.');
            System.assertEquals(rel.Contact__c, relationshipsByContactId.get(rel.RelatedContact__c).RelatedContact__c, 'The related contact on the reciprocal relationships should match the contact on the current relationship.');
            System.assertEquals('Current', rel.Status__c, 'Relationship status should be Current.');

            if (rel.Type__c.contains('Tester')){
                System.assertEquals(true, contactsById.containsKey(rel.Contact__c), 'Relationship contact should correspond with an inserted contact.');
                System.assertEquals(true, relatedContactsById.containsKey(rel.RelatedContact__c), 'Relationship should be associated with a related contact.');
            } else {
                System.assertEquals(true, relatedContactsById.containsKey(rel.Contact__c), 'Relationship contact should correspond with a related contact.');
                System.assertEquals(true, contactsById.containsKey(rel.RelatedContact__c), 'Relationship should be associated with an inserted contact.');
            }
        }
    }

    /*********************************************************************************************************
    * @description Test to verify that when Relationship Auto Creation is enabled, inserting a Contact record 
    * with an Auto Creation mapping, but leaving the corresponding field unpopulated on the contact inserted
    * does not generate any relationships.
    *********************************************************************************************************/
    @isTest
    private static void insertContactWithRelationshipAutoCreateFieldUnpopulated() {
        Relationship_Auto_Create__c contactReportToRelAutoCreate = new Relationship_Auto_Create__c(Name = 'ConReportToAutoCreate', 
                                                                                                   Object__c = 'Contact',
                                                                                                   Field__c = 'ReportsToId', 
                                                                                                   Relationship_Type__c = 'Tester',
                                                                                                   Campaign_Types__c = '');

        insert contactReportToRelAutoCreate;

        List<Relationship_Lookup__c> relationshipLookupsList = new List<Relationship_Lookup__c>();
        Relationship_Lookup__c testerRelationshipLookup = new Relationship_Lookup__c(Name = 'Tester', 
                                                                                   Male__c = 'Testee-Male',
                                                                                   Female__c = 'Testee-Female', 
                                                                                   Neutral__c = 'Testee');

        Relationship_Lookup__c testeeRelationshipLookup = new Relationship_Lookup__c(Name = 'Testee', 
                                                                                   Male__c = 'Tester-Male',
                                                                                   Female__c = 'Tester-Female', 
                                                                                   Neutral__c = 'Tester');

        relationshipLookupsList.add(TesterRelationshipLookup);
        relationshipLookupsList.add(TesteeRelationshipLookup);
        insert relationshipLookupsList;
    
        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        for (Integer i = 0; i < contactsList.size(); i++){
            contactsList[i].FirstName = 'Test';
            contactsList[i].LastName = 'Contact ' + i;
        }

        Test.startTest();
        insert contactsList;
        Test.stopTest();

        Map<Id, Contact> contactsById = new Map<Id, Contact>();
        for (Contact con : contactsList){
            contactsById.put(con.Id, con);
        }

        List<Relationship__c> relationshipResultsList = [SELECT Id, 
                                                                Contact__c,
                                                                RelatedContact__c,
                                                                Status__c,
                                                                Type__c
                                                        FROM Relationship__c
                                                        WHERE Contact__c IN :contactsList
                                                        OR RelatedContact__c IN :contactsList];
        
        System.assertEquals(true, relationshipResultsList.isEmpty(), 'No relationships should be created when mapped field is not populated.');
    }

    /*********************************************************************************************************
    * @description Test to verify that when Relationship Auto Creation is enabled, inserting a Contact record 
    * without populating a mapped Auto Creation field will not generate any relationship records.
    *********************************************************************************************************/
    @isTest 
    private static void insertContactWithoutRelationshipAutoCreateFieldPopulated(){
        Relationship_Auto_Create__c contactReportToRelAutoCreate = new Relationship_Auto_Create__c(Name = 'ConReportToAutoCreate', 
                                                                                                   Object__c = 'Contact',
                                                                                                   Field__c = 'ReportsToId', 
                                                                                                   Relationship_Type__c = 'Tester',
                                                                                                   Campaign_Types__c = '');

        insert contactReportToRelAutoCreate;

        List<Relationship_Lookup__c> relationshipLookupsList = new List<Relationship_Lookup__c>();
        Relationship_Lookup__c testerRelationshipLookup = new Relationship_Lookup__c(Name = 'Tester', 
                                                                                   Male__c = 'Testee-Male',
                                                                                   Female__c = 'Testee-Female', 
                                                                                   Neutral__c = 'Testee');

        Relationship_Lookup__c testeeRelationshipLookup = new Relationship_Lookup__c(Name = 'Testee', 
                                                                                   Male__c = 'Tester-Male',
                                                                                   Female__c = 'Tester-Female', 
                                                                                   Neutral__c = 'Tester');

        relationshipLookupsList.add(TesterRelationshipLookup);
        relationshipLookupsList.add(TesteeRelationshipLookup);
        insert relationshipLookupsList;
        
        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        for (Integer i = 0; i < contactsList.size(); i++){
            contactsList[i].FirstName = 'Test';
            contactsList[i].LastName = 'Contact ' + i;
            contactsList[i].ReportsToId = null;
        }

        Test.startTest();
        insert contactsList;
        Test.stopTest();

        Map<Id, Contact> contactsById = new Map<Id, Contact>();
        for (Contact con : contactsList){
            contactsById.put(con.Id, con);
        }

        List<Relationship__c> relationshipResultsList = [SELECT Id, 
                                                                Contact__c,
                                                                RelatedContact__c,
                                                                Status__c,
                                                                Type__c
                                                        FROM Relationship__c
                                                        WHERE Contact__c IN :contactsList
                                                        OR RelatedContact__c IN :contactsList];

        System.assertEquals(true, relationshipResultsList.isEmpty(), 'There should be no auto created relationship records when the auto create mapped field is null.');
    }

    /*********************************************************************************************************
    * @description Test to verify that with Auto-Created Duplicate Relations and Relationship Auto Create
    * enabled, populating an Auto Create mapped field on Contact with the same value multiple times will
    * generate duplicate relationship and reciprocal relationship records.
    *********************************************************************************************************/
    @isTest 
    private static void updateContactWithRelationshipAutoCreateDuplicatesAllowed(){
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Allow_AutoCreated_Duplicates__c = true));

        Relationship_Auto_Create__c contactReportToRelAutoCreate = new Relationship_Auto_Create__c(Name = 'ConReportToAutoCreate', 
                                                                                                   Object__c = 'Contact',
                                                                                                   Field__c = 'ReportsToId', 
                                                                                                   Relationship_Type__c = 'Tester',
                                                                                                   Campaign_Types__c = '');

        insert contactReportToRelAutoCreate;

        List<Relationship_Lookup__c> relationshipLookupsList = new List<Relationship_Lookup__c>();
        Relationship_Lookup__c testerRelationshipLookup = new Relationship_Lookup__c(Name = 'Tester', 
                                                                                   Male__c = 'Testee-Male',
                                                                                   Female__c = 'Testee-Female', 
                                                                                   Neutral__c = 'Testee');

        Relationship_Lookup__c testeeRelationshipLookup = new Relationship_Lookup__c(Name = 'Testee', 
                                                                                   Male__c = 'Tester-Male',
                                                                                   Female__c = 'Tester-Female', 
                                                                                   Neutral__c = 'Tester');

        relationshipLookupsList.add(TesterRelationshipLookup);
        relationshipLookupsList.add(TesteeRelationshipLookup);
        insert relationshipLookupsList;

        List<Contact> relatedContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        for (Integer i = 0; i < relatedContactsList.size(); i++){
            relatedContactsList[i].FirstName = 'Test';
            relatedContactsList[i].LastName = 'Related ' + i; 
        }
        insert relatedContactsList;

        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        for (Integer i = 0; i < contactsList.size(); i++){
            contactsList[i].FirstName = 'Test';
            contactsList[i].LastName = 'Contact ' + i;
            contactsList[i].ReportsToId = relatedContactsList[i].Id;
        }

        insert contactsList;

        for (Integer i = 0; i < contactsList.size(); i++){
            contactsList[i].FirstName = 'Test';
            contactsList[i].LastName = 'Contact ' + i;
            contactsList[i].ReportsToId = null;
        }

        update contactsList;

        for (Integer i = 0; i < contactsList.size(); i++){
            contactsList[i].FirstName = 'Test';
            contactsList[i].LastName = 'Contact ' + i;
            contactsList[i].ReportsToId = relatedContactsList[i].Id;
        }

        Test.startTest();
        update contactsList;
        Test.stopTest();

        Map<Id, Contact> contactsById = new Map<Id, Contact>();
        for (Contact con : contactsList){
            contactsById.put(con.Id, con);
        }

        List<Relationship__c> relationshipResultsList = [SELECT Id, 
                                                                Contact__c,
                                                                RelatedContact__c,
                                                                Status__c,
                                                                Type__c
                                                        FROM Relationship__c
                                                        WHERE Contact__c IN :contactsList
                                                        OR Contact__c IN :relatedContactsList];

        Map<Id, TestRelationshipMapper> testRelationshipMapperByContactId = REL_Relationships_Con_TEST.mapRelationshipListsToContact(contactsById, relationshipResultsList);

        for (Id contactId : testRelationshipMapperByContactId.keySet()){
            List<Relationship__c> testerRelList = testRelationshipMapperByContactId.get(contactId).testerRelationshipsList;
            List<Relationship__c> testeeRelList = testRelationshipMapperByContactId.get(contactId).testeeRelationshipsList;

            Boolean testerRecordsDuplicated = (testerRelList[0].Contact__c == testerRelList[1].Contact__c) && 
                                                (testerRelList[0].RelatedContact__c == testerRelList[1].RelatedContact__c);

            Boolean testeeRecordsDuplicated = (testeeRelList[0].Contact__c == testeeRelList[1].Contact__c) && 
                                                (testeeRelList[0].RelatedContact__c == testeeRelList[1].RelatedContact__c);

            System.assertEquals(2, testerRelList.size(), 'Each contact should be associated with 2 Tester relationship records.');
            System.assertEquals(2, testeeRelList.size(), 'Each contact should be associated with 2 Testee relationship records.');
            System.assertEquals(true, testerRecordsDuplicated, 'Tester relationship records should be duplicated.');
            System.assertEquals(true, testeeRecordsDuplicated, 'Testee relationship records should be duplicated.');
        }
    }

    /*********************************************************************************************************
    * @description Test to verify that when Relationship Auto Creation is enabled and Auto-Created Duplicate 
    * Relations is not, associating a Contact multiple times with the same value for an Auto Creation mapped 
    * field only results in a single relationship and reciprocal relationship record.
    *********************************************************************************************************/
    @isTest 
    private static void updateContactWithRelationshipAutoCreateDuplicatesNotAllowed(){
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Allow_AutoCreated_Duplicates__c = false));
        
        Relationship_Auto_Create__c contactReportToRelAutoCreate = new Relationship_Auto_Create__c(Name = 'ConReportToAutoCreate', 
                                                                                                   Object__c = 'Contact',
                                                                                                   Field__c = 'ReportsToId', 
                                                                                                   Relationship_Type__c = 'Tester',
                                                                                                   Campaign_Types__c = '');

        insert contactReportToRelAutoCreate;

        List<Relationship_Lookup__c> relationshipLookupsList = new List<Relationship_Lookup__c>();
        Relationship_Lookup__c testerRelationshipLookup = new Relationship_Lookup__c(Name = 'Tester', 
                                                                                   Male__c = 'Testee-Male',
                                                                                   Female__c = 'Testee-Female', 
                                                                                   Neutral__c = 'Testee');

        Relationship_Lookup__c testeeRelationshipLookup = new Relationship_Lookup__c(Name = 'Testee', 
                                                                                   Male__c = 'Tester-Male',
                                                                                   Female__c = 'Tester-Female', 
                                                                                   Neutral__c = 'Tester');

        relationshipLookupsList.add(TesterRelationshipLookup);
        relationshipLookupsList.add(TesteeRelationshipLookup);
        insert relationshipLookupsList;

        List<Contact> relatedContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        for (Integer i = 0; i < relatedContactsList.size(); i++){
            relatedContactsList[i].FirstName = 'Test';
            relatedContactsList[i].LastName = 'Related ' + i; 
        }
        insert relatedContactsList;

        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        for (Integer i = 0; i < contactsList.size(); i++){
            contactsList[i].FirstName = 'Test';
            contactsList[i].LastName = 'Contact ' + i;
            contactsList[i].ReportsToId = relatedContactsList[i].Id;
        }

        insert contactsList;

        for (Integer i = 0; i < contactsList.size(); i++){
            contactsList[i].FirstName = 'Test';
            contactsList[i].LastName = 'Contact ' + i;
            contactsList[i].ReportsToId = null;
        }

        update contactsList;

        for (Integer i = 0; i < contactsList.size(); i++){
            contactsList[i].FirstName = 'Test';
            contactsList[i].LastName = 'Contact ' + i;
            contactsList[i].ReportsToId = relatedContactsList[i].Id;
        }

        Test.startTest();
        update contactsList;
        Test.stopTest();

        Map<Id, Contact> contactsById = new Map<Id, Contact>();
        for (Contact con : contactsList){
            contactsById.put(con.Id, con);
        }

        List<Relationship__c> relationshipResultsList = [SELECT Id, 
                                                                Contact__c,
                                                                RelatedContact__c,
                                                                Status__c,
                                                                Type__c
                                                        FROM Relationship__c
                                                        WHERE Contact__c IN :contactsList
                                                        OR Contact__c IN :relatedContactsList];

        Map<Id, TestRelationshipMapper> testRelationshipMapperByContactId = REL_Relationships_Con_TEST.mapRelationshipListsToContact(contactsById, relationshipResultsList);

        for (Id contactId : testRelationshipMapperByContactId.keySet()){
            System.assertEquals(1, testRelationshipMapperByContactId.get(contactId).testerRelationshipsList.size(), 'Each contact should only have 1 Tester relationship record.');
            System.assertEquals(1, testRelationshipMapperByContactId.get(contactId).testeeRelationshipsList.size(), 'Each contact should only have 1 Testee relationship record.');
        }
    }

    /*********************************************************************************************************
    ********************************************* UNIT TESTS *************************************************
    *********************************************************************************************************/

    /*********************************************************************************************************
    * @description Test method to validate that unsetInsertRecursion() updates the REL_Relationships_Con_TDTM
    * recursion trigger flag from true to false.     
    *********************************************************************************************************/ 
    @isTest 
    private static void unsetInsertRecursionTrue(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_Con_TDTM, true);

        REL_Relationships_Con_TDTM relConTdtm = new REL_Relationships_Con_TDTM();
        Test.startTest();
        relConTdtm.unsetInsertRecursion();
        Test.stopTest();

        System.assertEquals(false, TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_Con_TDTM), 'Insert recursion trigger should be set to false.');
    }

    /*********************************************************************************************************
    * @description Test method to validate that unsetInsertRecursion() does not change the 
    * REL_Relationships_Con_TDTM recursion trigger flag if already set to false.   
    *********************************************************************************************************/ 
    @isTest 
    private static void unsetInsertRecursionFalse(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_Con_TDTM, false);

        REL_Relationships_Con_TDTM relConTdtm = new REL_Relationships_Con_TDTM();
        Test.startTest();
        relConTdtm.unsetInsertRecursion();
        Test.stopTest();

        System.assertEquals(false, TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_Con_TDTM), 'Insert recursion trigger should remain set to false.');
    }

    /*********************************************************************************************************
    * @description Test method to validate that setInsertRecursion() changes the 
    * REL_Relationships_Con_TDTM recursion trigger flag from false to true.   
    *********************************************************************************************************/ 
    @isTest 
    private static void setInsertRecursionTrue(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_Con_TDTM, false);

        REL_Relationships_Con_TDTM relConTdtm = new REL_Relationships_Con_TDTM();
        Test.startTest();
        relConTdtm.setInsertRecursion();
        Test.stopTest();

        System.assertEquals(true, TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_Con_TDTM), 'Insert recursion trigger should be set to true.');
    }

    /*********************************************************************************************************
    * @description Test method to validate that setInsertRecursion() does not change the 
    * REL_Relationships_Con_TDTM recursion trigger flag if already set to true.   
    *********************************************************************************************************/ 
    @isTest 
    private static void setInsertRecursionFalse(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_Con_TDTM, true);

        REL_Relationships_Con_TDTM relConTdtm = new REL_Relationships_Con_TDTM();
        Test.startTest();
        relConTdtm.setInsertRecursion();
        Test.stopTest();

        System.assertEquals(true, TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_Con_TDTM), 'Insert recursion trigger should remain set to true.');
    }

    /*********************************************************************************************************
    * @description Test method to validate that isInsertRecursion() returns true when the 
    * REL_Relationships_Con_TDTM recursion trigger flag is set to true.   
    *********************************************************************************************************/ 
    @isTest 
    private static void isInsertRecursionTrue(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_Con_TDTM, true);

        REL_Relationships_Con_TDTM relConTdtm = new REL_Relationships_Con_TDTM();
        Test.startTest();
        System.assertEquals(true, relConTdtm.isInsertRecursion(), 'Insert recursion trigger should be true.');
        Test.stopTest();
    }

    /*********************************************************************************************************
    * @description Test method to validate that isInsertRecursion() returns false when the 
    * REL_Relationships_Con_TDTM recursion trigger flag is set to false.   
    *********************************************************************************************************/ 
    @isTest 
    private static void isInsertRecursionFalse(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_Con_TDTM, false);

        REL_Relationships_Con_TDTM relConTdtm = new REL_Relationships_Con_TDTM();
        Test.startTest();
        System.assertEquals(false, relConTdtm.isInsertRecursion(), 'Insert recursion trigger should be false.');
        Test.stopTest();
    }

    /************************************************************************************************************
    * @description Test method to verify that the locateRelationshipAutoCreateService returns an instance of the
    * ContactRelAutoCreateService service class.
    *************************************************************************************************************/ 
    @isTest 
    private static void getInstanceOfRelationshipAutoCreateService(){
        Test.startTest();
        REL_Relationships_Con_TDTM relConTdtm = new REL_Relationships_Con_TDTM();
        ContactRelAutoCreateService srvcConRelAutoCreateInstance = relConTdtm.locateRelationshipAutoCreateService();
        Test.stopTest();
        
        System.assertEquals(true, srvcConRelAutoCreateInstance != null, 'Instance of service class should be retrieved.');
    }

    /************************************************************************************************************
    * @description Test method to verify that the locateRelationshipAutoCreateMapper() returns an instance 
    * of the RelAutoCreateSettingsMapper service class.
    *************************************************************************************************************/ 
    @isTest 
    private static void getInstanceOfRelationshipAutoCreateMappingService(){
        Test.startTest();
        REL_Relationships_Con_TDTM relConTdtm = new REL_Relationships_Con_TDTM();
        RelAutoCreateSettingsMapper srvcRelAutoCreateSettingsMapperInstance = relConTdtm.locateRelationshipAutoCreateMapper();
        Test.stopTest();
        
        System.assertEquals(true, srvcRelAutoCreateSettingsMapperInstance != null, 'Instance of service class should be retrieved.');
    }

    /************************************************************************************************************
    * @description Test method to verify that the handleAfterInsert() returns null and does not perform an
    * insert when executed in an Insert Recursion context.
    ************************************************************************************************************/
    @isTest 
    private static void handleAfterInsertWithRecursion(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_Con_TDTM, true);

        List<Contact> relatedContactsList = new List<Contact>();

        for (Integer i = 0; i < 5; i++){
            Contact con = new Contact(Id = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                      LastName = 'Testerson',
                                      ReportsToId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType));
            relatedContactsList.add(con);
        }

        REL_Relationships_Con_TDTM relConTdtm = new REL_Relationships_Con_TDTM();
        Test.startTest();
        System.assertEquals(null, relConTdtm.handleAfterInsert((List<SObject>)relatedContactsList), 'Insert logic in insert recursion context should not execute.');
        Test.stopTest();
    }

    /************************************************************************************************************
    * @description Test method to verify that the handleAfterInsert() inserts contacts and does not create 
    * relationships when Auto Create is not enabled.
    ************************************************************************************************************/
    @isTest 
    private static void handleAfterInsertWithoutAutoCreate(){
        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        insert contactsList;

        REL_Relationships_Con_TDTM relConTdtm = new REL_Relationships_Con_TDTM();
        Test.startTest();
        relConTdtm.handleAfterInsert((List<SObject>)contactsList);
        Test.stopTest();

        List<Relationship__c> relationshipResultsList = [SELECT Id
                                                         FROM Relationship__c
                                                         WHERE Contact__c IN :contactsList
                                                         OR RelatedContact__c IN :contactsList];
                                                        
        System.assertEquals(true, relationshipResultsList.isEmpty(), 'There should be no relationship records auto created.');
    }

    /************************************************************************************************************
    * @description Test method to verify that the handleAfterInsert() does not create a relationship and
    * reciprocal relationship when Auto Create is enabled, but the mapped field is not populated.
    ************************************************************************************************************/
    @isTest 
    private static void handleAfterInsertWithAutoCreateNoFieldPopulated(){
        Relationship_Auto_Create__c contactReportToRelAutoCreate = new Relationship_Auto_Create__c(Name = 'ConReportToAutoCreate', 
                                                                                                   Object__c = 'Contact',
                                                                                                   Field__c = 'ReportsToId', 
                                                                                                   Relationship_Type__c = 'Tester',
                                                                                                   Campaign_Types__c = '');

        insert contactReportToRelAutoCreate;

        List<Relationship_Lookup__c> relationshipLookupsList = new List<Relationship_Lookup__c>();
        Relationship_Lookup__c testerRelationshipLookup = new Relationship_Lookup__c(Name = 'Tester', 
                                                                                   Male__c = 'Testee-Male',
                                                                                   Female__c = 'Testee-Female', 
                                                                                   Neutral__c = 'Testee');

        Relationship_Lookup__c testeeRelationshipLookup = new Relationship_Lookup__c(Name = 'Testee', 
                                                                                   Male__c = 'Tester-Male',
                                                                                   Female__c = 'Tester-Female', 
                                                                                   Neutral__c = 'Tester');

        relationshipLookupsList.add(TesterRelationshipLookup);
        relationshipLookupsList.add(TesteeRelationshipLookup);
        insert relationshipLookupsList;

        Set<Id> fakeContactIdsSet = new Set<Id>();
        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        for (Contact con : contactsList){
            Id fakeConId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
            fakeContactIdsSet.add(fakeConId);
            con.Id = fakeConId;
            con.ReportsToId = null;
        }

        REL_Relationships_Con_TDTM relConTdtm = new REL_Relationships_Con_TDTM();
        Test.startTest();
        relConTdtm.handleAfterInsert((List<SObject>)contactsList);
        Test.stopTest();

        List<Relationship__c> relationshipResultsList = [SELECT Id
                                                         FROM Relationship__c
                                                         WHERE Contact__c IN :fakeContactIdsSet
                                                         OR RelatedContact__c IN :fakeContactIdsSet];
                                                        
        System.assertEquals(true, relationshipResultsList.isEmpty(), 'There should be no relationship records auto created.');
    }

    /************************************************************************************************************
    * @description Test method to verify that the handleAfterInsert() inserts contacts and creates a relationship 
    * and reciprocal relationship when Auto Create is enabled and a mappe field is populated.
    ************************************************************************************************************/
    @isTest 
    private static void handleAfterInsertWithAutoCreateFieldPopulated(){
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Allow_AutoCreated_Duplicates__c = false));

        Relationship_Auto_Create__c contactReportToRelAutoCreate = new Relationship_Auto_Create__c(Name = 'ConReportToAutoCreate', 
                                                                                                   Object__c = 'Contact',
                                                                                                   Field__c = 'ReportsToId', 
                                                                                                   Relationship_Type__c = 'Tester',
                                                                                                   Campaign_Types__c = '');

        insert contactReportToRelAutoCreate;

        List<Relationship_Lookup__c> relationshipLookupsList = new List<Relationship_Lookup__c>();
        Relationship_Lookup__c testerRelationshipLookup = new Relationship_Lookup__c(Name = 'Tester', 
                                                                                   Male__c = 'Testee-Male',
                                                                                   Female__c = 'Testee-Female', 
                                                                                   Neutral__c = 'Testee');

        Relationship_Lookup__c testeeRelationshipLookup = new Relationship_Lookup__c(Name = 'Testee', 
                                                                                   Male__c = 'Tester-Male',
                                                                                   Female__c = 'Tester-Female', 
                                                                                   Neutral__c = 'Tester');

        relationshipLookupsList.add(TesterRelationshipLookup);
        relationshipLookupsList.add(TesteeRelationshipLookup);
        insert relationshipLookupsList;

        List<Contact> relatedContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        for (Integer i = 0; i < relatedContactsList.size(); i++){
            relatedContactsList[i].FirstName = 'Test';
            relatedContactsList[i].LastName = 'Related ' + i; 
        }
        insert relatedContactsList;
        
        Map<Id, Contact> relatedContactsById = new Map<Id, Contact>();
        for (Contact con : relatedContactsList){
            relatedContactsById.put(con.Id, con);
        }

        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        for (Integer i = 0; i < contactsList.size(); i++){
            contactsList[i].FirstName = 'Test';
            contactsList[i].LastName = 'Contact ' + i;
            contactsList[i].ReportsToId = relatedContactsList[i].Id;
        }

        insert contactsList; // inserts 10 additional relationship records

        Map<Id, Contact> contactsById = new Map<Id, Contact>();
        for (Contact con : contactsList){
            contactsById.put(con.Id, con);
        }

        REL_Relationships_Con_TDTM relConTdtm = new REL_Relationships_Con_TDTM();
        Test.startTest();
        relConTdtm.handleAfterInsert((List<SObject>)contactsList);
        Test.stopTest();

        List<Relationship__c> relationshipResultsList = [SELECT Id, 
                                                                Contact__c,
                                                                RelatedContact__c,
                                                                Status__c,
                                                                Type__c
                                                        FROM Relationship__c
                                                        WHERE Contact__c IN :contactsList
                                                        OR Contact__c IN :relatedContactsList];

        System.assertEquals(20, relationshipResultsList.size(), '10 Relationship records should be auto created (10 extra created due to test setup).');
        
        Map<Id, TestRelationshipMapper> testRelationshipMapperByContactId = REL_Relationships_Con_TEST.mapRelationshipListsToContact(contactsById, relationshipResultsList);

        for (Id contactId : testRelationshipMapperByContactId.keySet()){
            System.assertEquals(2, testRelationshipMapperByContactId.get(contactId).testerRelationshipsList.size(), 'Each contact should only have 2 Tester relationship records (1 extra created due to test setup).');
            System.assertEquals(2, testRelationshipMapperByContactId.get(contactId).testeeRelationshipsList.size(), 'Each contact should only have 2 Testee relationship records (1 extra created due to test setup).');
        }
    }

    /************************************************************************************************************
    * @description Test to verify that run() creates relationships for contacts inserted with Relationship Auto 
    * Create enabled.
    ************************************************************************************************************/ 
    @isTest 
    private static void runAfterInsertWithAutoCreate(){
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Allow_AutoCreated_Duplicates__c = false));

        Relationship_Auto_Create__c contactReportToRelAutoCreate = new Relationship_Auto_Create__c(Name = 'ConReportToAutoCreate', 
                                                                                                   Object__c = 'Contact',
                                                                                                   Field__c = 'ReportsToId', 
                                                                                                   Relationship_Type__c = 'Tester',
                                                                                                   Campaign_Types__c = '');

        insert contactReportToRelAutoCreate;

        List<Relationship_Lookup__c> relationshipLookupsList = new List<Relationship_Lookup__c>();
        Relationship_Lookup__c testerRelationshipLookup = new Relationship_Lookup__c(Name = 'Tester', 
                                                                                   Male__c = 'Testee-Male',
                                                                                   Female__c = 'Testee-Female', 
                                                                                   Neutral__c = 'Testee');

        Relationship_Lookup__c testeeRelationshipLookup = new Relationship_Lookup__c(Name = 'Testee', 
                                                                                   Male__c = 'Tester-Male',
                                                                                   Female__c = 'Tester-Female', 
                                                                                   Neutral__c = 'Tester');

        relationshipLookupsList.add(TesterRelationshipLookup);
        relationshipLookupsList.add(TesteeRelationshipLookup);
        insert relationshipLookupsList;

        List<Contact> relatedContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        for (Integer i = 0; i < relatedContactsList.size(); i++){
            relatedContactsList[i].FirstName = 'Test';
            relatedContactsList[i].LastName = 'Related ' + i; 
        }
        insert relatedContactsList;
        
        Map<Id, Contact> relatedContactsById = new Map<Id, Contact>();
        for (Contact con : relatedContactsList){
            relatedContactsById.put(con.Id, con);
        }

        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        for (Integer i = 0; i < contactsList.size(); i++){
            contactsList[i].FirstName = 'Test';
            contactsList[i].LastName = 'Contact ' + i;
            contactsList[i].ReportsToId = relatedContactsList[i].Id;
        }

        insert contactsList; // inserts 10 additional relationship records

        Map<Id, Contact> contactsById = new Map<Id, Contact>();
        for (Contact con : contactsList){
            contactsById.put(con.Id, con);
        }

        REL_Relationships_Con_TDTM relConTdtm = new REL_Relationships_Con_TDTM();
        TDTM_Runnable.Action triggerAction = TDTM_Runnable.Action.AfterInsert;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Contact;

        Test.startTest();
        relConTdtm.run((List<SObject>)contactsList, null, triggerAction, objResult);
        Test.stopTest();

        List<Relationship__c> relationshipResultsList = [SELECT Id, 
                                                                Contact__c,
                                                                RelatedContact__c,
                                                                Status__c,
                                                                Type__c
                                                        FROM Relationship__c
                                                        WHERE Contact__c IN :contactsList
                                                        OR Contact__c IN :relatedContactsList];

        System.assertEquals(20, relationshipResultsList.size(), '10 Relationship records should be auto created (10 extra created due to test setup).');
    }

    /************************************************************************************************************
    * @description Test to verify that run() does not create relationships for contacts inserted with 
    * Relationship Auto Create disabled.
    ************************************************************************************************************/ 
    @isTest 
    private static void runAfterInsertWithoutAutoCreate(){
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Allow_AutoCreated_Duplicates__c = false));

        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        insert contactsList; 

        Map<Id, Contact> contactsById = new Map<Id, Contact>();
        for (Contact con : contactsList){
            contactsById.put(con.Id, con);
        }

        REL_Relationships_Con_TDTM relConTdtm = new REL_Relationships_Con_TDTM();
        TDTM_Runnable.Action triggerAction = TDTM_Runnable.Action.AfterInsert;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Contact;

        Test.startTest();
        relConTdtm.run((List<SObject>)contactsList, null, triggerAction, objResult);
        Test.stopTest();

        List<Relationship__c> relationshipResultsList = [SELECT Id, 
                                                                Contact__c,
                                                                RelatedContact__c,
                                                                Status__c,
                                                                Type__c
                                                        FROM Relationship__c
                                                        WHERE Contact__c IN :contactsList
                                                        OR RelatedContact__c IN :contactsList];

        System.assertEquals(true, relationshipResultsList.isEmpty(), 'No Relationship records should be auto created.');
    }

    /*********************************************************************************************************
    * @description Helper method to generate a map relating a contact to all associated Tester and Testee relationship records.
    * @param  contactsById A map of inserted contacts by Id
    * @param  relationshipsList A list of relationship records to be mapped
    * @return A map of TestRelationshipMapper value objects by Contact Id.
    *********************************************************************************************************/ 
    private static Map<Id, TestRelationshipMapper> mapRelationshipListsToContact(Map<Id, Contact> contactsById, List<Relationship__c> relationshipsList){
        Map<Id, TestRelationshipMapper> testRelationshipMapperByContactId = new Map<Id, TestRelationshipMapper>();

        for (Relationship__c rel : relationshipsList){
            TestRelationshipMapper testRelMapper;

            if (contactsById.containsKey(rel.Contact__c)){
                testRelMapper = testRelationshipMapperByContactId.get(rel.Contact__c);

                if (testRelMapper == null){
                    testRelMapper = new TestRelationshipMapper(rel.Contact__c);
                }
            } else {
                testRelMapper = testRelationshipMapperByContactId.get(rel.relatedContact__c);

                if (testRelMapper == null){
                    testRelMapper = new TestRelationshipMapper(rel.relatedContact__c);
                }
            }

            testRelMapper.addRelationship(rel);
        }

        return testRelationshipMapperByContactId;
    }

    /*********************************************************************************************************
    * @describe Wrapper class to associate Tester and Testee relationships to a Contact.
    *********************************************************************************************************/
    private class TestRelationshipMapper{
        public Id contactId { get; set; }
        public List<Relationship__c> testerRelationshipsList { get; set; }
        public List<Relationship__c> testeeRelationshipsList { get; set; }

        public TestRelationshipMapper(Id contactId){
            this.contactId = contactId;
            testerRelationshipsList = new List<Relationship__c>();
            testeeRelationshipsList = new List<Relationship__c>();
        }    

        /*********************************************************************************************************
        * @description Adds a new relationship to the Tester or Testee relationship
        * list for a contact based on relationship type.
        * @param  rel A relationship to add.
        *********************************************************************************************************/
        public void addRelationship(Relationship__c rel){
            if (rel.Type__c.contains('Tester')){
                testerRelationshipsList.add(rel);
            }

            if (rel.Type__c.contains('Testee')){
                testeeRelationshipsList.add(rel);
            }
        }
    }
}
