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
    
    private static void configSettings() {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c(Contacts_Addresses_Enabled__c = true,
                                               Simple_Address_Change_Treated_as_Update__c = true);
        UTIL_CustomSettings_API.getSettingsForTests(hs);
    }
    
    public static void turnOnAllAddrTriggers() {
        ADDR_Contact_TDTM.turnOn();
        ADDR_Account_TDTM.turnOn();        
        ADDR_Addresses_TDTM.turnOn();
    }
    
    public static void turnOffAllAddrTriggers() {
        ADDR_Contact_TDTM.turnOff();
        ADDR_Account_TDTM.turnOff();        
        ADDR_Addresses_TDTM.turnOff();
    }
    
    @isTest
    public static void noContactToAccPropagation() {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c(
            Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
            Accounts_Addresses_Enabled__c = UTIL_Describe_API.getAdminAccRecTypeID() + ';',
            Contacts_Addresses_Enabled__c = true,
            Simple_Address_Change_Treated_as_Update__c = true);
        UTIL_CustomSettings_API.getSettingsForTests(hs);
        
        Contact contact = new Contact(LastName = 'Testerson', MailingStreet = '123 Main St', 
        MailingCity = 'Austin', MailingState = 'Texas', MailingPostalcode = '78701', MailingCountry = 'United States');
        Test.startTest();
        insert contact;
        Test.stopTest();
        
        //Verify parent account was automatically created
        contact = [select AccountID from Contact where ID = :contact.ID];
        System.assertNotEquals(null, contact.AccountID);
        
        //Verify child address record was created
        List<Address__c> addrs = [select Parent_Account__c from Address__c where Parent_Contact__c = :contact.ID]; 
        System.assertEquals(1, addrs.size());
        System.assertEquals(null, addrs[0].Parent_Account__c);
        
        //Verify no address record was created as child of the parent account
        addrs = [select ID from Address__c where Parent_Account__c = :contact.AccountID];
        System.assertEquals(0, addrs.size()); 
        
        //Verify parent account has no address info
        Account acc = [select BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
        from Account where ID = :contact.AccountID];
        System.assertEquals(null, acc.BillingStreet);
        System.assertEquals(null, acc.BillingState);
        System.assertEquals(null, acc.BillingPostalCode);
        if (!ADDR_Addresses_UTIL.isStateCountryPickListsEnabled) {
            System.assertEquals(null, acc.BillingCountry);   
        }
    }
    
    @isTest
    public static void noAccToContactPropagation() {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c(
            Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
            Accounts_Addresses_Enabled__c = UTIL_Describe_API.getAdminAccRecTypeID() + ';',
            Contacts_Addresses_Enabled__c = true,
            Simple_Address_Change_Treated_as_Update__c = true);
        UTIL_CustomSettings_API.getSettingsForTests(hs);
        
        Contact contact1 = new Contact(LastName = 'Testerson');
        insert contact1;
        
        //Verify parent account was automatically created
        contact1 = [select AccountID from Contact where ID = :contact1.ID];
        System.assertNotEquals(null, contact1.AccountID);
        
        //Give address info to account
        Account acc = [select BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
        from Account where ID = :contact1.AccountID];
        acc.BillingStreet = '123 main st';
        acc.BillingState = 'Texas';
        acc.BillingPostalCode = '78701';
        acc.BillingCountry = 'United States';

        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        Test.startTest();
        update acc;
        Test.stopTest();
        
        //Verify child address record was created
        List<Address__c> addrs = [select Parent_Contact__c from Address__c where Parent_Account__c = :acc.ID]; 
        System.assertEquals(1, addrs.size());
        System.assertEquals(null, addrs[0].Parent_Contact__c);
        
         //Verify child contact has no address info
        contact1 = [select MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
        from Contact where ID = :contact1.ID];
        System.assertEquals(null, contact1.MailingStreet);
        System.assertEquals(null, contact1.MailingState);
        System.assertEquals(null, contact1.MailingPostalCode);
        if (!ADDR_Addresses_UTIL.isStateCountryPickListsEnabled) {
            System.assertEquals(null, contact1.MailingCountry);   
        }
        
        //Verify no address record was created as child of the child contact
        addrs = [select ID from Address__c where Parent_Contact__c = :contact1.ID];
        System.assertEquals(0, addrs.size()); 
    }
  
    /*********************************************************************************************************
    @description Create N new Contacts with Mailing addresses 
    verify:
        N addresses created
        Contact address matches address object address
    **********************************************************************************************************/            
    @isTest
    public static void newRecordsWithAddrInfo() {            
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Contacts_Addresses_Enabled__c = true));
 
        Integer contactCount = 3;
        List<Contact> contacts = UTIL_UnitTestData_API.getMultipleTestContacts(contactCount);
        for (Contact contact : contacts) {
            contact.MailingStreet = '123 45th';
            contact.MailingCity = 'Seattle';
        }
        Test.startTest();
        insert contacts;
        Test.stopTest();

        // verify results
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        System.assertEquals(contactCount, mapAccIdAcc.size());
        
        List<Address__c> ListAddr = [select Id, Default_Address__c, MailingStreet__c, MailingCity__c, Parent_Contact__c, 
        Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        System.assertEquals(contactCount, ListAddr.size());
        
        for (Address__c addr : ListAddr) {
            Contact contact = mapAccIdAcc.get(addr.Parent_Contact__c);
            System.assertEquals(contact.MailingStreet, addr.MailingStreet__c);
            System.assertEquals(contact.MailingCity, addr.MailingCity__c);
            System.assertEquals(true, addr.Default_Address__c);
        }
    }
        
    /*********************************************************************************************************
    @description Update existing default Addresses.  
    verify: Contact Mailing address fields updated
    **********************************************************************************************************/            
    @isTest 
    public static void updateDefaultAddr() {
        configSettings();

        // this creates a default Address for each Contact
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);

        // now let's update the Addresses
        for (Integer i = 0; i < contactsAddrs.addrs.size(); i++) {
            Address__c addr = contactsAddrs.addrs[i];
            addr.MailingStreet__c = 'New Street' + i;
            addr.MailingCity__c = 'New City' + i;
        }
        Test.startTest();
        update contactsAddrs.addrs;
        Test.stopTest();
    
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c
        from Contact]);
        
        for (Contact contact : mapAccIdAcc.values()) {
            System.assert(contact.MailingStreet.contains('New Street'));
            System.assert(contact.MailingCity.contains('New City'));
            System.assertEquals(false, contact.is_Address_Override__c);
            System.assertNotEquals(null, contact.Current_Address__c);
        }
    }
    
    /*********************************************************************************************************
    @description Delete existing default Addresses.  
    verify: Contact Mailing address fields cleared.
    **********************************************************************************************************/            
    @isTest 
    static void deleteDefaultAddr() {
        configSettings();
        
        // this creates a default Address for each Contact
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);
       
        // now let's delete the Addresses
        Test.startTest();
        delete contactsAddrs.addrs;
        Test.stopTest();
    
        // verify that the Contact address fields are cleared
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact contact : mapAccIdAcc.values()) {
            System.assertEquals(null, contact.MailingStreet);
            System.assertEquals(null, contact.MailingCity);
        }
    }

    /*********************************************************************************************************
    @description Delete existing non-default override Addresses.  
    verify: Contact Mailing address fields not changed.
    **********************************************************************************************************/            
    @isTest
    static void deleteNonDefaultOverrideAddr() {
        configSettings();
        
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);
        
        // create additional addresses
        List<Address__c> addrs = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            addrs[i].Parent_Contact__c = contactsAddrs.contacts[i].Id;
            addrs[i].Default_Address__c = false;
            addrs[i].MailingStreet__c = 'override' + i;
            addrs[i].MailingCity__c = 'override' + i;
        }
        turnOnAllAddrTriggers();
        insert addrs;
        
        // set the Contacts' address overrides
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            Contact contact = contactsAddrs.contacts[i];
            contact.Current_Address__c = addrs[i].Id;
            contact.is_Address_Override__c = true;
        }
        turnOnAllAddrTriggers();
        update contactsAddrs.contacts;        
        
        // now let's delete the override Addresses
        turnOnAllAddrTriggers();
        Test.startTest();
        delete addrs;
        Test.stopTest();
    
        // verify that the Contact address fields went back to the default
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        UTIL_Debug.debug('****Contacts with address info: ' + JSON.serializePretty(mapAccIdAcc.values()));
        for (Contact contact : mapAccIdAcc.values()) {
            System.assert(contact.MailingStreet.contains('Street'));
            System.assert(contact.MailingCity.contains('City')); 
            System.assertEquals(false, contact.is_Address_Override__c);
            System.assertNotEquals(null, contact.Current_Address__c);                
        }
    }

    /*********************************************************************************************************
    @description Making an Address non-default. That is, the address is no longer the default one for the Contact.  
    verify: no change to Contact address
    **********************************************************************************************************/            
    @isTest
    public static void updateNonDefaultAddr() {
        configSettings();
        
        // this creates a default Address for each Contact
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);

        // now let's update the Addresses
        for (Integer i = 0; i < contactsAddrs.addrs.size(); i++) {
            Address__c addr = contactsAddrs.addrs[i];
            addr.Default_Address__c = false;
        }
        Test.startTest();
        update contactsAddrs.addrs;
        Test.stopTest();
    
        // verify that the Contact and Contacts don't share the same address and it's new for the Contact!
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c 
        from Contact]);
        
        for (Contact contact : mapAccIdAcc.values()) {
            System.assertEquals(null, contact.MailingStreet); //address information has been cleared because address is no longer the default
            System.assertEquals(null, contact.MailingCity); //address information has been cleared because address is no longer the default
            System.assertEquals(false, contact.is_Address_Override__c);
            System.assertEquals(null, contact.Current_Address__c); //Contact no longer has a current address, since address is no longer the defaults
        }
    }

    /*********************************************************************************************************
    @description Set Contact address override.  
    verify: Contact's address matches override
    **********************************************************************************************************/            
    @isTest
    public static void setAddrOverride() {
        configSettings();
        
        // this creates a default Address for the Contact
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);

        // create new non-default address
        Address__c addrNew = new Address__c();
        addrNew.MailingStreet__c = 'street override';
        addrNew.MailingCity__c = 'city override';
        addrNew.Default_Address__c = false;
        // assign it to the second Contact
        addrNew.Parent_Contact__c = contactsAddrs.contacts[1].Id;
        
        turnOnAllAddrTriggers();
        insert addrNew;
        
        // set Contact's address override
        contactsAddrs.contacts[1].Current_Address__c = addrNew.Id;
        contactsAddrs.contacts[1].is_Address_Override__c = true;
        
        turnOnAllAddrTriggers();
        update contactsAddrs.contacts[0];
    
        // now let's update the default Address for both Contacts
        contactsAddrs.addrs[0].MailingStreet__c = 'New Street';
        contactsAddrs.addrs[0].MailingCity__c = 'New City';
        contactsAddrs.addrs[1].MailingStreet__c = 'New Street';
        contactsAddrs.addrs[1].MailingCity__c = 'New City';

        turnOnAllAddrTriggers();
        Test.startTest();
        update contactsAddrs.addrs;
        Test.stopTest();
        
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact contact : mapAccIdAcc.values()) {
            // verify that the Contact address is override
            if (contact.is_Address_Override__c) { 
                System.assert(!contact.MailingStreet.contains('street override'));
                System.assert(!contact.MailingCity.contains('city override'));
                System.assertEquals(contact.Current_Address__c, addrNew.Id);            
            // verify that the Contact address is new
            } else { 
                System.assert(contact.MailingStreet.contains('New Street'));
                System.assert(contact.MailingCity.contains('New City'));
                System.assertNotEquals(null, contact.Current_Address__c);
            }
        }
    }

    /*********************************************************************************************************
    @description Insert new default addresses to Contact w/ existing default addresses  
    verify:
        Contact address matches new default
        old default addresses no longer marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewDefaultAddr() {
        configSettings();
        
        // this creates a default Address for each Contact
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);
        
        // create additional addresses
        List<Address__c> addrs = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            addrs[i].Parent_Contact__c = contactsAddrs.contacts[i].Id;
            addrs[i].Default_Address__c = true;
            addrs[i].MailingStreet__c = 'New Default Street' + i;
            addrs[i].MailingCity__c = 'New Default City' + i;
        }
        turnOnAllAddrTriggers();
        Test.startTest();
        insert addrs;
        turnOnAllAddrTriggers();        
        Test.stopTest();

        // verify that the Contact addresses are new
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact contact : mapAccIdAcc.values()) {
            System.assert(contact.MailingStreet.contains('New Default Street'));
            System.assert(contact.MailingCity.contains('New Default City'));
            System.assertEquals(false, contact.is_Address_Override__c);
            System.assertNotEquals(null, contact.Current_Address__c);
        }
        
        // verify the previous addresses got Default cleared.
        // and verify latest start date and latest end date appropriately set.
        List<Address__c> ListAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Contact__c, Latest_Start_Date__c, 
        Latest_End_Date__c from Address__c];
        System.assertEquals(4, ListAddr.size());
        for (Address__c addr : ListAddr) {
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
    @description Insert new default addresses to Contact with existing default addresses, and then go back  
    verify:
        Contact address matches original default
        new default addresses no longer marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewDefaultAddrAndReset() {
        configSettings();
        
        // this creates a default Address for each Contact
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);
        List<Address__c> ListAddrOriginal = contactsAddrs.addrs;
        
        // create additional addresses
        ADDR_Addresses_TDTM.addressIdsInserted = new Set<Id>();
        List<Address__c> addrs = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            addrs[i].Parent_Contact__c = contactsAddrs.contacts[i].Id;
            addrs[i].Default_Address__c = true;
            addrs[i].MailingStreet__c = 'New Default Street' + i;
            addrs[i].MailingCity__c = 'New Default City' + i;
        }
        turnOnAllAddrTriggers();
        insert addrs;
        
        // go back to original default addresses
        // added this extra set to test fix where we didn't use the correct default
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            ListAddrOriginal[i].Default_Address__c = true;
            ListAddrOriginal[i].MailingStreet__c = 'Original Default Street' + i;
            ListAddrOriginal[i].MailingCity__c = 'Original Default City' + i;
        }
        turnOnAllAddrTriggers();
        ADDR_Addresses_TDTM.addressIdsUpdated = new Set<Id>();
        Test.startTest();
        update ListAddrOriginal;
        turnOnAllAddrTriggers();
        Test.stopTest();
        
        // verify the additional addresses got Default cleared.
        // and verify latest start date and latest end date appropriately set.
        List<Address__c> ListAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Contact__c, Latest_Start_Date__c, 
        Latest_End_Date__c from Address__c];
        System.assertEquals(4, ListAddr.size());
        for (Address__c addr : ListAddr) {
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
        Contacts get new Address
    **********************************************************************************************************/            
    @isTest
    public static void updateAddrNew() {
        configSettings();
        
        // this creates a default Address for each Contact
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(4);

        // modify some of the Contact addresses directly
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            contactsAddrs.contacts[i].MailingStreet = 'final Street Edit';
            contactsAddrs.contacts[i].MailingCity = 'final City Edit';
        }
        turnOnAllAddrTriggers();
        Test.startTest();
        update contactsAddrs.contacts;
        Test.stopTest();
        
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact contact : mapAccIdAcc.values()) {
            System.assert(contact.MailingStreet.contains('final Street Edit'));
            System.assert(contact.MailingCity.contains('final City Edit'));
            System.assertEquals(false, contact.is_Address_Override__c);
            System.assertNotEquals(null, contact.Current_Address__c);
        }
 
         // verify the previous addresses got Default cleared.
        List<Address__c> addrs = [select Id, Default_Address__c, MailingStreet__c, Parent_Contact__c from Address__c];
        UTIL_Debug.debug('****All addresses created: ' + JSON.serializePretty(addrs));
        // each set of edits created a new address object 
        System.assertEquals(8, addrs.size());
        for (Address__c addr : addrs) {
            boolean fNewDefault = (addr.MailingStreet__c.contains('final Street Edit'));
            System.assertEquals(fNewDefault, addr.Default_Address__c);
            System.assertEquals(!fNewDefault, !addr.Default_Address__c);
        }                
    }

    /*********************************************************************************************************
    @description
        update Address' Mailing address and mark it as override, to cause creation of new non-default Address object  
    verify:
        new Address created
        original Addresses still default    
    **********************************************************************************************************/            
    @isTest
    public static void updateAddrMarkOverride() {
        configSettings();
        
        // this creates a default Address for each Contact
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);

        // modify the Contact addresses directly, and set override
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            contactsAddrs.contacts[i].MailingStreet = 'Direct Street Edit';
            contactsAddrs.contacts[i].MailingCity = 'Direct City Edit';
            contactsAddrs.contacts[i].is_Address_Override__c = true;
        }
        turnOnAllAddrTriggers();
        Test.startTest();
        update contactsAddrs.contacts;
        Test.stopTest();
        
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        System.assertEquals('Direct Street Edit', mapAccIdAcc.values()[0].MailingStreet);
        System.assertEquals('Direct City Edit', mapAccIdAcc.values()[0].MailingCity);
        System.assertEquals(true, mapAccIdAcc.values()[0].is_Address_Override__c);
        System.assertEquals('Direct Street Edit', mapAccIdAcc.values()[1].MailingStreet);
        System.assertEquals('Direct City Edit', mapAccIdAcc.values()[1].MailingCity);
        System.assertEquals(true, mapAccIdAcc.values()[1].is_Address_Override__c);
 
         // verify the previous addresses didn't get Default cleared.
        List<Address__c> allAddrs = [select Id, Default_Address__c, MailingStreet__c, Parent_Contact__c from Address__c];
        System.assertEquals(4, allAddrs.size());
        UTIL_Debug.debug('****updateAddrMarkOverride all addrs: ' + JSON.serializePretty(allAddrs));
        for (Address__c addr : allAddrs) {
            boolean isNewEdit = (addr.MailingStreet__c.contains('Direct Street Edit'));
            System.assertNotEquals(isNewEdit, addr.Default_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Update Contact's Mailing address with just a case change, to cause an update to default Address object  
    verify:
        existing Default Address updated
        Contact has updated Address
    **********************************************************************************************************/            
    @isTest
    public static void updateAddrExistingCaseOnly() { 
        configSettings();
        
        // this creates a default Address for each Contact
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);

        // modify some of the Contact addresses directly
        // NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
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
            contactsAddrs.contacts[i].MailingStreet = ' direct street  edit ';  // whitespace and casing should not count as a real edit.
            contactsAddrs.contacts[i].MailingState = 'Oregon';
        }
        update contactsAddrs.contacts;

        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            contactsAddrs.contacts[i].MailingStreet = ' DIRECT STREET  EDIT ';  // only change casing.
        }
        Test.startTest();
        update contactsAddrs.contacts;
        Test.stopTest();
        
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact contact : mapAccIdAcc.values()) {
            System.assert(contact.MailingStreet.equals('DIRECT STREET  EDIT'));
            System.assertEquals(false, contact.is_Address_Override__c);
            System.assertNotEquals(null, contact.Current_Address__c);
        }
 
        // verify that no new address was created
        List<Address__c> ListAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Contact__c from Address__c];
        System.assertEquals(2, ListAddr.size());
        for (Address__c addr : ListAddr) {
            System.assert(addr.MailingStreet__c.equals('DIRECT STREET  EDIT'));
        }
        
        // now test that changing the case from the Contact updates all addresses
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            Contact contact = contactsAddrs.contacts[i];
            contact.MailingStreet = 'direct street  edit';
        }
        ADDR_Contact_TDTM.contactIdsUpdated = new Set<Id>();
        turnOnAllAddrTriggers();
        update contactsAddrs.contacts;
        
        // verify that the Contact address
        mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact contact : mapAccIdAcc.values()) {
            System.assert(contact.MailingStreet.equals('direct street  edit'));
            System.assertEquals(false, contact.is_Address_Override__c);
            System.assertNotEquals(null, contact.Current_Address__c);
        }
 
        // verify that no new address was created
        ListAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Contact__c from Address__c];
        System.assertEquals(2, ListAddr.size());
        for (Address__c addr : ListAddr) {
            System.assert(addr.MailingStreet__c.equals('direct street  edit'));
        }                   
    }

    /*********************************************************************************************************
    @description Update Contacts' Mailing address to cause an update of the default Address object.  
    verify:
        existing Default Address updated
        Contact get updated Address
    **********************************************************************************************************/            
    @isTest
    public static void updateAddrExisting() {
        configSettings();
        
        // this creates a default Address for each Contact
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);

        // modify some of the Contact addresses directly
        // NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
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
            contactsAddrs.contacts[i].MailingStreet = ' direct street  edit ';    // whitespace and casing should not count as real edit.
            contactsAddrs.contacts[i].MailingState = 'Oregon';
        }
        Test.startTest();
        update contactsAddrs.contacts;
        Test.stopTest();
        
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact contact : mapAccIdAcc.values()) {
            System.assert(contact.MailingStreet.contains('direct street  edit'));
            System.assert(contact.MailingState.contains('Oregon')); 
            System.assertEquals(false, contact.is_Address_Override__c);
            System.assertNotEquals(null, contact.Current_Address__c);
        }
 
        // verify that no new address was created
        List<Address__c> ListAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Contact__c from Address__c];
        System.assertEquals(2, ListAddr.size());
        for (Address__c addr : ListAddr) {
            System.assertEquals('direct street  edit', addr.MailingStreet__c);
        }        
    }

    /*********************************************************************************************************
    @description Create an Address with no Contact 
    verify: runtime error
    **********************************************************************************************************/            
    @isTest
    public static void newAddrNoParent() {        
        List<Address__c> addrs = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        for (Integer i = 0; i < addrs.size(); i++) {
            System.assertEquals(null, addrs[i].Parent_Contact__c);
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
    @description Create N new duplicate Addresses from Contact  
    verify:
        duplicates not created
    **********************************************************************************************************/            
    @isTest
    public static void newDupeAddr() {
        configSettings();
        
        // this creates a default Address for each Contact
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);

        // create additional addresses thru the Contact.
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            contactsAddrs.contacts[i].MailingStreet = contactsAddrs.addrs[i].MailingStreet__c;
            contactsAddrs.contacts[i].MailingCity = contactsAddrs.addrs[i].MailingCity__c;
            contactsAddrs.contacts[i].MailingState = contactsAddrs.addrs[i].MailingState__c;
            contactsAddrs.contacts[i].MailingPostalCode = contactsAddrs.addrs[i].MailingPostalCode__c;
            contactsAddrs.contacts[i].MailingCountry = contactsAddrs.addrs[i].MailingCountry__c;
        }        
        turnOnAllAddrTriggers();
        Test.startTest();
        update contactsAddrs.contacts;
        Test.stopTest();
        
        // verify that we don't have new Addresses
        List<Address__c> ListAddr = [select Id from Address__c];
        System.assertEquals(2, ListAddr.size());
    }

    /*********************************************************************************************************
    @description Create N new duplicate Addresses from Contact, with non-default existing  
    verify:
        duplicates not created
        found match becomes Default
    **********************************************************************************************************/            
    @isTest
    public static void newDupeAddrNonDefault() {
        configSettings();
        
        // this creates a default Address for each Contact
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);

        // create additional non-default addresses
        List<Address__c> addrs = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            addrs[i].Parent_Contact__c = contactsAddrs.contacts[i].Id;
            addrs[i].Default_Address__c = false;
            addrs[i].MailingStreet__c = 'New Street' + i;
            addrs[i].MailingCity__c = 'New City' + i;
        }
        turnOnAllAddrTriggers();
        insert addrs;
 
        // create additional addresses thru the Contact.
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            contactsAddrs.contacts[i].MailingStreet = addrs[i].MailingStreet__c;
            contactsAddrs.contacts[i].MailingCity = addrs[i].MailingCity__c;
            contactsAddrs.contacts[i].MailingState = addrs[i].MailingState__c;
            contactsAddrs.contacts[i].MailingPostalCode = addrs[i].MailingPostalCode__c;
            contactsAddrs.contacts[i].MailingCountry = addrs[i].MailingCountry__c;
        }        
        turnOnAllAddrTriggers();
        Test.startTest();
        update contactsAddrs.contacts;
        Test.stopTest();
        
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact contact : mapAccIdAcc.values()) {
            System.assert(contact.MailingStreet.contains('New Street'));
            System.assert(contact.MailingCity.contains('New City'));
            System.assertEquals(false, contact.is_Address_Override__c);
            System.assertNotEquals(null, contact.Current_Address__c);
        }
        
        // verify the new addresses still are Default and we don't have too many
        List<Address__c> allAddrs = [select Id, Default_Address__c, MailingStreet__c, Parent_Contact__c, Latest_Start_Date__c, 
        Latest_End_Date__c from Address__c];
        UTIL_Debug.debug('****newDupeAddrNonDefault addresses: ' + JSON.serializePretty(allAddrs));
        System.assertEquals(2 * 2, allAddrs.size());
        for (Address__c addr : allAddrs) {
            boolean isNew = (addr.MailingStreet__c.contains('New Street'));
            System.assertEquals(isNew, addr.Default_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Insert Contact w/ multiline street address
    verify: new default Address created and the street address is broken up into street and street2
    **********************************************************************************************************/            
    @isTest
    public static void insertMultilineStreetAddress() {
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Contacts_Addresses_Enabled__c = true));
    
        List<Contact> contacts = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        for (Contact contact : contacts) {
            contact.MailingStreet = 'new street\r\nsecond line';
            contact.MailingCity = 'new city';
        }
        Test.startTest();
        insert contacts; 
        Test.stopTest();       
        
        // verify the Address objects split street.
        List<Address__c> ListAddr = [select Id, MailingStreet__c, MailingStreet2__c, Formula_MailingStreetAddress__c from Address__c];
        System.assertEquals(2, ListAddr.size());
        for (Address__c addr : ListAddr) {
            System.assertEquals('new street', addr.MailingStreet__c);
            System.assertEquals('second line', addr.MailingStreet2__c);
            System.assertEquals('new street, second line', addr.Formula_MailingStreetAddress__c);
        }

        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact contact : mapAccIdAcc.values()) {
            System.assertEquals('new street\r\nsecond line', contact.MailingStreet);
            System.assertEquals(false, contact.is_Address_Override__c);
            System.assertNotEquals(null, contact.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Insert new default multiline street addresses w/ existing default addresses  
    verify:
        Contact address matches new default
        street & street2 combined into contact and Contact single street field
    **********************************************************************************************************/            
    @isTest
    public static void insertNewDefaultMultilineStreetAddr() {
        configSettings();
                
        // this creates a default Address for each Contact
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);

        // create additional addresses
        List<Address__c> addrs = UTIL_UnitTestData_API.getMultipleTestAddresses(2);
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            addrs[i].Parent_Contact__c = contactsAddrs.contacts[i].Id;
            addrs[i].Default_Address__c = true;
            addrs[i].MailingStreet__c = 'New Default Street';
            addrs[i].MailingStreet2__c = 'Second Line';
            addrs[i].MailingCity__c = 'New Default City' + i;
        }
        turnOnAllAddrTriggers();
        Test.startTest();
        insert addrs;
        turnOnAllAddrTriggers();        
        Test.stopTest();

        // verify Contact address is new
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact contact : mapAccIdAcc.values()) {
            System.assertEquals('New Default Street\r\nSecond Line', contact.MailingStreet);
            System.assertEquals('New Default Street\r\nSecond Line', contact.MailingStreet);
        }
        
    }
    
    /*********************************************************************************************************
    @description Update Contacts' Mailing address with multiline street address  
    verify:
        new Default Address created
        Contacts get new Address
        new Addresss has multiline street split into Street and Street2 fields
    **********************************************************************************************************/            
    @isTest
    public static void updateMultilineStreetAddr() {
        configSettings();
         
        // this creates a default Address for each Contact
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);

        // modify some of the Contact addresses directly
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            Contact contact = contactsAddrs.contacts[i];
            contact.MailingStreet = 'Direct Street Edit\r\nSecond Line';
            contact.MailingCity = 'Direct City Edit';
        }
        turnOnAllAddrTriggers();
        Test.startTest();
        update contactsAddrs.contacts;
        Test.stopTest();
        
        // verify Contact address
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact contact : mapAccIdAcc.values()) {
            System.assertEquals('Direct Street Edit\r\nSecond Line', contact.MailingStreet);
            System.assertEquals('Direct Street Edit\r\nSecond Line', contact.MailingStreet);
            System.assertEquals(false, contact.is_Address_Override__c);
            System.assertNotEquals(null, contact.Current_Address__c);
        }
 
        // verify the Address objects split street.
        List<Address__c> ListAddr = [select Id, MailingStreet__c, MailingStreet2__c, Formula_MailingStreetAddress__c, Default_Address__c from Address__c];
        for (Address__c addr : ListAddr) {
            if (addr.Default_Address__c) {
                System.assertEquals('Direct Street Edit', addr.MailingStreet__c);
                System.assertEquals('Second Line', addr.MailingStreet2__c);
                System.assertEquals('Direct Street Edit, Second Line', addr.Formula_MailingStreetAddress__c);
            }
        }
    }

    /*********************************************************************************************************
    @description Update N organizational Contacts with Mailing addresses 
    verify:
        N addresses created
        Contact addresses updated
    **********************************************************************************************************/            
    @isTest
    public static void updateRecordsWithAddrInfo() {         
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Contacts_Addresses_Enabled__c = true));
 
        // create Contacts without addresses
        Integer contactCount = 3;
        List<Contact> contacts = UTIL_UnitTestData_API.getMultipleTestContacts(contactCount);
        insert contacts;

        // update the Contacts' address
        for (Contact contact : contacts) {
            contact.MailingStreet = '123 45th';
            contact.MailingCity = 'Seattle';
        }
        Test.startTest();
        turnOnAllAddrTriggers();
        update contacts;
        Test.stopTest();

        // verify results
        contacts = [SELECT Id, Name, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, 
                   Current_Address__c FROM Contact];
        System.assertEquals(contactCount, contacts.size());
        
        List<Address__c> ListAddr = [SELECT Id, Default_Address__c, MailingStreet__c, MailingCity__c, 
        Parent_Contact__c, Latest_Start_Date__c, Latest_End_Date__c FROM Address__c];
        System.assertEquals(contactCount, ListAddr.size());
                
        for (Integer i = 0; i < contactCount; i++) {
            Contact contact = contacts[i];
            Address__c addr = ListAddr[i];
            System.assertEquals(contact.MailingStreet, addr.MailingStreet__c);
            System.assertEquals(contact.MailingCity, addr.MailingCity__c);
            System.assertNotEquals(null, contact.MailingStreet);
            System.assertNotEquals(null, contact.MailingCity);
            System.assertEquals(true, addr.Default_Address__c);
            System.assertNotEquals(null, contact.Current_Address__c);
        }
    }
    
    /*********************************************************************************************************
    @description Update N Contacts with address objects 
    verify:
        Contact addresses updated
        contact addresses not updated
    **********************************************************************************************************/            
    @isTest
    public static void newAddrForContacts() {           
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Contacts_Addresses_Enabled__c = true));
 
        // create Contacts without addresses
        List<Contact> contacts = UTIL_UnitTestData_API.getMultipleTestContacts(3);
        insert contacts;

         // create addresses for the Contacts
        List<Address__c> addrs = UTIL_UnitTestData_API.getMultipleTestAddresses(contacts.size());
        for (Integer i = 0; i < contacts.size(); i++) {
            addrs[i].Parent_Contact__c = contacts[i].Id;
            addrs[i].Default_Address__c = true;
        }
        turnOnAllAddrTriggers();
        insert addrs;
        turnOnAllAddrTriggers();
        
        // verify results
        contacts = [SELECT Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c 
        FROM Contact];
        System.assertEquals(3, contacts.size());
        
        addrs = [SELECT Id, Default_Address__c, MailingStreet__c, MailingCity__c, Parent_Contact__c, 
        Latest_Start_Date__c, Latest_End_Date__c FROM Address__c];
        System.assertEquals(3, addrs.size());
        
        for (Integer i = 0; i < contacts.size(); i++) {
            Contact contact = contacts[i];
            Address__c addr = addrs[i];
            System.assertEquals(contact.MailingStreet, addr.MailingStreet__c);
            System.assertEquals(contact.MailingCity, addr.MailingCity__c);
            System.assertNotEquals(null, contact.MailingStreet);
            System.assertNotEquals(null, contact.MailingCity);
            System.assertEquals(true, addr.Default_Address__c);
            System.assertEquals(addr.Id, contact.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Create Contacts when the setting for Address Mgmt is off. 
    verify:
        no Address objects created
        Contact addresses set
    **********************************************************************************************************/            
    @isTest
    public static void testDisabledAddr() {        
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Contacts_Addresses_Enabled__c = false));

        List<Contact> contacts = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        for (Contact contact : contacts) {
            contact.MailingStreet = 'new street';
            contact.MailingCity = 'new city';
        }

        // verify Contact address
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact contact : mapAccIdAcc.values()) {
            System.assertEquals(false, contact.is_Address_Override__c);
            System.assertEquals(null, contact.Current_Address__c);
        }
        
        // verify no address objects created
        List<Address__c> ListAddr = [select Id from Address__c];
        System.assertEquals(0, ListAddr.size());
    }
    
    /*********************************************************************************************************
    @description Update Contacts' Mailing address fields to empty cause clearing the default address  
    verify:
        existing Default Address updated to be non-default
        no new Address created
    **********************************************************************************************************/            
    static testMethod void clearAddrExisting() {
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Contacts_Addresses_Enabled__c = true));
                
        // this creates a default Address for each Contact
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(4);

        // clear addresses fields directly
        for (Integer i = 0; i < contactsAddrs.contacts.size(); i++) {
            contactsAddrs.contacts[i].MailingStreet = null;
            contactsAddrs.contacts[i].MailingCity = null;
            contactsAddrs.contacts[i].MailingState = null;
            contactsAddrs.contacts[i].MailingPostalCode = null;
            contactsAddrs.contacts[i].MailingCountry = null;
            if (ADDR_Addresses_UTIL.isStateCountryPickListsEnabled) {
                contactsAddrs.contacts[i].put('MailingStateCode', null);
                contactsAddrs.contacts[i].put('MailingCountryCode', null);
            }             
        }

        turnOnAllAddrTriggers();
        Test.startTest();
        update contactsAddrs.contacts;
        Test.stopTest();
        
        // verify that no new address was created
        List<Address__c> addrs = [select Default_Address__c from Address__c];
        UTIL_Debug.debug('****Contact addresses after clearing addr info: ' + JSON.serializePretty(addrs));
        System.assertEquals(4, addrs.size());
        
        // verify existing Default Address updated to be non-default
        for (Integer i = 0; i < addrs.size(); i++) {
            System.assertEquals(false, addrs[i].Default_Address__c);
        }              
    }

    /*********************************************************************************************************
    @description Insert admin account with blank address data but only primary address type
    verify:
        No blank address record is created
    **********************************************************************************************************/
    static testMethod void insertAdminAccountWithOnlyPrimaryAddressType() {
        List<Contact> contacts = UTIL_UnitTestData_API.getMultipleTestContacts(2);

        contacts[0].MailingStreet = 'new street';
        contacts[0].Primary_Address_Type__c = 'Home';
        contacts[1].Primary_Address_Type__c = 'Home';

        Test.startTest();
        insert contacts;
        Test.stopTest();

        List<Address__c> assertAddresses = [SELECT Id, Parent_Contact__c FROM Address__c];
        System.assertEquals(1, assertAddresses.size());
        System.assertEquals(contacts[0].Id, assertAddresses[0].Parent_Contact__c);
    }

}