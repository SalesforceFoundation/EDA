/**
 * Model for the picklist entries (values) of a specified picklist field.
 */
public with sharing class MODL_PicklistFieldDescribe extends MODL_FieldDescribe {
    public Map<String, String> picklistEntryLabelByApiName { get; private set; }
    public Map<String,Schema.PicklistEntry> picklistEntryByApiName { get; private set; }
    public Map<String, Schema.PicklistEntry> activePicklistEntryByApiName { get; private set; }

    public MODL_PicklistFieldDescribe(){
        picklistEntryLabelByApiName = new Map<String, String>();
        picklistEntryByApiName = new Map<String,Schema.PicklistEntry>();
        activePicklistEntryByApiName = new Map<String,Schema.PicklistEntry>();
    }

    /**
    * @description Populates the picklist entry maps with entries for the current picklist field.
    * @param  picklistEntry The schema for a picklist entry.
    */
    public void addPicklistEntry(Schema.PicklistEntry picklistEntry){
        picklistEntryLabelByApiName.put(picklistEntry.getValue(), picklistEntry.getLabel());
        picklistEntryByApiName.put(pickListEntry.getValue(), picklistEntry);

        if (picklistEntry.isActive()){
            activePicklistEntryByApiName.put(pickListEntry.getValue(), picklistEntry);
        }
    }
}
