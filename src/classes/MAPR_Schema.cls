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
* @description A mapper that retrieves schema information and creates models
* This should only be called by a service.
* This should only return models.
* Since the data is schema-based, we make the assumption that it does not change and cache it
* Note that if this dealt with data, it could be used to perform DML operations based on the models, converting back from the model to underlying data.
*/
public virtual with sharing class MAPR_Schema {

    /**********************************************************************************
    * @description Lazy loading cache for global describes.
    **********************************************************************************/
    private MODL_GlobalDescribe globalDescribeModel {
        get {
            if(this.globalDescribeModel != null) {
                return this.globalDescribeModel;
            }

            this.globalDescribeModel = new MODL_GlobalDescribe(Schema.getGlobalDescribe());
            return this.globalDescribeModel;
        }
        set;
    }

    /**********************************************************************************
    * @description Instance for Singleton Pattern.
    **********************************************************************************/
    @TestVisible
    private static MAPR_Schema instance;

    /**********************************************************************************
    * @description Empty constructor is not public for Singleton Pattern.
    **********************************************************************************/
    protected MAPR_Schema() {}

    /**********************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of MAPR_Schema.
    **********************************************************************************/
    public static MAPR_Schema getInstance() {
        if (instance == null) {
            instance = new MAPR_Schema();
        }

        return instance;
    }

    /**********************************************************************************
    * @description Retrive a cached GlobalDescribe model.
    * @return A cached MODL_GlobalDescribe representing the Global Describe schema.
    **********************************************************************************/
    public MODL_GlobalDescribe getGlobalDescribeModel() {
        return this.globalDescribeModel;
    }

    /**********************************************************************************
    * @description Retrieve a cached DescribeSObject model for a specified SObject API name.
    * @param  apiName The API name of an SObject.
    * @return A cached MODL_DescribeObject model representing the schema of the 
    * specified SObject API name.
    **********************************************************************************/
    public MODL_DescribeSObject getSObjectDescribeModelByApiName(String apiName) {
        Schema.SObjectType sObjectType = this.getSObjectTypeByApiName(apiName);

        MODL_DescribeSObject describeSObjectModel =
            this.globalDescribeModel.sObjectModelBySObjectType.get(sObjectType);

        if(describeSObjectModel != null) {
            return describeSObjectModel;
        }

        return this.getAndCacheSObjectDescribeModels(new List<Schema.SObjectType>{sObjectType})[0];
    }

    /**********************************************************************************
    * @description Retrieve a cached DescribeSObject model for a specified SObject label name.
    * @param  labelName The label name of an SObject.
    * @return A MODL_DescribeObject model representing the schema of the specified SObject label name.
    **********************************************************************************/ 
    public MODL_DescribeSObject getSObjectDescribeModelByLabelName(String labelName) {
        Schema.SObjectType sObjectType = this.getSObjectTypeByLabel(labelName);

        MODL_DescribeSObject describeSObjectModel =
            this.globalDescribeModel.sObjectModelBySObjectType.get(sObjectType);

        if(describeSObjectModel != null) {
            return describeSObjectModel;
        }

        return this.getAndCacheSObjectDescribeModels(new List<Schema.SObjectType>{sObjectType})[0];
    }

    /**********************************************************************************
    * @description Retrieve a cached FieldDescribe model for a specified SObject field API name.
    * @param  objectApiName The API name of an SObject.
    * @param  fieldApiName  The API name of a field on the specified SObject.
    * @return A MODL_FieldDescribe representing the schema of the specified SObject field API name.
    *         If the field is a picklist type, the associated MODL_PicklistFieldDescribe is also
    *         generated.
    **********************************************************************************/ 
    public MODL_FieldDescribe getSObjectFieldDescribeModelByApiNames(String objectApiName, String fieldApiName){

        Schema.SObjectType sObjectType =  this.getSObjectTypeByApiName(objectApiName);
        Schema.DescribeSObjectResult sObjectDescribe = sObjectType.getDescribe();
        Schema.SObjectField sObjectField = sObjectDescribe.fields.getMap().get(fieldApiName);

        if (sObjectField.getDescribe().getType() == Schema.DisplayType.PICKLIST){
            return (MODL_FieldDescribe)this.getCachedPicklistFieldDescribeModel(sObjectType, sObjectField);
        }
        
        return this.getCachedFieldDescribeModel(sObjectType, sObjectField);
    }

    /**********************************************************************************
    * @description Retrieve a cached FieldDescribe model for a specified SObject picklist field API name.
    * @param  objectApiName The API name of an SObject.
    * @param  fieldApiName  The API name of a field on the specified SObject of type Picklist.
    * @return A MODL_PicklistFieldDescribe for the specified picklist SObject field API name.
    **********************************************************************************/ 
    private MODL_PicklistFieldDescribe getPicklistFieldDescribeModelByApiNames(String objectApiName, String fieldApiName){
        Schema.SObjectType sObjectType =  this.getSObjectTypeByApiName(objectApiName);
        Schema.DescribeSObjectResult sObjectDescribe = sObjectType.getDescribe();
        Schema.SObjectField sObjectField = sObjectDescribe.fields.getMap().get(fieldApiName);

        return this.getAndCacheFieldDescribeModel(sObjectType, sObjectField).pickListFieldDescribeModel;
    }

    /**********************************************************************************
    * @description Retrieve a list of DescribeSObject models corresponding to a specified list of SObject types.
    * @param  sObjectTypesList A list of SObject types
    * @return A list of MODL_DescribeSObject models corresponding to the specified SObject types.
    **********************************************************************************/
    private List<MODL_DescribeSObject> getDescribeSObjectModelBySObjectType(List<Schema.SObjectType> sObjectTypesList) {
        List<MODL_DescribeSObject> describeSObjectModelsList = new List<MODL_DescribeSObject>();

        for (Schema.SObjectType sObjectType : sObjectTypesList){
            describeSObjectModelsList.add(new MODL_DescribeSObject(sObjectType.getDescribe()));
        }

        return describeSObjectModelsList;
    }

    /**********************************************************************************
    * @description
    * @param  sObjectField sObjectField description
    * @return              return description
    **********************************************************************************/ 
    // private MODL_FieldDescribe getNewFieldDescribeModelBySObjectField(Schema.SObjectField sObjectField){
    //     if (sObjectField.getDescribe().getType() == Schema.DisplayType.PICKLIST){
    //         return this.getNewPicklistFieldDescribeModel(sObjectField);
    //     }

    //     return new MODL_FieldDescribe(sObjectField);
    // }

    /**********************************************************************************
    * @description Retrieve a list of FieldDescribe models corresponding to a specified list of SObject fields.
    * @param  sObjectFieldsList A list of SObject fields.
    * @return A list of MODL_FieldDescribe models corresponding to the specified SObject fields.
    **********************************************************************************/
    private List<MODL_FieldDescribe> getNewFieldDescribeModelBySObjectFields(List<Schema.SObjectField> sObjectFieldsList){
        List<MODL_FieldDescribe> fieldDescribeModelsList = new List<MODL_FieldDescribe>();

        for (Schema.SObjectField sObjectField : sObjectFieldsList){
            if (sObjectField.getDescribe().getType() == Schema.DisplayType.PICKLIST){
                fieldDescribeModelsList.add(this.getNewPicklistFieldDescribeModels(new List<Schema.SObjectField>{sObjectField})[0]);
            } else {
                fieldDescribeModelsList.add(new MODL_FieldDescribe(sObjectField));
            }
        }
        
        return fieldDescribeModelsList;
    }

    /**********************************************************************************
    * @description Helper method to retrieve an SObjectType token by API name.
    * @param  apiName The API name of an SObjectType.
    * @return The SObjectType token corresponding to the specified API name.
    **********************************************************************************/ 
    private Schema.SObjectType getSObjectTypeByApiName(String apiName) {
        Schema.SObjectType sObjectType =
            this.globalDescribeModel.sObjectTypeByApiName.get(apiName);

        if(sObjectType != null) {
            return sObjectType;
        }

        //TODO: Labelify
        throw new InvalidParameterValueException('Object Name',apiName);
    }

    /**********************************************************************************
    * @description Helper method to retrieve an SObjectType token by Label name.
    * @param  labelName The label name of an SObjectType.
    * @return The SObjectType token corresponding to the specified label name.
    **********************************************************************************/ 
    private Schema.SObjectType getSObjectTypeByLabel(String labelName) {
        Schema.SObjectType sObjectType =
            this.globalDescribeModel.sObjectTypeByLabelName.get(labelName);

        if(sObjectType != null) {
            return sObjectType;
        }

        //TODO: Labelify
        throw new InvalidParameterValueException('Object Name', labelName);
    }

    /**********************************************************************************
    * @description Helper method to retrieve and SObjectField token by label name.
    * @param  sObjectType The SObjectType for an SObject.
    * @param  fieldLabelName The label name for a field on the specified SObject.
    * @return An SObjectField token corresponding to the specified SObject field.
    **********************************************************************************/ 
    private Schema.SObjectField getSObjectFieldByLabel(Schema.SObjectType sObjectType, String fieldLabelName) {
        MODL_DescribeSObject sObjectModel = this.globalDescribeModel.sObjectModelBySObjectType.get(sObjectType);
        Schema.SObjectField sObjectField = sObjectModel.sObjectFieldByLabel.get(fieldLabelName);

        if(sObjectField != null) {
            return sObjectField;
        }

        //TODO: Labelify
        throw new InvalidParameterValueException('Object Name', fieldLabelName);
    }

    /**********************************************************************************
    * @description Helper method to retrieve the cached version of MODL_DescribeSObject for an SObject type.
    * @param  sObjectType An SObject type.
    * @return The cached MODL_DescribeSObject model corresponding to the specified SObject type.
    **********************************************************************************/
    private MODL_DescribeSObject getCachedSObjectDescribeModel(Schema.SObjectType sObjectType){
        MODL_DescribeSObject cachedDescribeSObjectModel = this.globalDescribeModel.sObjectModelBySObjectType.get(sObjectType);
        if (cachedDescribeSObjectModel != null){
            return cachedDescribeSObjectModel;
        }

        return this.getAndCacheSObjectDescribeModels(new List<Schema.SObjectType>{sObjectType})[0];
    }

    /**********************************************************************************
    * @description Helper method to retrieve the cached version of MODL_FieldDescribe for an SObject field.
    * @param  sObjectType An SObject type. 
    * @param  sObjectField An SObject field on the specified SObject type.
    * @return The cached MODL_FieldDescribe model corresponding to the specified SObject field.
    **********************************************************************************/ 
    private MODL_FieldDescribe getCachedFieldDescribeModel(Schema.SObjectType sObjectType, Schema.SObjectField sObjectField){
        MODL_FieldDescribe cachedFieldDescribeModel = this.getCachedSObjectDescribeModel(sObjectType).sObjectFieldModelBySObjectField.get(sObjectField);
        
        if (cachedFieldDescribeModel != null){
            return cachedFieldDescribeModel;
        }

        return this.getAndCacheFieldDescribeModel(sObjectType, sObjectField);
    }

    /**********************************************************************************
    * @description Helper method to retrieve the cached MODL_PicklistFieldDescribe for an SObject field of type picklist.
    * @param  sObjectType An SObject type. 
    * @param  sObjectField An SObject field on the specified SObject type of type picklist.
    * @return The cached MODL_PicklistFieldDescribe model corresponding to the specified SObject field.
    **********************************************************************************/
    private MODL_PicklistFieldDescribe getCachedPicklistFieldDescribeModel(Schema.SObjectType sObjectType, Schema.SObjectField sObjectField){
        MODL_FieldDescribe cachedFieldDescribeModel = this.getCachedSObjectDescribeModel(sObjectType).sObjectFieldModelBySObjectField.get(sObjectField);
        
        if (cachedFieldDescribeModel != null && cachedFieldDescribeModel.pickListFieldDescribeModel != null){
            return cachedFieldDescribeModel.pickListFieldDescribeModel;
        }

        return this.getAndCacheFieldDescribeModel(sObjectType, sObjectField).pickListFieldDescribeModel;
    }

    /**********************************************************************************
    * @description Helper method to retreive SObject Describes for a list of SObject types and 
    * cache them in the Global Describe model.
    * @param  sObjectTypesList A list os SObject types
    * @return A list of MODL_DescribeSObject model representin the SObject types specified.
    **********************************************************************************/
    private List<MODL_DescribeSObject> getAndCacheSObjectDescribeModels(List<Schema.SObjectType> sObjectTypesList) {
        List<MODL_DescribeSObject> describeSObjectModelsList = this.getDescribeSObjectModelBySObjectType(sObjectTypesList);

        for (MODL_DescribeSObject describeSObjModel : describeSObjectModelsList){
            Schema.SObjectType sObjectType = describeSObjModel.sObjectDescribeResult.getSObjectType();
            this.globalDescribeModel.addSObjectDescribeModelToMap(sObjectType, describeSObjModel);
        }

        return describeSObjectModelsList;
    }

    /**
    * getNewPicklistFieldDescribeModel description
    * @param  sObjectField sObjectField description
    * @return              return description
    */
    // private MODL_PicklistFieldDescribe getNewPicklistFieldDescribeModel(Schema.SObjectField sObjectField){
    //     MODL_PicklistFieldDescribe picklistFieldDescribeModel = new MODL_PicklistFieldDescribe(sObjectField);
    //     picklistFieldDescribeModel.addPicklistFieldDescribeModelToFieldDescribeModel(picklistFieldDescribeModel);

    //     return picklistFieldDescribeModel;
    // }

    /**********************************************************************************
    * @description Helper method to generate a list of PicklistFieldDescribe models corresponding to 
    * a specified list of SObject fields.
    * @param  sObjectFieldsList A list of SObject fields.
    * @return A list of MODL_PicklistFieldDescribe models corresponding to the specified list
    * of SObject fields.
    **********************************************************************************/
    private List<MODL_PicklistFieldDescribe> getNewPicklistFieldDescribeModels(List<Schema.SObjectField> sObjectFieldsList){
        List<MODL_PicklistFieldDescribe> picklistFieldDescribeModelsList = new List<MODL_PicklistFieldDescribe>();

        for (Schema.SObjectField sObjectField : sObjectFieldsList){
            MODL_PicklistFieldDescribe picklistFieldDescribeModel = new MODL_PicklistFieldDescribe(sObjectField);
            picklistFieldDescribeModel.addPicklistFieldDescribeModelToFieldDescribeModel(picklistFieldDescribeModel);
            picklistFieldDescribeModelsList.add(picklistFieldDescribeModel);
        }
        
        return picklistFieldDescribeModelsList;
    }

    /**********************************************************************************
    * @description Helper method to generate and cache a copy of a FieldDescribe model for a specified object field.
    * If the field is of type picklist, a PicklistFieldDescribe model is also generated and associated with the 
    * FieldDescribe model.
    * @param  sObjectField The schema for the SObject field to model.
    * @return A MODL_FieldDescribe for the specified SObject field.
    **********************************************************************************/
    private MODL_FieldDescribe getAndCacheFieldDescribeModel(Schema.SObjectType sObjectType, Schema.SObjectField sObjectField){

        MODL_DescribeSObject cachedDescribeSObjectModel = this.globalDescribeModel.sObjectModelBySObjectType.get(sObjectType);
        MODL_FieldDescribe fieldDescribeModel = cachedDescribeSObjectModel.sObjectFieldModelBySObjectField.get(sObjectField);

        if (fieldDescribeModel != null){
            return fieldDescribeModel;
        }

        // generate field describe model for picklist or other field type
        fieldDescribeModel = this.getNewFieldDescribeModelBySObjectFields(new List<Schema.SObjectField>{sObjectField})[0];
        cachedDescribeSObjectModel.sObjectFieldModelBySObjectField.put(sObjectField, fieldDescribeModel);
        return fieldDescribeModel;
    }
}