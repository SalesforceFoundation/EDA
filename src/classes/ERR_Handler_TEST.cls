/*
    Copyright (c) 2014, Salesforce.org
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
* @date 2014
* @group Error Handling
* @group-content ../../ApexDocContent/ErrorHandling.htm
* @description Tests for error handling functionality.
*/
@isTest
public with sharing class ERR_Handler_TEST {

    // if you only want to run one test in this class, fill in its name here.
    // if you want to run all tests, then use '*'
    private static string strTestOnly = '*';
    
    private static Id chatterGroupId;
    
    private static void setupWithChatterNotifications() {
        
        if(Schema.SObjectType.User.isFeedEnabled()) {
            SObject chatterGroup = (SObject)System.Type.forName('CollaborationGroup').newInstance();
            chatterGroup.put('Name', 'ChatterTestGroup');
            chatterGroup.put('CollaborationType', 'Private');
            insert chatterGroup;
            chatterGroupId = chatterGroup.Id;
            UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Error_Notifications_On__c = true, 
              Error_Notifications_To__c = chatterGroup.Id, Store_Errors_On__c = true, 
              Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID()));
        } else {
            UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Error_Notifications_On__c = true, 
              Error_Notifications_To__c = null, Store_Errors_On__c = true, 
              Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID()));
        }
    }
    
    private static void setupWithEmailNotifications() {
        // all these tests are about testing our error handling, so we can't let the assert interfere       
        
        User user = UTIL_UnitTestData_API.CreateNewUserForTests(System.now().getTime() + '@testerson.com');
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Error_Notifications_On__c = true, 
            Error_Notifications_To__c = user.Id, Store_Errors_On__c = true, 
            Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID()));
    }
    
    /** Test using the default configuration of classes that implement TDTM_Runnable **/
    @isTest
    public static void errorStoredInDbTdtmStandardConfig() {
        if (strTestOnly != '*' && strTestOnly != 'errorStoredInDbTdtmStandardConfig') return;
    
        setupWithEmailNotifications();
                    
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
            new Relationship__c(Contact__c = contact1.id, Type__c='TestLookupType') };
        
        // We catch errors here because TDTM_TriggerHandler no loger processes errors.
        try {
            insert relationships;
        } catch (Exception ex) {
            ERR_Handler.processError(ex, ERR_Handler.Context.REL);
        }

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

    // This method tests handleAfflNullRecordTypeException() of ERR_ExceptionHandler class by passing Affiliaiton Record and List of Account Record Type API Names
    @isTest
    private static void testHandleAfflNullRecordTypeExceptionWithAPIPositive() {

        // Insert an Account
        Account[] testAccount = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID());
        insert testAccount;

        // Insert a Contact
        Contact testContact = UTIL_UnitTestData_TEST.getContact();
        insert testContact;

        Affiliation__c affl = new Affiliation__c(Contact__c = testContact.ID, Account__c = testAccount[0].ID);
        insert affl;

        Affiliation__c afflAfterInsert = [Select Id, Affiliation_Type__c, Account__c FROM Affiliation__c];
        System.assertEquals('Business Organization', afflAfterInsert.Affiliation_Type__c);

        // Construct a list of Account Record Type Names
        List<String> accRecTypeAPIs = new List<String>();
           accRecTypeAPIs.add('Academic_Program');
           accRecTypeAPIs.add('Educational_Institution');
           accRecTypeAPIs.add('Business_Organization');
           accRecTypeAPIs.add('HH_Account');
           accRecTypeAPIs.add('University_Department');
           accRecTypeAPIs.add('Sports_Organization');

        // Test calling the method doesn't throw any error
        Test.startTest();
            ERR_ExceptionHandler.handleAfflNullRecordTypeException(afflAfterInsert, accRecTypeAPIs);
        Test.stopTest();
    }

    // This method tests handleAfflNullRecordTypeException() of ERR_ExceptionHandler class by passing Affiliaiton Record and List of Account Record Type Labels
    @isTest
    private static void testHandleAfflNullRecordTypeExceptionWithLabelsPositive() {

        Account[] testAccount = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID());
        insert testAccount;

        Contact testContact = UTIL_UnitTestData_TEST.getContact();
        insert testContact;

        Affiliation__c affl = new Affiliation__c(Contact__c = testContact.ID, Account__c = testAccount[0].ID);
        insert affl;

        Affiliation__c afflAfterInsert = [Select Id, Affiliation_Type__c, Account__c FROM Affiliation__c];
        System.assertEquals('Business Organization', afflAfterInsert.Affiliation_Type__c);

        // Construct a list of Account Record Type Names
        List<String> accRecTypeLabels = new List<String>();
           accRecTypeLabels.add('Academic Program');
           accRecTypeLabels.add('Educational Institution');
           accRecTypeLabels.add('Business Organization');
           accRecTypeLabels.add('Household Account');
           accRecTypeLabels.add('University Department');
           accRecTypeLabels.add('Sports Organization');

        // Test calling the method doesn't throw any error
        Test.startTest();
            ERR_ExceptionHandler.handleAfflNullRecordTypeException(afflAfterInsert, accRecTypeLabels);
        Test.stopTest();
    }

    // This method tests handleAfflNullRecordTypeException() of ERR_ExceptionHandler class by passing Affiliaiton Record and List of Account Record Type Names
    @isTest
    private static void testHandleAfflNullRecordTypeExceptionWithLabelsNegative() {

        Account[] testAccount = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID());
        insert testAccount;

        Contact testContact = UTIL_UnitTestData_TEST.getContact();
        insert testContact;

        Affiliation__c affl = new Affiliation__c(Contact__c = testContact.ID, Account__c = testAccount[0].ID);
        insert affl;

        Affiliation__c afflAfterInsert = [Select Id, Affiliation_Type__c, Account__c FROM Affiliation__c];
        System.assertEquals('Business Organization', afflAfterInsert.Affiliation_Type__c);

        // Construct a list of Account Record Type Names
        List<String> accRecTypeLabels = new List<String>();
           accRecTypeLabels.add('Academic Program');
           accRecTypeLabels.add('Educational Institution');
           accRecTypeLabels.add('Household Account');
           accRecTypeLabels.add('University Department');
           accRecTypeLabels.add('Sports Organization');

        // Test Error is thrown because Business Organization is not part of accRecTypeLabels
        try {
            Test.startTest();
                ERR_ExceptionHandler.handleAfflNullRecordTypeException(afflAfterInsert, accRecTypeLabels);
            Test.stopTest();
            System.assert(false, 'Always throw an exception when affiliation type is not a part of Mappings');
        } catch (ERR_ExceptionHandler.AffAccountRecordTypeMappingsException error) {
            System.assert(error.getMessage().contains(Label.afflAccoutMappingError));
        }
    }
}