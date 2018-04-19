/*
    Copyright (c) 2017, Salesforce.org
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
 * @date 2017
 * @group TDTM
 * @group-content ../../ApexDocContent/TDTM.htm
 * @description Test class to validate behavior changes related to TDTM Static Flag handling, primarily focused on
 * dml operations with more than 200 records.
 *
***/
@isTest
private class TDTM_DMLgt200_TEST {
	
	static Integer inputSize = 500;

    /*********************************************************************************************************
    * @description Test Method for inserting large amounts of Contacts
    */
	@isTest static void testInsertContact() {
		// test data set up
		List<Contact> testContacts = new List<Contact>();
		for (Integer i = 0; i < inputSize; i++)
		{
			Contact testContact = new Contact(LastName = 'testLastName ' + i);
			testContacts.add(testContact);
		}
		insert testContacts;

		//assert
		List<Account> assertAccounts = [SELECT Id FROM Account];
		system.assertEquals(inputSize, assertAccounts.size());
	}

    /*********************************************************************************************************
    * @description Test Method for inserting and updating large amounts of Contact
    */
    @isTest
    public static void insertUpdateContact() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID()));

        String newContactMailingStreet = '123 Elm St';

		List<Contact> testContacts = new List<Contact>();

		for (Integer i = 0; i < inputSize; i++)
		{
        	Contact con = new Contact(
            FirstName='Test',
            LastName='Contact_forTests',
            MailingStreet = newContactMailingStreet,
            WorkEmail__c = 'junk@test.net',
            Preferred_Email__c = 'Work',
            WorkPhone__c = '206-777-8888',
            PreferredPhone__c = 'Work');
            testContacts.add(con);
        }
        insert testContacts;

        List<Contact> insertedContacts = [	Select FirstName, LastName, AccountId, Account.Name,Account.Primary_Contact__c,MailingStreet,
        									   Account.BillingStreet 
        							    	from Contact];

        //one contact should have been created
        system.assertEquals(inputSize, insertedContacts.size());

        //relationship should be bi-directional
        for (Contact con : insertedContacts)
        {
	        system.assertEquals(con.id, con.Account.Primary_Contact__c);   
            con.LastName = 'Contact_forTestsChange';
        	con.OtherCity = 'Seattle';  
        }
        update insertedContacts;

        List<Contact> updatedContacts = [Select FirstName, LastName, AccountId, Account.Name,Account.Primary_Contact__c
                                         from Contact];

        //relationship should be bi-directional
        for (Contact con : updatedContacts)
        {
        	system.assertEquals(con.id, con.Account.Primary_Contact__c);
        }
        system.assertEquals(inputSize, updatedContacts.size());
	}	

    /*********************************************************************************************************
    * @description Delete large amounts of Contacts and verify its parent Account is deleted.
    */
     @isTest
     public static void deleteContactNoOpps() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(
                    Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                    Accounts_to_Delete__c = UTIL_Describe_API.getAdminAccRecTypeID()));

		List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < inputSize; i++)
        {
	        Contact con = new Contact(
	            FirstName='Test',
	            LastName='Contact_forTests',
	            MailingStreet = '123 Elm St',
	            WorkEmail__c = 'junk@test.net',
	            Preferred_Email__c = 'Work',
	            WorkPhone__c = '206-777-8888',
	            PreferredPhone__c = 'Work');
	        testContacts.add(con);
	    }
        insert testContacts;

        List<Account> insertedAccounts = [Select Id from Account];
        system.assertEquals(inputSize,insertedAccounts.size());

        Test.startTest();
        delete testContacts;
        Test.stopTest();

        insertedAccounts = [Select Id from Account];
        system.assertEquals(0,insertedAccounts.size());
    }

    /*********************************************************************************************************
    @description Update existing large amounts of default Addresses.  
    verify: account billing address fields updated
    **********************************************************************************************************/            
    @isTest 
    public static void updateDefaultAddr() {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c(
            Accounts_Addresses_Enabled__c = UTIL_Describe_API.getAdminAccRecTypeID() + ';',
            Simple_Address_Change_Treated_as_Update__c = true);
        UTIL_CustomSettingsFacade.getSettingsForTests(hs);
        
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(inputSize, UTIL_Describe_API.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;        
        // now let's update the Addresses
        for (Integer i = 0; i < addrs.size(); i++) {
            Address__c addr = addrs[i];
            addr.MailingStreet__c = 'New Street' + i;
            addr.MailingCity__c = 'New City' + i;
        }

        Test.startTest();
        update addrs;
        Test.stopTest();
    
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c
        from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            System.assert(acc.BillingStreet.contains('New Street'));
            System.assert(acc.BillingCity.contains('New City'));
            System.assertNotEquals(null, acc.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Delete existing large amounts of default Addresses.  
    verify: Account billing address fields cleared.
    **********************************************************************************************************/            
    @isTest 
    static void deleteDefaultAddr() {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c(
            Accounts_Addresses_Enabled__c = UTIL_Describe_API.getAdminAccRecTypeID() + ';',
            Simple_Address_Change_Treated_as_Update__c = true);
        UTIL_CustomSettingsFacade.getSettingsForTests(hs);

        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(inputSize, UTIL_Describe_API.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;
       
        // now let's delete the Addresses
        Test.startTest();
        delete addrs;
        Test.stopTest();
    
        // verify that the Account address fields are cleared
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            System.assertEquals(null, acc.BillingStreet);
            System.assertEquals(null, acc.BillingCity);
        }
    }

    /*********************************************************************************************************
    @description Delete existing large amounts of non-default override Addresses.  
    verify: Account billing address fields not changed.
    **********************************************************************************************************/            
    @isTest
    static void deleteNonDefaultOverrideAddr() {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c(
            Accounts_Addresses_Enabled__c = UTIL_Describe_API.getAdminAccRecTypeID() + ';',
            Simple_Address_Change_Treated_as_Update__c = true);
        UTIL_CustomSettingsFacade.getSettingsForTests(hs);
        
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(inputSize, UTIL_Describe_API.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;
        
        // create additional addresses
        addrs = UTIL_UnitTestData_API.getMultipleTestAddresses(inputSize);
        
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            addrs[i].Parent_Account__c = accsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = false;
            addrs[i].MailingStreet__c = 'override' + i;
            addrs[i].MailingCity__c = 'override' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert addrs;
        
        // set the accounts' current address
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            Account acc = accsAddrs.accs[i];
            acc.Current_Address__c = addrs[i].Id;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        update accsAddrs.accs;        
        
        // now let's delete the current Addresses
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        delete addrs;
        Test.stopTest();
    
        // verify that the Account address fields went back to the default
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            System.assert(acc.BillingStreet.contains('Street'));
            System.assert(acc.BillingCity.contains('City')); 
            System.assertNotEquals(null, acc.Current_Address__c);                
        }
    }

    /*********************************************************************************************************
    @description Making an Address non-default. That is, the address is no longer the default one for the Account.  
    verify: no change to account address
    **********************************************************************************************************/            
    @isTest
    public static void updateNonDefaultAddr() {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c(
            Accounts_Addresses_Enabled__c = UTIL_Describe_API.getAdminAccRecTypeID() + ';',
            Simple_Address_Change_Treated_as_Update__c = true);
        UTIL_CustomSettingsFacade.getSettingsForTests(hs);
        
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(inputSize, UTIL_Describe_API.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;
        
        // now let's update the Addresses
        for (Integer i = 0; i < addrs.size(); i++) {
            Address__c addr = addrs[i];
            addr.Default_Address__c = false;
        }
        Test.startTest();
        update addrs;
        Test.stopTest();
    
        // verify that the Account and Contacts don't share the same address and it's new for the Account!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c 
        from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            System.assertEquals(null, acc.BillingStreet); //address information has been cleared because address is no longer the default
            System.assertEquals(null, acc.BillingCity); //address information has been cleared because address is no longer the default
            System.assertEquals(null, acc.Current_Address__c); //account no longer has a current address, since address is no longer the defaults
        }
    }

    /*********************************************************************************************************
    @description Insert large amounts of new default addresses to Account w/ existing default addresses  
    verify:
        Account address matches new default
        old default addresses no longer marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewDefaultAddr() {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c(
            Accounts_Addresses_Enabled__c = UTIL_Describe_API.getAdminAccRecTypeID() + ';',
            Simple_Address_Change_Treated_as_Update__c = true);
        UTIL_CustomSettingsFacade.getSettingsForTests(hs);          
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(inputSize, UTIL_Describe_API.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;
        
        // create additional addresses
        addrs = UTIL_UnitTestData_API.getMultipleTestAddresses(inputSize);
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            addrs[i].Parent_Account__c = accsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = true;
            addrs[i].MailingStreet__c = 'New Default Street' + i;
            addrs[i].MailingCity__c = 'New Default City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert addrs;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();        
        Test.stopTest();

        // verify that the Account addresses are new
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            System.assert(acc.BillingStreet.contains('New Default Street'));
            System.assert(acc.BillingCity.contains('New Default City'));
            System.assertNotEquals(null, acc.Current_Address__c);
        }
        
        // verify the previous addresses got Default cleared.
        // and verify latest start date and latest end date appropriately set.
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, 
        Latest_End_Date__c from Address__c];
        System.assertEquals(inputSize + inputSize, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fNewDefault = (addr.MailingStreet__c.contains('New Default Street'));
            System.assertEquals(fNewDefault, addr.Default_Address__c);
            if (fNewDefault) {
               System.assertEquals(System.today(), addr.Latest_Start_Date__c);
               System.assertEquals(null, addr.Latest_End_Date__c);
            } else {
               System.assertEquals(System.today(), addr.Latest_End_Date__c);                
            }
        }        
    }

	@isTest
    public static void noContactToAccPropagation() {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c(
            Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
            Accounts_Addresses_Enabled__c = UTIL_Describe_API.getAdminAccRecTypeID() + ';',
            Contacts_Addresses_Enabled__c = true,
            Simple_Address_Change_Treated_as_Update__c = true);
        UTIL_CustomSettingsFacade.getSettingsForTests(hs);
        
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < inputSize; i++){
 			Contact contact = new Contact(LastName = 'Testerson' + i, MailingStreet = '123 Main St', 
        	MailingCity = 'Austin', MailingState = 'Texas', MailingPostalcode = '78701', MailingCountry = 'United States');
        	testContacts.add(contact);       	
        }
        Test.startTest();
        insert testContacts;
        Test.stopTest();
        
        //Verify parent account was automatically created
        List<Contact> insertedContacts = [select AccountID from Contact];
        Set<Id> setInsertedContactsIds = new Set<Id>();
        for (Contact insertedContact : insertedContacts){
        	setInsertedContactsIds.add(insertedContact.Id);
        	System.assertNotEquals(null, contact.AccountID);
        }
        
        //Verify child address record was created
        List<Address__c> addrs = [select Parent_Account__c from Address__c]; 
		System.assertEquals(inputSize, addrs.size());
        for (Address__c addr : addrs){
        	System.assertEquals(null, addr.Parent_Account__c);       	
        }

        
        //Verify no address record was created as child of the parent account
        addrs = [select ID from Address__c where Parent_Account__c in :setInsertedContactsIds];
        System.assertEquals(0, addrs.size()); 
        
        //Verify parent account has no address info
        List<Account> accs = [select BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
        from Account];
        for (Account acc : accs){
			System.assertEquals(null, acc.BillingStreet);
	        System.assertEquals(null, acc.BillingState);
	        System.assertEquals(null, acc.BillingPostalCode);
	        if (!ADDR_Addresses_UTIL.isStateCountryPickListsEnabled) {
	            System.assertEquals(null, acc.BillingCountry);   
	        }
        }
    }

    /*********************************************************************************************************
    @description Change contacts for large amounts of affiliations
    verify:
        Account address matches new default
        old default addresses no longer marked default
    **********************************************************************************************************/    
    @isTest
    public static void changeContact() {
    	UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID()));

        Id orgRecTypeID = UTIL_Describe_API.getBizAccRecTypeID();
        Id householdRecTypeID = UTIL_Describe_API.getHhAccRecTypeID();

    	Contact oldContact = new Contact(FirstName = 'Old', LastName = 'Testerson');
    	insert oldContact;

    	List<Contact> newContacts = new List<Contact>();
    	for (Integer i = 0; i < inputSize; i++){
    		Contact newContact = new Contact(FirstName = 'New' + i, LastName = 'Testerson');
    		newContacts.add(newContact);
    	}
    	insert newContacts;

		//Create accounts of Business Organization record type
        Account bizOrg1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert bizOrg1;

        List<Affiliation__c> testAffls = new List<Affiliation__c>();
    	for (Integer i = 0; i < inputSize; i++){
    		Affiliation__c testAffl = new Affiliation__c(Contact__c = newContacts[i].ID, Account__c = bizOrg1.ID, Primary__c = true);
    		testAffls.add(testAffl);
    	}
    	insert testAffls;

        Test.startTest();
        for (Integer i = 0; i < inputSize; i++){
        	testAffls[i].Contact__c = newContacts[i].Id;
        }
        update testAffls;
        Test.stopTest();
        
        //Confirm Primary Business Organization field has been cleared in contact
        Contact contact = [select Primary_Organization__c from Contact where Id =:oldContact.Id];
        System.assertEquals(null, contact.Primary_Organization__c);
        
    }

    /*********************************************************************************************************
    @description Insert 200+ contacts with Primary_Education_Institution__c
    verify:
        certain amounts of affiliations are created
    **********************************************************************************************************/    
    @isTest
    public static void createContactsWithOrg() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID()));

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Primary Business Organization'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = 'Primary Household'));
        insert mappings;

        Id orgRecTypeID = UTIL_Describe_API.getBizAccRecTypeID();
        Id householdRecTypeID = UTIL_Describe_API.getHhAccRecTypeID();

        //Create account of Business Organization record type
        Account bizOrg1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert bizOrg1;

        List<Contact> newContacts = new List<Contact>();
        for (Integer i = 0; i < inputSize; i++){
            Contact newContact = new Contact(FirstName = 'New' + i, LastName = 'Testerson', Primary_Organization__c = bizOrg1.Id);
            newContacts.add(newContact);
        }

        Test.startTest();
        insert newContacts;
        Test.stopTest();

        //Verify
        List<Affiliation__c> affls = [select Affiliation_Type__c, Account__c, Primary__c from Affiliation__c];
        System.assertEquals(inputSize, affls.size());

        for (Affiliation__c affl : affls)
        {
            System.assertEquals('Business Organization', affl.Affiliation_Type__c);
        }
    }

}