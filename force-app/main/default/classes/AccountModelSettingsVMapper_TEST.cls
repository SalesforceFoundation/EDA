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
public with sharing class AccountModelSettingsVMapper_TEST {
    public static String adminAccRecordTypeId = UTIL_Describe_API.getAdminAccRecTypeID();
    public static String businessAccRecordTypeId = UTIL_Describe_API.getBizAccRecTypeID();
    public static String hhAccRecordTypeId = UTIL_Describe_API.getHhAccRecTypeID();

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
     * @description Test method to verify that the locateAccountRecordTypeAutomaticDeletionService method returns instance of
     * AccountRecordTypeAutomaticDeletionService
     ***********************************************************************************************************************************/
    // @isTest
    // private static void locateAccountRecordTypeAutomaticDeletionServiceValid() {
    //     AccountModelSettingsVMapper accountModelSettingsVMapperInstance = AccountModelSettingsVMapper.getInstance();

    //     Test.startTest();
    //     AccountRecordTypeAutomaticDeletionService accountRecordTypeAutomaticDeletionServiceInstance =
    //         accountModelSettingsVMapperInstance.locateAccountRecordTypeAutomaticDeletionService();
    //     Test.stopTest();

    //     System.assertEquals(
    //         AccountRecordTypeAutomaticDeletionService.getInstance(),
    //         accountRecordTypeAutomaticDeletionServiceInstance,
    //         'Should return the instance of AccountModelSettingsService'
    //     );
    // }

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

    @isTest
    private static void getAccountModelSettingsViewModelValid() {
        // only active record types available

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = adminAccRecordTypeId,
                Household_Addresses_RecType__c = hhAccRecordTypeId,
                Administrative_Account_Record_Type__c = adminAccRecordTypeId
            )
        );

        AccountModelSettingsVMapper accountModelSettingsVMapperInstance = AccountModelSettingsVMapper.getInstance();

        Test.startTest();
        AccountModelSettingsVModel accountModelSettingsVModel = accountModelSettingsVMapperInstance.getAccountModelSettingsViewModel();
        Test.stopTest();

        System.assertEquals(
            adminAccRecordTypeId,
            accountModelSettingsVModel.defaultAccountRecordType.value,
            'Selected value for default account record type should be set as admin account.'
        );

        System.assertEquals(
            hhAccRecordTypeId,
            accountModelSettingsVModel.householdAccountRecordType.value,
            'Selected value for household account record type should be set as household account.'
        );

        System.assertEquals(
            adminAccRecordTypeId,
            accountModelSettingsVModel.adminAccountRecordType.value,
            'Selected value for admin account record type should be set as admin account.'
        );

        Map<String, ComboboxValueVModel> activeAccountRecordTypeComboboxValueVModelsByValue = AccountModelSettingsVMapper_TEST.getActiveAccountRecordTypeComboboxValueVModelsByRecordTypeId();

        System.assertEquals(
            activeAccountRecordTypeComboboxValueVModelsByValue.values().size(),
            accountModelSettingsVModel.adminAccountRecordType.options.size(),
            'Number of Account Record Type options should match number of active record types in org.'
        );

        for (
            ComboboxValueVModel accountRecordTypeComboboxValueVModel : accountModelSettingsVModel.adminAccountRecordType.options
        ) {
            System.assertEquals(
                true,
                activeAccountRecordTypeComboboxValueVModelsByValue.containsKey(
                    accountRecordTypeComboboxValueVModel.value
                ),
                'Account record type options should contain all active record types in org.'
            );
        }
    }

    /***********************************************************************************************************************************
     * @description Helper method to retrieve active ComboboxValueVModels corresponding to the Account record types existing in the
     * org for testing.
     * @return A of ComboboxValueVModels representing the active Account record types in the org mapped by record type ID (value).
     ***********************************************************************************************************************************/
    private static Map<String, ComboboxValueVModel> getActiveAccountRecordTypeComboboxValueVModelsByRecordTypeId() {
        Map<Id, RecordTypeModel> activeAccountRecordTypeModelsById = RecordTypeService.getInstance()
            .getModelByIdMapForSObjectType(Account.SObjectType);

        // filter out inactive record types
        for (Id accountRecordTypeModelId : activeAccountRecordTypeModelsById.keySet()) {
            if (activeAccountRecordTypeModelsById.get(accountRecordTypeModelId).isActive == false) {
                activeAccountRecordTypeModelsById.remove(accountRecordTypeModelId);
            }
        }

        Map<String, ComboboxValueVModel> activeAccountRecordTypeComboboxValueVModelsByValue = new Map<String, ComboboxValueVModel>();
        for (RecordTypeModel recordTypeModel : activeAccountRecordTypeModelsById.values()) {
            activeAccountRecordTypeComboboxValueVModelsByValue.put(
                recordTypeModel.Id,
                new ComboboxValueVModel(recordTypeModel.name, recordTypeModel.id)
            );
        }

        return activeAccountRecordTypeComboboxValueVModelsByValue;
    }

    @isTest
    private static void getAccountModelSettingsViewModelWithBlankAccounSettingFields() {
        // TODO: what happens if account setting field in hierarchy settings is blank?
    }

    @isTest
    private static void getAccountModelSettingsViewModelWithInactiveRecordTypes() {
        // include inactive record types and ensure they are filtered out of final result
    }

    @isTest
    private static void getAccountModelSettingsViewModelWithNoRecordTypes() {
        // TODO: what happens if there are zero Account record types in the org?
    }

    /***********************************************************************************************************************************
     * @description Helper method to retrieve active ComboboxValueVModels corresponding to the Account record types existing in the
     * org for testing.
     * @return A of ComboboxValueVModels representing the active Account record types in the org mapped by record type ID (value).
     ***********************************************************************************************************************************/
    private static Map<String, ComboboxValueVModel> getActiveAccountRecordTypeComboboxValueVModelsByRecordTypeId() {
        Map<Id, RecordTypeModel> activeAccountRecordTypeModelsById = RecordTypeService.getInstance()
            .getModelByIdMapForSObjectType(Account.SObjectType);

        // filter out inactive record types
        for (Id accountRecordTypeModelId : activeAccountRecordTypeModelsById.keySet()) {
            if (activeAccountRecordTypeModelsById.get(accountRecordTypeModelId).isActive == false) {
                activeAccountRecordTypeModelsById.remove(accountRecordTypeModelId);
            }
        }

        Map<String, ComboboxValueVModel> activeAccountRecordTypeComboboxValueVModelsByValue = new Map<String, ComboboxValueVModel>();
        for (RecordTypeModel recordTypeModel : activeAccountRecordTypeModelsById.values()) {
            activeAccountRecordTypeComboboxValueVModelsByValue.put(
                recordTypeModel.Id,
                new ComboboxValueVModel(recordTypeModel.name, recordTypeModel.id)
            );
        }

        return activeAccountRecordTypeComboboxValueVModelsByValue;
    }
}
