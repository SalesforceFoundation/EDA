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
* @group Affiliations
* @group-content ../../ApexDocContent/Affiliations.htm
* @description Tests specific to Affiliation Management when an Account that
* is part of one or more Affiliation changes. 
*/
@isTest
public with sharing class AFFL_AccRecordType_TEST {

    private static ID orgRecTypeID;
    private static ID householdRecTypeID;
    
    public static void setup() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID()));

        STG_InstallScript.insertMappings();
        
        orgRecTypeID = UTIL_Describe_API.getBizAccRecTypeID();
        householdRecTypeID = UTIL_Describe_API.getHhAccRecTypeID();
    }
    
    @isTest
    public static void changePrimaryAffiliationRecordType() {        
        setup();

        Contact contact = UTIL_UnitTestData_API.getContact();
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
        
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary, false);
        Account acc = [select RecordTypeId from Account where ID=:contact.Account.ID];
        //Change the account record type to Business Organization
        acc.RecordTypeId = orgRecTypeID;
        Test.startTest();
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

        Contact contact = UTIL_UnitTestData_API.getContact();
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
        Account bizOrg = UTIL_UnitTestData_API.getMultipleTestAccounts(1, orgRecTypeID)[0];
        insert bizOrg;
        Affiliation__c bizAffl = new Affiliation__c(Contact__c = contact.ID, Account__c = bizOrg.ID, Primary__c = true);
        insert bizAffl;
        
        //Verify the primary business organization field was populated
        contact = [select Account.ID, Primary_Household__c, Primary_Organization__c from Contact where ID =:Contact.ID];
        System.assertEquals(bizOrg.ID, contact.Primary_Organization__c);
        
        Account household = [select RecordTypeId from Account where ID=:contact.Account.ID];
        //Change the account record type of the household to Business Organization, and of the biz org to Household
        household.RecordTypeId = orgRecTypeID;
        bizOrg.RecordTypeId = householdRecTypeID;
        Test.startTest();
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary, false);
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

        Contact contact = UTIL_UnitTestData_API.getContact();
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
        Account bizOrg = UTIL_UnitTestData_API.getMultipleTestAccounts(1, orgRecTypeID)[0];
        insert bizOrg;
        UTIL_Debug.debug('****Biz org ID: ' + bizOrg.ID);
        Affiliation__c bizAffl = new Affiliation__c(Contact__c = contact.ID, Account__c = bizOrg.ID, Primary__c = true);
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_Before_Insert, false);
        insert bizAffl;
        
        //Verify the primary business organization field was populated
        contact = [select Account.ID, Primary_Household__c, Primary_Organization__c from Contact where ID =:Contact.ID];
        System.assertEquals(bizOrg.ID, contact.Primary_Organization__c);
        
        Account household = [select RecordTypeId from Account where ID=:contact.Account.ID];
        UTIL_Debug.debug('****Household ID: ' + household.ID);
        //Change the account record type of parent Household to Business Organization
        household.RecordTypeId = orgRecTypeID;
        Test.startTest();
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary, false);
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

    @isTest
    public static void addRecordTypeToAcc() {        
        setup();
       
        Contact contact = UTIL_UnitTestData_API.getContact();
        insert contact;
       
        //Create primary Affl to Account without record type - since the account created will have the record type assigned
        //to the profile running the tests as default, we assign a different type to it. Profiles cannot be created in tests.
        Account acc = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getAdminAccRecTypeID())[0];
        insert acc;
        Affiliation__c affl = new Affiliation__c(Contact__c = contact.ID, Account__c = acc.ID, Primary__c = true);
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_Before_Insert, false);
        insert affl;
        
        //Verify Primary Business Organization field was not populated
        contact = [select Primary_Organization__c from Contact where ID=:contact.Id];
        System.assertEquals(null, contact.Primary_Organization__c);
        
        //Give record type to that Account
        acc.RecordTypeId = orgRecTypeID;
        Test.startTest();
        update acc;
        Test.stopTest();
        
        //Verify Primary Business Organization field was populated
        contact = [select Primary_Organization__c from Contact where ID=:contact.Id];
        System.assertEquals(acc.ID, contact.Primary_Organization__c);
    }

    @isTest
    public static void updateAdminAccRecordTypeBulk() {
        setup();

        //Create some Accounts with Admin record type
        List<Account> adminAccList = UTIL_UnitTestData_API.getMultipleTestAccounts(10, UTIL_Describe_API.getAdminAccRecTypeID());
        insert adminAccList;

        List<Account> theAccs = [Select Id from Account where RecordTypeId =: UTIL_Describe_API.getAdminAccRecTypeID()];
        system.assertEquals(10, theAccs.size());

        //Change the record type of the Accounts to Biz type and HH type
        for(Integer i = 0 ; i < 10; i++) {
            if(i < 5) {
                theAccs[i].RecordTypeId = orgRecTypeID;
            } else {
                theAccs[i].RecordTypeId = householdRecTypeID;
            }
        }

        //Update Accounts in bulk. It shouldn't throw any error
        Test.startTest();
        update theAccs;
        Test.stopTest();

        List<Account> orgAccounts = [Select Id from Account where RecordTypeId =: orgRecTypeID];
        system.assertEquals(5, orgAccounts.size());

        List<Account> hhAccounts = [Select Id from Account where RecordTypeId =: householdRecTypeID];
        system.assertEquals(5, hhAccounts.size());
    }

    @isTest
    public static void fillInPrimaryFieldForContacts() {
        setup();

        //Create Contacts
        Contact john = UTIL_UnitTestData_API.getContact();
        Contact mark = UTIL_UnitTestData_API.getContact();
        List<Contact> contacts = new List<Contact>{john, mark};
        insert contacts;

        //Create Accounts with Admin Record Type
        Account company = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getAdminAccRecTypeID())[0];
        Account hh = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getAdminAccRecTypeID())[0];
        List<Account> accs = new List<Account>{company, hh};
        insert accs;

        //Create Affiliations
        Affiliation__c companyAffl = new Affiliation__c(Contact__c = john.ID, Account__c = company.ID, Primary__c = true);
        Affiliation__c hhAffl = new Affiliation__c(Contact__c = mark.ID, Account__c = hh.ID, Primary__c = true);
        List<Affiliation__c> affls = new List<Affiliation__c>{companyAffl, hhAffl};
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_Before_Insert,false);
        insert affls;

        //Now Update the Account Record Type
        Account companyWithCorrectType = new Account(Id = company.Id, RecordTypeId = orgRecTypeID);
        Account hhWithCorrectType = new Account(Id = hh.Id, RecordTypeId = householdRecTypeID);
        List<Account> accsForUpdate = new List<Account>{companyWithCorrectType, hhWithCorrectType};

        Test.startTest();
        update accsForUpdate;
        Test.stopTest();

        //Verify that the Primary Fields on Contacts get populated correctly
        Contact johnUpdated = [Select Primary_Household__c, Primary_Organization__c from Contact where Id =: john.Id];
        system.assertEquals(null, johnUpdated.Primary_Household__c);
        system.assertEquals(company.Id, johnUpdated.Primary_Organization__c);

        Contact markUpdated = [Select Primary_Household__c, Primary_Organization__c from Contact where Id =: mark.Id];
        system.assertEquals(hh.id, markUpdated.Primary_Household__c);
        system.assertEquals(null, markUpdated.Primary_Organization__c);
    }
}