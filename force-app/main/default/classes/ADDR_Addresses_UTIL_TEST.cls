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
 * @group
 * @group-content ../../ApexDocContent/
 * @description Test class for ADDR_Addresses_UTIL.
 */
@isTest
private with sharing class ADDR_Addresses_UTIL_TEST {
    /**************************************************************************************************************************
     ****************************************************** isAddressEmpty ****************************************************
     **************************************************************************************************************************/
    @isTest
    static void testIsAddressEmptyFalseMailingStreetNotEmpty() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);
        addresses[0].MailingStreet__c = null;
        addresses[0].MailingStreet2__c = null;
        addresses[0].MailingCity__c = null;
        addresses[0].MailingCounty__c = null;
        addresses[0].MailingState__c = null;
        addresses[0].MailingPostalCode__c = null;
        addresses[0].MailingCountry__c = null;
        addresses[0].MailingStreet__c = 'Some random mailing street';

        Test.startTest();
        Boolean isAddressEmpty = ADDR_Addresses_UTIL.isAddressEmpty(addresses[0]);
        Test.stopTest();

        System.assertEquals(false, isAddressEmpty);
    }

    @isTest
    static void testIsAddressEmptyFalseMailingStreet2NotEmpty() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);
        addresses[0].MailingStreet__c = null;
        addresses[0].MailingStreet2__c = null;
        addresses[0].MailingCity__c = null;
        addresses[0].MailingCounty__c = null;
        addresses[0].MailingState__c = null;
        addresses[0].MailingPostalCode__c = null;
        addresses[0].MailingCountry__c = null;
        addresses[0].MailingStreet2__c = 'Some random mailing street 2';

        Test.startTest();
        Boolean isAddressEmpty = ADDR_Addresses_UTIL.isAddressEmpty(addresses[0]);
        Test.stopTest();

        System.assertEquals(false, isAddressEmpty);
    }

    @isTest
    static void testIsAddressEmptyFalseMailingCityNotEmpty() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);
        addresses[0].MailingStreet__c = null;
        addresses[0].MailingStreet2__c = null;
        addresses[0].MailingCity__c = null;
        addresses[0].MailingCounty__c = null;
        addresses[0].MailingState__c = null;
        addresses[0].MailingPostalCode__c = null;
        addresses[0].MailingCountry__c = null;
        addresses[0].MailingCity__c = 'Some random mailing city';

        Test.startTest();
        Boolean isAddressEmpty = ADDR_Addresses_UTIL.isAddressEmpty(addresses[0]);
        Test.stopTest();

        System.assertEquals(false, isAddressEmpty);
    }

    @isTest
    static void testIsAddressEmptyFalseMailingCountyNotEmpty() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);
        addresses[0].MailingStreet__c = null;
        addresses[0].MailingStreet2__c = null;
        addresses[0].MailingCity__c = null;
        addresses[0].MailingCounty__c = null;
        addresses[0].MailingState__c = null;
        addresses[0].MailingPostalCode__c = null;
        addresses[0].MailingCountry__c = null;
        addresses[0].MailingCounty__c = 'Some random mailing county';

        Test.startTest();
        Boolean isAddressEmpty = ADDR_Addresses_UTIL.isAddressEmpty(addresses[0]);
        Test.stopTest();

        System.assertEquals(false, isAddressEmpty);
    }

    @isTest
    static void testIsAddressEmptyFalseMailingStateNotEmpty() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);
        addresses[0].MailingStreet__c = null;
        addresses[0].MailingStreet2__c = null;
        addresses[0].MailingCity__c = null;
        addresses[0].MailingCounty__c = null;
        addresses[0].MailingState__c = null;
        addresses[0].MailingPostalCode__c = null;
        addresses[0].MailingCountry__c = null;
        addresses[0].MailingState__c = 'Some random mailing state';

        Test.startTest();
        Boolean isAddressEmpty = ADDR_Addresses_UTIL.isAddressEmpty(addresses[0]);
        Test.stopTest();

        System.assertEquals(false, isAddressEmpty);
    }

    @isTest
    static void testIsAddressEmptyFalseMailingPostCodeNotEmpty() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);
        addresses[0].MailingStreet__c = null;
        addresses[0].MailingStreet2__c = null;
        addresses[0].MailingCity__c = null;
        addresses[0].MailingCounty__c = null;
        addresses[0].MailingState__c = null;
        addresses[0].MailingPostalCode__c = null;
        addresses[0].MailingCountry__c = null;
        addresses[0].MailingPostalCode__c = 'Some random mailing postcode';

        Test.startTest();
        Boolean isAddressEmpty = ADDR_Addresses_UTIL.isAddressEmpty(addresses[0]);
        Test.stopTest();

        System.assertEquals(false, isAddressEmpty);
    }

    @isTest
    static void testIsAddressEmptyFalseMailingCountryNotEmpty() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);
        addresses[0].MailingStreet__c = null;
        addresses[0].MailingStreet2__c = null;
        addresses[0].MailingCity__c = null;
        addresses[0].MailingCounty__c = null;
        addresses[0].MailingState__c = null;
        addresses[0].MailingPostalCode__c = null;
        addresses[0].MailingCountry__c = null;
        addresses[0].MailingCountry__c = 'Some random mailing country';

        Test.startTest();
        Boolean isAddressEmpty = ADDR_Addresses_UTIL.isAddressEmpty(addresses[0]);
        Test.stopTest();

        System.assertEquals(false, isAddressEmpty);
    }

    @isTest
    static void testIsAddressEmptyTrue() {
        //This will fail every time we adding a new field
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);
        addresses[0].MailingStreet__c = null;
        addresses[0].MailingStreet2__c = null;
        addresses[0].MailingCity__c = null;
        addresses[0].MailingCounty__c = null;
        addresses[0].MailingState__c = null;
        addresses[0].MailingPostalCode__c = null;
        addresses[0].MailingCountry__c = null;

        Test.startTest();
        Boolean isAddressEmpty = ADDR_Addresses_UTIL.isAddressEmpty(addresses[0]);
        Test.stopTest();

        System.assertEquals(true, isAddressEmpty);
    }

    @isTest
    static void testIsAddressEmptyNull() {
        //This is working but null address is not empty does not make sense
        Test.startTest();
        Boolean isAddressEmpty = ADDR_Addresses_UTIL.isAddressEmpty(null);
        Test.stopTest();

        System.assertEquals(false, isAddressEmpty);
    }

    /**************************************************************************************************************************
     ****************************************************** isContactAccAddrInfoSame ******************************************
     **************************************************************************************************************************/
    @isTest
    static void testIsContactAccAddrInfoSameTrue() {
        Contact contact = UTIL_UnitTestData_TEST.getContact();
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        );

        Test.startTest();
        Boolean isContactAccAddrInfoSame = ADDR_Addresses_UTIL.isContactAccAddrInfoSame(contact, accounts[0]);
        Test.stopTest();

        System.assertEquals(true, isContactAccAddrInfoSame);
    }

    @isTest
    static void testIsContactAccAddrInfoSameDifferentMailingCity() {
        Contact contact = UTIL_UnitTestData_TEST.getContact();
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        contact.MailingCity = 'Something else';

        Test.startTest();
        Boolean isContactAccAddrInfoSame = ADDR_Addresses_UTIL.isContactAccAddrInfoSame(contact, accounts[0]);
        Test.stopTest();

        System.assertEquals(false, isContactAccAddrInfoSame);
    }

    @isTest
    static void testIsContactAccAddrInfoSameDifferentMailingCounty() {
        Contact contact = UTIL_UnitTestData_TEST.getContact();
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe.getBizAccRecTypeID());
        contact.Mailing_County__c = 'Something else';

        Test.startTest();
        Boolean isContactAccAddrInfoSame = ADDR_Addresses_UTIL.isContactAccAddrInfoSame(contact, accounts[0]);
        Test.stopTest();

        System.assertEquals(false, isContactAccAddrInfoSame);
    }

    @isTest
    static void testIsContactAccAddrInfoSameDifferentMailingState() {
        Contact contact = UTIL_UnitTestData_TEST.getContact();
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        contact.MailingState = 'Something else';

        Test.startTest();
        Boolean isContactAccAddrInfoSame = ADDR_Addresses_UTIL.isContactAccAddrInfoSame(contact, accounts[0]);
        Test.stopTest();

        System.assertEquals(false, isContactAccAddrInfoSame);
    }

    @isTest
    static void testIsContactAccAddrInfoSameDifferentMailingPostalCode() {
        Contact contact = UTIL_UnitTestData_TEST.getContact();
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        contact.MailingPostalCode = 'Something else';

        Test.startTest();
        Boolean isContactAccAddrInfoSame = ADDR_Addresses_UTIL.isContactAccAddrInfoSame(contact, accounts[0]);
        Test.stopTest();

        System.assertEquals(false, isContactAccAddrInfoSame);
    }

    @isTest
    static void testIsContactAccAddrInfoSameDifferentMailingCountry() {
        Contact contact = UTIL_UnitTestData_TEST.getContact();
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        contact.MailingCountry = 'Something else';

        Test.startTest();
        Boolean isContactAccAddrInfoSame = ADDR_Addresses_UTIL.isContactAccAddrInfoSame(contact, accounts[0]);
        Test.stopTest();

        System.assertEquals(false, isContactAccAddrInfoSame);
    }

    @isTest
    static void testIsContactAccAddrInfoSameDifferentMailingAddressInactive() {
        Contact contact = UTIL_UnitTestData_TEST.getContact();
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        contact.Mailing_Address_Inactive__c = true;

        Test.startTest();
        Boolean isContactAccAddrInfoSame = ADDR_Addresses_UTIL.isContactAccAddrInfoSame(contact, accounts[0]);
        Test.stopTest();

        System.assertEquals(false, isContactAccAddrInfoSame);
    }

    @isTest
    static void testIsContactAccAddrInfoSameFalseDifferentStateCode() {
        /*Almost no way we can test state code/country code here
         This need to be refactored so that we can override the returned result*/
        //TODO(Refactor): Make isStateCountryPicklistsEnabled overridable
    }

    @isTest
    static void testIsContactAccAddrInfoSameNotNullContactNullAccount() {
        Contact contact = UTIL_UnitTestData_TEST.getContact();

        Test.startTest();
        Boolean isContactAccAddrInfoSame = ADDR_Addresses_UTIL.isContactAccAddrInfoSame(contact, null);
        Test.stopTest();

        System.assertEquals(false, isContactAccAddrInfoSame);
    }

    @isTest
    static void testIsContactAccAddrInfoSameNullContactNotNullAccount() {
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        );

        Test.startTest();
        Boolean isContactAccAddrInfoSame = ADDR_Addresses_UTIL.isContactAccAddrInfoSame(null, accounts[0]);
        Test.stopTest();

        System.assertEquals(false, isContactAccAddrInfoSame);
    }

    @isTest
    static void testIsContactAccAddrInfoSameNullContactNullAccount() {
        //TODO(Refactor): add guard clause for contact == null $$ account == null

        try {
            Test.startTest();
            Boolean isContactAccAddrInfoSame = ADDR_Addresses_UTIL.isContactAccAddrInfoSame(null, null);
            Test.stopTest();
            System.assert(false, 'A Null Pointer Exception should be thrown as we do not handle nulls in the method.');
        } catch (NullPointerException e) {
            System.assertEquals(
                'Attempt to de-reference a null object',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    /**************************************************************************************************************************
     ****************************************************** isAddressChanged **************************************************
     **************************************************************************************************************************/
    @isTest
    static void testIsAddressChangedTrueDifferentMailingStreet() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[1].MailingCity__c = 'City' + 0;
        addresses[1].MailingCounty__c = 'County' + 0;
        addresses[1].MailingPostalCode__c = 'Zip' + 0;

        Test.startTest();
        Boolean isAddressChanged = ADDR_Addresses_UTIL.isAddressChanged(addresses[1], addresses[0], false);
        Test.stopTest();

        System.assertEquals(true, isAddressChanged);
    }

    @isTest
    static void testIsAddressChangedTrueDifferentMailingStreet2() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[1].MailingStreet__c = 'Street' + 0;
        addresses[1].MailingStreet2__c = 'Street' + 1;
        addresses[1].MailingCity__c = 'City' + 0;
        addresses[1].MailingCounty__c = 'County' + 0;
        addresses[1].MailingPostalCode__c = 'Zip' + 0;

        Test.startTest();
        Boolean isAddressChanged = ADDR_Addresses_UTIL.isAddressChanged(addresses[1], addresses[0], false);
        Test.stopTest();

        System.assertEquals(true, isAddressChanged);
    }

    @isTest
    static void testIsAddressChangedTrueDifferentMailingCity() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[1].MailingStreet__c = 'Street' + 0;
        addresses[1].MailingCounty__c = 'County' + 0;
        addresses[1].MailingPostalCode__c = 'Zip' + 0;

        Test.startTest();
        Boolean isAddressChanged = ADDR_Addresses_UTIL.isAddressChanged(addresses[1], addresses[0], false);
        Test.stopTest();

        System.assertEquals(true, isAddressChanged);
    }

    static void testIsAddressChangedTrueDifferentMailingCounty() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[1].MailingStreet__c = 'Street' + 0;
        addresses[1].MailingCity__c = 'City' + 0;
        addresses[1].MailingPostalCode__c = 'Zip' + 0;

        Test.startTest();
        Boolean isAddressChanged = ADDR_Addresses_UTIL.isAddressChanged(addresses[1], addresses[0], false);
        Test.stopTest();

        System.assertEquals(true, isAddressChanged);
    }

    static void testIsAddressChangedTrueDifferentPostalCode() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[1].MailingStreet__c = 'Street' + 0;
        addresses[1].MailingCity__c = 'City' + 0;
        addresses[1].MailingCounty__c = 'County' + 0;

        Test.startTest();
        Boolean isAddressChanged = ADDR_Addresses_UTIL.isAddressChanged(addresses[1], addresses[0], false);
        Test.stopTest();

        System.assertEquals(true, isAddressChanged);
    }

    static void testIsAddressChangedTrueDifferentInactive() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[1].MailingStreet__c = 'Street' + 0;
        addresses[1].MailingCity__c = 'City' + 0;
        addresses[1].MailingCounty__c = 'County' + 0;
        addresses[1].MailingPostalCode__c = 'Zip' + 0;
        addresses[1].Inactive__c = true;

        Test.startTest();
        Boolean isAddressChanged = ADDR_Addresses_UTIL.isAddressChanged(addresses[1], addresses[0], false);
        Test.stopTest();

        System.assertEquals(true, isAddressChanged);
    }

    @isTest
    static void testIsAddressChangedTrueIncludingType() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[1].Address_Type__c = 'Work';
        addresses[1].MailingStreet__c = 'Street' + 0;
        addresses[1].MailingCity__c = 'City' + 0;
        addresses[1].MailingCounty__c = 'County' + 0;
        addresses[1].MailingPostalCode__c = 'Zip' + 0;

        Test.startTest();
        Boolean isAddressChanged = ADDR_Addresses_UTIL.isAddressChanged(addresses[1], addresses[0], true);
        Test.stopTest();

        System.assertEquals(true, isAddressChanged);
    }

    @isTest
    static void testIsAddressChangedFalse() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[1].MailingStreet__c = 'Street' + 0;
        addresses[1].MailingCity__c = 'City' + 0;
        addresses[1].MailingCounty__c = 'County' + 0;
        addresses[1].MailingPostalCode__c = 'Zip' + 0;

        Test.startTest();
        Boolean isAddressChanged = ADDR_Addresses_UTIL.isAddressChanged(addresses[1], addresses[0], true);
        Test.stopTest();

        System.assertEquals(false, isAddressChanged);
    }

    @isTest
    static void testIsAddressChangedFalseExcludingType() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[1].Address_Type__c = 'Work';
        addresses[1].MailingStreet__c = 'Street' + 0;
        addresses[1].MailingCity__c = 'City' + 0;
        addresses[1].MailingCounty__c = 'County' + 0;
        addresses[1].MailingPostalCode__c = 'Zip' + 0;

        Test.startTest();
        Boolean isAddressChanged = ADDR_Addresses_UTIL.isAddressChanged(addresses[1], addresses[0], false);
        Test.stopTest();

        System.assertEquals(false, isAddressChanged);
    }

    @isTest
    static void testIsAddressChangedNewAddressNull() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);

        Test.startTest();
        Boolean isAddressChanged = ADDR_Addresses_UTIL.isAddressChanged(null, addresses[0], null);
        Test.stopTest();

        System.assertEquals(false, isAddressChanged);
    }

    /**************************************************************************************************************************
     ****************************************************** isAddressInfoSame *******************************************
     **************************************************************************************************************************/

    @isTest
    static void testIsAddressInfoSamedTrueDifferentMailingStreet() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[1].MailingCity__c = 'City' + 0;
        addresses[1].MailingCounty__c = 'County' + 0;
        addresses[1].MailingPostalCode__c = 'Zip' + 0;

        Test.startTest();
        Boolean isAddressInfoSamed = ADDR_Addresses_UTIL.isAddressInfoSame(addresses[1], addresses[0], false);
        Test.stopTest();

        System.assertEquals(true, isAddressInfoSamed);
    }

    @isTest
    static void testIsAddressInfoSamedTrueDifferentMailingStreet2() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[1].MailingStreet__c = 'Street' + 0;
        addresses[1].MailingStreet2__c = 'Street' + 1;
        addresses[1].MailingCity__c = 'City' + 0;
        addresses[1].MailingCounty__c = 'County' + 0;
        addresses[1].MailingPostalCode__c = 'Zip' + 0;

        Test.startTest();
        Boolean isAddressInfoSamed = ADDR_Addresses_UTIL.isAddressInfoSame(addresses[1], addresses[0], false);
        Test.stopTest();

        System.assertEquals(true, isAddressInfoSamed);
    }

    @isTest
    static void testIsAddressInfoSamedTrueDifferentMailingCity() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[1].MailingStreet__c = 'Street' + 0;
        addresses[1].MailingCounty__c = 'County' + 0;
        addresses[1].MailingPostalCode__c = 'Zip' + 0;

        Test.startTest();
        Boolean isAddressInfoSamed = ADDR_Addresses_UTIL.isAddressInfoSame(addresses[1], addresses[0], false);
        Test.stopTest();

        System.assertEquals(true, isAddressInfoSamed);
    }

    static void testIsAddressInfoSamedTrueDifferentMailingCounty() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[1].MailingStreet__c = 'Street' + 0;
        addresses[1].MailingCity__c = 'City' + 0;
        addresses[1].MailingPostalCode__c = 'Zip' + 0;

        Test.startTest();
        Boolean isAddressInfoSamed = ADDR_Addresses_UTIL.isAddressInfoSame(addresses[1], addresses[0], false);
        Test.stopTest();

        System.assertEquals(true, isAddressInfoSamed);
    }

    static void testIsAddressInfoSamedTrueDifferentPostalCode() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[1].MailingStreet__c = 'Street' + 0;
        addresses[1].MailingCity__c = 'City' + 0;
        addresses[1].MailingCounty__c = 'County' + 0;

        Test.startTest();
        Boolean isAddressInfoSamed = ADDR_Addresses_UTIL.isAddressInfoSame(addresses[1], addresses[0], false);
        Test.stopTest();

        System.assertEquals(true, isAddressInfoSamed);
    }

    @isTest
    static void testIsAddressInfoSamedTrueIncludingType() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[1].Address_Type__c = 'Work';
        addresses[1].MailingStreet__c = 'Street' + 0;
        addresses[1].MailingCity__c = 'City' + 0;
        addresses[1].MailingCounty__c = 'County' + 0;
        addresses[1].MailingPostalCode__c = 'Zip' + 0;

        Test.startTest();
        Boolean isAddressInfoSame = ADDR_Addresses_UTIL.isAddressInfoSame(addresses[1], addresses[0], true);
        Test.stopTest();

        System.assertEquals(true, isAddressInfoSame);
    }

    @isTest
    static void testIsAddressInfoSameFalse() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[1].MailingStreet__c = 'Street' + 0;
        addresses[1].MailingCity__c = 'City' + 0;
        addresses[1].MailingCounty__c = 'County' + 0;
        addresses[1].MailingPostalCode__c = 'Zip' + 0;

        Test.startTest();
        Boolean isAddressInfoSame = ADDR_Addresses_UTIL.isAddressInfoSame(addresses[1], addresses[0], true);
        Test.stopTest();

        System.assertEquals(false, isAddressInfoSame);
    }

    @isTest
    static void testIsAddressInfoSameFalseExcludingType() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[1].Address_Type__c = 'Work';
        addresses[1].MailingStreet__c = 'Street' + 0;
        addresses[1].MailingCity__c = 'City' + 0;
        addresses[1].MailingCounty__c = 'County' + 0;
        addresses[1].MailingPostalCode__c = 'Zip' + 0;

        Test.startTest();
        Boolean isAddressInfoSame = ADDR_Addresses_UTIL.isAddressInfoSame(addresses[1], addresses[0], false);
        Test.stopTest();

        System.assertEquals(false, isAddressInfoSame);
    }

    @isTest
    static void testIsAddressInfoSameNewAddressNull() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);

        Test.startTest();
        Boolean isAddressInfoSame = ADDR_Addresses_UTIL.isAddressInfoSame(null, addresses[0], null);
        Test.stopTest();

        System.assertEquals(false, isAddressInfoSame);
    }

    /**************************************************************************************************************************
     ****************************************************** isContactAddressChanged *******************************************
     **************************************************************************************************************************/
    @isTest
    static void testIsContactAddressChangedBothNull() {
        Test.startTest();
        Boolean isContactAddressChanged = ADDR_Addresses_UTIL.isContactAddressChanged(null, null);
        Test.stopTest();

        System.assertEquals(false, isContactAddressChanged);
    }

    @isTest
    static void testIsContactAddressChangedCon1Null() {
        Contact con2 = UTIL_UnitTestData_TEST.getContact();
        con2.MailingStreet = 'Some Street';

        Test.startTest();
        Boolean isContactAddressChanged = ADDR_Addresses_UTIL.isContactAddressChanged(null, con2);
        Test.stopTest();

        System.assertEquals(true, isContactAddressChanged);
    }

    @isTest
    static void testIsContactAddressChangedCon1NullCon2EmptyTypeEmpty() {
        Contact con2 = UTIL_UnitTestData_TEST.getContact();

        Test.startTest();
        Boolean isContactAddressChanged = ADDR_Addresses_UTIL.isContactAddressChanged(null, con2);
        Test.stopTest();

        System.assertEquals(false, isContactAddressChanged);
    }

    @isTest
    static void testIsContactAddressChangedCon2NullCon1NotEmptyTypeNotEmpty() {
        Contact con1 = UTIL_UnitTestData_TEST.getContact();
        con1.Primary_Address_Type__c = 'Some Type';

        Test.startTest();
        Boolean isContactAddressChanged = ADDR_Addresses_UTIL.isContactAddressChanged(con1, null);
        Test.stopTest();

        System.assertEquals(true, isContactAddressChanged);
    }

    @isTest
    static void testIsContactAddressChangedBothNotNullSameAddressInfo() {
        Contact con1 = UTIL_UnitTestData_TEST.getContact();
        Contact con2 = UTIL_UnitTestData_TEST.getContact();

        Test.startTest();
        Boolean isContactAddressChanged = ADDR_Addresses_UTIL.isContactAddressChanged(con1, con2);
        Test.stopTest();

        System.assertEquals(false, isContactAddressChanged);
    }

    @isTest
    static void testIsContactAddressChangedBothNotNullDifferentMailingStreet() {
        Contact con1 = UTIL_UnitTestData_TEST.getContact();
        Contact con2 = UTIL_UnitTestData_TEST.getContact();
        con1.MailingStreet = 'Some Street';

        Test.startTest();
        Boolean isContactAddressChanged = ADDR_Addresses_UTIL.isContactAddressChanged(con1, con2);
        Test.stopTest();

        System.assertEquals(true, isContactAddressChanged);
    }

    @isTest
    static void testIsContactAddressChangedBothNotNullDifferentMailingCity() {
        Contact con1 = UTIL_UnitTestData_TEST.getContact();
        Contact con2 = UTIL_UnitTestData_TEST.getContact();
        con1.MailingStreet = 'Some City';

        Test.startTest();
        Boolean isContactAddressChanged = ADDR_Addresses_UTIL.isContactAddressChanged(con1, con2);
        Test.stopTest();

        System.assertEquals(true, isContactAddressChanged);
    }

    @isTest
    static void testIsContactAddressChangedBothNotNullDifferentMailingCounty() {
        Contact con1 = UTIL_UnitTestData_TEST.getContact();
        Contact con2 = UTIL_UnitTestData_TEST.getContact();
        con1.MailingStreet = 'Some County';

        Test.startTest();
        Boolean isContactAddressChanged = ADDR_Addresses_UTIL.isContactAddressChanged(con1, con2);
        Test.stopTest();

        System.assertEquals(true, isContactAddressChanged);
    }

    /**************************************************************************************************************************
     ****************************************************** isAccountAddressChanged *******************************************
     **************************************************************************************************************************/
    @isTest
    static void testIsAccountAddressChangedAcc2NullFalse() {
        Account acc1 = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];

        Test.startTest();
        Boolean isAccountAddressChanged = ADDR_Addresses_UTIL.isAccountAddressChanged(acc1, null);
        Test.stopTest();

        System.assertEquals(false, isAccountAddressChanged);
    }

    @isTest
    static void testIsAccountAddressChangedAcc1NullFalse() {
        Account acc2 = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];

        Test.startTest();
        Boolean isAccountAddressChanged = ADDR_Addresses_UTIL.isAccountAddressChanged(null, acc2);
        Test.stopTest();

        System.assertEquals(false, isAccountAddressChanged);
    }

    @isTest
    static void testIsAccountAddressChangedNotNullSameAddressInfoFalse() {
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            2,
            UTIL_Describe_API.getBizAccRecTypeID()
        );

        Test.startTest();
        Boolean isAccountAddressChanged = ADDR_Addresses_UTIL.isAccountAddressChanged(accounts[0], accounts[1]);
        Test.stopTest();

        System.assertEquals(false, isAccountAddressChanged);
    }

    @isTest
    static void testIsAccountAddressChangedNotNullDifferentAddressInfoCaseTrue() {
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            2,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        accounts[0].BillingStreet = 'some random billing street';
        accounts[1].BillingStreet = accounts[0].BillingStreet.toUppercase();

        Test.startTest();
        Boolean isAccountAddressChanged = ADDR_Addresses_UTIL.isAccountAddressChanged(accounts[0], accounts[1]);
        Test.stopTest();

        System.assertEquals(true, isAccountAddressChanged);
    }

    @isTest
    static void testIsAccountAddressChangedNotNullDifferentAddressInfoTrue() {
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            2,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        accounts[0].BillingStreet = 'some other billing street';

        Test.startTest();
        Boolean isAccountAddressChanged = ADDR_Addresses_UTIL.isAccountAddressChanged(accounts[0], accounts[1]);
        Test.stopTest();

        System.assertEquals(true, isAccountAddressChanged);
    }

    /**************************************************************************************************************************
     ****************************************************** isContactAddressEmpty *********************************************
     **************************************************************************************************************************/
    @isTest
    static void testIsContactAddressEmptyNullTrue() {
        Test.startTest();
        Boolean isContactAddressEmpty = ADDR_Addresses_UTIL.isContactAddressEmpty(null);
        Test.stopTest();

        System.assertEquals(true, isContactAddressEmpty);
    }

    @isTest
    static void testIsContactAddressEmptyNotNullEmptyTrue() {
        Contact contact = UTIL_UnitTestData_TEST.getContact();

        Test.startTest();
        Boolean isContactAddressEmpty = ADDR_Addresses_UTIL.isContactAddressEmpty(contact);
        Test.stopTest();

        System.assertEquals(true, isContactAddressEmpty);
    }

    @isTest
    static void testIsContactAddressEmptyNotNullNotEmptyFalse() {
        Contact contact = UTIL_UnitTestData_TEST.getContact();
        contact.MailingStreet = 'Some random mailing street';

        Test.startTest();
        Boolean isContactAddressEmpty = ADDR_Addresses_UTIL.isContactAddressEmpty(contact);
        Test.stopTest();

        System.assertEquals(false, isContactAddressEmpty);
    }

    /**************************************************************************************************************************
     ****************************************************** isAccAddressEmpty *************************************************
     **************************************************************************************************************************/
    @isTest
    static void testIsAccAddressEmptyNullTrue() {
        Test.startTest();
        Boolean isAccAddressEmpty = ADDR_Addresses_UTIL.isAccAddressEmpty(null);
        Test.stopTest();

        System.assertEquals(true, isAccAddressEmpty);
    }

    @isTest
    static void testIsAccAddressEmptyNotNullEmptyTrue() {
        Account account = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];

        Test.startTest();
        Boolean isAccAddressEmpty = ADDR_Addresses_UTIL.isAccAddressEmpty(account);
        Test.stopTest();

        System.assertEquals(true, isAccAddressEmpty);
    }

    @isTest
    static void testIsAccAddressEmptyNotNullNotEmptyFalse() {
        Account account = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        account.BillingStreet = 'Some random billing street';

        Test.startTest();
        Boolean isAccAddressEmpty = ADDR_Addresses_UTIL.isAccAddressEmpty(account);
        Test.stopTest();

        System.assertEquals(false, isAccAddressEmpty);
    }

    /**************************************************************************************************************************
     ****************************************************** equalsCaseSensitive ***********************************************
     **************************************************************************************************************************/
    @isTest
    static void testEqualsCaseSensitiveBothNullTrue() {
        Test.startTest();
        Boolean stringEquals = ADDR_Addresses_UTIL.equalsCaseSensitive(null, null);
        Test.stopTest();

        System.assertEquals(true, stringEquals);
    }

    @isTest
    static void testEqualsCaseSensitiveOnlyStr1NullFalse() {
        Test.startTest();
        Boolean stringEquals = ADDR_Addresses_UTIL.equalsCaseSensitive(null, 'test string');
        Test.stopTest();

        System.assertEquals(false, stringEquals);
    }

    @isTest
    static void testEqualsCaseSensitiveOnlyStr2NullFalse() {
        Test.startTest();
        Boolean stringEquals = ADDR_Addresses_UTIL.equalsCaseSensitive('test string', null);
        Test.stopTest();

        System.assertEquals(false, stringEquals);
    }

    @isTest
    static void testEqualsCaseSensitiveNotNullEqualsTrue() {
        Test.startTest();
        Boolean stringEquals = ADDR_Addresses_UTIL.equalsCaseSensitive('test string', 'test string');
        Test.stopTest();

        System.assertEquals(true, stringEquals);
    }

    @isTest
    static void testEqualsCaseSensitiveNotNullEqualsFalse() {
        Test.startTest();
        Boolean stringEquals = ADDR_Addresses_UTIL.equalsCaseSensitive('test string', '!test string');
        Test.stopTest();

        System.assertEquals(false, stringEquals);
    }

    /**************************************************************************************************************************
     ****************************************************** isAddressMatchFuzzy ***********************************************
     **************************************************************************************************************************/
    @isTest
    static void testIsAddressMatchFuzzyAddrNewNullFalse() {
        Address__c oldAddress = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];

        Test.startTest();
        Boolean isAddressMatchFuzzy = ADDR_Addresses_UTIL.isAddressMatchFuzzy(null, oldAddress, true);
        Test.stopTest();

        System.assertEquals(false, isAddressMatchFuzzy);
    }

    @isTest
    static void testIsAddressMatchFuzzyAddrOldNullFalse() {
        Address__c newAddress = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];

        Test.startTest();
        Boolean isAddressMatchFuzzy = ADDR_Addresses_UTIL.isAddressMatchFuzzy(newAddress, null, true);
        Test.stopTest();

        System.assertEquals(false, isAddressMatchFuzzy);
    }

    @isTest
    static void testIsAddressMatchFuzzyIncludeAddressTypeNullFalse() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);

        //To Refactor: add guard clause.
        try {
            Test.startTest();
            Boolean isAddressMatchFuzzy = ADDR_Addresses_UTIL.isAddressMatchFuzzy(addresses[0], addresses[1], null);
            Test.stopTest();
            System.assert(false, 'A Null Pointer Exception should be thrown as we do not handle nulls in the method.');
        } catch (NullPointerException e) {
            System.assertEquals(
                'Attempt to de-reference a null object',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    @isTest
    static void testIsAddressMatchCompletelySame() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[0].MailingStreet__c = 'some random street';
        addresses[0].MailingStreet2__c = 'some random street 2';
        addresses[0].MailingCity__c = 'some random city';
        addresses[0].MailingCounty__c = 'some random county';
        addresses[0].MailingState__c = 'some random state';
        addresses[0].MailingPostalCode__c = 'some random postal code';
        addresses[0].MailingCountry__c = 'some random country';
        addresses[0].Address_Type__c = 'some random type';

        addresses[1].MailingStreet__c = 'SOME RANDOM STREET';
        addresses[1].MailingStreet2__c = 'SOME RANDOM STREET 2';
        addresses[1].MailingCity__c = 'SOME RANDOM CITY';
        addresses[1].MailingCounty__c = 'SOME RANDOM COUNTY';
        addresses[1].MailingState__c = 'SOME RANDOM STATE';
        addresses[1].MailingPostalCode__c = 'SOME RANDOM POSTAL CODE';
        addresses[1].MailingCountry__c = 'SOME RANDOM COUNTRY';
        addresses[1].Address_Type__c = 'SOME RANDOM TYPE';

        Test.startTest();
        Boolean isAddressMatchFuzzy = ADDR_Addresses_UTIL.isAddressMatchFuzzy(addresses[0], addresses[1], true);
        Test.stopTest();

        system.assertEquals(true, isAddressMatchFuzzy);
    }

    @isTest
    static void testIsAddressMatchFuzzyOneFieldDifferent() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[0].MailingStreet__c = 'some random street';
        addresses[0].MailingStreet2__c = 'some random street 2';
        addresses[0].MailingCity__c = 'some random city';
        addresses[0].MailingCounty__c = 'some random county';
        addresses[0].MailingState__c = 'some random state';
        addresses[0].MailingPostalCode__c = 'some random postal code';
        addresses[0].MailingCountry__c = 'some random country';
        addresses[0].Address_Type__c = 'some random type';

        addresses[1].MailingStreet__c = 'SOME OTHER STREET';
        addresses[1].MailingStreet2__c = 'SOME RANDOM STREET 2';
        addresses[1].MailingCity__c = 'SOME RANDOM CITY';
        addresses[1].MailingCounty__c = 'SOME RANDOM COUNTY';
        addresses[1].MailingState__c = 'SOME RANDOM STATE';
        addresses[1].MailingPostalCode__c = 'SOME RANDOM POSTAL CODE';
        addresses[1].MailingCountry__c = 'SOME RANDOM COUNTRY';
        addresses[1].Address_Type__c = 'SOME RANDOM TYPE';

        Test.startTest();
        Boolean isAddressMatchFuzzy = ADDR_Addresses_UTIL.isAddressMatchFuzzy(addresses[0], addresses[1], true);
        Test.stopTest();

        system.assertEquals(true, isAddressMatchFuzzy);
    }

    @isTest
    static void testIsAddressMatchFuzzyOneFieldAndTypeDifferentIncludingType() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[0].MailingStreet__c = 'some random street';
        addresses[0].MailingStreet2__c = 'some random street 2';
        addresses[0].MailingCity__c = 'some random city';
        addresses[0].MailingCounty__c = 'some random county';
        addresses[0].MailingState__c = 'some random state';
        addresses[0].MailingPostalCode__c = 'some random postal code';
        addresses[0].MailingCountry__c = 'some random country';
        addresses[0].Address_Type__c = 'some random type';

        addresses[1].MailingStreet__c = 'SOME OTHER STREET';
        addresses[1].MailingStreet2__c = 'SOME RANDOM STREET 2';
        addresses[1].MailingCity__c = 'SOME RANDOM CITY';
        addresses[1].MailingCounty__c = 'SOME RANDOM COUNTY';
        addresses[1].MailingState__c = 'SOME RANDOM STATE';
        addresses[1].MailingPostalCode__c = 'SOME RANDOM POSTAL CODE';
        addresses[1].MailingCountry__c = 'SOME RANDOM COUNTRY';
        addresses[1].Address_Type__c = 'SOME OTHER TYPE';

        Test.startTest();
        Boolean isAddressMatchFuzzy = ADDR_Addresses_UTIL.isAddressMatchFuzzy(addresses[0], addresses[1], true);
        Test.stopTest();

        system.assertEquals(false, isAddressMatchFuzzy);
    }

    @isTest
    static void testIsAddressMatchFuzzyOneFieldAndTypeDifferentExcludingType() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[0].MailingStreet__c = 'some random street';
        addresses[0].MailingStreet2__c = 'some random street 2';
        addresses[0].MailingCity__c = 'some random city';
        addresses[0].MailingCounty__c = 'some random county';
        addresses[0].MailingState__c = 'some random state';
        addresses[0].MailingPostalCode__c = 'some random postal code';
        addresses[0].MailingCountry__c = 'some random country';
        addresses[0].Address_Type__c = 'some random type';

        addresses[1].MailingStreet__c = 'SOME OTHER STREET';
        addresses[1].MailingStreet2__c = 'SOME RANDOM STREET 2';
        addresses[1].MailingCity__c = 'SOME RANDOM CITY';
        addresses[1].MailingCounty__c = 'SOME RANDOM COUNTY';
        addresses[1].MailingState__c = 'SOME RANDOM STATE';
        addresses[1].MailingPostalCode__c = 'SOME RANDOM POSTAL CODE';
        addresses[1].MailingCountry__c = 'SOME RANDOM COUNTRY';
        addresses[1].Address_Type__c = 'SOME OTHER TYPE';

        Test.startTest();
        Boolean isAddressMatchFuzzy = ADDR_Addresses_UTIL.isAddressMatchFuzzy(addresses[0], addresses[1], false);
        Test.stopTest();

        system.assertEquals(true, isAddressMatchFuzzy);
    }

    @isTest
    static void testIsAddressMatchFuzzyMoreThanOneFieldDifferentExcludingType() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[0].MailingStreet__c = 'some random street';
        addresses[0].MailingStreet2__c = 'some random street 2';
        addresses[0].MailingCity__c = 'some random city';
        addresses[0].MailingCounty__c = 'some random county';
        addresses[0].MailingState__c = 'some random state';
        addresses[0].MailingPostalCode__c = 'some random postal code';
        addresses[0].MailingCountry__c = 'some random country';
        addresses[0].Address_Type__c = 'some random type';

        addresses[1].MailingStreet__c = 'SOME OTHER STREET';
        addresses[1].MailingStreet2__c = 'SOME OTHER STREET 2';
        addresses[1].MailingCity__c = 'SOME RANDOM CITY';
        addresses[1].MailingCounty__c = 'SOME RANDOM COUNTY';
        addresses[1].MailingState__c = 'SOME RANDOM STATE';
        addresses[1].MailingPostalCode__c = 'SOME RANDOM POSTAL CODE';
        addresses[1].MailingCountry__c = 'SOME RANDOM COUNTRY';
        addresses[1].Address_Type__c = 'SOME OTHER TYPE';

        Test.startTest();
        Boolean isAddressMatchFuzzy = ADDR_Addresses_UTIL.isAddressMatchFuzzy(addresses[0], addresses[1], false);
        Test.stopTest();

        system.assertEquals(false, isAddressMatchFuzzy);
    }

    @isTest
    static void testIsAddressMatchFuzzyMoreThanOneFieldDifferentExcludingTypeOldFieldEmpty() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        addresses[0].MailingStreet__c = 'some random street';
        addresses[0].MailingStreet2__c = 'some random street 2';
        addresses[0].MailingCity__c = 'some random city';
        addresses[0].MailingCounty__c = 'some random county';
        addresses[0].MailingState__c = 'some random state';
        addresses[0].MailingPostalCode__c = 'some random postal code';
        addresses[0].MailingCountry__c = 'some random country';
        addresses[0].Address_Type__c = 'some random type';

        addresses[1].MailingStreet__c = '';
        addresses[1].MailingStreet2__c = '';
        addresses[1].MailingCity__c = 'SOME RANDOM CITY';
        addresses[1].MailingCounty__c = 'SOME RANDOM COUNTY';
        addresses[1].MailingState__c = 'SOME RANDOM STATE';
        addresses[1].MailingPostalCode__c = 'SOME RANDOM POSTAL CODE';
        addresses[1].MailingCountry__c = 'SOME RANDOM COUNTRY';
        addresses[1].Address_Type__c = 'SOME OTHER TYPE';

        Test.startTest();
        Boolean isAddressMatchFuzzy = ADDR_Addresses_UTIL.isAddressMatchFuzzy(addresses[0], addresses[1], false);
        Test.stopTest();

        system.assertEquals(true, isAddressMatchFuzzy);
    }

    /**************************************************************************************************************************
     ****************************************************** strCleanup ********************************************************
     **************************************************************************************************************************/
    @isTest
    static void testStrCleanupNull() {
        Test.startTest();
        String cleanedString = ADDR_Addresses_UTIL.strCleanup(null);
        Test.stopTest();

        System.assertEquals('', cleanedString);
    }

    @isTest
    static void testStrCleanupEmpty() {
        Test.startTest();
        String cleanedString = ADDR_Addresses_UTIL.strCleanup('');
        Test.stopTest();

        System.assertEquals('', cleanedString);
    }

    @isTest
    static void testStrCleanupStringWithSpaces() {
        Test.startTest();
        String cleanedString = ADDR_Addresses_UTIL.strCleanup(' a ');
        Test.stopTest();

        System.assertEquals('a', cleanedString);
    }

    @isTest
    static void testStrCleanupStringUpperCase() {
        Test.startTest();
        String cleanedString = ADDR_Addresses_UTIL.strCleanup('A');
        Test.stopTest();

        System.assertEquals('a', cleanedString);
    }

    /**************************************************************************************************************************
     ****************************************************** copyAddressObj ****************************************************
     **************************************************************************************************************************/
    @isTest
    static void testCopyAddressObjBothNull() {
        //To Refactor: we don't have guard clause for this.
        try {
            Test.startTest();
            ADDR_Addresses_UTIL.copyAddressObj(null, null);
            Test.stopTest();
            System.assert(false, 'A Null Pointer Exception should be thrown as we do not handle nulls in the method.');
        } catch (NullPointerException e) {
            System.assertEquals(
                'Attempt to de-reference a null object',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    @isTest
    static void testCopyAddressObjSourceNull() {
        //To Refactor: we don't have guard clause for this.
        Address__c addressSource = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];

        try {
            Test.startTest();
            ADDR_Addresses_UTIL.copyAddressObj(addressSource, null);
            Test.stopTest();
            System.assert(false, 'A Null Pointer Exception should be thrown as we do not handle nulls in the method.');
        } catch (NullPointerException e) {
            System.assertEquals(
                'Attempt to de-reference a null object',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    @isTest
    static void testCopyAddressObjDestinationNull() {
        //To Refactor: we don't have guard clause for this.
        Address__c addressDestination = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];

        try {
            Test.startTest();
            ADDR_Addresses_UTIL.copyAddressObj(null, addressDestination);
            Test.stopTest();
            System.assert(false, 'A Null Pointer Exception should be thrown as we do not handle nulls in the method.');
        } catch (NullPointerException e) {
            System.assertEquals(
                'Attempt to de-reference a null object',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    @isTest
    static void testCopyAddressObjNotNullSourceTypeNotBlank() {
        Address__c addressSource = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];
        Address__c addressDestination = new Address__c();
        addressDestination.Address_Type__c = 'Work';

        Test.startTest();
        ADDR_Addresses_UTIL.copyAddressObj(addressSource, addressDestination);
        Test.stopTest();

        System.assertEquals(addressSource.Default_Address__c, addressDestination.Default_Address__c);
        System.assertEquals(addressSource.MailingStreet__c, addressDestination.MailingStreet__c);
        System.assertEquals(addressSource.MailingStreet2__c, addressDestination.MailingStreet2__c);
        System.assertEquals(addressSource.MailingCity__c, addressDestination.MailingCity__c);
        System.assertEquals(addressSource.MailingCounty__c, addressDestination.MailingCounty__c);
        System.assertEquals(addressSource.MailingState__c, addressDestination.MailingState__c);
        System.assertEquals(addressSource.MailingPostalCode__c, addressDestination.MailingPostalCode__c);
        System.assertEquals(addressSource.MailingCountry__c, addressDestination.MailingCountry__c);
        System.assertEquals(addressSource.Geolocation__Latitude__s, addressDestination.Geolocation__Latitude__s);
        System.assertEquals(addressSource.Geolocation__Longitude__s, addressDestination.Geolocation__Longitude__s);
        System.assertEquals('Home', addressDestination.Address_Type__c);
    }

    @isTest
    static void testCopyAddressObjNotNullSourceTypeBlank() {
        Address__c addressSource = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];
        Address__c addressDestination = new Address__c();
        addressSource.Address_Type__c = '';
        addressDestination.Address_Type__c = 'Work';

        Test.startTest();
        ADDR_Addresses_UTIL.copyAddressObj(addressSource, addressDestination);
        Test.stopTest();

        System.assertEquals(addressSource.Default_Address__c, addressDestination.Default_Address__c);
        System.assertEquals(addressSource.MailingStreet__c, addressDestination.MailingStreet__c);
        System.assertEquals(addressSource.MailingStreet2__c, addressDestination.MailingStreet2__c);
        System.assertEquals(addressSource.MailingCity__c, addressDestination.MailingCity__c);
        System.assertEquals(addressSource.MailingCounty__c, addressDestination.MailingCounty__c);
        System.assertEquals(addressSource.MailingState__c, addressDestination.MailingState__c);
        System.assertEquals(addressSource.MailingPostalCode__c, addressDestination.MailingPostalCode__c);
        System.assertEquals(addressSource.MailingCountry__c, addressDestination.MailingCountry__c);
        System.assertEquals(addressSource.Geolocation__Latitude__s, addressDestination.Geolocation__Latitude__s);
        System.assertEquals(addressSource.Geolocation__Longitude__s, addressDestination.Geolocation__Longitude__s);
        System.assertEquals('Work', addressDestination.Address_Type__c);
    }

    @isTest
    static void testCopyAddressObjNotNullSourceTypeNotBlankInactive() {
        Address__c addressSource = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];
        addressSource.Inactive__c = true;
        Address__c addressDestination = new Address__c();
        addressDestination.Address_Type__c = 'Work';
        addressDestination.Inactive__c = false;

        Test.startTest();
        ADDR_Addresses_UTIL.copyAddressObj(addressSource, addressDestination);
        Test.stopTest();

        System.assertEquals(addressSource.Default_Address__c, addressDestination.Default_Address__c);
        System.assertEquals(addressSource.MailingStreet__c, addressDestination.MailingStreet__c);
        System.assertEquals(addressSource.MailingStreet2__c, addressDestination.MailingStreet2__c);
        System.assertEquals(addressSource.MailingCity__c, addressDestination.MailingCity__c);
        System.assertEquals(addressSource.MailingCounty__c, addressDestination.MailingCounty__c);
        System.assertEquals(addressSource.MailingState__c, addressDestination.MailingState__c);
        System.assertEquals(addressSource.MailingPostalCode__c, addressDestination.MailingPostalCode__c);
        System.assertEquals(addressSource.MailingCountry__c, addressDestination.MailingCountry__c);
        System.assertEquals(addressSource.Geolocation__Latitude__s, addressDestination.Geolocation__Latitude__s);
        System.assertEquals(addressSource.Geolocation__Longitude__s, addressDestination.Geolocation__Longitude__s);
        System.assertEquals('Home', addressDestination.Address_Type__c);
        System.assertEquals(true, addressDestination.Inactive__c);
    }

    /**************************************************************************************************************************
     ****************************************************** copyAddressStdSObj ************************************************
     **************************************************************************************************************************/
    @isTest
    static void testCopyAddressObjSobjSourceRecordNull() {
        //To Refactor: we don't have guard clause for this.
        //To Refactor: terrible method name.
        //To Refactor: Have to define the Address prefix is a loophole
        Account account = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];

        try {
            Test.startTest();
            ADDR_Addresses_UTIL.copyAddressStdSObj(null, 'Mailing', account, 'Billing');
            Test.stopTest();
            System.assert(false, 'A Null Pointer Exception should be thrown as we do not handle nulls in the method.');
        } catch (NullPointerException e) {
            System.assertEquals(
                'Attempt to de-reference a null object',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    @isTest
    static void testCopyAddressObjSobjSourceFieldPrefixNull() {
        //To Refactor: we don't have guard clause for this.
        Contact contact = UTIL_UnitTestData_TEST.getContact();
        Account account = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];

        try {
            Test.startTest();
            ADDR_Addresses_UTIL.copyAddressStdSObj(contact, null, account, 'Billing');
            Test.stopTest();
            System.assert(false, 'An SObject Exception should be thrown as we do not handle it in the method.');
        } catch (SObjectException e) {
            System.assertEquals(
                'Invalid field nullStreet for Contact',
                e.getMessage(),
                'Should throw Invalid field exception.'
            );
        }
    }

    @isTest
    static void testCopyAddressObjSobjDestinationRecordNull() {
        //To Refactor: we don't have guard clause for this.
        Contact contact = UTIL_UnitTestData_TEST.getContact();

        try {
            Test.startTest();
            ADDR_Addresses_UTIL.copyAddressStdSObj(contact, 'Mailing', null, 'Billing');
            Test.stopTest();
            System.assert(false, 'A Null Pointer Exception should be thrown as we do not handle nulls in the method.');
        } catch (NullPointerException e) {
            System.assertEquals(
                'Attempt to de-reference a null object',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    @isTest
    static void testCopyAddressObjSobjDestinationFieldPrefixNull() {
        //To Refactor: we don't have guard clause for this.
        Contact contact = UTIL_UnitTestData_TEST.getContact();
        Account account = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];

        try {
            Test.startTest();
            ADDR_Addresses_UTIL.copyAddressStdSObj(contact, 'Mailing', account, null);
            Test.stopTest();
            System.assert(false, 'An SObject Exception should be thrown as we do not handle it in the method.');
        } catch (SObjectException e) {
            System.assertEquals(
                'Invalid field nullStreet for Account',
                e.getMessage(),
                'Should throw Invalid field exception.'
            );
        }
    }

    @isTest
    static void testCopyAddressObjSobjValidField() {
        //To Refactor: No way we can test isStateCountryPicklistsEnabled.
        Contact contact = UTIL_UnitTestData_TEST.getContact();
        Account account = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];

        Test.startTest();
        ADDR_Addresses_UTIL.copyAddressStdSObj(account, 'Billing', contact, 'Mailing');
        Test.stopTest();

        System.assertEquals(account.BillingStreet, contact.MailingStreet);
        System.assertEquals(account.BillingCity, contact.MailingCity);
        System.assertEquals(account.Billing_County__c, contact.Mailing_County__c);
        System.assertEquals(account.BillingPostalCode, contact.MailingPostalCode);
        System.assertEquals(account.BillingState, contact.MailingState);
        System.assertEquals(account.BillingCountry, contact.MailingCountry);
        System.assertEquals(account.BillingLatitude, contact.MailingLatitude);
        System.assertEquals(account.BillingLongitude, contact.MailingLongitude);
    }

    @isTest
    static void testCopyAddressObjSobjValidFieldInactiveAddressFields() {
        //To Refactor: No way we can test isStateCountryPicklistsEnabled.
        Contact contact = UTIL_UnitTestData_TEST.getContact();
        contact.Mailing_Address_Inactive__c = false;
        Account account = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        account.Billing_Address_Inactive__c = true;

        Test.startTest();
        ADDR_Addresses_UTIL.copyAddressStdSObj(account, 'Billing', contact, 'Mailing');
        Test.stopTest();

        System.assertEquals(account.BillingStreet, contact.MailingStreet);
        System.assertEquals(account.BillingCity, contact.MailingCity);
        System.assertEquals(account.Billing_County__c, contact.Mailing_County__c);
        System.assertEquals(account.BillingPostalCode, contact.MailingPostalCode);
        System.assertEquals(account.BillingState, contact.MailingState);
        System.assertEquals(account.BillingCountry, contact.MailingCountry);
        System.assertEquals(account.BillingLatitude, contact.MailingLatitude);
        System.assertEquals(account.BillingLongitude, contact.MailingLongitude);
        System.assertEquals(true, contact.Mailing_Address_Inactive__c);
    }

    @isTest
    static void testCopyAddressObjSobjValidFieldInvalidInactiveAddressFields() {
        //To Refactor: No way we can test isStateCountryPicklistsEnabled.
        Contact contact = UTIL_UnitTestData_TEST.getContact();
        contact.Mailing_Address_Inactive__c = false;
        Account account = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        account.Billing_Address_Inactive__c = true;

        Test.startTest();
        ADDR_Addresses_UTIL.copyAddressStdSObj(account, 'Billing', contact, 'Other');
        Test.stopTest();

        System.assertEquals(account.BillingStreet, contact.MailingStreet);
        System.assertEquals(account.BillingCity, contact.MailingCity);
        System.assertEquals(account.Billing_County__c, contact.Mailing_County__c);
        System.assertEquals(account.BillingPostalCode, contact.MailingPostalCode);
        System.assertEquals(account.BillingState, contact.MailingState);
        System.assertEquals(account.BillingCountry, contact.MailingCountry);
        System.assertEquals(account.BillingLatitude, contact.MailingLatitude);
        System.assertEquals(account.BillingLongitude, contact.MailingLongitude);
        System.assertEquals(false, contact.Mailing_Address_Inactive__c);
    }

    @isTest
    static void testCopyAddressObjSobjInvalidField() {
        //To Refactor: we don't have guard clause for this.
        Contact contact = UTIL_UnitTestData_TEST.getContact();
        Account account = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];

        try {
            Test.startTest();
            ADDR_Addresses_UTIL.copyAddressStdSObj(account, 'Mailing', contact, 'Billing');
            Test.stopTest();
            System.assert(false, 'An SObject Exception should be thrown as we do not handle it in the method.');
        } catch (SObjectException e) {
            System.assertEquals(
                'Invalid field MailingStreet for Account',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    /**************************************************************************************************************************
     ****************************************************** copyAddressStdSObjAddr ********************************************
     **************************************************************************************************************************/
    @isTest
    static void testCopyAddressObjSobjAddrAddressNull() {
        //To Refactor: we don't have guard clause for this.
        Account account = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];

        try {
            Test.startTest();
            ADDR_Addresses_UTIL.copyAddressStdSObjAddr(account, 'Billing', null, 'Home');
            Test.stopTest();
            System.assert(false, 'A Null Pointer Exception should be thrown as we do not handle nulls in the method.');
        } catch (NullPointerException e) {
            System.assertEquals(
                'Attempt to de-reference a null object',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    @isTest
    static void testCopyAddressObjSobjAddrSourceFieldPrefixNull() {
        //To Refactor: we don't have guard clause for this.
        Account account = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        Address__c address = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];

        try {
            Test.startTest();
            ADDR_Addresses_UTIL.copyAddressStdSObjAddr(account, null, address, 'Home');
            Test.stopTest();
            System.assert(false, 'An SObject Exception should be thrown as we do not handle it in the method.');
        } catch (SObjectException e) {
            System.assertEquals(
                'Invalid field nullStreet for Account',
                e.getMessage(),
                'Should throw Invalid field exception.'
            );
        }
    }

    @isTest
    static void testCopyAddressObjSobjAddrSourceRecordNull() {
        //To Refactor: we don't have guard clause for this.
        Address__c address = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];

        try {
            Test.startTest();
            ADDR_Addresses_UTIL.copyAddressStdSObjAddr(null, 'Billing', address, 'Home');
            Test.stopTest();
            System.assert(false, 'A Null Pointer Exception should be thrown as we do not handle nulls in the method.');
        } catch (NullPointerException e) {
            System.assertEquals(
                'Attempt to de-reference a null object',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    @isTest
    static void testCopyAddressObjSobjAddrValidField() {
        Account account = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        Address__c address = new Address__c();

        Test.startTest();
        ADDR_Addresses_UTIL.copyAddressStdSObjAddr(account, 'Billing', address, 'Home');
        Test.stopTest();

        System.assertEquals(account.BillingStreet, address.MailingStreet__c);
        System.assertEquals(account.BillingCity, address.MailingCity__c);
        System.assertEquals(account.Billing_County__c, address.MailingCounty__c);
        System.assertEquals(account.BillingPostalCode, address.MailingPostalCode__c);
        System.assertEquals(account.BillingState, address.MailingState__c);
        System.assertEquals(account.BillingCountry, address.MailingCountry__c);
        System.assertEquals(account.BillingLatitude, address.Geolocation__Latitude__s);
        System.assertEquals(account.BillingLongitude, address.Geolocation__Longitude__s);
        System.assertEquals('Home', address.Address_Type__c);
    }

    @isTest
    static void testCopyAddressObjSobjAddrValidFieldAccountInactiveAddressFields() {
        Account account = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        account.Billing_Address_Inactive__c = true;
        Address__c address = new Address__c();
        address.Inactive__c = false;

        Test.startTest();
        ADDR_Addresses_UTIL.copyAddressStdSObjAddr(account, 'Billing', address, 'Home');
        Test.stopTest();

        System.assertEquals(account.BillingStreet, address.MailingStreet__c);
        System.assertEquals(account.BillingCity, address.MailingCity__c);
        System.assertEquals(account.Billing_County__c, address.MailingCounty__c);
        System.assertEquals(account.BillingPostalCode, address.MailingPostalCode__c);
        System.assertEquals(account.BillingState, address.MailingState__c);
        System.assertEquals(account.BillingCountry, address.MailingCountry__c);
        System.assertEquals(account.BillingLatitude, address.Geolocation__Latitude__s);
        System.assertEquals(account.BillingLongitude, address.Geolocation__Longitude__s);
        System.assertEquals('Home', address.Address_Type__c);
        System.assertEquals(true, address.Inactive__c);
    }

    @isTest
    static void testCopyAddressObjSobjAddrValidFieldContactInactiveAddressFields() {
        Contact contact = UTIL_UnitTestData_TEST.getContact();
        contact.Mailing_Address_Inactive__c = true;
        Address__c address = new Address__c();
        address.Inactive__c = false;

        Test.startTest();
        ADDR_Addresses_UTIL.copyAddressStdSObjAddr(contact, 'Mailing', address, 'Home');
        Test.stopTest();

        System.assertEquals(contact.MailingStreet, address.MailingStreet__c);
        System.assertEquals(contact.MailingCity, address.MailingCity__c);
        System.assertEquals(contact.Mailing_County__c, address.MailingCounty__c);
        System.assertEquals(contact.MailingPostalCode, address.MailingPostalCode__c);
        System.assertEquals(contact.MailingState, address.MailingState__c);
        System.assertEquals(contact.MailingCountry, address.MailingCountry__c);
        System.assertEquals(contact.MailingLatitude, address.Geolocation__Latitude__s);
        System.assertEquals(contact.MailingLongitude, address.Geolocation__Longitude__s);
        System.assertEquals('Home', address.Address_Type__c);
        System.assertEquals(true, address.Inactive__c);
    }

    @isTest
    static void testCopyAddressObjSobjAddrValidFieldContactInactiveAddressFieldsInvalid() {
        Contact contact = UTIL_UnitTestData_TEST.getContact();
        contact.Mailing_Address_Inactive__c = true;
        Address__c address = new Address__c();
        address.Inactive__c = false;

        Test.startTest();
        ADDR_Addresses_UTIL.copyAddressStdSObjAddr(contact, 'Other', address, 'Home');
        Test.stopTest();

        System.assertEquals(false, address.Inactive__c);
    }

    @isTest
    static void testCopyAddressObjSobjAddrInvalidField() {
        //To Refactor: we don't have guard clause for this.
        Account account = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        Address__c address = new Address__c();

        try {
            Test.startTest();
            ADDR_Addresses_UTIL.copyAddressStdSObjAddr(account, 'Mailing', address, 'Home');
            Test.stopTest();
            System.assert(false, 'An SObject Exception should be thrown as we do not handle it in the method.');
        } catch (SObjectException e) {
            System.assertEquals(
                'Invalid field MailingStreet for Account',
                e.getMessage(),
                'Should throw Invalid field exception.'
            );
        }
    }

    /**************************************************************************************************************************
     ****************************************************** copyAddressAddrSObj ***********************************************
     **************************************************************************************************************************/
    @isTest
    static void testCopyAddressAddrSObjAddressNull() {
        //To Refactor: we don't have guard clause for this.
        Account account = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        TDTM_Runnable.DmlWrapper dmlWrapper = new TDTM_Runnable.DmlWrapper();

        try {
            Test.startTest();
            ADDR_Addresses_UTIL.copyAddressAddrSObj(null, account, 'Billing', 'Primary_Address_Type__c', dmlWrapper);
            Test.stopTest();
            System.assert(false, 'A Null Pointer Exception should be thrown as we do not handle nulls in the method.');
        } catch (NullPointerException e) {
            System.assertEquals(
                'Attempt to de-reference a null object',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    @isTest
    static void testCopyAddressAddrSObjSourceRecordNull() {
        //To Refactor: we don't have guard clause for this.
        Address__c address = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];
        TDTM_Runnable.DmlWrapper dmlWrapper = new TDTM_Runnable.DmlWrapper();

        try {
            Test.startTest();
            ADDR_Addresses_UTIL.copyAddressAddrSObj(address, null, 'Billing', 'Primary_Address_Type__c', dmlWrapper);
            Test.stopTest();
            System.assert(false, 'A Null Pointer Exception should be thrown as we do not handle nulls in the method.');
        } catch (NullPointerException e) {
            System.assertEquals(
                'Attempt to de-reference a null object',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    @isTest
    static void testCopyAddressAddrSObjSourceRecordPrefixNull() {
        //To Refactor: we don't have guard clause for this.
        Address__c address = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];
        Account account = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        TDTM_Runnable.DmlWrapper dmlWrapper = new TDTM_Runnable.DmlWrapper();

        try {
            Test.startTest();
            ADDR_Addresses_UTIL.copyAddressAddrSObj(address, account, null, 'Primary_Address_Type__c', dmlWrapper);
            Test.stopTest();
            System.assert(false, 'An SObject Exception should be thrown as we do not handle it in the method.');
        } catch (SObjectException e) {
            System.assertEquals(
                'Invalid field nullStreet for Account',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    @isTest
    static void testCopyAddressAddrSObjValidField() {
        Address__c address = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];
        Contact contact = new Contact();
        TDTM_Runnable.DmlWrapper dmlWrapper = new TDTM_Runnable.DmlWrapper();

        Test.startTest();
        ADDR_Addresses_UTIL.copyAddressAddrSObj(address, contact, 'Mailing', 'Primary_Address_Type__c', dmlWrapper);
        Test.stopTest();

        System.assertEquals(address.MailingStreet__c, contact.MailingStreet);
        System.assertEquals(address.MailingCity__c, contact.MailingCity);
        System.assertEquals(address.MailingCounty__c, contact.Mailing_County__c);
        System.assertEquals(address.MailingPostalCode__c, contact.MailingPostalCode);
        System.assertEquals(address.MailingState__c, contact.MailingState);
        System.assertEquals(address.MailingCountry__c, contact.MailingCountry);
        System.assertEquals(address.Geolocation__Latitude__s, contact.MailingLatitude);
        System.assertEquals(address.Geolocation__Longitude__s, contact.MailingLongitude);
        System.assertEquals(address.Address_Type__c, contact.get('Primary_Address_Type__c'));
        System.assertEquals(true, dmlWrapper.objectsToUpdate.size() > 0);
        System.assertEquals(address.MailingStreet__c, dmlWrapper.objectsToUpdate[0].get('MailingStreet'));
    }

    @isTest
    static void testCopyAddressAddrSObjValidFieldInactiveAddressFields() {
        Address__c address = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];
        address.Inactive__c = true;
        Contact contact = new Contact();
        TDTM_Runnable.DmlWrapper dmlWrapper = new TDTM_Runnable.DmlWrapper();

        Test.startTest();
        ADDR_Addresses_UTIL.copyAddressAddrSObj(address, contact, 'Mailing', 'Primary_Address_Type__c', dmlWrapper);
        Test.stopTest();

        System.assertEquals(address.MailingStreet__c, contact.MailingStreet);
        System.assertEquals(address.MailingCity__c, contact.MailingCity);
        System.assertEquals(address.MailingCounty__c, contact.Mailing_County__c);
        System.assertEquals(address.MailingPostalCode__c, contact.MailingPostalCode);
        System.assertEquals(address.MailingState__c, contact.MailingState);
        System.assertEquals(address.MailingCountry__c, contact.MailingCountry);
        System.assertEquals(address.Geolocation__Latitude__s, contact.MailingLatitude);
        System.assertEquals(address.Geolocation__Longitude__s, contact.MailingLongitude);
        System.assertEquals(address.Address_Type__c, contact.get('Primary_Address_Type__c'));
        System.assertEquals(true, dmlWrapper.objectsToUpdate.size() > 0);
        System.assertEquals(address.MailingStreet__c, dmlWrapper.objectsToUpdate[0].get('MailingStreet'));
        System.assertEquals(true, contact.Mailing_Address_Inactive__c);
    }

    @isTest
    static void testCopyAddressAddrSObjValidFieldInactiveAddressFieldsInvalid() {
        Address__c address = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];
        address.Inactive__c = true;
        Contact contact = new Contact();
        TDTM_Runnable.DmlWrapper dmlWrapper = new TDTM_Runnable.DmlWrapper();

        Test.startTest();
        ADDR_Addresses_UTIL.copyAddressAddrSObj(address, contact, 'Other', 'Primary_Address_Type__c', dmlWrapper);
        Test.stopTest();

        System.assertEquals(false, contact.Mailing_Address_Inactive__c);
    }

    @isTest
    static void testCopyAddressAddrSObjInvalidSourceRecordField() {
        //To Refactor: we don't have guard clause for this.
        Address__c address = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];
        Contact contact = new Contact();
        TDTM_Runnable.DmlWrapper dmlWrapper = new TDTM_Runnable.DmlWrapper();

        try {
            Test.startTest();
            ADDR_Addresses_UTIL.copyAddressAddrSObj(address, contact, 'Billing', 'Primary_Address_Type__c', dmlWrapper);
            Test.stopTest();
            System.assert(false, 'An SObject Exception should be thrown as we do not handle it in the method.');
        } catch (SObjectException e) {
            System.assertEquals(
                'Invalid field BillingStreet for Contact',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    /**************************************************************************************************************************
     ****************************************************** initValidStateCountryCodes ****************************************
     **************************************************************************************************************************/

    //This method is not quite testable as it is using schema describe. Potentially we can use unmanaged tests.

    /**************************************************************************************************************************
     ****************************************************** handleMultilineStreet *********************************************
     **************************************************************************************************************************/
    @isTest
    static void testHandleMultilineStreetNull() {
        //To Refactor: we don't have guard clause for this.
        try {
            Test.startTest();
            ADDR_Addresses_UTIL.handleMultilineStreet(null);
            Test.stopTest();
            System.assert(false, 'A Null Pointer Exception should be thrown as we do not handle nulls in the method.');
        } catch (NullPointerException e) {
            System.assertEquals(
                'Attempt to de-reference a null object',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    @isTest
    static void testHandleMultilineStreetRN() {
        Address__c address = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];
        address.MailingStreet__c = 'test\r\nmultiple line street';

        Test.startTest();
        ADDR_Addresses_UTIL.handleMultilineStreet(address);
        Test.stopTest();

        System.assertEquals('test', address.MailingStreet__c);
        System.assertEquals('multiple line street', address.MailingStreet2__c);
    }

    @isTest
    static void testHandleMultilineStreetN() {
        Address__c address = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];
        address.MailingStreet__c = 'test\nmultiple line street';

        Test.startTest();
        ADDR_Addresses_UTIL.handleMultilineStreet(address);
        Test.stopTest();

        System.assertEquals('test', address.MailingStreet__c);
        System.assertEquals('multiple line street', address.MailingStreet2__c);
    }

    /**************************************************************************************************************************
     ****************************************************** getMultilineStreet ************************************************
     **************************************************************************************************************************/
    @isTest
    static void testGetMultilineStreetNull() {
        //To Refactor: we don't have guard clause for this.
        try {
            Test.startTest();
            ADDR_Addresses_UTIL.getMultilineStreet(null);
            Test.stopTest();
            System.assert(false, 'A Null Pointer Exception should be thrown as we do not handle nulls in the method.');
        } catch (NullPointerException e) {
            System.assertEquals(
                'Attempt to de-reference a null object',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    @isTest
    static void testGetMultilineStreetStreet2NotBlank() {
        Address__c address = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];
        address.MailingStreet__c = 'test';
        address.MailingStreet2__c = 'multiple line street';
        Test.startTest();
        String multilineStreet = ADDR_Addresses_UTIL.getMultilineStreet(address);
        Test.stopTest();

        System.assertEquals('test\r\nmultiple line street', multilineStreet);
    }

    @isTest
    static void testGetMultilineStreetStreet2Blank() {
        Address__c address = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];
        address.MailingStreet__c = 'test';
        address.MailingStreet2__c = null;
        Test.startTest();
        String multilineStreet = ADDR_Addresses_UTIL.getMultilineStreet(address);
        Test.stopTest();

        System.assertEquals('test', multilineStreet);
    }

    /**************************************************************************************************************************
     ****************************************************** isStateCountryPicklistsEnabled ************************************
     **************************************************************************************************************************/

    //At this moment, it is really hard to test this method. We may consider make the methods virtual to override.

    /**************************************************************************************************************************
     ****************************************************** getNonDuplicateAddresses ******************************************
     **************************************************************************************************************************/

    //Skipped for this release. TODO: Break down the methods so that it is not handling a hundred things.

    /**************************************************************************************************************************
     ****************************************************** findDuplicateAddresses ********************************************
     **************************************************************************************************************************/

    //Skipped for this release. TODO: Break down the methods so that it is not handling a hundred things.

    /**************************************************************************************************************************
     ****************************************************** getParentIdToAddrs ************************************************
     **************************************************************************************************************************/
    @isTest
    static void testGetParentIdToAddrsNull() {
        //To Refactor: we don't have guard clause for this.
        try {
            Test.startTest();
            Map<ID, List<Address__c>> parentIdToAddrs = ADDR_Addresses_UTIL.getParentIdToAddrs(null);
            Test.stopTest();
            System.assert(false, 'A Null Pointer Exception should be thrown as we do not handle nulls in the method.');
        } catch (NullPointerException e) {
            System.assertEquals(
                'Attempt to de-reference a null object',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    @isTest
    static void testGetParentIdToAddrsAccount() {
        //To Refactor: Make the getMapParentIdListAddrs() virtual so that we can override it.
        //To Refactor: Use set of ids instead.
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            10,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        insert accounts;

        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(10);
        for (Integer i = 0; i < addresses.size(); i++) {
            addresses[i].Parent_Account__c = accounts[i].Id;
        }
        insert addresses;

        Test.startTest();
        Map<ID, List<Address__c>> parentIdToAddrs = ADDR_Addresses_UTIL.getParentIdToAddrs(addresses);
        Test.stopTest();

        System.assertEquals(accounts.size(), parentIdToAddrs.keySet().size());
        for (Integer i = 0; i < addresses.size(); i++) {
            System.assertEquals(true, parentIdToAddrs.keySet().contains(accounts[i].Id));
            System.assertEquals(1, parentIdToAddrs.get(accounts[i].Id).size());
            System.assertEquals(addresses[i].Id, parentIdToAddrs.get(accounts[i].Id)[0].Id);
        }
    }

    @isTest
    static void testGetParentIdToAddrsContact() {
        //To Refactor: Make the getMapParentIdListAddrs() virtual so that we can override it.
        //To Refactor: Use set of ids instead.
        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(10);
        insert contacts;

        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(10);
        for (Integer i = 0; i < addresses.size(); i++) {
            addresses[i].Parent_Contact__c = contacts[i].Id;
        }
        insert addresses;

        Test.startTest();
        Map<ID, List<Address__c>> parentIdToAddrs = ADDR_Addresses_UTIL.getParentIdToAddrs(addresses);
        Test.stopTest();

        System.assertEquals(contacts.size(), parentIdToAddrs.keySet().size());
        for (Integer i = 0; i < addresses.size(); i++) {
            System.assertEquals(true, parentIdToAddrs.keySet().contains(contacts[i].Id));
            System.assertEquals(1, parentIdToAddrs.get(contacts[i].Id).size());
            System.assertEquals(addresses[i].Id, parentIdToAddrs.get(contacts[i].Id)[0].Id);
        }
    }

    /**************************************************************************************************************************
     ****************************************************** getMapParentIdListAddrs *******************************************
     **************************************************************************************************************************/
    @isTest
    static void testGetMapParentIdListAddrsNull() {
        //To Refactor: we don't have guard clause for this.
        try {
            Test.startTest();
            Map<ID, List<Address__c>> parentIdToAddrs = ADDR_Addresses_UTIL.getMapParentIdListAddrs(null);
            Test.stopTest();
            System.assert(false, 'A Null Pointer Exception should be thrown as we do not handle nulls in the method.');
        } catch (NullPointerException e) {
            System.assertEquals(
                'Attempt to de-reference a null object',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    @isTest
    static void testGetMapParentIdListAddrsEmptyIdList() {
        Test.startTest();
        Map<ID, List<Address__c>> parentIdToAddrs = ADDR_Addresses_UTIL.getMapParentIdListAddrs(new List<Id>());
        Test.stopTest();

        System.assertEquals(0, parentIdToAddrs.keySet().size());
    }

    @isTest
    static void testGetMapParentIdListAddrsAccount() {
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            10,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        insert accounts;

        List<Id> parentIds = new List<Id>();
        for (Account account : accounts) {
            parentIds.add(account.Id);
        }

        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(10);
        for (Integer i = 0; i < addresses.size(); i++) {
            addresses[i].Parent_Account__c = accounts[i].Id;
        }
        insert addresses;

        Test.startTest();
        Map<ID, List<Address__c>> parentIdToAddrs = ADDR_Addresses_UTIL.getMapParentIdListAddrs(parentIds);
        Test.stopTest();

        System.assertEquals(accounts.size(), parentIdToAddrs.keySet().size());
        for (Integer i = 0; i < addresses.size(); i++) {
            System.assertEquals(true, parentIdToAddrs.keySet().contains(accounts[i].Id));
            System.assertEquals(1, parentIdToAddrs.get(accounts[i].Id).size());
            System.assertEquals(addresses[i].Id, parentIdToAddrs.get(accounts[i].Id)[0].Id);
        }
    }

    @isTest
    static void testGetMapParentIdListAddrsContact() {
        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(10);
        insert contacts;

        List<Id> parentIds = new List<Id>();
        for (Contact contact : contacts) {
            parentIds.add(contact.Id);
        }

        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(10);
        for (Integer i = 0; i < addresses.size(); i++) {
            addresses[i].Parent_Contact__c = contacts[i].Id;
        }
        insert addresses;

        Test.startTest();
        Map<ID, List<Address__c>> parentIdToAddrs = ADDR_Addresses_UTIL.getMapParentIdListAddrs(parentIds);
        Test.stopTest();

        System.assertEquals(contacts.size(), parentIdToAddrs.keySet().size());
        for (Integer i = 0; i < addresses.size(); i++) {
            System.assertEquals(true, parentIdToAddrs.keySet().contains(contacts[i].Id));
            System.assertEquals(1, parentIdToAddrs.get(contacts[i].Id).size());
            System.assertEquals(addresses[i].Id, parentIdToAddrs.get(contacts[i].Id)[0].Id);
        }
    }

    /**************************************************************************************************************************
     ****************************************************** updateAddrIsOverride **********************************************
     **************************************************************************************************************************/
    @isTest
    static void testUpdateAddrIsOverrideMapNull() {
        //To Refactor: we don't have guard clause for this.
        TDTM_Runnable.DmlWrapper dmlWrapper = new TDTM_Runnable.DmlWrapper();

        try {
            Test.startTest();
            ADDR_Addresses_UTIL.updateAddrIsOverride(null, dmlWrapper);
            Test.stopTest();
            System.assert(false, 'A Null Pointer Exception should be thrown as we do not handle nulls in the method.');
        } catch (NullPointerException e) {
            System.assertEquals(
                'Attempt to de-reference a null object',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    @isTest
    static void testUpdateAddrIsOverrideDMWrapperNull() {
        //To Refactor: we don't have guard clause for this.
        Map<Id, Boolean> mapAddrIdIsOverride = new Map<Id, Boolean>();

        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            10,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        insert accounts;

        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(10);
        for (Integer i = 0; i < addresses.size(); i++) {
            addresses[i].Parent_Account__c = accounts[i].Id;
        }
        insert addresses;

        for (Integer i = 0; i < addresses.size(); i++) {
            if (i < 5) {
                mapAddrIdIsOverride.put(addresses[i].Id, true);
            } else {
                mapAddrIdIsOverride.put(addresses[i].Id, false);
            }
        }

        try {
            Test.startTest();
            ADDR_Addresses_UTIL.updateAddrIsOverride(mapAddrIdIsOverride, null);
            Test.stopTest();
            System.assert(false, 'A Null Pointer Exception should be thrown as we do not handle nulls in the method.');
        } catch (NullPointerException e) {
            System.assertEquals(
                'Attempt to de-reference a null object',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    @isTest
    static void testUpdateAddrIsOverride() {
        //To Refactor: we don't have guard clause for this.
        Map<Id, Boolean> mapAddrIdIsOverride = new Map<Id, Boolean>();

        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            10,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        insert accounts;

        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(10);
        for (Integer i = 0; i < addresses.size(); i++) {
            addresses[i].Parent_Account__c = accounts[i].Id;
        }
        insert addresses;
        Set<Id> overridedAddresseIds = new Set<Id>();

        for (Integer i = 0; i < addresses.size(); i++) {
            if (i < 5) {
                mapAddrIdIsOverride.put(addresses[i].Id, true);
                overridedAddresseIds.add(addresses[i].Id);
            } else {
                mapAddrIdIsOverride.put(addresses[i].Id, false);
            }
        }

        TDTM_Runnable.DmlWrapper dmlWrapper = new TDTM_Runnable.DmlWrapper();

        Test.startTest();
        ADDR_Addresses_UTIL.updateAddrIsOverride(mapAddrIdIsOverride, dmlWrapper);
        Test.stopTest();

        System.assertEquals(10, dmlWrapper.objectsToUpdate.size());
        for (SObject objectToUpdate : dmlWrapper.objectsToUpdate) {
            Address__c address = (Address__c) objectToUpdate;
            if (overridedAddresseIds.contains(address.Id)) {
                //Will this break if time zone or maybe test running delay
                System.assertEquals(true, address.Latest_Start_Date__c.isSameDay(System.Today()));
                System.assertEquals(null, address.Latest_End_Date__c);
            } else {
                System.assertEquals(true, address.Latest_End_Date__c.isSameDay(System.Today()));
            }
        }
    }

    /**************************************************************************************************************************
     ****************************************************** uncheckDefaultOtherAddrs ******************************************
     **************************************************************************************************************************/
    @isTest
    static void testUncheckDefaultOtherAddrsNewAddrNull() {
        //To Refactor: we don't have guard clause for this.
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(10);
        TDTM_Runnable.DmlWrapper dmlWrapper = new TDTM_Runnable.DmlWrapper();

        try {
            Test.startTest();
            ADDR_Addresses_UTIL.uncheckDefaultOtherAddrs(null, addresses, dmlWrapper);
            Test.stopTest();
            System.assert(false, 'A Null Pointer Exception should be thrown as we do not handle nulls in the method.');
        } catch (NullPointerException e) {
            System.assertEquals(
                'Attempt to de-reference a null object',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    @isTest
    static void testUncheckDefaultOtherAddrsAllAddrsNull() {
        //To Refactor: we don't have guard clause for this.
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);
        TDTM_Runnable.DmlWrapper dmlWrapper = new TDTM_Runnable.DmlWrapper();

        try {
            Test.startTest();
            ADDR_Addresses_UTIL.uncheckDefaultOtherAddrs(addresses[0], null, dmlWrapper);
            Test.stopTest();
            System.assert(false, 'A Null Pointer Exception should be thrown as we do not handle nulls in the method.');
        } catch (NullPointerException e) {
            System.assertEquals(
                'Attempt to de-reference a null object',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    @isTest
    static void testUncheckDefaultOtherAddrsDMLWrapperNull() {
        //To Refactor: we don't have guard clause for this.
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            10,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        insert accounts;

        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(10);
        for (Integer i = 0; i < addresses.size(); i++) {
            addresses[i].Parent_Account__c = accounts[i].Id;
        }
        insert addresses;
        TDTM_Runnable.DmlWrapper dmlWrapper = new TDTM_Runnable.DmlWrapper();

        try {
            Test.startTest();
            ADDR_Addresses_UTIL.uncheckDefaultOtherAddrs(addresses[0], addresses, null);
            Test.stopTest();
            System.assert(false, 'A Null Pointer Exception should be thrown as we do not handle nulls in the method.');
        } catch (NullPointerException e) {
            System.assertEquals(
                'Attempt to de-reference a null object',
                e.getMessage(),
                'Should throw null pointer exception.'
            );
        }
    }

    @isTest
    static void testUncheckDefaultOtherAddrs() {
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            10,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        insert accounts;

        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(10);
        for (Integer i = 0; i < addresses.size(); i++) {
            addresses[i].Parent_Account__c = accounts[i].Id;
        }
        insert addresses;
        TDTM_Runnable.DmlWrapper dmlWrapper = new TDTM_Runnable.DmlWrapper();

        Test.startTest();
        ADDR_Addresses_UTIL.uncheckDefaultOtherAddrs(addresses[0], addresses, dmlWrapper);
        Test.stopTest();

        System.assertEquals(9, dmlWrapper.objectsToUpdate.size());
        for (SObject objectToUpdate : dmlWrapper.objectsToUpdate) {
            Address__c address = (Address__c) objectToUpdate;
            System.assertEquals(false, address.Default_Address__c);
        }
    }

    /**************************************************************************************************************************
     ****************************************************** clearAddrInfo *****************************************************
     **************************************************************************************************************************/
    @isTest
    static void testClearAddrInfoNull() {
        //To Refactor: No need to overload here. Passing null will cause Ambiguous method signature error.
        //No way to test null parameters now.
    }

    @isTest
    static void testClearAddrInfoAccount() {
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        );

        Test.startTest();
        ADDR_Addresses_UTIL.clearAddrInfo(accounts[0]);
        Test.stopTest();

        System.assertEquals(null, accounts[0].BillingStreet);
        System.assertEquals(null, accounts[0].BillingCity);
        System.assertEquals(null, accounts[0].Billing_County__c);
        System.assertEquals(null, accounts[0].BillingState);
        System.assertEquals(null, accounts[0].BillingPostalCode);
        //To Refactor, we are setting coutnry to null whether the state picklist is enabled or not.
        System.assertEquals(null, accounts[0].BillingCountry);
        System.assertEquals(null, accounts[0].BillingLatitude);
        System.assertEquals(null, accounts[0].BillingLongitude);
        System.assertEquals(null, accounts[0].BillingState);
    }

    @isTest
    static void testClearAddrInfoContact() {
        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(1);

        Test.startTest();
        ADDR_Addresses_UTIL.clearAddrInfo(contacts[0]);
        Test.stopTest();

        System.assertEquals(null, contacts[0].MailingStreet);
        System.assertEquals(null, contacts[0].MailingCity);
        System.assertEquals(null, contacts[0].Mailing_County__c);
        System.assertEquals(null, contacts[0].MailingState);
        System.assertEquals(null, contacts[0].MailingPostalCode);
        System.assertEquals(null, contacts[0].MailingCountry);
        System.assertEquals(null, contacts[0].MailingLatitude);
        System.assertEquals(null, contacts[0].MailingLongitude);
    }

    /**************************************************************************************************************************
     ****************************************************** getParentAccsWithChildrenQuery ************************************
     **************************************************************************************************************************/
    @isTest
    static void testGetParentAccsWithChildrenQueryPicklistEnabled() {
        //Placeholder for now until we make the enable check virtual
        /*Test.startTest();
        String parentAccsWithChildrenQuery = ADDR_Addresses_UTIL.getParentAccsWithChildrenQuery();
        Test.stopTest();

        String assertString =
            'SELECT recordTypeId, Current_Address__c, BillingStreet, ' +
            'BillingCity, Billing_County__c, BillingState, ' +
            'BillingPostalCode, BillingCountry, BillingLatitude, ' +
            'BillingLongitude';

        assertString += ', BillingCountryCode, BillingStateCode';
        assertString += ', (SELECT Current_Address__c, is_Address_Override__c, Primary_Address_Type__c, MailingStreet, MailingCity, Mailing_County__c, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude';
        assertString += ', MailingCountryCode, MailingStateCode';
        assertString += ' FROM Account.Contacts)';
        assertString += ', (SELECT Default_Address__c, Parent_Account__c, Parent_Contact__c, MailingCounty__c, Latest_Start_Date__c, Latest_End_Date__c FROM Account.Addresses__r)';
        assertString += ' FROM Account WHERE Id IN ';

        System.assertEquals(parentAccsWithChildrenQuery, assertString);*/
    }

    @isTest
    static void testGetParentAccsWithChildrenQueryPicklistDisabled() {
        Test.startTest();
        String parentAccsWithChildrenQuery = ADDR_Addresses_UTIL.getParentAccsWithChildrenQuery();
        Test.stopTest();

        String assertString =
            'SELECT recordTypeId, Current_Address__c, BillingStreet, ' +
            'BillingCity, Billing_County__c, BillingState, ' +
            'BillingPostalCode, BillingCountry, BillingLatitude, ' +
            'BillingLongitude, Billing_Address_Inactive__c';

        assertString += ', (SELECT Current_Address__c, is_Address_Override__c, Primary_Address_Type__c, MailingStreet, MailingCity, Mailing_County__c, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, Mailing_Address_Inactive__c';
        assertString += ' FROM Account.Contacts)';
        assertString += ', (SELECT Default_Address__c, Parent_Account__c, Parent_Contact__c, MailingCounty__c, Latest_Start_Date__c, Latest_End_Date__c, Inactive__c FROM Account.Addresses__r)';
        assertString += ' FROM Account WHERE Id IN ';

        System.assertEquals(parentAccsWithChildrenQuery, assertString);
    }
}
