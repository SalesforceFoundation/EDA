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
 * @description Test class for RelationshipSettingsController class
 */
@isTest
private with sharing class RelationshipSettingsController_TEST {
    /**************************************************************************************************************************************************
     * @description Test method to verify that the locateRelationshipSettingsVMapper method returns instance of locateRelationshipSettingsVMapper.
     *************************************************************************************************************************************************/
    @isTest
    private static void locateRelationshipSettingsVMapper() {
        Test.startTest();
        RelationshipSettingsVMapper relationshipSettingsVMapperInstance = RelationshipSettingsController.locateRelationshipSettingsVMapper();
        Test.stopTest();

        System.assertEquals(
            RelationshipSettingsVMapper.getInstance(),
            RelationshipSettingsVMapperInstance,
            'Should return the instance of locateRelationshipSettingsVMapper.'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getRelationshipSettingsVModel method returns a RelationshipSettingsVModel
     * representing Relationship Settings in Hierarchy Settings.
     ****************************************************************************************************************************/
    @isTest
    private static void getRelationshipSettingsVModelValid() {
        RelationshipSettingsVMapper.instance = new STUB_RelationshipSettingsVMapper();

        Test.startTest();
        RelationshipSettingsVModel relationshipSettingsVModel = RelationshipSettingsController.getRelationshipSettingsVModel();
        Test.stopTest();

        System.assertEquals(
            'List Setting',
            relationshipSettingsVModel.reciprocalMethodComboboxVModel.value,
            'Selected value should be retrieved'
        );

        System.assertEquals(
            Label.stgReciprocalMethodListSetting,
            relationshipSettingsVModel.reciprocalMethodComboboxVModel.options[0].label,
            'Selected value should be retrieved'
        );

        System.assertEquals(
            'List Setting',
            relationshipSettingsVModel.reciprocalMethodComboboxVModel.options[0].value,
            'Selected value should be retrieved'
        );

        System.assertEquals(
            Label.stgReciprocalMethodValueInversion,
            relationshipSettingsVModel.reciprocalMethodComboboxVModel.options[1].label,
            'Selected value should be retrieved'
        );

        System.assertEquals(
            'Value Inversion',
            relationshipSettingsVModel.reciprocalMethodComboboxVModel.options[1].value,
            'Selected value should be retrieved'
        );

        System.assertEquals(
            true,
            relationshipSettingsVModel.preventAutoCreatedDuplicates,
            'Selected value should be retrieved for allow auto created duplicates'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getRelationshipSettingsVModel method fails gracefully when an exception is
     * encountered.
     ****************************************************************************************************************************/
    @isTest
    private static void getRelationshipSettingsVModelException() {
        RelationshipSettingsVMapper.instance = new STUB_ExceptionRelationshipSettingsVMapper();

        try {
            Test.startTest();
            RelationshipSettingsVModel relationshipSettingsVModel = RelationshipSettingsController.getRelationshipSettingsVModel();
            Test.stopTest();
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getRelationshipLookupsVModel method returns a RelationshipLookupsVModel
     * representing Relationship Lookups.
     ****************************************************************************************************************************/
    @isTest
    private static void getRelationshipLookupsVModelValid() {
        RelationshipLookupsVMapper.instance = new STUB_RelationshipLookupsVMapper();

        Test.startTest();
        RelationshipLookupsVModel relLookupsVModel = RelationshipSettingsController.getRelationshipLookupsVModel();
        Test.stopTest();
        System.assertEquals(2, relLookupsVModel.relationshipLookups.size(), 'Should return 2 items');
        System.assertEquals(
            'RelationshipLookupName1',
            relLookupsVModel.relationshipLookups[0].name,
            'Relationship lookup name should be \'RelationshipLookupName1\''
        );
        System.assertEquals(
            'FemaleValue1',
            relLookupsVModel.relationshipLookups[0].femaleValue,
            'femaleValue should be \'FemaleValue1\''
        );
        System.assertEquals(
            'MaleValue1',
            relLookupsVModel.relationshipLookups[0].maleValue,
            'maleValue should be \'MaleValue1\''
        );
        System.assertEquals(
            'NeutralValue1',
            relLookupsVModel.relationshipLookups[0].neutralValue,
            'neutralValue should be \'NeutralValue1\''
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getRelationshipLookupComboboxVModel method returns a ComboBoxVModel
     * representing active relationship types.
     ****************************************************************************************************************************/
    @isTest
    private static void getRelationshipLookupComboboxVModelValid() {
        RelationshipLookupsVMapper.instance = new STUB_RelationshipLookupsVMapper();

        Test.startTest();
        ComboBoxVModel activeRelTypesComboboxVModel = RelationshipSettingsController.getRelationshipLookupComboboxVModel(
            ''
        );
        Test.stopTest();
        System.assertEquals(2, activeRelTypesComboboxVModel.options.size(), 'Should return 2 items');
        System.assertEquals(
            'ActiveRelationshipName1',
            activeRelTypesComboboxVModel.options[0].value,
            'Active item value should be \'ActiveRelationshipName1\''
        );
        System.assertEquals(
            'ActiveRelationshipLabel1',
            activeRelTypesComboboxVModel.options[0].label,
            'Active item label should be \'ActiveRelationshipLabel1\''
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getRelationshipLookupNameComboboxVModel method returns a ComboBoxVModel
     * representing unmapped relationship types.
     ****************************************************************************************************************************/
    @isTest
    private static void getRelationshipLookupNameComboboxVModelValid() {
        RelationshipLookupsVMapper.instance = new STUB_RelationshipLookupsVMapper();

        Test.startTest();
        ComboBoxVModel activeUnmappedRelTypesComboboxVModel = RelationshipSettingsController.getRelationshipLookupNameComboboxVModel(
            ''
        );
        Test.stopTest();
        System.assertEquals(2, activeUnmappedRelTypesComboboxVModel.options.size(), 'Should return 2 items');
        System.assertEquals(
            'UnmappedRelationshipName1',
            activeUnmappedRelTypesComboboxVModel.options[0].value,
            'Unmapped item value should be \'UnmappedRelationshipName1\''
        );
        System.assertEquals(
            'UnmappedRelationshipLabel1',
            activeUnmappedRelTypesComboboxVModel.options[0].label,
            'Unmapped item label should be \'UnmappedRelationshipLabel1\''
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getRelationshipLookupsVModel method fails gracefully when an exception is
     * encountered.
     ****************************************************************************************************************************/
    @isTest
    private static void getRelationshipLookupsVModelException() {
        RelationshipLookupsVMapper.instance = new STUB_ExceptionRelationshipLookupsVMapper();

        try {
            Test.startTest();
            RelationshipLookupsVModel relLookupsVModel = RelationshipSettingsController.getRelationshipLookupsVModel();
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getRelationshipLookupComboboxVModel method fails gracefully when an exception is
     * encountered.
     ****************************************************************************************************************************/
    @isTest
    private static void getRelationshipLookupComboboxVModelException() {
        RelationshipLookupsVMapper.instance = new STUB_ExceptionRelationshipLookupsVMapper();

        try {
            Test.startTest();
            ComboBoxVModel activeRelTypesComboboxVModel = RelationshipSettingsController.getRelationshipLookupComboboxVModel(
                ''
            );
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getRelationshipLookupNameComboboxVModel method fails gracefully when an exception is
     * encountered.
     ****************************************************************************************************************************/
    @isTest
    private static void getRelationshipLookupNameComboboxVModelException() {
        RelationshipLookupsVMapper.instance = new STUB_ExceptionRelationshipLookupsVMapper();

        try {
            Test.startTest();
            ComboBoxVModel activeUnmappedRelTypesComboboxVModel = RelationshipSettingsController.getRelationshipLookupNameComboboxVModel(
                ''
            );
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }

        RelationshipLookupsVMapper.instance = new STUB_RelationshipLookupsVMapper();
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the createRelationshipLookup method returns a valid relationship lookup name
     ****************************************************************************************************************************/
    @isTest
    private static void createRelationshipLookupSuccess() {
        RelationshipLookupSettingsService.instance = new STUB_RelationshipLookupSettingsService();
        String relationshipLookupName = 'TestInsertedLookupName';

        Test.startTest();
        String insertedRelationshipLookupName = RelationshipSettingsController.createRelationshipLookup(
            relationshipLookupName,
            'TestFemaleValue',
            'TestMaleValue',
            'TestNeutralValue',
            true
        );
        Test.stopTest();
        System.assertEquals(
            relationshipLookupName,
            insertedRelationshipLookupName,
            'Relationship lookup name should be ' + relationshipLookupName
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the updateRelationshipLookup method returns a valid relationship lookup name
     ****************************************************************************************************************************/
    @isTest
    private static void updateRelationshipLookupSuccess() {
        RelationshipLookupSettingsService.instance = new STUB_RelationshipLookupSettingsService();

        String relationshipLookupName = 'TestUpdatedLookupName';
        String oldRelationshipLookupName = 'TestOldLookupName';

        Test.startTest();
        String updatedRelationshipLookupName = RelationshipSettingsController.updateRelationshipLookup(
            oldRelationshipLookupName,
            relationshipLookupName,
            'TestFemaleValue',
            'TestMaleValue',
            'TestNeutralValue',
            true
        );
        Test.stopTest();
        System.assertEquals(
            relationshipLookupName,
            updatedRelationshipLookupName,
            'Relationship lookup name should be ' + relationshipLookupName
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the deleteRelationshipLookup method returns a valid relationship lookup name
     ****************************************************************************************************************************/
    @isTest
    private static void deleteRelationshipLookupSuccess() {
        RelationshipLookupSettingsService.instance = new STUB_RelationshipLookupSettingsService();

        String relationshipLookupName = 'TestDeletedLookupName';

        Test.startTest();
        String deletedRelationshipLookupName = RelationshipSettingsController.deleteRelationshipLookup(
            relationshipLookupName
        );
        Test.stopTest();
        System.assertEquals(
            relationshipLookupName,
            deletedRelationshipLookupName,
            'Relationship lookup name should be ' + relationshipLookupName
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the createRelationshipLookup method fails gracefully when an exception is
     * encountered.
     ****************************************************************************************************************************/
    @isTest
    private static void createRelationshipLookupException() {
        RelationshipLookupSettingsService.instance = new STUB_ExceptionRelationshipLookupSettingsService();

        try {
            Test.startTest();
            String insertedRelLookupName = RelationshipSettingsController.createRelationshipLookup(
                'TestRelationshipLookupName',
                'femaleValue',
                'maleValue',
                'neutralValue',
                false
            );
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the updateRelationshipLookup method fails gracefully when an exception is
     * encountered.
     ****************************************************************************************************************************/
    @isTest
    private static void updateRelationshipLookupException() {
        RelationshipLookupSettingsService.instance = new STUB_ExceptionRelationshipLookupSettingsService();

        try {
            Test.startTest();
            String updatedRelLookupName = RelationshipSettingsController.updateRelationshipLookup(
                'TestOldRelationshipLookupName',
                'TestRelationshipLookupName',
                'femaleValue',
                'maleValue',
                'neutralValue',
                false
            );
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the deleteRelationshipLookup method fails gracefully when an exception is
     * encountered.
     ****************************************************************************************************************************/
    @isTest
    private static void deleteRelationshipLookupException() {
        RelationshipLookupSettingsService.instance = new STUB_ExceptionRelationshipLookupSettingsService();

        try {
            Test.startTest();
            String deletedRelLookupName = RelationshipSettingsController.deleteRelationshipLookup(
                'TestRelationshipLookupName'
            );
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /**************************************************************************************************************************
     ****************************************************** STUBS **************************************************************
     **************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from RelationshipSettingsVMapper to return a valid RelationshipSettingsVModel
     **************************************************************************************************************************************/
    private class STUB_RelationshipSettingsVMapper extends RelationshipSettingsVMapper {
        public override RelationshipSettingsVModel getRelationshipSettingsVModel() {
            ComboboxValueVModel listSettingComboboxValueVModel = new ComboboxValueVModel(
                Label.stgReciprocalMethodListSetting,
                'List Setting'
            );
            ComboboxValueVModel valueInversionComboboxValueVModel = new ComboboxValueVModel(
                Label.stgReciprocalMethodValueInversion,
                'Value Inversion'
            );
            List<ComboboxValueVModel> relationshipTypeComboboxValueVModelsList = new List<ComboboxValueVModel>();

            relationshipTypeComboboxValueVModelsList.add(listSettingComboboxValueVModel);
            relationshipTypeComboboxValueVModelsList.add(valueInversionComboboxValueVModel);

            return new RelationshipSettingsVModel(
                new comboboxvmodel('List Setting', relationshipTypeComboboxValueVModelsList),
                true
            );
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from RelationshipSettingsVMapper to throw an exception
     **************************************************************************************************************************************/
    private class STUB_ExceptionRelationshipSettingsVMapper extends RelationshipSettingsVMapper {
        public override RelationshipSettingsVModel getRelationshipSettingsVModel() {
            throw new TestException('Exception encountered!');
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from RelationshipLookupsVMapper to return a valid RelationshipSettingsVModel
     **************************************************************************************************************************************/
    private class STUB_RelationshipLookupsVMapper extends RelationshipLookupsVMapper {
        public override RelationshipLookupsVModel getRelationshipLookupsVModel() {
            List<RelationshipLookupVModel> relationshipLookupVModelList = new List<RelationshipLookupVModel>();
            relationshipLookupVModelList.add(
                new RelationshipLookupVModel(
                    'RelationshipLookupName1',
                    'FemaleValue1',
                    'MaleValue1',
                    'NeutralValue1',
                    true
                )
            );
            relationshipLookupVModelList.add(
                new RelationshipLookupVModel(
                    'RelationshipLookupName2',
                    'FemaleValue2',
                    'MaleValue2',
                    'NeutralValue2',
                    true
                )
            );
            return new RelationshipLookupsVModel(relationshipLookupVModelList);
        }

        public override ComboBoxVModel getRelationshipLookupComboboxVModel(String relationshipLookupName) {
            List<ComboboxValueVModel> relationshipLookupComboboxValueVModelsList = new List<ComboboxValueVModel>();
            relationshipLookupComboboxValueVModelsList.add(
                new ComboboxValueVModel('ActiveRelationshipLabel1', 'ActiveRelationshipName1')
            );
            relationshipLookupComboboxValueVModelsList.add(
                new ComboboxValueVModel('ActiveRelationshipLabel2', 'ActiveRelationshipName2')
            );

            return new ComboboxVModel('ActiveRelationshipName1', relationshipLookupComboboxValueVModelsList);
        }

        public override ComboBoxVModel getRelationshipLookupNameComboboxVModel(String relationshipLookupName) {
            List<ComboboxValueVModel> relationshipLookupComboboxValueVModelsList = new List<ComboboxValueVModel>();
            relationshipLookupComboboxValueVModelsList.add(
                new ComboboxValueVModel('UnmappedRelationshipLabel1', 'UnmappedRelationshipName1')
            );
            relationshipLookupComboboxValueVModelsList.add(
                new ComboboxValueVModel('UnmappedRelationshipLabel2', 'UnmappedRelationshipName2')
            );

            return new ComboboxVModel('UnmappedRelationshipName1', relationshipLookupComboboxValueVModelsList);
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from RelationshipSettingsVMapper to throw an exception
     **************************************************************************************************************************************/
    private class STUB_ExceptionRelationshipLookupsVMapper extends RelationshipLookupsVMapper {
        public override RelationshipLookupsVModel getRelationshipLookupsVModel() {
            throw new TestException('Exception encountered!');
        }

        public override ComboBoxVModel getRelationshipLookupComboboxVModel(String relationshipLookupName) {
            throw new TestException('Exception encountered!');
        }

        public override ComboBoxVModel getRelationshipLookupNameComboboxVModel(String relationshipLookupName) {
            throw new TestException('Exception encountered!');
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from RelationshipLookupSettingsService to return a valid RelationshipLookupSettingsService
     **************************************************************************************************************************************/
    private class STUB_RelationshipLookupSettingsService extends RelationshipLookupSettingsService {
        public override RelationshipLookupModel insertRelationshipLookup(
            String relationshipLookupName,
            String femaleValue,
            String maleValue,
            String neutralValue,
            Boolean isActive
        ) {
            return new RelationshipLookupModel(relationshipLookupName, isActive, femaleValue, maleValue, neutralValue);
        }

        public override RelationshipLookupModel updateRelationshipLookup(
            String oldRelationshipLookupName,
            String newRelationshipLookupName,
            String femaleValue,
            String maleValue,
            String neutralValue,
            Boolean isActive
        ) {
            return new RelationshipLookupModel(
                newRelationshipLookupName,
                isActive,
                femaleValue,
                maleValue,
                neutralValue
            );
        }

        public override RelationshipLookupModel deleteRelationshipLookup(String relationshipLookupName) {
            return new RelationshipLookupModel(
                relationshipLookupName,
                true,
                'TestDeletedFemaleValue',
                'TestDeletedMaleValue',
                'TestDeletedNeutralValue'
            );
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from RelationshipLookupSettingsService to throw an exception
     **************************************************************************************************************************************/
    private class STUB_ExceptionRelationshipLookupSettingsService extends RelationshipLookupSettingsService {
        public override RelationshipLookupModel insertRelationshipLookup(
            String relationshipLookupName,
            String femaleValue,
            String maleValue,
            String neutralValue,
            Boolean isActive
        ) {
            throw new TestException('Exception encountered!');
        }

        public override RelationshipLookupModel updateRelationshipLookup(
            String oldRelationshipLookupName,
            String newRelationshipLookupName,
            String femaleValue,
            String maleValue,
            String neutralValue,
            Boolean isActive
        ) {
            throw new TestException('Exception encountered!');
        }

        public override RelationshipLookupModel deleteRelationshipLookup(String relationshipLookupName) {
            throw new TestException('Exception encountered!');
        }
    }

    private class TestException extends Exception {
    }
}
