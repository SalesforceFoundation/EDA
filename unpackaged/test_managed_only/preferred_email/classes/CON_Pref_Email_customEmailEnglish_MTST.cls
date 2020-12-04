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
* @group Contact
* @group-content ../../ApexDocContent/Contacts.htm
* @description Tests CON_Pref_Email_Utility_MTST methods with a custom Email field in English language.
*/
@isTest
private with sharing class CON_Pref_Email_customEmailEnglish_MTST {

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with a Custom Email field in English Language updates Preferred Email and
    * standard Email with the custom email's label and value respectively when Preferred Email Enforcement is Enabled.
    *****************************************************************************************************************************/
    @isTest
    private static void populateCustomEmailOnInsertEnglish() {

        CON_Pref_Email_Utility_MTST.populateCustomEmailOnInsert('Custom_Email__c', 'test@sf.org');
    }

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with a Custom Email field and Preferred Email in ENglish Language sets
    * Preferred Email field and updates standard Email with the custom email's value when Preferred Email Enforcement is Enabled.
    *****************************************************************************************************************************/
    @isTest
    private static void populateCustomAndPrefEmailOnInsertEnglish() {

        CON_Pref_Email_Utility_MTST.populateCustomAndPrefEmailOnInsert('Custom_Email__c', 'test@sf.org');
    }

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with Preferred Email and setting no Email fields  in English Language  will throw 
    * 'PreferredEmailMatchNotNull' Error when Preferred Email Enforcement is Enabled.
    *****************************************************************************************************************************/
    @isTest
    private static void customEmailEmptyOnInsertEnglish() {

        CON_Pref_Email_Utility_MTST.customEmailEmptyOnInsert('Custom_Email__c', 'test@sf.org');
    }

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with Custom Email as Preferred Email and and an EDA Email field
    *  in English Language  will throw PreferredEmailRequiredError Error when Preferred Email Enforcement is Enabled.
    *****************************************************************************************************************************/
    @isTest
    private static void populateCustomEmailAndAlternateEmailOnInsertEnglish() {

        CON_Pref_Email_Utility_MTST.populateCustomEmailAndAlternateEmailOnInsert('Custom_Email__c', 'test@sf.org');
    }

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with Preferred Email and no Email fields  in English Language  will not throw an error
    * when Preferred Email Enforcement is enabled.
    *****************************************************************************************************************************/
    @isTest
    private static void populateCustomEmailWithEnforcementDisbaledOnInsertEnglish() {

        CON_Pref_Email_Utility_MTST.populateCustomEmailWithEnforcementDisbaledOnInsert('Custom_Email__c', 'test@sf.org');
    }

    /*****************************************************************************************************************************
    * @description Tests updating a Contact with a Custom Email field  in English Language  updates Preferred Email and
    * standard Email with the custom email's label and value respectively when Preferred Email Enforcement is Enabled.
    *****************************************************************************************************************************/
    @isTest
    private static void populateCustomEmailOnUpdateEnglish() {

        CON_Pref_Email_Utility_MTST.populateCustomEmailOnUpdate('Custom_Email__c', 'test@sf.org');
    }

    /*****************************************************************************************************************************
    * @description Tests Updating a Contact with a Custom Email field and Preferred Email  in English Language  sets
    * Preferred Email field and updates standard Email with the custom email's value when Preferred Email Enforcement is Enabled.
    *****************************************************************************************************************************/
    @isTest
    private static void populateCustomAndPrefEmailOnUpdateEnglish() {

        CON_Pref_Email_Utility_MTST.populateCustomAndPrefEmailOnUpdate('Custom_Email__c', 'test@sf.org');
    }

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with Preferred Email and setting no Email fields  in English Language  will throw 
    * 'PreferredEmailMatchNotNull' Error when Preferred Email Enforcement is Enabled.
    *****************************************************************************************************************************/
    @isTest
    private static void customEmailEmptyOnUpdateOnEnglish() {

        CON_Pref_Email_Utility_MTST.customEmailEmptyOnUpdate('Custom_Email__c', 'test@sf.org');
    }

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with Custom Email as Preferred Email and and an EDA Email field
    *  in English Language  will throw PreferredEmailRequiredError Error when Preferred Email Enforcement is Enabled.
    *****************************************************************************************************************************/
    @isTest
    private static void populateCustomEmailAndAlternateEmailOnUpdateOnEnglish() {

        CON_Pref_Email_Utility_MTST.populateCustomEmailAndAlternateEmailOnUpdate('Custom_Email__c', 'test@sf.org');
    }

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with Preferred Email and no Email fields  in English Language  will not throw an error
    * when Preferred Email Enforcement is enabled.
    *****************************************************************************************************************************/
    @isTest
    private static void populateCustomEmailWithEnforcementDisbaledOnUpdateEnglish() {

        CON_Pref_Email_Utility_MTST.populateCustomEmailWithEnforcementDisbaledOnupdate('Custom_Email__c', 'test@sf.org');
    }
}