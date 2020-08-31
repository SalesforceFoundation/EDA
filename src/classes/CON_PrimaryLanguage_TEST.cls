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

    private static final String DEFAULT_FLUENCY = Label.stgFluent;

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
            System.assertEquals(false, contactLanguagesListByContactId.get(con.Id)[0].Primary_Language__c, 'English Contact Language record should not be set as primary.');
            System.assertEquals(DEFAULT_FLUENCY, contactLanguagesListByContactId.get(con.Id)[0].Fluency__c, 'English Contact Language record fluency should match the default value.');
        }
    }

    /**************************************************************************************************************************
    ****************************************************** UNIT TESTS *********************************************************
    **************************************************************************************************************************/

    /************************************************************************************************************
    * @description Test method to verify that isUpdateRecursion returns true when either or both recursion flags
    * CON_PrimaryLanguage_TDTM and CLAN_PrimaryLanguage_TDTM are set.
    *************************************************************************************************************/ 
    @isTest 
    private static void isUpdateRecursionTrue(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM, true);
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CLAN_PrimaryLanguage_TDTM, false);

        CON_PrimaryLanguage_TDTM conPriLangTdtm = new CON_PrimaryLanguage_TDTM();

        Test.startTest();
        System.assertEquals(true, conPriLangTdtm.isUpdateRecursion(), 'Update recursion status should be true.');
        Test.stopTest();
    }

    /************************************************************************************************************
    * @description Test method to verify that isUpdateRecursion returns when both recursion flags
    * CON_PrimaryLanguage_TDTM and CLAN_PrimaryLanguage_TDTM are unset.
    *************************************************************************************************************/ 
    @isTest 
    private static void isUpdateRecursionFalse(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM, false);
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CLAN_PrimaryLanguage_TDTM, false);

        CON_PrimaryLanguage_TDTM conPriLangTdtm = new CON_PrimaryLanguage_TDTM();

        Test.startTest();
        System.assertEquals(false, conPriLangTdtm.isUpdateRecursion(), 'Update recursion status should be false.');
        Test.stopTest();
    }

    /************************************************************************************************************
    * @description Test method to verify that unsetUpdateRecursion properly updates the status for the 
    * CON_PrimaryLanguage_After_Update recursion flag to false.
    *************************************************************************************************************/ 
    @isTest 
    private static void unsetUpdateRecursionTrue(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM, true);

        CON_PrimaryLanguage_TDTM conPriLangTdtm = new CON_PrimaryLanguage_TDTM();

        Test.startTest();
        conPriLangTdtm.unsetUpdateRecursion();
        Test.stopTest();

        System.assertEquals(false, TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM), 'Update recursion flag should be cleared.');
    }

    /************************************************************************************************************
    * @description Test method to verify that unsetUpdateRecursion properly updates the status for the 
    * CON_PrimaryLanguage_After_Update recursion flag to true.
    *************************************************************************************************************/ 
    @isTest 
    private static void setUpdateRecursionTrue(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM, false);

        CON_PrimaryLanguage_TDTM conPriLangTdtm = new CON_PrimaryLanguage_TDTM();

        Test.startTest();
        conPriLangTdtm.setUpdateRecursion();
        Test.stopTest();

        System.assertEquals(true, TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM), 'Update recursion flag should be set.');
    }

    /************************************************************************************************************
    * @description Test method to verify that isInsertRecursion returns true when either or both recursion flags
    * CON_PrimaryLanguage_TDTM and CLAN_PrimaryLanguage_TDTM are set.
    *************************************************************************************************************/ 
    @isTest 
    private static void isInsertRecursionTrue(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM, true);
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CLAN_PrimaryLanguage_TDTM, false);

        CON_PrimaryLanguage_TDTM conPriLangTdtm = new CON_PrimaryLanguage_TDTM();

        Test.startTest();
        System.assertEquals(true, conPriLangTdtm.isInsertRecursion(), 'Insert recursion status should be true.');
        Test.stopTest();
    }

    /************************************************************************************************************
    * @description Test method to verify that isInsertRecursion returns false when both recursion flags
    * CON_PrimaryLanguage_TDTM and CLAN_PrimaryLanguage_TDTM are unset.
    *************************************************************************************************************/ 
    @isTest 
    private static void isInsertRecursionFalse(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM, false);
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CLAN_PrimaryLanguage_TDTM, false);

        CON_PrimaryLanguage_TDTM conPriLangTdtm = new CON_PrimaryLanguage_TDTM();

        Test.startTest();
        System.assertEquals(false, conPriLangTdtm.isInsertRecursion(), 'Insert recursion status should be false.');
        Test.stopTest();
    }

    /************************************************************************************************************
    * @description Test method to verify that unsetInsertRecursion correctly updates the status of the 
    * CON_PrimaryLanguage_TDTM recursion flag to false.
    *************************************************************************************************************/ 
    @isTest 
    private static void unsetInsertRecursionTrue(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM, true);

        CON_PrimaryLanguage_TDTM conPriLangTdtm = new CON_PrimaryLanguage_TDTM();

        Test.startTest();
        conPriLangTdtm.unsetInsertRecursion();
        Test.stopTest();

        System.assertEquals(false, TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM), 'Insert recursion flag should be cleared.');
    }

    /************************************************************************************************************
    * @description Test method to verify that setInsertRecursion correctly updates the status of the 
    * CON_PrimaryLanguage_TDTM recursion flag to true.
    *************************************************************************************************************/ 
    @isTest 
    private static void setInsertRecursionTrue(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM, false);

        CON_PrimaryLanguage_TDTM conPriLangTdtm = new CON_PrimaryLanguage_TDTM();

        Test.startTest();
        conPriLangTdtm.setInsertRecursion();
        Test.stopTest();

        System.assertEquals(true, TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM), 'Insert recursion flag should be set.');
    }

    /************************************************************************************************************
    * @description Test method to verify that getInstance correctly returns an existing instance of 
    * SRVC_ContactPrimaryLanguage when one already exists.
    *************************************************************************************************************/ 
    @isTest 
    private static void locateContactPrimaryLanguageServiceExisting(){
        SRVC_ContactPrimaryLanguage srvcConPrimaryLangInstance = SRVC_ContactPrimaryLanguage.getInstance();
        System.assertEquals(SRVC_ContactPrimaryLanguage.instance, srvcConPrimaryLangInstance);
        System.assertNotEquals(NULL, srvcConPrimaryLangInstance);

        srvcConPrimaryLangInstance = SRVC_ContactPrimaryLanguage.getInstance();
        System.assertEquals(SRVC_ContactPrimaryLanguage.instance, srvcConPrimaryLangInstance);
    }

    /************************************************************************************************************
    * @description Test method to verify that getInstance correctly returns a new instance of 
    * SRVC_ContactPrimaryLanguage when one does not exist.
    *************************************************************************************************************/ 
    @isTest 
    private static void locateContactPrimaryLanguageServiceNew(){
        SRVC_ContactPrimaryLanguage srvcConPrimaryLangInstance = SRVC_ContactPrimaryLanguage.getInstance();
        System.assertEquals(SRVC_ContactPrimaryLanguage.instance, srvcConPrimaryLangInstance);
        System.assertNotEquals(NULL, srvcConPrimaryLangInstance);

        srvcConPrimaryLangInstance = SRVC_ContactPrimaryLanguage.getInstance();
        System.assertEquals(SRVC_ContactPrimaryLanguage.instance, srvcConPrimaryLangInstance);
    }

    /************************************************************************************************************
    * @description Test method to verify that handleAfterUpdate updates existing contact language records to 
    * primary or creates new contact language records for languages updated to primary and not previously 
    * associated with a contact.
    *************************************************************************************************************/ 
    // @isTest 
    // private static void handleAfterUpdatePositive(){
    //     List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
    //     List<Contact> oldTestContactsList = new List<Contact>();
      
    //     Language__c englishLanguage = new Language__c(Id = UTIL_UnitTestData_TEST.getFakeId(Language__c.sObjectType),
    //                                                   Name = 'English'
    //                                                  );
    //     Language__c frenchLanguage = new Language__c(Id = UTIL_UnitTestData_TEST.getFakeId(Language__c.sObjectType),
    //                                                  Name = 'French'
    //                                                 );

    //     // Language__c englishLanguage = UTIL_UnitTestData_TEST.createLanguage('English');
    //     // Language__c frenchLanguage = UTIL_UnitTestData_TEST.createLanguage('French');

    //     for (Contact con : testContactsList){
    //         String testId = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);
    //         System.debug('MK DEBUG: testId: '  + testId);
    //         con.Id = testId;
    //         con.Primary_Language__c = frenchLanguage.Id;

    //         Contact oldCon = con.clone(false);
    //         oldCon.Id = con.Id;
    //         oldCon.Primary_Language__c = englishLanguage.Id;
    //         oldTestContactsList.add(oldCon);
    //     }
        
    //     Test.startTest();
    //     CON_PrimaryLanguage_TDTM conPrimaryLangTDTM = new CON_PrimaryLanguage_TDTM();
    //     conPrimaryLangTDTM.handleAfterUpdate((List<SObject>)testContactsList, (List<SObject>)oldTestContactsList);
    //     Test.stopTest();

    //     List<Contact_Language__c> conLangResults = [SELECT Id, 
    //                                                        Primary_Language__c, 
    //                                                        Fluency__c,
    //                                                        Contact__c,
    //                                                        Language__c
    //                                                 FROM Contact_Language__c
    //                                                 WHERE Contact__c IN :testContactsList];

    //     Map<Id, List<Contact_Language__c>> contactLanguagesListByContactId = UTIL_UnitTestData_TEST.mapContactLanguagesToContact(conLangResults);

    //     for (Contact con : testContactsList){
    //         System.assertEquals(true, contactLanguagesListByContactId.containsKey(con.Id), 'Contact should be associated with Contact Language records.');
    //         System.assertEquals(2, contactLanguagesListByContactId.get(con.Id).size(), 'Contact should be associated with two Contact Language records.');            
    //         System.assertEquals(frenchLanguage.Id, con.Primary_Language__c, 'Contact\'s primary language should be French.');            

    //         for (Contact_Language__c conLang : contactLanguagesListByContactId.get(con.Id)){
    //             if (conLang.Language__c == frenchLanguage.Id){
    //                 System.assertEquals(true, conLang.Primary_Language__c, 'French Contact Language record should be set as primary.');
    //                 System.assertEquals(DEFAULT_FLUENCY, conLang.Fluency__c, 'French Contact Language record fluency should match the default value.');
    //             } else {
    //                 System.assertEquals(englishLanguage.Id, conLang.Language__c, 'Second contact language record should correspond to the English Language.');
    //                 System.assertEquals(false, conLang.Primary_Language__c, 'English Contact Language record should not be set as primary.');
    //             }
    //         }
    //     }        
    // }

    /************************************************************************************************************
    * @description Test method to verify that handleAfterUpdate does not update existing contact language records  
    * to primary when none are previously associated with a contact.
    *************************************************************************************************************/ 
    @isTest 
    private static void handleAfterUpdateNegative(){
        
    }

    /************************************************************************************************************
    * @description Test method to verify that handleAfterInsert creates contact language records for newly 
    * inserted contact records with associated primary languages.   
    *************************************************************************************************************/ 
    @isTest 
    private static void handleAfterInsertWithPrimaryLanguage(){
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);      
        Language__c englishLanguage = UTIL_UnitTestData_TEST.createLanguage('English');

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM, false);

        for (Contact con : testContactsList){
            con.Primary_Language__c = englishLanguage.Id;
        }

        insert testContactsList; // increases expected count for conLangResultsList by 5

        Test.startTest();
        CON_PrimaryLanguage_TDTM conPrimaryLangTDTM = new CON_PrimaryLanguage_TDTM();
        conPrimaryLangTDTM.handleAfterInsert((List<SObject>)testContactsList);
		Test.stopTest();
        
        List<Contact_Language__c> conLangResultsList = [SELECT Id,
                                                               Contact__c,
                                                               Language__c,
                                                               Primary_Language__c,
                                                               Fluency__c
                                                        FROM Contact_Language__c
                                                        WHERE Contact__c IN :testContactsList
                                                        ];

        System.assertEquals(5, conLangResultsList.size() - 5, 'Each contact record should be associated with 1 new contact language records.');
        System.assertEquals(false, TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM), 'Recursion flag should be unset.');

        for (Contact_Language__c conLang : conLangResultsList){
            System.assertEquals(englishLanguage.Id, conLang.Language__c, 'Each new contact language record should be associated with the English language.');
            System.assertEquals(true, conLang.Primary_Language__c, 'Each new contact language record should be marked as primary.');
            System.assertEquals(UTIL_CustomSettingsFacade.getSettings().Default_Contact_Language_Fluency__c, conLang.Fluency__c, 'Each new contact language record should be associated with the default fluency value.');
        }
    }

    /************************************************************************************************************
    * @description Test method to verify that handleAfterInsert does not create contact language records for newly 
    * inserted contact records when no primary language is specified.   
    *************************************************************************************************************/ 
    @isTest 
    private static void handleAfterInsertWithoutPrimaryLanguage(){
        SRVC_ContactPrimarylanguage.instance = new STUB_HasNoContactLanguagesToCreate();

        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);  
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM, false);

        for (Contact con : testContactsList){
            con.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
            con.Primary_Language__c = null;
        }

        Test.startTest();
        CON_PrimaryLanguage_TDTM conPrimaryLangTDTM = new CON_PrimaryLanguage_TDTM();
        conPrimaryLangTDTM.handleAfterInsert((List<SObject>)testContactsList);
		Test.stopTest();
        
        List<Contact_Language__c> conLangResultsList = [SELECT Id,
                                                               Contact__c,
                                                               Language__c,
                                                               Primary_Language__c,
                                                               Fluency__c
                                                        FROM Contact_Language__c
                                                        WHERE Contact__c IN :testContactsList
                                                        ];

        System.assertEquals(true, conLangResultsList.isEmpty(), 'There should be no contact language records created for contacts inserted without a primary language.');
        System.assertEquals(false, TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM), 'Recursion flag should be remain unset.');

    }

    /************************************************************************************************************
    * @description Test method to verify that handleAfterInsert does not create contact language records for newly 
    * inserted contact records when executed in a recursion context.   
    *************************************************************************************************************/ 
    @isTest 
    private static void handleAfterInsertRecursion(){
        SRVC_ContactPrimaryLanguage.instance = new STUB_HasNoContactLanguagesToCreate();

        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);   
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM, true);

        for (Contact con : testContactsList){
            con.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
            con.Primary_Language__c = null;
        }

        Test.startTest();
        CON_PrimaryLanguage_TDTM conPrimaryLangTDTM = new CON_PrimaryLanguage_TDTM();
        conPrimaryLangTDTM.handleAfterInsert((List<SObject>)testContactsList);
		Test.stopTest();
        
        List<Contact_Language__c> conLangResultsList = [SELECT Id,
                                                               Contact__c,
                                                               Language__c,
                                                               Primary_Language__c,
                                                               Fluency__c
                                                        FROM Contact_Language__c
                                                        WHERE Contact__c IN :testContactsList
                                                        ];

        System.assertEquals(true, conLangResultsList.isEmpty(), 'There should be no contact language records created for contacts inserted without a primary language.');
        System.assertEquals(true, TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM), 'Recursion flag should remain set.');
    }

    /************************************************************************************************************
    * @description Test method to verify that the run method creates Contact Language records for newly inserted
    * Contacts with associated Primary Languages.
    *************************************************************************************************************/ 
    @isTest 
    private static void runAfterInsertPositive(){
        
        List<Contact> newContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        List<SObject> oldList = new List<SObject>();

        Language__c englishLanguage = UTIL_UnitTestData_TEST.createLanguage('English');
        TDTM_Runnable.Action triggerAction = TDTM_Runnable.Action.AfterInsert;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Contact;
        
        for (Contact con : newContactsList){
            con.Primary_Language__c = englishLanguage.Id;
        }
        
        insert newContactsList;

        Test.startTest();
        CON_PrimaryLanguage_TDTM conPrimaryLangTDTM = new CON_PrimaryLanguage_TDTM();
        conPrimaryLangTDTM.run((List<SObject>)newContactsList, oldList, triggerAction, objResult);
        Test.stopTest();

        List<Contact_Language__c> conLanguageResultsList = [SELECT Id,
                                                                   Contact__c,
                                                                   Language__c,
                                                                   Primary_Language__c,
                                                                   Fluency__c
                                                            FROM Contact_Language__c
                                                            WHERE Contact__c IN :newContactsList];

        System.assertEquals(5, conLanguageResultsList.size() - 5, 'There should 1 new contact language record created for each new contact.');

        for (Contact_Language__c conLang : conLanguageResultsList){
            System.assertEquals(englishLanguage.Id, conLang.Language__c, 'Each contact language record should be associated with the English language.');
            System.assertEquals(true, conLang.Primary_Language__c, 'Each new contact language record should be marked as primary.');
            System.assertEquals(UTIL_CustomSettingsFacade.getSettings().Default_Contact_Language_Fluency__c, conLang.Fluency__c, 'Each new contact language record should be associated with the default fluency value.');
        }
    }

    /************************************************************************************************************
    * @description Test method to verify that the run method does not create Contact Language records when no 
    * new contacts are inserted.
    *************************************************************************************************************/ 
    @isTest 
    private static void runAfterInsertNegative(){
        SRVC_ContactPrimaryLanguage.instance = new STUB_HasNoContactLanguagesToCreate();

        List<Contact> newContactsList = new List<Contact>();
        List<SObject> oldList = new List<SObject>();

        TDTM_Runnable.Action triggerAction = TDTM_Runnable.Action.AfterInsert;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Contact;

        Test.startTest();
        CON_PrimaryLanguage_TDTM conPrimaryLangTDTM = new CON_PrimaryLanguage_TDTM();
        conPrimaryLangTDTM.run((List<SObject>)newContactsList, oldList, triggerAction, objResult);
        Test.stopTest();

        List<Contact_Language__c> conLanguageResultsList = [SELECT Id,
                                                                   Contact__c,
                                                                   Language__c,
                                                                   Primary_Language__c,
                                                                   Fluency__c
                                                            FROM Contact_Language__c
                                                            WHERE Contact__c IN :newContactsList];

        System.assertEquals(true, conLanguageResultsList.isEmpty(), 'There should no contact language records created.');
    }

    /**************************************************************************************************************************
    ****************************************************** STUBS **************************************************************
    **************************************************************************************************************************/
    private class STUB_HasNoContactLanguagesToCreate extends SRVC_ContactPrimaryLanguage {
        @TestVisible 
        public override List<Contact_Language__c> getContactLanguagesToCreate(List<Contact> contactsList){            
            return new List<Contact_Language__c>();
        }
    }
    
}