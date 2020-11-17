public with sharing class CTRL_FilteredLookupComboBox {
    
    @AuraEnabled(cacheable=true)
    public static VMDL_ComboBox getAccountLookupFields(String objectApiName, String lookupObjectApiName){
        return new VMDL_Combobox(SRVC_Combobox.getInstance().getViewModelForComboxBoxFilteredByLookupObject(objectApiName, lookupObjectApiName));
    }
}
