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
    private static String city = 'City0';
    private static String newCity = 'Raccoon City';
    private static String street = 'Street0';
    private static String postalCode = 'Zip0';
    private static String country = 'United States';
    private static String county = 'County0';
    private static String newCountry = 'Umbrella';
    private static String state = 'Washington';
    private static String accountName = 'TestAccount12345';

    private static hed__Hierarchy_Settings__c createSettings() {
        hed__Hierarchy_Settings__c orgSettings = hed.UTIL_CustomSettings_API.getOrgSettings();
        hed.UTIL_CustomSettings_API.getSettingsForTests(orgSettings);
        return orgSettings;
    }

    private static void setSimpleAddressUpdate(hed__Hierarchy_Settings__c orgSettings, Boolean value) {
        orgSettings.hed__Simple_Address_Change_Treated_as_Update__c = value;
        hed.UTIL_CustomSettings_API.getSettingsForTests(orgSettings);
    }

    private static void setMultiAddress(hed__Hierarchy_Settings__c orgSettings, Boolean value) {
        orgSettings.hed__Contacts_Addresses_Enabled__c = value;
        hed.UTIL_CustomSettings_API.getSettingsForTests(orgSettings);
    }

    private static Account createTestAccountWithAddress(String recordTypeName) {
        RecordType accountRecordType = [
            SELECT Id, Name
            FROM RecordType
            WHERE DeveloperName = :recordTypeName AND SobjectType = 'Account'
        ];
        Account newAccount = hed.UTIL_UnitTestData_API.getMultipleTestAccounts(1, accountRecordType.Id).get(0);
        newAccount.BillingCity = city;
        newAccount.BillingState = state;
        newAccount.BillingStreet = street;
        newAccount.BillingCountry = country;
        newAccount.BillingPostalCode = postalCode;
        newAccount.hed__Billing_County__c = county;
        newAccount.hed__Billing_Address_Inactive__c = false;
        insert newAccount;
        hed__Address__c addr = hed.UTIL_UnitTestData_API.getMultipleTestAddresses(1).get(0);
        addr.hed__Inactive__c = false;
        addr.hed__Default_Address__c = true;
        addr.hed__Parent_Account__c = newAccount.Id;
        insert addr;
        return newAccount;
    }

    private static Contact createTestContactWithAddress(Id accountId) {
        Contact newContact = createTestContactWithoutAddress(accountId);
        hed__Address__c addr = hed.UTIL_UnitTestData_API.getMultipleTestAddresses(1).get(0);
        addr.hed__Inactive__c = false;
        addr.hed__Default_Address__c = true;
        addr.hed__Parent_Contact__c = newContact.Id;
        insert addr;
        return newContact;
    }

    private static Contact createTestContactWithoutAddress(Id accountId) {
        Contact newContact = hed.UTIL_UnitTestData_API.getMultipleTestContacts(1).get(0);
        newContact.MailingCity = city;
        newContact.MailingState = state;
        newContact.MailingStreet = street;
        newContact.MailingCountry = country;
        newContact.MailingPostalCode = postalCode;
        newContact.hed__Mailing_County__c = county;
        newContact.hed__Mailing_Address_Inactive__c = false;

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
     * ************************ This is the test method for Account ******************************************
     */
    @isTest
    private static void updateExistingAdministrativeAccountSimpleAddressUpdateDisabledMultiAddressEnabled() {
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
     * ************************ This is the test method for Contact ******************************************
     */
    @isTest
    private static void updateExistingAdministrativeContactSimpleAddressUpdateDisabledMultiAddressEnabled() {
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

    /**
     * @description T-3904092: Modify address record updates the mailing address field values on the Contact record
     */
    @isTest
    private static void updateAddressRecordUpdatesMailingContactAddress() {
        hed__Hierarchy_Settings__c orgSettings = createSettings();
        TDTM_Utility.disableAddressTriggers();
        Account newAccount = createTestAccountWithAddress('Administrative');
        Contact newContact = createTestContactWithAddress(newAccount.Id);
        TDTM_Utility.enableAddressTriggers();
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');

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

        System.runAs(testUser) {
            Test.startTest();

            //Update the mailing city on the Address record
            newContactAddressList.get(0).hed__MailingCity__c = newCity;
            update newContactAddressList;

            Test.stopTest();
        }

        //Reload the mailing field values for the new Contact
        newContact = [
            SELECT
                Id,
                MailingCity,
                MailingState,
                MailingStreet,
                MailingCountry,
                MailingPostalCode,
                hed__Current_Address__c
            FROM Contact
            WHERE Id = :newContact.Id
        ];

        System.assertEquals(state, newContact.MailingState, 'The state should be ' + state);
        System.assertEquals(newCity, newContact.MailingCity, 'The city should be ' + newCity);
        System.assertEquals(street, newContact.MailingStreet, 'The street should be ' + street);
        System.assertEquals(country, newContact.MailingCountry, 'The country should be ' + country);
        System.assertEquals(postalCode, newContact.MailingPostalCode, 'The postal code should be ' + postalCode);

        System.assertEquals(
            newContact.hed__Current_Address__c,
            newContactAddressList[0].Id,
            'The current address is incorrect'
        );
    }

    /**
     * @description T-7222806 Simple Address Change Treated as Update - Only one address field is modified.
     * Note: for simplicity we will separate this into 2 methods: one for account and one for contact.
     * ************************ This is the test method for Contact ******************************************
     */
    @isTest
    private static void updateOneFieldContactSimpleAddressUpdateEnabled() {
        hed__Hierarchy_Settings__c orgSettings = createSettings();
        TDTM_Utility.disableAddressTriggers();
        Account newAccount = createTestAccountWithAddress('Administrative');
        Contact newContact = createTestContactWithAddress(newAccount.Id);
        TDTM_Utility.enableAddressTriggers();
        setSimpleAddressUpdate(orgSettings, true);
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');
        System.runAs(testUser) {
            Test.startTest();
            newContact.MailingCity = newCity;
            update newContact;
            Test.stopTest();
        }
        Contact insertedContact = [SELECT Id, hed__Current_Address__c FROM Contact WHERE Id = :newContact.Id];
        List<hed__Address__c> newContactAddressList = [
            SELECT
                Id,
                hed__MailingCity__c,
                hed__MailingState__c,
                hed__MailingStreet__c,
                hed__MailingCountry__c,
                hed__MailingCounty__c,
                hed__MailingPostalCode__c,
                hed__Parent_Contact__c
            FROM hed__Address__c
            WHERE hed__Parent_Contact__c = :newContact.Id
            ORDER BY Id
        ];

        System.assertEquals(1, newContactAddressList.size(), 'There should be exactly 1 address inserted');
        System.assertEquals(state, newContactAddressList[0].hed__MailingState__c, 'The state should be ' + state);
        System.assertEquals(newCity, newContactAddressList[0].hed__MailingCity__c, 'The city should be ' + newCity);
        System.assertEquals(street, newContactAddressList[0].hed__MailingStreet__c, 'The street should be ' + street);
        System.assertEquals(county, newContactAddressList[0].hed__MailingCounty__c, 'The county should be ' + county);
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
        System.assertEquals(
            insertedContact.hed__Current_Address__c,
            newContactAddressList[0].Id,
            'The current address is incorrect'
        );
    }

    /**
     * @description T-7222806 Simple Address Change Treated as Update - Only one address field is modified.
     * Note: for simplicity we will separate this into 2 methods: one for account and one for contact.
     * ************************ This is the test method for Account ******************************************
     */
    @isTest
    private static void updateOneFieldAccountSimpleAddressUpdateEnabled() {
        hed__Hierarchy_Settings__c orgSettings = createSettings();
        TDTM_Utility.disableAddressTriggers();
        Account newAccount = createTestAccountWithAddress('Administrative');
        TDTM_Utility.enableAddressTriggers();
        setSimpleAddressUpdate(orgSettings, true);
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');
        System.runAs(testUser) {
            Test.startTest();
            newAccount.BillingCity = newCity;
            update newAccount;
            Test.stopTest();
        }
        List<hed__Address__c> newAccountAddressList = [
            SELECT
                Id,
                hed__MailingCity__c,
                hed__MailingState__c,
                hed__MailingStreet__c,
                hed__MailingCountry__c,
                hed__MailingCounty__c,
                hed__MailingPostalCode__c,
                hed__Parent_Account__c
            FROM hed__Address__c
            WHERE hed__Parent_Account__c = :newAccount.Id
            ORDER BY Id
        ];
        Account insertedAccount = [SELECT Id, hed__Current_Address__c FROM Account WHERE Id = :newAccount.Id];
        System.assertEquals(1, newAccountAddressList.size(), 'There should be exactly 1 address inserted');
        System.assertEquals(state, newAccountAddressList[0].hed__MailingState__c, 'The state should be ' + state);
        System.assertEquals(newCity, newAccountAddressList[0].hed__MailingCity__c, 'The city should be ' + newCity);
        System.assertEquals(street, newAccountAddressList[0].hed__MailingStreet__c, 'The street should be ' + street);
        System.assertEquals(county, newAccountAddressList[0].hed__MailingCounty__c, 'The county should be ' + county);
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
        System.assertEquals(
            newAccountAddressList[0].Id,
            insertedAccount.hed__Current_Address__c,
            'The current account address is incorrect'
        );
    }

    /**
     * @description T-3904090 Simple Address Change Treated as New Address - Two address fields are modified
     * Note: for simplicity we will separate this into 2 methods: one for account and one for contact.
     * ************************ This is the test method for Contact ******************************************
     */
    @isTest
    private static void updateTwoFieldsContactSimpleAddressUpdateEnabled() {
        hed__Hierarchy_Settings__c orgSettings = createSettings();
        TDTM_Utility.disableAddressTriggers();
        Account newAccount = createTestAccountWithAddress('Administrative');
        Contact newContact = createTestContactWithAddress(newAccount.Id);
        TDTM_Utility.enableAddressTriggers();
        setSimpleAddressUpdate(orgSettings, true);
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');
        System.runAs(testUser) {
            Test.startTest();
            newContact.MailingCity = newCity;
            newContact.MailingCountry = newCountry;
            update newContact;
            Test.stopTest();
        }
        Contact insertedContact = [SELECT Id, hed__Current_Address__c FROM Contact WHERE Id = :newContact.Id];
        List<hed__Address__c> newContactAddressList = [
            SELECT
                Id,
                hed__MailingCity__c,
                hed__MailingState__c,
                hed__MailingStreet__c,
                hed__MailingCountry__c,
                hed__MailingCounty__c,
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
        System.assertEquals(county, newContactAddressList[0].hed__MailingCounty__c, 'The county should be ' + county);
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
        System.assertEquals(county, newContactAddressList[1].hed__MailingCounty__c, 'The county should be ' + county);
        System.assertEquals(
            newCountry,
            newContactAddressList[1].hed__MailingCountry__c,
            'The country should be ' + newCountry
        );
        System.assertEquals(
            postalCode,
            newContactAddressList[1].hed__MailingPostalCode__c,
            'The postal code should be ' + postalCode
        );
        System.assertEquals(
            newContactAddressList[1].Id,
            insertedContact.hed__Current_Address__c,
            'The current account address is incorrect'
        );
    }

    /**
     * @description T-3904090 Simple Address Change Treated as New Address - Two address fields are modified
     * Note: for simplicity we will separate this into 2 methods: one for account and one for contact.
     * ************************ This is the test method for Account ******************************************
     */
    @isTest
    private static void updateTwoFieldsAccountSimpleAddressUpdateEnabled() {
        hed__Hierarchy_Settings__c orgSettings = createSettings();
        TDTM_Utility.disableAddressTriggers();
        Account newAccount = createTestAccountWithAddress('Administrative');
        TDTM_Utility.enableAddressTriggers();
        setSimpleAddressUpdate(orgSettings, true);
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');
        System.runAs(testUser) {
            Test.startTest();
            newAccount.BillingCity = newCity;
            newAccount.BillingCountry = newCountry;
            update newAccount;
            Test.stopTest();
        }
        List<hed__Address__c> newAccountAddressList = [
            SELECT
                Id,
                hed__MailingCity__c,
                hed__MailingState__c,
                hed__MailingStreet__c,
                hed__MailingCountry__c,
                hed__MailingPostalCode__c,
                hed__MailingCounty__c,
                hed__Parent_Account__c
            FROM hed__Address__c
            WHERE hed__Parent_Account__c = :newAccount.Id
            ORDER BY Id
        ];
        Account insertedAccount = [SELECT Id, hed__Current_Address__c FROM Account WHERE Id = :newAccount.Id];
        System.assertEquals(2, newAccountAddressList.size(), 'There should be exactly 2 addresses inserted');
        System.assertEquals(state, newAccountAddressList[0].hed__MailingState__c, 'The state should be ' + state);
        System.assertEquals(city, newAccountAddressList[0].hed__MailingCity__c, 'The city should be ' + city);
        System.assertEquals(street, newAccountAddressList[0].hed__MailingStreet__c, 'The street should be ' + street);
        System.assertEquals(county, newAccountAddressList[0].hed__MailingCounty__c, 'The county should be ' + county);
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
        System.assertEquals(county, newAccountAddressList[1].hed__MailingCounty__c, 'The county should be ' + county);
        System.assertEquals(
            newCountry,
            newAccountAddressList[1].hed__MailingCountry__c,
            'The country should be ' + newCountry
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
     * @description T-3904089 When Deleting an address, the filter field and usernames to exclude filters must work in
     * the trigger handler for the address trigger ADDR_Addresses_TDTM, the contact mailing address must remain filled in
     */
    @isTest
    private static void deleteAddressRecordLinkedToContactFieldFilterEnabled() {
        hed__Hierarchy_Settings__c orgSettings = createSettings();
        TDTM_Utility.disableAddressTriggers();
        Account newAccount = createTestAccountWithAddress('Administrative');
        Contact newContact = createTestContactWithAddress(newAccount.Id);
        TDTM_Utility.enableAddressTriggers();

        //Retrieves the defaultTDTMConfig
        List<hed.TDTM_Global_API.TdtmToken> tokens = hed.TDTM_Global_API.getDefaultTdtmConfig();

        //Add filter on ADDR_Addresses_TDTM triggerHandler
        for (hed.TDTM_Global_API.TdtmToken token : tokens) {
            if (token.className == 'ADDR_Addresses_TDTM') {
                token.filterField = 'MailingStreet__c';
                token.filterValue = street;
            }
        }
        hed.TDTM_Global_API.setTdtmConfig(tokens);

        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');
        List<hed__Address__c> newContactAddressList = [
            SELECT Id
            FROM hed__Address__c
            WHERE hed__Parent_Contact__c = :newContact.Id
            ORDER BY Id
        ];

        System.runAs(testUser) {
            Test.startTest();
            delete newContactAddressList;
            Test.stopTest();
        }
        Contact insertedContact = [
            SELECT
                Id,
                hed__Current_Address__c,
                MailingState,
                MailingCity,
                MailingStreet,
                MailingCountry,
                MailingPostalCode,
                hed__Mailing_County__c
            FROM Contact
            WHERE Id = :newContact.Id
        ];

        newContactAddressList = [
            SELECT Id, hed__Parent_Contact__c
            FROM hed__Address__c
            WHERE hed__Parent_Contact__c = :newContact.Id
            ORDER BY Id
        ];

        //Assert the address record got deleted
        System.assertEquals(0, newContactAddressList.size(), 'There should be exactly 0 address inserted');

        //The mailing fields on Contact should remain the filled in
        System.assertEquals(state, insertedContact.MailingState, 'The state should be ' + state);
        System.assertEquals(city, insertedContact.MailingCity, 'The city should be ' + city);
        System.assertEquals(street, insertedContact.MailingStreet, 'The street should be ' + street);
        System.assertEquals(county, insertedContact.hed__Mailing_County__c, 'The county should be ' + county);
        System.assertEquals(country, insertedContact.MailingCountry, 'The country should be ' + country);
        System.assertEquals(postalCode, insertedContact.MailingPostalCode, 'The postal code should be ' + postalCode);
        System.assertEquals(null, insertedContact.hed__Current_Address__c, 'The current address is incorrect');
    }
}
