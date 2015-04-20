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
    * @description Create a Contact with TDTM triggers off, for both 1:1 and Household account models.  
    */
    @isTest
    public static void insertContactTriggerOff() {
    	if (strTestOnly != '*' && strTestOnly != 'insertContactTriggerOff') return;

        UTIL_CustomSettingsFacade.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c(Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR));
        
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
    * @description Test Method for a new Contact, with Household Account selected as default Acc Record Type
    */
    @isTest
    public static void newContactHouseholdModel() {
    	if (strTestOnly != '*' && strTestOnly != 'newContactHouseholdModel') return;

        UTIL_CustomSettingsFacade.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c(Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR));
        
        Contact con = UTIL_UnitTestData_TEST.getContact();
        
        Test.startTest();
        insert con;
        Test.stopTest();
        
        Contact insertedContact = [Select Account.Name, AccountId, Organization_Type__c from Contact where id=:con.id];
        
        //the contact should have the right type
        system.assertEquals(CAO_Constants.HH_ACCOUNT_PROCESSOR, insertedcontact.Organization_Type__c);
        system.assertEquals(con.LastName + ' Household', insertedcontact.Account.Name);  
    }

    /*********************************************************************************************************
    * @description Test Method for inserting and updating a Contact in the Household Account model 
    */
    @isTest
    public static void insertUpdateContactHouseholds() {
        if (strTestOnly != '*' && strTestOnly != 'insertUpdateContactHouseholds') return;

        UTIL_CustomSettingsFacade.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c(Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR));
        
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
        
        Contact[] insertedContacts = [Select FirstName, LastName, AccountId, Account.Name,Account.One2OneContact__c,MailingStreet, 
        				Account.BillingStreet,Organization_Type__c,Account.SYSTEMIsIndividual__c  from Contact where id=:con.id];

        //one contact should have been created
        system.assertEquals(1,insertedContacts.size());
        
        //the account should have the right type   
        system.assertEquals(CAO_Constants.HH_ACCOUNT_PROCESSOR,insertedcontacts[0].Organization_Type__c);
        
        //the account should be flagged as an individual
        system.assertEquals(true,insertedcontacts[0].Account.SYSTEMIsIndividual__c );
        
        //the account should have been named correctly
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
        
        Contact[] updatedContacts = [Select FirstName, LastName, AccountId, Account.Name,Account.One2OneContact__c,MailingStreet,OtherCity, 
        							Account.BillingStreet,Account.ShippingCity from Contact where id=:con.id];

        //relationship should be bi-directional
        system.assertEquals(updatedContacts[0].id,updatedContacts[0].Account.One2OneContact__c);
        
        //addresses should be sync'd
        system.assertEquals(newContactMailingStreet,updatedContacts[0].MailingStreet);       
    }
    
    /*********************************************************************************************************
    * @description Add a contact to an existing or Household Account
    */
    @isTest
    public static void contactAddedToExisting() {
    	if (strTestOnly != '*' && strTestOnly != 'contactAddedToExisting') return;

       AFFL_MultiRecordType_TEST.setup();
        
        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        con = [select AccountId from Contact where id=:con.id];
        Id accountId = con.AccountId;
        
        Contact con2 = new Contact(FirstName='John', LastName='Smith', AccountId = accountId);
        
        Test.startTest();
        AFFL_MultiRecordType_TDTM.afflMultiHasRunBefore = false;
        insert con2;
        Test.stopTest();
        
        con2 = [select AccountId, Primary_Household__c from Contact where id=:con2.id];       
        system.assertEquals(accountId, con2.AccountId);  
        
        List<Affiliation__c> con2affls = [select Primary__c from Affiliation__c where Contact__c =:con2.Id and Organization__c =:accountId];
        system.assertEquals(1, con2affls.size());
        system.assertEquals(true, con2affls[0].Primary__c);
        
        system.assertEquals(accountId, con2.Primary_Household__c);
    }
    
    /*********************************************************************************************************
    * @description Update a contact to an existing Household Account
    */
    @isTest
    public static void contactUpdatedToExistingHH() {
        if (strTestOnly != '*' && strTestOnly != 'contactUpdatedToExistingHH') return;

        UTIL_CustomSettingsFacade.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c(Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR));
        
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
        
        system.assertEquals(accountId,insertedContact[0].AccountId);        
    }

    /*********************************************************************************************************
    * @description Update a contact's Lastname in the Household Account models
    */
    @isTest
    public static void contactInNormalOrgNameChange() {
    	if (strTestOnly != '*' && strTestOnly != 'contactInNormalOrgNameChange') return;

        UTIL_CustomSettingsFacade.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c(Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR));
                        
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
    * @description Test Method for detaching a Contact from an org account. It should land in Household account. 
    */
    @isTest
    public static void detachFromNormalAccountToeHousehold() {
        if (strTestOnly != '*' && strTestOnly != 'detachFromNormalAccountToeHousehold') return;

        UTIL_CustomSettingsFacade.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c(Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR));
                
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
        Test.startTest();
        update con;
        Test.stopTest();
        
        Contact[] updatedContacts = [Select Account.Name,AccountId,Account.SystemIsIndividual__c,Organization_Type__c from Contact where id=:con.id];
        
        //the account should be an individual account
        system.assert(updatedContacts[0].Account.SystemIsIndividual__c);
        //the account should not be the one we started with
        system.assertNotEquals(acct.id,updatedContacts[0].AccountId);        
    }
    
    /*********************************************************************************************************
    * @description Delete a Contact and verify its Household Account is deleted.
    */
     public static testMethod void deleteContactNoOpp() {
     	if (strTestOnly != '*' && strTestOnly != 'deleteContactNoOpp') return;

        UTIL_CustomSettingsFacade.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c(Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR));
        
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
        
        Test.startTest();
        delete con;
        Test.stopTest();
        
        insertedContacts = [Select FirstName, LastName, AccountId  from Contact where id=:contactId];
        system.assertEquals(0,insertedContacts.size());
        
        Account[] missingAccount = [select id from Account where id=:createdAccountId];
        system.assertEquals(0,missingAccount.size());
    }
    
    /*********************************************************************************************************
    * @description Delete a Contact with Opps and verify its Household Account is not deleted.
    */
    public static testMethod void deleteContactWithOpp() {
    	if (strTestOnly != '*' && strTestOnly != 'deleteContactWithOpp') return;
        
        UTIL_CustomSettingsFacade.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c(Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR));       
                      
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
        
        Test.startTest();
        delete con;
        Test.stopTest();
        
        Account[] missingAccount = [select id from Account where id=:createdAccountId];
        system.assertEquals(1,missingAccount.size());
    }
    
    /*********************************************************************************************************
    * @description Delete a Contact from an Org Account and make sure the Account is not deleted.
    */
    public static testMethod void deleteContactNormalAccountHouseholdAcc() {
        if (strTestOnly != '*' && strTestOnly != 'deleteContactNormalAccountHouseholdAcc') return;
              
        UTIL_CustomSettingsFacade.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c(Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR));
        
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
          
        Test.startTest();  
        delete con;
        Test.stopTest();
        
        Account[] missingAccount = [select id from Account where id=:createdAccountId];
        system.assertEquals(1,missingAccount.size());
    }   
    
    /*********************************************************************************************************
    * @description Rename a Contact's firstname to null and make sure the Household Account's name gets updated
    */
    @isTest
    public static void firstNameToNull(){
    	if (strTestOnly != '*' && strTestOnly != 'ghIssue16b') return;
        
        UTIL_CustomSettingsFacade.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c(Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR));
        
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
        
        system.assertEquals(newAcc.Name, CAO_Constants.Contact_LASTNAME_FOR_TESTS + ' Household');
        
        //set name to null
        con.FirstName = null;
        
        Test.startTest();
        update con;
        Test.stopTest();
        
        newAcc = [select id,Name from Account where id = :con.AccountId limit 1];
        system.assertEquals(newAcc.Name, CAO_Constants.Contact_LASTNAME_FOR_TESTS + ' Household');
    }
}