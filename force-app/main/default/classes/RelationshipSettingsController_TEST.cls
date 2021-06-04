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

    private class TestException extends Exception {
    }
}
