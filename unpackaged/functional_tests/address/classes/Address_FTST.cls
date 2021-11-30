/*
    Copyright (c) 2021, Salesforce.org
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
 * @date 2021
 * @group Inactive Address
 * @description Unmanaged functional tests for address
 */
@isTest
public with sharing class Address_FTST {
    private static String city = 'San Francisco';
    private static String newCity = 'Raccoon City';
    private static String street = '415 Mission Street, 3rd Floor';
    private static String postalCode = '94105';
    private static String country = 'US';
    private static String newCountry = 'Umbrella';
    private static String state = 'CA';
    private static String accountName = 'TestAccount12345';
    private static String contactFirstName = 'John';
    private static string contactLastName = 'Connor';

    private static hed__Hierarchy_Settings__c createSettings() {
        hed__Hierarchy_Settings__c orgSettings = hed.UTIL_CustomSettings_API.getOrgSettings();
        upsert orgSettings;
        hed.UTIL_CustomSettings_API.getSettingsForTests(orgSettings);
        return orgSettings;
    }

    private static void setSimpleAddressUpdate(hed__Hierarchy_Settings__c orgSettings, Boolean value) {
        orgSettings.hed__Simple_Address_Change_Treated_as_Update__c = value;
        hed.UTIL_CustomSettings_API.getSettingsForTests(orgSettings);
        update orgSettings;
    }

    private static void setMultiAddress(hed__Hierarchy_Settings__c orgSettings, Boolean value) {
        orgSettings.hed__Contacts_Addresses_Enabled__c = value;
        hed.UTIL_CustomSettings_API.getSettingsForTests(orgSettings);
        update orgSettings;
    }

    private static Account createTestAccountWithAddress(String recordTypeName) {
        RecordType accountRecordType = [
            SELECT Id, Name
            FROM RecordType
            WHERE DeveloperName = :recordTypeName AND SobjectType = 'Account'
        ];
        Account newAccount = new Account(
            Name = accountName,
            BillingCity = city,
            BillingState = state,
            BillingStreet = street,
            BillingCountry = country,
            BillingPostalCode = postalCode,
            hed__Billing_County__c = null,
            RecordTypeId = accountRecordType.Id,
            hed__Billing_Address_Inactive__c = false
        );
        insert newAccount;
        hed__Address__c addr = new hed__Address__c(
            hed__Address_Type__c = 'Home',
            hed__MailingStreet__c = street,
            hed__MailingCity__c = city,
            hed__MailingState__c = state,
            hed__MailingPostalCode__c = postalCode,
            hed__MailingCountry__c = country,
            hed__MailingCounty__c = null,
            hed__Inactive__c = false,
            hed__Default_Address__c = true,
            hed__Parent_Account__c = newAccount.Id
        );
        insert addr;
        return newAccount;
    }

    private static Contact createTestContactWithAddress(Id accountId) {
        Contact newContact = new Contact(
            FirstName = contactFirstName,
            LastName = contactLastName,
            MailingCity = city,
            MailingState = state,
            MailingStreet = street,
            MailingCountry = country,
            MailingPostalCode = postalCode,
            hed__Mailing_County__c = null,
            hed__Mailing_Address_Inactive__c = false
        );
        if (String.isNotBlank(accountId)) {
            newContact.accountId = accountId;
        }

        insert newContact;
        hed__Address__c addr = new hed__Address__c(
            hed__Address_Type__c = 'Home',
            hed__MailingStreet__c = street,
            hed__MailingCity__c = city,
            hed__MailingState__c = state,
            hed__MailingPostalCode__c = postalCode,
            hed__MailingCountry__c = country,
            hed__MailingCounty__c = null,
            hed__Inactive__c = false,
            hed__Default_Address__c = true,
            hed__Parent_Contact__c = newContact.Id
        );
        insert addr;
        return newContact;
    }

    private static Contact createTestContactWithoutAddress(Id accountId) {
        Contact newContact = new Contact(
            FirstName = contactFirstName,
            LastName = contactLastName,
            MailingCity = city,
            MailingState = state,
            MailingStreet = street,
            MailingCountry = country,
            MailingPostalCode = postalCode,
            hed__Mailing_County__c = null,
            hed__Mailing_Address_Inactive__c = false
        );
        if (String.isNotBlank(accountId)) {
            newContact.accountId = accountId;
        }

        insert newContact;
        return newContact;
    }

    /**
     * @description T-3904083: Enable Multiple Addresses for Account: Using Administrative account model Modify an
     * existing Contact & existing Account and verify new address records creation under Contact and Account
     * Note: for simplicity we will separate this into 2 methods: one for account and one for contact.
     * ************************ This is the test method for one for Account ******************************************
     */
    @isTest
    private static void updateExistingAdministrativeAccountSimpleAddressUpdateMultiAddress() {
        hed__Hierarchy_Settings__c orgSettings = createSettings();
        TDTM_Utility.disableAddressTriggers();
        Account newAccount = createTestAccountWithAddress('Administrative');
        TDTM_Utility.enableAddressTriggers();
        setMultiAddress(orgSettings, true);
        setSimpleAddressUpdate(orgSettings, false);
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');

        System.runAs(testUser) {
            Test.startTest();

            //Update the billing vity on Account
            newAccount.BillingCity = newCity;
            update newAccount;

            Test.stopTest();
        }

        //Assert the account and address logic
        List<hed__Address__c> newAccountAddressList = [
            SELECT
                Id,
                hed__MailingCity__c,
                hed__MailingState__c,
                hed__MailingStreet__c,
                hed__MailingCountry__c,
                hed__MailingPostalCode__c,
                hed__Parent_Account__c
            FROM hed__Address__c
            WHERE hed__Parent_Account__c = :newAccount.Id
            ORDER BY Id
        ];

        Account insertedAccount = [SELECT Id, hed__Current_Address__c FROM Account WHERE Id = :newAccount.Id];

        System.assertEquals(2, newAccountAddressList.size(), 'There should be exactly 2 addresses inserted');

        //Existing address
        System.assertEquals(state, newAccountAddressList[0].hed__MailingState__c, 'The state should be ' + state);
        System.assertEquals(city, newAccountAddressList[0].hed__MailingCity__c, 'The city should be ' + city);
        System.assertEquals(street, newAccountAddressList[0].hed__MailingStreet__c, 'The street should be ' + street);
        System.assertEquals(
            country,
            newAccountAddressList[0].hed__MailingCountry__c,
            'The country should be ' + country
        );
        System.assertEquals(
            postalCode,
            newAccountAddressList[0].hed__MailingPostalCode__c,
            'The postal code should be ' + postalCode
        );

        //New address inserted
        System.assertEquals(state, newAccountAddressList[1].hed__MailingState__c, 'The state should be ' + state);
        System.assertEquals(newCity, newAccountAddressList[1].hed__MailingCity__c, 'The city should be ' + newCity);
        System.assertEquals(street, newAccountAddressList[1].hed__MailingStreet__c, 'The street should be ' + street);
        System.assertEquals(
            country,
            newAccountAddressList[1].hed__MailingCountry__c,
            'The country should be ' + country
        );
        System.assertEquals(
            postalCode,
            newAccountAddressList[1].hed__MailingPostalCode__c,
            'The postal code should be ' + postalCode
        );
        System.assertEquals(
            newAccountAddressList[1].Id,
            insertedAccount.hed__Current_Address__c,
            'The current account address is incorrect'
        );
    }

    /**
     * @description T-3904083: Enable Multiple Addresses for Account: Using Administrative account model Modify an
     * existing Contact & existing Account and verify new address records creation under Contact and Account
     * Note: for simplicity we will separate this into 2 test methods: one for account and one for contact.
     * ************************ This is the test method for one for Contact ******************************************
     */
    @isTest
    private static void updateExistingAdministrativeContactSimpleAddressUpdateMultiAddress() {
        hed__Hierarchy_Settings__c orgSettings = createSettings();
        TDTM_Utility.disableAddressTriggers();
        Account newAccount = createTestAccountWithAddress('Administrative');
        Contact newContact = createTestContactWithAddress(newAccount.Id);
        TDTM_Utility.enableAddressTriggers();
        setMultiAddress(orgSettings, true);
        setSimpleAddressUpdate(orgSettings, false);
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');

        System.runAs(testUser) {
            Test.startTest();

            //Update the mailing city on Contact
            newContact.MailingCity = newCity;
            update newContact;

            Test.stopTest();
        }

        //Assert the contact and address logic
        Contact insertedContact = [SELECT Id, hed__Current_Address__c FROM Contact WHERE Id = :newContact.Id];
        List<hed__Address__c> newContactAddressList = [
            SELECT
                Id,
                hed__MailingCity__c,
                hed__MailingState__c,
                hed__MailingStreet__c,
                hed__MailingCountry__c,
                hed__MailingPostalCode__c,
                hed__Parent_Contact__c
            FROM hed__Address__c
            WHERE hed__Parent_Contact__c = :newContact.Id
            ORDER BY Id
        ];

        System.assertEquals(2, newContactAddressList.size(), 'There should be exactly 2 addresses inserted');
        System.assertEquals(state, newContactAddressList[0].hed__MailingState__c, 'The state should be ' + state);
        System.assertEquals(city, newContactAddressList[0].hed__MailingCity__c, 'The city should be ' + city);
        System.assertEquals(street, newContactAddressList[0].hed__MailingStreet__c, 'The street should be ' + street);
        System.assertEquals(
            country,
            newContactAddressList[0].hed__MailingCountry__c,
            'The country should be ' + country
        );
        System.assertEquals(
            postalCode,
            newContactAddressList[0].hed__MailingPostalCode__c,
            'The postal code should be ' + postalCode
        );

        System.assertEquals(state, newContactAddressList[1].hed__MailingState__c, 'The state should be ' + state);
        System.assertEquals(newCity, newContactAddressList[1].hed__MailingCity__c, 'The city should be ' + newCity);
        System.assertEquals(street, newContactAddressList[1].hed__MailingStreet__c, 'The street should be ' + street);
        System.assertEquals(
            country,
            newContactAddressList[1].hed__MailingCountry__c,
            'The country should be ' + country
        );
        System.assertEquals(
            postalCode,
            newContactAddressList[1].hed__MailingPostalCode__c,
            'The postal code should be ' + postalCode
        );
        System.assertEquals(
            insertedContact.hed__Current_Address__c,
            newContactAddressList[1].Id,
            'The current address is incorrect'
        );
    }

    /**
     * @description T-3904085: Using Household account model, modify an existing Contact Address and assess new address
     * creation under Household account
     */
    @isTest
    private static void updateExistingHouseholdAccountContactAddress() {
        hed__Hierarchy_Settings__c orgSettings = createSettings();
        TDTM_Utility.disableAddressTriggers();

        //Create a new Account with address and a Contact without an address
        Account newAccount = createTestAccountWithAddress('HH_Account');
        Contact newContact = createTestContactWithoutAddress(newAccount.Id);

        //Link the saved account address to the contact's current address and map its mailing address data.
        List<hed__Address__c> newAccountAddressList = [
            SELECT
                Id,
                hed__MailingCity__c,
                hed__MailingState__c,
                hed__MailingStreet__c,
                hed__MailingCountry__c,
                hed__MailingPostalCode__c,
                hed__Parent_Contact__c
            FROM hed__Address__c
            WHERE hed__Parent_Account__c = :newAccount.Id
            ORDER BY Id
        ];
        hed__Address__c accountSavedAddress = newAccountAddressList.get(0);
        newContact.hed__Current_Address__c = accountSavedAddress.Id;
        newContact.MailingCity = accountSavedAddress.hed__MailingCity__c;
        newContact.MailingState = accountSavedAddress.hed__MailingState__c;
        newContact.MailingStreet = accountSavedAddress.hed__MailingStreet__c;
        newContact.MailingCountry = accountSavedAddress.hed__MailingCountry__c;
        newContact.MailingPostalCode = accountSavedAddress.hed__MailingPostalCode__c;
        update newContact;

        TDTM_Utility.enableAddressTriggers();
        setMultiAddress(orgSettings, true);
        setSimpleAddressUpdate(orgSettings, false);
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');

        System.runAs(testUser) {
            Test.startTest();

            //Update the mailing city on Contact
            newContact.MailingCity = newCity;
            update newContact;

            Test.stopTest();
        }

        //Assert the contact and address logic
        Contact insertedContact = [SELECT Id, hed__Current_Address__c FROM Contact WHERE Id = :newContact.Id];
        List<hed__Address__c> newContactAddressList = [
            SELECT Id
            FROM hed__Address__c
            WHERE hed__Parent_Contact__c = :newContact.Id
            ORDER BY Id
        ];
        System.assertEquals(0, newContactAddressList.size(), 'There should be exactly 0 addresses inserted');

        //load the address fiels from the address record for the household account
        newAccountAddressList = [
            SELECT
                Id,
                hed__MailingCity__c,
                hed__MailingState__c,
                hed__MailingStreet__c,
                hed__MailingCountry__c,
                hed__MailingPostalCode__c,
                hed__Parent_Contact__c
            FROM hed__Address__c
            WHERE hed__Parent_Account__c = :newAccount.Id
            ORDER BY Id
        ];

        System.assertEquals(state, newAccountAddressList[0].hed__MailingState__c, 'The state should be ' + state);
        System.assertEquals(city, newAccountAddressList[0].hed__MailingCity__c, 'The city should be ' + city);
        System.assertEquals(street, newAccountAddressList[0].hed__MailingStreet__c, 'The street should be ' + street);
        System.assertEquals(
            country,
            newAccountAddressList[0].hed__MailingCountry__c,
            'The country should be ' + country
        );
        System.assertEquals(
            postalCode,
            newAccountAddressList[0].hed__MailingPostalCode__c,
            'The postal code should be ' + postalCode
        );

        System.assertEquals(state, newAccountAddressList[1].hed__MailingState__c, 'The state should be ' + state);
        System.assertEquals(newCity, newAccountAddressList[1].hed__MailingCity__c, 'The city should be ' + newCity);
        System.assertEquals(street, newAccountAddressList[1].hed__MailingStreet__c, 'The street should be ' + street);
        System.assertEquals(
            country,
            newAccountAddressList[1].hed__MailingCountry__c,
            'The country should be ' + country
        );
        System.assertEquals(
            postalCode,
            newAccountAddressList[1].hed__MailingPostalCode__c,
            'The postal code should be ' + postalCode
        );
        System.assertEquals(
            insertedContact.hed__Current_Address__c,
            newAccountAddressList[1].Id,
            'The current address is incorrect'
        );
    }
}
