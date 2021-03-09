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
* @description Test class for HierarchySettingsMapper class
*/
@isTest
public inherited sharing class HierarchySettingsMapper_TEST {
   /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * HierarchySettingsMapper class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            HierarchySettingsMapper.instance, 
            hierarchySettingsMapperInstance, 
            'Instance of mapper class returned should match static instance variable.'
        );

        System.assertEquals(
            true, 
            hierarchySettingsMapperInstance != null, 
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * HierarchySettingsMapper class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            HierarchySettingsMapper hierarchySettingsMapperInstance1 = HierarchySettingsMapper.getInstance();
            HierarchySettingsMapper hierarchySettingsMapperInstance2 = HierarchySettingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            HierarchySettingsMapper.instance, 
            hierarchySettingsMapperInstance1, 
            'Instance of mapper class returned should match static instance variable.'
        );

        System.assertEquals(
            hierarchySettingsMapperInstance1, 
            hierarchySettingsMapperInstance2, 
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );

        System.assertEquals(
            true, 
            hierarchySettingsMapperInstance1 != null, 
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getHierarchySettings method returns the values specified in Hierarchy Settings.
    ***************************************************************************************************************************/
    @isTest 
    private static void getHierarchySettingsValid() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c( 
                Account_Processor__c = 'Test Account'
            )
        );

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        Test.startTest();
        HierarchySettingsModel hierarchySettingsModel = hierarchySettingsMapperInstance.getHierarchySettings();
        Test.stopTest();

        System.assertEquals(
            'Test Account', 
            hierarchySettingsModel.hierarchySettings.Account_Processor__c,
            'Account_Processor__c hierarchy setting should match specified value.'    
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getHierarchySettingsField method returns the DescribeFieldResult for a 
    * specified Hierarchy Settings field.
    ***************************************************************************************************************************/
    @isTest 
    private static void getHierarchySettingsFieldValid() {
        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        Test.startTest();
        Schema.DescribeFieldResult describeFieldResult = 
            hierarchySettingsMapperInstance.getHierarchySettingsField(UTIL_Namespace.StrTokenNSPrefix('Account_Processor__c'));
        Test.stopTest();

        System.assertEquals(
            'Account Processor', 
            describeFieldResult.getLabel(), 
            'Should match field label value specified for Account Processor.'
        );
        System.assertEquals(
            UTIL_Namespace.StrTokenNSPrefix('Account_Processor__c'), 
            describeFieldResult.getName(), 
            'Should match api name value specified for Account Processor.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getHierarchySettingsField method throws an exception for a field
    * that is not specified in Hierarchy Settings.
    ***************************************************************************************************************************/
    @isTest 
    private static void getHierarchySettingsFieldInValid() {
        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        try {
            Test.startTest();
            Schema.DescribeFieldResult describeFieldResult = 
                hierarchySettingsMapperInstance.getHierarchySettingsField(UTIL_Namespace.StrTokenNSPrefix('Invalid_Field_Name__c'));
            Test.stopTest();
        } catch (UTIL_Describe.SchemaDescribeException e) {
            System.assertEquals(
                'Invalid field name \'' + UTIL_Namespace.StrTokenNSPrefix('Invalid_Field_Name__c') + '\'', 
                e.getMessage(), 
                'Invalid field name should cause exception'
            );
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the updateHierarchySetting method updates the Hierarchy Settings fields for 
    * updates to fields with String type.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsWithSingleValuesValidString() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = 'Original Value'
            )
        );
        insert hierarchySettings;
        
        Map<String, String> singleValueSettingUpdatesByName = new Map<String, String>{
            UTIL_Namespace.StrTokenNSPrefix('Account_Processor__c') => 'Updated Value'
        };

        HierarchySettingsChangesModel hierarchySettingsChangesModelStringValues = 
            new HierarchySettingsChangesModel(
                singleValueSettingUpdatesByName,
                new Map<String, List<String>>()
            );

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        Boolean updateResult;
        Test.startTest();
            updateResult = 
            hierarchySettingsMapperInstance.updateHierarchySettings(hierarchySettingsChangesModelStringValues);        
        Test.stopTest();

        System.assertEquals(
            true, 
            updateResult,
            'Update to string value should complete successfully.');

        Hierarchy_Settings__c updatedHierarchySettings = UTIL_CustomSettings_API.getSettings();

        System.assertEquals(
            'Updated Value', 
            updatedHierarchySettings.Account_Processor__c, 
            'Account Processor value should be updated.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the updateHierarchySettings method updates the Hierarchy Settings fields
    * for updates to fields with Boolean type.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsWithSingleValuesValidBoolean() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Allow_AutoCreated_Duplicates__c = false
            )
        );
        insert hierarchySettings;

        Map<String, String> singleValueSettingUpdatesByName = new Map<String, String>{
            UTIL_Namespace.StrTokenNSPrefix('Allow_AutoCreated_Duplicates__c') => 'true'
        };

        HierarchySettingsChangesModel hierarchySettingsChangesModelBooleanValues = 
            new HierarchySettingsChangesModel(
                singleValueSettingUpdatesByName,
                new Map<String, List<String>>()
            );

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        Test.startTest();
        Boolean updateResult = 
            hierarchySettingsMapperInstance.updateHierarchySettings(hierarchySettingsChangesModelBooleanValues);
        Test.stopTest();

        System.assertEquals(
            true, 
            updateResult,
            'Update to Boolean value should complete successfully.');

        Hierarchy_Settings__c updatedHierarchySettings = UTIL_CustomSettings_API.getSettings();

        System.assertEquals(
            true, 
            updatedHierarchySettings.Allow_AutoCreated_Duplicates__c, 
            'Allow_AutoCreated_Duplicates__c value should be updated.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the updateHierarchySettings method updates the Hierarchy Settings fields
    * for updates to fields with Datetime type.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsWithSingleValuesValidDateTime() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Async_Error_Check_Last_Run__c = Datetime.now().addDays(-3)
            )
        );
        insert hierarchySettings;

        Map<String, String> singleValueSettingUpdatesByName = new Map<String, String>{
            UTIL_Namespace.StrTokenNSPrefix('Async_Error_Check_Last_Run__c') => String.valueOf(DateTime.newInstance(2021, 03, 17, 5, 0, 0))
        };

        HierarchySettingsChangesModel hierarchySettingsChangesModelDateTimeValues = 
            new HierarchySettingsChangesModel(
                singleValueSettingUpdatesByName,
                new Map<String, List<String>>()
            );

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        Test.startTest();
        Boolean updateResult = 
            hierarchySettingsMapperInstance.updateHierarchySettings(hierarchySettingsChangesModelDateTimeValues);
        Test.stopTest();

        System.assertEquals(
            true, 
            updateResult,
            'Update to DateTime value should complete successfully.');

        Hierarchy_Settings__c updatedHierarchySettings = UTIL_CustomSettings_API.getSettings();

        System.assertEquals(
            DateTime.newInstance(2021, 03, 17, 5, 0, 0), 
            updatedHierarchySettings.Async_Error_Check_Last_Run__c, 
            'Async_Error_Check_Last_Run__c value should be updated.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the updateHierarchySettings method throws an error when an 
    * update is made for a field that is not in Hierarchy Settings.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsWithSingleValuesInValidFieldName() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = 'Original Value'
            )
        );
        insert hierarchySettings;

        Map<String, String> singleValueSettingUpdatesByName = new Map<String, String>{
            UTIL_Namespace.StrTokenNSPrefix('Account_Processor__c') => 'Updated Value',
            UTIL_Namespace.StrTokenNSPrefix('Invalid_Field_Name__c') => 'Updated Invalid Value'
        };

        HierarchySettingsChangesModel hierarchySettingsChangesModelError = new HierarchySettingsChangesModel(
            singleValueSettingUpdatesByName,
            new Map<String, List<String>>()
        );

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        try {
            Test.startTest();
            Boolean updateResult = 
                hierarchySettingsMapperInstance.updateHierarchySettings(hierarchySettingsChangesModelError);
            Test.stopTest();
        } catch (UTIL_Describe.SchemaDescribeException e) {
            System.assertEquals(
                'Invalid field name \'' + UTIL_Namespace.StrTokenNSPrefix('Invalid_Field_Name__c') + '\'', 
                e.getMessage(), 
                'Invalid mapping should throw exception.'
            );
        } catch (HierarchySettingsMapper.InvalidSettingsException e) {
            System.assertEquals(
                Label.stgErrorInvalidSettings,  
                e.getMessage(),
                'Invalid mapping should throw exception.'
            );
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the updateHierarchySettings method throws an error when a field is mapped to a 
    * Hierarchy Settings field with the wrong data type is updated.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsWithSingleValuesInValidDateTime() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Async_Error_Check_Last_Run__c = Datetime.now().addDays(-1)
            )
        );
        insert hierarchySettings;

        Map<String, String> singleValueSettingUpdatesByName = new Map<String, String>{
            UTIL_Namespace.StrTokenNSPrefix('Async_Error_Check_Last_Run__c') => 'Updated Value'
        };

        HierarchySettingsChangesModel hierarchySettingsChangesModelInvalidType = new HierarchySettingsChangesModel(
            singleValueSettingUpdatesByName,
            new Map<String, List<String>>()
        );

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        try {
            Test.startTest();
            Boolean updateResult = 
                hierarchySettingsMapperInstance.updateHierarchySettings(hierarchySettingsChangesModelInvalidType);
            Test.stopTest();
        } catch (System.TypeException e) {
            System.assertEquals(
                'Invalid date/time: Updated Value',
                e.getMessage(), 
                'Invalid mapping should throw exception.'
            );
        } catch (HierarchySettingsMapper.InvalidSettingsException e) {
            System.assertEquals(
                Label.stgErrorInvalidSettings,  
                e.getMessage(),
                'Invalid mapping should throw exception.'
            );
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the updateHierarchySettings method does not update Hierarchy Settings fields
    * when updates for a primitive data type are not specified.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsWithSingleValuesEmpty() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = 'Original Value'
            )
        );
        insert hierarchySettings;

        Map<String, String> singleValueSettingUpdatesByName = new Map<String, String>();

        HierarchySettingsChangesModel hierarchySettingsChangesModelEmptySingleValues= new HierarchySettingsChangesModel(
            singleValueSettingUpdatesByName,
            new Map<String, List<String>>()
        );

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        Test.startTest();
        Boolean updateResult = 
            hierarchySettingsMapperInstance.updateHierarchySettings(hierarchySettingsChangesModelEmptySingleValues);
        Test.stopTest();

        System.assertEquals(
            true, 
            updateResult,
            'Update to string value should complete successfully.'
        );

        Hierarchy_Settings__c updatedHierarchySettings = UTIL_CustomSettings_API.getSettings();

        System.assertEquals(
            'Original Value', 
            updatedHierarchySettings.Account_Processor__c, 
            'Account Processor value should remain unchanged.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the updateHierarchySettings method updates the specified Hierarchy Settings fields 
    * of a collection type.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsWithListValuesValid() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Accounts_to_Delete__c = 'Original Value1;Original Value2'
            )
        );
        insert hierarchySettings;

        Map<String, List<String>> listValueSettingUpdatesByName = new Map<String, List<String>>{
            UTIL_Namespace.StrTokenNSPrefix('Accounts_to_Delete__c') => new List<String>{'Updated Value 1', 'Updated Value 2'}
        };

        HierarchySettingsChangesModel hierarchySettingsChangesModelListValues = new HierarchySettingsChangesModel(
            new Map<String, String>(),
            listValueSettingUpdatesByName
        );

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        Test.startTest();
        Boolean updateResult = 
            hierarchySettingsMapperInstance.updateHierarchySettings(hierarchySettingsChangesModelListValues);
        Test.stopTest();

        System.assertEquals(
            true, 
            updateResult,
            'Update to string value should complete successfully.'
        );

        Hierarchy_Settings__c updatedHierarchySettings = UTIL_CustomSettings_API.getSettings();

        System.assertEquals(
            'Updated Value 1;Updated Value 2', 
            updatedHierarchySettings.Accounts_to_Delete__c, 
            'Accounts_to_Delete__c value should be updated.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the updateHierarchySettings method does not update the specified Hierarchy
    * Settings fields of type collection when no updates are specified.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsWithListValuesEmpty() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Accounts_to_Delete__c = 'Original Value1;Original Value2'
            )
        );
        insert hierarchySettings;

        Map<String, List<String>> listValueSettingUpdatesByName = new Map<String, List<String>>();

        HierarchySettingsChangesModel hierarchySettingsChangesModelListValuesEmpty = new HierarchySettingsChangesModel(
            new Map<String, String>(),
            listValueSettingUpdatesByName
        );

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        Test.startTest();
        Boolean updateResult = 
            hierarchySettingsMapperInstance.updateHierarchySettings(hierarchySettingsChangesModelListValuesEmpty);
        Test.stopTest();

        System.assertEquals(
            true, 
            updateResult,
            'Update to string value should complete successfully.'
        );

        Hierarchy_Settings__c updatedHierarchySettings = UTIL_CustomSettings_API.getSettings();

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
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Accounts_to_Delete__c = 'Original Value1;Original Value2'
            )
        );
        insert hierarchySettings;

        Map<String, List<String>> listValueSettingUpdatesByName = new Map<String, List<String>>{
            UTIL_Namespace.StrTokenNSPrefix('Accounts_to_Delete__c') => new List<String>{'Updated Value 1', 'Updated Value 2'},
            UTIL_Namespace.StrTokenNSPrefix('Not_A_Valid_Field__c') => new List<String>{'Invalid value'}
        };

        HierarchySettingsChangesModel hierarchySettingsChangesModelListValuesError = new HierarchySettingsChangesModel(
            new Map<String, String>(),
            listValueSettingUpdatesByName
        );

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        try {
            Test.startTest();
            Boolean updateResult = 
                hierarchySettingsMapperInstance.updateHierarchySettings(hierarchySettingsChangesModelListValuesError);
            Test.stopTest();
        } catch (UTIL_Describe.SchemaDescribeException e) {
            System.assertEquals(
                'Invalid field name \'' + UTIL_Namespace.StrTokenNSPrefix('Not_A_Valid_Field__c') + '\'', 
                e.getMessage(), 
                'Invalid field mapping should throw error.'
            );
        } catch (HierarchySettingsMapper.InvalidSettingsException e) {
            System.assertEquals(
                Label.stgErrorInvalidSettings,  
                e.getMessage(),
                'Invalid mapping should throw exception.'
            );
        } 
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the updateHierarchySettings method throws an error and does not update any 
    * Hierarchy Settings fields when an error is encountered.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsUpdateError() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = 'Original Account',
                Accounts_to_Delete__c = 'Original Value1;Original Value2'
            )
        );
        insert hierarchySettings;

        Map<String, String> singleValueSettingUpdatesByNameInvalid = new Map<String, String>{
            UTIL_Namespace.StrTokenNSPrefix('Account_Processor_Invalid__c') => 'Updated Value'
        };

        Map<String, List<String>> listValueSettingUpdatesByName = new Map<String, List<String>>{
            UTIL_Namespace.StrTokenNSPrefix('Accounts_to_Delete__c') => new List<String>{'Updated Value 1', 'Updated Value 2'}
        };

        HierarchySettingsChangesModel hierarchySettingsChangesModel = new HierarchySettingsChangesModel(
            singleValueSettingUpdatesByNameInvalid,
            listValueSettingUpdatesByName
        );

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        try {
            Test.startTest();
            Boolean updateResult = 
                hierarchySettingsMapperInstance.updateHierarchySettings(hierarchySettingsChangesModel);
            Test.stopTest();
        } catch (UTIL_Describe.SchemaDescribeException e) {
            System.assertEquals(
                'Invalid field name \'' + UTIL_Namespace.StrTokenNSPrefix('Account_Processor_Invalid__c') + '\'', 
                e.getMessage(), 
                'Invalid field name should cause exception'
            );
        } catch (HierarchySettingsMapper.InvalidSettingsException e) {
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
    * @description Test method to verify that the updateHierarchySettings method updates Hierarchy Setting values of both
    * primitive and collection data types.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsValid() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = 'Original Account',
                Accounts_to_Delete__c = 'Original Value1;Original Value2'
            )
        );
        insert hierarchySettings;

        Map<String, String> singleValueSettingUpdatesByName = new Map<String, String>{
            UTIL_Namespace.StrTokenNSPrefix('Account_Processor__c') => 'Updated Value'
        };

        Map<String, List<String>> listValueSettingUpdatesByName = new Map<String, List<String>>{
            UTIL_Namespace.StrTokenNSPrefix('Accounts_to_Delete__c') => new List<String>{'Updated Value 1', 'Updated Value 2'}
        };

        HierarchySettingsChangesModel hierarchySettingsChangesModel = new HierarchySettingsChangesModel(
            singleValueSettingUpdatesByName,
            listValueSettingUpdatesByName
        );

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        Test.startTest();
        Boolean updateResult = 
            hierarchySettingsMapperInstance.updateHierarchySettings(hierarchySettingsChangesModel);
        Test.stopTest();

        System.assertEquals(true, updateResult, 'Update should complete successfully.');

        Hierarchy_Settings__c updatedHierarchySettings = UTIL_CustomSettings_API.getSettings();

        System.assertEquals(
            'Updated Value', 
            updatedHierarchySettings.Account_Processor__c, 
            'Account_Processor__c value should be updated.'
        );

        System.assertEquals(
            'Updated Value 1;Updated Value 2', 
            updatedHierarchySettings.Accounts_to_Delete__c, 
            'Accounts_to_Delete__c value should be updated.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the denormalizeListSettingChange returns a semicolon-delimited string containing
    * all values in a specified list of strings.
    ***************************************************************************************************************************/
    @isTest 
    private static void denormalizeListSettingChangeValid() {
        List<String> stringsToConvertList = new List<String>{'value1', 'value2', 'value3'};
        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        Test.startTest();
        String denormalizedString = hierarchySettingsMapperInstance.denormalizeListSettingChange(stringsToConvertList);
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
        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        Test.startTest();
        String denormalizedString = hierarchySettingsMapperInstance.denormalizeListSettingChange(stringsToConvertList);
        Test.stopTest();

        System.assertEquals(
            '', 
            denormalizedString,
            'Should return empty string.'
        );
    }
}
