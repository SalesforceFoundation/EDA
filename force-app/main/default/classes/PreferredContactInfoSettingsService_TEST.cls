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
 * @group-content ../../ApexDocContent/
 * @description Test class for PreferredContactInfoSettingsService class.
 */
@isTest
private with sharing class PreferredContactInfoSettingsService_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * PreferredContactInfoSettingsService class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        PreferredContactInfoSettingsService preferredContactInfoSettingsServiceInstance = PreferredContactInfoSettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(
            PreferredContactInfoSettingsService.instance,
            preferredContactInfoSettingsServiceInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            preferredContactInfoSettingsServiceInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * PreferredContactInfoSettingsService class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        PreferredContactInfoSettingsService preferredContactInfoSettingsService1 = PreferredContactInfoSettingsService.getInstance();
        PreferredContactInfoSettingsService preferredContactInfoSettingsService2 = PreferredContactInfoSettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(
            PreferredContactInfoSettingsService.instance,
            preferredContactInfoSettingsService1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            preferredContactInfoSettingsService1,
            preferredContactInfoSettingsService2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            preferredContactInfoSettingsService1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the locatePreferredContactInfoSettingsMapper method returns instance of PreferredContactInfoSettingsMapper
     ***********************************************************************************************************************************/
    @isTest
    private static void locatePreferredContactInfoSettingsMapper() {
        PreferredContactInfoSettingsService preferredContactInfoSettingsServiceInstance = PreferredContactInfoSettingsService.getInstance();

        Test.startTest();
        PreferredContactInfoSettingsMapper preferredContactInfoSettingsMapperInstance = preferredContactInfoSettingsServiceInstance.locatePreferredContactInfoSettingsMapper();
        Test.stopTest();

        System.assertEquals(
            PreferredContactInfoSettingsMapper.getInstance(),
            preferredContactInfoSettingsMapperInstance,
            'Should return the instance of PreferredContactInfoSettingsMapper'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getPreferredContactInfoSettingsModel method returns a valid PreferredContactInfoSettingsModel
     ***********************************************************************************************************************************/
    @isTest
    private static void getPreferredContactInfoSettingsModelValid() {
        PreferredContactInfoSettingsMapper.instance = new STUB_PreferredContactInfoSettingsMapper();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Disable_Preferred_Email_Enforcement__c = false,
                Enable_New_Preferred_Phone_Sync__c = true,
                Disable_Preferred_Phone_Enforcement__c = false,
                Preferred_Phone_Selection__c = 'Test Phone Field'
            )
        );

        PreferredContactInfoSettingsService preferredContactInfoSettingsServiceInstance = PreferredContactInfoSettingsService.getInstance();

        Test.startTest();
        PreferredContactInfoSettingsModel preferredContactInfoSettingsModel = preferredContactInfoSettingsServiceInstance.getPreferredContactInfoSettingsModel();
        Test.stopTest();

        System.assertEquals(
            true,
            preferredContactInfoSettingsModel.requirePreferredEmail,
            'Should be set to inverse of value in hierarchy settings.'
        );
        System.assertEquals(
            true,
            preferredContactInfoSettingsModel.enhancedPhoneFunctionality,
            'Should match value in hierarchy settings.'
        );
        System.assertEquals(
            true,
            preferredContactInfoSettingsModel.preferredPhoneEnforcement,
            'Should be set to inverse of value in hierarchy settings.'
        );
        System.assertEquals(
            'Test Phone Field',
            preferredContactInfoSettingsModel.defaultPreferredPhone,
            'Should match value in hierarchy settings.'
        );
    }

    /***********************************************************************************************************************************
     ****************************************************** STUBS ***********************************************************************
     ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from PreferredContactInfoSettingsMapper to return a valid PreferredContactInfoSettingsModel
     **************************************************************************************************************************************/
    private class STUB_PreferredContactInfoSettingsMapper extends PreferredContactInfoSettingsMapper {
        public override PreferredContactInfoSettingsModel getPreferredContactInfoSettingsModel() {
            return new PreferredContactInfoSettingsModel(true, true, true, 'Test Phone Field');
        }
    }
}
