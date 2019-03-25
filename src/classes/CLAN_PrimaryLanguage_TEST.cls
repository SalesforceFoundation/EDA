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
* @description Tests specific to testing the logic around updating the Contact's "Primary Language" lookup 
* field when Contact Language records are modified.
*/
@isTest
private class CLAN_PrimaryLanguage_TEST {
    
    private static Contact contact;
    private static Language__c language;

    /*******************************************************************************************************
    * @description Inserts a new Language and Contact record for testing. 
    ********************************************************************************************************/
    private static void setup() {
        language = insertLanguage('English');

        contact = UTIL_UnitTestData_TEST.getContact();
        insert contact;
    }
    
    /*******************************************************************************************************
    * @description Inserts a new Language record for testing. 
    * @param name The name of the Language record.
    * @return The inserted Language record.
    ********************************************************************************************************/
    private static Language__c insertLanguage(String name) {
        Language__c languageToInsert = new Language__c(Name = name);
        insert languageToInsert;
        return languageToInsert;
    }

    /*******************************************************************************************************
    * @description Inserts a new Contact Language record for testing. 
    * @param languageId The Language associated to the Contact Language record.
    * @param isPrimaryLanguage Signifies whether or not the Contact Language should be marked as the Primary Language.
    * @return The inserted Contact Language record.
    ********************************************************************************************************/
    private static Contact_Language__c insertContactLanguage(Id languageId, Boolean isPrimaryLanguage) {
        Contact_Language__c contactLanguageToInsert = 
            new Contact_Language__c(Language__c = languageId, Contact__c = contact.Id, Primary_Language__c = isPrimaryLanguage);
        insert contactLanguageToInsert;
        return contactLanguageToInsert;
    }

    /*******************************************************************************************************
    * @description Verifies/asserts that the given Language is specified as the Primary Language on the test
    * Contact.
    * @param languageId The Language that should be the Primary Language on the Contact. May be null.
    ********************************************************************************************************/
    private static void assertPrimaryLanguageOnContact(Id languageId) {
        List<Contact> queriedContacts = [SELECT Primary_Language__c FROM Contact WHERE Id = :contact.Id];
        System.assertEquals(1, queriedContacts.size(), 'The expected Contact was not found.');
        System.assertEquals(languageId, queriedContacts[0].Primary_Language__c, 
            'The Primary Language on the Contact was not set as expected.');
    }

    /*******************************************************************************************************
    * @description Tests that when a Contact Language is created with Primary Language checked, the Primary
    * Language is set on the associated Contact.
    ********************************************************************************************************/
    @isTest
    private static void setPrimaryLanguageOnInsert() {
        setup();

        assertPrimaryLanguageOnContact(null);

        Test.startTest();
        insertContactLanguage(language.Id, true);
        Test.stopTest();

        assertPrimaryLanguageOnContact(language.Id);
    }

    /*******************************************************************************************************
    * @description Tests that when a Contact Language is updated with Primary Language checked, the Primary
    * Language is set on the associated Contact.
    ********************************************************************************************************/
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

    /*******************************************************************************************************
    * @description Tests that when multiple Contact Languages are updated with Primary Language checked, the 
    * Primary Language is set on the associated Contact of the most recent Primary Language and the other
    * Contact Language record is unset as the Primary Language.
    ********************************************************************************************************/
    @isTest
    private static void setMultiplePrimaryLanguages() {
        setup();

        assertPrimaryLanguageOnContact(null);

        Language__c newLanguage = insertLanguage('Spanish');
        Contact_Language__c firstContactLanguage = insertContactLanguage(language.Id, false);
        Contact_Language__c secondContactLanguage = insertContactLanguage(newLanguage.Id, false);

        Test.startTest();
        firstContactLanguage.Primary_Language__c = true;
        secondContactLanguage.Primary_Language__c = true;
        update new List<Contact_Language__c>{ firstContactLanguage, secondContactLanguage };
        Test.stopTest();

        assertPrimaryLanguageOnContact(newLanguage.Id);

        firstContactLanguage = [SELECT Primary_Language__c FROM Contact_Language__c WHERE Id = :firstContactLanguage.Id];
        System.assertEquals(false, firstContactLanguage.Primary_Language__c, 
            'Expected the other Contact Language record to no longer be set as the Primary Language.');
    }

    /*******************************************************************************************************
    * @description Tests that when a Contact Language is updated with Primary Language no longer checked, the 
    * Primary Language is cleared on the associated Contact.
    ********************************************************************************************************/
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

    /*******************************************************************************************************
    * @description Tests that when a Contact Language is deleted that had Primary Language checked, the Primary
    * Language is cleared on the associated Contact.
    ********************************************************************************************************/
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

    /*******************************************************************************************************
    * @description Tests that when a Contact Language is deleted that had Primary Language checked, the Primary
    * Language is not cleared on the associated Contact if the Language does not match.
    ********************************************************************************************************/
    @isTest
    private static void deletePrimaryLanguageWithNoMatchOnContact() {
        setup();

        Contact_Language__c contactLanguage = insertContactLanguage(language.Id, true);
        assertPrimaryLanguageOnContact(language.Id);

        // Manually update the lookup on the Contact to another value.
        Language__c newLanguage = insertLanguage('Spanish');
        contact.Primary_Language__c = newLanguage.Id;
        update contact;

        assertPrimaryLanguageOnContact(newLanguage.Id);

        Test.startTest();
        delete contactLanguage;
        Test.stopTest();

        assertPrimaryLanguageOnContact(newLanguage.Id);
    }

    /*******************************************************************************************************
    * @description Tests that when a Contact Language is updated with Primary Language checked and there had
    * been another Primary Language, the Primary Language is updated on the associated Contact and the old
    * Contact Language is unset as the Primary Language.
    ********************************************************************************************************/
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
        System.assertEquals(false, contactLanguage.Primary_Language__c, 
            'Expected the other Contact Language record to no longer be set as the Primary Language.');
    }

    /*******************************************************************************************************
    * @description Tests that when a Contact Language is updated with Primary Language checked and the former
    * Primary Contact Language is unset as the Primary Language in the same transaction, the Primary Language 
    * is updated correctly on the associated Contact.
    ********************************************************************************************************/
    @isTest
    private static void swapPrimaryLanguageInSameTransaction() {
        setup();

        Contact_Language__c contactLanguage = insertContactLanguage(language.Id, true);
        assertPrimaryLanguageOnContact(language.Id);

        Language__c newLanguage = insertLanguage('Spanish');
        Contact_Language__c secondContactLanguage = insertContactLanguage(newLanguage.Id, false);
        assertPrimaryLanguageOnContact(language.Id);

        Test.startTest();
        secondContactLanguage.Primary_Language__c = true;
        contactLanguage.Primary_Language__c = false;
        update new List<Contact_Language__c>{ contactLanguage, secondContactLanguage };
        Test.stopTest();

        assertPrimaryLanguageOnContact(newLanguage.Id);
    }
}