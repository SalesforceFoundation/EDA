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
* @group Address Management
* @description Tests specific to Address Management. 
*/

@isTest
private with sharing class ADDR_Addresses_TEST {

    /*********************************************************************************************************
    * @description if you only want to run one test in this class, fill in its name here.
    * if you want to run all tests, then use '*'
    */
    private static string strTestOnly = '*';

    /*********************************************************************************************************
    * @description Holds the number of Households to create in tests.
    */
    static integer cHH = 2;

    /*********************************************************************************************************
    * @description Holds the number of Contacts per Household to create in tests.
    */
    static integer cCon = 2;    

    /*********************************************************************************************************
    * @description The list of created test Contacts.
    */
    private static list<Contact> listConT;

    /*********************************************************************************************************
    * @description The list of created test Accounts.
    */
    private static list<Account> listAccT;            

    /*********************************************************************************************************
    * @description
    * utility to set up common test data for the Address tests.
    *    - this will create & insert N household Accounts, each with M contacts
    *    - also will create a Default Addresses for each HH Account
    *    - will also setup the default Account Processor to be HH Accounts
    * @param cHHT the number of Household Accounts to create
    * @param cConT the number of Contacts to create per Household
    * @return  void
    **********************************************************************************************************/
    private static void createHHTestData(integer cHHT, integer cConT) {
        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettings();
            
        listConT = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(cHHT * cConT);
        listAccT = UTIL_UnitTestData_TEST.CreateMultipleTestAccounts(cHHT, CAO_Constants.HH_ACCOUNT_PROCESSOR);
        insert listAccT;
        
        for (integer i = 0; i < cHHT; i++) {
        	for (integer j = 0; j < cConT; j++) {
        		listConT[ (i * cHHT) + j].AccountId = listAccT[i].Id;
        	}
        }        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listConT;    	

        initTestAddr(cHHT);
        for (integer i = 0; i < cHHT; i++) {
            listAddrT[i].Household_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = true;
        }
        // clear our triggers recursion prevention since we starting a new test
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        // clear our triggers recursion prevention since we are starting a new test
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        // start 'em off with new limits!
        test.startTest();
    }
    
    /*********************************************************************************************************
    * @description The list of created test Addresses.
    */
    private static list<Address__c> listAddrT;

    /*********************************************************************************************************
    * @description Initializes (but not inserts) N new Address objects.
    * @param cAddr the number of Address objects to create
    * @return  void
    **********************************************************************************************************/
    private static void initTestAddr(integer cAddr) {
    	listAddrT = new list<Address__c>();
    	for (integer i = 0; i < cAddr; i++) {
    		Address__c addr = new Address__c();
    		addr.Address_Type__c = 'Home';
    		addr.MailingStreet__c = 'Street' + i;
    		addr.MailingCity__c = 'City' + i;
            addr.MailingState__c = 'Washington';
            addr.MailingPostalCode__c = 'Zip' + i;
            addr.MailingCountry__c = 'United States';
            listAddrT.add(addr);    		
    	}
    }
    
    /*********************************************************************************************************
    * @description Returns whether an Account Billing address matches a Contact Mailing address
    * @return  boolean 
    **********************************************************************************************************/
    private static boolean isMatchAddressAccCon(Account acc, Contact con) {
        return (acc.BillingStreet == con.MailingStreet &&          
            acc.BillingCity == con.MailingCity &&          
            acc.BillingState == con.MailingState &&         
            acc.BillingPostalCode == con.MailingPostalCode &&          
            acc.BillingCountry == con.MailingCountry);                
    }
        
    /*********************************************************************************************************
    @description
        create N new default Addresses for N Households (with M Contacts)  
    verify:
        N addresses created
        N household billing address fields updated
        M contact Mailing address fields updated
    **********************************************************************************************************/            
    @isTest
    public static void newDefaultAddr() {
        if (strTestOnly != '*' && strTestOnly != 'newDefaultAddr') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);
        Test.stopTest();

        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description
        insert contact w/ address
    verify:
        new default Address created
        contact address lookup updated to new address
        the contact gets the new Address
    **********************************************************************************************************/            
    @isTest
    public static void insertContactWithAddress() {
        if (strTestOnly != '*' && strTestOnly != 'insertContactWithAddress') return;
        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettings();
            
        listConT = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(cCon);
        for (Contact con : listConT) {
            con.MailingStreet = 'new street';
            con.MailingCity = 'new city';
        }
        insert listConT;        

        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
    }
        
    /*********************************************************************************************************
    @description
        insert contact w/ new address override
    verify:
        new non-default Address created
        contact address lookup updated to new address
        the contact gets the new Address
    **********************************************************************************************************/            
    @isTest
    public static void insertContactWithAddressOverride() {
        if (strTestOnly != '*' && strTestOnly != 'insertContactWithAddressOverride') return;
        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettings();
            
        listConT = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(cCon);
        integer i = 1;
        for (Contact con : listConT) {
            con.MailingStreet = 'new street' + i;
            con.MailingCity = 'new city' + i;
            con.is_Address_Override__c = true;
            i++;
        }
        insert listConT;        

        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals(true, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
    }
        
    /*********************************************************************************************************
    @description
        update existing default Addresses  
    verify:
        household billing address fields updated
        contact Mailing address fields updated
    **********************************************************************************************************/            
    @isTest 
    public static void updateDefaultAddr() {
        if (strTestOnly != '*' && strTestOnly != 'updateDefaultAddr') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);
        
        // now let's update the Addresses
        for (integer i = 0; i < cHH; i++) {
        	Address__c addr = listAddrT[i];
        	addr.MailingStreet__c = 'New Street' + i;
        	addr.MailingCity__c = 'New City' + i;
        }
        system.assertEquals(false, ADDR_Addresses_TDTM.hasRunAddrTrigger);
        update listAddrT;
        Test.stopTest();
    
        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        system.assertEquals(cHH * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('New Street'));
            system.assert(con.MailingCity.contains('New City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description
        update existing non-default Addresses  
    verify:
        no change to HH and contact addresses
    **********************************************************************************************************/            
    @isTest
    public static void updateNonDefaultAddr() {
        if (strTestOnly != '*' && strTestOnly != 'updateNonDefaultAddr') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);
        
        // now let's update the Addresses
        for (integer i = 0; i < cHH; i++) {
            Address__c addr = listAddrT[i];
            addr.Default_Address__c = false;
            addr.MailingStreet__c = 'New Street' + i;
            addr.MailingCity__c = 'New City' + i;
        }
        system.assertEquals(false, ADDR_Addresses_TDTM.hasRunAddrTrigger);
        update listAddrT;
        Test.stopTest();
    
        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        system.assertEquals(cHH * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(!con.MailingStreet.contains('New Street'));
            system.assert(!con.MailingCity.contains('New City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description
        set contact address override  
    verify:
        contact's address matches override
    **********************************************************************************************************/            
    @isTest
    public static void setConAddrOverride() {
        if (strTestOnly != '*' && strTestOnly != 'setConAddrOverride') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);
        
        // create a new non-default address
        Address__c addrNew = new Address__c();
        addrNew.MailingStreet__c = 'street override';
        addrNew.MailingCity__c = 'city override';
        addrNew.Default_Address__c = false;
        addrNew.Household_Account__c = listAccT[0].Id;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert addrNew;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // set a contact's address override
        listConT[0].Current_Address__c = addrNew.Id;
        listConT[0].is_Address_Override__c = true;
        update listConT[0];
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
    
        // now let's update the default Addresses
        for (integer i = 0; i < cHH; i++) {
            Address__c addr = listAddrT[i];
            addr.MailingStreet__c = 'New Street' + i;
            addr.MailingCity__c = 'New City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAddrT;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        system.assertEquals(cHH * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
        	if (con.is_Address_Override__c) {
        		system.assertEquals(con.Current_Address__c, addrNew.Id);
	            system.assertEquals(false, isMatchAddressAccCon(acc, con));
	            system.assert(!con.MailingStreet.contains('New Street'));
	            system.assert(!con.MailingCity.contains('New City'));        		
        	} else {
	            system.assertEquals(true, isMatchAddressAccCon(acc, con));
	            system.assert(con.MailingStreet.contains('New Street'));
	            system.assert(con.MailingCity.contains('New City'));
	            system.assertEquals(false, con.is_Address_Override__c);
	            system.assertNotEquals(null, con.Current_Address__c);
        	}
        }
    }

    /*********************************************************************************************************
    @description
        set contact current address, but not override  
    verify:
        contact's address updated, but not override
    **********************************************************************************************************/            
    @isTest
    public static void setConAddrNoOverride() {
        if (strTestOnly != '*' && strTestOnly != 'setConAddrNoOverride') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);

        // create additional addresses
        initTestAddr(cHH);
        for (integer i = 0; i < cHH; i++) {
            listAddrT[i].Household_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].MailingStreet__c = 'not override' + i;
            listAddrT[i].MailingCity__c = 'not override' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // set the contacts' address overrides
        list<Contact> listCon = new list<Contact>();
        for (integer i = 0; i < cHH; i++) {
            Contact con = listConT[i*cHH + i];
            con.Current_Address__c = listAddrT[i].Id;
            con.is_Address_Override__c = false;
            listCon.add(con);
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address, except for the contacts we modified
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, Current_Address__r.Default_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        
        integer cNotOverride = 0;
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            if (con.MailingStreet.contains('not override') == true) {
                cNotOverride++;
                system.assertEquals(false, isMatchAddressAccCon(acc, con));
                system.assert(con.MailingStreet.contains('not override'));
                system.assert(con.MailingCity.contains('not override'));
                system.assertEquals(false, con.is_Address_Override__c);
                system.assertNotEquals(null, con.Current_Address__c);            
            } else {
                system.assertEquals(true, con.Current_Address__r.Default_Address__c);
                system.assertEquals(true, isMatchAddressAccCon(acc, con));
                system.assert(con.MailingStreet.contains('Street'));
                system.assert(con.MailingCity.contains('City'));
                system.assertEquals(false, con.is_Address_Override__c);
                system.assertNotEquals(null, con.Current_Address__c);
            }
        }
        system.assertEquals(cHH, cNotOverride);
    }

    /*********************************************************************************************************
    @description
        insert new default addresses to HH w/ existing default addresses  
    verify:
        contact's && hh address matches new default
        old default addresses no longer marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewDefaultAddr() {
        if (strTestOnly != '*' && strTestOnly != 'insertNewDefaultAddr') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);
        
        // create additional addresses
        initTestAddr(cHH);
        for (integer i = 0; i < cHH; i++) {
            listAddrT[i].Household_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = true;
            listAddrT[i].MailingStreet__c = 'New Default Street' + i;
            listAddrT[i].MailingCity__c = 'New Default City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;        
        Test.stopTest();

        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        system.assertEquals(cHH * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('New Default Street'));
            system.assert(con.MailingCity.contains('New Default City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the previous addresses got Default cleared.
        // and verify latest start date and latest end date appropriately set.
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Household_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(cHH * 2, listAddr.size());
        for (Address__c addr : listAddr) {
        	boolean fNewDefault = (addr.MailingStreet__c.contains('New Default Street'));
       		system.assertEquals(fNewDefault, addr.Default_Address__c);
       		if (fNewDefault) {
       		   system.assertEquals(system.today(), addr.Latest_Start_Date__c);
       		   system.assertEquals(null, addr.Latest_End_Date__c);
       		} else {
               system.assertEquals(system.today(), addr.Latest_End_Date__c);       			
       		}
        }        
    }
    
    /*********************************************************************************************************
    @description
        insert new default addresses to HH w/ existing default addresses, and then go back  
    verify:
        contact's && hh address matches original default
        new default addresses no longer marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewDefaultAddrAndReset() {
        if (strTestOnly != '*' && strTestOnly != 'insertNewDefaultAddrAndReset') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);
        list<Address__c> listAddrOriginal = listAddrT;
        
        // create additional addresses
        initTestAddr(cHH);
        for (integer i = 0; i < cHH; i++) {
            listAddrT[i].Household_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = true;
            listAddrT[i].MailingStreet__c = 'New Default Street' + i;
            listAddrT[i].MailingCity__c = 'New Default City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // go back to original default addresses
        // added this extra set to test fix where we didn't use the correct default
        for (integer i = 0; i < cHH; i++) {
            listAddrOriginal[i].Default_Address__c = true;
            listAddrOriginal[i].MailingStreet__c = 'Original Default Street' + i;
            listAddrOriginal[i].MailingCity__c = 'Original Default City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAddrOriginal;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();

        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        system.assertEquals(cHH * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('Original Default Street'));
            system.assert(con.MailingCity.contains('Original Default City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the previous addresses got Default cleared.
        // and verify latest start date and latest end date appropriately set.
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Household_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(cHH * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fNewDefault = (addr.MailingStreet__c.contains('Original Default Street'));
            system.assertEquals(fNewDefault, addr.Default_Address__c);
            if (fNewDefault) {
               system.assertEquals(system.today(), addr.Latest_Start_Date__c);
               system.assertEquals(null, addr.Latest_End_Date__c);
            } else {
               system.assertEquals(system.today(), addr.Latest_End_Date__c);                
            }
        }        
    }

    /*********************************************************************************************************
    @description
        update contacts' Address Override  
    verify:
        contacts' Mailing address fields updated to the Address Override's fields.
    **********************************************************************************************************/            
    @isTest
    public static void updateAddrOverride() {
        if (strTestOnly != '*' && strTestOnly != 'updateAddrOverride') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);

        // create additional addresses
        initTestAddr(cHH);
        for (integer i = 0; i < cHH; i++) {
            listAddrT[i].Household_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].MailingStreet__c = 'override' + i;
            listAddrT[i].MailingCity__c = 'override' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // set the contacts' address overrides
        list<Contact> listCon = new list<Contact>();
        for (integer i = 0; i < cHH; i++) {
        	Contact con = listConT[i*cHH + i];
            con.Current_Address__c = listAddrT[i].Id;
            con.is_Address_Override__c = true;
            listCon.add(con);
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            if (con.is_Address_Override__c) {
                system.assertNotEquals(null, con.Current_Address__c);
                system.assertEquals(false, isMatchAddressAccCon(acc, con));
                system.assert(con.MailingStreet.contains('override'));
                system.assert(con.MailingCity.contains('override'));               
            } else {
                system.assertEquals(true, isMatchAddressAccCon(acc, con));
                system.assert(con.MailingStreet.contains('Street'));
                system.assert(con.MailingCity.contains('City'));
	            system.assertEquals(false, con.is_Address_Override__c);
	            system.assertNotEquals(null, con.Current_Address__c);
            }
        }

        // verify address overrides have latest start date and latest end date appropriately set.
        list<Address__c> listAddr = [select Id, Latest_Start_Date__c, Latest_End_Date__c from Address__c where Id in :listAddrT];
        system.assertEquals(cHH, listAddr.size());
        for (Address__c addr : listAddr) {
           system.assertEquals(system.today(), addr.Latest_Start_Date__c);
           system.assertEquals(null, addr.Latest_End_Date__c);
        }        
    }
        
    /*********************************************************************************************************
    @description
        clear contacts' Address Override  
    verify:
        contacts' Mailing address fields updated to the HH default address
    **********************************************************************************************************/            
    @isTest
    public static void clearAddrOverride() {
        if (strTestOnly != '*' && strTestOnly != 'clearAddrOverride') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);

        // create additional addresses
        initTestAddr(cHH);
        for (integer i = 0; i < cHH; i++) {
            listAddrT[i].Household_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].MailingStreet__c = 'override' + i;
            listAddrT[i].MailingCity__c = 'override' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // set the contacts' address overrides
        list<Contact> listCon = new list<Contact>();
        for (integer i = 0; i < cHH; i++) {
            Contact con = listConT[i*cHH + i];
            con.Current_Address__c = listAddrT[i].Id;
            con.is_Address_Override__c = true;
            listCon.add(con);
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;

        // now clear out the contacts' address overrides
        for (Contact con : listCon) {
            con.is_Address_Override__c = false;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('Street'));
            system.assert(con.MailingCity.contains('City'));
        }

        // verify address overrides have latest start date and latest end date appropriately set.
        list<Address__c> listAddr = [select Id, Latest_Start_Date__c, Latest_End_Date__c from Address__c where Id in :listAddrT];
        system.assertEquals(cHH, listAddr.size());
        for (Address__c addr : listAddr) {
           system.assertEquals(system.today(), addr.Latest_Start_Date__c);
           system.assertEquals(system.today(), addr.Latest_End_Date__c);
        }        
    }

    /*********************************************************************************************************
    @description
        update contacts' mailing address to cause creation of new default Address object  
    verify:
        new Default Address created
        HH and Contacts get new Address
    **********************************************************************************************************/            
    @isTest
    public static void updateConAddrNew() {
        if (strTestOnly != '*' && strTestOnly != 'updateConAddrNew') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);

        // modify some of the contact addresses directly
        list<Contact> listCon = new list<Contact>();
        for (integer i = 0; i < cHH; i++) {
            Contact con = listConT[i*cHH + i];
            con.MailingStreet = 'Direct Street Edit';
            con.MailingCity = 'Direct City Edit';
            listCon.add(con);
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;

        for (integer i = 0; i < cHH; i++) {
            Contact con = listConT[i*cHH + i];
            con.MailingStreet = 'another Street Edit';
            con.MailingCity = 'another City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;

        for (integer i = 0; i < cHH; i++) {
            Contact con = listConT[i*cHH + i];
            con.MailingStreet = 'final Street Edit';
            con.MailingCity = 'final City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('final Street Edit'));
            system.assert(con.MailingCity.contains('final City Edit'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
 
         // verify the previous addresses got Default cleared.
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Household_Account__c from Address__c];
        // each set of edits created a new address object 
        system.assertEquals(cHH * 4, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fNewDefault = (addr.MailingStreet__c.contains('final Street Edit'));
            system.assertEquals(fNewDefault, addr.Default_Address__c);
        }                
    }

    /*********************************************************************************************************
    @description
        update contacts' mailing address and mark it as override, to cause creation of new non-default Address object  
    verify:
        new Address created
        HH sticks with default Address
        contact gets new address
    **********************************************************************************************************/            
    @isTest
    public static void updateConAddrMarkOverride() {
        if (strTestOnly != '*' && strTestOnly != 'updateConAddrMarkOverride') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);

        // modify the contact addresses directly, and set override
        list<Contact> listCon = new list<Contact>();
        for (integer i = 0; i < cHH*cCon; i++) {
            Contact con = listConT[i];
            con.MailingStreet = 'Direct Street Edit';
            con.MailingCity = 'Direct City Edit';
            con.is_Address_Override__c = true;
            listCon.add(con);
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;
        Test.stopTest();
        
        // verify that the HH and Contacts do not share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(false, isMatchAddressAccCon(acc, con));
            system.assertEquals(true, con.MailingStreet.contains('Direct Street Edit'));
            system.assertEquals(true, con.MailingCity.contains('Direct City Edit'));
            system.assertEquals(false, acc.BillingStreet.contains('Direct Street Edit'));
            system.assertEquals(false, acc.BillingCity.contains('Direct City Edit'));
            system.assertEquals(true, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
 
         // verify the previous addresses got Default cleared.
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Household_Account__c from Address__c];
        system.assertEquals(cHH * cCon + cHH, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean isNewEdit = (addr.MailingStreet__c.contains('Direct Street Edit'));
            system.assertNotEquals(isNewEdit, addr.Default_Address__c);
        }                
    }

    /*********************************************************************************************************
    @description
        update contacts' mailing address to cause an update to default Address object  
    verify:
        existing Default Address updated
        HH and Contacts get updated Address
    **********************************************************************************************************/            
    @isTest
    public static void updateConAddrExisting() {
        if (strTestOnly != '*' && strTestOnly != 'updateConAddrExisting') return;
        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c (
                Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR,
                Simple_Address_Change_Treated_as_Update__c = true
        ));
                
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);

        // modify some of the contact addresses directly
        // NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
        list<Contact> listCon = new list<Contact>();
        for (integer i = 0; i < cHH; i++) {
            Contact con = listConT[i*cHH + i];
            con.MailingStreet = 'Direct Street Edit';
            listCon.add(con);
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;

        for (integer i = 0; i < cHH; i++) {
            Contact con = listConT[i*cHH + i];
            con.MailingState = 'Washington';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;

        for (integer i = 0; i < cHH; i++) {
            Contact con = listConT[i*cHH + i];
            con.MailingStreet = ' direct street  edit ';  // whitespace and casing should not count as a real edit.
            con.MailingState = 'Oregon';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;

        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('direct street  edit'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
 
        // verify that no new address was created
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Household_Account__c from Address__c];
        system.assertEquals(cHH, listAddr.size());
        for (Address__c addr : listAddr) {
            system.assertEquals('direct street  edit', addr.MailingStreet__c);
        }                
    }

    /*********************************************************************************************************
    @description
        update contacts' mailing address with just a case change, to cause an update to default Address object  
    verify:
        existing Default Address updated
        HH and Contacts get updated Address
    **********************************************************************************************************/            
    @isTest
    public static void updateConAddrExistingCaseOnly() {
        if (strTestOnly != '*' && strTestOnly != 'updateConAddrExistingCaseOnly') return;
        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c (
                Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR,
                Simple_Address_Change_Treated_as_Update__c = true
        ));
                
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);

        // modify some of the contact addresses directly
        // NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
        list<Contact> listCon = new list<Contact>();
        for (integer i = 0; i < cHH; i++) {
            Contact con = listConT[i*cHH + i];
            con.MailingStreet = 'Direct Street Edit';
            listCon.add(con);
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;

        for (integer i = 0; i < cHH; i++) {
            Contact con = listConT[i*cHH + i];
            con.MailingState = 'Washington';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;

        for (integer i = 0; i < cHH; i++) {
            Contact con = listConT[i*cHH + i];
            con.MailingStreet = ' direct street  edit ';  // whitespace and casing should not count as a real edit.
            con.MailingState = 'Oregon';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;

        for (integer i = 0; i < cHH; i++) {
            Contact con = listConT[i*cHH + i];
            con.MailingStreet = ' DIRECT STREET  EDIT ';  // only change casing.
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.equals('DIRECT STREET  EDIT'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
 
        // verify that no new address was created
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Household_Account__c from Address__c];
        system.assertEquals(cHH, listAddr.size());
        for (Address__c addr : listAddr) {
            system.assert(addr.MailingStreet__c.equals('DIRECT STREET  EDIT'));
        }
        
        // now test that changing the case from the account updates all addresses
        for (integer i = 0; i < cHH; i++) {
        	Account acc = listAccT[i];
        	acc.BillingStreet = 'direct street  edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccT;
        
        // verify that the HH and Contacts share the same address
        mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.equals('direct street  edit'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
 
        // verify that no new address was created
        listAddr = [select Id, Default_Address__c, MailingStreet__c, Household_Account__c from Address__c];
        system.assertEquals(cHH, listAddr.size());
        for (Address__c addr : listAddr) {
            system.assert(addr.MailingStreet__c.equals('direct street  edit'));
        }
        
                        
    }

    /*********************************************************************************************************
    @description
        update accounts' billing address to cause creation of new default Address object  
    verify:
        new Default Address created
        HH and Contacts get new Address
    **********************************************************************************************************/            
    @isTest
    public static void updateAccAddrNew() {
        if (strTestOnly != '*' && strTestOnly != 'updateAccAddrNew') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);

        // modify some of the account addresses directly
        for (integer i = 0; i < cHH; i++) {
            Account acc = listAccT[i];
            acc.BillingStreet = 'Direct Street Edit';
            acc.BillingCity = 'Direct City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccT;

        for (integer i = 0; i < cHH; i++) {
            Account acc = listAccT[i];
            acc.BillingStreet = 'another Street Edit';
            acc.BillingCity = 'another City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccT;

        for (integer i = 0; i < cHH; i++) {
            Account acc = listAccT[i];
            acc.BillingStreet = 'final Street Edit';
            acc.BillingCity = 'final City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccT;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(acc.BillingStreet.contains('final Street Edit'));
            system.assert(con.MailingStreet.contains('final Street Edit')); 
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
 
         // verify the previous addresses got Default cleared.
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Household_Account__c from Address__c];
        // each set of edits created a new address object 
        system.assertEquals(cHH * 4, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fNewDefault = (addr.MailingStreet__c.contains('final Street Edit'));
            system.assertEquals(fNewDefault, addr.Default_Address__c);
        }        
    }

    /*********************************************************************************************************
    @description
        update accounts' billing address to cause an update of the default Address object  
    verify:
        existing Default Address updated
        HH and Contacts get updated Address
    **********************************************************************************************************/            
    @isTest
    public static void updateAccAddrExisting() {
        if (strTestOnly != '*' && strTestOnly != 'updateAccAddrExisting') return;
        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c (
                Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR,
                Simple_Address_Change_Treated_as_Update__c = true
        ));
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);

        // modify some of the account addresses directly
        // NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
        for (integer i = 0; i < cHH; i++) {
            Account acc = listAccT[i];
            acc.BillingStreet = 'Direct Street Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccT;

        for (integer i = 0; i < cHH; i++) {
            Account acc = listAccT[i];
            acc.BillingState = 'Washington';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccT;

        for (integer i = 0; i < cHH; i++) {
            Account acc = listAccT[i];
            acc.BillingStreet = ' direct street  edit ';    // whitespace and casing should not count as real edit.
            acc.BillingState = 'Oregon';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccT;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(acc.BillingStreet.contains('direct street  edit'));
            system.assert(con.MailingStreet.contains('direct street  edit')); 
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
 
        // verify that no new address was created
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Household_Account__c from Address__c];
        system.assertEquals(cHH, listAddr.size());
        for (Address__c addr : listAddr) {
            system.assertEquals('direct street  edit', addr.MailingStreet__c);
        }        
    }

    /*********************************************************************************************************
    @description
        create an Address with no Account 
    verify:
        runtime error
    **********************************************************************************************************/            
    @isTest
    public static void newAddrNoAccount() {
        if (strTestOnly != '*' && strTestOnly != 'newAddrNoAccount') return;
        
        initTestAddr(cHH);
        for (integer i = 0; i < cHH; i++) {
        	system.assertEquals(null, listAddrT[i].Household_Account__c);
        }
        
        try {
        	insert listAddrT;
        } catch (Exception ex) {
            system.assert(ex.getMessage().contains(Label.addrHHAccountOnly));
            return;
        }
        system.assert(false); //we shouldn't get here!
    }

    /*********************************************************************************************************
    @description
        insert new seasonal addresses to HH w/ existing default addresses  
    verify:
        contact's && hh address matches new seasonal
        old default addresses still marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewSeasonalAddr() {
        if (strTestOnly != '*' && strTestOnly != 'insertNewSeasonalAddr') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);
        
        // create additional addresses
        initTestAddr(cHH);
        for (integer i = 0; i < cHH; i++) {
            listAddrT[i].Household_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(-1).month());
            listAddrT[i].Seasonal_Start_Day__c = '1';
            listAddrT[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(1).month());
            listAddrT[i].Seasonal_End_Day__c = '28';
            listAddrT[i].MailingStreet__c = 'New Seasonal Street' + i;
            listAddrT[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        system.assertEquals(cHH * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('New Seasonal Street'));
            system.assert(con.MailingCity.contains('New Seasonal City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the previous addresses still are Default
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Household_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(cHH * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            system.assertEquals(!fSeasonal, addr.Default_Address__c);
        }        
    }

    /*********************************************************************************************************
    @description
        insert new seasonal addresses, not current, to HH w/ existing default addresses  
    verify:
        contact's && hh address stay with default
        old default addresses still marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewSeasonalAddrNotCurrent() {
        if (strTestOnly != '*' && strTestOnly != 'insertNewSeasonalAddrNotCurrent') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);
        
        // create additional addresses
        initTestAddr(cHH);
        for (integer i = 0; i < cHH; i++) {
            listAddrT[i].Household_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(1).month());
            listAddrT[i].Seasonal_Start_Day__c = '1';
            listAddrT[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(2).month());
            listAddrT[i].Seasonal_End_Day__c = '28';
            listAddrT[i].MailingStreet__c = 'New Seasonal Street' + i;
            listAddrT[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        system.assertEquals(cHH * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(!con.MailingStreet.contains('New Seasonal Street'));
            system.assert(!con.MailingCity.contains('New Seasonal City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the previous addresses still are Default
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Household_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(cHH * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            system.assertEquals(!fSeasonal, addr.Default_Address__c);
        }        
    }

    /*********************************************************************************************************
    @description
        update seasonal addresses to current, on HH w/ existing default addresses  
    verify:
        contact's && hh address updated to seasonal address
        old default addresses still marked default
    **********************************************************************************************************/            
    @isTest
    public static void updateSeasonalAddr() {
        if (strTestOnly != '*' && strTestOnly != 'updateSeasonalAddr') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);
        
        // create additional seasonal addresses not current
        initTestAddr(cHH);
        for (integer i = 0; i < cHH; i++) {
            listAddrT[i].Household_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(1).month());
            listAddrT[i].Seasonal_Start_Day__c = '1';
            listAddrT[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(2).month());
            listAddrT[i].Seasonal_End_Day__c = '28';
            listAddrT[i].MailingStreet__c = 'New Seasonal Street' + i;
            listAddrT[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // now make them current
        for (integer i = 0; i < cHH; i++) {
            listAddrT[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(-1).month());
        }
        update listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;                
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        system.assertEquals(cHH * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('New Seasonal Street'));
            system.assert(con.MailingCity.contains('New Seasonal City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the previous addresses still are Default
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Household_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(cHH * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            system.assertEquals(!fSeasonal, addr.Default_Address__c);
        }        
    }

    /*********************************************************************************************************
    @description
        create multiple seasonal address that overlap with eachother  
    verify:
        overlap detected, seasonal addresses don't save
    **********************************************************************************************************/            
    @isTest
    public static void insertSeasonalAddrWithOverlap() {
        if (strTestOnly != '*' && strTestOnly != 'insertSeasonalAddrWithOverlap') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);
        
        // create additional seasonal addresses not current
        initTestAddr(cHH * 2);
        for (integer i = 0; i < cHH * 2; i++) {
        	integer iacc = i < cHH ? i : i-cHH;
        	if (math.mod(i, 2) == 0) {
	            listAddrT[i].Household_Account__c = listAccT[iacc].Id;
	            listAddrT[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(1).month());
	            listAddrT[i].Seasonal_Start_Day__c = '1';
	            listAddrT[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(3).month());
	            listAddrT[i].Seasonal_End_Day__c = '28';
        	} else {
                listAddrT[i].Household_Account__c = listAccT[iacc-1].Id;
                listAddrT[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(-1).month());
                listAddrT[i].Seasonal_Start_Day__c = '1';
                listAddrT[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(2).month());
                listAddrT[i].Seasonal_End_Day__c = '28';        	
        	}
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].MailingStreet__c = 'New Seasonal Street' + i;
            listAddrT[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        try {
            insert listAddrT;
        } catch (Exception ex) {
            system.assert(ex.getMessage().contains(Label.addrSeasonalOverlap));
            return;
        }
        system.assert(false); //we shouldn't get here!
        
    }

    /*********************************************************************************************************
    @description
        create multiple seasonal address that overlap with eachother  
    verify:
        overlap detected
    **********************************************************************************************************/            
    @isTest
    public static void testSeasonalAddrOverlapLogic() {
        if (strTestOnly != '*' && strTestOnly != 'testSeasonalAddrOverlapLogic') return;
        
        Address__c a1 = new Address__c();
        Address__c a2 = new Address__c();

        // test both increasing ranges, no overlap
        a1.Seasonal_Start_Month__c = '1';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '3';
        a1.Seasonal_End_Day__c = '28';
        a2.Seasonal_Start_Month__c = '4';
        a2.Seasonal_Start_Day__c = '1';
        a2.Seasonal_End_Month__c = '6';
        a2.Seasonal_End_Day__c = '28';
        system.assertEquals(false, ADDR_Addresses_TDTM.isSeasonalOverlap(a1, a2));
        system.assertEquals(false, ADDR_Addresses_TDTM.isSeasonalOverlap(a2, a1));
        
        // test both increasing ranges, with overlap
        a2.Seasonal_Start_Month__c = '2';
        a2.Seasonal_End_Month__c = '6';
        system.assertEquals(true, ADDR_Addresses_TDTM.isSeasonalOverlap(a1, a2));
        system.assertEquals(true, ADDR_Addresses_TDTM.isSeasonalOverlap(a2, a1));
        
        // test one increasing range, one decreasing range, no overlap
        a1.Seasonal_Start_Month__c = '3';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '5';
        a1.Seasonal_End_Day__c = '28';
        a2.Seasonal_Start_Month__c = '11';
        a2.Seasonal_Start_Day__c = '1';
        a2.Seasonal_End_Month__c = '2';
        a2.Seasonal_End_Day__c = '28';
        system.assertEquals(false, ADDR_Addresses_TDTM.isSeasonalOverlap(a1, a2));
        system.assertEquals(false, ADDR_Addresses_TDTM.isSeasonalOverlap(a2, a1));

        // test one increasing range, one decreasing range, with overlap
        a2.Seasonal_Start_Month__c = '11';
        a2.Seasonal_Start_Day__c = '1';
        a2.Seasonal_End_Month__c = '4';
        a2.Seasonal_End_Day__c = '28';
        system.assertEquals(true, ADDR_Addresses_TDTM.isSeasonalOverlap(a1, a2));
        system.assertEquals(true, ADDR_Addresses_TDTM.isSeasonalOverlap(a2, a1));

        // test both decreasing ranges, always overlap
        a1.Seasonal_Start_Month__c = '9';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '2';
        a1.Seasonal_End_Day__c = '28';
        a2.Seasonal_Start_Month__c = '12';
        a2.Seasonal_Start_Day__c = '1';
        a2.Seasonal_End_Month__c = '3';
        a2.Seasonal_End_Day__c = '28';
        system.assertEquals(true, ADDR_Addresses_TDTM.isSeasonalOverlap(a1, a2));
        system.assertEquals(true, ADDR_Addresses_TDTM.isSeasonalOverlap(a2, a1));
        
        // test both increasing ranges in the same month, no overlap
        a1.Seasonal_Start_Month__c = '2';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '2';
        a1.Seasonal_End_Day__c = '10';
        a2.Seasonal_Start_Month__c = '2';
        a2.Seasonal_Start_Day__c = '11';
        a2.Seasonal_End_Month__c = '2';
        a2.Seasonal_End_Day__c = '28';
        system.assertEquals(false, ADDR_Addresses_TDTM.isSeasonalOverlap(a1, a2));
        system.assertEquals(false, ADDR_Addresses_TDTM.isSeasonalOverlap(a2, a1));

        // test both increasing ranges in the same month, with overlap
        a1.Seasonal_Start_Month__c = '2';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '2';
        a1.Seasonal_End_Day__c = '10';
        a2.Seasonal_Start_Month__c = '2';
        a2.Seasonal_Start_Day__c = '10';
        a2.Seasonal_End_Month__c = '2';
        a2.Seasonal_End_Day__c = '28';
        system.assertEquals(true, ADDR_Addresses_TDTM.isSeasonalOverlap(a1, a2));
        system.assertEquals(true, ADDR_Addresses_TDTM.isSeasonalOverlap(a2, a1));

        // test one increasing range, one decreasing range in the same month, no overlap
        a1.Seasonal_Start_Month__c = '2';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '2';
        a1.Seasonal_End_Day__c = '10';
        a2.Seasonal_Start_Month__c = '2';
        a2.Seasonal_Start_Day__c = '11';
        a2.Seasonal_End_Month__c = '1';
        a2.Seasonal_End_Day__c = '28';
        system.assertEquals(false, ADDR_Addresses_TDTM.isSeasonalOverlap(a1, a2));
        system.assertEquals(false, ADDR_Addresses_TDTM.isSeasonalOverlap(a2, a1));

        // test one increasing range, one decreasing range in the same month, with overlap
        a1.Seasonal_Start_Month__c = '2';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '2';
        a1.Seasonal_End_Day__c = '10';
        a2.Seasonal_Start_Month__c = '2';
        a2.Seasonal_Start_Day__c = '11';
        a2.Seasonal_End_Month__c = '2';
        a2.Seasonal_End_Day__c = '1';
        system.assertEquals(true, ADDR_Addresses_TDTM.isSeasonalOverlap(a1, a2));
        system.assertEquals(true, ADDR_Addresses_TDTM.isSeasonalOverlap(a2, a1));
    }

    /*********************************************************************************************************
    @description
        create multiple seasonal address that overlap existing seasonal addresses  
    verify:
        overlap detected, seasonal addresses don't save
    **********************************************************************************************************/            
    @isTest
    public static void insertSeasonalAddrOverlapExisting() {
        if (strTestOnly != '*' && strTestOnly != 'insertSeasonalAddrOverlapExisting') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);
        
        // create additional seasonal addresses not current
        initTestAddr(cHH);
        for (integer i = 0; i < cHH; i++) {
            listAddrT[i].Household_Account__c = listAccT[i].Id;
            listAddrT[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(1).month());
            listAddrT[i].Seasonal_Start_Day__c = '1';
            listAddrT[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(3).month());
            listAddrT[i].Seasonal_End_Day__c = '28';
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].MailingStreet__c = 'New Seasonal Street' + i;
            listAddrT[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        
        // create additional seasonal addresses that overlap existing seasonal addresses
        initTestAddr(cHH);
        for (integer i = 0; i < cHH; i++) {
            listAddrT[i].Household_Account__c = listAccT[i].Id;
            listAddrT[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(2).month());
            listAddrT[i].Seasonal_Start_Day__c = '1';
            listAddrT[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(4).month());
            listAddrT[i].Seasonal_End_Day__c = '28';
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].MailingStreet__c = 'New Seasonal Street' + i;
            listAddrT[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        try {
            insert listAddrT;
        } catch (Exception ex) {
            system.assert(ex.getMessage().contains(Label.addrSeasonalOverlap));
            return;
        }
        system.assert(false); //we shouldn't get here!
        
    }

    /*********************************************************************************************************
    @description
        create multiple partial seasonal address  
    verify:
        partial seasonal detected, seasonal addresses don't save
    **********************************************************************************************************/            
    @isTest
    public static void insertPartialSeasonalAddr() {
        if (strTestOnly != '*' && strTestOnly != 'insertPartialSeasonalAddr') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);
        
        // create additional seasonal addresses not current
        initTestAddr(cHH);
        for (integer i = 0; i < cHH; i++) {
            listAddrT[i].Household_Account__c = listAccT[i].Id;
            listAddrT[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(1).month());
            listAddrT[i].Seasonal_Start_Day__c = '1';
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].MailingStreet__c = 'New Seasonal Street' + i;
            listAddrT[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        try {
            insert listAddrT;
        } catch (Exception ex) {
            system.assert(ex.getMessage().contains(Label.addrSeasonalPartial));
            return;
        }
        system.assert(false); //we shouldn't get here!
        
    }

    /*********************************************************************************************************
    @description
        schedule a seasonal address update 
    verify:
        contact's && hh address matches new seasonal
        old default addresses still marked default
    **********************************************************************************************************/            
    @isTest
    public static void scheduleSeasonalAddrUpdate() {
        if (strTestOnly != '*' && strTestOnly != 'scheduleSeasonalAddrUpdate') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);
        
        // create additional addresses
        initTestAddr(cHH);
        for (integer i = 0; i < cHH; i++) {
            listAddrT[i].Household_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].Seasonal_Start_Month__c = string.valueOf(system.today().month());
            listAddrT[i].Seasonal_Start_Day__c = string.valueOf(system.today().day());
            listAddrT[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(1).month());
            listAddrT[i].Seasonal_End_Day__c = '28';
            listAddrT[i].MailingStreet__c = 'New Seasonal Street' + i;
            listAddrT[i].MailingCity__c = 'New Seasonal City' + i;
        }
        
        // Hack!  by setting our trigger handler as run,
        // we can insert the new seasonal addresses but not have them processed.
        // this way we can test the scheduled job!
        ADDR_Addresses_TDTM.hasRunAddrTrigger = true;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;

        // run the scheduled batch directly
        ADDR_Seasonal_SCHED sch = new ADDR_Seasonal_SCHED();
        //Test.startTest(); already called by createHHTestData() 
        //sch.executeReturnStatus();
        Database.executeBatch(sch, 10);
        UTIL_Debug.debug('DJH**** about to call stopTest!');
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        system.assertEquals(cHH * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('New Seasonal Street'));
            system.assert(con.MailingCity.contains('New Seasonal City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the previous addresses still are Default
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Household_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(cHH * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            system.assertEquals(!fSeasonal, addr.Default_Address__c);
        }        
    }

    /*********************************************************************************************************
    @description
        create N new duplicate Addresses from Account  
    verify:
        duplicates not created
    **********************************************************************************************************/            
    @isTest
    public static void newDupeAccountAddr() {
        if (strTestOnly != '*' && strTestOnly != 'newDupeAccountAddr') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);

        // create additional addresses thru the account.
        for (integer i = 0; i < cHH; i++) {
        	listAccT[i].BillingStreet = listAddrT[i].MailingStreet__c;
            listAccT[i].BillingCity = listAddrT[i].MailingCity__c;
            listAccT[i].BillingState = listAddrT[i].MailingState__c;
            listAccT[i].BillingPostalCode = listAddrT[i].MailingPostalCode__c;
            listAccT[i].BillingCountry = listAddrT[i].MailingCountry__c;
        }        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccT;
        Test.stopTest();
        
        // verify that we don't have new Addresses
        list<Address__c> listAddr = [select Id from Address__c];
        system.assertEquals(cHH, listAddr.size());
    }

    /*********************************************************************************************************
    @description
        create N new duplicate Addresses from Contact  
    verify:
        duplicates not created
    **********************************************************************************************************/            
    @isTest
    public static void newDupeContactAddr() {
        if (strTestOnly != '*' && strTestOnly != 'newDupeContactAddr') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);

        // create additional addresses thru the contact.
        for (integer i = 0; i < cHH; i++) {
        	for (integer j = 0; j < cCon; j++) {
	            listConT[(i * cHH) + j].MailingStreet = listAddrT[i].MailingStreet__c;
	            listConT[(i * cHH) + j].MailingCity = listAddrT[i].MailingCity__c;
	            listConT[(i * cHH) + j].MailingState = listAddrT[i].MailingState__c;
	            listConT[(i * cHH) + j].MailingPostalCode = listAddrT[i].MailingPostalCode__c;
	            listConT[(i * cHH) + j].MailingCountry = listAddrT[i].MailingCountry__c;
        	}
        }        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listConT;
        Test.stopTest();
        
        // verify that we don't have new Addresses
        list<Address__c> listAddr = [select Id from Address__c];
        system.assertEquals(cHH, listAddr.size());
    }

    /*********************************************************************************************************
    @description
        create N new duplicate Addresses from Account, with non-default existing  
    verify:
        duplicates not created
        found match becomes Default
    **********************************************************************************************************/            
    @isTest
    public static void newDupeAccountAddrNonDefault() {
        if (strTestOnly != '*' && strTestOnly != 'newDupeAccountAddrNonDefault') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);

         // create additional non-default addresses
        initTestAddr(cHH);
        for (integer i = 0; i < cHH; i++) {
            listAddrT[i].Household_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].MailingStreet__c = 'New Street' + i;
            listAddrT[i].MailingCity__c = 'New City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;        
 
        // create additional addresses thru the account.
        for (integer i = 0; i < cHH; i++) {
            listAccT[i].BillingStreet = listAddrT[i].MailingStreet__c;
            listAccT[i].BillingCity = listAddrT[i].MailingCity__c;
            listAccT[i].BillingState = listAddrT[i].MailingState__c;
            listAccT[i].BillingPostalCode = listAddrT[i].MailingPostalCode__c;
            listAccT[i].BillingCountry = listAddrT[i].MailingCountry__c;
        }        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccT;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        system.assertEquals(cHH * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('New Street'));
            system.assert(con.MailingCity.contains('New City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the new addresses still are Default and we don't have too many
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Household_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(cHH * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean isNew = (addr.MailingStreet__c.contains('New Street'));
            system.assertEquals(isNew, addr.Default_Address__c);
        }        
 
    }

    /*********************************************************************************************************
    @description
        create N new duplicate Addresses from Contact, with non-default existing  
    verify:
        duplicates not created
        found match becomes Default
    **********************************************************************************************************/            
    @isTest
    public static void newDupeContactAddrNonDefault() {
        if (strTestOnly != '*' && strTestOnly != 'newDupeContactAddrNonDefault') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);

         // create additional non-default addresses
        initTestAddr(cHH);
        for (integer i = 0; i < cHH; i++) {
            listAddrT[i].Household_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].MailingStreet__c = 'New Street' + i;
            listAddrT[i].MailingCity__c = 'New City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;        
 
        // create additional addresses thru the contact.
        for (integer i = 0; i < cHH; i++) {
            for (integer j = 0; j < cCon; j++) {
                listConT[(i * cHH) + j].MailingStreet = listAddrT[i].MailingStreet__c;
                listConT[(i * cHH) + j].MailingCity = listAddrT[i].MailingCity__c;
                listConT[(i * cHH) + j].MailingState = listAddrT[i].MailingState__c;
                listConT[(i * cHH) + j].MailingPostalCode = listAddrT[i].MailingPostalCode__c;
                listConT[(i * cHH) + j].MailingCountry = listAddrT[i].MailingCountry__c;
            }
        }        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listConT;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        system.assertEquals(cHH * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('New Street'));
            system.assert(con.MailingCity.contains('New City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the new addresses still are Default and we don't have too many
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Household_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(cHH * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean isNew = (addr.MailingStreet__c.contains('New Street'));
            system.assertEquals(isNew, addr.Default_Address__c);
        }        
 
    }

    /*********************************************************************************************************
    @description
        update contacts' mailing address when they have an address override
    verify:
        new non-default Address created
        contact override updated to new address
        only the contact gets the new Address
    **********************************************************************************************************/            
    @isTest
    public static void updateConAddrWithOverride() {
        if (strTestOnly != '*' && strTestOnly != 'updateConAddrWithOverride') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);

        // create additional addresses
        initTestAddr(cHH);
        for (integer i = 0; i < cHH; i++) {
            listAddrT[i].Household_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].MailingStreet__c = 'override' + i;
            listAddrT[i].MailingCity__c = 'override' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // set the contacts' address overrides
        list<Contact> listCon = new list<Contact>();
        for (integer i = 0; i < cHH; i++) {
            Contact con = listConT[i*cHH + i];
            con.Current_Address__c = listAddrT[i].Id;
            con.is_Address_Override__c = true;
            listCon.add(con);
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
 
        // modify some of the contact addresses directly
        for (Contact con : listCon) {
            con.MailingStreet = 'Direct Street Edit';
            con.MailingCity = 'Direct City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            if (con.is_Address_Override__c == false) {
                system.assertNotEquals(null, con.Current_Address__c);
	            system.assertEquals(true, isMatchAddressAccCon(acc, con));
	            system.assert(!con.MailingStreet.contains('Direct Street Edit'));
	            system.assert(!con.MailingCity.contains('Direct City Edit'));
                system.assert(!con.MailingStreet.contains('override'));
                system.assert(!con.MailingCity.contains('override'));
            } else {
                system.assertEquals(false, isMatchAddressAccCon(acc, con));
                system.assert(con.MailingStreet.contains('Direct Street Edit'));
                system.assert(con.MailingCity.contains('Direct City Edit'));
	            system.assertEquals(true, con.is_Address_Override__c);
	            system.assertNotEquals(null, con.Current_Address__c);
            }
        }
 
         // verify the new overrides are not marked default, and that the contact points to them
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Household_Account__c from Address__c];
        system.assertEquals(cHH * 3, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fOverride = (addr.MailingStreet__c.contains('Direct Street Edit'));
            if (fOverride) {
                system.assertEquals(false, addr.Default_Address__c);
                boolean isSetOnContact = false;
                for (Contact con : listCon) {
                    if (con.is_Address_Override__c && con.Current_Address__c == addr.Id)
                        isSetOnContact = true;
                }
                system.assertEquals(true, isSetOnContact);
            }
        }                
    }

    /*********************************************************************************************************
    @description
        insert new contacts with no addresses to existing households that have default addresses
    verify:
        new contacts get the default hh address
    **********************************************************************************************************/            
    @isTest
    public static void insertConWithNoAddrToExistingHH() {
        if (strTestOnly != '*' && strTestOnly != 'insertConWithNoAddrToExistingHH') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);
        
        // insert new contacts to the HH without any addresses
        list<Contact> listCon = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(cHH);
        for (integer i = 0; i < cHH; i++) {
            listCon[i].AccountId = listAccT[i].Id;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listCon;         
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description
        insert new contacts with addresses to existing households that have default addresses
    verify:
        all contacts and hh get the new default hh address from the new contacts
    **********************************************************************************************************/            
    @isTest
    public static void insertConWithAddrToExistingHH() {
        if (strTestOnly != '*' && strTestOnly != 'insertConWithAddrToExistingHH') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);
        
        // insert new contacts to the HH with new addresses
        list<Contact> listCon = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(cHH);
        for (integer i = 0; i < cHH; i++) {
        	listCon[i].AccountId = listAccT[i].Id;
            listCon[i].MailingStreet = 'New Mailing Street' + i;
        	listCon[i].MailingCity = 'New Mailing City' + i;
        	listCon[i].MailingState = 'California';
        	listCon[i].MailingCountry = 'United States';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listCon;         
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
            system.assert(con.MailingStreet.contains('New Mailing Street'));
            system.assert(con.MailingCity.contains('New Mailing City'));
        }
    }

    /*********************************************************************************************************
    @description
        insert new contacts with default addresses to existing households that have default addresses       
        (this is to mimic the behavior of doing New Contact from the HH Account, in which case Salesforce
        brings up the new contact page in edit mode, with the account's billing address copied into the 
        contact's mailing address fields).
    verify:
        no new addresses created
        new contacts point at the default address
    **********************************************************************************************************/            
    @isTest
    public static void insertConWithDefaultAddrToExistingHH() {
        if (strTestOnly != '*' && strTestOnly != 'insertConWithDefaultAddrToExistingHH') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);
        
        // reload accounts to get their default addresses
        listAccT = [select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account];
        system.assertEquals(cHH, listAccT.size());
        
        // insert new contacts to the HH with the current default addresses
        list<Contact> listCon = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(cHH);
        for (integer i = 0; i < cHH; i++) {
            listCon[i].AccountId = listAccT[i].Id;
            listCon[i].MailingStreet = listAccT[i].BillingStreet;
            listCon[i].MailingCity = listAccT[i].BillingCity;
            listCon[i].MailingState = listAccT[i].BillingState;
            listCon[i].MailingPostalCode = listAccT[i].BillingPostalCode;
            listCon[i].MailingCountry = listAccT[i].BillingCountry;            
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listCon;         
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        system.assertEquals(cHH * (cCon + 1), listCon.size());
        
        integer cAddr = [select count() from Address__c];
        system.assertEquals(cHH, cAddr);
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description
        insert contact w/ multiline street address
    verify:
        new default Address created and the street address is broken up into street and street2
        the HH Account gets the new multiline address
    **********************************************************************************************************/            
    @isTest
    public static void insertContactWithMultilineStreetAddress() {
        if (strTestOnly != '*' && strTestOnly != 'insertContactWithMultilineStreetAddress') return;
        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettings();
            
        listConT = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(cCon);
        for (Contact con : listConT) {
            con.MailingStreet = 'new street\r\nsecond line';
            con.MailingCity = 'new city';
        }
        insert listConT;        
        
        // verify the Address objects split street.
        list<Address__c> listAddr = [select Id, MailingStreet__c, MailingStreet2__c, Formula_MailingStreetAddress__c from Address__c];
        for (Address__c addr : listAddr) {
            system.assertEquals('new street', addr.MailingStreet__c);
            system.assertEquals('second line', addr.MailingStreet2__c);
            system.assertEquals('new street, second line', addr.Formula_MailingStreetAddress__c);
        }

        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals('new street\r\nsecond line', con.MailingStreet);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description
        insert new default multiline street addresses to HH w/ existing default addresses  
    verify:
        contact's && hh address matches new default
        street & street2 combined into contact and account single street field
    **********************************************************************************************************/            
    @isTest
    public static void insertNewDefaultMultilineStreetAddr() {
        if (strTestOnly != '*' && strTestOnly != 'insertNewDefaultMultilineStreetAddr') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);
        
        // create additional addresses
        initTestAddr(cHH);
        for (integer i = 0; i < cHH; i++) {
            listAddrT[i].Household_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = true;
            listAddrT[i].MailingStreet__c = 'New Default Street';
            listAddrT[i].MailingStreet2__c = 'Second Line';
            listAddrT[i].MailingCity__c = 'New Default City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;        
        Test.stopTest();

        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        system.assertEquals(cHH * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals('New Default Street\r\nSecond Line', con.MailingStreet);
            system.assertEquals('New Default Street\r\nSecond Line', acc.BillingStreet);
        }
        
    }
    
    /*********************************************************************************************************
    @description
        update accounts' billing address with multiline street address  
    verify:
        new Default Address created
        HH and Contacts get new Address
        new Addresss has multiline street split into Street and Street2 fields
    **********************************************************************************************************/            
    @isTest
    public static void updateAccMultilineStreetAddr() {
        if (strTestOnly != '*' && strTestOnly != 'updateAccMultilineStreetAddr') return;
        
        // this creates a default Address for each HH
        createHHTestData(cHH, cCon);

        // modify some of the account addresses directly
        for (integer i = 0; i < cHH; i++) {
            Account acc = listAccT[i];
            acc.BillingStreet = 'Direct Street Edit\r\nSecond Line';
            acc.BillingCity = 'Direct City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccT;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals('Direct Street Edit\r\nSecond Line', acc.BillingStreet);
            system.assertEquals('Direct Street Edit\r\nSecond Line', con.MailingStreet);
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
 
        // verify the Address objects split street.
        list<Address__c> listAddr = [select Id, MailingStreet__c, MailingStreet2__c, Formula_MailingStreetAddress__c, Default_Address__c from Address__c];
        for (Address__c addr : listAddr) {
        	if (addr.Default_Address__c) {
	            system.assertEquals('Direct Street Edit', addr.MailingStreet__c);
	            system.assertEquals('Second Line', addr.MailingStreet2__c);
	            system.assertEquals('Direct Street Edit, Second Line', addr.Formula_MailingStreetAddress__c);
        	}
        }

    }

    /*********************************************************************************************************
    @description
        create N new organizational accounts with billing addresses 
    verify:
        N addresses created
        account address matches address object address
    **********************************************************************************************************/            
    @isTest
    public static void newOrgAccounts() {
        if (strTestOnly != '*' && strTestOnly != 'newOrgAccounts') return;
        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c (
                Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR,
                Organizational_Account_Addresses_Enabled__c = true
        ));
 
        integer cAcc = 3;
        list<Account> listAcc = UTIL_UnitTestData_TEST.CreateMultipleTestAccounts(cAcc, null);
        for (Account acc : listAcc) {
            acc.BillingStreet = '123 45th';
            acc.BillingCity = 'Seattle';
        }
        Test.startTest();
        insert listAcc;
        Test.stopTest();

        // verify results
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        system.assertEquals(cAcc, mapAccIdAcc.size());
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, MailingCity__c, Household_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(cAcc, listAddr.size());
        
        for (Address__c addr : listAddr) {
            Account acc = mapAccIdAcc.get(addr.Household_Account__c);
            system.assertEquals(acc.BillingStreet, addr.MailingStreet__c);
            system.assertEquals(acc.BillingCity, addr.MailingCity__c);
            system.assertEquals(true, addr.Default_Address__c);
        }
    }

    /*********************************************************************************************************
    @description
        update N organizational accounts with billing addresses 
    verify:
        N addresses created
        account addresses updated
        contact addresses not updated
    **********************************************************************************************************/            
    @isTest
    public static void updateOrgAccounts() {
        if (strTestOnly != '*' && strTestOnly != 'updateOrgAccounts') return;
        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c (
                Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR,
                Organizational_Account_Addresses_Enabled__c = true
        ));
 
        // create accounts without addresses
        integer cAcc = 3;
        list<Account> listAcc = UTIL_UnitTestData_TEST.CreateMultipleTestAccounts(cAcc, null);
        insert listAcc;
        
        // add a contact to each account.
        list<Contact> listCon = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(cAcc);
        for (integer i = 0; i < cAcc; i++) {
            listCon[i].AccountId = listAcc[i].Id;
        }
        insert listCon;

        // update the accounts' address
        for (Account acc : listAcc) {
            acc.BillingStreet = '123 45th';
            acc.BillingCity = 'Seattle';
        }
        Test.startTest();
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAcc;
        Test.stopTest();

        // verify results
        listAcc = [select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry 
        			from Account order by Account.Name];
        system.assertEquals(cAcc, listAcc.size());
        
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, MailingCity__c, Household_Account__c, Latest_Start_Date__c, Latest_End_Date__c 
        							from Address__c order by Household_Account__r.Name];
        system.assertEquals(cAcc, listAddr.size());
        
        listCon = [select Id, AccountId, Name, Current_Address__c, MailingStreet, MailingCity from Contact order by Account.Name];
        system.assertEquals(cAcc, listCon.size());        
        
        for (integer i = 0; i < cAcc; i++) {
            Account acc = listAcc[i];
            Address__c addr = listAddr[i];
            Contact con = listCon[i];
            system.assertEquals(acc.BillingStreet, addr.MailingStreet__c);
            system.assertEquals(acc.BillingCity, addr.MailingCity__c);
            system.assertEquals(true, addr.Default_Address__c);
            system.assertEquals(null, con.Current_Address__c);
            system.assertEquals(null, con.MailingStreet);
            system.assertEquals(null, con.MailingCity);
        }
    }
    
    /*********************************************************************************************************
    @description
        update N organizational accounts with address objects 
    verify:
        account addresses updated
        contact addresses not updated
    **********************************************************************************************************/            
    @isTest
    public static void newAddrForOrgAccounts() {
        if (strTestOnly != '*' && strTestOnly != 'newAddrForOrgAccounts') return;
        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c (
                Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR,
                Organizational_Account_Addresses_Enabled__c = true
        ));
 
        // create accounts without addresses
        integer cAcc = 3;
        list<Account> listAcc = UTIL_UnitTestData_TEST.CreateMultipleTestAccounts(cAcc, null);
        insert listAcc;
        
        // add a contact to each account.
        list<Contact> listCon = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(cAcc);
        for (integer i = 0; i < cAcc; i++) {
            listCon[i].AccountId = listAcc[i].Id;
        }
        insert listCon;

         // create addresses for the accounts
        initTestAddr(cAcc);
        for (integer i = 0; i < cAcc; i++) {
            listAddrT[i].Household_Account__c = listAcc[i].Id;
            listAddrT[i].Default_Address__c = true;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // verify results
        listAcc = [select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account order by Account.Name];
        system.assertEquals(cAcc, listAcc.size());
        listAddrT = [select Id, Default_Address__c, MailingStreet__c, MailingCity__c, Household_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c order by Household_Account__r.Name];
        system.assertEquals(cAcc, listAddrT.size());
        listCon = [select Id, AccountId, Name, Current_Address__c, MailingStreet, MailingCity from Contact order by Account.Name];
        system.assertEquals(cAcc, listCon.size());        
        
        for (integer i = 0; i < cAcc; i++) {
            Account acc = listAcc[i];
            Address__c addr = listAddrT[i];
            Contact con = listCon[i];
            system.assertEquals(acc.BillingStreet, addr.MailingStreet__c);
            system.assertEquals(acc.BillingCity, addr.MailingCity__c);
            system.assertEquals(true, addr.Default_Address__c);
            system.assertEquals(null, con.Current_Address__c);
            system.assertEquals(null, con.MailingStreet);
            system.assertEquals(null, con.MailingCity);
        }
    }

    /*********************************************************************************************************
    @description
        create N contacts with Household Accounts when the setting for Address Mgmt is off. 
    verify:
        no Address objects created
        HH Account addresses set
        Contact addresses set
    **********************************************************************************************************/            
    @isTest
    public static void testDisabledHHAccountAddr() {
        if (strTestOnly != '*' && strTestOnly != 'testDisabledHHAccountAddr') return;
        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c (
                Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR,
                Household_Account_Addresses_Disabled__c = true
        ));
 
        listConT = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(cCon);
        for (Contact con : listConT) {
            con.MailingStreet = 'new street';
            con.MailingCity = 'new city';
        }
        insert listConT;        

        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertEquals(null, con.Current_Address__c);
        }
        
        // verify no address objects created
        list<Address__c> listAddr = [select Id from Address__c];
        system.assertEquals(0, listAddr.size());
    }
}