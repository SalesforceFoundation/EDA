/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group
* @group-content ../../ApexDocContent/Tests.htm
* @description Test class for AccountModelSettingsMapper
*/
@isTest
private class  AccountModelSettingsMapper_TEST {

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * FeatureParameterMapper class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            AccountModelSettingsMapper accountModelSettingsMapperInstance = AccountModelSettingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(AccountModelSettingsMapper.instance, accountModelSettingsMapperInstance, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(true, accountModelSettingsMapperInstance != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * AccountModelSettingsMapper class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            AccountModelSettingsMapper accountModelSettingsMapperInstance1 = AccountModelSettingsMapper.getInstance();
            AccountModelSettingsMapper accountModelSettingsMapperInstance2 = AccountModelSettingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(AccountModelSettingsMapper.instance, accountModelSettingsMapperInstance1, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(accountModelSettingsMapperInstance1, accountModelSettingsMapperInstance2, 'Subsequent retrievals of mapper class instance should return existing instance.');
        System.assertEquals(true, accountModelSettingsMapperInstance1 != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getAccountModelSettingsModel method returns the AccountModelSettingsModel
    ***************************************************************************************************************************/
    @isTest
    private static void getAccountModelSettingsModel() {

        Test.startTest();
            AccountModelSettingsModel accModelSettingsModel = AccountModelSettingsMapper.getInstance().getAccountModelSettingsModel();
        Test.stopTest();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettingsFacade.getSettings();

        System.assertEquals(hierarchySettings.Account_Processor__c, accModelSettingsModel.defaultAccountModelId, 'Retrieved model\'s defaultAccountModel should be same as Account Processor from settings');
        System.assertEquals(hierarchySettings.Administrative_Account_Record_Type__c, accModelSettingsModel.administrativeAccountRecordTypeId, 'Retrieved model\'s admin account record type should be same as Administrative Account Record Type from settings');
        System.assertEquals(hierarchySettings.Household_Addresses_RecType__c, accModelSettingsModel.householdAccountRecordTypeId, 'Retrieved model\'s HH account record type should be same as Household Account Record Type from settings');
    }
}