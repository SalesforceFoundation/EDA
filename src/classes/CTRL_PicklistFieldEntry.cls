/**
* @description Top-level controller class for LWC component
*/
public with sharing class CTRL_PicklistFieldEntry {

    /**
    * @description Aura enabled entry point that calls appropriate services to pass view models to LWC component
    */
    // @AuraEnabled(cacheable=true)
    // public static VMDL_Combobox getFieldSelectOptions(List<String> apiNameList) {
    //     return new VMDL_Combobox(SRVC_PicklistFieldEntry.getInstance().getViewModelsFromApiNameList(apiNameList));
    // }

    @AuraEnabled(cacheable=true)
    public static VMDL_Combobox getActivePickListOptions(String objectAPIName, String fieldAPIName){
        //TODO: error if field/object combo aren't valid pair?
        return new VMDL_Combobox(SRVC_PicklistFieldEntry.getInstance().getViewModelForPicklistFieldActiveEntriesOnObject(objectAPIName, fieldAPIName));
    }

    /**
    * @description Top-level view model for field select options
    */
    public with sharing class VMDL_Combobox {
        @AuraEnabled
        public List<SRVC_PicklistFieldEntry.VMDL_PicklistEntry> fieldSelectOptions { get; private set; }

        public VMDL_Combobox(List<SRVC_PicklistFieldEntry.VMDL_PicklistEntry> fieldSelectOptions){
            this.fieldSelectOptions = fieldSelectOptions;
        }
    }
}