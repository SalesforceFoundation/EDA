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
    
    /* @description The List of created test Contacts.*/
    private static List<Contact> contacts;
    
    private static void configSettings() {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c(
            Contacts_Addresses_Enabled__c = true,
            Simple_Address_Change_Treated_as_Update__c = true);
        UTIL_CustomSettingsFacade.getSettingsForTests(hs);
    }
    
    /*********************************************************************************************************
    * @description Sets up common test data for Contact Addresses tests.
    * @param contactCount Number of  Contacts to create.
    * @return  void
    **********************************************************************************************************/  
    public static List<Address__c> createTestDataContacts(Integer contactCount) {
        configSettings();
        
        //instantiate contacts
        contacts = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(contactCount);
        //insert contacts
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert contacts;
        
        //instantiate addresses
        List<Address__c> listAddrs = ADDR_Account_TEST.initTestAddr(contactCount);
        
        //link addresses with contacts and make them default
        for (Integer i = 0; i < contactCount; i++) {
            listAddrs[i].Parent_Contact__c = contacts[i].Id;
            listAddrs[i].Default_Address__c = true;
        }
        //insert addresses
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrs;
        
        //clear our triggers recursion prevention since we are starting a new test
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        return listAddrs;
    }
    
    @isTest
    public static void noContactToAccPropagation() {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c(
            Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID(),
            Accounts_Addresses_Enabled__c = UTIL_Describe.getAdminAccRecTypeID() + ';',
            Contacts_Addresses_Enabled__c = true,
            Simple_Address_Change_Treated_as_Update__c = true);
        UTIL_CustomSettingsFacade.getSettingsForTests(hs);
        
        Contact contact = new Contact(LastName = 'Testerson', MailingStreet = '123 Main St', 
        MailingCity = 'Chicago', MailingState = 'IL', MailingPostalcode = '60606', MailingCountry = 'USA');
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
        System.assertEquals(null, acc.BillingCountry);
    }
    
    @isTest
    public static void noAccToContactPropagation() {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c(
            Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID(),
            Accounts_Addresses_Enabled__c = UTIL_Describe.getAdminAccRecTypeID() + ';',
            Contacts_Addresses_Enabled__c = true,
            Simple_Address_Change_Treated_as_Update__c = true);
        UTIL_CustomSettingsFacade.getSettingsForTests(hs);
        
        Contact contact = new Contact(LastName = 'Testerson');
        insert contact;
        
        //Verify parent account was automatically created
        contact = [select AccountID from Contact where ID = :contact.ID];
        System.assertNotEquals(null, contact.AccountID);
        
        //Give address info to account
        Account acc = [select BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
        from Account where ID = :contact.AccountID];
        acc.BillingStreet = '123 main st';
        acc.BillingState = 'IL';
        acc.BillingPostalCode = '54545';
        acc.BillingCountry = 'USA';

        Test.startTest();
        update acc;
        Test.stopTest();
        
        //Verify child address record was created
        List<Address__c> addrs = [select Parent_Contact__c from Address__c where Parent_Account__c = :acc.ID]; 
        System.assertEquals(1, addrs.size());
        System.assertEquals(null, addrs[0].Parent_Contact__c);
        
         //Verify child contact has no address info
        contact = [select MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
        from Contact where ID = :contact.ID];
        System.assertEquals(null, contact.MailingStreet);
        System.assertEquals(null, contact.MailingState);
        System.assertEquals(null, contact.MailingPostalCode);
        System.assertEquals(null, contact.MailingCountry);
        
        //Verify no address record was created as child of the child contact
        addrs = [select ID from Address__c where Parent_Contact__c = :contact.ID];
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
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Contacts_Addresses_Enabled__c = true));
 
        Integer contactCount = 3;
        contacts = UTIL_UnitTestData_TEST.createMultipleTestContacts(contactCount);
        for (Contact acc : contacts) {
            acc.MailingStreet = '123 45th';
            acc.MailingCity = 'Seattle';
        }
        Test.startTest();
        insert contacts;
        Test.stopTest();

        // verify results
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        system.assertEquals(contactCount, mapAccIdAcc.size());
        
        List<Address__c> ListAddr = [select Id, Default_Address__c, MailingStreet__c, MailingCity__c, Parent_Contact__c, 
        Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(contactCount, ListAddr.size());
        
        for (Address__c addr : ListAddr) {
            Contact acc = mapAccIdAcc.get(addr.Parent_Contact__c);
            system.assertEquals(acc.MailingStreet, addr.MailingStreet__c);
            system.assertEquals(acc.MailingCity, addr.MailingCity__c);
            system.assertEquals(true, addr.Default_Address__c);
        }
    }
        
    /*********************************************************************************************************
    @description Update existing default Addresses.  
    verify: Contact Mailing address fields updated
    **********************************************************************************************************/            
    @isTest 
    public static void updateDefaultAddr() {
        // this creates a default Address for each Contact
        List<Address__c> listAddrs = createTestDataContacts(2);

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
    
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c
        from Contact]);
        
        for (Contact acc : mapAccIdAcc.values()) {
            system.assert(acc.MailingStreet.contains('New Street'));
            system.assert(acc.MailingCity.contains('New City'));
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
    }
    
    /*********************************************************************************************************
    @description Delete existing default Addresses.  
    verify: Contact Mailing address fields cleared.
    **********************************************************************************************************/            
    @isTest 
    static void deleteDefaultAddr() {        
        // this creates a default Address for each Contact
        List<Address__c> listAddrs = createTestDataContacts(2);
       
        // now let's delete the Addresses
        system.assertEquals(false, ADDR_Addresses_TDTM.hasRunAddrTrigger);
        Test.startTest();
        delete listAddrs;
        Test.stopTest();
    
        // verify that the Contact address fields are cleared
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact acc : mapAccIdAcc.values()) {
            system.assertEquals(null, acc.MailingStreet);
            system.assertEquals(null, acc.MailingCity);
        }
    }

    /*********************************************************************************************************
    @description Delete existing non-default override Addresses.  
    verify: Contact Mailing address fields not changed.
    **********************************************************************************************************/            
    @isTest
    static void deleteNonDefaultOverrideAddr() {        
        List<Address__c> listAddrs = createTestDataContacts(2);
        
        // create additional addresses
        listAddrs = ADDR_Account_TEST.initTestAddr(2);
        for (Integer i = 0; i < contacts.size(); i++) {
            listAddrs[i].Parent_Contact__c = contacts[i].Id;
            listAddrs[i].Default_Address__c = false;
            listAddrs[i].MailingStreet__c = 'override' + i;
            listAddrs[i].MailingCity__c = 'override' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrs;
        
        // set the Contacts' address overrides
        for (Integer i = 0; i < contacts.size(); i++) {
            Contact acc = contacts[i];
            acc.Current_Address__c = listAddrs[i].Id;
            acc.is_Address_Override__c = true;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update contacts;        
        
        // now let's delete the override Addresses
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        delete listAddrs;
        Test.stopTest();
    
        // verify that the Contact address fields went back to the default
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact acc : mapAccIdAcc.values()) {
            system.assert(acc.MailingStreet.contains('Street'));
            system.assert(acc.MailingCity.contains('City')); 
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);                
        }
    }

    /*********************************************************************************************************
    @description Making an Address non-default. That is, the address is no longer the default one for the Contact.  
    verify: no change to Contact address
    **********************************************************************************************************/            
    @isTest
    public static void updateNonDefaultAddr() { 
        // this creates a default Address for each Contact
        List<Address__c> listAddrs = createTestDataContacts(2);

        // now let's update the Addresses
        for (Integer i = 0; i < listAddrs.size(); i++) {
            Address__c addr = listAddrs[i];
            addr.Default_Address__c = false;
        }
        system.assertEquals(false, ADDR_Addresses_TDTM.hasRunAddrTrigger);
        Test.startTest();
        update listAddrs;
        Test.stopTest();
    
        // verify that the Contact and Contacts don't share the same address and it's new for the Contact!
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c 
        from Contact]);
        
        for (Contact acc : mapAccIdAcc.values()) {
            system.assertEquals(null, acc.MailingStreet); //address information has been cleared because address is no longer the default
            system.assertEquals(null, acc.MailingCity); //address information has been cleared because address is no longer the default
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertEquals(null, acc.Current_Address__c); //Contact no longer has a current address, since address is no longer the defaults
        }
    }

    /*********************************************************************************************************
    @description Set Contact address override.  
    verify: Contact's address matches override
    **********************************************************************************************************/            
    @isTest
    public static void setAddrOverride() {        
        // this creates a default Address for the Contact
        List<Address__c> listAddrs = createTestDataContacts(2);

        // create new non-default address
        Address__c addrNew = new Address__c();
        addrNew.MailingStreet__c = 'street override';
        addrNew.MailingCity__c = 'city override';
        addrNew.Default_Address__c = false;
        // assign it to the second Contact
        addrNew.Parent_Contact__c = contacts[1].Id;
        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert addrNew;
        
        // set Contact's address override
        contacts[1].Current_Address__c = addrNew.Id;
        contacts[1].is_Address_Override__c = true;
        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update contacts[0];
    
        // now let's update the default Address for both Contacts
        listAddrs[0].MailingStreet__c = 'New Street';
        listAddrs[0].MailingCity__c = 'New City';
        listAddrs[1].MailingStreet__c = 'New Street';
        listAddrs[1].MailingCity__c = 'New City';

        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update listAddrs;
        Test.stopTest();
        
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact acc : mapAccIdAcc.values()) {
            // verify that the Contact address is override
            if (acc.is_Address_Override__c) { 
                system.assert(!acc.MailingStreet.contains('street override'));
                system.assert(!acc.MailingCity.contains('city override'));
                system.assertEquals(acc.Current_Address__c, addrNew.Id);            
            // verify that the Contact address is new
            } else { 
                system.assert(acc.MailingStreet.contains('New Street'));
                system.assert(acc.MailingCity.contains('New City'));
                system.assertNotEquals(null, acc.Current_Address__c);
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
        // this creates a default Address for each Contact
        List<Address__c> listAddrs = createTestDataContacts(2);
        
        // create additional addresses
        listAddrs = ADDR_Account_TEST.initTestAddr(2);
        for (Integer i = 0; i < contacts.size(); i++) {
            listAddrs[i].Parent_Contact__c = contacts[i].Id;
            listAddrs[i].Default_Address__c = true;
            listAddrs[i].MailingStreet__c = 'New Default Street' + i;
            listAddrs[i].MailingCity__c = 'New Default City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        insert listAddrs;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;        
        Test.stopTest();

        // verify that the Contact addresses are new
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact acc : mapAccIdAcc.values()) {
            system.assert(acc.MailingStreet.contains('New Default Street'));
            system.assert(acc.MailingCity.contains('New Default City'));
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
        
        // verify the previous addresses got Default cleared.
        // and verify latest start date and latest end date appropriately set.
        List<Address__c> ListAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Contact__c, Latest_Start_Date__c, 
        Latest_End_Date__c from Address__c];
        system.assertEquals(4, ListAddr.size());
        for (Address__c addr : ListAddr) {
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
    @description Insert new default addresses to Contact with existing default addresses, and then go back  
    verify:
        Contact address matches original default
        new default addresses no longer marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewDefaultAddrAndReset() {  
        // this creates a default Address for each Contact
        List<Address__c> ListAddrOriginal = createTestDataContacts(2);
        
        // create additional addresses
        List<Address__c> listAddrs = ADDR_Account_TEST.initTestAddr(2);
        for (Integer i = 0; i < contacts.size(); i++) {
            listAddrs[i].Parent_Contact__c = contacts[i].Id;
            listAddrs[i].Default_Address__c = true;
            listAddrs[i].MailingStreet__c = 'New Default Street' + i;
            listAddrs[i].MailingCity__c = 'New Default City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrs;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // go back to original default addresses
        // added this extra set to test fix where we didn't use the correct default
        for (Integer i = 0; i < contacts.size(); i++) {
            ListAddrOriginal[i].Default_Address__c = true;
            ListAddrOriginal[i].MailingStreet__c = 'Original Default Street' + i;
            ListAddrOriginal[i].MailingCity__c = 'Original Default City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update ListAddrOriginal;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();
        
        // verify the additional addresses got Default cleared.
        // and verify latest start date and latest end date appropriately set.
        List<Address__c> ListAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Contact__c, Latest_Start_Date__c, 
        Latest_End_Date__c from Address__c];
        system.assertEquals(4, ListAddr.size());
        for (Address__c addr : ListAddr) {
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
    @description Update contacts' mailing address to cause creation of new default Address object.  
    verify:
        new Default Address created
        Contacts get new Address
    **********************************************************************************************************/            
    @isTest
    public static void updateAddrNew() {        
        // this creates a default Address for each Contact
        List<Address__c> listAddrs = createTestDataContacts(4);

        // modify some of the Contact addresses directly
        for (Integer i = 0; i < contacts.size(); i++) {
            contacts[i].MailingStreet = 'Direct Street Edit';
            contacts[i].MailingCity = 'Direct City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update contacts;

        for (Integer i = 0; i < contacts.size(); i++) {
            contacts[i].MailingStreet = 'another Street Edit';
            contacts[i].MailingCity = 'another City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update contacts;

        for (Integer i = 0; i < contacts.size(); i++) {
            contacts[i].MailingStreet = 'final Street Edit';
            contacts[i].MailingCity = 'final City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update contacts;
        Test.stopTest();
        
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact acc : mapAccIdAcc.values()) {
            system.assert(acc.MailingStreet.contains('final Street Edit'));
            system.assert(acc.MailingCity.contains('final City Edit'));
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
 
         // verify the previous addresses got Default cleared.
        List<Address__c> ListAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Contact__c from Address__c];
        // each set of edits created a new address object 
        system.assertEquals(16, ListAddr.size());
        for (Address__c addr : ListAddr) {
            boolean fNewDefault = (addr.MailingStreet__c.contains('final Street Edit'));
            system.assertEquals(fNewDefault, addr.Default_Address__c);
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
        // this creates a default Address for each Contact
        List<Address__c> listAddrs = createTestDataContacts(2);

        // modify the Contact addresses directly, and set override
        for (Integer i = 0; i < contacts.size(); i++) {
            contacts[i].MailingStreet = 'Direct Street Edit';
            contacts[i].MailingCity = 'Direct City Edit';
            contacts[i].is_Address_Override__c = true;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update contacts;
        Test.stopTest();
        
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        system.assertEquals('Direct Street Edit', mapAccIdAcc.values()[0].MailingStreet);
        system.assertEquals('Direct City Edit', mapAccIdAcc.values()[0].MailingCity);
        system.assertEquals(true, mapAccIdAcc.values()[0].is_Address_Override__c);
        system.assertEquals('Direct Street Edit', mapAccIdAcc.values()[1].MailingStreet);
        system.assertEquals('Direct City Edit', mapAccIdAcc.values()[1].MailingCity);
        system.assertEquals(true, mapAccIdAcc.values()[1].is_Address_Override__c);
 
         // verify the previous addresses didn't get Default cleared.
        List<Address__c> ListAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Contact__c from Address__c];
        system.assertEquals(4, ListAddr.size());
        for (Address__c addr : ListAddr) {
            boolean isNewEdit = (addr.MailingStreet__c.contains('Direct Street Edit'));
            if(isNewEdit) {
                system.assertNotEquals(false, addr.Default_Address__c);
            }
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
        // this creates a default Address for each Contact
        List<Address__c> listAddrs = createTestDataContacts(2);

        // modify some of the Contact addresses directly
        // NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
        for (Integer i = 0; i < contacts.size(); i++) {
            contacts[i].MailingStreet = 'Direct Street Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update contacts;

        for (Integer i = 0; i < contacts.size(); i++) {
            contacts[i].MailingState = 'Washington';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update contacts;

        for (Integer i = 0; i < contacts.size(); i++) {
            contacts[i].MailingStreet = ' direct street  edit ';  // whitespace and casing should not count as a real edit.
            contacts[i].MailingState = 'Oregon';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update contacts;

        for (Integer i = 0; i < contacts.size(); i++) {
            contacts[i].MailingStreet = ' DIRECT STREET  EDIT ';  // only change casing.
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update contacts;
        Test.stopTest();
        
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact acc : mapAccIdAcc.values()) {
            system.assert(acc.MailingStreet.equals('DIRECT STREET  EDIT'));
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
 
        // verify that no new address was created
        List<Address__c> ListAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Contact__c from Address__c];
        system.assertEquals(2, ListAddr.size());
        for (Address__c addr : ListAddr) {
            system.assert(addr.MailingStreet__c.equals('DIRECT STREET  EDIT'));
        }
        
        // now test that changing the case from the Contact updates all addresses
        for (Integer i = 0; i < contacts.size(); i++) {
            Contact acc = contacts[i];
            acc.MailingStreet = 'direct street  edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update contacts;
        
        // verify that the Contact address
        mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact acc : mapAccIdAcc.values()) {
            system.assert(acc.MailingStreet.equals('direct street  edit'));
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
 
        // verify that no new address was created
        ListAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Contact__c from Address__c];
        system.assertEquals(2, ListAddr.size());
        for (Address__c addr : ListAddr) {
            system.assert(addr.MailingStreet__c.equals('direct street  edit'));
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
        // this creates a default Address for each Contact
        List<Address__c> listAddrs = createTestDataContacts(2);

        // modify some of the Contact addresses directly
        // NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
        for (Integer i = 0; i < contacts.size(); i++) {
            contacts[i].MailingStreet = 'Direct Street Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update contacts;

        for (Integer i = 0; i < contacts.size(); i++) {
            contacts[i].MailingState = 'Washington';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update contacts;

        for (Integer i = 0; i < contacts.size(); i++) {
            contacts[i].MailingStreet = ' direct street  edit ';    // whitespace and casing should not count as real edit.
            contacts[i].MailingState = 'Oregon';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update contacts;
        Test.stopTest();
        
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact acc : mapAccIdAcc.values()) {
            system.assert(acc.MailingStreet.contains('direct street  edit'));
            system.assert(acc.MailingState.contains('Oregon')); 
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
 
        // verify that no new address was created
        List<Address__c> ListAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Contact__c from Address__c];
        system.assertEquals(2, ListAddr.size());
        for (Address__c addr : ListAddr) {
            system.assertEquals('direct street  edit', addr.MailingStreet__c);
        }        
    }

    /*********************************************************************************************************
    @description Create an Address with no Contact 
    verify: runtime error
    **********************************************************************************************************/            
    @isTest
    public static void newAddrNoParent() {        
        List<Address__c> listAddrs = ADDR_Account_TEST.initTestAddr(2);
        for (Integer i = 0; i < listAddrs.size(); i++) {
            system.assertEquals(null, listAddrs[i].Parent_Contact__c);
        }
        
        try {
            insert listAddrs;
        } catch (Exception ex) {
            system.assert(ex.getMessage().contains(Label.addrValidParentObjects));
            return;
        }
        system.assert(false); //we shouldn't get here!
    }
 
    /*********************************************************************************************************
    @description Create N new duplicate Addresses from Contact  
    verify:
        duplicates not created
    **********************************************************************************************************/            
    @isTest
    public static void newDupeAddr() {        
        // this creates a default Address for each Contact
        List<Address__c> listAddrs = createTestDataContacts(2);

        // create additional addresses thru the Contact.
        for (Integer i = 0; i < contacts.size(); i++) {
            contacts[i].MailingStreet = listAddrs[i].MailingStreet__c;
            contacts[i].MailingCity = listAddrs[i].MailingCity__c;
            contacts[i].MailingState = listAddrs[i].MailingState__c;
            contacts[i].MailingPostalCode = listAddrs[i].MailingPostalCode__c;
            contacts[i].MailingCountry = listAddrs[i].MailingCountry__c;
        }        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update contacts;
        Test.stopTest();
        
        // verify that we don't have new Addresses
        List<Address__c> ListAddr = [select Id from Address__c];
        system.assertEquals(2, ListAddr.size());
    }

    /*********************************************************************************************************
    @description Create N new duplicate Addresses from Contact, with non-default existing  
    verify:
        duplicates not created
        found match becomes Default
    **********************************************************************************************************/            
    @isTest
    public static void newDupeAddrNonDefault() {        
        // this creates a default Address for each Contact
        List<Address__c> listAddrs = createTestDataContacts(2);

         // create additional non-default addresses
        listAddrs = ADDR_Account_TEST.initTestAddr(2);
        for (Integer i = 0; i < contacts.size(); i++) {
            listAddrs[i].Parent_Contact__c = contacts[i].Id;
            listAddrs[i].Default_Address__c = false;
            listAddrs[i].MailingStreet__c = 'New Street' + i;
            listAddrs[i].MailingCity__c = 'New City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrs;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;        
 
        // create additional addresses thru the Contact.
        for (Integer i = 0; i < contacts.size(); i++) {
            contacts[i].MailingStreet = listAddrs[i].MailingStreet__c;
            contacts[i].MailingCity = listAddrs[i].MailingCity__c;
            contacts[i].MailingState = listAddrs[i].MailingState__c;
            contacts[i].MailingPostalCode = listAddrs[i].MailingPostalCode__c;
            contacts[i].MailingCountry = listAddrs[i].MailingCountry__c;
        }        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update contacts;
        Test.stopTest();
        
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact acc : mapAccIdAcc.values()) {
            system.assert(acc.MailingStreet.contains('New Street'));
            system.assert(acc.MailingCity.contains('New City'));
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
        
        // verify the new addresses still are Default and we don't have too many
        List<Address__c> ListAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Contact__c, Latest_Start_Date__c, 
        Latest_End_Date__c from Address__c];
        system.assertEquals(2 * 2, ListAddr.size());
        for (Address__c addr : ListAddr) {
            boolean isNew = (addr.MailingStreet__c.contains('New Street'));
            system.assertEquals(isNew, addr.Default_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Insert Contact w/ multiline street address
    verify: new default Address created and the street address is broken up into street and street2
    **********************************************************************************************************/            
    @isTest
    public static void insertMultilineStreetAddress() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Contacts_Addresses_Enabled__c = true));
    
        contacts = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(2);
        for (Contact acc : contacts) {
            acc.MailingStreet = 'new street\r\nsecond line';
            acc.MailingCity = 'new city';
        }
        Test.startTest();
        insert contacts; 
        Test.stopTest();       
        
        // verify the Address objects split street.
        List<Address__c> ListAddr = [select Id, MailingStreet__c, MailingStreet2__c, Formula_MailingStreetAddress__c from Address__c];
        System.assertEquals(2, ListAddr.size());
        for (Address__c addr : ListAddr) {
            system.assertEquals('new street', addr.MailingStreet__c);
            system.assertEquals('second line', addr.MailingStreet2__c);
            system.assertEquals('new street, second line', addr.Formula_MailingStreetAddress__c);
        }

        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact acc : mapAccIdAcc.values()) {
            system.assertEquals('new street\r\nsecond line', acc.MailingStreet);
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
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
        // this creates a default Address for each Contact
        List<Address__c> listAddrs = createTestDataContacts(2);

        // create additional addresses
        listAddrs = ADDR_Account_TEST.initTestAddr(2);
        for (Integer i = 0; i < contacts.size(); i++) {
            listAddrs[i].Parent_Contact__c = contacts[i].Id;
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

        // verify Contact address is new
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact acc : mapAccIdAcc.values()) {
            system.assertEquals('New Default Street\r\nSecond Line', acc.MailingStreet);
            system.assertEquals('New Default Street\r\nSecond Line', acc.MailingStreet);
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
        // this creates a default Address for each Contact
        List<Address__c> listAddrs = createTestDataContacts(2);

        // modify some of the Contact addresses directly
        for (Integer i = 0; i < contacts.size(); i++) {
            Contact acc = contacts[i];
            acc.MailingStreet = 'Direct Street Edit\r\nSecond Line';
            acc.MailingCity = 'Direct City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update contacts;
        Test.stopTest();
        
        // verify Contact address
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact acc : mapAccIdAcc.values()) {
            system.assertEquals('Direct Street Edit\r\nSecond Line', acc.MailingStreet);
            system.assertEquals('Direct Street Edit\r\nSecond Line', acc.MailingStreet);
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
 
        // verify the Address objects split street.
        List<Address__c> ListAddr = [select Id, MailingStreet__c, MailingStreet2__c, Formula_MailingStreetAddress__c, Default_Address__c from Address__c];
        for (Address__c addr : ListAddr) {
            if (addr.Default_Address__c) {
                system.assertEquals('Direct Street Edit', addr.MailingStreet__c);
                system.assertEquals('Second Line', addr.MailingStreet2__c);
                system.assertEquals('Direct Street Edit, Second Line', addr.Formula_MailingStreetAddress__c);
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
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Contacts_Addresses_Enabled__c = true));
 
        // create Contacts without addresses
        Integer contactCount = 3;
        contacts = UTIL_UnitTestData_TEST.createMultipleTestContacts(contactCount);
        insert contacts;

        // update the Contacts' address
        for (Contact acc : contacts) {
            acc.MailingStreet = '123 45th';
            acc.MailingCity = 'Seattle';
        }
        Test.startTest();
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update contacts;
        Test.stopTest();

        // verify results
        contacts = [select Id, Name, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, 
                   Current_Address__c from Contact order by Contact.Name];
        system.assertEquals(contactCount, contacts.size());
        
        List<Address__c> ListAddr = [select Id, Default_Address__c, MailingStreet__c, MailingCity__c, 
        Parent_Contact__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c 
        order by Parent_Contact__r.Name];
        system.assertEquals(contactCount, ListAddr.size());
                
        for (Integer i = 0; i < contactCount; i++) {
            Contact acc = contacts[i];
            Address__c addr = ListAddr[i];
            system.assertEquals(acc.MailingStreet, addr.MailingStreet__c);
            system.assertEquals(acc.MailingCity, addr.MailingCity__c);
            system.assertNotEquals(null, acc.MailingStreet);
            system.assertNotEquals(null, acc.MailingCity);
            system.assertEquals(true, addr.Default_Address__c);
            system.assertNotEquals(null, acc.Current_Address__c);
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
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Contacts_Addresses_Enabled__c = true));
 
        // create Contacts without addresses
        contacts = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(3);
        insert contacts;

         // create addresses for the Contacts
        List<Address__c> listAddrs = ADDR_Account_TEST.initTestAddr(contacts.size());
        for (Integer i = 0; i < contacts.size(); i++) {
            listAddrs[i].Parent_Contact__c = contacts[i].Id;
            listAddrs[i].Default_Address__c = true;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrs;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // verify results
        contacts = [select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c 
        from Contact order by Contact.Name];
        system.assertEquals(3, contacts.size());
        
        listAddrs = [select Id, Default_Address__c, MailingStreet__c, MailingCity__c, Parent_Contact__c, 
        Latest_Start_Date__c, Latest_End_Date__c from Address__c order by Parent_Contact__r.Name];
        system.assertEquals(3, listAddrs.size());
        
        for (Integer i = 0; i < contacts.size(); i++) {
            Contact acc = contacts[i];
            Address__c addr = listAddrs[i];
            system.assertEquals(acc.MailingStreet, addr.MailingStreet__c);
            system.assertEquals(acc.MailingCity, addr.MailingCity__c);
            system.assertNotEquals(null, acc.MailingStreet);
            system.assertNotEquals(null, acc.MailingCity);
            system.assertEquals(true, addr.Default_Address__c);
            system.assertEquals(addr.Id, acc.Current_Address__c);
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
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Contacts_Addresses_Enabled__c = false));

        contacts = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(2);
        for (Contact acc : contacts) {
            acc.MailingStreet = 'new street';
            acc.MailingCity = 'new city';
        }

        // verify Contact address
        map<Id, Contact> mapAccIdAcc = new map<Id, Contact>([select Id, Name, MailingStreet, MailingCity, MailingState, 
        MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, is_Address_Override__c, Current_Address__c from Contact]);
        
        for (Contact acc : mapAccIdAcc.values()) {
            system.assertEquals(false, acc.is_Address_Override__c);
            system.assertEquals(null, acc.Current_Address__c);
        }
        
        // verify no address objects created
        List<Address__c> ListAddr = [select Id from Address__c];
        system.assertEquals(0, ListAddr.size());
    }
    
    /*********************************************************************************************************
    @description Update Contacts' Mailing address fields to empty cause clearing the default address  
    verify:
        existing Default Address updated to be non-default
        no new Address created
    **********************************************************************************************************/            
    static testMethod void clearAddrExisting() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Contacts_Addresses_Enabled__c = true));
                
        // this creates a default Address for each Contact
        List<Address__c> listAddrs = createTestDataContacts(4);

        // clear addresses fields directly
        for (Integer i = 0; i < contacts.size(); i++) {
            contacts[i].MailingStreet = null;
            contacts[i].MailingCity = null;
            contacts[i].MailingState = null;
            contacts[i].MailingPostalCode = null;
            contacts[i].MailingCountry = null;
            if (ADDR_Addresses_UTIL.isStateCountryPickListsEnabled) {
                contacts[i].put('MailingStateCode', null);
                contacts[i].put('MailingCountryCode', null);
            }             
        }

        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.startTest();
        update contacts;
        Test.stopTest();
        
        // verify that no new address was created
        listAddrs = [select Default_Address__c from Address__c];
        system.assertEquals(4, listAddrs.size());
        
        // verify existing Default Address updated to be non-default
        for (Integer i = 0; i < listAddrs.size(); i++) {
            system.assertEquals(false, listAddrs[i].Default_Address__c);
        }              
    }
}