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
 * @description Test class for AccountNamingSettingsModel.
 */
@isTest
private class AccountNamingSettingsModel_TEST {
    /***********************************************************************************************
     * @description Test to verify five parameter constructor returns an AccountNamingSettingsModel
     * with all properties populated.
     ***********************************************************************************************/
    @isTest
    private static void fiveParameterConstructor() {
        Test.startTest();
        AccountNamingSettingsModel accountNamingSettingsModel = new AccountNamingSettingsModel(
            'admin format',
            'hh format',
            'custom admin format',
            'custom hh format',
            true
        );
        Test.stopTest();

        System.assertEquals(
            'admin format',
            accountNamingSettingsModel.administrativeAccountNameFormat,
            'Administrative Account name format should be set to specified value.'
        );

        System.assertEquals(
            'hh format',
            accountNamingSettingsModel.householdAccountNamingFormat,
            'Household Account name format should be set to specified value.'
        );

        System.assertEquals(
            'custom admin format',
            accountNamingSettingsModel.customAdministrativeAccountNameFormat,
            'Custom Administrative Account name format should be set to specified value.'
        );

        System.assertEquals(
            'custom hh format',
            accountNamingSettingsModel.customHouseholdAccountNameFormat,
            'Custom Household Account name format should be set to specified value.'
        );

        System.assertEquals(
            true,
            accountNamingSettingsModel.autoHouseholdAccountNamingEnabled,
            'Auto household account naming should be enabled.'
        );
    }

    /***********************************************************************************************
     * @description Test to verify five parameter constructor returns an AccountNamingSettingsModel
     * with all properties populated and blanks when appropriate.
     ***********************************************************************************************/
    @isTest
    private static void fiveParameterConstructorWithBlanks() {
        Test.startTest();
        AccountNamingSettingsModel accountNamingSettingsModel = new AccountNamingSettingsModel(
            'admin format',
            'hh format',
            '',
            null,
            true
        );
        Test.stopTest();

        System.assertEquals(
            'admin format',
            accountNamingSettingsModel.administrativeAccountNameFormat,
            'Administrative Account name format should be set to specified value.'
        );

        System.assertEquals(
            'hh format',
            accountNamingSettingsModel.householdAccountNamingFormat,
            'Household Account name format should be set to specified value.'
        );

        System.assertEquals(
            '',
            accountNamingSettingsModel.customAdministrativeAccountNameFormat,
            'Custom Administrative Account name format should be blank.'
        );

        System.assertEquals(
            '',
            accountNamingSettingsModel.customHouseholdAccountNameFormat,
            'Custom Household Account name format should be blank.'
        );

        System.assertEquals(
            true,
            accountNamingSettingsModel.autoHouseholdAccountNamingEnabled,
            'Auto household account naming should be enabled.'
        );
    }
}
