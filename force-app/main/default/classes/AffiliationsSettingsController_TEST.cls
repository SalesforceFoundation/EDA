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
 * @description Test class for AffiliaitonsSettingsController class
 */
@isTest
private with sharing class AffiliationsSettingsController_TEST {
    /**************************************************************************************************************************************************
     * @description Test method to verify that the locateAffiliaitonsSettingsVMapper method returns instance of locateAffiliaitonsSettingsVMapper.
     *************************************************************************************************************************************************/
    @isTest
    private static void locateAffiliaitonsSettingsVMapper() {
        Test.startTest();
        AffiliationsSettingsVMapper affiliaitonsSettingsVMapperInstance = AffiliationsSettingsController.locateAffiliationsSettingsVMapper();
        Test.stopTest();

        System.assertEquals(
            AffiliationsSettingsVMapper.getInstance(),
            affiliaitonsSettingsVMapperInstance,
            'Should return the instance of locateAffiliaitonsSettingsVMapper.'
        );
    }

    /**************************************************************************************************************************************************
     * @description Test method to verify that the locateAffiliationMappingsService method returns instance of locateAffiliationMappingsService.
     *************************************************************************************************************************************************/
    @isTest
    private static void locateAffiliationMappingsService() {
        Test.startTest();
        AffiliationMappingsService affiliationMappingsServiceInstance = AffiliationsSettingsController.locateAffiliationMappingsService();
        Test.stopTest();

        System.assertEquals(
            AffiliationMappingsService.getInstance(),
            affiliationMappingsServiceInstance,
            'Should return the instance of locateAffiliaitonsSettingsVMapper.'
        );
    }

    /**************************************************************************************************************************************************
     * @description Test method to verify that the locateRecordTypeService method returns instance of locateRecordTypeService.
     *************************************************************************************************************************************************/
    @isTest
    private static void locateRecordTypeService() {
        Test.startTest();
        RecordTypeService recordTypeServiceInstance = AffiliationsSettingsController.locateRecordTypeService();
        Test.stopTest();

        System.assertEquals(
            RecordTypeService.getInstance(),
            recordTypeServiceInstance,
            'Should return the instance of RecordTypeService.'
        );
    }

    /**************************************************************************************************************************************************
     * @description Test method to verify that the locatePrimaryAffiliationsSettingsVMapper method returns instance of locatePrimaryAffiliationsSettingsVMapper.
     *************************************************************************************************************************************************/
    @isTest
    private static void locatePrimaryAffiliationsSettingsVMapper() {
        Test.startTest();
        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = AffiliationsSettingsController.locatePrimaryAffiliationsSettingsVMapper();
        Test.stopTest();

        System.assertEquals(
            PrimaryAffiliationsSettingsVMapper.getInstance(),
            primaryAffiliationsSettingsVMapperInstance,
            'Should return the instance of locateAffiliaitonsSettingsVMapper.'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getAffiliationsSettingsVModel method returns a AffiliationsSettingsVModel
     * representing Affiliations Settings in Hierarchy Settings.
     ****************************************************************************************************************************/
    @isTest
    private static void getAffiliationsSettingsVModel() {
        AffiliationsSettingsVMapper.instance = new STUB_AffiliationsSettingsVMapper();

        Test.startTest();
        AffiliationsSettingsVModel affiliationsSettingsVModel = AffiliationsSettingsController.getAffiliationsSettingsVModel();
        Test.stopTest();

        System.assertEquals(
            true,
            affiliationsSettingsVModel.accountRecordTypesEnforced,
            'Affiliation recordtype should be enforced.'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getAffiliationsSettingsVModel method fails gracefully when an exception is
     * encountered.
     ****************************************************************************************************************************/
    @isTest
    private static void getAffiliationsSettingsViewModelException() {
        AffiliationsSettingsVMapper.instance = new STUB_ExceptionAffiliationsSettingsVMapper();

        try {
            Test.startTest();
            AffiliationsSettingsVModel affiliationsSettingsVModel = AffiliationsSettingsController.getAffiliationsSettingsVModel();
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getPrimaryAffiliationsSettingsVModel method returns a PrimaryAffiliationSettingsVModel
     * representing Affiliations Settings in Hierarchy Settings.
     ****************************************************************************************************************************/
    @isTest
    private static void getPrimaryAffiliationsSettingsVModel() {
        PrimaryAffiliationsSettingsVMapper.instance = new STUB_PrimaryAffiliationsSettingsVMapper();

        Test.startTest();
        PrimaryAffiliationSettingsVModel primaryAffiliationSettingsVModel = AffiliationsSettingsController.getPrimaryAffiliationsSettingsVModel();
        Test.stopTest();

        System.assertEquals(
            'Academic Program',
            primaryAffiliationSettingsVModel.primaryAffiliationMappings[0].mappingName,
            'Affiliation recordtype should be enforced.'
        );

        System.assertEquals(
            'Primary_Academic_Program__c',
            primaryAffiliationSettingsVModel.primaryAffiliationMappings[0].accountRecordTypeName,
            'Affiliation recordtype should be enforced.'
        );

        System.assertEquals(
            'Primary Academic Program',
            primaryAffiliationSettingsVModel.primaryAffiliationMappings[0].accountRecordTypeLabel,
            'Affiliation recordtype should be enforced.'
        );

        System.assertEquals(
            'Academic_Program',
            primaryAffiliationSettingsVModel.primaryAffiliationMappings[0].contactFieldName,
            'Affiliation recordtype should be enforced.'
        );

        System.assertEquals(
            'Academic Program',
            primaryAffiliationSettingsVModel.primaryAffiliationMappings[0].contactFieldLabel,
            'Affiliation recordtype should be enforced.'
        );

        System.assertEquals(
            false,
            primaryAffiliationSettingsVModel.primaryAffiliationMappings[0].autoProgramEnrollment,
            'Affiliation auto-enrollment should not be enabled.'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getPrimaryAffiliationsSettingsVModel method fails gracefully when an exception is
     * encountered.
     ****************************************************************************************************************************/
    @isTest
    private static void getPrimaryAffiliationsSettingsVModelException() {
        PrimaryAffiliationsSettingsVMapper.instance = new STUB_ExceptionPrimaryAffiliationsSettingsVMapper();

        try {
            Test.startTest();
            PrimaryAffiliationSettingsVModel primaryAffiliationSettingsVModel = AffiliationsSettingsController.getPrimaryAffiliationsSettingsVModel();
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getAccountRecordTypeComboboxVModel method returns a ComboBoxVModel
     ****************************************************************************************************************************/
    @isTest
    private static void getAccountRecordTypeComboboxVModel() {
        PrimaryAffiliationsSettingsVMapper.instance = new STUB_PrimaryAffiliationsSettingsVMapperComboBox();

        Test.startTest();
        ComboBoxVModel accRecTypeComboboxVModel = AffiliationsSettingsController.getAccountRecordTypeComboboxVModel(
            'Business_Organization'
        );
        Test.stopTest();

        System.assertEquals(
            'Business_Organization',
            accRecTypeComboboxVModel.value,
            'The value should be same as passed'
        );

        System.assertEquals(
            'Academic Program',
            accRecTypeComboboxVModel.options[0].label,
            'The value should be same as passed'
        );

        System.assertEquals(
            'Academic_Program',
            accRecTypeComboboxVModel.options[0].value,
            'The value should be same as passed'
        );

        System.assertEquals(
            'Business Organization',
            accRecTypeComboboxVModel.options[1].label,
            'The value should be same as passed'
        );

        System.assertEquals(
            'Business_Organization',
            accRecTypeComboboxVModel.options[1].value,
            'The value should be same as passed'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getAccountRecordTypeComboboxVModel method fails gracefully when an exception is
     * encountered.
     ****************************************************************************************************************************/
    @isTest
    private static void getAccountRecordTypeComboboxVModelException() {
        PrimaryAffiliationsSettingsVMapper.instance = new STUB_ExceptionPrimaryAffiliationsSettingsVMapperComboBox();

        try {
            Test.startTest();
            ComboBoxVModel accRecTypeComboboxVModel = AffiliationsSettingsController.getAccountRecordTypeComboboxVModel(
                'Business_Organization'
            );
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getContactAccountLookupFieldComboboxVModel method returns a ComboBoxVModel
     ****************************************************************************************************************************/
    @isTest
    private static void getContactAccountLookupFieldComboboxVModel() {
        PrimaryAffiliationsSettingsVMapper.instance = new STUB_PrimaryAffiliationsSettingsVMapperLookup();

        Test.startTest();
        ComboBoxVModel accRecTypeComboboxVModel = AffiliationsSettingsController.getContactAccountLookupFieldComboboxVModel(
            'Primary_Organization__c'
        );
        Test.stopTest();

        System.assertEquals(
            'Primary_Organization__c',
            accRecTypeComboboxVModel.value,
            'The value should be same as passed'
        );

        System.assertEquals(
            'Primary Academic Program',
            accRecTypeComboboxVModel.options[0].label,
            'The value should be same as passed'
        );

        System.assertEquals(
            'Primary_Academic_Program__c',
            accRecTypeComboboxVModel.options[0].value,
            'The value should be same as passed'
        );

        System.assertEquals(
            'Primary Business Organization',
            accRecTypeComboboxVModel.options[1].label,
            'The value should be same as passed'
        );

        System.assertEquals(
            'Primary_Organization__c',
            accRecTypeComboboxVModel.options[1].value,
            'The value should be same as passed'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the insertAffiliationMappings method inserts records into custom settings
     ****************************************************************************************************************************/
    @isTest
    private static void insertAffiliationMappings() {
        Test.startTest();
        String mappingName = AffiliationsSettingsController.insertAffiliationMappings(
            'Business_Organization',
            'Business_Organization',
            'Primary_Department__c'
        );
        Test.stopTest();

        Affl_Mappings__c afflSettings = Affl_Mappings__c.getInstance('Business_Organization');
        System.assertEquals(
            'Business_Organization',
            afflSettings.name,
            'Household account mappings should be retrieved'
        );
        System.assertEquals(
            'Business_Organization',
            afflSettings.Account_Record_Type__c,
            'Account record type should be changed to Business organization'
        );
        System.assertEquals(
            'Primary_Department__c',
            afflSettings.Primary_Affl_Field__c,
            'Primary Affiliation Field should change to Primary Department'
        );
        System.assertEquals(
            'Business Organization',
            mappingName,
            'The recordtype label of the changed account rectype should be returned'
        );
    }

    /****************************************************************************************************************************
     * @description  Test method to verify that the insertAffiliationMappings method fails gracefully when an exception is
     * encountered.
     ****************************************************************************************************************************/
    @isTest
    private static void insertAffiliationMappingsException() {
        UserPermissionService.instance = new STUB_UserPermissionServiceFalse();
        try {
            Test.startTest();
            AffiliationsSettingsController.insertAffiliationMappings(
                'Business_Organization',
                'Business_Organization',
                'Primary_Department__c'
            );
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the insertAffiliationMappings method updates the custom settings
     ****************************************************************************************************************************/
    @isTest
    private static void insertAffiliationMappingsNull() {
        RecordTypeMapper.instance = new STUB_RecordTypeMapperNull();
        Test.startTest();
        String accRectypeLabelAfterInsert = AffiliationsSettingsController.insertAffiliationMappings(
            'Business_Organization',
            'Business_Organization',
            'Primary_Department__c'
        );
        Test.stopTest();
        Affl_Mappings__c afflSettings = Affl_Mappings__c.getInstance('Business_Organization');
        System.assertEquals(
            'Business_Organization',
            afflSettings.name,
            'Household account mappings should be retrieved'
        );
        System.assertEquals(
            'Business_Organization',
            afflSettings.Account_Record_Type__c,
            'Account record type should be changed to Business organization'
        );
        System.assertEquals(
            'Primary_Department__c',
            afflSettings.Primary_Affl_Field__c,
            'Primary Affiliation Field should change to Primary Department'
        );
        System.assertEquals(
            'Business_Organization',
            accRectypeLabelAfterInsert,
            'Account recordtype should be returned'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the updateAffiliationMappings method updates the custom settings
     ****************************************************************************************************************************/
    @isTest
    private static void updateAffiliationMappings() {
        Affl_Mappings__c afflMapping = new Affl_Mappings__c(
            Name = 'Household Account',
            Account_Record_Type__c = 'HH_Account',
            Primary_Affl_Field__c = 'Primary_Household__c'
        );
        insert afflMapping;

        Test.startTest();
        String accRectypeLabelAfterUpdate = AffiliationsSettingsController.updateAffiliationMappings(
            'Household Account',
            'Business_Organization',
            'Primary_Department__c'
        );
        Test.stopTest();

        Affl_Mappings__c afflSettings = Affl_Mappings__c.getInstance('Household Account');
        System.assertEquals('Household Account', afflSettings.name, 'Household account mappings should be retrieved');
        System.assertEquals(
            'Business_Organization',
            afflSettings.Account_Record_Type__c,
            'Account record type should be changed to Business organization'
        );
        System.assertEquals(
            'Primary_Department__c',
            afflSettings.Primary_Affl_Field__c,
            'Primary Affiliation Field should change to Primary Department'
        );
        System.assertEquals(
            'Business Organization',
            accRectypeLabelAfterUpdate,
            'The recordtype label of the changed account rectype should be returned'
        );
    }

    /****************************************************************************************************************************
     * @description  Test method to verify that the updateAffiliationMappings method fails gracefully when an exception is
     * encountered.
     ****************************************************************************************************************************/
    @isTest
    private static void updateAffiliationMappingsException() {
        UserPermissionService.instance = new STUB_UserPermissionServiceFalse();
        try {
            Test.startTest();
            AffiliationsSettingsController.updateAffiliationMappings(
                'Household Account',
                'Business_Organization',
                'Primary_Department__c'
            );
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the updateAffiliationMappings method updates the custom settings
     ****************************************************************************************************************************/
    @isTest
    private static void updateAffiliationMappingsNull() {
        Affl_Mappings__c afflMapping = new Affl_Mappings__c(
            Name = 'Household Account',
            Account_Record_Type__c = 'HH_Account',
            Primary_Affl_Field__c = 'Primary_Household__c'
        );
        insert afflMapping;
        RecordTypeMapper.instance = new STUB_RecordTypeMapperNull();
        Test.startTest();
        String accRectypeLabelAfterUpdate = AffiliationsSettingsController.updateAffiliationMappings(
            'Household Account',
            'Business_Organization',
            'Primary_Department__c'
        );
        Test.stopTest();
        System.assertEquals(
            'Business_Organization',
            accRectypeLabelAfterUpdate,
            'Account recordtype should be returned'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getContactAccountLookupFieldComboboxVModel method fails gracefully when an exception is
     * encountered.
     ****************************************************************************************************************************/
    @isTest
    private static void getContactAccountLookupFieldComboboxVModelException() {
        PrimaryAffiliationsSettingsVMapper.instance = new STUB_ExceptionPrimaryAffiliationsSettingsVMapperLookup();

        try {
            Test.startTest();
            ComboBoxVModel accRecTypeComboboxVModel = AffiliationsSettingsController.getContactAccountLookupFieldComboboxVModel(
                'Primary_Organization__c'
            );
            Test.stopTest();
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the deleteAffiliationMapping method deletes an affiliation mapping when it exists.
     ****************************************************************************************************************************/
    @isTest
    private static void deleteAffiliationMapping() {
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsService();

        Affl_Mappings__c afflMapping = new Affl_Mappings__c(
            Name = 'Test Affiliation Mapping',
            Account_Record_Type__c = 'Test_Account_Record',
            Primary_Affl_Field__c = 'Test Contact Field'
        );

        Test.startTest();
        String accountRecordTypeNameAfterDelete = AffiliationsSettingsController.deleteAffiliationMapping(
            'Test Affiliation Mapping'
        );
        Test.stopTest();

        System.assertEquals(
            'Test_Account_Record',
            accountRecordTypeNameAfterDelete,
            'Should return name of account record associated with deleted affiliation mapping.'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the deleteAffiliationMapping method returns null when attempting to delete an
     * affiliation mapping that does not exist.
     ****************************************************************************************************************************/
    @isTest
    private static void deleteAffiliationMappingInvalid() {
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsServiceNull();

        Test.startTest();
        String accountRecordTypeNameAfterDelete = AffiliationsSettingsController.deleteAffiliationMapping(
            'Non-Existent Affiliation Mapping'
        );
        Test.stopTest();

        System.assertEquals(
            null,
            accountRecordTypeNameAfterDelete,
            'Should return null when attempting to delete an affiliation mapping that does not exist.'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the deleteAffiliationMapping method fails gracefully when an exception is
     * encountered.
     ****************************************************************************************************************************/
    @isTest
    private static void deleteAffiliationMappingException() {
        AffiliationMappingsService.instance = new STUB_ExceptionAffiliationMappingsService();

        try {
            Test.startTest();
            String accountRecordTypeNameAfterDelete = AffiliationsSettingsController.deleteAffiliationMapping(
                'Non-Existent Affiliation Mapping'
            );
            Test.stopTest();
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /**************************************************************************************************************************
     ****************************************************** STUBS **************************************************************
     **************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AffiliationsSettingsVMapper to return a valid AffiliationsSettingVModel
     **************************************************************************************************************************************/
    private class STUB_AffiliationsSettingsVMapper extends AffiliationsSettingsVMapper {
        public override AffiliationsSettingsVModel getAffiliationsSettingsViewModel() {
            return new AffiliationsSettingsVModel(true);
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AffiliationsSettingsVMapper to throw an exception
     **************************************************************************************************************************************/
    private class STUB_ExceptionAffiliationsSettingsVMapper extends AffiliationsSettingsVMapper {
        public override AffiliationsSettingsVModel getAffiliationsSettingsViewModel() {
            throw new TestException('Exception encountered!');
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from PrimaryAffiliationsSettingsVMapper to return a valid PrimaryAffiliationMappingVModel
     **************************************************************************************************************************************/
    private class STUB_PrimaryAffiliationsSettingsVMapper extends PrimaryAffiliationsSettingsVMapper {
        public override PrimaryAffiliationSettingsVModel getPrimaryAffiliationsSettingsVModel() {
            PrimaryAffiliationMappingVModel primaryAfflMappVModel = new PrimaryAffiliationMappingVModel(
                'Academic Program',
                'Primary_Academic_Program__c',
                'Primary Academic Program',
                'Academic_Program',
                'Academic Program',
                false
            );
            List<PrimaryAffiliationMappingVModel> primaryAfflSettingsVModel = new List<PrimaryAffiliationMappingVModel>();
            primaryAfflSettingsVModel.add(primaryAfflMappVModel);
            return new PrimaryAffiliationSettingsVModel(primaryAfflSettingsVModel);
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AffiliationsSettingsVMapper to throw an exception
     **************************************************************************************************************************************/
    private class STUB_ExceptionPrimaryAffiliationsSettingsVMapper extends PrimaryAffiliationsSettingsVMapper {
        public override PrimaryAffiliationSettingsVModel getPrimaryAffiliationsSettingsVModel() {
            throw new TestException('Exception encountered!');
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from PrimaryAffiliationsSettingsVMapper to return a valid ComboboxVModel
     **************************************************************************************************************************************/
    private class STUB_PrimaryAffiliationsSettingsVMapperComboBox extends PrimaryAffiliationsSettingsVMapper {
        public override ComboBoxVModel getAccountRecordTypeComboboxVModel(String recordTypeToCheck) {
            List<ComboboxValueVModel> comboboxValues = new List<ComboboxValueVModel>();
            comboboxValues.add(new ComboboxValueVModel('Academic Program', 'Academic_Program'));
            comboboxValues.add(new ComboboxValueVModel('Business Organization', 'Business_Organization'));
            return new ComboboxVModel('Business_Organization', comboboxValues);
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from PrimaryAffiliationsSettingsVMapper to throw an exception
     **************************************************************************************************************************************/
    private class STUB_ExceptionPrimaryAffiliationsSettingsVMapperComboBox extends PrimaryAffiliationsSettingsVMapper {
        public override ComboBoxVModel getAccountRecordTypeComboboxVModel(String recordTypeToCheck) {
            throw new TestException('Exception encountered!');
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from PrimaryAffiliationsSettingsVMapper to return a valid ComboboxVModel
     **************************************************************************************************************************************/
    private class STUB_PrimaryAffiliationsSettingsVMapperLookup extends PrimaryAffiliationsSettingsVMapper {
        public override ComboBoxVModel getContactAccountLookupFieldComboboxVModel(String recordTypeToCheck) {
            List<ComboboxValueVModel> comboboxValues = new List<ComboboxValueVModel>();
            comboboxValues.add(new ComboboxValueVModel('Primary Academic Program', 'Primary_Academic_Program__c'));
            comboboxValues.add(new ComboboxValueVModel('Primary Business Organization', 'Primary_Organization__c'));
            return new ComboboxVModel('Primary_Organization__c', comboboxValues);
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from PrimaryAffiliationsSettingsVMapper to throw an exception
     **************************************************************************************************************************************/
    private class STUB_ExceptionPrimaryAffiliationsSettingsVMapperLookup extends PrimaryAffiliationsSettingsVMapper {
        public override ComboBoxVModel getContactAccountLookupFieldComboboxVModel(String recordTypeToCheck) {
            throw new TestException('Exception encountered!');
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from UserPermissionService to return false
     **************************************************************************************************************************************/
    private class STUB_UserPermissionServiceFalse extends UserPermissionService {
        public override Boolean checkViewSetupForCurrentUser() {
            throw new NoAccessException();
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from RecordTypeMapper to return null
     **************************************************************************************************************************************/
    private class STUB_RecordTypeMapperNull extends RecordTypeMapper {
        public override RecordTypeModel getRecordTypeModelFromRecTypeDevName(String objectAPI, String recTypeDevName) {
            return null;
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AffiliationMappingsService to return a valid response
     **************************************************************************************************************************************/
    private class STUB_AffiliationMappingsService extends AffiliationMappingsService {
        public override String deleteAffiliationMapping(String mappingName) {
            return 'Test_Account_Record';
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AffiliationMappingsService to return a null response
     **************************************************************************************************************************************/
    private class STUB_AffiliationMappingsServiceNull extends AffiliationMappingsService {
        public override String deleteAffiliationMapping(String mappingName) {
            return null;
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AffiliationMappingsService to throw an error
     **************************************************************************************************************************************/
    private class STUB_ExceptionAffiliationMappingsService extends AffiliationMappingsService {
        public override String deleteAffiliationMapping(String mappingName) {
            throw new TestException('Exception encountered!');
        }
    }

    private class TestException extends Exception {
    }
}
