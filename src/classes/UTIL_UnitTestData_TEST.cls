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
    	return new Contact (FirstName = 'Test', LastName = 'Contact_forTests', WorkEmail__c = 'junk@test.net', 
    	       Preferred_Email__c = 'Work',WorkPhone__c = '206-777-8888', PreferredPhone__c = 'Work',OtherCity = 'Seattle');
    }
    
    public static List<Contact> getMultipleTestContacts(Integer n) {
        List<contact> ContactsToAdd = New List<contact> ();
        for (Integer i=0; i<n; i++) {
            Contact newCon = New Contact (FirstName = 'Test' + i, LastName = 'Contact_forTests' + i, WorkEmail__c = 'junk@test.net', 
                Preferred_Email__c = 'Work', WorkPhone__c = '206-777-8888', PreferredPhone__c = 'Work', OtherCity = 'Seattle');
            ContactsToAdd.add (newCon);
        }       
        return ContactsToAdd;
    }

    public static List<Account> getMultipleTestAccounts(Integer n, ID recTypeId) {
        List<Account> AcctsToAdd = New List<Account> ();    
        for (Integer i=0; i<n; i++) {
            AcctsToAdd.add(new Account(Name = 'Yet Another Org ' + i, RecordTypeId = recTypeId));
        }
        return AcctsToAdd;
    }

    public static User createNewUserForTests(String strUsername) {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u;	
        // to work around mixed DML errors during tests, you must create user account in its own transaction. got this
        // hack from the web.
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {        
	        u = new User(alias = 'jsmith', email='jsmith@acme.com', emailencodingkey='UTF-8', lastname='Smith', 
	            languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', 
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
    public static List<Address__c> getMultipleTestAddresses(Integer addrCount) {
        List<Address__c> addrs = new List<Address__c>();
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
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        
        AccsWithAddrs accsAddrs = new AccsWithAddrs();
        //instantiate accounts
        accsAddrs.accs = getMultipleTestAccounts(accCount, recTypeID);
        insert accsAddrs.accs;      
        
        //instantiate addresses
        accsAddrs.addrs = getMultipleTestAddresses(accCount);
        
        //link addresses with accounts and make them default
        for (Integer i = 0; i < accCount; i++) {
            accsAddrs.addrs[i].Parent_Account__c = accsAddrs.accs[i].Id;
            accsAddrs.addrs[i].Default_Address__c = true;
        }
        //insert addresses
        insert accsAddrs.addrs;
        
        //link accounts with addresses and copy address info to accounts
        for(Integer i = 0; i < accCount; i++) {
            accsAddrs.accs[i].Current_Address__c = accsAddrs.addrs[i].Id;
            accsAddrs.accs[i].BillingStreet = accsAddrs.addrs[i].MailingStreet__c;
            accsAddrs.accs[i].BillingCity = accsAddrs.addrs[i].MailingCity__c;
            accsAddrs.accs[i].BillingState = accsAddrs.addrs[i].MailingState__c;
            accsAddrs.accs[i].BillingPostalCode = accsAddrs.addrs[i].MailingPostalCode__c;
            accsAddrs.accs[i].BillingCountry = accsAddrs.addrs[i].MailingCountry__c;
            accsAddrs.accs[i].BillingLatitude = accsAddrs.addrs[i].Geolocation__Latitude__s;
            accsAddrs.accs[i].BillingLongitude = accsAddrs.addrs[i].Geolocation__Longitude__s;
        }
        update  accsAddrs.accs;

        //clear our triggers recursion prevention since we are starting a new test
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        
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
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = new ContactsWithAddrs();        
        //instantiate contacts
        contactsAddrs.contacts = getMultipleTestContacts(contactCount);
        insert contactsAddrs.contacts;
        
        //instantiate addresses
        contactsAddrs.addrs = getMultipleTestAddresses(contactCount);
        
        //link addresses with contacts and make them default
        for (Integer i = 0; i < contactCount; i++) {
            contactsAddrs.addrs[i].Parent_Contact__c = contactsAddrs.contacts[i].Id;
            contactsAddrs.addrs[i].Default_Address__c = true;
        }
        //insert addresses
        insert contactsAddrs.addrs;
        
       //link contacts with addresses and copy address info to contacts
        for (Integer i = 0; i < contactCount; i++) {
            contactsAddrs.contacts[i].Current_Address__c = contactsAddrs.addrs[i].Id;
            contactsAddrs.contacts[i].MailingStreet = contactsAddrs.addrs[i].MailingStreet__c;
            contactsAddrs.contacts[i].MailingCity = contactsAddrs.addrs[i].MailingCity__c;
            contactsAddrs.contacts[i].MailingState = contactsAddrs.addrs[i].MailingState__c;
            contactsAddrs.contacts[i].MailingPostalCode = contactsAddrs.addrs[i].MailingPostalCode__c;
            contactsAddrs.contacts[i].MailingCountry = contactsAddrs.addrs[i].MailingCountry__c;
            contactsAddrs.contacts[i].MailingLatitude = contactsAddrs.addrs[i].Geolocation__Latitude__s;
            contactsAddrs.contacts[i].MailingLongitude = contactsAddrs.addrs[i].Geolocation__Longitude__s;
        }
        update contactsAddrs.contacts;
        
        //clear our triggers recursion prevention since we are starting a new test
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        
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
        ADDR_Contact_TEST.turnOffAllAddrTriggers();
        
        ContactsAccsWithAddrs consAccsAddrs = new ContactsAccsWithAddrs();
        consAccsAddrs.contacts = getMultipleTestContacts(accCount * contactCount);
        consAccsAddrs.accs = getMultipleTestAccounts(accCount, recTypeID);
        insert consAccsAddrs.accs;
        
        // link contacts with accounts
        for (Integer i = 0; i < accCount; i++) {
            for (Integer j = 0; j < contactCount; j++) {
                consAccsAddrs.contacts[ (i * contactCount) + j].AccountId = consAccsAddrs.accs[i].Id;
            }
        }
        insert consAccsAddrs.contacts; 
        
        /* With accCount = 2, contactCount = 2
            i = 0, j = 0 => contact0 parent is account0
            i = 0, j = 1 => contact1 parent is account0
            i = 1, j = 0 => contact2 parent is account1
            i = 1, j = 1 => contact3 parent is account1
        */       
        
        //instantiate addresses
        consAccsAddrs.addrs = getMultipleTestAddresses(accCount);
        
        //link addresses with accounts and make them default
        for (Integer i = 0; i < accCount; i++) {
            consAccsAddrs.addrs[i].Parent_Account__c = consAccsAddrs.accs[i].Id;
            consAccsAddrs.addrs[i].Default_Address__c = true;
        }
        insert consAccsAddrs.addrs;
        
        //link accounts with addresses and copy address info to accounts
        for(Integer i = 0; i < accCount; i++) {
            consAccsAddrs.accs[i].Current_Address__c = consAccsAddrs.addrs[i].ID;
            consAccsAddrs.accs[i].BillingStreet = consAccsAddrs.addrs[i].MailingStreet__c;
            consAccsAddrs.accs[i].BillingCity = consAccsAddrs.addrs[i].MailingCity__c;
            consAccsAddrs.accs[i].BillingState = consAccsAddrs.addrs[i].MailingState__c;
            consAccsAddrs.accs[i].BillingPostalCode = consAccsAddrs.addrs[i].MailingPostalCode__c;
            consAccsAddrs.accs[i].BillingCountry = consAccsAddrs.addrs[i].MailingCountry__c;
            consAccsAddrs.accs[i].BillingLatitude = consAccsAddrs.addrs[i].Geolocation__Latitude__s;
            consAccsAddrs.accs[i].BillingLongitude = consAccsAddrs.addrs[i].Geolocation__Longitude__s;
        }
        update  consAccsAddrs.accs;
        
        // link contacts with addresses and copy address info to contacts
        for (Integer i = 0; i < accCount; i++) {
            Account parentAcc = consAccsAddrs.accs[i];
            Address__c addr = consAccsAddrs.addrs[i];
            for (Integer j = 0; j < contactCount; j++) {
                consAccsAddrs.contacts[ (i * contactCount) + j].Current_Address__c = parentAcc.Current_Address__c;
                consAccsAddrs.contacts[ (i * contactCount) + j].MailingStreet = addr.MailingStreet__c;
	            consAccsAddrs.contacts[ (i * contactCount) + j].MailingCity = addr.MailingCity__c;
	            consAccsAddrs.contacts[ (i * contactCount) + j].MailingState = addr.MailingState__c;
	            consAccsAddrs.contacts[ (i * contactCount) + j].MailingPostalCode = addr.MailingPostalCode__c;
	            consAccsAddrs.contacts[ (i * contactCount) + j].MailingCountry = addr.MailingCountry__c;
	            consAccsAddrs.contacts[ (i * contactCount) + j].MailingLatitude = addr.Geolocation__Latitude__s;
                consAccsAddrs.contacts[ (i * contactCount) + j].MailingLongitude = addr.Geolocation__Longitude__s;
            }
        }
        update consAccsAddrs.contacts;
        
        // clear our triggers recursion prevention since we are starting a new test
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        
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