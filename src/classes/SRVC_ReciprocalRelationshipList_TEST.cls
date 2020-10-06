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
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * SRVC_ReciprocalRelationshipList class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNewTest() {
        SRVC_ReciprocalRelationshipList srvcReciprocalRelationshipListInstance = SRVC_ReciprocalRelationshipList.getInstance();
        System.assertEquals(SRVC_ReciprocalRelationshipList.instance, srvcReciprocalRelationshipListInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, srvcReciprocalRelationshipListInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * SRVC_ReciprocalRelationshipList class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExistingTest() {
        SRVC_ReciprocalRelationshipList srvcReciprocalRelationshipListInstance1 = SRVC_ReciprocalRelationshipList.getInstance();
        SRVC_ReciprocalRelationshipList srvcReciprocalRelationshipListInstance2 = SRVC_ReciprocalRelationshipList.getInstance();
 
        System.assertEquals(SRVC_ReciprocalRelationshipList.instance, srvcReciprocalRelationshipListInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(srvcReciprocalRelationshipListInstance1, srvcReciprocalRelationshipListInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, srvcReciprocalRelationshipListInstance1 != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test for getRelationshipToUpdateFromSalutation if relationship exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getRelationshipToUpdateFromSalutationRelationshipExistsTest() {
        Contact fatherContact = UTIL_UnitTestData_TEST.getContact();
        Contact sonContact = UTIL_UnitTestData_TEST.getContact();
        insert new List<Contact>{fatherContact, sonContact};

        Relationship__c fatherRelationship = UTIL_UnitTestData_TEST.getRelationship(sonContact.Id, fatherContact.Id, 'Father');
        insert fatherRelationship;

        Relationship_Lookup__c relationshipLookup = new Relationship_Lookup__c(Name = 'Son',
                                                                            Active__c = true,
                                                                            Female__c = 'Mother',
                                                                            Male__c = 'Father',
                                                                            Neutral__c = 'Parent');
        insert relationshipLookup;

        Set<String> femaleSalutationSet = SRVC_ReciprocalRelationshipList.getInstance().getFemaleSalutationSet();
        Set<String> maleSalutationSet = SRVC_ReciprocalRelationshipList.getInstance().getMaleSalutationSet();
        MODL_ReciprocalRelationshipMapping reciprocalRelationshipMappingModel = MAPR_ReciprocalRelationshipSettings.getInstance().getActiveMappingModelsFromRelationshipLookups().get('Son');

        Test.startTest();
            fatherContact.Gender__c = 'Female';
            Relationship__c relationshipToUpdate = SRVC_ReciprocalRelationshipList.getInstance().getRelationshipToUpdateFromSalutation(fatherRelationship, fatherContact, reciprocalRelationshipMappingModel, femaleSalutationSet, maleSalutationSet);
        Test.stopTest();
        
        System.assertNotEquals(null, relationshipToUpdate);
        System.assertEquals('Mother', relationshipToUpdate.Type__c);
    }

    /**************************************************************************************************************************
    * @description Test for getRelationshipToUpdateFromSalutation if no relationship exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getRelationshipToUpdateFromSalutationNoRelationshipExistsTest() {
        Relationship_Lookup__c relationshipLookup = new Relationship_Lookup__c(Name = 'Son',
                                                                            Active__c = true,
                                                                            Female__c = 'Mother',
                                                                            Male__c = 'Father',
                                                                            Neutral__c = 'Parent');
        insert relationshipLookup;

        Set<String> femaleSalutationSet = SRVC_ReciprocalRelationshipList.getInstance().getFemaleSalutationSet();
        Set<String> maleSalutationSet = SRVC_ReciprocalRelationshipList.getInstance().getMaleSalutationSet();
        MODL_ReciprocalRelationshipMapping reciprocalRelationshipMappingModel = MAPR_ReciprocalRelationshipSettings.getInstance().getActiveMappingModelsFromRelationshipLookups().get('Son');

        Test.startTest();
            Relationship__c relationshipToUpdate = SRVC_ReciprocalRelationshipList.getInstance().getRelationshipToUpdateFromSalutation(null, null, reciprocalRelationshipMappingModel, femaleSalutationSet, maleSalutationSet);
        Test.stopTest();
        
        System.assertEquals(null, relationshipToUpdate);
    }

    /**************************************************************************************************************************
    * @description Test for locateReciprocalRelationshipMapper.
    ***************************************************************************************************************************/
    @isTest
    private static void locateReciprocalRelationshipMapperTest() {
        Test.startTest();
            MAPR_ReciprocalRelationshipSettings maprReciprocalRelationshipSettingsInstance = SRVC_ReciprocalRelationshipList.getInstance().locateReciprocalRelationshipMapper();
        Test.stopTest();

        System.assertEquals(MAPR_ReciprocalRelationshipSettings.instance, maprReciprocalRelationshipSettingsInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, maprReciprocalRelationshipSettingsInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test for getFemaleGenderSet.
    ***************************************************************************************************************************/
    @isTest
    private static void getFemaleGenderSetTest() {
        Test.startTest();
            Set<String> femaleGenderSet = SRVC_ReciprocalRelationshipList.getInstance().getFemaleGenderSet();
        Test.stopTest();

        System.assertEquals(true, femaleGenderSet.size() > 0);
    }

    /**************************************************************************************************************************
    * @description Test for getMaleGenderSet.
    ***************************************************************************************************************************/
    @isTest
    private static void getMaleGenderSetTest() {
        Test.startTest();
            Set<String> maleGenderSet = SRVC_ReciprocalRelationshipList.getInstance().getMaleGenderSet();
        Test.stopTest();

        System.assertEquals(true, maleGenderSet.size() > 0);
    }
    
    /**************************************************************************************************************************
    * @description Test for getFemaleLabelList.
    ***************************************************************************************************************************/
    @isTest
    private static void getFemaleLabelListTest() {
        Test.startTest();
            List<String> femaleLabelList = SRVC_ReciprocalRelationshipList.getInstance().getFemaleLabelList();
        Test.stopTest();

        System.assertEquals(true, femaleLabelList.size() > 0);
    }

    /**************************************************************************************************************************
    * @description Test for getMaleLabelList.
    ***************************************************************************************************************************/
    @isTest
    private static void getMaleLabelListTest() {
        Test.startTest();
            List<String> maleLabelList = SRVC_ReciprocalRelationshipList.getInstance().getMaleLabelList();
        Test.stopTest();

        System.assertEquals(true, maleLabelList.size() > 0);
    }

    /**************************************************************************************************************************
    * @description Test for getFemaleSalutationSet.
    ***************************************************************************************************************************/
    @isTest
    private static void getFemaleSalutationSetTest() {
        Test.startTest();
            Set<String> femaleSalutationSet = SRVC_ReciprocalRelationshipList.getInstance().getFemaleSalutationSet();
        Test.stopTest();

        System.assertEquals(true, femaleSalutationSet.size() >= 2);
    }

    /**************************************************************************************************************************
    * @description Test for getMaleSalutationSet.
    ***************************************************************************************************************************/
    @isTest
    private static void getMaleSalutationSetTest() {
        Test.startTest();
            Set<String> maleSalutationSet = SRVC_ReciprocalRelationshipList.getInstance().getMaleSalutationSet();
        Test.stopTest();

        System.assertEquals(true, maleSalutationSet.size() >= 1);
    }
}
