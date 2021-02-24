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
* @description Test class for AccountNamingSettingsMapper.
*/
@isTest
public inherited sharing class AccountNamingSettingsMapper_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * AccountNamingSettingsMapper class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            AccountNamingSettingsMapper accountNamingSettingsMapperInstance = AccountNamingSettingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(AccountNamingSettingsMapper.instance, accountNamingSettingsMapperInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, accountNamingSettingsMapperInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * AccountNamingSettingsMapper class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            AccountNamingSettingsMapper accountNamingSettingsMapperInstance1 = AccountNamingSettingsMapper.getInstance();
            AccountNamingSettingsMapper accountNamingSettingsMapperInstance2 = AccountNamingSettingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(AccountNamingSettingsMapper.instance, accountNamingSettingsMapperInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(accountNamingSettingsMapperInstance1, accountNamingSettingsMapperInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, accountNamingSettingsMapperInstance1 != null, 'Instance of service class should not be null.');
    }

    /***********************************************************************************************************************************
    * @description Test method to verify that the getAccountNamingSettingsmodel method returns an AccountNamingSettingsModel with account
    * naming formats correctly represented.
    ***********************************************************************************************************************************/
    @isTest
    private static void getAccountNamingSettingsmodelValid() {

        AccountNamingSettingsMapper accountNamingSettingsMapperInstance = AccountNamingSettingsMapper.getInstance();

        Test.startTest();
        AccountNamingSettingsModel accountNamingSettingsModel = accountNamingSettingsMapperInstance.getAccountNamingSettingsModel();
        Test.stopTest();

        System.assertEquals(
            Label.lastNameAdminAcc, 
            accountNamingSettingsModel.validAccountNamingFormatsByName.get('lastNameAdminAcc'), 
            'Label name \'lastNameAdminAcc\' should map to text associated with custom label with same name.'
        );

        System.assertEquals(
            Label.firstNameLastNameAdminACC, 
            accountNamingSettingsModel.validAccountNamingFormatsByName.get('firstNameLastNameAdminACC'), 
            'Label name \'firstNameLastNameAdminACC\' should map to text associated with custom label with same name.'
        );

        System.assertEquals(
            Label.lastNameFirstNameAdminAcc, 
            accountNamingSettingsModel.validAccountNamingFormatsByName.get('lastNameFirstNameAdminAcc'), 
            'Label name \'lastNameFirstNameAdminAcc\' should map to text associated with custom label with same name.'
        );

        System.assertEquals(
            Label.acctNamingOther, 
            accountNamingSettingsModel.validAccountNamingFormatsByName.get('acctNamingOther'), 
            'Label name \'acctNamingOther\' should map to text associated with custom label with same name.'
        );
    }
}
