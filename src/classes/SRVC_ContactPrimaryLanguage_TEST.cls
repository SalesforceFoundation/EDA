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

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * SRVC_ContactPrimaryLanguage class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        SRVC_ContactPrimaryLanguage srvcConPrimLangInstance = SRVC_ContactPrimaryLanguage.getInstance();
        System.assertEquals(SRVC_ContactPrimaryLanguage.instance, srvcConPrimLangInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, srvcConPrimLangInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * SRVC_ContactPrimaryLanguage class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        SRVC_ContactPrimaryLanguage srvcConPrimLangInstance1 = SRVC_ContactPrimaryLanguage.getInstance();
        SRVC_ContactPrimaryLanguage srvcConPrimLangInstance2 = SRVC_ContactPrimaryLanguage.getInstance();
 
        System.assertEquals(SRVC_ContactPrimaryLanguage.instance, srvcConPrimLangInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(srvcConPrimLangInstance1, srvcConPrimLangInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, srvcConPrimLangInstance1 != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getContactLanguagesToCreate method returns a list of contact language records 
    * to create when Contacts are inserted new values specified for Primary Language.
    ***************************************************************************************************************************/
    @isTest 
    private static void getContactLanguagesToCreatePositive(){                                                            
        List<Contact> testContactsList = UTIL_UnitTestData_Test.getMultipleTestContacts(5);
        Language__c testEnglishLanguage = new Language__c(Id = UTIL_UnitTestData_TEST.getFakeId(Language__c.SObjectType), 
                                                          Name='English');

        for (Contact con : testContactsList){
            con.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
            con.Primary_Language__c = testEnglishLanguage.Id;
        }

        Test.startTest();
        List<Contact_Language__c> conLangsToInsertList = SRVC_ContactPrimaryLanguage.getInstance().getContactLanguagesToCreate(testContactsList);
        Test.stopTest();

        System.assertEquals(5, conLangsToInsertList.size());
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getContactLanguagesToCreate method does not return a list of contact 
    * language records to create when contacts are inserted without a value specified for Primary Language.
    ***************************************************************************************************************************/
    @isTest 
    private static void getContactLanguagesToCreateNegative(){
        List<Contact> testContactsList = UTIL_UnitTestData_Test.getMultipleTestContacts(5);
        Language__c testEnglishLanguage = new Language__c(Id = UTIL_UnitTestData_TEST.getFakeId(Language__c.SObjectType), 
                                                          Name='English');

        for (Contact con : testContactsList){
            con.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
        }

        Test.startTest();
        List<Contact_Language__c> conLangsToInsertList = SRVC_ContactPrimaryLanguage.getInstance().getContactLanguagesToCreate(testContactsList);
        Test.stopTest();

        System.assertEquals(true, conLangsToInsertList.isEmpty());
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getContactLanguagesToCreate method does not return a list of contact 
    * language records to create when contacts are inserted with a null value specified for Primary Language.
    ***************************************************************************************************************************/
    @isTest 
    private static void getContactLanguagesToCreateNull(){
        List<Contact> testContactsList = UTIL_UnitTestData_Test.getMultipleTestContacts(5);
        Language__c testEnglishLanguage = new Language__c(Id = UTIL_UnitTestData_TEST.getFakeId(Language__c.SObjectType), 
                                                          Name='English');

        for (Contact con : testContactsList){
            con.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
            con.Primary_Language__c = null;
        }

        Test.startTest();
        List<Contact_Language__c> conLangsToInsertList = SRVC_ContactPrimaryLanguage.getInstance().getContactLanguagesToCreate(testContactsList);
        Test.stopTest();

        System.assertEquals(true, conLangsToInsertList.isEmpty());
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getContactLanguagesToCreateOrUpdate method returns a list of new contact 
    * languages to create when a contact is updated with a new Primary Language that has not been previously associated with the
    * contact.
    ***************************************************************************************************************************/
    @isTest 
    private static void getContactLanguagesToInsertNoUpdates(){
        SRVC_ContactPrimaryLanguage.instance = new STUB_HasContactLanguagesToInsert();

        Map<Id, Contact> newContactsById = new Map<Id, Contact>();
        Map<Id, Contact> oldContactsById = new Map<Id, Contact>();

        for (Integer i = 0; i < 5; i++){
            String testId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);

            Contact con = new Contact(Id = testId,
                                      LastName = 'Test' + i,
                                      Primary_Language__c = UTIL_UnitTestData_TEST.getFakeId(Language__c.SObjectType));
            
            Contact oldCon = con.clone(false);
            oldCon.Id = testId;
            oldCon.Primary_Language__c = UTIL_UnitTestData_TEST.getFakeId(Language__c.SObjectType);
            
            oldContactsById.put(testId, oldCon);
            newContactsById.put(testId, con);
        }

        Test.startTest();
        SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess conLangsToInsertUpdate = SRVC_ContactPrimaryLanguage.getInstance().getContactLanguagesToCreateOrUpdate(newContactsById, oldContactsById);
        Test.stopTest();

        System.assertEquals(5, conLangsToInsertUpdate.contactLanguagesToInsertList.size(), 'There should be 5 new Contact Language records to create.'); 
        System.assertEquals(true, conLangsToInsertUpdate.contactLanguagesToUpdateList.isEmpty(), 'There should be no existing Contact Language records to update.'); 
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getContactLanguagesToCreateOrUpdate method returns a list of existing contact 
    * languages to update when a contact is updated with a Primary Language that was previously associated with the contact.
    ***************************************************************************************************************************/
    @isTest 
    private static void getContactLanguagesToUpdateNoInserts(){    
        SRVC_ContactPrimaryLanguage.instance = new STUB_HasContactLanguagesToUpdate();
        
        Map<Id, Contact> newContactsById = new Map<Id, Contact>();
        Map<Id, Contact> oldContactsById = new Map<Id, Contact>();

        for (Integer i = 0; i < 5; i++){
            String testConId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
            String existingLangId = UTIL_UnitTestData_TEST.getFakeId(Language__c.SObjectType);
            
            Contact con = new Contact(Id = testConId,
                                      LastName = 'Test' + i,
                                      Primary_Language__c = existingLangId);

            Contact oldCon = con.clone(false);
            oldCon.Id = testConId;
            oldCon.Primary_Language__c = UTIL_UnitTestData_TEST.getFakeId(Language__c.SObjectType);

            Contact_Language__c conLang = new Contact_Language__c(Id = UTIL_UnitTestData_TEST.getFakeId(Contact_Language__c.SObjectType),
                                                                  Contact__c = testConId,
                                                                  Language__c = existingLangId,
                                                                  Primary_Language__c = false);

            oldContactsById.put(testConId, oldCon);
            newContactsById.put(testConId, con);
        }

        Test.startTest();
        SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess conLangsToInsertUpdate = SRVC_ContactPrimaryLanguage.getInstance().getContactLanguagesToCreateOrUpdate(newContactsById, oldContactsById);
        Test.stopTest();

        System.assertEquals(true, conLangsToInsertUpdate.contactLanguagesToInsertList.isEmpty(), 'There should be no new Contact Language records to create.'); 
        System.assertEquals(5, conLangsToInsertUpdate.contactLanguagesToUpdateList.size(), 'There should be 5 existing Contact Language records to update.'); 
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getContactLanguagesToUpdateAsNonPrimary method returns an empty list when 
    * a contact is not associated with contact language records set as primary.
    ***************************************************************************************************************************/
    @isTest 
    private static void getContactLanguagesToUpdateAsNonPrimaryNegative(){
        SRVC_ContactPrimaryLanguage.instance = new STUB_HasContactLanguagesToInsert();
        Set<Id> testContactIdsSet = new Set<Id>();

        for (Integer i = 0; i < 5; i++){
            String testConId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
            String testLangId = UTIL_UnitTestData_TEST.getFakeId(Language__c.SObjectType);

            Contact_Language__c conLang = new Contact_Language__c(Id = UTIL_UnitTestData_TEST.getFakeId(Contact_Language__c.SObjectType),
                                                                  Language__c = testLangId,
                                                                  Contact__c = testConId,
                                                                  Primary_Language__c = false);

            testContactIdsSet.add(testConId);
        }

        Test.startTest();
        List<Contact_Language__c> conLangsToSetNonPrimary = SRVC_ContactPrimaryLanguage.getInstance().getContactLanguagesToUpdateAsNonPrimary(testContactIdsSet);
        Test.stopTest();

        System.assertEquals(true, conLangsToSetNonPrimary.isEmpty(), 'There should be no Contact Languages to be updated to non-primary status.');
    }  

    /**************************************************************************************************************************
    * @description Test method to verify that the getContactLanguagesToUpdateAsNonPrimary method returns a list of contact
    * language records matching contacts that are associated with contact language records set as primary.
    ***************************************************************************************************************************/
    @isTest 
    private static void getContactLanguagesToUpdateAsNonPrimaryPositive(){
        SRVC_ContactPrimaryLanguage.instance = new STUB_HasContactLanguagesToUpdate();
        
        Set<Id> testContactIdsSet = new Set<Id>();

        for (Integer i = 0; i < 5; i++){
            String testConId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
            String testLangId = UTIL_UnitTestData_TEST.getFakeId(Language__c.SObjectType);

            Contact_Language__c conLang = new Contact_Language__c(Id = UTIL_UnitTestData_TEST.getFakeId(Contact_Language__c.SObjectType),
                                                                  Language__c = testLangId,
                                                                  Contact__c = testConId,
                                                                  Primary_Language__c = true);

            testContactIdsSet.add(testConId);
        }

        Test.startTest();
        List<Contact_Language__c> conLangsToSetNonPrimary = SRVC_ContactPrimaryLanguage.getInstance().getContactLanguagesToUpdateAsNonPrimary(testContactIdsSet);
        Test.stopTest();

        System.assertEquals(5, conLangsToSetNonPrimary.size(), 'There should be 5 Contact Languages to be updated to non-primary status.');
    }                               

    /**************************************************************************************************************************
    * @description Test method to verify that the getContactLanguagesToUpdateAsNonPrimary method returns an empty list of 
    * contact language records when an empty set of contact Ids is passed in as a parameter.
    ***************************************************************************************************************************/
    @isTest 
    private static void getContactLanguagesToUpdateAsNonPrimaryEmpty(){
        Test.startTest();
        List<Contact_Language__c> conLangsToSetNonPrimary = SRVC_ContactPrimaryLanguage.getInstance().getContactLanguagesToUpdateAsNonPrimary(new Set<Id>());
        Test.stopTest();

        System.assertEquals(true, conLangsToSetNonPrimary.isEmpty(), 'There should be no Contact Languages to be updated to non-primary status.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getDefaultFluencyFromSettings correctly returns the value set as the 
    * Default_Contact_Language_Fluency__c.
    ***************************************************************************************************************************/
    @isTest 
    private static void getDefaultFluencyFromSettingsPositive(){
        Hierarchy_Settings__c hs = UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                                                    (Default_Contact_Language_Fluency__c = 'Fluent'));

        Test.startTest();
        String fluencySetting = SRVC_ContactPrimaryLanguage.getInstance().getDefaultFluencyFromSettings();
        Test.stopTest();

        System.assertEquals('Fluent', fluencySetting, 'Default fluency setting should be "Fluent".');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getDefaultFluencyFromSettings correctly returns a blank value when 
    * the value of Default_Contact_Language_Fluency__c is set as null.
    ***************************************************************************************************************************/
    @isTest 
    private static void getDefaultFluencyFromSettingsNull(){
        Hierarchy_Settings__c hs = UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                                                     (Default_Contact_Language_Fluency__c = null));

        Test.startTest();
        String fluencySetting = SRVC_ContactPrimaryLanguage.getInstance().getDefaultFluencyFromSettings();
        Test.stopTest();

        System.assertEquals(true, String.isBlank(fluencySetting), 'Default fluency setting should be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getPrimaryContactLanguagesToInsertOrUpdate returns a list new Contact 
    * Languages to insert when a Contact is updated with a new primary language and a list of existing Contact Languages to 
    * update when a contact is updated with a language that was previously associated as a primary language.
    ***************************************************************************************************************************/
    @isTest 
    private static void getPrimaryContactLanguagesInsertAndUpdate(){
        SRVC_ContactPrimaryLanguage.instance = new STUB_HasPrimaryContactLanguagesToInsertAndUpdate();

        Map<Id, Contact_Language__c> conLanguagesToInsertByConId = new Map<Id, Contact_Language__c>();
        Map<Id, Id> languageIdToCheckForUpdateByContactId = new Map<Id, Id>();

        for (Integer i = 0; i < 5; i++){
            String testConId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
            String testLangId = UTIL_UnitTestData_TEST.getFakeId(Language__c.SObjectType);

            Contact_Language__c conLang = new Contact_Language__c(Id = UTIL_UnitTestData_TEST.getFakeId(Contact_Language__c.SObjectType),
                                                                  Language__c = testLangId,
                                                                  Contact__c = testConId,
                                                                  Primary_Language__c = true);

            conLanguagesToInsertByConId.put(testConId, conLang);

            if (Math.mod(i, 2) != 0){
                languageIdToCheckForUpdateByContactId.put(testConId, testLangId);
            }
        }

        Test.startTest();
        SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess conLangToProcess = SRVC_ContactPrimaryLanguage.getInstance().getPrimaryContactLanguagesToInsertOrUpdate(conLanguagesToInsertByConId, languageIdToCheckForUpdateByContactId);
        Test.stopTest();

        System.assertEquals(3, conLangToProcess.contactLanguagesToInsertList.size(), 'There should be 3 new Contact Language records to create.');
        System.assertEquals(2, conLangToProcess.contactLanguagesToUpdateList.size(), 'There should be 2 existing Contact Language records to update.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getPrimaryContactLanguagesToInsertOrUpdate returns a list new Contact 
    * Languages to insert when a Contact is updated with a new primary language and an empty list of existing Contact Languages to 
    * update when a contact is updated with a language that was not previously associated as a primary language.
    ***************************************************************************************************************************/
    @isTest 
    private static void getPrimaryContactLanguagesInsertNoUpdates(){
        SRVC_ContactPrimaryLanguage.instance = new STUB_HasContactLanguagesToInsert();

        Map<Id, Contact_Language__c> conLanguagesToInsertByConId = new Map<Id, Contact_Language__c>();
        Map<Id, Id> languageIdToCheckForUpdateByContactId = new Map<Id, Id>();

        for (Integer i = 0; i < 5; i++){
            String testConId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
            String testLangId = UTIL_UnitTestData_TEST.getFakeId(Language__c.SObjectType);

            Contact_Language__c conLang = new Contact_Language__c(Id = UTIL_UnitTestData_TEST.getFakeId(Contact_Language__c.SObjectType),
                                                                  Language__c = testLangId,
                                                                  Contact__c = testConId,
                                                                  Primary_Language__c = true);

            conLanguagesToInsertByConId.put(testConId, conLang);
        }

        Test.startTest();
        SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess conLangToProcess = SRVC_ContactPrimaryLanguage.getInstance().getPrimaryContactLanguagesToInsertOrUpdate(conLanguagesToInsertByConId, languageIdToCheckForUpdateByContactId);
        Test.stopTest();

        System.assertEquals(5, conLangToProcess.contactLanguagesToInsertList.size(), 'There should be 5 new Contact Language records to create.');
        System.assertEquals(true, conLangToProcess.contactLanguagesToUpdateList.isEmpty(), 'There should be no existing Contact Language records to update.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getPrimaryContactLanguagesToInsertOrUpdate returns an empty list of new Contact 
    * Languages to insert and a list of existing Contact Language records when a Contact is updated with primary languages that 
    * were previously associated with the Contact.
    ***************************************************************************************************************************/
    @isTest 
    private static void getPrimaryContactLanguagesUpdateNoInserts(){
        SRVC_ContactPrimaryLanguage.instance = new STUB_HasContactLanguagesToUpdate();
        
        Map<Id, Contact_Language__c> conLanguagesToInsertByConId = new Map<Id, Contact_Language__c>();
        Map<Id, Id> languageIdToCheckForUpdateByContactId = new Map<Id, Id>();

        for (Integer i = 0; i < 5; i++){
            String testConId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
            String testLangId = UTIL_UnitTestData_TEST.getFakeId(Language__c.SObjectType);

            Contact_Language__c conLang = new Contact_Language__c(Id = UTIL_UnitTestData_TEST.getFakeId(Contact_Language__c.SObjectType),
                                                                  Language__c = testLangId,
                                                                  Contact__c = testConId,
                                                                  Primary_Language__c = true);

            conLanguagesToInsertByConId.put(testConId, conLang);
            languageIdToCheckForUpdateByContactId.put(testConId, testLangId);
        }

        Test.startTest();
        SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess conLangToProcess = SRVC_ContactPrimaryLanguage.getInstance().getPrimaryContactLanguagesToInsertOrUpdate(conLanguagesToInsertByConId, languageIdToCheckForUpdateByContactId);
        Test.stopTest();

        System.assertEquals(true, conLangToProcess.contactLanguagesToInsertList.isEmpty(), 'There should be no new Contact Language records to create.');
        System.assertEquals(5, conLangToProcess.contactLanguagesToUpdateList.size(), 'There should be 5 existing Contact Language records to update.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getPrimaryContactLanguagesToInsertOrUpdate returns empty lists when a Contact
    * is updated with no primary language.
    ***************************************************************************************************************************/
    @isTest 
    private static void getPrimaryContactLanguagesNoInsertsNoUpdates(){
        Test.startTest();
        SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess conLangToProcess = SRVC_ContactPrimaryLanguage.getInstance().getPrimaryContactLanguagesToInsertOrUpdate(new Map<Id, Contact_Language__c>(), new Map<Id, Id>());
        Test.stopTest();

        System.assertEquals(true, conLangToProcess.contactLanguagesToInsertList.isEmpty(), 'There should be no new Contact Language records to create.');
        System.assertEquals(true, conLangToProcess.contactLanguagesToUpdateList.isEmpty(), 'There should be no existing Contact Language records to update.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the addContactLanguagesToUpdate method for the ContactLanguagesToProcess value
    * object appends a list of Contact Language records to the existing list.
    ***************************************************************************************************************************/
    @isTest 
    private static void addContactLanguagesToUpdatePositive(){
        List<Contact_Language__c> conLangsToInsertList = new List<Contact_Language__c>();
        List<Contact_Language__c> conLangsToUpdateList = new List<Contact_Language__c>();
        List<Contact_Language__c> additionalConLangsToUpdateList = new List<Contact_Language__c>();

        for (Integer i = 0; i< 5; i++){
            Contact_Language__c conLang = new Contact_Language__c(Id = UTIL_UnitTestData_TEST.getFakeId(Contact_Language__c.SObjectType),
                                                                  Contact__c = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                                                  Language__c = UTIL_UnitTestData_TEST.getFakeId(Language__c.SObjectType));

            

            Contact_Language__c addConLang = new Contact_Language__c(Id = UTIL_UnitTestData_TEST.getFakeId(Contact_Language__c.SObjectType),
                                                                  Contact__c = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                                                  Language__c = UTIL_UnitTestData_TEST.getFakeId(Language__c.SObjectType));

            conLangsToUpdateList.add(conLang);
            additionalConLangsToUpdateList.add(addConLang);
        }

        SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess conLangToProcess = new SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess(conLangsToInsertList, conLangsToUpdateList);
        
        Test.startTest();
        conLangToProcess.addContactLanguagesToUpdate(additionalConLangsToUpdateList);
        Test.stopTest();

        System.assertEquals(10, conLangToProcess.contactLanguagesToUpdateList.size(), 'List of Contact Language records to insert should increase to 10.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the addContactLanguagesToUpdate method for the ContactLanguagesToProcess value
    * object does not append and empty list to the existing list.
    ***************************************************************************************************************************/
    @isTest 
    private static void addContactLanguagesToUpdateNegative(){
        List<Contact_Language__c> conLangsToInsertList = new List<Contact_Language__c>();
        List<Contact_Language__c> conLangsToUpdateList = new List<Contact_Language__c>();
        List<Contact_Language__c> additionalConLangsToUpdateList = new List<Contact_Language__c>();

        for (Integer i = 0; i< 5; i++){
            Contact_Language__c conLang = new Contact_Language__c(Id = UTIL_UnitTestData_TEST.getFakeId(Contact_Language__c.SObjectType),
                                                                  Contact__c = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                                                  Language__c = UTIL_UnitTestData_TEST.getFakeId(Language__c.SObjectType));

            conLangsToUpdateList.add(conLang);
        }

        SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess conLangToProcess = new SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess(conLangsToInsertList, conLangsToUpdateList);
        
        Test.startTest();
        conLangToProcess.addContactLanguagesToUpdate(additionalConLangsToUpdateList);
        Test.stopTest();

        System.assertEquals(5, conLangToProcess.contactLanguagesToUpdateList.size(), 'List of Contact Language records to insert should remain at 5.');
    }
    
    /**************************************************************************************************************************
    ****************************************************** STUBS **************************************************************
    **************************************************************************************************************************/
    
    /************************************************************************************************************
    * @description Stub class to simulate the response from SRVC_ContactPrimaryLanguage with contact language 
    * records to be inserted and no existing records to update.
    *************************************************************************************************************/ 
    private class STUB_HasContactLanguagesToInsert extends SRVC_ContactPrimaryLanguage {
        @TestVisible
        public override SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess getContactLanguagesToCreateOrUpdate(Map<Id, Contact> newContactsById, Map<Id, Contact> oldContactsById){
            List<Contact_Language__c> contactLanguagesToInsertList = new List<Contact_Language__c>();
            List<Contact_Language__c> contactLanguagesToUpdateList = new List<Contact_Language__c>();

            for (Integer i = 0; i < 5; i++){
                Contact_Language__c conLang = new Contact_Language__c(Id = UTIL_UnitTestData_TEST.getFakeId(Contact_Language__c.SObjectType),
                                                                      Contact__c = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                                                      Language__c = UTIL_UnitTestData_TEST.getFakeId(Language__c.SObjectType),
                                                                      Primary_Language__c = false
                                                                     );
                contactLanguagesToInsertList.add(conLang);
            }      

            SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess conLangToProcess = new SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess(contactLanguagesToInsertList,
                                                                                                                                                    contactLanguagesToUpdateList);
            return conLangToProcess;
        }

        @TestVisible
        protected override SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess getPrimaryContactLanguagesToInsertOrUpdate(Map<Id, Contact_Language__c> contactLanguagesToInsertByContactId,
                                                                                                                                Map<Id, Id> languageIdToCheckForUpdateByContactId){
            List<Contact_Language__c> contactLanguagesToInsertList = new List<Contact_Language__c>();
            List<Contact_Language__c> contactLanguagesToUpdateList = new List<Contact_Language__c>();
            
            for (Integer i = 0; i < 5; i++){
                Contact_Language__c conLang = new Contact_Language__c(Id = UTIL_UnitTestData_TEST.getFakeId(Contact_Language__c.SObjectType),
                                                                      Contact__c = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                                                      Language__c = UTIL_UnitTestData_TEST.getFakeId(Language__c.SObjectType),
                                                                      Primary_Language__c = false
                                                                     );
                contactLanguagesToInsertList.add(conLang);
            }                                                                                                                       

            SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess conLangToProcess = new SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess(contactLanguagesToInsertList,
                                                                                                                                                    contactLanguagesToUpdateList);
            return conLangToProcess;
        }

        @TestVisible 
        protected override List<Contact_Language__c> getContactLanguagesToUpdateAsNonPrimary(Set<Id> contactIdsToMarkAsNonPrimarySet){            
            return new List<Contact_Language__c>();
        }
    }

    /************************************************************************************************************
    * @description Stub class to simulate the response from SRVC_ContactPrimaryLanguage with existing contact  
    * language records to be updated and no new records to be inserted.
    *************************************************************************************************************/ 
    private class STUB_HasContactLanguagesToUpdate extends SRVC_ContactPrimaryLanguage{
        @TestVisible
        public override List<Contact_Language__c> getContactLanguagesToCreate(List<Contact> contactsList){
            return new List<Contact_Language__c>();
        }

        @TestVisible
        public override SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess getContactLanguagesToCreateOrUpdate(Map<Id, Contact> newContactsById, Map<Id, Contact> oldContactsById){
            List<Contact_Language__c> contactLanguagesToInsertList = new List<Contact_Language__c>();
            List<Contact_Language__c> contactLanguagesToUpdateList = new List<Contact_Language__c>();

            for (Integer i = 0; i < 5; i++){
                Contact_Language__c conLang = new Contact_Language__c(Id = UTIL_UnitTestData_TEST.getFakeId(Contact_Language__c.SObjectType),
                                                                      Contact__c = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                                                      Language__c = UTIL_UnitTestData_TEST.getFakeId(Language__c.SObjectType),
                                                                      Primary_Language__c = false
                                                                     );
                contactLanguagesToUpdateList.add(conLang);
            }      

            SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess conLangToProcess = new SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess(contactLanguagesToInsertList,
                                                                                                                                                    contactLanguagesToUpdateList);
            return conLangToProcess;
        }

        @TestVisible
        protected override SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess getPrimaryContactLanguagesToInsertOrUpdate(Map<Id, Contact_Language__c> contactLanguagesToInsertByContactId,
                                                                                                                                Map<Id, Id> languageIdToCheckForUpdateByContactId){
            
            List<Contact_Language__c> contactLanguagesToInsertList = new List<Contact_Language__c>();
            List<Contact_Language__c> contactLanguagesToUpdateList = new List<Contact_Language__c>();
            
            for (Integer i = 0; i < 5; i++){
                Contact_Language__c conLang = new Contact_Language__c(Id = UTIL_UnitTestData_TEST.getFakeId(Contact_Language__c.SObjectType),
                                                                      Contact__c = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                                                      Language__c = UTIL_UnitTestData_TEST.getFakeId(Language__c.SObjectType),
                                                                      Primary_Language__c = false
                                                                     );
                contactLanguagesToUpdateList.add(conLang);
            }                                                                                                                         

            SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess conLangToProcess = new SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess(contactLanguagesToInsertList,
                                                                                                                                                    contactLanguagesToUpdateList);
            return conLangToProcess;
        }

        @TestVisible 
        protected override List<Contact_Language__c> getContactLanguagesToUpdateAsNonPrimary(Set<Id> contactIdsToMarkAsNonPrimarySet){
            List<Contact_Language__c> contactLanguagesToUpdateList = new List<Contact_Language__c>();
            
            for (Integer i = 0; i < 5; i++){
                Contact_Language__c conLang = new Contact_Language__c(Id = UTIL_UnitTestData_TEST.getFakeId(Contact_Language__c.SObjectType),
                                                                      Contact__c = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                                                      Language__c = UTIL_UnitTestData_TEST.getFakeId(Language__c.SObjectType)
                                                                     );
                contactLanguagesToUpdateList.add(conLang);
            } 
            
            return contactLanguagesToUpdateList;
        }
    }

    /************************************************************************************************************
    * @description Stub class to simulate the response from SRVC_ContactPrimaryLanguage with contact language 
    * records to be both inserted and updated
    *************************************************************************************************************/ 
    private class STUB_HasPrimaryContactLanguagesToInsertAndUpdate extends SRVC_ContactPrimaryLanguage {
        @TestVisible
        protected override SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess getPrimaryContactLanguagesToInsertOrUpdate(Map<Id, Contact_Language__c> contactLanguagesToInsertByContactId,
                                                                                                                                Map<Id, Id> languageIdToCheckForUpdateByContactId){            
            List<Contact_Language__c> contactLanguagesToInsertList = new List<Contact_Language__c>();
            List<Contact_Language__c> contactLanguagesToUpdateList = new List<Contact_Language__c>();
            
            for (Integer i = 0; i < 5; i++){
                Contact_Language__c conLang = new Contact_Language__c(Id = UTIL_UnitTestData_TEST.getFakeId(Contact_Language__c.SObjectType),
                                                                      Contact__c = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType),
                                                                      Language__c = UTIL_UnitTestData_TEST.getFakeId(Language__c.SObjectType),
                                                                      Primary_Language__c = false
                                                                     );
                if (Math.mod(i, 2) == 0){
                    contactLanguagesToInsertList.add(conLang);
                } else {
                    contactLanguagesToUpdateList.add(conLang);
                }
            }                                                                                                                         

            SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess conLangToProcess = new SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess(contactLanguagesToInsertList,
                                                                                                                                                    contactLanguagesToUpdateList);
            return conLangToProcess;
        }
    }
}
