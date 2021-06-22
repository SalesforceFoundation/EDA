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
 * @description Test class for AccountNamingSettingsController class
 */
@isTest
private with sharing class AccountNamingSettingsController_TEST {
    private static Integer loopCounter = 5;

    /****************************************************************************************************************************
     * @description Test method to verify that the locateAccountNamingSettingsVMapper method returns instance of AccountNamingSettingsVMapper.
     ****************************************************************************************************************************/
    @isTest
    private static void locateAccountNamingSettingsVMapperValid() {
        Test.startTest();
        AccountNamingSettingsVMapper accountNamingSettingsVMapperInstance = AccountNamingSettingsController.locateAccountNamingSettingsVMapper();
        Test.stopTest();

        System.assertEquals(
            AccountNamingSettingsVMapper.getInstance(),
            accountNamingSettingsVMapperInstance,
            'Should return the instance of AccountNamingSettingsVMapper.'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify getAccountNamingSettingsViewModel returns an AccountNamingSettingsVModel representing
     * the account naming format settings specified in hierarchy settings and lists of valid naming formats for Admin and HH
     * accounts.
     ****************************************************************************************************************************/
    @isTest
    private static void getAccountNamingSettingsViewModelValid() {
        AccountNamingSettingsVMapper.instance = new STUB_AccountNamingSettingsVMapper();

        Test.startTest();
        AccountNamingSettingsVModel accountNamingSettingsVModel = AccountNamingSettingsController.getAccountNamingSettingsViewModel();
        Test.stopTest();

        System.assertEquals(
            'customAdminAccountNamingFormat',
            accountNamingSettingsVModel.customAdministrativeAccountNameFormat,
            'Custom Admin Account naming format should match value in hierarchy settings.'
        );

        System.assertEquals(
            'customHHAccountNamingFormat',
            accountNamingSettingsVModel.customHouseholdAccountNameFormat,
            'Custom HH Account naming format should match value in hierarchy settings.'
        );

        System.assertEquals(
            true,
            accountNamingSettingsVModel.autoHouseholdAccountNamingEnabled,
            'Auto HH acount naming setting should match value in hierarchy settings.'
        );

        System.assertEquals(
            'adminNameFormatValue1',
            accountNamingSettingsVModel.administrativeAccountNameFormat.value,
            'Selected Admin account naming format should match hierarchy settings.'
        );

        System.assertEquals(
            loopCounter,
            accountNamingSettingsVModel.administrativeAccountNameFormat.options.size(),
            'Should have ' +
            loopCounter +
            'Admin account naming formats to choose from.'
        );

        System.assertEquals(
            'hhNameFormatValue1',
            accountNamingSettingsVModel.householdAccountNameFormat.value,
            'Selected HH account naming format should match hierarchy settings.'
        );

        System.assertEquals(
            loopCounter,
            accountNamingSettingsVModel.householdAccountNameFormat.options.size(),
            'Should have ' +
            loopCounter +
            'HH account naming formats to choose from.'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify getAccountNamingSettingsViewModel method fails gracefully when an exception is
     * encountered.
     ****************************************************************************************************************************/
    @isTest
    private static void getAccountNamingSettingsViewModelException() {
        AccountNamingSettingsVMapper.instance = new STUB_ExceptionAccountNamingSettingsVMapper();

        try {
            Test.startTest();
            AccountNamingSettingsVModel accountNamingSettingsVModel = AccountNamingSettingsController.getAccountNamingSettingsViewModel();
            Test.stopTest();
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /**************************************************************************************************************************
     ****************************************************** STUBS **************************************************************
     **************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AccountNamingSettingsVMapper to return a valid AccountNamingSettingsVModel
     **************************************************************************************************************************************/
    private class STUB_AccountNamingSettingsVMapper extends AccountNamingSettingsVMapper {
        public override AccountNamingSettingsVModel getAccountNamingSettingsVModel() {
            List<ComboboxValueVModel> adminAccountNameFormatComboboxValueVModelsList = new List<ComboboxValueVModel>();
            List<ComboboxValueVModel> hhAccountNameFormatComboboxValueVModelsList = new List<ComboboxValueVModel>();

            for (Integer i = 0; i < loopCounter; i++) {
                adminAccountNameFormatComboboxValueVModelsList.add(
                    new ComboboxValueVModel('adminNameFormatLabel' + i, 'adminNameFormatValue' + i)
                );

                hhAccountNameFormatComboboxValueVModelsList.add(
                    new ComboboxValueVModel('hhNameFormatLabel' + i, 'hhNameFormatValue' + i)
                );
            }

            ComboboxVModel adminAccountNameFormatComboboxVModel = new ComboboxVModel(
                'adminNameFormatValue1',
                adminAccountNameFormatComboboxValueVModelsList
            );

            ComboboxVModel hhAccountNameFormatComboboxVModel = new ComboboxVModel(
                'hhNameFormatValue1',
                hhAccountNameFormatComboboxValueVModelsList
            );

            return new AccountNamingSettingsVModel(
                'customAdminAccountNamingFormat',
                'customHHAccountNamingFormat',
                true,
                adminAccountNameFormatComboboxVModel,
                hhAccountNameFormatComboboxVModel
            );
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AccountNamingSettingsVMapper to throw an exception
     **************************************************************************************************************************************/
    private class STUB_ExceptionAccountNamingSettingsVMapper extends AccountNamingSettingsVMapper {
        public override AccountNamingSettingsVModel getAccountNamingSettingsVModel() {
            throw new TestException('Exception encountered!');
        }
    }

    private class TestException extends Exception {
    }
}
