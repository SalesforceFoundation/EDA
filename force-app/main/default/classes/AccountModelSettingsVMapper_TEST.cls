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
 * @description Test class for AccountModelSettingsVMapper class
 */
@isTest
private with sharing class AccountModelSettingsVMapper_TEST {
    private static Integer loopCounter = 5;

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * AccountModelSettingsVMapper class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        AccountModelSettingsVMapper accountModelSettingsVMapperInstance = AccountModelSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            AccountModelSettingsVMapper.instance,
            accountModelSettingsVMapperInstance,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            true,
            accountModelSettingsVMapperInstance != null,
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * AccountModelSettingsVMapper class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        AccountModelSettingsVMapper accountModelSettingsVMapperInstance1 = AccountModelSettingsVMapper.getInstance();
        AccountModelSettingsVMapper accountModelSettingsVMapperInstance2 = AccountModelSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            AccountModelSettingsVMapper.instance,
            accountModelSettingsVMapperInstance1,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            accountModelSettingsVMapperInstance1,
            accountModelSettingsVMapperInstance2,
            'Subsequent retrievals of service class instance should return existing instance.'
        );

        System.assertEquals(
            true,
            accountModelSettingsVMapperInstance1 != null,
            'Instance of service class should not be null.'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the locateAccountModelSettingsService method returns instance of AccountModelSettingsMapper
     ***********************************************************************************************************************************/
    @isTest
    private static void locateAccountModelSettingsServiceValid() {
        AccountModelSettingsVMapper accountModelSettingsVMapperInstance = AccountModelSettingsVMapper.getInstance();

        Test.startTest();
        AccountModelSettingsService accountModelSettingsServiceInstance = accountModelSettingsVMapperInstance.locateAccountModelSettingsService();
        Test.stopTest();

        System.assertEquals(
            AccountModelSettingsService.getInstance(),
            accountModelSettingsServiceInstance,
            'Should return the instance of AccountModelSettingsService'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the locateAccountRecordTypeAutoDeletionService method returns instance of
     * AccountRecordTypeAutoDeletionService
     ***********************************************************************************************************************************/
    @isTest
    private static void locateAccountRecordTypeAutoDeletionServiceValid() {
        AccountModelSettingsVMapper accountModelSettingsVMapperInstance = AccountModelSettingsVMapper.getInstance();

        Test.startTest();
        AccountRecordTypeAutoDeletionService accountRecordTypeAutoDeletionServiceInstance = accountModelSettingsVMapperInstance.locateAccountRecordTypeAutoDeletionService();
        Test.stopTest();

        System.assertEquals(
            AccountRecordTypeAutoDeletionService.getInstance(),
            accountRecordTypeAutoDeletionServiceInstance,
            'Should return the instance of AccountModelSettingsService'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the locateRecordTypeService method returns instance of RecordTypeService
     ***********************************************************************************************************************************/
    @isTest
    private static void locateRecordTypeServiceValid() {
        AccountModelSettingsVMapper accountModelSettingsVMapperInstance = AccountModelSettingsVMapper.getInstance();

        Test.startTest();
        RecordTypeService recordTypeServiceInstance = accountModelSettingsVMapperInstance.locateRecordTypeService();
        Test.stopTest();

        System.assertEquals(
            RecordTypeService.getInstance(),
            recordTypeServiceInstance,
            'Should return the instance of RecordTypeService'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getAccountModelSettingsViewModel returns an AccountModelSettingsVModel with the selected
     * value set to the current field value specified in Hierarchy Settings for Account Record Types and a list of comboboxVModels that
     * correspond to all active Account Record Types in the org.
     ***********************************************************************************************************************************/
    @isTest
    private static void getAccountModelSettingsViewModelValid() {
        RecordTypeMapper.instance = new STUB_RecordTypeMapper();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = '000000000000000001',
                Household_Addresses_RecType__c = '',
                Administrative_Account_Record_Type__c = null
            )
        );

        AccountModelSettingsVMapper accountModelSettingsVMapperInstance = AccountModelSettingsVMapper.getInstance();

        Test.startTest();
        AccountModelSettingsVModel accountModelSettingsVModel = accountModelSettingsVMapperInstance.getAccountModelSettingsViewModel();
        Test.stopTest();

        System.assertEquals(
            '000000000000000001',
            accountModelSettingsVModel.defaultAccountRecordType.value,
            'Selected value for default account record type should be set as default account.'
        );

        System.assertEquals(
            '""',
            accountModelSettingsVModel.householdAccountRecordType.value,
            'Selected value for household account record type should be set as household account.'
        );

        System.assertEquals(
            '""',
            accountModelSettingsVModel.adminAccountRecordType.value,
            'Selected value for admin account record type should be set as admin account.'
        );

        System.assertEquals(
            1,
            accountModelSettingsVModel.defaultAccountRecordType.options.size(),
            'Should only list active record types as options.'
        );
        System.assertEquals(
            '000000000000000001',
            accountModelSettingsVModel.defaultAccountRecordType.options[0].value,
            'Should only list active record types as options.'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getAccountModelSettingsViewModel returns an AccountModelSettingsVModel with the selected
     * value set to the value specified in the associated Hierarchy Settings fields and an empty list of comboboxVModels when there are
     * no active Account Record Types in the org.
     ***********************************************************************************************************************************/
    @isTest
    private static void getAccountModelSettingsViewModelWithNoRecordTypes() {
        RecordTypeMapper.instance = new STUB_RecordTypeMapperEmpty();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = 'Default Account',
                Household_Addresses_RecType__c = null,
                Administrative_Account_Record_Type__c = ''
            )
        );

        AccountModelSettingsVMapper accountModelSettingsVMapperInstance = AccountModelSettingsVMapper.getInstance();

        Test.startTest();
        AccountModelSettingsVModel accountModelSettingsVModel = accountModelSettingsVMapperInstance.getAccountModelSettingsViewModel();
        Test.stopTest();

        System.assertEquals(
            'Default Account',
            accountModelSettingsVModel.defaultAccountRecordType.value,
            'Selected value for default account record type should be set.'
        );

        System.assertEquals(
            '""',
            accountModelSettingsVModel.householdAccountRecordType.value,
            'Selected value for household account record type should be blank.'
        );

        System.assertEquals(
            '""',
            accountModelSettingsVModel.adminAccountRecordType.value,
            'Selected value for admin account record type should be blank.'
        );

        System.assertEquals(
            true,
            accountModelSettingsVModel.defaultAccountRecordType.options.isEmpty(),
            'Default Account model should have no Account Record Type options available.'
        );

        System.assertEquals(
            true,
            accountModelSettingsVModel.householdAccountRecordType.options.isEmpty(),
            'HH Account model should have no Account Record Type options available.'
        );
        System.assertEquals(
            true,
            accountModelSettingsVModel.adminAccountRecordType.options.isEmpty(),
            'Admin Account model should have no Account Record Type options available.'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getComboboxVModelOptionsForActiveAccountRecordTypes returns an list of ComboboxValueVModels
     * corresponding to all active Account Record Types.
     ***********************************************************************************************************************************/
    @isTest
    private static void getComboboxVModelOptionsForActiveAccountRecordTypesValid() {
        List<RecordTypeModel> recordTypeModelsList = new List<RecordTypeModel>();

        for (Integer i = 0; i < loopCounter; i++) {
            recordTypeModelsList.add(
                new RecordTypeModel('00000000000000000' + i, 'Active RecordType ' + i, 'Active_RecordType_' + i, true)
            );
        }

        AccountModelSettingsVMapper accountModelSettingsVMapperInstance = AccountModelSettingsVMapper.getInstance();

        Test.startTest();
        List<ComboboxValueVModel> comboboxValueVModelsList = accountModelSettingsVMapperInstance.getComboboxVModelOptionsForActiveAccountRecordTypes(
            recordTypeModelsList
        );
        Test.stopTest();

        System.assertEquals(
            loopCounter,
            comboboxValueVModelsList.size(),
            'Should return ' +
            loopCounter +
            ' ComboboxValueVModels.'
        );

        for (Integer i = 0; i < loopCounter; i++) {
            System.assertEquals(
                'Active RecordType ' + i,
                comboboxValueVModelsList[i].label,
                'Label should correspond to record type model name property.'
            );

            System.assertEquals(
                '00000000000000000' + i,
                comboboxValueVModelsList[i].value,
                'Value should correspond to record type model ID property.'
            );
        }
    }

    /**************************************************************************************************************************
     ****************************************************** STUBS **************************************************************
     **************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from RecordTypeMapper to return a map of Account Record Types, both active and inactive
     **************************************************************************************************************************************/
    private class STUB_RecordTypeMapper extends RecordTypeMapper {
        public override Map<Id, RecordTypeModel> getModelByIdMapForSObjectType(Schema.SObjectType sObjectType) {
            Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>();

            recordTypeModelsById.put(
                '000000000000000001',
                new RecordTypeModel('000000000000000001', 'Active Record Type 1', 'Active_Record_Type_1', true)
            );
            recordTypeModelsById.put(
                '000000000000000002',
                new RecordTypeModel('000000000000000002', 'Inactive Record Type 1', 'Inactive_Record_Type_1', false)
            );
            recordTypeModelsById.put(
                '000000000000000003',
                new RecordTypeModel('000000000000000003', 'Inactive Record Type 2', 'Inactive_Record_Type_2', false)
            );

            return recordTypeModelsById;
        }
    }
    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from RecordTypeMapper to return an empty map of Account Record Types
     **************************************************************************************************************************************/
    private class STUB_RecordTypeMapperEmpty extends RecordTypeMapper {
        public override Map<Id, RecordTypeModel> getModelByIdMapForSObjectType(Schema.SObjectType sObjectType) {
            return new Map<Id, RecordTypeModel>();
        }
    }
}
