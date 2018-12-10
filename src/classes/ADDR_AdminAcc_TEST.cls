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
* @description Tests specific to Administrative Account Address Management. 
*/

@isTest
public with sharing class ADDR_AdminAcc_TEST {
    
    private static void configSettings() {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c(
            Accounts_Addresses_Enabled__c = UTIL_Describe_API.getAdminAccRecTypeID() + ';',
            Simple_Address_Change_Treated_as_Update__c = true);
        UTIL_CustomSettingsFacade.getSettingsForTests(hs);
    }
        
    /*********************************************************************************************************
    @description Update existing default Addresses.  
    verify: account billing address fields updated
    **********************************************************************************************************/            
    @isTest 
    public static void updateDefaultAddr() {
        configSettings();
        
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe_API.getAdminAccRecTypeID());
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
    @description Delete existing default Addresses.  
    verify: Account billing address fields cleared.
    **********************************************************************************************************/            
    @isTest 
    static void deleteDefaultAddr() {
        configSettings();
            
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe_API.getAdminAccRecTypeID());
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
    @description Delete existing non-default override Addresses.  
    verify: Account billing address fields not changed.
    **********************************************************************************************************/            
    @isTest
    static void deleteNonDefaultOverrideAddr() {
        configSettings();
        
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe_API.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;
        
        // create additional addresses
        addrs = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        
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
        configSettings();
        
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe_API.getAdminAccRecTypeID());
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
    @description Set account address override.  
    verify: account's address matches override
    **********************************************************************************************************/            
    @isTest
    public static void setAddrOverride() {
        configSettings();
        
        // this creates a default Address for the Account
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe_API.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;
        
        // create new non-default address
        Address__c addrNew = new Address__c();
        addrNew.MailingStreet__c = 'street override';
        addrNew.MailingCity__c = 'city override';
        addrNew.Default_Address__c = false;
        // assign it to the second account
        addrNew.Parent_Account__c = accsAddrs.accs[1].Id;
        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert addrNew;
        
        // set account's address current address
        accsAddrs.accs[1].Current_Address__c = addrNew.Id;
        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        update accsAddrs.accs[0];
    
        // now let's update the default Address for both accounts
        addrs[0].MailingStreet__c = 'New Street';
        addrs[0].MailingCity__c = 'New City';
        addrs[1].MailingStreet__c = 'New Street';
        addrs[1].MailingCity__c = 'New City';

        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update addrs;
        Test.stopTest();
        
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {         
            // verify that the Account address is new
            System.assert(acc.BillingStreet.contains('New Street'));
            System.assert(acc.BillingCity.contains('New City'));
            System.assertNotEquals(null, acc.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Insert new default addresses to Account w/ existing default addresses  
    verify:
        Account address matches new default
        old default addresses no longer marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewDefaultAddr() {
        configSettings();
          
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe_API.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;
        
        // create additional addresses
        addrs = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
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
        System.assertEquals(4, listAddr.size());
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
    @description Insert new default addresses to Account with existing default addresses, and then go back  
    verify:
        Account address matches original default
        new default addresses no longer marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewDefaultAddrAndReset() {
        configSettings();
        
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe_API.getAdminAccRecTypeID());
        List<Address__c> listAddrOriginal = accsAddrs.addrs;
        
        // create additional addresses
        ADDR_Addresses_TDTM.addressIdsInserted = new Set<Id>();
        List<Address__c> addrs = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            addrs[i].Parent_Account__c = accsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = true;
            addrs[i].MailingStreet__c = 'New Default Street' + i;
            addrs[i].MailingCity__c = 'New Default City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert addrs;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        
        // go back to original default addresses
        // added this extra set to test fix where we didn't use the correct default
        ADDR_Addresses_TDTM.addressIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            listAddrOriginal[i].Default_Address__c = true;
            listAddrOriginal[i].MailingStreet__c = 'Original Default Street' + i;
            listAddrOriginal[i].MailingCity__c = 'Original Default City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update listAddrOriginal;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();
        
        // verify the additional addresses got Default cleared.
        // and verify latest start date and latest end date appropriately set.
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, 
        Latest_End_Date__c from Address__c];
        System.assertEquals(4, listAddr.size());
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
    @description Update contacts' mailing address to cause creation of new default Address object.  
    verify:
        new Default Address created
        Accounts get new Address
    **********************************************************************************************************/            
    @isTest
    public static void updateAddrNew() {
        configSettings();
         
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(4, UTIL_Describe_API.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;
        
        // modify some of the Account addresses directly
        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = 'Direct Street Edit';
            accsAddrs.accs[i].BillingCity = 'Direct City Edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        update accsAddrs.accs;

        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = 'another Street Edit';
            accsAddrs.accs[i].BillingCity = 'another City Edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        update accsAddrs.accs;

        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = 'final Street Edit';
            accsAddrs.accs[i].BillingCity = 'final City Edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update accsAddrs.accs;
        Test.stopTest();
        
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            System.assert(acc.BillingStreet.contains('final Street Edit'));
            System.assert(acc.BillingCity.contains('final City Edit'));
            System.assertNotEquals(null, acc.Current_Address__c);
        }
 
         // verify the previous addresses got Default cleared.
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        // each set of edits created a new address object 
        System.assertEquals(16, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fNewDefault = (addr.MailingStreet__c.contains('final Street Edit'));
            System.assertEquals(fNewDefault, addr.Default_Address__c);
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
    public static void updateAddrMarkOverride() {
        configSettings();
             
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe_API.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;
        
        // modify the account addresses directly
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = 'Direct Street Edit';
            accsAddrs.accs[i].BillingCity = 'Direct City Edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update accsAddrs.accs;
        Test.stopTest();
        
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c from Account]);
        
        System.assertEquals('Direct Street Edit', mapAccIdAcc.values()[0].BillingStreet);
        System.assertEquals('Direct City Edit', mapAccIdAcc.values()[0].BillingCity);
        System.assertEquals('Direct Street Edit', mapAccIdAcc.values()[1].BillingStreet);
        System.assertEquals('Direct City Edit', mapAccIdAcc.values()[1].BillingCity);
 
         // verify the previous addresses didn't get Default cleared.
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        System.assertEquals(4, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean isNewEdit = (addr.MailingStreet__c.contains('Direct Street Edit'));
            if(isNewEdit) {
                System.assertNotEquals(false, addr.Default_Address__c);
            }
        }
    }

    /*********************************************************************************************************
    @description Update Account's billing address with just a case change, to cause an update to default Address object  
    verify:
        existing Default Address updated
        Account has updated Address
    **********************************************************************************************************/            
    @isTest
    public static void updateAddrExistingCaseOnly() {
        configSettings();
        
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe_API.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;
        
        // modify some of the account addresses directly
        // NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = 'Direct Street Edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();
        update accsAddrs.accs;

        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingState = 'Washington';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();    
        update accsAddrs.accs;

        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = ' direct street  edit ';  // whitespace and casing should not count as a real edit.
            accsAddrs.accs[i].BillingState = 'Oregon';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();    
        update accsAddrs.accs;

        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();    
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = ' DIRECT STREET  EDIT ';  // only change casing.
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update accsAddrs.accs;
        Test.stopTest();
        
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            System.assert(acc.BillingStreet.equals('DIRECT STREET  EDIT'));
            System.assertNotEquals(null, acc.Current_Address__c);
        }
 
        // verify that no new address was created
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        System.assertEquals(2, listAddr.size());
        for (Address__c addr : listAddr) {
            System.assert(addr.MailingStreet__c.equals('DIRECT STREET  EDIT'));
        }
        
        // now test that changing the case from the account updates all addresses
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            Account acc = accsAddrs.accs[i];
            acc.BillingStreet = 'direct street  edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();    
        update accsAddrs.accs;
        
        // verify that the Account address
        mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            System.assert(acc.BillingStreet.equals('direct street  edit'));
            System.assertNotEquals(null, acc.Current_Address__c);
        }
 
        // verify that no new address was created
        listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        System.assertEquals(2, listAddr.size());
        for (Address__c addr : listAddr) {
            System.assert(addr.MailingStreet__c.equals('direct street  edit'));
        }                   
    }

    /*********************************************************************************************************
    @description Update accounts' billing address to cause an update of the default Address object.  
    verify:
        existing Default Address updated
        Account get updated Address
    **********************************************************************************************************/            
    @isTest
    public static void updateAddrExisting() {
        configSettings();
        
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe_API.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;
        
        // modify some of the account addresses directly
        // NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = 'Direct Street Edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        update accsAddrs.accs;

        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingState = 'Washington';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        update accsAddrs.accs;

        ADDR_Account_TDTM.accountIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = ' direct street  edit ';    // whitespace and casing should not count as real edit.
            accsAddrs.accs[i].BillingState = 'Oregon';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update accsAddrs.accs;
        Test.stopTest();
        
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            System.assert(acc.BillingStreet.contains('direct street  edit'));
            System.assert(acc.BillingState.contains('Oregon')); 
            System.assertNotEquals(null, acc.Current_Address__c);
        }
 
        // verify that no new address was created
        List<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        System.assertEquals(2, listAddr.size());
        for (Address__c addr : listAddr) {
            System.assertEquals('direct street  edit', addr.MailingStreet__c);
        }        
    }

    /*********************************************************************************************************
    @description Create an Address with no Account 
    verify: runtime error
    **********************************************************************************************************/            
    @isTest
    public static void newAddrNoParent() {
        configSettings();
        
        List<Address__c> addrs = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        for (Integer i = 0; i < addrs.size(); i++) {
            System.assertEquals(null, addrs[i].Parent_Account__c);
        }
        
        try {
            insert addrs;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(Label.addrValidParentObjects));
            return;
        }
        System.assert(false); //we shouldn't get here!
    }
 
    /*********************************************************************************************************
    @description Create N new duplicate Addresses from Account  
    verify:
        duplicates not created
    **********************************************************************************************************/            
    @isTest
    public static void newDupeAddr() {
        configSettings();
         
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe_API.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;
        
        // create additional addresses thru the account.
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = addrs[i].MailingStreet__c;
            accsAddrs.accs[i].BillingCity = addrs[i].MailingCity__c;
            accsAddrs.accs[i].BillingState = addrs[i].MailingState__c;
            accsAddrs.accs[i].BillingPostalCode = addrs[i].MailingPostalCode__c;
            accsAddrs.accs[i].BillingCountry = addrs[i].MailingCountry__c;
        }        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update accsAddrs.accs;
        Test.stopTest();
        
        // verify that we don't have new Addresses
        List<Address__c> listAddr = [select Id from Address__c];
        System.assertEquals(2, listAddr.size());
    }

    /*********************************************************************************************************
    @description Create N new duplicate Addresses from Account, with non-default existing  
    verify:
        duplicates not created
        found match becomes Default
    **********************************************************************************************************/            
    @isTest
    public static void newDupeAddrNonDefault() {
        configSettings();
        
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe_API.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;
        
        // create additional non-default addresses
        addrs = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            addrs[i].Parent_Account__c = accsAddrs.accs[i].Id;
            addrs[i].Default_Address__c = false;
            addrs[i].MailingStreet__c = 'New Street' + i;
            addrs[i].MailingCity__c = 'New City' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert addrs;
 
        // create additional addresses thru the account.
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = addrs[i].MailingStreet__c;
            accsAddrs.accs[i].BillingCity = addrs[i].MailingCity__c;
            accsAddrs.accs[i].BillingState = addrs[i].MailingState__c;
            accsAddrs.accs[i].BillingPostalCode = addrs[i].MailingPostalCode__c;
            accsAddrs.accs[i].BillingCountry = addrs[i].MailingCountry__c;
        }        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update accsAddrs.accs;
        Test.stopTest();
        
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            System.assert(acc.BillingStreet.contains('New Street'));
            System.assert(acc.BillingCity.contains('New City'));
            System.assertNotEquals(null, acc.Current_Address__c);
        }
        
        // verify the new addresses still are Default and we don't have too many
        List<Address__c> allAddrs = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, 
        Latest_End_Date__c from Address__c];
        UTIL_Debug.debug('***newDupeAddrNonDefault all addresses: ' + JSON.serializePretty(allAddrs));
        System.assertEquals(2 * 2, allAddrs.size());
        for (Address__c addr : allAddrs) {
            boolean isNew = (addr.MailingStreet__c.contains('New Street'));
            System.assertEquals(isNew, addr.Default_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Insert account w/ multiline street address
    verify: new default Address created and the street address is broken up into street and street2
    **********************************************************************************************************/            
    @isTest
    public static void insertMultilineStreetAddress() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Accounts_Addresses_Enabled__c = 
                                                                    UTIL_Describe_API.getAdminAccRecTypeID() + ';'));
    
        List<Account> accs = UTIL_UnitTestData_API.getMultipleTestAccounts(2, UTIL_Describe_API.getAdminAccRecTypeID());
        for (Account acc : accs) {
            acc.BillingStreet = 'new street\r\nsecond line';
            acc.BillingCity = 'new city';
        }
        Test.startTest();
        insert accs; 
        Test.stopTest();       
        
        // verify the Address objects split street.
        List<Address__c> listAddr = [select Id, MailingStreet__c, MailingStreet2__c, Formula_MailingStreetAddress__c from Address__c];
        System.assertEquals(2, listAddr.size());
        for (Address__c addr : listAddr) {
            System.assertEquals('new street', addr.MailingStreet__c);
            System.assertEquals('second line', addr.MailingStreet2__c);
            System.assertEquals('new street<br>second line<br>new city,', addr.Formula_MailingStreetAddress__c);
        }

        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            System.assertEquals('new street\r\nsecond line', acc.BillingStreet);
            System.assertNotEquals(null, acc.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Insert new default multiline street addresses w/ existing default addresses  
    verify:
        Account address matches new default
        street & street2 combined into contact and account single street field
    **********************************************************************************************************/            
    @isTest
    public static void insertNewDefaultMultilineStreetAddr() {
        configSettings();
             
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe_API.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;
        
        // create additional addresses
        addrs = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            addrs[i].Parent_Account__c = accsAddrs.accs[i].Id;
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

        // verify Account address is new
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            System.assertEquals('New Default Street\r\nSecond Line', acc.BillingStreet);
            System.assertEquals('New Default Street\r\nSecond Line', acc.BillingStreet);
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
    public static void updateMultilineStreetAddr() {
        configSettings();
        
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(2, UTIL_Describe_API.getAdminAccRecTypeID());
        List<Address__c> addrs = accsAddrs.addrs;
        
        // modify some of the account addresses directly
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            Account acc = accsAddrs.accs[i];
            acc.BillingStreet = 'Direct Street Edit\r\nSecond Line';
            acc.BillingCity = 'Direct City Edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update accsAddrs.accs;
        Test.stopTest();
        
        // verify Account address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            System.assertEquals('Direct Street Edit\r\nSecond Line', acc.BillingStreet);
            System.assertEquals('Direct Street Edit\r\nSecond Line', acc.BillingStreet);
            System.assertNotEquals(null, acc.Current_Address__c);
        }
 
        // verify the Address objects split street.
        List<Address__c> listAddr = [select Id, MailingStreet__c, MailingStreet2__c, Formula_MailingStreetAddress__c, Default_Address__c from Address__c];
        for (Address__c addr : listAddr) {
            if (addr.Default_Address__c) {
                System.assertEquals('Direct Street Edit', addr.MailingStreet__c);
                System.assertEquals('Second Line', addr.MailingStreet2__c);
                System.assertEquals('Direct Street Edit<br>Second Line<br>Direct City Edit, Washington Zip0<br>United States', addr.Formula_MailingStreetAddress__c);
            }
        }
    }
    
    /*********************************************************************************************************
    @description Update accounts' billing address fields to empty cause clearing the default address  
    verify:
        existing Default Address updated to be non-default
        no new Address created
    **********************************************************************************************************/            
    static testMethod void clearAddrExisting() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Accounts_Addresses_Enabled__c = 
                                                                    UTIL_Describe_API.getAdminAccRecTypeID() + ';'));
                
        // this creates a default Address for each Account
        UTIL_UnitTestData_TEST.AccsWithAddrs accsAddrs = UTIL_UnitTestData_TEST.createTestAccsAddrs(4, UTIL_Describe_API.getAdminAccRecTypeID());
        UTIL_Debug.debug('****accsAddrs: ' + JSON.serializePretty(accsAddrs));
        List<Address__c> addrs = accsAddrs.addrs;
        
        // clear addresses fields directly
        for (Integer i = 0; i < accsAddrs.accs.size(); i++) {
            accsAddrs.accs[i].BillingStreet = null;
            accsAddrs.accs[i].BillingCity = null;
            accsAddrs.accs[i].BillingState = null;
            accsAddrs.accs[i].BillingPostalCode = null;
            accsAddrs.accs[i].BillingCountry = null;
            if (ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled) {
                accsAddrs.accs[i].put('BillingStateCode', null);
                accsAddrs.accs[i].put('BillingCountryCode', null);
            }             
        }

        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update accsAddrs.accs;
        Test.stopTest();
        
        // verify that no new address was created
        addrs = [select Default_Address__c from Address__c];
        System.assertEquals(4, addrs.size());
        
        // verify existing Default Address updated to be non-default
        for (Integer i = 0; i < addrs.size(); i++) {
            System.assertEquals(false, addrs[i].Default_Address__c);
        }              
    }
}