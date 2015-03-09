/*
    Copyright (c) 2013, Salesforce.com Foundation
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Salesforce.com Foundation nor the names of
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
@isTest
public with sharing class TDTM_Runnable_TEST {

    private static string strTestOnly = '*';
    
    /** This test verifies that the runFuture method of the TDTM_Runnable class works properly **/
    public static testmethod void testAsync() {
    	if (strTestOnly != '*' && strTestOnly != 'testAsync') return;
    	
    	insert new Trigger_Handler__c(Active__c = true, Asynchronous__c = true, 
              Class__c = 'ERR_ParentAccountUpdater2_TEST', Load_Order__c = 1, Object__c = 'Contact', 
              Trigger_Action__c = 'AfterInsert;');
         
        Account acc = new Account(Name = 'Old Acc Name');
        insert acc;
        
        Contact contact = new Contact(FirstName = 'Old First Name', LastName = 'Testerson', AccountId = acc.Id);
        
        Test.startTest(); 
        insert contact;
        Test.stopTest();
        
        contact = [select FirstName from Contact where Id = :contact.ID];
        acc = [select Name from Account where Id = :acc.Id];
        
        System.assertEquals('New First Name', contact.FirstName); //To verify fields from record are available in future
        System.assertEquals('New Acc Name', acc.Name);
    }
    
    /** Test we do not get the "Cannot have more than 10 chunks in a single operation. Please rearrange the data to 
    reduce chunking" error. 
    If you comment out the first line in the method groupSObjects of TDTM_Runnable this test fails.**/
    public static testmethod void nochunking() {
    	if (strTestOnly != '*' && strTestOnly != 'nochunking') return;
    	
    	Contacts_and_Orgs_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getContactsSettingsForTests(
            new Contacts_and_Orgs_Settings__c (Account_Processor__c = 'Household Account'));
    
    	List<Contact> contacts = new List<Contact>();
		for(integer i = 0; i< 200; i++) {
		    Contact contact = new contact(firstname='Test', lastname='Person' + i);
		    contact.MailingStreet = 'multiple-address';
		    contact.MailingCity = 'Cupertino';
		    contact.MailingState = 'California';
		    contact.MailingPostalCode = '95014';
		    contact.MailingCountry = 'United States';
		    contacts.add(contact);
		}
		
		Test.startTest();
		insert contacts;
		Test.stopTest();
		
		Integer errors = [select count() from Error__c];
		System.assertEquals(0, errors);
    }
}