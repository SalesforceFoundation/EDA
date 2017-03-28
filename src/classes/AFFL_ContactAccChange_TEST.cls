/*
    Copyright (c) 2016, Salesforce.org
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
* @date 2016
* @group Affiliations
* @group-content ../../ApexDocContent/Affiliations.htm
* @description Tests specific to changing Contact or Account in an Affiliation.
*/
@isTest
public with sharing class AFFL_ContactAccChange_TEST {

    private static ID orgRecTypeID;
    private static ID householdRecTypeID;

    @testSetup 
    static void dataSetup() {

        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getHhAccRecTypeID()));

        orgRecTypeID = UTIL_Describe.getBizAccRecTypeID();
        householdRecTypeID = UTIL_Describe.getHhAccRecTypeID();

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Primary Business Organization'));  
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = 'Primary Household'));
        insert mappings;

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        Contact contact2 = new Contact(FirstName = 'Test2', LastName = 'Testerson2');
        insert new Contact[] {contact, contact2};
        
        //Create accounts of Business Organization record type
        Account bizOrg1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        Account bizOrg2 = new Account(Name='Acme2', RecordTypeId = orgRecTypeID);
        Account householdOrg1 = new Account(Name='AcmeHousehold2', RecordTypeId = householdRecTypeID);
        insert new Account[] {bizOrg1, bizOrg2, householdOrg1};

        //Create primary affiliation
        Affiliation__c bizAffl1 = new Affiliation__c(Contact__c = contact.ID, Account__c = bizOrg1.ID, Primary__c = true);
        resetAfflFlags();
        insert bizAffl1;
    }
    
    @isTest
    public static void changeContact() {

        Account bizOrg1 = [SELECT Id FROM Account WHERE Name = 'Acme'];
        
        //Confirm Primary Business Organization field has been populated in contact
        Contact contact = [Select Primary_Organization__c from Contact WHERE FirstName = 'Test' AND Lastname = 'Testerson'];
        Contact contact2 = [Select Primary_Organization__c from Contact WHERE FirstName = 'Test2' AND Lastname = 'Testerson2'];

        Affiliation__c bizAffl1 = [SELECT Account__c FROM Affiliation__c WHERE Contact__c =: contact.ID AND Account__c =: bizOrg1.ID];

        System.assertEquals(contact.Primary_Organization__c, bizAffl1.Account__c);
        
        //Update primary affiliation to point to a different contact
        bizAffl1.Contact__c = contact2.ID;

        //resetAfflFlags();

        Test.startTest();
        update bizAffl1;
        Test.stopTest();
        
        //Confirm Primary Business Organization field has been cleared in contact
        contact = [select Primary_Organization__c from Contact where ID =:contact.ID];
        System.assertEquals(null, contact.Primary_Organization__c);
        
        //Confirm Primary Business Organization field has been populated in contact2
        contact2 = [select Primary_Organization__c from Contact where ID =:contact2.ID];
        System.assertEquals(bizAffl1.Account__c, contact2.Primary_Organization__c);
    }
    
    @isTest
    public static void clearContact() {
        Contact contact = [Select Primary_Organization__c from Contact WHERE FirstName = 'Test' AND Lastname = 'Testerson'];
        Account bizOrg1 = [SELECT Id FROM Account WHERE Name = 'Acme'];
        Affiliation__c bizAffl1 = [SELECT Account__c FROM Affiliation__c WHERE Contact__c =: contact.ID AND Account__c =: bizOrg1.ID];
        
        //Clear contact
        bizAffl1.Contact__c = null;
        Test.startTest();
        update bizAffl1;
        Test.stopTest();
        
        //Confirm Primary Business Organization field has been cleared in contact
        contact = [select Primary_Organization__c from Contact where ID =:contact.ID];
        System.assertEquals(null, contact.Primary_Organization__c);
    }
    
    @isTest
    public static void changeAccountSameType() {
        Contact contact = [Select Primary_Organization__c from Contact WHERE FirstName = 'Test' AND Lastname = 'Testerson'];
        Account bizOrg1 = [SELECT Id FROM Account WHERE Name = 'Acme'];
        Account bizOrg2 = [SELECT Id FROM Account WHERE Name = 'Acme2'];
        
        Affiliation__c bizAffl1 = [SELECT Account__c FROM Affiliation__c WHERE Contact__c =: contact.ID AND Account__c =: bizOrg1.ID];
        
        //Change affiliation account
        bizAffl1.Account__c = bizOrg2.ID;
        Test.startTest();
        update bizAffl1;
        Test.stopTest();
        
        //Confirm primary field has been updated
        contact = [select Primary_Organization__c from Contact where ID =:contact.ID];
        System.assertEquals(bizOrg2.ID, contact.Primary_Organization__c);
    }
    
    @isTest
    public static void changeAccountDifferentType() {

        Contact contact = [Select Primary_Organization__c from Contact WHERE FirstName = 'Test' AND Lastname = 'Testerson'];

        Account bizOrg1 = [SELECT Id FROM Account WHERE Name = 'Acme'];
        Account householdOrg1 = [SELECT Id FROM Account WHERE Name = 'AcmeHousehold2'];

        //Get primary affiliation
        Affiliation__c bizAffl1 = [SELECT Account__c FROM Affiliation__c WHERE Contact__c =: contact.ID AND Account__c =: bizOrg1.ID];
        
        //Change affiliation account
        bizAffl1.Account__c = householdOrg1.ID;
        Test.startTest();
        update bizAffl1;
        Test.stopTest();
        
        //Confirm primary field has been updated
        contact = [select Primary_Organization__c, Primary_Household__c from Contact where ID =:contact.ID];
        System.assertEquals(null, contact.Primary_Organization__c);
        System.assertEquals(householdOrg1.ID, contact.Primary_Household__c);
    }
    
    @isTest
    public static void clearAccount() {

        Contact contact = [Select Primary_Organization__c from Contact WHERE FirstName = 'Test' AND Lastname = 'Testerson'];
        Account bizOrg1 = [SELECT Id FROM Account WHERE Name = 'Acme'];
        Affiliation__c bizAffl1 = [SELECT Account__c FROM Affiliation__c WHERE Contact__c =: contact.ID AND Account__c =: bizOrg1.ID];
        
        //Clear affiliation account
        bizAffl1.Account__c = null;
        Test.startTest();
        update bizAffl1;
        Test.stopTest();
        
        //Confirm primary field has been cleared
        contact = [select Primary_Organization__c from Contact where ID =:contact.ID];
        System.assertEquals(null, contact.Primary_Organization__c);
    }
    
    public static void resetAfflFlags() {
        AFFL_ContactChange_TDTM.afflContactChangeAlreadyRun = false;
        
        CON_PrimaryAffls_TDTM.keyAfflLookupUpdated = false;
        CON_PrimaryAffls_TDTM.alreadyRunAfterInsert = false;
        CON_PrimaryAffls_TDTM.alreadyRunBeforeUpdate = false;
        
        AFFL_MultiRecordType_TDTM.afflMadePrimary = false;
        AFFL_MultiRecordType_TDTM.afflMultiHasRunBefore = false;
        AFFL_MultiRecordType_TDTM.afflMultiHasRunAfter = false;
    }    
}