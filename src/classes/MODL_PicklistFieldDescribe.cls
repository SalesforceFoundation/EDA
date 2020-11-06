/**
 * Model for the picklist entries (values) of a specified picklist field.
 */
public with sharing class MODL_PicklistFieldDescribe extends MODL_FieldDescribe {
    public Map<String, String> picklistEntryLabelByApiName { get; private set; }
    public Map<String,Schema.PicklistEntry> picklistEntryByApiName { get; private set; }
    public Map<String, Schema.PicklistEntry> activePicklistEntryByApiName { get; private set; }

    public MODL_PicklistFieldDescribe(Schema.SObjectField sObjectField){
        super(sObjectField);
        List<Schema.PicklistEntry> pickListEntriesList = sObjectField.getDescribe().getPicklistValues();
        this.populatePicklistEntryMaps(pickListEntriesList);
    }

    /**********************************************************************************
    * @description Assigns a picklistFieldDescribe model to a FieldDescribe model.
    * @param  picklistFieldDescribeModel The picklistFieldDescribe model to assign.
    **********************************************************************************/ 
    public void addPicklistFieldDescribeModelToFieldDescribeModel(MODL_PicklistFieldDescribe picklistFieldDescribeModel){
       super.populatePicklistFieldDescribeModel(picklistFieldDescribeModel);
    }

    /**********************************************************************************
    * @description Populates the picklist entry maps for a FieldDescribe model.
    * @param  pickListEntriesList A list of picklist entries to be mapped.
    **********************************************************************************/ 
    private void populatePicklistEntryMaps(List<Schema.PicklistEntry> pickListEntriesList){
        this.picklistEntryLabelByApiName = new Map<String, String>();
        this.picklistEntryByApiName = new Map<String,Schema.PicklistEntry>();
        this.activePicklistEntryByApiName = new Map<String,Schema.PicklistEntry>();

        for (Schema.PicklistEntry pickListEntry : pickListEntriesList){
            this.addPicklistEntry(picklistEntry);
        }
    }

    /**********************************************************************************
    * @description Separates active picklist entries from inactive entries.
    * @param  picklistEntry The schema for a picklist entry.
    **********************************************************************************/
    private void addPicklistEntry(Schema.PicklistEntry picklistEntry){
        picklistEntryLabelByApiName.put(picklistEntry.getValue(), picklistEntry.getLabel());
        picklistEntryByApiName.put(pickListEntry.getValue(), picklistEntry);

        if (picklistEntry.isActive()){
            activePicklistEntryByApiName.put(pickListEntry.getValue(), picklistEntry);
        }
    }
}
