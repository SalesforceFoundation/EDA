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

        System.assertEquals(
            AccountNamingSettingsMapper.instance,
            accountNamingSettingsMapperInstance,
            'Instance of service class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            accountNamingSettingsMapperInstance != null,
            'Instance of service class should not be null.'
        );
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

        System.assertEquals(
            AccountNamingSettingsMapper.instance,
            accountNamingSettingsMapperInstance1,
            'Instance of service class returned should match static instance variable.'
        );
        System.assertEquals(
            accountNamingSettingsMapperInstance1,
            accountNamingSettingsMapperInstance2,
            'Subsequent retrievals of service class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            accountNamingSettingsMapperInstance1 != null,
            'Instance of service class should not be null.'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getAccountNamingSettingsModel method returns an AccountNamingSettingsModel
     * with account naming values that match those represented in hierarchy settings.
     ***********************************************************************************************************************************/
    @isTest
    private static void getAccountNamingSettingsModelValid() {
        AccountNamingSettingsMapper accountNamingSettingsMapperInstance = AccountNamingSettingsMapper.getInstance();

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Admin_Account_Naming_Format__c = 'admin account naming format',
                Household_Account_Naming_Format__c = 'hh account naming formate',
                Admin_Other_Name_Setting__c = 'admin other naming format',
                Household_Other_Name_Setting__c = 'hh other naming format',
                Automatic_Household_Naming__c = true
            )
        );

        Test.startTest();
        AccountNamingSettingsModel accountNamingSettingsModel = accountNamingSettingsMapperInstance.getAccountNamingSettingsModel();
        Test.stopTest();

        System.assertEquals(
            'admin account naming format',
            accountNamingSettingsModel.administrativeAccountNameFormat,
            'Administrative account naming format should match value in hierarchy settings.'
        );

        System.assertEquals(
            'hh account naming formate',
            accountNamingSettingsModel.householdAccountNamingFormat,
            'Household account naming format should match value in hierarchy settings.'
        );

        System.assertEquals(
            'admin other naming format',
            accountNamingSettingsModel.customAdministrativeAccountNameFormat,
            'Administrative account other naming format should match value in hierarchy settings.'
        );

        System.assertEquals(
            'hh other naming format',
            accountNamingSettingsModel.customHouseholdAccountNameFormat,
            'Household account other naming format should match value in hierarchy settings.'
        );

        System.assertEquals(
            true,
            accountNamingSettingsModel.autoHouseholdAccountNamingEnabled,
            'Auto Household Account Naming should match value in hierarchy settings.'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getAdministrativeAccountNamingFormatModel method returns an AccountNamingFormatModel
     * with Admin account naming formats correctly represented.
     ***********************************************************************************************************************************/
    @isTest
    private static void getAdministrativeAccountNamingFormatModelValid() {
        AccountNamingSettingsMapper accountNamingSettingsMapperInstance = AccountNamingSettingsMapper.getInstance();

        Test.startTest();
        AccountNamingFormatModel accountNamingSettingsModel = accountNamingSettingsMapperInstance.getAdministrativeAccountNamingFormatModel();
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

    /***********************************************************************************************************************************
     * @description Test method to verify that the getHouseholdAccountNamingFormatModel method returns an AccountNamingFormatModel
     * with HH account naming formats correctly represented.
     ***********************************************************************************************************************************/
    @isTest
    private static void getHouseholdAccountNamingFormatModelValid() {
        AccountNamingSettingsMapper accountNamingSettingsMapperInstance = AccountNamingSettingsMapper.getInstance();

        Test.startTest();
        AccountNamingFormatModel accountNamingSettingsModel = accountNamingSettingsMapperInstance.getHouseholdAccountNamingFormatModel();
        Test.stopTest();

        System.assertEquals(
            Label.lastNameHH,
            accountNamingSettingsModel.validAccountNamingFormatsByName.get('lastNameHH'),
            'Label name \'lastNameHH\' should map to text associated with custom label with same name.'
        );

        System.assertEquals(
            Label.lastNameFirstNameHH,
            accountNamingSettingsModel.validAccountNamingFormatsByName.get('lastNameFirstNameHH'),
            'Label name \'lastNameFirstNameHH\' should map to text associated with custom label with same name.'
        );

        System.assertEquals(
            Label.firstNameLastNameHH,
            accountNamingSettingsModel.validAccountNamingFormatsByName.get('firstNameLastNameHH'),
            'Label name \'firstNameLastNameHH\' should map to text associated with custom label with same name.'
        );

        System.assertEquals(
            Label.lastNameFamily,
            accountNamingSettingsModel.validAccountNamingFormatsByName.get('lastNameFamily'),
            'Label name \'lastNameFamily\' should map to text associated with custom label with same name.'
        );

        System.assertEquals(
            Label.lastNameFirstNameFamily,
            accountNamingSettingsModel.validAccountNamingFormatsByName.get('lastNameFirstNameFamily'),
            'Label name \'lastNameFirstNameFamily\' should map to text associated with custom label with same name.'
        );

        System.assertEquals(
            Label.firstNameLastNameFamily,
            accountNamingSettingsModel.validAccountNamingFormatsByName.get('firstNameLastNameFamily'),
            'Label name \'firstNameLastNameFamily\' should map to text associated with custom label with same name.'
        );

        System.assertEquals(
            Label.acctNamingOther,
            accountNamingSettingsModel.validAccountNamingFormatsByName.get('acctNamingOther'),
            'Label name \'acctNamingOther\' should map to text associated with custom label with same name.'
        );
    }
}
