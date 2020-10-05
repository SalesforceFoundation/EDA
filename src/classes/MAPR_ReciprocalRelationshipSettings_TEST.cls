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
* @description Test class for MAPR_ReciprocalRelationshipSettings
*/
@isTest
private class MAPR_ReciprocalRelationshipSettings_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * MAPR_ReciprocalRelationshipSettings class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNewTest() {
        MAPR_ReciprocalRelationshipSettings maprReciprocalRelationshipSettingsInstance = MAPR_ReciprocalRelationshipSettings.getInstance();
        System.assertEquals(MAPR_ReciprocalRelationshipSettings.instance, maprReciprocalRelationshipSettingsInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, maprReciprocalRelationshipSettingsInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * MAPR_ReciprocalRelationshipSettings class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExistingTest() {
        MAPR_ReciprocalRelationshipSettings maprReciprocalRelationshipSettingsInstance1 = MAPR_ReciprocalRelationshipSettings.getInstance();
        MAPR_ReciprocalRelationshipSettings maprReciprocalRelationshipSettingsInstance2 = MAPR_ReciprocalRelationshipSettings.getInstance();
 
        System.assertEquals(MAPR_ReciprocalRelationshipSettings.instance, maprReciprocalRelationshipSettingsInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(maprReciprocalRelationshipSettingsInstance1, maprReciprocalRelationshipSettingsInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, maprReciprocalRelationshipSettingsInstance1 != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test for getModelFromMapping if relationship lookup exists
    ***************************************************************************************************************************/
    @isTest
    private static void getModelFromMappingRelationshipLookupExistsTest() {
        Relationship_Lookup__c relationshipLookup = new Relationship_Lookup__c(Name = 'test relationship name',
                                                                            Active__c = true,
                                                                            Female__c = 'Mother',
                                                                            Male__c = 'Father',
                                                                            Neutral__c = 'Parent');

        Test.startTest();
            MODL_ReciprocalRelationshipMapping modelReciprocalRelationshipMapping = MAPR_ReciprocalRelationshipSettings.getInstance().getModelFromMapping(relationshipLookup);
        Test.stopTest();

        System.assertEquals('test relationship name', modelReciprocalRelationshipMapping.getRelationshipName());
        System.assertEquals(true, modelReciprocalRelationshipMapping.getIsActive());
        System.assertEquals('Mother', modelReciprocalRelationshipMapping.getFemaleRelationshipType());
        System.assertEquals('Father', modelReciprocalRelationshipMapping.getMaleRelationshipType());
        System.assertEquals('Parent', modelReciprocalRelationshipMapping.getNeutralRelationshipType());
    }

    /**************************************************************************************************************************
    * @description Test for getActiveMappingModelsFromRelationshipLookups if relationship lookup exists
    ***************************************************************************************************************************/
    @isTest
    private static void getActiveMappingModelsFromRelationshipLookupsRelationshipLookupExistsTest() {
        Relationship_Lookup__c relationshipLookup = new Relationship_Lookup__c(Name = 'test relationship name',
                                                                            Active__c = true,
                                                                            Female__c = 'Mother',
                                                                            Male__c = 'Father',
                                                                            Neutral__c = 'Parent');
        insert relationshipLookup;

        Test.startTest();
            Map<String, MODL_ReciprocalRelationshipMapping> activeMappingModelsFromRelationshipLookups = MAPR_ReciprocalRelationshipSettings.getInstance().getActiveMappingModelsFromRelationshipLookups();
        Test.stopTest();

        System.assertEquals(1, activeMappingModelsFromRelationshipLookups.values().size());
        System.assertEquals('test relationship name', activeMappingModelsFromRelationshipLookups.get(relationshipLookup.Name).getRelationshipName());
        System.assertEquals(true, activeMappingModelsFromRelationshipLookups.get(relationshipLookup.Name).getIsActive());
        System.assertEquals('Mother', activeMappingModelsFromRelationshipLookups.get(relationshipLookup.Name).getFemaleRelationshipType());
        System.assertEquals('Father', activeMappingModelsFromRelationshipLookups.get(relationshipLookup.Name).getMaleRelationshipType());
        System.assertEquals('Parent', activeMappingModelsFromRelationshipLookups.get(relationshipLookup.Name).getNeutralRelationshipType());
    }

    /**************************************************************************************************************************
    * @description Test for getModelFromMapping if no relationship lookup exists
    ***************************************************************************************************************************/
    @isTest
    private static void getActiveMappingModelsFromRelationshipLookupsNoRelationshipLookupExistsTest() {
        Test.startTest();
            Map<String, MODL_ReciprocalRelationshipMapping> activeMappingModelsFromRelationshipLookups = MAPR_ReciprocalRelationshipSettings.getInstance().getActiveMappingModelsFromRelationshipLookups();
        Test.stopTest();

        System.assertEquals(0, activeMappingModelsFromRelationshipLookups.values().size());
    }
}