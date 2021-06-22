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
 * @group-content ../../ApexDocContent/Test.htm
 * @description Test class for AccountNamingSettingsVModel.
 */
@isTest
private with sharing class AccountNamingSettingsVModel_TEST {
    private static Integer loopCounter = 5;

    /****************************************************************************************************
     * @description Test to verify that five argument constructor returns an AccountNamingSettingsVModel
     * with all properties populated.
     ****************************************************************************************************/
    @isTest
    private static void fiveArgumentConstructorValid() {
        List<ComboboxValueVModel> adminNamingFormatComboboxValueVModelsList = new List<ComboboxValueVModel>();
        List<ComboboxValueVModel> hhNamingFormatComboboxValueVModelsList = new List<ComboboxValueVModel>();

        for (Integer i = 0; i < loopCounter; i++) {
            adminNamingFormatComboboxValueVModelsList.add(new ComboboxValueVModel('adminLabel' + i, 'adminValue' + i));
            hhNamingFormatComboboxValueVModelsList.add(new ComboboxValueVModel('hhLabel' + i, 'hhValue' + i));
        }

        ComboboxVModel adminAccountNameFormatComboboxVModel = new ComboboxVModel(
            'adminValue' + (loopCounter - 2),
            adminNamingFormatComboboxValueVModelsList
        );

        ComboboxVModel hhAccountNameFormatComboboxVModel = new ComboboxVModel(
            'hhValue' + (loopCounter - 1),
            hhNamingFormatComboboxValueVModelsList
        );

        Test.startTest();
        AccountNamingSettingsVModel accountNamingSettingsVModel = new AccountNamingSettingsVModel(
            'Custom Admin Naming Format',
            'Custom HH Naming Format',
            false,
            adminAccountNameFormatComboboxVModel,
            hhAccountNameFormatComboboxVModel
        );
        Test.stopTest();

        System.assertEquals(
            'Custom Admin Naming Format',
            accountNamingSettingsVModel.customAdministrativeAccountNameFormat,
            'Custom administrative naming format string should match value provided.'
        );

        System.assertEquals(
            'Custom HH Naming Format',
            accountNamingSettingsVModel.customHouseholdAccountNameFormat,
            'Custom househould naming format string should match value provided.'
        );

        System.assertEquals(
            false,
            accountNamingSettingsVModel.autoHouseholdAccountNamingEnabled,
            'Auto household naming enabled setting should match value provided.'
        );

        System.assertEquals(
            'adminValue' + (loopCounter - 2),
            accountNamingSettingsVModel.administrativeAccountNameFormat.value,
            'Selected admin account name format should match value set in hierarchy settings.'
        );

        System.assertEquals(
            'hhValue' + (loopCounter - 1),
            accountNamingSettingsVModel.householdAccountNameFormat.value,
            'Selected HH account name format should match value set in hierarchy settings.'
        );

        for (Integer i = 0; i < loopCounter; i++) {
            System.assertEquals(
                'adminValue' + i,
                accountNamingSettingsVModel.administrativeAccountNameFormat.options[i].value,
                'Administrative naming format options should match specified values.'
            );

            System.assertEquals(
                'hhValue' + i,
                accountNamingSettingsVModel.householdAccountNameFormat.options[i].value,
                'Household naming format options should match specified values.'
            );
        }
    }

    /****************************************************************************************************
     * @description Test to verify that five argument constructor returns an AccountNamingSettingsVModel
     * with all properties populated as expected when blank values exist.
     ****************************************************************************************************/
    @isTest
    private static void fiveArgumentConstructorEmptyValues() {
        List<ComboboxValueVModel> adminNamingFormatComboboxValueVModelsList = new List<ComboboxValueVModel>();
        List<ComboboxValueVModel> hhNamingFormatComboboxValueVModelsList = new List<ComboboxValueVModel>();

        for (Integer i = 0; i < loopCounter; i++) {
            adminNamingFormatComboboxValueVModelsList.add(new ComboboxValueVModel('adminLabel' + i, 'adminValue' + i));
            hhNamingFormatComboboxValueVModelsList.add(new ComboboxValueVModel('hhLabel' + i, 'hhValue' + i));
        }

        ComboboxVModel adminAccountNameFormatComboboxVModel = new ComboboxVModel(
            'adminValue' + (loopCounter - 2),
            adminNamingFormatComboboxValueVModelsList
        );

        ComboboxVModel hhAccountNameFormatComboboxVModel = new ComboboxVModel(
            'hhValue' + (loopCounter - 1),
            hhNamingFormatComboboxValueVModelsList
        );

        Test.startTest();
        AccountNamingSettingsVModel accountNamingSettingsVModel = new AccountNamingSettingsVModel(
            null,
            '',
            true,
            adminAccountNameFormatComboboxVModel,
            hhAccountNameFormatComboboxVModel
        );
        Test.stopTest();

        System.assertEquals(
            '',
            accountNamingSettingsVModel.customAdministrativeAccountNameFormat,
            'Custom administrative naming format string should be blank.'
        );

        System.assertEquals(
            '',
            accountNamingSettingsVModel.customHouseholdAccountNameFormat,
            'Custom househould naming format string should be blank.'
        );

        System.assertEquals(
            true,
            accountNamingSettingsVModel.autoHouseholdAccountNamingEnabled,
            'Auto household naming enabled setting should match value provided.'
        );

        System.assertEquals(
            'adminValue' + (loopCounter - 2),
            accountNamingSettingsVModel.administrativeAccountNameFormat.value,
            'Selected admin account name format should match value set in hierarchy settings.'
        );

        System.assertEquals(
            'hhValue' + (loopCounter - 1),
            accountNamingSettingsVModel.householdAccountNameFormat.value,
            'Selected HH account name format should match value set in hierarchy settings.'
        );

        for (Integer i = 0; i < loopCounter; i++) {
            System.assertEquals(
                'adminValue' + i,
                accountNamingSettingsVModel.administrativeAccountNameFormat.options[i].value,
                'Administrative naming format options should match specified values.'
            );

            System.assertEquals(
                'hhValue' + i,
                accountNamingSettingsVModel.householdAccountNameFormat.options[i].value,
                'Household naming format options should match specified values.'
            );
        }
    }
}
