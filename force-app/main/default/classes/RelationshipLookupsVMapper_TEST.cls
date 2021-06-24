/*
    Copyright (c) 2021, Salesforce.org
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
 * @date 2021
 * @group
 * @group-content ../../ApexDocContent/Tests.htm
 * @description Test class for RelationshipLookupsVMapper class
 */
@isTest
private with sharing class RelationshipLookupsVMapper_TEST {
    /**************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * RelationshipLookupsVMapper class when one does not already exist.
     **************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        RelationshipLookupsVMapper relationshipLookupsVMapperInstance = RelationshipLookupsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            RelationshipLookupsVMapper.instance,
            relationshipLookupsVMapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            relationshipLookupsVMapperInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * RelationshipLookupsVMapper class when one already exists.
     **************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        RelationshipLookupsVMapper relationshipLookupsVMapperInstance1 = RelationshipLookupsVMapper.getInstance();
        RelationshipLookupsVMapper relationshipLookupsVMapperInstance2 = RelationshipLookupsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            RelationshipLookupsVMapper.instance,
            relationshipLookupsVMapperInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            relationshipLookupsVMapperInstance1,
            relationshipLookupsVMapperInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            relationshipLookupsVMapperInstance1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify locateRelationshipLookupSettingsService() returns an instance of
     * the RelationshipLookupSettingsService class.
     ****************************************************************************************/
    @isTest
    private static void locatePicklistEntryServiceValid() {
        RelationshipLookupsVMapper relationshipLookupsVMapperInstance = RelationshipLookupsVMapper.getInstance();

        Test.startTest();
        PicklistEntryService picklistEntryServiceInstance = relationshipLookupsVMapperInstance.locatePicklistEntryService();
        Test.stopTest();

        System.assertEquals(
            PicklistEntryService.getInstance(),
            picklistEntryServiceInstance,
            'Should return instance of PicklistEntryService class.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify locateRelationshipLookupSettingsService() returns an instance of
     * the RelationshipLookupSettingsService class.
     ****************************************************************************************/
    @isTest
    private static void locateRelationshipLookupSettingsServiceValid() {
        RelationshipLookupsVMapper relationshipLookupsVMapperInstance = RelationshipLookupsVMapper.getInstance();

        Test.startTest();
        RelationshipLookupSettingsService relationshipLookupSettingsServiceInstance = relationshipLookupsVMapperInstance.locateRelationshipLookupSettingsService();
        Test.stopTest();

        System.assertEquals(
            RelationshipLookupSettingsService.getInstance(),
            relationshipLookupSettingsServiceInstance,
            'Should return instance of RelationshipLookupSettingsService class.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getComboboxValueVModelListFromPicklist()
     * returns a list of ComboboxValueVModels representing the relationship lookup picklist values
     ****************************************************************************************/
    @isTest
    private static void getComboboxValueVModelListFromPicklistValid() {
        STUB_PicklistEntryService picklistEntryServiceStub = new STUB_PicklistEntryService();

        RelationshipLookupsVMapper relationshipLookupsVMapperInstance = RelationshipLookupsVMapper.getInstance();

        Test.startTest();
        List<ComboboxValueVModel> lookupComboboxValueVModelsList = relationshipLookupsVMapperInstance.getComboboxValueVModelListFromPicklist(
            picklistEntryServiceStub.getModelsByNameForSObjectField(null, null)
        );
        Test.stopTest();

        System.assertEquals(7, lookupComboboxValueVModelsList.size(), 'Should return 7 ComboboxValueVModels.');

        for (Integer i = 0; i < lookupComboboxValueVModelsList.size(); i++) {
            System.assertEquals(
                'TestRelationshipName' + String.valueOf(i + 1),
                lookupComboboxValueVModelsList[i].value,
                'ComoboboxValueVModel value should match lookup field model name.'
            );

            System.assertEquals(
                'TestRelationshipLabel' + String.valueOf(i + 1),
                lookupComboboxValueVModelsList[i].label,
                'ComoboboxValueVModel label should match lookup field model label.'
            );
        }
    }

    /****************************************************************************************
     * @description Test method to verify getRelationshipLookupsVModel()
     * returns a RelationshipLookupsVModel representing existing relationship lookups
     ****************************************************************************************/
    @isTest
    private static void getRelationshipLookupsVModelValid() {
        PicklistEntryService.instance = new STUB_PicklistEntryService();
        RelationshipLookupSettingsService.instance = new STUB_RelationshipLookupSettingsService();

        RelationshipLookupsVMapper relationshipLookupsVMapperInstance = RelationshipLookupsVMapper.getInstance();

        Test.startTest();
        RelationshipLookupsVModel relLookupVModel = relationshipLookupsVMapperInstance.getRelationshipLookupsVModel();
        Test.stopTest();

        System.assertEquals(
            5,
            relLookupVModel.relationshipLookups.size(),
            'Should return 5 RelationshipLookupVModel items'
        );

        System.assertEquals(
            'TestRelationshipName1',
            relLookupVModel.relationshipLookups[0].name,
            'Relationship lookup name should be \'TestRelationshipName1\''
        );
        System.assertEquals(
            'TestFemaleValue1',
            relLookupVModel.relationshipLookups[0].femaleValue,
            'Female value should be \'TestFemaleValue1\''
        );
        System.assertEquals(
            'TestMaleValue1',
            relLookupVModel.relationshipLookups[0].maleValue,
            'Male value should be \'TestMaleValue1\''
        );
        System.assertEquals(
            'TestNeutralValue1',
            relLookupVModel.relationshipLookups[0].neutralValue,
            'Neutral value should be \'TestNeutralValue1\''
        );
        System.assertEquals(true, relLookupVModel.relationshipLookups[0].isActive, 'isActive should be \'true\'');
    }

    /****************************************************************************************
     * @description Test method to verify getRelationshipLookupComboboxVModel()
     * returns a ComboboxVModel representing active picklist items
     ****************************************************************************************/
    @isTest
    private static void getRelationshipLookupComboboxVModelValid() {
        PicklistEntryService.instance = new STUB_PicklistEntryService();
        RelationshipLookupSettingsService.instance = new STUB_RelationshipLookupSettingsService();

        RelationshipLookupsVMapper relationshipLookupsVMapperInstance = RelationshipLookupsVMapper.getInstance();

        Test.startTest();
        ComboBoxVModel relationshipLookupComboBoxVModel = relationshipLookupsVMapperInstance.getRelationshipLookupComboboxVModel(
            ''
        );
        ComboBoxVModel missingRelationshipLookupComboBoxVModel = relationshipLookupsVMapperInstance.getRelationshipLookupComboboxVModel(
            'MissingValue'
        );
        Test.stopTest();

        System.assertEquals(
            5,
            relationshipLookupComboBoxVModel.options.size(),
            'Should return 5 active relationship types'
        );

        System.assertEquals(
            'TestRelationshipName1',
            relationshipLookupComboBoxVModel.options[0].value,
            'Relationship type value should be \'TestRelationshipName1\''
        );
        System.assertEquals(
            'TestRelationshipLabel1',
            relationshipLookupComboBoxVModel.options[0].label,
            'Relationship type label should be \'TestRelationshipLabel1\''
        );
        System.assertEquals(
            'TestRelationshipName7',
            relationshipLookupComboBoxVModel.options[4].value,
            'Relationship type value should be \'TestRelationshipName7\''
        );
        System.assertEquals(
            'TestRelationshipLabel7',
            relationshipLookupComboBoxVModel.options[4].label,
            'Relationship type label should be \'TestRelationshipLabel7\''
        );

        System.assertEquals(
            6,
            missingRelationshipLookupComboBoxVModel.options.size(),
            'Should return 6 relationship types (5 active, 1 missing)'
        );
        System.assertEquals(
            'MissingValue',
            missingRelationshipLookupComboBoxVModel.options[0].value,
            'Relationship type value should be \'TestRelationshipName1\''
        );
        System.assertEquals(
            'MissingValue',
            missingRelationshipLookupComboBoxVModel.options[0].label,
            'Relationship type label should be \'TestRelationshipLabel1\''
        );
    }

    /****************************************************************************************
     * @description Test method to verify getRelationshipLookupsVModel()
     * returns a ComboboxVModel representing active unmapped picklist items
     ****************************************************************************************/
    @isTest
    private static void getActiveUnmappedRelationshipTypesComboboxVModelValid() {
        PicklistEntryService.instance = new STUB_PicklistEntryService();
        RelationshipLookupSettingsService.instance = new STUB_RelationshipLookupSettingsService();

        RelationshipLookupsVMapper relationshipLookupsVMapperInstance = RelationshipLookupsVMapper.getInstance();

        Test.startTest();
        ComboBoxVModel activeUnmappedRelTypesComboBoxVModel = relationshipLookupsVMapperInstance.getActiveUnmappedRelationshipTypesComboboxVModel(
            ''
        );
        Test.stopTest();

        System.assertEquals(
            2,
            activeUnmappedRelTypesComboBoxVModel.options.size(),
            'Should return 2 active unmapped relationship types'
        );

        System.assertEquals(
            'TestRelationshipName6',
            activeUnmappedRelTypesComboBoxVModel.options[0].value,
            'Relationship type value should be \'TestRelationshipName6\''
        );
        System.assertEquals(
            'TestRelationshipLabel6',
            activeUnmappedRelTypesComboBoxVModel.options[0].label,
            'Relationship type label should be \'TestRelationshipLabel6\''
        );

        System.assertEquals(
            'TestRelationshipName7',
            activeUnmappedRelTypesComboBoxVModel.options[1].value,
            'Relationship type value should be \'TestRelationshipName7\''
        );
        System.assertEquals(
            'TestRelationshipLabel7',
            activeUnmappedRelTypesComboBoxVModel.options[1].label,
            'Relationship type label should be \'TestRelationshipLabel7\''
        );
    }

    /****************************************************************************************
     * @description Test method to verify getRelationshipLookupNameComboboxVModel()
     * returns a ComboboxVModel representing active unmapped picklist items for a new record
     ****************************************************************************************/
    @isTest
    private static void getRelationshipLookupNameComboboxVModelValidNew() {
        PicklistEntryService.instance = new STUB_PicklistEntryService();
        RelationshipLookupSettingsService.instance = new STUB_RelationshipLookupSettingsService();

        RelationshipLookupsVMapper relationshipLookupsVMapperInstance = RelationshipLookupsVMapper.getInstance();

        Test.startTest();
        ComboBoxVModel activeUnmappedRelTypesComboBoxVModel = relationshipLookupsVMapperInstance.getRelationshipLookupNameComboboxVModel(
            ''
        );
        Test.stopTest();

        System.assertEquals(
            2,
            activeUnmappedRelTypesComboBoxVModel.options.size(),
            'Should return 2 active unmapped relationship types'
        );

        System.assertEquals(
            'TestRelationshipName6',
            activeUnmappedRelTypesComboBoxVModel.options[0].value,
            'Relationship type value should be \'TestRelationshipName6\''
        );
        System.assertEquals(
            'TestRelationshipLabel6',
            activeUnmappedRelTypesComboBoxVModel.options[0].label,
            'Relationship type label should be \'TestRelationshipLabel6\''
        );

        System.assertEquals(
            'TestRelationshipName7',
            activeUnmappedRelTypesComboBoxVModel.options[1].value,
            'Relationship type value should be \'TestRelationshipName7\''
        );
        System.assertEquals(
            'TestRelationshipLabel7',
            activeUnmappedRelTypesComboBoxVModel.options[1].label,
            'Relationship type label should be \'TestRelationshipLabel7\''
        );
    }

    /****************************************************************************************
     * @description Test method to verify getRelationshipLookupNameComboboxVModel()
     * returns a ComboboxVModel representing active picklist items
     * for an existing record (edit mode)
     ****************************************************************************************/
    @isTest
    private static void getRelationshipLookupNameComboboxVModelValidEdit() {
        PicklistEntryService.instance = new STUB_PicklistEntryService();
        RelationshipLookupSettingsService.instance = new STUB_RelationshipLookupSettingsService();

        RelationshipLookupsVMapper relationshipLookupsVMapperInstance = RelationshipLookupsVMapper.getInstance();

        Test.startTest();
        ComboBoxVModel activeItemRelTypesComboBoxVModel = relationshipLookupsVMapperInstance.getRelationshipLookupNameComboboxVModel(
            'TestRelationshipName1'
        );
        ComboBoxVModel inactiveItemRelTypesComboBoxVModel = relationshipLookupsVMapperInstance.getRelationshipLookupNameComboboxVModel(
            'TestRelationshipName6'
        );
        ComboBoxVModel missingItemRelTypesComboBoxVModel = relationshipLookupsVMapperInstance.getRelationshipLookupNameComboboxVModel(
            'TestRelationshipName8'
        );

        Test.stopTest();

        System.assertEquals(
            3,
            activeItemRelTypesComboBoxVModel.options.size(),
            'Should return 3 active unmapped relationship types (2 active unmapped + 1 current)'
        );

        System.assertEquals(
            2,
            inactiveItemRelTypesComboBoxVModel.options.size(),
            'Should return 2 active unmapped relationship types'
        );

        System.assertEquals(
            'TestRelationshipName1',
            activeItemRelTypesComboBoxVModel.options[0].value,
            'Relationship type value should be \'TestRelationshipName1\''
        );
        System.assertEquals(
            'TestRelationshipLabel1',
            activeItemRelTypesComboBoxVModel.options[0].label,
            'Relationship type label should be \'TestRelationshipLabel1\''
        );

        System.assertEquals(
            3,
            missingItemRelTypesComboBoxVModel.options.size(),
            'Should return 3 active unmapped relationship types'
        );

        //Checking if the mapper returns inactive item because this is the current record's value
        Boolean hasInactiveItemValue = false;
        for (ComboboxValueVModel inactiveItemVModel : inactiveItemRelTypesComboBoxVModel.options) {
            if (inactiveItemVModel.value == 'TestRelationshipName6') {
                hasInactiveItemValue = true;
                break;
            }
        }
        System.assertEquals(
            true,
            hasInactiveItemValue,
            'getRelationshipLookupNameComboboxVModel should return \'TestRelationshipName6\''
        );

        //Checking if the mapper returns missing item because this is the current record's value
        Boolean hasMissingItemValue = false;
        for (ComboboxValueVModel missingItemVModel : missingItemRelTypesComboBoxVModel.options) {
            if (missingItemVModel.value == 'TestRelationshipName8') {
                hasMissingItemValue = true;
                break;
            }
        }
        System.assertEquals(
            true,
            hasMissingItemValue,
            'getRelationshipLookupNameComboboxVModel should return \'TestRelationshipName8\''
        );
    }

    /***********************************************************************************************************************************
     ****************************************************** STUBS ***********************************************************************
     ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate valid responses from RelationshipLookupSettingsService
     **************************************************************************************************************************************/
    private class STUB_RelationshipLookupSettingsService extends RelationshipLookupSettingsService {
        public override List<RelationshipLookupModel> getRelationshipLookupModels() {
            List<RelationshipLookupModel> relLookupModelList = new List<RelationshipLookupModel>();
            relLookupModelList.add(
                new RelationshipLookupModel(
                    'TestRelationshipName1',
                    true,
                    'TestFemaleValue1',
                    'TestMaleValue1',
                    'TestNeutralValue1'
                )
            );
            relLookupModelList.add(
                new RelationshipLookupModel(
                    'TestRelationshipName2',
                    false,
                    'TestFemaleValue2',
                    'TestMaleValue2',
                    'TestNeutralValue2'
                )
            );
            relLookupModelList.add(
                new RelationshipLookupModel(
                    'TestRelationshipName3',
                    true,
                    'TestFemaleValue3',
                    'TestMaleValue3',
                    'TestNeutralValue3'
                )
            );
            relLookupModelList.add(
                new RelationshipLookupModel(
                    'TestRelationshipName4',
                    true,
                    'TestFemaleValue4',
                    'TestMaleValue4',
                    'TestNeutralValue4'
                )
            );
            relLookupModelList.add(
                new RelationshipLookupModel(
                    'TestRelationshipName5',
                    false,
                    'TestFemaleValue5',
                    'TestMaleValue5',
                    'TestNeutralValue5'
                )
            );
            return relLookupModelList;
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate valid responses from PicklistEntryService
     **************************************************************************************************************************************/
    private class STUB_PicklistEntryService extends PicklistEntryService {
        public override Map<String, PicklistEntryModel> getModelsByNameForSObjectField(
            SObjectType sObjectTypeName,
            SObjectField SObjectFieldName
        ) {
            Map<String, PicklistEntryModel> picklistModelsMap = new Map<String, PicklistEntryModel>();
            picklistModelsMap.put(
                'TestRelationshipName1',
                new PicklistEntryModel('TestRelationshipName1', 'TestRelationshipLabel1', true)
            );
            picklistModelsMap.put(
                'TestRelationshipName2',
                new PicklistEntryModel('TestRelationshipName2', 'TestRelationshipLabel2', true)
            );
            picklistModelsMap.put(
                'TestRelationshipName3',
                new PicklistEntryModel('TestRelationshipName3', 'TestRelationshipLabel3', true)
            );
            picklistModelsMap.put(
                'TestRelationshipName4',
                new PicklistEntryModel('TestRelationshipName4', 'TestRelationshipLabel4', false)
            );
            picklistModelsMap.put(
                'TestRelationshipName5',
                new PicklistEntryModel('TestRelationshipName5', 'TestRelationshipLabel5', false)
            );
            picklistModelsMap.put(
                'TestRelationshipName6',
                new PicklistEntryModel('TestRelationshipName6', 'TestRelationshipLabel6', true)
            );
            picklistModelsMap.put(
                'TestRelationshipName7',
                new PicklistEntryModel('TestRelationshipName7', 'TestRelationshipLabel7', true)
            );
            return picklistModelsMap;
        }
    }
}
