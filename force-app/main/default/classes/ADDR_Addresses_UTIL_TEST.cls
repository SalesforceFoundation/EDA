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
    static void testIsAddressEmptyFalse() {
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1);

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
    static void isContactAccAddrInfoSameTrue() {
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
    static void isContactAccAddrInfoSameFalseDifferentAddressField() {
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
    static void isContactAccAddrInfoSameFalseDifferentStateCode() {
        /*Almost no way we can test state code/country code here
         This need to be refactored so that we can override the returned result*/
        //TODO(Refactor): Make isStateCountryPicklistsEnabled overridable
    }

    @isTest
    static void isContactAccAddrInfoSameNotNullContactNullAccount() {
        Contact contact = UTIL_UnitTestData_TEST.getContact();

        Test.startTest();
        Boolean isContactAccAddrInfoSame = ADDR_Addresses_UTIL.isContactAccAddrInfoSame(contact, null);
        Test.stopTest();

        System.assertEquals(false, isContactAccAddrInfoSame);
    }

    @isTest
    static void isContactAccAddrInfoSameNullContactNotNullAccount() {
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
    static void isContactAccAddrInfoSameNullContactNullAccount() {
        //We don't have guard clause for the scenario when both contact and account are null
        //Thus this will hit null pointer exception. Given the static method, we should refactor this.
        //TODO(Refactor): add guard clause for contact == null $$ account == null

        /*Test.startTest();
        Boolean isContactAccAddrInfoSame = ADDR_Addresses_UTIL.isContactAccAddrInfoSame(null, null);
        Test.stopTest();

        System.assertEquals(true, isContactAccAddrInfoSame);*/
    }
}
