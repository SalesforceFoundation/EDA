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
    private static Contact contact1;
    private static Contact contact2;
    private static Account bizOrg1;
    private static Account bizOrg2;
    private static Account householdOrg1;
    private static Affiliation__c bizAffl1;

    private static void dataSetup() {

        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID()));

        orgRecTypeID = UTIL_Describe_API.getBizAccRecTypeID();
        householdRecTypeID = UTIL_Describe_API.getHhAccRecTypeID();

        STG_InstallScript.insertMappings();

        contact1 = new Contact(FirstName = 'Test', LastName = 'Testerson');
        contact2 = new Contact(FirstName = 'Test2', LastName = 'Testerson2');
        insert new Contact[] {contact1, contact2};
        
        //Create accounts of Business Organization record type
        bizOrg1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        bizOrg2 = new Account(Name='Acme2', RecordTypeId = orgRecTypeID);
        householdOrg1 = new Account(Name='AcmeHousehold2', RecordTypeId = householdRecTypeID);
        insert new Account[] {bizOrg1, bizOrg2, householdOrg1};

        //Create primary affiliation
        bizAffl1 = new Affiliation__c(Contact__c=contact1.ID, Account__c=bizOrg1.ID, Primary__c=true);
        resetAfflFlags();
        insert bizAffl1;
    }
    
    @isTest
    public static void changeContact() {
        dataSetup();
        Account bizAcct = [SELECT Id FROM Account WHERE ID = :bizOrg1.Id];
        
        //Confirm Primary Business Organization field has been populated in contact
        Contact con1 = [SELECT Primary_Organization__c FROM Contact WHERE ID = :contact1.ID];
        Contact con2 = [SELECT Primary_Organization__c FROM Contact WHERE ID = :contact2.ID];

        Affiliation__c affl1 = [SELECT Account__c FROM Affiliation__c WHERE Contact__c =: con1.ID AND Account__c =: bizAcct.ID];

        System.assertEquals(con1.Primary_Organization__c, affl1.Account__c, 'Primary Org Does Not Match');
        
        //Update primary affiliation to point to a different contact
        affl1.Contact__c = con2.ID;

        //resetAfflFlags();

        Test.startTest();
        update affl1;
        Test.stopTest();
        
        //Confirm Primary Business Organization field has been cleared in contact
        Contact updatedContact = [SELECT Primary_Organization__c from Contact where ID =:con1.ID];
        System.assertEquals(null, updatedContact.Primary_Organization__c);
        
        //Confirm Primary Business Organization field has been populated in contact2
        Contact updatedContact2 = [SELECT Primary_Organization__c FROM Contact where ID =:con2.ID];
        System.assertEquals(affl1.Account__c, updatedcontact2.Primary_Organization__c);

        //Make sure we are not creating duplicate affiliations
        List<Affiliation__c> affls = [select Id from Affiliation__c];
        System.assertEquals(1, affls.size());
    }
    
    @isTest
    public static void clearContact() {
        dataSetup();
        Contact con = [SELECT Primary_Organization__c FROM Contact WHERE ID = :contact1.Id];
        Account bizAcct = [SELECT Id FROM Account WHERE ID = :bizOrg1.Id];
        Affiliation__c affl1 = [SELECT Account__c FROM Affiliation__c WHERE Contact__c = :con.ID AND Account__c = :bizAcct.ID];
        
        //Clear contact
        affl1.Contact__c = null;
        Test.startTest();
        update affl1;
        Test.stopTest();
        
        //Confirm Primary Business Organization field has been cleared in contact
        Contact updatedContact = [SELECT Primary_Organization__c FROM Contact where ID =:con.ID];
        System.assertEquals(null, updatedContact.Primary_Organization__c);
    }
    
    @isTest
    public static void changeAccountSameType() {
        dataSetup();
        Contact con = [SELECT Primary_Organization__c FROM Contact WHERE ID = :contact1.Id];
        Account bizAcct1 = [SELECT Id FROM Account WHERE ID = :bizOrg1.Id];
        Account bizAcct2 = [SELECT Id FROM Account WHERE ID = :bizOrg2.Id];
        
        Affiliation__c affl1 = [SELECT Account__c FROM Affiliation__c WHERE Contact__c =: con.ID AND Account__c =: bizAcct1.ID];
        
        //Change affiliation account
        affl1.Account__c = bizAcct2.ID;
        Test.startTest();
        update affl1;
        Test.stopTest();
        
        //Confirm primary field has been updated
        Contact updatedContact = [SELECT Primary_Organization__c FROM Contact where ID =:con.Id];
        System.assertEquals(bizAcct2.ID, updatedContact.Primary_Organization__c);

        //Make sure we are not creating duplicate affiliations
        List<Affiliation__c> affls = [select Id from Affiliation__c];
        System.assertEquals(1, affls.size());
    }
    
    @isTest
    public static void changeAccountDifferentType() {
        dataSetup();
        Contact contact = [SELECT Primary_Organization__c FROM Contact WHERE ID = :contact1.Id];

        Account bizAcct1 = [SELECT Id FROM Account WHERE ID = :bizOrg1.Id];
        Account houseAcct1 = [SELECT Id FROM Account WHERE ID = :householdOrg1.Id];

        //Get primary affiliation
        Affiliation__c affl1 = [SELECT Account__c FROM Affiliation__c WHERE Contact__c =: contact.ID AND Account__c =: bizAcct1.ID];
        
        //Change affiliation account
        affl1.Account__c = houseAcct1.ID;
        Test.startTest();
        update affl1;
        Test.stopTest();
        
        //Confirm primary field has been updated
        Contact updatedContact = [SELECT Primary_Organization__c, Primary_Household__c FROM Contact where ID =:contact.ID];
        System.assertEquals(null, updatedContact.Primary_Organization__c);
        System.assertEquals(householdOrg1.ID, updatedContact.Primary_Household__c);

        //Make sure we are not creating duplicate affiliations
        List<Affiliation__c> affls = [select Id from Affiliation__c];
        System.assertEquals(1, affls.size());
    }
    
    @isTest
    public static void clearAccount() {
        dataSetup();
        Contact contact = [SELECT Primary_Organization__c from Contact WHERE ID = :contact1.Id];
        Account bizAcct1 = [SELECT Id FROM Account WHERE ID = :bizOrg1.Id];
        Affiliation__c affl1 = [SELECT Account__c FROM Affiliation__c WHERE Contact__c =: contact.ID AND Account__c =: bizAcct1.ID];
        
        //Clear affiliation account
        affl1.Account__c = null;
        Test.startTest();
        update affl1;
        Test.stopTest();
        
        //Confirm primary field has been cleared
        Contact updatedContact = [SELECT Primary_Organization__c FROM Contact where ID =:contact.ID];
        System.assertEquals(null, updatedContact.Primary_Organization__c);
    }
    
    public static void resetAfflFlags() {
        TDTM_ProcessControl.resetRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_ContactChange_TDTM);
        
        TDTM_ProcessControl.resetRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_keyAfflLookupUpdated);
        TDTM_ProcessControl.resetRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Insert);
        TDTM_ProcessControl.resetRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Update);
        
        TDTM_ProcessControl.resetRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_afflMadePrimary);
        TDTM_ProcessControl.resetRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_Before_Insert);
        TDTM_ProcessControl.resetRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_After_Update);
    }    
}