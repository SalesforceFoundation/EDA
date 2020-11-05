/**
* @description Model to view model mapper service
* This ideally should return only view models
* This is should be called by controllers or other view model mapper services and call services necessary to get the models it requires.
*/
public virtual with sharing class SRVC_FieldSelectOption {
    /**
    * @description Instance for Singleton Pattern
    */
    @TestVisible
    private static SRVC_FieldSelectOption instance;

    /**
    * @description Empty constructor is not public for Singleton Pattern
    */
    protected SRVC_FieldSelectOption(){}

    /**
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of MAPR_Schema.
    */
    public static SRVC_FieldSelectOption getInstance() {
        if (instance == null) {
            instance = new SRVC_FieldSelectOption();
        }

        return instance;
    }

    /**
     * @description Generate a list of models representing the metadata for each value of a specified picklist field.
     * @param  objectAPIName A string representing the API name of the Object to describe
     * @param  fieldAPIName  A string representing the API name of a picklist Field on the object to describe
     * @return A list of FieldSelectOption models representing each value of a specified picklist field
     */
    public List<VMDL_FieldSelectOption> getViewModelForPicklistFieldActiveEntriesOnObject(String objectAPIName, String fieldApiName){
        List<VMDL_FieldSelectOption> sObjectViewModelList = new List<VMDL_FieldSelectOption>();
        
        MODL_FieldDescribe fieldDescribeModel = SRVC_Schema.getInstance().getFieldDescribeModelsForSObjectByFieldApiNamesList(objectAPIName, new List<String>{fieldApiName})[0];
        //fieldDescribeModel.addPicklistFieldDescribeModel(fieldDescribeModel.describeFieldResult.getSObjectField());

        for (Schema.PicklistEntry activePLEntry : fieldDescribeModel.pickListFieldDescribeModel.activePicklistEntryByApiName.values()){
            // create view model for picklist entry
            VMDL_FieldSelectOption fieldOptionViewMdl = new VMDL_FieldSelectOption(
                activePLEntry.getValue(), 
                activePLEntry.getLabel(),
                activePLEntry.isActive()
            );

            sObjectViewModelList.add(fieldOptionViewMdl);
        }

        return sObjectViewModelList;
    }

    /**
    * @description Method to get view models specified by controller
    */
    public List<VMDL_FieldSelectOption> getViewModelsFromApiNameList(List<String> apiNameList) {
        List<MODL_DescribeSObject> sObjectModelList = SRVC_Schema.getInstance().getSObjectDescribeModelByApiNameList(apiNameList);

        List<VMDL_FieldSelectOption> sObjectViewModelList = new List<VMDL_FieldSelectOption>();

        for (MODL_DescribeSObject sObjectModel : sObjectModelList) {
            VMDL_FieldSelectOption sObjectViewModel = 
                new VMDL_FieldSelectOption(
                    sObjectModel.apiName,
                    sObjectModel.label
                );

            sObjectViewModelList.add(sObjectViewModel);
        }

        return sObjectViewModelList;
    }

    /**
    * @description View model for field select options
    */
    public with sharing class VMDL_FieldSelectOption {
        public VMDL_FieldSelectOption(){}

        /**
        * @description We could incorporate an invalid version of this model that overrides it.
        * In that case we would use the value and label as the 'bad' settings option.
        */
        public VMDL_FieldSelectOption(String value, String label) {
            this.value = value;
            this.label = label;
            this.isValid = true;
        }

        public VMDL_FieldSelectOption(String value, String label, Boolean isValid) {
            this.value = value;
            this.label = label;
            this.isValid = isValid;
        }

        /**
        * @description Aura enabled property for passing down to back-end
        */
        @AuraEnabled
        public String value {
            get; private set;
        }

        /**
        * @description Aura enabled property for displaying value in localized format
        */
        @AuraEnabled
        public String label {
            get; private set;
        }

        /**
        * @description Aura enabled property for displaying value in localized format
        */
        @AuraEnabled
        public Boolean isValid {
            get; private set;
        }
    }
}