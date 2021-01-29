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
* @description Test class for AccountModelSettingsModel
*/
@isTest
private class AccountModelSettingsModel_TEST {

    /**************************************************************************************************************************
    * @description Test method to verify that the constructor set the properties 
    ***************************************************************************************************************************/
    @isTest
    private static void constructor() {
        Test.startTest();
            AccountModelSettingsModel accountModelSettingsModel = new AccountModelSettingsModel('01217000002Zs0pAAC', '01217000002Zs0pAAC', '01217000002Zs0sAAC');
        Test.stopTest();

        System.assertEquals('01217000002Zs0pAAC', accountModelSettingsModel.defaultAccountModelId, 'defaultAccountModelId should be set with the value that is passed');
        System.assertEquals('01217000002Zs0pAAC', accountModelSettingsModel.administrativeAccountRecordTypeId, 'administrativeAccountRecordTypeId should be set with the value that is passed');
        System.assertEquals('01217000002Zs0sAAC', accountModelSettingsModel.householdAccountRecordTypeId, 'householdAccountRecordTypeId should be set with the value that is passed');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the constructor set the properties for nulls
    ***************************************************************************************************************************/
    @isTest
    private static void constructorNull() {
        Test.startTest();
            AccountModelSettingsModel accountModelSettingsModel = new AccountModelSettingsModel(null, null, null);
        Test.stopTest();

        System.assertEquals('""', accountModelSettingsModel.defaultAccountModelId, 'defaultAccountModelId should be set with the value that is passed');
        System.assertEquals('""', accountModelSettingsModel.administrativeAccountRecordTypeId, 'administrativeAccountRecordTypeId should be set with the value that is passed');
        System.assertEquals('""', accountModelSettingsModel.householdAccountRecordTypeId, 'householdAccountRecordTypeId should be set with the value that is passed');
    }
}