/*
    Copyright (c) 2014, Salesforce.com Foundation
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
public with sharing class ERR_Handler_TEST {

    // if you only want to run one test in this class, fill in its name here.
    // if you want to run all tests, then use '*'
    private static string strTestOnly = '*';
    
    private static Id chatterGroupId;
    
    private static void setupWithChatterNotifications() {
    	// all these tests are about testing our error handling, so we can't let the assert interfere
    	TDTM_TriggerHandler.suppressDebugAssertAfterErrorLogging = true;        
    	
    	UTIL_CustomSettingsFacade.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c(
            Account_Processor__c = 'Household Account'));
    	//UTIL_CustomSettingsFacade.getHouseholdsSettingsForTests(new Households_Settings__c (
        //    Household_Rules__c = HH_Households.ALL_PROCESSOR, Enable_Opp_Rollup_Triggers__c = true));
    	
    	if(Schema.SObjectType.User.isFeedEnabled()) {
	    	SObject chatterGroup = (SObject)System.Type.forName('CollaborationGroup').newInstance();
	    	chatterGroup.put('Name', 'ChatterTestGroup');
	    	chatterGroup.put('CollaborationType', 'Private');
	    	insert chatterGroup;
	    	chatterGroupId = chatterGroup.Id;
	    	UTIL_CustomSettingsFacade.getErrorSettingsForTests(new Error_Settings__c(Error_Notifications_On__c = true, 
	    	  Error_Notifications_To__c = chatterGroup.Id, Store_Errors_On__c = true));
    	} else {
    		UTIL_CustomSettingsFacade.getErrorSettingsForTests(new Error_Settings__c(Error_Notifications_On__c = true, 
    		  Error_Notifications_To__c = null, Store_Errors_On__c = true));
    	}
    }
    
    private static void setupWithEmailNotifications() {
        // all these tests are about testing our error handling, so we can't let the assert interfere
        TDTM_TriggerHandler.suppressDebugAssertAfterErrorLogging = true;        

        UTIL_CustomSettingsFacade.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c(
            Account_Processor__c = 'Household Account'));
        //UTIL_CustomSettingsFacade.getHouseholdsSettingsForTests(new Households_Settings__c (
        //    Household_Rules__c = HH_Households.ALL_PROCESSOR, Enable_Opp_Rollup_Triggers__c = true));
        
        User user = CreateNewUserForTests(System.now().getTime() + '@testerson.com');
        UTIL_CustomSettingsFacade.getErrorSettingsForTests(new Error_Settings__c(Error_Notifications_On__c = true, 
            Error_Notifications_To__c = user.Id, Store_Errors_On__c = true));
    }
    
    public static User CreateNewUserForTests(string strUsername) {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        UserRole r = [SELECT Id FROM UserRole WHERE Name='COO'];
        User u;	
        // to work around mixed DML errors during tests, you must
        // create user account in its own transaction.  got this
        // hack from the web.
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {        
	        u = new User(alias = 'jsmith', email='jsmith@acme.com', 
	            emailencodingkey='UTF-8', lastname='Smith', 
	            languagelocalekey='en_US', 
	            localesidkey='en_US', profileid = p.Id, userroleid = r.Id,
	            timezonesidkey='America/Los_Angeles', 
	            username=strUsername);
	        insert u;
        }
        return u;
    }
    
    /** Test using the default configuration of classes that implement TDTM_Runnable **/
    @isTest
    public static void errorStoredInDbTdtmStandardConfig() {
    	if (strTestOnly != '*' && strTestOnly != 'errorStoredInDbTdtmStandardConfig') return;
    
        setupWithChatterNotifications();
        
        UTIL_CustomSettingsFacade.getAffiliationsSettingsForTests(
            new Affiliations_Settings__c(Automatic_Affiliation_Creation_Turned_On__c = true));
                    
        //Create account
        Account acc1 = new Account(Name='test1');
        Account acc2 = new Account(Name='test2');
        Account acc3 = new Account(Name='test3');
        insert new Account[] {acc1, acc2, acc3};
        
        //Create contact
        Contact contact1 = new Contact(FirstName = 'test', LastName = 'testerson1', AccountId = acc1.Id, Title = 'VP1');
        Contact contact2 = new Contact(FirstName = 'test', LastName = 'testerson2', AccountId = acc2.Id, Title = 'VP2');
        Contact contact3 = new Contact(FirstName = 'test', LastName = 'testerson3', AccountId = acc3.Id, Title = 'VP3');

        //Delete the account to get the affiliations code to throw an exception
        delete acc2;
        
        Test.startTest();
        List<Contact> contacts = new Contact[]{contact1, contact2, contact3};
        LIST<database.SaveResult> results = Database.insert(contacts, false);
        Test.stopTest();
        
        //Database.insert will roll everything back if there is an error, and then run again only with the records that
        //don't produce exceptions
        System.assertEquals(true, results[0].isSuccess());  
        System.assertEquals(false, results[1].isSuccess()); 
        System.assertEquals(true, results[2].isSuccess()); 

        //Verify 2 contacts were properly inserted
        list<Contact> insertedContacts = [select Id from Contact where Id in :contacts];
        System.assertEquals(2, insertedContacts.size()); 
        
        //Verify error record was created -> Nope. Since we are using Database insert the operation
        //gets rolled back and then run again only with records that succeed. No error is saved.
        //**Note that we have not created a Trigger_Handler__c record with the test class that would throw an exception**
        List<Error__c> errors = [select Id, Full_Message__c, Stack_Trace__c from Error__c];
        UTIL_Debug.debug('****ERROR: ' + JSON.serializePretty(errors));
        System.assertEquals(0, errors.size());                                    
    }
    
    /** This is the same test called testErrorRecordCreation in the REL_Relationships_TEST class, but
        using simple insert instead of Database.insert ***/
    @isTest 
    public static void errorStoredInDatabaseFromInsert() {
        if (strTestOnly != '*' && strTestOnly != 'errorStoredInDatabaseFromInsert') return;
        
        setupWithChatterNotifications();
        
        Contact contact1 = new Contact(FirstName = 'test', LastName = 'testerson1', Title = 'VP1');
        insert contact1;
                
        Relationship__c[] relationships = new Relationship__c[]{
            new Relationship__c(contact__c = contact1.id, Type__c='TestLookupType') };
        
        TDTM_TriggerHandler.isPropogateErrorsFromTrigger = false;
        insert relationships;
        //assert an error record was created - Required fields are missing: [Contact__c]
        //Contact__c is missing from the reciprocal relationship that gets automatically created.
        system.assertEquals(1, [select count() from Error__c]);
        
        //update relationship - this will create the missing Contact__c field
        relationships[0].RelatedContact__c = contact1.id;
        Database.SaveResult[] updateResults = Database.update(relationships, false);
        system.assertNotEquals(null, relationships[0].Contact__c);
        
        //get errors
        ERR_Handler.Errors errors = ERR_Handler.getErrors(updateResults, (List<SObject>)relationships);
        //we still get an error, because of the Related_Contact_Do_Not_Change validation rule on Relationship
        system.assertEquals(true, errors.errorsExist);
        system.assertEquals(1, errors.errorRecords.size());

        //assert no additional error record was created on update
        system.assertEquals(1, [select count() from Error__c]);
    }
}