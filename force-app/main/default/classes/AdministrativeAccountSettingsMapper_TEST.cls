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
* @description Test class for Administrative Account Settings Mapper.
*/
@isTest
public inherited sharing class AdministrativeAccountSettingsMapper_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * AdministrativeAccountSettingsMapper class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            AdministrativeAccountSettingsMapper administrativeAccountSettingsMapperInstance = AdministrativeAccountSettingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(AdministrativeAccountSettingsMapper.instance, administrativeAccountSettingsMapperInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, administrativeAccountSettingsMapperInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * AdministrativeAccountSettingsMapper class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            AdministrativeAccountSettingsMapper administrativeAccountSettingsMapperInstance1 = AdministrativeAccountSettingsMapper.getInstance();
            AdministrativeAccountSettingsMapper administrativeAccountSettingsMapperInstance2 = AdministrativeAccountSettingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(AdministrativeAccountSettingsMapper.instance, administrativeAccountSettingsMapperInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(administrativeAccountSettingsMapperInstance1, administrativeAccountSettingsMapperInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, administrativeAccountSettingsMapperInstance1 != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify the getAdministrativeAccountSettingsModel() returns a model populated with data from
    * hierarchy settings.
    ***************************************************************************************************************************/
    @isTest
    private static void getAdministrativeAccountSettingsModelValid() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Admin_Account_Naming_Format__c = '{!LastName} Test Format',
                Admin_Other_Name_Setting__c = '{!LastName} Test Other Format'
            )
        );

        AdministrativeAccountSettingsMapper administrativeAccountSettingsMapperInstance = 
            AdministrativeAccountSettingsMapper.getInstance();


        Test.startTest();
        AdministrativeAccountSettingsModel adminAccountSettingsModel = 
            administrativeAccountSettingsMapperInstance.getAdministrativeAccountSettingsModel();
        Test.stopTest();

        System.assertEquals(
            '{!LastName} Test Format', 
            adminAccountSettingsModel.administrativeAccountNameFormat, 
            'Model should contain specified account naming format'
        );

        System.assertEquals(
            '{!LastName} Test Other Format', 
            adminAccountSettingsModel.administrativeAccountOtherNameFormat, 
            'Model should contain specified other account naming format'
        );
    }
}
