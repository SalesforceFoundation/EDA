public with sharing class CTRL_AffiliationMappings {
    @AuraEnabled(cacheable=true)
    public static VMDL_Combobox getAccountRecordTypes(){
        return new VMDL_Combobox(SRVC_Combobox.getInstance().getViewModelForRecordTypes(Account.SObjectType));
    }
}
