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

        Id adminRecordTypeId = Util_Describe.getCustomAdminAccRecTypeId();
        String query = 'SELECT Id, RecordTypeId, Primary_Contact__c ' +
            		    'FROM Account ' +
            		    'WHERE RecordTypeId = :adminRecordTypeId' ;
        return Database.getQueryLocator(String.escapeSingleQuotes(query));
    }

    public void execute(Database.BatchableContext bc, List<Account> returnAccounts){

        List<Account> accountsToRename = new List<Account>();
        List<Contact> contactsToProcess = new List<Contact>();
        Set<Id> primaryCons = new Set<Id>(); 

        if (returnAccounts.size() > 0) {
            for (Account acc : returnAccounts) {
                if (acc.Primary_Contact__c != null) {
                    primaryCons.add(acc.Primary_Contact__c); 
                }
            }

            if (primaryCons.size() > 0) {
                contactsToProcess = [SELECT Id, AccountId, Account.RecordTypeId, FirstName, LastName, Salutation 
                                     FROM Contact
                                     WHERE Id IN :primaryCons]; 
            }
        }

        if (contactsToProcess.size() > 0) {
            accountsToRename = UTIL_ACCT_Naming.updateAdminAccountsName(contactsToProcess);
        }

        if (accountsToRename.size() > 0) {
            Database.update(accountsToRename);
        }
    }

    public void finish(Database.BatchableContext bc) {
        AsyncApexJob asyncJob = [SELECT Id, Status, JobType, NumberOfErrors,
                          JobItemsProcessed, TotalJobItems, CompletedDate,
                          ExtendedStatus, CreatedById, CreatedBy.Email
        				  FROM AsyncApexJob
                          WHERE Id =:bc.getJobId()];

       	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<String> {asyncJob.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Administrative Name Refresh Status : ' + asyncJob.Status);
            mail.setPlainTextBody('The batch Apex job processed ' + asyncJob.TotalJobItems +
           ' batches with '+ asyncJob.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}