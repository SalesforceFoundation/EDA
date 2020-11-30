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
* @description Tests CON_Preferred_Email_Utility_MTST methods with a custom Email field with the same Label as 
* an EDA Email field in English and Spanish languages.
*/
@isTest
private with sharing class CON_Pref_Email_duplicateField_MTST {

    private static Integer contactCount = 250; // used to determine number of test contact records to create

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with a field whose label is duplicate with any of the EDA's field label
    * will not update Preferred Email and standard Email in English language.
    *****************************************************************************************************************************/
    @isTest
    public static void duplicateUniversityFieldLabelOnInsert() {

        hed.UTIL_CustomSettings_API.getSettingsForTests(
            new %%%NAMESPACE%%%Hierarchy_Settings__c(%%%NAMESPACE%%%Disable_Preferred_Email_Enforcement__c = false)
        );

        List<Contact> contactsToBeInsertedList = new List<Contact>();

        for (integer i = 0; i < contactCount; i++) {

            Contact contactToBeInserted = new Contact();
            contactToBeInserted.put('Lastname', 'Email ' + i);
            contactToBeInserted.put('FirstName', 'Preferred');
            contactToBeInserted.put('University_Email__c', 'test@sf.org');
            contactToBeInserted.put('Description', i + ' Contact Description ' + i );
            contactToBeInserted.put('Department', 'Dept Num: '+i);

            contactsToBeInsertedList.add(contactToBeInserted);
        }

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.DuplicateRuleHeader.AllowSave = true;
        
        Test.startTest();
            List<Database.saveResult> results = Database.insert(contactsToBeInsertedList, dmo);
        Test.stopTest();

        List<Contact> insertedContactList = [SELECT Id, University_Email__c, %%%NAMESPACE%%%Preferred_Email__c, Email FROM Contact];

        System.assertEquals(contactCount,insertedContactList.size(), 'All the Contacts should be successfully inserted.');

        for (Contact eachContact: insertedContactList) {
            System.assertEquals(null, eachContact.%%%NAMESPACE%%%Preferred_Email__c, 'Preferred Email should not be populated with duplicate University Email\'s label');
            System.assertEquals(null, eachContact.Email, 'Standard Email should not be populated with duplicate University Email\'s value');
        }
    }

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with a field whose label is duplicate with any of the EDA's field label
    * will not update Preferred Email and standard Email in Spanish language.
    *****************************************************************************************************************************/
    @isTest
    private static void duplicateUniversityFieldLabelOnUpdate() {

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
            contactToBeInserted.put('Department', 'Dept Num: '+i);

            contactsToBeInsertedList.add(contactToBeInserted);
        }

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.DuplicateRuleHeader.AllowSave = true;

        List<Database.saveResult> insertedResults = Database.insert(contactsToBeInsertedList, dmo);

        for (Contact eachContact: [SELECT Id FROM Contact]) {
              eachContact.put('University_Email__c', 'test@sf.org');

              contactsToBeUpdatedList.add(eachContact);
        }

        Test.startTest();
            List<Database.saveResult> results = Database.update(contactsToBeUpdatedList, dmo);
        Test.stopTest();

        List<Contact> updatedContactList = [SELECT Id, University_Email__c, %%%NAMESPACE%%%Preferred_Email__c, Email FROM Contact];

        System.assertEquals(contactCount, updatedContactList.size(), 'All the Contacts should be successfully updated.');

        for (Contact eachContact: updatedContactList) {
            System.assertEquals(null, eachContact.%%%NAMESPACE%%%Preferred_Email__c, 'Preferred Email should not be populated with duplicate University Email\'s label');
            System.assertEquals(null, eachContact.Email,'Standard Email should not be populated with duplicate University Email\'s value');
        }
    }
}