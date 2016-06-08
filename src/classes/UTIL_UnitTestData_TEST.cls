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
    
    public static List<Contact> CreateMultipleTestContacts (integer n) {
        
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

    public static List<Account> CreateMultipleTestAccounts (integer n, ID recTypeId) {
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
}