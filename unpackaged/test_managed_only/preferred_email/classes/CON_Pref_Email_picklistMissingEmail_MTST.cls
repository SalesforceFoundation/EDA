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
* @description Tests CON_Preferred_Email_Utility_MTST methods with a custom Email field that has its 
* corresponding field label missing in the Preferred Email picklist entries in English and Spanish languages.
*/
@isTest
private with sharing class CON_Pref_Email_picklistMissingEmail_MTST {

    private static User spanishUser = CON_Pref_Email_picklistMissingEmail_MTST.returnUserInSpanish();
    
    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with a value in Picklist_Missing_Email__c field updates Preferred Email and
    * standard Email with the 'Picklist Missing Email' and its value respectively when Preferred Email Enforcement is Enabled.
    *****************************************************************************************************************************/
    @isTest
    private static void populateCustomEmailOnInsertEnglish() {
        CON_Pref_Email_Utility_MTST.populateCustomEmailOnInsert('Picklist_Missing_Email__c', 'test@sf.org');
    }

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with a Custom Email(Picklist Missing Email) and and an EDA Email field
    * will throw PreferredEmailRequiredError when Preferred Email Enforcement is Enabled.
    *****************************************************************************************************************************/
    @isTest
    private static void populateCustomEmailAndAlternateEmailOnInsertEnglish() {
        CON_Pref_Email_Utility_MTST.populateCustomEmailAndAlternateEmailOnInsert('Picklist_Missing_Email__c', 'test@sf.org');
    }

    /*****************************************************************************************************************************
    * @description Tests updating a Contact with a value in Picklist_Missing_Email__c field updates Preferred Email and
    * standard Email with the 'Picklist Missing Email' and its value respectively when Preferred Email Enforcement is Enabled.
    *****************************************************************************************************************************/
    @isTest
    private static void populateCustomEmailOnUpdateSpanish() {
        
        System.runAs(spanishUser) {
            CON_Pref_Email_Utility_MTST.populateCustomEmailOnUpdate('Picklist_Missing_Email__c', 'test@sf.org');
        }
    }

    /*****************************************************************************************************************************
    * @description Tests updating a Contact with a Custom Email(Picklist Missing Email) and and an EDA Email field
    * will throw PreferredEmailRequiredError when Preferred Email Enforcement is Enabled.
    *****************************************************************************************************************************/
    @isTest
    private static void populateCustomEmailAndAlternateEmailOnUpdateSpanish() {

        System.runAs(spanishUser) {
            CON_Pref_Email_Utility_MTST.populateCustomEmailAndAlternateEmailOnUpdate('Picklist_Missing_Email__c', 'test@sf.org');
        }
    }

    /*****************************************************************************************************************************
    * @description Helper method to return a user in Spanish language
    *****************************************************************************************************************************/
    private static User returnUserInSpanish() {

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User userInSpanish = new User(Alias = 'newUser', Email='newuser@testorg.com',
           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='es',
           LocaleSidKey='es', ProfileId = p.Id,
           TimeZoneSidKey='America/Los_Angeles', UserName='prefEmail@sf.com');

        return userInSpanish;

    }

}