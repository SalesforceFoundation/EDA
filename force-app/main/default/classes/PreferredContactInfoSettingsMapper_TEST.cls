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
 * @description Test class for PreferredContactInfoSettingsMapper class.
 */
@isTest
private with sharing class PreferredContactInfoSettingsMapper_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * PreferredContactInfoSettingsMapper class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        PreferredContactInfoSettingsMapper preferredContactInfoSettingsMapperInstance = PreferredContactInfoSettingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            PreferredContactInfoSettingsMapper.instance,
            preferredContactInfoSettingsMapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            preferredContactInfoSettingsMapperInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * PreferredContactInfoSettingsMapper class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        PreferredContactInfoSettingsMapper preferredContactInfoSettingsMapper1 = PreferredContactInfoSettingsMapper.getInstance();
        PreferredContactInfoSettingsMapper preferredContactInfoSettingsMapper2 = PreferredContactInfoSettingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            PreferredContactInfoSettingsMapper.instance,
            preferredContactInfoSettingsMapper1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            preferredContactInfoSettingsMapper1,
            preferredContactInfoSettingsMapper2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            preferredContactInfoSettingsMapper1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getPreferredContactInfoSettingsModel method returns a PreferredContactInfoSettingsModel
     * with all properties set to match the corresponding values in hierarchy settings.  In the case of Disable_Preferred_Email_Enforcement__c
     * and Disable_Preferred_Phone_Enforcement__c, the model values should be the invers of the hierarchy setting values.
     ***************************************************************************************************************************/
    @isTest
    private static void getPreferredContactInfoSettingsModelValid() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Disable_Preferred_Email_Enforcement__c = true, //false
                Enable_New_Preferred_Phone_Sync__c = true,
                Disable_Preferred_Phone_Enforcement__c = true, //false
                Preferred_Phone_Selection__c = 'Test Phone Field'
            )
        );
        PreferredContactInfoSettingsMapper preferredContactInfoSettingsMapperInstance = PreferredContactInfoSettingsMapper.getInstance();

        Test.startTest();
        PreferredContactInfoSettingsModel preferredContactInfoSettingsModel = preferredContactInfoSettingsMapperInstance.getPreferredContactInfoSettingsModel();
        Test.stopTest();

        System.assertEquals(
            false,
            preferredContactInfoSettingsModel.requirePreferredEmail,
            'True value for hierarchy setting Disable_Preferred_Email_Enforcement__c, should set requirePreferredEmail property to false.'
        );

        System.assertEquals(
            true,
            preferredContactInfoSettingsModel.enhancedPhoneFunctionality,
            'True value for hierarchy setting Enable_New_Preferred_Phone_Sync__c, should set enhancedPhoneFunctionality property to true.'
        );

        System.assertEquals(
            false,
            preferredContactInfoSettingsModel.preferredPhoneEnforcement,
            'True value for hierarchy setting Disable_Preferred_Phone_Enforcement__c, should set preferredPhoneEnforcement property to false.'
        );

        System.assertEquals(
            'Test Phone Field',
            preferredContactInfoSettingsModel.defaultPreferredPhone,
            'defaultPreferredPhone property should be set to match Preferred_Phone_Selection__c hierarchy setting.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getPreferredContactInfoSettingsModel method returns a PreferredContactInfoSettingsModel
     * with all properties set to match the corresponding values in hierarchy settings and specify a blank value when no preferred
     * phone value is specified.  In the case of Disable_Preferred_Email_Enforcement__c
     * and Disable_Preferred_Phone_Enforcement__c, the model values should be the invers of the hierarchy setting values.
     ***************************************************************************************************************************/
    @isTest
    private static void getPreferredContactInfoSettingsModelBlankString() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Disable_Preferred_Email_Enforcement__c = false, //true
                Enable_New_Preferred_Phone_Sync__c = false,
                Disable_Preferred_Phone_Enforcement__c = false, //true
                Preferred_Phone_Selection__c = ''
            )
        );
        PreferredContactInfoSettingsMapper preferredContactInfoSettingsMapperInstance = PreferredContactInfoSettingsMapper.getInstance();

        Test.startTest();
        PreferredContactInfoSettingsModel preferredContactInfoSettingsModel = preferredContactInfoSettingsMapperInstance.getPreferredContactInfoSettingsModel();
        Test.stopTest();

        System.assertEquals(
            true,
            preferredContactInfoSettingsModel.requirePreferredEmail,
            'False value for hierarchy setting Disable_Preferred_Email_Enforcement__c, should set requirePreferredEmail property to true.'
        );

        System.assertEquals(
            false,
            preferredContactInfoSettingsModel.enhancedPhoneFunctionality,
            'False value for hierarchy setting Enable_New_Preferred_Phone_Sync__c, should set enhancedPhoneFunctionality property to false.'
        );

        System.assertEquals(
            true,
            preferredContactInfoSettingsModel.preferredPhoneEnforcement,
            'False value for hierarchy setting Disable_Preferred_Phone_Enforcement__c, should set preferredPhoneEnforcement property to true.'
        );

        System.assertEquals(
            '""',
            preferredContactInfoSettingsModel.defaultPreferredPhone,
            'defaultPreferredPhone property should be blank when no valud is specified for Preferred_Phone_Selection__c hierarchy setting.'
        );
    }
}
