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
    // private static void setup(Boolean insertContact) {
    //     language = UTIL_UnitTestData_TEST.createLanguage('English');

    //     contact = UTIL_UnitTestData_TEST.getContact();
    //     if (insertContact) {
    //         insert contact;
    //     }
    // }

    /*******************************************************************************************************
    * @description Verifies/asserts that the Contact Language record for the Language and Contact exists with
    * the expected values.
    * @param isPrimaryLanguage If true, the Primary Language checkbox is expected to be checked.
    * @param expectedFluency The expected value of the Contact Language's Fluency.
    * @param expectedLanguageId The expected value of the Contact Language's Language.
    * @param expectedContactLanguageId The expected value of the Contact Language's ID. May be null, in which
    * case the record was created by the process and did not already exist.
    ********************************************************************************************************/
    // private static void assertContactLanguageRecord(Boolean isPrimaryLanguage, String expectedFluency, 
    //                                                 Id expectedLanguageId, Id expectedContactLanguageId) {
    //     List<Contact_Language__c> queriedContactLanguages = [SELECT Id, Primary_Language__c, Fluency__c
    //         FROM Contact_Language__c
    //         WHERE Language__c = :expectedLanguageId 
    //             AND Contact__c = :contact.Id];

    //     System.assertEquals(1, queriedContactLanguages.size(), 'The expected Contact Language was not found.');

    //     contactLanguage = queriedContactLanguages[0];
    //     if (expectedContactLanguageId != null) {
    //         System.assertEquals(expectedContactLanguageId, contactLanguage.Id, 'The ID does not match the expected Contact Language ID.');
    //     }

    //     System.assertEquals(isPrimaryLanguage, contactLanguage.Primary_Language__c, 'The Primary Language value does not match the expected Primary Language value.');
    //     System.assertEquals(expectedFluency, contactLanguage.Fluency__c, 'The Fluency value does not match the expected Fluency value.');
    // }


    
    /**************************************************************************************************************************
    ****************************************************** FUNCTIONAL TESTS ***************************************************
    **************************************************************************************************************************/

    /*******************************************************************************************************
    * @description Test method to verify that insertion of a new Contact with a Primary Language specified
    * results in the creation of a Primary Contact Language corresponding to the specified language
    * and related to the Contact.
    ********************************************************************************************************/
    @isTest
    private static void insertContactWithPrimaryLanguage() {
        Language__c englishLanguage = UTIL_UnitTestData_TEST.createLanguage('English');

        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        
        for (Contact con : testContactsList){
            con.Primary_Language__c = englishLanguage.Id;
        }

        Test.startTest();
        insert testContactsList;
        Test.stopTest();

        List<Contact_Language__c> conLangAfterInsertList = [SELECT Id, 
                                                                   Primary_Language__c, 
                                                                   Fluency__c,
                                                                   Contact__c,
                                                                   Language__c
                                                            FROM Contact_Language__c
                                                            WHERE Contact__c IN :testContactsList];

        Map<Id, List<Contact_Language__c>> contactLanguagesListByContactId = UTIL_UnitTestData_TEST.mapContactLanguagesToContact(conLangAfterInsertList);

        for (Contact con : testContactsList){
            System.assertEquals(true, contactLanguagesListByContactId.containsKey(con.Id), 'Contact should be associated with Contact Language records.');
            System.assertEquals(1, contactLanguagesListByContactId.get(con.Id).size(), 'Contact should be associated with one Contact Language record.');            
            System.assertEquals(englishLanguage.Id, contactLanguagesListByContactId.get(con.Id)[0].Language__c, 'Contact Language record associated with Contact should be for the English Language.');
            System.assertEquals(englishLanguage.Id, con.Primary_Language__c, 'Contact\'s primary language should be English.');            
            System.assertEquals(con.Primary_Language__c, contactLanguagesListByContactId.get(con.Id)[0].Language__c, 'Primary language on Contact should match the language specified on Contact Language record.');
            System.assertEquals(true, contactLanguagesListByContactId.get(con.Id)[0].Primary_Language__c, 'English Contact Language record should be set as primary.');
            System.assertEquals(DEFAULT_FLUENCY, contactLanguagesListByContactId.get(con.Id)[0].Fluency__c, 'English Contact Language record fluency should match the default value.');
        }
    }

    /*******************************************************************************************************
    * @description Test method to verify that updating of a Contact to specify a Primary Language 
    * results in the creation of a Primary Contact Language corresponding to the language when one
    * does not already exist.
    ********************************************************************************************************/
    @isTest
    private static void updateContactToAddNewPrimaryLanguage() {
        Language__c englishLanguage = UTIL_UnitTestData_TEST.createLanguage('English');
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        insert testContactsList;
        
        for (Contact con : testContactsList){
            con.Primary_Language__c = englishLanguage.Id;
        }

        Test.startTest();
        update testContactsList;
        Test.stopTest();

        List<Contact_Language__c> conLangAfterInsertList = [SELECT Id, 
                                                                   Primary_Language__c, 
                                                                   Fluency__c,
                                                                   Contact__c,
                                                                   Language__c
                                                            FROM Contact_Language__c
                                                            WHERE Contact__c IN :testContactsList];

        Map<Id, List<Contact_Language__c>> contactLanguagesListByContactId = UTIL_UnitTestData_TEST.mapContactLanguagesToContact(conLangAfterInsertList);

        for (Contact con : testContactsList){
            System.assertEquals(true, contactLanguagesListByContactId.containsKey(con.Id), 'Contact should be associated with Contact Language records.');
            System.assertEquals(1, contactLanguagesListByContactId.get(con.Id).size(), 'Contact should be associated with one Contact Language record.');            
            System.assertEquals(englishLanguage.Id, contactLanguagesListByContactId.get(con.Id)[0].Language__c, 'Contact Language record associated with Contact should be for the English Language.');
            System.assertEquals(englishLanguage.Id, con.Primary_Language__c, 'Contact\'s primary language should be English.');            
            System.assertEquals(con.Primary_Language__c, contactLanguagesListByContactId.get(con.Id)[0].Language__c, 'Primary language on Contact should match the language specified on Contact Language record.');
            System.assertEquals(true, contactLanguagesListByContactId.get(con.Id)[0].Primary_Language__c, 'English Contact Language record should be set as primary.');
            System.assertEquals(DEFAULT_FLUENCY, contactLanguagesListByContactId.get(con.Id)[0].Fluency__c, 'English Contact Language record fluency should match the default value.');
        }
    }

     /*******************************************************************************************************
    * @description Test method to verify that updating of a Contact to change the specified Primary Language 
    * results in the creation of a new Primary Contact Language corresponding to the new language when one
    * does not already exist and removes the primary setting from the former contact languge record.
    ********************************************************************************************************/
    @isTest
    private static void updateContactToChangeToNewPrimaryLanguage() {
        Language__c englishLanguage = UTIL_UnitTestData_TEST.createLanguage('English');
        Language__c frenchLanguage = UTIL_UnitTestData_TEST.createLanguage('French');

        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        
        for (Contact con : testContactsList){
            con.Primary_Language__c = englishLanguage.Id;
        }

        insert testContactsList;
        
        for (Contact con : testContactsList){
            con.Primary_Language__c = frenchLanguage.Id;
        }

        Test.startTest();
        update testContactsList;
        Test.stopTest();

        List<Contact_Language__c> conLangAfterInsertList = [SELECT Id, 
                                                                   Primary_Language__c, 
                                                                   Fluency__c,
                                                                   Contact__c,
                                                                   Language__c
                                                            FROM Contact_Language__c
                                                            WHERE Contact__c IN :testContactsList];

        Map<Id, List<Contact_Language__c>> contactLanguagesListByContactId = UTIL_UnitTestData_TEST.mapContactLanguagesToContact(conLangAfterInsertList);

        for (Contact con : testContactsList){
            System.assertEquals(true, contactLanguagesListByContactId.containsKey(con.Id), 'Contact should be associated with Contact Language records.');
            System.assertEquals(2, contactLanguagesListByContactId.get(con.Id).size(), 'Contact should be associated with two Contact Language records.');            
            System.assertEquals(frenchLanguage.Id, con.Primary_Language__c, 'Contact\'s primary language should be French.');            

            for (Contact_Language__c conLang : contactLanguagesListByContactId.get(con.Id)){
                if (conLang.Language__c == frenchLanguage.Id){
                    System.assertEquals(true, conLang.Primary_Language__c, 'French Contact Language record should be set as primary.');
                    System.assertEquals(DEFAULT_FLUENCY, conLang.Fluency__c, 'French Contact Language record fluency should match the default value.');
                } else {
                    System.assertEquals(englishLanguage.Id, conLang.Language__c, 'Second contact language record should correspond to the English Language.');
                    System.assertEquals(false, conLang.Primary_Language__c, 'English Contact Language record should not be set as primary.');
                }
            }
        }
    }

    /*******************************************************************************************************
    * @description Test method to verify that updating of a Contact to specify a new Primary Language 
    * does not result in the creation of a new Primary Contact Language corresponding to the new language 
    * when one already exists, and sets the existing record as primary.  Additionally, the primary status on 
    * the former contact is cleard.
    ********************************************************************************************************/
    @isTest
    private static void updateContactToIncludeExistingPrimaryLanguage(){
        Language__c englishLanguage = UTIL_UnitTestData_TEST.createLanguage('English');
        Language__c frenchLanguage = UTIL_UnitTestData_TEST.createLanguage('French');

        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        List<Contact_Language__c> testExistingConLangs = new List<Contact_Language__c>();

        for (Contact con : testContactsList){
            con.Primary_Language__c = englishLanguage.Id;
        }

        insert testContactsList;

        for (Contact con : testContactsList){
            Contact_Language__c existingConLang = UTIL_UnitTestData_TEST.getContactLanguage(frenchLanguage, con, DEFAULT_FLUENCY);
            testExistingConLangs.add(existingConLang);
        }

        insert testExistingConLangs;

        for (Contact con : testContactsList){
            con.Primary_Language__c = frenchLanguage.Id;
        }

        Test.startTest();
        update testContactsList;
        Test.stopTest();

        List<Contact_Language__c> conLangAfterInsertList = [SELECT Id, 
                                                                   Primary_Language__c, 
                                                                   Fluency__c,
                                                                   Contact__c,
                                                                   Language__c
                                                            FROM Contact_Language__c
                                                            WHERE Contact__c IN :testContactsList];

        Map<Id, List<Contact_Language__c>> contactLanguagesListByContactId = UTIL_UnitTestData_TEST.mapContactLanguagesToContact(conLangAfterInsertList);

        for (Contact con : testContactsList){
            System.assertEquals(true, contactLanguagesListByContactId.containsKey(con.Id), 'Contact should be associated with Contact Language records.');
            System.assertEquals(2, contactLanguagesListByContactId.get(con.Id).size(), 'Contact should be associated with two Contact Language records.');            
            System.assertEquals(frenchLanguage.Id, con.Primary_Language__c, 'Contact\'s primary language should be French.');            
            
            for (Contact_Language__c conLang : contactLanguagesListByContactId.get(con.Id)){
                if (conLang.Language__c == frenchLanguage.Id){
                    System.assertEquals(true, conLang.Primary_Language__c, 'French Contact Language record should be set as primary.');
                    System.assertEquals(con.Primary_Language__c, conLang.Language__c, 'Primary language on Contact should match the language specified on Contact Language record.');
                } else {
                    System.assertEquals(englishLanguage.Id, conLang.Language__c, 'Second contact language record should correspond to the English Language.');
                    System.assertEquals(false, conLang.Primary_Language__c, 'English Contact Language record should not be set as primary.');
                }
            }
        }
    }

    /*******************************************************************************************************
    * @description Test method to ensure that new contact language records are creaded with a fluency level
    * specified by the default Fluency value in EDA settings when available.
    ********************************************************************************************************/
    @isTest
    private static void setPrimaryLanguageWithDifferentFluencyValue() {
        String fluencyValue = 'Intermediate';
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(
                                                        Default_Contact_Language_Fluency__c = fluencyValue));
        
        Language__c englishLanguage = UTIL_UnitTestData_TEST.createLanguage('English');
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);

        for (Contact con : testContactsList){
            con.Primary_Language__c = englishLanguage.Id;
        }

        Test.startTest();
        insert testContactsList;
        Test.stopTest();

        List<Contact_Language__c> conLangAfterInsertList = [SELECT Id, 
                                                                   Primary_Language__c, 
                                                                   Fluency__c,
                                                                   Contact__c,
                                                                   Language__c
                                                            FROM Contact_Language__c
                                                            WHERE Contact__c IN :testContactsList];

        Map<Id, List<Contact_Language__c>> contactLanguagesListByContactId = UTIL_UnitTestData_TEST.mapContactLanguagesToContact(conLangAfterInsertList);

        for (Contact con : testContactsList){
            System.assertEquals(true, contactLanguagesListByContactId.containsKey(con.Id), 'Contact should be associated with Contact Language records.');
            System.assertEquals(1, contactLanguagesListByContactId.get(con.Id).size(), 'Contact should be associated with two Contact Language records.');            
            System.assertEquals(englishLanguage.Id, contactLanguagesListByContactId.get(con.Id)[0].Language__c, 'Contact Language record should be associated with the English language.');
            System.assertEquals(fluencyValue, contactLanguagesListByContactId.get(con.Id)[0].Fluency__c, 'Contact Language fluency level for English should be Intermediate.');
            System.assertEquals(englishLanguage.Id, con.Primary_Language__c, 'Contact\'s primary language should be English.');            
        }
    }

    /*******************************************************************************************************
    * @description Test method to ensure that when the Primary Language is removed from a Contact, the
    * the primary setting on the corresponding contact language record is cleared. 
    ********************************************************************************************************/
    @isTest
    private static void updateContactToRemovePrimaryLanguage() {
        Language__c englishLanguage = UTIL_UnitTestData_TEST.createLanguage('English');
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        
        for (Contact con : testContactsList){
            con.Primary_Language__c = englishLanguage.Id;
        }

        insert testContactsList;

        for (Contact con : testContactsList){
            con.Primary_Language__c = null;
        }

        Test.startTest();
        update testContactsList;
        Test.stopTest();

        List<Contact_Language__c> conLangAfterInsertList = [SELECT Id, 
                                                                   Primary_Language__c, 
                                                                   Fluency__c,
                                                                   Contact__c,
                                                                   Language__c
                                                            FROM Contact_Language__c
                                                            WHERE Contact__c IN :testContactsList];

        Map<Id, List<Contact_Language__c>> contactLanguagesListByContactId = UTIL_UnitTestData_TEST.mapContactLanguagesToContact(conLangAfterInsertList);

        for (Contact con : testContactsList){
            System.assertEquals(true, contactLanguagesListByContactId.containsKey(con.Id), 'Contact should be associated with Contact Language records.');
            System.assertEquals(1, contactLanguagesListByContactId.get(con.Id).size(), 'Contact should be associated with one Contact Language record.');            
            System.assertEquals(englishLanguage.Id, contactLanguagesListByContactId.get(con.Id)[0].Language__c, 'Contact Language record associated with Contact should be for the English Language.');
            System.assertEquals(null, con.Primary_Language__c, 'Contact\'s primary language should be blank.');            
            System.assertEquals(false, contactLanguagesListByContactId.get(con.Id)[0].Primary_Language__c, 'English Contact Language record should be set as primary.');
            System.assertEquals(DEFAULT_FLUENCY, contactLanguagesListByContactId.get(con.Id)[0].Fluency__c, 'English Contact Language record fluency should match the default value.');
        }
    }

    /*******************************************************************************************************
    * @description Test method to verify that when the Primary Language on a Contact is changed, the Contact
    * Language record associated with the former language is updated to no longer be set as the Primary 
    * Language and a new Contact Language record is created for the new Primary Language.
    ********************************************************************************************************/
    @isTest
    private static void swapPrimaryLanguage() {
        // setup(false); // Don't insert the Contact right away

        // contact.Primary_Language__c = language.Id;
        // insert contact;
        // assertContactLanguageRecord(true, DEFAULT_FLUENCY, language.Id, null);

        // System.assert(contactLanguage != null, 'Expected the contactLanguage variable to be set.');

        // Language__c newLanguage = UTIL_UnitTestData_TEST.createLanguage('Spanish');

        // Test.startTest();
        // contact.Primary_Language__c = newLanguage.Id;
        // update contact;
        // Test.stopTest();

        // // Assert that the old Contact Language record is no longer the Primary Language.
        // assertContactLanguageRecord(false, DEFAULT_FLUENCY, language.Id, contactLanguage.Id);

        // // Assert that there's a new Contact Language record for the new Primary Language.
        // assertContactLanguageRecord(true, DEFAULT_FLUENCY, newLanguage.Id, null);
    }
}