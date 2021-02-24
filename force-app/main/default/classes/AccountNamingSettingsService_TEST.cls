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
* @description Test class for AccountNamingSettingsService.
*/
@isTest 
public inherited sharing class AccountNamingSettingsService_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * AccountNamingSettingsService class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            AccountNamingSettingsService accountNamingSettingsServiceInstance = AccountNamingSettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(AccountNamingSettingsService.instance, accountNamingSettingsServiceInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, accountNamingSettingsServiceInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * AccountNamingSettingsService class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            AccountNamingSettingsService accountNamingSettingsServiceInstance1 = AccountNamingSettingsService.getInstance();
            AccountNamingSettingsService accountNamingSettingsServiceInstance2 = AccountNamingSettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(AccountNamingSettingsService.instance, accountNamingSettingsServiceInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(accountNamingSettingsServiceInstance1, accountNamingSettingsServiceInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, accountNamingSettingsServiceInstance1 != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test to verify locateAccountNamingSettingsMapper() returns and instance of AccountNamingSettingsMapper.
    **************************************************************************************************************************/
    @isTest 
    private static void locateAccountNamingSettingsMapperValid() {
        AccountNamingSettingsService accountNamingSettingsServiceInstance = AccountNamingSettingsService.getInstance();
        
        Test.startTest();
        AccountNamingSettingsMapper accountNamingSettingsMapperInstance = accountNamingSettingsServiceInstance.locateAccountNamingSettingsMapper();
        Test.stopTest();

        System.assertEquals(
            AccountNamingSettingsMapper.getInstance(), 
            accountNamingSettingsMapperInstance,
            'Should return instance of AccountNamingSettingsMapper.'
        );
    }

    /**************************************************************************************************************************
    * @description Test to verify getAccountNamingSettingsModel() returns a valid Account Naming Settings model.
    **************************************************************************************************************************/
    @isTest 
    private static void getAccountNamingSettingsModelValid() {
        AccountNamingSettingsService.instance = new STUB_AccountNamingSettingsService();
        AccountNamingSettingsService accountNamingSettingsServiceInstance = AccountNamingSettingsService.getInstance();
        
        Test.startTest();
        AccountNamingSettingsModel accountNamingSettingsModel = accountNamingSettingsServiceInstance.getAccountNamingSettingsModel();
        Test.stopTest();

        System.assertEquals(
            1, 
            accountNamingSettingsModel.validAccountNamingFormatsByName.values().size(),
            'Should return model with 1 valid account naming formats.'
        );

        System.assertEquals(
            'format {LastName}', 
            accountNamingSettingsModel.validAccountNamingFormatsByName.get('test1'),
            '\'format {LastName}\' should be mapped to \'test1\' key in resulting model.'
        );
    }

    /**************************************************************************************************************************
    ****************************************************** STUBS **************************************************************
    **************************************************************************************************************************/
    
    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from AccountNamingSettingsService to return a valid AccountNamingSettings model.
    **************************************************************************************************************************************/ 
    private class STUB_AccountNamingSettingsService extends AccountNamingSettingsService {
        @TestVisible 
        public override AccountNamingSettingsModel getAccountNamingSettingsModel() { 
            Map<String, String> validAccountNamingFormatsByName = new Map<String, String>{
                'test1' => 'format {LastName}'
            };
            
            return new AccountNamingSettingsModel(validAccountNamingFormatsByName);
        }
    }
}


