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
 * @description Test class for AutoEnrollmentMappingsVMapper class.
 */
@isTest
private with sharing class AutoEnrollmentMappingsVMapper_TEST {
    /**************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * AutoEnrollmentMappingsVMapper class when one does not already exist.
     **************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance = AutoEnrollmentMappingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            AutoEnrollmentMappingsVMapper.instance,
            autoEnrollmentMappingsVMapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            autoEnrollmentMappingsVMapperInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * AutoEnrollmentMappingsVMapper class when one already exists.
     **************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance1 = AutoEnrollmentMappingsVMapper.getInstance();
        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance2 = AutoEnrollmentMappingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            AutoEnrollmentMappingsVMapper.instance,
            autoEnrollmentMappingsVMapperInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            autoEnrollmentMappingsVMapperInstance1,
            autoEnrollmentMappingsVMapperInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            autoEnrollmentMappingsVMapperInstance1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify locateRecordTypeService() returns an instance of
     * the RecordTypeService class.
     ****************************************************************************************/
    @isTest
    private static void locateRecordTypeServiceValid() {
        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance = AutoEnrollmentMappingsVMapper.getInstance();

        Test.startTest();
        RecordTypeService recordTypeServiceInstance = autoEnrollmentMappingsVMapperInstance.locateRecordTypeService();
        Test.stopTest();

        System.assertEquals(
            RecordTypeService.getInstance(),
            recordTypeServiceInstance,
            'Should return instance of RecordTypeService class.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify locateAffiliationMappingsService() returns an instance of
     * the AffiliationMappingsService class.
     ****************************************************************************************/
    @isTest
    private static void locateAffiliationMappingsServiceValid() {
        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance = AutoEnrollmentMappingsVMapper.getInstance();

        Test.startTest();
        AffiliationMappingsService affiliationMappingsServiceInstance = autoEnrollmentMappingsVMapperInstance.locateAffiliationMappingsService();
        Test.stopTest();

        System.assertEquals(
            AffiliationMappingsService.getInstance(),
            affiliationMappingsServiceInstance,
            'Should return instance of AffiliationMappingsService class.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify locatePicklistEntryService() returns an instance of
     * the PicklistEntryService class.
     ****************************************************************************************/
    @isTest
    private static void locatePicklistEntryServiceValid() {
        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance = AutoEnrollmentMappingsVMapper.getInstance();

        Test.startTest();
        PicklistEntryService picklistEntryServiceInstance = autoEnrollmentMappingsVMapperInstance.locatePicklistEntryService();
        Test.stopTest();

        System.assertEquals(
            PicklistEntryService.getInstance(),
            picklistEntryServiceInstance,
            'Should return instance of PicklistEntryService class.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getAutoEnrollmentMappingVModel()
     * returns an instance of AutoEnrollmentMappingVModel with account record type
     * corresponding to the matching model properties when matching models exists.
     ****************************************************************************************/
    @isTest
    private static void getAutoEnrollmentMappingVModelValid() {
        RecordTypeService.instance = new STUB_RecordTypeServiceValid();

        AffiliationMappingsModel affiliationMappingsModel = new AffiliationMappingsModel(
            'Affliation Name',
            'Account Record Type',
            'Primary Affiliation Field',
            true,
            'autoProgramEnrollmentStatus',
            'autoProgramEnrollmentRole'
        );
        Map<String, RecordTypeModel> accountRecordTypeModelsByName = new Map<String, RecordTypeModel>{
            'Account_Record_Type' => new RecordTypeModel(
                '000000000000000009',
                'Account Record Type',
                'Account_Record_Type',
                true
            )
        };

        Map<String, RecordTypeModel> accountRecordTypeModelsByLabel = new Map<String, RecordTypeModel>{
            'Account Record Type' => new RecordTypeModel(
                '000000000000000009',
                'Account Record Type',
                'Account_Record_Type',
                true
            )
        };

        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance = AutoEnrollmentMappingsVMapper.getInstance();

        Test.startTest();
        AutoEnrollmentMappingVModel autoEnrollmentMappingVModel = autoEnrollmentMappingsVMapperInstance.getAutoEnrollmentMappingVModel(
            affiliationMappingsModel,
            accountRecordTypeModelsByName,
            accountRecordTypeModelsByLabel
        );
        Test.stopTest();

        System.assertEquals(
            'Affliation Name',
            autoEnrollmentMappingVModel.mappingName,
            'Mapping name should be Affliation Name.'
        );

        System.assertEquals(
            'Account_Record_Type',
            autoEnrollmentMappingVModel.accountRecordTypeName,
            'Account Record Type name should match developer name of Record Type model corresponding to record type specified for the affiliation mapping.'
        );

        System.assertEquals(
            'Account Record Type',
            autoEnrollmentMappingVModel.accountRecordTypeLabel,
            'Account Record Type label should match label of Record Type model corresponding to record type specified for the affiliation mapping.'
        );

        System.assertEquals(
            'autoProgramEnrollmentStatus',
            autoEnrollmentMappingVModel.autoProgramEnrollmentStatus,
            'Auto enrollment status should match the auto enrollment status of the affiliation mapping.'
        );

        System.assertEquals(
            'autoProgramEnrollmentRole',
            autoEnrollmentMappingVModel.autoProgramEnrollmentRole,
            'Auto enrollment role should match the auto enrollment role of the affiliation mapping.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getAutoEnrollmentMappingVModel()
     * returns an instance of AutoEnrollmentMappingVModel with valid values
     * when auto enrollment status and role are empty
     ****************************************************************************************/
    @isTest
    private static void getAutoEnrollmentMappingVModelEmpty() {
        RecordTypeService.instance = new STUB_RecordTypeServiceValid();

        AffiliationMappingsModel affiliationMappingsModel = new AffiliationMappingsModel(
            'Affliation Name',
            'Account Record Type',
            'Primary Affiliation Field',
            true,
            '',
            ''
        );
        Map<String, RecordTypeModel> accountRecordTypeModelsByName = new Map<String, RecordTypeModel>{
            'Account_Record_Type' => new RecordTypeModel(
                '000000000000000009',
                'Account Record Type',
                'Account_Record_Type',
                true
            )
        };

        Map<String, RecordTypeModel> accountRecordTypeModelsByLabel = new Map<String, RecordTypeModel>{
            'Account Record Type' => new RecordTypeModel(
                '000000000000000009',
                'Account Record Type',
                'Account_Record_Type',
                true
            )
        };

        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance = AutoEnrollmentMappingsVMapper.getInstance();

        Test.startTest();
        AutoEnrollmentMappingVModel autoEnrollmentMappingVModel = autoEnrollmentMappingsVMapperInstance.getAutoEnrollmentMappingVModel(
            affiliationMappingsModel,
            accountRecordTypeModelsByName,
            accountRecordTypeModelsByLabel
        );
        Test.stopTest();

        System.assertEquals(
            'Affliation Name',
            autoEnrollmentMappingVModel.mappingName,
            'Mapping name should be Affliation Name.'
        );

        System.assertEquals(
            'Account_Record_Type',
            autoEnrollmentMappingVModel.accountRecordTypeName,
            'Account Record Type name should match developer name of Record Type model corresponding to record type specified for the affiliation mapping.'
        );

        System.assertEquals(
            'Account Record Type',
            autoEnrollmentMappingVModel.accountRecordTypeLabel,
            'Account Record Type label should match label of Record Type model corresponding to record type specified for the affiliation mapping.'
        );

        System.assertEquals(
            '',
            autoEnrollmentMappingVModel.autoProgramEnrollmentStatus,
            'Auto enrollment status should be empty.'
        );

        System.assertEquals(
            '',
            autoEnrollmentMappingVModel.autoProgramEnrollmentRole,
            'Auto enrollment role should be empty.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getAutoEnrollmentMappingVModel()
     * returns a AutoEnrollmentMappingVModel with account record type and lookup field names
     * and labels corresponding to the properties specified for the affiliation mapping
     * when matching models do not exist.
     ****************************************************************************************/
    @isTest
    private static void getAutoEnrollmentMappingVModelInValidRecordType() {
        RecordTypeService.instance = new STUB_RecordTypeServiceInvalid();

        AffiliationMappingsModel affiliationMappingsModel = new AffiliationMappingsModel(
            'Affliation Name',
            'Invalid Account Record Type',
            'Invalid Primary Affiliation Field',
            false,
            'autoProgramEnrollmentStatus',
            'autoProgramEnrollmentRole'
        );

        Map<String, RecordTypeModel> accountRecordTypeModelsByName = new Map<String, RecordTypeModel>{
            'Account_Record_Type' => new RecordTypeModel(
                '000000000000000009',
                'Account Record Type',
                'Account_Record_Type',
                true
            )
        };

        Map<String, RecordTypeModel> accountRecordTypeModelsByLabel = new Map<String, RecordTypeModel>{
            'Account Record Type' => new RecordTypeModel(
                '000000000000000009',
                'Account Record Type',
                'Account_Record_Type',
                true
            )
        };

        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance = AutoEnrollmentMappingsVMapper.getInstance();

        Test.startTest();
        AutoEnrollmentMappingVModel autoEnrollmentMappingVModel = autoEnrollmentMappingsVMapperInstance.getAutoEnrollmentMappingVModel(
            affiliationMappingsModel,
            accountRecordTypeModelsByName,
            accountRecordTypeModelsByLabel
        );
        Test.stopTest();

        System.assertEquals(
            'Affliation Name',
            autoEnrollmentMappingVModel.mappingName,
            'Mapping name should be Affliation Name.'
        );

        System.assertEquals(
            'Invalid Account Record Type',
            autoEnrollmentMappingVModel.accountRecordTypeName,
            'Account Record Type name should match value specified for the affiliation mapping.'
        );

        System.assertEquals(
            'Invalid Account Record Type',
            autoEnrollmentMappingVModel.accountRecordTypeLabel,
            'Account Record Type label should match value specified for the affiliation mapping.'
        );

        System.assertEquals(
            'autoProgramEnrollmentStatus',
            autoEnrollmentMappingVModel.autoProgramEnrollmentStatus,
            'Auto enrollment status should match the auto enrollment status of the affiliation mapping.'
        );

        System.assertEquals(
            'autoProgramEnrollmentRole',
            autoEnrollmentMappingVModel.autoProgramEnrollmentRole,
            'Auto enrollment role should match the auto enrollment role of the affiliation mapping.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getAutoEnrollmentMappingsVModel()
     * returns a AutoEnrollmentMappingsVModel with proper values
     * when active auto enrollment exists.
     ****************************************************************************************/
    @isTest
    private static void getAutoEnrollmentMappingsVModelActiveAutoEnrollmentExists() {
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsService();
        RecordTypeService.instance = new STUB_RecordTypeService();

        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance = AutoEnrollmentMappingsVMapper.getInstance();

        Test.startTest();
        AutoEnrollmentMappingsVModel autoEnrollmentMappingsVModel = autoEnrollmentMappingsVMapperInstance.getAutoEnrollmentMappingsVModel();
        Test.stopTest();

        System.assertEquals(
            2,
            autoEnrollmentMappingsVModel.autoEnrollmentMappingVModels.size(),
            'Should return 2 autoEnrollmentMappingVModels.'
        );

        for (Integer i = 0; i < autoEnrollmentMappingsVModel.autoEnrollmentMappingVModels.size(); i++) {
            System.assertEquals(
                'Record_Type_' + (i + 1),
                autoEnrollmentMappingsVModel.autoEnrollmentMappingVModels[i].accountRecordTypeName,
                'Account record type name should match developer name of corresponding record type model.'
            );

            System.assertEquals(
                'Record Type ' + (i + 1),
                autoEnrollmentMappingsVModel.autoEnrollmentMappingVModels[i].accountRecordTypeLabel,
                'Account record type label should match label of corresponding record type model.'
            );

            System.assertEquals(
                'autoProgramEnrollmentStatus' + (i + 1),
                autoEnrollmentMappingsVModel.autoEnrollmentMappingVModels[i].autoProgramEnrollmentStatus,
                'Auto-Enrollment status should match.'
            );

            System.assertEquals(
                'autoProgramEnrollmentRole' + (i + 1),
                autoEnrollmentMappingsVModel.autoEnrollmentMappingVModels[i].autoProgramEnrollmentRole,
                'Auto-Enrollment role should match.'
            );
        }
    }

    /****************************************************************************************
     * @description Test method to verify getAutoEnrollmentMappingsVModel()
     * returns a AutoEnrollmentMappingsVModel with proper values
     * when active auto enrollment exists but empty.
     ****************************************************************************************/
    @isTest
    private static void getAutoEnrollmentMappingsVModelActiveAutoEnrollmentEmpty() {
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsServiceEmptyAutoEnrollment();
        RecordTypeService.instance = new STUB_RecordTypeService();

        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance = AutoEnrollmentMappingsVMapper.getInstance();

        Test.startTest();
        AutoEnrollmentMappingsVModel autoEnrollmentMappingsVModel = autoEnrollmentMappingsVMapperInstance.getAutoEnrollmentMappingsVModel();
        Test.stopTest();

        System.assertEquals(
            2,
            autoEnrollmentMappingsVModel.autoEnrollmentMappingVModels.size(),
            'Should return 2 autoEnrollmentMappingVModels.'
        );

        for (Integer i = 0; i < autoEnrollmentMappingsVModel.autoEnrollmentMappingVModels.size(); i++) {
            System.assertEquals(
                'Record_Type_' + (i + 1),
                autoEnrollmentMappingsVModel.autoEnrollmentMappingVModels[i].accountRecordTypeName,
                'Account record type name should match developer name of corresponding record type model.'
            );

            System.assertEquals(
                'Record Type ' + (i + 1),
                autoEnrollmentMappingsVModel.autoEnrollmentMappingVModels[i].accountRecordTypeLabel,
                'Account record type label should match label of corresponding record type model.'
            );

            System.assertEquals(
                '',
                autoEnrollmentMappingsVModel.autoEnrollmentMappingVModels[i].autoProgramEnrollmentStatus,
                'Auto-Enrollment status should be empty.'
            );

            System.assertEquals(
                '',
                autoEnrollmentMappingsVModel.autoEnrollmentMappingVModels[i].autoProgramEnrollmentRole,
                'Auto-Enrollment role should be empty.'
            );
        }
    }

    /****************************************************************************************
     * @description Test method to verify getAutoEnrollmentMappingsVModel()
     * returns a AutoEnrollmentMappingsVModel with proper values
     * when no active auto enrollment exists.
     ****************************************************************************************/
    @isTest
    private static void getAutoEnrollmentMappingsVModelActiveAutoEnrollmentNotExists() {
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsServiceInactiveAutoEnrollment();
        RecordTypeService.instance = new STUB_RecordTypeService();

        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance = AutoEnrollmentMappingsVMapper.getInstance();

        Test.startTest();
        AutoEnrollmentMappingsVModel autoEnrollmentMappingsVModel = autoEnrollmentMappingsVMapperInstance.getAutoEnrollmentMappingsVModel();
        Test.stopTest();

        System.assertEquals(
            0,
            autoEnrollmentMappingsVModel.autoEnrollmentMappingVModels.size(),
            'Should return 0 autoEnrollmentMappingVModels.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getAccountRecordTypeComboboxVModel()
     * returns a ComboBoxVModel with proper values
     * when no record type except the current one is mapped to active auto enrollment.
     ****************************************************************************************/
    @isTest
    private static void getAccountRecordTypeComboboxVModelUnmapped() {
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsServiceMixAutoEnrollment();
        RecordTypeService.instance = new STUB_RecordTypeServiceAccountRecordTypeCombobox(false);

        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance = AutoEnrollmentMappingsVMapper.getInstance();

        Test.startTest();
        ComboBoxVModel accountRecordTypeComboboxVModel = autoEnrollmentMappingsVMapperInstance.getAccountRecordTypeComboboxVModel(
            'Record_Type_1'
        );
        Test.stopTest();

        System.assertEquals(
            'Record_Type_1',
            accountRecordTypeComboboxVModel.value,
            'The size of comboboxVModelOptionsForActiveAccountRecordTypes should be 2'
        );
        System.assertEquals(
            2,
            accountRecordTypeComboboxVModel.options.size(),
            'The size of accountRecordTypeComboboxVModel.options should be 2'
        );
        System.assertEquals(
            'Record Type 1',
            accountRecordTypeComboboxVModel.options[0].label,
            'The label of accountRecordTypeComboboxVModel.options[0] should be Record Type 1'
        );
        System.assertEquals(
            'Record_Type_1',
            accountRecordTypeComboboxVModel.options[0].value,
            'The value of accountRecordTypeComboboxVModel.options[0] should be Record_Type_1'
        );
        System.assertEquals(
            'Record Type 2',
            accountRecordTypeComboboxVModel.options[1].label,
            'The label of accountRecordTypeComboboxVModel.options[1] should be Record Type 2'
        );
        System.assertEquals(
            'Record_Type_2',
            accountRecordTypeComboboxVModel.options[1].value,
            'The value of accountRecordTypeComboboxVModel.options[1] should be Record_Type_2'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getAccountRecordTypeComboboxVModel()
     * returns a ComboBoxVModel with proper values
     * when all record types are mapped to active auto enrollment.
     ****************************************************************************************/
    @isTest
    private static void getAccountRecordTypeComboboxVModelMapped() {
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsService();
        RecordTypeService.instance = new STUB_RecordTypeServiceAccountRecordTypeCombobox(false);

        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance = AutoEnrollmentMappingsVMapper.getInstance();

        Test.startTest();
        ComboBoxVModel accountRecordTypeComboboxVModel = autoEnrollmentMappingsVMapperInstance.getAccountRecordTypeComboboxVModel(
            'Record_Type_1'
        );
        Test.stopTest();

        System.assertEquals(
            'Record_Type_1',
            accountRecordTypeComboboxVModel.value,
            'The value of comboboxVModelOptionsForActiveAccountRecordTypes should be Record_Type_1'
        );
        System.assertEquals(
            1,
            accountRecordTypeComboboxVModel.options.size(),
            'The size of accountRecordTypeComboboxVModel.options should be 1'
        );
        System.assertEquals(
            'Record Type 1',
            accountRecordTypeComboboxVModel.options[0].label,
            'The label of accountRecordTypeComboboxVModel.options[0] should be Record Type 1'
        );
        System.assertEquals(
            'Record_Type_1',
            accountRecordTypeComboboxVModel.options[0].value,
            'The value of accountRecordTypeComboboxVModel.options[0] should be Record_Type_1'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getAccountRecordTypeComboboxVModel() returns a
     * ComboBoxVModel with proper values when the record type does not exist
     ****************************************************************************************/
    @isTest
    private static void getAccountRecordTypeComboboxVModelMappedNull() {
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsService();
        RecordTypeService.instance = new STUB_RecordTypeServiceAccountRecordTypeCombobox(true);

        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance = AutoEnrollmentMappingsVMapper.getInstance();

        Test.startTest();
        ComboBoxVModel accountRecordTypeComboboxVModel = autoEnrollmentMappingsVMapperInstance.getAccountRecordTypeComboboxVModel(
            'Invalid'
        );
        Test.stopTest();

        System.assertEquals(
            'Invalid',
            accountRecordTypeComboboxVModel.value,
            'The value of comboboxVModelOptionsForActiveAccountRecordTypes should be Invalid'
        );
        System.assertEquals(
            1,
            accountRecordTypeComboboxVModel.options.size(),
            'The size of accountRecordTypeComboboxVModel.options should be 1'
        );
        System.assertEquals(
            'Invalid',
            accountRecordTypeComboboxVModel.options[0].label,
            'The label of accountRecordTypeComboboxVModel.options[0] should be Invalid'
        );
        System.assertEquals(
            'Invalid',
            accountRecordTypeComboboxVModel.options[0].value,
            'The value of accountRecordTypeComboboxVModel.options[0] should be Invalid'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getComboboxVModelOptionsForActiveAccountRecordTypes()
     * returns a list of ComboboxValueVModel with proper values
     * when no record type is mapped to active auto enrollment.
     ****************************************************************************************/
    @isTest
    private static void getComboboxVModelOptionsForActiveAccountRecordTypesAllUnmapped() {
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsServiceInactiveAutoEnrollment();
        List<RecordTypeModel> activeAccountRecordTypeModelsList = new List<RecordTypeModel>{
            new RecordTypeModel('000000000000000001', 'Record Type 1', 'Record_Type_1', true),
            new RecordTypeModel('000000000000000002', 'Record Type 2', 'Record_Type_2', true)
        };

        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance = AutoEnrollmentMappingsVMapper.getInstance();

        Test.startTest();
        List<ComboboxValueVModel> comboboxVModelOptionsForActiveAccountRecordTypes = autoEnrollmentMappingsVMapperInstance.getComboboxVModelOptionsForActiveAccountRecordTypes(
            activeAccountRecordTypeModelsList,
            'Record_Type_1'
        );
        Test.stopTest();

        System.assertEquals(
            2,
            comboboxVModelOptionsForActiveAccountRecordTypes.size(),
            'The size of comboboxVModelOptionsForActiveAccountRecordTypes should be 2'
        );
        System.assertEquals(
            'Record Type 1',
            comboboxVModelOptionsForActiveAccountRecordTypes[0].label,
            'The label of comboboxVModelOptionsForActiveAccountRecordTypes[0] should be Record Type 1'
        );
        System.assertEquals(
            'Record_Type_1',
            comboboxVModelOptionsForActiveAccountRecordTypes[0].value,
            'The value of comboboxVModelOptionsForActiveAccountRecordTypes[0] should be Record_Type_1'
        );
        System.assertEquals(
            'Record Type 2',
            comboboxVModelOptionsForActiveAccountRecordTypes[1].label,
            'The label of comboboxVModelOptionsForActiveAccountRecordTypes[1] should be Record Type 2'
        );
        System.assertEquals(
            'Record_Type_2',
            comboboxVModelOptionsForActiveAccountRecordTypes[1].value,
            'The value of comboboxVModelOptionsForActiveAccountRecordTypes[1] should be Record_Type_2'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getComboboxVModelOptionsForActiveAccountRecordTypes()
     * returns a empty list of ComboboxValueVModel with proper values
     * when all record types are mapped to active auto enrollment.
     ****************************************************************************************/
    @isTest
    private static void getComboboxVModelOptionsForActiveAccountRecordTypesAllMapped() {
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsService();
        List<RecordTypeModel> activeAccountRecordTypeModelsList = new List<RecordTypeModel>{
            new RecordTypeModel('000000000000000001', 'Record Type 1', 'Record_Type_1', true),
            new RecordTypeModel('000000000000000002', 'Record Type 2', 'Record_Type_2', true)
        };

        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance = AutoEnrollmentMappingsVMapper.getInstance();

        Test.startTest();
        List<ComboboxValueVModel> comboboxVModelOptionsForActiveAccountRecordTypes = autoEnrollmentMappingsVMapperInstance.getComboboxVModelOptionsForActiveAccountRecordTypes(
            activeAccountRecordTypeModelsList,
            'Record_Type_1'
        );
        Test.stopTest();

        System.assertEquals(
            1,
            comboboxVModelOptionsForActiveAccountRecordTypes.size(),
            'The size of comboboxVModelOptionsForActiveAccountRecordTypes should be 0'
        );
        System.assertEquals(
            'Record Type 1',
            comboboxVModelOptionsForActiveAccountRecordTypes[0].label,
            'The label of comboboxVModelOptionsForActiveAccountRecordTypes[0] should be Record Type 1'
        );
        System.assertEquals(
            'Record_Type_1',
            comboboxVModelOptionsForActiveAccountRecordTypes[0].value,
            'The value of comboboxVModelOptionsForActiveAccountRecordTypes[0] should be Record_Type_1'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getAutoEnrollmentMappingStatusComboboxVModel()
     * returns a ComboBoxVModel with proper values of picklist entries.
     ****************************************************************************************/
    @isTest
    private static void getAutoEnrollmentMappingStatusComboboxVModelValid() {
        PicklistEntryService.instance = new STUB_StatusPicklistEntryServiceValid();

        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance = AutoEnrollmentMappingsVMapper.getInstance();

        Test.startTest();
        ComboBoxVModel autoEnrollmentMappingStatusCombobox = autoEnrollmentMappingsVMapperInstance.getAutoEnrollmentMappingStatusComboboxVModel(
            'Status'
        );
        Test.stopTest();

        System.assertEquals(
            'Status',
            autoEnrollmentMappingStatusCombobox.value,
            'The value of autoEnrollmentMappingStatusCombobox should be Status'
        );
        System.assertEquals(
            'Test Status',
            autoEnrollmentMappingStatusCombobox.options[0].label,
            'The label of autoEnrollmentMappingStatusCombobox.options[0] should be Test Status'
        );
        System.assertEquals(
            'Test_Status',
            autoEnrollmentMappingStatusCombobox.options[0].value,
            'The value of autoEnrollmentMappingStatusCombobox.options[0] should be Test_Status'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getAutoEnrollmentMappingStatusComboboxVModel()
     * returns a ComboBoxVModel with no options when no valid picklist value entry is found.
     ****************************************************************************************/
    @isTest
    private static void getAutoEnrollmentMappingStatusComboboxVModelInvalid() {
        PicklistEntryService.instance = new STUB_StatusPicklistEntryServiceInvalid();

        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance = AutoEnrollmentMappingsVMapper.getInstance();

        Test.startTest();
        ComboBoxVModel autoEnrollmentMappingStatusCombobox = autoEnrollmentMappingsVMapperInstance.getAutoEnrollmentMappingStatusComboboxVModel(
            'Status'
        );
        Test.stopTest();

        System.assertEquals(
            'Status',
            autoEnrollmentMappingStatusCombobox.value,
            'The value of autoEnrollmentMappingStatusCombobox should be Status'
        );
        System.assertEquals(
            0,
            autoEnrollmentMappingStatusCombobox.options.size(),
            'The size of autoEnrollmentMappingStatusCombobox.options should be 0'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getAutoEnrollmentMappingRoleComboboxVModel()
     * returns a ComboBoxVModel with proper values of picklist entries.
     ****************************************************************************************/
    @isTest
    private static void getAutoEnrollmentMappingRoleComboboxVModelValid() {
        PicklistEntryService.instance = new STUB_RolePicklistEntryServiceValid();

        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance = AutoEnrollmentMappingsVMapper.getInstance();

        Test.startTest();
        ComboBoxVModel autoEnrollmentMappingRoleCombobox = autoEnrollmentMappingsVMapperInstance.getAutoEnrollmentMappingRoleComboboxVModel(
            'Role'
        );
        Test.stopTest();

        System.assertEquals(
            'Role',
            autoEnrollmentMappingRoleCombobox.value,
            'The value of autoEnrollmentMappingRoleCombobox should be Role'
        );
        System.assertEquals(
            'Test Role',
            autoEnrollmentMappingRoleCombobox.options[0].label,
            'The label of autoEnrollmentMappingRoleCombobox.options[0] should be Test Role'
        );
        System.assertEquals(
            'Test_Role',
            autoEnrollmentMappingRoleCombobox.options[0].value,
            'The value of autoEnrollmentMappingRoleCombobox.options[0] should be Test_Role'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getAutoEnrollmentMappingRoleComboboxVModel()
     * returns a ComboBoxVModel with no options when no valid picklist value entry is found.
     ****************************************************************************************/
    @isTest
    private static void getAutoEnrollmentMappingRoleComboboxVModelInvalid() {
        PicklistEntryService.instance = new STUB_RolePicklistEntryServiceInvalid();

        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance = AutoEnrollmentMappingsVMapper.getInstance();

        Test.startTest();
        ComboBoxVModel autoEnrollmentMappingRoleCombobox = autoEnrollmentMappingsVMapperInstance.getAutoEnrollmentMappingRoleComboboxVModel(
            'Role'
        );
        Test.stopTest();

        System.assertEquals(
            'Role',
            autoEnrollmentMappingRoleCombobox.value,
            'The value of autoEnrollmentMappingRoleCombobox should be Role'
        );
        System.assertEquals(
            0,
            autoEnrollmentMappingRoleCombobox.options.size(),
            'The size of autoEnrollmentMappingRoleCombobox.options should be 0'
        );
    }

    /***********************************************************************************************************************************
     ****************************************************** STUBS ***********************************************************************
     ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate valid responses from AffiliationMappingsService
     **************************************************************************************************************************************/
    private class STUB_AffiliationMappingsService extends AffiliationMappingsService {
        public override List<AffiliationMappingsModel> getAffiliationMappingsModels() {
            return new List<AffiliationMappingsModel>{
                new AffiliationMappingsModel(
                    'Affiliation Name 1',
                    'Record_Type_1',
                    'Contact_Account_Lookup_1',
                    true,
                    'autoProgramEnrollmentStatus1',
                    'autoProgramEnrollmentRole1'
                ),
                new AffiliationMappingsModel(
                    'Affiliation Name 2',
                    'Record_Type_2',
                    'Contact_Account_Lookup_2',
                    true,
                    'autoProgramEnrollmentStatus2',
                    'autoProgramEnrollmentRole2'
                )
            };
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate valid responses from AffiliationMappingsService with inactive auto enrollment
     **************************************************************************************************************************************/
    private class STUB_AffiliationMappingsServiceInactiveAutoEnrollment extends AffiliationMappingsService {
        public override List<AffiliationMappingsModel> getAffiliationMappingsModels() {
            return new List<AffiliationMappingsModel>{
                new AffiliationMappingsModel(
                    'Affiliation Name 1',
                    'Record_Type_1',
                    'Contact_Account_Lookup_1',
                    false,
                    'autoProgramEnrollmentStatus1',
                    'autoProgramEnrollmentRole1'
                ),
                new AffiliationMappingsModel(
                    'Affiliation Name 2',
                    'Record_Type_2',
                    'Contact_Account_Lookup_2',
                    false,
                    'autoProgramEnrollmentStatus2',
                    'autoProgramEnrollmentRole2'
                )
            };
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate valid responses from AffiliationMappingsService with inactive auto enrollment
     **************************************************************************************************************************************/
    private class STUB_AffiliationMappingsServiceMixAutoEnrollment extends AffiliationMappingsService {
        public override List<AffiliationMappingsModel> getAffiliationMappingsModels() {
            return new List<AffiliationMappingsModel>{
                new AffiliationMappingsModel(
                    'Affiliation Name 1',
                    'Record_Type_1',
                    'Contact_Account_Lookup_1',
                    true,
                    'autoProgramEnrollmentStatus1',
                    'autoProgramEnrollmentRole1'
                ),
                new AffiliationMappingsModel(
                    'Affiliation Name 2',
                    'Record_Type_2',
                    'Contact_Account_Lookup_2',
                    false,
                    'autoProgramEnrollmentStatus2',
                    'autoProgramEnrollmentRole2'
                )
            };
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate valid responses from AffiliationMappingsService with empty auto enrollment
     **************************************************************************************************************************************/
    private class STUB_AffiliationMappingsServiceEmptyAutoEnrollment extends AffiliationMappingsService {
        public override List<AffiliationMappingsModel> getAffiliationMappingsModels() {
            return new List<AffiliationMappingsModel>{
                new AffiliationMappingsModel(
                    'Affiliation Name 1',
                    'Record_Type_1',
                    'Contact Account Lookup Label 1',
                    true,
                    '',
                    ''
                ),
                new AffiliationMappingsModel(
                    'Affiliation Name 2',
                    'Record_Type_2',
                    'Contact Account Lookup Label 2',
                    true,
                    '',
                    ''
                )
            };
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate valid responses from RecordTypeService
     **************************************************************************************************************************************/
    private class STUB_RecordTypeService extends RecordTypeService {
        public override Map<Id, RecordTypeModel> getModelByIdMapForSObjectType(Schema.SObjectType sObjectType) {
            return new Map<Id, RecordTypeModel>{
                '000000000000000001' => new RecordTypeModel(
                    '000000000000000001',
                    'Record Type 1',
                    'Record_Type_1',
                    true
                ),
                '000000000000000002' => new RecordTypeModel(
                    '000000000000000002',
                    'Record Type 2',
                    'Record_Type_2',
                    true
                ),
                '000000000000000003' => new RecordTypeModel(
                    '000000000000000003',
                    'Record Type 3',
                    'Record_Type_3',
                    false
                )
            };
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate valid responses from RecordTypeService
     **************************************************************************************************************************************/
    private class STUB_RecordTypeServiceValid extends RecordTypeService {
        public override RecordTypeModel getRecordTypeModelFromNameAndLabelMaps(
            String recordTypeNameOrLabel,
            Map<String, RecordTypeModel> recordTypeModelByName,
            Map<String, RecordTypeModel> recordTypeModelByLabel
        ) {
            return new RecordTypeModel('000000000000000009', 'Account Record Type', 'Account_Record_Type', true);
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate invalid responses from RecordTypeService
     **************************************************************************************************************************************/
    private class STUB_RecordTypeServiceInvalid extends RecordTypeService {
        public override RecordTypeModel getRecordTypeModelFromNameAndLabelMaps(
            String recordTypeNameOrLabel,
            Map<String, RecordTypeModel> recordTypeModelByName,
            Map<String, RecordTypeModel> recordTypeModelByLabel
        ) {
            return null;
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate valid responses for account record type combobox
     **************************************************************************************************************************************/
    private class STUB_RecordTypeServiceAccountRecordTypeCombobox extends RecordTypeService {
        private Boolean neverFindRecordType = false;

        public STUB_RecordTypeServiceAccountRecordTypeCombobox(Boolean neverFindRecordType) {
            this.neverFindRecordType = neverFindRecordType;
        }

        public override Map<Id, RecordTypeModel> getModelByIdMapForSObjectType(Schema.SObjectType sObjectType) {
            return new Map<Id, RecordTypeModel>{
                '000000000000000001' => new RecordTypeModel(
                    '000000000000000001',
                    'Record Type 1',
                    'Record_Type_1',
                    true
                ),
                '000000000000000002' => new RecordTypeModel(
                    '000000000000000002',
                    'Record Type 2',
                    'Record_Type_2',
                    true
                )
            };
        }

        public override RecordTypeModel getRecordTypeModelFromNameAndLabelMaps(
            String recordTypeNameOrLabel,
            Map<String, RecordTypeModel> recordTypeModelByName,
            Map<String, RecordTypeModel> recordTypeModelByLabel
        ) {
            if (this.neverFindRecordType) {
                return null;
            }

            return new RecordTypeModel('000000000000000001', 'Record Type 1', 'Record_Type_1', true);
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate valid responses from PicklistEntryService
     **************************************************************************************************************************************/
    private class STUB_StatusPicklistEntryServiceValid extends PicklistEntryService {
        public override Map<String, PicklistEntryModel> getModelsByNameForSObjectField(
            SObjectType sObjectTypeName,
            SObjectField SObjectFieldName
        ) {
            return new Map<String, PicklistEntryModel>{
                'Status' => new PicklistEntryModel('Test_Status', 'Test Status', true)
            };
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate invalid responses from PicklistEntryService
     **************************************************************************************************************************************/
    private class STUB_StatusPicklistEntryServiceInvalid extends PicklistEntryService {
        public override Map<String, PicklistEntryModel> getModelsByNameForSObjectField(
            SObjectType sObjectTypeName,
            SObjectField SObjectFieldName
        ) {
            return new Map<String, PicklistEntryModel>{
                'Status' => new PicklistEntryModel('Test_Status', 'Test Status', false)
            };
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate valid responses from PicklistEntryService
     **************************************************************************************************************************************/
    private class STUB_RolePicklistEntryServiceValid extends PicklistEntryService {
        public override Map<String, PicklistEntryModel> getModelsByNameForSObjectField(
            SObjectType sObjectTypeName,
            SObjectField SObjectFieldName
        ) {
            return new Map<String, PicklistEntryModel>{
                'Role' => new PicklistEntryModel('Test_Role', 'Test Role', true)
            };
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate invalid responses from PicklistEntryService
     **************************************************************************************************************************************/
    private class STUB_RolePicklistEntryServiceInvalid extends PicklistEntryService {
        public override Map<String, PicklistEntryModel> getModelsByNameForSObjectField(
            SObjectType sObjectTypeName,
            SObjectField SObjectFieldName
        ) {
            return new Map<String, PicklistEntryModel>{
                'Role' => new PicklistEntryModel('Test_Role', 'Test Role', false)
            };
        }
    }
}
