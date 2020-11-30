/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group Contacts
* @group-content ../../ApexDocContent/Contacts.htm
* @description Tests CON_Preferred_Email_Utility_MTST methods with a custom Email field in English 
*/
@isTest
private with sharing class CON_Pref_Email_untranslatedSpsh_MTST {

    private static Integer contactCount = 250; // used to determine number of test contact records to create
    private static User spanishUser = CON_Pref_Email_untranslatedSpsh_MTST.returnUserInSpanish();

    /*************************************************************************************************************************************
    * @description Tests inserting a Contact with a Custom Email field(Untranslated Email) in Spanish Language updates Preferred Email and
    * standard Email with the custom email's label and value respectively when Preferred Email Enforcement is Enabled.
    **************************************************************************************************************************************/
    @isTest
    private static void populateCustomEmailOnInsertSpanish() {

        System.runAs(spanishUser) {
            hed.UTIL_CustomSettings_API.getSettingsForTests(
            new %%%NAMESPACE%%%Hierarchy_Settings__c(%%%NAMESPACE%%%Disable_Preferred_Email_Enforcement__c = false)
            );

            List<Contact> contactsToBeInsertedList = new List<Contact>();

            for (integer i = 0; i < contactCount; i++) {

                Contact contactToBeInserted = new Contact();
                contactToBeInserted.put('Lastname', 'Email ' + i);
                contactToBeInserted.put('FirstName', 'Preferred'+ i);
                contactToBeInserted.put('Untranslated_Email__c', 'sf@test.org');

                contactsToBeInsertedList.add(contactToBeInserted);
            }

            Database.DMLOptions dml = new Database.DMLOptions();
            dml.duplicateRuleHeader.allowSave = true;
            Test.startTest();
                List<Database.saveResult> results = Database.insert(contactsToBeInsertedList, dml);
            Test.stopTest();
            
            List<Contact> insertedContactList = [SELECT Id, Untranslated_Email__c, toLabel(%%%NAMESPACE%%%Preferred_Email__c), Email FROM Contact];
            System.assertEquals(contactCount, insertedContactList.size(), 'All the Contacts should be successfully inserted.');

            String preferredFieldLabel = CON_Pref_Email_untranslatedSpsh_MTST.getContactFieldLabelFromApi('Untranslated_Email__c');

            for (Contact eachContact: insertedContactList) {
                System.assertEquals('Correo electrónico sin traducir', eachContact.%%%NAMESPACE%%%Preferred_Email__c, 'Preferred Email should be in Spanish');
                System.assertEquals('Untranslated Email', preferredFieldLabel, 'Preferred Email should be English as it does not have translations');
                System.assertEquals('sf@test.org', eachContact.Email, 'Standard Email should be populated with Preferred Email\'s value');
            }
        }
        
        // Assert in English language
        for (Contact eachContact: [SELECT Id, %%%NAMESPACE%%%Preferred_Email__c FROM Contact]) {
            System.assertEquals('Untranslated Email', eachContact.%%%NAMESPACE%%%Preferred_Email__c, 'Preferred Email should be in English when running as English user');
        }
    }

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with a Custom Email(Untranslated Email) field and Preferred Email in Spanish Language 
    * throws PreferredEmailMatchMustExist an error 
    *****************************************************************************************************************************/
    @isTest
    private static void populateCustomAndPrefEmailOnInsertSpanish() {

        System.runAs(spanishUser) {
            hed.UTIL_CustomSettings_API.getSettingsForTests(
                new %%%NAMESPACE%%%Hierarchy_Settings__c(%%%NAMESPACE%%%Disable_Preferred_Email_Enforcement__c = false)
            );
            
            List<Contact> contactsToBeInsertedList = new List<Contact>();
            
            for (integer i = 0; i < contactCount; i++) {
                
                Contact contactToBeInserted = new Contact();
                contactToBeInserted.put('Lastname', 'Email ' + i);
                contactToBeInserted.put('FirstName', 'Preferred');
                contactToBeInserted.put('Description', i + ' Contact Description ' + i );
                contactToBeInserted.put('Department', i + ' Dept Num: ' + i);
                contactToBeInserted.put('Untranslated_Email__c', 's@g.com');
                contactToBeInserted.put('%%%NAMESPACE%%%preferred_Email__c', 'Correo electrónico sin traducir');
                
                contactsToBeInsertedList.add(contactToBeInserted);
            }
            
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.duplicateRuleHeader.allowSave = true;
            Test.startTest();
                List<Database.saveResult> results = Database.insert(contactsToBeInsertedList, dml);
            Test.stopTest();
            
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess() == false) {
                    System.assertEquals(Label.PrefEmailMatchMustExist, sr.getErrors()[0].getMessage(), 'The Contact record should not be inserted.');
                } else {
                    System.assert(false, 'No record should be updated as the Preferred Email value is still in Spanish.');
                }
            }
        }
    }

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with Preferred Email and setting no Email fields  in Spanish Language  will throw 
    * 'PreferredEmailMatchNotNull' Error when Preferred Email Enforcement is Enabled.
    *****************************************************************************************************************************/
    @isTest
    private static void customEmailEmptyOnInsertSpanish() {

        System.runAs(spanishUser) {
            hed.UTIL_CustomSettings_API.getSettingsForTests(
                new %%%NAMESPACE%%%Hierarchy_Settings__c(%%%NAMESPACE%%%Disable_Preferred_Email_Enforcement__c = false)
            );
            
            List<Contact> contactsToBeInsertedList = new List<Contact>();
     
            for (integer i = 0; i < contactCount; i++) {
                
                Contact contactToBeInserted = new Contact();
                contactToBeInserted.put('Lastname', 'Email ' + i);
                contactToBeInserted.put('FirstName', 'Preferred');
                contactToBeInserted.put('Description', i + ' Contact Description ' + i );
                contactToBeInserted.put('Department', i + ' Dept Num: ' + i);
                contactToBeInserted.put('%%%NAMESPACE%%%preferred_Email__c', 'Correo electrónico sin traducir');
                
                contactsToBeInsertedList.add(contactToBeInserted);
            }

                            
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;
            
            Test.startTest();
                List<Database.saveResult> results = Database.insert(contactsToBeInsertedList, dml);
            Test.stopTest();
            
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess() == false) {
                    System.assertEquals(label.PrefEmailMatchNotNull, sr.getErrors()[0].getMessage(), 'The Contact record should not be inserted.');
                } else {
                    System.assert(false, 'No record should be inserted as the field in Preferred Email is empty.');
                }
            }
        }
    }

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with Custom Email as Preferred Email and and an EDA Email field
    *  in Spanish Language  will throw PreferredEmailRequiredError Error when Preferred Email Enforcement is Enabled.
    *****************************************************************************************************************************/
    @isTest
    private static void populateCustomEmailAndAlternateEmailOnInsertSpanish() {

        System.runAs(spanishUser) {
            CON_Pref_Email_Utility_MTST.populateCustomEmailAndAlternateEmailOnInsert('Untranslated_Email__c', 'test@sf.org');
        }    
    }

    /*************************************************************************************************************************************
    * @description Tests updating a Contact with a Custom Email field(Untranslated Email) in Spanish Language updates Preferred Email and
    * standard Email with the custom email's label and value respectively when Preferred Email Enforcement is Enabled.
    **************************************************************************************************************************************/
    @isTest
    private static void populateCustomEmailOnUpdateSpanish() {
        
        System.runAs(spanishUser) {
            hed.UTIL_CustomSettings_API.getSettingsForTests(
                new %%%NAMESPACE%%%Hierarchy_Settings__c(%%%NAMESPACE%%%Disable_Preferred_Email_Enforcement__c = false)
            );
            
            List<Contact> contactsToBeInsertedList = new List<Contact>();
            List<Contact> contactsToBeUpdatedList = new List<Contact>();
            
            for (integer i = 0; i < contactCount; i++) {
                
                Contact contactToBeInserted = new Contact();
                contactToBeInserted.put('Lastname', 'Email ' + i);
                contactToBeInserted.put('FirstName', 'Preferred' + i);
                
                contactsToBeInsertedList.add(contactToBeInserted);
            }
            
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.duplicateRuleHeader.allowSave = true;
            
            List<Database.saveResult> insertedResults = Database.insert(contactsToBeInsertedList, dml);
            
            for (Contact eachContact: [SELECT Id FROM Contact]) {
                eachContact.put('Untranslated_Email__c', 'sf@test.org');
                contactsToBeUpdatedList.add(eachContact);
            }
            
            Test.startTest();
                List<Database.saveResult> results = Database.update(contactsToBeUpdatedList, dml);
            Test.stopTest();
            
            List<Contact> updatedContactList = [SELECT Id, Untranslated_Email__c, toLabel(%%%NAMESPACE%%%Preferred_Email__c), Email FROM Contact];
            
            System.assertEquals(contactCount, updatedContactList.size(), 'All the Contacts should be successfully updated.');
            
            String preferredFieldLabel = CON_Pref_Email_untranslatedSpsh_MTST.getContactFieldLabelFromApi('Untranslated_Email__c');

            for (Contact eachContact: updatedContactList) {
                System.assertEquals('Correo electrónico sin traducir', eachContact.%%%NAMESPACE%%%Preferred_Email__c, 'Preferred Email should be in Spanish');
                System.assertEquals('Untranslated Email', preferredFieldLabel, 'Preferred Email should be English as it does not have translations');
                System.assertEquals('sf@test.org', eachContact.Email, 'Standard Email should be populated with Preferred Email\'s value');
            }
        }
        
        for (Contact eachContact: [SELECT Id, %%%NAMESPACE%%%Preferred_Email__c FROM Contact]) {
            System.assertEquals('Untranslated Email', eachContact.%%%NAMESPACE%%%Preferred_Email__c, 'Preferred Email should be in English when running as English user');
        }
    }

    /*****************************************************************************************************************************
    * @description Tests updating a Contact with a Custom Email(Untranslated Email) field and Preferred Email in Spanish Language 
    * throws PreferredEmailMatchMustExist an error 
    *****************************************************************************************************************************/
    @isTest
    private static void populateCustomAndPrefEmailOnUpdateSpanish() {

        System.runAs(spanishUser) {
            
            hed.UTIL_CustomSettings_API.getSettingsForTests(
                new %%%NAMESPACE%%%Hierarchy_Settings__c(%%%NAMESPACE%%%Disable_Preferred_Email_Enforcement__c = false)
            );
            
            List<Contact> contactsToBeInsertedList = new List<Contact>();
            List<Contact> contactsToBeUpdatedList = new List<Contact>();

            for (integer i = 0; i < contactCount; i++) {
                
                Contact contactToBeInserted = new Contact();
                contactToBeInserted.put('Lastname', 'Email ' + i);
                contactToBeInserted.put('FirstName', 'Preferred');
                contactToBeInserted.put('Description', i + ' Contact Description ' + i );
                contactToBeInserted.put('Department', i + ' Dept Num: ' + i);
                
                contactsToBeInsertedList.add(contactToBeInserted);
            }
            
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;
            List<Database.saveResult> insertedResults = Database.update(contactsToBeInsertedList, dml);
            
            for (Contact eachContact: [SELECT Id FROM Contact]) {
                eachContact.put('Untranslated_Email__c', 'test@sf.org');
                eachContact.put('%%%NAMESPACE%%%preferred_Email__c', 'Correo electrónico sin traducir');
                
                contactsToBeUpdatedList.add(eachContact);
            }
            
            Test.startTest();
                List<Database.saveResult> results = Database.update(contactsToBeUpdatedList, dml);
            Test.stopTest();
            
            List<Contact> updatedContactList = [SELECT Id, %%%NAMESPACE%%%Preferred_Email__c, Email FROM Contact];
            
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess() == false) {
                    System.assertEquals(Label.PrefEmailMatchMustExist, sr.getErrors()[0].getMessage(), 'The Contact record should not be inserted.');
                } else {
                    System.assert(false, 'No record should be updated as the Preferred Email value is still in Spanish.');
                }
            }
        }
    }

    /*****************************************************************************************************************************
    * @description Tests updating a Contact with Preferred Email and setting no Email fields  in Spanish Language  will throw 
    * 'PreferredEmailMatchNotNull' Error when Preferred Email Enforcement is Enabled.
    *****************************************************************************************************************************/
    @isTest
    private static void customEmailEmptyOnUpdateOnSpanish() {

        System.runAs(spanishUser) {
            CON_Pref_Email_Utility_MTST.customEmailEmptyOnUpdate('Untranslated_Email__c', 'test@sf.org');
        }
    }

    /*****************************************************************************************************************************
    * @description Tests updating a Contact with Custom Email as Preferred Email and and an EDA Email field
    *  in Spanish Language  will throw PreferredEmailRequiredError Error when Preferred Email Enforcement is Enabled.
    *****************************************************************************************************************************/
    @isTest
    private static void populateCustomEmailAndAlternateEmailOnUpdateOnSpanish() {

        User spanishUser = CON_Pref_Email_untranslatedSpsh_MTST.returnUserInSpanish();
        System.runAs(spanishUser) {
            CON_Pref_Email_Utility_MTST.populateCustomEmailAndAlternateEmailOnUpdate('Untranslated_Email__c', 'test@sf.org');
        }    
    }

    /*****************************************************************************************************************************
    * @description Helper method to retrieve Contact Field's Label from its Api name
    * @Params fieldApi The Api name of the Contact Field
    * @return Label of the Contact Field
    ******************************************************************************************************************************/
    private static User returnUserInSpanish() {

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User userInSpanish = new User(Alias = 'newUser', Email='newuser@testorg.com',
           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='es',
           LocaleSidKey='es', ProfileId = p.Id,
           TimeZoneSidKey='America/Los_Angeles', UserName='prefEmail@testorg.com');

        return userInSpanish;

    }

    /*****************************************************************************************************************************
    * @description Helper method to retrieve Contact Field's Label from its Api name
    * @Params fieldApi The Api name of the Contact Field
    * @return Label of the Contact Field
    *****************************************************************************************************************************/
     private static String getContactFieldLabelFromApi(String fieldApi) {
        return Describe_Utility.getFieldLabelFromObjectApiAndFieldApi('Contact', fieldApi);
    }
}