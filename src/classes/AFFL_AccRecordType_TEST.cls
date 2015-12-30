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
* @group Affiliation Management
* @description Tests specific to Affiliation Management when an Account that
* is part of one or more Affiliation changes. 
*/
@isTest
public with sharing class AFFL_AccRecordType_TEST {

    private static ID orgRecTypeID;
    private static ID householdRecTypeID;
    
    public static void setup() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR));
                
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Primary Business Organization'));  
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = 'Primary Household'));
        insert mappings;
        
        orgRecTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Business Organization').getRecordTypeId();
        householdRecTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
    }
    
    @isTest
    public static void changePrimaryAffiliationRecordType() {        
        setup();

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;
        
        //Verify default household account has been created for the contact
        contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
        System.assertNotEquals(null, contact.Account.ID);
        System.assertEquals(null, contact.Primary_Household__c);
        
        //Manually create an Affiliation to the household, since we are not automatically doing so any more.
        insert new Affiliation__c(Contact__c = contact.ID, Account__c = contact.Account.ID, Primary__c = true);

        //Verify the primary household field was populated
        contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
        System.assertNotEquals(null, contact.Primary_Household__c);
        
        Account acc = [select RecordTypeId from Account where ID=:contact.Account.ID];
        //Change the account record type to Business Organization
        acc.RecordTypeId = orgRecTypeID;
        Test.startTest();
        AFFL_MultiRecordType_TDTM.afflMultiHasRunBefore = false;
        update acc;
        Test.stopTest();
        
        contact = [select Primary_Household__c, Primary_Organization__c from Contact where ID=:contact.Id];
        //Verify primary household field has been cleared
        System.assertEquals(null, contact.Primary_Household__c);
        //Verify primary business organization field has been populated
        System.assertEquals(acc.ID, contact.Primary_Organization__c);
    }
    
    @isTest
    public static void changePrimaryAffiliationRecordTypeTwoAccs() {        
        setup();

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;
        
        //Verify default household account has been created for the contact
        contact = [select Account.ID, Primary_Household__c, Primary_Organization__c from Contact where ID =:Contact.ID];
        System.assertNotEquals(null, contact.Account.ID);
        System.assertEquals(null, contact.Primary_Household__c);
        
        //Manually create an Affiliation to the household, since we are not automatically doing so any more.
        insert new Affiliation__c(Contact__c = contact.ID, Account__c = contact.Account.ID, Primary__c = true);

        //Verify the primary household field was populated
        contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
        System.assertNotEquals(null, contact.Primary_Household__c);
        
        //Create primary Affl to a Business Organization
        Account bizOrg = new Account(Name = 'BizOrg', RecordTypeId = orgRecTypeID);
        insert bizOrg;
        Affiliation__c bizAffl = new Affiliation__c(Contact__c = contact.ID, Account__c = bizOrg.ID, Primary__c = true);
        AFFL_MultiRecordType_TDTM.afflMultiHasRunBefore = false;
        insert bizAffl;
        
        //Verify the primary business organization field was populated
        contact = [select Account.ID, Primary_Household__c, Primary_Organization__c from Contact where ID =:Contact.ID];
        System.assertEquals(bizOrg.ID, contact.Primary_Organization__c);
        
        Account household = [select RecordTypeId from Account where ID=:contact.Account.ID];
        //Change the account record type of the household to Business Organization, and of the biz org to Household
        household.RecordTypeId = orgRecTypeID;
        bizOrg.RecordTypeId = householdRecTypeID;
        Test.startTest();
        AFFL_MultiRecordType_TDTM.afflMultiHasRunBefore = false;
        update new Account[]{household, bizOrg};
        Test.stopTest();
        
        contact = [select Primary_Household__c, Primary_Organization__c from Contact where ID=:contact.Id];
        //Verify primary household field has changed to the biz org
        System.assertEquals(bizOrg.ID, contact.Primary_Household__c);
        //Verify primary business organization field has changed to the household
        System.assertEquals(household.ID, contact.Primary_Organization__c);
    }
    
    @isTest
    public static void otherPrimaryNotPrimary() {        
        setup();

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;
        
        //Verify default household account has been created for the contact
        contact = [select Account.ID, Primary_Household__c, Primary_Organization__c from Contact where ID =:Contact.ID];
        System.assertNotEquals(null, contact.Account.ID);
        System.assertEquals(null, contact.Primary_Household__c);
        
        //Manually create an Affiliation to the household, since we are not automatically doing so any more
        insert new Affiliation__c(Contact__c = contact.ID, Account__c = contact.Account.ID, Primary__c = true);

        //Verify the primary household field was populated
        contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
        System.assertNotEquals(null, contact.Primary_Household__c);
        
        //Create primary Affl to a Business Organization
        Account bizOrg = new Account(Name = 'BizOrg', RecordTypeId = orgRecTypeID);
        insert bizOrg;
        UTIL_Debug.debug('****Biz org ID: ' + bizOrg.ID);
        Affiliation__c bizAffl = new Affiliation__c(Contact__c = contact.ID, Account__c = bizOrg.ID, Primary__c = true);
        AFFL_MultiRecordType_TDTM.afflMultiHasRunBefore = false;
        insert bizAffl;
        
        //Verify the primary business organization field was populated
        contact = [select Account.ID, Primary_Household__c, Primary_Organization__c from Contact where ID =:Contact.ID];
        System.assertEquals(bizOrg.ID, contact.Primary_Organization__c);
        
        Account household = [select RecordTypeId from Account where ID=:contact.Account.ID];
        UTIL_Debug.debug('****Household ID: ' + household.ID);
        //Change the account record type of parent Household to Business Organization
        household.RecordTypeId = orgRecTypeID;
        Test.startTest();
        AFFL_MultiRecordType_TDTM.afflMultiHasRunBefore = false;
        update household;
        Test.stopTest();
        
        contact = [select Primary_Household__c, Primary_Organization__c from Contact where ID=:contact.Id];
        //Verify primary household field has been cleared
        System.assertEquals(null, contact.Primary_Household__c);
        //Verify primary business organization field has changed to the household
        System.assertEquals(household.ID, contact.Primary_Organization__c);

        //Verify the old primary business affiliation is not primary now
        bizAffl = [select Primary__c from Affiliation__c where ID = :bizAffl.ID];
        System.assertEquals(false, bizAffl.Primary__c);
    }
    
    //WARNING: this test will fail is the default Account record type for the system administrator profile (which is the
    //one the test runs under) is Business Organization, as the bizOrg record will be of that type even if we don't assign
    //it explicitly.
    @isTest
    public static void addRecordTypeToAcc() {        
        setup();
       
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;
       
        //Create primary Affl to Account without record type
        Account bizOrg = new Account(Name = 'BizOrg');
        insert bizOrg;
        Affiliation__c bizAffl = new Affiliation__c(Contact__c = contact.ID, Account__c = bizOrg.ID, Primary__c = true);
        AFFL_MultiRecordType_TDTM.afflMultiHasRunBefore = false;
        insert bizAffl;
        
        //Verify Primary Business Organization field was not populated
        contact = [select Primary_Organization__c from Contact where ID=:contact.Id];
        System.assertEquals(null, contact.Primary_Organization__c);
        
        //Give record type to that Account
        bizOrg.RecordTypeId = orgRecTypeID;
        Test.startTest();
        update bizOrg;
        Test.stopTest();
        
        //Verify Primary Business Organization field was populated
        contact = [select Primary_Organization__c from Contact where ID=:contact.Id];
        System.assertEquals(bizOrg.ID, contact.Primary_Organization__c);
    }
}