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
* @group Languages
* @group-content ../../ApexDocContent/Languages.htm
* @description Tests specific to testing the logic around updating the Contact's "Primary Language" lookup field when Contact
* Language records are modified.
*/
@isTest
private class CLAN_PrimaryLanguage_TEST {
    // TODO - finish these and remember to add ApexDocs for all

    private static Contact contact;
    private static Language__c language;

    private static void setup() {
        language = insertLanguage('English');

        contact = UTIL_UnitTestData_TEST.getContact();
        insert contact;
    }
    
    private static Language__c insertLanguage(String name) {
        Language__c languageToInsert = new Language__c(Name = name);
        insert languageToInsert;
        return languageToInsert;
    }

    private static Contact_Language__c insertContactLanguage(Id languageId, Boolean isPrimaryLanguage) {
        Contact_Language__c contactLanguageToInsert = new Contact_Language__c(Language__c = languageId, Contact__c = contact.Id, Primary_Language__c = isPrimaryLanguage);
        insert contactLanguageToInsert;
        return contactLanguageToInsert;
    }

    private static void assertPrimaryLanguageOnContact(Id languageId) {
        List<Contact> queriedContacts = [SELECT Primary_Language__c FROM Contact WHERE Id = :contact.Id];
        System.assertEquals(1, queriedContacts.size(), 'The expected Contact was not found.');
        System.assertEquals(languageId, queriedContacts[0].Primary_Language__c, 'The Primary Language on the Contact was not set as expected.');
    }

    @isTest
    private static void setPrimaryLanguageOnInsert() {
        setup();

        assertPrimaryLanguageOnContact(null);

        Test.startTest();
        insertContactLanguage(language.Id, true);
        Test.stopTest();

        assertPrimaryLanguageOnContact(language.Id);
    }

    @isTest
    private static void setPrimaryLanguageOnUpdate() {
        setup();

        Contact_Language__c contactLanguage = insertContactLanguage(language.Id, false);
        assertPrimaryLanguageOnContact(null);

        Test.startTest();
        contactLanguage.Primary_Language__c = true;
        update contactLanguage;
        Test.stopTest();

        assertPrimaryLanguageOnContact(language.Id);
    }

    @isTest
    private static void unsetPrimaryLanguage() {
        setup();

        Contact_Language__c contactLanguage = insertContactLanguage(language.Id, true);
        assertPrimaryLanguageOnContact(language.Id);

        Test.startTest();
        contactLanguage.Primary_Language__c = false;
        update contactLanguage;
        Test.stopTest();

        assertPrimaryLanguageOnContact(null);
    }

    @isTest
    private static void deletePrimaryLanguage() {
        setup();

        Contact_Language__c contactLanguage = insertContactLanguage(language.Id, true);
        assertPrimaryLanguageOnContact(language.Id);

        Test.startTest();
        delete contactLanguage;
        Test.stopTest();

        assertPrimaryLanguageOnContact(null);
    }

    @isTest
    private static void swapPrimaryLanguage() {
        setup();

        Contact_Language__c contactLanguage = insertContactLanguage(language.Id, true);
        assertPrimaryLanguageOnContact(language.Id);

        Language__c newLanguage = insertLanguage('Spanish');
        Contact_Language__c secondContactLanguage = insertContactLanguage(newLanguage.Id, false);
        assertPrimaryLanguageOnContact(language.Id);

        Test.startTest();
        secondContactLanguage.Primary_Language__c = true;
        update secondContactLanguage;
        Test.stopTest();

        assertPrimaryLanguageOnContact(newLanguage.Id);

        contactLanguage = [SELECT Primary_Language__c FROM Contact_Language__c WHERE Id = :contactLanguage.Id];
        System.assertEquals(false, contactLanguage.Primary_Language__c, 'Expected the other Contact Language record to no longer be set as the Primary Language.');
    }

    // Other possible unit tests to add:
    // Unset Primary Language - Primary Language not unset on Contact if not matching Language?
    // Delete Primary Language - Primary Language not unset on Contact if not matching Language?
    // Set Primary Language on one Contact Language and unset Primary Language on other Contact Language in same transaction
    // Set Primary Language on one Contact Language and delete Primary Contact Language in same transaction
    // Set multiple Contact Languages for the same Contact as the Primary Language in same transaction - which one wins
    // Nothing happens if the trigger is disabled?
    // Bulk Primary Language test?
}