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
* @group-content ../../ApexDocContent/Relationships
* @description Test class for ContactRelationshipsModel. 
*/
@isTest
private with sharing class ContactRelationshipsModel_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that addRelationship() appends additional Relationship records to an existing list of 
    * records for a Contact Relationships model.
    **************************************************************************************************************************/
    @isTest 
    private static void addRelationshipWithExisting(){
        List<ContactRelationshipsModel> conRelsModelsList = ContactRelationshipsModel_TEST.getContactRelationshipsModelList(5);

        for (ContactRelationshipsModel conRelsMod : conRelsModelsList){
            for (Integer i = 0; i < 2; i++){
                Id relatedConFakeId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
                Relationship__c rel = UTIL_UnitTestData_TEST.getRelationship(conRelsMod.contactId, relatedConFakeId, 'Brother');
                conRelsMod.addRelationship(rel);
            }
        }

        Test.startTest();
        for (ContactRelationshipsModel conRelsMod : conRelsModelsList){
            for (Integer i = 0; i < 5; i++){
                Id relatedConFakeId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
                Relationship__c rel = UTIL_UnitTestData_TEST.getRelationship(conRelsMod.contactId, relatedConFakeId, 'Aunt');
                conRelsMod.addRelationship(rel);
            }
                    
            System.assertEquals(7, conRelsMod.relationshipList.size(), 'Contact Relationships model should have 5 new Relationship records added to existing 2 records.');
            System.assertEquals(7, conRelsMod.relationshipByTypeByRelatedContactId.keySet().size(), 'There should be 7 total related contact mappings for Contact Relationships model.');        
        }
        Test.stopTest();
    }

    /**************************************************************************************************************************
    * @description Test method to verify that addRelationship() adds new Relationship records to an empty list of 
    * records for a Contact Relationships model.
    **************************************************************************************************************************/
    @isTest 
    private static void addRelationshipWithoutExisting(){
        List<ContactRelationshipsModel> conRelsModelsList = ContactRelationshipsModel_TEST.getContactRelationshipsModelList(5);

        Test.startTest();
        for (ContactRelationshipsModel conRelsMod : conRelsModelsList){

            for (Integer i = 0; i < 5; i++){
                Id relatedConFakeId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
                Relationship__c rel = UTIL_UnitTestData_TEST.getRelationship(conRelsMod.contactId, relatedConFakeId, 'Aunt');
                conRelsMod.addRelationship(rel);
            }
                    
            System.assertEquals(5, conRelsMod.relationshipList.size(), 'Contact Relationships model should be associated with 5 new Relationship records.');
        }
        Test.stopTest();
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getRelatedContactIdSet() returns a set of related Contact Ids when they exist for
    * a Contact Relationships model.
    **************************************************************************************************************************/
    @isTest 
    private static void getRelatedContactIdSetTrue(){
        List<ContactRelationshipsModel> contactRelationshipsModelList = ContactRelationshipsModel_TEST.getContactRelationshipsModelList(5);

        for (ContactRelationshipsModel conRelsMod : contactRelationshipsModelList){
            List<Id> relatedContactIdsList;

            for (Integer i = 0; i < 5; i++){
                Id fakeRelConId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
                Relationship__c rel = UTIL_UnitTestData_TEST.getRelationship(conRelsMod.contactId, fakeRelConId, 'Cousin');
                conRelsMod.addRelationship(rel);
            }
        }

        Test.startTest();
        for (ContactRelationshipsModel conRelsMod : contactRelationshipsModelList){
            System.assertEquals(5, conRelsMod.getRelatedContactIdSet().size(), 'There should be 5 related Contact Ids associated with the current Contact Relationships model.');
        }
        Test.stopTest();
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getRelatedContactIdSet() returns an empty set of related Contact Ids when they 
    * do not exist for a Contact Relationships model.
    **************************************************************************************************************************/
    @isTest 
    private static void getRelatedContactIdSetFalse(){
        List<ContactRelationshipsModel> contactRelationshipsModelList = ContactRelationshipsModel_TEST.getContactRelationshipsModelList(5);

        Test.startTest();
        for (ContactRelationshipsModel conRelsMod : contactRelationshipsModelList){
            System.assertEquals(true, conRelsMod.getRelatedContactIdSet().isEmpty(), 'There should be no related Contact Ids associated with the current Contact Relationships model.');
        }
        Test.stopTest();
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getRelationship() returns a Relationship when a matching record of a specified
    * Type is associated with a related Contact record.
    **************************************************************************************************************************/
    @isTest 
    private static void getRelationshipTrue(){
        List<ContactRelationshipsModel> contactRelationshipsModelList = ContactRelationshipsModel_TEST.getContactRelationshipsModelList(5);
        Map<Id, List<Id>> relatedContactIdsListByContactId = new Map<Id, List<Id>>();

        for (ContactRelationshipsModel conRelsMod : contactRelationshipsModelList){
            List<Id> relatedContactIdsList;

            for (Integer i = 0; i < 5; i++){
                Id fakeRelConId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
                Relationship__c rel = UTIL_UnitTestData_TEST.getRelationship(conRelsMod.contactId, fakeRelConId, 'Cousin');
                conRelsMod.addRelationship(rel);

                relatedContactIdsList = relatedContactIdsListByContactId.get(conRelsMod.contactId);

                if (relatedContactIdsList == null){
                    relatedContactIdsList = new List<Id>();
                }

                relatedContactIdsList.add(fakeRelConId);
                relatedContactIdsListByContactId.put(conRelsMod.contactId, relatedContactIdsList);
            }
        }

        Test.startTest();
        for (ContactRelationshipsModel conRelsMod : contactRelationshipsModelList){
            List<Id> relatedContactIdsList = relatedContactIdsListByContactId.get(conRelsMod.contactId);
            for (Id relConId : relatedContactIdsList){
                System.assertEquals(true, conRelsMod.getRelationship(relConId, 'Cousin') != null, 'There should be relationships of type \'Cousin\' associated with the current related Contact.');

            }
        }
        Test.stopTest();
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getRelationship() returns null when a related Contact is not associated with 
    * Relationship records of a specified type.
    **************************************************************************************************************************/
    @isTest 
    private static void getRelationshipFalse(){
        List<ContactRelationshipsModel> contactRelationshipsModelList = ContactRelationshipsModel_TEST.getContactRelationshipsModelList(5);
        Map<Id, List<Id>> relatedContactIdsListByContactId = new Map<Id, List<Id>>();

        for (ContactRelationshipsModel conRelsMod : contactRelationshipsModelList){
            List<Id> relatedContactIdsList;

            for (Integer i = 0; i < 5; i++){
                Id fakeRelConId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);

                Relationship__c rel = UTIL_UnitTestData_TEST.getRelationship(conRelsMod.contactId, fakeRelConId, 'Brother');
                conRelsMod.addRelationship(rel);

                relatedContactIdsList = relatedContactIdsListByContactId.get(conRelsMod.contactId);

                if (relatedContactIdsList == null){
                    relatedContactIdsList = new List<Id>();
                }

                relatedContactIdsList.add(fakeRelConId);
                relatedContactIdsListByContactId.put(conRelsMod.contactId, relatedContactIdsList);
            }
        }

        Test.startTest();
        for (ContactRelationshipsModel conRelsMod : contactRelationshipsModelList){
            List<Id> relatedContactIdsList = relatedContactIdsListByContactId.get(conRelsMod.contactId);
            for (Id relConId : relatedContactIdsList){
                System.assertEquals(true, conRelsMod.getRelationship(relConId, 'Cousin') == null, 'There should be no relationships of type \'Cousin\' associated with the current related Contact.');
            }
        }
        Test.stopTest();
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getRelationship() returns null when a related Contact is not associated with any
    * Relationship records of any type.
    **************************************************************************************************************************/
    @isTest 
    private static void getRelationshipNull(){
        List<ContactRelationshipsModel> contactRelationshipsModelList = ContactRelationshipsModel_TEST.getContactRelationshipsModelList(5);
        Map<Id, List<Id>> relatedContactIdsListByContactId = new Map<Id, List<Id>>();

        for (ContactRelationshipsModel conRelsMod : contactRelationshipsModelList){
            List<Id> relatedContactIdsList;

            for (Integer i = 0; i < 5; i++){
                Id fakeRelConId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
                Relationship__c rel = UTIL_UnitTestData_TEST.getRelationship(conRelsMod.contactId, fakeRelConId, 'Cousin');
                conRelsMod.addRelationship(rel);

                relatedContactIdsList = relatedContactIdsListByContactId.get(conRelsMod.contactId);

                if (relatedContactIdsList == null){
                    relatedContactIdsList = new List<Id>();
                }

                relatedContactIdsList.add(fakeRelConId);
                relatedContactIdsListByContactId.put(conRelsMod.contactId, relatedContactIdsList);
            }
        }

        Test.startTest();
        for (ContactRelationshipsModel conRelsMod : contactRelationshipsModelList){
            System.assertEquals(null, conRelsMod.getRelationship(UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType), 'Cousin'), 'There should be no relationships of any type associated with the current related Contact.');
        }
        Test.stopTest();
    }

    /**************************************************************************************************************************
    * @description Test method to verify that isEmpty() returns false when a Contact Relationships model is associated with
    * Relationships records.
    **************************************************************************************************************************/
    @isTest 
    private static void isEmptyFalse(){
        List<ContactRelationshipsModel> contactRelationshipsModelList = ContactRelationshipsModel_TEST.getContactRelationshipsModelList(5);

        for (ContactRelationshipsModel conRelsMod : contactRelationshipsModelList){
            for (Integer i = 0; i < 5; i++){
                Relationship__c rel = UTIL_UnitTestData_TEST.getRelationship(conRelsMod.contactId, UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType), 'Cousin');
                conRelsMod.addRelationship(rel);
            }
        }

        Test.startTest();
        for (ContactRelationshipsModel conRelsMod : contactRelationshipsModelList){
            System.assertEquals(false, conRelsMod.isEmpty(), 'There should be relationships associated with the current Contact Relationships model.');
        }
        Test.stopTest();
    }

    /**************************************************************************************************************************
    * @description Test method to verify that isEmpty() returns true when a Contact Relationships model is not associated with
    * any Relationships records.
    **************************************************************************************************************************/
    @isTest 
    private static void isEmptyTrue(){
        List<ContactRelationshipsModel> contactRelationshipsModelList = ContactRelationshipsModel_TEST.getContactRelationshipsModelList(5);

        Test.startTest();
        for (ContactRelationshipsModel conRelsMod : contactRelationshipsModelList){
            System.assertEquals(true, conRelsMod.isEmpty(), 'There should be no relationships associated with the current Contact Relationships model.');
        }
        Test.stopTest();
    }

    /**************************************************************************************************************************
    * @description Helper method to generate a list of Contact Relationships models.
    * @param contactsCount The number of Contacts to associate with Contact Relationships models.
    * @return A list of ContactRelationshipsModel.
    **************************************************************************************************************************/ 
    private static List<ContactRelationshipsModel> getContactRelationshipsModelList(Integer contactsCount){
        List<ContactRelationshipsModel> conRelsModelsList = new List<ContactRelationshipsModel>();
        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(contactsCount);
        
        for (Contact con : contactsList){
            Id conFakeId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
            con.Id = conFakeId;

            ContactRelationshipsModel conRelsModel = new ContactRelationshipsModel(conFakeId);
            conRelsModelsList.add(conRelsModel);
        }

        return conRelsModelsList;
    }
}