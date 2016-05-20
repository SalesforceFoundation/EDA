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
* @description Tests specific to Address Management. 
*/

@isTest
public with sharing class ADDR_Addresses_TEST {

    /* @description The list of created test Contacts.*/
    private static list<Contact> listContacts;

    /* @description The list of created test Accounts.*/
    public static list<Account> listAccs;
    
    /* @description The list of created test Addresses.*/
    public static list<Address__c> listAddrs;
    
    private static void configSettings() {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c();
        hs.Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID();
        hs.Accounts_Addresses_Enabled__c = UTIL_Describe.getAdminAccRecTypeID() + ';';
        hs.Simple_Address_Change_Treated_as_Update__c = true;
        UTIL_CustomSettingsFacade.getSettingsForTests(hs);
    }

    /*********************************************************************************************************
    * @description Sets up common test data for Account Addresses tests.
    * @param accCount Number of  Accounts to create.
    * @return  void
    **********************************************************************************************************/    
    public static void createTestDataAccs(Integer accCount) {        
        configSettings();
        
        //instantiate accounts
        listAccs = UTIL_UnitTestData_TEST.CreateMultipleTestAccounts(accCount, UTIL_Describe.getAdminAccRecTypeID());
        //insert accounts
        insert listAccs;      
        
        //instantiate addresses
        initTestAddr(accCount);
        //link addresses with accounts and make them default
        for (Integer i = 0; i < accCount; i++) {
            listAddrs[i].Parent_Account__c = listAccs[i].Id;
            listAddrs[i].Default_Address__c = true;
        }
        //insert addresses
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrs;
        
        //clear our triggers recursion prevention since we are starting a new test
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
    }
    
    /*********************************************************************************************************
    * @description Sets up common test data for Contact Addresses tests.
    * @param contactCount Number of  Contacts to create.
    * @return  void
    **********************************************************************************************************/  
    public static void createTestDataContacts(Integer contactCount) {
        //instantiate contacts
        listContacts = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(contactCount);
        //insert contacts
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listContacts;
        
        //instantiate addresses
        initTestAddr(contactCount);
        //link addresses with contacts and make them default
        for (Integer i = 0; i < contactCount; i++) {
            listAddrs[i].Parent_Contact__c = listContacts[i].Id;
            listAddrs[i].Default_Address__c = true;
        }
        //insert addresses
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrs;
        
        //clear our triggers recursion prevention since we are starting a new test
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
    }

    /*********************************************************************************************************
    * @description Initializes (but not inserts) N new Address objects.
    * @param cAddr the number of Address objects to create
    * @return  void
    **********************************************************************************************************/
    public static void initTestAddr(Integer cAddr) {
        listAddrs = new list<Address__c>();
        for (Integer i = 0; i < cAddr; i++) {
            Address__c addr = new Address__c();
            addr.Address_Type__c = 'Home';
            addr.MailingStreet__c = 'Street' + i;
            addr.MailingCity__c = 'City' + i;
            addr.MailingState__c = 'Washington';
            addr.MailingPostalCode__c = 'Zip' + i;
            addr.MailingCountry__c = 'United States';
            addr.Geolocation__Latitude__s = 47.6097 + i;
            addr.Geolocation__Longitude__s = -122.3331 + i;
            listAddrs.add(addr);            
        }
    }
        
    /*********************************************************************************************************
    @description Update existing default Addresses.  
    verify: household billing address fields updated
    **********************************************************************************************************/            
    @isTest 
    public static void updateDefaultAddrAcc() {
        // this creates a default Address for each Account
        createTestDataAccs(2);

        // now let's update the Addresses
        for (Integer i = 0; i < listAddrs.size(); i++) {
            Address__c addr = listAddrs[i];
            addr.MailingStreet__c = 'New Street' + i;
            addr.MailingCity__c = 'New City' + i;
        }
        system.assertEquals(false, ADDR_Addresses_TDTM.hasRunAddrTrigger);
        Test.startTest();
        update listAddrs;
        Test.stopTest();
    
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c
        from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            system.assert(acc.BillingStreet.contains('New Street'));
            system.assert(acc.BillingCity.contains('New City'));
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
    }
    
    /*********************************************************************************************************
    @description Delete existing default Addresses.  
    verify: Account billing address fields cleared.
    **********************************************************************************************************/            
    @isTest //PASS
    static void deleteDefaultAddrAcc() {        
        // this creates a default Address for each Account
        createTestDataAccs(2);
       
        // now let's delete the Addresses
        system.assertEquals(false, ADDR_Addresses_TDTM.hasRunAddrTrigger);
        Test.startTest();
        delete listAddrs;
        Test.stopTest();
    
        // verify that the Account address fields are cleared
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            system.assertEquals(null, acc.BillingStreet);
            system.assertEquals(null, acc.BillingCity);
        }
    }

    /*********************************************************************************************************
    @description Delete existing non-default override Addresses.  
    verify: Account billing address fields not changed.
    **********************************************************************************************************/            
    @isTest
    static void deleteNonDefaultOverrideAddrAcc() {        
        createTestDataAccs(2);
        
        // create additional addresses
        initTestAddr(2);
        for (integer i = 0; i < listAccs.size(); i++) {
            listAddrs[i].Parent_Account__c = listAccs[i].Id;
            listAddrs[i].Default_Address__c = false;
            listAddrs[i].MailingStreet__c = 'override' + i;
            listAddrs[i].MailingCity__c = 'override' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrs;
        
        Integer addrCount = [select count() from Address__c];
        System.assertEquals(4, addrCount);
        
        // set the accounts' address overrides
        for (integer i = 0; i < listAccs.size(); i++) {
            Account acc = listAccs[i];
            acc.Current_Address__c = listAddrs[i].Id;
            acc.is_Address_Override__c = true;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccs;        
        
        // now let's delete the override Addresses
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        delete listAddrs;
        Test.stopTest();
    
        // verify that the Account address fields went back to the default
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            system.assert(acc.BillingStreet.contains('Street'));
            system.assert(acc.BillingCity.contains('City')); 
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);                
        }
    }

    /*********************************************************************************************************
    @description Making an Address non-default. That is, the address is no longer the default one for the Account.  
    verify:
        no change to account address
    **********************************************************************************************************/            
    @isTest
    public static void updateNonDefaultAddrAcc() { 
        // this creates a default Address for each Account
        createTestDataAccs(2);

        // now let's update the Addresses
        for (Integer i = 0; i < listAddrs.size(); i++) {
            Address__c addr = listAddrs[i];
            addr.Default_Address__c = false;
        }
        system.assertEquals(false, ADDR_Addresses_TDTM.hasRunAddrTrigger);
        Test.startTest();
        update listAddrs;
        Test.stopTest();
    
        // verify that the Account and Contacts don't share the same address and it's new for the Account!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c 
        from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            system.assertEquals(null, acc.BillingStreet); //address information has been cleared because address is no longer the default
            system.assertEquals(null, acc.BillingCity); //address information has been cleared because address is no longer the default
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertEquals(null, acc.Current_Address__c); //account no longer has a current address, since address is no longer the defaults
        }
    }

    /*********************************************************************************************************
    @description Set account address override.  
    verify: account's address matches override
    **********************************************************************************************************/            
    @isTest
    public static void setAddrOverrideAcc() {        
        // this creates a default Address for the Account
        createTestDataAccs(2);

        // create new non-default address
        Address__c addrNew = new Address__c();
        addrNew.MailingStreet__c = 'street override';
        addrNew.MailingCity__c = 'city override';
        addrNew.Default_Address__c = false;
        // assign it to the second account
        addrNew.Parent_Account__c = listAccs[1].Id;
        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert addrNew;
        
        // set account's address override
        listAccs[1].Current_Address__c = addrNew.Id;
        listAccs[1].is_Address_Override__c = true;
        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccs[0];
    
        // now let's update the default Address for both accounts
        listAddrs[0].MailingStreet__c = 'New Street';
        listAddrs[0].MailingCity__c = 'New City';
        listAddrs[1].MailingStreet__c = 'New Street';
        listAddrs[1].MailingCity__c = 'New City';

        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update listAddrs;
        Test.stopTest();
        
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            // verify that the Account address is override
            if (acc.is_Address_Override__c) { 
                system.assert(!acc.BillingStreet.contains('street override'));
                system.assert(!acc.BillingCity.contains('city override'));
                system.assertEquals(acc.Current_Address__c, addrNew.Id);            
            // verify that the Account address is new
            } else { 
                system.assert(acc.BillingStreet.contains('New Street'));
                system.assert(acc.BillingCity.contains('New City'));
                system.assertNotEquals(null, acc.Current_Address__c);
            }
        }
    }

    /*********************************************************************************************************
    @description Insert new default addresses to Account w/ existing default addresses  
    verify:
        Account address matches new default
        old default addresses no longer marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewDefaultAddrAcc() {        
        // this creates a default Address for each Account
        createTestDataAccs(2);
        
        // create additional addresses
        initTestAddr(2);
        for (Integer i = 0; i < listAccs.size(); i++) {
            listAddrs[i].Parent_Account__c = listAccs[i].Id;
            listAddrs[i].Default_Address__c = true;
            listAddrs[i].MailingStreet__c = 'New Default Street' + i;
            listAddrs[i].MailingCity__c = 'New Default City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        insert listAddrs;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;        
        Test.stopTest();

        // verify that the Account addresses are new
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            system.assert(acc.BillingStreet.contains('New Default Street'));
            system.assert(acc.BillingCity.contains('New Default City'));
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
        
        // verify the previous addresses got Default cleared.
        // and verify latest start date and latest end date appropriately set.
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, 
        Latest_End_Date__c from Address__c];
        system.assertEquals(4, listAddr.size());
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
    @description Insert new default addresses to Account with existing default addresses, and then go back  
    verify:
        Account address matches original default
        new default addresses no longer marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewDefaultAddrAndResetAcc() {  
        // this creates a default Address for each Account
        createTestDataAccs(2);

        list<Address__c> listAddrOriginal = listAddrs;
        
        // create additional addresses
        initTestAddr(2);
        for (Integer i = 0; i < listAccs.size(); i++) {
            listAddrs[i].Parent_Account__c = listAccs[i].Id;
            listAddrs[i].Default_Address__c = true;
            listAddrs[i].MailingStreet__c = 'New Default Street' + i;
            listAddrs[i].MailingCity__c = 'New Default City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrs;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // go back to original default addresses
        // added this extra set to test fix where we didn't use the correct default
        for (Integer i = 0; i < listAccs.size(); i++) {
            listAddrOriginal[i].Default_Address__c = true;
            listAddrOriginal[i].MailingStreet__c = 'Original Default Street' + i;
            listAddrOriginal[i].MailingCity__c = 'Original Default City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update listAddrOriginal;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();
        
        // verify the additional addresses got Default cleared.
        // and verify latest start date and latest end date appropriately set.
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, 
        Latest_End_Date__c from Address__c];
        system.assertEquals(4, listAddr.size());
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
    @description Clear Accounts' Address Override  
    verify: accounts' Mailing address fields updated to the default address
    **********************************************************************************************************/            
    @isTest
    public static void clearAddrOverrideAcc() {        
        // this creates a default Address for each Account
        createTestDataAccs(4);

        // create additional addresses
        initTestAddr(4);
        for (Integer i = 0; i < listAddrs.size(); i++) {
            listAddrs[i].Parent_Account__c = listAccs[i].Id;
            listAddrs[i].Default_Address__c = false;
            listAddrs[i].MailingStreet__c = 'override' + i;
            listAddrs[i].MailingCity__c = 'override' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrs;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // set the accounts' address overrides
        for (Integer i = 0; i < listAccs.size(); i++) {
            listAccs[i].Current_Address__c = listAddrs[i].Id;
            listAccs[i].is_Address_Override__c = true;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccs;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;

        // now clear out the accounts' address overrides
        for (Account acc : listAccs) {
            acc.is_Address_Override__c = false;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update listAccs;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();
        
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c from Account]);
        
        // verify accounts reverted to the defaults
        for (Account acc : mapAccIdAcc.values()) {
            system.assert(acc.BillingStreet.contains('Street'));
            system.assert(acc.BillingCity.contains('City'));
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }

        // verify address overrides have latest start date and latest end date appropriately set.
        list<Address__c> listAddr = [select Id, Latest_Start_Date__c, Latest_End_Date__c from Address__c where Id in :listAddrs];
        system.assertEquals(4, listAddr.size());
        for (Address__c addr : listAddr) {
           system.assertEquals(system.today(), addr.Latest_Start_Date__c);
           system.assertEquals(system.today(), addr.Latest_End_Date__c);
        }        
    }

    /*********************************************************************************************************
    @description Update contacts' mailing address to cause creation of new default Address object.  
    verify:
        new Default Address created
        Accounts get new Address
    **********************************************************************************************************/            
    @isTest
    public static void updateAddrNewAcc() {        
        // this creates a default Address for each Account
        createTestDataAccs(4);

        // modify some of the Account addresses directly
        for (Integer i = 0; i < listAccs.size(); i++) {
            listAccs[i].BillingStreet = 'Direct Street Edit';
            listAccs[i].BillingCity = 'Direct City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccs;

        for (Integer i = 0; i < listAccs.size(); i++) {
            listAccs[i].BillingStreet = 'another Street Edit';
            listAccs[i].BillingCity = 'another City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccs;

        for (Integer i = 0; i < listAccs.size(); i++) {
            listAccs[i].BillingStreet = 'final Street Edit';
            listAccs[i].BillingCity = 'final City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update listAccs;
        Test.stopTest();
        
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            system.assert(acc.BillingStreet.contains('final Street Edit'));
            system.assert(acc.BillingCity.contains('final City Edit'));
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
 
         // verify the previous addresses got Default cleared.
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        // each set of edits created a new address object 
        system.assertEquals(16, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fNewDefault = (addr.MailingStreet__c.contains('final Street Edit'));
            system.assertEquals(fNewDefault, addr.Default_Address__c);
        }                
    }

    /*********************************************************************************************************
    @description
        update Address' billing address and mark it as override, to cause creation of new non-default Address object  
    verify:
        new Address created
        original Addresses still default    
    **********************************************************************************************************/            
    @isTest
    public static void updateAddrMarkOverrideAcc() {        
        // this creates a default Address for each Account
        createTestDataAccs(2);

        // modify the account addresses directly, and set override
        for (Integer i = 0; i < listAccs.size(); i++) {
            listAccs[i].BillingStreet = 'Direct Street Edit';
            listAccs[i].BillingCity = 'Direct City Edit';
            listAccs[i].is_Address_Override__c = true;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update listAccs;
        Test.stopTest();
        
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c from Account]);
        
        system.assertEquals('Direct Street Edit', mapAccIdAcc.values()[0].BillingStreet);
        system.assertEquals('Direct City Edit', mapAccIdAcc.values()[0].BillingCity);
        system.assertEquals(true, mapAccIdAcc.values()[0].is_Address_Override__c);
        system.assertEquals('Direct Street Edit', mapAccIdAcc.values()[1].BillingStreet);
        system.assertEquals('Direct City Edit', mapAccIdAcc.values()[1].BillingCity);
        system.assertEquals(true, mapAccIdAcc.values()[1].is_Address_Override__c);
 
         // verify the previous addresses didn't get Default cleared.
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        system.assertEquals(4, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean isNewEdit = (addr.MailingStreet__c.contains('Direct Street Edit'));
            if(isNewEdit) {
                system.assertNotEquals(false, addr.Default_Address__c);
            }
        }
    }

    /*********************************************************************************************************
    @description Update accounts' billing address to cause an update to default Address object  
    verify:
        existing Default Address updated
        HH and Contacts get updated Address
    **********************************************************************************************************/            
    @isTest
    public static void updateAddrExistingAcc() {        
        // this creates a default Address for each Account
        createTestDataAccs(2);

        // modify some of the account addresses directly
        // NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
        for (Integer i = 0; i < listAccs.size(); i++) {
            listAccs[i].BillingStreet = 'Direct Street Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccs;

        for (Integer i = 0; i < listAccs.size(); i++) {
            listAccs[i].BillingState = 'Washington';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccs;

        for (Integer i = 0; i < listAccs.size(); i++) {
            listAccs[i].BillingStreet = ' direct street  edit ';  // whitespace and casing should not count as a real edit.
            listAccs[i].BillingState = 'Oregon';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update listAccs;
        Test.stopTest();
        
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            system.assert(acc.BillingStreet.contains('direct street  edit'));
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
 
        // verify that no new address was created
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        system.assertEquals(2, listAddr.size());
        for (Address__c addr : listAddr) {
            system.assertEquals('direct street  edit', addr.MailingStreet__c);
        }                
    }

    /*********************************************************************************************************
    @description Update contacts' mailing address with just a case change, to cause an update to default Address object  
    verify:
        existing Default Address updated
        HH and Contacts get updated Address
    **********************************************************************************************************/            
    @isTest
    public static void updateConAddrExistingCaseOnly() {    
        // this creates a default Address for each Account
        createTestDataAccs(2);

        // modify some of the account addresses directly
        // NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
        for (Integer i = 0; i < listAccs.size(); i++) {
            listAccs[i].BillingStreet = 'Direct Street Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccs;

        for (Integer i = 0; i < listAccs.size(); i++) {
            listAccs[i].BillingState = 'Washington';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccs;

        for (Integer i = 0; i < listAccs.size(); i++) {
            listAccs[i].BillingStreet = ' direct street  edit ';  // whitespace and casing should not count as a real edit.
            listAccs[i].BillingState = 'Oregon';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccs;

        for (Integer i = 0; i < listAccs.size(); i++) {
            listAccs[i].BillingStreet = ' DIRECT STREET  EDIT ';  // only change casing.
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update listAccs;
        Test.stopTest();
        
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            system.assert(acc.BillingStreet.equals('DIRECT STREET  EDIT'));
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
 
        // verify that no new address was created
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        system.assertEquals(2, listAddr.size());
        for (Address__c addr : listAddr) {
            system.assert(addr.MailingStreet__c.equals('DIRECT STREET  EDIT'));
        }
        
        // now test that changing the case from the account updates all addresses
        for (Integer i = 0; i < listAccs.size(); i++) {
            Account acc = listAccs[i];
            acc.BillingStreet = 'direct street  edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccs;
        
        // verify that the HH and Contacts share the same address
        mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            system.assert(acc.BillingStreet.equals('direct street  edit'));
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
 
        // verify that no new address was created
        listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        system.assertEquals(2, listAddr.size());
        for (Address__c addr : listAddr) {
            system.assert(addr.MailingStreet__c.equals('direct street  edit'));
        }                   
    }

    /*********************************************************************************************************
    @description Update accounts' billing address to cause an update of the default Address object.  
    verify:
        existing Default Address updated
        Account get updated Address
    **********************************************************************************************************/            
    @isTest
    public static void updateAccAddrExisting() {
        // this creates a default Address for each Account
        createTestDataAccs(2);

        // modify some of the account addresses directly
        // NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
        for (Integer i = 0; i < listAccs.size(); i++) {
            listAccs[i].BillingStreet = 'Direct Street Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccs;

        for (Integer i = 0; i < listAccs.size(); i++) {
            listAccs[i].BillingState = 'Washington';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccs;

        for (Integer i = 0; i < listAccs.size(); i++) {
            listAccs[i].BillingStreet = ' direct street  edit ';    // whitespace and casing should not count as real edit.
            listAccs[i].BillingState = 'Oregon';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update listAccs;
        Test.stopTest();
        
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            system.assert(acc.BillingStreet.contains('direct street  edit'));
            system.assert(acc.BillingStreet.contains('direct street  edit')); 
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
 
        // verify that no new address was created
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        system.assertEquals(2, listAddr.size());
        for (Address__c addr : listAddr) {
            system.assertEquals('direct street  edit', addr.MailingStreet__c);
        }        
    }

    /*********************************************************************************************************
    @description Create an Address with no Account 
    verify:
        runtime error
    **********************************************************************************************************/            
    @isTest
    public static void newAddrNoAccount() {        
        initTestAddr(2);
        for (Integer i = 0; i < listAddrs.size(); i++) {
            system.assertEquals(null, listAddrs[i].Parent_Account__c);
        }
        
        try {
            insert listAddrs;
        } catch (Exception ex) {
            system.assert(ex.getMessage().contains(Label.addrHhAdmAccountOnly));
            return;
        }
        system.assert(false); //we shouldn't get here!
    }
 
    /*********************************************************************************************************
    @description Create N new duplicate Addresses from Account  
    verify:
        duplicates not created
    **********************************************************************************************************/            
    @isTest
    public static void newDupeAccountAddr() {        
        // this creates a default Address for each Account
        createTestDataAccs(2);

        // create additional addresses thru the account.
        for (Integer i = 0; i < listAccs.size(); i++) {
            listAccs[i].BillingStreet = listAddrs[i].MailingStreet__c;
            listAccs[i].BillingCity = listAddrs[i].MailingCity__c;
            listAccs[i].BillingState = listAddrs[i].MailingState__c;
            listAccs[i].BillingPostalCode = listAddrs[i].MailingPostalCode__c;
            listAccs[i].BillingCountry = listAddrs[i].MailingCountry__c;
        }        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update listAccs;
        Test.stopTest();
        
        // verify that we don't have new Addresses
        list<Address__c> listAddr = [select Id from Address__c];
        system.assertEquals(2, listAddr.size());
    }

    /*********************************************************************************************************
    @description Create N new duplicate Addresses from Account, with non-default existing  
    verify:
        duplicates not created
        found match becomes Default
    **********************************************************************************************************/            
    @isTest
    public static void newDupeAccountAddrNonDefault() {        
        // this creates a default Address for each Account
        createTestDataAccs(2);

         // create additional non-default addresses
        initTestAddr(2);
        for (Integer i = 0; i < listAccs.size(); i++) {
            listAddrs[i].Parent_Account__c = listAccs[i].Id;
            listAddrs[i].Default_Address__c = false;
            listAddrs[i].MailingStreet__c = 'New Street' + i;
            listAddrs[i].MailingCity__c = 'New City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrs;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;        
 
        // create additional addresses thru the account.
        for (Integer i = 0; i < listAccs.size(); i++) {
            listAccs[i].BillingStreet = listAddrs[i].MailingStreet__c;
            listAccs[i].BillingCity = listAddrs[i].MailingCity__c;
            listAccs[i].BillingState = listAddrs[i].MailingState__c;
            listAccs[i].BillingPostalCode = listAddrs[i].MailingPostalCode__c;
            listAccs[i].BillingCountry = listAddrs[i].MailingCountry__c;
        }        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update listAccs;
        Test.stopTest();
        
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            system.assert(acc.BillingStreet.contains('New Street'));
            system.assert(acc.BillingCity.contains('New City'));
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
        
        // verify the new addresses still are Default and we don't have too many
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, 
        Latest_End_Date__c from Address__c];
        system.assertEquals(2 * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean isNew = (addr.MailingStreet__c.contains('New Street'));
            system.assertEquals(isNew, addr.Default_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Insert account w/ multiline street address
    verify: new default Address created and the street address is broken up into street and street2
    **********************************************************************************************************/            
    @isTest
    public static void insertContactWithMultilineStreetAddress() {
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID(), 
                Accounts_Addresses_Enabled__c = UTIL_Describe.getAdminAccRecTypeID() + ';'));
    
        listAccs = UTIL_UnitTestData_TEST.CreateMultipleTestAccounts(2, UTIL_Describe.getBizAccRecTypeID());
        for (Account acc : listAccs) {
            acc.BillingStreet = 'new street\r\nsecond line';
            acc.BillingCity = 'new city';
        }
        Test.startTest();
        insert listAccs; 
        Test.stopTest();       
        
        // verify the Address objects split street.
        list<Address__c> listAddr = [select Id, MailingStreet__c, MailingStreet2__c, Formula_MailingStreetAddress__c from Address__c];
        for (Address__c addr : listAddr) {
            system.assertEquals('new street', addr.MailingStreet__c);
            system.assertEquals('second line', addr.MailingStreet2__c);
            system.assertEquals('new street, second line', addr.Formula_MailingStreetAddress__c);
        }

        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            system.assertEquals('new street\r\nsecond line', acc.BillingStreet);
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Insert new default multiline street addresses w/ existing default addresses  
    verify:
        contact's && hh address matches new default
        street & street2 combined into contact and account single street field
    **********************************************************************************************************/            
    @isTest
    public static void insertNewDefaultMultilineStreetAddr() {        
        // this creates a default Address for each Account
        createTestDataAccs(2);

        // create additional addresses
        initTestAddr(2);
        for (Integer i = 0; i < listAccs.size(); i++) {
            listAddrs[i].Parent_Account__c = listAccs[i].Id;
            listAddrs[i].Default_Address__c = true;
            listAddrs[i].MailingStreet__c = 'New Default Street';
            listAddrs[i].MailingStreet2__c = 'Second Line';
            listAddrs[i].MailingCity__c = 'New Default City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        insert listAddrs;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;        
        Test.stopTest();

        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            system.assertEquals('New Default Street\r\nSecond Line', acc.BillingStreet);
            system.assertEquals('New Default Street\r\nSecond Line', acc.BillingStreet);
        }
        
    }
    
    /*********************************************************************************************************
    @description Update accounts' billing address with multiline street address  
    verify:
        new Default Address created
        ACcounts get new Address
        new Addresss has multiline street split into Street and Street2 fields
    **********************************************************************************************************/            
    @isTest
    public static void updateAccMultilineStreetAddr() {        
        // this creates a default Address for each Account
        createTestDataAccs(2);

        // modify some of the account addresses directly
        for (Integer i = 0; i < listAccs.size(); i++) {
            Account acc = listAccs[i];
            acc.BillingStreet = 'Direct Street Edit\r\nSecond Line';
            acc.BillingCity = 'Direct City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update listAccs;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            system.assertEquals('Direct Street Edit\r\nSecond Line', acc.BillingStreet);
            system.assertEquals('Direct Street Edit\r\nSecond Line', acc.BillingStreet);
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
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
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c (Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID(),
                Accounts_Addresses_Enabled__c = UTIL_Describe.getBizAccRecTypeID() + ';'));
 
        Integer cAcc = 3;
        list<Account> listAcc = UTIL_UnitTestData_TEST.CreateMultipleTestAccounts(cAcc, UTIL_Describe.getBizAccRecTypeID());
        for (Account acc : listAcc) {
            acc.BillingStreet = '123 45th';
            acc.BillingCity = 'Seattle';
        }
        Test.startTest();
        insert listAcc;
        Test.stopTest();

        // verify results
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c from Account]);
        system.assertEquals(cAcc, mapAccIdAcc.size());
        
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, MailingCity__c, Parent_Account__c, 
        Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(cAcc, listAddr.size());
        
        for (Address__c addr : listAddr) {
            Account acc = mapAccIdAcc.get(addr.Parent_Account__c);
            system.assertEquals(acc.BillingStreet, addr.MailingStreet__c);
            system.assertEquals(acc.BillingCity, addr.MailingCity__c);
            system.assertEquals(true, addr.Default_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Update N organizational accounts with billing addresses 
    verify:
        N addresses created
        account addresses updated
    **********************************************************************************************************/            
    @isTest
    public static void updateOrgAccounts() {         
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c (Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID(),
                Accounts_Addresses_Enabled__c = UTIL_Describe.getBizAccRecTypeID() + ';'));
 
        // create accounts without addresses
        Integer cAcc = 3;
        list<Account> listAcc = UTIL_UnitTestData_TEST.CreateMultipleTestAccounts(cAcc, UTIL_Describe.getBizAccRecTypeID());
        insert listAcc;

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
        listAcc = [select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, 
                   Current_Address__c from Account order by Account.Name];
        system.assertEquals(cAcc, listAcc.size());
        
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, MailingCity__c, 
        Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c 
        order by Parent_Account__r.Name];
        system.assertEquals(cAcc, listAddr.size());
                
        for (Integer i = 0; i < cAcc; i++) {
            Account acc = listAcc[i];
            Address__c addr = listAddr[i];
            system.assertEquals(acc.BillingStreet, addr.MailingStreet__c);
            system.assertEquals(acc.BillingCity, addr.MailingCity__c);
            system.assertNotEquals(null, acc.BillingStreet);
            system.assertNotEquals(null, acc.BillingCity);
            system.assertEquals(true, addr.Default_Address__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
    }
    
    /*********************************************************************************************************
    @description Update N organizational accounts with address objects 
    verify:
        account addresses updated
        contact addresses not updated
    **********************************************************************************************************/            
    @isTest
    public static void newAddrForOrgAccounts() {           
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c (Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID(),
                Accounts_Addresses_Enabled__c = UTIL_Describe.getBizAccRecTypeID() + ';'));
 
        // create accounts without addresses
        list<Account> listAcc = UTIL_UnitTestData_TEST.CreateMultipleTestAccounts(3, UTIL_Describe.getBizAccRecTypeID());
        insert listAcc;

         // create addresses for the accounts
        initTestAddr(listAcc.size());
        for (Integer i = 0; i < listAcc.size(); i++) {
            listAddrs[i].Parent_Account__c = listAcc[i].Id;
            listAddrs[i].Default_Address__c = true;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrs;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // verify results
        listAcc = [select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c 
        from Account order by Account.Name];
        system.assertEquals(3, listAcc.size());
        
        listAddrs = [select Id, Default_Address__c, MailingStreet__c, MailingCity__c, Parent_Account__c, 
        Latest_Start_Date__c, Latest_End_Date__c from Address__c order by Parent_Account__r.Name];
        system.assertEquals(3, listAddrs.size());
        
        for (Integer i = 0; i < listAcc.size(); i++) {
            Account acc = listAcc[i];
            Address__c addr = listAddrs[i];
            system.assertEquals(acc.BillingStreet, addr.MailingStreet__c);
            system.assertEquals(acc.BillingCity, addr.MailingCity__c);
            system.assertNotEquals(null, acc.BillingStreet);
            system.assertNotEquals(null, acc.BillingCity);
            system.assertEquals(true, addr.Default_Address__c);
            system.assertEquals(addr.Id, acc.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Create Accounts when the setting for Address Mgmt is off. 
    verify:
        no Address objects created
        Account addresses set
    **********************************************************************************************************/            
    @isTest
    public static void testDisabledAddrAcc() {        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c (Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID()));

        listAccs = UTIL_UnitTestData_TEST.CreateMultipleTestAccounts(2, UTIL_Describe.getAdminAccRecTypeID());
        for (Account acc : listAccs) {
            acc.BillingStreet = 'new street';
            acc.BillingCity = 'new city';
        }

        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, is_Address_Override__c, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertEquals(null, acc.Current_Address__c);
        }
        
        // verify no address objects created
        list<Address__c> listAddr = [select Id from Address__c];
        system.assertEquals(0, listAddr.size());
    }
    
    /*********************************************************************************************************
    @description Update accounts' billing address fields to empty cause clearing the default address  
    verify:
        existing Default Address updated to be non-default
        no new Address created
    **********************************************************************************************************/            
    static testMethod void clearAddrExisting() {
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID(), 
                Accounts_Addresses_Enabled__c = UTIL_Describe.getAdminAccRecTypeID() + ';'));
                
        // this creates a default Address for each Account
        createTestDataAccs(4);

        // clear addresses fields directly
        for (integer i = 0; i < listAccs.size(); i++) {
            listAccs[i].BillingStreet = null;
            listAccs[i].BillingCity = null;
            listAccs[i].BillingState = null;
            listAccs[i].BillingPostalCode = null;
            listAccs[i].BillingCountry = null;
            if (ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled) {
                listAccs[i].put('BillingStateCode', null);
                listAccs[i].put('BillingCountryCode', null);
            }             
        }

        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update listAccs;
        Test.stopTest();
        
        // verify that no new address was created
        list<Address__c> listAddr = [select Default_Address__c from Address__c];
        system.assertEquals(4, listAddr.size());
        
        // verify existing Default Address updated to be non-default
        for (integer i = 0; i < listAddrs.size(); i++) {
            system.assertEquals(false, listAddrs[i].Default_Address__c);
        }              
    }
}