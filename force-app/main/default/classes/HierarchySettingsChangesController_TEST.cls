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
* @description Test class for HierarchySettingsChangesController class
*/
@isTest
public with sharing class HierarchySettingsChangesController_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the locateHierarchySettingsUpdaterService method returns an instance of the
    * HierarchySettingsService class.
    ***************************************************************************************************************************/
    @isTest 
    private static void locateHierarchySettingsUpdaterServiceValid() {
        Test.startTest();
        HierarchySettingsService hierarchySettingsServiceInstance = 
            HierarchySettingsChangesController.locateHierarchySettingsUpdaterService();
        Test.stopTest();

        System.assertEquals(
            HierarchySettingsService.instance, 
            hierarchySettingsServiceInstance,
            'Should return instance of HierarchySettingsService class.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the updateHierarchySettings method returns true when an update to Hierarchy
    * Settings is successfully processed.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsValid() {
        HierarchySettingsService.instance = new STUB_HierarchySettingsService();

        Map<String, String> settingsSingleValueBySettingsName = new Map<String, String> {
            'Value1' => 'Changed Value 1'
        };

        Map<String, List<String>> settingsListSettingsName = new Map<String, List<String>> {
            'CollectionValue1' => new List<String>{'Change1', 'Change2', 'Change3'}
        };

        HierarchySettingsChangesVModel hierarchySettingsChangesVModel = 
            new HierarchySettingsChangesVModel(settingsSingleValueBySettingsName, settingsListSettingsName);

        Test.startTest();
        Boolean updateHierarchySettingsResult = 
            HierarchySettingsChangesController.updateHierarchySettings(hierarchySettingsChangesVModel);
        Test.stopTest();

        System.assertEquals(
            true, 
            updateHierarchySettingsResult,
            'Should return true indicating a successful update.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the updateHierarchySettings method returns false when an update to Hierarchy
    * Settings is fails due to a DML exception.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsInValid() {
        HierarchySettingsService.instance = new STUB_HierarchySettingsServiceDMLFailure();

        Map<String, String> settingsSingleValueBySettingsName = new Map<String, String> {
            'Value1' => 'Changed Value 1'
        };

        Map<String, List<String>> settingsListSettingsName = new Map<String, List<String>> {
            'CollectionValue1' => new List<String>{'Change1', 'Change2', 'Change3'}
        };

        HierarchySettingsChangesVModel hierarchySettingsChangesVModel = 
            new HierarchySettingsChangesVModel(settingsSingleValueBySettingsName, settingsListSettingsName);

        Test.startTest();
        Boolean updateHierarchySettingsResult = 
            HierarchySettingsChangesController.updateHierarchySettings(hierarchySettingsChangesVModel);
        Test.stopTest();

        System.assertEquals(
            false, 
            updateHierarchySettingsResult,
            'Should return true indicating a failure due to a DML Exception.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the updateHierarchySettings method throws an exception when the update fails due
    * to inadequate permissions or casting errors.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsException() {
        HierarchySettingsService.instance = new STUB_HierarchySettingsExceptionResponse();

        Map<String, String> settingsSingleValueBySettingsName = new Map<String, String> {
            UTIL_Namespace.StrTokenNSPrefix('Value1') => 'Changed Value 1'
        };

        Map<String, List<String>> settingsListSettingsName = new Map<String, List<String>> {
            UTIL_Namespace.StrTokenNSPrefix('CollectionValue1') => new List<String>{'Change1', 'Change2', 'Change3'}
        };

        HierarchySettingsChangesVModel hierarchySettingsChangesVModel = 
            new HierarchySettingsChangesVModel(settingsSingleValueBySettingsName, settingsListSettingsName);

        try {
            Test.startTest();
            Boolean updateHierarchySettingsResult = 
                HierarchySettingsChangesController.updateHierarchySettings(hierarchySettingsChangesVModel);
            Test.stopTest();
        } catch (TestException e) {
            System.assertEquals(
                'Test Exception Encountered', 
                e.getMessage(),
                'Should throw a TestException.'
            );
        }        
    }
    /**************************************************************************************************************************
    ****************************************************** STUBS **************************************************************
    **************************************************************************************************************************/
    
    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from HierarchySettingsService to indicate a successful update
    **************************************************************************************************************************************/ 
    private class STUB_HierarchySettingsService extends HierarchySettingsService {
        public override Boolean updateHierarchySettings(HierarchySettingsChangesVModel hierarchySettingsChangesVModel) {
            return true;
        }
    }
    
    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from HierarchySettingsService to indicate a failure due to a DML exception.
    **************************************************************************************************************************************/ 
    private class STUB_HierarchySettingsServiceDMLFailure extends HierarchySettingsService {
        public override Boolean updateHierarchySettings(HierarchySettingsChangesVModel hierarchySettingsChangesVModel) {
            return false;
        }
    }

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from HierarchySettingsService to indicate a failure due to a DML exception.
    **************************************************************************************************************************************/ 
    private class STUB_HierarchySettingsExceptionResponse extends HierarchySettingsService {
        public override Boolean updateHierarchySettings(HierarchySettingsChangesVModel hierarchySettingsChangesVModel) {
            throw new TestException('Test Exception Encountered');
        }
    }

    /********************************************************************************************************
    * @description A custom exception class to for testing.
    ********************************************************************************************************/
    public class TestException extends Exception {}
}
