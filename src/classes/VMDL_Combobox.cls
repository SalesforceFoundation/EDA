public with sharing class VMDL_Combobox {
    @AuraEnabled
    public List<VMDL_ComboboxSelectItem> fieldSelectOptions { get; private set; }

    public VMDL_Combobox(List<VMDL_ComboboxSelectItem> fieldSelectOptions){
        this.fieldSelectOptions = fieldSelectOptions;
    }
}
