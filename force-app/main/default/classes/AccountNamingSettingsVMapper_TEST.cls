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
 * @group EDA Settings
 * @group-content ../../ApexDocContent/EdaSettings.htm
 * @description Test class for AccountNamingSettingsVMapper.
 */
@isTest
private class AccountNamingSettingsVMapper_TEST {
    private static Integer loopCounter = 5;

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * AccountNamingSettingsVMapper class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        AccountNamingSettingsVMapper accountNamingSettingsVMapperInstance = AccountNamingSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            AccountNamingSettingsVMapper.instance,
            accountNamingSettingsVMapperInstance,
            'Instance of service class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            accountNamingSettingsVMapperInstance != null,
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * AccountNamingSettingsVMapper class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        AccountNamingSettingsVMapper accountNamingSettingsVMapperInstance1 = AccountNamingSettingsVMapper.getInstance();
        AccountNamingSettingsVMapper accountNamingSettingsVMapperInstance2 = AccountNamingSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            AccountNamingSettingsVMapper.instance,
            accountNamingSettingsVMapperInstance1,
            'Instance of service class returned should match static instance variable.'
        );
        System.assertEquals(
            accountNamingSettingsVMapperInstance1,
            accountNamingSettingsVMapperInstance2,
            'Subsequent retrievals of service class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            accountNamingSettingsVMapperInstance1 != null,
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the locateAccountNamingSettingsService() returns an instance of the
     * AccountNamingSettingsVMapper class.
     ***************************************************************************************************************************/
    @isTest
    private static void locateAccountNamingSettingsServiceValid() {
        AccountNamingSettingsVMapper accountNamingSettingsVMapperInstance = AccountNamingSettingsVMapper.getInstance();

        Test.startTest();
        AccountNamingSettingsService adminAccountSettingsService = accountNamingSettingsVMapperInstance.locateAccountNamingSettingsService();
        Test.stopTest();

        System.assertEquals(
            AccountNamingSettingsService.getInstance(),
            adminAccountSettingsService,
            'Should return instance of AccountNamingSettingsService class.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getAccountNamingSettingsVModel method returns an AccountNamingSettingsVModel
     * representing the hierarchy settings values specified for account naming functionality.
     ***************************************************************************************************************************/
    @isTest
    private static void getAccountNamingSettingsVModelValid() {
        AccountNamingSettingsMapper.instance = new STUB_AccountNamingSettingsMapper();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Admin_Account_Naming_Format__c = 'administrativeAccountNameFormat',
                Household_Account_Naming_Format__c = 'householdAccountNamingFormat',
                Admin_Other_Name_Setting__c = 'customAdministrativeAccountNameFormat',
                Household_Other_Name_Setting__c = 'customHouseholdAccountNameFormat',
                Automatic_Household_Naming__c = false
            )
        );

        AccountNamingSettingsVMapper accountNamingSettingsVMapperInstance = AccountNamingSettingsVMapper.getInstance();

        Test.startTest();
        AccountNamingSettingsVModel accountNamingSettingsVModel = accountNamingSettingsVMapperInstance.getAccountNamingSettingsVModel();
        Test.stopTest();

        System.assertEquals(
            'customAdministrativeAccountNameFormat',
            accountNamingSettingsVModel.customAdministrativeAccountNameFormat,
            'Custom Admin Naming format should match value in hierarchy settings.'
        );

        System.assertEquals(
            'customHouseholdAccountNameFormat',
            accountNamingSettingsVModel.customHouseholdAccountNameFormat,
            'Custom HH Naming format should match value in hierarchy settings.'
        );

        System.assertEquals(
            false,
            accountNamingSettingsVModel.autoHouseholdAccountNamingEnabled,
            'Auto household account naming enabled setting should match value in hierarchy settings.'
        );

        System.assertEquals(
            'administrativeAccountNameFormat1',
            accountNamingSettingsVModel.administrativeAccountNameFormat.value,
            'Selected Admin Naming format should match value in hierarchy settings.'
        );

        System.assertEquals(
            loopCounter,
            accountNamingSettingsVModel.administrativeAccountNameFormat.options.size(),
            'Should have ' +
            loopCounter +
            ' Admin Naming format options.'
        );

        System.assertEquals(
            'householdAccountNamingFormat1',
            accountNamingSettingsVModel.householdAccountNameFormat.value,
            'Selected HH Naming format should match value in hierarchy settings.'
        );

        System.assertEquals(
            loopCounter,
            accountNamingSettingsVModel.householdAccountNameFormat.options.size(),
            'Should have ' +
            loopCounter +
            ' HH Naming format options.'
        );
    }

    /**************************************************************************************************************************
     ****************************************************** STUBS **************************************************************
     **************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AccountNamingSettingsMapper to return a valid AccountNamingSettingsModel and
     * AccountNamingFormatModels for Administrative and Household accounts.
     **************************************************************************************************************************************/
    private class STUB_AccountNamingSettingsMapper extends AccountNamingSettingsMapper {
        public override AccountNamingSettingsModel getAccountNamingSettingsModel() {
            return new AccountNamingSettingsModel(
                'administrativeAccountNameFormat1',
                'householdAccountNamingFormat1',
                'customAdministrativeAccountNameFormat',
                'customHouseholdAccountNameFormat',
                false
            );
        }

        public override AccountNamingFormatModel getAdministrativeAccountNamingFormatModel() {
            Map<String, String> validAdminAccountNamingFormatsByName = new Map<String, String>();

            for (Integer i = 0; i < loopCounter; i++) {
                validAdminAccountNamingFormatsByName.put('adminNameFormat' + i, 'administrativeAccountNameFormat' + i);
            }

            AccountNamingFormatModel adminAccountNamingFormatModel = new AccountNamingFormatModel(
                validAdminAccountNamingFormatsByName
            );

            return adminAccountNamingFormatModel;
        }

        public override AccountNamingFormatModel getHouseholdAccountNamingFormatModel() {
            Map<String, String> validHHAccountNamingFormatsByName = new Map<String, String>();

            for (Integer i = 0; i < loopCounter; i++) {
                validHHAccountNamingFormatsByName.put('hhNameFormat' + i, 'householdAccountNamingFormat' + i);
            }

            AccountNamingFormatModel hhAccountNamingFormatModel = new AccountNamingFormatModel(
                validHHAccountNamingFormatsByName
            );
            return hhAccountNamingFormatModel;
        }
    }
}
