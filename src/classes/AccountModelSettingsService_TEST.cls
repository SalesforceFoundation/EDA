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
* @description Test class for FeatureParameterService class
*/
@isTest
private class AccountModelSettingsService_TEST {

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * AccountModelSettingsService class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            AccountModelSettingsService accountModelSettingsServiceInstance = AccountModelSettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(AccountModelSettingsService.instance, accountModelSettingsServiceInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, accountModelSettingsServiceInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * AccountModelSettingsService class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            AccountModelSettingsService accountModelSettingsServiceInstance1 = AccountModelSettingsService.getInstance();
            AccountModelSettingsService accountModelSettingsServiceInstance2 = AccountModelSettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(AccountModelSettingsService.instance, accountModelSettingsServiceInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(accountModelSettingsServiceInstance1, accountModelSettingsServiceInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, accountModelSettingsServiceInstance1 != null, 'Instance of service class should not be null.');
    }

    /***********************************************************************************************************************************
    * @description Test method to verify that the locateAccountModelSettingsMapper method returns instance of AccountModelSettingsMapper
    ***********************************************************************************************************************************/
    @isTest
    private static void locateAccountModelSettingsMapper() {

        Test.startTest();
            AccountModelSettingsMapper accoungModelSettingsMapper = AccountModelSettingsService.getInstance().locateAccountModelSettingsMapper();
        Test.stopTest();

        System.assertEquals(AccountModelSettingsMapper.getInstance(), accoungModelSettingsMapper, 'Should return the instance of AccountModelSettingsMapper');

    }
    
    /***********************************************************************************************************************************
    * @description Test method to verify that the getAccountModelSettingsModel method returns instance of AccountModelSettings Model
    ***********************************************************************************************************************************/
    @isTest
    private static void getAccountModelSettingsModel() {

        AccountModelSettingsMapper.instance = new STUB_AccountModelSettingsMapper();

        Test.startTest();
            AccountModelSettingsModel accountModelSettingsModel = AccountModelSettingsService.getInstance().getAccountModelSettingsModel();
        Test.stopTest();

        System.assertEquals('01217000002Zs0pAAC', accountModelSettingsModel.defaultAccountModelId, 'Retrieved model\'s defaultAccountModel should be same as Account Processor from settings');
        System.assertEquals('01217000002Zs0pAAC', accountModelSettingsModel.administrativeAccountRecordTypeId, 'Retrieved model\'s admin account record type should be same as Administrative Account Record Type from settings');
        System.assertEquals('01217000002Zs0sAAC', accountModelSettingsModel.householdAccountRecordTypeId, 'Retrieved model\'s HH account record type should be same as Household Account Record Type from settings');

    }

    /***********************************************************************************************************************************
    ****************************************************** STUBS ***********************************************************************
    ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from AccountModelSettingsMapper to return a AccountModelSettings model
    **************************************************************************************************************************************/ 
    private class STUB_AccountModelSettingsMapper extends AccountModelSettingsMapper {
 
        public override AccountModelSettingsModel getAccountModelSettingsModel() {
            AccountModelSettingsModel accountModelSettingsModel = new AccountModelSettingsModel('01217000002Zs0pAAC', '01217000002Zs0pAAC', '01217000002Zs0sAAC');

            return accountModelSettingsModel;
        }
    }
}