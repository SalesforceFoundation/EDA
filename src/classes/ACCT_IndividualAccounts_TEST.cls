/*
    Copyright (c) 2011, Salesforce.com Foundation
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
/**
* @author Salesforce.com Foundation
* @date 2011 (1.x)
* @group Accounts
* @description Tests for ACCT_IndividualAccounts_TDTM
*/
@isTest
private class ACCT_IndividualAccounts_TEST {    

    /*********************************************************************************************************
    * @description if you only want to run one test in this class, fill in its name here.
    * if you want to run all tests, then use '*'
    */
    private static string strTestOnly = '*';
    
    /*********************************************************************************************************
    * @description tests default contructor
    */
    @isTest
    public static void ACCT_IndividualAccounts_TEST() {
    	if (strTestOnly != '*' && strTestOnly != 'ACCT_IndividualAccounts_TEST') return;
        ACCT_IndividualAccounts_TDTM testIndividualAccounts = new ACCT_IndividualAccounts_TDTM();
    }

    /*********************************************************************************************************
    * @description Test Method for inserting a Contact that should get no account 
    */
    @isTest
    public static void insertPrivate() {
    	if (strTestOnly != '*' && strTestOnly != 'insertPrivate') return;
        insertPrivateProcessor(CAO_Constants.ONE_TO_ONE_PROCESSOR);
        insertPrivateProcessor(CAO_Constants.BUCKET_PROCESSOR);
        insertPrivateProcessor(CAO_Constants.HH_ACCOUNT_PROCESSOR);
    }   
    public static void insertPrivateProcessor(string strProcessor) {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getContactsSettingsForTests(
            new Contacts_and_Orgs_Settings__c (Account_Processor__c = strProcessor));

        CAO_Constants.setIndividualAccountForTests(CAO_Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);

        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            Private__c=true,
            WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS, 
            Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select FirstName, LastName, AccountId  from Contact where id=:con.id];
        
        //contact should have no AccountId
        system.assertEquals(null,insertedContacts[0].AccountId);
    }
    
    /*********************************************************************************************************
    * @description Test changing the account model from one-to-one account to household account.  
    */
    @isTest
    public static void changeFromOneToOneToHouseholdAccount() {
    	if (strTestOnly != '*' && strTestOnly != 'changeFromOneToOneToHouseholdAccount') return;
            
    	//Set Individual (Bucket) settings
    	Contacts_And_Orgs_Settings__c contactsSettings = UTIL_CustomSettingsFacade.getContactsSettings();
    	contactsSettings.Account_Processor__c = CAO_Constants.BUCKET_PROCESSOR;
        
        
    	//Create a contact
    	Contact contact1 = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact1;
        
    	//Verify it's using Individual
    	contact1 = [select Account.Name from Contact Where ID = :contact1.ID];
    	System.assertEquals(CAO_Constants.BUCKET_PROCESSOR, contact1.Account.Name);
    	
    	//Verify we are still using Individual (Bucket) settings
    	contactsSettings = UTIL_CustomSettingsFacade.getContactsSettings();
    	System.assertEquals(CAO_Constants.BUCKET_PROCESSOR, contactsSettings.Account_Processor__c);
    	
    	//Change to Household Account
    	contactsSettings.Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR;
            
    	//Create a Contact
    	Contact contact2 = new Contact(FirstName = 'Test2', LastName = 'Testerson2');
        insert contact2;
        
    	//Verify it's using Household Account - a new Account should have been created for it
    	Integer numOfAccs = [select count() from Account];
    	System.assertEquals(2, numOfAccs);
    }
    
    /*********************************************************************************************************
    * @description Create a contact, and change it to private, against all three account models.  
    */
    @isTest
    public static void insertOneToOneChangeToPrivate() {
    	if (strTestOnly != '*' && strTestOnly != 'insertOneToOneChangeToPrivate') return;
    	
        insertOneToOneChangeToPrivateProcessor(CAO_Constants.ONE_TO_ONE_PROCESSOR);	
        insertOneToOneChangeToPrivateProcessor(CAO_Constants.BUCKET_PROCESSOR); 
        insertOneToOneChangeToPrivateProcessor(CAO_Constants.HH_ACCOUNT_PROCESSOR); 
    }
    
    public static void insertOneToOneChangeToPrivateProcessor(string strProcessor) {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getContactsSettingsForTests(
            new Contacts_and_Orgs_Settings__c (Account_Processor__c = strProcessor));
        
        CAO_Constants.setIndividualAccountForTests(CAO_Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);

        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select FirstName, LastName, AccountId  from Contact where id=:con.id];
        ID accountId = insertedContacts[0].AccountId;
        
        insertedContacts[0].Private__c = true;
        update insertedContacts;
        insertedContacts = [Select FirstName, LastName, AccountId,Private__c  from Contact where id=:con.id];
        //contact should have no AccountId
        system.assertEquals(null,insertedContacts[0].AccountId);
        system.assert(insertedContacts[0].Private__c);
        
        // account should NOT get deleted
        Account[] acts = [Select Id from Account where Id = :accountId];
        system.assertEquals(1, acts.size());
    }
    
    /*********************************************************************************************************
    * @description Create a Contact with TDTM triggers off, for both 1:1 and Household account models.  
    */
    @isTest
    public static void insertOneToOneTriggerOff() {
    	if (strTestOnly != '*' && strTestOnly != 'insertOneToOneTriggerOff') return;
        insertOneToOneTriggerOffProcessor(CAO_Constants.ONE_TO_ONE_PROCESSOR);
        insertOneToOneTriggerOffProcessor(CAO_Constants.HH_ACCOUNT_PROCESSOR);    
    }
    
    public static void insertOneToOneTriggerOffProcessor(string strProcessor) {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getContactsSettingsForTests(
            new Contacts_and_Orgs_Settings__c (Account_Processor__c = strProcessor));
        
        // turn off all TDTM triggers for this component
        List<Trigger_Handler__c> handlers = new List<Trigger_Handler__c>();
        handlers.add(new Trigger_Handler__c(Active__c = false, Asynchronous__c = false, 
              Class__c = 'ACCT_IndividualAccounts_TDTM', Load_Order__c = 1, Object__c = 'Contact', 
              Trigger_Action__c = 'BeforeInsert'));
        handlers.add(new Trigger_Handler__c(Active__c = false, Asynchronous__c = false, 
              Class__c = 'ACCT_IndividualAccounts_TDTM', Load_Order__c = 1, Object__c = 'Contact', 
              Trigger_Action__c = 'BeforeUpdate'));
        handlers.add(new Trigger_Handler__c(Active__c = false, Asynchronous__c = false, 
              Class__c = 'ACCT_IndividualAccounts_TDTM', Load_Order__c = 1, Object__c = 'Contact', 
              Trigger_Action__c = 'AfterInsert'));
        handlers.add(new Trigger_Handler__c(Active__c = false, Asynchronous__c = false, 
              Class__c = 'ACCT_IndividualAccounts_TDTM', Load_Order__c = 1, Object__c = 'Contact', 
              Trigger_Action__c = 'AfterUpdate'));                
        handlers.add(new Trigger_Handler__c(Active__c = false, Asynchronous__c = false, 
              Class__c = 'ACCT_IndividualAccounts_TDTM', Load_Order__c = 1, Object__c = 'Contact', 
              Trigger_Action__c = 'AfterDelete'));
        insert handlers;
         
        CAO_Constants.setIndividualAccountForTests(CAO_Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);

        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select FirstName, LastName, AccountId  from Contact where id=:con.id];

        //contact should have no AccountId
        system.assertEquals(null,insertedContacts[0].AccountId);
    }

    /*********************************************************************************************************
    * @description Test Method for inserting and updating a Contact in the One-to-One model 
    */
    @isTest
    public static void insertUpdateOneToOne() {
    	if (strTestOnly != '*' && strTestOnly != 'insertUpdateOneToOne') return;
    	insertUpdateOneToOneProcessor(CAO_Constants.ONE_TO_ONE_PROCESSOR);
    }

    /*********************************************************************************************************
    * @description Test Method for inserting and updating a Contact in the Household Account model 
    */
    @isTest
    public static void insertUpdateOneToOneHouseholds() {
        if (strTestOnly != '*' && strTestOnly != 'insertUpdateOneToOneHouseholds') return;
        insertUpdateOneToOneProcessor(CAO_Constants.HH_ACCOUNT_PROCESSOR); 
    }
    
    public static void insertUpdateOneToOneProcessor(string strProcessor) {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getContactsSettingsForTests(
            new Contacts_and_Orgs_Settings__c (Account_Processor__c = strProcessor));
        
        String newContactMailingStreet = '123 Elm St';

        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            MailingStreet = newContactMailingStreet,
            WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select FirstName, LastName, AccountId, Account.Name,Account.One2OneContact__c,MailingStreet,Account.BillingStreet,Organization_Type__c,Account.SYSTEMIsIndividual__c  from Contact where id=:con.id];
        UTIL_Debug.debug('****' +insertedContacts);
        UTIL_Debug.debug('****' +insertedcontacts[0].id);
        UTIL_Debug.debug('****' +insertedContacts);
        //one contact should have been created
        system.assertEquals(1,insertedContacts.size());
        //the account should have the right type
        if (strProcessor == CAO_Constants.ONE_TO_ONE_PROCESSOR)        
            system.assertEquals(CAO_Constants.ONE_TO_ONE_ORGANIZATION_TYPE,insertedcontacts[0].Organization_Type__c);
        else if (strProcessor == CAO_Constants.HH_ACCOUNT_PROCESSOR)    
            system.assertEquals(CAO_Constants.HH_ACCOUNT_TYPE,insertedcontacts[0].Organization_Type__c);
        //the account should be flagged as an individual
        system.assertEquals(true,insertedcontacts[0].Account.SYSTEMIsIndividual__c );
        //the account should have been named correctly
        if (strProcessor == CAO_Constants.ONE_TO_ONE_PROCESSOR)
            system.assertEquals(CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS + ' ' + CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,insertedcontacts[0].Account.Name);
        else if (strProcessor == CAO_Constants.HH_ACCOUNT_PROCESSOR)
            system.assertEquals(CAO_Constants.CONTACT_LASTNAME_FOR_TESTS + ' Household',insertedcontacts[0].Account.Name);        
        //relationship should be bi-directional
        system.assertEquals(insertedcontacts[0].id,insertedcontacts[0].Account.One2OneContact__c);
        //addresses should be sync'd
        system.assertEquals(newContactMailingStreet,insertedcontacts[0].Account.BillingStreet);
        system.assertEquals(insertedcontacts[0].MailingStreet,insertedcontacts[0].Account.BillingStreet);
        
        String updatedContactLastName = 'Contact_forTestsChange';
        String updatedOtherCity = 'Seattle';
        con.LastName=updatedContactLastName;
        con.OtherCity = updatedOtherCity;
        con.AccountId = insertedContacts[0].AccountId;
        update con;
        
        Contact[] updatedContacts = [Select FirstName, LastName, AccountId, Account.Name,Account.One2OneContact__c,MailingStreet,OtherCity,Account.BillingStreet,Account.ShippingCity from Contact where id=:con.id];
        
        //the account should have been named correctly
        /*if (strProcessor == CAO_Constants.ONE_TO_ONE_PROCESSOR)        
            system.assertEquals(updatedContacts[0].firstName + ' ' + updatedContacts[0].LastName,updatedContacts[0].Account.Name);
        else if (strProcessor == CAO_Constants.HH_ACCOUNT_PROCESSOR)
            system.assertEquals(updatedContacts[0].LastName + ' Household',updatedContacts[0].Account.Name);*/        
        
        //relationship should be bi-directional
        system.assertEquals(updatedContacts[0].id,updatedContacts[0].Account.One2OneContact__c);
        
        //addresses should be sync'd
        system.assertEquals(newContactMailingStreet,updatedContacts[0].MailingStreet);
        if (strProcessor == CAO_Constants.ONE_TO_ONE_PROCESSOR) {        
	        system.assertEquals(updatedOtherCity,updatedContacts[0].Account.ShippingCity);
	        system.assertEquals(updatedContacts[0].MailingStreet,updatedContacts[0].Account.BillingStreet);
	        system.assertEquals(updatedContacts[0].OtherCity,updatedContacts[0].Account.ShippingCity);
        }        
    }
    /*
    @isTest
    public static void testDefault()
    {
       
        boolean aDefaultIsSelected = false;
        Schema.DescribeFieldResult F = Schema.sObjectType.Contact.fields.Salutation;
            List<Schema.PicklistEntry> P = F.getPicklistValues();
            for(Schema.PicklistEntry pe : P){
                UTIL_Debug.debug('****' +pe.getValue() + ' : ' + pe.isDefaultValue());
                if (pe.isDefaultValue()){
                        aDefaultIsSelected = true;
                }
            }
         system.assert(aDefaultIsSelected); 
    }
    */
    
    /*********************************************************************************************************
    * @description Test Method for separating a Contact from it's One-to-One account, in 1:1 and Household Account models.
    */
    @isTest
    public static void detachOneToOne() {
    	if (strTestOnly != '*' && strTestOnly != 'detachOneToOne') return;
        detachOneToOneProcessor(CAO_Constants.ONE_TO_ONE_PROCESSOR);
        detachOneToOneProcessor(CAO_Constants.HH_ACCOUNT_PROCESSOR);
    }
    
    public static void detachOneToOneProcessor(string strProcessor) {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getContactsSettingsForTests(
            new Contacts_and_Orgs_Settings__c (Account_Processor__c = strProcessor));
        
        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select AccountId from Contact where id=:con.id];      
        
        Id originalAccountId = insertedContacts[0].AccountId;
        
        String updatedContactLastName = 'Contact_forTestsChange';
        
        con.AccountId = null;
        con.LastName = updatedContactLastName;
        update con;
        
        Contact[] updatedContacts = [Select FirstName, LastName, AccountId,Account.Name,Account.One2OneContact__c from Contact where id=:con.id];
        
        //Original Account should still be there
        Account[] originalAccount = [Select id from Account where Id=:originalAccountId];
        
        system.assertEquals(1,originalAccount.size());
        
        //AccountId of updated contact should match the orignial Account
        system.assertEquals(originalAccountId,updatedContacts[0].AccountId);
    }
        
    /*********************************************************************************************************
    * @description Test Method for editing a contact while it is being detached from it's One-to-One Account. This was a bug (#37)
    */
    @isTest
    public static void editContactDuringDetachOneToOne() {
    	if (strTestOnly != '*' && strTestOnly != 'editContactDuringDetachOneToOne') return;
        editContactDuringDetachOneToOneProcessor(CAO_Constants.ONE_TO_ONE_PROCESSOR);
        editContactDuringDetachOneToOneProcessor(CAO_Constants.HH_ACCOUNT_PROCESSOR);	
    }
    
    public static void editContactDuringDetachOneToOneProcessor(string strProcessor) {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getContactsSettingsForTests(
            new Contacts_and_Orgs_Settings__c (Account_Processor__c = strProcessor));
                
        String newContactMailingStreet = '123 Elm St';

        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            MailingStreet = newContactMailingStreet,
            WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select AccountId from Contact where id=:con.id];      
        
        Id originalAccountId = insertedContacts[0].AccountId;
        
        String updatedContactLastName = 'Contact_forTestsChange';
        String updateContactMailingStreet = '234 Oak St';
        
        con.AccountId = null;
        con.LastName = updatedContactLastName;
        con.MailingStreet = updateContactMailingStreet;
        update con;
        
        Contact[] updatedContacts = [Select FirstName, LastName, AccountId,Account.Name,Account.One2OneContact__c,MailingStreet,Organization_Type__c,Account.BillingStreet from Contact where id=:con.id];
        
        //AccountId of updated contact should match the orignial Account
        system.assertEquals(originalAccountId,updatedContacts[0].AccountId);
        
        //org type should be set correctly
        if (strProcessor == CAO_Constants.ONE_TO_ONE_PROCESSOR)            
            system.assertEquals(CAO_Constants.ONE_TO_ONE_ORGANIZATION_TYPE,updatedContacts[0].Organization_Type__c);
        else if (strProcessor == CAO_Constants.HH_ACCOUNT_PROCESSOR)            
            system.assertEquals(CAO_Constants.HH_ACCOUNT_TYPE,updatedContacts[0].Organization_Type__c);
        
        //the account should have been named correctly
        /*if (strProcessor == CAO_Constants.ONE_TO_ONE_PROCESSOR)            
            system.assertEquals(updatedContacts[0].FirstName + ' ' + updatedContacts[0].LastName,updatedContacts[0].Account.Name);
        else if (strProcessor == CAO_Constants.HH_ACCOUNT_PROCESSOR)            
            system.assertEquals(updatedContacts[0].LastName + ' Household',updatedContacts[0].Account.Name);*/
        
        //addresses should be sync'd
        if (strProcessor == CAO_Constants.ONE_TO_ONE_PROCESSOR) {           
	        system.assertEquals(updateContactMailingStreet,updatedContacts[0].MailingStreet);
	        system.assertEquals(updatedContacts[0].MailingStreet,updatedContacts[0].Account.BillingStreet);
        } 
    }

    /*********************************************************************************************************
    * @description Test Method for a new Contact in the Bucket Individual model 
    */
    @isTest
    public static void attachToIndividualAccount() {
    	if (strTestOnly != '*' && strTestOnly != 'attachToIndividualAccount') return;
        attachToIndividualAccountProcessor(CAO_Constants.BUCKET_PROCESSOR);
        attachToIndividualAccountProcessor(CAO_Constants.HH_ACCOUNT_PROCESSOR); 
    }
    
    public static void attachToIndividualAccountProcessor(string strProcessor) {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getContactsSettingsForTests(
            new Contacts_and_Orgs_Settings__c (Account_Processor__c = strProcessor));
                
        CAO_Constants.setIndividualAccountForTests(CAO_Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);

        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select Account.Name,AccountId,Organization_Type__c from Contact where id=:con.id];
        //the contact should have the right type
        if (strProcessor == CAO_Constants.BUCKET_PROCESSOR)
            system.assertEquals(CAO_Constants.BUCKET_ORGANIZATION_TYPE,insertedcontacts[0].Organization_Type__c);
        else if (strProcessor == CAO_Constants.HH_ACCOUNT_PROCESSOR)
            system.assertEquals(CAO_Constants.HH_ACCOUNT_TYPE,insertedcontacts[0].Organization_Type__c);
        //the account should have been named correctly
        if (strProcessor == CAO_Constants.BUCKET_PROCESSOR)
            system.assertEquals(CAO_Constants.BUCKET_ACCOUNT_NAME,insertedcontacts[0].Account.Name);
        else if (strProcessor == CAO_Constants.HH_ACCOUNT_PROCESSOR)
            system.assertEquals(con.LastName + ' Household',insertedcontacts[0].Account.Name);        
    }
    
    /*********************************************************************************************************
    * @description Test Method for detaching a Contact from the bucket individual account  
    */
    @isTest
    public static void detachIndividualAccount() {
    	if (strTestOnly != '*' && strTestOnly != 'detachIndividualAccount') return;
    	detachIndividualAccountProcessor(CAO_Constants.BUCKET_PROCESSOR);
        detachIndividualAccountProcessor(CAO_Constants.HH_ACCOUNT_PROCESSOR);
    }
    
    public static void detachIndividualAccountProcessor(string strProcessor) {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getContactsSettingsForTests(
            new Contacts_and_Orgs_Settings__c (Account_Processor__c = strProcessor));
               
        CAO_Constants.setIndividualAccountForTests(CAO_Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);

        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select Account.Name,AccountId,Organization_Type__c from Contact where id=:con.id];
        
        Id AccountId = insertedContacts[0].AccountId;
             
        con.AccountId = null;
        update con;
        
        Contact[] updatedContacts = [Select Lastname,Account.Name,AccountId,Organization_Type__c from Contact where id=:con.id];
        
        //the contact should have the right type
        if (strProcessor == CAO_Constants.BUCKET_PROCESSOR)
            system.assertEquals(CAO_Constants.BUCKET_ORGANIZATION_TYPE,updatedContacts[0].Organization_Type__c);
        else if (strProcessor == CAO_Constants.HH_ACCOUNT_PROCESSOR)
            system.assertEquals(CAO_Constants.HH_ACCOUNT_TYPE,updatedContacts[0].Organization_Type__c);
        //the account should have been named correctly
        if (strProcessor == CAO_Constants.BUCKET_PROCESSOR)
            system.assertEquals(CAO_Constants.BUCKET_ACCOUNT_NAME,updatedContacts[0].Account.Name);
        else if (strProcessor == CAO_Constants.HH_ACCOUNT_PROCESSOR)
            system.assertEquals(updatedContacts[0].Lastname + ' Household',updatedContacts[0].Account.Name);
        //the account should have the correct AccountId
        system.assertEquals(AccountId,updatedContacts[0].AccountId);        
    }

    /*********************************************************************************************************
    * @description Test Method for detaching a Contact from a normal account. It should land in the bucket account.
    */
    @isTest
    public static void detachFromNormalAccountToBucket() {
    	if (strTestOnly != '*' && strTestOnly != 'detachFromNormalAccountToBucket') return;
        detachFromNormalAccountToBucketProcessor(CAO_Constants.BUCKET_PROCESSOR);
    }
    
    /*********************************************************************************************************
    * @description Test Method for detaching a Contact from a normal account. It should land in the bucket account.
    */
    @isTest
    public static void detachFromNormalAccountToBucketAccountProcessor() {
        if (strTestOnly != '*' && strTestOnly != 'detachFromNormalAccountToBucketAccountProcessor') return;
        detachFromNormalAccountToBucketProcessor(CAO_Constants.HH_ACCOUNT_PROCESSOR);
    }
    
    public static void detachFromNormalAccountToBucketProcessor(string strProcessor) {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getContactsSettingsForTests(
            new Contacts_and_Orgs_Settings__c (Account_Processor__c = CAO_Constants.BUCKET_PROCESSOR));
               
        CAO_Constants.setIndividualAccountForTests(CAO_Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);
        
        Account acct = new Account(Name='Test Account 876');
        insert acct;
        
        Account[] insertedAccount = [select SystemIsIndividual__c from Account where id = :acct.id];
        
        //the account should not be an individual one
        system.assert(!insertedAccount[0].SystemIsIndividual__c);

        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            AccountId = acct.id,
            WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select Account.Name,Account.SystemIsIndividual__c,AccountId,Organization_Type__c from Contact where id=:con.id];
        
        //the contact should be connected to the account
        system.assertEquals(acct.id,insertedContacts[0].AccountId);
        //the account should not be an individual account
        system.assert(!insertedContacts[0].Account.SystemIsIndividual__c);
             
        con.AccountId = null;
        update con;
        
        Contact[] updatedContacts = [Select Account.Name,AccountId,Account.SystemIsIndividual__c,Organization_Type__c from Contact where id=:con.id];
        
        //the account should be an individual account
        system.assert(updatedContacts[0].Account.SystemIsIndividual__c);
        //the account should not be the one we started with
        system.assertNotEquals(acct.id,updatedContacts[0].AccountId);         
    }
    
    /*********************************************************************************************************
    * @description Add a contact to an existing 1:1 or Household Account
    */
    @isTest
    public static void contactAddedToExistingOneToOne() {
    	if (strTestOnly != '*' && strTestOnly != 'contactAddedToExistingOneToOne') return;
        contactAddedToExistingOneToOneProcessor(CAO_Constants.ONE_TO_ONE_PROCESSOR);
        contactAddedToExistingOneToOneProcessor(CAO_Constants.HH_ACCOUNT_PROCESSOR);   
    }
    
    public static void contactAddedToExistingOneToOneProcessor(string strProcessor) {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getContactsSettingsForTests(
            new Contacts_and_Orgs_Settings__c (Account_Processor__c = strProcessor));
        
        CAO_Constants.setIndividualAccountForTests(CAO_Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);

        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select Account.Name,Account.SystemIsIndividual__c,AccountId,Organization_Type__c from Contact where id=:con.id];
        
        Id accountId = insertedContacts[0].AccountId;
        
        Contact con2 = new Contact(FirstName='John', LastName='Smith',AccountId=accountId);
        
        insert con2;
        
        Contact[] insertedContact = [Select Account.Name,AccountId,Account.SystemIsIndividual__c,Organization_Type__c from Contact where id=:con2.id];
        
        if (strProcessor == CAO_Constants.ONE_TO_ONE_PROCESSOR)
            system.assertNotEquals(accountId,insertedContact[0].AccountId);  
        else if (strProcessor == CAO_Constants.HH_ACCOUNT_PROCESSOR)
            system.assertEquals(accountId,insertedContact[0].AccountId);        
    }
    
    /*********************************************************************************************************
    * @description Update a contact to an existing 1:1 or Household Account
    */
    @isTest
    public static void contactUpdatedToExistingOneToOne() {
    	if (strTestOnly != '*' && strTestOnly != 'contactUpdatedToExistingOneToOne') return;
        contactUpdatedToExistingOneToOneProcessor(CAO_Constants.ONE_TO_ONE_PROCESSOR);
    }
    
    @isTest
    public static void contactUpdatedToExistingOneToOneHH() {
        if (strTestOnly != '*' && strTestOnly != 'contactUpdatedToExistingOneToOneHH') return;
        contactUpdatedToExistingOneToOneProcessor(CAO_Constants.HH_ACCOUNT_PROCESSOR);   
    }
    
    public static void contactUpdatedToExistingOneToOneProcessor(string strProcessor) {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getContactsSettingsForTests(
            new Contacts_and_Orgs_Settings__c (Account_Processor__c = strProcessor));
        
        CAO_Constants.setIndividualAccountForTests(CAO_Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);

        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select Account.Name,Account.SystemIsIndividual__c,AccountId,Organization_Type__c from Contact where id=:con.id];
        
        Id accountId = insertedContacts[0].AccountId;
        
        Contact con2 = new Contact(FirstName='John', LastName='Smith',AccountId=null);       
        insert con2;
        
        // now update the contact to the existing account from contact 1
        con2.AccountId = accountId;
        update con2;
        
        Contact[] insertedContact = [Select Account.Name,AccountId,Account.SystemIsIndividual__c,Organization_Type__c from Contact where id=:con2.id];
        
        if (strProcessor == CAO_Constants.ONE_TO_ONE_PROCESSOR)
            system.assertNotEquals(accountId,insertedContact[0].AccountId);  
        else if (strProcessor == CAO_Constants.HH_ACCOUNT_PROCESSOR)
            system.assertEquals(accountId,insertedContact[0].AccountId);        
    }

    /*********************************************************************************************************
    * @description Update a contact's Lastname in the 1:1 and Household Account models
    */
    @isTest
    public static void contactInNormalOrgNameChange() {
    	if (strTestOnly != '*' && strTestOnly != 'contactInNormalOrgNameChange') return;
        contactInNormalOrgNameChangeProcessor(CAO_Constants.ONE_TO_ONE_PROCESSOR);
        contactInNormalOrgNameChangeProcessor(CAO_Constants.HH_ACCOUNT_PROCESSOR);
    }
    
    public static void contactInNormalOrgNameChangeProcessor(string strProcessor) {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getContactsSettingsForTests(
            new Contacts_and_Orgs_Settings__c (Account_Processor__c = strProcessor));
                
        CAO_Constants.setIndividualAccountForTests(CAO_Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);
        
        String acctName = 'Test Account 876';
        Account acct = new Account(Name=acctName);
        insert acct;

        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            AccountId = acct.id,
            WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select Account.Name,Account.SystemIsIndividual__c,AccountId,Organization_Type__c from Contact where id=:con.id];
        
        //the contact should be connected to the account
        system.assertEquals(acct.id,insertedContacts[0].AccountId);
        
        system.assertEquals(acctName,insertedContacts[0].Account.Name);
        
        
        Contact con2 = new Contact(id=con.id, LastName='Smith');
        
        update con2;
        
        Contact[] updatedContacts = [Select Account.Name,AccountId,Account.SystemIsIndividual__c,Organization_Type__c from Contact where id=:con.id];
        
        system.assertEquals(acctName,updatedContacts[0].Account.Name);         
    }
    
    /*********************************************************************************************************
    * @description Test Method for detaching a Contact from an org account. It should land in a one-to-one account. 
    */
    @isTest
    public static void detachFromNormalAccountToOneToOne() {
    	if (strTestOnly != '*' && strTestOnly != 'detachFromNormalAccountToOneToOne') return;
    	detachFromNormalAccountToOneToOneProcessor(CAO_Constants.ONE_TO_ONE_PROCESSOR);
    }
    
    /*********************************************************************************************************
    * @description Test Method for detaching a Contact from an org account. It should land in Household account. 
    */
    @isTest
    public static void detachFromNormalAccountToOneToOneHousehold() {
        if (strTestOnly != '*' && strTestOnly != 'detachFromNormalAccountToOneToOneHousehold') return;
        detachFromNormalAccountToOneToOneProcessor(CAO_Constants.HH_ACCOUNT_PROCESSOR);
    }
    
    public static void detachFromNormalAccountToOneToOneProcessor(string strProcessor) {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getContactsSettingsForTests(
            new Contacts_and_Orgs_Settings__c (Account_Processor__c = strProcessor));
        
        CAO_Constants.setIndividualAccountForTests(CAO_Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);
        
        Account acct = new Account(Name='Test Account 876');
        insert acct;
        
        Account[] insertedAccount = [select SystemIsIndividual__c from Account where id = :acct.id];
        
        //the account should not be an individual one
        system.assert(!insertedAccount[0].SystemIsIndividual__c);

        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            AccountId = acct.id,
            WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select Account.Name,Account.SystemIsIndividual__c,AccountId,Organization_Type__c from Contact where id=:con.id];
        
        //the contact should be connected to the account
        system.assertEquals(acct.id,insertedContacts[0].AccountId);
        //the account should not be an individual account
        system.assert(!insertedContacts[0].Account.SystemIsIndividual__c);
             
        con.AccountId = null;
        update con;
        
        Contact[] updatedContacts = [Select Account.Name,AccountId,Account.SystemIsIndividual__c,Organization_Type__c from Contact where id=:con.id];
        
        //the account should be an individual account
        system.assert(updatedContacts[0].Account.SystemIsIndividual__c);
        //the account should not be the one we started with
        system.assertNotEquals(acct.id,updatedContacts[0].AccountId);        
    }
    
    /*********************************************************************************************************
    * @description Delete a Contact and verify its One-to-One or Household Account is deleted.
    */
     public static testMethod void deleteContactNoOpp() {
     	if (strTestOnly != '*' && strTestOnly != 'deleteContactNoOpp') return;
        deleteContactNoOppProcessor(CAO_Constants.ONE_TO_ONE_PROCESSOR);
        deleteContactNoOppProcessor(CAO_Constants.HH_ACCOUNT_PROCESSOR);
     }
     
     public static void deleteContactNoOppProcessor(string strProcessor) {

        Contacts_and_Orgs_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getContactsSettingsForTests(
            new Contacts_and_Orgs_Settings__c (Account_Processor__c = strProcessor));

        
        CAO_Constants.setIndividualAccountForTests(CAO_Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);
        
        String newContactMailingStreet = '123 Elm St';

        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            MailingStreet = newContactMailingStreet,
            WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        Id contactId;
        contactId = con.id;
        
        Contact[] insertedContacts = [Select FirstName, LastName, AccountId  from Contact where id=:contactId];
        Id createdAccountId = insertedContacts[0].AccountId;
        
        delete con;
        
        insertedContacts = [Select FirstName, LastName, AccountId  from Contact where id=:contactId];
        system.assertEquals(0,insertedContacts.size());
        
        Account[] missingAccount = [select id from Account where id=:createdAccountId];
        system.assertEquals(0,missingAccount.size());
    }
    
    /*********************************************************************************************************
    * @description Delete a Contact with Opps and verify its One-to-One or Household Account is not deleted.
    */
    public static testMethod void deleteContactWithOpp() {
    	if (strTestOnly != '*' && strTestOnly != 'deleteContactWithOpp') return;
        deleteContactWithOppProcessor(CAO_Constants.ONE_TO_ONE_PROCESSOR);
        deleteContactWithOppProcessor(CAO_Constants.HH_ACCOUNT_PROCESSOR);
    }    
    
    public static void deleteContactWithOppProcessor(string strProcessor) {
        
        Contacts_and_Orgs_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getContactsSettingsForTests(
            new Contacts_and_Orgs_Settings__c (Account_Processor__c = strProcessor));        
        
        CAO_Constants.setIndividualAccountForTests(CAO_Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);
              
        String newContactMailingStreet = '123 Elm St';

        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            MailingStreet = newContactMailingStreet,
            WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        Id contactId;
        contactId = con.id;
        Id accountId;
        Contact[] insertedContacts = [Select FirstName, LastName, AccountId  from Contact where id=:contactId];
        
        Id createdAccountId = insertedContacts[0].AccountId;
       
       Opportunity opp = new Opportunity(
            Amount=500,
            AccountId=createdAccountId,
            Name='test',
            StageName='Closed/Won',
            CloseDate=System.today()
        );
        insert opp;
        
        delete con;
        
        Account[] missingAccount = [select id from Account where id=:createdAccountId];
        system.assertEquals(1,missingAccount.size());
    }
    
    /*********************************************************************************************************
    * @description Delete a Contact from an Org Account and make sure the Account is not deleted.
    */
    public static testMethod void deleteContactNormalAccountOneToOne() {
    	if (strTestOnly != '*' && strTestOnly != 'deleteContactNormalAccountOneToOne') return;
        deleteContactNormalAccountProcessor(CAO_Constants.ONE_TO_ONE_PROCESSOR);
    }
    
    /*********************************************************************************************************
    * @description Delete a Contact from an Org Account and make sure the Account is not deleted.
    */
    public static testMethod void deleteContactNormalAccountHouseholdAcc() {
        if (strTestOnly != '*' && strTestOnly != 'deleteContactNormalAccountHouseholdAcc') return;
        deleteContactNormalAccountProcessor(CAO_Constants.HH_ACCOUNT_PROCESSOR);
    }
    
    public static void deleteContactNormalAccountProcessor(string strProcessor) {
              
        Contacts_and_Orgs_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getContactsSettingsForTests(
            new Contacts_and_Orgs_Settings__c (Account_Processor__c = strProcessor));        

        CAO_Constants.setIndividualAccountForTests(CAO_Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);
        
        Account orgAccount = new Account(
            Name='Fake account'
        );
        insert orgAccount;
               
        String newContactMailingStreet = '123 Elm St';

        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            MailingStreet = newContactMailingStreet,
            AccountId=orgAccount.id,
            WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select FirstName, LastName, AccountId  from Contact where id=:con.id];
        
        Id createdAccountId = insertedContacts[0].AccountId;
            
        delete con;
        
        Account[] missingAccount = [select id from Account where id=:createdAccountId];
        system.assertEquals(1,missingAccount.size());
    }   
     
    /*********************************************************************************************************
    * @description Rename a Contact's firstname to null and make sure the 1:1 Account's name gets updated
    */
    @isTest
    public static void ghIssue16a(){
    	if (strTestOnly != '*' && strTestOnly != 'ghIssue16a') return;
        ghIssue16Processor(CAO_Constants.ONE_TO_ONE_PROCESSOR);
    }
    
    /*********************************************************************************************************
    * @description Rename a Contact's firstname to null and make sure the Household Account's name gets updated
    */
    @isTest
    public static void ghIssue16b(){
    	if (strTestOnly != '*' && strTestOnly != 'ghIssue16b') return;
        ghIssue16Processor(CAO_Constants.HH_ACCOUNT_PROCESSOR);
    }
    
    public static void ghIssue16Processor(string strProcessor){
        /* Set value of Account name to blank when first name is blank, not null */ 
        
        Contacts_and_Orgs_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getContactsSettingsForTests(
            new Contacts_and_Orgs_Settings__c (Account_Processor__c = strProcessor));
        
        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        con = [select AccountId from Contact where id = :con.Id];
        Account newAcc = [select id,Name from Account where id = :con.AccountId limit 1];
        if (strProcessor == CAO_Constants.ONE_TO_ONE_PROCESSOR)
            system.assertEquals(newAcc.Name, CAO_Constants.Contact_FIRSTNAME_FOR_TESTS + ' ' + CAO_Constants.Contact_LASTNAME_FOR_TESTS);
        else if (strProcessor == CAO_Constants.HH_ACCOUNT_PROCESSOR)            
            system.assertEquals(newAcc.Name, CAO_Constants.Contact_LASTNAME_FOR_TESTS + ' Household');
        
        //set name to null
        con.FirstName = null;
        
        Test.startTest();
        update con;
        Test.stopTest();
        
        newAcc = [select id,Name from Account where id = :con.AccountId limit 1];
        if (strProcessor == CAO_Constants.ONE_TO_ONE_PROCESSOR)
            system.assertEquals(newAcc.Name, CAO_Constants.Contact_LASTNAME_FOR_TESTS);
        else if (strProcessor == CAO_Constants.HH_ACCOUNT_PROCESSOR)            
            system.assertEquals(newAcc.Name, CAO_Constants.Contact_LASTNAME_FOR_TESTS + ' Household');
    }
}