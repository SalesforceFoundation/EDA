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
 * @description Test class for AccountModelSettingsController class
 */
@isTest
private with sharing class AccountModelSettingsController_TEST {
    private static Integer loopCounter = 5;
    /****************************************************************************************************************************
     * @description Test method to verify that the locateAccountModelSettingsVMapper method returns instance of AccountModelSettingsVMapper.
     ****************************************************************************************************************************/
    @isTest
    private static void locateAccountModelSettingsVMapperValid() {
        Test.startTest();
        AccountModelSettingsVMapper accountModelSettingsVMapperInstance = AccountModelSettingsController.locateAccountModelSettingsVMapper();
        Test.stopTest();

        System.assertEquals(
            AccountModelSettingsVMapper.getInstance(),
            accountModelSettingsVMapperInstance,
            'Should return the instance of AccountModelSettingsVMapper.'
        );
    }

    @isTest
    private static void getAccountModelSettingsViewModelValid() {
        AccountModelSettingsVMapper.instance = new STUB_AccountModelSettingsVMapper();

        Test.startTest();
        AccountModelSettingsVModel accountModelSettingsVModel = AccountModelSettingsController.getAccountModelSettingsViewModel();
        Test.stopTest();

        System.assertEquals(
            'Selected Default Account',
            accountModelSettingsVModel.defaultAccountRecordType.value,
            'Default Account ComboboxVModel selected value should be set.'
        );

        System.assertEquals(
            'Selected HH Account',
            accountModelSettingsVModel.householdAccountRecordType.value,
            'HH Account ComboboxVModel selected value should be set.'
        );

        System.assertEquals(
            'Selected Admin Account',
            accountModelSettingsVModel.adminAccountRecordType.value,
            'Admin Account ComboboxVModel selected value should be set.'
        );

        System.assertEquals(
            loopCounter,
            accountModelSettingsVModel.defaultAccountRecordType.options.size(),
            'ComboboxVModel options should be populated.'
        );
    }

    @isTest
    private static void getAccountModelSettingsViewModelException() {
        AccountModelSettingsVMapper.instance = new STUB_ExceptionAccountModelSettingsVMapper();

        try {
            Test.startTest();
            AccountModelSettingsVModel accountModelSettingsVModel = AccountModelSettingsController.getAccountModelSettingsViewModel();
            Test.stopTest();
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /**************************************************************************************************************************
     ****************************************************** STUBS **************************************************************
     **************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AccountModelSettingsVMapper to return a valid AccountModelSettingsVModel
     **************************************************************************************************************************************/
    private class STUB_AccountModelSettingsVMapper extends AccountModelSettingsVMapper {
        public override AccountModelSettingsVModel getAccountModelSettingsViewModel() {
            List<ComboboxValueVModel> accountRecordTypeOptionsList = new List<ComboboxValueVModel>();

            for (Integer i = 0; i < loopCounter; i++) {
                accountRecordTypeOptionsList.add(new ComboboxValueVModel('Label' + i, 'Value' + i));
            }

            ComboboxVModel defaultAccountComboboxVModel = new ComboboxVModel(
                'Selected Default Account',
                accountRecordTypeOptionsList
            );
            ComboboxVModel hhAccountComboboxVModel = new ComboboxVModel(
                'Selected HH Account',
                accountRecordTypeOptionsList
            );
            ComboboxVModel adminAccountComboboxVModel = new ComboboxVModel(
                'Selected Admin Account',
                accountRecordTypeOptionsList
            );

            return new AccountModelSettingsVModel(
                defaultAccountComboboxVModel,
                hhAccountComboboxVModel,
                adminAccountComboboxVModel
            );
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AccountModelSettingsVMapper to return a valid AccountModelSettingsVModel
     **************************************************************************************************************************************/
    private class STUB_ExceptionAccountModelSettingsVMapper extends AccountModelSettingsVMapper {
        public override AccountModelSettingsVModel getAccountModelSettingsViewModel() {
            throw new TestException('Test exception!');
        }
    }

    private class TestException extends Exception {
    }
}
