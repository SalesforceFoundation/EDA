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
* @description Tests CON_Preferred_Email_Utility_MTST methods with a custom Email field(WHICH IS NOT TRANSLATED)
* which has the coressponding picklist value not translated in Preferred Email field.
*/

@isTest
private with sharing class CON_Pref_Email_untranslatPcklstSpsh_MTST {
    
    private static Integer contactCount = 250; // used to determine number of test contact records to create
    private static User spanishUser = CON_Pref_Email_untranslatPcklstSpsh_MTST.returnUserInSpanish();
    
    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with a Custom Email field in Spanish Language updates Preferred Email and
    * standard Email with the custom email's label and value respectively when Preferred Email Enforcement is Enabled.
    *****************************************************************************************************************************/
    @isTest
    private static void populateCustomEmailOnInsertSpanish() {
        
        System.runAs(spanishUser) {
            CON_Pref_Email_Utility_MTST.populateCustomEmailOnInsert('Untranslated_Picklist_Email__c', 'test@sf.org');
        }

    }

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with a Custom Email field and Preferred Email in Spanish Language sets
    * Preferred Email field and updates standard Email with the custom email's value when Preferred Email Enforcement is Enabled.
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
                contactToBeInserted.put('Untranslated_Picklist_Email__c', 'test@sf.org');
                contactToBeInserted.put('%%%NAMESPACE%%%preferred_Email__c', 'Untranslated Picklist Email');

                contactsToBeInsertedList.add(contactToBeInserted);
            }
                            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.DuplicateRuleHeader.AllowSave = true;
            
            Test.startTest();
                List<Database.saveResult> results = Database.insert(contactsToBeInsertedList, dmo);
            Test.stopTest();
            
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess() == false) {
                    System.assertEquals(label.PrefEmailMatchMustExist, sr.getErrors()[0].getMessage(), 'The Contact record should not be inserted as the field is in Spanish and picklist is in English.');
                } else {
                    System.assert(false, 'No record should be inserted as the field in Preferred Email is empty.');
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
                contactToBeInserted.put('%%%NAMESPACE%%%preferred_Email__c', 'Untranslated Picklist Email');
                
                contactsToBeInsertedList.add(contactToBeInserted);
            }
            
                            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.DuplicateRuleHeader.AllowSave = true;
            
            Test.startTest();
                List<Database.saveResult> results = Database.insert(contactsToBeInsertedList, dmo);
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
            CON_Pref_Email_Utility_MTST.populateCustomEmailAndAlternateEmailOnInsert('Untranslated_Picklist_Email__c', 'test@sf.org');
        }    
    }

    /*****************************************************************************************************************************
    * @description Tests updating a Contact with a Custom Email field  in English Language  updates Preferred Email and
    * standard Email with the custom email's label and value respectively when Preferred Email Enforcement is Enabled.
    *****************************************************************************************************************************/
    @isTest
    private static void populateCustomEmailOnUpdateSpanish() {

        System.runAs(spanishUser) {
            CON_Pref_Email_Utility_MTST.populateCustomEmailOnUpdate('Untranslated_Picklist_Email__c', 'test@sf.org');
        } 
    }

    /*****************************************************************************************************************************
    * @description Tests Updating a Contact with a Custom Email field and Preferred Email in Spanish Language  sets
    * Preferred Email field and updates standard Email with the custom email's value when Preferred Email Enforcement is Enabled.
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
            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.DuplicateRuleHeader.AllowSave = true;
            List<Database.saveResult> insertResults = Database.insert(contactsToBeInsertedList, dmo);
            
            for (Contact eachContact: [SELECT Id FROM Contact]) {
                eachContact.put('Untranslated_Picklist_Email__c', 'test@sf.org');
                eachContact.put('%%%NAMESPACE%%%preferred_Email__c', 'Untranslated Picklist Email');
                
                contactsToBeUpdatedList.add(eachContact);
            }
            
            Test.startTest();
                List<Database.saveResult> results = Database.update(contactsToBeUpdatedList, false);
            Test.stopTest();
            
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess() == false) {
                    System.assertEquals(label.PrefEmailMatchMustExist, sr.getErrors()[0].getMessage(), 'The Contact record should not be inserted as the field is in Spanish and picklist is in English.');
                } else {
                    System.assert(false, 'No record should be inserted as the field in Preferred Email is empty.');
                }
            }
        }
    }

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with Preferred Email and setting no Email fields  in Spanish Language  will throw 
    * 'PreferredEmailMatchNotNull' Error when Preferred Email Enforcement is Enabled.
    *****************************************************************************************************************************/
    @isTest
    private static void customEmailEmptyOnUpdateOnSpanish() {
        
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
            
                            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.DuplicateRuleHeader.AllowSave = true;
            
            List<Database.saveResult> insertResults = Database.insert(contactsToBeInsertedList, dmo);
            
            for (Contact eachContact: [SELECT Id FROM Contact]) {
                eachContact.put('%%%NAMESPACE%%%preferred_Email__c', 'Untranlated Picklist Email');
                
                contactsToBeUpdatedList.add(eachContact);
            }

            Test.startTest();
                List<Database.saveResult> results = Database.update(contactsToBeUpdatedList, false);
            Test.stopTest();
            
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess() == false) {
                    System.assertEquals(Label.PrefEmailMatchNotNull, sr.getErrors()[0].getMessage(), 'The Contact record should not be updated.');
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
    private static void populateCustomEmailAndAlternateEmailOnUpdateOnSpanish() {

        System.runAs(spanishUser) {
            CON_Pref_Email_Utility_MTST.populateCustomEmailAndAlternateEmailOnUpdate('Untranslated_Picklist_Email__c', 'test@sf.org');
        }    
    }

    /*****************************************************************************************************************************
    * @description Helper method to reurn a user in Spanish Language
    *****************************************************************************************************************************/
    private static User returnUserInSpanish() {

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User userInSpanish = new User(Alias = 'newUser', Email='newuser@testorg.com',
           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='es',
           LocaleSidKey='es', ProfileId = p.Id,
           TimeZoneSidKey='America/Los_Angeles', UserName='prefEmail@testorg.com');

        return userInSpanish;

    }

}