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
    
    /* @description Household Account Record Type ID. */
    private static ID householdRecTypeID = UTIL_Describe.getHhAccRecTypeID();
    
    private static void configSettings() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(
            Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
            Household_Addresses_RecType__c = UTIL_Describe.getHhAccRecTypeID(),
            Contacts_Addresses_Enabled__c = true,
            Simple_Address_Change_Treated_as_Update__c = true));
    }
    
    /*********************************************************************************************************
    * @description Returns whether an Account Billing address matches a Contact Mailing address
    * @return  boolean 
    **********************************************************************************************************/
    private static boolean isMatchAddressAccCon(Account acc, Contact con) {
        UTIL_Debug.debug('****Account to Compare: ' + JSON.serializePretty(acc));
        UTIL_Debug.debug('****Contact to Compare: ' + JSON.serializePretty(con));
        return (acc.BillingStreet == con.MailingStreet && acc.BillingCity == con.MailingCity &&          
            acc.BillingState == con.MailingState && acc.BillingPostalCode == con.MailingPostalCode &&          
            acc.BillingCountry == con.MailingCountry && acc.BillingLatitude == con.MailingLatitude &&
            acc.BillingLongitude == con.MailingLongitude);                
    }
        
    /*********************************************************************************************************
    @description create N new default Addresses for N Households (with M Contacts)  
    verify:
        N addresses created
        N household billing address fields updated
        M contact Mailing address fields updated
    **********************************************************************************************************/            
    @isTest
    public static void newDefaultAddrHH() {
        configSettings();
        
        Test.startTest();
        //This is really just testing that the helper method is properly written
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        UTIL_Debug.debug('****newDefaultAddrHH Accounts: ' + JSON.serializePretty(mapAccIdAcc.values()));  
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        UTIL_Debug.debug('****newDefaultAddrHH listCon: ' + JSON.serializePretty(listCon)); 
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
    }
    
    @isTest
    public static void insertContactWithAddress() {
        configSettings();
        
        Contact con = new Contact(Lastname='Testy', MailingStreet = '123 Main St', MailingCity = 'Chicago');
        Test.startTest();
        insert con;
        Test.stopTest();
        
        List<Account> accs = [select ID, BillingStreet, BillingCity from Account];
        System.assertEquals(1, accs.size());
        System.assertEquals('123 Main St', accs[0].BillingStreet);
        System.assertEquals('Chicago', accs[0].BillingCity);
        
        List<Address__c> addrs = [select ID, Parent_Account__c, Parent_Contact__c, Default_Address__c, MailingStreet__c, MailingCity__c from Address__c];
        System.assertEquals(1, addrs.size());
        System.assertEquals(accs[0].ID, addrs[0].Parent_Account__c);
        System.assertEquals(null, addrs[0].Parent_Contact__c);
        System.assertEquals('123 Main St', addrs[0].MailingStreet__c);
        System.assertEquals('Chicago', addrs[0].MailingCity__c);
        System.assertEquals(true, addrs[0].Default_Address__c);
    }

    /*********************************************************************************************************
    @description Insert contact w/ address.
    verify:
        new default Address created
        contact address lookup updated to new address
        the contact gets the new Address
    **********************************************************************************************************/            
    @isTest
    public static void insertContactWithAddressToHH() {
        configSettings();
          
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        //Insert one contact in each household
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = New Contact();
            con.AccountId = consAccsAddrs.accs[i].Id;
            con.LastName = 'Testerson';
            con.MailingStreet = 'new street';
            con.MailingCity = 'new city';
            contacts.add(con);
        }
        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert contacts;
        Test.stopTest();      
        
        // verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
    }
        
    /*********************************************************************************************************
    @description Insert contact w/ new address override.
    verify:
        new non-default Address created
        contact address lookup updated to new address
        the contact gets the new Address
    **********************************************************************************************************/            
    @isTest
    public static void insertContactWithAddressOverrideHH() {
        configSettings();
                           
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        List<Contact> contacts = new List<Contact>();
        //Insert one Contact per household with address info and override
        for (Integer i = 0; i<2; i++) {
            Contact con = new Contact();
            con.LastName = 'Testerson';
            con.AccountId = consAccsAddrs.accs[i].Id;
            con.MailingStreet = 'new street' + i;
            con.MailingCity = 'new city' + i;
            con.is_Address_Override__c = true;
            contacts.add(con);
        }
        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert contacts;
        Test.stopTest();    

        // verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        List<Address__c> addrs = [select Default_Address__c, MailingStreet__c, MailingCity__c from Address__c];
        UTIL_Debug.debug('****Accouns after query: ' + JSON.serializePretty(mapAccIdAcc.values()));
        UTIL_Debug.debug('****Contacts after query: ' + JSON.serializePretty(listCon));
        UTIL_Debug.debug('****Addresses after query: ' + JSON.serializePretty(addrs));
        System.assertEquals(4, addrs.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertNotEquals(null, con.Current_Address__c);
            if(con.is_Address_Override__c) {
                System.assertEquals(false, isMatchAddressAccCon(acc, con));
            } else {
                System.assertEquals(true, isMatchAddressAccCon(acc, con));               
            }
        }
    }
        
    /*********************************************************************************************************
    @description Update existing default Addresses.  
    verify:
        household billing address fields updated
        contact Mailing address fields updated
    **********************************************************************************************************/            
    @isTest 
    public static void updateDefaultAddrHH() {
        configSettings();
        
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        // now let's update the Addresses
        for (Integer i = 0; i < 2; i++) {
            Address__c addr = consAccsAddrs.addrs[i];
            addr.MailingStreet__c = 'New Street' + i;
            addr.MailingCity__c = 'New City' + i;
        }
        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update consAccsAddrs.addrs;
        Test.stopTest();
    
        // verify that the HH and Contacts share the same address and it's new!
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        System.assertEquals(2 * 2, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Street'));
            System.assert(con.MailingCity.contains('New City'));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
    }
    
    /*********************************************************************************************************
    @description
        delete existing default Addresses  
    verify:
        household billing address fields cleared
        contact Mailing address fields cleared
    **********************************************************************************************************/            
    @isTest
    static void deleteDefaultAddrHH() {
        configSettings();
             
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        // now let's delete the Addresses
        Test.startTest();
        delete consAccsAddrs.addrs;
        Test.stopTest();
    
        // verify that the HH and Contacts' address fields are cleared
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        System.assertEquals(2 * 2, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assertEquals(null, con.MailingStreet);
            System.assertEquals(null, con.MailingCity);
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertEquals(null, con.Current_Address__c);
            System.assertEquals(null, acc.BillingStreet);
            System.assertEquals(null, acc.BillingCity);
        }
    }

    /*********************************************************************************************************
    @description Delete existing non-default override Addresses.  
    verify:
        household billing address fields not changed
        contact Mailing address fields reset to default
    **********************************************************************************************************/            
    @isTest
    static void deleteNonDefaultOverrideAddrHH() {
        configSettings();
           
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        // create additional addresses
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = false;
            addrs[i].MailingStreet__c = 'override' + i;
            addrs[i].MailingCity__c = 'override' + i;
        }
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        insert addrs;
        
        // set the contacts' address overrides - one Contact per household
        List<Contact> listCon = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.Current_Address__c = addrs[i].Id;
            con.is_Address_Override__c = true;
            ADDR_Addresses_UTIL.copyAddressAddrSObj(addrs[i], con, 'Mailing', 'Primary_Address_Type__c', null);
            listCon.add(con);
        }
        update listCon;        
        
        // now let's delete the override Addresses
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        delete addrs;
        Test.stopTest();
    
        // verify that the HH and Contacts' address fields the default
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        UTIL_Debug.debug('****Accounts deleteNonDefaultOverrideAddrHH: ' + JSON.serializePretty(mapAccIdAcc.values()));
        UTIL_Debug.debug('****Contacts deleteNonDefaultOverrideAddrHH: ' + JSON.serializePretty(listCon));
        System.assertEquals(2 * 2, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
            System.assert(con.MailingStreet.contains('Street'));
            System.assert(con.MailingCity.contains('City'));            
        }
    }

    /*********************************************************************************************************
    @description Making an Address non-default. That is, the address is no longer the default one for the Account/Contact.  
    verify: no change to HH and contact addresses
    **********************************************************************************************************/            
    @isTest
    public static void updateNonDefaultAddrHH() {
        configSettings();
        
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        // now let's update the Addresses
        for (Integer i = 0; i < 2; i++) {
            Address__c addr = consAccsAddrs.addrs[i];
            addr.Default_Address__c = false;
        }
        Test.startTest();
        update consAccsAddrs.addrs;
        Test.stopTest();
    
        // verify that the HH and Contacts share the same address and it's new!
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        System.assertEquals(2 * 2, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assertEquals(null, con.MailingStreet); //address information has been cleared because address is no longer the default
            System.assertEquals(null, con.MailingCity); //address information has been cleared because address is no longer the default
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertEquals(null, con.Current_Address__c); //contact no longer has a current address, since address is no longer the default
        }
    }

    /*********************************************************************************************************
    @description Set contact address override.  
    verify: Contact's address matches override.
    **********************************************************************************************************/            
    @isTest
    public static void setConAddrOverrideHH() {
        configSettings();
               
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        // create a new non-default address
        Address__c addrNew = new Address__c();
        addrNew.MailingStreet__c = 'street override';
        addrNew.MailingCity__c = 'city override';
        addrNew.Default_Address__c = false;
        addrNew.Parent_Account__c = consAccsAddrs.accs[0].Id;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert addrNew;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        
        // set a contact's address override
        consAccsAddrs.contacts[0].Current_Address__c = addrNew.Id;
        consAccsAddrs.contacts[0].is_Address_Override__c = true;
        update consAccsAddrs.contacts[0];
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
    
        // now let's update the default Addresses
        for (Integer i = 0; i < 2; i++) {
            Address__c addr = consAccsAddrs.addrs[i];
            addr.MailingStreet__c = 'New Street' + i;
            addr.MailingCity__c = 'New City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update consAccsAddrs.addrs;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        System.assertEquals(2 * 2, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            if (con.is_Address_Override__c) {
                System.assertEquals(con.Current_Address__c, addrNew.Id);
                System.assertEquals(false, isMatchAddressAccCon(acc, con));
                System.assert(!con.MailingStreet.contains('New Street'));
                System.assert(!con.MailingCity.contains('New City'));               
            } else {
                System.assertEquals(true, isMatchAddressAccCon(acc, con));
                System.assert(con.MailingStreet.contains('New Street'));
                System.assert(con.MailingCity.contains('New City'));
                System.assertEquals(false, con.is_Address_Override__c);
                System.assertNotEquals(null, con.Current_Address__c);
            }
        }
    }

    /*********************************************************************************************************
    @description Set contact current address, but not override.  
    verify: Contact's address updated, but not override.
    **********************************************************************************************************/            
    @isTest
    public static void setConAddrNoOverrideHH() {
        configSettings();
             
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        // create additional addresses
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = false;
            addrs[i].MailingStreet__c = 'not override' + i;
            addrs[i].MailingCity__c = 'not override' + i;
        }
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        insert addrs;
        
        // set the contacts' address overrides
        List<Contact> listCon = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.Current_Address__c = addrs[i].Id;
            con.is_Address_Override__c = false;
            listCon.add(con);
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update listCon;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address, except for the contacts we modified
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, Current_Address__r.Default_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        Integer cNotOverride = 0;
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            if (con.MailingStreet.contains('not override') == true) {
                cNotOverride++;
                System.assertEquals(false, isMatchAddressAccCon(acc, con));
                System.assert(con.MailingStreet.contains('not override'));
                System.assert(con.MailingCity.contains('not override'));
                System.assertEquals(false, con.is_Address_Override__c);
                System.assertNotEquals(null, con.Current_Address__c);            
            } else {
                System.assertEquals(true, con.Current_Address__r.Default_Address__c);
                System.assertEquals(true, isMatchAddressAccCon(acc, con));
                System.assert(con.MailingStreet.contains('Street'));
                System.assert(con.MailingCity.contains('City'));
                System.assertEquals(false, con.is_Address_Override__c);
                System.assertNotEquals(null, con.Current_Address__c);
            }
        }
        System.assertEquals(2, cNotOverride);
    }

    /*********************************************************************************************************
    @description Insert new default addresses to HH w/ existing default addresses.  
    verify:
        contact's && hh address matches new default
        old default addresses no longer marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewDefaultAddrHH() {
        configSettings();
        
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        List<Address__c> listAddr = [select Id from Address__c];
        UTIL_Debug.debug('****listAddr count 1: ' + listAddr.size());
        
        // create additional addresses
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = true;
            addrs[i].MailingStreet__c = 'New Default Street' + i;
            addrs[i].MailingCity__c = 'New Default City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert addrs;
        Test.stopTest();

        // verify that the HH and Contacts share the same address and it's new!
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        System.assertEquals(2 * 2, listCon.size());
        listAddr = [select Id from Address__c];
        UTIL_Debug.debug('****listAddr count 2: ' + listAddr.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Default Street'));
            System.assert(con.MailingCity.contains('New Default City'));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the previous addresses got Default cleared.
        // and verify latest start date and latest end date appropriately set.
        listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        UTIL_Debug.debug('****listAddr in insertNewDefaultAddrHH: ' + JSON.serializePretty(listAddr));
        System.assertEquals(2 * 2, listAddr.size());
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
    
    /*********************************************************************************************************
    @description Insert new default addresses to HH w/ existing default addresses, and then go back.  
    verify:
        contact's && hh address matches original default
        new default addresses no longer marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewDefaultAddrAndResetHH() {
        configSettings();
        
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        List<Address__c> listAddrOriginal = consAccsAddrs.addrs;
        
        ADDR_Addresses_TDTM.addressIdsInserted = new Set<Id>();
        // create additional addresses
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = true;
            addrs[i].MailingStreet__c = 'New Default Street' + i;
            addrs[i].MailingCity__c = 'New Default City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert addrs;
 
         ADDR_Addresses_TDTM.addressIdsUpdated = new Set<Id>();       
        // go back to original default addresses
        // added this extra set to test fix where we didn't use the correct default
        for (Integer i = 0; i < 2; i++) {
            listAddrOriginal[i].Default_Address__c = true;
            listAddrOriginal[i].MailingStreet__c = 'Original Default Street' + i;
            listAddrOriginal[i].MailingCity__c = 'Original Default City' + i;
        }
        Test.startTest();
        update listAddrOriginal;
        Test.stopTest();

        // verify that the HH and Contacts share the same address and it's new!
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        System.assertEquals(2 * 2, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('Original Default Street'));
            System.assert(con.MailingCity.contains('Original Default City'));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the previous addresses got Default cleared.
        // and verify latest start date and latest end date appropriately set.
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        System.assertEquals(2 * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fNewDefault = (addr.MailingStreet__c.contains('Original Default Street'));
            System.assertEquals(fNewDefault, addr.Default_Address__c);
            if (fNewDefault) {
               System.assertEquals(System.today(), addr.Latest_Start_Date__c);
               System.assertEquals(null, addr.Latest_End_Date__c);
            } else {
               System.assertEquals(System.today(), addr.Latest_End_Date__c);                
            }
        }        
    }

    /*********************************************************************************************************
    @description Update contacts' Address Override.  
    verify: Contacts' Mailing address fields updated to the Address Override's fields.
    **********************************************************************************************************/            
    @isTest
    public static void updateAddrOverrideHH() {
        configSettings();
        
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        // create additional addresses
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = false;
            addrs[i].MailingStreet__c = 'override' + i;
            addrs[i].MailingCity__c = 'override' + i;
        }
        //ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert addrs;
        
        // set the contacts' address overrides
        List<Contact> listCon = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.Current_Address__c = addrs[i].Id;
            con.is_Address_Override__c = true;
            listCon.add(con);
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update listCon;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            if (con.is_Address_Override__c) {
                System.assertNotEquals(null, con.Current_Address__c);
                System.assertEquals(false, isMatchAddressAccCon(acc, con));
                System.assert(con.MailingStreet.contains('override'));
                System.assert(con.MailingCity.contains('override'));               
            } else {
                System.assertEquals(true, isMatchAddressAccCon(acc, con));
                System.assert(con.MailingStreet.contains('Street'));
                System.assert(con.MailingCity.contains('City'));
                System.assertEquals(false, con.is_Address_Override__c);
                System.assertNotEquals(null, con.Current_Address__c);
            }
        }

        // verify address overrides have latest start date and latest end date appropriately set.
        List<Address__c> listAddr = [select Id, Latest_Start_Date__c, Latest_End_Date__c from Address__c where Id in :addrs];
        System.assertEquals(2, listAddr.size());
        for (Address__c addr : listAddr) {
           System.assertEquals(System.today(), addr.Latest_Start_Date__c);
           System.assertEquals(null, addr.Latest_End_Date__c);
        }        
    }
        
    /*********************************************************************************************************
    @description Clear contacts' Address Override.  
    verify: Contacts' Mailing address fields updated to the HH default address.
    **********************************************************************************************************/            
    @isTest
    public static void clearAddrOverrideHH() {
        configSettings();

        // this creates two child Contacts and a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        UTIL_Debug.debug('****clearAddrOverrideHH consAccsAddrs: ' + JSON.serializePretty(consAccsAddrs));
        
        // create additional addresses - one for each account
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = false;
            addrs[i].MailingStreet__c = 'override' + i;
            addrs[i].MailingCity__c = 'override' + i;
            addrs[i].Latest_Start_Date__c = System.today();
        }
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        insert addrs;
        
        // set the contacts' address overrides - one contact in each account
        List<Contact> listCon = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.Current_Address__c = addrs[i].Id;
            con.is_Address_Override__c = true;
            ADDR_Addresses_UTIL.copyAddressAddrSObj(addrs[i], con, 'Mailing', 'Primary_Address_Type__c', null);
            listCon.add(con);
        }
        //ADDR_Contact_TEST.turnOnAllAddrTriggers();
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        update listCon;

        List<Contact> allCons = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        UTIL_Debug.debug('****Contacts after first update: ' + JSON.serializePretty(allCons));

        // now clear out the contacts' address overrides
        for (Contact con : listCon) {
            con.is_Address_Override__c = false;
        }

        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        UTIL_Debug.debug('****Second explicit contacts update in clearAddrOverrideHH');
        Test.startTest();
        update listCon;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        allCons = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        UTIL_Debug.debug('****Contacts after second update: ' + JSON.serializePretty(allCons));
        
        for (Contact con : allCons) {
            UTIL_Debug.debug('****Contact after clearing override: ' + JSON.serializePretty(con));
            Account acc = mapAccIdAcc.get(con.AccountId);
            UTIL_Debug.debug('****Parent Account after clearing override: ' + JSON.serializePretty(acc));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('Street'));
            System.assert(con.MailingCity.contains('City'));
        }

        // verify address overrides have latest start date and latest end date appropriately set.
        List<Address__c> listAddr = [select Id, Latest_Start_Date__c, Latest_End_Date__c from Address__c where Id in :addrs];
        System.assertEquals(2, listAddr.size());
        UTIL_Debug.debug('****Additional addresses after update: ' + JSON.serializePretty(listAddr));
        for (Address__c addr : listAddr) {
           System.assertEquals(System.today(), addr.Latest_Start_Date__c);
           System.assertEquals(System.today(), addr.Latest_End_Date__c);
        }     
    }

    /*********************************************************************************************************
    @description Update contacts' mailing address to cause creation of new default Address object.  
    verify:
        new Default Address created
        HH and Contacts get new Address
    **********************************************************************************************************/            
    @isTest
    public static void updateConAddrNewHH() {
        configSettings();
             
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        // modify some of the contact addresses directly
        for (Integer i = 0; i < 2; i++) {
            consAccsAddrs.contacts[i*2 + i].MailingStreet = 'final Street Edit';
            consAccsAddrs.contacts[i*2 + i].MailingCity = 'final City Edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update consAccsAddrs.contacts;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('final Street Edit'));
            System.assert(con.MailingCity.contains('final City Edit'));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
 
         // verify the previous addresses got Default cleared.
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        // each set of edits created a new address object 
        System.assertEquals(4, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fNewDefault = (addr.MailingStreet__c.contains('final Street Edit'));
            System.assertEquals(fNewDefault, addr.Default_Address__c);
        }                
    }

    /*********************************************************************************************************
    @description Update contacts' mailing address and mark it as override, to cause creation of new non-default Address object.  
    verify:
        new Address created
        HH sticks with default Address
        contact gets new address
    **********************************************************************************************************/            
    @isTest
    public static void updateConAddrMarkOverrideHH() {
        configSettings();
        
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        // modify the contact addresses directly, and set override
        for (Integer i = 0; i < 4; i++) {
            consAccsAddrs.contacts[i].MailingStreet = 'Direct Street Edit';
            consAccsAddrs.contacts[i].MailingCity = 'Direct City Edit';
            consAccsAddrs.contacts[i].is_Address_Override__c = true;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update consAccsAddrs.contacts;
        Test.stopTest();
        
        // verify that the HH and Contacts do not share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        UTIL_Debug.debug('****updateConAddrMarkOverrideHH accounts: ' + JSON.serializePretty(mapAccIdAcc.values()));
        UTIL_Debug.debug('****updateConAddrMarkOverrideHH contacts: ' + JSON.serializePretty(listCon));
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(false, isMatchAddressAccCon(acc, con));
            System.assertEquals(true, con.MailingStreet.contains('Direct Street Edit'));
            System.assertEquals(true, con.MailingCity.contains('Direct City Edit'));
            System.assertEquals(false, acc.BillingStreet.contains('Direct Street Edit'));
            System.assertEquals(false, acc.BillingCity.contains('Direct City Edit'));
            System.assertEquals(true, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
 
         // verify the previous addresses got Default cleared.
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        System.assertEquals(6, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean isNewEdit = (addr.MailingStreet__c.contains('Direct Street Edit'));
            System.assertNotEquals(isNewEdit, addr.Default_Address__c);
        }                
    }

    /*********************************************************************************************************
    @description Update contacts' mailing address to cause an update to default Address object.  
    verify:
        existing Default Address updated
        HH and Contacts get updated Address
    **********************************************************************************************************/            
    @isTest
    public static void updateConAddrExistingHH() {
        configSettings();
          
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
       
        // modify some of the contact addresses directly
        // NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
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
            con.MailingState = 'Washington';
        }
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        update listCon;

        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.MailingStreet = ' direct street  edit ';  // whitespace and casing should not count as a real edit.
            con.MailingState = 'Oregon';
        }
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        Test.startTest();
        update listCon;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('direct street  edit'));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
 
        // verify that no new address was created
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        System.assertEquals(2, listAddr.size());
        for (Address__c addr : listAddr) {
            System.assertEquals('direct street  edit', addr.MailingStreet__c);
        }                
    }

    /*********************************************************************************************************
    @description Update contacts' mailing address with just a case change, to cause an update to default Address object.  
    verify:
        existing Default Address updated
        HH and Contacts get updated Address
    **********************************************************************************************************/            
    @isTest
    public static void updateConAddrExistingCaseOnlyHH() {
        configSettings();
         
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        // modify some of the contact addresses directly
        // NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
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

        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.MailingStreet = ' direct street  edit ';  // whitespace and casing should not count as a real edit.
            con.MailingState = 'Oregon';
        }
        update listCon;

        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.MailingStreet = ' DIRECT STREET  EDIT ';  // only change casing.
        }
        Test.startTest();
        update listCon;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.equals('DIRECT STREET  EDIT'));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
 
        // verify that no new address was created
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        System.assertEquals(2, listAddr.size());
        for (Address__c addr : listAddr) {
            System.assert(addr.MailingStreet__c.equals('DIRECT STREET  EDIT'));
        }
        
        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();
        // now test that changing the case from the account updates all addresses
        for (Integer i = 0; i < 2; i++) {
            Account acc = consAccsAddrs.accs[i];
            acc.BillingStreet = 'direct street  edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        update consAccsAddrs.accs;
        
        // verify that the HH and Contacts share the same address
        mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.equals('direct street  edit'));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
 
        // verify that no new address was created
        listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        System.assertEquals(2, listAddr.size());
        for (Address__c addr : listAddr) {
            System.assert(addr.MailingStreet__c.equals('direct street  edit'));
        }                   
    }

    /*********************************************************************************************************
    @description Update accounts' billing address to cause creation of new default Address object.  
    verify:
        new Default Address created
        HH and Contacts get new Address
    **********************************************************************************************************/            
    @isTest
    public static void updateAccAddrNewHH() {
        configSettings();
          
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();
        // modify some of the account addresses directly
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
            acc.BillingStreet = 'final Street Edit';
            acc.BillingCity = 'final City Edit';
        }
        Test.startTest();
        update consAccsAddrs.accs;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assert(acc.BillingStreet.contains('final Street Edit'));
            System.assert(con.MailingStreet.contains('final Street Edit')); 
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
 
         // verify the previous addresses got Default cleared.
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        // each set of edits created a new address object 
        System.assertEquals(2 * 4, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fNewDefault = (addr.MailingStreet__c.contains('final Street Edit'));
            System.assertEquals(fNewDefault, addr.Default_Address__c);
        }        
    }

    /*********************************************************************************************************
    @description Update accounts' billing address to cause an update of the default Address object.  
    verify:
        existing Default Address updated
        HH and Contacts get updated Address
    **********************************************************************************************************/            
    @isTest
    public static void updateAccAddrExistingHH() {
        configSettings();
        
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        // modify some of the account addresses directly
        // NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
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
            acc.BillingStreet = ' direct street  edit ';    // whitespace and casing should not count as real edit.
            acc.BillingState = 'Oregon';
        }
        Test.startTest();
        update consAccsAddrs.accs;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            UTIL_Debug.debug('****Contact to compare in updateAccAddrExistingHH: ' + JSON.serializePretty(con));
            Account acc = mapAccIdAcc.get(con.AccountId);
            UTIL_Debug.debug('****Account to compare in updateAccAddrExistingHH: ' + JSON.serializePretty(acc));
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assert(acc.BillingStreet.contains('direct street  edit'));
            System.assert(con.MailingStreet.contains('direct street  edit')); 
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
 
        // verify that no new address was created
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        System.assertEquals(2, listAddr.size());
        for (Address__c addr : listAddr) {
            System.assertEquals('direct street  edit', addr.MailingStreet__c);
        }        
    }

    /*********************************************************************************************************
    @description Create an Address with no Account. 
    verify:
        runtime error
    **********************************************************************************************************/            
    @isTest
    public static void newAddrNoAccount() {
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            System.assertEquals(null, addrs[i].Parent_Account__c);
        }
        
        try {
            insert addrs;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(Label.addrHhAdmAccountOnly));
            return;
        }
        System.assert(false); //we shouldn't get here!
    }

    /*********************************************************************************************************
    @description Insert new seasonal addresses to HH w/ existing default addresses.  
    verify:
        contact's && hh address matches new seasonal
        old default addresses still marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewSeasonalAddrHH() {
        configSettings();
             
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        // create additional addresses
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = false;
            addrs[i].Seasonal_Start_Month__c = string.valueOf(System.today().addMonths(-1).month());
            addrs[i].Seasonal_Start_Day__c = '1';
            addrs[i].Seasonal_End_Month__c = string.valueOf(System.today().addMonths(1).month());
            addrs[i].Seasonal_End_Day__c = '28';
            addrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert addrs;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        System.assertEquals(2 * 2, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Seasonal Street'));
            System.assert(con.MailingCity.contains('New Seasonal City'));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the previous addresses still are Default
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        System.assertEquals(2 * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            System.assertEquals(!fSeasonal, addr.Default_Address__c);
        }        
    }
    
    /*********************************************************************************************************
    @description Insert new seasonal addresses to HH w/ existing default addresses.  
    verify:
        contact's && hh address matches new seasonal
        old default addresses still marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewSeasonalAddrHHWithYear() {
        configSettings();
        
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        // create additional addresses
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = false;
            
            addrs[i].Seasonal_Start_Year__c = System.today().addYears(-1).year();
            addrs[i].Seasonal_Start_Month__c = string.valueOf(System.today().addMonths(-1).month());
            addrs[i].Seasonal_Start_Day__c = '1';
            
            addrs[i].Seasonal_End_Year__c = System.today().addYears(1).year();
            addrs[i].Seasonal_End_Month__c = string.valueOf(System.today().addMonths(1).month());
            addrs[i].Seasonal_End_Day__c = '28';
            
            addrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert addrs;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        System.assertEquals(2 * 2, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Seasonal Street'));
            System.assert(con.MailingCity.contains('New Seasonal City'));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the previous addresses still are Default
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        System.assertEquals(2 * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            UTIL_Debug.debug('****Is seasonal: ' + fSeasonal);
            System.assertEquals(!fSeasonal, addr.Default_Address__c);
        }        
    }

    /*********************************************************************************************************
    @description Insert new seasonal addresses, not current, to HH w/ existing default addresses.  
    verify:
        contact's && hh address stay with default
        old default addresses still marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewSeasonalAddrNotCurrentHH() {
        configSettings();
        
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        // create additional addresses
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = false;
            addrs[i].Seasonal_Start_Month__c = string.valueOf(System.today().addMonths(1).month());
            addrs[i].Seasonal_Start_Day__c = '1';
            addrs[i].Seasonal_End_Month__c = string.valueOf(System.today().addMonths(2).month());
            addrs[i].Seasonal_End_Day__c = '28';
            addrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert addrs;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        System.assertEquals(2 * 2, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assert(!con.MailingStreet.contains('New Seasonal Street'));
            System.assert(!con.MailingCity.contains('New Seasonal City'));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the previous addresses still are Default
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        System.assertEquals(2 * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            System.assertEquals(!fSeasonal, addr.Default_Address__c);
        }        
    }

    /*********************************************************************************************************
    @description Update seasonal addresses to current, on HH w/ existing default addresses.  
    verify:
        contact's && hh address updated to seasonal address
        old default addresses still marked default
    **********************************************************************************************************/            
    @isTest
    public static void updateSeasonalAddrHH() {
        configSettings();
        
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        // create additional seasonal addresses not current
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = false;
            addrs[i].Seasonal_Start_Month__c = string.valueOf(System.today().addMonths(1).month());
            addrs[i].Seasonal_Start_Day__c = '1';
            addrs[i].Seasonal_End_Month__c = string.valueOf(System.today().addMonths(2).month());
            addrs[i].Seasonal_End_Day__c = '28';
            addrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        insert addrs;
        
        // now make them current
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Seasonal_Start_Month__c = string.valueOf(System.today().addMonths(-1).month());
        }
        Test.startTest();
        ADDR_Contact_TEST.turnOnAllAddrTriggers();                
        update addrs;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        System.assertEquals(2 * 2, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Seasonal Street'));
            System.assert(con.MailingCity.contains('New Seasonal City'));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the previous addresses still are Default
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        System.assertEquals(2 * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            System.assertEquals(!fSeasonal, addr.Default_Address__c);
        }        
    }

    /*********************************************************************************************************
    @description Schedule a seasonal address update. 
    verify:
        contact's && hh address matches new seasonal
        old default addresses still marked default
    **********************************************************************************************************/            
    @isTest
    public static void scheduleSeasonalAddrUpdateHH() {
        configSettings();
                
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
 
        // create additional addresses
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = false;
            addrs[i].Seasonal_Start_Month__c = string.valueOf(System.today().month());
            addrs[i].Seasonal_Start_Day__c = string.valueOf(System.today().day());
            addrs[i].Seasonal_End_Month__c = string.valueOf(System.today().addMonths(1).month());
            addrs[i].Seasonal_End_Day__c = '28';
            addrs[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrs[i].MailingCity__c = 'New Seasonal City' + i;
        }
        
        // Hack!  by setting our trigger handler as run,
        // we can insert the new seasonal addresses but not have them processed.
        // this way we can test the scheduled job!
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
        
        // run the scheduled batch directly
        ADDR_Seasonal_BATCH batch = new ADDR_Seasonal_BATCH();
        Test.startTest(); 
        Database.executeBatch(batch);
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        System.assertEquals(2 * 2, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Seasonal Street'));
            System.assert(con.MailingCity.contains('New Seasonal City'));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the previous addresses still are Default
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        System.assertEquals(2 * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            System.assertEquals(!fSeasonal, addr.Default_Address__c);
        }        
    }

    /*********************************************************************************************************
    @description Create N new duplicate Addresses from Account, with non-default existing.  
    verify:
        duplicates not created
        found match becomes Default
    **********************************************************************************************************/            
    @isTest
    public static void newDupeAccountAddrNonDefaultHH() {
        configSettings();
           
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());

         // create additional non-default addresses
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = false;
            addrs[i].MailingStreet__c = 'New Street' + i;
            addrs[i].MailingCity__c = 'New City' + i;
        }
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        insert addrs;
 
        // create additional addresses thru the account.
        for (Integer i = 0; i < 2; i++) {
            consAccsAddrs.accs[i].BillingStreet = addrs[i].MailingStreet__c;
            consAccsAddrs.accs[i].BillingCity = addrs[i].MailingCity__c;
            consAccsAddrs.accs[i].BillingState = addrs[i].MailingState__c;
            consAccsAddrs.accs[i].BillingPostalCode = addrs[i].MailingPostalCode__c;
            consAccsAddrs.accs[i].BillingCountry = addrs[i].MailingCountry__c;
        }        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update consAccsAddrs.accs;
        Test.stopTest();
        
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        UTIL_Debug.debug('****newDupeAccountAddrNonDefaultHH accounts: ' + JSON.serializePretty(mapAccIdAcc.values()));
        UTIL_Debug.debug('****newDupeAccountAddrNonDefaultHH contacts: ' + JSON.serializePretty(listCon));
        UTIL_Debug.debug('****newDupeAccountAddrNonDefaultHH addresses: ' + JSON.serializePretty(listAddr));
        System.assertEquals(4, listAddr.size());
        
        // verify that the HH and Contacts share the same address and it's new!
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Street'));
            System.assert(con.MailingCity.contains('New City'));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the new addresses still are Default and we don't have too many
        for (Address__c addr : listAddr) {
            boolean isNew = (addr.MailingStreet__c.contains('New Street'));
            System.assertEquals(isNew, addr.Default_Address__c);
        }        
 
    }

    /*********************************************************************************************************
    @description Create N new duplicate Addresses from Contact, with non-default existing.  
    verify:
        duplicates not created
        found match becomes Default
    **********************************************************************************************************/            
    @isTest
    public static void newDupeContactAddrNonDefaultHH() {
        configSettings();
        
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());

        // create additional non-default addresses
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = false;
            addrs[i].MailingStreet__c = 'New Street' + i;
            addrs[i].MailingCity__c = 'New City' + i;
        }
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        insert addrs;
 
        // create additional addresses thru the contact.
        for (Integer i = 0; i < 2; i++) {
            for (Integer j = 0; j < 2; j++) {
                consAccsAddrs.contacts[(i * 2) + j].MailingStreet = addrs[i].MailingStreet__c;
                consAccsAddrs.contacts[(i * 2) + j].MailingCity = addrs[i].MailingCity__c;
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
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        System.assertEquals(2 * 2, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Street'));
            System.assert(con.MailingCity.contains('New City'));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the new addresses still are Default and we don't have too many
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        System.assertEquals(2 * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean isNew = (addr.MailingStreet__c.contains('New Street'));
            System.assertEquals(isNew, addr.Default_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Update contacts' mailing address when they have an address override.
    verify:
        new non-default Address created
        contact override updated to new address
        only the contact gets the new Address
    **********************************************************************************************************/            
    @isTest
    public static void updateConAddrWithOverrideHH() {
        configSettings();
               
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());

        // create additional addresses
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        ADDR_Addresses_TDTM.addressIdsInserted = new Set<Id>();
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        ADDR_Addresses_TDTM.addressIdsInserted = new Set<Id>();
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = false;
            addrs[i].MailingStreet__c = 'override' + i;
            addrs[i].MailingCity__c = 'override' + i;
        }
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        insert addrs;
    
        ADDR_Contact_TEST.turnOnAllAddrTriggers();    
        // set the contacts' address overrides
        List<Contact> listCon = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.Current_Address__c = addrs[i].Id;
            con.is_Address_Override__c = true;
            listCon.add(con);
        }
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        update listCon;
 
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        // modify override contact address info directly
        for (Contact con : listCon) {
            con.MailingStreet = 'Direct Street Edit';
            con.MailingCity = 'Direct City Edit';
        }
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        Test.startTest();
        update listCon;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        UTIL_Debug.debug('****Contacts after all updates: ' + JSON.serializePretty(listCon));
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            if (con.is_Address_Override__c == false) {
                System.assertNotEquals(null, con.Current_Address__c);
                System.assertEquals(true, isMatchAddressAccCon(acc, con));
                System.assert(!con.MailingStreet.contains('Direct Street Edit'));
                System.assert(!con.MailingCity.contains('Direct City Edit'));
                System.assert(!con.MailingStreet.contains('override'));
                System.assert(!con.MailingCity.contains('override'));
            } else {
                System.assertEquals(false, isMatchAddressAccCon(acc, con));
                System.assert(con.MailingStreet.contains('Direct Street Edit'));
                System.assert(con.MailingCity.contains('Direct City Edit'));
                System.assertEquals(true, con.is_Address_Override__c);
                System.assertNotEquals(null, con.Current_Address__c);
            }
        }
 
         // verify the new overrides are not marked default, and that the contact points to them
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        System.assertEquals(2 * 3, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fOverride = (addr.MailingStreet__c.contains('Direct Street Edit'));
            if (fOverride) {
                System.assertEquals(false, addr.Default_Address__c);
                boolean isSetOnContact = false;
                for (Contact con : listCon) {
                    if (con.is_Address_Override__c && con.Current_Address__c == addr.Id)
                        isSetOnContact = true;
                }
                System.assertEquals(true, isSetOnContact);
            }
        }                
    }

    /*********************************************************************************************************
    @description Insert new contacts with no addresses to existing households that have default addresses
    verify new contacts get the default hh address.
    **********************************************************************************************************/            
    @isTest
    public static void insertConWithNoAddrToExistingHH() {
        configSettings();
             
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, 
                                                                                        UTIL_Describe.getHhAccRecTypeID());

        // insert new contacts to the HH without any addresses
        List<Contact> listCon = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        for (Integer i = 0; i < 2; i++) {
            listCon[i].LastName = 'ToAvoidDupeRule' + i;
            listCon[i].AccountId = consAccsAddrs.accs[i].Id;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert listCon;         
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, 
                                                                            BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, 
                                                                            MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Insert new contacts with addresses to existing households that have default addresses.
    verify all contacts and hh get the new default hh address from the new contacts.
    **********************************************************************************************************/            
    @isTest
    public static void insertConWithAddrToExistingHH() {
        configSettings();
           
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
 
        // insert new contacts to the HH with new addresses, one per Household
        List<Contact> listCon = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        for (Integer i = 0; i < 2; i++) {
            listCon[i].AccountId = consAccsAddrs.accs[i].Id;
            listCon[i].LastName = 'ToAvoidDupeRule' + i;
            listCon[i].MailingStreet = 'New Mailing Street' + i;
            listCon[i].MailingCity = 'New Mailing City' + i;
            listCon[i].MailingState = 'California';
            listCon[i].MailingCountry = 'United States';
        }
        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert listCon;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        List<Address__c> addrs = [select Default_Address__c, MailingStreet__c, MailingCity__c, MailingState__c, MailingCountry__c from Address__c];
        
        UTIL_Debug.debug('****Accs queried: ' + JSON.serializePretty(mapAccIdAcc.values()));
        UTIL_Debug.debug('****Contacts queried: ' + JSON.serializePretty(listCon));
        UTIL_Debug.debug('****Addresses queried: ' + JSON.serializePretty(addrs));
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
            System.assert(con.MailingStreet.contains('New Mailing Street'));
            System.assert(con.MailingCity.contains('New Mailing City'));
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
        configSettings();
              
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        // insert new contacts to the HH with the current default addresses
        List<Contact> listCon = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        for (Integer i = 0; i < 2; i++) {
            listCon[i].LastName = 'ToAvoidDupeRule' + i;
            listCon[i].AccountId = consAccsAddrs.accs[i].Id;
            listCon[i].MailingStreet = consAccsAddrs.accs[i].BillingStreet;
            listCon[i].MailingCity = consAccsAddrs.accs[i].BillingCity;
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
        
        // verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        System.assertEquals(2 * (2 + 1), listCon.size());
        
        Integer cAddr = [select count() from Address__c];
        System.assertEquals(2, cAddr);
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Insert contact w/ multiline street address.
    verify:
        new default Address created and the street address is broken up into street and street2
        the HH Account gets the new multiline address
    **********************************************************************************************************/            
    @isTest
    public static void insertContactWithMultilineStreetAddressHH() {
        configSettings();
   
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        //create new contacts, one per household
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
        
        // verify the Address objects split street.
        List<Address__c> listAddr = [select Id, MailingStreet__c, MailingStreet2__c, Formula_MailingStreetAddress__c from Address__c 
        where MailingStreet__c = 'new street'];
        System.assertEquals(2, listAddr.size());
        for (Address__c addr : listAddr) {
            System.assertEquals('new street', addr.MailingStreet__c);
            System.assertEquals('second line', addr.MailingStreet2__c);
            System.assertEquals('new street, second line', addr.Formula_MailingStreetAddress__c);
        }

        // verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals('new street\r\nsecond line', con.MailingStreet);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
            System.assertEquals(false, con.is_Address_Override__c);
            System.assertNotEquals(null, con.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Insert new default multiline street addresses to HH w/ existing default addresses.  
    verify:
        contact's && hh address matches new default
        street & street2 combined into contact and account single street field
    **********************************************************************************************************/            
    @isTest
    public static void insertNewDefaultMultilineStreetAddrHH() {
        configSettings();
        
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());

        // create additional addresses
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = true;
            addrs[i].MailingStreet__c = 'New Default Street';
            addrs[i].MailingStreet2__c = 'Second Line';
            addrs[i].MailingCity__c = 'New Default City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert addrs;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();        
        Test.stopTest();

        // verify that the HH and Contacts share the same address and it's new!
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        System.assertEquals(2 * 2, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            System.assertEquals(true, isMatchAddressAccCon(acc, con));
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
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());

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
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
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
                System.assertEquals('Direct Street Edit, Second Line', addr.Formula_MailingStreetAddress__c);
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
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c (Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(), 
                                       Household_Addresses_RecType__c = null));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        for (Contact con : contacts) {
            con.MailingStreet = 'new street';
            con.MailingCity = 'new city';
        }
        insert contacts;        

        // verify that the HH and Contacts don't share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
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
        Contact contact = new Contact(LastName = 'Testerson', MailingStreet = '123 Default', MailingCity = 'Austin', MailingState = 'Texas', MailingCountry = 'United States');
        insert contact;
        
        //Parent Admin Account should have been created
        contact = [select AccountID, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude 
                   from Contact where ID = :contact.ID];       
        System.assertNotEquals(null, contact.AccountID);
                
        //Address flagged as default should have been created
        Address__c defaultAddress = [select ID, Default_Address__c from Address__c where Parent_Account__c = : contact.AccountID];
        System.assertEquals(true, defaultAddress.Default_Address__c);
        
        Account acc = [select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude 
                       from Account where ID = :contact.AccountID];
        
        //Verify account and contact share same address
        System.assertEquals(true, isMatchAddressAccCon(acc, contact));
        System.assertEquals('123 Default', contact.MailingStreet);
        System.assertEquals('Austin', acc.BillingCity);
        
        //Create seasonal Address with start and end year that include the current date
        Address__c seasonalAddress = new Address__c(Parent_Account__c = contact.AccountID, MailingStreet__c = '123 Seasonal', MailingCity__c = 'Seattle', 
            MailingState__c = 'Washington', MailingCountry__c = 'United States', Seasonal_Start_Day__c = String.valueOf(System.today().addDays(-1).day()), 
            Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(-1).month()), Seasonal_Start_Year__c = System.today().addYears(-1).year(), 
            Seasonal_End_Day__c = String.valueOf(System.today().addDays(1).day()), Seasonal_End_Month__c = String.valueOf(System.today().addMonths(1).month()), 
            Seasonal_End_Year__c = System.today().addYears(1).year());
        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert seasonalAddress;
        Test.stopTest();
        
        //Seasonal Address should have been copied to the Contact and the Account
        contact = [select AccountID, MailingStreet, MailingCity, MailingState from Contact where ID = :contact.ID];
        System.assertEquals('123 Seasonal', contact.MailingStreet);
        System.assertEquals('Seattle', contact.MailingCity);
        System.assertEquals('Washington', contact.MailingState);
        
        acc = [select BillingStreet, BillingCity, BillingState from Account where ID = :contact.AccountID];
        System.assertEquals('123 Seasonal', acc.BillingStreet);
        System.assertEquals('Seattle', acc.BillingCity);
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
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        UTIL_Debug.debug('****Test data created for test: ' + JSON.serializePretty(consAccsAddrs));
        
        // clear some of the contact addresses directly - one in each household
        for (integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.MailingStreet = null;
            con.MailingCity = null;
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
        List<Account> listAcc = [select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account];
        List<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
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
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe.getHhAccRecTypeID());
        
        Contact con = new Contact();
        con.lastname = 'test';
        con.AccountId = consAccsAddrs.accs[0].Id;
        con.is_Address_Override__c = true;
        con.Current_Address__c = consAccsAddrs.addrs[0].Id;
        
        Test.startTest();
        insert con;
        Test.stopTest();
        
        con = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, 
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
        
        Account orgAcc = new Account(Name='Org Account', RecordTypeID = UTIL_Describe.getBizAccRecTypeID());
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
        Account acc = [select Id, Name, BillingStreet from Account where Name like '%Household%'];
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
}