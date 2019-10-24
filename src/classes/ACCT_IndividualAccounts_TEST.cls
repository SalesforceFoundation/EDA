/*
    Copyright (c) 2011, Salesforce.org
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
* @date 2011 (1.x)
* @group Accounts
* @group-content ../../ApexDocContent/Accounts.htm
* @description Tests for ACCT_IndividualAccounts_TDTM.
*/
@isTest
private class ACCT_IndividualAccounts_TEST {
    /*********************************************************************************************************
    * @description Create a Contact with TDTM triggers off
    */
    @isTest
    public static void insertContactTriggerOff() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID()));

        // turn off all TDTM triggers for this component
        TDTM_ProcessControl.turnOffRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Insert);
        TDTM_ProcessControl.turnOffRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Update);
        TDTM_ProcessControl.turnOffRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Delete);

        Contact con = UTIL_UnitTestData_API.getContact();

        Test.startTest();
        insert con;
        Test.stopTest();

        Contact[] insertedContacts = [SELECT FirstName, LastName, AccountId
                                      FROM Contact
                                      WHERE Id = :con.Id];

        //contact should have no AccountId
        System.assertEquals(null,insertedContacts[0].AccountId);
    }

    /*********************************************************************************************************
    * @description Test Method for a new Contact
    */
    @isTest
    public static void newContact() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID()));

        Contact con = UTIL_UnitTestData_API.getContact();

        Test.startTest();
        insert con;
        Test.stopTest();

        Contact insertedContact = [SELECT Account.Name, AccountId
                                   FROM Contact
                                   WHERE Id = :con.Id];

        //the contact should have the right type
        System.assertEquals(con.LastName + ' ' + Label.DefaultAdminName, insertedcontact.Account.Name);
    }

    /*********************************************************************************************************
    * @description Test Method for inserting and updating a Contact
    */
    @isTest
    public static void insertUpdateContact() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID()));

        String newContactMailingStreet = '123 Elm St';

        Contact con = UTIL_UnitTestData_API.getContact();
        insert con;

        Contact[] insertedContacts = [SELECT FirstName, LastName, AccountId,
                                      Account.Name,Account.Primary_Contact__c,MailingStreet,
                                      Account.BillingStreet
                                      FROM Contact
                                      WHERE Id = :con.Id];

        //one contact should have been created
        System.assertEquals(1,insertedContacts.size());

        //relationship should be bi-directional
        System.assertEquals(insertedcontacts[0].id,insertedcontacts[0].Account.Primary_Contact__c);

        String updatedContactLastName = 'Contact_forTestsChange';
        String updatedOtherCity = 'Seattle';
        con.LastName=updatedContactLastName;
        con.OtherCity = updatedOtherCity;
        con.AccountId = insertedContacts[0].AccountId;
        update con;

        Contact[] updatedContacts = [SELECT FirstName, LastName, AccountId,
                                     Account.Name,Account.Primary_Contact__c
                                     FROM Contact
                                     WHERE Id = :con.Id];

        //relationship should be bi-directional
        System.assertEquals(updatedContacts[0].id,updatedContacts[0].Account.Primary_Contact__c);
    }

    /*********************************************************************************************************
    * @description Add a contact to an existing Account
    */
    @isTest
    public static void contactAddedToExistingAcc() {
       UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID()));

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Primary Business Organization'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = 'Primary Household'));
        insert mappings;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        con = [SELECT AccountId
               FROM Contact
               WHERE id = :con.id];
        Id accountId = con.AccountId;

        Contact con2 = contacts[1];
        con2.AccountId = accountId;

        Test.startTest();
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_Before_Insert, false);
        insert con2;
        Test.stopTest();

        con2 = [SELECT AccountId, Primary_Household__c
                FROM Contact
                WHERE Id = :con2.Id];
        System.assertEquals(accountId, con2.AccountId);

    }

    /*********************************************************************************************************
    * @description Update a contact to an existing Account
    */
    @isTest
    public static void contactUpdatedToExistingAcc() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID()));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Contact[] insertedContacts = [SELECT Account.Name, AccountId
                                      FROM Contact
                                      WHERE Id = :con.Id];
        Id accountId = insertedContacts[0].AccountId;

        Contact con2 = contacts[1];
        con2.AccountId = null;
        insert con2;

        // now update the contact to the existing account from contact 1
        con2.AccountId = accountId;
        update con2;

        Contact[] insertedContact = [SELECT Account.Name, AccountId
                                     FROM Contact
                                     WHERE Id = :con2.Id];

        System.assertEquals(accountId,insertedContact[0].AccountId);
    }

    /*********************************************************************************************************
    * @description Update a contact's Lastname in the Account
    * Based on latest requirement, if there is a change on contact's last name,
    * admin account's lastname should be changed accordingly.
    */
    @isTest
    public static void contactInNormalOrgNameChangem() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID()));

        String acctName = 'Test Account 876';
        List<Account> accts = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getAdminAccRecTypeID());
        accts[0].Name = acctName;
        insert accts[0];

        Contact con = UTIL_UnitTestData_API.getContact();
        con.AccountId = accts[0].id;
        insert con;

        Contact[] insertedContacts = [SELECT Account.Name, AccountId
                                      FROM Contact
                                      WHERE id = :con.Id];

        //the contact should be connected to the account
        System.assertEquals(accts[0].id,insertedContacts[0].AccountId);
        System.assertEquals(acctName,insertedContacts[0].Account.Name);

        con.LastName = 'Smith';
        update con;

        Contact[] updatedContacts = [SELECT Account.Name, AccountId
                                     FROM Contact
                                     WHERE Id = :con.Id];
        System.assertEquals(con.LastName + ' ' + Label.DefaultAdminName, updatedContacts[0].Account.Name);
    }

    /*********************************************************************************************************
    * @description Test Method for detaching a Contact from an already existing account
    * which is the default account model.
    */
    @isTest
    public static void detachFromDefaultAccount() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID()));

        Account acct = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getAdminAccRecTypeID())[0];
        insert acct;

        Contact con = UTIL_UnitTestData_API.getContact();
        con.AccountId = acct.id;
        insert con;

        List<Contact> insertedContacts = [SELECT Account.Name, AccountId
                                          FROM Contact
                                          WHERE Id = :con.Id];
        //the contact should be connected to the account
        System.assertEquals(acct.id, insertedContacts[0].AccountId);

        con.AccountId = NULL;
        Test.startTest();
        update con;
        Test.stopTest();

        List<Contact> updatedContacts = [SELECT Account.Name, AccountId, Id
                                         FROM Contact
                                         WHERE Id = :con.Id];
        List<Account> relatedAccount = [SELECT Primary_Contact__c
                                        FROM Account];

        //the account should not be the one we started with
        System.assertEquals(acct.id, updatedContacts[0].AccountId);
        System.assertNotEquals(NULL, relatedAccount[0].Primary_Contact__c);
        System.assertEquals(updatedContacts[0].id, relatedAccount[0].Primary_Contact__c);
    }

    /*********************************************************************************************************
    * @description Delete a Contact and verify its parent Account is deleted.
    */
     @isTest
     public static void deleteContactNoOpps() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(
                    Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                    Accounts_to_Delete__c = UTIL_Describe_API.getAdminAccRecTypeID()));

        String newContactMailingStreet = '123 Elm St';

        Contact con = UTIL_UnitTestData_API.getContact();
        insert con;
        Id contactId;
        contactId = con.id;

        Contact[] insertedContacts = [SELECT FirstName, LastName, AccountId
                                      FROM Contact
                                      WHERE Id = :contactId];
        Id createdAccountId = insertedContacts[0].AccountId;

        Test.startTest();
        delete con;
        Test.stopTest();

        insertedContacts = [SELECT FirstName, LastName, AccountId
                            FROM Contact
                            WHERE Id = :contactId];
        System.assertEquals(0,insertedContacts.size());

        Account[] missingAccount = [SELECT Id
                                    FROM Account
                                    WHERE Id = :createdAccountId];
        System.assertEquals(0,missingAccount.size());
    }

    /*********************************************************************************************************
    * @description Delete a Contact with Opps and verify its parent Account is not deleted.
    */
    @isTest
    public static void deleteContactWithOppAdm() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(
                                    Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                                    Accounts_to_Delete__c = UTIL_Describe_API.getAdminAccRecTypeID()));

        String newContactMailingStreet = '123 Elm St';

        Contact con = UTIL_UnitTestData_API.getContact();
        insert con;
        Id contactId;
        contactId = con.id;
        Id accountId;
        Contact[] insertedContacts = [SELECT FirstName, LastName, AccountId
                                      FROM Contact
                                      WHERE Id = :contactId];

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

        Account[] missingAccount = [SELECT Id
                                    FROM Account
                                    WHERE Id = :createdAccountId];
        System.assertEquals(1,missingAccount.size());
    }

    /*********************************************************************************************************
    * @description Specify only admin accounts with all child contacts deleted will be automatically deleted,
    * and delete a Contact from an Account without type. Make sure the Account is not deleted.
    */
    @isTest
    public static void deleteContactNormalAccount() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(
                                    Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                                    Accounts_to_Delete__c = UTIL_Describe_API.getAdminAccRecTypeID()));

        List<Account> orgAccounts = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID());
        insert orgAccounts[0];

        String newContactMailingStreet = '123 Elm St';

        Contact con = UTIL_UnitTestData_API.getContact();
        con.MailingStreet = newContactMailingStreet;
        con.AccountId = orgAccounts[0].id;
        insert con;

        Contact[] insertedContacts = [SELECT FirstName, LastName, AccountId
                                      FROM Contact
                                      WHERE Id = :con.Id];
        Id createdAccountId = insertedContacts[0].AccountId;

        Test.startTest();
        delete con;
        Test.stopTest();

        Account[] missingAccount = [SELECT Id
                                    FROM Account
                                    WHERE Id = :createdAccountId];
        System.assertEquals(1, missingAccount.size());
    }

    /*********************************************************************************************************
    * @description Rename a Contact's firstname to null and make sure the Admin Account's name doesn't change.
    */
    @isTest
    public static void firstNameToNullAdm() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID()));

        Contact con = UTIL_UnitTestData_API.getContact();
        insert con;

        con = [SELECT AccountId, LastName
               FROM Contact
               WHERE Id = :con.Id];
        Account newAcc = [SELECT Id, Name
                          FROM Account
                          WHERE Id = :con.AccountId LIMIT 1];
        System.assertEquals(newAcc.Name, con.LastName + ' ' + Label.DefaultAdminName);

        //set name to null
        con.FirstName = null;

        Test.startTest();
        update con;
        Test.stopTest();

        newAcc = [SELECT Id, Name
                  FROM Account
                  WHERE Id = :con.AccountId LIMIT 1];
        System.assertEquals(newAcc.Name, con.LastName + ' ' + Label.DefaultAdminName);
    }

    /*********************************************************************************************************
    * @description Insert a new contact and the default account record type is Household
    * Make sure the Account's name is set based on account naming setting.
    */
    @isTest
    public static void newContactNewHHAcc() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = '{!FirstName} {!LastName} Household', Automatic_Household_Naming__c = true));

        Contact con = UTIL_UnitTestData_API.getContact();
        Test.startTest();
        insert con;
        Test.stopTest();

        Account assertAccount = [SELECT Id, RecordType.Name, Name
                                 FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' Household', assertAccount.Name);
    }

    /*********************************************************************************************************
    * @description Insert a new contact and link it to an existing Household Account
    * Make sure the Account's name is set based on account naming setting.
    */
    @isTest
    public static void newContactExistingHHAcc() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = '{!FirstName} {!LastName} Household', Automatic_Household_Naming__c = true));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name
                                 FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' Household', assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.LastName = con.LastName + '2';
        con2.FirstName = 'Test2';
        Test.startTest();
        insert con2;
        Test.stopTest();

        assertAccount = [SELECT Id, RecordType.Name, Name
                         FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' and ' + con2.FirstName + ' ' + con2.LastName + ' Household', assertAccount.Name);

    }

    /*********************************************************************************************************
    * @description Insert a new contact with the same lastname and link it to an existing Household Account
    * Make sure the Account's name is set based on account naming setting.
    * This naming setting has parenthesis around firstname
    */
    @isTest
    public static void newContactExistingHHAccSameLastNameWithParenthesis() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = '{!LastName} ({!FirstName}) Household', Automatic_Household_Naming__c = true));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name
                                 FROM Account limit 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.LastName + ' (' + con.FirstName + ') Household', assertAccount.Name);

        Contact con2 = contacts[1];
        con2.FirstName = 'Test2';
        con2.LastName = con.LastName;
        con2.AccountId = assertAccount.id;
        Test.startTest();
        insert con2;
        Test.stopTest();

        assertAccount = [SELECT Id, RecordType.Name, Name
                         FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.LastName + ' (' + con.FirstName + ' and ' + con2.FirstName + ') Household', assertAccount.Name);
    }

    /*********************************************************************************************************
    * @description Insert a new contact with the same lastname and link it to an existing Household Account
    * Make sure the Account's name is set based on account naming setting.
    */
    @isTest
    public static void newContactExistingHHAccSameLastName() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = '{!FirstName} {!LastName} Household', Automatic_Household_Naming__c = true));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name
                                 FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' Household', assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.LastName = con.LastName;
        con2.FirstName = 'Test2';
        Test.startTest();
        insert con2;
        Test.stopTest();

        assertAccount = [SELECT Id, RecordType.Name, Name
                         FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' and ' + con2.FirstName + ' ' + con2.LastName + ' Household', assertAccount.Name);

    }

    /*********************************************************************************************************
    * @description Update the name of a contact linked to a Household Account
    * Make sure the Account's name is set based on account naming setting.
    */
    @isTest
    public static void updateContactExistingHHAcc() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = '{!FirstName} {!LastName} Household', Automatic_Household_Naming__c = true));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name
                                 FROM Account limit 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' Household', assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.FirstName = 'Test2';
        con2.LastName = con.LastName + '2';
        insert con2;

        assertAccount = [SELECT Id, RecordType.Name, Name
                         FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' and ' + con2.FirstName + ' ' + con2.LastName + ' Household', assertAccount.Name);

        con2.FirstName = 'Test3';
        con2.LastName = 'Contact_forTests3';
        Test.startTest();
        update con2;
        Test.stopTest();

        assertAccount = [SELECT Id, RecordType.Name, Name
                         FROM Account];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' and ' + con2.FirstName + ' ' + con2.LastName + ' Household', assertAccount.Name);
    }

    /*********************************************************************************************************
    * @description
    * Update the custom setting of automatic household naming as false
    * Create a new contact and link it to an existing Household Account
    * Make sure the Account's name is not set based on account naming setting.
    */
    @isTest
    public static void newContactExistingHHAccNotAutomatic() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = '{!FirstName} {!LastName} Household', Automatic_Household_Naming__c = false));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name
                                 FROM Account limit 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' Household', assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.FirstName = 'Test2';
        con2.LastName = con.LastName + '2';
        insert con2;

        assertAccount = [SELECT Id, RecordType.Name, Name
                         FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' Household', assertAccount.Name);
    }

    /*********************************************************************************************************
    * @description
    * Create a new contact and link it to an existing Household Account
    * Set the new contact as excluded from household naming
    * Make sure the Account's name is not set based on account naming setting.
    */
    @isTest
    public static void newContactExistingHHAccExcludedFromNaming() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = '{!FirstName} {!LastName} Household', Automatic_Household_Naming__c = true));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name
                                 FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' Household', assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.FirstName = 'Test2';
        con2.LastName = con.LastName + '2';
        con2.Exclude_From_Household_Name__c = true;
        insert con2;

        assertAccount = [SELECT Id, RecordType.Name, Name
                         FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' Household', assertAccount.Name);

        con2.Exclude_From_Household_Name__c = false;
        update con2;

        assertAccount = [SELECT Id, RecordType.Name, Name
                         FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' and ' + con2.FirstName + ' ' + con2.LastName + ' Household', assertAccount.Name);
    }

    /*********************************************************************************************************
    * @description
    * Update the custom setting of automatic household naming as false
    * Update the name of a contact linked to a Household Account
    * Make sure the Account's name is not set based on account naming setting.
    */
    @isTest
    public static void updateContactExistingHHAccNotAutomatic() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = '{!FirstName} {!LastName} Household', Automatic_Household_Naming__c = false));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name
                                 FROM Account limit 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' Household', assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.FirstName = 'Test2';
        con2.LastName = con.LastName + '2';
        insert con2;

        assertAccount = [SELECT Id, RecordType.Name, Name
                         FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' Household', assertAccount.Name);

        con2.FirstName = 'Test3';
        con2.LastName = 'Contact_forTests3';
        Test.startTest();
        update con2;
        Test.stopTest();

        assertAccount = [SELECT Id, RecordType.Name, Name
                         FROM Account];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' Household', assertAccount.Name);
    }

    /*********************************************************************************************************
    * @description
    * Update the custom setting of automatic household naming as true
    * Delete the contact linked to a Household Account
    * Make sure the Account's name is set back based on account naming setting.
    */
    @isTest
    public static void deleteContactFromHHAccAutomatic() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = '{!FirstName} {!LastName} Household', Automatic_Household_Naming__c = true));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name
                                 FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' Household', assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.FirstName = 'Test2';
        con2.LastName = con.LastName + '2';
        insert con2;

        assertAccount = [SELECT Id, RecordType.Name, Name
                         FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' and ' + con2.FirstName + ' ' + con2.LastName + ' Household', assertAccount.Name);

        Test.startTest();
        delete con2;
        Test.stopTest();

        assertAccount = [SELECT Id, RecordType.Name, Name
                         FROM Account];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' Household', assertAccount.Name);
    }

    /*********************************************************************************************************
    * @description
    * Update the custom setting of automatic household naming as true
    * Disconnect the contact from a Household Account
    * Make sure the Account's name is set back based on account naming setting.
    */
    @isTest
    public static void disconnectContactFromHHAccAutomatic() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = '{!FirstName} {!LastName} Household', Automatic_Household_Naming__c = true));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name
                                 FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' Household', assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.FirstName = 'Test2';
        con2.LastName = con.LastName + '2';
        insert con2;

        assertAccount = [SELECT Id, RecordType.Name, Name
                         FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' and ' + con2.FirstName + ' ' + con2.LastName + ' Household', assertAccount.Name);

        con2.AccountId = null;
        Test.startTest();
        update con2;
        Test.stopTest();

        //After remove the Account lookup for con2, system will create a new Account for con2. So, we need to query the Account of con in order to verify the Account Name.
        assertAccount = [SELECT Id, RecordType.Name, Name
                         FROM Account
                         WHERE Id =: assertAccount.Id];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' Household', assertAccount.Name);
    }

    /*********************************************************************************************************
    * @description
    * Update the custom setting of automatic household naming as true
    * Delete all the contacts linked to a Household Account
    * Make sure the Account's name is set back based on account naming setting.
    */
    @isTest
    public static void deleteAllContactsFromHHAccAutomatic() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = '{!FirstName} {!LastName} Household', Automatic_Household_Naming__c = true));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name
                                 FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' Household', assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.FirstName = 'Test2';
        con2.LastName = con.LastName + '2';
        insert con2;

        assertAccount = [SELECT Id, RecordType.Name, Name
                         FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' and ' + con2.FirstName + ' ' + con2.LastName + ' Household', assertAccount.Name);

        Test.startTest();
        delete con2;
        delete con;
        Test.stopTest();

        assertAccount = [SELECT Id, RecordType.Name, Name
                         FROM Account];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals('Household', assertAccount.Name);
    }

    /*********************************************************************************************************
    * @description
    * Remove primary contact from household account
    * Make sure the primary contact of household account is repopulated
    */
    @isTest
    public static void hhAccountNoChildContactResetPrimaryContact() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getHhAccRecTypeID()));

        Contact con = UTIL_UnitTestData_TEST.getContact();
        insert con;

        Test.startTest();
        con.AccountId = NULL;
        update con;
        Test.stopTest();

        Account assertAccount = [SELECT Id, Primary_Contact__c
                                 FROM Account LIMIT 1];
        List<Contact> relatedContact = [SELECT Id, AccountId
                                        FROM Contact];

        System.assertNotEquals(NULL, assertAccount.Primary_Contact__c);
        System.assertNotEquals(NULL, relatedContact[0].AccountId);
        System.assertEquals(assertAccount.Primary_Contact__c, relatedContact[0].Id);
        System.assertEquals(relatedContact[0].AccountId, assertAccount.Id);
    }

    /*********************************************************************************************************
    * @description
    * Add a contact to a household account
    * Make sure the primary contact of household account is not changed
    */
    @isTest
    public static void hhAccountNewChildContactNotResetPrimaryContact() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getHhAccRecTypeID()));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account acc = [SELECT Id
                       FROM Account LIMIT 1];

        Contact con2 = contacts[1];
        insert con2;

        Test.startTest();
        con2.AccountId = acc.Id;
        update con2;
        Test.stopTest();

        Account assertAccount = [SELECT Primary_Contact__c
                                 FROM Account
                                 WHERE Id = :acc.Id LIMIT 1];
        System.assertEquals(con.Id, assertAccount.Primary_Contact__c);
        System.assertNotEquals(con2.Id, assertAccount.Primary_Contact__c);

    }

    /*********************************************************************************************************
    * @description
    * Switch contacts between two household accounts
    * Make sure primary contacts are updated correctly
    */
    @isTest
    public static void hhAccountSwitchChildContactResetPrimaryContact() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getHhAccRecTypeID()));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account acc = [SELECT Id, Name
                       FROM Account LIMIT 1 ];
        Contact con2 = contacts[1];
        insert con2;

        Account acc2 = [SELECT Id, Name
                        FROM Account
                        WHERE Id != :acc.Id LIMIT 1];

        Test.startTest();
        con2.AccountId = acc.Id;
        update con2;
        con.AccountId = acc2.Id;
        update con;
        Test.stopTest();

        Account assertAccount = [SELECT Primary_Contact__c, Name
                                 FROM Account
                                 WHERE Id = :acc.Id LIMIT 1];
        Account assertAccount2 = [SELECT Primary_Contact__c, Name
                                  FROM Account
                                  WHERE Id = :acc2.Id LIMIT 1];
        System.assertEquals(con2.Id, assertAccount.Primary_Contact__c);
        System.assertEquals(con.Id, assertAccount2.Primary_Contact__c);
    }

    /********************************************************************************************************
     * @description Validate that when inserting a new Account for a Contact, it uses the same OwnerId as the
     * Contact that was inserted (especially if the Contact.OwnerId is set to a value other than the current user).
     */
    private static testMethod void test_insertAsOtherUser() {
        // Create a single new User
        Id sysAdminProfileId = UTIL_Profile.getInstance().getProfileIds(UTIL_Profile.SYSTEM_ADMINISTRATOR)[0];
        User tempUser = new User(LastName = 'TestSysAdminUserA', Email = 'test_insertAsOtherUser@email.npsp',
                                       ProfileId = sysAdminProfileId, isActive = true, UserName = 'test_insertAsOtherUser@email.npsp',
                                     Alias = 'tu08534', TimeZoneSidKey = 'America/Los_Angeles',
                                    LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'ISO-8859-1');
        insert tempUser;

        Id currUserId = UserInfo.getUserId();
        Contact c = UTIL_UnitTestData_TEST.getContact();
        c.OwnerId = currUserId;
        System.runAs(tempUser) {
            insert c;
            c = [SELECT Id, OwnerId, Account.OwnerId
                 FROM Contact
                 WHERE Id = :c.Id LIMIT 1];
            System.assertEquals(c.OwnerId, currUserId, 'The Contact owner should be current system admin user');
            System.assertEquals(c.Account.OwnerId, currUserId, 'The Account owner should be the same as the Contact Owner');
        }
    }

    /*********************************************************************************************************
    * @description Insert a new contact with empty name string to an existing Household Account
    * Make sure the Account's name is set based on account naming setting.
    */
    @isTest
    public static void newContactExistingHHNewConEmptyString() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.acctNamingOther, Household_Other_Name_Setting__c = '{!Salutation} {!FirstName} Family', Automatic_Household_Naming__c = true));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        con.Salutation = 'Mr.';
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name
                                 FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.Salutation + ' ' + con.FirstName + ' Family', assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.Salutation = '';
        con2.FirstName = '';
        Test.startTest();
        insert con2;
        Test.stopTest();


        assertAccount = [SELECT Id, RecordType.Name, Name
                         FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.Salutation + ' ' + con.FirstName + ' Family', assertAccount.Name);

    }

    /*********************************************************************************************************
    * @description Insert a new contact to an existing Household Account with its child contact empty naming string
    * Make sure the Account's name is set based on account naming setting.
    */
    @isTest
    public static void newContactExistingHHExistingConEmptyString() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.acctNamingOther, Household_Other_Name_Setting__c = '{!Salutation} {!FirstName} Family', Automatic_Household_Naming__c = true));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        con.Salutation = '';
        con.FirstName = '';
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name
                                 FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals('Family', assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.Salutation = 'Mr.';
        con2.FirstName = 'Test';
        Test.startTest();
        insert con2;
        Test.stopTest();

        assertAccount = [SELECT Id, RecordType.Name, Name
                         FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con2.Salutation + ' ' + con2.FirstName + ' Family', assertAccount.Name);

    }

    /*********************************************************************************************************
    * @description Test method that tests when a new contact with blank FirstName does not add an empty space and comma.
    */
    @isTest
    public static void newContactWithEmptyFirstName() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                        Household_Account_Naming_Format__c = Label.acctNamingOther,
                                                        Household_Other_Name_Setting__c = '{!{!FirstName}} {!LastName} Household',
                                                        Automatic_Household_Naming__c = true));
        Account acct = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getHhAccRecTypeID())[0];
        insert acct;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(3);
        for (Contact con : contacts) {
            con.AccountId = acct.Id;
        }
        contacts[0].FirstName = 'Will';
        contacts[0].LastName = 'Zap';
        contacts[1].FirstName = '';
        contacts[1].LastName = 'Zap';
        contacts[2].FirstName = 'Abigail';
        contacts[2].LastName = 'Zap';
        insert contacts;

        List<Contact> returnedContacts = [SELECT Id, AccountId, Account.Name
                                         FROM Contact
                                         WHERE Id = :contacts LIMIT 3];
        System.assertEquals(contacts[2].FirstName + ' and ' + contacts[0].FirstName + ' ' +
                            contacts[0].LastName + ' ' + 'Household',
                            returnedContacts[0].Account.Name);


    }

    /*********************************************************************************************************
    * @description Test Method for detaching a Contact from an already existing account
    * which is not the default account model.
    */
    @isTest
    public static void detachFromBizAccountToAdministrative() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID()));

        Account acct = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acct;

        Contact con = UTIL_UnitTestData_API.getContact();
        con.AccountId = acct.id;
        insert con;

        List<Contact> insertedContacts = [SELECT Account.Name, AccountId
                                          FROM Contact
                                          WHERE Id = :con.Id];
        //the contact should be connected to the account
        System.assertEquals(acct.id, insertedContacts[0].AccountId);

        con.AccountId = NULL;
        Test.startTest();
        update con;
        Test.stopTest();

        List<Contact> updatedContacts = [SELECT Account.Name, AccountId, Account.RecordTypeId
                                         FROM Contact
                                         WHERE Id =:con.Id];

        //The account should not be the one we started with
        System.assertNotEquals(NULL, updatedContacts[0].AccountId);
        System.assertNotEquals(acct.id, updatedContacts[0].AccountId);
        System.assertEquals(UTIL_Describe_API.getAdminAccRecTypeID(), updatedContacts[0].Account.RecordTypeId);
    }

    /*********************************************************************************************************
    * @description Test Method for when a Contact's owner change the Account's Owner
    * should match the Contact's new owner.
    */
    @isTest
    private static void contactOwnerChange() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                      (Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID()));

        Id sysAdminProfileId = UTIL_Profile.getInstance().getProfileIds(UTIL_Profile.SYSTEM_ADMINISTRATOR)[0];
        User adminUser = new User(LastName = 'TestAdmin', Email = 'testAdminUser@emailtest.edatest',
                                ProfileId = sysAdminProfileId, isActive = true,
                                UserName = 'testAdminUser@emailtest.edatest', Alias = 'tAdmin0',
                                TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US', EmailEncodingKey = 'ISO-8859-1');
        insert adminUser;

        Contact con = UTIL_UnitTestData_API.getContact();
        insert con;

        con.OwnerId = adminUser.Id;
        Test.startTest();
        update con;
        Test.stopTest();

        Contact updatedContact = [SELECT Id, Account.OwnerId
                                  FROM Contact
                                  WHERE Id = :con.Id];
        System.assertEquals(adminUser.Id, updatedContact.Account.OwnerId);
    }

    /*********************************************************************************************************
    * @description Test Method to test the queryContact() method in ACCT_IndividualAccounts_TDTM
    */
    @isTest
    public static void testQueryContacts() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                       (Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID()));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Test.startTest();
         List<Contact> contactReturned  = ACCT_IndividualAccounts_TDTM.queryContacts(contacts);

        Test.stopTest();

        System.assertEquals(2, contactReturned.size());
        for (Contact c : contactReturned) {
            System.assertNotEquals(NULL, c.AccountId);
            System.assertNotEquals(NULL, c.Account.Name);
        }
    }

    /*********************************************************************************************************
    * @description Test Method to test the handlesAfterInsertUpdate() method in ACCT_IndividualAccounts_TDTM
    */
    @isTest
    public static void testHandleAfterInsertUpdate() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                       (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID()));

        Contact con = UTIL_UnitTestData_TEST.getContact();

        Test.startTest();
        insert con;
        Test.stopTest();

          Contact contactReturned = [SELECT Id, AccountId, Account.RecordTypeId,
                                 Account.Primary_Contact__c,FirstName, LastName
                                 FROM Contact
                                 WHERE Id = :con.Id];

        System.assertEquals(UTIL_Describe_API.getHhAccRecTypeID(), contactReturned.Account.RecordTypeId);
        System.assertEquals(con.Id, contactReturned.Account.Primary_Contact__c);
    }

    /*********************************************************************************************************
    * @description Test Method to test the HandleInsertWrapperLogic() method in ACCT_IndividualAccounts_TDTM
    */
    @isTest
    public static void testHandleInsertWrapperLogic() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                      (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                        Household_Account_Naming_Format__c = '{!FirstName} {!LastName} Household',
                                                        Automatic_Household_Naming__c = true));

        Account acct = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getHhAccRecTypeID())[0];
        insert acct;

        Contact con = UTIL_UnitTestData_API.getContact();
        con.AccountId = acct.id;
        insert con;

        Contact returnedContact = [SELECT Id, FirstName, LastName,
                                  AccountId, Account.Name,
                                  Account.Primary_Contact__c, Account.RecordTypeId
                                  FROM Contact
                                  WHERE Id = :con.Id];

        System.assertNotEquals(NULL, returnedContact.Account.Primary_Contact__c);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' ' + 'Household', returnedContact.Account.Name);
    }

    /*********************************************************************************************************
    * @description Test Method to test the HandleUpdateWrapperLogic() method in ACCT_IndividualAccounts_TDTM
    */
    @isTest
    public static void testHandleUpdateWrapperLogic() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                      (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                        Household_Account_Naming_Format__c = '{!FirstName} {!LastName} Household',
                                                        Automatic_Household_Naming__c = true));
        Contact con = UTIL_UnitTestData_API.getContact();
        insert con;

        Id sysAdminProfileId = UTIL_Profile.getInstance().getProfileIds(UTIL_Profile.SYSTEM_ADMINISTRATOR)[0];
        User adminUser = new User(LastName = 'TestAdmin', Email = 'testAdminUser@emailtest.edatest',
                                    ProfileId = sysAdminProfileId, isActive = true, UserName = 'testAdminUser@emailtest.edatest',
                                     Alias = 'tAdmin0', TimeZoneSidKey = 'America/Los_Angeles',
                                    LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'ISO-8859-1');
        insert adminUser;

        con.FirstName = 'Samantha';
        con.LastName = 'Smith';
        con.OwnerId = adminUser.Id;

        Test.startTest();
        update con;
        Test.stopTest();

           Contact returnedContact = [SELECT Id, FirstName, LastName,
                                  OwnerId, AccountId, Account.OwnerId,
                                  Account.Name
                                  FROM Contact
                                  WHERE Id = :con.Id];

        System.assertEquals(con.OwnerId, returnedContact.Account.OwnerId);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' ' + 'Household', returnedContact.Account.Name);
    }

    /*********************************************************************************************************
    * @description Test Method to test the handlesAfterDelete() && handleDeleteProcessing() method in ACCT_IndividualAccounts_TDTM
    */
    @isTest
    public static void testHandlesAfterDelete() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                      (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                        Household_Account_Naming_Format__c = '{!FirstName} {!LastName} Household',
                                                        Automatic_Household_Naming__c = true));
        Contact con = UTIL_UnitTestData_API.getContact();
        insert con;

        Contact returnedContact = [SELECT Id, AccountId
                                   FROM Contact
                                   WHERE Id = :con.Id];
        Account returnedAccount = [SELECT Id, Name, Primary_Contact__c
                                  FROM Account
                                  WHERE Id = :returnedContact.AccountId];
        Test.startTest();
        delete con;
        Test.stopTest();

        List<Contact> returnedContactDelete = [SELECT Id, IsDeleted
                                               FROM Contact
                                               WHERE Id = :con.Id];
        System.assertEquals(0, returnedContactDelete.size());
    }

    /*********************************************************************************************************
    * @description Test Method to test sorting Contacts alphabetically by LastName FirstName
    * with {!{!FirstName}} {!LastName} Household format.
    */
    @isTest
    private static void sortContactsFirstLastNames() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                    (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                     Household_Account_Naming_Format__c = '{!{!FirstName}} {!LastName} Household',
                                                     Automatic_Household_Naming__c = true));

        Account acct = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getHhAccRecTypeID())[0];
        insert acct;

        List<Contact> contacts = UTIL_UnitTestData_API.getMultipleTestContacts(9);
        for (Contact c : contacts) {
            c.AccountId = acct.Id;
        }

        contacts[0].FirstName = 'Will';
        contacts[0].LastName = 'Zap';
        contacts[1].FirstName = 'William';
        contacts[1].LastName = 'Zap';
        contacts[2].FirstName = 'Abigail';
        contacts[2].LastName = 'Zap';
        contacts[3].FirstName = 'Tammy';
        contacts[3].LastName = 'Brett';
        contacts[4].FirstName = 'Betty';
        contacts[4].LastName = 'Brett';
        contacts[5].FirstName = 'Charles';
        contacts[5].LastName = 'Brett';
        contacts[6].FirstName = 'Cat';
        contacts[6].LastName = 'Pierre';
        contacts[7].FirstName = 'Lyla';
        contacts[7].LastName = 'Pierre';
        contacts[8].FirstName = 'Annie';
        contacts[8].LastName = 'Pierre';

        Test.startTest();
        insert contacts;
        Test.stopTest();

        List<Contact> returnSortedContacts = [SELECT Id, FirstName, LastName, Account.Name
                                            FROM Contact
                                            WHERE Id = :contacts];
        System.assertEquals(contacts[4].FirstName + ', ' + contacts[5].FirstName + ' and ' + contacts[3].FirstName +
                            ' ' + contacts[3].LastName + ', ' + contacts[8].FirstName + ', '
                            + contacts[6].FirstName + ' and ' + contacts[7].FirstName + ' ' + contacts[7].LastName +
                            ' and ' + contacts[2].FirstName + ', ' + contacts[0].FirstName + ' and ' +
                            contacts[1].FirstName + ' ' + contacts[1].LastName + ' ' + 'Household',
                            returnSortedContacts[0].Account.Name);

    }

    /*********************************************************************************************************
    * @description Test Method to test sorting Contacts alphabetically by LastName FirstName
    * with {!LastName} ({!{!FirstName}}) Household format.
    */
    @isTest
    private static void sortContactsLastFirstNames() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                    (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                     Household_Account_Naming_Format__c = '{!LastName} ({!{!FirstName}}) Household',
                                                     Automatic_Household_Naming__c = true));

        Account acct = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getHhAccRecTypeID())[0];
        insert acct;

        List<Contact> contacts = UTIL_UnitTestData_API.getMultipleTestContacts(9);
        for (Contact c : contacts) {
            c.AccountId = acct.Id;
        }

        contacts[0].FirstName = 'Will';
        contacts[0].LastName = 'Zap';
        contacts[1].FirstName = 'William';
        contacts[1].LastName = 'Zap';
        contacts[2].FirstName = 'Abigail';
        contacts[2].LastName = 'Zap';
        contacts[3].FirstName = 'Tammy';
        contacts[3].LastName = 'Brett';
        contacts[4].FirstName = 'Betty';
        contacts[4].LastName = 'Brett';
        contacts[5].FirstName = 'Charles';
        contacts[5].LastName = 'Brett';
        contacts[6].FirstName = 'Cat';
        contacts[6].LastName = 'Pierre';
        contacts[7].FirstName = 'Lyla';
        contacts[7].LastName = 'Pierre';
        contacts[8].FirstName = 'Annie';
        contacts[8].LastName = 'Pierre';

        Test.startTest();
        insert contacts;
        Test.stopTest();

        List<Contact> returnSortedContacts = [SELECT Id, FirstName, LastName, Account.Name
                                             FROM Contact
                                             WHERE Id = :contacts];
        System.assertEquals(contacts[3].LastName + ' ('+ contacts[4].FirstName + ', ' + contacts[5].FirstName +
                            ' and ' + contacts[3].FirstName + ')'+ ', ' + contacts[8].LastName +
                            ' (' + contacts[8].FirstName + ', ' + contacts[6].FirstName + ' and ' +
                            contacts[7].FirstName + ')'+ ' and ' + contacts[2].LastName + ' (' +
                            contacts[2].FirstName + ', ' + contacts[0].FirstName + ' and ' + contacts[1].FirstName +
                            ')' + ' ' + 'Household',
                            returnSortedContacts[0].Account.Name);

    }

    /*********************************************************************************************************
    * @description Test Method to test sorting Contacts alphabetically by LastName FirstName
    * with {!LastName} Household format.
    */
    @isTest
    private static void sortContactsLastNameOnly() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                    (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                     Household_Account_Naming_Format__c = '{!LastName} Household',
                                                    Automatic_Household_Naming__c = true));

        Account acct = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getHhAccRecTypeID())[0];
        insert acct;

        List<Contact> contacts = UTIL_UnitTestData_API.getMultipleTestContacts(3);
        for (Contact c : contacts) {
            c.AccountId = acct.Id;
        }

        contacts[0].FirstName = 'Will';
        contacts[0].LastName = 'Zap';
        contacts[1].FirstName = 'Betty';
        contacts[1].LastName = 'Brett';
        contacts[2].FirstName = 'Abigail';
        contacts[2].LastName = 'Pierre';


        Test.startTest();
        insert contacts;
        Test.stopTest();

        List<Contact> returnSortedContacts = [SELECT Id, FirstName, LastName, Account.Name
                                             FROM Contact
                                             WHERE Id = :contacts];
        System.assertEquals(contacts[1].LastName + ', ' + contacts[2].LastName + ' and ' +
                            contacts[0].LastName + ' ' + 'Household',
                            returnSortedContacts[0].Account.Name);

    }

    /*********************************************************************************************************
    * @description Test Method to test sorting Contacts alphabetically by LastName FirstName
    * with {!{!FirstName}} {!LastName} Household format and blank FirstNames.
    */
    @isTest
    private static void sortContactsWithoutFirstNames() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                    (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                     Household_Account_Naming_Format__c = '{!{!FirstName}} {!LastName} Household',
                                                    Automatic_Household_Naming__c = true));

        Account acct = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getHhAccRecTypeID())[0];
        insert acct;

        List<Contact> contacts = UTIL_UnitTestData_API.getMultipleTestContacts(3);
        for (Contact c : contacts) {
            c.AccountId = acct.Id;
        }

        contacts[0].FirstName = '';
        contacts[0].LastName = 'Zap';
        contacts[1].FirstName = '';
        contacts[1].LastName = 'Brett';
        contacts[2].FirstName = '';
        contacts[2].LastName = 'Pierre';


        Test.startTest();
        insert contacts;
        Test.stopTest();

        List<Contact> returnSortedContacts = [SELECT Id, FirstName, LastName, Account.Name
                                             FROM Contact
                                             WHERE Id = :contacts];
        System.assertEquals(contacts[1].LastName + ', ' + contacts[2].LastName + ' and ' +
                            contacts[0].LastName + ' ' + 'Household',
                            returnSortedContacts[0].Account.Name);

    }
}