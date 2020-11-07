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
* @description Model to view model mapper service
* This ideally should return only view models
* This is should be called by controllers or other view model mapper services and call services necessary to get the models it requires.
*/
public virtual with sharing class SRVC_FieldSelectOption {
    /**********************************************************************************
    * @description Instance for Singleton Pattern
    **********************************************************************************/
    @TestVisible
    private static SRVC_FieldSelectOption instance;

    /**********************************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************************/
    protected SRVC_FieldSelectOption(){}

    /**********************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of MAPR_Schema.
    **********************************************************************************/
    public static SRVC_FieldSelectOption getInstance() {
        if (instance == null) {
            instance = new SRVC_FieldSelectOption();
        }

        return instance;
    }

    /**********************************************************************************
    * @description Retrieve a list of view models representing the active entries of a specified SObject picklist field.
    * @param  objectAPIName An SObject Type API Name.
    * @param  fieldAPIName  An SObject Picklist Field API Name for the specified SObject type.
    * @return A list of VMDL_FieldSelectOption view models representing the active entries of a specified picklist field
    **********************************************************************************/
    public List<VMDL_FieldSelectOption> getViewModelForPicklistFieldActiveEntriesOnObject(String objectAPIName, String fieldApiName){
        List<VMDL_FieldSelectOption> sObjectViewModelList = new List<VMDL_FieldSelectOption>();
        
        MODL_FieldDescribe fieldDescribeModel = SRVC_Schema.getInstance().getFieldDescribeModelsForSObjectByFieldApiNamesList(objectAPIName, new List<String>{fieldApiName})[0];

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

    /**********************************************************************************
    * @description Retrieves a list of FieldSelectOption view models corresponding to a list of SObject Type API names.
    * @param  apiNameList A list of SObjectType API names.
    * @return A list of VMDL_FieldSelectOption models corresponding to the specified Sobject types.
    **********************************************************************************/
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