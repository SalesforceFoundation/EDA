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
 * @description Test class for AddressSettingsController class
 */
@isTest
private with sharing class AddressSettingsController_TEST {
    
    private static Integer loopCounter = 5;

    /**************************************************************************************************************************************************
     * @description Test method to verify that the locateAccountAddressSettingsVMapper method returns instance of locateAccountAddressSettingsVMapper.
     *************************************************************************************************************************************************/
    @isTest
    private static void locateAccountAddressSettingsVMapper() {
        Test.startTest();
            AddressSettingsVMapper addressSettingsVMapperInstance = AddressSettingsController.locateAddressSettingsVMapper();
        Test.stopTest();

        System.assertEquals(
            AddressSettingsVMapper.getInstance(),
            addressSettingsVMapperInstance,
            'Should return the instance of locateAccountAddressSettingsVMapper.'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getddressSettingsVModel method returns a AddressSettingsVModel
     * representing all active Account Record Types selected for Multi Address Accounts in Hierarchy Settings
     * and all remaining active Account Record Types as selection options.
     ****************************************************************************************************************************/
    @isTest
    private static void getAddressSettingsViewModelValid() {
        AddressSettingsVMapper.instance = new STUB_AddressSettingsVMapper();

        Test.startTest();
            AddressSettingsVModel addressSettingsVModel = AddressSettingsController.getAddressSettingsVModel();
        Test.stopTest();

        System.assertEquals(2, addressSettingsVModel.accountRecordTypesWithAddressesEnabled.value.size(), 'Should have 2 Account Record Types selected.');
        System.assertEquals(
            loopCounter,
            addressSettingsVModel.accountRecordTypesWithAddressesEnabled.options.size(),
            'Should include all active Account Record Types as options even if they are also selected.'
        );

        System.assertEquals(
            '000000000000000001',
            addressSettingsVModel.accountRecordTypesWithAddressesEnabled.value[0],
            'Value of selected Account Record Type should match Id of active record type that is selected.'
        );
        System.assertEquals(
            '000000000000000002',
            addressSettingsVModel.accountRecordTypesWithAddressesEnabled.value[1],
            'Value of selected Account Record Type should match Id of active record type that is selected.'
        );

        for (Integer i = 0; i < loopCounter; i++) {
            System.assertEquals(
                'RecordType' + (i + 1),
                addressSettingsVModel.accountRecordTypesWithAddressesEnabled.options[i].label,
                'Options list should contain all active account record type labels.'
            );
            System.assertEquals(
                '00000000000000000' + (i + 1),
                addressSettingsVModel.accountRecordTypesWithAddressesEnabled.options[i].value,
                'Options list should contain all active account record type values.'
            );
        }
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getAddressSettingsViewModel method fails gracefully when an exception is
     * encountered.
     ****************************************************************************************************************************/
    @isTest
    private static void getAddressSettingsViewModelException() {
        AddressSettingsVMapper.instance = new STUB_ExceptionAddressSettingsVMapper();

        try {
            Test.startTest();
                AddressSettingsVModel addressSettingsVModel = AddressSettingsController.getAddressSettingsVModel();
            Test.stopTest();
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /**************************************************************************************************************************
     ****************************************************** STUBS **************************************************************
     **************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AddressSettingsVMapper to return a valid AddressSettingVModel
     **************************************************************************************************************************************/
    private class STUB_AddressSettingsVMapper extends AddressSettingsVMapper {
        public override AddressSettingsVModel getAddressSettingsViewModel() {
            List<String> selectedValuesList = new List<String>{ '000000000000000001', '000000000000000002' };

            List<DualListboxValueVModel> allOptionsDualListBoxValueVModelsList = new List<DualListboxValueVModel>();

            for (Integer i = 0; i < loopCounter; i++) {
                allOptionsDualListBoxValueVModelsList.add(
                    new DualListboxValueVModel('RecordType' + (i + 1), '00000000000000000' + (i + 1))
                );
            }

            return new AddressSettingsVModel(true, new DualListboxVModel(selectedValuesList, allOptionsDualListBoxValueVModelsList), true);
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AddressSettingsVMapper to throw an exception
     **************************************************************************************************************************************/
    private class STUB_ExceptionAddressSettingsVMapper extends AddressSettingsVMapper {
        public override AddressSettingsVModel getAddressSettingsViewModel() {
            throw new TestException('Exception encountered!');
        }
    }

    private class TestException extends Exception {
    }
}