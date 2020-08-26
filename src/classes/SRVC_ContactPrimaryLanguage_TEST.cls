/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group 
* @group-content ../../ApexDocContent/
* @description Test class for SRVC_ContactPrimaryLanguage
*/
@isTest
private class SRVC_ContactPrimaryLanguage_TEST {
    private static Id generateFakeLanguageId() {
        return UTIL_UnitTestData_Test.getFakeId(Language__c.SObjectType);
    }

    private static Id generateFakeContactId() {  
        return UTIL_UnitTestData_Test.getFakeId(Contact.SObjectType);
    }

    private static Id generateFakeContactLanguageId() {  
        return UTIL_UnitTestData_Test.getFakeId(Contact_Language__c.SObjectType);
    }

    // Tests getInstance()
    @isTest
    private static void getInstancePositive() {
        SRVC_ContactPrimaryLanguage srvcConPrimLangInstance = SRVC_ContactPrimaryLanguage.getInstance();
        System.assertEquals(SRVC_ContactPrimaryLanguage.instance, srvcConPrimLangInstance);
        System.assertNotEquals(NULL, srvcConPrimLangInstance);
 
        srvcConPrimLangInstance = SRVC_ContactPrimaryLanguage.getInstance();
        System.assertEquals(SRVC_ContactPrimaryLanguage.instance, srvcConPrimLangInstance);
    }

    @isTest 
    private static void getContactLanguagesToCreatePositive(){                                                            
        List<Contact> testContactsList = UTIL_UnitTestData_Test.getMultipleTestContacts(5);
        Language__c testEnglishLanguage = new Language__c(Id = SRVC_ContactPrimaryLanguage_TEST.generateFakeLanguageId(), 
                                                          Name='English');

        for (Contact con : testContactsList){
            con.Id = SRVC_ContactPrimaryLanguage_TEST.generateFakeContactId();
            con.Primary_Language__c = testEnglishLanguage.Id;
        }

        Test.startTest();
        List<Contact_Language__c> conLangsToInsertList = SRVC_ContactPrimaryLanguage.getInstance().getContactLanguagesToCreate(testContactsList);
        Test.stopTest();

        System.assertEquals(5, conLangsToInsertList.size());
    }

    @isTest 
    private static void getContactLanguagesToCreateNegative(){
        List<Contact> testContactsList = UTIL_UnitTestData_Test.getMultipleTestContacts(5);
        Language__c testEnglishLanguage = new Language__c(Id = SRVC_ContactPrimaryLanguage_TEST.generateFakeLanguageId(), 
                                                          Name='English');

        for (Contact con : testContactsList){
            con.Id = SRVC_ContactPrimaryLanguage_TEST.generateFakeContactId();
        }

        Test.startTest();
        List<Contact_Language__c> conLangsToInsertList = SRVC_ContactPrimaryLanguage.getInstance().getContactLanguagesToCreate(testContactsList);
        Test.stopTest();

        System.assertEquals(true, conLangsToInsertList.isEmpty());
    }

    @isTest 
    private static void getContactLanguagesToCreateNull(){
        List<Contact> testContactsList = UTIL_UnitTestData_Test.getMultipleTestContacts(5);
        Language__c testEnglishLanguage = new Language__c(Id = SRVC_ContactPrimaryLanguage_TEST.generateFakeLanguageId(), 
                                                          Name='English');

        for (Contact con : testContactsList){
            con.Id = SRVC_ContactPrimaryLanguage_TEST.generateFakeContactId();
            con.Primary_Language__c = null;
        }

        Test.startTest();
        List<Contact_Language__c> conLangsToInsertList = SRVC_ContactPrimaryLanguage.getInstance().getContactLanguagesToCreate(testContactsList);
        Test.stopTest();

        System.assertEquals(true, conLangsToInsertList.isEmpty());
    }

    @isTest 
    private static void getContactLanguagesToInsertNoUpdates(){
        Map<Id, Contact> newContactsById = new Map<Id, Contact>();
        Map<Id, Contact> oldContactsById = new Map<Id, Contact>();

        List<Contact> testContactsList = UTIL_UnitTestData_Test.getMultipleTestContacts(5);
        Language__c testEnglishLanguage = UTIL_UnitTestData_TEST.createLanguage('English');
        Language__c testFrenchLanguage = UTIL_UnitTestData_TEST.createLanguage('French');

        for (Contact con : testContactsList){
            String testConId = SRVC_ContactPrimaryLanguage_TEST.generateFakeContactId();

            Contact oldContact = con.clone(false);
            oldContact.Id = testConId;
            oldContact.Primary_Language__c = testFrenchLanguage.Id;            
            oldContactsById.put(testConId, oldContact);

            con.Id = testConId;
            con.Primary_Language__c = testEnglishLanguage.Id;
            newContactsById.put(testConId, con);
        }

        Test.startTest();
        SRVC_ContactPrimaryLanguage.ContactLanguageCategorization conLangsToInsertUpdate = SRVC_ContactPrimaryLanguage.getInstance().getContactLanguagesToCreateOrUpdate(newContactsById, oldContactsById);
        Test.stopTest();

        System.assertEquals(5, conLangsToInsertUpdate.getContactLanguagesToInsert().size(), 'There should be 5 new Contact Language records to create.'); 
        System.assertEquals(true, conLangsToInsertUpdate.getContactLanguagesToUpdate().isEmpty(), 'There should be no existing Contact Language records to update.'); 

        for (Contact_Language__c conLang : conLangsToInsertUpdate.getContactLanguagesToInsert()){
            System.assertEquals(testEnglishLanguage.Id, conLang.Language__c, 'Each new Contact Language to be created should correspond to the English language');
        }
    }

    @isTest 
    private static void getContactLanguagesToUpdateNoInserts(){        
        Map<Id, Contact> newContactsById = new Map<Id, Contact>();
        Map<Id, Contact> oldContactsById = new Map<Id, Contact>();

        List<Contact> testContactsList = UTIL_UnitTestData_Test.getMultipleTestContacts(5);
        Language__c testEnglishLanguage = UTIL_UnitTestData_TEST.createLanguage('English');

        for (Contact con : testContactsList){
            con.Primary_Language__c = testEnglishLanguage.Id;
        }

        insert testContactsList;

        for (Contact con : testContactsList){
            newContactsById.put(con.Id, con);

            Contact oldContact = con.clone(false);
            oldContact.Primary_Language__c = null;            
            oldContactsById.put(con.Id, oldContact);
        }

        Test.startTest();
        SRVC_ContactPrimaryLanguage.ContactLanguageCategorization conLangsToInsertUpdate = SRVC_ContactPrimaryLanguage.getInstance().getContactLanguagesToCreateOrUpdate(newContactsById, oldContactsById);
        Test.stopTest();

        System.assertEquals(true, conLangsToInsertUpdate.getContactLanguagesToInsert().isEmpty(), 'There should be no new Contact Language records to create.'); 
        System.assertEquals(5, conLangsToInsertUpdate.getContactLanguagesToUpdate().size(), 'There should be 5 existing Contact Language records to update.'); 

        for (Contact_Language__c conLang : conLangsToInsertUpdate.getContactLanguagesToUpdate()){
            System.assertEquals(testEnglishLanguage.Id, conLang.Language__c, 'Each existing Contact Language to be updated should correspond to the English language');
        }
    }

    @isTest 
    private static void getContactLanguagesToUpdateToNonPrimary(){        
        Map<Id, Contact> newContactsById = new Map<Id, Contact>();
        Map<Id, Contact> oldContactsById = new Map<Id, Contact>();

        List<Contact> testContactsList = UTIL_UnitTestData_Test.getMultipleTestContacts(5);
        Language__c testEnglishLanguage = UTIL_UnitTestData_TEST.createLanguage('English');

        for (Contact con : testContactsList){
            con.Primary_Language__c = testEnglishLanguage.Id;
        }

        insert testContactsList;

        for (Contact con : testContactsList){
            Contact oldContact = con.clone(false);
            oldContact.Id = con.Id;
            oldContact.Primary_Language__c = testEnglishLanguage.Id;            
            oldContactsById.put(con.Id, oldContact);

            con.Id = con.Id;
            con.Primary_Language__c = null;
            newContactsById.put(con.Id, con);
        }

        Test.startTest();
        SRVC_ContactPrimaryLanguage.ContactLanguageCategorization conLangsToInsertUpdate = SRVC_ContactPrimaryLanguage.getInstance().getContactLanguagesToCreateOrUpdate(newContactsById, oldContactsById);
        Test.stopTest();

        System.assertEquals(true, conLangsToInsertUpdate.getContactLanguagesToInsert().isEmpty(), 'There should be no new Contact Language records to create.'); 
        System.assertEquals(5, conLangsToInsertUpdate.getContactLanguagesToUpdate().size(), 'There should be 5 existing Contact Language records to update to non-primary.'); 

        for (Contact_Language__c conLang : conLangsToInsertUpdate.getContactLanguagesToUpdate()){
            System.assertEquals(false, conLang.Primary_Language__c, 'Each existing Contact Language should be updated to non-primary status.');
        }
    }
    

    // @isTest 
    // private static void getContactLanguagesToUpdateAsNonPrimaryPositive(){
    //     Language__c testEnglishLanguage = UTIL_UnitTestData_TEST.createLanguage('English');
    //     List<Contact> testContactsList = UTIL_UnitTestData_Test.getMultipleTestContacts(5);
    //     Set<Id> testContactIdsSet = new Set<Id>();

    //     for (Contact con : testContactsList){
    //         con.Primary_Language__c = testEnglishLanguage.Id;          
    //     }

    //     insert testContactsList;
    //     testContactIdsSet = new Map<Id, Contact>(testContactsList).keySet();

    //     Test.startTest();
    //     List<Contact_Language__c> conLangsToSetNonPrimary = SRVC_ContactPrimaryLanguage.getInstance().getContactLanguagesToUpdateAsNonPrimary(testContactIdsSet);
    //     Test.stopTest();

    //     System.assertEquals(5, conLangsToSetNonPrimary.size(), 'There should be 5 Contact Languages to be updated to non-primary status.');
    // }

    // @isTest 
    // private static void getContactLanguagesToUpdateAsNonPrimaryNegative(){
    //     Language__c testEnglishLanguage = UTIL_UnitTestData_TEST.createLanguage('English');
    //     List<Contact> testContactsList = UTIL_UnitTestData_Test.getMultipleTestContacts(5);
    //     Set<Id> testContactIdsSet = new Set<Id>();

    //     for (Contact con : testContactsList){
    //         con.Primary_Language__c = testEnglishLanguage.Id;          
    //     }

    //     insert testContactsList;
    //     testContactIdsSet = new Map<Id, Contact>(testContactsList).keySet();

    //     for (Contact con : testContactsList){
    //         con.Primary_Language__c = null;          
    //     }

    //     update testContactsList;

    //     Test.startTest();
    //     List<Contact_Language__c> conLangsToSetNonPrimary = SRVC_ContactPrimaryLanguage.getInstance().getContactLanguagesToUpdateAsNonPrimary(testContactIdsSet);
    //     Test.stopTest();

    //     System.assertEquals(true, conLangsToSetNonPrimary.isEmpty(), 'There should be no Contact Languages to be updated to non-primary status.');
    // }












    // @isTest 
    // private static void getContactLanguagesToUpdateAsNonPrimaryNegative(){
    //     Language__c testEnglishLanguage = UTIL_UnitTestData_TEST.createLanguage('English');
    //     List<Contact> testContactsList = UTIL_UnitTestData_Test.getMultipleTestContacts(5);
    //     Set<Id> testContactIdsSet = new Set<Id>();

    //     for (Contact con : testContactsList){
    //         con.Primary_Language__c = testEnglishLanguage.Id;          
    //     }

    //     insert testContactsList;
    //     testContactIdsSet = new Map<Id, Contact>(testContactsList).keySet();

    //     for (Contact con : testContactsList){
    //         con.Primary_Language__c = null;          
    //     }

    //     update testContactsList;

    //     Test.startTest();
    //     List<Contact_Language__c> conLangsToSetNonPrimary = SRVC_ContactPrimaryLanguage.getInstance().getContactLanguagesToUpdateAsNonPrimary(testContactIdsSet);
    //     Test.stopTest();

    //     System.assertEquals(true, conLangsToSetNonPrimary.isEmpty(), 'There should be no Contact Languages to be updated to non-primary status.');
    // }

    @isTest 
    private static void getContactLanguagesToUpdateAsNonPrimaryNegative(){
        SRVC_ContactPrimaryLanguage.instance = new STUB_hasNoContactLanguagesToUpdateAsNonPrimary();

        Set<Id> testContactIdsSet = new Set<Id>();

        Test.startTest();
        List<Contact_Language__c> conLangsToSetNonPrimary = SRVC_ContactPrimaryLanguage.getInstance().getContactLanguagesToUpdateAsNonPrimary(testContactIdsSet);
        Test.stopTest();

        System.assertEquals(true, conLangsToSetNonPrimary.isEmpty(), 'There should be no Contact Languages to be updated to non-primary status.');
    }  

    @isTest 
    private static void getContactLanguagesToUpdateAsNonPrimaryPositive(){
        SRVC_ContactPrimaryLanguage.instance = new STUB_hasContactLanguagesToUpdateAsNonPrimary();

        Set<Id> testContactIdsSet = new Set<Id>();

        Test.startTest();
        List<Contact_Language__c> conLangsToSetNonPrimary = SRVC_ContactPrimaryLanguage.getInstance().getContactLanguagesToUpdateAsNonPrimary(testContactIdsSet);
        Test.stopTest();

        System.assertEquals(5, conLangsToSetNonPrimary.size(), 'There should be 5 Contact Languages to be updated to non-primary status.');
    }                               

    @isTest 
    private static void getContactLanguagesToUpdateAsNonPrimaryEmpty(){
        Test.startTest();
        List<Contact_Language__c> conLangsToSetNonPrimary = SRVC_ContactPrimaryLanguage.getInstance().getContactLanguagesToUpdateAsNonPrimary(new Set<Id>());
        Test.stopTest();

        System.assertEquals(true, conLangsToSetNonPrimary.isEmpty(), 'There should be no Contact Languages to be updated to non-primary status.');
    }

    @isTest 
    private static void getDefaultFluencyFromSettingsPositive(){
        Hierarchy_Settings__c hs = UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                                                    (Default_Contact_Language_Fluency__c = 'Fluent'));

        Test.startTest();
        String fluencySetting = SRVC_ContactPrimaryLanguage.getInstance().getDefaultFluencyFromSettings();
        Test.stopTest();

        System.assertEquals('Fluent', fluencySetting, 'Default fluency setting should be "Fluent".');
    }

    @isTest 
    private static void getDefaultFluencyFromSettingsNull(){
        Hierarchy_Settings__c hs = UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                                                     (Default_Contact_Language_Fluency__c = null));

        Test.startTest();
        String fluencySetting = SRVC_ContactPrimaryLanguage.getInstance().getDefaultFluencyFromSettings();
        Test.stopTest();

        System.assertEquals(true, String.isBlank(fluencySetting), 'Default fluency setting should be null.');
    }

    @isTest 
    private static void getDefaultFluencyFromSettingsBlank(){
        Hierarchy_Settings__c hs = UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                                                     (Default_Contact_Language_Fluency__c = ''));

        Test.startTest();
        String fluencySetting = SRVC_ContactPrimaryLanguage.getInstance().getDefaultFluencyFromSettings();
        Test.stopTest();

        System.assertEquals(true, String.isBlank(fluencySetting), 'Default fluency setting should be blank.');
    }

    // @isTest 
    // private static void getPrimaryContactLanguagesToInsertNoUpdates(){
    //     Hierarchy_Settings__c hs = UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
    //                                                                                     (Default_Contact_Language_Fluency__c = null));

    //     List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
    //     Map<Id,Contact_Language__c> conLanguagesToInsertByConId = new Map<Id,Contact_Language__c>();
    //     Language__c testEnglishLanguage = new Language__c(Id = SRVC_ContactPrimaryLanguage_TEST.generateFakeLanguageId(),
    //                                                       Name = 'English');
    //     for (Contact con : testContactsList){
    //         String testConId = SRVC_ContactPrimaryLanguage_TEST.generateFakeContactId();
    //         con.Id = testConId;
    //         con.Primary_Language__c = testEnglishLanguage.Id;

    //         Contact_Language__c conLang = UTIL_UnitTestData_TEST.getContactLanguage(testEnglishLanguage, con, hs.Default_Contact_Language_Fluency__c);
    //         conLang.Primary_Language__c = true;
    //         conLanguagesToInsertByConId.put(testConId, conLang);
    //     }

    //     Test.startTest();
    //     SRVC_ContactPrimaryLanguage.ContactLanguageCategorization conLangCat = SRVC_ContactPrimaryLanguage.getInstance().getPrimaryContactLanguagesToInsertOrUpdate(conLanguagesToInsertByConId, new Map<Id, Id>());
    //     Test.stopTest();

    //     System.assertEquals(5, conLangCat.getContactLanguagesToInsert().size(), 'There should be 5 new Contact Language records to create.');
    //     System.assertEquals(true, conLangCat.getContactLanguagesToUpdate().isEmpty(), 'There should be no existing Contact Language records to update.');
    // }

    // @isTest 
    // private static void getPrimaryContactLanguagesToUpdateNoInserts(){
    //     Hierarchy_Settings__c hs = UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
    //                                                                                     (Default_Contact_Language_Fluency__c = null));

    //     List<Contact_Language__c> existingContactLanugages = new List<Contact_Language__c>();
    //     Map<Id, Contact_Language__c> conLanguagesToInsertByConId = new Map<Id, Contact_Language__c>();
    //     Map<Id, Id> languageIdToCheckForUpdateByContactId = new Map<Id, Id>();
    //     List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
    //     Language__c testEnglishLanguage = UTIL_UnitTestData_TEST.createLanguage('English');

    //     insert testContactsList;

    //     for (Contact con : testContactsList){
    //         Contact_Language__c conLang = new Contact_Language__c(Contact__c = con.Id,
    //                                                               Language__c = testEnglishLanguage.Id,
    //                                                               Primary_Language__c = false  
    //                                                              );
    //         existingContactLanugages.add(conLang);
    //     }

    //     insert existingContactLanugages;

    //     for (Contact_Language__c conLang : existingContactLanugages){
    //         conLanguagesToInsertByConId.put(conLang.Contact__c, conLang);
    //         languageIdToCheckForUpdateByContactId.put(conLang.Contact__c, conLang.Language__c);
    //     }

    //     Test.startTest();
    //     SRVC_ContactPrimaryLanguage.ContactLanguageCategorization conLangCat = SRVC_ContactPrimaryLanguage.getInstance().getPrimaryContactLanguagesToInsertOrUpdate(conLanguagesToInsertByConId, languageIdToCheckForUpdateByContactId);
    //     Test.stopTest();

    //     System.assertEquals(true, conLangCat.getContactLanguagesToInsert().isEmpty(), 'There should be no new Contact Language records to create.');
    //     System.assertEquals(5, conLangCat.getContactLanguagesToUpdate().size(), 'There should be 5 existing Contact Language records to update.');
    // }

    @isTest 
    private static void getPrimaryContactLanguagesInsertAndUpdateSTUB(){
        SRVC_ContactPrimaryLanguage.instance = new STUB_HasPrimaryContactLanguagesToInsertAndUpdate();

        Map<Id, Contact_Language__c> conLanguagesToInsertByConId = new Map<Id, Contact_Language__c>();
        Map<Id, Id> languageIdToCheckForUpdateByContactId = new Map<Id, Id>();

        Test.startTest();
        SRVC_ContactPrimaryLanguage.ContactLanguageCategorization conLangCat = SRVC_ContactPrimaryLanguage.getInstance().getPrimaryContactLanguagesToInsertOrUpdate(conLanguagesToInsertByConId, languageIdToCheckForUpdateByContactId);
        Test.stopTest();

        System.assertEquals(3, conLangCat.getContactLanguagesToInsert().size(), 'There should be 3 new Contact Language records to create.');
        System.assertEquals(2, conLangCat.getContactLanguagesToUpdate().size(), 'There should be 2 existing Contact Language records to update.');
    }

    @isTest 
    private static void getPrimaryContactLanguagesInsertNoUpdatesSTUB(){
        SRVC_ContactPrimaryLanguage.instance = new STUB_HasPrimaryContactLanguagesToInsert();
        
        Map<Id, Contact_Language__c> conLanguagesToInsertByConId = new Map<Id, Contact_Language__c>();
        Map<Id, Id> languageIdToCheckForUpdateByContactId = new Map<Id, Id>();

        Test.startTest();
        SRVC_ContactPrimaryLanguage.ContactLanguageCategorization conLangCat = SRVC_ContactPrimaryLanguage.getInstance().getPrimaryContactLanguagesToInsertOrUpdate(conLanguagesToInsertByConId, languageIdToCheckForUpdateByContactId);
        Test.stopTest();

        System.assertEquals(5, conLangCat.getContactLanguagesToInsert().size(), 'There should be 5 new Contact Language records to create.');
        System.assertEquals(true, conLangCat.getContactLanguagesToUpdate().isEmpty(), 'There should be no existing Contact Language records to update.');
    }

    @isTest 
    private static void getPrimaryContactLanguagesUpdateNoInsertsSTUB(){
        SRVC_ContactPrimaryLanguage.instance = new STUB_HasPrimaryContactLanguagesToUpdate();
        
        Map<Id, Contact_Language__c> conLanguagesToInsertByConId = new Map<Id, Contact_Language__c>();
        Map<Id, Id> languageIdToCheckForUpdateByContactId = new Map<Id, Id>();

        Test.startTest();
        SRVC_ContactPrimaryLanguage.ContactLanguageCategorization conLangCat = SRVC_ContactPrimaryLanguage.getInstance().getPrimaryContactLanguagesToInsertOrUpdate(conLanguagesToInsertByConId, languageIdToCheckForUpdateByContactId);
        Test.stopTest();

        System.assertEquals(true, conLangCat.getContactLanguagesToInsert().isEmpty(), 'There should be no new Contact Language records to create.');
        System.assertEquals(5, conLangCat.getContactLanguagesToUpdate().size(), 'There should be 5 existing Contact Language records to update.');
    }

    @isTest 
    private static void getPrimaryContactLanguagesNoInsertsNoUpdates(){
        Test.startTest();
        SRVC_ContactPrimaryLanguage.ContactLanguageCategorization conLangCat = SRVC_ContactPrimaryLanguage.getInstance().getPrimaryContactLanguagesToInsertOrUpdate(new Map<Id, Contact_Language__c>(), new Map<Id, Id>());
        Test.stopTest();

        System.assertEquals(true, conLangCat.getContactLanguagesToInsert().isEmpty(), 'There should be no new Contact Language records to create.');
        System.assertEquals(true, conLangCat.getContactLanguagesToUpdate().isEmpty(), 'There should be no existing Contact Language records to update.');
    }

    @isTest 
    private static void getPrimaryContactLanguagesInsertsAndUpdates(){
    }


    /**************************************************************************************************************************
    ****************************************************** STUBS **************************************************************
    **************************************************************************************************************************/
    private class STUB_HasPrimaryContactLanguagesToInsert extends SRVC_ContactPrimaryLanguage {
        @TestVisible
        protected override SRVC_ContactPrimaryLanguage.ContactLanguageCategorization getPrimaryContactLanguagesToInsertOrUpdate(Map<Id, Contact_Language__c> contactLanguagesToInsertByContactId,
                                                                                                                                Map<Id, Id> languageIdToCheckForUpdateByContactId){
            List<Contact_Language__c> contactLanguagesToInsertList = new List<Contact_Language__c>();
            List<Contact_Language__c> contactLanguagesToUpdateList = new List<Contact_Language__c>();
            
            for (Integer i = 0; i < 5; i++){
                Contact_Language__c conLang = new Contact_Language__c(Id = SRVC_ContactPrimaryLanguage_TEST.generateFakeContactLanguageId(),
                                                                      Contact__c = SRVC_ContactPrimaryLanguage_TEST.generateFakeContactId(),
                                                                      Language__c = SRVC_ContactPrimaryLanguage_TEST.generateFakeLanguageId(),
                                                                      Primary_Language__c = false
                                                                     );
                contactLanguagesToInsertList.add(conLang);
            }                                                                                                                       

            SRVC_ContactPrimaryLanguage.ContactLanguageCategorization conLangCat = new SRVC_ContactPrimaryLanguage.ContactLanguageCategorization(contactLanguagesToInsertList,
                                                                                                                                                    contactLanguagesToUpdateList);
            return conLangCat;
        }
    }

    private class STUB_HasPrimaryContactLanguagesToUpdate extends SRVC_ContactPrimaryLanguage {
        @TestVisible
        protected override SRVC_ContactPrimaryLanguage.ContactLanguageCategorization getPrimaryContactLanguagesToInsertOrUpdate(Map<Id, Contact_Language__c> contactLanguagesToInsertByContactId,
                                                                                                                                Map<Id, Id> languageIdToCheckForUpdateByContactId){
            
            List<Contact_Language__c> contactLanguagesToInsertList = new List<Contact_Language__c>();
            List<Contact_Language__c> contactLanguagesToUpdateList = new List<Contact_Language__c>();
            
            for (Integer i = 0; i < 5; i++){
                Contact_Language__c conLang = new Contact_Language__c(Id = SRVC_ContactPrimaryLanguage_TEST.generateFakeContactLanguageId(),
                                                                      Contact__c = SRVC_ContactPrimaryLanguage_TEST.generateFakeContactId(),
                                                                      Language__c = SRVC_ContactPrimaryLanguage_TEST.generateFakeLanguageId(),
                                                                      Primary_Language__c = false
                                                                     );
                contactLanguagesToUpdateList.add(conLang);
            }                                                                                                                         

            SRVC_ContactPrimaryLanguage.ContactLanguageCategorization conLangCat = new SRVC_ContactPrimaryLanguage.ContactLanguageCategorization(contactLanguagesToInsertList,
                                                                                                                                                    contactLanguagesToUpdateList);
            return conLangCat;
        }
    }

    private class STUB_HasPrimaryContactLanguagesToInsertAndUpdate extends SRVC_ContactPrimaryLanguage {
        @TestVisible
        protected override SRVC_ContactPrimaryLanguage.ContactLanguageCategorization getPrimaryContactLanguagesToInsertOrUpdate(Map<Id, Contact_Language__c> contactLanguagesToInsertByContactId,
                                                                                                                                Map<Id, Id> languageIdToCheckForUpdateByContactId){            
            List<Contact_Language__c> contactLanguagesToInsertList = new List<Contact_Language__c>();
            List<Contact_Language__c> contactLanguagesToUpdateList = new List<Contact_Language__c>();
            
            for (Integer i = 0; i < 5; i++){
                Contact_Language__c conLang = new Contact_Language__c(Id = SRVC_ContactPrimaryLanguage_TEST.generateFakeContactLanguageId(),
                                                                      Contact__c = SRVC_ContactPrimaryLanguage_TEST.generateFakeContactId(),
                                                                      Language__c = SRVC_ContactPrimaryLanguage_TEST.generateFakeLanguageId(),
                                                                      Primary_Language__c = false
                                                                     );
                if (Math.mod(i, 2) == 0){
                    contactLanguagesToInsertList.add(conLang);
                } else {
                    contactLanguagesToUpdateList.add(conLang);
                }
            }                                                                                                                         

            SRVC_ContactPrimaryLanguage.ContactLanguageCategorization conLangCat = new SRVC_ContactPrimaryLanguage.ContactLanguageCategorization(contactLanguagesToInsertList,
                                                                                                                                                    contactLanguagesToUpdateList);
            return conLangCat;
        }
    }

    private class STUB_hasContactLanguagesToUpdateAsNonPrimary extends SRVC_ContactPrimaryLanguage {
        @TestVisible 
        protected override List<Contact_Language__c> getContactLanguagesToUpdateAsNonPrimary(Set<Id> contactIdsToMarkAsNonPrimarySet){
            List<Contact_Language__c> contactLanguagesToUpdateList = new List<Contact_Language__c>();
            
            for (Integer i = 0; i < 5; i++){
                Contact_Language__c conLang = new Contact_Language__c(Id = SRVC_ContactPrimaryLanguage_TEST.generateFakeContactLanguageId(),
                                                                      Contact__c = SRVC_ContactPrimaryLanguage_TEST.generateFakeContactId(),
                                                                      Language__c = SRVC_ContactPrimaryLanguage_TEST.generateFakeLanguageId()
                                                                     );
                contactLanguagesToUpdateList.add(conLang);
            } 
            
            return contactLanguagesToUpdateList;
        }
    }

    private class STUB_hasNoContactLanguagesToUpdateAsNonPrimary extends SRVC_ContactPrimaryLanguage {
        @TestVisible 
        protected override List<Contact_Language__c> getContactLanguagesToUpdateAsNonPrimary(Set<Id> contactIdsToMarkAsNonPrimarySet){            
            return new List<Contact_Language__c>();
        }
    }
}
