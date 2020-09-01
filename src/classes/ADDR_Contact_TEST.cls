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
* @description Tests specific to Contact Address Management. 
*/

@isTest
public with sharing class ADDR_Contact_TEST {
    
    /*@description Set up of Hierarchy Settings leverage by test methods*/
    private static void configSettings() {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c(Contacts_Addresses_Enabled__c = True,
                                                Simple_Address_Change_Treated_as_Update__c = True);
        UTIL_CustomSettings_API.getSettingsForTests(hs);
    }
    
    /*@description Enable Address TDTM triggers*/
    public static void turnOnAllAddrTriggers() {
        ADDR_Contact_TDTM.turnOn();
        ADDR_Account_TDTM.turnOn();        
        ADDR_Addresses_TDTM.turnOn();
    }
    
    /*@description Disable Address TDTM triggers*/
    public static void turnOffAllAddrTriggers() {
        ADDR_Contact_TDTM.turnOff();
        ADDR_Account_TDTM.turnOff();        
        ADDR_Addresses_TDTM.turnOff();
    }
    
    /*********************************************************************************************************
    @description Create a new Contact record and populate its mailing fields. 
    * Verify:
    * - New default Address record is created. 
    * - New default Address record's Parent_Account__c is blank and Parent_Contact__c is populated. 
    * - New Admin Account is created and its billing fields are not populated. 
    **********************************************************************************************************/   
    @isTest
    private static void noContactAddressToAdminAccountAddressPropagation() {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getCustomAdminAccRecTypeID(),
                                                                Accounts_Addresses_Enabled__c = UTIL_Describe.getCustomAdminAccRecTypeID() + ';',	
                                                                Contacts_Addresses_Enabled__c = True,
                                                                Simple_Address_Change_Treated_as_Update__c = True);
        UTIL_CustomSettings_API.getSettingsForTests(hs);
        
        Contact contact = UTIL_UnitTestData_TEST.getContact();
        contact.LastName = 'Testerson'; 
        contact.MailingStreet = '123 Main St'; 
        contact.MailingCity = 'Austin'; 
        contact.Mailing_County__c = 'Bergen'; 
        contact.MailingState = 'Texas'; 
        contact.MailingPostalcode = '78701'; 
        contact.MailingCountry = 'United States';
        Test.startTest();
        insert contact;
        Test.stopTest();
        
        contact = [SELECT AccountId 
                    FROM Contact 
                    WHERE Id = :contact.Id];
        System.assertNotEquals(Null, contact.AccountID);
        
        //Verify child Address record was created
        List<Address__c> addrList = [SELECT Parent_Account__c, Parent_Contact__c, Default_Address__c
                                        FROM Address__c 
                                        WHERE Parent_Contact__c = :contact.Id]; 
        System.assertEquals(1, addrList.size());
        System.assertEquals(Null, addrList[0].Parent_Account__c);
        System.assertNotEquals(Null, addrList[0].Parent_Contact__c);
        System.assertEquals(True, addrList[0].Default_Address__c); 
        
        //Verify no Address record was created as child of the parent Account
        addrList = [SELECT ID 
                    FROM Address__c 
                    WHERE Parent_Account__c = :contact.AccountId];
        System.assertEquals(0, addrList.size()); 
        
        //Verify parent Admin Account has no Address info
        Account acc = [SELECT BillingStreet, BillingCity, Billing_County__c,
                        BillingState, BillingPostalCode, BillingCountry
                        FROM Account 
                        WHERE Id = :contact.AccountId];
        System.assertEquals(Null, acc.BillingStreet);
        System.assertEquals(Null, acc.BillingCity);
        System.assertEquals(Null, acc.Billing_County__c);
        System.assertEquals(Null, acc.BillingState);
        System.assertEquals(Null, acc.BillingPostalCode);
        if (!ADDR_Addresses_UTIL.isStateCountryPickListsEnabled) {
            System.assertEquals(Null, acc.BillingCountry);   
        }
    }
    
    /*********************************************************************************************************
    @description Create a new Contact record without populating its mailing fields. Update the new Admin 
    * Account's billing fields. 
    * Verify:
    * - New default Address record is created. 
    * - New default Address record's Parent_Account__c is populated and Parent_Contact__c is blank. 
    * - Contact's mailing fields are not populated and are blank. 
    **********************************************************************************************************/ 
    @isTest
    private static void noAdminAccountAddressToContactAddressPropagation() {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getCustomAdminAccRecTypeID(),
                                                                Accounts_Addresses_Enabled__c = UTIL_Describe.getCustomAdminAccRecTypeID() + ';',
                                                                Contacts_Addresses_Enabled__c = True,
                                                                Simple_Address_Change_Treated_as_Update__c = True);
        UTIL_CustomSettings_API.getSettingsForTests(hs);
        
        Contact newContact = UTIL_UnitTestData_TEST.getContact();
        newContact.LastName = 'Testerson'; 
        insert newContact;
        
        //Verify parent Account was automatically created
        newContact = [SELECT AccountId 
                        FROM Contact 
                        WHERE Id = :newContact.Id];
        System.assertNotEquals(Null, newContact.AccountId);
        
        //Update Admin Account's billing fields
        Account acc = [SELECT BillingStreet, BillingCity, Billing_County__c, 
                        BillingState, BillingPostalCode, BillingCountry
                        FROM Account 
                        WHERE Id = :newContact.AccountId];
        acc.BillingStreet = '123 main st';
        acc.BillingCity = 'Austin';
        acc.Billing_County__c = 'Bergen';
        acc.BillingState = 'Texas';
        acc.BillingPostalCode = '78701';
        acc.BillingCountry = 'United States';

        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update acc;
        Test.stopTest();
        
        //Verify child Address record was created
        List<Address__c> addrList = [SELECT Parent_Contact__c, Default_Address__c
                                        FROM Address__c 
                                        WHERE Parent_Account__c = :acc.Id]; 
        System.assertEquals(1, addrList.size());
        System.assertEquals(Null, addrList[0].Parent_Contact__c);
        System.assertEquals(True, addrList[0].Default_Address__c);
        
        //Verify child Contact's mailing fields are not populated
        newContact = [SELECT MailingStreet, MailingCity, Mailing_County__c, 
                        MailingState, MailingPostalCode, MailingCountry
                        FROM Contact 
                        WHERE Id = :newContact.Id];
        System.assertEquals(Null, newContact.MailingStreet);
        System.assertEquals(Null, newContact.MailingCity);
        System.assertEquals(Null, newContact.Mailing_County__c);
        System.assertEquals(Null, newContact.MailingState);
        System.assertEquals(Null, newContact.MailingPostalCode);
        if (!ADDR_Addresses_UTIL.isStateCountryPickListsEnabled) {
            System.assertEquals(Null, newContact.MailingCountry);   
        }
        
        addrList = [SELECT Id 
                    FROM Address__c 
                    WHERE Parent_Contact__c = :newContact.Id];
        System.assertEquals(0, addrList.size()); 
    }
  
    /*********************************************************************************************************
    @description Create x number of Contact records with its mailing fields populated.
    * Verify:
    * - X number of default Address records are created to match the x number of Contacts created. 
    * - Contact's mailing fields should match the mailing fields of the default Address records. 
    * - Account's billing fields should match the mailing fields of the default Address records. 
    **********************************************************************************************************/            
    @isTest
    private static void insertContactsNewDefaultAddresses() {            
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Contacts_Addresses_Enabled__c = True));

        Integer contactCount = 3;
        List<Contact> contactList = UTIL_UnitTestData_API.getMultipleTestContacts(contactCount);
        for (Contact contact : contactList) {
            contact.MailingStreet = '123 45th';
            contact.MailingCity = 'Seattle';
            contact.Mailing_County__c = 'Bergen';
        }
        Test.startTest();
        insert contactList;
        Test.stopTest();

        Map<Id, Contact> contactsById = new Map<Id, Contact>([SELECT Id, Name, MailingStreet, 
                                                                MailingCity, Mailing_County__c, MailingState, 
                                                                MailingPostalCode, MailingCountry, MailingLatitude, 
                                                                MailingLongitude, is_Address_Override__c, Current_Address__c 
                                                                FROM Contact]);
        System.assertEquals(contactCount, contactsById.size());
        
        List<Account> accList = [SELECT Id, BillingStreet, BillingCity, Billing_County__c
                                    FROM Account];
        for (Account acc : accList) {
            System.assertEquals('123 45th', acc.BillingStreet); 
            System.assertEquals('Seattle', acc.BillingCity); 
            System.assertEquals('Bergen', acc.Billing_County__c); 
        }
        
        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                        MailingCity__c, MailingCounty__c, Parent_Contact__c, 
                                        Latest_Start_Date__c, Latest_End_Date__c 
                                        FROM Address__c];
        System.assertEquals(contactCount, addrList.size());
        for (Address__c addr : addrList) {
            Contact contact = contactsById.get(addr.Parent_Contact__c);
            System.assertEquals(contact.MailingStreet, addr.MailingStreet__c);
            System.assertEquals(contact.MailingCity, addr.MailingCity__c);
            System.assertEquals(contact.Mailing_County__c, addr.MailingCounty__c);
            System.assertEquals(True, addr.Default_Address__c);
        }
    }
        
    /*********************************************************************************************************
    @description Update existing mailing fields on default Address records. 
    * Verify: 
    * - Contact's mailing fields are updated to match the mailing fields on default Address records.
    **********************************************************************************************************/            
    @isTest 
    private static void updateDefaultAddressMailingFields() {
        configSettings();

        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);

        for (Integer i = 0; i < contactsAddrs.addrs.size(); i++) {
            Address__c addr = contactsAddrs.addrs[i];
            addr.MailingStreet__c = 'New Street' + i;
            addr.MailingCity__c = 'New City' + i;
            addr.MailingCounty__c = 'New County' + i;
        }
        Test.startTest();
        update contactsAddrs.addrs;
        Test.stopTest();

        Map<Id, Contact> contactsById = new Map<Id, Contact>([SELECT Id, Name, MailingStreet, 
                                                            MailingCity, Mailing_County__c, 
                                                            is_Address_Override__c, Current_Address__c
                                                            FROM Contact]);
        for (Contact contact : contactsById.values()) {
            System.assert(contact.MailingStreet.contains('New Street'));
            System.assert(contact.MailingCity.contains('New City'));
            System.assert(contact.Mailing_County__c.contains('New County'));
            System.assertEquals(False, contact.is_Address_Override__c);
            System.assertNotEquals(Null, contact.Current_Address__c);
        }
    }
    
    /*********************************************************************************************************
    @description Delete existing default Address records.  
    * Verify: 
    * - Contact's mailing fields are cleared.
    * - Account's billing fields are cleared. 
    **********************************************************************************************************/            
    @isTest 
    private static void deleteDefaultAddressRecords() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);
        
        List<Account> accList = [SELECT Id, BillingStreet, BillingCity, 
                                    Billing_County__c
                                    FROM Account];
        
        for (Account account : accList) {
            System.assertNotEquals(Null, account.BillingStreet); 
            System.assertNotEquals(Null, account.BillingCity); 
            System.assertNotEquals(Null, account.Billing_County__c); 
        }
        
        Test.startTest();
        delete contactsAddrs.addrs;
        Test.stopTest();

        //Verify that the Contact mailing fields are cleared
        Map<Id, Contact> contactsById = new Map<Id, Contact>([SELECT Id, Name, MailingStreet, 
                                                                MailingCity, Mailing_County__c, MailingState, 
                                                                Current_Address__c 
                                                                FROM Contact]);
        for (Contact contact : contactsById.values()) {
            System.assertEquals(Null, contact.MailingStreet);
            System.assertEquals(Null, contact.MailingCity);
            System.assertEquals(Null, contact.Mailing_County__c);
            System.assertEquals(Null, contact.MailingState);
            System.assertEquals(Null, contact.Current_Address__c);
        }
        
        accList = [SELECT Id, BillingStreet, BillingCity, 
                                    Billing_County__c
                                    FROM Account];
        for (Account acc : accList) {
            System.assertEquals(Null, acc.BillingStreet); 
            System.assertEquals(Null, acc.BillingCity); 
            System.assertEquals(Null, acc.Billing_County__c); 
        }
    }

    /*********************************************************************************************************
    @description Delete existing non-default override Addresses.  
    * Verify: 
    * - Contact's mailing fields are updated to match the mailing fields of the default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void deleteNonDefaultOverrideAddress() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);
        
        List<Address__c> addrs = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            addrs[i].Parent_Contact__c = contactsAddrs.contacts[i].Id;
            addrs[i].Default_Address__c = False;
            addrs[i].MailingStreet__c = 'override' + i;
            addrs[i].MailingCity__c = 'override' + i;
            addrs[i].MailingCounty__c = 'override' + i;
        }
        turnOnAllAddrTriggers();
        insert addrs;
        
        //Set the Contacts' address override
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            Contact contact = contactsAddrs.contacts[i];
            contact.Current_Address__c = addrs[i].Id;
            contact.is_Address_Override__c = True;
        }
        turnOnAllAddrTriggers();
        update contactsAddrs.contacts;   
        
        Map<Id, Contact> contactsById = new Map<Id, Contact>([SELECT Id, Name, MailingStreet, 
                                                            MailingCity, Mailing_County__c
                                                            FROM Contact]);
        
        for (Contact con : contactsById.values()) {
            System.assert(con.MailingStreet.contains('override')); 
            System.assert(con.MailingCity.contains('override')); 
            System.assert(con.Mailing_County__c.contains('override')); 
        }
        
        //Delete the override Addresses
        turnOnAllAddrTriggers();
        Test.startTest();
        delete addrs;
        Test.stopTest();

        //Verify that the Contact's mailing fields are set to the default Address's mailing fields 
        contactsById = new Map<Id, Contact>([SELECT Id, Name, MailingStreet, 
                                                MailingCity, Mailing_County__c, 
                                                is_Address_Override__c, Current_Address__c 
                                                FROM Contact]);
        for (Contact contact : contactsById.values()) {
            System.assert(contact.MailingStreet.contains('Street'));
            System.assert(contact.MailingCity.contains('City')); 
            System.assert(contact.Mailing_County__c.contains('County')); 
            System.assertEquals(False, contact.is_Address_Override__c);
            System.assertNotEquals(Null, contact.Current_Address__c);                
        }
    }

    /*********************************************************************************************************
    @description Update existing default Address record to non default by setting Default_Address__c to false. 
    * Verify:
    * - Contact's mailing fields are cleared. 
    **********************************************************************************************************/            
    @isTest
    private static void updateDefaultAddressToNonDefaultAddress() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);

        for (Integer i = 0; i < contactsAddrs.addrs.size(); i++) {
            Address__c addr = contactsAddrs.addrs[i];
            addr.Default_Address__c = False;
        }
        Test.startTest();
        update contactsAddrs.addrs;
        Test.stopTest();

        Map<Id, Contact> contactsById = new Map<Id, Contact>([SELECT Id, MailingStreet, MailingCity, 
                                                                Mailing_County__c, Current_Address__c, is_Address_Override__c
                                                                FROM Contact]);
        for (Contact contact : contactsById.values()) {
            System.assertEquals(Null, contact.MailingStreet); 
            System.assertEquals(Null, contact.MailingCity); 
            System.assertEquals(Null, contact.Mailing_County__c); 
            System.assertEquals(False, contact.is_Address_Override__c);
            System.assertEquals(Null, contact.Current_Address__c); 
        }
    }

    /*********************************************************************************************************
    @description Create new non default Address record and associate to one of the Contact records.
    * Enable is_Address_Override__c on the Contact who recently had a new non default Address record. 
    * Update mailing fields on default Address record. 
    * Verify:
    * - Contact whose is_Address_Override__c is enabled, its mailing fields should not be updated to match
    * the non default Address record. Its mailing fields should be updated to match the newly updated field
    * of the default Address record's mailing fields. 
    * - Contact whose is_Address_Override__c is disabled, its mailing fields should be updated to match the 
    * default Address record's mailing fields. 
    **********************************************************************************************************/            
    @isTest
    private static void setContactAddrOverrideAndUpdateDefaultAddressRecord() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);
        
        List<Address__c> newOverrideAddrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1); 
        newOverrideAddrList[0].MailingStreet__c = 'street override';
        newOverrideAddrList[0].MailingCity__c = 'city override';
        newOverrideAddrList[0].MailingCounty__c = 'county override';
        newOverrideAddrList[0].Default_Address__c = False;
        newOverrideAddrList[0].Parent_Contact__c = contactsAddrs.contacts[1].Id;        
        turnOnAllAddrTriggers();
        insert newOverrideAddrList;
        
        //Set Contact's address override
        contactsAddrs.contacts[1].Current_Address__c = newOverrideAddrList[0].Id;
        contactsAddrs.contacts[1].is_Address_Override__c = True;
        turnOnAllAddrTriggers();
        update contactsAddrs.contacts;
        
        for (Contact con : contactsAddrs.contacts) {
            if (con.is_Address_Override__c) {
                System.assertNotEquals('street override', con.MailingStreet); 
                System.assert(con.MailingStreet.contains('Street'));
            }
        }

        //Update the default Address for both Contacts
        contactsAddrs.addrs[0].MailingStreet__c = 'New Street';
        contactsAddrs.addrs[0].MailingCity__c = 'New City';
        contactsAddrs.addrs[0].MailingCounty__c = 'New County';
        contactsAddrs.addrs[1].MailingStreet__c = 'New Street';
        contactsAddrs.addrs[1].MailingCity__c = 'New City';
        contactsAddrs.addrs[1].MailingCounty__c = 'New County';

        turnOnAllAddrTriggers();
        Test.startTest();
        update contactsAddrs.addrs;
        Test.stopTest();
        
        Map<Id, Contact> contactsById = new Map<Id, Contact>([SELECT Id, Name, MailingStreet, 
                                                                MailingCity, Mailing_County__c, Current_Address__c, 
                                                                is_Address_Override__c
                                                                FROM Contact]);
        for (Contact contact : contactsById.values()) {
            if (contact.is_Address_Override__c) { 
                System.assert(!contact.MailingStreet.contains('street override'));
                System.assertEquals('New Street', contact.MailingStreet);
                System.assert(!contact.MailingCity.contains('city override'));
                System.assertEquals('New City', contact.MailingCity);
                System.assert(!contact.Mailing_County__c.contains('county override'));
                System.assertEquals('New County', contact.Mailing_County__c);
                System.assertNotEquals(contact.Current_Address__c, newOverrideAddrList[0].Id);            
            } else { 
                System.assert(contact.MailingStreet.contains('New Street'));
                System.assert(contact.MailingCity.contains('New City'));
                System.assert(contact.Mailing_County__c.contains('New County'));
                System.assertNotEquals(Null, contact.Current_Address__c);
            }
        }
    }

    /*********************************************************************************************************
    @description Insert new default Address record to an existing Contact with existing default Address record. 
    * Verify: 
    * - New default Address record is created.
    * - Existing Contact's mailing fields are updated to match the mailing fields from the newly created default 
    * Address record. 
    * - Previous default Address record is no longer marked as default. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNewDefaultAddress() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);
        
        List<Address__c> addrs = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            addrs[i].Parent_Contact__c = contactsAddrs.contacts[i].Id;
            addrs[i].Default_Address__c = True;
            addrs[i].MailingStreet__c = 'New Default Street' + i;
            addrs[i].MailingCity__c = 'New Default City' + i;
            addrs[i].MailingCounty__c = 'New Default County' + i;
        }
        turnOnAllAddrTriggers();
        Test.startTest();
        insert addrs;
        turnOnAllAddrTriggers();        
        Test.stopTest();

        Map<Id, Contact> contactsById = new Map<Id, Contact>([SELECT Id, Name, MailingStreet, 
                                                                MailingCity, Mailing_County__c, is_Address_Override__c, 
                                                                Current_Address__c 
                                                                FROM Contact]);
        for (Contact contact : contactsById.values()) {
            System.assert(contact.MailingStreet.contains('New Default Street'));
            System.assert(contact.MailingCity.contains('New Default City'));
            System.assert(contact.Mailing_County__c.contains('New Default County'));
            System.assertEquals(False, contact.is_Address_Override__c);
            System.assertNotEquals(Null, contact.Current_Address__c);
        }
        
        //Verify the previous addresses got Default cleared.
        //And verify latest start date and latest end date appropriately set.
        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                        MailingCounty__c, Parent_Contact__c, Latest_Start_Date__c, 
                                        Latest_End_Date__c
                                        FROM Address__c];
        System.assertEquals(4, addrList.size());
        for (Address__c addr : addrList) {
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
    @description Insert new default Address record to existing Contact with existing default Address record. 
    * Update/reset previous old default Address record Default_Address__c to true and update its mailing fields.
    * Verify: 
    * - Newly created default Address record is no longer marked as Default Address. 
    * - Previous existing default Address record is still marked as Default Address record and its mailing fields are 
    * updated.
    * - Existing Contact's mailing fields are updated to match the mailing fields of the existing default Address record.
    **********************************************************************************************************/            
    @isTest
    private static void insertNewDefaultAddressAndResetPreviousDefaultAddress() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);
        List<Address__c> originalAddrList = contactsAddrs.addrs;

        ADDR_Addresses_TDTM.addressIdsInserted = new Set<Id>();
        List<Address__c> newAddrList = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            newAddrList[i].Parent_Contact__c = contactsAddrs.contacts[i].Id;
            newAddrList[i].Default_Address__c = True;
            newAddrList[i].MailingStreet__c = 'New Default Street' + i;
            newAddrList[i].MailingCity__c = 'New Default City' + i;
            newAddrList[i].MailingCounty__c = 'New Default County' + i;
        }
        turnOnAllAddrTriggers();
        insert newAddrList;
        
        //Update original default Address record
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            originalAddrList[i].Default_Address__c = True;
            originalAddrList[i].MailingStreet__c = 'Original Default Street' + i;
            originalAddrList[i].MailingCity__c = 'Original Default City' + i;
            originalAddrList[i].MailingCounty__c = 'Original Default County' + i;
        }
        turnOnAllAddrTriggers();
        ADDR_Addresses_TDTM.addressIdsUpdated = new Set<Id>();
        Test.startTest();
        update originalAddrList;
        turnOnAllAddrTriggers();
        Test.stopTest();
        
        //Verify the new additional Address record's Default_Address__c is cleared
        //and verify latest start date and latest end date appropriately set
        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                        Parent_Contact__c, Latest_Start_Date__c, Latest_End_Date__c 
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
    @description Update existing Contact's mailing fields. 
    * Verify:
    * - New default Address record is created. 
    * - Contact's mailing field matches the mailing fields of the newly created default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void updateExistingContactMailingFields() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(4);

        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            contactsAddrs.contacts[i].MailingStreet = 'final Street Edit';
            contactsAddrs.contacts[i].MailingCity = 'final City Edit';
            contactsAddrs.contacts[i].Mailing_County__c = 'final County Edit';
        }
        turnOnAllAddrTriggers();
        Test.startTest();
        update contactsAddrs.contacts;
        Test.stopTest();
        
        Map<Id, Contact> contactsById = new Map<Id, Contact>([SELECT Id, Name, MailingStreet, 
                                                                MailingCity, Mailing_County__c, is_Address_Override__c, 
                                                                Current_Address__c 
                                                                FROM Contact]);
        for (Contact contact : contactsById.values()) {
            System.assert(contact.MailingStreet.contains('final Street Edit'));
            System.assert(contact.MailingCity.contains('final City Edit'));
            System.assertEquals(False, contact.is_Address_Override__c);
            System.assertNotEquals(Null, contact.Current_Address__c);
        }

        //Verify the previous Address records Default_Address__c is cleared
        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                        Parent_Contact__c 
                                        FROM Address__c];
        //Each set of edits creates a new Address record 
        System.assertEquals(8, addrList.size());
        for (Address__c addr : addrList) {
            if (addr.MailingStreet__c.contains('final Street Edit')) {
                System.assertEquals(True, addr.Default_Address__c); 
            } else {
                System.assertEquals(False, addr.Default_Address__c); 
            }
        }                
    }

    /*********************************************************************************************************
    @description Update existing Contact's mailing fields and enable is_Address_Override__c. 
    * Verify:
    * - New non default Address record is created. 
    * - Contact's mailing fields are updated to match the mailing fields of the newly created non default Address record. 
    * - Existing default Address record is still marked as default. 
    **********************************************************************************************************/            
    @isTest
    private static void updateContactMailingFieldsAndMarkedOverride () {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);

        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            contactsAddrs.contacts[i].MailingStreet = 'Direct Street Edit';
            contactsAddrs.contacts[i].MailingCity = 'Direct City Edit';
            contactsAddrs.contacts[i].Mailing_County__c = 'Direct County Edit';
            contactsAddrs.contacts[i].is_Address_Override__c = True;
        }
        turnOnAllAddrTriggers();
        Test.startTest();
        update contactsAddrs.contacts;
        Test.stopTest();
        
        Map<Id, Contact> contactsById = new Map<Id, Contact>([SELECT Id, Name, MailingStreet, 
                                                                MailingCity, Mailing_County__c, is_Address_Override__c, 
                                                                Current_Address__c 
                                                                FROM Contact]);
        System.assertEquals('Direct Street Edit', contactsById.values()[0].MailingStreet);
        System.assertEquals('Direct City Edit', contactsById.values()[0].MailingCity);
        System.assertEquals('Direct County Edit', contactsById.values()[0].Mailing_County__c);
        System.assertEquals(True, contactsById.values()[0].is_Address_Override__c);
        System.assertEquals('Direct Street Edit', contactsById.values()[1].MailingStreet);
        System.assertEquals('Direct City Edit', contactsById.values()[1].MailingCity);
        System.assertEquals('Direct County Edit', contactsById.values()[1].Mailing_County__c);
        System.assertEquals(True, contactsById.values()[1].is_Address_Override__c);

        //Verify the previous default Address records are still marked default Address
        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c, Parent_Contact__c 
                                        FROM Address__c];
        System.assertEquals(4, addrList.size());
        for (Address__c addr : addrList) {
            if (addr.MailingStreet__c.contains('Direct Street Edit')) {
                System.assertEquals(False, addr.Default_Address__c); 
            } else {
                System.assertEquals(True, addr.Default_Address__c); 
            }
        }
    }

    /*********************************************************************************************************
    @description Update Contact's mailing fields format only or update single mailing field. 
    * Verify: 
    * - No new default or non default Addres records created. 
    * - Existing default Address record's mailing fields are updated to match the updates made on Contact's 
    * mailing fields. 
    **********************************************************************************************************/            
    @isTest
    private static void updateContactMailingFieldsForSimpleAddrChangeTreatedAsUpdate() { 
        configSettings();

        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);

        //NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            contactsAddrs.contacts[i].MailingStreet = 'Direct Street Edit';
        }
        turnOnAllAddrTriggers();
        update contactsAddrs.contacts;

        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            contactsAddrs.contacts[i].MailingState = 'Washington';
        }
        update contactsAddrs.contacts;
        
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            contactsAddrs.contacts[i].Mailing_County__c = 'COUNTY';
        }
        update contactsAddrs.contacts;
        
        //Whitespace and casing should not count as a real edit
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            contactsAddrs.contacts[i].MailingStreet = ' direct street  edit ';  
            contactsAddrs.contacts[i].MailingState = 'Oregon';
        }
        update contactsAddrs.contacts;
        
        //Change casing only 
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            contactsAddrs.contacts[i].MailingStreet = ' DIRECT STREET  EDIT '; 
            contactsAddrs.contacts[i].Mailing_County__c = ' COUNTY  '; 
        }
        Test.startTest();
        update contactsAddrs.contacts;
        Test.stopTest();
        
        Map<Id, Contact> contactsById = new Map<Id, Contact>([SELECT Id, Name, MailingStreet,
                                                                is_Address_Override__c, Current_Address__c 
                                                                FROM Contact]);
        for (Contact contact : contactsById.values()) {
            System.assert(contact.MailingStreet.equals('DIRECT STREET  EDIT'));
            System.assertEquals(False, contact.is_Address_Override__c);
            System.assertNotEquals(Null, contact.Current_Address__c);
        }

        //Verify that no new Address record was created
        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c, Parent_Contact__c 
                                        FROM Address__c];
        System.assertEquals(2, addrList.size());
        for (Address__c addr : addrList) {
            System.assert(addr.MailingStreet__c.equals('DIRECT STREET  EDIT'));
        }
        
        //Test that changing the case from the Contact updates all Address
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            Contact contact = contactsAddrs.contacts[i];
            contact.MailingStreet = 'direct street  edit';
        }
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        turnOnAllAddrTriggers();
        update contactsAddrs.contacts;
        
        contactsById = new Map<Id, Contact>([SELECT Id, Name, MailingStreet, MailingCity, 
                                                MailingState, is_Address_Override__c, Current_Address__c 
                                                FROM Contact]);
        for (Contact contact : contactsById.values()) {
            System.assert(contact.MailingStreet.equals('direct street  edit'));
            System.assertEquals(False, contact.is_Address_Override__c);
            System.assertNotEquals(Null, contact.Current_Address__c);
        }

        //Verify that no new Address record was created
        addrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                        Parent_Contact__c 
                        FROM Address__c];
        System.assertEquals(2, addrList.size());
        for (Address__c addr : addrList) {
            System.assert(addr.MailingStreet__c.equals('direct street  edit'));
        }                   
    }
    
    /*********************************************************************************************************
    @description Create an Address record with no Parent record. 
    * Verify: 
    * - Runtime error. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNewAddressWithNoParentRecord() {        
        List<Address__c> addrList = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        
        for (Integer i = 0; i < addrList.size(); i++) {
            System.assertEquals(Null, addrList[i].Parent_Contact__c);
        }
        
        try {
            insert addrList;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(Label.addrValidParentObjects));
            return;
        }
        System.assert(False); 
    }
 
    /*********************************************************************************************************
    @description Update existing Contact's mailing fields with existing mailing field values from default Address
    * record. Essentially, we're updating the Contact's mailing fields with duplicate mailing values. 
    * Verify:
    * - No new default Address record is created. 
    **********************************************************************************************************/            
    @isTest
    private static void updateContactMailingFieldsWithDuplicateAddress() {
        configSettings();

        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);

        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            contactsAddrs.contacts[i].MailingStreet = contactsAddrs.addrs[i].MailingStreet__c;
            contactsAddrs.contacts[i].MailingCity = contactsAddrs.addrs[i].MailingCity__c;
            contactsAddrs.contacts[i].Mailing_County__c = contactsAddrs.addrs[i].MailingCounty__c;
            contactsAddrs.contacts[i].MailingState = contactsAddrs.addrs[i].MailingState__c;
            contactsAddrs.contacts[i].MailingPostalCode = contactsAddrs.addrs[i].MailingPostalCode__c;
            contactsAddrs.contacts[i].MailingCountry = contactsAddrs.addrs[i].MailingCountry__c;
        }        
        turnOnAllAddrTriggers();
        Test.startTest();
        update contactsAddrs.contacts;
        Test.stopTest();
        
        //Verify that we don't have new Address records
        List<Address__c> addrList = [SELECT Id 
                                        FROM Address__c];
        System.assertEquals(2, addrList.size());
    }

    /*********************************************************************************************************
    @description Update existing Contact's mailing fields with existing mailing fields values from a non default 
    * Address record.
    * Verify:
    * - Non default Address record is now marked as default Address record.
    * - No new default Address record is created.
    * - Previous default Address record is no longer marked as default. 
    **********************************************************************************************************/            
    @isTest
    private static void updateContactMailingFieldsWithNonDefaultAddressMailingFields() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);

        List<Address__c> newAddrList = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            newAddrList[i].Parent_Contact__c = contactsAddrs.contacts[i].Id;
            newAddrList[i].Default_Address__c = False;
            newAddrList[i].MailingStreet__c = 'New Street' + i;
            newAddrList[i].MailingCity__c = 'New City' + i;
            newAddrList[i].MailingCounty__c = 'New County' + i;
        }
        turnOnAllAddrTriggers();
        insert newAddrList;

        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            contactsAddrs.contacts[i].MailingStreet = newAddrList[i].MailingStreet__c;
            contactsAddrs.contacts[i].MailingCity = newAddrList[i].MailingCity__c;
            contactsAddrs.contacts[i].Mailing_County__c = newAddrList[i].MailingCounty__c;
            contactsAddrs.contacts[i].MailingState = newAddrList[i].MailingState__c;
            contactsAddrs.contacts[i].MailingPostalCode = newAddrList[i].MailingPostalCode__c;
            contactsAddrs.contacts[i].MailingCountry = newAddrList[i].MailingCountry__c;
        }        
        turnOnAllAddrTriggers();
        Test.startTest();
        update contactsAddrs.contacts;
        Test.stopTest();
        
        Map<Id, Contact> contactsById = new Map<Id, Contact>([SELECT Id, Name, MailingStreet, MailingCity, 
                                                            Mailing_County__c, is_Address_Override__c, Current_Address__c 
                                                            FROM Contact]);
        for (Contact contact : contactsById.values()) {
            System.assert(contact.MailingStreet.contains('New Street'));
            System.assert(contact.MailingCity.contains('New City'));
            System.assert(contact.Mailing_County__c.contains('New County'));
            System.assertEquals(False, contact.is_Address_Override__c);
            System.assertNotEquals(Null, contact.Current_Address__c);
        }
        
        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                    Parent_Contact__c, Latest_Start_Date__c, Latest_End_Date__c 
                                    FROM Address__c];
        System.assertEquals(4, addrList.size());
        for (Address__c addr : addrList) {
            if (addr.MailingStreet__c.contains('New Street')) {
                System.assertEquals(True, addr.Default_Address__c); 
            } else {
                System.assertEquals(False, addr.Default_Address__c); 
            }
        }
    }

    /*********************************************************************************************************
    @description Update existing Contact's MailingStreet with multiline Street value.
    * Verify:
    * - New default Address record is created and multiline street is populated into MailingStreet__c and MailingStreet2__c. 
    **********************************************************************************************************/            
    @isTest
    private static void updateContactMailingStreetWithMultiLineStreetValue() {
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Contacts_Addresses_Enabled__c = True));

        List<Contact> contacts = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        for (Contact contact : contacts) {
            contact.MailingStreet = 'new street\r\nsecond line';
            contact.MailingCity = 'new city';
        }
        Test.startTest();
        insert contacts; 
        Test.stopTest();       
        
        //Verify the Address record contains split street 
        List<Address__c> addrList = [SELECT Id, MailingStreet__c, MailingStreet2__c, 
                                        Formula_MailingStreetAddress__c 
                                        FROM Address__c];
        System.assertEquals(2, addrList.size());
        for (Address__c addr : addrList) {
            System.assertEquals('new street', addr.MailingStreet__c);
            System.assertEquals('second line', addr.MailingStreet2__c);
            System.assertEquals('new street<br>second line<br>new city,', addr.Formula_MailingStreetAddress__c);
        }

        Map<Id, Contact> contactsById = new Map<Id, Contact>([SELECT Id, Name, MailingStreet,
                                                                is_Address_Override__c, Current_Address__c 
                                                                FROM Contact]);
        for (Contact contact : contactsById.values()) {
            System.assertEquals('new street\r\nsecond line', contact.MailingStreet);
            System.assertEquals(False, contact.is_Address_Override__c);
            System.assertNotEquals(Null, contact.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Insert new default Address record with multiline Street value. 
    * Verify:
    * - New default Address record is created with multiline Street fields populated.
    * - Existing Contact's mailing fields are updated and Address record's multiline street fields are combined 
    * into MailingStreet on Contact record. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNewDefaultAddressWithMultiStreetValue() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);
        
        List<Address__c> newAddrList = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            newAddrList[i].Parent_Contact__c = contactsAddrs.contacts[i].Id;
            newAddrList[i].Default_Address__c = True;
            newAddrList[i].MailingStreet__c = 'New Default Street';
            newAddrList[i].MailingStreet2__c = 'Second Line';
            newAddrList[i].MailingCity__c = 'New Default City' + i;
        }
        turnOnAllAddrTriggers();
        Test.startTest();
        insert newAddrList;
        turnOnAllAddrTriggers();        
        Test.stopTest();

        Map<Id, Contact> contactsById = new Map<Id, Contact>([SELECT Id, Name, MailingStreet
                                                                FROM Contact]);
        for (Contact contact : contactsById.values()) {
            System.assertEquals('New Default Street\r\nSecond Line', contact.MailingStreet);
            System.assertEquals('New Default Street\r\nSecond Line', contact.MailingStreet);
        }   
    }

    /*********************************************************************************************************
    @description Update existing Contact record's mailing fields without existing default Address records.
    * Verify:
    * - New default Address is created
    * - Contact's mailing fields matches the mailing fields of the newly created default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void updateContactMailingFieldsWithoutExistingAddressRecord() {         
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Contacts_Addresses_Enabled__c = True));

        Integer contactCount = 3;
        List<Contact> contactList = UTIL_UnitTestData_API.getMultipleTestContacts(contactCount);
        insert contactList;
        
        for (Contact contact : contactList) {
            contact.MailingStreet = '123 45th';
            contact.MailingCity = 'Seattle';
            contact.Mailing_County__c = 'Bergen'; 
        }
        Test.startTest();
        turnOnAllAddrTriggers();
        update contactList;
        Test.stopTest();

        contactList = [SELECT Id, Name, MailingStreet, 
                            MailingCity, Mailing_County__c, Current_Address__c 
                            FROM Contact];
        System.assertEquals(contactCount, contactList.size());
        
        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                        MailingCity__c, MailingCounty__c
                                        FROM Address__c];
        System.assertEquals(contactCount, addrList.size());      
        for (Integer i = 0; i < contactCount; i++) {
            Contact contact = contactList[i];
            Address__c addr = addrList[i];
            System.assertEquals(contact.MailingStreet, addr.MailingStreet__c);
            System.assertEquals(contact.MailingCity, addr.MailingCity__c);
            System.assertEquals(contact.Mailing_County__c, addr.MailingCounty__c);
            System.assertNotEquals(Null, contact.MailingStreet);
            System.assertNotEquals(Null, contact.MailingCity);
            System.assertEquals(True, addr.Default_Address__c);
            System.assertNotEquals(Null, contact.Current_Address__c);
        }
    }
    
    /*********************************************************************************************************
    @description Insert new default Address records and associate to existing Contact record without existing 
    * default Address record. 
    * Verify:
    * - New default Address record is created and associated to the existing Contact record.
    * - Existing Contact's mailing fields matches the mailing fields of the newly created default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNewDefaultAddressOnExistingContact() {           
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Contacts_Addresses_Enabled__c = True));

        List<Contact> contactList = UTIL_UnitTestData_API.getMultipleTestContacts(3);
        insert contactList;

        List<Address__c> newAddrList = UTIL_UnitTestData_API.getMultipleTestAddresses(contactList.size());
        for (Integer i = 0; i < contactList.size(); i++) {
            newAddrList[i].Parent_Contact__c = contactList[i].Id;
            newAddrList[i].Default_Address__c = True;
        }
        turnOnAllAddrTriggers();
        insert newAddrList;
        turnOnAllAddrTriggers();

        contactList = [SELECT Id, Name, MailingStreet, 
                        MailingCity, Mailing_County__c, Current_Address__c 
                        FROM Contact];
        System.assertEquals(3, contactList.size());
        
        newAddrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                        MailingCity__c, MailingCounty__c
                        FROM Address__c];
        System.assertEquals(3, newAddrList.size());
        for (Integer i = 0; i < contactList.size(); i++) {
            Contact contact = contactList[i];
            Address__c addr = newAddrList[i];
            System.assertEquals(contact.MailingStreet, addr.MailingStreet__c);
            System.assertEquals(contact.MailingCity, addr.MailingCity__c);
            System.assertEquals(contact.Mailing_County__c, addr.MailingCounty__c);
            System.assertNotEquals(Null, contact.MailingStreet);
            System.assertNotEquals(Null, contact.MailingCity);
            System.assertEquals(True, addr.Default_Address__c);
            System.assertEquals(addr.Id, contact.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Create Contact record with populated mailing fields when the setting for Address Mgmt is disabled. 
    * Verify:
    * - No new Address record is created.
    * - Contact record is created and its mailing fields are populated except Current_Address__c. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNewContactWithMailingFieldsWithDisabledContactAddressSetting() {        
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Contacts_Addresses_Enabled__c = False));

        List<Contact> contactList = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        for (Contact contact : contactList) {
            contact.MailingStreet = 'new street';
            contact.MailingCity = 'new city';
            contact.Mailing_County__c = 'new county'; 
        }
        insert contactList; 
        
        List<Contact> queryContacts = [SELECT Id FROM Contact WHERE Id IN :contactList]; 
        System.assertEquals(2, queryContacts.size()); 
        
        Map<Id, Contact> contactsById = new Map<Id, Contact>([SELECT Id, is_Address_Override__c, Current_Address__c 
                                                                FROM Contact]);
        for (Contact contact : contactsById.values()) {
            System.assertEquals(False, contact.is_Address_Override__c);
            System.assertEquals(Null, contact.Current_Address__c);
        }
        
        //Verify no Address record was created
        List<Address__c> addrList = [SELECT Id 
                                        FROM Address__c];
        System.assertEquals(0, addrList.size());
    }
    
    /*********************************************************************************************************
    @description Clear Contact's mailing fields.  
    * Verify:
    * - Existing default Address is updated to non default. 
    * - No new Address record is created. 
    **********************************************************************************************************/            
    @isTest
    private static void clearContactMailingFields() {
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Contacts_Addresses_Enabled__c = True));
                
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(4);

        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            contactsAddrs.contacts[i].MailingStreet = Null;
            contactsAddrs.contacts[i].MailingCity = Null;
            contactsAddrs.contacts[i].Mailing_County__c = Null;
            contactsAddrs.contacts[i].MailingState = Null;
            contactsAddrs.contacts[i].MailingPostalCode = Null;
            contactsAddrs.contacts[i].MailingCountry = Null;
            if (ADDR_Addresses_UTIL.isStateCountryPickListsEnabled) {
                contactsAddrs.contacts[i].put('MailingStateCode', Null);
                contactsAddrs.contacts[i].put('MailingCountryCode', Null);
            }             
        }

        turnOnAllAddrTriggers();
        Test.startTest();
        update contactsAddrs.contacts;
        Test.stopTest();
        
        //Verify that no new Address record was created
        List<Address__c> addrList = [SELECT Default_Address__c 
                                    FROM Address__c];
        System.assertEquals(4, addrList.size());
        
        //Verify existing Default Address record is updated non default
        for (Integer i = 0; i < addrList.size(); i++) {
            System.assertEquals(False, addrList[i].Default_Address__c);
        }              
    }

    /*********************************************************************************************************
    @description Insert new Contact records one with MailingStreet and Primary Address Type populated, and 
    * a second Contact with only Primary Address Type populated. 
    * Verify:
    * - Only 1 new default Address record is created.
    * - No blank Address record is created.
    * - 2nd Contact whose mailing field were not populated but only Primary Address Type, has blank mailing fields. 
    **********************************************************************************************************/
    @isTest
    private static void insertNewContactWithOnlyPrimaryAddressType() {
        List<Contact> contactList = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        contactList[0].LastName = 'newConWithLastName'; 
        contactList[0].MailingStreet = 'new street';
        contactList[0].Primary_Address_Type__c = 'Home';
        contactList[1].Primary_Address_Type__c = 'Home';
        
        Test.startTest();
        insert contactList;
        Test.stopTest();
        
        contactList = [SELECT Id, LastName, MailingStreet
                        FROM Contact]; 
        for (Contact con : contactList) {
            if (con.LastName.contains('newConWithLastName')) {
                System.assertEquals('new street', con.MailingStreet); 
            } else {
                System.assertNotEquals('new street', con.MailingStreet); 
                System.assertEquals(Null, con.MailingStreet);
            }
        }
        
        List<Address__c> assertAddressList = [SELECT Id, Parent_Contact__c, Default_Address__c, 
                                                MailingStreet__c
                                                FROM Address__c];
        System.assertEquals(1, assertAddressList.size());
        System.assertEquals(contactList[0].Id, assertAddressList[0].Parent_Contact__c);
        System.assertEquals('new street', assertAddressList[0].MailingStreet__c);
        System.assertEquals(True, assertAddressList[0].Default_Address__c);
    }
}