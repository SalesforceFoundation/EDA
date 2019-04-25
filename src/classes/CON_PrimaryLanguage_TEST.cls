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
* @description Tests specific to testing the logic around creating and modifying Contact Language records when
* the Contact's "Primary Language" lookup field is manually changed.
*/
@isTest
private class CON_PrimaryLanguage_TEST {

    private static Contact contact;
    private static Language__c language;
    private static Contact_Language__c contactLanguage;
    private static final String DEFAULT_FLUENCY = Label.stgFluent;

    /*******************************************************************************************************
    * @description Inserts a new Language and Contact record for testing.
    * @param insertContact If true, inserts a new Contact record. Otherwise, a Contact is instantiated but
    * not inserted.
    ********************************************************************************************************/
    private static void setup(Boolean insertContact) {
        language = UTIL_UnitTestData_TEST.createLanguage('English');

        contact = UTIL_UnitTestData_TEST.getContact();
        if (insertContact) {
            insert contact;
        }
    }

    /*******************************************************************************************************
    * @description Verifies/asserts that the Contact Language record for the Language and Contact exists with
    * the expected values.
    * @param isPrimaryLanguage If true, the Primary Language checkbox is expected to be checked.
    * @param expectedFluency The expected value of the Contact Language's Fluency.
    * @param expectedLanguageId The expected value of the Contact Language's Language.
    * @param expectedContactLanguageId The expected value of the Contact Language's ID. May be null, in which
    * case the record was created by the process and did not already exist.
    ********************************************************************************************************/
    private static void assertContactLanguageRecord(Boolean isPrimaryLanguage, String expectedFluency, 
            Id expectedLanguageId, Id expectedContactLanguageId) {
        List<Contact_Language__c> queriedContactLanguages = [SELECT Id, Primary_Language__c, Fluency__c
            FROM Contact_Language__c
            WHERE Language__c = :expectedLanguageId 
                AND Contact__c = :contact.Id];

        System.assertEquals(1, queriedContactLanguages.size(), 'The expected Contact Language was not found.');

        contactLanguage = queriedContactLanguages[0];
        if (expectedContactLanguageId != null) {
            System.assertEquals(expectedContactLanguageId, contactLanguage.Id, 'The ID does not match the expected Contact Language ID.');
        }

        System.assertEquals(isPrimaryLanguage, contactLanguage.Primary_Language__c, 'The Primary Language value does not match the expected Primary Language value.');
        System.assertEquals(expectedFluency, contactLanguage.Fluency__c, 'The Fluency value does not match the expected Fluency value.');
    }

    /*******************************************************************************************************
    * @description Tests that when the Primary Language is set on a Contact when a new Contact is inserted,
    * a corresponding Primary Language Contact Language record is also created.
    ********************************************************************************************************/
    @isTest
    private static void setPrimaryLanguage() {
        setup(false); // Don't insert the Contact right away

        Test.startTest();
        contact.Primary_Language__c = language.Id;
        insert contact;
        Test.stopTest();

        assertContactLanguageRecord(true, DEFAULT_FLUENCY, language.Id, null);
    }

    /*******************************************************************************************************
    * @description Tests that when the Primary Language is set on a Contact when a Contact is updated, a
    * corresponding Primary Language Contact Language record is created if one doesn't already exist.
    ********************************************************************************************************/
    @isTest
    private static void setPrimaryLanguageOnUpdate() {
        setup(true);

        Test.startTest();
        contact.Primary_Language__c = language.Id;
        update contact;
        Test.stopTest();

        assertContactLanguageRecord(true, DEFAULT_FLUENCY, language.Id, null);
    }

    /*******************************************************************************************************
    * @description Tests that when the Primary Language is set on a Contact when a Contact is updated, a
    * corresponding Primary Language Contact Language record is not created if one already exists for the
    * Contact and Language. The existing record is updated as the Primary Language.
    ********************************************************************************************************/
    @isTest
    private static void setPrimaryLanguageWhenContactLanguageRecordExists() {
        setup(true);

        Contact_Language__c existingContactLanguage = 
            new Contact_Language__c(
                Language__c = language.Id, 
                Contact__c = contact.Id, 
                Fluency__c = DEFAULT_FLUENCY, 
                Primary_Language__c = false
            );
        insert existingContactLanguage;

        Test.startTest();
        contact.Primary_Language__c = language.Id;
        update contact;
        Test.stopTest();

        assertContactLanguageRecord(true, DEFAULT_FLUENCY, language.Id, existingContactLanguage.Id);
    }

    /*******************************************************************************************************
    * @description Tests that when the Primary Language is set on a Contact when a Contact is updated, a
    * corresponding Primary Language Contact Language record is created if one doesn't already exist. If a 
    * different value for default Fluency is set in the HEDA Settings, that value is used for the Fluency.
    ********************************************************************************************************/
    @isTest
    private static void setPrimaryLanguageWithDifferentFluencyValue() {
        String fluencyValue = 'Intermediate';
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Default_Contact_Language_Fluency__c = fluencyValue));
        
        setup(false); // Don't insert the Contact right away

        Test.startTest();
        contact.Primary_Language__c = language.Id;
        insert contact;
        Test.stopTest();

        assertContactLanguageRecord(true, fluencyValue, language.Id, null);
    }

    /*******************************************************************************************************
    * @description Tests that when the Primary Language is unset on a Contact, the corresponding Contact
    * Language record is updated to no longer be the Primary Language.
    ********************************************************************************************************/
    @isTest
    private static void unsetPrimaryLanguage() {
        setup(false); // Don't insert the Contact right away

        contact.Primary_Language__c = language.Id;
        insert contact;
        assertContactLanguageRecord(true, DEFAULT_FLUENCY, language.Id, null);

        System.assert(contactLanguage != null, 'Expected the contactLanguage variable to be set.');

        Test.startTest();
        contact.Primary_Language__c = null;
        update contact;
        Test.stopTest();

        // Assert that the Contact Language record is no longer the Primary Language.
        assertContactLanguageRecord(false, DEFAULT_FLUENCY, language.Id, contactLanguage.Id);
    }

    /*******************************************************************************************************
    * @description Tests that when the Primary Language is set on a Contact to a different value, the previous
    * Contact Language record is updated to no longer be the Primary Language and a new Contact Language record
    * is created for the new Primary Language.
    ********************************************************************************************************/
    @isTest
    private static void swapPrimaryLanguage() {
        setup(false); // Don't insert the Contact right away

        contact.Primary_Language__c = language.Id;
        insert contact;
        assertContactLanguageRecord(true, DEFAULT_FLUENCY, language.Id, null);

        System.assert(contactLanguage != null, 'Expected the contactLanguage variable to be set.');

        Language__c newLanguage = UTIL_UnitTestData_TEST.createLanguage('Spanish');

        Test.startTest();
        contact.Primary_Language__c = newLanguage.Id;
        update contact;
        Test.stopTest();

        // Assert that the old Contact Language record is no longer the Primary Language.
        assertContactLanguageRecord(false, DEFAULT_FLUENCY, language.Id, contactLanguage.Id);

        // Assert that there's a new Contact Language record for the new Primary Language.
        assertContactLanguageRecord(true, DEFAULT_FLUENCY, newLanguage.Id, null);
    }
}