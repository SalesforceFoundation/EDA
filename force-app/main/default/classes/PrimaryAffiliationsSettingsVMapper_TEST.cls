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
 * @description Test class for PrimaryAffiliationsSettingsVMapper class
 */
@isTest
private with sharing class PrimaryAffiliationsSettingsVMapper_TEST {
    private static Integer loopCounter = 5;

    /**************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * PrimaryAffiliationsSettingsVMapper class when one does not already exist.
     **************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = PrimaryAffiliationsSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            PrimaryAffiliationsSettingsVMapper.instance,
            primaryAffiliationsSettingsVMapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            primaryAffiliationsSettingsVMapperInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * PrimaryAffiliationsSettingsVMapper class when one already exists.
     **************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance1 = PrimaryAffiliationsSettingsVMapper.getInstance();
        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance2 = PrimaryAffiliationsSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            PrimaryAffiliationsSettingsVMapper.instance,
            primaryAffiliationsSettingsVMapperInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            primaryAffiliationsSettingsVMapperInstance1,
            primaryAffiliationsSettingsVMapperInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            primaryAffiliationsSettingsVMapperInstance1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify locateLookupFieldService() returns an instance of
     * the LookupFieldService class.
     ****************************************************************************************/
    @isTest
    private static void locateLookupFieldServiceValid() {
        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = PrimaryAffiliationsSettingsVMapper.getInstance();

        Test.startTest();
        LookupFieldService lookupFieldServiceInstance = primaryAffiliationsSettingsVMapperInstance.locateLookupFieldService();
        Test.stopTest();

        System.assertEquals(
            LookupFieldService.getInstance(),
            lookupFieldServiceInstance,
            'Should return instance of LookupFieldService class.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify locateRecordTypeService() returns an instance of
     * the RecordTypeService class.
     ****************************************************************************************/
    @isTest
    private static void locateRecordTypeServiceValid() {
        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = PrimaryAffiliationsSettingsVMapper.getInstance();

        Test.startTest();
        RecordTypeService recordTypeServiceInstance = primaryAffiliationsSettingsVMapperInstance.locateRecordTypeService();
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
        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = PrimaryAffiliationsSettingsVMapper.getInstance();

        Test.startTest();
        AffiliationMappingsService affiliationMappingsServiceInstance = primaryAffiliationsSettingsVMapperInstance.locateAffiliationMappingsService();
        Test.stopTest();

        System.assertEquals(
            AffiliationMappingsService.getInstance(),
            affiliationMappingsServiceInstance,
            'Should return instance of AffiliationMappingsService class.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getComboboxVModelOptionsForContactAccountLookupFields()
     * returns a list of ComboboxValueVModels representing the Account lookup fields on the
     * Contact object.
     ****************************************************************************************/
    @isTest
    private static void getComboboxVModelOptionsForContactAccountLookupFieldsValid() {
        List<LookupFieldModel> contactLookupFieldModelList = new List<LookupFieldModel>();

        for (Integer i = 0; i < loopCounter; i++) {
            contactLookupFieldModelList.add(new LookupFieldModel('Lookup Field Name ' + i, 'Lookup Field Label ' + i));
        }

        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = PrimaryAffiliationsSettingsVMapper.getInstance();

        Test.startTest();
        List<ComboboxValueVModel> lookupFieldComboboxValueVModelsList = primaryAffiliationsSettingsVMapperInstance.getComboboxVModelOptionsForContactAccountLookupFields(
            contactLookupFieldModelList
        );
        Test.stopTest();

        System.assertEquals(
            loopCounter,
            lookupFieldComboboxValueVModelsList.size(),
            'Should return ' +
            loopCounter +
            ' ComboboxValueVModels.'
        );

        for (Integer i = 0; i < loopCounter; i++) {
            System.assertEquals(
                'Lookup Field Name ' + i,
                lookupFieldComboboxValueVModelsList[i].value,
                'ComoboboxValueVModel value should match lookup field model name.'
            );

            System.assertEquals(
                'Lookup Field Label ' + i,
                lookupFieldComboboxValueVModelsList[i].label,
                'ComoboboxValueVModel label should match lookup field model label.'
            );
        }
    }

    /****************************************************************************************
     * @description Test method to verify getContactAccountLookupFieldComboboxVModel()
     * returns a ComboboxVModel representing the selected Account lookup field and a list of
     * options all account lookup fields on contact.
     ****************************************************************************************/
    @isTest
    private static void getContactAccountLookupFieldComboboxVModelValid() {
        LookupFieldService.instance = new STUB_LookupFieldService();

        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = PrimaryAffiliationsSettingsVMapper.getInstance();

        Test.startTest();
        ComboBoxVModel accountLookupFieldComboBoxVModel = primaryAffiliationsSettingsVMapperInstance.getContactAccountLookupFieldComboboxVModel(
            'Contact Account Lookup Name 1'
        );
        Test.stopTest();

        System.assertEquals(
            'Contact Account Lookup Name 1',
            accountLookupFieldComboBoxVModel.value,
            'Selected value in combobox view model should match contact field to check.'
        );

        System.assertEquals(
            2,
            accountLookupFieldComboBoxVModel.options.size(),
            'Combobox options should include only existing account lookup fields.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getContactAccountLookupFieldComboboxVModel()
     * returns a ComboboxVModel representing a list of options all account lookup fields on contact.
     ****************************************************************************************/
    @isTest
    private static void getContactAccountLookupFieldComboboxVModelEmpty() {
        LookupFieldService.instance = new STUB_LookupFieldService();

        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = PrimaryAffiliationsSettingsVMapper.getInstance();

        Test.startTest();
        ComboBoxVModel accountLookupFieldComboBoxVModel = primaryAffiliationsSettingsVMapperInstance.getContactAccountLookupFieldComboboxVModel(
            null
        );
        Test.stopTest();

        System.assertEquals(
            null,
            accountLookupFieldComboBoxVModel.value,
            'Selected value in combobox view model should be null.'
        );

        System.assertEquals(
            2,
            accountLookupFieldComboBoxVModel.options.size(),
            'Combobox options should include only existing account lookup fields.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getContactAccountLookupFieldComboboxVModel()
     * returns a ComboboxVModel representing the selected Account lookup field and a list of
     * options that includes the selected lookup field when it is not currently a specified field.
     ****************************************************************************************/
    @isTest
    private static void getContactAccountLookupFieldComboboxVModelInValid() {
        LookupFieldService.instance = new STUB_LookupFieldService();

        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = PrimaryAffiliationsSettingsVMapper.getInstance();

        Test.startTest();
        ComboBoxVModel accountLookupFieldComboBoxVModel = primaryAffiliationsSettingsVMapperInstance.getContactAccountLookupFieldComboboxVModel(
            'Invalid Field Name'
        );
        Test.stopTest();

        System.assertEquals(
            'Invalid Field Name',
            accountLookupFieldComboBoxVModel.value,
            'Selected value in combobox view model should match contact field to check.'
        );

        System.assertEquals(
            3,
            accountLookupFieldComboBoxVModel.options.size(),
            'Combobox options should include invalid field name as an option in addition to existing account lookup fields.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getComboboxVModelOptionsForActiveAccountRecordTypes()
     * returns a List<ComboboxValueVModel> representing the record type models provided as
     * arguments.
     ****************************************************************************************/
    @isTest
    private static void getComboboxVModelOptionsForActiveAccountRecordTypesValid() {
        List<RecordTypeModel> activeAccountRecordTypeModelsList = new List<RecordTypeModel>();

        for (Integer i = 0; i < loopCounter; i++) {
            activeAccountRecordTypeModelsList.add(
                new RecordTypeModel('00000000000000000' + i, 'AcctRT' + i, 'Acct_RT_' + i, true)
            );
        }

        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = PrimaryAffiliationsSettingsVMapper.getInstance();

        Test.startTest();
        List<ComboboxValueVModel> activeRecordTypeComboboxValueVModelsList = primaryAffiliationsSettingsVMapperInstance.getComboboxVModelOptionsForActiveAccountRecordTypes(
            activeAccountRecordTypeModelsList
        );
        Test.stopTest();

        System.assertEquals(
            loopCounter,
            activeRecordTypeComboboxValueVModelsList.size(),
            'Should return ' +
            loopCounter +
            ' comboboxValueVModels corresponding to active record type models.'
        );

        for (Integer i = 0; i < loopCounter; i++) {
            System.assertEquals(
                'AcctRT' + i,
                activeRecordTypeComboboxValueVModelsList[i].label,
                'ComboboxVModel label should correspond to record type model name.'
            );

            System.assertEquals(
                'Acct_RT_' + i,
                activeRecordTypeComboboxValueVModelsList[i].value,
                'ComboboxVModel label should correspond to record type model developer name.'
            );
        }
    }

    /****************************************************************************************
     * @description Test method to verify getAccountRecordTypeComboboxVModel()
     * returns a ComboboxVModel representing a selected account record type that is also an
     * existing value.
     ****************************************************************************************/
    @isTest
    private static void getAccountRecordTypeComboboxVModelValid() {
        RecordTypeService.instance = new STUB_RecordTypeService();

        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = PrimaryAffiliationsSettingsVMapper.getInstance();

        Test.startTest();
        ComboBoxVModel accountRTComboboxVModel = primaryAffiliationsSettingsVMapperInstance.getAccountRecordTypeComboboxVModel(
            'Record_Type_2'
        );
        Test.stopTest();

        System.assertEquals(
            'Record_Type_2',
            accountRTComboboxVModel.value,
            'Selected account record type should match record type to check.'
        );
        System.assertEquals(
            3,
            accountRTComboboxVModel.options.size(),
            'Account record type options list should consist only of existing values.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getAccountRecordTypeComboboxVModel()
     * returns a ComboboxVModel representing a list of all active Account Record Types
     ****************************************************************************************/
    @isTest
    private static void getAccountRecordTypeComboboxVModelEmpty() {
        RecordTypeService.instance = new STUB_RecordTypeService();

        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = PrimaryAffiliationsSettingsVMapper.getInstance();

        Test.startTest();
        ComboBoxVModel accountRTComboboxVModel = primaryAffiliationsSettingsVMapperInstance.getAccountRecordTypeComboboxVModel(
            null
        );
        Test.stopTest();

        System.assertEquals(null, accountRTComboboxVModel.value, 'Selected account record type should be null.');
        System.assertEquals(
            3,
            accountRTComboboxVModel.options.size(),
            'Account record type options list should consist only of existing values.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getAccountRecordTypeComboboxVModel()
     * returns a ComboboxVModel representing a selected account record type that is not an
     * existing value.
     ****************************************************************************************/
    @isTest
    private static void getAccountRecordTypeComboboxVModelInValid() {
        RecordTypeService.instance = new STUB_RecordTypeService();

        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = PrimaryAffiliationsSettingsVMapper.getInstance();

        Test.startTest();
        ComboBoxVModel accountRTComboboxVModel = primaryAffiliationsSettingsVMapperInstance.getAccountRecordTypeComboboxVModel(
            'New Record Type'
        );
        Test.stopTest();

        System.assertEquals(
            'New Record Type',
            accountRTComboboxVModel.value,
            'Selected account record type should match record type to check.'
        );
        System.assertEquals(
            4,
            accountRTComboboxVModel.options.size(),
            'Account record type options list should include new value with existing values.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getPrimaryAffiliationsMappingVModel()
     * returns a PrimaryAffiliationMappingVModel with account record type and lookup field names
     * and labels corresponding to the matching model properties when matching models exists.
     ****************************************************************************************/
    @isTest
    private static void getPrimaryAffiliationsMappingVModelValid() {
        RecordTypeService.instance = new STUB_RecordTypeServiceValid();
        LookupFieldService.instance = new STUB_LookupFieldServiceValid();

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

        Map<String, LookupFieldModel> accountLookupsOnContactFieldModelsByName = new Map<String, LookupFieldModel>{
            'Account Field Name' => new LookupFieldModel('Account Field Name', 'Account Field Label')
        };

        Map<String, LookupFieldModel> accountLookupsOnContactFieldModelsByLabel = new Map<String, LookupFieldModel>{
            'Account Field Label' => new LookupFieldModel('Account Field Name', 'Account Field Label')
        };

        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = PrimaryAffiliationsSettingsVMapper.getInstance();

        Test.startTest();
        PrimaryAffiliationMappingVModel primaryAffiliationMappingVModel = primaryAffiliationsSettingsVMapperInstance.getPrimaryAffiliationsMappingVModel(
            affiliationMappingsModel,
            accountRecordTypeModelsByName,
            accountRecordTypeModelsByLabel,
            accountLookupsOnContactFieldModelsByName,
            accountLookupsOnContactFieldModelsByLabel
        );
        Test.stopTest();

        System.assertEquals(
            'Affliation Name',
            PrimaryAffiliationMappingVModel.mappingName,
            'Mapping name should match name of affiliation mapping.'
        );

        System.assertEquals(
            'Account_Record_Type',
            PrimaryAffiliationMappingVModel.accountRecordTypeName,
            'Account Record Type name should match developer name of Record Type model corresponding to record type specified for the affiliation mapping.'
        );

        System.assertEquals(
            'Account Record Type',
            PrimaryAffiliationMappingVModel.accountRecordTypeLabel,
            'Account Record Type label should match label of Record Type model corresponding to record type specified for the affiliation mapping.'
        );

        System.assertEquals(
            'Account Field Name',
            PrimaryAffiliationMappingVModel.contactFieldName,
            'Contact field name should match name of Lookup Field model corresponding to primary affiliation field specified for the affiliation mapping.'
        );

        System.assertEquals(
            'Account Field Label',
            PrimaryAffiliationMappingVModel.contactFieldLabel,
            'Contact field label should match label of Lookup Field model corresponding to primary affiliation field specified for the affiliation mapping.'
        );

        System.assertEquals(
            true,
            PrimaryAffiliationMappingVModel.autoProgramEnrollment,
            'Auto-enrollment enablement should match value specified for the affiliation mapping.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getPrimaryAffiliationsMappingVModel()
     * returns a PrimaryAffiliationMappingVModel with account record type and lookup field names
     * and labels corresponding to the properties specified for the affiliation mapping
     * when matching models do not exist.
     ****************************************************************************************/
    @isTest
    private static void getPrimaryAffiliationsMappingVModelInValid() {
        RecordTypeService.instance = new STUB_RecordTypeServiceInvalid();
        LookupFieldService.instance = new STUB_LookupFieldServiceInvalid();

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

        Map<String, LookupFieldModel> accountLookupsOnContactFieldModelsByName = new Map<String, LookupFieldModel>{
            'Account Field Name' => new LookupFieldModel('Account Field Name', 'Account Field Label')
        };

        Map<String, LookupFieldModel> accountLookupsOnContactFieldModelsByLabel = new Map<String, LookupFieldModel>{
            'Account Field Label' => new LookupFieldModel('Account Field Name', 'Account Field Label')
        };

        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = PrimaryAffiliationsSettingsVMapper.getInstance();

        Test.startTest();
        PrimaryAffiliationMappingVModel primaryAffiliationMappingVModel = primaryAffiliationsSettingsVMapperInstance.getPrimaryAffiliationsMappingVModel(
            affiliationMappingsModel,
            accountRecordTypeModelsByName,
            accountRecordTypeModelsByLabel,
            accountLookupsOnContactFieldModelsByName,
            accountLookupsOnContactFieldModelsByLabel
        );
        Test.stopTest();

        System.assertEquals(
            'Affliation Name',
            PrimaryAffiliationMappingVModel.mappingName,
            'Mapping name should match name of affiliation mapping.'
        );

        System.assertEquals(
            'Invalid Account Record Type',
            PrimaryAffiliationMappingVModel.accountRecordTypeName,
            'Account Record Type name should match value specified for the affiliation mapping.'
        );

        System.assertEquals(
            'Invalid Account Record Type',
            PrimaryAffiliationMappingVModel.accountRecordTypeLabel,
            'Account Record Type label should match value specified for the affiliation mapping.'
        );

        System.assertEquals(
            'Invalid Primary Affiliation Field',
            PrimaryAffiliationMappingVModel.contactFieldName,
            'Contact field name should match value specified for the affiliation mapping.'
        );

        System.assertEquals(
            'Invalid Primary Affiliation Field',
            PrimaryAffiliationMappingVModel.contactFieldLabel,
            'Contact field label should match value specified for the affiliation mapping.'
        );

        System.assertEquals(
            false,
            PrimaryAffiliationMappingVModel.autoProgramEnrollment,
            'Auto-enrollment enablement should match value specified for the affiliation mapping.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getPrimaryAffiliationsSettingsVModel()
     * returns a PrimaryAffiliationSettingsVModel with a list of PrimaryAffiliationMappingVModels
     * corresponding to the affiliation mappings with account record type and lookup field names
     * and labels matching the corresponding models when matching models exist.
     ****************************************************************************************/
    @isTest
    private static void getPrimaryAffiliationsSettingsVModelValid() {
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsService();
        RecordTypeService.instance = new STUB_RecordTypeService();
        LookupFieldService.instance = new STUB_LookupFieldService();

        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = PrimaryAffiliationsSettingsVMapper.getInstance();

        Test.startTest();
        PrimaryAffiliationSettingsVModel primaryAffiliationSettingsVModel = primaryAffiliationsSettingsVMapperInstance.getPrimaryAffiliationsSettingsVModel();
        Test.stopTest();

        System.assertEquals(
            2,
            PrimaryAffiliationSettingsVModel.primaryAffiliationMappings.size(),
            'Should return 2 PrimaryAffiliationMappingVModels.'
        );

        for (Integer i = 0; i < PrimaryAffiliationSettingsVModel.primaryAffiliationMappings.size(); i++) {
            System.assertEquals(
                'Affiliation Name ' + (i + 1),
                PrimaryAffiliationSettingsVModel.primaryAffiliationMappings[i].mappingName,
                'Mapping name on PrimaryAffiliationMappingVModel should match affiliation.'
            );

            System.assertEquals(
                'Record_Type_' + (i + 1),
                PrimaryAffiliationSettingsVModel.primaryAffiliationMappings[i].accountRecordTypeName,
                'Account record type name on PrimaryAffiliationMappingVModel should match developer name of corresponding record type model.'
            );

            System.assertEquals(
                'Record Type ' + (i + 1),
                PrimaryAffiliationSettingsVModel.primaryAffiliationMappings[i].accountRecordTypeLabel,
                'Account record type label on PrimaryAffiliationMappingVModel should match label of corresponding record type model.'
            );

            System.assertEquals(
                'Contact Account Lookup Name ' + (i + 1),
                PrimaryAffiliationSettingsVModel.primaryAffiliationMappings[i].contactFieldName,
                'Contact field name on PrimaryAffiliationMappingVModel should match name of corresponding lookup field model.'
            );

            System.assertEquals(
                'Contact Account Lookup Label ' + (i + 1),
                PrimaryAffiliationSettingsVModel.primaryAffiliationMappings[i].contactFieldLabel,
                'Contact field label on PrimaryAffiliationMappingVModel should match label of corresponding lookup field model.'
            );

            System.assertEquals(
                true,
                PrimaryAffiliationSettingsVModel.primaryAffiliationMappings[i].autoProgramEnrollment,
                'Auto-Enrollment enablement on PrimaryAffiliationMappingVModel should match affiliation.'
            );
        }
    }

    /****************************************************************************************
     * @description Test method to verify getPrimaryAffiliationsSettingsVModel()
     * returns a PrimaryAffiliationSettingsVModel with a list of PrimaryAffiliationMappingVModels
     * corresponding to the affiliation mappings with account record type and lookup field names
     * and labels matching the affiliation model properties when matching models do not exist.
     ****************************************************************************************/
    @isTest
    private static void getPrimaryAffiliationsSettingsVModelInValid() {
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsService();
        RecordTypeService.instance = new STUB_RecordTypeServiceInvalid();
        LookupFieldService.instance = new STUB_LookupFieldServiceInvalid();

        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = PrimaryAffiliationsSettingsVMapper.getInstance();

        Test.startTest();
        PrimaryAffiliationSettingsVModel primaryAffiliationSettingsVModel = primaryAffiliationsSettingsVMapperInstance.getPrimaryAffiliationsSettingsVModel();
        Test.stopTest();

        System.assertEquals(
            2,
            PrimaryAffiliationSettingsVModel.primaryAffiliationMappings.size(),
            'Should return 2 PrimaryAffiliationMappingVModels.'
        );

        for (Integer i = 0; i < PrimaryAffiliationSettingsVModel.primaryAffiliationMappings.size(); i++) {
            System.assertEquals(
                'Affiliation Name ' + (i + 1),
                PrimaryAffiliationSettingsVModel.primaryAffiliationMappings[i].mappingName,
                'Mapping name on PrimaryAffiliationMappingVModel should match affiliation.'
            );

            System.assertEquals(
                'Record Type ' + (i + 1),
                PrimaryAffiliationSettingsVModel.primaryAffiliationMappings[i].accountRecordTypeName,
                'Account record type name on PrimaryAffiliationMappingVModel should match affiliation.'
            );

            System.assertEquals(
                'Record Type ' + (i + 1),
                PrimaryAffiliationSettingsVModel.primaryAffiliationMappings[i].accountRecordTypeLabel,
                'Account record type label on PrimaryAffiliationMappingVModel should match affiliation.'
            );

            System.assertEquals(
                'Contact Account Lookup Label ' + (i + 1),
                PrimaryAffiliationSettingsVModel.primaryAffiliationMappings[i].contactFieldName,
                'Contact field name on PrimaryAffiliationMappingVModel should match affiliation.'
            );

            System.assertEquals(
                'Contact Account Lookup Label ' + (i + 1),
                PrimaryAffiliationSettingsVModel.primaryAffiliationMappings[i].contactFieldLabel,
                'Contact field label on PrimaryAffiliationMappingVModel should match affiliation.'
            );

            System.assertEquals(
                true,
                PrimaryAffiliationSettingsVModel.primaryAffiliationMappings[i].autoProgramEnrollment,
                'Auto-Enrollment enablement on PrimaryAffiliationMappingVModel should match affiliation.'
            );
        }
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
                    'Record Type 1',
                    'Contact Account Lookup Label 1',
                    true,
                    'autoProgramEnrollmentStatus1',
                    'autoProgramEnrollmentRole1'
                ),
                new AffiliationMappingsModel(
                    'Affiliation Name 2',
                    'Record Type 2',
                    'Contact Account Lookup Label 2',
                    true,
                    'autoProgramEnrollmentStatus2',
                    'autoProgramEnrollmentRole2'
                )
            };
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate valid responses from LookupFieldService
     **************************************************************************************************************************************/
    private class STUB_LookupFieldService extends LookupFieldService {
        public override Map<String, LookupFieldModel> getModelByNameMapForSObjectType(
            SObjectType sObjectType,
            SObjectType lookupToSObjectType
        ) {
            return new Map<String, LookupFieldModel>{
                'Contact Account Lookup Name 1' => new LookupFieldModel(
                    'Contact Account Lookup Name 1',
                    'Contact Account Lookup Label 1'
                ),
                'Contact Account Lookup Name 2' => new LookupFieldModel(
                    'Contact Account Lookup Name 2',
                    'Contact Account Lookup Label 2'
                )
            };
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate valid responses from LookupFieldService
     **************************************************************************************************************************************/
    private class STUB_LookupFieldServiceValid extends LookupFieldService {
        public override LookupFieldModel getLookupFieldModelFromNameAndLabelMaps(
            String lookupFieldNameOrLabel,
            Map<String, LookupFieldModel> lookupFieldModelByName,
            Map<String, LookupFieldModel> lookupFieldModelByLabel
        ) {
            return new LookupFieldModel('Account Field Name', 'Account Field Label');
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
     * @description Stub class to simulate invalid responses from LookupFieldService
     **************************************************************************************************************************************/
    private class STUB_LookupFieldServiceInvalid extends LookupFieldService {
        public override LookupFieldModel getLookupFieldModelFromNameAndLabelMaps(
            String lookupFieldNameOrLabel,
            Map<String, LookupFieldModel> lookupFieldModelByName,
            Map<String, LookupFieldModel> lookupFieldModelByLabel
        ) {
            return null;
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
}
