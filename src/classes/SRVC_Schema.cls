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
* @description Schema service that calls the appropriate mapper to return models upstream.
* This should ideally never return anything but abstracted data in the form of models.
* This is called by either another service to orchestrate functionality or by a service that maps models to view models.
*/
public virtual with sharing class SRVC_Schema {

    /**********************************************************************************
    * @description Instance for Singleton Pattern
    **********************************************************************************/
    @TestVisible
    private static SRVC_Schema instance;

    /**********************************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************************/
    protected SRVC_Schema() {}

    /**********************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of MAPR_Schema.
    **********************************************************************************/
    public static SRVC_Schema getInstance() {
        if (instance == null) {
            instance = new SRVC_Schema();
        }

        return instance;
    }

    /**********************************************************************************
    * @description Retrieve a list of DescribeSObject models by SObject API name.
    * @param  apiNameList A list of SObject API names.
    * @return A list of MODL_DescribeSObject models mapped by SObject API name, or label names if API name not found.
    **********************************************************************************/
    public List<MODL_DescribeSObject> getSObjectDescribeModelByApiNameList(List<String> apiNameList) {
        List<MODL_DescribeSObject> sObjectModelList = new List<MODL_DescribeSObject>();

        for(String apiName : apiNameList) {
            MODL_DescribeSObject sObjectModel = this.locateSchemaMapper().getSObjectDescribeModelByApiName(apiName);

            if (sObjectModel == null){
                // model not found by apiName, search by labelName
                String labelName = this.locateSchemaMapper().getGlobalDescribeModel().sObjectLabelByApiName.get(apiName);
                sObjectModel = this.locateSchemaMapper().getSObjectDescribeModelByLabelName(labelName);
            } 

            if (sObjectModel == null){
                continue;
            }

            sObjectModelList.add(sObjectModel);
        }

        return sObjectModelList;
    }

    /**********************************************************************************
    * @description Retrieve a list of DesribeSObject models by SObject label name.
    * @param  labelNameList A list of SObject label names.
    * @return A list of MODL_DescribeSObject models mapped by SObject lable names.
    **********************************************************************************/ 
    public List<MODL_DescribeSObject> getSObjectDescribeModelByLabelNameList(List<String> labelNameList) {
        List<MODL_DescribeSObject> sObjectModelList = new List<MODL_DescribeSObject>();

        for(String labelName : labelNameList) {
            MODL_DescribeSObject sObjectModel = this.locateSchemaMapper().getSObjectDescribeModelByLabelName(labelName);

            if (sObjectModel == null){
                continue;
            }

            sObjectModelList.add(sObjectModel);
        }

        return sObjectModelList;
    }

    /**********************************************************************************
    * @description Retrieve a list of FieldDescribe models for specified SObject fields.
    * @param  sOjbectApiName The API name for the related SObject.
    * @param  sObjectFieldApiNamesList A List of API names for SObject fields to model.
    * @return A list of MODL_FieldDescribe modelling the specified SObject fields.
    **********************************************************************************/
    public List<MODL_FieldDescribe> getFieldDescribeModelsForSObjectByFieldApiNamesList(String sOjbectApiName, List<String> sObjectFieldApiNamesList){
        
        List<MODL_FieldDescribe> fieldDescribeModelsList = new List<MODL_FieldDescribe>();

        for (String fieldApi : sObjectFieldApiNamesList){
            MODL_FieldDescribe fieldDescribeModel = this.locateSchemaMapper().getSObjectFieldDescribeModelByApiNames(sOjbectApiName, fieldApi);
            fieldDescribeModelsList.add(fieldDescribeModel);
        }
        
        return fieldDescribeModelsList;
    }

    /**********************************************************************************
    * @description Retrieve a list of PicklistFieldDescribe models corresponding to a list of SObject
    * Field API names for a specified SObject API Name.
    * @param  sOjbectApiName An SObject Type API name.
    * @param  sObjectFieldApiNamesList A list of SObject field API names for the specified SObject.
    * @return a list of MODL_PicklistFieldDescribe models corresponding to the SObject field
    * API names for the specified SObject type.
    **********************************************************************************/
    public List<MODL_PicklistFieldDescribe> getPicklistFieldDescribeModelsByApiNamesList(String sOjbectApiName, List<String> sObjectFieldApiNamesList){
        List<MODL_PicklistFieldDescribe> picklistFieldDescribeModelsList = new List<MODL_PicklistFieldDescribe>();

        for (String fieldApi : sObjectFieldApiNamesList){
            MODL_FieldDescribe fieldDescribeModel = this.locateSchemaMapper().getSObjectFieldDescribeModelByApiNames(sOjbectApiName, fieldApi);

            if (fieldDescribeModel.pickListFieldDescribeModel == null){
                continue;
            }

            picklistFieldDescribeModelsList.add(fieldDescribeModel.pickListFieldDescribeModel);
        }
        
        return picklistFieldDescribeModelsList;
    }

    /**********************************************************************************
    * @description Locates and returns an instance of the schema mapper
    **********************************************************************************/
    private MAPR_Schema locateSchemaMapper() {
        return MAPR_Schema.getInstance();
    }
}