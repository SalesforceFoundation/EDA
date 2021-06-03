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
 * @description Test class for RelationshipSettingsVMapper class
 */
@isTest
private with sharing class RelationshipSettingsVMapper_TEST {
    private static Integer loopCounter = 5;

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * RelationshipSettingsVMapper class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        RelationshipSettingsVMapper relationshipSettingsVMapperInstance = RelationshipSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            RelationshipSettingsVMapper.instance,
            relationshipSettingsVMapperInstance,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            true,
            relationshipSettingsVMapperInstance != null,
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * RelationshipSettingsVMapper class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        RelationshipSettingsVMapper relationshipSettingsVMapperInstance1 = RelationshipSettingsVMapper.getInstance();
        RelationshipSettingsVMapper relationshipSettingsVMapperInstance2 = RelationshipSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            RelationshipSettingsVMapper.instance,
            relationshipSettingsVMapperInstance1,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            relationshipSettingsVMapperInstance1,
            relationshipSettingsVMapperInstance2,
            'Subsequent retrievals of service class instance should return existing instance.'
        );

        System.assertEquals(
            true,
            relationshipSettingsVMapperInstance1 != null,
            'Instance of service class should not be null.'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the locateRelationshipSettingsService method returns instance of locateRelationshipSettingsService
     ***********************************************************************************************************************************/
    @isTest
    private static void locateRelationshipSettingsService() {
        RelationshipSettingsVMapper relationshipSettingsVMapperInstance = RelationshipSettingsVMapper.getInstance();

        Test.startTest();
        RelationshipSettingsService relationshipSettingsServiceInstance = RelationshipSettingsVMapperInstance.locateRelationshipSettingsService();
        Test.stopTest();

        System.assertEquals(
            RelationshipSettingsService.getInstance(),
            relationshipSettingsServiceInstance,
            'Should return the instance of RelationshipSettingsService'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getReciprocalMethodTypesComboboxValueVModelList returns accurate
     * List of ComboboxValueVModel for reciporcal method settings
     ***********************************************************************************************************************************/
    @isTest
    private static void getReciprocalMethodTypesComboboxValueVModelList() {
        RelationshipSettingsVMapper relationshipSettingsVMapperInstance = RelationshipSettingsVMapper.getInstance();

        Test.startTest();
        List<ComboboxValueVModel> relationshipTypeComboboxValueVModelsList = relationshipSettingsVMapperInstance.getReciprocalMethodTypesComboboxValueVModelList();
        Test.stopTest();

        System.assertEquals(
            Label.stgReciprocalMethodListSetting,
            relationshipTypeComboboxValueVModelsList[0].label,
            'Should only list active record types as options.'
        );

        System.assertEquals(
            'List Setting',
            relationshipTypeComboboxValueVModelsList[0].value,
            'Should only list active record types as options.'
        );

        System.assertEquals(
            Label.stgReciprocalMethodValueInversion,
            relationshipTypeComboboxValueVModelsList[1].label,
            'Should only list active record types as options.'
        );

        System.assertEquals(
            'Value Inversion',
            relationshipTypeComboboxValueVModelsList[1].value,
            'Should only list active record types as options.'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getRelationshipSettingsVModel returns an RelationshipSettingsVModel with the selected
     * value set to the value specified in the associated Hierarchy Settings fields and a list of comboboxValueVModels with available values
     ***********************************************************************************************************************************/
    @isTest
    private static void getRelationshipSettingsVModel() {
        RelationshipSettingsService.instance = new STUB_RelationshipSettingsService();

        RelationshipSettingsVMapper relationshipSettingsVMapperInstance = RelationshipSettingsVMapper.getInstance();

        Test.startTest();
        RelationshipSettingsVModel relationshipSettingsVModel = relationshipSettingsVMapperInstance.getRelationshipSettingsVModel();
        Test.stopTest();

        System.assertEquals(
            'List Setting',
            relationshipSettingsVModel.reciprocalMethodComboboxVModel.value,
            'Selected value for Reciprocal method should be retreived.'
        );

        System.assertEquals(
            Label.stgReciprocalMethodListSetting,
            relationshipSettingsVModel.reciprocalMethodComboboxVModel.options[0].label,
            'Label for the reciprocal method options shoule be retreived'
        );

        System.assertEquals(
            'List Setting',
            relationshipSettingsVModel.reciprocalMethodComboboxVModel.options[0].value,
            'Value for the reciprocal method options shoule be retreived'
        );

        System.assertEquals(
            Label.stgReciprocalMethodValueInversion,
            relationshipSettingsVModel.reciprocalMethodComboboxVModel.options[1].label,
            'Label for the reciprocal method options shoule be retreived'
        );

        System.assertEquals(
            'Value Inversion',
            RelationshipSettingsVModel.reciprocalMethodComboboxVModel.options[1].value,
            'Value for the reciprocal method options shoule be retreived'
        );

        System.assertEquals(
            false,
            relationshipSettingsVModel.preventAutoCreatedDuplicates,
            'Inverted value for Allow Auto Created Duplicates should be retreived.'
        );
    }

    /**************************************************************************************************************************
     ****************************************************** STUBS **************************************************************
     **************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from RelationshipSettingsService to return a RelationshipSettingsModel
     **************************************************************************************************************************************/
    private class STUB_RelationshipSettingsService extends RelationshipSettingsService {
        public override RelationshipSettingsModel getRelationshipSettingsModel() {
            return new RelationshipSettingsModel('List Setting', true);
        }
    }
}
