/*
    Copyright (c) 2019, Salesforce.org
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
* @date 2019
* @group Utilities
* @description Test for UTIL_SortContacts
*/
@isTest
private class UTIL_SortContacts_TEST {
	/*********************************************************************************************************
    * @description Test Method to test sorting Contacts alphabetically by LastName FirstName
    */
    @isTest()
    private static void sortContactsLastFirstName() {
        List<UTIL_SortContacts> utilSortCons = new List<UTIL_SortContacts>();
        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(9);

        contacts[0].FirstName = 'Will';
        contacts[0].LastName = 'Zap';
        contacts[1].FirstName = 'William';
        contacts[1].LastName = 'Zap';
        contacts[2].FirstName = 'Abigail';
        contacts[2].LastName = 'Zap';
        contacts[3].FirstName = 'Tammy';
        contacts[3].LastName = 'Brett';
        contacts[4].FirstName = 'Betty';
        contacts[4].LastName = 'Brett';
        contacts[5].FirstName = 'Charles';
        contacts[5].LastName = 'Brett';
        contacts[6].FirstName = 'Cat';
        contacts[6].LastName = 'Pierre';
        contacts[7].FirstName = 'Lyla';
        contacts[7].LastName = 'Pierre';
        contacts[8].FirstName = 'Annie';
        contacts[8].LastName = 'Pierre';

        Test.startTest();
        utilSortCons.add(new UTIL_SortContacts(contacts[0]));
        utilSortCons.add(new UTIL_SortContacts(contacts[1]));
        utilSortCons.add(new UTIL_SortContacts(contacts[2]));
        utilSortCons.add(new UTIL_SortContacts(contacts[3]));
        utilSortCons.add(new UTIL_SortContacts(contacts[4]));
        utilSortCons.add(new UTIL_SortContacts(contacts[5]));
        utilSortCons.add(new UTIL_SortContacts(contacts[6]));
        utilSortCons.add(new UTIL_SortContacts(contacts[7]));
        utilSortCons.add(new UTIL_SortContacts(contacts[8]));
        Test.stopTest();
        utilSortCons.sort();

        List<Contact> sortedContacts = new List<Contact>();
        for (UTIL_SortContacts us : utilSortCons) {
            sortedContacts.add(us.contactRecord);
        }

        System.assertEquals(contacts[4], sortedContacts[0]);
        System.assertEquals(contacts[5], sortedContacts[1]);
        System.assertEquals(contacts[3], sortedContacts[2]);
        System.assertEquals(contacts[8], sortedContacts[3]);
        System.assertEquals(contacts[6], sortedContacts[4]);
        System.assertEquals(contacts[7], sortedContacts[5]);
        System.assertEquals(contacts[2], sortedContacts[6]);
        System.assertEquals(contacts[0], sortedContacts[7]);
        System.assertEquals(contacts[1], sortedContacts[8]);

    }

    /*********************************************************************************************************
    * @description Test Method to test sorting Contacts alphabetically by LastName only.
    */
    @isTest
    private static void sortContactsLastName() {
        List<UTIL_SortContacts> utilSortCons = new List<UTIL_SortContacts>();
        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(3);

        contacts[0].FirstName = 'Will';
        contacts[0].LastName = 'Zap';
        contacts[1].FirstName = 'William';
        contacts[1].LastName = 'Brett';
        contacts[2].FirstName = 'Abigail';
        contacts[2].LastName = 'Pierre';


        Test.startTest();
        utilSortCons.add(new UTIL_SortContacts(contacts[0]));
        utilSortCons.add(new UTIL_SortContacts(contacts[1]));
        utilSortCons.add(new UTIL_SortContacts(contacts[2]));
        Test.stopTest();
        utilSortCons.sort();

        List<Contact> sortedContacts = new List<Contact>();
        for (UTIL_SortContacts us : utilSortCons) {
            sortedContacts.add(us.contactRecord);
        }

        System.assertEquals(contacts[1], sortedContacts[0]);
        System.assertEquals(contacts[2], sortedContacts[1]);
        System.assertEquals(contacts[0], sortedContacts[2]);
    }

    /*********************************************************************************************************
    * @description Test Method to test sorting Contacts alphabetically by FirstName only.
    */
    @isTest
    private static void sortContactsFirstName() {
        List<UTIL_SortContacts> utilSortCons = new List<UTIL_SortContacts>();
        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(3);

        contacts[0].FirstName = 'Will';
        contacts[0].LastName = 'Zap';
        contacts[1].FirstName = 'William';
        contacts[1].LastName = 'Zap';
        contacts[2].FirstName = 'Abigail';
        contacts[2].LastName = 'Zap';


        Test.startTest();
        utilSortCons.add(new UTIL_SortContacts(contacts[0]));
        utilSortCons.add(new UTIL_SortContacts(contacts[1]));
        utilSortCons.add(new UTIL_SortContacts(contacts[2]));
        Test.stopTest();
        utilSortCons.sort();

        List<Contact> sortedContacts = new List<Contact>();
        for (UTIL_SortContacts us : utilSortCons) {
            sortedContacts.add(us.contactRecord);
        }

        System.assertEquals(contacts[2], sortedContacts[0]);
        System.assertEquals(contacts[0], sortedContacts[1]);
        System.assertEquals(contacts[1], sortedContacts[2]);
    }

    /*********************************************************************************************************
    * @description Test Method to test sorting Contacts alphabetically by LastName with blank FirstName.
    */
    @isTest
    private static void sortContactsWithoutFirstNames() {
        List<UTIL_SortContacts> utilSortCons = new List<UTIL_SortContacts>();
        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(3);

        contacts[0].FirstName = '';
        contacts[0].LastName = 'Zap';
        contacts[1].FirstName = '';
        contacts[1].LastName = 'Brett';
        contacts[2].FirstName = '';
        contacts[2].LastName = 'Pierre';


        Test.startTest();
        utilSortCons.add(new UTIL_SortContacts(contacts[0]));
        utilSortCons.add(new UTIL_SortContacts(contacts[1]));
        utilSortCons.add(new UTIL_SortContacts(contacts[2]));
        Test.stopTest();
        utilSortCons.sort();

        List<Contact> sortedContacts = new List<Contact>();
        for (UTIL_SortContacts us : utilSortCons) {
            sortedContacts.add(us.contactRecord);
        }

        System.assertEquals(contacts[1], sortedContacts[0]);
        System.assertEquals(contacts[2], sortedContacts[1]);
        System.assertEquals(contacts[0], sortedContacts[2]);
    }
}