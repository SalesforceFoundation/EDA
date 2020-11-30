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
* @description Unmanaged Utility tests for CON_Email, used to test custom email fields
* for Preferred Email Enforcement functionality that are not EDA fields.
*/

@isTest
public class CON_Pref_Email_Utility_MTST {

    private static Integer contactCount = 250; // used to determine number of test contact records to create

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with a Custom Email field updates Preferred Email and
    * standard Email with the custom email's label and value respectively when Preferred Email Enforcement is Enabled.
    * @Params fieldApiName Field Api name of the Contact's Custom Email field
    * @Params fieldValue The value of the Custom Contact field being passed
    *****************************************************************************************************************************/
    public static void populateCustomEmailOnInsert(String fieldApiName, String fieldValue) {

        // Turn Preferred Email Enforcement on
        hed.UTIL_CustomSettings_API.getSettingsForTests(
            new %%%NAMESPACE%%%Hierarchy_Settings__c(%%%NAMESPACE%%%Disable_Preferred_Email_Enforcement__c = false)
        );

        List<Contact> contactsToBeInsertedList = new List<Contact>();

        for (integer i = 0; i < contactCount; i++) {

            Contact contactToBeInserted = new Contact();
            contactToBeInserted.put('Lastname', i + 'Email ');
            contactToBeInserted.put('FirstName', i + 'Preferred');
            contactToBeInserted.put('Description', i + ' Contact Description ' + i );
            contactToBeInserted.put('Department', i + ' Dept Num: ' + i);
            contactToBeInserted.put(fieldApiName, fieldValue);

            contactsToBeInsertedList.add(contactToBeInserted);
        }
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.duplicateRuleHeader.allowSave = true;

        Test.startTest();
            List<Database.saveResult> results = Database.insert(contactsToBeInsertedList, dml);
        Test.stopTest();

        List<Contact> insertedContactList = [SELECT Id, toLabel(%%%NAMESPACE%%%Preferred_Email__c), Email FROM Contact];

        System.assertEquals(contactCount, insertedContactList.size(), 'All the Contacts should be successfully inserted.');

        String preferredFieldLabel = CON_Pref_Email_Utility_MTST.getContactFieldLabelFromApi(fieldApiName);

        for (Contact eachContact: insertedContactList) {
            System.assertEquals(preferredFieldLabel, eachContact.%%%NAMESPACE%%%Preferred_Email__c, 'Preferred Email should be populated with Custom Email\'s label');
            System.assertEquals(fieldValue, eachContact.Email, 'Standard Email should be populated with Preferred Email\'s value');
        }
    }

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with a Custom Email field and Preferred Email sets
    * Preferred Email field and updates standard Email with the custom email's value when Preferred Email Enforcement is Enabled.
    * @Params fieldApiName Field Api name of the Contact's Custom Email field
    * @Params fieldValue The value of the Custom Contact field being passed
    *****************************************************************************************************************************/
    public static void populateCustomAndPrefEmailOnInsert(String fieldApiName, String fieldValue) {

        hed.UTIL_CustomSettings_API.getSettingsForTests(
            new %%%NAMESPACE%%%Hierarchy_Settings__c(%%%NAMESPACE%%%Disable_Preferred_Email_Enforcement__c = false)
        );

        List<Contact> contactsToBeInsertedList = new List<Contact>();

        String preferredFieldLabel = CON_Pref_Email_Utility_MTST.getContactFieldLabelFromApi(fieldApiName);
        
        for (integer i = 0; i < contactCount; i++) {

            Contact contactToBeInserted = new Contact();
            contactToBeInserted.put('Lastname', 'Email ' + i);
            contactToBeInserted.put('FirstName', 'Preferred');
            contactToBeInserted.put('Description', i + ' Contact Description ' + i );
            contactToBeInserted.put('Department', i + ' Dept Num: ' + i);
            contactToBeInserted.put(fieldApiName, fieldValue);
            contactToBeInserted.put('%%%NAMESPACE%%%preferred_Email__c', preferredFieldLabel);

            contactsToBeInsertedList.add(contactToBeInserted);
        }

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.duplicateRuleHeader.allowSave = true;
        
        Test.startTest();
            List<Database.saveResult> results = Database.insert(contactsToBeInsertedList, dml);
        Test.stopTest();

        List<Contact> insertedContactList = [SELECT Id, %%%NAMESPACE%%%Preferred_Email__c, Email FROM Contact];
        System.assertEquals(contactCount, insertedContactList.size(), 'All the Contacts should be successfully inserted.');

        for (Contact eachContact: insertedContactList) {
            System.assertEquals(preferredFieldLabel, eachContact.%%%NAMESPACE%%%Preferred_Email__c, 'Preferred Email should be populated with Custom Email\'s label');
            System.assertEquals(fieldValue, eachContact.Email, 'Standard Email should be populated with Preferred Email\'s value');
        }
    }

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with Preferred Email and setting no Email fields will throw 
    * 'PreferredEmailMatchNotNull' Error when Preferred Email Enforcement is Enabled.
    * @Params fieldApiName Field Api name of the Contact's Custom Email field
    * @Params fieldValue The value of the Custom Contact field being passed
    *****************************************************************************************************************************/
    public static void customEmailEmptyOnInsert(String fieldApiName, String fieldValue) {

        hed.UTIL_CustomSettings_API.getSettingsForTests(
            new %%%NAMESPACE%%%Hierarchy_Settings__c(%%%NAMESPACE%%%Disable_Preferred_Email_Enforcement__c = false)
        );

        List<Contact> contactsToBeInsertedList = new List<Contact>();

        String preferredFieldLabel = CON_Pref_Email_Utility_MTST.getContactFieldLabelFromApi(fieldApiName);

        for (integer i = 0; i < contactCount; i++) {

            Contact contactToBeInserted = new Contact();
            contactToBeInserted.put('Lastname', 'Email ' + i);
            contactToBeInserted.put('FirstName', 'Preferred');
            contactToBeInserted.put('Description', i + ' Contact Description ' + i );
            contactToBeInserted.put('Department', i + ' Dept Num: ' + i);
            contactToBeInserted.put('%%%NAMESPACE%%%preferred_Email__c', preferredFieldLabel);
            
            contactsToBeInsertedList.add(contactToBeInserted);
        }

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.duplicateRuleHeader.allowSave = true;

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

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with a Custom Email and and an EDA Email field
    * will throw PreferredEmailRequiredError Error when Preferred Email Enforcement is Enabled.
    * @Params fieldApiName Field Api name of the Contact's Custom Email field
    * @Params fieldValue The value of the Custom Contact field being passed
    *****************************************************************************************************************************/
    public static void populateCustomEmailAndAlternateEmailOnInsert(String fieldApiName, String fieldValue) {

        hed.UTIL_CustomSettings_API.getSettingsForTests(
            new %%%NAMESPACE%%%Hierarchy_Settings__c(%%%NAMESPACE%%%Disable_Preferred_Email_Enforcement__c = false)
        );

        List<Contact> contactsToBeInsertedList = new List<Contact>();

        String preferredFieldLabel = CON_Pref_Email_Utility_MTST.getContactFieldLabelFromApi(fieldApiName);

        for (integer i = 0; i < contactCount; i++) {

            Contact contactToBeInserted = new Contact();
            contactToBeInserted.put('Lastname', 'Email ' + i);
            contactToBeInserted.put('FirstName', 'Preferred');
            contactToBeInserted.put('Description', i + ' Contact Description ' + i );
            contactToBeInserted.put('Department', i + ' Dept Num: ' + i);
            contactToBeInserted.put(fieldApiName, fieldValue);
            contactToBeInserted.put('%%%NAMESPACE%%%AlternateEmail__c', 'test@sf.com');

            contactsToBeInsertedList.add(contactToBeInserted);
        }

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.duplicateRuleHeader.allowSave = true;

        Test.startTest();
            List<Database.saveResult> results = Database.insert(contactsToBeInsertedList, dml);
        Test.stopTest();

        for (Database.SaveResult sr : results) {
            if (sr.isSuccess() == false) {
                System.assertEquals(label.PrefEmailRequiredError, sr.getErrors()[0].getMessage(), 'The Contact record should not be inserted.');
            } else {
                System.assert(false, 'No record should be inserted as the field in Preferred Email is empty.');
            }
        }

    }

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with Preferred Email and no Email fields will not throw an error
    * when Preferred Email Enforcement is enabled.
    * @Params fieldApiName Field Api name of the Contact's Custom Email field
    * @Params fieldValue The value of the Custom Contact field being passed
    *****************************************************************************************************************************/
    public static void populateCustomEmailWithEnforcementDisbaledOnInsert(String fieldApiName, String fieldValue) {

        hed.UTIL_CustomSettings_API.getSettingsForTests(
            new %%%NAMESPACE%%%Hierarchy_Settings__c(%%%NAMESPACE%%%Disable_Preferred_Email_Enforcement__c = true)
        );

        List<Contact> contactsToBeInsertedList = new List<Contact>();

        for (integer i = 0; i < contactCount; i++) {

            Contact contactToBeInserted = new Contact();
            contactToBeInserted.put('Lastname', 'Email ' + i);
            contactToBeInserted.put('FirstName', 'Preferred');
            contactToBeInserted.put('Description', i + ' Contact Description ' + i );
            contactToBeInserted.put('Department', i + ' Dept Num: ' + i);
            contactToBeInserted.put(fieldApiName, fieldValue);

            
            contactsToBeInsertedList.add(contactToBeInserted);
        }

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.duplicateRuleHeader.allowSave = true;
        
        Test.startTest();
            List<Database.saveResult> results = Database.insert(contactsToBeInsertedList, dml);
        Test.stopTest();

        List<Contact> insertedContactList = [SELECT Id, %%%NAMESPACE%%%Preferred_Email__c, Email FROM Contact];

        System.assertEquals(contactCount, insertedContactList.size(), 'All the Contacts should be successfully inserted.');

        for (Contact eachContact: insertedContactList) {
            System.assertEquals(null, eachContact.%%%NAMESPACE%%%Preferred_Email__c, 'Preferred Email should be not be populated with Custom Email\'s label');
            System.assertEquals(null, eachContact.Email, 'Standard Email should not be populated with Preferred Email\'s value');
        }
    }

    /*****************************************************************************************************************************
    * @description Tests updating a Contact with a Custom Email field updates Preferred Email and
    * standard Email with the custom email's label and value respectively when Preferred Email Enforcement is Enabled.
    * @Params fieldApiName Field Api name of the Contact's Custom Email field
    * @Params fieldValue The value of the Custom Contact field being passed
    *****************************************************************************************************************************/
    public static void populateCustomEmailOnUpdate(String fieldApiName, String fieldValue) {

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
        dml.duplicateRuleHeader.allowSave = true;
        
        List<Database.saveResult> insertedResults = Database.insert(contactsToBeInsertedList, dml);

        for (Contact eachContact: [SELECT Id FROM Contact]) {
            eachContact.put(fieldApiName, fieldValue);
            contactsToBeUpdatedList.add(eachContact);
        }

        
        Test.startTest();
            List<Database.saveResult> results = Database.update(contactsToBeUpdatedList, dml);
        Test.stopTest();

        List<Contact> updatedContactList = [SELECT Id, toLabel(%%%NAMESPACE%%%Preferred_Email__c), Email FROM Contact];

        System.assertEquals(contactCount, updatedContactList.size(), 'All the Contacts should be successfully inserted.');

        String preferredFieldLabel = CON_Pref_Email_Utility_MTST.getContactFieldLabelFromApi(fieldApiName);

        for (Contact eachContact: updatedContactList) {
            System.assertEquals(preferredFieldLabel, eachContact.%%%NAMESPACE%%%Preferred_Email__c, 'Preferred Email should be populated with Custom Email\'s label');
            System.assertEquals(fieldValue, eachContact.Email, 'Standard Email should be populated with Preferred Email\'s value');
        }
    }

    /*****************************************************************************************************************************
    * @description Tests Updating a Contact with a Custom Email field and Preferred Email sets
    * Preferred Email field and updates standard Email with the custom email's value when Preferred Email Enforcement is Enabled.
    * @Params fieldApiName Field Api name of the Contact's Custom Email field
    * @Params fieldValue The value of the Custom Contact field being passed
    *****************************************************************************************************************************/
    public static void populateCustomAndPrefEmailOnUpdate(String fieldApiName, String fieldValue) {

        hed.UTIL_CustomSettings_API.getSettingsForTests(
            new %%%NAMESPACE%%%Hierarchy_Settings__c(%%%NAMESPACE%%%Disable_Preferred_Email_Enforcement__c = false)
        );

        List<Contact> contactsToBeInsertedList = new List<Contact>();
        List<Contact> contactsToBeUpdatedList = new List<Contact>();

        String preferredFieldLabel = CON_Pref_Email_Utility_MTST.getContactFieldLabelFromApi(fieldApiName);

        for (integer i = 0; i < contactCount; i++) {

            Contact contactToBeInserted = new Contact();
            contactToBeInserted.put('Lastname', 'Email ' + i);
            contactToBeInserted.put('FirstName', 'Preferred');
            contactToBeInserted.put('Description', i + ' Contact Description ' + i );
            contactToBeInserted.put('Department', i + ' Dept Num: ' + i);

            contactsToBeInsertedList.add(contactToBeInserted);
        }

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.duplicateRuleHeader.allowSave = true;
        
        List<Database.saveResult> insertedResults = Database.insert(contactsToBeInsertedList, dml);

        for (Contact eachContact: [SELECT Id FROM Contact]) {
            eachContact.put(fieldApiName, fieldValue);
            eachContact.put('%%%NAMESPACE%%%preferred_Email__c', preferredFieldLabel);

            contactsToBeUpdatedList.add(eachContact);
        }
        
        Test.startTest();
            List<Database.saveResult> results = Database.update(contactsToBeUpdatedList, dml);
        Test.stopTest();

        List<Contact> updatedContactList = [SELECT Id, %%%NAMESPACE%%%Preferred_Email__c, Email FROM Contact];

        System.assertEquals(contactCount, updatedContactList.size(), 'All the Contacts should be successfully inserted.');

        for (Contact eachContact: updatedContactList) {
            System.assertEquals(preferredFieldLabel, eachContact.%%%NAMESPACE%%%Preferred_Email__c, 'Preferred Email should be populated with Custom Email\'s label');
            System.assertEquals(fieldValue, eachContact.Email, 'Standard Email should be populated with Preferred Email\'s value');
        }
    }

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with Preferred Email and setting no Email fields will throw 
    * 'PreferredEmailMatchNotNull' Error when Preferred Email Enforcement is Enabled.
    * @Params fieldApiName Field Api name of the Contact's Custom Email field
    * @Params fieldValue The value of the Custom Contact field being passed
    *****************************************************************************************************************************/
    public static void customEmailEmptyOnUpdate(String fieldApiName, String fieldValue) {

        hed.UTIL_CustomSettings_API.getSettingsForTests(
            new %%%NAMESPACE%%%Hierarchy_Settings__c(%%%NAMESPACE%%%Disable_Preferred_Email_Enforcement__c = false)
        );

        List<Contact> contactsToBeInsertedList = new List<Contact>();
        List<Contact> contactsToBeUpdatedList = new List<Contact>();

        String preferredFieldLabel = CON_Pref_Email_Utility_MTST.getContactFieldLabelFromApi(fieldApiName);

        for (integer i = 0; i < contactCount; i++) {

            Contact contactToBeInserted = new Contact();
            contactToBeInserted.put('Lastname', 'Email ' + i);
            contactToBeInserted.put('FirstName', 'Preferred');
            contactToBeInserted.put('Description', i + ' Contact Description ' + i );
            contactToBeInserted.put('Department', i + ' Dept Num: ' + i);

            contactsToBeInsertedList.add(contactToBeInserted);
        }

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.duplicateRuleHeader.allowSave = true;

        List<Database.saveResult> insertedResults = Database.insert(contactsToBeInsertedList, dml);

        for (Contact eachContact: [SELECT Id FROM Contact]) {
            eachContact.put('%%%NAMESPACE%%%preferred_Email__c', preferredFieldLabel);

            contactsToBeUpdatedList.add(eachContact);
        }
        
        Test.startTest();
            List<Database.saveResult> results = Database.update(contactsToBeUpdatedList, dml);
        Test.stopTest();

        for (Database.SaveResult sr : results) {
            if (sr.isSuccess() == false) {
                System.assertEquals(Label.PrefEmailMatchNotNull, sr.getErrors()[0].getMessage(), 'The Contact record should not be updated.');
            } else {
                System.assert(false, 'No record should be inserted as the field in Preferred Email is empty.');
            }
        }

    }

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with Custom Email as Preferred Email and and an EDA Email field
    * will throw PreferredEmailRequiredError Error when Preferred Email Enforcement is Enabled.
    * @Params fieldApiName Field Api name of the Contact's Custom Email field
    * @Params fieldValue The value of the Custom Contact field being passed
    *****************************************************************************************************************************/
    public static void populateCustomEmailAndAlternateEmailOnUpdate(String fieldApiName, String fieldValue) {

        hed.UTIL_CustomSettings_API.getSettingsForTests(
            new %%%NAMESPACE%%%Hierarchy_Settings__c(%%%NAMESPACE%%%Disable_Preferred_Email_Enforcement__c = false)
        );

        List<Contact> contactsToBeInsertedList = new List<Contact>();
        List<Contact> contactsToBeUpdateList = new List<Contact>();

        String preferredFieldLabel = CON_Pref_Email_Utility_MTST.getContactFieldLabelFromApi(fieldApiName);

        for (integer i = 0; i < contactCount; i++) {

            Contact contactToBeInserted = new Contact();
            contactToBeInserted.put('Lastname', 'Email ' + i);
            contactToBeInserted.put('FirstName', 'Preferred');
            contactToBeInserted.put('Description', i + ' Contact Description ' + i );
            contactToBeInserted.put('Department', i + ' Dept Num: ' + i);

            contactsToBeInsertedList.add(contactToBeInserted);
        }
        
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.duplicateRuleHeader.allowSave = true;
        
        List<Database.saveResult> insertedResults = Database.insert(contactsToBeInsertedList, dml);

        for (Contact eachContact: [SELECT Id FROM Contact]) {
            eachContact.put(fieldApiName, fieldValue);
            eachContact.put('%%%NAMESPACE%%%AlternateEmail__c', 'test@sf.com');

            contactsToBeUpdateList.add(eachContact);
        }

        
        Test.startTest();
            List<Database.saveResult> results = Database.update(contactsToBeUpdateList, dml);
        Test.stopTest();

        for (Database.SaveResult sr : results) {
            if (sr.isSuccess() == false) {
                System.assertEquals(Label.PrefEmailRequiredError, sr.getErrors()[0].getMessage(), 'The Contact record should not be inserted.');
            } else {
                System.assert(false, 'No record should be inserted as the field in Preferred Email is empty.');
            }
        }

    }

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with Preferred Email and no Email fields will not throw an error
    * when Preferred Email Enforcement is enabled.
    * @Params fieldApiName Field Api name of the Contact's Custom Email field
    * @Params fieldValue The value of the Custom Contact field being passed
    *****************************************************************************************************************************/
    public static void populateCustomEmailWithEnforcementDisbaledOnUpdate(String fieldApiName, String fieldValue) {

        hed.UTIL_CustomSettings_API.getSettingsForTests(
            new %%%NAMESPACE%%%Hierarchy_Settings__c(%%%NAMESPACE%%%Disable_Preferred_Email_Enforcement__c = true)
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
        dml.duplicateRuleHeader.allowSave = true;
        
        List<Database.saveResult> insertedResults = Database.insert(contactsToBeInsertedList, dml);

        for (Contact eachContact: [SELECT Id FROM Contact]) {
            eachContact.put(fieldApiName, fieldValue);

            contactsToBeUpdatedList.add(eachContact);
        }

        Test.startTest();
            List<Database.saveResult> results = Database.update(contactsToBeUpdatedList, dml);
        Test.stopTest();

        String soqlQuery = 'SELECT Id, %%%NAMESPACE%%%Preferred_Email__c, Email FROM Contact';
        List<Contact> updatedContactList = database.query(soqlQuery);

        System.assertEquals(contactCount, updatedContactList.size(), 'All the Contacts should be successfully inserted.');

        for (Contact eachContact: updatedContactList) {
            System.assertEquals(null, eachContact.%%%NAMESPACE%%%Preferred_Email__c, 'Preferred Email should be not be populated with Custom Email\'s label');
            System.assertEquals(null, eachContact.Email, 'Standard Email should not be populated with Preferred Email\'s value');
        }
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