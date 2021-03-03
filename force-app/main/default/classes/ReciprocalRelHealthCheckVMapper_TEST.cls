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
    *******************************INSTANCE*************************************
    ***************************************************************************/

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
    *************************HEALTH CHECK GROUP/ITEM****************************
    ***************************************************************************/

    /***************************************************************************
    * @description Test method to verify that getHealthCheckGroup handles all
    * passed health checks
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

        Integer numberOfHealthChecks = 1;

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapperStub.getHealthCheckGroup();
        Test.stopTest();

        System.assertEquals(
            Label.stgHealthCheckReciprocalRelTitle,
            healthCheckGroupVModel.label,
            'Label of returned health check should match expected custom label.'
        );
        System.assertEquals(
            Label.stgHealthCheckStatusPassed,
            healthCheckGroupVModel.status,
            'Status of returned health check should match expected custom label.'
        );
        System.assertEquals(
            numberOfHealthChecks,
            healthCheckGroupVModel.passedChecks,
            'Number of passed checks of returned health check should match expected custom label.'
        );
        System.assertEquals(
            numberOfHealthChecks,
            healthCheckGroupVModel.totalChecks,
            'Number of total checks of returned health check should match expected custom label.'
        );
        System.assertEquals(
            0,
            healthCheckGroupVModel.expandedRowsList.size(),
            'No health checks should fail, making expanded rows list size 0.'
        );
        System.assertEquals(
            1,
            healthCheckGroupVModel.healthCheckItemList.size(),
            'Number of health check items of returned health check should be 1.'
        );
    }

    /***************************************************************************
    * @description Test method to verify that getHealthCheckGroup handles all
    * passed health checks
    ***************************************************************************/
    @isTest
    private static void getHealthCheckGroupAllFail() {
        RelationshipLookupSettingsService.instance = 
            new STUB_RelationshipLookupSettingsUnfound();
        PicklistEntryService.instance =
            new STUB_PicklistEntryService();

        STUB_ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapperStub =
            new STUB_ReciprocalRelHealthCheckVMapper();
        ReciprocalRelHealthCheckVMapper.instance = reciprocalRelHealthCheckVMapperStub;  

        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        Integer numberOfHealthChecks = 1;

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
            reciprocalRelHealthCheckVMapper.getHealthCheckGroup();
        Test.stopTest();

        System.assertEquals(
            Label.stgHealthCheckReciprocalRelTitle,
            healthCheckGroupVModel.label,
            'Label of returned health check should match expected custom label.'
        );
        System.assertEquals(
            Label.stgHealthCheckStatusFailed,
            healthCheckGroupVModel.status,
            'Status of returned health check should match expected custom label.'
        );
        System.assertEquals(
            0,
            healthCheckGroupVModel.passedChecks,
            'Number of passed checks should be 0.'
        );
        System.assertEquals(
            numberOfHealthChecks,
            healthCheckGroupVModel.totalChecks,
            'Number of total checks of returned health check should match expected custom label.'
        );
        System.assertEquals(
            1,
            healthCheckGroupVModel.expandedRowsList.size(),
            'All health checks should fail, making expanded rows list size 1.'
        );
        System.assertEquals(
            1,
            healthCheckGroupVModel.healthCheckItemList.size(),
            'Number of health check items of returned health check should be 1.'
        );
    }

    /***************************************************************************
    * @description Test method to verify that
    * getRelationshipLookupHealthCheckGroup returns the expected passed health
    * check
    ***************************************************************************/
    @isTest
    private static void getRelationshipLookupHealthCheckGroupPass() {
        STUB_RelationshipLookupSettingsService relationshipLookupSettingsServiceStub =
            new STUB_RelationshipLookupSettingsService();
        STUB_PicklistEntryService picklistEntryServiceStub =
            new STUB_PicklistEntryService();

        ReciprocalRelHealthCheckVMapper.instance =
            new STUB_ReciprocalRelHealthCheckVMapperSub();

        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();
 
        List<RelationshipLookupModel> relationshipLookupModelList =
            relationshipLookupSettingsServiceStub.getRelationshipLookupModels();

        Map<String,PicklistEntryModel> picklistEntryModelByName =
            picklistEntryServiceStub.getModelsByNameForSObjectField(
                Relationship__c.SObjectType,
                Relationship__c.Type__c
            );

        Set<String> duplicateMappingKeys = new Set<String>();

        Integer numberOfHealthChecks = 5;

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapper.getRelationshipLookupHealthCheckGroup(
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
            numberOfHealthChecks,
            healthCheckGroupVModel.passedChecks,
            'Passed checks should equal expected value of ' + numberOfHealthChecks
        );
        System.assertEquals(
            numberOfHealthChecks,
            healthCheckGroupVModel.totalChecks,
            'Total checks should equal expected value of ' + numberOfHealthChecks
        );
        System.assertEquals(
            0,
            healthCheckGroupVModel.expandedRowsList.size(),
            'Expanded rows list should have a size of 0'
        );
        System.assertEquals(
            1,
            healthCheckGroupVModel.healthCheckItemList.size(),
            'Health Check Item list should have a size of 1'
        );
    }

    /***************************************************************************
    * @description Test method to verify that
    * getRelationshipLookupHealthCheckGroup returns the expected failed health
    * check
    ***************************************************************************/
    @isTest
    private static void getRelationshipLookupHealthCheckGroupFail() {
        RelationshipLookupSettingsService.instance = 
            new STUB_RelationshipLookupSettingsService();
        PicklistEntryService.instance =
            new STUB_PicklistEntryService();

        ReciprocalRelHealthCheckVMapper.instance =
            new STUB_ReciprocalRelHealthCheckVMapperSub();  
        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();
 
        List<RelationshipLookupModel> relationshipLookupModelList =
            reciprocalRelHealthCheckVMapper.locateRelationshipLookupSettingsService(
            ).getRelationshipLookupModels();

        Map<String,PicklistEntryModel> picklistEntryModelByName =
            new Map<String,PicklistEntryModel>();

        Set<String> duplicateMappingKeys = new Set<String>();

        Integer numberOfHealthChecks = 5;

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapper.getRelationshipLookupHealthCheckGroup(
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
            numberOfHealthChecks,
            healthCheckGroupVModel.totalChecks,
            'Total checks should equal expected value of ' + numberOfHealthChecks
        );
        System.assertEquals(
            1,
            healthCheckGroupVModel.expandedRowsList.size(),
            'Expanded rows list should have a size of 1'
        );
        System.assertEquals(
            1,
            healthCheckGroupVModel.healthCheckItemList.size(),
            'Health Check Item list should have a size of 1'
        );
    }

    /***************************************************************************
    **********************************NAME**************************************
    ***************************************************************************/

    /***************************************************************************
    * @description Test method to verify that getNameHealthCheckGroup
    * passes with an active picklist entry model for its relationship model's
    * name
    ***************************************************************************/
    @isTest
    private static void getNameHealthCheckGroupPass() {
        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        RelationshipLookupModel relationshipLookupModel = 
            new RelationshipLookupModel(
                'testvalue',
                true,
                'testfemalevalue',
                'testmalevalue',
                'testneutralvalue'
            );

        PicklistEntryModel picklistEntryModel = new PicklistEntryModel(
            'testvalue',
            'testlabel',
            true
        );

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapper.getNameHealthCheckGroup(
                    relationshipLookupModel,
                    picklistEntryModel
                );
        Test.stopTest();

        ReciprocalRelHealthCheckVMapper_TEST.healthCheckAssertionHelper(
            picklistEntryModel,
            healthCheckGroupVModel,
            1,
            relationshipLookupModel.name,
            '01',
            Label.stgHCReciprocalRelNameTitle,
            'Pass',
            Label.stgHealthCheckStatusPassed,
            Label.stgHCPicklistValueValid,
            Label.stgHealthCheckFixNotApplicable
        );
    }

    /***************************************************************************
    * @description Test method to verify that getNameHealthCheckGroupPass fails
    * with an inactive picklist entry model for its relationship model's name
    ***************************************************************************/
    @isTest
    private static void getNameHealthCheckGroupInactive() {
        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        RelationshipLookupModel relationshipLookupModel = 
            new RelationshipLookupModel(
                'testvalue',
                true,
                'testfemalevalue',
                'testmalevalue',
                'testneutralvalue'
            );

        PicklistEntryModel picklistEntryModel = new PicklistEntryModel(
            'testvalue',
            'testlabel',
            false
        );

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapper.getNameHealthCheckGroup(
                    relationshipLookupModel,
                    picklistEntryModel
                );
        Test.stopTest();

        ReciprocalRelHealthCheckVMapper_TEST.healthCheckAssertionHelper(
            picklistEntryModel,
            healthCheckGroupVModel,
            0,
            relationshipLookupModel.name,
            '01',
            Label.stgHCReciprocalRelNameTitle,
            'Fail',
            Label.stgHealthCheckStatusFailed,
            Label.stgHCPicklistValueInactive,
            Label.stgHCReciprocalRelNameInactiveFix
        );               
    }

    /***************************************************************************
    * @description Test method to verify that getNameHealthCheckGroupPass fails
    * with an unfound picklist entry model for its relationship model's name
    ***************************************************************************/
    @isTest
    private static void getNameHealthCheckGroupNotFound() {
        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        RelationshipLookupModel relationshipLookupModel = 
            new RelationshipLookupModel(
                'testvalue',
                true,
                'testfemalevalue',
                'testmalevalue',
                'testneutralvalue'
            );

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapper.getNameHealthCheckGroup(
                    relationshipLookupModel,
                    null
                );
        Test.stopTest();

        ReciprocalRelHealthCheckVMapper_TEST.healthCheckAssertionHelper(
            null,
            healthCheckGroupVModel,
            0,
            relationshipLookupModel.name,
            '01',
            Label.stgHCReciprocalRelNameTitle,
            'Fail',
            Label.stgHealthCheckStatusFailed,
            Label.stgHCPicklistValueNotFound,
            Label.stgHCReciprocalRelNameNotFoundFix
        );
    }

    /***************************************************************************
    *********************************FEMALE*************************************
    ***************************************************************************/

    /***************************************************************************
    * @description Test method to verify that getFemaleHealthCheckGroup
    * passes with an active picklist entry model for its relationship model's
    * female value
    ***************************************************************************/
    @isTest
    private static void getFemaleHealthCheckGroupPass() {
        STUB_PicklistEntryService picklistEntryServiceStub =
            new STUB_PicklistEntryService();

        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        Map<String,PicklistEntryModel> picklistEntryModelByName =
            picklistEntryServiceStub.getModelsByNameForSObjectField(
                Relationship__c.SObjectType,
                Relationship__c.Type__c
            );

        RelationshipLookupModel relationshipLookupModel = 
            new RelationshipLookupModel(
                'testvalue',
                true,
                'testfemalevalue',
                'testmalevalue',
                'testneutralvalue'
            );

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapper.getFemaleHealthCheckGroup(
                    relationshipLookupModel,
                    picklistEntryModelByName
                );
        Test.stopTest();

        ReciprocalRelHealthCheckVMapper_TEST.healthCheckAssertionHelper(
            picklistEntryModelByName.get('testfemalevalue'),
            healthCheckGroupVModel,
            1,
            relationshipLookupModel.femaleValue,
            '02',
            Label.stgHCReciprocalRelFemaleTitle,
            'Pass',
            Label.stgHealthCheckStatusPassed,
            Label.stgHCPicklistValueValid,
            Label.stgHealthCheckFixNotApplicable
        );
    }

    /***************************************************************************
    * @description Test method to verify that getFemaleHealthCheckGroupPass
    * fails with an inactive picklist entry model for its relationship model's
    * female value
    ***************************************************************************/
    @isTest
    private static void getFemaleHealthCheckGroupInactive() {
        STUB_PicklistEntryServiceInactive picklistEntryServiceStub =
            new STUB_PicklistEntryServiceInactive();

        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        Map<String,PicklistEntryModel> picklistEntryModelByName =
            picklistEntryServiceStub.getModelsByNameForSObjectField(
                Relationship__c.SObjectType,
                Relationship__c.Type__c
            );

        RelationshipLookupModel relationshipLookupModel = 
            new RelationshipLookupModel(
                'testvalue',
                true,
                'testfemalevalue',
                'testmalevalue',
                'testneutralvalue'
            );

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapper.getFemaleHealthCheckGroup(
                    relationshipLookupModel,
                    picklistEntryModelByName
                );
        Test.stopTest();

        ReciprocalRelHealthCheckVMapper_TEST.healthCheckAssertionHelper(
            picklistEntryModelByName.get('testfemalevalue'),
            healthCheckGroupVModel,
            0,
            relationshipLookupModel.femaleValue,
            '02',
            Label.stgHCReciprocalRelFemaleTitle,
            'Fail',
            Label.stgHealthCheckStatusFailed,
            Label.stgHCPicklistValueInactive,
            Label.stgHCReciprocalRelFemaleInactiveFix
        );               
    }

    /***************************************************************************
    * @description Test method to verify that getFemaleHealthCheckGroupPass
    * fails with an unfound picklist entry model for its relationship model's
    * female value
    ***************************************************************************/
    @isTest
    private static void getFemaleHealthCheckGroupNotFound() {
        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        RelationshipLookupModel relationshipLookupModel = 
            new RelationshipLookupModel(
                'testvalue',
                true,
                'testfemalevalue',
                'testmalevalue',
                'testneutralvalue'
            );

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapper.getFemaleHealthCheckGroup(
                    relationshipLookupModel,
                    new Map<String,PicklistEntryModel>()
                );
        Test.stopTest();

        ReciprocalRelHealthCheckVMapper_TEST.healthCheckAssertionHelper(
            null,
            healthCheckGroupVModel,
            0,
            relationshipLookupModel.femaleValue,
            '02',
            Label.stgHCReciprocalRelFemaleTitle,
            'Fail',
            Label.stgHealthCheckStatusFailed,
            Label.stgHCPicklistValueNotFound,
            Label.stgHCReciprocalRelFemaleNotFoundFix
        );
    }

    /***************************************************************************
    **********************************MALE**************************************
    ***************************************************************************/

    /***************************************************************************
    * @description Test method to verify that getMaleHealthCheckGroup
    * passes with an active picklist entry model for its relationship model's
    * male value
    ***************************************************************************/
    @isTest
    private static void getMaleHealthCheckGroupPass() {
        STUB_PicklistEntryService picklistEntryServiceStub =
            new STUB_PicklistEntryService();

        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        Map<String,PicklistEntryModel> picklistEntryModelByName =
            picklistEntryServiceStub.getModelsByNameForSObjectField(
                Relationship__c.SObjectType,
                Relationship__c.Type__c
            );

        RelationshipLookupModel relationshipLookupModel = 
            new RelationshipLookupModel(
                'testvalue',
                true,
                'testmalevalue',
                'testmalevalue',
                'testneutralvalue'
            );

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapper.getMaleHealthCheckGroup(
                    relationshipLookupModel,
                    picklistEntryModelByName
                );
        Test.stopTest();

        ReciprocalRelHealthCheckVMapper_TEST.healthCheckAssertionHelper(
            picklistEntryModelByName.get('testmalevalue'),
            healthCheckGroupVModel,
            1,
            relationshipLookupModel.maleValue,
            '03',
            Label.stgHCReciprocalRelMaleTitle,
            'Pass',
            Label.stgHealthCheckStatusPassed,
            Label.stgHCPicklistValueValid,
            Label.stgHealthCheckFixNotApplicable
        );
    }

    /***************************************************************************
    * @description Test method to verify that getMaleHealthCheckGroupPass
    * fails with an inactive picklist entry model for its relationship model's
    * male value
    ***************************************************************************/
    @isTest
    private static void getMaleHealthCheckGroupInactive() {
        STUB_PicklistEntryServiceInactive picklistEntryServiceStub =
            new STUB_PicklistEntryServiceInactive();

        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        Map<String,PicklistEntryModel> picklistEntryModelByName =
            picklistEntryServiceStub.getModelsByNameForSObjectField(
                Relationship__c.SObjectType,
                Relationship__c.Type__c
            );

        RelationshipLookupModel relationshipLookupModel = 
            new RelationshipLookupModel(
                'testvalue',
                true,
                'testmalevalue',
                'testmalevalue',
                'testneutralvalue'
            );

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapper.getMaleHealthCheckGroup(
                    relationshipLookupModel,
                    picklistEntryModelByName
                );
        Test.stopTest();

        ReciprocalRelHealthCheckVMapper_TEST.healthCheckAssertionHelper(
            picklistEntryModelByName.get('testmalevalue'),
            healthCheckGroupVModel,
            0,
            relationshipLookupModel.maleValue,
            '03',
            Label.stgHCReciprocalRelMaleTitle,
            'Fail',
            Label.stgHealthCheckStatusFailed,
            Label.stgHCPicklistValueInactive,
            Label.stgHCReciprocalRelMaleInactiveFix
        );               
    }

    /***************************************************************************
    * @description Test method to verify that getMaleHealthCheckGroupPass
    * fails with an unfound picklist entry model for its relationship model's
    * male value
    ***************************************************************************/
    @isTest
    private static void getMaleHealthCheckGroupNotFound() {
        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        RelationshipLookupModel relationshipLookupModel = 
            new RelationshipLookupModel(
                'testvalue',
                true,
                'testmalevalue',
                'testmalevalue',
                'testneutralvalue'
            );

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapper.getMaleHealthCheckGroup(
                    relationshipLookupModel,
                    new Map<String,PicklistEntryModel>()
                );
        Test.stopTest();

        ReciprocalRelHealthCheckVMapper_TEST.healthCheckAssertionHelper(
            null,
            healthCheckGroupVModel,
            0,
            relationshipLookupModel.maleValue,
            '03',
            Label.stgHCReciprocalRelMaleTitle,
            'Fail',
            Label.stgHealthCheckStatusFailed,
            Label.stgHCPicklistValueNotFound,
            Label.stgHCReciprocalRelMaleNotFoundFix
        );
    }

    /***************************************************************************
    ********************************NEUTRAL*************************************
    ***************************************************************************/

    /***************************************************************************
    * @description Test method to verify that getNeutralHealthCheckGroup
    * passes with an active picklist entry model for its relationship model's
    * neutral value
    ***************************************************************************/
    @isTest
    private static void getNeutralHealthCheckGroupPass() {
        STUB_PicklistEntryService picklistEntryServiceStub =
            new STUB_PicklistEntryService();

        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        Map<String,PicklistEntryModel> picklistEntryModelByName =
            picklistEntryServiceStub.getModelsByNameForSObjectField(
                Relationship__c.SObjectType,
                Relationship__c.Type__c
            );

        RelationshipLookupModel relationshipLookupModel = 
            new RelationshipLookupModel(
                'testvalue',
                true,
                'testneutralvalue',
                'testmalevalue',
                'testneutralvalue'
            );

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapper.getNeutralHealthCheckGroup(
                    relationshipLookupModel,
                    picklistEntryModelByName
                );
        Test.stopTest();

        ReciprocalRelHealthCheckVMapper_TEST.healthCheckAssertionHelper(
            picklistEntryModelByName.get('testneutralvalue'),
            healthCheckGroupVModel,
            1,
            relationshipLookupModel.neutralValue,
            '04',
            Label.stgHCReciprocalRelNeutralTitle,
            'Pass',
            Label.stgHealthCheckStatusPassed,
            Label.stgHCPicklistValueValid,
            Label.stgHealthCheckFixNotApplicable
        );
    }

    /***************************************************************************
    * @description Test method to verify that getNeutralHealthCheckGroupPass
    * fails with an inactive picklist entry model for its relationship model's
    * neutral value
    ***************************************************************************/
    @isTest
    private static void getNeutralHealthCheckGroupInactive() {
        STUB_PicklistEntryServiceInactive picklistEntryServiceStub =
            new STUB_PicklistEntryServiceInactive();

        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        Map<String,PicklistEntryModel> picklistEntryModelByName =
            picklistEntryServiceStub.getModelsByNameForSObjectField(
                Relationship__c.SObjectType,
                Relationship__c.Type__c
            );

        RelationshipLookupModel relationshipLookupModel = 
            new RelationshipLookupModel(
                'testvalue',
                true,
                'testneutralvalue',
                'testmalevalue',
                'testneutralvalue'
            );

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapper.getNeutralHealthCheckGroup(
                    relationshipLookupModel,
                    picklistEntryModelByName
                );
        Test.stopTest();

        ReciprocalRelHealthCheckVMapper_TEST.healthCheckAssertionHelper(
            picklistEntryModelByName.get('testneutralvalue'),
            healthCheckGroupVModel,
            0,
            relationshipLookupModel.neutralValue,
            '04',
            Label.stgHCReciprocalRelNeutralTitle,
            'Fail',
            Label.stgHealthCheckStatusFailed,
            Label.stgHCPicklistValueInactive,
            Label.stgHCReciprocalRelNeutralInactiveFix
        );               
    }

    /***************************************************************************
    * @description Test method to verify that getNeutralHealthCheckGroupPass
    * fails with an unfound picklist entry model for its relationship model's
    * neutral value
    ***************************************************************************/
    @isTest
    private static void getNeutralHealthCheckGroupNotFound() {
        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        RelationshipLookupModel relationshipLookupModel = 
            new RelationshipLookupModel(
                'testvalue',
                true,
                'testneutralvalue',
                'testmalevalue',
                'testneutralvalue'
            );

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapper.getNeutralHealthCheckGroup(
                    relationshipLookupModel,
                    new Map<String,PicklistEntryModel>()
                );
        Test.stopTest();

        ReciprocalRelHealthCheckVMapper_TEST.healthCheckAssertionHelper(
            null,
            healthCheckGroupVModel,
            0,
            relationshipLookupModel.neutralValue,
            '04',
            Label.stgHCReciprocalRelNeutralTitle,
            'Fail',
            Label.stgHealthCheckStatusFailed,
            Label.stgHCPicklistValueNotFound,
            Label.stgHCReciprocalRelNeutralNotFoundFix
        );
    }

    /***************************************************************************
    ******************************PICKLIST HELPER*******************************
    ***************************************************************************/

    /***************************************************************************
    * @description Test method to verify that
    * getHealthCheckGroupForPicklistSetting passes with an active picklist entry
    * model
    ***************************************************************************/
    @isTest
    private static void getHealthCheckGroupForPicklistSettingPass() {
        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        PicklistEntryModel picklistEntryModel = new PicklistEntryModel(
            'testvalue',
            'testlabel',
            true
        );

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapper.getHealthCheckGroupForPicklistSetting(
                    picklistEntryModel,
                    'value',
                    '01',
                    'settingsLabel',
                    'notFoundFix {0}',
                    'inactiveFix {0} {1}'
                );
        Test.stopTest();

        ReciprocalRelHealthCheckVMapper_TEST.healthCheckAssertionHelper(
            picklistEntryModel,
            healthCheckGroupVModel,
            1,
            'value',
            '01',
            'settingsLabel',
            'Pass',
            Label.stgHealthCheckStatusPassed,
            Label.stgHCPicklistValueValid,
            Label.stgHealthCheckFixNotApplicable
        );
    }

    /***************************************************************************
    * @description Test method to verify that
    * getHealthCheckGroupForPicklistSetting fails with an inactive picklist
    * entry model
    ***************************************************************************/
    @isTest
    private static void getHealthCheckGroupForPicklistSettingInactive() {
        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        PicklistEntryModel picklistEntryModel = new PicklistEntryModel(
            'testvalue',
            'testlabel',
            false
        );

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapper.getHealthCheckGroupForPicklistSetting(
                    picklistEntryModel,
                    'value',
                    '01',
                    'settingsLabel',
                    'notFoundFix {0}',
                    'inactiveFix {0} {1}'
                );
        Test.stopTest();

        ReciprocalRelHealthCheckVMapper_TEST.healthCheckAssertionHelper(
            picklistEntryModel,
            healthCheckGroupVModel,
            0,
            'value',
            '01',
            'settingsLabel',
            'Fail',
            Label.stgHealthCheckStatusFailed,
            Label.stgHCPicklistValueInactive,
            'inactiveFix {0} {1}'
        );               
    }

    /***************************************************************************
    * @description Test method to verify that
    * getHealthCheckGroupForPicklistSetting fails with an unfound picklist
    * entry model
    ***************************************************************************/
    @isTest
    private static void getHealthCheckGroupForPicklistSettingNotFound() {
        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapper.getHealthCheckGroupForPicklistSetting(
                    null,
                    'value',
                    '01',
                    'settingsLabel',
                    'notFoundFix {0}',
                    'inactiveFix {0} {1}'
                );
        Test.stopTest();

        ReciprocalRelHealthCheckVMapper_TEST.healthCheckAssertionHelper(
            null,
            healthCheckGroupVModel,
            0,
            'value',
            '01',
            'settingsLabel',
            'Fail',
            Label.stgHealthCheckStatusFailed,
            Label.stgHCPicklistValueNotFound,
            'notFoundFix {0}'
        );
    }

    /***************************************************************************
    ********************************UNIQUENESS**********************************
    ***************************************************************************/

    /***************************************************************************
    * @description Test method to verify that getUniquenessHealthCheckGroup
    * passes with a unique name
    ***************************************************************************/
    @isTest
    private static void getUniquenessHealthCheckGroupUnique() {
        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        RelationshipLookupModel relationshipLookupModel = 
            new RelationshipLookupModel(
                'testvalue',
                true,
                'testfemalevalue',
                'testmalevalue',
                'testneutralvalue'
            );

        PicklistEntryModel picklistEntryModel = new PicklistEntryModel(
            'testvalue',
            'testlabel',
            true
        );

        Set<String> duplicateNameSet = new Set<String>();

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapper.getUniquenessHealthCheckGroup(
                    relationshipLookupModel,
                    picklistEntryModel,
                    duplicateNameSet
                );
        Test.stopTest();

        ReciprocalRelHealthCheckVMapper_TEST.healthCheckAssertionHelper(
            picklistEntryModel,
            healthCheckGroupVModel,
            1,
            relationshipLookupModel.name,
            '05',
            Label.stgHCReciprocalRelNameUniqueTitle,
            'Pass',
            Label.stgHealthCheckStatusPassed,
            Label.stgHCReciprocalRelNameUniqueDesc,
            Label.stgHealthCheckFixNotApplicable
        );
    }

    /***************************************************************************
    * @description Test method to verify that getUniquenessHealthCheckGroup
    * passes with a unique name and unfound picklist entry model
    ***************************************************************************/
    @isTest
    private static void getUniquenessHealthCheckGroupUniqueUnfoundPicklist() {
        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        RelationshipLookupModel relationshipLookupModel = 
            new RelationshipLookupModel(
                'testvalue',
                true,
                'testfemalevalue',
                'testmalevalue',
                'testneutralvalue'
            );

        Set<String> duplicateNameSet = new Set<String>();

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapper.getUniquenessHealthCheckGroup(
                    relationshipLookupModel,
                    null,
                    duplicateNameSet
                );
        Test.stopTest();

        ReciprocalRelHealthCheckVMapper_TEST.healthCheckAssertionHelper(
            null,
            healthCheckGroupVModel,
            1,
            relationshipLookupModel.name,
            '05',
            Label.stgHCReciprocalRelNameUniqueTitle,
            'Pass',
            Label.stgHealthCheckStatusPassed,
            Label.stgHCReciprocalRelNameUniqueDesc,
            Label.stgHealthCheckFixNotApplicable
        );
    }

    /***************************************************************************
    * @description Test method to verify that getUniquenessHealthCheckGroup
    * fails with a duplicate name
    ***************************************************************************/
    @isTest
    private static void getUniquenessHealthCheckGroupDuplicate() {
        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        RelationshipLookupModel relationshipLookupModel = 
            new RelationshipLookupModel(
                'testvalue',
                true,
                'testfemalevalue',
                'testmalevalue',
                'testneutralvalue'
            );

        PicklistEntryModel picklistEntryModel = new PicklistEntryModel(
            'testvalue',
            'testlabel',
            true
        );

        Set<String> duplicateNameSet = new Set<String>{'testvalue'};

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapper.getUniquenessHealthCheckGroup(
                    relationshipLookupModel,
                    picklistEntryModel,
                    duplicateNameSet
                );
        Test.stopTest();

        ReciprocalRelHealthCheckVMapper_TEST.healthCheckAssertionHelper(
            picklistEntryModel,
            healthCheckGroupVModel,
            0,
            relationshipLookupModel.name,
            '05',
            Label.stgHCReciprocalRelNameUniqueTitle,
            'Fail',
            Label.stgHealthCheckStatusFailed,
            Label.stgHCReciprocalRelNameNotUniqueDesc,
            Label.stgHCReciprocalRelNameNotUniqueFix
        );
    }

    /***************************************************************************
    * @description Test method to verify that getUniquenessHealthCheckGroup
    * fails with a duplicate name and unfound picklist entry model
    ***************************************************************************/
    @isTest
    private static void getUniquenessHealthCheckGroupDuplicateUnfoundPicklist() {
        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        RelationshipLookupModel relationshipLookupModel = 
            new RelationshipLookupModel(
                'testvalue',
                true,
                'testfemalevalue',
                'testmalevalue',
                'testneutralvalue'
            );

        Set<String> duplicateNameSet = new Set<String>{'testvalue'};

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                reciprocalRelHealthCheckVMapper.getUniquenessHealthCheckGroup(
                    relationshipLookupModel,
                    null,
                    duplicateNameSet
                );
        Test.stopTest();

        ReciprocalRelHealthCheckVMapper_TEST.healthCheckAssertionHelper(
            null,
            healthCheckGroupVModel,
            0,
            relationshipLookupModel.name,
            '05',
            Label.stgHCReciprocalRelNameUniqueTitle,
            'Fail',
            Label.stgHealthCheckStatusFailed,
            Label.stgHCReciprocalRelNameNotUniqueDesc,
            Label.stgHCReciprocalRelNameNotUniqueFix
        );
    }

    /***************************************************************************
    ****************************LOCATORS AND HELPERS***************************
    ***************************************************************************/

    /***************************************************************************
    * @description Test method to verify that a formatted HealthCheckItemVModel
    * is returned
    ***************************************************************************/
    @isTest 
    private static void getHealthCheckItemVModelForRelationshipLookupModel(){
        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        RelationshipLookupModel relationshipLookupModel = 
            new RelationshipLookupModel(
                'testvalue',
                true,
                'testfemalevalue',
                'testmalevalue',
                'testneutralvalue'
            );

        PicklistEntryModel picklistEntryModel = new PicklistEntryModel(
            'testvalue',
            'testlabel',
            false
        );

        Test.startTest();
            HealthCheckItemVModel healthCheckItemVModel =
                reciprocalRelHealthCheckVMapper.getHealthCheckItemVModelForRelationshipLookupModel(
                    relationshipLookupModel,
                    picklistEntryModel
                );
        Test.stopTest();

        List<String> listForSettingsLabel =
            new List<String>{relationshipLookupModel.name,relationshipLookupModel.name};
        List<String> listForDescriptionLabel =
            new List<String>{relationshipLookupModel.name,picklistEntryModel.name};

        System.assertEquals(
            relationshipLookupModel.name,
            healthCheckItemVModel.key,
            'Health Check Item View Model key should equal the relationship lookup model name.'
        );
        System.assertEquals(
            String.format(Label.stgHCReciprocalRelSetting,listForSettingsLabel),
            healthCheckItemVModel.setting,
            'Health Check Item View Model setting should equal the formatted expected label.'
            );
        System.assertEquals(
            'Pass',
            healthCheckItemVModel.status,
            'The Health Check Item\'s status should status should be Pass.'
        );
        System.assertEquals(
            Label.stgHealthCheckStatusPassed,
            healthCheckItemVModel.statusLabel,
            'Health Check Item View Model status should equal the expected label.'
        );
        System.assertEquals(
            '',
            healthCheckItemVModel.description,
            'Health Check Item View Model description should equal the expected formatted label.'
        );
        System.assertEquals(
            '',
            healthCheckItemVModel.recommendedFix,
            'Health Check Item View Model recommended fix should be blank.'
        );
        System.assertEquals(
            true,
            healthCheckItemVModel.healthCheckItemList.isEmpty(),
            'Health Check Item View Model health check item list should be empty.'
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
    * @description Test method to verify that a
    * StringHandlingService is retrieved by the locator method.
    ***************************************************************************/
    @isTest 
    private static void locateStringHandlingService(){
        StringHandlingService expectedStringHandlingService
            = StringHandlingService.getInstance();

        ReciprocalRelHealthCheckVMapper reciprocalRelHealthCheckVMapper =
            ReciprocalRelHealthCheckVMapper.getInstance();

        Test.startTest();
            StringHandlingService StringHandlingService
                = reciprocalRelHealthCheckVMapper.locateStringHandlingService();
        Test.stopTest();

        System.assertNotEquals(
            null,
            StringHandlingService,
            'Instance of service class should not be null.'
        );

        System.assertEquals(
            expectedStringHandlingService,
            StringHandlingService,
            'Instance of service class from view model mapper should match the singleton instance.'
        );
    }

    /***************************************************************************
    *******************************TEST HELPERS*********************************
    ***************************************************************************/

    /***************************************************************************
    * @description A helper method to steamline standardized picklist value
    * assertions and reduce eye strain.
    ***************************************************************************/
    private static void healthCheckAssertionHelper(
        PicklistEntryModel picklistEntryModel,
        HealthCheckGroupVModel healthCheckGroupVModel,
        Integer passedChecks,
        String picklistName,
        String picklistIndex,
        String setting,
        String status,
        String statusLabel,
        String description,
        String recommendedFix
    ) {
        System.assertEquals(
            passedChecks,
            healthCheckGroupVModel.passedChecks,
            'The Health Check Group View Model should have ' + passedChecks + ' passed check(s).'
        );
        System.assertEquals(
            1,
            healthCheckGroupVModel.totalChecks,
            'The Health Check Group View Model should have 1 total check.'
        );
        System.assertEquals(
            0,
            healthCheckGroupVModel.expandedRowsList.size(),
            'The Health Check Group View Model should have 0 expanded rows.'
        );
        System.assertEquals(
            1,
            healthCheckGroupVModel.healthCheckItemList.size(),
            'The Health Check Group View Model should have 1 health check item.'
        );

        HealthCheckItemVModel healthCheckItemVModel =
            healthCheckGroupVModel.healthCheckItemList[0];
        List<String> labelAndNameForFormat = new List<String>{picklistName,picklistName};

        if(picklistEntryModel != null) {
            labelAndNameForFormat = new List<String>{picklistEntryModel.label,picklistEntryModel.name};
        }

        System.assertEquals(
            picklistName + picklistIndex,
            healthCheckItemVModel.key,
            'The Health Check Item\'s key should match the relationship lookup model\'s name.'
        );
        System.assertEquals(
            setting,
            healthCheckItemVModel.setting,
            'The Health Check Item\'s setting should match the specified label.'
            );
        System.assertEquals(
            status,
            healthCheckItemVModel.status,
            'The Health Check Item\'s status should status should be ' + status + '.'
        );
        System.assertEquals(
            statusLabel,
            healthCheckItemVModel.statusLabel,
            'The Health Check Item\'s status label should match the specified label.'
        );
        System.assertEquals(
            StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
                description,
                labelAndNameForFormat
            ),
            healthCheckItemVModel.description,
            'The Health Check Item\'s description should match the specified label.'
        );
        System.assertEquals(
            StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
                recommendedFix,
                labelAndNameForFormat
            ),
            healthCheckItemVModel.recommendedFix,
            'The Health Check Item\'s recommended fix should match the specified label.'
        );
    }

    /***************************************************************************
    *********************************STUBS**************************************
    ***************************************************************************/

    /***************************************************************************
    * @description Stub class to simulate the response from
    * ReciprocalRelHealthCheckVMapper to control
    * getRelationshipLookupHealthCheckGroup
    ***************************************************************************/
    private class STUB_ReciprocalRelHealthCheckVMapper extends ReciprocalRelHealthCheckVMapper {
        protected override HealthCheckGroupVModel getRelationshipLookupHealthCheckGroup(
            RelationshipLookupModel relationshipLookupModel,
            Map<String,PicklistEntryModel> picklistEntryModelByName,
            Set<String> duplicateMappingKeys
        ) {
            HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel(
                '',
                '',
                0,
                0,
                new List<String>(),
                new List<HealthCheckItemVModel>()
            );

            PicklistEntryModel picklistEntryModel =
                picklistEntryModelByName.get(relationshipLookupModel.name);
    
            HealthCheckItemVModel healthCheckItemVModel = 
                this.getHealthCheckItemVModelForRelationshipLookupModel(
                    relationshipLookupModel,
                    picklistEntryModel
                );

            healthCheckGroupVModel.totalChecks += 1;

            if(picklistEntryModel != null) {
                healthCheckGroupVModel.passedChecks += 1;
            }

            if(healthCheckGroupVModel.passedChecks < healthCheckGroupVModel.totalChecks) {
                healthCheckItemVModel.status = 'Fail';
                healthCheckItemVModel.statusLabel = Label.stgHealthCheckStatusFailed;
                healthCheckGroupVModel.expandedRowsList.add(relationshipLookupModel.name);
            }
    
            healthCheckItemVModel.healthCheckItemList.sort();
    
            healthCheckGroupVModel.healthCheckItemList.add(healthCheckItemVModel);

            return healthCheckGroupVModel;
        }
    }

    /***************************************************************************
    * @description Stub class to simulate the response from
    * ReciprocalRelHealthCheckVMapper to control individual health check methods
    * for success or failure
    ***************************************************************************/
    private class STUB_ReciprocalRelHealthCheckVMapperSub extends ReciprocalRelHealthCheckVMapper {
        protected override HealthCheckGroupVModel getHealthCheckGroupForPicklistSetting(
            PicklistEntryModel picklistEntryModel,
            String relationshipLookupModelFieldValue,
            String indexString,
            String settingsLabel,
            String notFoundFix,
            String inactiveFix
        ) {
            return this.mockCheck(picklistEntryModel);
        }

        protected override HealthCheckGroupVModel getUniquenessHealthCheckGroup(
            RelationshipLookupModel relationshipLookupModel,
            PicklistEntryModel picklistEntryModel,
            Set<String> duplicateNameSet
        ) {
            return this.mockCheck(picklistEntryModel);
        }

        private HealthCheckGroupVModel mockCheck(PicklistEntryModel picklistEntryModel) {
            HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel(
                '',
                '',
                0,
                0,
                new List<String>(),
                new List<HealthCheckItemVModel>()
            );
    
            HealthCheckItemVModel healthCheckItemVModel =
                new healthCheckItemVModel(
                    'Mock',
                    'MockSetting',
                    'Pass',
                    'MockStatusLabel',
                    'MockDescription',
                    'MockRecommendedFix',
                    new List<HealthCheckItemVModel>()
                );

            healthCheckGroupVModel.totalChecks += 1;

            if(picklistEntryModel != null) {
                healthCheckGroupVModel.passedChecks += 1;
            }

            if(healthCheckGroupVModel.passedChecks < healthCheckGroupVModel.totalChecks) {
                healthCheckItemVModel.status = 'Fail';
                healthCheckItemVModel.statusLabel = Label.stgHealthCheckStatusFailed;
            }
    
            healthCheckGroupVModel.healthCheckItemList.add(healthCheckItemVModel);
            return healthCheckGroupVModel;
        }
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

            relationshipLookupModelList.add(relationshipLookupModel);

            return relationshipLookupModelList;
        }
    }

    /***************************************************************************
    * @description Stub class to simulate the response from
    * RelationshipLookupSettingsService to return a predetermined set of unfound
    * models.
    ***************************************************************************/
    private class STUB_RelationshipLookupSettingsUnfound extends RelationshipLookupSettingsService {

        public override List<RelationshipLookupModel> getRelationshipLookupModels() {
            List<RelationshipLookupModel> relationshipLookupModelList =
                new List<RelationshipLookupModel>();
            
            RelationshipLookupModel relationshipLookupModel = 
                new RelationshipLookupModel(
                    'unfoundvalue',
                    true,
                    'unfoundfemalevalue',
                    'unfoundmalevalue',
                    'unfoundneutralvalue'
                );

            relationshipLookupModelList.add(relationshipLookupModel);

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
            picklistEntryModelByName.put('testfemalevalue',new PicklistEntryModel(
                'testfemalevalue',
                'testfemalelabel',
                true
            ));            
            picklistEntryModelByName.put('testmalevalue',new PicklistEntryModel(
                'testmalevalue',
                'testmalelabel',
                true
            ));            
            picklistEntryModelByName.put('testneutralvalue',new PicklistEntryModel(
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
            picklistEntryModelByName.put('testfemalevalue',new PicklistEntryModel(
                'testfemalevalue',
                'testfemalelabel',
                false
            ));            
            picklistEntryModelByName.put('testmalevalue',new PicklistEntryModel(
                'testmalevalue',
                'testmalelabel',
                false
            ));            
            picklistEntryModelByName.put('testneutralvalue',new PicklistEntryModel(
                'testneutralvalue',
                'testneutrallabel',
                false
            ));

            return picklistEntryModelByName;
        }
    }
}