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
* @description Test class for Administrative Account Settings Service.
*/
@isTest 
public inherited sharing class AdministrativeAccountSettingsServ_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * AdministrativeAccountSettingsService class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            AdministrativeAccountSettingsService administrativeAccountSettingsServiceInstance = AdministrativeAccountSettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(AdministrativeAccountSettingsService.instance, administrativeAccountSettingsServiceInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, administrativeAccountSettingsServiceInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * AdministrativeAccountSettingsService class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            AdministrativeAccountSettingsService administrativeAccountSettingsServiceInstance1 = AdministrativeAccountSettingsService.getInstance();
            AdministrativeAccountSettingsService administrativeAccountSettingsServiceInstance2 = AdministrativeAccountSettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(AdministrativeAccountSettingsService.instance, administrativeAccountSettingsServiceInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(administrativeAccountSettingsServiceInstance1, administrativeAccountSettingsServiceInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, administrativeAccountSettingsServiceInstance1 != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the locateAdministrativeAccountSettingsMapper() returns an instance of the
    * AdministrativeAccountSettingsService class.
    ***************************************************************************************************************************/
    @isTest
    private static void locateAdministrativeAccountSettingsMapperValid() {
        AdministrativeAccountSettingsService administrativeAccountSettingsServiceInstance = 
            AdministrativeAccountSettingsService.getInstance();
        
        Test.startTest();
        AdministrativeAccountSettingsMapper adminAccountSettingsMapper = 
            administrativeAccountSettingsServiceInstance.locateAdministrativeAccountSettingsMapper();
        Test.stopTest();

        System.assertEquals(
            AdministrativeAccountSettingsMapper.getInstance(), 
            adminAccountSettingsMapper,
            'Should return instance of AdministrativeAccountSettingsMapper class.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getAdministrativeAccountSettingsModel() returns an AdministrativeAccountSettingsModel
    * with the specified naming format strings.
    ***************************************************************************************************************************/
    @isTest 
    private static void getAdministrativeAccountSettingsModelValid() {
        AdministrativeAccountSettingsMapper.instance = new STUB_AdministrativeAccountSettingsMapper();

        AdministrativeAccountSettingsService administrativeAccountSettingsServiceInstance = 
            AdministrativeAccountSettingsService.getInstance();
        
        Test.startTest();
        AdministrativeAccountSettingsModel adminAccountSettingsModel = 
            administrativeAccountSettingsServiceInstance.getAdministrativeAccountSettingsModel();
        Test.stopTest();

        System.assertEquals(
            'Test Account Naming Format', 
            adminAccountSettingsModel.administrativeAccountNameFormat,
            'Model should contain specified account naming format.'
        );

        System.assertEquals(
            'Test Account Other Naming Format', 
            adminAccountSettingsModel.administrativeAccountOtherNameFormat,
            'Model should contain specified other account naming format.'
        );
    }

    /**************************************************************************************************************************
    ****************************************************** STUBS **************************************************************
    **************************************************************************************************************************/
    
    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from AdministrativeAccountSettingsMapper to return a valid AdministrativeAccountSettingsModel.
    **************************************************************************************************************************************/ 
    private class STUB_AdministrativeAccountSettingsMapper extends AdministrativeAccountSettingsMapper {
        @TestVisible 
        public override AdministrativeAccountSettingsModel getAdministrativeAccountSettingsModel() {
            return new AdministrativeAccountSettingsModel(
                'Test Account Naming Format',
                'Test Account Other Naming Format'
            );
        }
    }
}
