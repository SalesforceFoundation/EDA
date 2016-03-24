/*
    Copyright (c) 2015, Salesforce.org
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
* @date 2015
* @group Contacts
* @group-content ../../ApexDocContent/Contacts.htm
* @description Test for Contact primary affilation fields functionality.
*/
@isTest
public with sharing class CON_PrimaryAffls_TEST {
    
    private static ID orgRecTypeID;
    private static ID householdRecTypeID;
    
    public static void setup() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getHhAccRecTypeID()));
                
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Primary Business Organization'));  
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = 'Primary Household'));
        insert mappings;
        
        orgRecTypeID = UTIL_Describe.getBizAccRecTypeID();
        householdRecTypeID = UTIL_Describe.getHhAccRecTypeID();
    }
    
    @isTest
    public static void newContactWithPrimaryAfflField() {        
        setup();
        
        //Create account of Business Organization record type
        Account bizOrg1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert bizOrg1;

        //Create contact with value in Primary Business Organization field
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson', Primary_Organization__c = bizOrg1.ID);
        Test.startTest();
        insert contact;
        Test.stopTest();
        
        //Verify key business affiliation has been automatically created
        List<Affiliation__c> affls = [select Affiliation_Type__c, Account__c, Primary__c from Affiliation__c 
                                        where Contact__c = :contact.ID and Account__c = :bizOrg1.ID];
        System.assertEquals(1, affls.size());
        System.assertEquals('Business Organization', affls[0].Affiliation_Type__c);
        System.assertEquals(true, affls[0].Primary__c);
    }
    
    @isTest
    public static void addingValToExistingPrimaryAfflField() {        
        setup();
        
        //Create account of Business Organization record type
        Account bizOrg1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert bizOrg1;

        //Create contact without value in Primary Business Organization field
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;
        
        //No business affiliation should have been created
        List<Affiliation__c> affls = [select Affiliation_Type__c, Account__c from Affiliation__c where Contact__c = :contact.ID 
                                        and Account__c = :bizOrg1.ID];
        System.assertEquals(0, affls.size());
        
        //Set primary affl field
        contact.Primary_Organization__c = bizOrg1.ID;
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        Test.startTest();
        update contact;
        Test.stopTest();
        
        //Verify key business affiliation has been automatically created
        affls = [select Affiliation_Type__c, Account__c, Primary__c from Affiliation__c where Contact__c = :contact.ID 
                                        and Account__c = :bizOrg1.ID];
        System.assertEquals(1, affls.size());
        System.assertEquals('Business Organization', affls[0].Affiliation_Type__c);
        System.assertEquals(true, affls[0].Primary__c);
    }
    
    @isTest
    public static void changingPrimaryAfflField() {        
        setup();
        
        //Create account of Business Organization record type
        Account bizOrg1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert bizOrg1;

        //Create contact with value in Primary Business Organization field
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson', Primary_Organization__c = bizOrg1.ID);
        insert contact;
        
        //Verify key business affiliation has been automatically created
        List<Affiliation__c> affls = [select Affiliation_Type__c, Account__c, Primary__c from Affiliation__c 
                                        where Contact__c = :contact.ID and Account__c = :bizOrg1.ID];
        System.assertEquals(1, affls.size());
        Affiliation__c affl1 = affls[0];
        System.assertEquals('Business Organization', affl1.Affiliation_Type__c);
        System.assertEquals(true, affl1.Primary__c);
        
        //Create second Business Organization
        Account bizOrg2 = new Account(Name='Acme 2', RecordTypeId = orgRecTypeID);
        insert bizOrg2;
        
        //update key Business Organization field in Contact
        contact.Primary_Organization__c = bizOrg2.ID;
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        Test.startTest();
        update contact;
        Test.stopTest();
        
        //Verify previous Affiliation has been made non-primary
        affl1 = [select Primary__c from Affiliation__c where ID = : affl1.ID];
        System.assertEquals(false, affl1.Primary__c);
        
        //Verify new Affiliation has been created and made primary
        affls = [select Affiliation_Type__c, Account__c, Primary__c from Affiliation__c where Contact__c = :contact.ID 
                                        and Account__c = :bizOrg2.ID];
        System.assertEquals(1, affls.size());
        System.assertEquals('Business Organization', affls[0].Affiliation_Type__c);
        System.assertEquals(true, affls[0].Primary__c);
    }
    
    @isTest
    public static void clearingPrimaryAfflField() {        
        setup();
        
        //Create account of Business Organization record type
        Account bizOrg1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert bizOrg1;

        //Create contact with value in Primary Business Organization field
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson', Primary_Organization__c = bizOrg1.ID);
        insert contact;
        
        //Verify key business affiliation has been automatically created
        List<Affiliation__c> affls = [select Affiliation_Type__c, Account__c from Affiliation__c where Contact__c = :contact.ID 
                                        and Account__c = :bizOrg1.ID];
        System.assertEquals(1, affls.size());
        System.assertEquals('Business Organization', affls[0].Affiliation_Type__c);
        
        //update key Business Organization field in Contact
        contact.Primary_Organization__c = null;
        AFFL_ContactAccChange_TEST.resetAfflFlags();
        Test.startTest();
        update contact;
        Test.stopTest();
        
        //Verify key business affiliation has been changed to non-primary
        affls = [select Affiliation_Type__c, Account__c, Primary__c from Affiliation__c where Contact__c = :contact.ID 
                                        and Account__c = :bizOrg1.ID];
        System.assertEquals(1, affls.size());
        System.assertEquals('Business Organization', affls[0].Affiliation_Type__c);
        System.assertEquals(false, affls[0].Primary__c);
    }
    
    @isTest
    public static void invalidFieldName() {        
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getHhAccRecTypeID()));
                
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', 
                                            Primary_Affl_Field__c = 'Primary Invalid Field'));  
        insert mappings;
        
        orgRecTypeID = UTIL_Describe.getBizAccRecTypeID();
        
        //Create account of Business Organization record type
        Account bizOrg1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert bizOrg1;
        
        //Create contact with value in Primary Business Organization field
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson', Primary_Organization__c = bizOrg1.ID);
        Test.startTest();
        insert contact;
        Test.stopTest();
        
        //Verify no key business affiliation has been automatically created
        List<Affiliation__c> affls = [select Affiliation_Type__c, Account__c from Affiliation__c where Contact__c = :contact.ID 
                                        and Account__c = :bizOrg1.ID];
        System.assertEquals(0, affls.size());
    }
}