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
* @group-content ../../ApexDocContent/Relationships.htm
* @description Test class for SRVC_ReciprocalRelationshipList.
*/
@isTest
private class SRVC_ReciprocalRelationshipList_TEST {
    /**************************************************************************************************************************
    * @description Test for getRelationshipsToUpdateForContacts no mapping.
    ***************************************************************************************************************************/
    @isTest
    private static void getRelationshipsToUpdateForContactsNoMappingTest() {
        Contact fatherContact = UTIL_UnitTestData_TEST.getContact();
        Contact sonContact = UTIL_UnitTestData_TEST.getContact();
        fatherContact.Gender__c = 'Male';
        sonContact.Gender__c = 'Male';
        insert new List<Contact>{fatherContact, sonContact};

        Relationship__c fatherRelationship = UTIL_UnitTestData_TEST.getRelationship(sonContact.Id, fatherContact.Id, 'Father');
        insert fatherRelationship;

        List<Relationship__c> relationships = [SELECT ID,
                                                    Contact__c,
                                                    RelatedContact__c,
                                                    ReciprocalRelationship__c,
                                                    Type__c     
                                                FROM Relationship__c];
        Map<Id, Relationship__c> relationshipsByIdToUpdateMap = new Map<Id, Relationship__c>(relationships);
       
        SRVC_ReciprocalRelationshipList instance = new SRVC_ReciprocalRelationshipList();

        Test.startTest();
            fatherContact.Gender__c = 'Female';
            fatherContact.Salutation = 'Mr.';
            Map<Id, Contact> newContactRelationshipToUpdateByIdMap = new Map<Id, Contact>();
            newContactRelationshipToUpdateByIdMap.put(fatherContact.Id, fatherContact);
            List<Relationship__c> relationshipsToUpdate = instance.getRelationshipsToUpdateForContacts(newContactRelationshipToUpdateByIdMap, relationshipsByIdToUpdateMap);
        Test.stopTest();
        
        System.assertEquals(1, relationshipsToUpdate.size());
        System.assertEquals(fatherRelationship.Id, relationshipsToUpdate[0].Id);
        System.assertEquals('Son', relationshipsToUpdate[0].Type__c);
    }

    /**************************************************************************************************************************
    * @description Test for getRelationshipsToUpdateForContacts if gender.
    ***************************************************************************************************************************/
    @isTest
    private static void getRelationshipsToUpdateForContactsGenderTest() {
        Relationship_Lookup__c sonRelationshipLookup = new Relationship_Lookup__c(Name = 'Son',
                                                                            Active__c = true,
                                                                            Female__c = 'Mother',
                                                                            Male__c = 'Father',
                                                                            Neutral__c = 'Parent');
        insert sonRelationshipLookup;
        
        Relationship_Lookup__c fatherRelationshipLookup = new Relationship_Lookup__c(Name = 'Father',
                                                                            Active__c = true,
                                                                            Female__c = 'Daughter',
                                                                            Male__c = 'Son',
                                                                            Neutral__c = 'Child');
        insert fatherRelationshipLookup;

        Contact fatherContact = UTIL_UnitTestData_TEST.getContact();
        Contact sonContact = UTIL_UnitTestData_TEST.getContact();
        fatherContact.Gender__c = 'Male';
        sonContact.Gender__c = 'Male';
        insert new List<Contact>{fatherContact, sonContact};

        Relationship__c fatherRelationship = UTIL_UnitTestData_TEST.getRelationship(sonContact.Id, fatherContact.Id, 'Father');
        insert fatherRelationship;

        List<Relationship__c> relationships = [SELECT ID,
                                                    Contact__c,
                                                    RelatedContact__c,
                                                    ReciprocalRelationship__c,
                                                    Type__c     
                                                FROM Relationship__c];
        Map<Id, Relationship__c> relationshipsByIdToUpdateMap = new Map<Id, Relationship__c>(relationships);
        
        SRVC_ReciprocalRelationshipList instance = new SRVC_ReciprocalRelationshipList();

        Test.startTest();
            fatherContact.Gender__c = 'Female';
            fatherContact.Salutation = 'Mr.';
            Map<Id, Contact> newContactRelationshipToUpdateByIdMap = new Map<Id, Contact>();
            newContactRelationshipToUpdateByIdMap.put(fatherContact.Id, fatherContact);
            List<Relationship__c> relationshipsToUpdate = instance.getRelationshipsToUpdateForContacts(newContactRelationshipToUpdateByIdMap, relationshipsByIdToUpdateMap);
        Test.stopTest();
        
        System.assertEquals(1, relationshipsToUpdate.size());
        System.assertEquals(fatherRelationship.Id, relationshipsToUpdate[0].Id);
        System.assertEquals('Mother', relationshipsToUpdate[0].Type__c);
    }

    /**************************************************************************************************************************
    * @description Test for getRelationshipsToUpdateForContacts if only salutation.
    ***************************************************************************************************************************/
    @isTest
    private static void getRelationshipsToUpdateForContactsSalutationOnlyTest() {
        Relationship_Lookup__c sonRelationshipLookup = new Relationship_Lookup__c(Name = 'Son',
                                                                            Active__c = true,
                                                                            Female__c = 'Mother',
                                                                            Male__c = 'Father',
                                                                            Neutral__c = 'Parent');
        insert sonRelationshipLookup;
        
        Relationship_Lookup__c fatherRelationshipLookup = new Relationship_Lookup__c(Name = 'Father',
                                                                            Active__c = true,
                                                                            Female__c = 'Daughter',
                                                                            Male__c = 'Son',
                                                                            Neutral__c = 'Child');
        insert fatherRelationshipLookup;

        Contact fatherContact = UTIL_UnitTestData_TEST.getContact();
        Contact sonContact = UTIL_UnitTestData_TEST.getContact();
        fatherContact.Gender__c = 'Male';
        sonContact.Gender__c = 'Male';
        insert new List<Contact>{fatherContact, sonContact};

        Relationship__c fatherRelationship = UTIL_UnitTestData_TEST.getRelationship(sonContact.Id, fatherContact.Id, 'Father');
        insert fatherRelationship;

        List<Relationship__c> relationships = [SELECT ID,
                                                    Contact__c,
                                                    RelatedContact__c,
                                                    ReciprocalRelationship__c,
                                                    Type__c     
                                                FROM Relationship__c];
        Map<Id, Relationship__c> relationshipsByIdToUpdateMap = new Map<Id, Relationship__c>(relationships);
        
        SRVC_ReciprocalRelationshipList instance = new SRVC_ReciprocalRelationshipList();

        Test.startTest();
            fatherContact.Salutation = 'Ms.';
            Map<Id, Contact> newContactRelationshipToUpdateByIdMap = new Map<Id, Contact>();
            newContactRelationshipToUpdateByIdMap.put(fatherContact.Id, fatherContact);
            List<Relationship__c> relationshipsToUpdate = instance.getRelationshipsToUpdateForContacts(newContactRelationshipToUpdateByIdMap, relationshipsByIdToUpdateMap);
        Test.stopTest();
        
        System.assertEquals(1, relationshipsToUpdate.size());
        System.assertEquals(fatherRelationship.Id, relationshipsToUpdate[0].Id);
        System.assertEquals('Mother', relationshipsToUpdate[0].Type__c);
    }

    /**************************************************************************************************************************
    * @description Test for getRelationshipToUpdateWithoutMapping.
    ***************************************************************************************************************************/
    @isTest
    private static void getRelationshipToUpdateWithoutMapping() {
        Contact fatherContact = UTIL_UnitTestData_TEST.getContact();
        Contact sonContact = UTIL_UnitTestData_TEST.getContact();
        insert new List<Contact>{fatherContact, sonContact};

        Relationship__c fatherRelationship = UTIL_UnitTestData_TEST.getRelationship(sonContact.Id, fatherContact.Id, 'Father');
        insert fatherRelationship;
       
        SRVC_ReciprocalRelationshipList instance = new SRVC_ReciprocalRelationshipList();

        Test.startTest();
            Relationship__c relationshipToUpdate = instance.getRelationshipToUpdateWithoutMapping(fatherRelationship, 'Son');
        Test.stopTest();
        
        System.assertNotEquals(null, relationshipToUpdate);
        System.assertEquals('Son', relationshipToUpdate.Type__c);
    }

    /**************************************************************************************************************************
    * @description Test for getRelationshipToUpdateFromGender if female.
    ***************************************************************************************************************************/
    @isTest
    private static void getRelationshipToUpdateFromGenderFemaleTest() {
        Relationship_Lookup__c relationshipLookup = new Relationship_Lookup__c(Name = 'Son',
                                                                            Active__c = true,
                                                                            Female__c = 'Mother',
                                                                            Male__c = 'Father',
                                                                            Neutral__c = 'Parent');
        insert relationshipLookup;
        
        MODL_ReciprocalRelationshipMapping reciprocalRelationshipMappingModel = MAPR_ReciprocalRelationshipSettings.getInstance().getActiveMappingModelsFromRelationshipLookups().get('Son');

        Contact fatherContact = UTIL_UnitTestData_TEST.getContact();
        Contact sonContact = UTIL_UnitTestData_TEST.getContact();
        insert new List<Contact>{fatherContact, sonContact};

        Relationship__c fatherRelationship = UTIL_UnitTestData_TEST.getRelationship(sonContact.Id, fatherContact.Id, 'Father');
        insert fatherRelationship;

        SRVC_ReciprocalRelationshipList instance = new SRVC_ReciprocalRelationshipList();

        Set<String> femaleGenderSet = instance.getFemaleGenderSet();
        Set<String> maleGenderSet = instance.getMaleGenderSet();
        
        Test.startTest();
            fatherContact.Gender__c = 'Female';
            Relationship__c relationshipToUpdate = instance.getRelationshipToUpdateFromGender(fatherRelationship, fatherContact, reciprocalRelationshipMappingModel, femaleGenderSet, maleGenderSet);
        Test.stopTest();
        
        System.assertNotEquals(null, relationshipToUpdate);
        System.assertEquals('Mother', relationshipToUpdate.Type__c);
    }

    /**************************************************************************************************************************
    * @description Test for getRelationshipToUpdateFromGender if male.
    ***************************************************************************************************************************/
    @isTest
    private static void getRelationshipToUpdateFromGenderMaleTest() {
        Relationship_Lookup__c relationshipLookup = new Relationship_Lookup__c(Name = 'Son',
                                                                            Active__c = true,
                                                                            Female__c = 'Mother',
                                                                            Male__c = 'Father',
                                                                            Neutral__c = 'Parent');
        insert relationshipLookup;
        
        MODL_ReciprocalRelationshipMapping reciprocalRelationshipMappingModel = MAPR_ReciprocalRelationshipSettings.getInstance().getActiveMappingModelsFromRelationshipLookups().get('Son');

        Contact fatherContact = UTIL_UnitTestData_TEST.getContact();
        Contact sonContact = UTIL_UnitTestData_TEST.getContact();
        insert new List<Contact>{fatherContact, sonContact};

        Relationship__c fatherRelationship = UTIL_UnitTestData_TEST.getRelationship(sonContact.Id, fatherContact.Id, 'Father');
        insert fatherRelationship;

        SRVC_ReciprocalRelationshipList instance = new SRVC_ReciprocalRelationshipList();

        Set<String> femaleGenderSet = instance.getFemaleGenderSet();
        Set<String> maleGenderSet = instance.getMaleGenderSet();
           
        Test.startTest();
            fatherContact.Gender__c = 'Male';
            Relationship__c relationshipToUpdate = instance.getRelationshipToUpdateFromGender(fatherRelationship, fatherContact, reciprocalRelationshipMappingModel, femaleGenderSet, maleGenderSet);
        Test.stopTest();
        
        System.assertNotEquals(null, relationshipToUpdate);
        System.assertEquals('Father', relationshipToUpdate.Type__c);
    }

    /**************************************************************************************************************************
    * @description Test for getRelationshipToUpdateFromGender if neutral.
    ***************************************************************************************************************************/
    @isTest
    private static void getRelationshipToUpdateFromGenderNeutralTest() {
        Relationship_Lookup__c relationshipLookup = new Relationship_Lookup__c(Name = 'Son',
                                                                            Active__c = true,
                                                                            Female__c = 'Mother',
                                                                            Male__c = 'Father',
                                                                            Neutral__c = 'Parent');
        insert relationshipLookup;
        
        MODL_ReciprocalRelationshipMapping reciprocalRelationshipMappingModel = MAPR_ReciprocalRelationshipSettings.getInstance().getActiveMappingModelsFromRelationshipLookups().get('Son');

        Contact fatherContact = UTIL_UnitTestData_TEST.getContact();
        Contact sonContact = UTIL_UnitTestData_TEST.getContact();
        insert new List<Contact>{fatherContact, sonContact};

        Relationship__c fatherRelationship = UTIL_UnitTestData_TEST.getRelationship(sonContact.Id, fatherContact.Id, 'Father');
        insert fatherRelationship;

        SRVC_ReciprocalRelationshipList instance = new SRVC_ReciprocalRelationshipList();
        
        Set<String> femaleGenderSet = instance.getFemaleGenderSet();
        Set<String> maleGenderSet = instance.getMaleGenderSet();
               
        Test.startTest();
            fatherContact.Gender__c = 'Neutral';
            Relationship__c relationshipToUpdate = instance.getRelationshipToUpdateFromGender(fatherRelationship, fatherContact, reciprocalRelationshipMappingModel, femaleGenderSet, maleGenderSet);
        Test.stopTest();
        
        System.assertEquals(null, relationshipToUpdate);
    }

    /**************************************************************************************************************************
    * @description Test for getRelationshipToUpdateFromSalutation if female.
    ***************************************************************************************************************************/
    @isTest
    private static void getRelationshipToUpdateFromSalutationFemaleTest() {
        Relationship_Lookup__c relationshipLookup = new Relationship_Lookup__c(Name = 'Son',
                                                                            Active__c = true,
                                                                            Female__c = 'Mother',
                                                                            Male__c = 'Father',
                                                                            Neutral__c = 'Parent');
        insert relationshipLookup;
        
        MODL_ReciprocalRelationshipMapping reciprocalRelationshipMappingModel = MAPR_ReciprocalRelationshipSettings.getInstance().getActiveMappingModelsFromRelationshipLookups().get('Son');

        Contact fatherContact = UTIL_UnitTestData_TEST.getContact();
        Contact sonContact = UTIL_UnitTestData_TEST.getContact();
        insert new List<Contact>{fatherContact, sonContact};

        Relationship__c fatherRelationship = UTIL_UnitTestData_TEST.getRelationship(sonContact.Id, fatherContact.Id, 'Father');
        insert fatherRelationship;

        SRVC_ReciprocalRelationshipList instance = new SRVC_ReciprocalRelationshipList();
        
        Set<String> femaleSalutationSet = instance.getFemaleSalutationSet();
        Set<String> maleSalutationSet = instance.getMaleSalutationSet();
        
        Test.startTest();
            fatherContact.Salutation = 'Ms.';
            Relationship__c relationshipToUpdate = instance.getRelationshipToUpdateFromSalutation(fatherRelationship, fatherContact, reciprocalRelationshipMappingModel, femaleSalutationSet, maleSalutationSet);
        Test.stopTest();
        
        System.assertNotEquals(null, relationshipToUpdate);
        System.assertEquals('Mother', relationshipToUpdate.Type__c);
    }

    /**************************************************************************************************************************
    * @description Test for getRelationshipToUpdateFromSalutation if male.
    ***************************************************************************************************************************/
    @isTest
    private static void getRelationshipToUpdateFromSalutationMaleTest() {
        Relationship_Lookup__c relationshipLookup = new Relationship_Lookup__c(Name = 'Son',
                                                                            Active__c = true,
                                                                            Female__c = 'Mother',
                                                                            Male__c = 'Father',
                                                                            Neutral__c = 'Parent');
        insert relationshipLookup;
        
        MODL_ReciprocalRelationshipMapping reciprocalRelationshipMappingModel = MAPR_ReciprocalRelationshipSettings.getInstance().getActiveMappingModelsFromRelationshipLookups().get('Son');

        Contact fatherContact = UTIL_UnitTestData_TEST.getContact();
        Contact sonContact = UTIL_UnitTestData_TEST.getContact();
        insert new List<Contact>{fatherContact, sonContact};

        Relationship__c fatherRelationship = UTIL_UnitTestData_TEST.getRelationship(sonContact.Id, fatherContact.Id, 'Father');
        insert fatherRelationship;

        SRVC_ReciprocalRelationshipList instance = new SRVC_ReciprocalRelationshipList();
        
        Set<String> femaleSalutationSet = instance.getFemaleSalutationSet();
        Set<String> maleSalutationSet = instance.getMaleSalutationSet();
               
        Test.startTest();
            fatherContact.Salutation = 'Mr.';
            Relationship__c relationshipToUpdate = instance.getRelationshipToUpdateFromSalutation(fatherRelationship, fatherContact, reciprocalRelationshipMappingModel, femaleSalutationSet, maleSalutationSet);
        Test.stopTest();
        
        System.assertNotEquals(null, relationshipToUpdate);
        System.assertEquals('Father', relationshipToUpdate.Type__c);
    }

    /**************************************************************************************************************************
    * @description Test for getRelationshipToUpdateFromSalutation if neutral.
    ***************************************************************************************************************************/
    @isTest
    private static void getRelationshipToUpdateFromSalutationNeutralTest() {
        Relationship_Lookup__c relationshipLookup = new Relationship_Lookup__c(Name = 'Son',
                                                                            Active__c = true,
                                                                            Female__c = 'Mother',
                                                                            Male__c = 'Father',
                                                                            Neutral__c = 'Parent');
        insert relationshipLookup;
        
        MODL_ReciprocalRelationshipMapping reciprocalRelationshipMappingModel = MAPR_ReciprocalRelationshipSettings.getInstance().getActiveMappingModelsFromRelationshipLookups().get('Son');

        List<Contact> testContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(10);
        insert testContacts;
        List<Contact> fatherContacts = new List<Contact>();
        List<Contact> sonContacts = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            if (i < 5) {
                sonContacts.add(testContacts[i]); 
            } else {
                fatherContacts.add(testContacts[i]);  
            }
        }

        List<Relationship__c> fatherRelationships = new List<Relationship__c>();
        for (Integer i = 0; i < 5; i++) {
            Relationship__c fatherRelationship = UTIL_UnitTestData_TEST.getRelationship(sonContacts[i].Id, fatherContacts[i].Id, 'Father'); 
            fatherRelationships.add(fatherRelationship);
        }
        insert fatherRelationships;

        SRVC_ReciprocalRelationshipList instance = new SRVC_ReciprocalRelationshipList();
        
        Set<String> femaleSalutationSet = instance.getFemaleSalutationSet();
        Set<String> maleSalutationSet = instance.getMaleSalutationSet();
               
        Test.startTest();
            List<Relationship__c> resultRelationships = new List<Relationship__c>();
            for (Integer i = 0; i < 5; i++) {
                fatherContacts[i].Salutation = 'Neutral';
                Relationship__c relationshipToUpdate = instance.getRelationshipToUpdateFromSalutation(fatherRelationships[i], fatherContacts[i], reciprocalRelationshipMappingModel, femaleSalutationSet, maleSalutationSet);
                if (relationshipToUpdate != null) {
                    resultRelationships.add(relationshipToUpdate);
                }
            }
        Test.stopTest();
        
        
        System.assertNotEquals(5, resultRelationships.size());
        for (Relationship__c resultRelationship : resultRelationships) {
            System.assertEquals('Parent', resultRelationship.Type__c);
        }
    }

    /**************************************************************************************************************************
    * @description Test for locateReciprocalRelationshipMapper.
    ***************************************************************************************************************************/
    @isTest
    private static void locateReciprocalRelationshipMapperTest() {   
        SRVC_ReciprocalRelationshipList instance = new SRVC_ReciprocalRelationshipList();

        Test.startTest();
            MAPR_ReciprocalRelationshipSettings maprReciprocalRelationshipSettingsInstance = instance.locateReciprocalRelationshipMapper();
        Test.stopTest();

        System.assertEquals(MAPR_ReciprocalRelationshipSettings.instance, maprReciprocalRelationshipSettingsInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, maprReciprocalRelationshipSettingsInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test for getFemaleGenderSet.
    ***************************************************************************************************************************/
    @isTest
    private static void getFemaleGenderSetTest() {
        SRVC_ReciprocalRelationshipList instance = new SRVC_ReciprocalRelationshipList();

        Test.startTest();
            Set<String> femaleGenderSet = instance.getFemaleGenderSet();
        Test.stopTest();

        System.assertEquals(true, femaleGenderSet.size() > 0);
    }

    /**************************************************************************************************************************
    * @description Test for getMaleGenderSet.
    ***************************************************************************************************************************/
    @isTest
    private static void getMaleGenderSetTest() {
        SRVC_ReciprocalRelationshipList instance = new SRVC_ReciprocalRelationshipList();

        Test.startTest();
            Set<String> maleGenderSet = instance.getMaleGenderSet();
        Test.stopTest();

        System.assertEquals(true, maleGenderSet.size() > 0);
    }
    
    /**************************************************************************************************************************
    * @description Test for getFemaleLabelList.
    ***************************************************************************************************************************/
    @isTest
    private static void getFemaleLabelListTest() {
        SRVC_ReciprocalRelationshipList instance = new SRVC_ReciprocalRelationshipList();

        Test.startTest();
            List<String> femaleLabelList = instance.getFemaleLabelList();
        Test.stopTest();

        System.assertEquals(true, femaleLabelList.size() > 0);
    }

    /**************************************************************************************************************************
    * @description Test for getMaleLabelList.
    ***************************************************************************************************************************/
    @isTest
    private static void getMaleLabelListTest() {
        SRVC_ReciprocalRelationshipList instance = new SRVC_ReciprocalRelationshipList();

        Test.startTest();
            List<String> maleLabelList = instance.getMaleLabelList();
        Test.stopTest();

        System.assertEquals(true, maleLabelList.size() > 0);
    }

    /**************************************************************************************************************************
    * @description Test for getFemaleSalutationSet.
    ***************************************************************************************************************************/
    @isTest
    private static void getFemaleSalutationSetTest() {
        SRVC_ReciprocalRelationshipList instance = new SRVC_ReciprocalRelationshipList();

        Test.startTest();
            Set<String> femaleSalutationSet = instance.getFemaleSalutationSet();
        Test.stopTest();

        System.assertEquals(true, femaleSalutationSet.size() >= 2);
    }

    /**************************************************************************************************************************
    * @description Test for getMaleSalutationSet.
    ***************************************************************************************************************************/
    @isTest
    private static void getMaleSalutationSetTest() {
        SRVC_ReciprocalRelationshipList instance = new SRVC_ReciprocalRelationshipList();

        Test.startTest();
            Set<String> maleSalutationSet = instance.getMaleSalutationSet();
        Test.stopTest();

        System.assertEquals(true, maleSalutationSet.size() >= 1);
    }
}
