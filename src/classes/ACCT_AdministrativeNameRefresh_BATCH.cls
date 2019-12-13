/*
    Copyright (c) 2019, Salesforce.org
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
* @date 2019
* @group Account
* @group-content ../../ApexDocContent/Account.htm
* @description Batch class to refresh Administrative Account names.
*/
public class ACCT_AdministrativeNameRefresh_BATCH implements Database.Batchable<SObject>{

    public Database.Querylocator start(Database.BatchableContext bc) {
        System.debug('ACCT_AdminBATCH Method -->');
        Id adminRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Administrative').getRecordTypeId();
        System.debug('ACCT_AdminBATCH RecordType -->' + adminRecordTypeId);
        String query = 'SELECT Id, RecordTypeId, Primary_Contact__c' +
            		    'FROM Account ' +
            		    'WHERE RecordTypeId = :adminRecordTypeId' ;
        System.debug('ACCT_AdminBATCH Method -->' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account> returnAccounts){
        System.debug('ACCT_AdminBATCH Main -->' + returnAccounts);
        Set<Id> primaryConId = new Set<Id>();
      	List<Account> accountsToRename = new List<Account>();
        List<Contact> contactsToProcess = new List<Contact>();

        if (returnAccounts.size() > 0) {
            System.debug('ACCT_AdminBATCH Main Method -->' + returnAccounts);

            for (Account a : returnAccounts) {
                if (a.Primary_Contact__c != NULL) {
                    primaryConId.add(a.Primary_Contact__c);
                }
            }

            if (primaryConId.size() > 0) {
                contactsToProcess = [SELECT Id, FirstName, LastName,
                                     Salutation, AccountId
                                     FROM Contact
                                     WHERE Id IN :primaryConId];
                for (Account a : returnAccounts) {
                	a.Name = UTIL_ACCT_Naming.updateName(contactsToProcess);
                    accountsToRename.add(a);
                }
            }

            if (accountsToRename.size() > 0) {
                System.debug('ACCT_AdminBATCH accListBatchUpdate -->' + accountsToRename);
                Database.update(accountsToRename);
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status, JobType, NumberOfErrors,
                          JobItemsProcessed, TotalJobItems, CompletedDate,
                          ExtendedStatus, CreatedById, CreatedBy.Email
        				  FROM AsyncApexJob
                          WHERE Id =:bc.getJobId()];

       	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<String> {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Administrative Name Refresh Status : ' + a.Status);
            mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
           ' batches with '+ a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}