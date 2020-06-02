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
* @group Addresses
* @group-content ../../ApexDocContent/Addresses.htm
* @description Tests specific to Household Account Address Management. 
*/

@isTest
public with sharing class ADDR_HouseholdAcc_TEST {
    
    /*@description Household Account Record Type ID.*/
    private static ID householdRecTypeID = UTIL_Describe_API.getHhAccRecTypeID();
    
    /*@description Set up of Hierarchy Settings leverage by test methods*/
    private static void configSettings() {
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(
                										Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
            											Household_Addresses_RecType__c = UTIL_Describe_API.getHhAccRecTypeID(),
            											Contacts_Addresses_Enabled__c = True,
            											Simple_Address_Change_Treated_as_Update__c = True));
    }
    
    /*********************************************************************************************************
    * @description Returns whether an Account Billing address matches a Contact Mailing address. 
    * @return Boolean.  
    **********************************************************************************************************/
    private static Boolean isMatchAddressAccCon(Account acc, Contact con) {
        UTIL_Debug.debug('****Account to Compare: ' + JSON.serializePretty(acc));
        UTIL_Debug.debug('****Contact to Compare: ' + JSON.serializePretty(con));
        
        return (acc.BillingStreet == con.MailingStreet && 
                acc.BillingCity == con.MailingCity &&  
                acc.Billing_County__c == con.Mailing_County__c && 
            	acc.BillingState == con.MailingState && 
                acc.BillingPostalCode == con.MailingPostalCode &&          
            	acc.BillingCountry == con.MailingCountry && 
                acc.BillingLatitude == con.MailingLatitude &&
            	acc.BillingLongitude == con.MailingLongitude);                
    }
        
    /*********************************************************************************************************
    @description Create 2 Household Accounts and 2 Contacts. 
	* Verify:
	* - Contact's mailing fields are updated.
	* - Household Account's billing address fields are updated. 
	* - Address records are created. 
    **********************************************************************************************************/            
    @isTest
    private static void newDefaultAddrHH() {
        configSettings();
        
        //Tests that the helper method is properly written
        Test.startTest();
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        Test.stopTest();
        
        //Verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, BillingCity, 
                                                             Billing_County__c,BillingState, BillingPostalCode, 
                                                             BillingCountry, BillingLatitude, BillingLongitude 
                                                             FROM Account]);
        UTIL_Debug.debug('****newDefaultAddrHH Accounts: ' + JSON.serializePretty(mapAccIdAcc.values()));  
        
        List<Contact> listCon = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c,MailingState, 
                                 MailingPostalCode, MailingCountry, MailingLatitude, 
                                 MailingLongitude 
                                 FROM Contact];
        UTIL_Debug.debug('****newDefaultAddrHH listCon: ' + JSON.serializePretty(listCon)); 
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
    }
    
    /*********************************************************************************************************
    @description Create a Contact with mailing fields populated. 
	* Verify:
	* - Household Account record is created. 
	* - Housebold Account billing address fields are populated based on mailing fields from Contact. 
	* - Address record is created. 
	* - Address record is associated to the Household Account but not the Contact record. 
    **********************************************************************************************************/      
    @isTest
    private static void insertContactWithAddress() {
        configSettings();
        
        Contact con = new Contact(Lastname='Testy', MailingStreet = '123 Main St', MailingCity = 'Chicago', Mailing_County__c = 'Bergen');
        Test.startTest();
        insert con;
        Test.stopTest();
        
        List<Account> accs = [SELECT Id, BillingStreet, BillingCity , Billing_County__c
                              FROM Account];
        System.assertEquals(1, accs.size());
        System.assertEquals('123 Main St', accs[0].BillingStreet);
        System.assertEquals('Chicago', accs[0].BillingCity);
        System.assertEquals('Bergen', accs[0].Billing_County__c);
        
        List<Address__c> addrs = [SELECT Id, Parent_Account__c, Parent_Contact__c, 
                                  Default_Address__c, MailingStreet__c, MailingCity__c,
                                  MailingCounty__c
                                  FROM Address__c];
        System.assertEquals(1, addrs.size());
        System.assertEquals(accs[0].Id, addrs[0].Parent_Account__c);
        System.assertEquals(Null, addrs[0].Parent_Contact__c);
        System.assertEquals('123 Main St', addrs[0].MailingStreet__c);
        System.assertEquals('Chicago', addrs[0].MailingCity__c);
        System.assertEquals('Bergen', addrs[0].MailingCounty__c);
        System.assertEquals(True, addrs[0].Default_Address__c);
    }

    /*********************************************************************************************************
    @description Create a new Contact with new mailing address on an existing Household Account with existing 
	* Contact records and default Address record.
	* Verify:
	* - New Contact record is created on the existing Household Account. 
	* - Household Account's billing fields are updated with the new mailing fields from the new Contact inserted. 
	* - New default Address record is created and associated to the Household Account. 
    **********************************************************************************************************/            
    @isTest
    private static void insertContactWithAddressToHH() {
        configSettings();
          
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        //Add a Contact to each existing Household Account
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = New Contact();
            con.AccountId = consAccsAddrs.accs[i].Id;
            con.LastName = 'Testerson';
            con.MailingStreet = 'new street';
            con.MailingCity = 'new city';
            con.Mailing_County__c = 'new county';
            contacts.add(con);
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert contacts;
        Test.stopTest();      
        
        //Verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState,
                                                             BillingPostalCode, BillingCountry, BillingLatitude,
                                                             BillingLongitude
                                                             FROM Account]);
        List<Contact> listCon = [SELECT Id, AccountId, is_Address_Override__c, 
                                 Current_Address__c, MailingStreet, MailingCity, 
                                 Mailing_County__c, MailingState, MailingPostalCode,
                                 MailingCountry, MailingLatitude, MailingLongitude
                                 FROM Contact];
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
            System.assertEquals('new street', con.MailingStreet);
            System.assertEquals('new city', con.MailingCity);
            System.assertEquals('new county', con.Mailing_County__c);
        }
        
        List<Address__c> addrs = [SELECT Id, MailingStreet__c, Default_Address__c
                                  FROM Address__c]; 
        for (Address__c address : addrs) {
            if (address.MailingStreet__c.contains('new street')) {
                System.assertEquals(True, address.Default_Address__c); 
            } else {
                System.assertEquals(False, address.Default_Address__c); 
            }
        }
    }
        
    /*********************************************************************************************************
    @description Create new Contact with new mailing address on an existing Household Account and set is_Address_Override__c
	* to true for the newly created Contact. 
	* Verify: 
	* - New non default Address is created.
	* - Current_Address__c is populated on new Contact record.
    **********************************************************************************************************/            
    @isTest
    private static void insertContactWithAddressOverrideHH() {
        configSettings();
                           
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        //Add a Contact in each existing Household Account
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i<2; i++) {
            Contact con = new Contact();
            con.LastName = 'Testerson';
            con.AccountId = consAccsAddrs.accs[i].Id;
            con.MailingStreet = 'new street' + i;
            con.MailingCity = 'new city' + i;
            con.Mailing_County__c = 'new county' + i;
            con.is_Address_Override__c = True;
            contacts.add(con);
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert contacts;
        Test.stopTest();    

        //Verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude, Current_Address__c
                                                             FROM Account]);
        List<Contact> listCon = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c, MailingState, 
                                 MailingPostalCode, MailingCountry, MailingLatitude, 
                                 MailingLongitude 
                                 FROM Contact];
        List<Address__c> addrs = [SELECT Default_Address__c, MailingStreet__c, MailingCity__c 
                                  FROM Address__c];
        UTIL_Debug.debug('****Accouns after query: ' + JSON.serializePretty(mapAccIdAcc.values()));
        UTIL_Debug.debug('****Contacts after query: ' + JSON.serializePretty(listCon));
        UTIL_Debug.debug('****Addresses after query: ' + JSON.serializePretty(addrs));
        System.assertEquals(4, addrs.size());
        for (Address__c addr : addrs) {
            if (addr.MailingStreet__c.contains('new street')) {
                System.assertEquals(False, addr.Default_Address__c); 
            }
        }
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertNotEquals(Null, con.Current_Address__c);
            System.assertNotEquals(Null, mapAccIdAcc.get(con.AccountId).Current_Address__c); 
            
            if (con.is_Address_Override__c) {
                System.assertEquals(False, isMatchAddressAccCon(acc, con));
            } else {
                System.assertEquals(True, isMatchAddressAccCon(acc, con));               
            }
        }
    }
        
    /*********************************************************************************************************
    @description Existing Household Account's Address mailing fields are updated. 
	* Verify:
	* - No new Address record is created. 
	* - Household Account's billing fields are updated.
	* - Contact's mailing fields are updated. 
    **********************************************************************************************************/            
    @isTest 
    private static void updateDefaultAddrHH() {
        configSettings();

        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        System.assertEquals(2, consAccsAddrs.addrs.size()); 
        
        for (Integer i = 0; i < 2; i++) {
            Address__c addr = consAccsAddrs.addrs[i];
            addr.MailingStreet__c = 'New Street' + i;
            addr.MailingCity__c = 'New City' + i;
            addr.MailingCounty__c = 'New County' + i; 
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update consAccsAddrs.addrs;
        Test.stopTest();
    
        //Verify that the HH and Contacts share the same address and it's new!
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude
                                                             FROM Account]);
        List<Contact> listCon = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c, MailingState, 
                                 MailingPostalCode, MailingCountry, MailingLatitude, 
                                 MailingLongitude 
                                 FROM Contact];
        System.assertEquals(4, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Street'));
            System.assert(con.MailingCity.contains('New City'));
            System.assert(con.Mailing_County__c.contains('New County'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
        
        List<Address__c> addrs = [SELECT Id, Default_Address__c
                                 FROM Address__c]; 
        System.assertEquals(2, addrs.size()); 
        for (Address__c addr : addrs) {
            System.assertEquals(True, addr.Default_Address__c); 
        }
        
    }
    
    /*********************************************************************************************************
    @description Delete existing default Address record. 
	* Verify: 
	* - Household Account's billing fields are cleared. 
	* - Contact's mailing fields are cleared.
    **********************************************************************************************************/            
    @isTest
    private static void deleteDefaultAddrHH() {
        configSettings();

        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        delete consAccsAddrs.addrs;
        Test.stopTest();
    
        //Verify that the HH and Contacts' address fields are cleared
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        List<Contact> listCon = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c, MailingState, 
                                 MailingPostalCode, MailingCountry, MailingLatitude, 
                                 MailingLongitude 
                                 FROM Contact];
        System.assertEquals(4, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assertEquals(Null, con.MailingStreet);
            System.assertEquals(Null, con.MailingCity);
            System.assertEquals(Null, con.Mailing_County__c); 
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertEquals(Null, con.Current_Address__c);
            System.assertEquals(Null, acc.BillingStreet);
            System.assertEquals(Null, acc.BillingCity);
            System.assertEquals(Null, acc.Billing_County__c);
        }
    }

    /*********************************************************************************************************
    @description Create a new non default Address record. Associate this non default Address record to an existing
	* Contact record and set its is_Address_Override__c = True and associate it to the HH Account. 
	* Delete existing non default override Address record. 
	* Verify: 
	* - For creation of new non default Address record: 
	* 	- Household Account's billing fields are not updated with the non default Address record. 
	* 	- Contact's mailing address field are updated to match the mailing fields from the new non default Address record. 
	* - For deletion of the non default Address record:
	* 	- Contact's mailing address fields are updated back to the original default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void deleteNonDefaultOverrideAddrHH() {
        configSettings();
           
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        System.assertEquals(4, consAccsAddrs.contacts.size()); 
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = False;
            addrs[i].MailingStreet__c = 'override' + i;
            addrs[i].MailingCity__c = 'override' + i;
            addrs[i].MailingCounty__c = 'override' + i;
        }
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        insert addrs;
        
        //Set the Contacts' address overrides - one Contact per household
        List<Contact> listCon = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.Current_Address__c = addrs[i].Id;
            con.is_Address_Override__c = True;
            ADDR_Addresses_UTIL.copyAddressAddrSObj(addrs[i], con, 'Mailing', 'Primary_Address_Type__c', Null);
            listCon.add(con);
        }
        update listCon;      
        
        for (Contact contact : listCon) {
            System.assert(contact.MailingStreet.contains('override')); 
        }
        
        //Delete the non default Addresses recently created
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        delete addrs;
        Test.stopTest();
    
        //Verify that the HH Account and Contacts' address fields are set as the original default address values 
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        listCon = [SELECT Id, Name, AccountId, 
                   is_Address_Override__c, Current_Address__c, MailingStreet, 
                   MailingCity, Mailing_County__c, MailingState, 
                   MailingPostalCode, MailingCountry, MailingLatitude, 
                   MailingLongitude
                   FROM Contact];
        UTIL_Debug.debug('****Accounts deleteNonDefaultOverrideAddrHH: ' + JSON.serializePretty(mapAccIdAcc.values()));
        UTIL_Debug.debug('****Contacts deleteNonDefaultOverrideAddrHH: ' + JSON.serializePretty(listCon));
        System.assertEquals(4, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
            System.assert(con.MailingStreet.contains('Street'));
            System.assert(con.MailingCity.contains('City'));  
            System.assert(con.Mailing_County__c.contains('County'));      
        }
    }

    /*********************************************************************************************************
    @description Update existing default Address record where Default_Address__c is set to False. There are no
	* other existing Address records on the Household Account. 
	* Verify:
	* - Household Account's billing fields are cleared. 
	* - Contact's mailing fields are cleared. 
    **********************************************************************************************************/            
    @isTest
    private static void updateNonDefaultAddrHH() {
        configSettings();

        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        for (Account acc : consAccsAddrs.accs) {
            System.assertNotEquals(Null, acc.BillingCity); 
            System.assert(acc.BillingCity.contains('City')); 
            
        }
        
        for (Integer i = 0; i < 2; i++) {
            Address__c addr = consAccsAddrs.addrs[i];
            addr.Default_Address__c = False;
        }
        
        Test.startTest();
        update consAccsAddrs.addrs;
        Test.stopTest();
    
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account
                                                             WHERE Id IN :consAccsAddrs.accs]);

        List<Contact> listCon = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c, MailingState, 
                                 MailingPostalCode, MailingCountry, MailingLatitude, 
                                 MailingLongitude 
                                 FROM Contact];
        System.assertEquals(4, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assertEquals(Null, con.MailingStreet); 
            System.assertEquals(Null, con.MailingCity); 
            System.assertEquals(Null, con.Mailing_County__c);
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertEquals(Null, con.Current_Address__c); 
        }
    }

    /*********************************************************************************************************
    @description Create new non default Address records and associate to the Household Account. Set a Contact's
	* is_Address_Override__c to True. Update existing default Address record's mailing fields. 
	* Verify:
	* - Contact record whose is_Address_Override__c = False, will have their mailing fields updated based on the
	* newest mailing fields update from the default Address record.
	* - Contact record whose is_Address_Override__c = True, will not have their mailing fields updated based on the
	* newest mailing fields update from the default Address record. 
	* - Household Account's billing fields will be updated based on the newest mailing field update from the default
	* Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void setConAddrOverrideHH() {
        configSettings();
               
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());

        Address__c addrNew = new Address__c();
        addrNew.MailingStreet__c = 'street override';
        addrNew.MailingCity__c = 'city override';
        addrNew.Default_Address__c = False;
        addrNew.Parent_Account__c = consAccsAddrs.accs[0].Id;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert addrNew;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        
        //Set a Contact's address override 
        consAccsAddrs.contacts[0].Current_Address__c = addrNew.Id;
        consAccsAddrs.contacts[0].is_Address_Override__c = True;
        update consAccsAddrs.contacts[0];
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
    
        //Update the default Addresses
        for (Integer i = 0; i < 2; i++) {
            Address__c addr = consAccsAddrs.addrs[i];
            addr.MailingStreet__c = 'New Street' + i;
            addr.MailingCity__c = 'New City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update consAccsAddrs.addrs;
        Test.stopTest();
        

        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        List<Contact> listCon = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c, MailingState, 
                                 MailingPostalCode, MailingCountry, MailingLatitude, 
                                 MailingLongitude 
                                 FROM Contact];
        System.assertEquals(4, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            if (con.is_Address_Override__c) {
                System.assertEquals(con.Current_Address__c, addrNew.Id);
                System.assertEquals(False, isMatchAddressAccCon(acc, con));
                System.assert(!con.MailingStreet.contains('New Street'));
                System.assert(!con.MailingCity.contains('New City'));               
            } else {
                System.assertEquals(True, isMatchAddressAccCon(acc, con));
                System.assert(con.MailingStreet.contains('New Street'));
                System.assert(con.MailingCity.contains('New City'));
                System.assertEquals(False, con.is_Address_Override__c);
                System.assertNotEquals(Null, con.Current_Address__c);
            }
        }
    }

    /*********************************************************************************************************
    @description Create new non default Address record and associate it to a Contact record 
	* whose is_Address_Override__c = False. 
	* Verify: 
	* - The Contact record who is associated to the new non default Address record should have its mailing fields
	* updated to match the mailing fields from the non default Address record. 
	* - The Contact record who is assocaited to the new non default Address record's mailing fields should not
	* match the billing fields on the Household Account. 
	* - Household Account's billing fields should not be updated and still be the original default Address. 
    **********************************************************************************************************/            
    @isTest
    private static void setConAddrNoOverrideHH() {
        configSettings();
             
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        for (Contact contact : consAccsAddrs.contacts) {
            System.assertEquals(False, contact.is_Address_Override__c); 
        }
        
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = False;
            addrs[i].MailingStreet__c = 'not override' + i;
            addrs[i].MailingCity__c = 'not override' + i;
        }
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        insert addrs;
        
        //Set the Contacts' address overrides
        List<Contact> listCon = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.Current_Address__c = addrs[i].Id;
            con.is_Address_Override__c = False;
            listCon.add(con);
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update listCon;
        Test.stopTest();
        
        //Verify that the HH and Contacts share the same address, except for the contacts we modified
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        listCon = [SELECT Id, Name, AccountId, 
                   is_Address_Override__c, Current_Address__c, Current_Address__r.Default_Address__c, 
                   MailingStreet, MailingCity, Mailing_County__c, 
                   MailingState, MailingPostalCode, MailingCountry, 
                   MailingLatitude, MailingLongitude 
                   FROM Contact];
        
        Integer cNotOverride = 0;
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            if (con.MailingStreet.contains('not override') == True) {
                cNotOverride++;
                System.assertEquals(False, isMatchAddressAccCon(acc, con));
                System.assert(con.MailingStreet.contains('not override'));
                System.assert(con.MailingCity.contains('not override'));
                System.assertEquals(False, con.is_Address_Override__c);
                System.assertNotEquals(Null, con.Current_Address__c);   
                System.assertEquals(False, con.Current_Address__r.Default_Address__c);
            } else {
                System.assertEquals(True, con.Current_Address__r.Default_Address__c);
                System.assertEquals(True, isMatchAddressAccCon(acc, con));
                System.assert(con.MailingStreet.contains('Street'));
                System.assert(con.MailingCity.contains('City'));
                System.assertEquals(False, con.is_Address_Override__c);
                System.assertNotEquals(Null, con.Current_Address__c);
            }
        }
        System.assertEquals(2, cNotOverride);
    }

    /*********************************************************************************************************
    @description Create new default Address record on an existing Household Account with Contact. 
	* Verify: 
	* - New default Address record is created and associated to the Household Account. 
	* - New default Address record's Latest_Start_Date__c is with today's date.   
	* - Contact's mailing fields are updated to match the mailing fields from the newly created default Address records.
	* - Account's billing fields are updated to match the mailing fields from the newly created default Address records. 
	* - The previous default Address record is no longer set as the default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNewDefaultAddrHH() {
        configSettings();
       
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        List<Address__c> listAddr = [select Id from Address__c];
        
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = True;
            addrs[i].MailingStreet__c = 'New Default Street' + i;
            addrs[i].MailingCity__c = 'New Default City' + i;
            addrs[i].MailingCounty__c = 'New Default County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert addrs;
        Test.stopTest();

        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        List<Contact> listCon = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c, MailingState, 
                                 MailingPostalCode, MailingCountry, MailingLatitude, 
                                 MailingLongitude 
                                 FROM Contact];
        System.assertEquals(4, listCon.size());
        
        //Verify that the HH and Contacts share the same address and its mailing fields matches the newly created default Address record 
        listAddr = [SELECT Id 
                    FROM Address__c];
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Default Street'));
            System.assert(con.MailingCity.contains('New Default City'));
            System.assert(con.Mailing_County__c.contains('New Default County'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
        
        //Verify the previous Address record's default is cleared
        //And verify latest start date and latest end date fields are appropriately set 
        listAddr = [SELECT Id, Default_Address__c, MailingStreet__c,
                    Latest_Start_Date__c, Latest_End_Date__c 
                    FROM Address__c];
        System.assertEquals(4, listAddr.size());
        for (Address__c addr : listAddr) {
            if (addr.MailingStreet__c.contains('New Default Street')) {
                System.assertEquals(True, addr.Default_Address__c); 
                System.assertEquals(System.today(), addr.Latest_Start_Date__c);
               	System.assertEquals(Null, addr.Latest_End_Date__c);
            } else {
                System.assertEquals(System.today(), addr.Latest_End_Date__c);                
            }
        }        
    }
    
    /*********************************************************************************************************
    @description Create new default Address record to an existing Household Account with Contact. Update previous
	* default Address record's mailing fields and mark it as the default Address record.
	* Verify:
	* - For newly created default Address record:
	* 	- Contact's and Account's mailing/billing fields are updated with the mailing fields from the newly created
	* 	Address record. 
	* 	- Previous default Address record is no longer marked as default Address record. 
	* - When updating the previous Address record's mailing fields and marking it as default: 
	* 	- Contact's and Account's mailing/billing fields are updated with the mailing fields from the recently
	* 	updated Address record. 
	* 	- Previous default Address record is no longer marked as default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNewDefaultAddrAndResetHH() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        List<Address__c> listAddrOriginal = consAccsAddrs.addrs;
        
        ADDR_Addresses_TDTM.addressIdsInserted = new Set<Id>();
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = True;
            addrs[i].MailingStreet__c = 'New Default Street' + i;
            addrs[i].MailingCity__c = 'New Default City' + i;
            addrs[i].MailingCounty__c = 'New Default County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert addrs;
 
         ADDR_Addresses_TDTM.addressIdsUpdated = new Set<Id>();       
        //Update original default Address record
        //added this extra set to test fix where we didn't use the correct default
        for (Integer i = 0; i < 2; i++) {
            listAddrOriginal[i].Default_Address__c = True;
            listAddrOriginal[i].MailingStreet__c = 'Original Default Street' + i;
            listAddrOriginal[i].MailingCity__c = 'Original Default City' + i;
            listAddrOriginal[i].MailingCounty__c = 'Original Default County' + i;
        }
        Test.startTest();
        update listAddrOriginal;
        Test.stopTest();

        //Verify that the HH and Contacts share the same address and it's new!
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        List<Contact> listCon = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c, MailingState, 
                                 MailingPostalCode, MailingCountry, MailingLatitude, 
                                 MailingLongitude 
                                 FROM Contact];
        System.assertEquals(4, listCon.size());
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('Original Default Street'));
            System.assert(con.MailingCity.contains('Original Default City'));
            System.assert(con.Mailing_County__c.contains('Original Default County'));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
        
        //Verify the previous default Address record is no longer the default Address record 
        //and verify latest start date and latest end date are appropriately set.
        List<Address__c> listAddr = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                     Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c 
                                     FROM Address__c];
        System.assertEquals(4, listAddr.size());
        for (Address__c addr : listAddr) {
            if (addr.MailingStreet__c.contains('Original Default Street')) {
                System.assertEquals(True, addr.Default_Address__c); 
                System.assertEquals(System.today(), addr.Latest_Start_Date__c);
               	System.assertEquals(Null, addr.Latest_End_Date__c);
            } else {
                System.assertEquals(False, addr.Default_Address__c); 
                System.assertEquals(System.today(), addr.Latest_End_Date__c);  
            }
        }        
    }

    /*********************************************************************************************************
    @description Create a non default Address record. Set the Contact's is_Address_Override__c to True. 
	* Verify:
	* - New non default Address record is created.
	* - If a Contact's is_Address_Override__c = True, then the Contact's mailing fields is updated to match the 
	* mailing fields from the newly created non default Address record. 
	* - If a Contact's is_Address_Override__c = False, then the Contact's mailing fields is not updated to match 
	* the mailing fields from the newly created non default Address record. 
	* - The Latest_Start_Date__c on the Address record is set. 
    **********************************************************************************************************/            
    @isTest
    private static void updateAddrOverrideHH() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());

        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = False;
            addrs[i].MailingStreet__c = 'override' + i;
            addrs[i].MailingCity__c = 'override' + i;
            addrs[i].MailingCounty__c = 'override' + i;
        }
        insert addrs;
        
        //Set the Contacts' address overrides
        List<Contact> listCon = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.Current_Address__c = addrs[i].Id;
            con.is_Address_Override__c = True;
            listCon.add(con);
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update listCon;
        Test.stopTest();
        
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        listCon = [SELECT Id, Name, AccountId, 
                   is_Address_Override__c, Current_Address__c, MailingStreet, 
                   MailingCity, Mailing_County__c, MailingState, 
                   MailingPostalCode, MailingCountry, MailingLatitude,
                   MailingLongitude 
                   FROM Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            if (con.is_Address_Override__c) {
                System.assertNotEquals(Null, con.Current_Address__c);
                System.assertEquals(False, isMatchAddressAccCon(acc, con));
                System.assert(con.MailingStreet.contains('override'));
                System.assert(con.MailingCity.contains('override'));   
                System.assert(con.Mailing_County__c.contains('override')); 
            } else {
                System.assertEquals(True, isMatchAddressAccCon(acc, con));
                System.assert(con.MailingStreet.contains('Street'));
                System.assert(con.MailingCity.contains('City'));
                System.assert(con.Mailing_County__c.contains('County'));
                System.assertEquals(False, con.is_Address_Override__c);
                System.assertNotEquals(Null, con.Current_Address__c);
            }
        }

        //Verify address overrides have latest start date and latest end date appropriately set.
        List<Address__c> listAddr = [SELECT Id, Latest_Start_Date__c, Latest_End_Date__c 
                                     FROM Address__c 
                                     WHERE Id IN :addrs];
        System.assertEquals(2, listAddr.size());
        for (Address__c addr : listAddr) {
           System.assertEquals(System.today(), addr.Latest_Start_Date__c);
           System.assertEquals(Null, addr.Latest_End_Date__c);
        }        
    }
        
    /*********************************************************************************************************
    @description Create a non default Address record. Set the Contact's is_Address_Override__c to True. 
	* Then set is_Address_Override__c to False. 
	* Verify: 
	* - Contact's mailing fields are updated back to the original mailing fields from the billing fields from
	* the Household Account record.
	* - Both Latest_Start_Date__c and Latest_End_Date__c are populated because is_Address_Override__c was
	* set and reset. 
    **********************************************************************************************************/            
    @isTest
    private static void clearAddrOverrideHH() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        UTIL_Debug.debug('****clearAddrOverrideHH consAccsAddrs: ' + JSON.serializePretty(consAccsAddrs));
        
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = False;
            addrs[i].MailingStreet__c = 'override' + i;
            addrs[i].MailingCity__c = 'override' + i;
            addrs[i].Latest_Start_Date__c = System.today();
        }
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        insert addrs;
        
        //Set the Contact's address overrides - one contact in each account
        List<Contact> listCon = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.Current_Address__c = addrs[i].Id;
            con.is_Address_Override__c = True;
            ADDR_Addresses_UTIL.copyAddressAddrSObj(addrs[i], con, 'Mailing', 'Primary_Address_Type__c', null);
            listCon.add(con);
        }
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        update listCon;

        List<Contact> allCons = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c, MailingState, 
                                 MailingPostalCode, MailingCountry, MailingLatitude, 
                                 MailingLongitude 
                                 FROM Contact];
        UTIL_Debug.debug('****Contacts after first update: ' + JSON.serializePretty(allCons));

        //Clear out the Contact's address overrides
        for (Contact con : listCon) {
            con.is_Address_Override__c = False;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        UTIL_Debug.debug('****Second explicit contacts update in clearAddrOverrideHH');
        Test.startTest();
        update listCon;
        Test.stopTest();
        
        //Verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        allCons = [SELECT Id, Name, AccountId, 
                   is_Address_Override__c, Current_Address__c, MailingStreet, 
                   MailingCity, Mailing_County__c,  MailingState, 
                   MailingPostalCode, MailingCountry, MailingLatitude, 
                   MailingLongitude 
                   FROM Contact];
        UTIL_Debug.debug('****Contacts after second update: ' + JSON.serializePretty(allCons));
        for (Contact con : allCons) {
            UTIL_Debug.debug('****Contact after clearing override: ' + JSON.serializePretty(con));
            Account acc = mapAccIdAcc.get(con.AccountId);
            UTIL_Debug.debug('****Parent Account after clearing override: ' + JSON.serializePretty(acc));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('Street'));
            System.assert(con.MailingCity.contains('City'));
        }

        //Verify address overrides have latest start date and latest end date appropriately set.
        List<Address__c> listAddr = [SELECT Id, Latest_Start_Date__c, Latest_End_Date__c 
                                     FROM Address__c 
                                     WHERE Id IN :addrs];
        System.assertEquals(2, listAddr.size());
        UTIL_Debug.debug('****Additional addresses after update: ' + JSON.serializePretty(listAddr));
        for (Address__c addr : listAddr) {
           System.assertEquals(System.today(), addr.Latest_Start_Date__c);
           System.assertEquals(System.today(), addr.Latest_End_Date__c);
        }     
    }

    /*********************************************************************************************************
    @description Update Contact's mailing fields. 
	* Verify: 
	* - New default Address record is created. 
	* - Household Account's billing fields are updated with the mailing fields from the new default Address record.
	* - Previous old default Address record is no longer mark as default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void updateConAddrNewHH() {
        configSettings();
             
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());

        for (Integer i = 0; i < 2; i++) {
            consAccsAddrs.contacts[i*2 + i].MailingStreet = 'final Street Edit';
            consAccsAddrs.contacts[i*2 + i].MailingCity = 'final City Edit';
            consAccsAddrs.contacts[i*2 + i].Mailing_County__c = 'final County Edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update consAccsAddrs.contacts;
        Test.stopTest();
        
        //Verify that the Household Account and Contact share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        List<Contact> listCon = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c, MailingState, 
                                 MailingPostalCode, MailingCountry, MailingLatitude, 
                                 MailingLongitude 
                                 FROM Contact];
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('final Street Edit'));
            System.assert(con.MailingCity.contains('final City Edit'));
            System.assert(con.Mailing_County__c.contains('final County Edit'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
 
        //Verify the previous addresses got Default cleared.
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c 
                                     FROM Address__c];
        //Each set of edits created a new address object 
        System.assertEquals(4, listAddr.size());
        for (Address__c addr : listAddr) {
            if (addr.MailingStreet__c.contains('final Street Edit')) {
                System.assertEquals(True, addr.Default_Address__c);
            } else {
                System.assertEquals(False, addr.Default_Address__c);
            }
        }                
    }

    /*********************************************************************************************************
    @description Update Contact's mailing fields and set is_Address_Override__c = True. 
	* Verify:
	* - New non default Address record is created.  
	* - Household Account billing fields are not updated - billing fields matches the default Address record. 
	* - The Contact that was updated will not match the mailing fields with the Household Account billing fields. 
    **********************************************************************************************************/            
    @isTest
    private static void updateConAddrAndMarkAddrOverride() {
        configSettings();

        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        for (Integer i = 0; i < 4; i++) {
            consAccsAddrs.contacts[i].MailingStreet = 'Direct Street Edit';
            consAccsAddrs.contacts[i].MailingCity = 'Direct City Edit';
            consAccsAddrs.contacts[i].Mailing_County__c = 'Direct County Edit';
            consAccsAddrs.contacts[i].is_Address_Override__c = True;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update consAccsAddrs.contacts;
        Test.stopTest();
        
        //Verify that the Household Account and Contacts do not share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        List<Contact> listCon = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c, MailingState, 
                                 MailingPostalCode, MailingCountry, MailingLatitude, 
                                 MailingLongitude 
                                 FROM Contact];
        UTIL_Debug.debug('****updateConAddrMarkOverrideHH accounts: ' + JSON.serializePretty(mapAccIdAcc.values()));
        UTIL_Debug.debug('****updateConAddrMarkOverrideHH contacts: ' + JSON.serializePretty(listCon));
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(False, isMatchAddressAccCon(acc, con));
            System.assertEquals(True, con.MailingStreet.contains('Direct Street Edit'));
            System.assertEquals(True, con.MailingCity.contains('Direct City Edit'));
            System.assertEquals(True, con.Mailing_County__c.contains('Direct County Edit'));
            System.assertEquals(False, acc.BillingStreet.contains('Direct Street Edit'));
            System.assertEquals(False, acc.BillingCity.contains('Direct City Edit'));
            System.assertEquals(False, acc.Billing_County__c.contains('Direct County Edit'));
            System.assertEquals(True, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
 
        //Verify the previous addresses got Default cleared.
        List<Address__c> listAddr = [SELECT Id, Default_Address__c, MailingStreet__c, Parent_Account__c 
                                     FROM Address__c];
        System.assertEquals(6, listAddr.size());
        for (Address__c addr : listAddr) {
            if (addr.MailingStreet__c.contains('Direct Street Edit')) {
                System.assertEquals(False, addr.Default_Address__c);
            }
            boolean isNewEdit = (addr.MailingStreet__c.contains('Direct Street Edit'));
            System.assertNotEquals(isNewEdit, addr.Default_Address__c);
        }                
    }

    /*********************************************************************************************************
    @description Update Contact's mailing fields - format, case, and mailing address field that don't count 
	* as a new Address to insert.
	* Verify:
	* - Existing default Address record's mailing fields are updated.
	* - No new Address record is created. 
	* - Household Account and Contact's billing/mailing fields are updated. 
    **********************************************************************************************************/            
    @isTest
    private static void updateCaseAndFormatForContactAddrFields() {
        configSettings();
          
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
       
        //NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
        List<Contact> listCon = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.MailingStreet = 'Direct Street Edit';
            listCon.add(con);
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        update listCon;
        
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.Mailing_County__c = 'bergen';
        }
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        update listCon;
        
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.MailingState = 'Washington';
        }
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        update listCon;
		
        //Whitespace and casing update should not count as a real edit 
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.MailingStreet = ' direct street  edit ';  
            con.MailingState = 'Oregon';
        }
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        Test.startTest();
        update listCon;
        Test.stopTest();
        
        //Verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        listCon = [SELECT Id, Name, AccountId, 
                   is_Address_Override__c, Current_Address__c, MailingStreet, 
                   MailingCity, Mailing_County__c, MailingState, 
                   MailingPostalCode, MailingCountry, MailingLatitude, 
                   MailingLongitude 
                   FROM Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('direct street  edit'));
            System.assert(con.Mailing_County__c.contains('bergen'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
 
        //Verify that no new address was created
        List<Address__c> listAddr = [SELECT Id, Default_Address__c, MailingStreet__c, Parent_Account__c 
                                     FROM Address__c];
        System.assertEquals(2, listAddr.size());
        for (Address__c addr : listAddr) {
            System.assertEquals('direct street  edit', addr.MailingStreet__c);
        }                
    }

    /*********************************************************************************************************
    @description Update Contact's mailing fields and Account's billing fields - format, case, and mailing address field that don't count 
	* as a new Address to insert.
	* Verify:
	* - Existing default Address record's mailing fields are updated.
	* - No new Address record is created. 
	* - Household Account and Contact's billing/mailing fields are updated. 
    **********************************************************************************************************/            
    @isTest
    private static void updateCaseAndFormatForConAccAddrFields() {
        configSettings();
         
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        //NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        List<Contact> listCon = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.MailingStreet = 'Direct Street Edit';
            listCon.add(con);
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        update listCon;
      
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.MailingState = 'Washington';
        }
        update listCon;
		
        //Whitespace and casing should not count as a real edit 
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.MailingStreet = ' direct street  edit ';  
            con.MailingState = 'Oregon';
        }
        update listCon;

        //Update casing only 
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.MailingStreet = ' DIRECT STREET  EDIT ';  
        }
        Test.startTest();
        update listCon;
        Test.stopTest();
        
        //Verify that the Household Account and Contact share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        listCon = [SELECT Id, Name, AccountId, 
                   is_Address_Override__c, Current_Address__c, MailingStreet, 
                   MailingCity, Mailing_County__c, MailingState, 
                   MailingPostalCode, MailingCountry, MailingLatitude, 
                   MailingLongitude 
                   FROM Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.equals('DIRECT STREET  EDIT'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
 
        //Verify that no new address was created
        List<Address__c> listAddr = [SELECT Id, Default_Address__c, MailingStreet__c, Parent_Account__c 
                                     FROM Address__c];
        System.assertEquals(2, listAddr.size());
        for (Address__c addr : listAddr) {
            System.assert(addr.MailingStreet__c.equals('DIRECT STREET  EDIT'));
        }
        
        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();
        //Test that changing the case from the Account record updates the Address record and 
        //all mailing fields on Contact record 
        for (Integer i = 0; i < 2; i++) {
            Account acc = consAccsAddrs.accs[i];
            acc.BillingStreet = 'direct street  edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        update consAccsAddrs.accs;
        
        //Verify that the Household Account and Contacts share the same address
        mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                            BillingCity, Billing_County__c, BillingState, 
                                            BillingPostalCode, BillingCountry, BillingLatitude, 
                                            BillingLongitude 
                                            FROM Account]);
        listCon = [SELECT Id, Name, AccountId, 
                   is_Address_Override__c, Current_Address__c, MailingStreet, 
                   MailingCity, Mailing_County__c, MailingState, 
                   MailingPostalCode, MailingCountry, MailingLatitude, 
                   MailingLongitude 
                   FROM Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.equals('direct street  edit'));
           
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
 
        //Verify that no new address was created
        listAddr = [SELECT Id, Default_Address__c, MailingStreet__c, 
                    MailingCounty__c, Parent_Account__c 
                    FROM Address__c];
        System.assertEquals(2, listAddr.size());
        for (Address__c addr : listAddr) {
            System.assert(addr.MailingStreet__c.equals('direct street  edit'));
            System.assert(addr.MailingCounty__c.contains('County')); 
        }
    }

    /*********************************************************************************************************
    @description Update Account's billing fields. 
	* Verify:
	* - New default Address record is created. 
	* - Household Account billing and Contact mailing fields are updated with the newest default Address record's 
	* mailing fields. 
    **********************************************************************************************************/            
    @isTest
    private static void updateAccAddrAndInsertNewAddr() {
        configSettings();
          
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < 2; i++) {
            Account acc = consAccsAddrs.accs[i];
            acc.BillingStreet = 'Direct Street Edit';
            acc.BillingCity = 'Direct City Edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        update consAccsAddrs.accs;

        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < 2; i++) {
            Account acc = consAccsAddrs.accs[i];
            acc.BillingStreet = 'another Street Edit';
            acc.BillingCity = 'another City Edit';
        }
        update consAccsAddrs.accs;
        
        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < 2; i++) {
            Account acc = consAccsAddrs.accs[i];
            acc.BillingStreet = 'third Street Edit';
            acc.Billing_County__c = 'third County Edit';
        }
        update consAccsAddrs.accs;

        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < 2; i++) {
            Account acc = consAccsAddrs.accs[i];
            acc.BillingStreet = 'final Street Edit';
            acc.BillingCity = 'final City Edit';
            acc.Billing_County__c = 'final County Edit'; 
        }
        Test.startTest();
        update consAccsAddrs.accs;
        Test.stopTest();
        
        //Verify that the Household Account and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        List<Contact> listCon = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c, MailingState, 
                                 MailingPostalCode, MailingCountry, MailingLatitude, 
                                 MailingLongitude 
                                 FROM Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(acc.BillingStreet.contains('final Street Edit'));
            System.assert(con.MailingStreet.contains('final Street Edit')); 
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
 
        //Verify the previous Address record is no longer default
        List<Address__c> listAddr = [SELECT Id, Default_Address__c, MailingStreet__c, Parent_Account__c 
                                     FROM Address__c];
        //Each set of edits created a new address object 
        System.assertEquals(10, listAddr.size());
        for (Address__c addr : listAddr) {
            if (addr.MailingStreet__c.contains('final Street Edit')) {
                System.assertEquals(True, addr.Default_Address__c);
            } else {
                System.assertEquals(False, addr.Default_Address__c);
            }
        }        
    }

    /*********************************************************************************************************
    @description Update Account's billing fields -  format, case, and mailing address field that don't count 
	* as a new Address to insert.  
    * Verify:
    * - Existing default Address mailing fields are updated. 
    * - Household Account and Contact's billing/mailing fields are updated with the latest address field updates. 
    * - No new Address record is created for each billing field(s) update. 
    **********************************************************************************************************/            
    @isTest
    private static void updateAccAddrExistingHH() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        //NOTE: We only modify 1 field, so it will be treated as an update to an existing address!
        for (Integer i = 0; i < 2; i++) {
            Account acc = consAccsAddrs.accs[i];
            acc.BillingStreet = 'Direct Street Edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        update consAccsAddrs.accs;

        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < 2; i++) {
            Account acc = consAccsAddrs.accs[i];
            acc.BillingState = 'Washington';
        }
        update consAccsAddrs.accs;
        
        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < 2; i++) {
            Account acc = consAccsAddrs.accs[i];
            acc.Billing_County__c = 'county';
        }
        update consAccsAddrs.accs;
		
        //Whitespace and casing should not count as real edit.
        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < 2; i++) {
            Account acc = consAccsAddrs.accs[i];
            acc.BillingStreet = ' direct street  edit ';    
            acc.BillingState = 'Oregon';
        }
        Test.startTest();
        update consAccsAddrs.accs;
        Test.stopTest();
        
        //Verify that the Household Account and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        List<Contact> listCon = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c, MailingState, 
                                 MailingPostalCode, MailingCountry, MailingLatitude, 
                                 MailingLongitude 
                                 FROM Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(acc.BillingStreet.contains('direct street  edit'));
            System.assert(con.MailingStreet.contains('direct street  edit')); 
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
 
        //Verify that no new address was created
        List<Address__c> listAddr = [SELECT Id, Default_Address__c, MailingStreet__c, Parent_Account__c 
                                     FROM Address__c];
        System.assertEquals(2, listAddr.size());
        for (Address__c addr : listAddr) {
            System.assertEquals('direct street  edit', addr.MailingStreet__c);
        }        
    }

    /*********************************************************************************************************
    @description Create an Address with no Account. 
    * Verify:
    * - Runtime error. 
    **********************************************************************************************************/            
    @isTest
    private static void newAddrNoAccount() {
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            System.assertEquals(Null, addrs[i].Parent_Account__c);
        }
        
        try {
            insert addrs;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(Label.addrHhAdmAccountOnly));
            return;
        }
        System.assert(False);
    }

    /*********************************************************************************************************
    @description Create a new current seasonal non default Address record to an existing Household Account with 
	* existing default Address.
	* Verify:
	* - Creates new non default Seasonal Address record. 
	* - Contact's and Household Account's mailing/billing fields are updated with the mailing fields from the 
	* new Seasonal Address record. 
	* - Existing default Address record is still set as default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNewSeasonalAddrHH() {
        configSettings();
             
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = False;
            addrs[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(-1).month());
            addrs[i].Seasonal_Start_Day__c = '1';
            addrs[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(1).month());
            addrs[i].Seasonal_End_Day__c = '28';
            addrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrs[i].MailingCity__c = 'New Seasonal City' + i;
            addrs[i].MailingCounty__c = 'New Seasonal County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert addrs;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();
        
        //Verify that the Household Account and Contacts share the same address 
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        List<Contact> listCon = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c, MailingState, 
                                 MailingPostalCode, MailingCountry, MailingLatitude, 
                                 MailingLongitude 
                                 FROM Contact];
        System.assertEquals(4, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Seasonal Street'));
            System.assert(con.MailingCity.contains('New Seasonal City'));
            System.assert(con.Mailing_County__c.contains('New Seasonal County'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
        
        //Verify the previous default Address record is still marked as default
        List<Address__c> listAddr = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                     Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c 
                                     FROM Address__c];
        System.assertEquals(4, listAddr.size());
        for (Address__c addr : listAddr) {
            if (addr.MailingStreet__c.contains('New Seasonal Street')) {
                System.assertEquals(False, addr.Default_Address__c); 
            } else {
                System.assertEquals(True, addr.Default_Address__c); 
            }
        }        
    }
    
    /*********************************************************************************************************
    @description Create a new current seasonal non default Address record with its year populated to an existing Household 
	* Account with existing default Address.
	* Verify:
	* - Creates new non default Seasonal Address record. 
	* - Contact's and Household Account's mailing/billing fields are updated with the mailing fields from the 
	* new Seasonal Address record. 
	* - Existing default Address record is still set as default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNewSeasonalAddrHHWithYear() {
        configSettings();

        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = False;
            addrs[i].Seasonal_Start_Year__c = System.today().addYears(-1).year();
            addrs[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(-1).month());
            addrs[i].Seasonal_Start_Day__c = '1';
            addrs[i].Seasonal_End_Year__c = System.today().addYears(1).year();
            addrs[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(1).month());
            addrs[i].Seasonal_End_Day__c = '28';
            addrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrs[i].MailingCity__c = 'New Seasonal City' + i;
            addrs[i].MailingCounty__c = 'New Seasonal County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert addrs;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();
        
        //Verify that the Household Account and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c,BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        List<Contact> listCon = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c, MailingState, 
                                 MailingPostalCode, MailingCountry, MailingLatitude, 
								 MailingLongitude 
                                 FROM Contact];
        System.assertEquals(4, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Seasonal Street'));
            System.assert(con.MailingCity.contains('New Seasonal City'));
            System.assert(con.Mailing_County__c.contains('New Seasonal County'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
        
        //Verify the previous default Address record is marked as default
        List<Address__c> listAddr = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                     Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c 
                                     FROM Address__c];
        System.assertEquals(4, listAddr.size());
        for (Address__c addr : listAddr) {
            if (addr.MailingStreet__c.contains('New Seasonal Street')) {
                System.assertEquals(False, addr.Default_Address__c); 
            } else {
                System.assertEquals(True, addr.Default_Address__c); 
            }
        }        
    }

    /*********************************************************************************************************
    @description Create a non current new seasonal non default Address record to an existing Household 
	* Account with existing default Address.
	* Verify:
	* - Creates new non default Seasonal Address record. 
	* - Contact's and Household Account's mailing/billing fields are not updated. 
	* - Existing default Address record is still set as default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNewSeasonalAddrNotCurrentHH() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());

        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = False;
            addrs[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(1).month());
            addrs[i].Seasonal_Start_Day__c = '1';
            addrs[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(2).month());
            addrs[i].Seasonal_End_Day__c = '28';
            addrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrs[i].MailingCity__c = 'New Seasonal City' + i;
            addrs[i].MailingCounty__c = 'New Seasonal County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert addrs;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();
        
        //Verify that the HH Account and Contacts share the same address and it's new!
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        List<Contact> listCon = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c, MailingState, MailingPostalCode, 
                                 MailingCountry, MailingLatitude, 
                                 MailingLongitude 
                                 FROM Contact];
        System.assertEquals(4, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(!con.MailingStreet.contains('New Seasonal Street'));
            System.assert(!con.MailingCity.contains('New Seasonal City'));
            System.assert(!con.Mailing_County__c.contains('New Seasonal County'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
        
        //Verify the previous default Address record is still marked as default
        List<Address__c> listAddr = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                     Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c 
                                     FROM Address__c];
        System.assertEquals(4, listAddr.size());
        for (Address__c addr : listAddr) {
            if (addr.MailingStreet__c.contains('New Seasonal Street')) {
                System.assertEquals(False, addr.Default_Address__c); 
            } else {
                System.assertEquals(True, addr.Default_Address__c); 
            }
        }        
    }

    /*********************************************************************************************************
    @description Update existing non current seasonal Address record to make it current. 
	* Verify:
	* - Contact's and Household Account's mailing/billing fields are updated with the mailing fields from the 
	* current Seasonal Address record. 
	* - Existing default Address record is still set as default Address record.
    **********************************************************************************************************/            
    @isTest
    private static void updateSeasonalAddrHH() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = False;
            addrs[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(1).month());
            addrs[i].Seasonal_Start_Day__c = '1';
            addrs[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(2).month());
            addrs[i].Seasonal_End_Day__c = '28';
            addrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrs[i].MailingCity__c = 'New Seasonal City' + i;
            addrs[i].MailingCounty__c = 'New Seasonal County' + i;
        }
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        insert addrs;
        
        //Update Seasonal Address record to make it current
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(-1).month());
        }
        Test.startTest();
        ADDR_Contact_TEST.turnOnAllAddrTriggers();                
        update addrs;
        Test.stopTest();
        
        //Verify that the Household and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        List<Contact> listCon = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c, MailingState, 
                                 MailingPostalCode, MailingCountry, MailingLatitude, 
                                 MailingLongitude 
                                 FROM Contact];
        System.assertEquals(4, listCon.size());
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Seasonal Street'));
            System.assert(con.MailingCity.contains('New Seasonal City'));
            System.assert(con.Mailing_County__c.contains('New Seasonal County'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
        
        //Verify the previous default Address record is still marked as default 
        List<Address__c> listAddr = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                     Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c 
                                     FROM Address__c];
        System.assertEquals(4, listAddr.size());
        for (Address__c addr : listAddr) {
            if (addr.MailingStreet__c.contains('New Seasonal Street')) {
                System.assertEquals(False, addr.Default_Address__c); 
            } else {
                System.assertEquals(True, addr.Default_Address__c); 
            }
        }        
    }

    /*********************************************************************************************************
    @description Tests ADDR_Seasonal_Batch - Create a new current seasonal non default Address record to an 
	* existing Household Account with existing default Address.
	* Verify:
	* - Creates new non default Seasonal Address record. 
	* - Contact's and Household Account's mailing/billing fields are updated with the mailing fields from the 
	* new Seasonal Address record. 
	* - Existing default Address record is still set as default Address record. 
    **********************************************************************************************************/            
    @isTest
    public static void scheduleSeasonalAddrUpdateHH() {
        configSettings();
                
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
 
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = False;
            addrs[i].Seasonal_Start_Month__c = String.valueOf(System.today().month());
            addrs[i].Seasonal_Start_Day__c = String.valueOf(System.today().day());
            addrs[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(1).month());
            addrs[i].Seasonal_End_Day__c = '28';
            addrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        
        //Hack! by setting our trigger handler as run,
        //we can insert the new seasonal addresses but not have them processed.
        //this way we can test the scheduled job!
        ADDR_Addresses_TDTM.turnOff();
        insert addrs;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();

        //Schedule the job just for test coverage purposes. But we still have to manually run the
        //batch, as batch jobs run from a scheduled job don't actually run after stopTest, as described
        //at https://salesforce.stackexchange.com/questions/36806/does-test-stoptest-ensure-a-system-schedule-database-batchable-completes-in-a
        STG_InstallScript.scheduleJobIfNotScheduled('Seasonal Addresses Update', '0 15 0 * * ?', 'ADDR_Seasonal_SCHED');
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name = 'Seasonal Addresses Update'];
        // Verify the expressions are the same
        System.assertEquals('0 15 0 * * ?', ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        System.assert(String.valueOf(ct.NextFireTime).contains('00:15:00'));
        
        //Run the scheduled batch directly
        ADDR_Seasonal_BATCH batch = new ADDR_Seasonal_BATCH();
        Test.startTest(); 
        Database.executeBatch(batch);
        Test.stopTest();
        
        //Verify that the HH and Contacts share the same address and it's new!
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        List<Contact> listCon = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c, MailingState, 
                                 MailingPostalCode, MailingCountry, MailingLatitude, 
                                 MailingLongitude 
                                 FROM Contact];
        System.assertEquals(4, listCon.size());
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Seasonal Street'));
            System.assert(con.MailingCity.contains('New Seasonal City'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
        
        //Verify the previous default Address record is still marked as default
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, 
                                     Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c 
                                     FROM Address__c];
        System.assertEquals(2 * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            System.assertEquals(!fSeasonal, addr.Default_Address__c);
        }        
    }

    /*********************************************************************************************************
    @description Create non default Address record. Update Account's billing fields to match the mailing fields
	* from the non default Address record. 
	* Verify: 
	* - No new duplicate Address record is created.
	* - Found match Address record is updated as the default Address record. 
	* - Old default Address record is no longer marked as default. 
	* - Contact's mailing fields are updated to match the mailing fields from the mailings fields on the newly
	* marked default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void newDupeAccountAddrNonDefaultHH() {
        configSettings();
           
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());

        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = False;
            addrs[i].MailingStreet__c = 'New Street' + i;
            addrs[i].MailingCity__c = 'New City' + i;
            addrs[i].MailingCounty__c = 'New County' + i;

        }
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        insert addrs;
 
        for (Integer i = 0; i < 2; i++) {
            consAccsAddrs.accs[i].BillingStreet = addrs[i].MailingStreet__c;
            consAccsAddrs.accs[i].BillingCity = addrs[i].MailingCity__c;
            consAccsAddrs.accs[i].Billing_County__c = addrs[i].MailingCounty__c;
            consAccsAddrs.accs[i].BillingState = addrs[i].MailingState__c;
            consAccsAddrs.accs[i].BillingPostalCode = addrs[i].MailingPostalCode__c;
            consAccsAddrs.accs[i].BillingCountry = addrs[i].MailingCountry__c;
        }        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update consAccsAddrs.accs;
        Test.stopTest();
        
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        List<Contact> listCon = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c, MailingState, 
                                 MailingPostalCode, MailingCountry, MailingLatitude, 
                                 MailingLongitude 
                                 FROM Contact];
        List<Address__c> listAddr = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                     Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c 
                                     FROM Address__c];
        System.assertEquals(4, listAddr.size());
        
        //Verify that the Household and Contacts share the same address and it's new!
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Street'));
            System.assert(con.MailingCity.contains('New City'));
            System.assert(con.Mailing_County__c.contains('New County'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
        
        //Verify the new addresses still are Default and we don't have too many
        for (Address__c addr : listAddr) {
            if (addr.MailingStreet__c.contains('New Street')) {
                System.assertEquals(True, addr.Default_Address__c);
            } else {
                System.assertEquals(False, addr.Default_Address__c); 
            }
        }        
 
    }

    /*********************************************************************************************************
    @description Create non default Address record. Update Contact's mailings fields to match the mailing fields
	* from the non default Address record. 
	* Verify: 
	* - No new duplicate Address record is created.
	* - Found match Address record is updated as the default Address record. 
	* - Old default Address record is no longer marked as default. 
	* - Account's billings fields are updated to match the mailing fields from the mailings fields on the newly
	* marked default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void newDupeContactAddrNonDefaultHH() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());

        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = False;
            addrs[i].MailingStreet__c = 'New Street' + i;
            addrs[i].MailingCity__c = 'New City' + i;
            addrs[i].MailingCounty__c = 'New County' + i;
        }
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        insert addrs;
 
        for (Integer i = 0; i < 2; i++) {
            for (Integer j = 0; j < 2; j++) {
                consAccsAddrs.contacts[(i * 2) + j].MailingStreet = addrs[i].MailingStreet__c;
                consAccsAddrs.contacts[(i * 2) + j].MailingCity = addrs[i].MailingCity__c;
                consAccsAddrs.contacts[(i * 2) + j].Mailing_County__c = addrs[i].MailingCounty__c;
                consAccsAddrs.contacts[(i * 2) + j].MailingState = addrs[i].MailingState__c;
                consAccsAddrs.contacts[(i * 2) + j].MailingPostalCode = addrs[i].MailingPostalCode__c;
                consAccsAddrs.contacts[(i * 2) + j].MailingCountry = addrs[i].MailingCountry__c;
            }
        }        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update consAccsAddrs.contacts;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        List<Contact> listCon = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c, MailingState, 
                                 MailingPostalCode, MailingCountry, MailingLatitude, 
                                 MailingLongitude 
                                 FROM Contact];
        System.assertEquals(4, listCon.size());
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Street'));
            System.assert(con.MailingCity.contains('New City'));
            System.assert(con.Mailing_County__c.contains('New County'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
        
        //Verify the new addresses still are Default and we don't have too many
        List<Address__c> listAddr = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                     Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c 
                                     FROM Address__c];
        System.assertEquals(4, listAddr.size());
        for (Address__c addr : listAddr) {
            if (addr.MailingStreet__c.contains('New Street')) {
                System.assertEquals(True, addr.Default_Address__c); 
            } else {
                System.assertEquals(False, addr.Default_Address__c); 
            }
        }
    }

    /*********************************************************************************************************
    @description Create a non default Address record and associate it to a Contact whose is_Address_Override__c is enabled. 
	* Verify: 
	* - New non default Address record is created. 
	* - Contact record (whose is_Address_Override__c is enabled) mailing fields are updated to match the mailing 
	* fields from the newly created non default Address record.
	* - Existing Contact whose is_Address_Override__c is disabled mailing fields are not updated to match the 
	* mailing fields from the newly created non default Address record. 
	* - Account's billing fields is not updated to match the mailing fields from the newly created non default
	* Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void updateConAddrWithOverrideHH() {
        configSettings();
               
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());

        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        ADDR_Addresses_TDTM.addressIdsInserted = new Set<Id>();
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        ADDR_Addresses_TDTM.addressIdsInserted = new Set<Id>();
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = False;
            addrs[i].MailingStreet__c = 'override' + i;
            addrs[i].MailingCity__c = 'override' + i;
            addrs[i].MailingCounty__c = 'override' + i;
        }
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        insert addrs;
    
        ADDR_Contact_TEST.turnOnAllAddrTriggers();    
        //Set the Contact's Address override
        List<Contact> listCon = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.Current_Address__c = addrs[i].Id;
            con.is_Address_Override__c = True;
            listCon.add(con);
        }
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        update listCon;
 
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        for (Contact con : listCon) {
            con.MailingStreet = 'Direct Street Edit';
            con.MailingCity = 'Direct City Edit';
        }
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        Test.startTest();
        update listCon;
        Test.stopTest();
        
        //Verify that the Household and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        listCon = [SELECT Id, Name, AccountId, 
                   is_Address_Override__c, Current_Address__c, MailingStreet, 
                   MailingCity, Mailing_County__c, MailingState, 
                   MailingPostalCode, MailingCountry, MailingLatitude, 
                   MailingLongitude 
                   FROM Contact];
 
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            //Mailing fields for Contact record's whose is_Address_Override__c is disabled, will not contain
            //the mailing fields from the Address record associated to the Contact whose is_Address_Override__c is enabled. 
            if (con.is_Address_Override__c == False) {
                System.assertNotEquals(Null, con.Current_Address__c);
                System.assertEquals(True, isMatchAddressAccCon(acc, con));
                System.assert(!con.MailingStreet.contains('Direct Street Edit'));
                System.assert(!con.MailingCity.contains('Direct City Edit'));
                System.assert(!con.MailingStreet.contains('override'));
                System.assert(!con.MailingCity.contains('override'));
                System.assert(!con.Mailing_County__c.contains('override'));
            } 
            //Mailing fields for Contact record's whose is_Address_Override__c is enabled, should contain 
            //mailing fields with the latest update that starts with "Direct"
            else {
                System.assertEquals(False, isMatchAddressAccCon(acc, con));
                System.assert(con.MailingStreet.contains('Direct Street Edit'));
                System.assert(con.MailingCity.contains('Direct City Edit'));
                System.assertEquals(True, con.is_Address_Override__c);
                System.assertNotEquals(Null, con.Current_Address__c);
            }
        }
 
        //Verify the new overrides are not marked default, and that the contact points to them
        List<Address__c> listAddr = [SELECT Id, Default_Address__c, MailingStreet__c, Parent_Account__c 
                                     FROM Address__c];
        System.assertEquals(6, listAddr.size());
        for (Address__c addr : listAddr) {
            if (addr.MailingStreet__c.contains('Direct Street Edit')) {
                System.assertEquals(False, addr.Default_Address__c); 
                for (Contact con : listCon) {
                    if (con.is_Address_Override__c && con.Current_Address__c == addr.Id) {
                        System.assertEquals(True, con.is_Address_Override__c); 
                    }
                }
            } else if (addr.MailingStreet__c.startsWith('Street')){
                System.assertEquals(True, addr.Default_Address__c);
            }
        }                
    }

    /*********************************************************************************************************
    @description Create new Contact records with no Address to an existing Household Account that have a default
	* Address record. 
	* Verify:
	* - The new Contact's mailing fields are udpated to match the mailing fields from the default Address record.
    **********************************************************************************************************/            
    @isTest
    private static void insertConWithNoAddrToExistingHH() {
        configSettings();

        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());

        List<Contact> listCon = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        for (Integer i = 0; i < 2; i++) {
            listCon[i].LastName = 'ToAvoidDupeRule' + i;
            listCon[i].AccountId = consAccsAddrs.accs[i].Id;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert listCon;         
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();
        
        //Verify that the Household Account and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        listCon = [SELECT Id, Name, AccountId, 
                   is_Address_Override__c, Current_Address__c, MailingStreet, 
                   MailingCity, Mailing_County__c, MailingState, 
                   MailingPostalCode, MailingCountry, MailingLatitude, 
                   MailingLongitude 
                   FROM Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.Mailing_County__c.contains('County')); 
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Create Contact records and populate its mailing fields with new Address values. 
	* Verify:
	* - New Contact is created.
	* - New default Address record is created. 
	* - Account's billing fields are updated with the mailing fields from the newly created default Address record. 
	* - Existing Contact's mailing fields are updated with the mailing fields from the newly created default Address record.
	* - Previous default Address record is no longer marked as default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void insertConWithAddrToExistingHH() {
        configSettings();
           
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
 
        List<Contact> listCon = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        for (Integer i = 0; i < 2; i++) {
            listCon[i].AccountId = consAccsAddrs.accs[i].Id;
            listCon[i].LastName = 'ToAvoidDupeRule' + i;
            listCon[i].MailingStreet = 'New Mailing Street' + i;
            listCon[i].MailingCity = 'New Mailing City' + i;
            listCon[i].Mailing_County__c = 'New Mailing County' + i;
            listCon[i].MailingState = 'California';
            listCon[i].MailingCountry = 'United States';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert listCon;
        Test.stopTest();
        
        //Verify that the Household Account and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        listCon = [SELECT Id, Name, AccountId, 
                   is_Address_Override__c, Current_Address__c, MailingStreet, 
                   MailingCity, Mailing_County__c, MailingState, 
                   MailingPostalCode, MailingCountry, MailingLatitude, 
                   MailingLongitude 
                   FROM Contact];
        List<Address__c> addrs = [SELECT Default_Address__c, MailingStreet__c, MailingCity__c, 
                                  MailingState__c, MailingCountry__c 
                                  FROM Address__c];
        System.assertEquals(4, addrs.size()); 
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
            System.assert(con.MailingStreet.contains('New Mailing Street'));
            System.assert(con.MailingCity.contains('New Mailing City'));
            System.assert(con.Mailing_County__c.contains('New Mailing County'));
        }
        for (Address__c addr : addrs) {
            if (addr.MailingStreet__c.contains('New Mailing Street')) {
                System.assertEquals(True, addr.Default_Address__c); 
            } else {
                System.assertEquals(False, addr.Default_Address__c); 
            }
        }
    }

    /*********************************************************************************************************
    @description Household Account has default Address record. Create new Contact records and match its mailing 
	* fields with the Account's billing fields. 
	* Verify: 
	* - No new Address record is created.
	* - New Contact's Current_Address__c is populated with the default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void insertConWithDefaultAddrToExistingHH() {
        configSettings();
              
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        // insert new contacts to the HH with the current default addresses
        List<Contact> listCon = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        for (Integer i = 0; i < 2; i++) {
            listCon[i].LastName = 'ToAvoidDupeRule' + i;
            listCon[i].AccountId = consAccsAddrs.accs[i].Id;
            listCon[i].MailingStreet = consAccsAddrs.accs[i].BillingStreet;
            listCon[i].MailingCity = consAccsAddrs.accs[i].BillingCity;
            listCon[i].Mailing_County__c = consAccsAddrs.accs[i].Billing_County__c;
            listCon[i].MailingState = consAccsAddrs.accs[i].BillingState;
            listCon[i].MailingPostalCode = consAccsAddrs.accs[i].BillingPostalCode;
            listCon[i].MailingCountry = consAccsAddrs.accs[i].BillingCountry;
            listCon[i].MailingLatitude = consAccsAddrs.accs[i].BillingLatitude;
            listCon[i].MailingLongitude = consAccsAddrs.accs[i].BillingLongitude;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert listCon;         
        Test.stopTest();
        
        //Verify that the Household Account and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        listCon = [SELECT Id, Name, AccountId, 
                   is_Address_Override__c, Current_Address__c, MailingStreet,
                   MailingCity, Mailing_County__c, MailingState, 
                   MailingPostalCode, MailingCountry, MailingLatitude, 
                   MailingLongitude 
                   FROM Contact];
        System.assertEquals(6, listCon.size());
        Integer numOfAddrs = [SELECT Count()
                               FROM Address__c]; 
        System.assertEquals(2, numOfAddrs);
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Create new Contact on an existing Household Account and populate its mailing street with multi-line
	* character.
	* Verify:
	* - New default Address record is created and MailingStreet__c and MailingStreet2__c are populated appropriately.
	* - Account's billing fields are updated with the mailing fields from the newly created default Address record.
	* - Existing Contact's mailing fields are updated with the mailing fields from the newly created default Address record.
    **********************************************************************************************************/            
    @isTest
    private static void insertContactWithMultilineStreetAddressHH() {
        configSettings();
   
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        List<Contact> contacts = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        for (Integer i = 0; i<contacts.size(); i++) {
            Contact con = contacts[i];
            con.LastName = 'ToAvoidDupeRule' + i;
            con.AccountId = consAccsAddrs.accs[i].Id;
            con.MailingStreet = 'new street\r\nsecond line';
            con.MailingCity = 'new city';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert contacts;
        Test.stopTest();
        
        //Verify the Address objects split street.
        List<Address__c> addresses = [SELECT Id, MailingStreet__c, MailingStreet2__c, 
                                      Formula_MailingStreetAddress__c 
                                      FROM Address__c];
        
        List<Address__c> listAddr = new List<Address__c>();
        for (Address__c addy : addresses) {
            if (addy.MailingStreet__c == 'new street') {
                listAddr.add(addy);
            }
        }
        System.assertEquals(2, listAddr.size());

        for (Address__c addr : listAddr) {
            System.assertEquals('new street', addr.MailingStreet__c);
            System.assertEquals('second line', addr.MailingStreet2__c);
            System.assertEquals('new street<br>second line<br>new city,', addr.Formula_MailingStreetAddress__c);
        }

        //Verify that the Household Account and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        List<Contact> listCon = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c, MailingState, 
                                 MailingPostalCode, MailingCountry, MailingLatitude, 
                                 MailingLongitude 
                                 FROM Contact];
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals('new street\r\nsecond line', con.MailingStreet);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Create new multi-street default Address record for an existing Household Account.
	* Verify: 
	* - New default Address is created. 
	* - Contact's and Account's mailing/billing fields are updated, specifically multi-street fields from default Address
	* record are populated in MailingStreet and BillingStreet.
    **********************************************************************************************************/            
    @isTest
    private static void insertNewDefaultMultilineStreetAddrHH() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
		System.assertEquals(2, consAccsAddrs.addrs.size()); 
        
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = True;
            addrs[i].MailingStreet__c = 'New Default Street';
            addrs[i].MailingStreet2__c = 'Second Line';
            addrs[i].MailingCity__c = 'New Default City' + i;
            addrs[i].MailingCounty__c = 'New Default County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert addrs;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();        
        Test.stopTest();
		
        Integer numOfAddrs = [SELECT Count() FROM Address__c];
        System.assertEquals(4, numOfAddrs); 
        
        //Verify that the Household Account and Contacts share the same address 
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                             BillingCity, Billing_County__c, BillingState, 
                                                             BillingPostalCode, BillingCountry, BillingLatitude, 
                                                             BillingLongitude 
                                                             FROM Account]);
        List<Contact> listCon = [SELECT Id, Name, AccountId, 
                                 is_Address_Override__c, Current_Address__c, MailingStreet, 
                                 MailingCity, Mailing_County__c, MailingState, 
                                 MailingPostalCode, MailingCountry, MailingLatitude, 
                                 MailingLongitude 
                                 FROM Contact];
        System.assertEquals(4, listCon.size());
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assertEquals('New Default Street\r\nSecond Line', con.MailingStreet);
            System.assertEquals('New Default Street\r\nSecond Line', acc.BillingStreet);
        }
    }
    
    /*********************************************************************************************************
    @description Update accounts' billing address with multiline street address.  
    verify:
        new Default Address created
        HH and Contacts get new Address
        new Addresss has multiline street split into Street and Street2 fields
    **********************************************************************************************************/            
    @isTest
    public static void updateAccMultilineStreetAddrHH() {
        configSettings();
          
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());

        // modify some of the account addresses directly
        for (Integer i = 0; i < 2; i++) {
            Account acc = consAccsAddrs.accs[i];
            acc.BillingStreet = 'Direct Street Edit\r\nSecond Line';
            acc.BillingCity = 'Direct City Edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update consAccsAddrs.accs;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, Billing_County__c, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, Mailing_County__c, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assertEquals('Direct Street Edit\r\nSecond Line', acc.BillingStreet);
            System.assertEquals('Direct Street Edit\r\nSecond Line', con.MailingStreet);
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
 
        // verify the Address objects split street.
        List<Address__c> listAddr = [select Id, MailingStreet__c, MailingStreet2__c, Formula_MailingStreetAddress__c, Default_Address__c from Address__c];
        for (Address__c addr : listAddr) {
            if (addr.Default_Address__c) {
                System.assertEquals('Direct Street Edit', addr.MailingStreet__c);
                System.assertEquals('Second Line', addr.MailingStreet2__c);
                System.assert(addr.Formula_MailingStreetAddress__c.contains('Direct Street Edit<br>Second Line<br>Direct City Edit'));
            }
        }

    }

    /*********************************************************************************************************
    @description Create N contacts with Household Accounts when the setting for Household Address Mgmt is off. 
    verify:
        no Address objects created
        HH Account addresses set
        Contact addresses set
    **********************************************************************************************************/            
    @isTest
    public static void testDisabledHHAccountAddr() {        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(), 
                                       Household_Addresses_RecType__c = null));

        List<Contact> contacts = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        for (Contact con : contacts) {
            con.MailingStreet = 'new street';
            con.MailingCity = 'new city';
        }
        insert contacts;        

        // verify that the HH and Contacts don't share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, Billing_County__c, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, Mailing_County__c, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(false, isMatchAddressAccCon(acc, con));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertEquals(null, con.Current_Address__c);
        }
        
        // verify no address objects created
        List<Address__c> listAddr = [select Id from Address__c];
        System.assertEquals(0, listAddr.size());
    }
    
    @isTest
    public static void testSeasonalStartEndYearCurrent() {
        configSettings();
              
        //Create Contact with Address info
        Contact contact = new Contact(LastName = 'Testerson', MailingStreet = '123 Default', MailingCity = 'Austin', Mailing_County__c = 'Bergen', MailingState = 'Texas', MailingCountry = 'United States');
        insert contact;
        
        //Parent Admin Account should have been created
        contact = [select AccountID, MailingStreet, MailingCity, Mailing_County__c, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude 
                   from Contact where ID = :contact.ID];       
        System.assertNotEquals(null, contact.AccountID);
                
        //Address flagged as default should have been created
        Address__c defaultAddress = [select ID, Default_Address__c, MailingCounty__c from Address__c where Parent_Account__c = : contact.AccountID];
        System.assertEquals(true, defaultAddress.Default_Address__c);
        
        Account acc = [select Id, Name, BillingStreet, BillingCity, Billing_County__c, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude 
                       from Account where ID = :contact.AccountID];
        
        //Verify account and contact share same address
        System.assertEquals(true, isMatchAddressAccCon(acc, contact));
        System.assertEquals('123 Default', contact.MailingStreet);
        System.assertEquals('Austin', acc.BillingCity);
        
        //Create seasonal Address with start and end year that include the current date
        Address__c seasonalAddress = new Address__c(Parent_Account__c = contact.AccountID, MailingStreet__c = '123 Seasonal', MailingCity__c = 'Seattle', 
            										MailingCounty__c = 'Bergen', 
                                                    MailingState__c = 'Washington', MailingCountry__c = 'United States', Seasonal_Start_Day__c = String.valueOf(System.today().addDays(-1).day()), 
            Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(-1).month()), Seasonal_Start_Year__c = System.today().addYears(-1).year(), 
            Seasonal_End_Day__c = String.valueOf(System.today().addDays(1).day()), Seasonal_End_Month__c = String.valueOf(System.today().addMonths(1).month()), 
            Seasonal_End_Year__c = System.today().addYears(1).year());
        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert seasonalAddress;
        Test.stopTest();
        
        //Seasonal Address should have been copied to the Contact and the Account
        contact = [select AccountID, MailingStreet, MailingCity, Mailing_County__c, MailingState from Contact where ID = :contact.ID];
        System.assertEquals('123 Seasonal', contact.MailingStreet);
        System.assertEquals('Seattle', contact.MailingCity);
        System.assertEquals('Bergen', contact.Mailing_County__c);
        System.assertEquals('Washington', contact.MailingState);
        
        acc = [select BillingStreet, BillingCity, Billing_County__c, BillingState from Account where ID = :contact.AccountID];
        System.assertEquals('123 Seasonal', acc.BillingStreet);
        System.assertEquals('Seattle', acc.BillingCity);
        System.assertEquals('Bergen', acc.Billing_County__c);
        System.assertEquals('Washington', acc.BillingState);
    }
    
    /*********************************************************************************************************
    @description Update contacts' mailing address fields to empty cause clearing the default address.  
    verify:
        no new Address created
        existing Default Address updated to be non-default
        HH and Contacts get updated to empty address fields
    **********************************************************************************************************/            
    static testMethod void clearConAddrExisting() {
        configSettings();
                
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        UTIL_Debug.debug('****Test data created for test: ' + JSON.serializePretty(consAccsAddrs));
        
        // clear some of the contact addresses directly - one in each household
        for (integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.MailingStreet = null;
            con.MailingCity = null;
            con.Mailing_County__c = null;
            con.MailingPostalCode = null;
            con.MailingState = null;
            con.MailingCountry = null;
            con.MailingLatitude = null;
            con.MailingLongitude = null;
            if (ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled) {
                con.put('MailingStateCode', null);
                con.put('MailingCountryCode', null);
            }                
        }

        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update consAccsAddrs.contacts;
        Test.stopTest();
        
        // verify that the HH and Contacts have empty addresses
        List<Account> listAcc = [select Id, Name, BillingStreet, BillingCity, Billing_County__c, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account];
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, Mailing_County__c, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        UTIL_Debug.debug('****listAcc after test: ' + JSON.serializePretty(listAcc));
        UTIL_Debug.debug('****listCon after test: ' + JSON.serializePretty(listCon));
        
        for (Contact con : listCon) {
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertEquals(null, con.Current_Address__c);
            System.assertEquals(null, con.MailingStreet);
            System.assertEquals(null, con.MailingCity);
            System.assertEquals(null, con.MailingPostalCode);
            System.assertEquals(null, con.MailingState);
            System.assertEquals(null, con.MailingCountry);
        }
 
        for (Account acc : listAcc) {
            System.assertEquals(null, acc.BillingStreet);
            System.assertEquals(null, acc.BillingCity);
            System.assertEquals(null, acc.BillingPostalCode);
            System.assertEquals(null, acc.BillingState);
            System.assertEquals(null, acc.BillingCountry);
        }
        
        // verify that no new address was created
        List<Address__c> listAddr = [select Default_Address__c from Address__c];
        System.assertEquals(2, listAddr.size());
        for (Address__c addr : listAddr) {
            System.assertEquals(false, addr.Default_Address__c);
        }                
    }

    /*********************************************************************************************************
    @description Set contact address override and address lookup on a new household contact.  
    verify contact's address fields correctly set
    **********************************************************************************************************/            
    static testMethod void setConAddrOverrideAndLookupOnNewContact() {
        configSettings();
           
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        Contact con = new Contact();
        con.lastname = 'test';
        con.AccountId = consAccsAddrs.accs[0].Id;
        con.is_Address_Override__c = true;
        con.Current_Address__c = consAccsAddrs.addrs[0].Id;
        
        Test.startTest();
        insert con;
        Test.stopTest();
        
        con = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, Mailing_County__c,
            MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact where Id = :con.Id];
        System.assertEquals(true, con.is_Address_Override__c);
        System.assertEquals(consAccsAddrs.addrs[0].Id, con.Current_Address__c);
        System.assertEquals(consAccsAddrs.addrs[0].MailingStreet__c, con.MailingStreet);
        System.assertEquals(consAccsAddrs.addrs[0].MailingCity__c, con.MailingCity);
        System.assertEquals(consAccsAddrs.addrs[0].MailingPostalCode__c, con.MailingPostalCode);
        System.assertEquals(consAccsAddrs.addrs[0].MailingState__c, con.MailingState);
        System.assertEquals(consAccsAddrs.addrs[0].MailingCountry__c, con.MailingCountry);
    }

    /*********************************************************************************************************
    @description
        update an org contact to be a household contact 
    verify:
        HH address created
        account address matches address object address
        contact address matches address object address
    **********************************************************************************************************/            
    static testMethod void updateOrgContactToHH() {
        configSettings();
        
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        
        Account orgAcc = new Account(Name='Org Account', RecordTypeID = UTIL_Describe_API.getBizAccRecTypeID());
        insert orgAcc;
        
        Contact con = new Contact(Lastname='Testy', AccountId = orgAcc.Id);
        insert con;
        
        // now give the contact an address and change it to get a hh account
        con.AccountId = null;
        con.MailingStreet = '123 abc';
        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update con;
        Test.stopTest();

        // verify results
        String hhAccRecTypeID = UTIL_Describe_API.getHhAccRecTypeID();
        //Account acc = [select Id, Name, BillingStreet from Account where Name like '%Household%'];
        Account acc = [select Id, Name, BillingStreet from Account where RecordTypeId = :hhAccRecTypeID];
        UTIL_Debug.debug('****Parent account: ' + JSON.serializePretty(acc));
        System.assertNotEquals(null, acc);
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c from Address__c];
        System.assertEquals(1, listAddr.size());
        con = [select Id, Lastname, MailingStreet, Current_Address__c from Contact];
        System.assertEquals('Testy', con.Lastname);
        System.assertEquals('123 abc', con.MailingStreet);
        System.assertEquals(listAddr[0].Id, con.Current_Address__c);
        System.assertEquals(listAddr[0].MailingStreet__c, con.MailingStreet);
        System.assertEquals(listAddr[0].MailingStreet__c, acc.BillingStreet);
    }

    /*********************************************************************************************************
    @description Insert admin account with blank address data but only primary address type
    verify:
        No blank address record is created
    **********************************************************************************************************/
    static testMethod void insertHHAccountWithOnlyPrimaryAddressType() {
        configSettings();
        ADDR_Contact_TEST.turnOffAllAddrTriggers();

        List<Account> accs = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, householdRecTypeID);
        insert accs;

        List<Contact> contacts = UTIL_UnitTestData_API.getMultipleTestContacts(2);

        contacts[0].MailingStreet = 'new street';
        contacts[0].Primary_Address_Type__c = 'Home';
        contacts[0].AccountId = accs[0].Id;
        contacts[1].AccountId = accs[0].Id;
        contacts[1].Primary_Address_Type__c = 'Home';

        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert contacts;
        Test.stopTest();

        List<Address__c> assertAddresses = [SELECT Id, Parent_Account__c FROM Address__c];
        System.assertEquals(1, assertAddresses.size());
        System.assertEquals(accs[0].Id, assertAddresses[0].Parent_Account__c);
    }
}