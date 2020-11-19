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
* @description Model to view model mapper service for a picklist field entry
* This ideally should return only view models
* This is should be called by controllers or other view model mapper services and call services necessary to get the models it requires.
*/
public virtual with sharing class SRVC_Combobox {
    /**********************************************************************************
    * @description Instance for Singleton Pattern
    **********************************************************************************/
    @TestVisible
    private static SRVC_Combobox instance;

    /**********************************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************************/
    protected SRVC_Combobox(){}

    /**********************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of MAPR_Schema.
    **********************************************************************************/
    public static SRVC_Combobox getInstance() {
        if (instance == null) {
            instance = new SRVC_Combobox();
        }

        return instance;
    }

    /**********************************************************************************
    * @description Retrieve a list of view models representing the active entries of a specified SObject picklist field.
    * @param  objectAPIName An SObject Type API Name.
    * @param  fieldAPIName  An SObject Picklist Field API Name for the specified SObject type.
    * @return A list of VMDL_ComboboxSelectItem view models representing the active entries of a specified picklist field
    **********************************************************************************/
    public List<VMDL_ComboboxSelectItem> getViewModelForPicklistFieldActiveEntriesOnObject(String objectAPIName, String fieldApiName){
        List<VMDL_ComboboxSelectItem> picklistEntryViewModelsList = new List<VMDL_ComboboxSelectItem>();
        
        MODL_PicklistFieldDescribe picklistFieldDescribeModel = SRVC_FieldDescribe.getInstance().getPicklistFieldDescribeModelsFromApiNames(objectAPIName, new List<String>{fieldApiName})[0];

        for (Schema.PicklistEntry activePLEntry : picklistFieldDescribeModel.activePicklistEntryByApiName.values()){
            // create view model for picklist entry
            VMDL_ComboboxSelectItem picklistEntryViewModel = new VMDL_ComboboxSelectItem(
                activePLEntry.getValue(), 
                activePLEntry.getLabel(),
                activePLEntry.isActive()
            );

            picklistEntryViewModelsList.add(picklistEntryViewModel);
        }

        return picklistEntryViewModelsList;
    }

    /**********************************************************************************
    * @description Retrieves a list of FieldSelectOption view models corresponding to a list of SObject Type API names.
    * @param  apiNameList A list of SObjectType API names.
    * @return A list of VMDL_ComboboxSelectItem models corresponding to the specified Sobject types.
    **********************************************************************************/
    public List<VMDL_ComboboxSelectItem> getViewModelsFromApiNameList(List<String> apiNameList) {
        List<MODL_DescribeSObject> describeSObjectModelList = SRVC_DescribeSObject.getInstance().getSObjectDescribeModelByApiNameList(apiNameList);

        List<VMDL_ComboboxSelectItem> picklistEntryViewModelsList = new List<VMDL_ComboboxSelectItem>();

        for (MODL_DescribeSObject sObjectModel : describeSObjectModelList) {
            VMDL_ComboboxSelectItem sObjectViewModel = 
                new VMDL_ComboboxSelectItem(
                    sObjectModel.apiName,
                    sObjectModel.label
                );

            picklistEntryViewModelsList.add(sObjectViewModel);
        }

        return picklistEntryViewModelsList;
    }

    /**
    * getViewModelForComboxBoxFilteredByLookupObject description
    * @param  objectApiName       objectApiName description
    * @param  lookupObjectApiName lookupObjectApiName description
    * @return                     return description
    */ 
    public List<VMDL_ComboboxSelectItem> getViewModelForComboxBoxFilteredByLookupObject(String objectApiName, String lookupObjectApiName){
        List<VMDL_ComboboxSelectItem> filteredLookupComboboxItemViewModelsList = new List<VMDL_ComboboxSelectItem>();

        List<MODL_FieldDescribe> fieldDescribeModelsForLookupsList = 
            SRVC_FieldDescribe.getInstance().getFilteredLookupFieldDescribeModelsFromSObjectType(objectAPIName, lookupObjectApiName);
        
        for (MODL_FieldDescribe fieldDescribeModel : fieldDescribeModelsForLookupsList){
            VMDL_ComboboxSelectItem lookupFieldSelection = new VMDL_ComboboxSelectItem(
                fieldDescribeModel.apiName,
                fieldDescribeModel.label
            );

            filteredLookupComboboxItemViewModelsList.add(lookupFieldSelection);
        }

        return filteredLookupComboboxItemViewModelsList;
    }

    /**
    * getViewModelForAffiliationMappings description
    * @return   return description
    */ 
    public List<VMDL_ComboboxSelectItem> getViewModelForAffiliationMappings(){
        List<VMDL_ComboboxSelectItem> afflMappingSelectItemsViewModelsList = new List<VMDL_ComboboxSelectItem>();

        List<MODL_FieldDescribe> afflMappingFieldModelsList = 
            SRVC_FieldDescribe.getInstance().getAllFieldDescribeModelsForSObject(Affl_Mappings__c.SObjectType);

        for (MODL_FieldDescribe afflMappingFieldModel : afflMappingFieldModelsList){
            if (afflMappingFieldModel.isCustom == false){
                continue;
            }
            
            VMDL_ComboboxSelectItem afflMappingSelectionItem = new VMDL_ComboboxSelectItem(
                afflMappingFieldModel.apiName,
                afflMappingFieldModel.label
            );

            afflMappingSelectItemsViewModelsList.add(afflMappingSelectionItem);
        }
        
        return afflMappingSelectItemsViewModelsList;
    }

    /**
     * getViewModelForRecordTypes description
     * @param  sObjectType sObjectType description
     * @return             return description
     */ 
    public List<VMDL_ComboboxSelectItem> getViewModelForRecordTypes(Schema.SObjectType sObjectType){
        List<VMDL_ComboboxSelectItem> recordTypeViewModelsList = new List<VMDL_ComboboxSelectItem>();
        MODL_DescribeSObject describeSObjectModel = 
            SRVC_DescribeSObject.getInstance().getSObjectDescribeModelBySObjectType(new List<Schema.SObjectType>{sObjectType})[0];

        List<Schema.RecordTypeInfo> accountRecordTypesList = describeSObjectModel.sObjectDescribeResult.getRecordTypeInfos();

        for (Schema.RecordTypeInfo rt : accountRecordTypesList){
            VMDL_ComboboxSelectItem selectItem = new VMDL_ComboboxSelectItem(
                rt.getDeveloperName(),
                rt.getName(),
                rt.isActive()
            );

            recordTypeViewModelsList.add(selectItem);
        }

        
        return recordTypeViewModelsList;
    }
}