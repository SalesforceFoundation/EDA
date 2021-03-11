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
 * @description Test class for HierarchySettingsService class
 */
@isTest
public with sharing class HierarchySettingsService_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * HierarchySettingsService class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(
            HierarchySettingsService.instance,
            hierarchySettingsServiceInstance,
            'Instance of mapper class returned should match static instance variable.'
        );

        System.assertEquals(
            true,
            hierarchySettingsServiceInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * HierarchySettingsService class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        HierarchySettingsService hierarchySettingsServiceInstance1 = HierarchySettingsService.getInstance();
        HierarchySettingsService hierarchySettingsServiceInstance2 = HierarchySettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(
            HierarchySettingsService.instance,
            hierarchySettingsServiceInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );

        System.assertEquals(
            hierarchySettingsServiceInstance1,
            hierarchySettingsServiceInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );

        System.assertEquals(
            true,
            hierarchySettingsServiceInstance1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the locateHierarchySettingsMapper method returns a valid instance of
     * HierarchySettingsMapper.
     ***************************************************************************************************************************/
    @isTest
    private static void locateHierarchySettingsMapperValid() {
        HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();

        Test.startTest();
        HierarchySettingsMapper hierarchySettingsMapperInstance = hierarchySettingsServiceInstance.locateHierarchySettingsMapper();
        Test.stopTest();

        System.assertEquals(
            HierarchySettingsMapper.getInstance(),
            hierarchySettingsMapperInstance,
            'Should return instance of HierarchySettingsMapper.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the locateUserPermissionService method returns a valid instance of
     * UserPermissionService.
     ***************************************************************************************************************************/
    @isTest
    private static void locateUserPermissionServiceValid() {
        HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();

        Test.startTest();
        UserPermissionService userPermissionServiceInstance = hierarchySettingsServiceInstance.locateUserPermissionService();
        Test.stopTest();

        System.assertEquals(
            UserPermissionService.getInstance(),
            userPermissionServiceInstance,
            'Should return instance of UserPermissionService.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the updateHierarchySettings method returns true when an update to Hierarchy
     * Settings is successfully processed.
     ***************************************************************************************************************************/
    @isTest
    private static void updateHierarchySettingsValid() {
        PermissionSetMapper.instance = new STUB_PermissionSetMapperHasAccess();
        HierarchySettingsMapper.instance = new STUB_HierarchySettingsMapper();

        HierarchySettingsChangesVModel hierarchySettingsChangesVModel = new HierarchySettingsChangesVModel();
        HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();

        Test.startTest();
        Boolean updateHierarchySettingsResult = hierarchySettingsServiceInstance.updateHierarchySettings(
            hierarchySettingsChangesVModel
        );
        Test.stopTest();

        System.assertEquals(true, updateHierarchySettingsResult, 'Should return true indicating a successful update.');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the updateHierarchySettings method throws an exception when an exception is
     * encountered from the UserPermissionService class
     ***************************************************************************************************************************/
    @isTest
    private static void updateHierarchySettingsPermissionException() {
        PermissionSetMapper.instance = new STUB_PermissionSetMapperNoAccess();

        HierarchySettingsChangesVModel hierarchySettingsChangesVModel = new HierarchySettingsChangesVModel();
        HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();

        try {
            Test.startTest();
            Boolean updateHierarchySettingsResult = hierarchySettingsServiceInstance.updateHierarchySettings(
                hierarchySettingsChangesVModel
            );
            Test.stopTest();
        } catch (System.NoAccessException e) {
            System.assertEquals(
                'Script-thrown exception',
                e.getMessage(),
                'Should throw an error when permissions are missing.'
            );
        }
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the updateHierarchySettings method throws an error and does not update any
     * Hierarchy Settings fields when an error is encountered.
     ***************************************************************************************************************************/
    @isTest
    private static void updateHierarchySettingsSchemaDescribeException() {
        PermissionSetMapper.instance = new STUB_PermissionSetMapperHasAccess();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = 'Original Account',
                Accounts_to_Delete__c = 'Original Value1;Original Value2'
            )
        );

        Map<String, String> singleValueSettingUpdatesByNameInvalid = new Map<String, String>{
            UTIL_Namespace.StrTokenNSPrefix('Account_Processor_Invalid__c') => 'Updated Value'
        };

        Map<String, List<String>> listValueSettingUpdatesByName = new Map<String, List<String>>{
            UTIL_Namespace.StrTokenNSPrefix('Accounts_to_Delete__c') => new List<String>{
                'Updated Value 1',
                'Updated Value 2'
            }
        };

        HierarchySettingsChangesVModel hierarchySettingsChangesVModel = new HierarchySettingsChangesVModel(
            singleValueSettingUpdatesByNameInvalid,
            listValueSettingUpdatesByName
        );

        HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();

        try {
            Test.startTest();
            Boolean updateResult = hierarchySettingsServiceInstance.updateHierarchySettings(
                hierarchySettingsChangesVModel
            );
            Test.stopTest();
        } catch (UTIL_Describe.SchemaDescribeException e) {
            System.assertEquals(
                'Invalid field name \'' +
                UTIL_Namespace.StrTokenNSPrefix('Account_Processor_Invalid__c') +
                '\'',
                e.getMessage(),
                'Invalid field name should cause exception'
            );
        } catch (HierarchySettingsService.InvalidSettingsException e) {
            System.assertEquals(
                Label.stgErrorInvalidSettings,
                e.getMessage(),
                'Invalid mapping should throw exception.'
            );
        }

        Hierarchy_Settings__c updatedHierarchySettings = UTIL_CustomSettings_API.getSettings();

        System.assertEquals(
            'Original Account',
            updatedHierarchySettings.Account_Processor__c,
            'Account_Processor__c value should remain unchanged.'
        );

        System.assertEquals(
            'Original Value1;Original Value2',
            updatedHierarchySettings.Accounts_to_Delete__c,
            'Accounts_to_Delete__c value should remain unchanged.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the updateHierarchySettingsWithListValues method throws an error when an invalid
     * Hierarchy Setting field is specified for update.
     ***************************************************************************************************************************/
    @isTest
    private static void updateHierarchySettingsWithListValuesInValidFieldName() {
        PermissionSetMapper.instance = new STUB_PermissionSetMapperHasAccess();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Accounts_to_Delete__c = 'Original Value1;Original Value2')
        );

        Map<String, List<String>> listValueSettingUpdatesByName = new Map<String, List<String>>{
            UTIL_Namespace.StrTokenNSPrefix('Accounts_to_Delete__c') => new List<String>{
                'Updated Value 1',
                'Updated Value 2'
            },
            UTIL_Namespace.StrTokenNSPrefix('Not_A_Valid_Field__c') => new List<String>{ 'Invalid value' }
        };

        HierarchySettingsChangesVModel hierarchySettingsChangesVModelListValuesError = new HierarchySettingsChangesVModel(
            new Map<String, String>(),
            listValueSettingUpdatesByName
        );

        HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();

        try {
            Test.startTest();
            Boolean updateResult = hierarchySettingsServiceInstance.updateHierarchySettings(
                hierarchySettingsChangesVModelListValuesError
            );
            Test.stopTest();
        } catch (UTIL_Describe.SchemaDescribeException e) {
            System.assertEquals(
                'Invalid field name \'' +
                UTIL_Namespace.StrTokenNSPrefix('Not_A_Valid_Field__c') +
                '\'',
                e.getMessage(),
                'Invalid field mapping should throw error.'
            );
        } catch (HierarchySettingsService.InvalidSettingsException e) {
            System.assertEquals(
                Label.stgErrorInvalidSettings,
                e.getMessage(),
                'Invalid mapping should throw exception.'
            );
        }
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the updateHierarchySettings method does not update the specified Hierarchy
     * Settings fields of type collection when no updates are specified.
     ***************************************************************************************************************************/
    @isTest
    private static void updateHierarchySettingsWithListValuesEmpty() {
        PermissionSetMapper.instance = new STUB_PermissionSetMapperHasAccess();
        HierarchySettingsMapper.instance = new STUB_HierarchySettingsMapper();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Accounts_to_Delete__c = 'Original Value1;Original Value2')
        );

        Map<String, List<String>> listValueSettingUpdatesByName = new Map<String, List<String>>();

        HierarchySettingsChangesVModel hierarchySettingsChangesVModelListValuesEmpty = new HierarchySettingsChangesVModel(
            new Map<String, String>(),
            listValueSettingUpdatesByName
        );

        HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();

        Test.startTest();
        Boolean updateResult = hierarchySettingsServiceInstance.updateHierarchySettings(
            hierarchySettingsChangesVModelListValuesEmpty
        );
        Test.stopTest();

        System.assertEquals(true, updateResult, 'Update to string value should complete successfully.');

        Hierarchy_Settings__c updatedHierarchySettings = UTIL_CustomSettings_API.getSettings();

        System.assertEquals(
            'Original Value1;Original Value2',
            updatedHierarchySettings.Accounts_to_Delete__c,
            'Accounts_to_Delete__c value should remain unchanged.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the updateHierarchySettings method does not update Hierarchy Settings fields
     * when updates for a primitive data type are not specified.
     ***************************************************************************************************************************/
    @isTest
    private static void updateHierarchySettingsWithSingleValuesEmpty() {
        PermissionSetMapper.instance = new STUB_PermissionSetMapperHasAccess();
        HierarchySettingsMapper.instance = new STUB_HierarchySettingsMapper();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = 'Original Value')
        );

        Map<String, String> singleValueSettingUpdatesByName = new Map<String, String>();

        HierarchySettingsChangesVModel hierarchySettingsChangesVModelEmptySingleValues = new HierarchySettingsChangesVModel(
            singleValueSettingUpdatesByName,
            new Map<String, List<String>>()
        );

        HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();

        Test.startTest();
        Boolean updateResult = hierarchySettingsServiceInstance.updateHierarchySettings(
            hierarchySettingsChangesVModelEmptySingleValues
        );
        Test.stopTest();

        System.assertEquals(true, updateResult, 'Update to string value should complete successfully.');

        Hierarchy_Settings__c updatedHierarchySettings = UTIL_CustomSettings_API.getSettings();

        System.assertEquals(
            'Original Value',
            updatedHierarchySettings.Account_Processor__c,
            'Account Processor value should remain unchanged.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the updateHierarchySettings method throws an error when a field is mapped to a
     * Hierarchy Settings field with the wrong data type is updated.
     ***************************************************************************************************************************/
    @isTest
    private static void updateHierarchySettingsWithSingleValuesInValidDateTime() {
        PermissionSetMapper.instance = new STUB_PermissionSetMapperHasAccess();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Async_Error_Check_Last_Run__c = Datetime.now().addDays(-1))
        );

        Map<String, String> singleValueSettingUpdatesByName = new Map<String, String>{
            UTIL_Namespace.StrTokenNSPrefix('Async_Error_Check_Last_Run__c') => 'Updated Value'
        };

        HierarchySettingsChangesVModel hierarchySettingsChangesVModelInvalidType = new HierarchySettingsChangesVModel(
            singleValueSettingUpdatesByName,
            new Map<String, List<String>>()
        );

        HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();

        try {
            Test.startTest();
            Boolean updateResult = hierarchySettingsServiceInstance.updateHierarchySettings(
                hierarchySettingsChangesVModelInvalidType
            );
            Test.stopTest();
        } catch (System.TypeException e) {
            System.assertEquals(
                'Invalid date/time: Updated Value',
                e.getMessage(),
                'Invalid mapping should throw exception.'
            );
        } catch (HierarchySettingsService.InvalidSettingsException e) {
            System.assertEquals(
                Label.stgErrorInvalidSettings,
                e.getMessage(),
                'Invalid mapping should throw exception.'
            );
        }
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the updateHierarchySettings method updates the specified Hierarchy Settings fields
     * of a collection type.
     ***************************************************************************************************************************/
    @isTest
    private static void updateHierarchySettingsWithListValuesValid() {
        PermissionSetMapper.instance = new STUB_PermissionSetMapperHasAccess();
        HierarchySettingsMapper.instance = new STUB_HierarchySettingsMapper();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Accounts_to_Delete__c = 'Original Value1;Original Value2')
        );

        Map<String, List<String>> listValueSettingUpdatesByName = new Map<String, List<String>>{
            UTIL_Namespace.StrTokenNSPrefix('Accounts_to_Delete__c') => new List<String>{
                'Updated Value 1',
                'Updated Value 2'
            }
        };

        HierarchySettingsChangesVModel hierarchySettingsChangesVModelListValues = new HierarchySettingsChangesVModel(
            new Map<String, String>(),
            listValueSettingUpdatesByName
        );

        HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();

        Test.startTest();
        Boolean updateResult = hierarchySettingsServiceInstance.updateHierarchySettings(
            hierarchySettingsChangesVModelListValues
        );
        Test.stopTest();

        System.assertEquals(true, updateResult, 'Update to string value should complete successfully.');

        Hierarchy_Settings__c updatedHierarchySettings = UTIL_CustomSettings_API.getSettings();

        System.assertEquals(
            'Updated Value 1;Updated Value 2',
            updatedHierarchySettings.Accounts_to_Delete__c,
            'Accounts_to_Delete__c value should be updated.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the updateHierarchySettings method throws an error when an
     * update is made for a field that is not in Hierarchy Settings.
     ***************************************************************************************************************************/
    @isTest
    private static void updateHierarchySettingsWithSingleValuesInValidFieldName() {
        PermissionSetMapper.instance = new STUB_PermissionSetMapperHasAccess();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = 'Original Value')
        );

        Map<String, String> singleValueSettingUpdatesByName = new Map<String, String>{
            UTIL_Namespace.StrTokenNSPrefix('Account_Processor__c') => 'Updated Value',
            UTIL_Namespace.StrTokenNSPrefix('Invalid_Field_Name__c') => 'Updated Invalid Value'
        };

        HierarchySettingsChangesVModel hierarchySettingsChangesVModelError = new HierarchySettingsChangesVModel(
            singleValueSettingUpdatesByName,
            new Map<String, List<String>>()
        );

        HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();

        try {
            Test.startTest();
            Boolean updateResult = hierarchySettingsServiceInstance.updateHierarchySettings(
                hierarchySettingsChangesVModelError
            );
            Test.stopTest();
        } catch (UTIL_Describe.SchemaDescribeException e) {
            System.assertEquals(
                'Invalid field name \'' +
                UTIL_Namespace.StrTokenNSPrefix('Invalid_Field_Name__c') +
                '\'',
                e.getMessage(),
                'Invalid mapping should throw exception.'
            );
        } catch (HierarchySettingsService.InvalidSettingsException e) {
            System.assertEquals(
                Label.stgErrorInvalidSettings,
                e.getMessage(),
                'Invalid mapping should throw exception.'
            );
        }
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the updateHierarchySettings method updates the Hierarchy Settings fields
     * for updates to fields with Datetime type.
     ***************************************************************************************************************************/
    @isTest
    private static void updateHierarchySettingsWithSingleValuesValidDateTime() {
        PermissionSetMapper.instance = new STUB_PermissionSetMapperHasAccess();
        HierarchySettingsMapper.instance = new STUB_HierarchySettingsMapper();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Async_Error_Check_Last_Run__c = Datetime.now().addDays(-3))
        );

        Map<String, String> singleValueSettingUpdatesByName = new Map<String, String>{
            UTIL_Namespace.StrTokenNSPrefix('Async_Error_Check_Last_Run__c') => String.valueOf(
                DateTime.newInstance(2021, 3, 17, 5, 0, 0)
            )
        };

        HierarchySettingsChangesVModel hierarchySettingsChangesVModelDateTimeValues = new HierarchySettingsChangesVModel(
            singleValueSettingUpdatesByName,
            new Map<String, List<String>>()
        );

        HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();

        Test.startTest();
        Boolean updateResult = hierarchySettingsServiceInstance.updateHierarchySettings(
            hierarchySettingsChangesVModelDateTimeValues
        );
        Test.stopTest();

        System.assertEquals(true, updateResult, 'Update to DateTime value should complete successfully.');

        Hierarchy_Settings__c updatedHierarchySettings = UTIL_CustomSettings_API.getSettings();

        System.assertEquals(
            DateTime.newInstance(2021, 3, 17, 5, 0, 0),
            updatedHierarchySettings.Async_Error_Check_Last_Run__c,
            'Async_Error_Check_Last_Run__c value should be updated.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the updateHierarchySettings method updates the Hierarchy Settings fields
     * for updates to fields with Boolean type.
     ***************************************************************************************************************************/
    @isTest
    private static void updateHierarchySettingsWithSingleValuesValidBoolean() {
        PermissionSetMapper.instance = new STUB_PermissionSetMapperHasAccess();
        HierarchySettingsMapper.instance = new STUB_HierarchySettingsMapper();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Allow_AutoCreated_Duplicates__c = false)
        );

        Map<String, String> singleValueSettingUpdatesByName = new Map<String, String>{
            UTIL_Namespace.StrTokenNSPrefix('Allow_AutoCreated_Duplicates__c') => 'true'
        };

        HierarchySettingsChangesVModel hierarchySettingsChangesVModelBooleanValues = new HierarchySettingsChangesVModel(
            singleValueSettingUpdatesByName,
            new Map<String, List<String>>()
        );

        HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();

        Test.startTest();
        Boolean updateResult = hierarchySettingsServiceInstance.updateHierarchySettings(
            hierarchySettingsChangesVModelBooleanValues
        );
        Test.stopTest();

        System.assertEquals(true, updateResult, 'Update to Boolean value should complete successfully.');

        Hierarchy_Settings__c updatedHierarchySettings = UTIL_CustomSettings_API.getSettings();

        System.assertEquals(
            true,
            updatedHierarchySettings.Allow_AutoCreated_Duplicates__c,
            'Allow_AutoCreated_Duplicates__c value should be updated.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the updateHierarchySetting method updates the Hierarchy Settings fields for
     * updates to fields with String type.
     ***************************************************************************************************************************/
    @isTest
    private static void updateHierarchySettingsWithSingleValuesValidString() {
        PermissionSetMapper.instance = new STUB_PermissionSetMapperHasAccess();
        HierarchySettingsMapper.instance = new STUB_HierarchySettingsMapper();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = 'Original Value')
        );

        Map<String, String> singleValueSettingUpdatesByName = new Map<String, String>{
            UTIL_Namespace.StrTokenNSPrefix('Account_Processor__c') => 'Updated Value'
        };

        HierarchySettingsChangesVModel hierarchySettingsChangesVModelStringValues = new HierarchySettingsChangesVModel(
            singleValueSettingUpdatesByName,
            new Map<String, List<String>>()
        );

        HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();

        Boolean updateResult;
        Test.startTest();
        updateResult = hierarchySettingsServiceInstance.updateHierarchySettings(
            hierarchySettingsChangesVModelStringValues
        );
        Test.stopTest();

        System.assertEquals(true, updateResult, 'Update to string value should complete successfully.');

        Hierarchy_Settings__c updatedHierarchySettings = UTIL_CustomSettings_API.getSettings();

        System.assertEquals(
            'Updated Value',
            updatedHierarchySettings.Account_Processor__c,
            'Account Processor value should be updated.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the denormalizeListSettingChange returns a semicolon-delimited string containing
     * all values in a specified list of strings.
     ***************************************************************************************************************************/
    @isTest
    private static void denormalizeListSettingChangeValid() {
        List<String> stringsToConvertList = new List<String>{ 'value1', 'value2', 'value3' };
        HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();

        Test.startTest();
        String denormalizedString = hierarchySettingsServiceInstance.denormalizeListSettingChange(stringsToConvertList);
        Test.stopTest();

        System.assertEquals(
            'value1;value2;value3',
            denormalizedString,
            'Should return semicolon-delimited string containing values in list.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the denormalizeListSettingChange returns an empty string when an empty list of
     * Strings is provided.
     ***************************************************************************************************************************/
    @isTest
    private static void denormalizeListSettingChangeEmptyList() {
        List<String> stringsToConvertList = new List<String>();
        HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();

        Test.startTest();
        String denormalizedString = hierarchySettingsServiceInstance.denormalizeListSettingChange(stringsToConvertList);
        Test.stopTest();

        System.assertEquals('', denormalizedString, 'Should return empty string.');
    }

    /**************************************************************************************************************************
     ****************************************************** STUBS **************************************************************
     **************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate a successful response from HierarchySettingsMapper
     **************************************************************************************************************************************/
    private class STUB_HierarchySettingsMapper extends HierarchySettingsMapper {
        public override Boolean updateHierarchySettings(HierarchySettingsModel hierarchySettingsModel) {
            return true;
        }
    }

    /*************************************************************************************************************
     * @description Stub class to simulate the response from PermissionSetMapper to return true
     */
    private class STUB_PermissionSetMapperHasAccess extends PermissionSetMapper {
        public override Boolean checkPermissionSetsWithViewSetupFromIds(Set<Id> permissionSetIdsSet) {
            return true;
        }
    }

    /*************************************************************************************************************
     * @description Stub class to simulate the response from PermissionSetMapper to return false
     */
    private class STUB_PermissionSetMapperNoAccess extends PermissionSetMapper {
        public override Boolean checkPermissionSetsWithViewSetupFromIds(Set<Id> permissionSetIdsSet) {
            return false;
        }
    }
}
