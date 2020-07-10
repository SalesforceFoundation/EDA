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
    private static Id householdRecTypeID = UTIL_Describe_API.getHhAccRecTypeID();
    
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
    * - Contact's mailing fields are updated.plea
    * - Household Account's billing address fields are updated. 
    * - Address records are created. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNewHHAccAndCon() {
        configSettings();
        
        //Tests that the helper method is properly written
        Test.startTest();
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        Test.stopTest();
        
        //Verify that the Household Account and Contacts share the same address
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, BillingCity, 
                                                                Billing_County__c,BillingState, BillingPostalCode, 
                                                                BillingCountry, BillingLatitude, BillingLongitude 
                                                                FROM Account]);
        
        List<Contact> contactList = [SELECT Id, Name, AccountId, 
                                        is_Address_Override__c, Current_Address__c, MailingStreet, 
                                        MailingCity, Mailing_County__c,MailingState, 
                                        MailingPostalCode, MailingCountry, MailingLatitude, 
                                        MailingLongitude 
                                        FROM Contact];        
        for (Contact con : contactList) {
            Account acc = accountsById.get(con.AccountId);
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
    * - Address record is created and is marked as default. 
    * - Address record is associated to the Household Account but not the Contact record. 
    **********************************************************************************************************/      
    @isTest
    private static void insertNewContactWithMailingFields() {
        configSettings();
        
        Contact con = UTIL_UnitTestData_TEST.getContact(); 
        con.MailingStreet = '123 Main St';
        con.MailingCity = 'Chicago';
        con.Mailing_County__c = 'Bergen'; 
        Test.startTest();
        insert con;
        Test.stopTest();
        
        List<Account> accountList = [SELECT Id, BillingStreet, BillingCity , Billing_County__c
                                        FROM Account];
        System.assertEquals(1, accountList.size());
        System.assertEquals('123 Main St', accountList[0].BillingStreet);
        System.assertEquals('Chicago', accountList[0].BillingCity);
        System.assertEquals('Bergen', accountList[0].Billing_County__c);
        
        List<Address__c> addrList = [SELECT Id, Parent_Account__c, Parent_Contact__c, 
                                        Default_Address__c, MailingStreet__c, MailingCity__c,
                                        MailingCounty__c
                                        FROM Address__c];
        System.assertEquals(1, addrList.size());
        System.assertEquals(accountList[0].Id, addrList[0].Parent_Account__c);
        System.assertEquals(Null, addrList[0].Parent_Contact__c);
        System.assertEquals('123 Main St', addrList[0].MailingStreet__c);
        System.assertEquals('Chicago', addrList[0].MailingCity__c);
        System.assertEquals('Bergen', addrList[0].MailingCounty__c);
        System.assertEquals(True, addrList[0].Default_Address__c);
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
    private static void insertContactWithMailingFieldsToExistingHHAccount() {
        configSettings();
            
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());

        List<Contact> contactList = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = New Contact();
            con.AccountId = consAccsAddrs.accs[i].Id;
            con.LastName = 'Testerson';
            con.MailingStreet = 'new street';
            con.MailingCity = 'new city';
            con.Mailing_County__c = 'new county';
            contactList.add(con);
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert contactList;
        Test.stopTest();      
        
        //Verify that the Household Account and Contacts share the same address
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState,
                                                                BillingPostalCode, BillingCountry, BillingLatitude,
                                                                BillingLongitude
                                                                FROM Account]);
        List<Contact> returnContactList = [SELECT Id, AccountId, is_Address_Override__c, 
                                            Current_Address__c, MailingStreet, MailingCity, 
                                            Mailing_County__c, MailingState, MailingPostalCode,
                                            MailingCountry, MailingLatitude, MailingLongitude
                                            FROM Contact];
        for (Contact con : returnContactList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
            System.assertEquals('new street', con.MailingStreet);
            System.assertEquals('new city', con.MailingCity);
            System.assertEquals('new county', con.Mailing_County__c);
        }
        
        List<Address__c> addrList = [SELECT Id, MailingStreet__c, Default_Address__c
                                        FROM Address__c]; 
        for (Address__c address : addrList) {
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
    * - Existing Contact's mailing fields are not updated with the newly created non default Address record.
    * - Household Account's billing fields are not updated with the newly created non default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void insertContactWithMailingFieldsOverrideToExistingHHAccount() {
        configSettings();
                        
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        List<Contact> contactList = new List<Contact>();
        for (Integer i = 0; i<2; i++) {
            Contact con = new Contact();
            con.LastName = 'Testerson';
            con.AccountId = consAccsAddrs.accs[i].Id;
            con.MailingStreet = 'new street' + i;
            con.MailingCity = 'new city' + i;
            con.Mailing_County__c = 'new county' + i;
            con.is_Address_Override__c = True;
            contactList.add(con);
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert contactList;
        Test.stopTest();    

        //Verify that the Household and Contacts share the same address
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude, Current_Address__c
                                                                FROM Account]);
        List<Contact> returnContactList = [SELECT Id, Name, AccountId, 
                                                is_Address_Override__c, Current_Address__c, MailingStreet, 
                                                MailingCity, Mailing_County__c, MailingState, 
                                                MailingPostalCode, MailingCountry, MailingLatitude, 
                                                MailingLongitude 
                                                FROM Contact];
        List<Address__c> addrList = [SELECT Default_Address__c, MailingStreet__c, MailingCity__c 
                                        FROM Address__c];
        System.assertEquals(4, addrList.size());
        for (Address__c addr : addrList) {
            if (addr.MailingStreet__c.contains('new street')) {
                System.assertEquals(False, addr.Default_Address__c); 
            }
        }
        
        for (Contact con : returnContactList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertNotEquals(Null, con.Current_Address__c);
            System.assertNotEquals(Null, accountsById.get(con.AccountId).Current_Address__c); 
            
            if (con.is_Address_Override__c) {
                System.assertEquals(False, isMatchAddressAccCon(acc, con));
            } else {
                System.assertEquals(True, isMatchAddressAccCon(acc, con));               
            }
        }
    }
        
    /*********************************************************************************************************
    @description Update existing default Address record mailing fields. 
    * Verify:
    * - No new Address record is created. 
    * - Household Account's billing fields are updated.
    * - Contact's mailing fields are updated. 
    **********************************************************************************************************/            
    @isTest 
    private static void updateDefaultAddressMailingFields() {
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

        //Verify that the Household Account and Contacts share the same address
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude
                                                                FROM Account]);
        List<Contact> contactList = [SELECT Id, Name, AccountId, 
                                        is_Address_Override__c, Current_Address__c, MailingStreet, 
                                        MailingCity, Mailing_County__c, MailingState, 
                                        MailingPostalCode, MailingCountry, MailingLatitude, 
                                        MailingLongitude 
                                        FROM Contact];
        System.assertEquals(4, contactList.size());
        for (Contact con : contactList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Street'));
            System.assert(con.MailingCity.contains('New City'));
            System.assert(con.Mailing_County__c.contains('New County'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
        
        List<Address__c> addrList = [SELECT Id, Default_Address__c
                                        FROM Address__c]; 
        System.assertEquals(2, addrList.size()); 
        for (Address__c addr : addrList) {
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
    private static void deleteDefaultAddressOnExistingHHAccount() {
        configSettings();

        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        delete consAccsAddrs.addrs;
        Test.stopTest();

        //Verify that the Household Account and Contacts' address fields are cleared
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        List<Contact> contactList = [SELECT Id, Name, AccountId, 
                                        is_Address_Override__c, Current_Address__c, MailingStreet, 
                                        MailingCity, Mailing_County__c, MailingState, 
                                        MailingPostalCode, MailingCountry, MailingLatitude, 
                                        MailingLongitude 
                                        FROM Contact];
        System.assertEquals(4, contactList.size());
        for (Contact con : contactList) {
            Account acc = accountsById.get(con.AccountId);
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
    * - Household Account's billing fields are not updated with the non default Address record. 
    * - Existing Contact whose is_Address_Override__c is disabled, mailing fields are not updated. 
    * - For the Contact whose is_Address_Override__c is enabled, its mailing fields are updated to match the mailing
    * fields from the non default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void deleteNonDefaultAddressAssociatedToOverrideContactOnHHAccount() {
        configSettings();
            
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        System.assertEquals(4, consAccsAddrs.contacts.size()); 
        
        List<Address__c> addrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (integer i = 0; i < 2; i++) {
            addrList[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrList[i].Default_Address__c = False;
            addrList[i].MailingStreet__c = 'override' + i;
            addrList[i].MailingCity__c = 'override' + i;
            addrList[i].MailingCounty__c = 'override' + i;
        }
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        insert addrList;
        
        //Set the Contacts' address overrides - one Contact per household
        List<Contact> conList = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.Current_Address__c = addrList[i].Id;
            con.is_Address_Override__c = True;
            ADDR_Addresses_UTIL.copyAddressAddrSObj(addrList[i], con, 'Mailing', 'Primary_Address_Type__c', Null);
            conList.add(con);
        }
        update conList;      
        
        for (Contact contact : conList) {
            System.assert(contact.MailingStreet.contains('override')); 
        }
        
        //Delete the non default Addresses recently created
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        delete addrList;
        Test.stopTest();

        //Verify that the Household Account and Contacts' address fields are set as the original default address values 
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        conList = [SELECT Id, Name, AccountId, 
                        is_Address_Override__c, Current_Address__c, MailingStreet, 
                        MailingCity, Mailing_County__c, MailingState, 
                        MailingPostalCode, MailingCountry, MailingLatitude, 
                        MailingLongitude
                        FROM Contact];
        System.assertEquals(4, conList.size());
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            if (con.is_Address_Override__c) {
                System.assertEquals(False, isMatchAddressAccCon(acc, con));
                System.assert(!con.MailingStreet.contains('Street'));
            } else {
                System.assertEquals(True, isMatchAddressAccCon(acc, con));
                System.assertEquals(False, con.is_Address_Override__c);
                System.assertNotEquals(Null, con.Current_Address__c);
                System.assert(con.MailingStreet.contains('Street'));
                System.assert(con.MailingCity.contains('City'));  
                System.assert(con.Mailing_County__c.contains('County'));  
            }  
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
    private static void updateDefaultAddressToNonDefaultOnExistingHHAccount() {
        configSettings();

        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        for (Integer i = 0; i < 2; i++) {
            Address__c addr = consAccsAddrs.addrs[i];
            addr.Default_Address__c = False;
        }
        Test.startTest();
        update consAccsAddrs.addrs;
        Test.stopTest();

        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 	
                                                                FROM Account
                                                                WHERE Id IN :consAccsAddrs.accs]);

        List<Contact> contactList = [SELECT Id, Name, AccountId, 
                                        is_Address_Override__c, Current_Address__c, MailingStreet, 
                                        MailingCity, Mailing_County__c, MailingState, 
                                        MailingPostalCode, MailingCountry, MailingLatitude, 
                                        MailingLongitude 
                                        FROM Contact];
        System.assertEquals(4, contactList.size());
        for (Contact con : contactList) {
            Account acc = accountsById.get(con.AccountId);
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
    * - Contact record whose is_Address_Override__c is disabled, will have their mailing fields updated based on the
    * newest mailing fields update from the default Address record.
    * - Contact record whose is_Address_Override__c is enabled, will not have their mailing fields updated based on the
    * newest mailing fields update from the default Address record. 
    * - Household Account's billing fields will be updated based on the newest mailing field update from the default
    * Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void setContactOverrideAndUpdateExistingDefaultAddress() {
        configSettings();
                
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        List<Address__c> newAddrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1); 
        for (Address__c newAddr : newAddrList) {
            newAddr.MailingStreet__c = 'street override';
            newAddr.MailingCity__c = 'city override';
            newAddr.Default_Address__c = False;
            newAddr.Parent_Account__c = consAccsAddrs.accs[0].Id;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert newAddrList;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        
        //Set a Contact's address override 
        consAccsAddrs.contacts[0].Current_Address__c = newAddrList[0].Id;
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

        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        List<Contact> conList = [SELECT Id, Name, AccountId, 
                                    is_Address_Override__c, Current_Address__c, MailingStreet, 
                                    MailingCity, Mailing_County__c, MailingState, 
                                    MailingPostalCode, MailingCountry, MailingLatitude, 
                                    MailingLongitude 
                                    FROM Contact];
        System.assertEquals(4, conList.size());
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            if (con.is_Address_Override__c) {
                System.assertEquals(con.Current_Address__c, newAddrList[0].Id);
                System.assertEquals(False, isMatchAddressAccCon(acc, con));
                System.assert(!con.MailingStreet.contains('New Street'));
                System.assert(!con.MailingCity.contains('New City'));  
                System.assert(con.MailingStreet.contains('street override'));
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
    * - Contact record who is associated to the new non default Address record should have its mailing fields
    * updated to match the mailing fields from the non default Address record. 
    * - Contact record who is assocaited to the new non default Address record's mailing fields should not
    * match the billing fields on the Household Account. 
    * - Household Account's billing fields should not be updated and still be the original default Address. 
    **********************************************************************************************************/            
    @isTest
    private static void setContactNoOverride() {
        configSettings();
                
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());

        List<Address__c> addrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrList[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrList[i].Default_Address__c = False;
            addrList[i].MailingStreet__c = 'not override' + i;
            addrList[i].MailingCity__c = 'not override' + i;
        }
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        insert addrList;

        List<Contact> conList = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.Current_Address__c = addrList[i].Id;
            con.is_Address_Override__c = False;
            conList.add(con);
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update conList;
        Test.stopTest();
        
        //Verify that the HH and Contacts share the same address, except for the contacts we modified
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        conList = [SELECT Id, Name, AccountId, 
                    is_Address_Override__c, Current_Address__c, Current_Address__r.Default_Address__c, 
                    MailingStreet, MailingCity, Mailing_County__c, 
                    MailingState, MailingPostalCode, MailingCountry, 
                    MailingLatitude, MailingLongitude 
                    FROM Contact];
        
        Integer numOfConNotOverride = 0;
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            if (con.MailingStreet.contains('not override') == True) {
                numOfConNotOverride++;
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
        System.assertEquals(2, numOfConNotOverride);
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
    private static void insertNewDefaultAddressOnExistingHHAccount() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        List<Address__c> returnAddrList = [SELECT Id 
                                            FROM Address__c];
        
        List<Address__c> addrsList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrsList[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrsList[i].Default_Address__c = True;
            addrsList[i].MailingStreet__c = 'New Default Street' + i;
            addrsList[i].MailingCity__c = 'New Default City' + i;
            addrsList[i].MailingCounty__c = 'New Default County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert addrsList;
        Test.stopTest();

        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        List<Contact> conList = [SELECT Id, Name, AccountId, 
                                    is_Address_Override__c, Current_Address__c, MailingStreet, 
                                    MailingCity, Mailing_County__c, MailingState, 
                                    MailingPostalCode, MailingCountry, MailingLatitude, 
                                    MailingLongitude 
                                    FROM Contact];
        System.assertEquals(4, conList.size());
        
        //Verify that the Household Account and Contacts share the same address and 
        //its mailing fields matches the newly created default Address record 
        returnAddrList = [SELECT Id 
                            FROM Address__c];
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Default Street'));
            System.assert(con.MailingCity.contains('New Default City'));
            System.assert(con.Mailing_County__c.contains('New Default County'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
        
        //Verify the previous Address record's default is cleared
        //And verify latest start date and latest end date fields are appropriately set 
        returnAddrList = [SELECT Id, Default_Address__c, MailingStreet__c,
                            Latest_Start_Date__c, Latest_End_Date__c 
                            FROM Address__c];
        System.assertEquals(4, returnAddrList.size());
        for (Address__c addr : returnAddrList) {
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
    @description Create new default Address record to an existing Household Account with existing default Address 
    * record. Update previous default Address record's mailing fields and mark it as the default Address record.
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
    private static void insertNewDefaultAddressAndResetPreviousDefaultAddress() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        List<Address__c> originalAddList = consAccsAddrs.addrs;
        
        ADDR_Addresses_TDTM.addressIdsInserted = new Set<Id>();
        List<Address__c> newAddrsList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            newAddrsList[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            newAddrsList[i].Default_Address__c = True;
            newAddrsList[i].MailingStreet__c = 'New Default Street' + i;
            newAddrsList[i].MailingCity__c = 'New Default City' + i;
            newAddrsList[i].MailingCounty__c = 'New Default County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert newAddrsList;

            ADDR_Addresses_TDTM.addressIdsUpdated = new Set<Id>();       
        //Update original default Address record
        //added this extra set to test fix where we didn't use the correct default
        for (Integer i = 0; i < 2; i++) {
            originalAddList[i].Default_Address__c = True;
            originalAddList[i].MailingStreet__c = 'Original Default Street' + i;
            originalAddList[i].MailingCity__c = 'Original Default City' + i;
            originalAddList[i].MailingCounty__c = 'Original Default County' + i;
        }
        Test.startTest();
        update originalAddList;
        Test.stopTest();

        //Verify that the Househodl Account and Contacts share the same address and it's new!
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        List<Contact> conList = [SELECT Id, Name, AccountId, 
                                    is_Address_Override__c, Current_Address__c, MailingStreet, 
                                    MailingCity, Mailing_County__c, MailingState, 
                                    MailingPostalCode, MailingCountry, MailingLatitude, 
                                    MailingLongitude 
                                    FROM Contact];
        System.assertEquals(4, conList.size());
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('Original Default Street'));
            System.assert(con.MailingCity.contains('Original Default City'));
            System.assert(con.Mailing_County__c.contains('Original Default County'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
        
        //Verify the previous default Address record is no longer the default Address record 
        //and verify latest start date and latest end date are appropriately set.
        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                        Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c 
                                        FROM Address__c];
        System.assertEquals(4, addrList.size());
        for (Address__c addr : addrList) {
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
    @description Create a non default Address record. Set a Contact's is_Address_Override__c to True. 
    * Verify:
    * - New non default Address record is created.
    * - If a Contact's is_Address_Override__c enabled, then the Contact's mailing fields is updated to match the 
    * mailing fields from the newly created non default Address record. 
    * - If a Contact's is_Address_Override__c disabled, then the Contact's mailing fields is not updated to match 
    * the mailing fields from the newly created non default Address record. 
    * - The Latest_Start_Date__c on the newly created non Address record is set. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNonDefaultAddressToAnOverrideContactOnHHAccount() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());

        List<Address__c> newAddrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            newAddrList[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            newAddrList[i].Default_Address__c = False;
            newAddrList[i].MailingStreet__c = 'override' + i;
            newAddrList[i].MailingCity__c = 'override' + i;
            newAddrList[i].MailingCounty__c = 'override' + i;
        }
        insert newAddrList;
        
        //Set the Contacts' address overrides
        List<Contact> conList = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.Current_Address__c = newAddrList[i].Id;
            con.is_Address_Override__c = True;
            conList.add(con);
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update conList;
        Test.stopTest();
        
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        conList = [SELECT Id, Name, AccountId, 
                        is_Address_Override__c, Current_Address__c, MailingStreet, 
                        MailingCity, Mailing_County__c, MailingState, 
                        MailingPostalCode, MailingCountry, MailingLatitude,
                        MailingLongitude 
                        FROM Contact];
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
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
        List<Address__c> addrList = [SELECT Id, Latest_Start_Date__c, Latest_End_Date__c 
                                        FROM Address__c 
                                        WHERE Id IN :newAddrList];
        System.assertEquals(2, addrList.size());
        for (Address__c addr : addrList) {
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
    * - Both Latest_Start_Date__c and Latest_End_Date__c are populated on the non default Address record 
    * because is_Address_Override__c was set and reset. 
    **********************************************************************************************************/            
    @isTest
    private static void disableOverrideOnContact() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());

        List<Address__c> newAddrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            newAddrList[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            newAddrList[i].Default_Address__c = False;
            newAddrList[i].MailingStreet__c = 'override' + i;
            newAddrList[i].MailingCity__c = 'override' + i;
            newAddrList[i].Latest_Start_Date__c = System.today();
        }
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        insert newAddrList;
        
        //Set the Contact's address overrides - one contact in each account
        List<Contact> conList = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.Current_Address__c = newAddrList[i].Id;
            con.is_Address_Override__c = True;
            ADDR_Addresses_UTIL.copyAddressAddrSObj(newAddrList[i], con, 'Mailing', 'Primary_Address_Type__c', null);
            conList.add(con);
        }
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        update conList;

        List<Contact> allConList = [SELECT Id, Name, AccountId, 
                                        is_Address_Override__c, Current_Address__c, MailingStreet, 
                                        MailingCity, Mailing_County__c, MailingState, 
                                        MailingPostalCode, MailingCountry, MailingLatitude, 
                                        MailingLongitude 
                                        FROM Contact];
        //Clear out the Contact's address overrides
        for (Contact con : conList) {
            con.is_Address_Override__c = False;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update conList;
        Test.stopTest();
        
        //Verify that the HH and Contacts share the same address
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        allConList = [SELECT Id, Name, AccountId, 
                        is_Address_Override__c, Current_Address__c, MailingStreet, 
                        MailingCity, Mailing_County__c,  MailingState, 
                        MailingPostalCode, MailingCountry, MailingLatitude, 
                        MailingLongitude 
                        FROM Contact];
        for (Contact con : allConList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('Street'));
            System.assert(con.MailingCity.contains('City'));
        }

        //Verify address overrides have latest start date and latest end date appropriately set.
        List<Address__c> addrList = [SELECT Id, Latest_Start_Date__c, Latest_End_Date__c 
                                        FROM Address__c 
                                        WHERE Id IN :newAddrList];
        System.assertEquals(2, addrList.size());
        for (Address__c addr : addrList) {
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
    private static void updateContactMailingFields() {
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
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        List<Contact> conList = [SELECT Id, Name, AccountId, 
                                    is_Address_Override__c, Current_Address__c, MailingStreet, 
                                    MailingCity, Mailing_County__c, MailingState, 
                                    MailingPostalCode, MailingCountry, MailingLatitude, 
                                    MailingLongitude 
                                    FROM Contact];
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('final Street Edit'));
            System.assert(con.MailingCity.contains('final City Edit'));
            System.assert(con.Mailing_County__c.contains('final County Edit'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }

        //Verify the previous addresses got Default cleared.
        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c, Parent_Account__c 
                                        FROM Address__c];
        //Each set of edits created a new address object 
        System.assertEquals(4, addrList.size());
        for (Address__c addr : addrList) {
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
    * - Contact whose is_Address_Override__c is disbaled, will not have its mailing fields updated.
    * - Contact whose is_Address_Override__c is enabled, will have its mailing fields updated to match the newly
    * created non default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void updateContactOverrideAndMailingFields() {
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
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        List<Contact> conList = [SELECT Id, Name, AccountId, 
                                    is_Address_Override__c, Current_Address__c, MailingStreet, 
                                    MailingCity, Mailing_County__c, MailingState, 
                                    MailingPostalCode, MailingCountry, MailingLatitude, 
                                    MailingLongitude 
                                    FROM Contact];
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            if (con.is_Address_Override__c) {
                System.assertEquals(False, isMatchAddressAccCon(acc, con));
                System.assertEquals(True, con.MailingStreet.contains('Direct Street Edit'));
                System.assertEquals(True, con.MailingCity.contains('Direct City Edit'));
                System.assertEquals(True, con.Mailing_County__c.contains('Direct County Edit'));
                System.assertEquals(False, acc.BillingStreet.contains('Direct Street Edit'));
                System.assertEquals(False, acc.BillingCity.contains('Direct City Edit'));
                System.assertEquals(False, acc.Billing_County__c.contains('Direct County Edit'));
                System.assertNotEquals(Null, con.Current_Address__c);
            } else {
                System.assertEquals(True, isMatchAddressAccCon(acc, con));
            }
        }

        //Verify the previous addresses got Default cleared.
        List<Address__c> listAddr = [SELECT Id, Default_Address__c, MailingStreet__c, Parent_Account__c 
                                        FROM Address__c];
        System.assertEquals(6, listAddr.size());
        for (Address__c addr : listAddr) {
            if (addr.MailingStreet__c.contains('Direct Street Edit')) {
                System.assertEquals(False, addr.Default_Address__c);
            }
        }                
    }

    /*********************************************************************************************************
    @description Update Contact's mailing fields - format only or single mailing fields. 
    * Verify:
    * - Existing default Address record's mailing fields are updated.
    * - No new Address record is created. 
    * - Household Account and Contact's billing/mailing fields are updated. 
    **********************************************************************************************************/            
    @isTest
    private static void updateContactMailingFieldsForSimpleAddressChangeTreatedAsUpdate() {
        configSettings();
            
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        //NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
        List<Contact> conList = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.MailingStreet = 'Direct Street Edit';
            conList.add(con);
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        update conList;
        
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.Mailing_County__c = 'bergen';
        }
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        update conList;
        
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.MailingState = 'Washington';
        }
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        update conList;
        
        //Whitespace and casing update should not count as a real edit 
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.MailingStreet = ' direct street  edit ';  
            con.MailingState = 'Oregon';
        }
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        Test.startTest();
        update conList;
        Test.stopTest();
        
        //Verify that the HH and Contacts share the same address
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        conList = [SELECT Id, Name, AccountId, 
                    is_Address_Override__c, Current_Address__c, MailingStreet, 
                    MailingCity, Mailing_County__c, MailingState, 
                    MailingPostalCode, MailingCountry, MailingLatitude, 
                    MailingLongitude 
                    FROM Contact];
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('direct street  edit'));
            System.assert(con.Mailing_County__c.contains('bergen'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }

        //Verify that no new Address record was created
        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c, Parent_Account__c 
                                        FROM Address__c];
        System.assertEquals(2, addrList.size());
        for (Address__c addr : addrList) {
            System.assertEquals('direct street  edit', addr.MailingStreet__c);
        }                
    }

    /*********************************************************************************************************
    @description Update Contact's mailing fields and Account's billing fields - format only. 
    * Verify:
    * - Existing default Address record's mailing fields are updated.
    * - No new Address record is created. 
    * - Household Account and Contact's billing/mailing fields are updated. 
    **********************************************************************************************************/            
    @isTest
    private static void updateContactAndAccountMailingBillingFieldsForSimpleAddressChangeTreatedAsUpdate() {
        configSettings();
            
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        //NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        List<Contact> conList = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.MailingStreet = 'Direct Street Edit';
            conList.add(con);
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        update conList;
        
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.MailingState = 'Washington';
        }
        update conList;
        
        //Whitespace and casing should not count as a real edit 
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.MailingStreet = ' direct street  edit ';  
            con.MailingState = 'Oregon';
        }
        update conList;

        //Update casing only 
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.MailingStreet = ' DIRECT STREET  EDIT ';  
        }
        Test.startTest();
        update conList;
        Test.stopTest();
        
        //Verify that the Household Account and Contact share the same address
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        conList = [SELECT Id, Name, AccountId, 
                        is_Address_Override__c, Current_Address__c, MailingStreet, 
                        MailingCity, Mailing_County__c, MailingState, 
                        MailingPostalCode, MailingCountry, MailingLatitude, 
                        MailingLongitude 
                        FROM Contact];
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.equals('DIRECT STREET  EDIT'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }

        //Verify that no new address was created
        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c, Parent_Account__c 
                                        FROM Address__c];
        System.assertEquals(2, addrList.size());
        for (Address__c addr : addrList) {
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
        accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                BillingCity, Billing_County__c, BillingState, 
                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                BillingLongitude 
                                                FROM Account]);
        conList = [SELECT Id, Name, AccountId, 
                        is_Address_Override__c, Current_Address__c, MailingStreet, 
                        MailingCity, Mailing_County__c, MailingState, 
                        MailingPostalCode, MailingCountry, MailingLatitude, 
                        MailingLongitude 
                        FROM Contact];
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.equals('direct street  edit'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }

        //Verify that no new address was created
        addrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                        MailingCounty__c, Parent_Account__c 
                        FROM Address__c];
        System.assertEquals(2, addrList.size());
        for (Address__c addr : addrList) {
            System.assert(addr.MailingStreet__c.equals('direct street  edit'));
            System.assert(addr.MailingCounty__c.contains('County')); 
        }
    }

    /*********************************************************************************************************
    @description Update Account's billing fields. 
    * Verify:
    * - New default Address record is created. 
    * - Household Account's billing and Contact's mailing fields are updated with the newest default Address record's 
    * mailing fields. 
    **********************************************************************************************************/            
    @isTest
    private static void updateHHAccountBillingFields() {
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
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        List<Contact> conList = [SELECT Id, Name, AccountId, 
                                    is_Address_Override__c, Current_Address__c, MailingStreet, 
                                    MailingCity, Mailing_County__c, MailingState, 
                                    MailingPostalCode, MailingCountry, MailingLatitude, 
                                    MailingLongitude 
                                    FROM Contact];
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(acc.BillingStreet.contains('final Street Edit'));
            System.assert(con.MailingStreet.contains('final Street Edit')); 
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }

        //Verify the previous Address record is no longer default
        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c, Parent_Account__c 
                                        FROM Address__c];
        //Each set of edits created a new address object 
        System.assertEquals(10, addrList.size());
        for (Address__c addr : addrList) {
            if (addr.MailingStreet__c.contains('final Street Edit')) {
                System.assertEquals(True, addr.Default_Address__c);
            } else {
                System.assertEquals(False, addr.Default_Address__c);
            }
        }        
    }

    /*********************************************************************************************************
    @description Update Account's billing fields - format only.
    * Verify:
    * - Existing default Address mailing fields are updated. 
    * - Household Account and Contact's billing/mailing fields are updated with the latest address field updates. 
    * - No new Address record is created for each billing field(s) update. 
    **********************************************************************************************************/            
    @isTest
    private static void updateHHAccountBillingFieldsForSimpleAddressChangedTreatedAsUpdate() {
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
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        List<Contact> conList = [SELECT Id, Name, AccountId, 
                                    is_Address_Override__c, Current_Address__c, MailingStreet, 
                                    MailingCity, Mailing_County__c, MailingState, 
                                    MailingPostalCode, MailingCountry, MailingLatitude, 
                                    MailingLongitude 
                                    FROM Contact];
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(acc.BillingStreet.contains('direct street  edit'));
            System.assert(con.MailingStreet.contains('direct street  edit')); 
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }

        //Verify that no new address was created
        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c, Parent_Account__c 
                                        FROM Address__c];
        System.assertEquals(2, addrList.size());
        for (Address__c addr : addrList) {
            System.assertEquals('direct street  edit', addr.MailingStreet__c);
        }        
    }

    /*********************************************************************************************************
    @description Create an Address record with no parent record. 
    * Verify:
    * - Runtime error. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNewAddressWithoutParentRecord() {
        List<Address__c> addrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            System.assertEquals(Null, addrList[i].Parent_Account__c);
        }
        
        try {
            insert addrList;
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
    * new Seasonal non default Address record. 
    * - Existing default Address record is still set as default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void insertCurrentNonDefaultSeasonalAddressOnExistingHHAccount() {
        configSettings();
                
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        List<Address__c> addrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrList[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrList[i].Default_Address__c = False;
            addrList[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(-1).month());
            addrList[i].Seasonal_Start_Day__c = '1';
            addrList[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(1).month());
            addrList[i].Seasonal_End_Day__c = '28';
            addrList[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrList[i].MailingCity__c = 'New Seasonal City' + i;
            addrList[i].MailingCounty__c = 'New Seasonal County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert addrList;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();
        
        //Verify that the Household Account and Contacts share the same address 
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        List<Contact> conList = [SELECT Id, Name, AccountId, 
                                    is_Address_Override__c, Current_Address__c, MailingStreet, 
                                    MailingCity, Mailing_County__c, MailingState, 
                                    MailingPostalCode, MailingCountry, MailingLatitude, 
                                    MailingLongitude 
                                    FROM Contact];
        System.assertEquals(4, conList.size());
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Seasonal Street'));
            System.assert(con.MailingCity.contains('New Seasonal City'));
            System.assert(con.Mailing_County__c.contains('New Seasonal County'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
        
        //Verify the previous default Address record is still marked as default
        List<Address__c> returnAddrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                                Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c 
                                                FROM Address__c];
        System.assertEquals(4, returnAddrList.size());
        for (Address__c addr : returnAddrList) {
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
    private static void insertCurrentNonDefaultSeasonalAddressWithYearOnExistingHHAccount() {
        configSettings();

        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        List<Address__c> addrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrList[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrList[i].Default_Address__c = False;
            addrList[i].Seasonal_Start_Year__c = System.today().addYears(-1).year();
            addrList[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(-1).month());
            addrList[i].Seasonal_Start_Day__c = '1';
            addrList[i].Seasonal_End_Year__c = System.today().addYears(1).year();
            addrList[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(1).month());
            addrList[i].Seasonal_End_Day__c = '28';
            addrList[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrList[i].MailingCity__c = 'New Seasonal City' + i;
            addrList[i].MailingCounty__c = 'New Seasonal County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert addrList;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();
        
        //Verify that the Household Account and Contacts share the same address
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c,BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        List<Contact> conList = [SELECT Id, Name, AccountId, 
                                    is_Address_Override__c, Current_Address__c, MailingStreet, 
                                    MailingCity, Mailing_County__c, MailingState, 
                                    MailingPostalCode, MailingCountry, MailingLatitude, 
                                    MailingLongitude 
                                    FROM Contact];
        System.assertEquals(4, conList.size());
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Seasonal Street'));
            System.assert(con.MailingCity.contains('New Seasonal City'));
            System.assert(con.Mailing_County__c.contains('New Seasonal County'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
        
        //Verify the previous default Address record is still marked as default
        List<Address__c> returnAddrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                                Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c 
                                                FROM Address__c];
        System.assertEquals(4, returnAddrList.size());
        for (Address__c addr : returnAddrList) {
            if (addr.MailingStreet__c.contains('New Seasonal Street')) {
                System.assertEquals(False, addr.Default_Address__c); 
            } else {
                System.assertEquals(True, addr.Default_Address__c); 
            }
        }        
    }

    /*********************************************************************************************************
    @description Create a new non current non default Seasonal Address record to an existing Household 
    * Account with existing default Address.
    * Verify:
    * - Creates new non default non current Seasonal Address record. 
    * - Contact's and Household Account's mailing/billing fields are not updated. 
    * - Existing default Address record is still set as default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNonCurrentNonDefaultSeasonalAddressOnExistingHHAccount() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());

        List<Address__c> addrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrList[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrList[i].Default_Address__c = False;
            addrList[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(1).month());
            addrList[i].Seasonal_Start_Day__c = '1';
            addrList[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(2).month());
            addrList[i].Seasonal_End_Day__c = '28';
            addrList[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrList[i].MailingCity__c = 'New Seasonal City' + i;
            addrList[i].MailingCounty__c = 'New Seasonal County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert addrList;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();
        
        //Verify that the Household Account and Contacts share the same address 
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        List<Contact> conList = [SELECT Id, Name, AccountId, 
                                    is_Address_Override__c, Current_Address__c, MailingStreet, 
                                    MailingCity, Mailing_County__c, MailingState, MailingPostalCode, 
                                    MailingCountry, MailingLatitude, 
                                    MailingLongitude 
                                    FROM Contact];
        System.assertEquals(4, conList.size());
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(!con.MailingStreet.contains('New Seasonal Street'));
            System.assert(!con.MailingCity.contains('New Seasonal City'));
            System.assert(!con.Mailing_County__c.contains('New Seasonal County'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
        
        //Verify the previous default Address record is still marked as default
        List<Address__c> returnAddrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                                Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c 
                                                FROM Address__c];
        System.assertEquals(4, returnAddrList.size());
        for (Address__c addr : returnAddrList) {
            if (addr.MailingStreet__c.contains('New Seasonal Street')) {
                System.assertEquals(False, addr.Default_Address__c); 
            } else {
                System.assertEquals(True, addr.Default_Address__c); 
            }
        }        
    }

    /*********************************************************************************************************
    @description Update existing non current non default Seasonal Address record to make it current. 
    * Verify:
    * - Contact's and Household Account's mailing/billing fields are updated with the mailing fields from the 
    * current non default Seasonal Address record. 
    * - Existing default Address record is still set as default Address record.
    **********************************************************************************************************/            
    @isTest
    private static void updateNonCurrentNonDefaultSeasonAddressToCurrentSeasonalOnExistingHHAccount() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        List<Address__c> addrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrList[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrList[i].Default_Address__c = False;
            addrList[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(1).month());
            addrList[i].Seasonal_Start_Day__c = '1';
            addrList[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(2).month());
            addrList[i].Seasonal_End_Day__c = '28';
            addrList[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrList[i].MailingCity__c = 'New Seasonal City' + i;
            addrList[i].MailingCounty__c = 'New Seasonal County' + i;
        }
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        insert addrList;
        
        //Update Seasonal Address record to make it current
        for (Integer i = 0; i < 2; i++) {
            addrList[i].Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(-1).month());
        }
        Test.startTest();
        ADDR_Contact_TEST.turnOnAllAddrTriggers();                
        update addrList;
        Test.stopTest();
        
        //Verify that the Household and Contacts share the same address
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        List<Contact> conList = [SELECT Id, Name, AccountId, 
                                    is_Address_Override__c, Current_Address__c, MailingStreet, 
                                    MailingCity, Mailing_County__c, MailingState, 
                                    MailingPostalCode, MailingCountry, MailingLatitude, 
                                    MailingLongitude 
                                    FROM Contact];
        System.assertEquals(4, conList.size());
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Seasonal Street'));
            System.assert(con.MailingCity.contains('New Seasonal City'));
            System.assert(con.Mailing_County__c.contains('New Seasonal County'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
        
        //Verify the previous default Address record is still marked as default 
        List<Address__c> returnAddrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                                Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c 
                                                FROM Address__c];
        System.assertEquals(4, returnAddrList.size());
        for (Address__c addr : returnAddrList) {
            if (addr.MailingStreet__c.contains('New Seasonal Street')) {
                System.assertEquals(False, addr.Default_Address__c); 
            } else {
                System.assertEquals(True, addr.Default_Address__c); 
            }
        }        
    }

    /*********************************************************************************************************
    @description Tests ADDR_Seasonal_Batch - Create a new current Seasonal non default Address record to an 
    * existing Household Account with existing default Address.
    * Verify:
    * - Creates new non default current Seasonal Address record. 
    * - Contact's and Household Account's mailing/billing fields are updated with the mailing fields from the 
    * new Seasonal Address record. 
    * - Existing default Address record is still set as default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void scheduleInsertNewCurrentNonDefaultSeasonalAddress() {
        configSettings();
                
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());

        List<Address__c> addrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrList[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrList[i].Default_Address__c = False;
            addrList[i].Seasonal_Start_Month__c = String.valueOf(System.today().month());
            addrList[i].Seasonal_Start_Day__c = String.valueOf(System.today().day());
            addrList[i].Seasonal_End_Month__c = String.valueOf(System.today().addMonths(1).month());
            addrList[i].Seasonal_End_Day__c = '28';
            addrList[i].MailingStreet__c = 'New Seasonal Street' + i;
            addrList[i].MailingCity__c = 'New Seasonal City' + i;
        }
        
        //Hack! by setting our trigger handler as run,
        //we can insert the new seasonal addresses but not have them processed.
        //this way we can test the scheduled job!
        ADDR_Addresses_TDTM.turnOff();
        insert addrList;
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
        
        //Verify that the Household Account and Contacts share the same address 
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                    BillingCity, Billing_County__c, BillingState, 
                                                                    BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                    BillingLongitude 
                                                                    FROM Account]);
        List<Contact> conList = [SELECT Id, Name, AccountId, 
                                    is_Address_Override__c, Current_Address__c, MailingStreet, 
                                    MailingCity, Mailing_County__c, MailingState, 
                                    MailingPostalCode, MailingCountry, MailingLatitude, 
                                    MailingLongitude 
                                    FROM Contact];
        System.assertEquals(4, conList.size());
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Seasonal Street'));
            System.assert(con.MailingCity.contains('New Seasonal City'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
        
        //Verify the previous default Address record is still marked as default
        List<Address__c> returnAddrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                                Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c 
                                                FROM Address__c];
        System.assertEquals(4, returnAddrList.size());
        for (Address__c addr : returnAddrList) {
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
    private static void updateAccountBillingFieldsWithNonDefaultDupeAddress() {
        configSettings();
            
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());

        List<Address__c> newAddrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            newAddrList[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            newAddrList[i].Default_Address__c = False;
            newAddrList[i].MailingStreet__c = 'New Street' + i;
            newAddrList[i].MailingCity__c = 'New City' + i;
            newAddrList[i].MailingCounty__c = 'New County' + i;

        }
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        insert newAddrList;

        for (Integer i = 0; i < 2; i++) {
            consAccsAddrs.accs[i].BillingStreet = newAddrList[i].MailingStreet__c;
            consAccsAddrs.accs[i].BillingCity = newAddrList[i].MailingCity__c;
            consAccsAddrs.accs[i].Billing_County__c = newAddrList[i].MailingCounty__c;
            consAccsAddrs.accs[i].BillingState = newAddrList[i].MailingState__c;
            consAccsAddrs.accs[i].BillingPostalCode = newAddrList[i].MailingPostalCode__c;
            consAccsAddrs.accs[i].BillingCountry = newAddrList[i].MailingCountry__c;
        }        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update consAccsAddrs.accs;
        Test.stopTest();
        
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        List<Contact> conList = [SELECT Id, Name, AccountId, 
                                    is_Address_Override__c, Current_Address__c, MailingStreet, 
                                    MailingCity, Mailing_County__c, MailingState, 
                                    MailingPostalCode, MailingCountry, MailingLatitude, 
                                    MailingLongitude 
                                    FROM Contact];
        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                        Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c 
                                        FROM Address__c];
        System.assertEquals(4, addrList.size());
        
        //Verify that the Household and Contacts share the same address and it's new!
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Street'));
            System.assert(con.MailingCity.contains('New City'));
            System.assert(con.Mailing_County__c.contains('New County'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
        
        //Verify the new addresses still are Default and we don't have too many
        for (Address__c addr : addrList) {
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
    private static void updateContactMailingFieldsWithNonDefaultDupeAddress() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());

        List<Address__c> addrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrList[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrList[i].Default_Address__c = False;
            addrList[i].MailingStreet__c = 'New Street' + i;
            addrList[i].MailingCity__c = 'New City' + i;
            addrList[i].MailingCounty__c = 'New County' + i;
        }
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        insert addrList;

        for (Integer i = 0; i < 2; i++) {
            for (Integer j = 0; j < 2; j++) {
                consAccsAddrs.contacts[(i * 2) + j].MailingStreet = addrList[i].MailingStreet__c;
                consAccsAddrs.contacts[(i * 2) + j].MailingCity = addrList[i].MailingCity__c;
                consAccsAddrs.contacts[(i * 2) + j].Mailing_County__c = addrList[i].MailingCounty__c;
                consAccsAddrs.contacts[(i * 2) + j].MailingState = addrList[i].MailingState__c;
                consAccsAddrs.contacts[(i * 2) + j].MailingPostalCode = addrList[i].MailingPostalCode__c;
                consAccsAddrs.contacts[(i * 2) + j].MailingCountry = addrList[i].MailingCountry__c;
            }
        }        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update consAccsAddrs.contacts;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        List<Contact> conList = [SELECT Id, Name, AccountId, 
                                    is_Address_Override__c, Current_Address__c, MailingStreet, 
                                    MailingCity, Mailing_County__c, MailingState, 
                                    MailingPostalCode, MailingCountry, MailingLatitude, 
                                    MailingLongitude 
                                    FROM Contact];
        System.assertEquals(4, conList.size());
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.MailingStreet.contains('New Street'));
            System.assert(con.MailingCity.contains('New City'));
            System.assert(con.Mailing_County__c.contains('New County'));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
        
        //Verify the new addresses still are Default and we don't have too many
        List<Address__c> returnAddrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                            Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c 
                                            FROM Address__c];
        System.assertEquals(4, returnAddrList.size());
        for (Address__c addr : returnAddrList) {
            if (addr.MailingStreet__c.contains('New Street')) {
                System.assertEquals(True, addr.Default_Address__c); 
            } else {
                System.assertEquals(False, addr.Default_Address__c); 
            }
        }
    }

    /*********************************************************************************************************
    @description Create a non default Address record and associate it to a Contact whose is_Address_Override__c 
    * is enabled. Update the override Contact’s mailing fields. 
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
    private static void enableOverrideOnContactAndUpdateMailingFields() {
        configSettings();
                
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());

        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        ADDR_Addresses_TDTM.addressIdsInserted = new Set<Id>();
        List<Address__c> addrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        ADDR_Addresses_TDTM.addressIdsInserted = new Set<Id>();
        for (Integer i = 0; i < 2; i++) {
            addrList[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrList[i].Default_Address__c = False;
            addrList[i].MailingStreet__c = 'override' + i;
            addrList[i].MailingCity__c = 'override' + i;
            addrList[i].MailingCounty__c = 'override' + i;
        }
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        insert addrList;

        ADDR_Contact_TEST.turnOnAllAddrTriggers();    
        //Set the Contact's Address override
        List<Contact> conList = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.Current_Address__c = addrList[i].Id;
            con.is_Address_Override__c = True;
            conList.add(con);
        }
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        update conList; 

        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        for (Contact con : conList) {
            con.MailingStreet = 'Direct Street Edit';
            con.MailingCity = 'Direct City Edit';
        }
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        Test.startTest();
        update conList;
        Test.stopTest();
        
        //Verify that the Household and Contacts share the same address
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        conList = [SELECT Id, Name, AccountId, 
                        is_Address_Override__c, Current_Address__c, MailingStreet, 
                        MailingCity, Mailing_County__c, MailingState, 
                        MailingPostalCode, MailingCountry, MailingLatitude, 
                        MailingLongitude 
                        FROM Contact];

        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
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
        List<Address__c> returnAddrList = [SELECT Id, Default_Address__c, MailingStreet__c, Parent_Account__c 
                                                FROM Address__c];
        System.assertEquals(6, returnAddrList.size());
        for (Address__c addr : returnAddrList) {
            if (addr.MailingStreet__c.contains('Direct Street Edit')) {
                System.assertEquals(False, addr.Default_Address__c); 
                for (Contact con : conList) {
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
    @description Create new Contact records where mailing fields are not populated on an existing Household Account
    * with existing default Address record. 
    * Verify:
    * - The new Contact's mailing fields are udpated to match the mailing fields from the default Address record.
    **********************************************************************************************************/            
    @isTest
    private static void insertNewContactWithEmptyMailingFieldsOnExistingHHAccount() {
        configSettings();

        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        List<Contact> conList = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        for (Integer i = 0; i < 2; i++) {
            conList[i].LastName = 'ToAvoidDupeRule' + i;
            conList[i].AccountId = consAccsAddrs.accs[i].Id;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert conList;         
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.stopTest();
        
        //Verify that the Household Account and Contacts share the same address
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        conList = [SELECT Id, Name, AccountId, 
                        is_Address_Override__c, Current_Address__c, MailingStreet, 
                        MailingCity, Mailing_County__c, MailingState, 
                        MailingPostalCode, MailingCountry, MailingLatitude, 
                        MailingLongitude 
                        FROM Contact];
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assert(con.Mailing_County__c.contains('County')); 
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Create new Contact records with populated mailing fields.  
    * Verify:
    * - New Contact is created with mailing fields populated. 
    * - New default Address record is created. 
    * - Account's billing fields are updated with the mailing fields from the newly created default Address record. 
    * - Existing Contact's mailing fields are updated with the mailing fields from the newly created default Address record.
    * - Previous default Address record is no longer marked as default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void insertContactWithPopulatedMailingFieldsToExistingHHAccount() {
        configSettings();
            
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());

        List<Contact> conList = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        for (Integer i = 0; i < 2; i++) {
            conList[i].AccountId = consAccsAddrs.accs[i].Id;
            conList[i].LastName = 'ToAvoidDupeRule' + i;
            conList[i].MailingStreet = 'New Mailing Street' + i;
            conList[i].MailingCity = 'New Mailing City' + i;
            conList[i].Mailing_County__c = 'New Mailing County' + i;
            conList[i].MailingState = 'California';
            conList[i].MailingCountry = 'United States';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert conList;
        Test.stopTest();
        
        //Verify that the Household Account and Contacts share the same address
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        conList = [SELECT Id, Name, AccountId, 
                        is_Address_Override__c, Current_Address__c, MailingStreet, 
                        MailingCity, Mailing_County__c, MailingState, 
                        MailingPostalCode, MailingCountry, MailingLatitude, 
                        MailingLongitude 
                        FROM Contact];
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
            System.assert(con.MailingStreet.contains('New Mailing Street'));
            System.assert(con.MailingCity.contains('New Mailing City'));
            System.assert(con.Mailing_County__c.contains('New Mailing County'));
        }
        
        List<Address__c> addrList = [SELECT Default_Address__c, MailingStreet__c, MailingCity__c, 
                                        MailingState__c, MailingCountry__c 
                                        FROM Address__c];
        System.assertEquals(4, addrList.size()); 
        for (Address__c addr : addrList) {
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
    private static void insertContactWithDupeMailingFields() {
        configSettings();
                
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        List<Contact> conList = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        for (Integer i = 0; i < 2; i++) {
            conList[i].LastName = 'ToAvoidDupeRule' + i;
            conList[i].AccountId = consAccsAddrs.accs[i].Id;
            conList[i].MailingStreet = consAccsAddrs.accs[i].BillingStreet;
            conList[i].MailingCity = consAccsAddrs.accs[i].BillingCity;
            conList[i].Mailing_County__c = consAccsAddrs.accs[i].Billing_County__c;
            conList[i].MailingState = consAccsAddrs.accs[i].BillingState;
            conList[i].MailingPostalCode = consAccsAddrs.accs[i].BillingPostalCode;
            conList[i].MailingCountry = consAccsAddrs.accs[i].BillingCountry;
            conList[i].MailingLatitude = consAccsAddrs.accs[i].BillingLatitude;
            conList[i].MailingLongitude = consAccsAddrs.accs[i].BillingLongitude;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert conList;         
        Test.stopTest();
        
        //Verify that the Household Account and Contacts share the same address
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        conList = [SELECT Id, Name, AccountId, 
                        is_Address_Override__c, Current_Address__c, MailingStreet,
                        MailingCity, Mailing_County__c, MailingState, 
                        MailingPostalCode, MailingCountry, MailingLatitude, 
                        MailingLongitude 
                        FROM Contact];
        System.assertEquals(6, conList.size());
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }
        
        Integer numOfAddrs = [SELECT Count()
                                FROM Address__c]; 
        System.assertEquals(2, numOfAddrs);
    }

    /*********************************************************************************************************
    @description Create new Contact on an existing Household Account and populate its mailing street with multiline
    * street value. 
    * Verify:
    * - New default Address record is created and MailingStreet__c and MailingStreet2__c are populated appropriately.
    * - Account's billing fields are updated with the mailing fields from the newly created default Address record.
    * - Existing Contact's mailing fields are updated with the mailing fields from the newly created default Address record.
    **********************************************************************************************************/            
    @isTest
    private static void insertContactWithMultilineStreetValue() {
        configSettings();

        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        List<Contact> contactList = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        for (Integer i = 0; i<contactList.size(); i++) {
            Contact con = contactList[i];
            con.LastName = 'ToAvoidDupeRule' + i;
            con.AccountId = consAccsAddrs.accs[i].Id;
            con.MailingStreet = 'new street\r\nsecond line';
            con.MailingCity = 'new city';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert contactList;
        Test.stopTest();
        
        //Verify the Address objects split street.
        List<Address__c> returnAddrList = [SELECT Id, MailingStreet__c, MailingStreet2__c, 
                                            Formula_MailingStreetAddress__c 
                                            FROM Address__c];
        System.assertEquals(4, returnAddrList.size());
        for (Address__c addr : returnAddrList) {
            if (addr.MailingStreet__c.contains('new street')) {
                System.assertEquals('second line', addr.MailingStreet2__c);
                System.assertEquals('new street<br>second line<br>new city,', addr.Formula_MailingStreetAddress__c);
            }
        }

        //Verify that the Household Account and Contacts share the same address
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                    BillingCity, Billing_County__c, BillingState, 
                                                                    BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                    BillingLongitude 
                                                                    FROM Account]);
        List<Contact> returnConList = [SELECT Id, Name, AccountId, 
                                            is_Address_Override__c, Current_Address__c, MailingStreet, 
                                            MailingCity, Mailing_County__c, MailingState, 
                                            MailingPostalCode, MailingCountry, MailingLatitude, 
                                            MailingLongitude 
                                            FROM Contact];
        for (Contact con : returnConList) {
            Account acc = accountsById.get(con.AccountId);
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
    private static void insertNewDefaultMultilineStreetAddressRecord() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        List<Address__c> addrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2);
        for (Integer i = 0; i < 2; i++) {
            addrList[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            addrList[i].Default_Address__c = True;
            addrList[i].MailingStreet__c = 'New Default Street';
            addrList[i].MailingStreet2__c = 'Second Line';
            addrList[i].MailingCity__c = 'New Default City' + i;
            addrList[i].MailingCounty__c = 'New Default County' + i;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert addrList;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();        
        Test.stopTest();
        
        Integer numOfAddrs = [SELECT Count() 
                                FROM Address__c];
        System.assertEquals(4, numOfAddrs); 
        
        //Verify that the Household Account and Contacts share the same address 
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);	
        List<Contact> conList = [SELECT Id, Name, AccountId, 
                                    is_Address_Override__c, Current_Address__c, MailingStreet, 
                                    MailingCity, Mailing_County__c, MailingState, 
                                    MailingPostalCode, MailingCountry, MailingLatitude, 
                                    MailingLongitude 
                                    FROM Contact];
        System.assertEquals(4, conList.size());
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assertEquals('New Default Street\r\nSecond Line', con.MailingStreet);
            System.assertEquals('New Default Street\r\nSecond Line', acc.BillingStreet);
        }
    }
    
    /*********************************************************************************************************
    @description Update existing Account's billing fields - specifically adding multiline street value. 
    * Verify:
    * - New default Address record is created and MailingStreet__c and MailingStreet2__c are populated appropriately.
    * - Existing Contact records' mailing fields are updated with the mailing fields from the newly created 
    * default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void updateHHAccountBillingStreetWithMultilineStreetValue() {
        configSettings();
            
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());

        for (Integer i = 0; i < 2; i++) {
            Account acc = consAccsAddrs.accs[i];
            acc.BillingStreet = 'Direct Street Edit\r\nSecond Line';
            acc.BillingCity = 'Direct City Edit';
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update consAccsAddrs.accs;
        Test.stopTest();
        
        //Verify that the Household Account and Contacts share the same address
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        List<Contact> conList = [SELECT Id, Name, AccountId, 
                                    is_Address_Override__c, Current_Address__c, MailingStreet, 
                                    MailingCity, Mailing_County__c, MailingState, 
                                    MailingPostalCode, MailingCountry, MailingLatitude, 
                                    MailingLongitude 
                                    FROM Contact];
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(True, isMatchAddressAccCon(acc, con));
            System.assertEquals('Direct Street Edit\r\nSecond Line', acc.BillingStreet);
            System.assertEquals('Direct Street Edit\r\nSecond Line', con.MailingStreet);
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertNotEquals(Null, con.Current_Address__c);
        }

        //Verify the Address objects split street
        List<Address__c> addrList = [SELECT Id, MailingStreet__c, MailingStreet2__c, 
                                        Formula_MailingStreetAddress__c, Default_Address__c 
                                        FROM Address__c];
        for (Address__c addr : addrList) {
            if (addr.Default_Address__c) {
                System.assertEquals('Direct Street Edit', addr.MailingStreet__c);
                System.assertEquals('Second Line', addr.MailingStreet2__c);
                System.assert(addr.Formula_MailingStreetAddress__c.contains('Direct Street Edit<br>Second Line<br>Direct City Edit'));
            } else {
                System.assertEquals(False, addr.Default_Address__c); 
            }
        }
    }

    /*********************************************************************************************************
    @description Create a new Contact with mailing fields populated and Household_Addresses_RecType__c on Hierarchy
    * Setting is not set to "Household". 
    * Verify:
    * - No new Address record is created.
    * - Account's billing fields are not populated. 
    **********************************************************************************************************/            
    @isTest
    private static void insertContactWithHouseholdRecTypeDisabled() {        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),                 																	
                                                                                                                                Household_Addresses_RecType__c = Null));

        List<Contact> contactList = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        for (Contact con : contactList) {
            con.MailingStreet = 'new street';
            con.MailingCity = 'new city';
            con.Mailing_County__c = 'new county';
        }
        insert contactList;        

        //Verify that the Household Account and Contacts don't share the same address
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, BillingState, 
                                                                BillingPostalCode, BillingCountry, BillingLatitude, 
                                                                BillingLongitude 
                                                                FROM Account]);
        List<Contact> conList = [SELECT Id, Name, AccountId, 
                                    is_Address_Override__c, Current_Address__c, MailingStreet, 
                                    MailingCity, Mailing_County__c, MailingState, 
                                    MailingPostalCode, MailingCountry, MailingLatitude, 
                                    MailingLongitude 
                                    FROM Contact];
        for (Contact con : conList) {
            Account acc = accountsById.get(con.AccountId);
            System.assertEquals(False, isMatchAddressAccCon(acc, con));
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertEquals(Null, con.Current_Address__c);
            System.assertEquals(Null, acc.BillingStreet); 
        }
        
        //Verify no address objects created
        List<Address__c> addrList = [SELECT Id 
                                        FROM Address__c];
        System.assertEquals(0, addrList.size());
    }
    
    /*********************************************************************************************************
    @description Create new current non default Seasonal Address record to an existing Household Account. 
    * Verify:
    * - New current non default Seasonal Address record is created. 
    * - Household and Contact's billing/mailing fields are updated with the mailing fields from the newly created
    * current default Seasonal Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNewCurrentNonDefaultSeasonalAddressRecord() {
        configSettings();
        
        Contact contact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        contact.MailingStreet = '123 Default';
        contact.MailingCity = 'Austin';
        contact.Mailing_County__c = 'Bergen'; 
        contact.MailingState = 'Texas';
        contact.MailingCountry = 'United States';
        insert contact; 

        contact = [SELECT AccountID, MailingStreet, MailingCity, 
                        Mailing_County__c, MailingState, MailingPostalCode, 
                        MailingCountry, MailingLatitude, MailingLongitude 
                        FROM Contact 
                        WHERE Id = :contact.Id];       
        System.assertNotEquals(Null, contact.AccountID);
                
        Address__c defaultAddress = [SELECT Id, Default_Address__c 
                                        FROM Address__c 
                                        WHERE Parent_Account__c = : contact.AccountId];
        System.assertEquals(True, defaultAddress.Default_Address__c);
        
        Account acc = [SELECT Id, Name, BillingStreet, 
                            BillingCity, Billing_County__c, BillingState, 
                            BillingPostalCode, BillingCountry, BillingLatitude, 
                            BillingLongitude 
                            FROM Account 
                            WHERE Id = :contact.AccountID];
        System.assertEquals(True, isMatchAddressAccCon(acc, contact));
        System.assertEquals('123 Default', contact.MailingStreet);
        System.assertEquals('Austin', acc.BillingCity);
        System.assertEquals('Bergen', acc.Billing_County__c);
        
        //Create seasonal Address with start and end year that include the current date
        Address__c seasonalAddress = new Address__c(
            Parent_Account__c = contact.AccountID, 
            MailingStreet__c = '123 Seasonal', 
            MailingCity__c = 'Seattle', 
            MailingCounty__c = 'SeasonCounty', 
            MailingState__c = 'Washington', 
            MailingCountry__c = 'United States', 
            Seasonal_Start_Day__c = String.valueOf(System.today().addDays(-1).day()), 
            Seasonal_Start_Month__c = String.valueOf(System.today().addMonths(-1).month()), 
            Seasonal_Start_Year__c = System.today().addYears(-1).year(), 
            Seasonal_End_Day__c = String.valueOf(System.today().addDays(1).day()), 
            Seasonal_End_Month__c = String.valueOf(System.today().addMonths(1).month()), 
            Seasonal_End_Year__c = System.today().addYears(1).year()
        );
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert seasonalAddress;
        Test.stopTest();
        
        //Seasonal Address should have been copied to the Contact and the Account
        contact = [SELECT AccountId, MailingStreet, 
                        MailingCity, Mailing_County__c, MailingState 
                        FROM Contact 
                        WHERE Id = :contact.Id];
        System.assertEquals('123 Seasonal', contact.MailingStreet);
        System.assertEquals('Seattle', contact.MailingCity);
        System.assertEquals('SeasonCounty', contact.Mailing_County__c);
        System.assertEquals('Washington', contact.MailingState);
        
        acc = [SELECT BillingStreet, BillingCity, Billing_County__c, 
                    BillingState 
                    FROM Account 
                    WHERE Id = :contact.AccountId];
        System.assertEquals('123 Seasonal', acc.BillingStreet);
        System.assertEquals('Seattle', acc.BillingCity);
        System.assertEquals('SeasonCounty', acc.Billing_County__c);
        System.assertEquals('Washington', acc.BillingState);
    }
    
    /*********************************************************************************************************
    @description Update Contact's mailing fields to Null/empty. 
    * Verify: 
    * - No new Address record was created.
    * - Existing previous default Address record is no longer marked as default Address record. 
    * - Household Account's billing fields are cleared. 
    * - Existing Contact's mailing fields are cleared. 
    **********************************************************************************************************/            
    @isTest
    private static void clearContactMailingFields() {
        configSettings();
                
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        for (Integer i = 0; i < 2; i++) {
            Contact con = consAccsAddrs.contacts[i*2 + i];
            con.MailingStreet = Null;
            con.MailingCity = Null;
            con.Mailing_County__c = Null;
            con.MailingPostalCode = Null;
            con.MailingState = Null;
            con.MailingCountry = Null;
            con.MailingLatitude = Null;
            con.MailingLongitude = Null;
            if (ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled) {
                con.put('MailingStateCode', Null);
                con.put('MailingCountryCode', Null);
            }                
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update consAccsAddrs.contacts;
        Test.stopTest();
        
        //Verify that the Household Account and Contacts have empty addresses
        List<Account> accList = [SELECT Id, Name, BillingStreet, 
                                    BillingCity, Billing_County__c, BillingState,
                                    BillingPostalCode, BillingCountry, BillingLatitude, 
                                    BillingLongitude 
                                    FROM Account];
        for (Account acc : accList) {
            System.assertEquals(Null, acc.BillingStreet);
            System.assertEquals(Null, acc.BillingCity);
            System.assertEquals(Null, acc.Billing_County__c);
            System.assertEquals(Null, acc.BillingPostalCode);
            System.assertEquals(Null, acc.BillingState);
            System.assertEquals(Null, acc.BillingCountry);
        }
        
        List<Contact> conList = [SELECT Id, Name, AccountId, 
                                    is_Address_Override__c, Current_Address__c, MailingStreet, 
                                    MailingCity, Mailing_County__c, MailingState, 
                                    MailingPostalCode, MailingCountry, MailingLatitude, 
                                    MailingLongitude 
                                    FROM Contact];
        for (Contact con : conList) {
            System.assertEquals(False, con.is_Address_Override__c);
            System.assertEquals(Null, con.Current_Address__c);
            System.assertEquals(Null, con.MailingStreet);
            System.assertEquals(Null, con.MailingCity);
            System.assertEquals(Null, con.Mailing_County__c);
            System.assertEquals(Null, con.MailingPostalCode);
            System.assertEquals(Null, con.MailingState);
            System.assertEquals(Null, con.MailingCountry);
        }

        //Verify that no new Address record was created
        List<Address__c> addrList = [SELECT Default_Address__c 
                                        FROM Address__c];
        System.assertEquals(2, addrList.size());
        for (Address__c addr : addrList) {
            System.assertEquals(False, addr.Default_Address__c);
        }                
    }

    /*********************************************************************************************************
    @description Create new Contact where is_Address_Override__c is enabled on an existing Household Account with
    * default Address record. 
    * Verify:
    * - New Contact whose is_Address_Override__c is enabled, its mailing fields are populated with the existing 
    * default Address record. 
    * - No new Address record is created. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNewOverrideContactOnExistingHHAccount() {
        configSettings();
            
        UTIL_UnitTestData_TEST.ContactsAccsWithAddrs consAccsAddrs = UTIL_UnitTestData_TEST.createTestConsAccsAddrs(2, 2, UTIL_Describe_API.getHhAccRecTypeID());
        
        Contact con = UTIL_UnitTestData_TEST.getUniqueContact(1);
        con.LastName = 'test';
        con.AccountId = consAccsAddrs.accs[0].Id;
        con.is_Address_Override__c = True;
        con.Current_Address__c = consAccsAddrs.addrs[0].Id;
        Test.startTest();
        insert con;
        Test.stopTest();
        
        con = [SELECT Id, Name, AccountId, 
                    is_Address_Override__c, Current_Address__c, MailingStreet, 
                    MailingCity, Mailing_County__c,MailingState, 
                    MailingPostalCode, MailingCountry, MailingLatitude, 
                    MailingLongitude 
                    FROM Contact 
                    WHERE Id = :con.Id];
        System.assertEquals(True, con.is_Address_Override__c);
        System.assertEquals(consAccsAddrs.addrs[0].Id, con.Current_Address__c);
        System.assertEquals(consAccsAddrs.addrs[0].MailingStreet__c, con.MailingStreet);
        System.assertEquals(consAccsAddrs.addrs[0].MailingCity__c, con.MailingCity);
        System.assertEquals(consAccsAddrs.addrs[0].MailingCounty__c, con.Mailing_County__c);
        System.assertEquals(consAccsAddrs.addrs[0].MailingPostalCode__c, con.MailingPostalCode);
        System.assertEquals(consAccsAddrs.addrs[0].MailingState__c, con.MailingState);
        System.assertEquals(consAccsAddrs.addrs[0].MailingCountry__c, con.MailingCountry);
        
        Integer numOfAddress = [SELECT COUNT()
                                    FROM Address__c];
        System.assertEquals(2, numOfAddress); 
    }

    /*********************************************************************************************************
    @description Update existing Contact's AccountId to Null and MailingStreet. 
    * Verify:
    * - New default Address record is created. 
    * - New Household Account record is created. 
    * - Household Account's billing field is updated to match the mailing fields of the default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void switchContactAccountRecordToHouseholdAndUpdateMailingFields() {
        configSettings();
        
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        
        Account orgAcc = new Account(Name='Org Account', RecordTypeID = UTIL_Describe_API.getBizAccRecTypeID());
        insert orgAcc;
        
        Contact con = UTIL_UnitTestData_TEST.getContact();
        con.AccountId = orgAcc.Id; 
        insert con;
        
        con.AccountId = Null;
        con.MailingStreet = '123 abc';
        
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update con;
        Test.stopTest();

        String hhAccRecTypeID = UTIL_Describe_API.getHhAccRecTypeID();
        Account acc = [SELECT Id, Name, BillingStreet 
                            FROM Account 
                            WHERE RecordTypeId = :hhAccRecTypeID];
        System.assertNotEquals(Null, acc);
        System.assert(acc.Name.startsWith('Testerson')); 
        
        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c 
                                        FROM Address__c];
        System.assertEquals(1, addrList.size());
        System.assertEquals('123 abc', addrList[0].MailingStreet__c); 
        System.assertEquals(True, addrList[0].Default_Address__c); 
        
        con = [SELECT Id, Lastname, MailingStreet, Current_Address__c 
                    FROM Contact];
        System.assert(con.Lastname.startsWith('Testerson'));
        System.assertEquals('123 abc', con.MailingStreet);
        System.assertEquals(addrList[0].Id, con.Current_Address__c);
        System.assertEquals(addrList[0].MailingStreet__c, con.MailingStreet);
        System.assertEquals(addrList[0].MailingStreet__c, acc.BillingStreet);
    }

    /*********************************************************************************************************
    @description Create 2 new Contact records, one with Mailing fields filled out and one without. 
    * Verify:
    * - 2 new Contact records are created.
    * - New default Address record is created.
    * - Only 1 Address record is created. 
    * - Account's billing fields are updated to match the mailing fields of the newly created default Address record.
    * - Both Contact's mailing fields are updated to match the mailing fields of the newly created default Address record. 
    **********************************************************************************************************/
    @isTest
    private static void insertHHAccountWithOnlyPrimaryAddressType() {
        configSettings();
        
        ADDR_Contact_TEST.turnOffAllAddrTriggers();

        List<Account> accList = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, householdRecTypeID);
        insert accList;

        List<Contact> contactList = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        contactList[0].MailingStreet = 'new street';
        contactList[0].Primary_Address_Type__c = 'Home';
        contactList[0].AccountId = accList[0].Id;
        contactList[1].AccountId = accList[0].Id;
        contactList[1].Primary_Address_Type__c = 'Home';
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        insert contactList;
        Test.stopTest();

        List<Address__c> assertAddressesList = [SELECT Id, Parent_Account__c, Default_Address__c 
                                                    FROM Address__c];
        System.assertEquals(1, assertAddressesList.size());
        System.assertEquals(True, assertAddressesList[0].Default_Address__c);
        System.assertEquals(accList[0].Id, assertAddressesList[0].Parent_Account__c);
    }
}