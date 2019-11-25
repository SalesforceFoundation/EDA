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
* @description Batch class to refresh Household Account names.
*/
public class ACCT_HouseholdNameRefresh_BATCH implements Database.Batchable<SObject>{

    public Database.Querylocator start(Database.BatchableContext bc) {
        System.debug('ACCT_BATCH Method -->');
        Id hhRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        System.debug('ACCT_BATCH RecordType -->' + hhRecordTypeId);
        String query = 'SELECT Id ' +
                        'FROM Account ' +
            	        'WHERE RecordTypeId = :hhRecordTypeId' ;
        System.debug('ACCT_BATCH Method -->' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account> returnAccounts){
        Set<Id> dedupedAccountIds = new Set<Id>();

        System.debug('ACCT_BATCH Main Method -->' + returnAccounts);

        if (returnAccounts.size() > 0) {
            for (Account a : returnAccounts) {
                dedupedAccountIds.add(a.Id);
                System.debug('ACCT_BATCH Main dedupedAccountIds -->' + dedupedAccountIds);
            }
        }

        if (dedupedAccountIds.size() > 0) {
            System.debug('ACCT_BATCH Main B4UpdateNmae -->' + dedupedAccountIds);
            UTIL_ACCT_Naming.updateHHAccountsName(dedupedAccountIds);
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
            mail.setSubject('Household Name Refresh Status : ' + a.Status);
            mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
           ' batches with '+ a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}