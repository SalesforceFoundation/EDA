/*
    Copyright (c) 2011, Salesforce.org
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
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
* @date 2011 (1.x)
* @group Utilities
* @group-content ../../ApexDocContent/Utilities.htm
* @description Provides automated generation of unit test data for tests throughout the org 
*/
@isTest
public class UTIL_UnitTestData_TEST { 
    
    public static Contact getContact() {
    	return new Contact (
                FirstName = 'Test',
                LastName = 'Contact_forTests',
                WorkEmail__c = 'junk@test.net', 
                Preferred_Email__c = 'Work',
                WorkPhone__c = '206-777-8888',
                PreferredPhone__c = 'Work',
                OtherCity = 'Seattle'
            );
    }
    
    public static List<Contact> createMultipleTestContacts (integer n) {
        
        List<contact> ContactsToAdd = New List<contact> ();
        
        for (integer i=0;i<n;i++) {
            Contact newCon = New Contact (
                FirstName= 'Test' + i,
                LastName= 'Contact_forTests' + i,
                WorkEmail__c = 'junk@test.net', 
                Preferred_Email__c = 'Work',
                WorkPhone__c = '206-777-8888',
                PreferredPhone__c = 'Work',
                OtherCity = 'Seattle'
            );
            ContactsToAdd.add (newCon);
        }
        
        // testing doing the insert in the calling code - will maybe reinstate this
        //insert ContactsToAdd;
        
        return ContactsToAdd;
    }

    public static List<Account> createMultipleTestAccounts (integer n, ID recTypeId) {
        List<Account> AcctsToAdd = New List<Account> ();    
        for (integer i=0;i<n;i++) {
            AcctsToAdd.add(new Account(Name = 'Yet Another Org ' + i, RecordTypeId = recTypeId));
        }
        return AcctsToAdd;
    }

    public static User CreateNewUserForTests(string strUsername) {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u;	
        // to work around mixed DML errors during tests, you must
        // create user account in its own transaction.  got this
        // hack from the web.
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {        
	        u = new User(alias = 'jsmith', email='jsmith@acme.com', 
	            emailencodingkey='UTF-8', lastname='Smith', 
	            languagelocalekey='en_US', 
	            localesidkey='en_US', profileid = p.Id,
	            timezonesidkey='America/Los_Angeles', 
	            username=strUsername);
	        insert u;
        }
        return u;
    }
    
    /*********************************************************************************************************
    * @description Initializes (but not inserts) N new Address objects.
    * @param addrCount the number of Address objects to create
    * @return  void
    **********************************************************************************************************/
    public static List<Address__c> initTestAddr(Integer addrCount) {
        List<Address__c> addrs = new list<Address__c>();
        for (Integer i = 0; i < addrCount; i++) {
            Address__c addr = new Address__c();
            addr.Address_Type__c = 'Home';
            addr.MailingStreet__c = 'Street' + i;
            addr.MailingCity__c = 'City' + i;
            addr.MailingState__c = 'Washington';
            addr.MailingPostalCode__c = 'Zip' + i;
            addr.MailingCountry__c = 'United States';
            addr.Geolocation__Latitude__s = 47.6097 + i;
            addr.Geolocation__Longitude__s = -122.3331 + i;
            addrs.add(addr);            
        }
        return addrs;
    }
    
    /*********************************************************************************************************
    * @description Sets up common test data for Account Addresses tests.
    * @param accCount Number of  Accounts to create.
    * @param recTypeID The record type to use when creating Accounts.
    * @return  void
    **********************************************************************************************************/    
    public static AccsWithAddrs createTestAccsAddrs(Integer accCount, String recTypeID) {                
        AccsWithAddrs accsAddrs = new AccsWithAddrs();
        
        //instantiate accounts
        accsAddrs.accs = createMultipleTestAccounts(accCount, recTypeID);
        //insert accounts
        insert accsAddrs.accs;      
        
        //instantiate addresses
        accsAddrs.addrs = initTestAddr(accCount);
        
        //link addresses with accounts and make them default
        for (Integer i = 0; i < accCount; i++) {
            accsAddrs.addrs[i].Parent_Account__c = accsAddrs.accs[i].Id;
            accsAddrs.addrs[i].Default_Address__c = true;
        }
        //insert addresses
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert accsAddrs.addrs;
        
        //clear our triggers recursion prevention since we are starting a new test
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        return accsAddrs;
    }
    
    /*********************************************************************************************************
    * @description Groups a list of Accounts and a list of Addresses so they can be returned from a method together.
    **********************************************************************************************************/ 
    public class AccsWithAddrs {
        public List<Account> accs { public get; public set; }
        public List<Address__c> addrs { public get; public set; }
    }
    
    /*********************************************************************************************************
    * @description Sets up common test data for Contact Addresses tests.
    * @param contactCount Number of  Contacts to create.
    * @return  void
    **********************************************************************************************************/  
    public static ContactsWithAddrs createTestContactsAddrs(Integer contactCount) {
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = new ContactsWithAddrs();
        
        //instantiate contacts
        contactsAddrs.contacts = createMultipleTestContacts(contactCount);
        //insert contacts
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert contactsAddrs.contacts;
        
        //instantiate addresses
        contactsAddrs.addrs = initTestAddr(contactCount);
        
        //link addresses with contacts and make them default
        for (Integer i = 0; i < contactCount; i++) {
            contactsAddrs.addrs[i].Parent_Contact__c = contactsAddrs.contacts[i].Id;
            contactsAddrs.addrs[i].Default_Address__c = true;
        }
        //insert addresses
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert contactsAddrs.addrs;
        
        //clear our triggers recursion prevention since we are starting a new test
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        return contactsAddrs;
    }
    
    /*********************************************************************************************************
    * @description Groups a list of Contacts and a list of Addresses so they can be returned from a method together.
    **********************************************************************************************************/ 
    public class ContactsWithAddrs {
        public List<Contact> contacts { public get; public set; }
        public List<Address__c> addrs { public get; public set; }
    }
    
    /*********************************************************************************************************
    * @description Sets up common test data for the Address tests.
    *    - this will create & insert N household Accounts, each with M contacts
    *    - also will create a Default Addresses for each HH Account
    *    - will also setup the default Account Processor to be HH Accounts
    * @param accCount the number of Household Accounts to create
    * @param contactCount the number of Contacts to create per Household
    * @return  void
    **********************************************************************************************************/
    public static ContactsAccsWithAddrs createTestConsAccsAddrs(Integer accCount, Integer contactCount, String recTypeID) {
        ContactsAccsWithAddrs consAccsAddrs = new ContactsAccsWithAddrs();
        
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c();
        hs.Account_Processor__c = recTypeID;
        hs.Household_Addresses_RecType__c = recTypeID;
        hs.Simple_Address_Change_Treated_as_Update__c = true;
        UTIL_CustomSettingsFacade.getSettingsForTests(hs);
            
        consAccsAddrs.contacts = createMultipleTestContacts(accCount * contactCount);
        consAccsAddrs.accs = createMultipleTestAccounts(accCount, recTypeID);
        insert consAccsAddrs.accs;
        
        for (Integer i = 0; i < accCount; i++) {
            for (Integer j = 0; j < contactCount; j++) {
                consAccsAddrs.contacts[ (i * contactCount) + j].AccountId = consAccsAddrs.accs[i].Id;
            }
        }        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert consAccsAddrs.contacts;        

        consAccsAddrs.addrs = initTestAddr(accCount);
        for (Integer i = 0; i < accCount; i++) {
            consAccsAddrs.addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            consAccsAddrs.addrs[i].Default_Address__c = true;
        }
        // clear our triggers recursion prevention since we starting a new test
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert consAccsAddrs.addrs;
        
        // clear our triggers recursion prevention since we are starting a new test
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        return consAccsAddrs;
    }
    
    /*********************************************************************************************************
    * @description Groups a list of Accounts, a list of Contacts, and a list of Addresses so they can be returned 
    * from a method together.
    **********************************************************************************************************/ 
    public class ContactsAccsWithAddrs {
        public List<Account> accs { public get; public set; }
        public List<Contact> contacts { public get; public set; }
        public List<Address__c> addrs { public get; public set; }
    }
}