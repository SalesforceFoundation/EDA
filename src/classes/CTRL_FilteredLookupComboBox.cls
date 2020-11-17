public with sharing class CTRL_FilteredLookupComboBox {
    
    @AuraEnabled(cacheable=true)
    public static VMDL_Combobox getLookupFields(String objectApiName, String lookupObjectApiName){
        return new VMDL_Combobox(SRVC_Combobox.getInstance().getViewModelForComboxBoxFilteredByLookupObject(objectApiName, lookupObjectApiName));
    }

    @AuraEnabled(cacheable=true)
    public static VMDL_Combobox getAffiliationMappingFields(){
        return new VMDL_Combobox(SRVC_Combobox.getInstance().getViewModelForAffiliationMappings());
    }
}
