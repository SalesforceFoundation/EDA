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
public with sharing class REL_Relationships_Con_TEST {

    /*********************************************************************************************************
    ****************************** RELATIONSHIP AUTO CREATION FUNCTIONAL TESTS *******************************
    *********************************************************************************************************/

    /*********************************************************************************************************
    * @description Test to verify that inserting a Contact record without an Auto Creation mapping does not
    * generate a relationship or reciprocal relationship record.
    *********************************************************************************************************/
    @isTest 
    private static void InsertContactWithoutRelationshipAutoCreate(){

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
    * @description Test to verify that when Relationship Auto Creation is enabled, inserting a Contact record 
    * with an Auto Creation mapped field populated generates the expected relationship  and reciprocal 
    * reciprocal relationship records.
    *********************************************************************************************************/
    @isTest
    private static void InsertContactWithRelationshipAutoCreateFieldPopulated() {
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
    * without populating a mapped Auto Creation field will not generate any relationship records.
    *********************************************************************************************************/
    @isTest 
    private static void InsertContactWithoutRelationshipAutoCreateFieldPopulated(){
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
    private static void UpdateContactWithRelationshipAutoCreateDuplicatesAllowed(){
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
    private static void UpdateContactWithRelationshipAutoCreateDuplicatesNotAllowed(){
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

                // TODO: refactor
                if (rel.Type__c.contains('Tester')){
                    testRelMapper.testerRelationshipsList.add(rel);
                } else {
                    testRelMapper.testeeRelationshipsList.add(rel);
                }
            } else {
                testRelMapper = testRelationshipMapperByContactId.get(rel.relatedContact__c);

                if (testRelMapper == null){
                    testRelMapper = new TestRelationshipMapper(rel.relatedContact__c);
                }
                
                // TODO: refactor
                if (rel.Type__c.contains('Tester')){
                    testRelMapper.testerRelationshipsList.add(rel);
                } else {
                    testRelMapper.testeeRelationshipsList.add(rel);
                }
            }
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

        System.assertEquals(false, TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_Con_TDTM), 'Recursion trigger should be set to false.');
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

        System.assertEquals(false, TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_Con_TDTM), 'Recursion trigger should remain set to false.');
    }
}
