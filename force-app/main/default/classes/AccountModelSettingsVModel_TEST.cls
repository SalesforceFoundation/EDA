/*
    Copyright (c) 2021, Salesforce.org
    All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
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
 * @description Test class for AccountModelSettingsVModel
 */
@isTest
private with sharing class AccountModelSettingsVModel_TEST {
    private static Integer loopCounter = 5;

    /********************************************************************************
     * @description Test to verify 3 argument constructor creates a AccountModelSettingsVModel
     * with all properties populated.
     ********************************************************************************/
    @isTest
    private static void threeArgumentConstructorValid() {
        List<ComboboxValueVModel> accountRecordTypeComboboxValueVModelsList = new List<ComboboxValueVModel>();

        for (Integer i = 0; i < loopCounter; i++) {
            accountRecordTypeComboboxValueVModelsList.add(
                new ComboboxValueVModel('Account Record Type Label' + i, 'Account Record Type Value' + i)
            );
        }

        ComboboxVModel defaultAccountComboboxVModel = new ComboboxVModel(
            'Default Account',
            accountRecordTypeComboboxValueVModelsList
        );

        ComboboxVModel hhAccountComboboxVModel = new ComboboxVModel(
            'HH Account',
            accountRecordTypeComboboxValueVModelsList
        );

        ComboboxVModel adminAccountComboboxVModel = new ComboboxVModel(
            'Admin Account',
            accountRecordTypeComboboxValueVModelsList
        );

        Test.startTest();
        AccountModelSettingsVModel accountModelSettingsVModel = new AccountModelSettingsVModel(
            defaultAccountComboboxVModel,
            hhAccountComboboxVModel,
            adminAccountComboboxVModel
        );
        Test.stopTest();

        System.assertEquals(
            'Default Account',
            accountModelSettingsVModel.defaultAccountRecordType.value,
            'Value property should be populated for Default Account model.'
        );

        System.assertEquals(
            'HH Account',
            accountModelSettingsVModel.householdAccountRecordType.value,
            'Value property should be populated for HH Account model.'
        );

        System.assertEquals(
            'Admin Account',
            accountModelSettingsVModel.adminAccountRecordType.value,
            'Value property should be populated for Admin Account model.'
        );

        for (Integer i = 0; i < loopCounter; i++) {
            System.assertEquals(
                'Account Record Type Label' + i,
                accountModelSettingsVModel.defaultAccountRecordType.options[i].label,
                'Label on comboboxValueVModel for Default Account model should be set.'
            );

            System.assertEquals(
                'Account Record Type Label' + i,
                accountModelSettingsVModel.householdAccountRecordType.options[i].label,
                'Label on comboboxValueVModel for HH Account model should be set.'
            );

            System.assertEquals(
                'Account Record Type Label' + i,
                accountModelSettingsVModel.adminAccountRecordType.options[i].label,
                'Label on comboboxValueVModel for Admin Account model should be set.'
            );

            System.assertEquals(
                'Account Record Type Value' + i,
                accountModelSettingsVModel.defaultAccountRecordType.options[i].value,
                'Value on comboboxValueVModel for Default Account model should be set.'
            );

            System.assertEquals(
                'Account Record Type Value' + i,
                accountModelSettingsVModel.householdAccountRecordType.options[i].value,
                'Value on comboboxValueVModel for HH Account model should be set.'
            );

            System.assertEquals(
                'Account Record Type Value' + i,
                accountModelSettingsVModel.adminAccountRecordType.options[i].value,
                'Value on comboboxValueVModel for Admin Account model should be set.'
            );
        }
    }
}
