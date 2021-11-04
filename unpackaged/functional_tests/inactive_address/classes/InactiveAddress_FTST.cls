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
 * @group Inactive Address
 * @description Unmanaged functional tests for inactive address
 */
@isTest
private with sharing class InactiveAddress_FTST {
    private static String city = 'San Francisco';
    private static String newCity = 'Toronto';
    private static String street = '415 Mission Street, 3rd Floor';
    private static String postalCode = '94105';
    private static String country = 'US';
    private static String newCountry = 'CA';
    private static String state = 'CA';
    private static String accountName = 'TestAccount12345';
    private static String contactFirstName = 'Sam';
    private static string contactLastName = 'Winchester';

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

    private static Contact createTestContact() {
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

    private static Contact createTestContactWithoutAddress() {
        Contact newContact = new Contact(
            FirstName = contactFirstName,
            LastName = contactLastName,
            hed__Mailing_Address_Inactive__c = false
        );
        insert newContact;
        return newContact;
    }

    private static Account createTestAccount() {
        RecordType administrativeRT = [
            SELECT Id, Name
            FROM RecordType
            WHERE DeveloperName = 'Administrative' AND SobjectType = 'Account'
        ];
        Account newAccount = new Account(
            Name = accountName,
            BillingCity = city,
            BillingState = state,
            BillingStreet = street,
            BillingCountry = country,
            BillingPostalCode = postalCode,
            hed__Billing_County__c = null,
            RecordTypeId = administrativeRT.Id,
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

    private static Account createTestAccountWithoutAddress() {
        RecordType administrativeRT = [
            SELECT Id, Name
            FROM RecordType
            WHERE DeveloperName = 'Administrative' AND SobjectType = 'Account'
        ];
        Account newAccount = new Account(
            Name = accountName,
            RecordTypeId = administrativeRT.Id,
            hed__Billing_Address_Inactive__c = false
        );
        insert newAccount;
        return newAccount;
    }

    /**
     * @description T-6464826: Insert a new Contact with valid address information and inactive as checked
     */
    @isTest
    private static void insertNewContactWithInactiveChecked() {
        createSettings();
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');
        Contact newContact;
        System.runAs(testUser) {
            Test.startTest();
            newContact = new Contact(
                FirstName = 'John',
                LastName = 'Doe',
                MailingCity = city,
                MailingState = state,
                MailingStreet = street,
                MailingCountry = country,
                MailingPostalCode = postalCode,
                hed__Mailing_Address_Inactive__c = true
            );
            insert newContact;
            Test.stopTest();
        }
        Contact insertedContact = [SELECT Id, hed__Mailing_Address_Inactive__c FROM Contact WHERE Id = :newContact.Id];
        List<hed__Address__c> newContactAddressList = [
            SELECT
                hed__MailingCity__c,
                hed__MailingState__c,
                hed__MailingStreet__c,
                hed__MailingCountry__c,
                hed__MailingPostalCode__c,
                hed__Parent_Contact__c,
                hed__Inactive__c
            FROM hed__Address__c
            WHERE hed__Parent_Contact__c = :newContact.Id
        ];
        System.assertEquals(
            true,
            insertedContact.hed__Mailing_Address_Inactive__c,
            'The contact address inactive should be true'
        );
        System.assertEquals(1, newContactAddressList.size(), 'There should be exactly 1 address inserted');
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
        System.assertEquals(true, newContactAddressList[0].hed__Inactive__c, 'The inactive should be true');
    }

    /**
     * @description T-6464973: Insert a new Account with valid address information and inactive as checked
     */
    @isTest
    private static void insertNewAccountWithInactiveChecked() {
        createSettings();
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');
        Account newAccount;
        System.runAs(testUser) {
            Test.startTest();
            RecordType administrativeRT = [
                SELECT Id, Name
                FROM RecordType
                WHERE DeveloperName = 'Administrative' AND SobjectType = 'Account'
            ];
            newAccount = new Account(
                Name = 'New Account',
                BillingCity = city,
                BillingState = state,
                BillingStreet = street,
                BillingCountry = country,
                BillingPostalCode = postalCode,
                RecordTypeId = administrativeRT.Id,
                hed__Billing_Address_Inactive__c = true
            );
            insert newAccount;
            Test.stopTest();
        }
        List<hed__Address__c> newAccountAddressList = [
            SELECT
                hed__MailingCity__c,
                hed__MailingState__c,
                hed__MailingStreet__c,
                hed__MailingCountry__c,
                hed__MailingPostalCode__c,
                hed__Parent_Account__c,
                hed__Inactive__c
            FROM hed__Address__c
            WHERE hed__Parent_Account__c = :newAccount.Id
        ];
        System.assertEquals(1, newAccountAddressList.size(), 'There should be exactly 1 address inserted');
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
        System.assertEquals(true, newAccountAddressList[0].hed__Inactive__c, 'The inactive should be true');
    }

    /**
     * @description T-6464974: Insert a new Account with valid address information and inactive as unchecked
     */
    @isTest
    private static void insertNewAccountWithInactiveUnchecked() {
        createSettings();
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');
        Account newAccount;
        System.runAs(testUser) {
            Test.startTest();
            RecordType administrativeRT = [
                SELECT Id, Name
                FROM RecordType
                WHERE DeveloperName = 'Administrative' AND SobjectType = 'Account'
            ];
            newAccount = new Account(
                Name = 'New Account',
                BillingCity = city,
                BillingState = state,
                BillingStreet = street,
                BillingCountry = country,
                BillingPostalCode = postalCode,
                RecordTypeId = administrativeRT.Id,
                hed__Billing_Address_Inactive__c = false
            );
            insert newAccount;
            Test.stopTest();
        }
        List<hed__Address__c> newAccountAddressList = [
            SELECT
                hed__MailingCity__c,
                hed__MailingState__c,
                hed__MailingStreet__c,
                hed__MailingCountry__c,
                hed__MailingPostalCode__c,
                hed__Parent_Account__c,
                hed__Inactive__c
            FROM hed__Address__c
            WHERE hed__Parent_Account__c = :newAccount.Id
        ];
        System.assertEquals(1, newAccountAddressList.size(), 'There should be exactly 1 address inserted');
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
        System.assertEquals(false, newAccountAddressList[0].hed__Inactive__c, 'The inactive should be false');
    }

    /**
     * @description T-6478481: Insert a new Contact with only inactive as checked
     */
    @isTest
    private static void insertNewContactWithoutAddressInactiveChecked() {
        createSettings();
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');
        Contact newContact;
        System.runAs(testUser) {
            Test.startTest();
            newContact = new Contact(FirstName = 'John', LastName = 'Doe', hed__Mailing_Address_Inactive__c = true);
            insert newContact;
            Test.stopTest();
        }
        Contact insertedContact = [SELECT Id, hed__Mailing_Address_Inactive__c FROM Contact WHERE Id = :newContact.Id];
        List<hed__Address__c> newContactAddressList = [
            SELECT
                hed__MailingCity__c,
                hed__MailingState__c,
                hed__MailingStreet__c,
                hed__MailingCountry__c,
                hed__MailingPostalCode__c,
                hed__Parent_Contact__c,
                hed__Inactive__c
            FROM hed__Address__c
            WHERE hed__Parent_Contact__c = :newContact.Id
        ];
        System.assertEquals(
            true,
            insertedContact.hed__Mailing_Address_Inactive__c,
            'The contact address inactive should be true'
        );
        System.assertEquals(0, newContactAddressList.size(), 'There should not be any address records created');
    }

    /**
     * @description T-6478480: Insert a new Account with only inactive as checked
     */
    @isTest
    private static void insertNewAccountWithoutAddressInactiveChecked() {
        createSettings();
        Account newAccount;
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');
        System.runAs(testUser) {
            Test.startTest();
            RecordType administrativeRT = [
                SELECT Id, Name
                FROM RecordType
                WHERE DeveloperName = 'Administrative' AND SobjectType = 'Account'
            ];
            newAccount = new Account(
                Name = 'New Account',
                RecordTypeId = administrativeRT.Id,
                hed__Billing_Address_Inactive__c = true
            );
            insert newAccount;
            Test.stopTest();
        }
        Account insertedAccount = [SELECT Id, hed__Billing_Address_Inactive__c FROM Account WHERE Id = :newAccount.Id];
        List<hed__Address__c> newAccountAddressList = [
            SELECT
                hed__MailingCity__c,
                hed__MailingState__c,
                hed__MailingStreet__c,
                hed__MailingCountry__c,
                hed__MailingPostalCode__c,
                hed__Parent_Account__c,
                hed__Inactive__c
            FROM hed__Address__c
            WHERE hed__Parent_Account__c = :newAccount.Id
        ];
        System.assertEquals(0, newAccountAddressList.size(), 'There should not be any address records created');
        System.assertEquals(true, insertedAccount.hed__Billing_Address_Inactive__c, 'The inactive should be true');
    }

    /**
     * @description T-6478570: Update an existing Account with current address by toggling the inactive checkbox
     */
    @isTest
    private static void updateExistingAccountWithInactiveToggle() {
        createSettings();
        TDTM_Utility.disableAddressTriggers();
        Account newAccount = createTestAccount();
        TDTM_Utility.enableAddressTriggers();
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');
        System.runAs(testUser) {
            Test.startTest();
            newAccount.hed__Billing_Address_Inactive__c = true;
            update newAccount;
            Test.stopTest();
        }
        List<hed__Address__c> newAccountAddressList = [
            SELECT
                hed__MailingCity__c,
                hed__MailingState__c,
                hed__MailingStreet__c,
                hed__MailingCountry__c,
                hed__MailingPostalCode__c,
                hed__Parent_Account__c,
                hed__Inactive__c
            FROM hed__Address__c
            WHERE hed__Parent_Account__c = :newAccount.Id
        ];
        System.assertEquals(1, newAccountAddressList.size(), 'There should be exactly 1 address inserted');
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
        System.assertEquals(true, newAccountAddressList[0].hed__Inactive__c, 'The inactive should be true');
    }

    /**
     * @description T-6478568: Update an existing Contact with current address by toggling the inactive checkbox
     */
    @isTest
    private static void updateExistingContactWithInactiveToggle() {
        createSettings();
        TDTM_Utility.disableAddressTriggers();
        Contact newContact = createTestContact();
        TDTM_Utility.enableAddressTriggers();
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');
        System.runAs(testUser) {
            Test.startTest();
            newContact.hed__Mailing_Address_Inactive__c = true;
            update newContact;
            Test.stopTest();
        }
        Contact insertedContact = [SELECT Id, hed__Mailing_Address_Inactive__c FROM Contact WHERE Id = :newContact.Id];
        List<hed__Address__c> newContactAddressList = [
            SELECT
                hed__MailingCity__c,
                hed__MailingState__c,
                hed__MailingStreet__c,
                hed__MailingCountry__c,
                hed__MailingPostalCode__c,
                hed__Parent_Contact__c,
                hed__Inactive__c
            FROM hed__Address__c
            WHERE hed__Parent_Contact__c = :newContact.Id
        ];
        System.assertEquals(
            true,
            insertedContact.hed__Mailing_Address_Inactive__c,
            'The contact address inactive should be true'
        );
        System.assertEquals(1, newContactAddressList.size(), 'There should be exactly 1 address inserted');
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
        System.assertEquals(true, newContactAddressList[0].hed__Inactive__c, 'The inactive should be true');
    }

    /**
     * @description T-6478674: Update an existing Account without current address by toggling the inactive checkbox
     */
    @isTest
    private static void updateExistingAccountWithoutAddressInactiveToggle() {
        createSettings();
        TDTM_Utility.disableAddressTriggers();
        Account newAccount = createTestAccountWithoutAddress();
        TDTM_Utility.enableAddressTriggers();
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');
        System.runAs(testUser) {
            Test.startTest();
            newAccount.hed__Billing_Address_Inactive__c = true;
            update newAccount;
            Test.stopTest();
        }
        Account insertedAccount = [SELECT Id, hed__Billing_Address_Inactive__c FROM Account WHERE Id = :newAccount.Id];
        List<hed__Address__c> newAccountAddressList = [
            SELECT
                hed__MailingCity__c,
                hed__MailingState__c,
                hed__MailingStreet__c,
                hed__MailingCountry__c,
                hed__MailingPostalCode__c,
                hed__Parent_Account__c,
                hed__Inactive__c
            FROM hed__Address__c
            WHERE hed__Parent_Account__c = :newAccount.Id
        ];
        System.assertEquals(0, newAccountAddressList.size(), 'There should not be any address records created');
        System.assertEquals(true, insertedAccount.hed__Billing_Address_Inactive__c, 'The inactive should be true');
    }

    /**
     * @description T-6478675: Update an existing Contact without current address by toggling the inactive checkbox
     */
    @isTest
    private static void updateExistingContactWithoutAddressInactiveToggle() {
        createSettings();
        TDTM_Utility.disableAddressTriggers();
        Contact newContact = createTestContactWithoutAddress();
        TDTM_Utility.enableAddressTriggers();
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');
        System.runAs(testUser) {
            Test.startTest();
            newContact.hed__Mailing_Address_Inactive__c = true;
            update newContact;
            Test.stopTest();
        }
        Contact insertedContact = [SELECT Id, hed__Mailing_Address_Inactive__c FROM Contact WHERE Id = :newContact.Id];
        List<hed__Address__c> newContactAddressList = [
            SELECT
                hed__MailingCity__c,
                hed__MailingState__c,
                hed__MailingStreet__c,
                hed__MailingCountry__c,
                hed__MailingPostalCode__c,
                hed__Parent_Contact__c,
                hed__Inactive__c
            FROM hed__Address__c
            WHERE hed__Parent_Contact__c = :newContact.Id
        ];
        System.assertEquals(
            true,
            insertedContact.hed__Mailing_Address_Inactive__c,
            'The contact address inactive should be true'
        );
        System.assertEquals(0, newContactAddressList.size(), 'There should not be any address records');
    }

    /**
     * @description T-6478749: With Simple Address Update disabled, update an existing Contact with current address
     * by changing another address field and toggling the inactive checkbox
     */
    @isTest
    private static void updateExistingContactSimpleAddressUpdateDisabled() {
        hed__Hierarchy_Settings__c orgSettings = createSettings();
        TDTM_Utility.disableAddressTriggers();
        Contact newContact = createTestContact();
        TDTM_Utility.enableAddressTriggers();
        setSimpleAddressUpdate(orgSettings, false);
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');
        System.runAs(testUser) {
            Test.startTest();
            newContact.hed__Mailing_Address_Inactive__c = true;
            newContact.MailingCity = newCity;
            update newContact;
            Test.stopTest();
        }
        Contact insertedContact = [
            SELECT Id, hed__Mailing_Address_Inactive__c, hed__Current_Address__c
            FROM Contact
            WHERE Id = :newContact.Id
        ];
        List<hed__Address__c> newContactAddressList = [
            SELECT
                Id,
                hed__MailingCity__c,
                hed__MailingState__c,
                hed__MailingStreet__c,
                hed__MailingCountry__c,
                hed__MailingPostalCode__c,
                hed__Parent_Contact__c,
                hed__Inactive__c
            FROM hed__Address__c
            WHERE hed__Parent_Contact__c = :newContact.Id
            ORDER BY Id
        ];
        System.assertEquals(
            true,
            insertedContact.hed__Mailing_Address_Inactive__c,
            'The contact address inactive should be true'
        );
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
        System.assertEquals(false, newContactAddressList[0].hed__Inactive__c, 'The inactive should be false');
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
        System.assertEquals(true, newContactAddressList[1].hed__Inactive__c, 'The inactive should be true');
        System.assertEquals(
            insertedContact.hed__Current_Address__c,
            newContactAddressList[1].Id,
            'The current address is incorrect'
        );
    }

    /**
     * @description T-6478750: With Simple Address Update disabled, update an existing Account with current address
     * by changing another address field and toggling the inactive checkbox
     */
    @isTest
    private static void updateExistingAccountSimpleAddressUpdateDisabled() {
        hed__Hierarchy_Settings__c orgSettings = createSettings();
        TDTM_Utility.disableAddressTriggers();
        Account newAccount = createTestAccount();
        TDTM_Utility.enableAddressTriggers();
        setSimpleAddressUpdate(orgSettings, false);
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');
        System.runAs(testUser) {
            Test.startTest();
            newAccount.hed__Billing_Address_Inactive__c = true;
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
                hed__MailingPostalCode__c,
                hed__Parent_Account__c,
                hed__Inactive__c
            FROM hed__Address__c
            WHERE hed__Parent_Account__c = :newAccount.Id
            ORDER BY Id
        ];
        Account insertedAccount = [
            SELECT Id, hed__Billing_Address_Inactive__c, hed__Current_Address__c
            FROM Account
            WHERE Id = :newAccount.Id
        ];
        System.assertEquals(2, newAccountAddressList.size(), 'There should be exactly 2 addresses inserted');
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
        System.assertEquals(false, newAccountAddressList[0].hed__Inactive__c, 'The inactive should be false');
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
        System.assertEquals(true, newAccountAddressList[1].hed__Inactive__c, 'The inactive should be true');
        System.assertEquals(
            newAccountAddressList[1].Id,
            insertedAccount.hed__Current_Address__c,
            'The current account address is incorrect'
        );
    }

    /**
     * @description T-6478800: With Simple Address Update enabled, update an existing Contact with current address
     * by changing another one address field and toggling the inactive checkbox
     */
    @isTest
    private static void updateExistingContactSimpleAddressUpdateEnabled() {
        hed__Hierarchy_Settings__c orgSettings = createSettings();
        TDTM_Utility.disableAddressTriggers();
        Contact newContact = createTestContact();
        TDTM_Utility.enableAddressTriggers();
        setSimpleAddressUpdate(orgSettings, true);
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');
        System.runAs(testUser) {
            Test.startTest();
            newContact.hed__Mailing_Address_Inactive__c = true;
            newContact.MailingCity = newCity;
            update newContact;
            Test.stopTest();
        }
        Contact insertedContact = [
            SELECT Id, hed__Mailing_Address_Inactive__c, hed__Current_Address__c
            FROM Contact
            WHERE Id = :newContact.Id
        ];
        List<hed__Address__c> newContactAddressList = [
            SELECT
                Id,
                hed__MailingCity__c,
                hed__MailingState__c,
                hed__MailingStreet__c,
                hed__MailingCountry__c,
                hed__MailingPostalCode__c,
                hed__Parent_Contact__c,
                hed__Inactive__c
            FROM hed__Address__c
            WHERE hed__Parent_Contact__c = :newContact.Id
            ORDER BY Id
        ];
        System.assertEquals(
            true,
            insertedContact.hed__Mailing_Address_Inactive__c,
            'The contact address inactive should be true'
        );
        System.assertEquals(1, newContactAddressList.size(), 'There should be exactly 1 address inserted');
        System.assertEquals(state, newContactAddressList[0].hed__MailingState__c, 'The state should be ' + state);
        System.assertEquals(newCity, newContactAddressList[0].hed__MailingCity__c, 'The city should be ' + newCity);
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
        System.assertEquals(true, newContactAddressList[0].hed__Inactive__c, 'The inactive should be true');
        System.assertEquals(
            insertedContact.hed__Current_Address__c,
            newContactAddressList[0].Id,
            'The current address is incorrect'
        );
    }

    /**
     * @description T-6478849: With Simple Address Update enabled, update an existing Account with current address
     * by changing another one address field and toggling the inactive checkbox
     */
    @isTest
    private static void updateExistingAccountSimpleAddressUpdateEnabled() {
        hed__Hierarchy_Settings__c orgSettings = createSettings();
        TDTM_Utility.disableAddressTriggers();
        Account newAccount = createTestAccount();
        TDTM_Utility.enableAddressTriggers();
        setSimpleAddressUpdate(orgSettings, true);
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');
        System.runAs(testUser) {
            Test.startTest();
            newAccount.hed__Billing_Address_Inactive__c = true;
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
                hed__MailingPostalCode__c,
                hed__Parent_Account__c,
                hed__Inactive__c
            FROM hed__Address__c
            WHERE hed__Parent_Account__c = :newAccount.Id
            ORDER BY Id
        ];
        Account insertedAccount = [
            SELECT Id, hed__Billing_Address_Inactive__c, hed__Current_Address__c
            FROM Account
            WHERE Id = :newAccount.Id
        ];
        System.assertEquals(1, newAccountAddressList.size(), 'There should be exactly 1 address inserted');
        System.assertEquals(state, newAccountAddressList[0].hed__MailingState__c, 'The state should be ' + state);
        System.assertEquals(newCity, newAccountAddressList[0].hed__MailingCity__c, 'The city should be ' + newCity);
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
        System.assertEquals(true, newAccountAddressList[0].hed__Inactive__c, 'The inactive should be true');
        System.assertEquals(
            newAccountAddressList[0].Id,
            insertedAccount.hed__Current_Address__c,
            'The current account address is incorrect'
        );
    }

    /**
     * @description T-6480273: With Simple Address Update disabled, update an existing Contact with current address
     * by changing another two address fields and toggling the inactive checkbox
     */
    @isTest
    private static void updateExistingContactSimpleAddressUpdateEnabledTwoFields() {
        hed__Hierarchy_Settings__c orgSettings = createSettings();
        TDTM_Utility.disableAddressTriggers();
        Contact newContact = createTestContact();
        TDTM_Utility.enableAddressTriggers();
        setSimpleAddressUpdate(orgSettings, true);
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');
        System.runAs(testUser) {
            Test.startTest();
            newContact.hed__Mailing_Address_Inactive__c = true;
            newContact.MailingCity = newCity;
            newContact.MailingCountry = newCountry;
            update newContact;
            Test.stopTest();
        }
        Contact insertedContact = [
            SELECT Id, hed__Mailing_Address_Inactive__c, hed__Current_Address__c
            FROM Contact
            WHERE Id = :newContact.Id
        ];
        List<hed__Address__c> newContactAddressList = [
            SELECT
                Id,
                hed__MailingCity__c,
                hed__MailingState__c,
                hed__MailingStreet__c,
                hed__MailingCountry__c,
                hed__MailingPostalCode__c,
                hed__Parent_Contact__c,
                hed__Inactive__c
            FROM hed__Address__c
            WHERE hed__Parent_Contact__c = :newContact.Id
            ORDER BY Id
        ];
        System.assertEquals(
            true,
            insertedContact.hed__Mailing_Address_Inactive__c,
            'The contact address inactive should be true'
        );
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
        System.assertEquals(false, newContactAddressList[0].hed__Inactive__c, 'The inactive should be false');

        System.assertEquals(state, newContactAddressList[1].hed__MailingState__c, 'The state should be ' + state);
        System.assertEquals(newCity, newContactAddressList[1].hed__MailingCity__c, 'The city should be ' + newCity);
        System.assertEquals(street, newContactAddressList[1].hed__MailingStreet__c, 'The street should be ' + street);
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
        System.assertEquals(true, newContactAddressList[1].hed__Inactive__c, 'The inactive should be true');
        System.assertEquals(
            newContactAddressList[1].Id,
            insertedContact.hed__Current_Address__c,
            'The current account address is incorrect'
        );

        System.assertEquals(
            insertedContact.hed__Current_Address__c,
            newContactAddressList[1].Id,
            'The current address is incorrect'
        );
    }

    /**
     * @description T-6480274: With Simple Address Update enabled, update an existing Account with current address
     * by changing another two address fields and toggling the inactive checkbox
     */
    @isTest
    private static void updateExistingAccountSimpleAddressUpdateEnabledTwoFields() {
        hed__Hierarchy_Settings__c orgSettings = createSettings();
        TDTM_Utility.disableAddressTriggers();
        Account newAccount = createTestAccount();
        TDTM_Utility.enableAddressTriggers();
        setSimpleAddressUpdate(orgSettings, true);
        User testUser = hed.UTIL_UnitTestData_API.createNewUserForTests(System.now().getTime() + '@testerson.com');
        System.runAs(testUser) {
            Test.startTest();
            newAccount.hed__Billing_Address_Inactive__c = true;
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
                hed__Parent_Account__c,
                hed__Inactive__c
            FROM hed__Address__c
            WHERE hed__Parent_Account__c = :newAccount.Id
            ORDER BY Id
        ];
        Account insertedAccount = [
            SELECT Id, hed__Billing_Address_Inactive__c, hed__Current_Address__c
            FROM Account
            WHERE Id = :newAccount.Id
        ];
        System.assertEquals(2, newAccountAddressList.size(), 'There should be exactly 2 addresses inserted');
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
        System.assertEquals(false, newAccountAddressList[0].hed__Inactive__c, 'The inactive should be false');
        System.assertEquals(state, newAccountAddressList[1].hed__MailingState__c, 'The state should be ' + state);
        System.assertEquals(newCity, newAccountAddressList[1].hed__MailingCity__c, 'The city should be ' + newCity);
        System.assertEquals(street, newAccountAddressList[1].hed__MailingStreet__c, 'The street should be ' + street);
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
        System.assertEquals(true, newAccountAddressList[1].hed__Inactive__c, 'The inactive should be true');
        System.assertEquals(
            newAccountAddressList[1].Id,
            insertedAccount.hed__Current_Address__c,
            'The current account address is incorrect'
        );
    }
}
