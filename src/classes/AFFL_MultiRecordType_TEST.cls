/*
    Copyright (c) 2014, Salesforce.com Foundation
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Salesforce.com Foundation nor the names of
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
* @author Salesforce.com Foundation
* @date 2013
* @group Affiliation Management
* @description Tests specific to Affiliation Management. 
*/
@isTest
public with sharing class AFFL_MultiRecordType_TEST {
	
	private static ID orgRecTypeID;
	private static ID householdRecTypeID;
	
	// if you only want to run one test in this class, fill in its name here.
    // if you want to run all tests, then use '*'
    private static string strTestOnly = '*';
    
	public static void setup() {
		UTIL_CustomSettingsFacade.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c(Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR));
            
		UTIL_CustomSettingsFacade.getAffiliationsSettingsForTests(new Affiliations_Settings__c(Automatic_Affiliation_Creation_Turned_On__c = true));
		
		List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
    	mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Primary Business Organization'));	
    	mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = 'Primary Household'));
    	insert mappings;
    	
    	orgRecTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Business Organization').getRecordTypeId();
    	householdRecTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
	}
	
	@isTest
	public static void createPrimaryAffl() {
		if (strTestOnly != '*' && strTestOnly != 'createPrimaryAffl') return;
		
		setup();

    	Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
    	insert contact;
    	
    	//Verify default household account has been created for the contact
    	contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
    	System.assertNotEquals(null, contact.Account.ID);
    	
    	//Verify the primary household field was populated
    	System.assertEquals(contact.Account.ID, contact.Primary_Household__c);
    	
    	//Verify key houehold affiliation has been automatically created
    	List<Affiliation__c> affls = [select Affiliation_Type__c, Organization__c from Affiliation__c where Contact__c = :contact.ID];
    	System.assertEquals(1, affls.size());
    	System.assertEquals('Household Account', affls[0].Affiliation_Type__c);
    	System.assertEquals(contact.Account.ID, affls[0].Organization__c);
    	
    	//Craete account of Business Organization record type
    	Account bizOrg1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
    	insert bizOrg1;
    	
    	//Create abother key affiliation, this time to a biz org
		Affiliation__c bizAffl1 = new Affiliation__c(Contact__c = contact.ID, Organization__c = bizOrg1.ID, Primary__c = true);
		AFFL_MultiRecordType_TDTM.afflMultiHasRun = false; 
		Test.startTest();
		insert bizAffl1;
		Test.stopTest();
		
		//The business organization lookup should point to the account that is part of the affiliation we created
		bizAffl1 = [select Affiliation_Type__c from Affiliation__c where Organization__c = :bizOrg1.ID];
		System.assertEquals('Business Organization', bizAffl1.Affiliation_Type__c);
		
		contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
		System.assertEquals(bizOrg1.ID, Contact.Primary_Organization__c);
		
		//Create second account of the same record type
		Account bizOrg2 = new Account(Name='Toys Inc', RecordTypeId = orgRecTypeID);
    	insert bizOrg2;
		
		//Create second primary affiliation
		Affiliation__c bizAffl2 = new Affiliation__c(Contact__c = contact.ID, Organization__c = bizOrg2.ID, Primary__c = true);
		AFFL_MultiRecordType_TDTM.afflMultiHasRun = false;
		insert bizAffl2;
		
		//The previous affiliation should not be the primary any more
		bizAffl1 = [select Primary__c from Affiliation__c where ID = :bizAffl1.ID];
		System.assertEquals(false, bizAffl1.Primary__c);
		
		//The business organization lookup should point to the account that is part of the second affiliation we created
		contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
		System.assertEquals(bizOrg2.ID, Contact.Primary_Organization__c);
	}
	
	@isTest
	public static void deletePrimaryAffl() {
		if (strTestOnly != '*' && strTestOnly != 'deletePrimaryAffl') return;
		
		setup();

    	Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
    	insert contact;
    	
    	//Verify default household account has been created for the contact
    	contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
    	System.assertNotEquals(null, contact.Account.ID);
    	
    	//Verify the primary household field was populated
    	System.assertEquals(contact.Account.ID, contact.Primary_Household__c);
    	
    	//Verify key household affiliation has been automatically created
    	List<Affiliation__c> affls = [select Affiliation_Type__c, Organization__c from Affiliation__c where Contact__c = :contact.ID];
    	System.assertEquals(1, affls.size());
    	System.assertEquals('Household Account', affls[0].Affiliation_Type__c);
    	System.assertEquals(contact.Account.ID, affls[0].Organization__c);
    	
    	//Craete account of Business Organization record type
    	Account acc1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
    	insert acc1;
    	
    	//Create primary Business affiliation
		Affiliation__c affl1 = new Affiliation__c(Contact__c = contact.ID, Organization__c = acc1.ID, Primary__c = true);
		Test.startTest();
		AFFL_MultiRecordType_TDTM.afflMultiHasRun = false;
		insert affl1;
    	Test.stopTest();
    	
    	//Verify Primary Organization lookup field points to the account we just created
    	contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
		System.assertEquals(acc1.ID, Contact.Primary_Organization__c);
		
		//Delete Business affiliation
		AFFL_MultiRecordType_TDTM.afflMultiHasRun = false;
		delete affl1;
		
		//Verify Primary Organization lookup field has been cleared
		contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
		System.assertEquals(null, Contact.Primary_Organization__c);
	}
	
	@isTest
	public static void makePrimaryAfflNonPrimary() {
		if (strTestOnly != '*' && strTestOnly != 'makePrimaryAfflNonPrimary') return;
		
		setup();

    	Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
    	insert contact;
    	
    	//Verify default household account has been created for the contact
    	contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
    	System.assertNotEquals(null, contact.Account.ID);
    	ID parentAccountId = contact.Account.ID;
    	
    	//Verify the primary household field was populated
    	System.assertEquals(parentAccountId, contact.Primary_Household__c);
    	
    	//Verify key household affiliation has been automatically created
    	List<Affiliation__c> affls = [select Affiliation_Type__c, Organization__c, Primary__c from Affiliation__c where Contact__c = :contact.ID];
    	System.assertEquals(1, affls.size());
    	System.assertEquals('Household Account', affls[0].Affiliation_Type__c);
    	System.assertEquals(contact.Account.ID, affls[0].Organization__c);
    	System.assertEquals(true, affls[0].Primary__c);
    	
    	//Make the affiliation not primary
    	affls[0].Primary__c = false;
    	Test.startTest();
    	AFFL_MultiRecordType_TDTM.afflMultiHasRun = false;
    	update affls[0];
    	Test.stopTest();
    	
    	//Verify Primary_Household__c field has been cleared
    	contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
    	System.assertEquals(null, contact.Primary_Household__c);
    	
    	//Verify the contact is still the child of the same account
    	System.assertEquals(parentAccountId, contact.Account.ID);
	}
	
	@isTest
	public static void changePrimaryAffiliationRecordType() {
		if (strTestOnly != '*' && strTestOnly != 'changePrimaryAffiliationRecordType') return;
		
		setup();

    	Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
    	insert contact;
    	
    	//Verify default household account has been created for the contact
    	contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
    	System.assertNotEquals(null, contact.Account.ID);
    	
    	//Verify the primary household field was populated
    	System.assertEquals(contact.Account.ID, contact.Primary_Household__c);
    	
    	Account acc = [select RecordTypeId from Account where ID=:contact.Account.ID];
    	//Change the account record type to Business Organization
    	acc.RecordTypeId = orgRecTypeID;
    	Test.startTest();
    	AFFL_MultiRecordType_TDTM.afflMultiHasRun = false;
    	update acc;
    	Test.stopTest();
    	
    	contact = [select Primary_Household__c, Primary_Organization__c from Contact where ID=:contact.Id];
    	//Verify primary household field has been cleared
    	System.assertEquals(null, contact.Primary_Household__c);
    	//Verify primary business organization field has been populated
    	System.assertEquals(acc.ID, contact.Primary_Organization__c);
	}
}