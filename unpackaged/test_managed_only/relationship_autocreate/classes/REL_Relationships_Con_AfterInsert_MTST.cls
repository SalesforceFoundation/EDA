/*
    Copyright (c) 2020, Salesforce.org
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
* @group Relationships
* @description Unmanaged tests for UTIL_Describe used to verify inactive
* Record Types are included in record type mapping.
*/
@isTest
private class REL_Relationships_Con_AfterInsert_MTST {

    /*********************************************************************************************************
    * @description Test to verify that when Relationship Auto Creation is enabled, inserting a Contact record 
    * with an Auto Creation mapped field populated generates the expected relationship  and reciprocal 
    * reciprocal relationship records.
    *********************************************************************************************************/
    @isTest
    private static void insertContactWithMultipleAutoCreateMappings(){

        List<Relationship_Auto_Create__c> relAutoCreateList = new List<Relationship_Auto_Create__c>();
    
        Relationship_Auto_Create__c contactReportToRelAutoCreate = new Relationship_Auto_Create__c(Name = 'ConReportToAutoCreate', 
                                                                                                    Object__c = 'Contact',
                                                                                                    Field__c = 'ReportsToId', 
                                                                                                    Relationship_Type__c = 'Tester',
                                                                                                    Campaign_Types__c = '');

        Relationship_Auto_Create__c contactEmployerRelAutoCreate = new Relationship_Auto_Create__c(Name = 'ConEmployerAutoCreate', 
                                                                                                   Object__c = 'Contact',
                                                                                                   Field__c = 'Employer__c', 
                                                                                                   Relationship_Type__c = 'Employer',
                                                                                                   Campaign_Types__c = '');
        
        relAutoCreateList.add(contactReportToRelAutoCreate);  
        relAutoCreateList.add(contactEmployerRelAutoCreate);                                                                                         
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
}