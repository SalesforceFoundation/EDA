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
* @group-content ../../ApexDocContent/Relationships.htm
* @description Test class for SRVC_ReciprocalRelationshipInversion.
*/
@isTest
private class SRVC_ReciprocalRelInversion_TEST {

    /**************************************************************************************************************************
    * @description Test for getInversedRelationship when the relationship type is a string with hyphen in the middle.
    ***************************************************************************************************************************/
    @isTest
    private static void getInversedRelationshipWithHyphenMiddleTest() {
        String relationshipType = 'abc' + Label.Relationship_Split + 'def';
 
        SRVC_ReciprocalRelationshipInversion instance = new SRVC_ReciprocalRelationshipInversion();

        Test.startTest();
            String inversedRelationshipType = instance.getInversedRelationshipType(relationshipType);
        Test.stopTest();

        System.assertEquals('def' + Label.Relationship_Split + 'abc', inversedRelationshipType);
    }

    /**************************************************************************************************************************
    * @description Test for getInversedRelationship when the relationship type is a string with hyphen at the end.
    ***************************************************************************************************************************/
    @isTest
    private static void getInversedRelationshipWithHyphenEndTest() {
        String relationshipType = 'abc' + Label.Relationship_Split;

        SRVC_ReciprocalRelationshipInversion instance = new SRVC_ReciprocalRelationshipInversion();
 
        Test.startTest();
            String inversedRelationshipType = instance.getInversedRelationshipType(relationshipType);
        Test.stopTest();

        System.assertEquals('abc', inversedRelationshipType);
    }

    /**************************************************************************************************************************
    * @description Test for getInversedRelationship when the relationship type is a string with hyphen at the beginning.
    ***************************************************************************************************************************/
    @isTest
    private static void getInversedRelationshipWithHyphenBeginTest() {
        String relationshipType = Label.Relationship_Split + 'def';

        SRVC_ReciprocalRelationshipInversion instance = new SRVC_ReciprocalRelationshipInversion();
 
        Test.startTest();
            String inversedRelationshipType = instance.getInversedRelationshipType(relationshipType);
        Test.stopTest();

        System.assertEquals('def' + Label.Relationship_Split, inversedRelationshipType);
    }

    /**************************************************************************************************************************
    * @description Test for getInversedRelationship when the relationship type is a string with only hyphen.
    ***************************************************************************************************************************/
    /*@isTest
    private static void getInversedRelationshipWithOnlyHyphenTest() {
        String relationshipType = Label.Relationship_Split;
 
        Test.startTest();
            String inversedRelationshipType = instance.getInversedRelationshipType(relationshipType);
        Test.stopTest();

        System.assertEquals(Label.Relationship_Split, inversedRelationshipType);
    }TODO: this is currently a bug or at least we are not preventing users from entering only hyphen*/ 

    /**************************************************************************************************************************
    * @description Test for getInversedRelationship when the relationship type is empty string.
    ***************************************************************************************************************************/
    @isTest
    private static void getInversedRelationshipWithEmptyStringTest() { 
        SRVC_ReciprocalRelationshipInversion instance = new SRVC_ReciprocalRelationshipInversion();

        Test.startTest();
            String inversedRelationshipType = instance.getInversedRelationshipType('');
        Test.stopTest();

        System.assertEquals('', inversedRelationshipType);
    }

    /**************************************************************************************************************************
    * @description Test for getInversedRelationship when the relationship type is a string with hyphen in the middle.
    ***************************************************************************************************************************/
    /*@isTest
    private static void getInversedRelationshipWithMoreThanTwoRelMiddleTest() {
        String relationshipType = 'abc' + Label.Relationship_Split + 'def' + Label.Relationship_Split + 'ghi';
 
        Test.startTest();
            String inversedRelationshipType = instance.getInversedRelationshipType(relationshipType);
        Test.stopTest();

        System.assertEquals('def' + Label.Relationship_Split + 'abc', inversedRelationshipType);
    }TODO: this is currently a bug. The result returns def-abc and we are not preventing users from entering long relationship type*/

    /**************************************************************************************************************************
    * @description Test method for getRelationshipsToUpdateForContacts() if relationships exist
    ***************************************************************************************************************************/
    @isTest
    private static void getRelationshipsToUpdateForContactsRelationshipsExistHyphenMiddleTest() {
        List<Contact> testContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(10);
        List<Contact> fatherContacts = new List<Contact>();
        List<Contact> sonContacts = new List<Contact>();
        Map<Id, Contact> newContactRelationshipToUpdateByIdMap = new Map<Id, Contact>();
        for (Integer i = 0; i < 10; i++) {
            testContacts[i].Gender__c = 'Male';
            if (i < 5) {
                sonContacts.add(testContacts[i]); 
            } else {
                fatherContacts.add(testContacts[i]);
            }
        }
        insert testContacts;

        for (Contact fatherContact : fatherContacts) {
            newContactRelationshipToUpdateByIdMap.put(fatherContact.Id, fatherContact);
        }

        List<Relationship__c> fatherRelationships = new List<Relationship__c>();
        for (Integer i = 0; i < 5; i++) {
            Relationship__c fatherRelationship = UTIL_UnitTestData_TEST.getRelationship(sonContacts[i].Id, fatherContacts[i].Id, 'Father' + Label.Relationship_Split + 'Son'); 
            fatherRelationships.add(fatherRelationship);
        }
        insert fatherRelationships;

        List<Relationship__c> relationships = [SELECT ID,
                                                    Contact__c,
                                                    RelatedContact__c,
                                                    ReciprocalRelationship__c,
                                                    Type__c     
                                                FROM Relationship__c];
        Map<Id, Relationship__c> relationshipsByIdToUpdateMap = new Map<Id, Relationship__c>(relationships);

        SRVC_ReciprocalRelationshipInversion instance = new SRVC_ReciprocalRelationshipInversion();

        Test.startTest();
        List<Relationship__c> relationshipsToUpdateList = instance.getRelationshipsToUpdateForContacts(newContactRelationshipToUpdateByIdMap, relationshipsByIdToUpdateMap);
        Test.stopTest();

        System.assertEquals(5, relationshipsToUpdateList.size());
        for (Relationship__c resultRelationship : relationshipsToUpdateList) {
            System.assertEquals('Son' + Label.Relationship_Split + 'Father', resultRelationship.Type__c);
        }
    }

    /**************************************************************************************************************************
    * @description Test method for getRelationshipsToUpdateForContacts() if no relationship exists
    ***************************************************************************************************************************/
    @isTest
    private static void getRelationshipsToUpdateForContactsNoRelationshipTest() {
        SRVC_ReciprocalRelationshipInversion instance = new SRVC_ReciprocalRelationshipInversion();

        Test.startTest();
            List<Relationship__c> relationshipsToUpdateList = instance.getRelationshipsToUpdateForContacts(new Map<Id,Contact>(), new Map<Id, Relationship__c>());
        Test.stopTest();
        
        System.assertEquals(0, relationshipsToUpdateList.size());
    }
}
