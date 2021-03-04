public without sharing class STG_UnmanagedInstall {

    //Include Affiliation mappings for test account record types
    public static void mapAccountRecordTypesForAffiliationTesting(){
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'An Active Record Type', Account_Record_Type__c = 'An_Active_Record_Type', Primary_Affl_Field__c = 'Primary_Active_Account__c'));
        mappings.add(new Affl_Mappings__c(Name = 'An Inactive Record Type', Account_Record_Type__c = 'An_Inactive_Record_Type', Primary_Affl_Field__c = 'Primary_Inactive_Account__c'));
        insert mappings;
    }
}