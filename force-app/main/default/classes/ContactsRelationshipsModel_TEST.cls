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
* @description Test class for ContactsRelationshipsModel. 
*/
@isTest
private with sharing class ContactsRelationshipsModel_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that addRelationshipWithExisting() adds a new Contact Relationships model and populates
    * all variables when the new Contact Relationships model is associated with relationships.
    **************************************************************************************************************************/
    @isTest 
    private static void addContactRelationshipsModelTrue(){
        List<ContactsRelationshipsModel> contactsRelationshipsModelsList = new List<ContactsRelationshipsModel>();

        for (Integer i = 0; i < 5; i++){
            ContactsRelationshipsModel consRelsModel = new ContactsRelationshipsModel();
            contactsRelationshipsModelsList.add(consRelsModel);
        }

        Test.startTest();
        for (ContactsRelationshipsModel consRelsMod : contactsRelationshipsModelsList){
            List<ContactRelationshipsModel> conRelsModelsList = ContactsRelationshipsModel_TEST.getContactRelationshipsModelList(5);

            for (ContactRelationshipsModel conRelsMod : conRelsModelsList){
                for (Integer i = 0; i < 5; i++){
                    Id fakeRelConId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
                    Relationship__c rel = UTIL_UnitTestData_TEST.getRelationship(conRelsMod.contactId, fakeRelConId, 'Cousin');
                    conRelsMod.addRelationship(rel);
                }
            }

            for (ContactRelationshipsModel conRelsMod : conRelsModelsList){
                consRelsMod.addContactRelationshipsModel(conRelsMod);
            }
        }
        Test.stopTest();

        for (ContactsRelationshipsModel consRelsMod : contactsRelationshipsModelsList){
            System.assertEquals(5, consRelsMod.contactRelationshipsModelsByContactId.keySet().size(), 'Each Contacts Relationships model should be associated with 5 Contact Relationships models.');
            System.assertEquals(5, consRelsMod.contactIdsSet.size(), 'Each Contacts Relationships model should be associated with 5 Contacts.');
            System.assertEquals(25, consRelsMod.relatedContactIdSet.size(), 'Each Contacts Relationships model should be associated with 25 related Contacts.');
            System.assertEquals(25, consRelsMod.relationshipList.size(), 'Each Contacts Relationships model should be associated with 25 Relationships.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that addRelationshipWithExisting() adds a new Contact Relationships model, but does
    * not populuate the relatedContactIdSet and relationshipsList variables when the new Contact Relationships model is not 
    * associated Relationships any relationships.
    **************************************************************************************************************************/
    @isTest 
    private static void addContactRelationshipsModelFalse(){
        List<ContactsRelationshipsModel> contactsRelationshipsModelsList = new List<ContactsRelationshipsModel>();

        for (Integer i = 0; i < 5; i++){
            ContactsRelationshipsModel consRelsModel = new ContactsRelationshipsModel();
            contactsRelationshipsModelsList.add(consRelsModel);
        }

        Test.startTest();
        for (ContactsRelationshipsModel consRelsMod : contactsRelationshipsModelsList){
            List<ContactRelationshipsModel> conRelsModelsList = ContactsRelationshipsModel_TEST.getContactRelationshipsModelList(5);

            for (ContactRelationshipsModel conRelsMod : conRelsModelsList){
                consRelsMod.addContactRelationshipsModel(conRelsMod);
            }
        }
        Test.stopTest();

        for (ContactsRelationshipsModel consRelsMod : contactsRelationshipsModelsList){
            System.assertEquals(5, consRelsMod.contactRelationshipsModelsByContactId.keySet().size(), 'Each Contacts Relationships model should be associated with 5 Contact Relationships models.');
            System.assertEquals(5, consRelsMod.contactIdsSet.size(), 'Each Contacts Relationships model should be associated with 5 Contacts.');
            System.assertEquals(true, consRelsMod.relatedContactIdSet.isEmpty(), 'Each Contacts Relationships model should be associated with no related Contacts.');
            System.assertEquals(true, consRelsMod.relationshipList.isEmpty(), 'Each Contacts Relationships model should be associated with no Relationships.');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that hasRelationship() returns true when a specified Relationship record is  
    * found in the list of Relationship records associated with a Contacts Relationships model.
    **************************************************************************************************************************/
    @isTest 
    private static void hasRelationshipTrue(){
        List<ContactsRelationshipsModel> contactsRelationshipsModelsList = new List<ContactsRelationshipsModel>();
        Map<ContactRelationshipsModel, List<Relationship__c>> relationshipsToFindByContactRelsModel = new Map<ContactRelationshipsModel, List<Relationship__c>>();

        for (Integer i = 0; i < 5; i++){
            ContactsRelationshipsModel consRelsModel = new ContactsRelationshipsModel();
            contactsRelationshipsModelsList.add(consRelsModel);
        }

        for (ContactsRelationshipsModel consRelsMod : contactsRelationshipsModelsList){
            List<ContactRelationshipsModel> conRelsModelsList = ContactsRelationshipsModel_TEST.getContactRelationshipsModelList(5);
            conRelsModelsList = ContactsRelationshipsModel_TEST.addRelationshipsToContactRelationshipsModels(conRelsModelsList, 3);

            for (ContactRelationshipsModel conRelsMod : conRelsModelsList){
                List<Relationship__c> relationshipsToFind = relationshipsToFindByContactRelsModel.get(conRelsMod);
                if (relationshipsToFind == null){
                    relationshipsToFind = new List<Relationship__c>();
                }

                relationshipsToFind.add(conRelsMod.relationshipList[0]); 
                relationshipsToFind.add(conRelsMod.relationshipList[1]);
                relationshipsToFindByContactRelsModel.put(conRelsMod, relationshipsToFind);
                consRelsMod.addContactRelationshipsModel(conRelsMod);
            }
        }
        
        Test.startTest();
        for (ContactsRelationshipsModel consRelsMod : contactsRelationshipsModelsList){
            for (Id conId : consRelsMod.contactIdsSet){
                ContactRelationshipsModel conRelsMod = consRelsMod.contactRelationshipsModelsByContactId.get(conId);
                for (Relationship__c relToFind : relationshipsToFindByContactRelsModel.get(conRelsMod)){
                    System.assertEquals(true, consRelsMod.hasRelationship(relToFind), 'There should be matching Relationships in relationships associated with current Contacts Relationships model.');
                }
            }
        }
        Test.stopTest();
    }

    /**************************************************************************************************************************
    * @description Test method to verify that hasRelationship() returns false when a specified Relationship record is not 
    * found in the list of Relationship records associated with a Contacts Relationships model.
    **************************************************************************************************************************/
    @isTest 
    private static void hasRelationshipFalse(){
        List<Relationship__c> relationshipsToFind = new List<Relationship__c>();
        List<ContactsRelationshipsModel> contactsRelationshipsModelsList = new List<ContactsRelationshipsModel>();

        for (Integer i = 0; i < 5; i++){
            ContactsRelationshipsModel consRelsModel = new ContactsRelationshipsModel();
            contactsRelationshipsModelsList.add(consRelsModel);
        }

        for (ContactsRelationshipsModel consRelsMod : contactsRelationshipsModelsList){
            List<ContactRelationshipsModel> conRelsModelsList = ContactsRelationshipsModel_TEST.getContactRelationshipsModelList(5);
            conRelsModelsList = ContactsRelationshipsModel_TEST.addRelationshipsToContactRelationshipsModels(conRelsModelsList, 5);

            for (ContactRelationshipsModel conRelsMod : conRelsModelsList){
                Relationship__c relToFind = UTIL_UnitTestData_TEST.getRelationship(conRelsMod.contactId, UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType), 'Cousin');
                relationshipsToFind.add(relToFind);
                consRelsMod.addContactRelationshipsModel(conRelsMod);
            }
        }
        
        Test.startTest();
        for (ContactsRelationshipsModel consRelsMod : contactsRelationshipsModelsList){
            for (Relationship__c relToFind : relationshipsToFind){
                if (consRelsMod.contactIdsSet.contains(relToFind.Contact__c)){
                    System.assertEquals(false, consRelsMod.hasRelationship(relToFind), 'There should be no matching Relationship in relationships associated with current Contacts Relationships model.');
                }
            }
        }
        Test.stopTest();
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getRelationship() returns true when a specified Relationship record is  
    * found in the list of Relationship records associated with a Contacts Relationships model.
    **************************************************************************************************************************/
    @isTest 
    private static void getRelationship(){
        List<ContactsRelationshipsModel> contactsRelationshipsModelsList = new List<ContactsRelationshipsModel>();
        Map<ContactRelationshipsModel, List<Relationship__c>> relationshipsToFindByContactRelsModel = new Map<ContactRelationshipsModel, List<Relationship__c>>();

        for (Integer i = 0; i < 5; i++){
            ContactsRelationshipsModel consRelsModel = new ContactsRelationshipsModel();
            contactsRelationshipsModelsList.add(consRelsModel);
        }

        for (ContactsRelationshipsModel consRelsMod : contactsRelationshipsModelsList){
            List<ContactRelationshipsModel> conRelsModelsList = ContactsRelationshipsModel_TEST.getContactRelationshipsModelList(5);
            conRelsModelsList = ContactsRelationshipsModel_TEST.addRelationshipsToContactRelationshipsModels(conRelsModelsList, 3);

            for (ContactRelationshipsModel conRelsMod : conRelsModelsList){
                List<Relationship__c> relationshipsToFind = relationshipsToFindByContactRelsModel.get(conRelsMod);
                if (relationshipsToFind == null){
                    relationshipsToFind = new List<Relationship__c>();
                }

                relationshipsToFind.add(conRelsMod.relationshipList[0]); 
                relationshipsToFind.add(conRelsMod.relationshipList[1]);
                relationshipsToFindByContactRelsModel.put(conRelsMod, relationshipsToFind);
                consRelsMod.addContactRelationshipsModel(conRelsMod);
            }
        }
        
        Test.startTest();
        for (ContactsRelationshipsModel consRelsMod : contactsRelationshipsModelsList){
            for (Id conId : consRelsMod.contactIdsSet){
                ContactRelationshipsModel conRelsMod = consRelsMod.contactRelationshipsModelsByContactId.get(conId);
                for (Relationship__c relToFind : relationshipsToFindByContactRelsModel.get(conRelsMod)){
                    System.assertNotEquals(null, consRelsMod.getRelationship(relToFind), 'There should be matching Relationships in relationships associated with current Contacts Relationships model.');
                }
            }
        }
        Test.stopTest();
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getRelationship() returns null there are no Contact Relationships models associated
    * with a specified contact.
    **************************************************************************************************************************/
    @isTest 
    private static void getRelationshipNull(){
        List<Relationship__c> relationshipsToFind = new List<Relationship__c>();
        for (Integer i = 0; i < 5; i++){
            Relationship__c relationship = UTIL_UnitTestData_TEST.getRelationship(UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType), UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType), 'Cousin');
            relationshipsToFind.add(relationship);
        }

        List<ContactsRelationshipsModel> contactsRelationshipsModelsList = new List<ContactsRelationshipsModel>();

        for (Integer i = 0; i < 5; i++){
            ContactsRelationshipsModel consRelsModel = new ContactsRelationshipsModel();
            contactsRelationshipsModelsList.add(consRelsModel);
        }

        for (ContactsRelationshipsModel consRelsMod : contactsRelationshipsModelsList){
            List<ContactRelationshipsModel> conRelsModelsList = ContactsRelationshipsModel_TEST.getContactRelationshipsModelList(5);
            conRelsModelsList = ContactsRelationshipsModel_TEST.addRelationshipsToContactRelationshipsModels(conRelsModelsList, 3);

            for (ContactRelationshipsModel conRelsMod : conRelsModelsList){
                consRelsMod.addContactRelationshipsModel(conRelsMod);
            }
        }
        
        Test.startTest();
        for (ContactsRelationshipsModel consRelsMod : contactsRelationshipsModelsList){
            for (Relationship__c relToFind : relationshipsToFind){
                System.assertEquals(null, consRelsMod.getRelationship(relToFind), 'There should be no matching Relationship in relationships associated with current Contacts Relationships model.');
            }
        }
        Test.stopTest();
    }

    /**************************************************************************************************************************
    * @description Test method to verify that isEmpty() returns True when there are no Contact Relationships models associated
    * with a Contacts Relationships model.
    **************************************************************************************************************************/
    @isTest 
    private static void isEmptyTrue(){
        List<ContactsRelationshipsModel> contactsRelationshipsModelsList = new List<ContactsRelationshipsModel>();

        for (Integer i = 0; i < 5; i++){
            ContactsRelationshipsModel consRelsModel = new ContactsRelationshipsModel();
            contactsRelationshipsModelsList.add(consRelsModel);
        }

        Test.startTest();
        for (ContactsRelationshipsModel consRelsMod : contactsRelationshipsModelsList){
            System.assertEquals(true, consRelsMod.isEmpty(), 'There should be no Contact Relationships models associated with the current Contacts Relationships model.');
        }
        Test.stopTest();
    }

    /**************************************************************************************************************************
    * @description Test method to verify that isEmpty() returns False when there are Contact Relationships models associated
    * with a Contacts Relationships model.
    **************************************************************************************************************************/
    @isTest
    private static void isEmptyFalse(){
        List<ContactsRelationshipsModel> contactsRelationshipsModelsList = new List<ContactsRelationshipsModel>();

        for (Integer i = 0; i < 5; i++){
            ContactsRelationshipsModel consRelsModel = new ContactsRelationshipsModel();
            contactsRelationshipsModelsList.add(consRelsModel);
        }

        for (ContactsRelationshipsModel consRelsMod : contactsRelationshipsModelsList){
            List<ContactRelationshipsModel> conRelsModelsList = ContactsRelationshipsModel_TEST.getContactRelationshipsModelList(5);

            for (ContactRelationshipsModel conRelsMod : conRelsModelsList){
                consRelsMod.addContactRelationshipsModel(conRelsMod);
            }
        }

        Test.startTest();
        for (ContactsRelationshipsModel consRelsMod : contactsRelationshipsModelsList){
            System.assertEquals(false, consRelsMod.isEmpty(), 'There should be Contact Relationships models associated with the current Contacts Relationships model.');
        }
        Test.stopTest();
    }

    /**************************************************************************************************************************
    * @description Helper method to create and associate a specified number of Relationship records to a each model in a list of
    * Contact Relationships models.
    * @param conRelsModelsList The List of ContactRelationshipsModel models to associate with the specified number of new Relationships.
    * @param relationshipCount The number of Relationship records to generate for each model.
    * @return A list of ContactRelationshipsModel, each associated with the specified number of new Relationship records.
    **************************************************************************************************************************/
    private static List<ContactRelationshipsModel> addRelationshipsToContactRelationshipsModels(List<ContactRelationshipsModel> conRelsModelsList, Integer relationshipCount){
        for (ContactRelationshipsModel conRelsMod : conRelsModelsList){

            for (Integer i = 0; i < relationshipCount; i++){
                Relationship__c rel = UTIL_UnitTestData_TEST.getRelationship(conRelsMod.contactId, UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType), 'Cousin');
                rel.Id = UTIL_UnitTestData_TEST.getFakeId(Relationship__c.SObjectType);
                conRelsMod.addRelationship(rel);
            }
        }

        return conRelsModelsList;
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