/*
    Copyright (c) 2020, Salesforce.org
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
 * @date 2020
 * @group Account
 * @group-content ../../ApexDocContent/Account.htm
 * @description Tests class for refreshing Administrative Account Names.
 */
@isTest
private class ACCT_AdministrativeNameRefresh_TEST {
    /*******************************************************************************************************
     * @description Ensure Administrative Account refresh (batch) successfully renames the applicable
     * administrative accounts.
     * Test Scenario: T-3904053
     */
    @isTest
    private static void ensureRefreshAdministrativeAccountBatchRenamesAccounts() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                Admin_Account_Naming_Format__c = Label.lastNameAdminAcc
            )
        );

        List<Contact> contacts = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        contacts[0].LastName = 'Wells';
        contacts[0].FirstName = 'Tommy';
        contacts[1].LastName = 'Jones';
        contacts[1].FirstName = 'Betty';
        insert contacts;

        Set<Id> accountIds = new Set<Id>();
        Map<String, Id> lastNameByAccountId = new Map<String, Id>();

        for (Contact con : [SELECT Id, LastName, AccountId, Account.Name FROM Contact WHERE Id IN :contacts]) {
            accountIds.add(con.AccountId);
            lastNameByAccountId.put(con.LastName, con.AccountId);
        }

        List<Account> queryAccounts = [
            SELECT Id, Name, RecordTypeId, RecordType.Name
            FROM Account
            WHERE Id IN :accountIds
        ];
        queryAccounts[0].Name = 'Tommy Wells Account';
        queryAccounts[1].Name = 'Betty Jones Account';
        update queryAccounts;

        //Verifies that the update on Account Name on the Account record persisted
        for (Account acc : queryAccounts) {
            if (lastNameByAccountId.get('Wells') == acc.Id) {
                System.assertEquals('Tommy Wells Account', acc.Name);
            }
            if (lastNameByAccountId.get('Jones') == acc.Id) {
                System.assertEquals('Betty Jones Account', acc.Name);
            }
        }

        Test.startTest();
        ACCT_AdministrativeNameRefresh_BATCH batch = new ACCT_AdministrativeNameRefresh_BATCH();
        Id apexJobId = Database.executeBatch(batch, 200);
        Test.stopTest();

        //Verifies that after refresh Admin Account was ran that the Account names are properly updated
        List<Account> returnAccounts = [SELECT Id, Name FROM Account WHERE Id IN :accountIds];
        System.assertEquals(2, returnAccounts.size());
        for (Account acc : returnAccounts) {
            if (lastNameByAccountId.get('Wells') == acc.Id) {
                System.assertEquals('Wells ' + Label.DefaultAdminName, acc.Name);
            }
            if (lastNameByAccountId.get('Jones') == acc.Id) {
                System.assertEquals('Jones ' + Label.DefaultAdminName, acc.Name);
            }
        }
    }

    /*******************************************************************************************************
     * @description Tests that the refresh Administrative Account name functionality is working properly if
     * there are multiple Admin Account, and each Admin Account have more than one Contact associated
     * to it. The Admin Account should be renamed based on the Primary Contact.
     */
    @isTest
    private static void multipleContactsOnAdminAccount() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                Admin_Account_Naming_Format__c = Label.lastNameFirstNameAdminAcc
            )
        );

        List<Contact> contacts = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        contacts[0].LastName = 'Wells';
        contacts[0].FirstName = 'Tommy';
        contacts[1].LastName = 'White';
        contacts[1].FirstName = 'Betty';
        insert contacts;

        List<Contact> cons = [SELECT Id, LastName, AccountId, Account.Name FROM Contact WHERE Id IN :contacts];

        Set<Id> accountIds = new Set<Id>();
        Map<String, Id> lastNameByAccountId = new Map<String, Id>();
        for (Contact con : cons) {
            accountIds.add(con.AccountId);
            lastNameByAccountId.put(con.LastName, con.AccountId);
        }

        List<Account> accounts = [SELECT Id FROM Account WHERE Id IN :accountIds];
        accounts[0].Name = 'Tommy Wells Account';
        accounts[1].Name = 'Betty White Account';
        update accounts;

        //Verifies that the update on Account Name on the Account record persisted
        for (Account acc : accounts) {
            if (lastNameByAccountId.get('Wells') == acc.Id) {
                System.assertEquals('Tommy Wells Account', acc.Name);
            }
            if (lastNameByAccountId.get('Jones') == acc.Id) {
                System.assertEquals('Betty White Account', acc.Name);
            }
        }

        //Adding 2nd Contacts for Wells and White Account records
        List<Contact> addContacts = new List<Contact>{
            new Contact(AccountId = lastNameByAccountId.get('Wells'), LastName = 'Wells', FirstName = 'Abby'),
            new Contact(AccountId = lastNameByAccountId.get('White'), LastName = 'White', FirstName = 'Lily')
        };
        insert addContacts;

        //Verifies that the 2 Accounts now contains 2 Contacts each
        List<Contact> queryAllContacts = [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accounts];
        System.assertEquals(4, queryAllContacts.size());

        Test.startTest();
        ACCT_AdministrativeNameRefresh_BATCH batch = new ACCT_AdministrativeNameRefresh_BATCH();
        Id apexJobId = Database.executeBatch(batch, 200);
        Test.stopTest();

        //Verifies that after refresh Admin Account was ran that the Account names are properly
        //update with just the Primary Contact
        List<Account> returnAccounts = [SELECT Id, Name FROM Account WHERE Id IN :accounts];
        System.assertEquals(2, returnAccounts.size());
        for (Account acc : returnAccounts) {
            if (lastNameByAccountId.get('Wells') == acc.Id) {
                System.assertEquals('Wells (Tommy) ' + Label.DefaultAdminName, acc.Name);
            }
            if (lastNameByAccountId.get('Jones') == acc.Id) {
                System.assertEquals('White (Betty) ' + Label.DefaultAdminName, acc.Name);
            }
        }
    }
    /*********************************************************************************************************
     * @description Test Method to check if multiple Contacts are marked deceased, Administrative Account names
     * are updated properly.
     * Test Scenario: T-3904057
     */
    @isTest
    private static void AdministrativeAcctContactMarkedDeceasedBulked() {
        Hierarchy_Settings__c edaSettings = new Hierarchy_Settings__c(
            Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
            Administrative_Account_Record_Type__c = UTIL_Describe_API.getAdminAccRecTypeID(),
            Admin_Account_Naming_Format__c = Label.acctNamingOther,
            Admin_Other_Name_Setting__c = Label.lastNameFirstNameAdminAcc
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

        for (Contact con : addSecondContacts) {
            con.Deceased__c = true;
        }

        Test.startTest();
        update addSecondContacts;
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
                Label.DefaultAdminName,
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

        returnAccounts = [SELECT Id, Name FROM Account WHERE Id IN :accounts];
        for (Integer i = 0; i < returnAccounts.size(); i++) {
            String primaryContactName = 'PrimaryContact_FirstName ' + i;
            String LastName = 'PrimaryContact_LastName ' + i;

            System.assertEquals(
                LastName +
                ' (' +
                primaryContactName +
                ') ' +
                ' ' +
                Label.DefaultAdminName,
                returnAccounts[i].Name
            );
        }
    }

    /*********************************************************************************************************
     * @description Insert a new contact and the default account record type is Household
     * Make sure the Account's name is set based on account naming setting for a user in Spanish.
     * Test Scenario: T-3904055
     */
    @isTest
    private static void newContactNewAdminAccSpanish() {
        Profile systemAdministratorProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        System.runAs(UTIL_UnitTestData_TEST.createNewUserForTests(
            System.now().getTime() + '@testerson.com',
            systemAdministratorProfile.Id,
            'es'
        )) {
            Hierarchy_Settings__c edaSettings = new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                Administrative_Account_Record_Type__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                Admin_Account_Naming_Format__c = Label.acctNamingOther,
                Admin_Other_Name_Setting__c = Label.lastNameAdminAcc
            );

            UTIL_CustomSettingsFacade.getSettingsForTests(edaSettings);

            Contact con = UTIL_UnitTestData_API.getContact();
            con.Email = 's@salesfor.com';
            con.Preferred_Email__c = 'Correo electrónico laboral';

            Test.startTest();
            insert con;
            Test.stopTest();

            Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];
            System.assertEquals('Administrative', assertAccount.RecordType.Name);
            System.assertEquals('Cuenta administrativa de ' + con.LastName, assertAccount.Name);
        }
    }

    /*********************************************************************************************************
     * @description Ensure prefix/suffix is appropriately mapped to administrative account renaming logic.
     * Test Scenario: T-3904064
     */
    @isTest
    private static void shouldAppendPrefixSuffixAdministrativeAcct() {
        Set<String> objectFields = Schema.SObjectType.Contact.fields.getMap().keySet();
        Boolean ispersonNameSuffixEnabled = objectFields.contains('suffix');

        Hierarchy_Settings__c edaSettings = new Hierarchy_Settings__c(
            Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
            Administrative_Account_Record_Type__c = UTIL_Describe_API.getAdminAccRecTypeID(),
            Admin_Account_Naming_Format__c = Label.acctNamingOther,
            Admin_Other_Name_Setting__c = '{!Salutation} ' + Label.lastNameAdminAcc
        );

        if (ispersonNameSuffixEnabled) {
            edaSettings.Admin_Other_Name_Setting__c = '{!Salutation} {!LastName} {!Suffix} ' + Label.DefaultAdminName;
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
                    Label.DefaultAdminName,
                    accts[i].Name
                );
            }
        } else {
            for (integer i = 0; i < accts.size(); i++) {
                System.assertEquals('Mr.' + ' ' + 'LastNew' + i + ' ' + Label.DefaultAdminName, accts[i].Name);
            }
        }
    }

    /*********************************************************************************************************
     * @description Ensure prefix/suffix is appropriately mapped to administrative account renaming logic for
     * a non-engligh user.
     * Test Scenario: T-3904063
     */
    @isTest
    private static void shouldAppendPrefixSuffixAdministrativeAcctSpanish() {
        Profile systemAdministratorProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        System.runAs(UTIL_UnitTestData_TEST.createNewUserForTests(
            System.now().getTime() + '@testerson.com',
            systemAdministratorProfile.Id,
            'es'
        )) {
            Set<String> objectFields = Schema.SObjectType.Contact.fields.getMap().keySet();
            Boolean ispersonNameSuffixEnabled = objectFields.contains('suffix');

            Hierarchy_Settings__c edaSettings = new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                Administrative_Account_Record_Type__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                Admin_Account_Naming_Format__c = Label.acctNamingOther,
                Admin_Other_Name_Setting__c = '{!Salutation} {!LastName} ' + Label.DefaultAdminName
            );

            if (ispersonNameSuffixEnabled) {
                edaSettings.Admin_Other_Name_Setting__c =
                    '{!Salutation} {!LastName} {!Suffix} ' + Label.DefaultAdminName;
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
                        Label.DefaultAdminName,
                        accts[i].Name
                    );
                }
            } else {
                for (integer i = 0; i < accts.size(); i++) {
                    System.assertEquals('Mr.' + ' ' + 'LastNew' + i + ' ' + Label.DefaultAdminName, accts[i].Name);
                }
            }
        }
    }
}
