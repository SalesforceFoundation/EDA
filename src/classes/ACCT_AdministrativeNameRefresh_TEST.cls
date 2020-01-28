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
public class ACCT_AdministrativeNameRefresh_TEST {
	/*******************************************************************************************************
    * @description test that the refresh administrative account name functionality is working properly.
    */
    @isTest
    private static void refreshAdministrativeAccountNames() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                										Admin_Account_Naming_Format__c = '{!LastName} Administrative Account'
                                                        ));

        List<Contact> contacts = UTIL_UnitTestData_API.getMultipleTestContacts(2);
        contacts[0].LastName = 'Wells';
        contacts[0].FirstName = 'Tommy';
        contacts[1].LastName = 'Jones';
        contacts[1].FirstName = 'Betty';
        insert contacts;

        Set<Id> accountIds = new Set<Id>();
        for (Contact c : [SELECT Id, AccountId FROM Contact WHERE Id IN :contacts]) {
            accountIds.add(c.AccountId);
        }

        List<Id> dedupedAccountIds = new List<Id>();
        if (accountIds.size() > 0) {
            dedupedAccountIds.addAll(accountIds);
        }
        List<Account> queryAccounts = [SELECT Id, Name, RecordTypeId, RecordType.Name
                                      FROM Account
                                      WHERE Id IN :dedupedAccountIds];
        queryAccounts[0].Name = 'Tommy Wells Account';
        queryAccounts[1].Name = 'Betty Jones Account';
        update queryAccounts;

        System.assertEquals(contacts[0].FirstName + ' ' + contacts[0].LastName + ' ' + 'Account', queryAccounts[0].Name);
        System.assertEquals(contacts[1].FirstName + ' ' + contacts[1].LastName + ' ' + 'Account', queryAccounts[1].Name);

        Test.startTest();
        ACCT_AdministrativeNameRefresh_BATCH batch = new ACCT_AdministrativeNameRefresh_BATCH();
        Id apexJobId = Database.executeBatch(batch, 200);
        Test.stopTest();

        List<Account> returnAccounts = [SELECT Id, Name
                                       FROM Account
                                       WHERE Id IN :dedupedAccountIds];
        System.assertEquals(contacts[0].LastName + ' ' + 'Administrative Account', returnAccounts[0].Name);
        System.assertEquals(contacts[1].LastName + ' ' + 'Administrative Account', returnAccounts[1].Name);

    }
}