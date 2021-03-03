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
    * @description Test method to verify that the updateHierarchySettingsWithSingleValuesValid method updates the fields on a
    * HierarchySettingsModel for updates to fields with String type.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsWithSingleValuesValidString() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = 'Original Value'
            )
        );
        HierarchySettingsModel hierarchySettingsModelToUpdate = new HierarchySettingsModel(hierarchySettings);
        Map<String, String> singleValueSettingUpdatesByName = new Map<String, String>{
            'Account_Processor__c' => 'Updated Value'
        };

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        Test.startTest();
        HierarchySettingsModel hierarchySettingsModel = 
            hierarchySettingsMapperInstance.updateHierarchySettingsWithSingleValues(hierarchySettingsModelToUpdate, singleValueSettingUpdatesByName);
        Test.stopTest();

        System.assertEquals(
            'Updated Value', 
            hierarchySettingsModel.hierarchySettings.Account_Processor__c, 
            'Account Processor value should be updated.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the updateHierarchySettingsWithSingleValuesValid method updates the fields on a
    * HierarchySettingsModel for updates to fields with Boolean type.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsWithSingleValuesValidBoolean() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Allow_AutoCreated_Duplicates__c = false
            )
        );
        HierarchySettingsModel hierarchySettingsModelToUpdate = new HierarchySettingsModel(hierarchySettings);
        Map<String, String> singleValueSettingUpdatesByName = new Map<String, String>{
            'Allow_AutoCreated_Duplicates__c' => 'true'
        };

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        Test.startTest();
        HierarchySettingsModel hierarchySettingsModel = 
            hierarchySettingsMapperInstance.updateHierarchySettingsWithSingleValues(hierarchySettingsModelToUpdate, singleValueSettingUpdatesByName);
        Test.stopTest();

        System.assertEquals(
            true, 
            hierarchySettingsModel.hierarchySettings.Allow_AutoCreated_Duplicates__c, 
            'Allow_AutoCreated_Duplicates__c value should be updated.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the updateHierarchySettingsWithSingleValuesValid method updates the fields on a
    * HierarchySettingsModel for updates to fields with Datetime type.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsWithSingleValuesValidDateTime() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Async_Error_Check_Last_Run__c = Datetime.now().addDays(-3)
            )
        );
        HierarchySettingsModel hierarchySettingsModelToUpdate = new HierarchySettingsModel(hierarchySettings);
        Map<String, String> singleValueSettingUpdatesByName = new Map<String, String>{
            'Async_Error_Check_Last_Run__c' => String.valueOf(Datetime.now().addDays(-1))
        };

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        Test.startTest();
        HierarchySettingsModel hierarchySettingsModel = 
            hierarchySettingsMapperInstance.updateHierarchySettingsWithSingleValues(hierarchySettingsModelToUpdate, singleValueSettingUpdatesByName);
        Test.stopTest();

        System.assertEquals(
            Datetime.now().addDays(-1), 
            hierarchySettingsModel.hierarchySettings.Async_Error_Check_Last_Run__c, 
            'Async_Error_Check_Last_Run__c value should be updated.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the updateHierarchySettingsWithSingleValuesValid method throws an error when an 
    * update is made for a field that is not in Hierarchy Settings.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsWithSingleValuesInValidFieldName() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = 'Original Value'
            )
        );
        HierarchySettingsModel hierarchySettingsModelToUpdate = new HierarchySettingsModel(hierarchySettings);
        Map<String, String> singleValueSettingUpdatesByName = new Map<String, String>{
            'Account_Processor__c' => 'Updated Value',
            'Invalid_Field_Name__c' => 'Updated Invalid Value'
        };

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        try {
            Test.startTest();
            HierarchySettingsModel hierarchySettingsModel = 
                hierarchySettingsMapperInstance.updateHierarchySettingsWithSingleValues(hierarchySettingsModelToUpdate, singleValueSettingUpdatesByName);
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
    * @description Test method to verify that the updateHierarchySettingsWithSingleValuesValid method throws an error when a 
    * mapping to an invalid Hierarchy Settings field is updated.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsWithSingleValuesInValidDateTime() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Async_Error_Check_Last_Run__c = Datetime.now().addDays(-1)
            )
        );
        HierarchySettingsModel hierarchySettingsModelToUpdate = new HierarchySettingsModel(hierarchySettings);
        Map<String, String> singleValueSettingUpdatesByName = new Map<String, String>{
            'Async_Error_Check_Last_Run__c' => 'Updated Value'
        };

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        try {
            Test.startTest();
            HierarchySettingsModel hierarchySettingsModel = 
                hierarchySettingsMapperInstance.updateHierarchySettingsWithSingleValues(hierarchySettingsModelToUpdate, singleValueSettingUpdatesByName);
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
    * @description Test method to verify that the updateHierarchySettingsWithSingleValuesValid method does not update the fields on a
    * HierarchySettingsModel for updates to fields with primitive data types when no updates are specified.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsWithSingleValuesEmpty() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = 'Original Value'
            )
        );
        HierarchySettingsModel hierarchySettingsModelToUpdate = new HierarchySettingsModel(hierarchySettings);
        Map<String, String> singleValueSettingUpdatesByName = new Map<String, String>();

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        Test.startTest();
        HierarchySettingsModel hierarchySettingsModel = 
            hierarchySettingsMapperInstance.updateHierarchySettingsWithSingleValues(hierarchySettingsModelToUpdate, singleValueSettingUpdatesByName);
        Test.stopTest();

        System.assertEquals(
            'Original Value', 
            hierarchySettingsModel.hierarchySettings.Account_Processor__c, 
            'Account Processor value should remain unchanged.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the updateHierarchySettingsWithListValues method updates the specified fields 
    * of type collection on a HierarchySettingsModel.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsWithListValuesValid() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Accounts_to_Delete__c = 'Original Value1;Original Value2'
            )
        );
        HierarchySettingsModel hierarchySettingsModelToUpdate = new HierarchySettingsModel(hierarchySettings);
        Map<String, List<String>> listValueSettingUpdatesByName = new Map<String, List<String>>{
            'Accounts_to_Delete__c' => new List<String>{'Updated Value 1', 'Updated Value 2'}
        };

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        Test.startTest();
        HierarchySettingsModel hierarchySettingsModel = 
            hierarchySettingsMapperInstance.updateHierarchySettingsWithListValues(hierarchySettingsModelToUpdate, listValueSettingUpdatesByName);
        Test.stopTest();

        System.assertEquals(
            'Updated Value 1;Updated Value 2', 
            hierarchySettingsModel.hierarchySettings.Accounts_to_Delete__c, 
            'Accounts_to_Delete__c value should be updated.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the updateHierarchySettingsWithListValues method does not update the specified fields 
    * of type collection on a HierarchySettingsModel when no updates are specified.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsWithListValuesEmpty() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Accounts_to_Delete__c = 'Original Value1;Original Value2'
            )
        );
        HierarchySettingsModel hierarchySettingsModelToUpdate = new HierarchySettingsModel(hierarchySettings);
        Map<String, List<String>> listValueSettingUpdatesByName = new Map<String, List<String>>();

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        Test.startTest();
        HierarchySettingsModel hierarchySettingsModel = 
            hierarchySettingsMapperInstance.updateHierarchySettingsWithListValues(hierarchySettingsModelToUpdate, listValueSettingUpdatesByName);
        Test.stopTest();

        System.assertEquals(
            'Original Value1;Original Value2', 
            hierarchySettingsModel.hierarchySettings.Accounts_to_Delete__c, 
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
        HierarchySettingsModel hierarchySettingsModelToUpdate = new HierarchySettingsModel(hierarchySettings);
        Map<String, List<String>> listValueSettingUpdatesByName = new Map<String, List<String>>{
            'Accounts_to_Delete__c' => new List<String>{'Updated Value 1', 'Updated Value 2'},
            'Not_A_Valid_Field__c' => new List<String>{'Invalid value'}
        };

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        try {
            Test.startTest();
            HierarchySettingsModel hierarchySettingsModel = 
                hierarchySettingsMapperInstance.updateHierarchySettingsWithListValues(hierarchySettingsModelToUpdate, listValueSettingUpdatesByName);
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

        Map<String, String> singleValueSettingUpdatesByName = new Map<String, String>{
            'Account_Processor__c' => 'Updated Value'
        };

        Map<String, List<String>> listValueSettingUpdatesByName = new Map<String, List<String>>{
            'Accounts_to_Delete__c' => new List<String>{'Updated Value 1', 'Updated Value 2'}
        };

        HierarchySettingsChangesModel hierarchySettingsChangesModel = new HierarchySettingsChangesModel(
            singleValueSettingUpdatesByName,
            listValueSettingUpdatesByName
        );

        HierarchySettingsMapper hierarchySettingsMapperInstance = HierarchySettingsMapper.getInstance();

        Test.startTest();
        HierarchySettingsModel hierarchySettingsModel = hierarchySettingsMapperInstance.updateHierarchySettings(hierarchySettingsChangesModel);
        Test.stopTest();

        System.assertEquals(
            'Updated Value', 
            hierarchySettingsModel.hierarchySettings.Account_Processor__c, 
            'Hierarchy Settings model value should be updated.'
        );

        System.assertEquals(
            'Updated Value 1;Updated Value 2', 
            hierarchySettingsModel.hierarchySettings.Accounts_to_Delete__c, 
            'Hierarchy Settings model value should be updated.'
        );
    }
}
