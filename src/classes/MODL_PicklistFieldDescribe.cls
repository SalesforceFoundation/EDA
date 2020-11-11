/*
    Copyright (c) 2020, Salesforce.org
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
 
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2020
* @group Schema
* @group-content ../../ApexDocContent/Schema.htm
* @description Model to represent the picklist entries of a picklist field.
*/
public with sharing class MODL_PicklistFieldDescribe extends MODL_FieldDescribe {
    public Map<String, String> picklistEntryLabelByApiName { get; private set; }
    public Map<String,Schema.PicklistEntry> picklistEntryByApiName { get; private set; }
    public Map<String, Schema.PicklistEntry> activePicklistEntryByApiName { get; private set; }

    public MODL_PicklistFieldDescribe(Schema.SObjectField sObjectField){
        super(sObjectField);
        List<Schema.PicklistEntry> pickListEntriesList = this.describeFieldResult.getPicklistValues();
        this.populatePicklistEntryMaps(pickListEntriesList);
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
