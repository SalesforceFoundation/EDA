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
* @description Tests specific to Affiliation Management. 
*/
@isTest
public with sharing class AFFL_MultiRecordType_TEST {
	
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
	public static void createPrimaryAffl() {		
		setup();

    	Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
    	insert contact;
    	
    	//Verify default household account has been created for the contact
    	contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
    	System.assertNotEquals(null, contact.Account.ID);
    	System.assertEquals(null, contact.Primary_Household__c);
        
        //Manually create an Affiliation to the household, since we are not automatically doing so any more
        insert new Affiliation__c(AfflContact__c = contact.ID, AfflAccount__c = contact.Account.ID, Primary__c = true);

        //Verify the primary household field was populated
        contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
        System.assertNotEquals(null, contact.Primary_Household__c);
    	
    	//Create account of Business Organization record type
    	Account bizOrg1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
    	insert bizOrg1;
    	
    	//Create another key affiliation, this time to a biz org
		Affiliation__c bizAffl1 = new Affiliation__c(AfflContact__c = contact.ID, AfflAccount__c = bizOrg1.ID, Primary__c = true);
		AFFL_MultiRecordType_TDTM.afflMultiHasRunBefore = false;
		Test.startTest();
		insert bizAffl1;
		Test.stopTest();
		
		//The business organization lookup should point to the account that is part of the affiliation we created
		bizAffl1 = [select Affiliation_Type__c from Affiliation__c where AfflAccount__c = :bizOrg1.ID];
		System.assertEquals('Business Organization', bizAffl1.Affiliation_Type__c);
		
		contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
		System.assertEquals(bizOrg1.ID, Contact.Primary_Organization__c);
		
		//Create second account of the same record type
		Account bizOrg2 = new Account(Name='Toys Inc', RecordTypeId = orgRecTypeID);
    	insert bizOrg2;
		
		//Create second primary affiliation
		Affiliation__c bizAffl2 = new Affiliation__c(AfflContact__c = contact.ID, AfflAccount__c = bizOrg2.ID, Primary__c = true);
		AFFL_MultiRecordType_TDTM.afflMultiHasRunBefore = false;
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
		setup();

    	Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
    	insert contact;
    	
    	//Verify default household account has been created for the contact
    	contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
    	System.assertNotEquals(null, contact.Account.ID);
    	System.assertEquals(null, contact.Primary_Household__c);
        
        //Manually create an Affiliation to the household, since we are not automatically doing so any more.
        insert new Affiliation__c(AfflContact__c = contact.ID, AfflAccount__c = contact.Account.ID, Primary__c = true);

        //Verify the primary household field was populated
        contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
        System.assertNotEquals(null, contact.Primary_Household__c);
    	
    	//Craete account of Business Organization record type
    	Account acc1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
    	insert acc1;
    	
    	//Create primary Business affiliation
		Affiliation__c affl1 = new Affiliation__c(AfflContact__c = contact.ID, AfflAccount__c = acc1.ID, Primary__c = true);
		Test.startTest();
		AFFL_MultiRecordType_TDTM.afflMultiHasRunBefore = false;
		insert affl1;
    	Test.stopTest();
    	
    	//Verify Primary Organization lookup field points to the account we just created
    	contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
		System.assertEquals(acc1.ID, Contact.Primary_Organization__c);
		
		//Delete Business affiliation
		AFFL_MultiRecordType_TDTM.afflMultiHasRunBefore = false;
		delete affl1;
		
		//Verify Primary Organization lookup field has been cleared
		contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
		System.assertEquals(null, Contact.Primary_Organization__c);
	}
	
	@isTest
	public static void makePrimaryAfflNonPrimary() {		
		setup();

    	Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
    	insert contact;
    	
    	//Verify default household account has been created for the contact
    	contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
    	System.assertNotEquals(null, contact.Account.ID);
    	ID parentAccountId = contact.Account.ID;
    	System.assertEquals(null, contact.Primary_Household__c);
        
        //Manually create an Affiliation to the household, since we are not automatically doing so any more.
        Affiliation__c affl = new Affiliation__c(AfflContact__c = contact.ID, AfflAccount__c = contact.Account.ID, Primary__c = true);
        insert affl;

        //Verify the primary household field was populated
        contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
        System.assertNotEquals(null, contact.Primary_Household__c);

    	//Make the affiliation not primary
    	affl.Primary__c = false;
    	Test.startTest();
    	AFFL_MultiRecordType_TDTM.afflMultiHasRunBefore = false;
    	update affl;
    	Test.stopTest();
    	
    	//Verify Primary_Household__c field has been cleared
    	contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
    	System.assertEquals(null, contact.Primary_Household__c);
    	
    	//Verify the contact is still the child of the same account
    	System.assertEquals(parentAccountId, contact.Account.ID);
	}
	
	@isTest
	public static void makeNonPrimaryAfflPrimary() {
		setup();

    	Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
    	insert contact;
    	
    	//Create account of Business Organization record type
    	Account acc1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
    	insert acc1;
    	
    	//Create non-primary Business affiliation
		Affiliation__c affl1 = new Affiliation__c(AfflContact__c = contact.ID, AfflAccount__c = acc1.ID, Primary__c = false);
		AFFL_MultiRecordType_TDTM.afflMultiHasRunBefore = false;
		insert affl1;
		
		//Verify Primary Organization lookup field is blank
    	contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
		System.assertEquals(null, Contact.Primary_Organization__c);
		
		//Make the business affiliation primary
		affl1.Primary__c = true;
		AFFL_MultiRecordType_TDTM.afflMultiHasRunBefore = false;
		CON_PrimaryAffls_TDTM.alreadyRunAfterInsert = false;
		Test.startTest();
		update affl1;
		Test.stopTest();
		
		//Verify key affl field has been populated
    	contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
		System.assertEquals(acc1.ID, Contact.Primary_Organization__c);
		
		//No other affiliation should have been created (bug W-008631)
        List<Affiliation__c> affls = [select ID from Affiliation__c where AfflContact__c = :contact.ID];
        System.assertEquals(1, affls.size());
	}
	
	@isTest
	public static void makeNonPrimaryAfflPrimaryWhenAnotherPrimaryExists() {		
		setup();

    	Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
    	insert contact;
    	
    	//Create 2 accounts of Business Organization record type
    	Account acc1 = new Account(Name='Acme1', RecordTypeId = orgRecTypeID);
    	Account acc2 = new Account(Name='Acme2', RecordTypeId = orgRecTypeID);
    	insert new Account[] {acc1, acc2};
    	
    	//Create primary Business affiliation
		Affiliation__c affl1 = new Affiliation__c(AfflContact__c = contact.ID, AfflAccount__c = acc1.ID, Primary__c = true);
		AFFL_MultiRecordType_TDTM.afflMultiHasRunBefore = false;
		insert affl1;
		
		//Verify key affl field has been populated
    	contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
		System.assertEquals(acc1.ID, Contact.Primary_Organization__c);
		
    	//Create non-primary Business affiliation
		Affiliation__c affl2 = new Affiliation__c(AfflContact__c = contact.ID, AfflAccount__c = acc2.ID, Primary__c = false);
		AFFL_MultiRecordType_TDTM.afflMultiHasRunBefore = false;
		insert affl2;
		
		//Made the second business affiliation primary
		affl2.Primary__c = true;
		AFFL_MultiRecordType_TDTM.afflMultiHasRunBefore = false;
		Test.startTest();
		update affl2;
		Test.stopTest();
		
		//The second affiliation should be the only primary
		List<Affiliation__c> affls = [select AfflAccount__c, Primary__c from Affiliation__c where AfflContact__c = :contact.ID order by AfflAccount__r.Name];
		System.assertEquals(affls[0].AfflAccount__c, acc1.ID);
		System.assertEquals(affls[0].Primary__c, false);
		System.assertEquals(affls[1].AfflAccount__c, acc2.ID);
		System.assertEquals(affls[1].Primary__c, true);
		
		//Verify key affl field has been updated
    	contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
		System.assertEquals(acc2.ID, Contact.Primary_Organization__c);
	}
	
	@isTest
	public static void autoCreateProgramEnrollment() {		
		setup();
		
		//Turn on Academic Record auto-creation for Business Organization mapping - doesn't make a lot of sense for this type, but just for testing 
		Affl_Mappings__c bizOrgMapping = [select Auto_Program_Enrollment__c from Affl_Mappings__c where Name = 'Business Organization'];
		bizOrgMapping.Auto_Program_Enrollment__c = true;
		bizOrgMapping.Auto_Program_Enrollment_Role__c = 'Student';
		bizOrgMapping.Auto_Program_Enrollment_Status__c = 'Current';
		update bizOrgMapping;

    	Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
    	insert contact;
	
		//Craete account of Business Organization record type
    	Account acc = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
    	insert acc;
    	
    	//Create Business affiliation
		Affiliation__c affl = new Affiliation__c(AfflContact__c = contact.ID, AfflAccount__c = acc.ID, Role__c = 'Student', Status__c = 'Current');
		Test.startTest();
		AFFL_MultiRecordType_TDTM.afflMultiHasRunBefore = false;
		AFFL_MultiRecordType_TDTM.afflMultiHasRunAfter = false;
		insert affl;
		Test.stopTest();
		
		//Verify Progran Enrollment record has been created
		List<Program_Enrollment__c> programEnrollments = [select ID, StudentContact__c from Program_Enrollment__c where Affiliation__c = :affl.ID];
		System.assertEquals(1, programEnrollments.size());
		System.assertEquals(contact.ID, programEnrollments[0].StudentContact__c);
	}
	
	@isTest
    public static void autoCreateProgramEnrollmentDifferentRole() {        
        setup();
        
        //Turn on Academic Record auto-creation for Business Organization mapping - doesn't make a lot of sense for this type, but just for testing 
        Affl_Mappings__c bizOrgMapping = [select Auto_Program_Enrollment__c from Affl_Mappings__c where Name = 'Business Organization'];
        bizOrgMapping.Auto_Program_Enrollment__c = true;
        bizOrgMapping.Auto_Program_Enrollment_Role__c = 'Student';
        bizOrgMapping.Auto_Program_Enrollment_Status__c = 'Current';
        update bizOrgMapping;

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;
    
        //Craete account of Business Organization record type
        Account acc = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert acc;
        
        //Create Business affiliation
        Affiliation__c affl = new Affiliation__c(AfflContact__c = contact.ID, AfflAccount__c = acc.ID, Role__c = 'Teacher', Status__c = 'Current');
        Test.startTest();
        AFFL_MultiRecordType_TDTM.afflMultiHasRunBefore = false;
        AFFL_MultiRecordType_TDTM.afflMultiHasRunAfter = false;
        insert affl;
        Test.stopTest();
        
        //Verify Program Enrollment record has not been created
        List<Program_Enrollment__c> programEnrollments = [select ID, StudentContact__c from Program_Enrollment__c where Affiliation__c = :affl.ID];
        System.assertEquals(0, programEnrollments.size());
    }
}