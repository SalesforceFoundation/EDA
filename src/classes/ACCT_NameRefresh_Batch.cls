public class ACCT_NameRefresh_Batch implements Database.Batchable<SObject>{
	
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
    
    public void finish(Database.BatchableContext bc) {}

}