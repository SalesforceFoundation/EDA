/**
 * @File Name          : ACCT_AdministrativeNameRefresh_BATCH.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/25/2019, 11:30:20 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/25/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class ACCT_AdministrativeNameRefresh_BATCH implements Database.Batchable<SObject>{

    public Database.Querylocator start(Database.BatchableContext bc) {
        System.debug('ACCT_AdminBATCH Method -->');
        Id adminRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Administrative').getRecordTypeId();
        System.debug('ACCT_AdminBATCH RecordType -->' + adminRecordTypeId);
        String query = 'SELECT Id, RecordTypeId ' +
            		    'FROM Account ' +
            		    'WHERE RecordTypeId = :adminRecordTypeId' ;
        System.debug('ACCT_AdminBATCH Method -->' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account> returnAccounts){
        System.debug('ACCT_AdminBATCH Main -->' + returnAccounts);
        Set<Id> dedupedAccountIds = new Set<Id>();
      	List<Account> accountsToRename = new List<Account>();
        if (returnAccounts.size() > 0) {
            System.debug('ACCT_AdminBATCH Main Method -->' + returnAccounts);

            for (Account a : returnAccounts) {
                dedupedAccountIds.add(a.Id);
                System.debug('ACCT_AdminBATCH Main dedupedAccountIds -->' + dedupedAccountIds);
            }

            List<Contact> contactsToProcess = [SELECT Id, FirstName, LastName, Salutation, AccountId
                                              FROM Contact WHERE AccountId = :dedupedAccountIds];
            if (contactsToProcess.size() > 0) {
                System.debug('ACCT_AdminBATCH contactsToProcess -->' + contactsToProcess);
                for (Account a : returnAccounts) {
                    a.Name = UTIL_ACCT_Naming.updateName(contactsToProcess);
                    System.debug('ACCT_AdminBATCH accCheck -->' + a.Name);
                    accountsToRename.add(a);
                    System.debug('ACCT_AdminBATCH accList -->' + accountsToRename);
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