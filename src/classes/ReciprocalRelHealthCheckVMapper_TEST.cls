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
* @date 2021
* @group
* @group-content ../../ApexDocContent/Tests.htm
* @description Test class for ReciprocalRelHealthCheckVMapper
*/
@isTest
private class ReciprocalRelHealthCheckVMapper_TEST {

    /***************************************************************************
    * @description Test method to verify that the getInstance method returns a
    * new instance of the ReciprocalRelHealthCheckVMapper class when one does
    * not already exist.
    ***************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapperInstance =
            ReciprocalRelHealthCheckVMapper.getInstance();
        Test.stopTest();

        System.assertNotEquals(
            null,
            reciprocalRelHealthCheckVMapperInstance,
            'Instance of view model mapper class should not be null.'
        );

        System.assertEquals(
            ReciprocalRelHealthCheckVMapper.instance,
            reciprocalRelHealthCheckVMapperInstance,
            'Instance of view model mapper class returned should match static instance variable.'
        );
    }

    /***************************************************************************
    * @description Test method to verify that the getInstance method returns the
    * existing instance of the ReciprocalRelHealthCheckVMapper class when one
    * already exists.
    ***************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        ReciprocalRelHealthCheckVMapper expectedReciprocalRelHealthCheckVMapperInstance =
            ReciprocalRelHealthCheckVMapper.getInstance();

        Test.startTest();
            ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapperInstance =
                ReciprocalRelHealthCheckVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            expectedReciprocalRelHealthCheckVMapperInstance,
            reciprocalRelHealthCheckVMapperInstance,
            'Instance of mapper class returned should match cached value.'
        );
    }

    /***************************************************************************
    * @description Test method to verify that getHealthCheckGroup handles all
    * passed health checks
    * @TODO finish test
    ***************************************************************************/
    @isTest
    private static void getHealthCheckGroupAllPassed() {
        RelationshipLookupSettingsService.instance = 
            new STUB_RelationshipLookupSettingsService();
        PicklistEntryService.instance =
            new STUB_PicklistEntryService();

        STUB_ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapperStub =
            new STUB_ReciprocalRelHealthCheckVMapper();
        ReciprocalRelHealthCheckVMapper.instance = reciprocalRelHealthCheckVMapperStub;  

        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();
 
        List<RelationshipLookupModel> relationshipLookupModelList =
            reciprocalRelHealthCheckVMapperStub.locateRelationshipLookupSettingsService(
            ).getRelationshipLookupModels();

        Map<String,PicklistEntryModel> picklistEntryModelByName =
            reciprocalRelHealthCheckVMapperStub.locatePicklistEntryService(
            ).getModelsByNameForSObjectField(
                Relationship__c.SObjectType,
                Relationship__c.Type__c
            );

        Set<String> duplicateMappingKeys = new Set<String>();

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapperStub.getHealthCheckGroup();
        Test.stopTest();
    }

    /***************************************************************************
    * @description Test method to verify that
    * getRelationshipLookupHealthCheckGroup returns the expected health check
    ***************************************************************************/
    @isTest
    private static void getRelationshipLookupHealthCheckGroup() {
        RelationshipLookupSettingsService.instance = 
            new STUB_RelationshipLookupSettingsService();
        PicklistEntryService.instance =
            new STUB_PicklistEntryService();

        STUB_ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapperStub =
            new STUB_ReciprocalRelHealthCheckVMapper();
        ReciprocalRelHealthCheckVMapper.instance = reciprocalRelHealthCheckVMapperStub;  

        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();
 
        List<RelationshipLookupModel> relationshipLookupModelList =
            reciprocalRelHealthCheckVMapperStub.locateRelationshipLookupSettingsService(
            ).getRelationshipLookupModels();

        Map<String,PicklistEntryModel> picklistEntryModelByName =
            reciprocalRelHealthCheckVMapperStub.locatePicklistEntryService(
            ).getModelsByNameForSObjectField(
                Relationship__c.SObjectType,
                Relationship__c.Type__c
            );

        Set<String> duplicateMappingKeys = new Set<String>();

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapperStub.getRelationshipLookupHealthCheckGroup(
                    relationshipLookupModelList[0],
                    picklistEntryModelByName,
                    duplicateMappingKeys
                );
        Test.stopTest();

        System.assertEquals(
            '',
            healthCheckGroupVModel.label,
            'Label should equal expected value of blank'
        );
        System.assertEquals(
            '',
            healthCheckGroupVModel.status,
            'Status should equal expected value of blank'
        );
        System.assertEquals(
            0,
            healthCheckGroupVModel.passedChecks,
            'Passed checks should equal expected value of 0'
        );
        System.assertEquals(
            0,
            healthCheckGroupVModel.totalChecks,
            'Total checks should equal expected value of 0'
        );
        System.assertEquals(
            0,
            healthCheckGroupVModel.expandedRowsList.size(),
            'Expanded rows list should have a size of 0'
        );
        System.assertEquals(
            0,
            healthCheckGroupVModel.healthCheckItemList.size(),
            'Health Check Item list should have a size of 0'
        );
    }

    /***************************************************************************
    * @description Test method to verify that a PicklistEntryService is
    * retrieved by the locator method.
    ***************************************************************************/
    @isTest 
    private static void locatePicklistEntryService(){
        PicklistEntryService expectedPicklistEntryService
            = PicklistEntryService.getInstance();

        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        Test.startTest();
            PicklistEntryService picklistEntryService
                = reciprocalRelHealthCheckVMapper.locatePicklistEntryService();
        Test.stopTest();

        System.assertNotEquals(
            null,
            picklistEntryService,
            'Instance of service class should not be null.'
        );

        System.assertEquals(
            expectedPicklistEntryService,
            picklistEntryService,
            'Instance of service class from view model mapper should match the singleton instance.'
        );
    }

    /***************************************************************************
    * @description Test method to verify that a
    * RelationshipLookupSettingsService is retrieved by the locator method.
    ***************************************************************************/
    @isTest 
    private static void locateRelationshipLookupSettingsService(){
        RelationshipLookupSettingsService expectedRelationshipLookupSettingsService
            = RelationshipLookupSettingsService.getInstance();

        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        Test.startTest();
            RelationshipLookupSettingsService relationshipLookupSettingsService
                = reciprocalRelHealthCheckVMapper.locateRelationshipLookupSettingsService();
        Test.stopTest();

        System.assertNotEquals(
            null,
            relationshipLookupSettingsService,
            'Instance of service class should not be null.'
        );

        System.assertEquals(
            expectedRelationshipLookupSettingsService,
            relationshipLookupSettingsService,
            'Instance of service class from view model mapper should match the singleton instance.'
        );
    }

    /***************************************************************************
    *********************************STUBS**************************************
    ***************************************************************************/

    /***************************************************************************
    * @description Stub class to simulate the response from
    * ReciprocalRelHealthCheckVMapper to control individual health check methods
    ***************************************************************************/
    private class STUB_ReciprocalRelHealthCheckVMapper extends ReciprocalRelHealthCheckVMapper {
    }
    
    /***************************************************************************
    * @description Stub class to simulate the response from
    * RelationshipLookupSettingsService to return a predetermined set of models.
    ***************************************************************************/
    private class STUB_RelationshipLookupSettingsService extends RelationshipLookupSettingsService {

        public override List<RelationshipLookupModel> getRelationshipLookupModels() {
            List<RelationshipLookupModel> relationshipLookupModelList =
                new List<RelationshipLookupModel>();
            
            RelationshipLookupModel relationshipLookupModel = 
                new RelationshipLookupModel(
                    'testvalue',
                    true,
                    'testfemalevalue',
                    'testmalevalue',
                    'testneutralvalue'
                );

            return relationshipLookupModelList;
        }
    }

    /***************************************************************************
    * @description Stub class to simulate the response from
    * RelationshipLookupSettingsService to return a predetermined set of unfound
    * models.
    ***************************************************************************/
    private class STUB_RelationshipLookupSettingsSvUnfound extends RelationshipLookupSettingsService {

        public override List<RelationshipLookupModel> getRelationshipLookupModels() {
            List<RelationshipLookupModel> relationshipLookupModelList =
                new List<RelationshipLookupModel>();
            
            RelationshipLookupModel relationshipLookupModel = 
                new RelationshipLookupModel(
                    'testvalue',
                    true,
                    'testfemalevalue',
                    'testmalevalue',
                    'testneutralvalue'
                );

            return relationshipLookupModelList;
        }
    }

    /***************************************************************************
    * @description Stub class to simulate the response from
    * PicklistEntryService to return a predetermined set of active models.
    ***************************************************************************/
    private class STUB_PicklistEntryService extends PicklistEntryService {
        public override Map<String,PicklistEntryModel> getModelsByNameForSObjectField(
            SObjectType sObjectTypeName,
            SObjectField SObjectFieldName
        ) {
            Map<String,PicklistEntryModel> picklistEntryModelByName =
                new Map<String,PicklistEntryModel>();
            
            picklistEntryModelByName.put('testvalue',new PicklistEntryModel(
                'testvalue',
                'testlabel',
                true
            ));            
            picklistEntryModelByName.put('testvalue',new PicklistEntryModel(
                'testfemalevalue',
                'testfemalelabel',
                true
            ));            
            picklistEntryModelByName.put('testvalue',new PicklistEntryModel(
                'testmalevalue',
                'testmalelabel',
                true
            ));            
            picklistEntryModelByName.put('testvalue',new PicklistEntryModel(
                'testneutralvalue',
                'testneutrallabel',
                true
            ));

            return picklistEntryModelByName;
        }
    }

    /***************************************************************************
    * @description Stub class to simulate the response from
    * PicklistEntryService to return a predetermined set of inactive models.
    ***************************************************************************/
    private class STUB_PicklistEntryServiceInactive extends PicklistEntryService {
        public override Map<String,PicklistEntryModel> getModelsByNameForSObjectField(
            SObjectType sObjectTypeName,
            SObjectField SObjectFieldName
        ) {
            Map<String,PicklistEntryModel> picklistEntryModelByName =
                new Map<String,PicklistEntryModel>();
            
            picklistEntryModelByName.put('testvalue',new PicklistEntryModel(
                'testvalue',
                'testlabel',
                false
            ));            
            picklistEntryModelByName.put('testvalue',new PicklistEntryModel(
                'testfemalevalue',
                'testfemalelabel',
                false
            ));            
            picklistEntryModelByName.put('testvalue',new PicklistEntryModel(
                'testmalevalue',
                'testmalelabel',
                false
            ));            
            picklistEntryModelByName.put('testvalue',new PicklistEntryModel(
                'testneutralvalue',
                'testneutrallabel',
                false
            ));

            return picklistEntryModelByName;
        }
    }
}