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
    private static void insertContactTriggerOff() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID())
        );

        // turn off all TDTM triggers for this component
        TDTM_ProcessControl.turnOffRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Insert
        );
        TDTM_ProcessControl.turnOffRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Update
        );
        TDTM_ProcessControl.turnOffRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Delete
        );

        Contact con = UTIL_UnitTestData_API.getContact();

        Test.startTest();
        insert con;
        Test.stopTest();

        Contact[] insertedContacts = [SELECT FirstName, LastName, AccountId FROM Contact WHERE Id = :con.Id];

        //contact should have no AccountId
        System.assertEquals(null, insertedContacts[0].AccountId);
    }

    /*********************************************************************************************************
     * @description Test Method for a new Contact
     */
    @isTest
    private static void newContact() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID())
        );

        Contact con = UTIL_UnitTestData_API.getContact();

        Test.startTest();
        insert con;
        Test.stopTest();

        Contact insertedContact = [SELECT Account.Name, AccountId FROM Contact WHERE Id = :con.Id];

        //the contact should have the right type
        System.assertEquals(con.LastName + ' ' + Label.DefaultAdminName, insertedcontact.Account.Name);
    }

    /*********************************************************************************************************
     * @description Test Method for inserting and updating a Contact
     */
    @isTest
    private static void insertUpdateContact() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID())
        );

        String newContactMailingStreet = '123 Elm St';

        Contact con = UTIL_UnitTestData_API.getContact();
        insert con;

        Contact[] insertedContacts = [
            SELECT
                FirstName,
                LastName,
                AccountId,
                Account.Name,
                Account.Primary_Contact__c,
                MailingStreet,
                Account.BillingStreet
            FROM Contact
            WHERE Id = :con.Id
        ];

        //one contact should have been created
        System.assertEquals(1, insertedContacts.size());

        //relationship should be bi-directional
        System.assertEquals(insertedcontacts[0].id, insertedcontacts[0].Account.Primary_Contact__c);

        String updatedContactLastName = 'Contact_forTestsChange';
        String updatedOtherCity = 'Seattle';
        con.LastName = updatedContactLastName;
        con.OtherCity = updatedOtherCity;
        con.AccountId = insertedContacts[0].AccountId;
        update con;

        Contact[] updatedContacts = [
            SELECT FirstName, LastName, AccountId, Account.Name, Account.Primary_Contact__c
            FROM Contact
            WHERE Id = :con.Id
        ];

        //relationship should be bi-directional
        System.assertEquals(updatedContacts[0].id, updatedContacts[0].Account.Primary_Contact__c);
    }

    /*********************************************************************************************************
     * @description Add a contact to an existing Account
     */
    @isTest
    private static void contactAddedToExistingAcc() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID())
        );

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business Organization',
                Primary_Affl_Field__c = 'Primary Business Organization'
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'Household Account',
                Primary_Affl_Field__c = 'Primary ' + Label.DefaultHouseholdName
            )
        );
        insert mappings;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        con = [SELECT AccountId FROM Contact WHERE id = :con.id];
        Id accountId = con.AccountId;

        Contact con2 = contacts[1];
        con2.AccountId = accountId;

        Test.startTest();
        TDTM_ProcessControl.setRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_Before_Insert,
            false
        );
        insert con2;
        Test.stopTest();

        con2 = [SELECT AccountId, Primary_Household__c FROM Contact WHERE Id = :con2.Id];
        System.assertEquals(accountId, con2.AccountId);
    }

    /*********************************************************************************************************
     * @description Update a contact to an existing Account
     */
    @isTest
    private static void contactUpdatedToExistingAcc() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID())
        );

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Contact[] insertedContacts = [SELECT Account.Name, AccountId FROM Contact WHERE Id = :con.Id];
        Id accountId = insertedContacts[0].AccountId;

        Contact con2 = contacts[1];
        con2.AccountId = null;
        insert con2;

        // now update the contact to the existing account from contact 1
        con2.AccountId = accountId;
        update con2;

        Contact[] insertedContact = [SELECT Account.Name, AccountId FROM Contact WHERE Id = :con2.Id];

        System.assertEquals(accountId, insertedContact[0].AccountId);
    }

    /*********************************************************************************************************
     * @description Update a contact's Lastname in the Account
     * Based on latest requirement, if there is a change on contact's last name,
     * admin account's lastname should be changed accordingly.
     */
    @isTest
    private static void contactInNormalOrgNameChangem() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID())
        );

        String acctName = 'Test Account 876';
        List<Account> accts = UTIL_UnitTestData_API.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getAdminAccRecTypeID()
        );
        accts[0].Name = acctName;
        insert accts[0];

        Contact con = UTIL_UnitTestData_API.getContact();
        con.AccountId = accts[0].id;
        insert con;

        Contact[] insertedContacts = [SELECT Account.Name, AccountId FROM Contact WHERE Id = :con.Id];

        //the contact should be connected to the account
        System.assertEquals(accts[0].id, insertedContacts[0].AccountId);
        System.assertEquals(acctName, insertedContacts[0].Account.Name);

        con.LastName = 'Smith';
        update con;

        Contact[] updatedContacts = [SELECT Account.Name, AccountId FROM Contact WHERE Id = :con.Id];
        System.assertEquals(con.LastName + ' ' + Label.DefaultAdminName, updatedContacts[0].Account.Name);
    }

    /*********************************************************************************************************
     * @description Test Method for detaching a Contact from an already existing account
     * which is the default account model.
     */
    @isTest
    private static void detachFromDefaultAccount() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID())
        );

        Account acct = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getAdminAccRecTypeID())[0];
        insert acct;

        Contact con = UTIL_UnitTestData_API.getContact();
        con.AccountId = acct.id;
        insert con;

        List<Contact> insertedContacts = [SELECT Account.Name, AccountId FROM Contact WHERE Id = :con.Id];
        //the contact should be connected to the account
        System.assertEquals(acct.Id, insertedContacts[0].AccountId);

        con.AccountId = null;
        Test.startTest();
        update con;
        Test.stopTest();

        List<Contact> updatedContacts = [SELECT Account.Name, AccountId, Id FROM Contact WHERE Id = :con.Id];
        List<Account> relatedAccount = [SELECT Primary_Contact__c FROM Account];

        //the account should not be the one we started with
        System.assertEquals(acct.id, updatedContacts[0].AccountId);
        System.assertNotEquals(null, relatedAccount[0].Primary_Contact__c);
        System.assertEquals(updatedContacts[0].id, relatedAccount[0].Primary_Contact__c);
    }

    /*********************************************************************************************************
     * @description Delete a Contact and verify its parent Account is deleted.
     */
    @isTest
    private static void deleteContactNoOpps() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                Accounts_to_Delete__c = UTIL_Describe_API.getAdminAccRecTypeID()
            )
        );

        String newContactMailingStreet = '123 Elm St';

        Contact con = UTIL_UnitTestData_API.getContact();
        insert con;
        Id contactId;
        contactId = con.Id;

        Contact[] insertedContacts = [SELECT FirstName, LastName, AccountId FROM Contact WHERE Id = :contactId];
        Id createdAccountId = insertedContacts[0].AccountId;

        Test.startTest();
        delete con;
        Test.stopTest();

        insertedContacts = [SELECT FirstName, LastName, AccountId FROM Contact WHERE Id = :contactId];
        System.assertEquals(0, insertedContacts.size());

        Account[] missingAccount = [SELECT Id FROM Account WHERE Id = :createdAccountId];
        System.assertEquals(0, missingAccount.size());
    }

    /*********************************************************************************************************
     * @description Delete a Contact with Opps and verify its parent Account is not deleted.
     */
    @isTest
    private static void deleteContactWithOppAdm() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                Accounts_to_Delete__c = UTIL_Describe_API.getAdminAccRecTypeID()
            )
        );

        String newContactMailingStreet = '123 Elm St';

        Contact con = UTIL_UnitTestData_API.getContact();
        insert con;
        Id contactId;
        contactId = con.id;
        Id accountId;
        Contact[] insertedContacts = [SELECT FirstName, LastName, AccountId FROM Contact WHERE Id = :contactId];

        Id createdAccountId = insertedContacts[0].AccountId;

        Opportunity opp = new Opportunity(
            Amount = 500,
            AccountId = createdAccountId,
            Name = 'test',
            StageName = 'Closed/Won',
            CloseDate = System.today()
        );
        insert opp;

        Test.startTest();
        delete con;
        Test.stopTest();

        Account[] missingAccount = [SELECT Id FROM Account WHERE Id = :createdAccountId];
        System.assertEquals(1, missingAccount.size());
    }

    /*********************************************************************************************************
     * @description Specify only admin accounts with all child contacts deleted will be automatically deleted,
     * and delete a Contact from an Account without type. Make sure the Account is not deleted.
     */
    @isTest
    private static void deleteContactNormalAccount() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                Accounts_to_Delete__c = UTIL_Describe_API.getAdminAccRecTypeID()
            )
        );

        List<Account> orgAccounts = UTIL_UnitTestData_API.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        insert orgAccounts[0];

        String newContactMailingStreet = '123 Elm St';

        Contact con = UTIL_UnitTestData_API.getContact();
        con.MailingStreet = newContactMailingStreet;
        con.AccountId = orgAccounts[0].id;
        insert con;

        Contact[] insertedContacts = [SELECT FirstName, LastName, AccountId FROM Contact WHERE Id = :con.Id];
        Id createdAccountId = insertedContacts[0].AccountId;

        Test.startTest();
        delete con;
        Test.stopTest();

        Account[] missingAccount = [SELECT Id FROM Account WHERE Id = :createdAccountId];
        System.assertEquals(1, missingAccount.size());
    }

    /*********************************************************************************************************
     * @description Rename a Contact's firstname to null and make sure the Admin Account's name doesn't change.
     */
    @isTest
    private static void firstNameToNullAdm() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID())
        );

        Contact con = UTIL_UnitTestData_API.getContact();
        insert con;

        con = [SELECT AccountId, LastName FROM Contact WHERE Id = :con.Id];
        Account newAcc = [SELECT Id, Name FROM Account WHERE Id = :con.AccountId LIMIT 1];
        System.assertEquals(newAcc.Name, con.LastName + ' ' + Label.DefaultAdminName);

        //set name to null
        con.FirstName = null;

        Test.startTest();
        update con;
        Test.stopTest();

        newAcc = [SELECT Id, Name FROM Account WHERE Id = :con.AccountId LIMIT 1];
        System.assertEquals(newAcc.Name, con.LastName + ' ' + Label.DefaultAdminName);
    }

    /*********************************************************************************************************
     * @description Insert a new contact and the default account record type is Household
     * Make sure the Account's name is set based on account naming setting.
     */
    @isTest
    private static void newContactNewHHAcc() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.firstNameLastNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        Contact con = UTIL_UnitTestData_API.getContact();
        Test.startTest();
        insert con;
        Test.stopTest();

        Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' ' + Label.DefaultHouseholdName, assertAccount.Name);
    }

    /*********************************************************************************************************
     * @description Insert a new contact and the default account record type is Household
     * Make sure the Account's name is set based on account naming setting for a user in Spanish.
     * Test Scenario: T-3904056
     */
    @isTest
    private static void newContactNewHHAccSpanish() {
        Profile systemAdministratorProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        System.runAs(UTIL_UnitTestData_TEST.createNewUserForTests(
            System.now().getTime() + '@testerson.com',
            systemAdministratorProfile.Id,
            'es'
        )) {
            Hierarchy_Settings__c edaSettings = new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.acctNamingOther,
                Automatic_Household_Naming__c = true,
                Household_Other_Name_Setting__c = Label.lastNameHH
            );

            UTIL_CustomSettingsFacade.getSettingsForTests(edaSettings);

            Contact con = UTIL_UnitTestData_API.getContact();
            con.Email = 's@salesfor.com';
            con.Preferred_Email__c = 'Correo electrónico laboral';

            Test.startTest();
            insert con;
            Test.stopTest();

            Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];
            System.assertEquals('Household Account', assertAccount.RecordType.Name);
            System.assertEquals('Domicilio de ' + con.LastName, assertAccount.Name);
        }
    }

    /*********************************************************************************************************
     * @description Insert a new contact and the default account record type is Household
     * Make sure the Account's name is set based on account naming setting and binded variables.
     * Test Scenario: T-3904070
     */
    @isTest
    private static void ensureHHNamingBindFields() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = '{!LastName} ({!MailingCity}) Family',
                Automatic_Household_Naming__c = true
            )
        );

        Contact con = UTIL_UnitTestData_API.getContact();
        con.LastName = 'Smith';
        con.MailingCity = 'Seattle';

        Test.startTest();
        insert con;
        Test.stopTest();

        Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.LastName + ' (' + con.MailingCity + ') Family', assertAccount.Name);
    }

    /*********************************************************************************************************
     * @description Ensure household account naming persists when the the default account model is changed.
     * Test Scenario: T-3904058
     */
    @isTest
    private static void shouldPersistHHNamingWhenAcctModelChanged() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Addresses_RecType__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.firstNameLastNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        Contact primaryContact = UTIL_UnitTestData_TEST.getUniqueContact(0);
        Test.startTest();
        insert primaryContact;
        Test.stopTest();

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                Admin_Account_Naming_Format__c = Label.lastNameAdminAcc,
                Administrative_Account_Record_Type__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                Automatic_Household_Naming__c = true
            )
        );
        ACCT_IndividualAccounts_TDTM.defaultRecTypeId = UTIL_Describe_API.getAdminAccRecTypeID();

        Contact secondaryContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        insert secondaryContact;

        List<Account> assertAccounts = [SELECT Id, RecordType.Name, Name FROM Account ORDER BY CreatedDate];
        System.assertEquals('Household Account', assertAccounts[0].RecordType.Name);
        System.assertEquals(
            primaryContact.FirstName +
            ' ' +
            primaryContact.LastName +
            ' ' +
            Label.DefaultHouseholdName,
            assertAccounts[0].Name
        );

        System.assertEquals('Administrative', assertAccounts[1].RecordType.Name);
        System.assertEquals(secondaryContact.LastName + ' Administrative Account', assertAccounts[1].Name);

        Contact tertiaryContact = UTIL_UnitTestData_TEST.getUniqueContact(2);
        tertiaryContact.AccountId = assertAccounts[0].Id;
        primaryContact.Deceased__c = true;
        upsert new List<Contact>{ primaryContact, tertiaryContact };

        assertAccounts = [SELECT Id, RecordType.Name, Name FROM Account ORDER BY CreatedDate];
        System.assertEquals(
            tertiaryContact.FirstName +
            ' ' +
            tertiaryContact.LastName +
            ' ' +
            Label.DefaultHouseholdName,
            assertAccounts[0].Name
        );
    }

    /*********************************************************************************************************
     * @description Ensure household account naming consists of last deceased contact.
     * Test Scenario: T-3904066
     */
    @isTest
    private static void hhNamingContainsLastDeceasedContact() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Addresses_RecType__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.firstNameLastNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        Contact primaryContact = UTIL_UnitTestData_TEST.getUniqueContact(0);

        Test.startTest();
        insert primaryContact;
        Test.stopTest();

        Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account ORDER BY CreatedDate LIMIT 1];

        Contact secondaryContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        secondaryContact.AccountId = assertAccount.Id;
        insert secondaryContact;

        assertAccount = [SELECT Id, RecordType.Name, Name FROM Account ORDER BY CreatedDate LIMIT 1];
        System.assertEquals(
            primaryContact.FirstName +
            ' ' +
            primaryContact.LastName +
            ' ' +
            Label.defaultNamingConnector +
            ' ' +
            secondaryContact.FirstName +
            ' ' +
            secondaryContact.LastName +
            ' ' +
            Label.DefaultHouseholdName,
            assertAccount.Name
        );

        primaryContact.Deceased__c = true;
        update primaryContact;

        assertAccount = [SELECT Id, RecordType.Name, Name FROM Account ORDER BY CreatedDate LIMIT 1];
        System.assertEquals(
            secondaryContact.FirstName +
            ' ' +
            secondaryContact.LastName +
            ' ' +
            Label.DefaultHouseholdName,
            assertAccount.Name
        );

        secondaryContact.Deceased__c = true;
        update secondaryContact;

        assertAccount = [SELECT Id, RecordType.Name, Name FROM Account ORDER BY CreatedDate LIMIT 1];
        System.assertEquals(
            secondaryContact.FirstName +
            ' ' +
            secondaryContact.LastName +
            ' ' +
            Label.DefaultHouseholdName,
            assertAccount.Name
        );
    }

    /*********************************************************************************************************
     * @description Insert a new contact and link it to an existing Household Account
     * Make sure the Account's name is set based on account naming setting.
     */
    @isTest
    private static void newContactExistingHHAcc() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.firstNameLastNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        String andConnector = Label.defaultNamingConnector;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' ' + Label.DefaultHouseholdName, assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.LastName = con.LastName + '2';
        con2.FirstName = 'Test2';
        Test.startTest();
        insert con2;
        Test.stopTest();

        assertAccount = [SELECT Id, RecordType.Name, Name FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(
            con.FirstName +
            ' ' +
            con.LastName +
            ' ' +
            andConnector +
            ' ' +
            con2.FirstName +
            ' ' +
            con2.LastName +
            ' ' +
            Label.DefaultHouseholdName,
            assertAccount.Name
        );
    }

    /*********************************************************************************************************
     * @description Insert a new contact with the same lastname and link it to an existing Household Account
     * Make sure the Account's name is set based on account naming setting.
     * This naming setting has parenthesis around firstname
     */
    @isTest
    private static void newContactExistingHHAccSameLastNameWithParenthesis() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.lastNameFirstNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        String andConnector = Label.defaultNamingConnector;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(
            con.LastName +
            ' (' +
            con.FirstName +
            ') ' +
            Label.DefaultHouseholdName,
            assertAccount.Name
        );

        Contact con2 = contacts[1];
        con2.FirstName = 'Test2';
        con2.LastName = con.LastName;
        con2.AccountId = assertAccount.id;
        Test.startTest();
        insert con2;
        Test.stopTest();

        assertAccount = [SELECT Id, RecordType.Name, Name FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(
            con.LastName +
            ' (' +
            con.FirstName +
            ' ' +
            andConnector +
            ' ' +
            con2.FirstName +
            ') ' +
            Label.DefaultHouseholdName,
            assertAccount.Name
        );
    }

    /*********************************************************************************************************
     * @description Insert a new contact with the same lastname and link it to an existing Household Account
     * Make sure the Account's name is set based on account naming setting.
     */
    @isTest
    private static void newContactExistingHHAccSameLastName() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.firstNameLastNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        String andConnector = Label.defaultNamingConnector;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' ' + Label.DefaultHouseholdName, assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.LastName = con.LastName;
        con2.FirstName = 'Test2';
        Test.startTest();
        insert con2;
        Test.stopTest();

        assertAccount = [SELECT Id, RecordType.Name, Name FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(
            con.FirstName +
            ' ' +
            andConnector +
            ' ' +
            con2.FirstName +
            ' ' +
            con2.LastName +
            ' ' +
            Label.DefaultHouseholdName,
            assertAccount.Name
        );
    }

    /*********************************************************************************************************
     * @description Update the name of a contact linked to a Household Account
     * Make sure the Account's name is set based on account naming setting.
     */
    @isTest
    private static void updateContactExistingHHAcc() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.firstNameLastNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        String andConnector = Label.defaultNamingConnector;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' ' + Label.DefaultHouseholdName, assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.FirstName = 'Test2';
        con2.LastName = con.LastName + '2';
        insert con2;

        assertAccount = [SELECT Id, RecordType.Name, Name FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(
            con.FirstName +
            ' ' +
            con.LastName +
            ' ' +
            andConnector +
            ' ' +
            con2.FirstName +
            ' ' +
            con2.LastName +
            ' ' +
            Label.DefaultHouseholdName,
            assertAccount.Name
        );

        con2.FirstName = 'Test3';
        con2.LastName = 'Contact_forTests3';
        Test.startTest();
        update con2;
        Test.stopTest();

        assertAccount = [SELECT Id, RecordType.Name, Name FROM Account];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(
            con.FirstName +
            ' ' +
            con.LastName +
            ' ' +
            andConnector +
            ' ' +
            con2.FirstName +
            ' ' +
            con2.LastName +
            ' ' +
            Label.DefaultHouseholdName,
            assertAccount.Name
        );
    }

    /*********************************************************************************************************
     * @description
     * Update the custom setting of automatic household naming as false
     * Create a new contact and link it to an existing Household Account
     * Make sure the Account's name is not set based on account naming setting.
     */
    @isTest
    private static void newContactExistingHHAccNotAutomatic() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.firstNameLastNameHH,
                Automatic_Household_Naming__c = false
            )
        );

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' ' + Label.DefaultHouseholdName, assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.FirstName = 'Test2';
        con2.LastName = con.LastName + '2';
        insert con2;

        assertAccount = [SELECT Id, RecordType.Name, Name FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' ' + Label.DefaultHouseholdName, assertAccount.Name);
    }

    /*********************************************************************************************************
     * @description
     * Create a new contact and link it to an existing Household Account
     * Set the new contact as excluded from household naming
     * Make sure the Account's name is not set based on account naming setting.
     */
    @isTest
    private static void newContactExistingHHAccExcludedFromNaming() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.firstNameLastNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        String andConnector = Label.defaultNamingConnector;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' ' + Label.DefaultHouseholdName, assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.FirstName = 'Test2';
        con2.LastName = con.LastName + '2';
        con2.Exclude_From_Household_Name__c = true;
        insert con2;

        assertAccount = [SELECT Id, RecordType.Name, Name FROM Account];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' ' + Label.DefaultHouseholdName, assertAccount.Name);

        con2.Exclude_From_Household_Name__c = false;
        update con2;
        assertAccount = [SELECT Id, RecordType.Name, Name FROM Account];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(
            con.FirstName +
            ' ' +
            con.LastName +
            ' ' +
            andConnector +
            ' ' +
            con2.FirstName +
            ' ' +
            con2.LastName +
            ' ' +
            Label.DefaultHouseholdName,
            assertAccount.Name
        );
    }

    /*********************************************************************************************************
     * @description
     * Update the custom setting of automatic household naming as false
     * Update the name of a contact linked to a Household Account
     * Make sure the Account's name is not set based on account naming setting.
     */
    @isTest
    private static void updateContactExistingHHAccNotAutomatic() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.firstNameLastNameHH,
                Automatic_Household_Naming__c = false
            )
        );

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' ' + Label.DefaultHouseholdName, assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.FirstName = 'Test2';
        con2.LastName = con.LastName + '2';
        insert con2;

        assertAccount = [SELECT Id, RecordType.Name, Name FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' ' + Label.DefaultHouseholdName, assertAccount.Name);

        con2.FirstName = 'Test3';
        con2.LastName = 'Contact_forTests3';
        Test.startTest();
        update con2;
        Test.stopTest();

        assertAccount = [SELECT Id, RecordType.Name, Name FROM Account];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' ' + Label.DefaultHouseholdName, assertAccount.Name);
    }

    /*********************************************************************************************************
     * @description
     * Update the custom setting of automatic household naming as true
     * Delete the contact linked to a Household Account
     * Make sure the Account's name is set back based on account naming setting.
     * Test Scenario: T-3904068
     */
    @isTest
    private static void deleteContactFromHHAccAutomatic() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.firstNameLastNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        String andConnector = Label.defaultNamingConnector;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' ' + Label.DefaultHouseholdName, assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.FirstName = 'Test2';
        con2.LastName = con.LastName + '2';
        insert con2;

        assertAccount = [SELECT Id, RecordType.Name, Name FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(
            con.FirstName +
            ' ' +
            con.LastName +
            ' ' +
            andConnector +
            ' ' +
            con2.FirstName +
            ' ' +
            con2.LastName +
            ' ' +
            Label.DefaultHouseholdName,
            assertAccount.Name
        );

        Test.startTest();
        delete con2;
        Test.stopTest();

        assertAccount = [SELECT Id, RecordType.Name, Name FROM Account];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' ' + Label.DefaultHouseholdName, assertAccount.Name);
    }

    /*********************************************************************************************************
     * @description
     * Update the custom setting of automatic household naming as true
     * Disconnect the contact from a Household Account
     * Make sure the Account's name is set back based on account naming setting.
     */
    @isTest
    private static void disconnectContactFromHHAccAutomatic() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.firstNameLastNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        String andConnector = Label.defaultNamingConnector;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' ' + Label.DefaultHouseholdName, assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.FirstName = 'Test2';
        con2.LastName = con.LastName + '2';
        insert con2;

        assertAccount = [SELECT Id, RecordType.Name, Name FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(
            con.FirstName +
            ' ' +
            con.LastName +
            ' ' +
            andConnector +
            ' ' +
            con2.FirstName +
            ' ' +
            con2.LastName +
            ' ' +
            Label.DefaultHouseholdName,
            assertAccount.Name
        );

        con2.AccountId = null;
        Test.startTest();
        update con2;
        Test.stopTest();

        //After remove the Account lookup for con2, system will create a new Account for con2. So, we need to query the Account of con in order to verify the Account Name.
        assertAccount = [SELECT Id, RecordType.Name, Name FROM Account WHERE Id = :assertAccount.Id];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' ' + Label.DefaultHouseholdName, assertAccount.Name);
    }

    /*********************************************************************************************************
     * @description
     * Update the custom setting of automatic household naming as true
     * Delete all the contacts linked to a Household Account
     * Make sure the Account's name is set back based on account naming setting.
     */
    @isTest
    private static void deleteAllContactsFromHHAccAutomatic() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.firstNameLastNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        String andConnector = Label.defaultNamingConnector;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        con.FirstName = 'James';
        con.LastName = 'Bond';
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.FirstName + ' ' + con.LastName + ' ' + Label.DefaultHouseholdName, assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.FirstName = 'John';
        con2.LastName = 'Legend';
        insert con2;

        assertAccount = [SELECT Id, RecordType.Name, Name FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(
            con.FirstName +
            ' ' +
            con.LastName +
            ' ' +
            andConnector +
            ' ' +
            con2.FirstName +
            ' ' +
            con2.LastName +
            ' ' +
            Label.DefaultHouseholdName,
            assertAccount.Name
        );

        Test.startTest();
        delete con2;
        delete con;
        Test.stopTest();

        assertAccount = [SELECT Id, RecordType.Name, Name FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals('James Bond ' + Label.DefaultHouseholdName, assertAccount.Name);
    }

    /*********************************************************************************************************
     * @description
     * Remove primary contact from household account
     * Make sure the primary contact of household account is repopulated
     */
    @isTest
    private static void hhAccountNoChildContactResetPrimaryContact() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getHhAccRecTypeID())
        );

        Contact con = UTIL_UnitTestData_TEST.getContact();
        insert con;

        Test.startTest();
        con.AccountId = null;
        update con;
        Test.stopTest();

        Account assertAccount = [SELECT Id, Primary_Contact__c FROM Account LIMIT 1];
        List<Contact> relatedContact = [SELECT Id, AccountId FROM Contact];

        System.assertNotEquals(null, assertAccount.Primary_Contact__c);
        System.assertNotEquals(null, relatedContact[0].AccountId);
        System.assertEquals(assertAccount.Primary_Contact__c, relatedContact[0].Id);
        System.assertEquals(relatedContact[0].AccountId, assertAccount.Id);
    }

    /*********************************************************************************************************
     * @description
     * Add a contact to a household account
     * Make sure the primary contact of household account is not changed
     */
    @isTest
    private static void hhAccountNewChildContactNotResetPrimaryContact() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getHhAccRecTypeID())
        );

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Contact con2 = contacts[1];
        con2.AccountId = acc.Id;
        insert con2;
        Test.stopTest();

        Account assertAccount = [SELECT Primary_Contact__c FROM Account WHERE Id = :acc.Id LIMIT 1];
        System.assertEquals(con.Id, assertAccount.Primary_Contact__c);
        System.assertNotEquals(con2.Id, assertAccount.Primary_Contact__c);
    }

    /*********************************************************************************************************
     * @description
     * Switch contacts between two household accounts
     * Make sure primary contacts are updated correctly
     */
    @isTest
    private static void hhAccountSwitchChildContactResetPrimaryContact() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getHhAccRecTypeID())
        );

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        insert con;

        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        Contact con2 = contacts[1];
        insert con2;

        Account acc2 = [SELECT Id, Name FROM Account WHERE Id != :acc.Id LIMIT 1];

        Test.startTest();
        con2.AccountId = acc.Id;
        update con2;
        con.AccountId = acc2.Id;
        update con;
        Test.stopTest();

        Account assertAccount = [SELECT Primary_Contact__c, Name FROM Account WHERE Id = :acc.Id LIMIT 1];
        Account assertAccount2 = [SELECT Primary_Contact__c, Name FROM Account WHERE Id = :acc2.Id LIMIT 1];
        System.assertEquals(con2.Id, assertAccount.Primary_Contact__c);
        System.assertEquals(con.Id, assertAccount2.Primary_Contact__c);
    }

    /********************************************************************************************************
     * @description Validate that when inserting a new Account for a Contact, it uses the same OwnerId as the
     * Contact that was inserted (especially if the Contact.OwnerId is set to a value other than the current user).
     */
    @isTest
    private static void test_insertAsOtherUser() {
        // Create a single new User
        Id sysAdminProfileId = UTIL_Profile.getInstance().getProfileIds(UTIL_Profile.SYSTEM_ADMINISTRATOR)[0];
        User tempUser = new User(
            LastName = 'TestSysAdminUserA',
            Email = 'test_insertAsOtherUser@email.npsp',
            ProfileId = sysAdminProfileId,
            isActive = true,
            UserName = 'test_insertAsOtherUser@email.npsp',
            Alias = 'tu08534',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1'
        );
        insert tempUser;

        Id currUserId = UserInfo.getUserId();
        Contact con = UTIL_UnitTestData_TEST.getContact();
        con.OwnerId = currUserId;
        System.runAs(tempUser) {
            insert con;
            con = [SELECT Id, OwnerId, Account.OwnerId FROM Contact WHERE Id = :con.Id LIMIT 1];
            System.assertEquals(con.OwnerId, currUserId, 'The Contact owner should be current system admin user');
            System.assertEquals(
                con.Account.OwnerId,
                currUserId,
                'The Account owner should be the same as the Contact Owner'
            );
        }
    }

    /*********************************************************************************************************
     * @description Insert a new contact with empty name string to an existing Household Account
     * Make sure the Account's name is set based on account naming setting.
     */
    @isTest
    private static void newContactExistingHHNewConEmptyString() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.acctNamingOther,
                Household_Other_Name_Setting__c = '{!Salutation} {!FirstName} Family',
                Automatic_Household_Naming__c = true
            )
        );

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        con.Salutation = 'Mr.';
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.Salutation + ' ' + con.FirstName + ' Family', assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.Salutation = '';
        con2.FirstName = '';
        Test.startTest();
        insert con2;
        Test.stopTest();

        assertAccount = [SELECT Id, RecordType.Name, Name FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con.Salutation + ' ' + con.FirstName + ' Family', assertAccount.Name);
    }

    /*********************************************************************************************************
     * @description Insert a new contact to an existing Household Account with its child contact empty naming string
     * Make sure the Account's name is set based on account naming setting.
     */
    @isTest
    private static void newContactExistingHHExistingConEmptyString() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.acctNamingOther,
                Household_Other_Name_Setting__c = '{!Salutation} {!FirstName} Family',
                Automatic_Household_Naming__c = true
            )
        );

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        Contact con = contacts[0];
        con.Salutation = '';
        con.FirstName = '';
        insert con;

        Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];
        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals('Family', assertAccount.Name);

        Contact con2 = contacts[1];
        con2.AccountId = assertAccount.Id;
        con2.Salutation = 'Mr.';
        con2.FirstName = 'Test';
        Test.startTest();
        insert con2;
        Test.stopTest();

        assertAccount = [SELECT Id, RecordType.Name, Name FROM Account];

        System.assertEquals('Household Account', assertAccount.RecordType.Name);
        System.assertEquals(con2.Salutation + ' ' + con2.FirstName + ' Family', assertAccount.Name);
    }

    /*********************************************************************************************************
     * @description Test method that tests when a new contact with blank FirstName does not add an empty space and comma.
     */
    @isTest
    private static void newContactWithEmptyFirstName() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.acctNamingOther,
                Household_Other_Name_Setting__c = Label.firstNameLastNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        String andConnector = Label.defaultNamingConnector;

        Account acct = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe.getCustomHHAccRecTypeID())[0];
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

        List<Contact> returnedContacts = [SELECT Id, AccountId, Account.Name FROM Contact WHERE Id = :contacts LIMIT 3];
        System.assertEquals(
            contacts[2].FirstName +
            ' ' +
            andConnector +
            ' ' +
            contacts[0].FirstName +
            ' ' +
            contacts[0].LastName +
            ' ' +
            Label.DefaultHouseholdName,
            returnedContacts[0].Account.Name
        );
    }

    /*********************************************************************************************************
     * @description Test Method for detaching a Contact from an already existing account
     * which is not the default account model.
     */
    @isTest
    private static void detachFromBizAccountToAdministrative() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID())
        );

        Account acct = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acct;

        Contact con = UTIL_UnitTestData_API.getContact();
        con.AccountId = acct.id;
        insert con;

        List<Contact> insertedContacts = [SELECT Account.Name, AccountId FROM Contact WHERE Id = :con.Id];
        //the contact should be connected to the account
        System.assertEquals(acct.id, insertedContacts[0].AccountId);

        con.AccountId = null;
        Test.startTest();
        update con;
        Test.stopTest();

        List<Contact> updatedContacts = [
            SELECT Account.Name, AccountId, Account.RecordTypeId
            FROM Contact
            WHERE Id = :con.Id
        ];

        //The account should not be the one we started with
        System.assertNotEquals(null, updatedContacts[0].AccountId);
        System.assertNotEquals(acct.id, updatedContacts[0].AccountId);
        System.assertEquals(UTIL_Describe_API.getAdminAccRecTypeID(), updatedContacts[0].Account.RecordTypeId);
    }

    /*********************************************************************************************************
     * @description Test Method for when a Contact's owner change the Account's Owner
     * should match the Contact's new owner.
     */
    @isTest
    private static void contactOwnerChange() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID())
        );

        Id sysAdminProfileId = UTIL_Profile.getInstance().getProfileIds(UTIL_Profile.SYSTEM_ADMINISTRATOR)[0];
        User adminUser = new User(
            LastName = 'TestAdmin',
            Email = 'testAdminUser@emailtest.edatest',
            ProfileId = sysAdminProfileId,
            isActive = true,
            UserName = 'testAdminUser@emailtest.edatest',
            Alias = 'tAdmin0',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1'
        );
        insert adminUser;

        Contact con = UTIL_UnitTestData_API.getContact();
        insert con;

        con.OwnerId = adminUser.Id;
        Test.startTest();
        update con;
        Test.stopTest();

        Contact updatedContact = [SELECT Id, Account.OwnerId FROM Contact WHERE Id = :con.Id];
        System.assertEquals(adminUser.Id, updatedContact.Account.OwnerId);
    }

    /*********************************************************************************************************
     * @description Test Method to test the queryContact() method in ACCT_IndividualAccounts_TDTM
     */
    @isTest
    private static void testQueryContacts() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID())
        );

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Test.startTest();
        List<Contact> contactReturned = ACCT_IndividualAccounts_TDTM.queryContacts(contacts);
        Test.stopTest();

        System.assertEquals(2, contactReturned.size());
        for (Contact con : contactReturned) {
            System.assertNotEquals(null, con.AccountId);
            System.assertNotEquals(null, con.Account.Name);
        }
    }

    /*********************************************************************************************************
     * @description Test Method to test the handlesAfterInsertUpdate() method in ACCT_IndividualAccounts_TDTM
     */
    @isTest
    public static void testHandleAfterInsertUpdate() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getHhAccRecTypeID())
        );

        Contact con = UTIL_UnitTestData_TEST.getContact();

        Test.startTest();
        insert con;
        Test.stopTest();

        Contact contactReturned = [
            SELECT Id, AccountId, Account.RecordTypeId, Account.Primary_Contact__c, FirstName, LastName
            FROM Contact
            WHERE Id = :con.Id
        ];

        System.assertEquals(UTIL_Describe.getCustomHHAccRecTypeID(), contactReturned.Account.RecordTypeId);
        System.assertEquals(con.Id, contactReturned.Account.Primary_Contact__c);
    }

    /*********************************************************************************************************
     * @description Test Method to test the HandleInsertWrapperLogic() method in ACCT_IndividualAccounts_TDTM
     */
    @isTest
    private static void testHandleInsertWrapperLogic() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.firstNameLastNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        List<Account> accts = UTIL_UnitTestData_API.getMultipleTestAccounts(2, UTIL_Describe.getCustomHHAccRecTypeID());
        insert accts;

        List<Contact> cons = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        cons[0].AccountId = accts[0].Id;
        cons[1].AccountId = accts[1].Id;
        insert cons;

        List<Contact> returnedContacts = [
            SELECT Id, FirstName, LastName, AccountId, Account.Name, Account.Primary_Contact__c, Account.RecordTypeId
            FROM Contact
            WHERE Id IN :cons
        ];

        for (Contact con : returnedContacts) {
            if (con.Id == cons[0].Id) {
                System.assertEquals(cons[0].Id, con.Account.Primary_Contact__c);
                System.assertEquals(
                    cons[0].FirstName +
                    ' ' +
                    cons[0].LastName +
                    ' ' +
                    Label.DefaultHouseholdName,
                    con.Account.Name
                );
            } else {
                System.assertEquals(cons[1].Id, con.Account.Primary_Contact__c);
                System.assertEquals(
                    cons[1].FirstName +
                    ' ' +
                    cons[1].LastName +
                    ' ' +
                    Label.DefaultHouseholdName,
                    con.Account.Name
                );
            }
        }
    }

    /*********************************************************************************************************
     * @description Test Method to test the HandleUpdateWrapperLogic() method in ACCT_IndividualAccounts_TDTM
     */
    @isTest
    private static void testHandleUpdateWrapperLogic() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.firstNameLastNameHH,
                Automatic_Household_Naming__c = true
            )
        );
        List<Contact> cons = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        insert cons;

        Id sysAdminProfileId = UTIL_Profile.getInstance().getProfileIds(UTIL_Profile.SYSTEM_ADMINISTRATOR)[0];
        User adminUser = new User(
            LastName = 'TestAdmin',
            Email = 'testAdminUser@emailtest.edatest',
            ProfileId = sysAdminProfileId,
            isActive = true,
            UserName = 'testAdminUser@emailtest.edatest',
            Alias = 'tAdmin0',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1'
        );
        insert adminUser;

        cons[0].FirstName = 'Samantha';
        cons[0].LastName = 'Smith';
        cons[0].OwnerId = adminUser.Id;

        cons[1].FirstName = 'Samuel';
        cons[1].LastName = 'Smith';
        cons[1].OwnerId = adminUser.Id;

        Test.startTest();
        update cons;
        Test.stopTest();

        List<Contact> returnedContacts = [
            SELECT Id, FirstName, LastName, OwnerId, AccountId, Account.OwnerId, Account.Name
            FROM Contact
            WHERE Id IN :cons
        ];

        for (Contact con : returnedContacts) {
            System.assertEquals(adminUser.Id, con.Account.OwnerId);
            System.assertEquals(adminUser.Id, con.OwnerId);

            if (con.Id == cons[0].Id) {
                System.assertEquals(
                    cons[0].FirstName +
                    ' ' +
                    cons[0].LastName +
                    ' ' +
                    Label.DefaultHouseholdName,
                    con.Account.Name
                );
            } else {
                System.assertEquals(
                    cons[1].FirstName +
                    ' ' +
                    cons[1].LastName +
                    ' ' +
                    Label.DefaultHouseholdName,
                    con.Account.Name
                );
            }
        }
    }

    /*********************************************************************************************************
     * @description Test Method to test that bulk update of contact names affect account name
     */
    @isTest
    private static void testBulkUpdateContactNames() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.firstNameLastNameHH,
                Automatic_Household_Naming__c = true
            )
        );
        List<Contact> cons = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        insert cons;
        List<Account> hhAccounts = [SELECT Id, Name FROM Account];
        System.assertEquals(2, hhAccounts.size(), 'expected number of accounts does not match 2');
        for (Account acc : hhAccounts) {
            System.assert(acc.Name.contains('Contact_forTests'), 'unexpected default account name');
        }

        Id sysAdminProfileId = UTIL_Profile.getInstance().getProfileIds(UTIL_Profile.SYSTEM_ADMINISTRATOR)[0];
        User adminUser = new User(
            LastName = 'TestAdmin',
            Email = 'testAdminUser@emailtest.edatest',
            ProfileId = sysAdminProfileId,
            isActive = true,
            UserName = 'testAdminUser@emailtest.edatest',
            Alias = 'tAdmin0',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1'
        );
        insert adminUser;

        cons[0].FirstName = 'Samantha';
        cons[0].LastName = 'Smith';
        cons[0].OwnerId = adminUser.Id;

        cons[1].FirstName = 'Jenny';
        cons[1].LastName = 'Johnson';
        cons[1].OwnerId = adminUser.Id;

        Test.startTest();
        update cons;
        Test.stopTest();

        List<Contact> returnContacts = [SELECT Id, AccountId, Account.Name, LastName FROM Contact WHERE Id IN :cons];
        System.assertEquals(2, returnContacts.size());

        Map<String, String> lastNameByAccountName = new Map<String, String>();
        for (Contact con : returnContacts) {
            if (con.AccountId != null) {
                lastNameByAccountName.put(con.LastName, con.Account.Name);
            }
        }

        System.assertEquals('Jenny Johnson ' + Label.DefaultHouseholdName, lastNameByAccountName.get('Johnson'));
        System.assertEquals('Samantha Smith ' + Label.DefaultHouseholdName, lastNameByAccountName.get('Smith'));
    }

    /*********************************************************************************************************
     * @description Test Method to test the handlesAfterDelete() && handleDeleteProcessing() method in ACCT_IndividualAccounts_TDTM
     */
    @isTest
    private static void testHandlesAfterDelete() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.firstNameLastNameHH,
                Automatic_Household_Naming__c = true
            )
        );
        Contact con = UTIL_UnitTestData_API.getContact();
        insert con;

        Contact returnedContact = [SELECT Id, AccountId FROM Contact WHERE Id = :con.Id];
        Account returnedAccount = [
            SELECT Id, Name, Primary_Contact__c
            FROM Account
            WHERE Id = :returnedContact.AccountId
        ];
        Test.startTest();
        delete con;
        Test.stopTest();

        List<Contact> returnedContactDelete = [SELECT Id, IsDeleted FROM Contact WHERE Id = :con.Id];
        System.assertEquals(0, returnedContactDelete.size());
    }

    /*********************************************************************************************************
     * @description Test Method to test sorting Contacts alphabetically by LastName FirstName
     * with {!{!FirstName}} {!LastName} Household format.
     * Test Scenario: T-3904076
     */
    @isTest
    private static void sortContactsFirstLastNames() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.firstNameLastNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        String andConnector = Label.defaultNamingConnector;

        Account acct = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe.getCustomHHAccRecTypeID())[0];
        insert acct;

        List<Contact> contacts = UTIL_UnitTestData_API.getMultipleTestContacts(9);
        for (Contact con : contacts) {
            con.AccountId = acct.Id;
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

        List<Contact> returnSortedContacts = [
            SELECT Id, FirstName, LastName, Account.Name
            FROM Contact
            WHERE Id = :contacts
        ];
        System.assertEquals(
            contacts[4].FirstName +
            ', ' +
            contacts[5].FirstName +
            ' ' +
            andConnector +
            ' ' +
            contacts[3].FirstName +
            ' ' +
            contacts[3].LastName +
            ', ' +
            contacts[8].FirstName +
            ', ' +
            contacts[6].FirstName +
            ' ' +
            andConnector +
            ' ' +
            contacts[7].FirstName +
            ' ' +
            contacts[7].LastName +
            ' ' +
            andConnector +
            ' ' +
            contacts[2].FirstName +
            ', ' +
            contacts[0].FirstName +
            ' ' +
            andConnector +
            ' ' +
            contacts[1].FirstName +
            ' ' +
            contacts[1].LastName +
            ' ' +
            Label.DefaultHouseholdName,
            returnSortedContacts[0].Account.Name
        );
    }

    /*********************************************************************************************************
     * @description Test Method to test sorting Contacts alphabetically by LastName FirstName
     * with {!LastName} ({!{!FirstName}}) Household format.
     * Test Scenario: T-3904065
     */
    @isTest
    private static void sortContactsLastFirstNames() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.lastNameFirstNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        String andConnector = Label.defaultNamingConnector;

        Account acct = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe.getCustomHHAccRecTypeID())[0];
        insert acct;

        List<Contact> contacts = UTIL_UnitTestData_API.getMultipleTestContacts(9);
        for (Contact con : contacts) {
            con.AccountId = acct.Id;
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

        List<Contact> returnSortedContacts = [
            SELECT Id, FirstName, LastName, Account.Name
            FROM Contact
            WHERE Id = :contacts
        ];

        System.assertEquals(
            contacts[3].LastName +
            ' (' +
            contacts[4].FirstName +
            ', ' +
            contacts[5].FirstName +
            ' ' +
            andConnector +
            ' ' +
            contacts[3].FirstName +
            ')' +
            ', ' +
            contacts[8].LastName +
            ' (' +
            contacts[8].FirstName +
            ', ' +
            contacts[6].FirstName +
            ' ' +
            andConnector +
            ' ' +
            contacts[7].FirstName +
            ')' +
            ' ' +
            andConnector +
            ' ' +
            contacts[2].LastName +
            ' (' +
            contacts[2].FirstName +
            ', ' +
            contacts[0].FirstName +
            ' ' +
            andConnector +
            ' ' +
            contacts[1].FirstName +
            ')' +
            ' ' +
            Label.DefaultHouseholdName,
            returnSortedContacts[0].Account.Name
        );
    }

    /*********************************************************************************************************
     * @description Test Method to test sorting Contacts alphabetically by LastName FirstName
     * with {!LastName} Household format.
     * Test Scenario: T-3904065
     */
    @isTest
    private static void sortContactsLastNameOnly() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.lastNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        String andConnector = Label.defaultNamingConnector;

        Account acct = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe.getCustomHHAccRecTypeID())[0];
        insert acct;

        List<Contact> contacts = UTIL_UnitTestData_API.getMultipleTestContacts(3);
        for (Contact con : contacts) {
            con.AccountId = acct.Id;
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

        List<Contact> returnSortedContacts = [
            SELECT Id, FirstName, LastName, Account.Name
            FROM Contact
            WHERE Id = :contacts
        ];

        System.assertEquals(
            contacts[1].LastName +
            ', ' +
            contacts[2].LastName +
            ' ' +
            andConnector +
            ' ' +
            contacts[0].LastName +
            ' ' +
            Label.DefaultHouseholdName,
            returnSortedContacts[0].Account.Name
        );
    }

    /*********************************************************************************************************
     * @description Test Method to test sorting Contacts alphabetically by LastName FirstName
     * with {!{!FirstName}} {!LastName} Household format and blank FirstNames.
     * Test Scenario: T-3904065
     */
    @isTest
    private static void sortContactsWithoutFirstNames() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.firstNameLastNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        String andConnector = Label.defaultNamingConnector;

        Account acct = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe.getCustomHHAccRecTypeID())[0];
        insert acct;

        List<Contact> contacts = UTIL_UnitTestData_API.getMultipleTestContacts(3);
        for (Contact con : contacts) {
            con.AccountId = acct.Id;
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

        List<Contact> returnSortedContacts = [
            SELECT Id, FirstName, LastName, Account.Name
            FROM Contact
            WHERE Id = :contacts
        ];
        System.assertEquals(
            contacts[1].LastName +
            ', ' +
            contacts[2].LastName +
            ' ' +
            andConnector +
            ' ' +
            contacts[0].LastName +
            ' ' +
            Label.DefaultHouseholdName,
            returnSortedContacts[0].Account.Name
        );
    }

    /*********************************************************************************************************
     * @description Test Method to test sorting Contacts alphabetically with custom format.
     * {!{!FirstName} {!LastName}} House
     * Test Scenario: T-3904065
     */
    @isTest
    private static void sortContactsWithCustomFormat() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = '{!{!FirstName} {!LastName}} House',
                Automatic_Household_Naming__c = true
            )
        );

        String andConnector = Label.defaultNamingConnector;

        Contact con = UTIL_UnitTestData_API.getContact();
        con.FirstName = 'Marvin';
        con.LastName = 'Johnston';
        insert con;

        Contact requeryInsertedCon = [SELECT Id, AccountId, Account.Name FROM Contact WHERE Id = :con.Id];
        Account acc = [SELECT Id, Name FROM Account WHERE Id = :requeryInsertedCon.AccountId];

        Contact con2 = new Contact(LastName = 'Johnston', FirstName = 'Tyrone', AccountId = acc.Id);
        insert con2;

        Account requeryAccount = [SELECT Id, Name FROM Account WHERE Id = :requeryInsertedCon.AccountId];

        System.assertEquals(
            con.FirstName +
            ' ' +
            con.LastName +
            ' ' +
            andConnector +
            ' ' +
            con2.FirstName +
            ' ' +
            con2.LastName +
            ' ' +
            'House',
            requeryAccount.Name
        );

        Contact con3 = new Contact(LastName = 'Phillips', FirstName = 'Crystal', AccountId = acc.Id);
        insert con3;

        Account requeryFinalAccount = [SELECT Id, Name FROM Account WHERE Id = :requeryInsertedCon.AccountId];
        System.assertEquals(
            con.FirstName +
            ' ' +
            con.LastName +
            ', ' +
            con2.FirstName +
            ' ' +
            con2.LastName +
            ' ' +
            andConnector +
            ' ' +
            con3.FirstName +
            ' ' +
            con3.LastName +
            ' ' +
            'House',
            requeryFinalAccount.Name
        );
    }

    /*********************************************************************************************************
     * @description Test Method to test sorting Contacts alphabetically with custom format.
     * {!Salutation} {!{!FirstName}} {!LastName} Family
     * Test Scenario: T-3904065
     */
    @isTest
    private static void sortContactsWithCustomFormat2() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = '{!Salutation} ' + Label.firstNameLastNameFamily,
                Automatic_Household_Naming__c = true
            )
        );

        String andConnector = Label.defaultNamingConnector;

        Contact con = UTIL_UnitTestData_API.getContact();
        con.Salutation = 'Ms.';
        con.FirstName = 'Betty';
        con.LastName = 'White';
        insert con;

        Contact requeryInsertedCon = [SELECT Id, AccountId, Account.Name FROM Contact WHERE Id = :con.Id];
        Account acc = [SELECT Id, Name FROM Account WHERE Id = :requeryInsertedCon.AccountId];

        Contact con2 = new Contact(LastName = 'White', FirstName = 'Lily', Salutation = 'Ms.', AccountId = acc.Id);
        insert con2;

        Account requeryAccount = [SELECT Id, Name FROM Account WHERE Id = :requeryInsertedCon.AccountId];

        System.assertEquals(
            con.Salutation +
            ' ' +
            con.FirstName +
            ' ' +
            andConnector +
            ' ' +
            con2.FirstName +
            ' ' +
            con2.LastName +
            ' ' +
            Label.hhFamily,
            requeryAccount.Name
        );

        Contact con3 = new Contact(LastName = 'White', FirstName = 'Tom', Salutation = 'Mr.', AccountId = acc.Id);
        insert con3;

        Account requeryFinalAccount = [SELECT Id, Name FROM Account WHERE Id = :requeryInsertedCon.AccountId];

        System.assertEquals(
            con.Salutation +
            ' ' +
            con.FirstName +
            ', ' +
            con2.FirstName +
            ' ' +
            andConnector +
            ' ' +
            con3.FirstName +
            ' ' +
            con3.LastName +
            ' ' +
            Label.hhFamily,
            requeryFinalAccount.Name
        );
    }

    /*********************************************************************************************************
     * @description Test Method to check if a Contact is marked deceased, the Account name is updated properly.
     */
    @isTest
    private static void contactMarkedDeceased() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.lastNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        Contact con = UTIL_UnitTestData_API.getContact();
        con.LastName = 'Thomas';
        insert con;

        Contact requeryInsertedCon = [SELECT Id, AccountId, Account.Name FROM Contact WHERE Id = :con.Id];
        Account acc = [SELECT Id, Name FROM Account WHERE Id = :requeryInsertedCon.AccountId];

        Contact con2 = UTIL_UnitTestData_API.getContact();
        con2.LastName = 'Pens';
        con2.AccountId = acc.Id;
        insert con2;

        con.Deceased__c = true;

        Test.startTest();
        update con;
        Test.stopTest();

        Account returnAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id];

        System.assertEquals('Pens ' + Label.DefaultHouseholdName, returnAccount.Name);
    }

    /*********************************************************************************************************
     * @description Test Method to check if multiple Contacts are marked deceased, Household account names are
     * updated properly.
     * Test Scenario: T-3904057
     */
    @isTest
    private static void hhContactMarkedDeceasedBulked() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.lastNameFirstNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        List<Contact> newContacts = UTIL_UnitTestData_API.getMultipleTestContacts(5);
        for (Integer i = 0; i < newContacts.size(); i++) {
            for (Contact con : newContacts) {
                con.FirstName = 'PrimaryContact_FirstName ' + i;
                con.LastName = 'PrimaryContact_LastName ' + i;
            }
        }
        insert newContacts;

        List<Contact> requeryInsertedCon = [SELECT Id, AccountId, Account.Name FROM Contact WHERE Id IN :newContacts];

        List<Id> accountIds = new List<Id>();

        for (Contact cAccountId : requeryInsertedCon) {
            accountIds.add(cAccountId.Id);
        }

        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id IN :accountIds];

        List<Contact> addSecondContacts = new List<Contact>();
        for (Integer i = 0; i < accounts.size(); i++) {
            Contact con2 = new Contact(
                AccountId = accounts[i].Id,
                FirstName = 'SecondaryContact_FirstName ' + i,
                LastName = 'PrimaryContact_LastName ' + i
            );
            addSecondContacts.add(con2);
        }
        insert addSecondContacts;

        List<Contact> addThirdContacts = new List<Contact>();
        for (Integer i = 0; i < accounts.size(); i++) {
            Contact con3 = new Contact(
                AccountId = accounts[i].Id,
                FirstName = 'TertiaryContact_FirstName ' + i,
                LastName = 'PrimaryContact_LastName ' + i
            );
            addThirdContacts.add(con3);
        }
        insert addThirdContacts;

        List<Contact> returnSecondContacts = [
            SELECT Id, FirstName, Deceased__c
            FROM Contact
            WHERE Id IN :addSecondContacts
        ];
        for (Contact con : returnSecondContacts) {
            con.Deceased__c = true;
        }

        Test.startTest();
        update returnSecondContacts;
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id, Name FROM Account WHERE Id IN :accounts];

        for (Integer i = 0; i < returnAccounts.size(); i++) {
            String primaryContactName = 'PrimaryContact_FirstName ' + i;
            String tertiaryContactName = 'TertiaryContact_FirstName ' + i;
            String LastName = 'PrimaryContact_LastName ' + i;

            System.assertEquals(
                LastName +
                ' (' +
                primaryContactName +
                Label.defaultNamingConnector +
                tertiaryContactName +
                ') ' +
                ' ' +
                Label.DefaultHouseholdName,
                returnAccounts[i].Name
            );
        }

        List<Contact> returnThirdContacts = [
            SELECT Id, FirstName, Deceased__c
            FROM Contact
            WHERE Id IN :addThirdContacts
        ];

        for (Contact conThree : returnThirdContacts) {
            conThree.Deceased__c = true;
        }

        update returnThirdContacts;

        List<Account> returnAccounts2 = [SELECT Id, Name FROM Account WHERE Id IN :accounts];

        for (Integer i = 0; i < returnAccounts2.size(); i++) {
            String primaryContactName = 'PrimaryContact_FirstName ' + i;
            String LastName = 'PrimaryContact_LastName ' + i;

            System.assertEquals(
                LastName +
                ' (' +
                primaryContactName +
                ') ' +
                ' ' +
                Label.DefaultHouseholdName,
                returnAccounts[i].Name
            );
        }
    }

    /*********************************************************************************************************
     * @description Test Method to check if multiple Contacts from different Accounts are updated, and the
     * updates made on the Contacts are different, the Accounts names should be updated appropriately.
     */
    @isTest
    private static void contactMarkedDeceasedandNonDeceased() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.lastNameFirstNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        List<Contact> newContacts = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        newContacts[0].FirstName = 'Joe';
        newContacts[0].LastName = 'Wagon';
        newContacts[1].FirstName = 'Lilian';
        newContacts[1].LastName = 'Watts';
        insert newContacts;

        List<Contact> requeryInsertedCon = [
            SELECT Id, FirstName, LastName, AccountId, Account.Name
            FROM Contact
            WHERE Id IN :newContacts
        ];

        requeryInsertedCon[0].Deceased__c = true;
        requeryInsertedCon[1].FirstName = 'Betty';

        Test.startTest();
        update requeryInsertedCon;
        Test.stopTest();

        List<Contact> returnContacts = [
            SELECT Id, AccountId, Account.Name, FirstName, LastName
            FROM Contact
            WHERE Id IN :newContacts
        ];

        System.assertEquals(
            returnContacts[0].LastName +
            ' (' +
            returnContacts[0].FirstName +
            ') ' +
            Label.DefaultHouseholdName,
            returnContacts[0].Account.Name
        );
        System.assertEquals(
            returnContacts[1].LastName +
            ' (' +
            returnContacts[1].FirstName +
            ') ' +
            Label.DefaultHouseholdName,
            returnContacts[1].Account.Name
        );
    }

    /*********************************************************************************************************
     * @description Test Method to test if all Contacts associated to the Account are deceased, do not update
     * the Account's Name to "Household".
     */
    @isTest
    private static void deceasedContacts() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.lastNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        Contact con = UTIL_UnitTestData_API.getContact();
        con.LastName = 'Thomas';
        insert con;

        Contact requeryInsertedCon = [SELECT Id, AccountId, Account.Name FROM Contact WHERE Id = :con.Id];
        Account acc = [SELECT Id, Name FROM Account WHERE Id = :requeryInsertedCon.AccountId];

        Contact con2 = UTIL_UnitTestData_API.getContact();
        con2.LastName = 'Pens';
        con2.AccountId = acc.Id;
        insert con2;

        con2.Deceased__c = true;
        update con2;

        con.Deceased__c = true;

        Test.startTest();
        update con;
        Test.stopTest();

        Account returnAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Thomas ' + Label.DefaultHouseholdName, returnAccount.Name);
    }

    /*********************************************************************************************************
     * @description Test Method to check if all Contacts associated to the Account are marked exclude from
     * Household Name, do not update the Account's Name to "Household".
     * Test Scenario: T-3904067
     */
    @isTest
    private static void contactMarkedExcludedFromHHNaming() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.lastNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        Contact con = UTIL_UnitTestData_API.getContact();
        con.LastName = 'Thomas';
        insert con;

        Contact requeryInsertedCon = [SELECT Id, AccountId, Account.Name FROM Contact WHERE Id = :con.Id];
        Account acc = [SELECT Id, Name FROM Account WHERE Id = :requeryInsertedCon.AccountId];

        Contact con2 = UTIL_UnitTestData_API.getContact();
        con2.LastName = 'Pens';
        con2.AccountId = acc.Id;
        insert con2;

        Account returnAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id];
        System.assertEquals(
            con2.LastName +
            ' ' +
            Label.defaultNamingConnector +
            ' ' +
            con.LastName +
            ' ' +
            Label.DefaultHouseholdName,
            returnAccount.Name
        );

        con.Exclude_from_Household_Name__c = true;

        Test.startTest();
        update con;
        Test.stopTest();

        returnAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id];
        System.assertEquals(con2.LastName + ' ' + Label.DefaultHouseholdName, returnAccount.Name);
    }

    /*********************************************************************************************************
     * @description Test Method to check if a Contact is marked excluded from HH Naming, the Account name is updated properly.
     */
    @isTest
    private static void allContactsMarkedExcludedFromHHNaming() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.lastNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        Contact con = UTIL_UnitTestData_API.getContact();
        con.LastName = 'Thomas';
        insert con;

        Contact requeryInsertedCon = [SELECT Id, AccountId, Account.Name FROM Contact WHERE Id = :con.Id];
        Account acc = [SELECT Id, Name FROM Account WHERE Id = :requeryInsertedCon.AccountId];

        Contact con2 = UTIL_UnitTestData_API.getContact();
        con2.LastName = 'Pens';
        con2.AccountId = acc.Id;
        insert con2;

        con2.Exclude_from_Household_Name__c = true;
        update con2;

        con.Exclude_from_Household_Name__c = true;

        Test.startTest();
        update con;
        Test.stopTest();

        Account returnAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Thomas ' + Label.DefaultHouseholdName, returnAccount.Name);
    }

    /*********************************************************************************************************
     * @description Test Method to check if the last Contact is deleted should not update the Account name.
     */
    @isTest
    private static void lastContactIsDeleted() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.lastNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        Contact con = UTIL_UnitTestData_API.getContact();
        con.LastName = 'Thomas';
        insert con;

        Contact requeryInsertedCon = [SELECT Id, AccountId, Account.Name FROM Contact WHERE Id = :con.Id];
        Account acc = [
            SELECT Id, Name, RecordTypeId, RecordType.Name
            FROM Account
            WHERE Id = :requeryInsertedCon.AccountId
        ];

        Contact con2 = UTIL_UnitTestData_API.getContact();
        con2.LastName = 'Pens';
        con2.AccountId = acc.Id;
        insert con2;

        con2.Exclude_from_Household_Name__c = true;
        update con2;

        Test.startTest();
        delete con;
        Test.stopTest();

        Account returnAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Thomas ' + Label.DefaultHouseholdName, returnAccount.Name);
    }

    /*********************************************************************************************************
     * @description Test Method to check if one of many Contacts associated to an Account is deleted,
     * it should update the Account name properly based on the existing Contacts left that's not marked
     * deceased or exclude from Household naming.
     */
    @isTest
    private static void contactDeleted() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.lastNameHH,
                Automatic_Household_Naming__c = true
            )
        );

        Contact con = UTIL_UnitTestData_API.getContact();
        con.LastName = 'Thomas';
        insert con;

        Contact requeryInsertedCon = [SELECT Id, AccountId, Account.Name FROM Contact WHERE Id = :con.Id];
        Account acc = [SELECT Id, Name FROM Account WHERE Id = :requeryInsertedCon.AccountId];

        Contact con2 = UTIL_UnitTestData_API.getContact();
        con2.LastName = 'Pens';
        con2.AccountId = acc.Id;
        insert con2;

        con2.Exclude_from_Household_Name__c = true;
        update con2;

        Contact con3 = UTIL_UnitTestData_API.getContact();
        con3.LastName = 'James';
        con3.AccountId = acc.Id;
        insert con3;

        con3.Deceased__c = true;
        update con3;

        Contact con4 = UTIL_UnitTestData_API.getContact();
        con4.LastName = 'Bond';
        con4.AccountId = acc.Id;
        insert con4;

        Contact con5 = UTIL_UnitTestData_API.getContact();
        con5.LastName = 'Legend';
        con5.AccountId = acc.Id;
        insert con5;

        Test.startTest();
        delete con;
        Test.stopTest();

        String andConnector = Label.defaultNamingConnector;

        Account returnAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id];
        System.assertEquals(
            con4.LastName +
            ' ' +
            andConnector +
            ' ' +
            con5.LastName +
            ' ' +
            Label.DefaultHouseholdName,
            returnAccount.Name
        );
    }

    /*********************************************************************************************************
     * @description Test Method to test whether Account Name is renamed appropriately if Prefix is not
     * surrounded in curly braces.
     */
    @isTest
    private static void testBulkPrefix() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = 'Foyer {!LastName} ({!{!FirstName}})',
                Automatic_Household_Naming__c = true
            )
        );

        String andConnector = Label.defaultNamingConnector;

        Id sysAdminProfileId = UTIL_Profile.getInstance().getProfileIds(UTIL_Profile.SYSTEM_ADMINISTRATOR)[0];
        User adminUser = new User(
            LastName = 'TestAdmin',
            Email = 'testAdminUser@emailtest.edatest',
            ProfileId = sysAdminProfileId,
            isActive = true,
            UserName = 'testAdminUser@emailtest.edatest',
            Alias = 'tAdmin0',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'fr',
            EmailEncodingKey = 'ISO-8859-1'
        );
        insert adminUser;

        List<Contact> newCons = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        newCons[0].FirstName = 'Jane';
        newCons[0].LastName = 'Pens';
        newCons[1].FirstName = 'Betty';
        newCons[1].LastName = 'Jones';
        insert newCons;

        List<Id> accountIds = new List<Id>();
        List<Contact> queryContacts = [
            SELECT Id, AccountId, Account.Name, LastName, FirstName
            FROM Contact
            WHERE Id IN :newCons
        ];
        for (Contact con : queryContacts) {
            System.assertEquals('Foyer ' + con.LastName + ' (' + con.FirstName + ')', con.Account.Name);
            accountIds.add(con.AccountId);
        }

        List<Contact> addNewCons = new List<Contact>{
            new Contact(AccountId = accountIds[0], FirstName = 'John', LastName = 'Pens'),
            new Contact(AccountId = accountIds[1], FirstName = 'Tommy', LastName = 'Jones')
        };

        Test.startTest();
        insert addNewCons;
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id, Name FROM Account WHERE Id IN :accountIds];
        System.assertEquals('Foyer Pens ' + '(Jane ' + andConnector + ' John)', returnAccounts[0].Name);
        System.assertEquals('Foyer Jones ' + '(Betty ' + andConnector + ' Tommy)', returnAccounts[1].Name);
    }

    /*********************************************************************************************************
     * @description Ensure prefix/suffix is appropriately mapped to household account renaming logic.
     * Test Scenario: T-3904064
     */
    @isTest
    private static void shouldAppendPrefixSuffixHH() {
        Set<String> objectFields = Schema.SObjectType.Contact.fields.getMap().keySet();
        Boolean ispersonNameSuffixEnabled = objectFields.contains('suffix');

        Hierarchy_Settings__c edaSettings = new Hierarchy_Settings__c(
            Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
            Household_Account_Naming_Format__c = Label.acctNamingOther,
            Household_Other_Name_Setting__c = '{!Salutation} {!LastName} ' + Label.DefaultHouseholdName,
            Automatic_Household_Naming__c = true
        );

        if (ispersonNameSuffixEnabled) {
            edaSettings.Household_Other_Name_Setting__c =
                '{!Salutation} {!LastName} {!Suffix} ' + Label.DefaultHouseholdName;
        }

        UTIL_CustomSettingsFacade.getSettingsForTests(edaSettings);

        List<Contact> allContacts = new List<Contact>();
        Contact currentContact;
        for (integer i = 0; i < 10; i++) {
            currentContact = UTIL_UnitTestData_TEST.getUniqueContact(i);
            currentContact.Salutation = 'Mr.';

            if (ispersonNameSuffixEnabled) {
                currentContact.put('Suffix', 'Suffix' + i);
            }
            allContacts.add(currentContact);
        }

        Test.startTest();
        insert allContacts;
        Test.stopTest();

        List<Account> accts = [SELECT Id, Name FROM Account];
        if (ispersonNameSuffixEnabled) {
            for (integer i = 0; i < accts.size(); i++) {
                System.assertEquals(
                    'Mr.' +
                    ' ' +
                    'LastNew' +
                    i +
                    ' ' +
                    'Suffix' +
                    i +
                    ' ' +
                    Label.DefaultHouseholdName,
                    accts[i].Name
                );
            }
        } else {
            for (integer i = 0; i < accts.size(); i++) {
                System.assertEquals('Mr.' + ' ' + 'LastNew' + i + ' ' + Label.DefaultHouseholdName, accts[i].Name);
            }
        }
    }

    /*********************************************************************************************************
     * @description Ensure prefix/suffix is appropriately mapped to household account renaming logic for a
     * non English user.
     * Test Scenario: T-3904063
     */
    @isTest
    private static void shouldAppendPrefixSuffixHHSpanish() {
        Profile systemAdministratorProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        System.runAs(UTIL_UnitTestData_TEST.createNewUserForTests(
            System.now().getTime() + '@testerson.com',
            systemAdministratorProfile.Id,
            'es'
        )) {
            Set<String> objectFields = Schema.SObjectType.Contact.fields.getMap().keySet();
            Boolean ispersonNameSuffixEnabled = objectFields.contains('suffix');
            Hierarchy_Settings__c edaSettings = new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.acctNamingOther,
                Household_Other_Name_Setting__c = 'Domicilio de {!Salutation} {!LastName}',
                Automatic_Household_Naming__c = true
            );

            if (ispersonNameSuffixEnabled) {
                edaSettings.Household_Other_Name_Setting__c = 'Domicilio de {!Salutation} {!LastName} {!Suffix}';
            }

            UTIL_CustomSettingsFacade.getSettingsForTests(edaSettings);

            List<Contact> allContacts = new List<Contact>();
            Contact currentContact;
            for (integer i = 0; i < 10; i++) {
                currentContact = UTIL_UnitTestData_TEST.getUniqueContact(i);
                currentContact.Salutation = 'Mr.';

                if (ispersonNameSuffixEnabled) {
                    currentContact.put('Suffix', 'Suffix' + i);
                }
                allContacts.add(currentContact);
            }

            Test.startTest();
            insert allContacts;
            Test.stopTest();

            List<Account> accts = [SELECT Id, Name FROM Account];
            if (ispersonNameSuffixEnabled) {
                for (integer i = 0; i < accts.size(); i++) {
                    System.assertEquals(
                        'Domicilio de ' +
                        'Mr.' +
                        ' ' +
                        'LastNew' +
                        i +
                        ' ' +
                        'Suffix' +
                        i,
                        accts[i].Name
                    );
                }
            } else {
                for (integer i = 0; i < accts.size(); i++) {
                    System.assertEquals('Domicilio de ' + 'Mr.' + ' ' + 'LastNew' + i, accts[i].Name);
                }
            }
        }
    }

    /*********************************************************************************************************
     * @description In a multi-currency enabled org, create a contact with different currency than the default one.
     * Ensure the account automatically is created and the account currency maps to contact respectively.
     * Ensure subsequent contacts insertions, update account naming (conform alphabetically).
     * Ensure subsequent contacts insertions, preserve initial contact/account currency.
     * Test Scenario: T-3904075
     */
    @isTest
    private static void insertContactMultiCurrencyEnabled() {
        if (UserInfo.isMultiCurrencyOrganization()) {
            UTIL_CustomSettingsFacade.getSettingsForTests(
                new Hierarchy_Settings__c(
                    Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                    Household_Account_Naming_Format__c = Label.lastNameHH,
                    Automatic_Household_Naming__c = true
                )
            );

            //Test data setup
            String nonDefaultCurrencyCode = '';
            String qryCurrencyTypeString = 'SELECT IsoCode FROM CurrencyType WHERE IsCorporate = false LIMIT 1';
            List<SObject> nonDefaultCurrencies = Database.query(qryCurrencyTypeString);
            if (nonDefaultCurrencies.size() > 0) {
                nonDefaultCurrencyCode = (String) nonDefaultCurrencies[0].get('IsoCode');
            } else {
                return;
            }

            Contact primaryContact = UTIL_UnitTestData_TEST.getContact();
            primaryContact.LastName = 'Zhang';
            primaryContact.put('CurrencyIsoCode', nonDefaultCurrencyCode);

            //Run the logic
            Test.startTest();
            insert primaryContact;
            Test.stopTest();

            //Assert the result
            String qryString = 'SELECT Id, Name, CurrencyIsoCode FROM Account';
            List<Account> resultAccounts = Database.query(qryString);

            System.assertEquals(primaryContact.LastName + ' ' + Label.DefaultHouseholdName, resultAccounts[0].Name);
            System.assertEquals(1, resultAccounts.size(), 'More than one Account were created.');
            System.assertEquals(
                nonDefaultCurrencyCode,
                resultAccounts[0].get('CurrencyIsoCode'),
                'The currency between contact and account mismatch.'
            );

            Contact secondaryContact = UTIL_UnitTestData_TEST.getContact();
            secondaryContact.LastName = 'Wilson';
            secondaryContact.AccountId = resultAccounts[0].Id;
            insert secondaryContact;

            resultAccounts = Database.query(qryString);

            Id secondaryContactId = secondaryContact.Id;
            String querySecondaryContact = 'SELECT Id, LastName, CurrencyIsoCode FROM CONTACT WHERE Id =: secondaryContactId';
            secondaryContact = (Contact) Database.query(querySecondaryContact)[0];

            System.assertNotEquals(secondaryContact.get('CurrencyIsoCode'), nonDefaultCurrencyCode);
            System.assertEquals(nonDefaultCurrencyCode, resultAccounts[0].get('CurrencyIsoCode'));

            System.assertEquals(
                secondaryContact.LastName +
                ' ' +
                Label.defaultNamingConnector +
                ' ' +
                primaryContact.LastName +
                ' ' +
                Label.DefaultHouseholdName,
                resultAccounts[0].Name
            );
        }
    }

    /*********************************************************************************************************
     * @description In a multi-currency enabled org, insert a contact with different currency than the default
     * one. Ensure the associated account automatically is created and has the contacts respective currency.
     * Test Scenario: T-3904059
     */
    @isTest
    private static void ensureContactWithCustomCurrencyMapsToAccount() {
        if (UserInfo.isMultiCurrencyOrganization()) {
            //Test data setup
            String nonDefaultCurrencyCode = '';
            String qryCurrencyTypeString = 'SELECT IsoCode FROM CurrencyType WHERE IsCorporate = false LIMIT 1';
            List<SObject> nonDefaultCurrencies = Database.query(qryCurrencyTypeString);
            if (nonDefaultCurrencies.size() > 0) {
                nonDefaultCurrencyCode = (String) nonDefaultCurrencies[0].get('IsoCode');
            } else {
                return;
            }

            Contact testContact = UTIL_UnitTestData_TEST.getContact();
            testContact.put('CurrencyIsoCode', nonDefaultCurrencyCode);

            //Run the logic
            Test.startTest();
            insert testContact;
            Test.stopTest();

            //Assert the result
            String qryString = 'SELECT Id, Name, CurrencyIsoCode FROM Account';
            List<Account> resultAccounts = Database.query(qryString);

            System.assertEquals(1, resultAccounts.size(), 'More than one Account were created.');
            System.assertEquals(
                nonDefaultCurrencyCode,
                resultAccounts[0].get('CurrencyIsoCode'),
                'The currency between contact and account mismatch.'
            );
        }
    }

    /*****************************************************************************************************************************************
     * @description Test to ensure Account's owner and name is changed when COntact's owner and Last names are changed in a single transaction
     */
    @isTest
    private static void testOwnerLastNameUpdate() {
        // Create a single new User
        Id sysAdminProfileId = UTIL_Profile.getInstance().getProfileIds(UTIL_Profile.SYSTEM_ADMINISTRATOR)[0];
        User tempUser = new User(
            LastName = 'TestSysAdminUserA',
            Email = 'test_insertAsOtherUser@email.npsp',
            ProfileId = sysAdminProfileId,
            isActive = true,
            UserName = 'test_insertAsOtherUser@email.npsp',
            Alias = 'tu08534',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1'
        );
        insert tempUser;

        // Create a Contact
        Contact testContact = UTIL_UnitTestData_TEST.getContact();
        testContact.FirstName = 'Jon';
        testContact.LastName = 'Day';
        insert testContact;

        // Ensure Account is created
        Account acc = [SELECT Id, ownerId, Name FROM Account];
        System.assertEquals('Day Administrative Account', acc.Name);

        // Change Contact's Last Name and owner in a single transaction
        Test.startTest();
        testContact.LastName = 'Night';
        testContact.OwnerId = tempUser.Id;
        update testContact;
        Test.stopTest();

        // Ensure Contact is updated
        Contact conAfterUpdate = [SELECT Id, Name, ownerId FROM Contact];
        System.assertEquals('Jon Night', conAfterUpdate.Name);
        System.assertEquals(tempUser.Id, conAfterUpdate.OwnerId);

        // Ensure Account's name and owner are updated
        Account accAfterUpdate = [SELECT Id, ownerId, Name FROM Account];
        System.assertEquals('Night Administrative Account', accAfterUpdate.Name);
        System.assertEquals(tempUser.Id, accAfterUpdate.ownerId);
    }

    /*****************************************************************************************************************************************
     * @description Helper method to set the Default Account Model and Administrative Account Record Type.
     */

    private static void setAdminAccRecTypeAsBizOrgHelper() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getBizAccRecTypeID(),
                Administrative_Account_Record_Type__c = UTIL_Describe_API.getBizAccRecTypeID()
            )
        );
    }

    /***********************************************************************************************************************************************
     * @description Test to ensure Account owner update changes owner on Account when Administrative Account Record Type  and Account Model are
     * Business Org Record Type
     */
    @isTest
    private static void testContactOwnerUpdateWithBizAccRecTypeAsAdminAccRecType() {
        ACCT_IndividualAccounts_Test.setAdminAccRecTypeAsBizOrgHelper();

        // Insert a user
        Id sysAdminProfileId = UTIL_Profile.getInstance().getProfileIds(UTIL_Profile.SYSTEM_ADMINISTRATOR)[0];
        User tempUser = new User(
            LastName = 'TestSysAdminUserA',
            Email = 'test_insertAsOtherUser@email.npsp',
            ProfileId = sysAdminProfileId,
            isActive = true,
            UserName = 'test_insertAsOtherUser@email.npsp',
            Alias = 'tu08534',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1'
        );
        insert tempUser;

        Contact con = UTIL_UnitTestData_API.getContact();
        con.LastName = 'test1234';
        insert con;
        con.OwnerId = tempUser.Id;

        Test.startTest();
        update con;
        Test.stopTest();

        // Ensure record type stays the same and owner on the Account is updated to match Contact's owner
        Account acc = [SELECT Id, RecordTypeId, ownerId FROM Account LIMIT 1];
        Contact conAfterUpdate = [SELECT Id, AccountId, ownerId FROM Contact WHERE Id = :con.Id];

        System.assertEquals(UTIL_Describe_API.getBizAccRecTypeID(), acc.RecordTypeId);
        System.assertEquals(conAfterUpdate.ownerId, acc.ownerId);
    }

    /**************************************************************************************************************************************
     * @description Test to ensure Account's name follows Administrative Account naming format when Administrative Account Record Type
     * is Business Org Rec Type
     */
    @isTest
    private static void testContactInsertWithBizAccRecTypeAsAdminAccRecType() {
        ACCT_IndividualAccounts_Test.setAdminAccRecTypeAsBizOrgHelper();

        Test.startTest();
        Contact con = UTIL_UnitTestData_API.getContact();
        con.LastName = 'test1234';
        insert con;
        Test.stopTest();

        // Assert Account Name follows Admin Acount Naming format, record type is Default Account Model Record Type
        // and Owner on the Account matches Contact's
        Account acc = [SELECT Id, Name, RecordTypeId, ownerId FROM Account LIMIT 1];
        Contact conAfterInsert = [SELECT Id, AccountId, ownerId FROM Contact WHERE Id = :con.Id];

        System.assertEquals('test1234 Administrative Account', acc.Name);
        System.assertEquals(UTIL_Describe_API.getBizAccRecTypeID(), acc.RecordTypeId);
        System.assertEquals(conAfterInsert.ownerId, acc.ownerId);
    }

    /***********************************************************************************************************************
     * @description Test to ensure Account's name follows Administrative naming format when Contact's Last Name changes and
     * Administrative Account Record TYpe is Business Org Rec Type
     */
    @isTest
    private static void testContactLastNameUpdateWithBizAccRecTypeAsAdminAccRecType() {
        ACCT_IndividualAccounts_Test.setAdminAccRecTypeAsBizOrgHelper();

        Contact con = UTIL_UnitTestData_API.getContact();
        con.LastName = 'test1234';
        insert con;

        Account acc = [SELECT Id, Name, RecordTypeId, ownerId FROM Account LIMIT 1];
        Contact conAfterInsert = [SELECT Id, AccountId, ownerId FROM Contact WHERE Id = :con.Id];

        System.assertEquals('test1234 Administrative Account', acc.Name);
        System.assertEquals(UTIL_Describe_API.getBizAccRecTypeID(), acc.RecordTypeId);
        System.assertEquals(conAfterInsert.ownerId, acc.ownerId);

        Test.startTest();
        conAfterInsert.LastName = 'test 0';
        update conAfterInsert;
        Test.stopTest();

        //Ensure Account Name on the Account is updated
        Account accAfterUpdate = [SELECT Id, Name, RecordTypeId, ownerId FROM Account WHERE Id = :acc.Id];

        System.assertEquals('test 0 Administrative Account', accAfterUpdate.Name);
    }
}
