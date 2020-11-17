public virtual with sharing class SRVC_FieldDescribe {
    /**********************************************************************************
    * @description Instance for Singleton Pattern
    **********************************************************************************/
    @TestVisible
    private static SRVC_FieldDescribe instance;

    /**********************************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************************/
    protected SRVC_FieldDescribe() {}

    /**********************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of SRVC_FieldDescribe.
    **********************************************************************************/
    public static SRVC_FieldDescribe getInstance() {
        if (instance == null) {
            instance = new SRVC_FieldDescribe();
        }

        return instance;
    }

    /**********************************************************************************
    * @description Locates and returns an instance of the FieldDescribe mapper
    **********************************************************************************/
    private MAPR_FieldDescribe locateFieldDescribeMapper() {
        return MAPR_FieldDescribe.getInstance();
    }

    /**********************************************************************************
    * @description Retrieve cached FieldDescribe models for a specified list of SObject field api names.
    * @param  sObjectApiName The API name for an SObject.
    * @param  apiNameList A list of API names for fields on the specified SObject.
    * @return A list of MODL_FieldDescribe models corresponding to the specified list of SObject field api names.
    **********************************************************************************/
    public List<MODL_FieldDescribe> getFieldDescribeModelsFromApiNames(String sObjectApiName, List<String> apiNameList) {
        List<MODL_FieldDescribe> fieldDescribeModelList = new List<MODL_FieldDescribe>();

        MODL_DescribeSObject describeSObjectModel = 
            SRVC_DescribeSObject.getInstance().getSObjectDescribeModelByApiNameList(new List<String>{sObjectApiName})[0];

        for (String fieldApiName : apiNameList){
            Schema.SObjectField sObjectField = describeSObjectModel.sObjectFieldByApiName.get(fieldApiName);

            if (sObjectField == null){
                // TODO throw exception: field API name is not valid for specified sObject type
            }

            MODL_FieldDescribe fieldDescribeModel = describeSObjectModel.sObjectFieldModelBySObjectField.get(sObjectField);

            if (fieldDescribeModel == null){
                fieldDescribeModel = this.locateFieldDescribeMapper().createAndCacheFieldDescribeModel(describeSObjectModel, fieldApiName);
            }

            fieldDescribeModelList.add(fieldDescribeModel);
        }

        return fieldDescribeModelList;
    } 

    /**********************************************************************************
    * @description Retrieve cached FieldDescribe models for a specified list of SObject field label names.
    * @param  sObjectApiName An SObject label name.
    * @param  apiNameList A list of API names for fields for the specified SObject.
    * @return A list of MODL_FieldDescribe models corresponding to the specified list of SObject field label names.
    **********************************************************************************/
    public List<MODL_FieldDescribe> getFieldDescribeModelsFromLabelNames(String sObjectLabelName, List<String> labelNameList) {
        List<MODL_FieldDescribe> fieldDescribeModelList = new List<MODL_FieldDescribe>();

        MODL_DescribeSObject describeSObjectModel = 
            SRVC_DescribeSObject.getInstance().getSObjectDescribeModelByLabelNameList(new List<String>{sObjectLabelName})[0];

        for (String fieldLabelName : labelNameList){
            Schema.SObjectField sObjectField = describeSObjectModel.sObjectFieldByLabel.get(fieldLabelName);

            if (sObjectField == null){
                // TODO throw exception: field Label name is not valid for specified sObject type
            }

            MODL_FieldDescribe fieldDescribeModel = describeSObjectModel.sObjectFieldModelBySObjectField.get(sObjectField);

            if (fieldDescribeModel == null){
                fieldDescribeModel = this.locateFieldDescribeMapper().createAndCacheFieldDescribeModel(describeSObjectModel, fieldLabelName);
            }

            fieldDescribeModelList.add(fieldDescribeModel);
        }

        return fieldDescribeModelList;
    } 

    /**********************************************************************************
    * @description Retrieve cached FieldDescribe models for a specified list of SObject field api names.
    * @param  sObjectApiName An SObject token.
    * @param  apiNameList A list of API names for fields on the specified SObject.
    * @return A list of MODL_FieldDescribe models corresponding to the specified list of SObject field api names.
    **********************************************************************************/
    public List<MODL_FieldDescribe> getFieldDescribeModelsFromFieldApiNames(Schema.SObjectType sObjectType, List<String> apiNameList) {
        List<MODL_FieldDescribe> fieldDescribeModelList = new List<MODL_FieldDescribe>();

        MODL_DescribeSObject describeSObjectModel = SRVC_DescribeSObject.getInstance().getSObjectDescribeModelBySObjectType(new List<Schema.SObjectType>{sObjectType})[0];

        for (String fieldApiName : apiNameList){
            Schema.SObjectField sObjectField = describeSObjectModel.sObjectFieldByApiName.get(fieldApiName);

            if (sObjectField == null){
                // TODO throw exception: field Label name is not valid for specified sObject type
            }

            MODL_FieldDescribe fieldDescribeModel = describeSObjectModel.sObjectFieldModelBySObjectField.get(sObjectField);

            if (fieldDescribeModel == null){
                fieldDescribeModel = this.locateFieldDescribeMapper().createAndCacheFieldDescribeModel(describeSObjectModel, fieldApiName);
            }

            fieldDescribeModelList.add(fieldDescribeModel);
        }

        return fieldDescribeModelList;
    } 

    /**********************************************************************************
    * @description Retrieve cached FieldDescribe models for a specified list of SObject field label names.
    * @param  sObjectApiName An SObject token.
    * @param  apiNameList A list of label names for fields on the specified SObject.
    * @return A list of MODL_FieldDescribe models corresponding to the specified list of SObject field label.
    **********************************************************************************/
    public List<MODL_FieldDescribe> getFieldDescribeModelsFromFieldLabelNames(Schema.SObjectType sObjectType, List<String> labelNameList) {
        List<MODL_FieldDescribe> fieldDescribeModelList = new List<MODL_FieldDescribe>();

        MODL_DescribeSObject describeSObjectModel = SRVC_DescribeSObject.getInstance().getSObjectDescribeModelBySObjectType(new List<Schema.SObjectType>{sObjectType})[0];

        for (String fieldLabelName : labelNameList){
            Schema.SObjectField sObjectField = describeSObjectModel.sObjectFieldByLabel.get(fieldLabelName);

            if (sObjectField == null){
                // TODO throw exception: field Label name is not valid for specified sObject type
            }

            MODL_FieldDescribe fieldDescribeModel = describeSObjectModel.sObjectFieldModelBySObjectField.get(sObjectField);

            if (fieldDescribeModel == null){
                fieldDescribeModel = this.locateFieldDescribeMapper().createAndCacheFieldDescribeModel(describeSObjectModel, fieldLabelName);
            }

            fieldDescribeModelList.add(fieldDescribeModel);
        }

        return fieldDescribeModelList;
    } 

    /**********************************************************************************
    *  @description Retrieve cached PicklistFieldDescribe models for a specified list of SObject field api names of type picklist.
    * @param  sObjectApiName The label name for an SObject.
    * @param  apiNameList A list of API names for picklist fields on the specified SObject.
    * @return A list of MODL_FieldDescribe models corresponding to the specified list of SObject field api names of type picklist.
    **********************************************************************************/
    public List<MODL_PicklistFieldDescribe> getPicklistFieldDescribeModelsFromApiNames(String sObjectApiName, List<String> apiNameList){
        List<MODL_PicklistFieldDescribe> picklistFieldDescribeModelsList = new List<MODL_PicklistFieldDescribe>();

        try {
            for (MODL_FieldDescribe fieldDescribeModel : this.getFieldDescribeModelsFromApiNames(sObjectApiName, apiNameList)){
                MODL_PicklistFieldDescribe picklistFieldDescribeModel = (MODL_PicklistFieldDescribe)fieldDescribeModel;
                picklistFieldDescribeModelsList.add(picklistFieldDescribeModel);    
            }
        // } catch(NotAPicklistException ape) {
        } catch(Exception e) {
            //TODO handle error: aField API name provided is not associated with a picklist field type
        }

        return picklistFieldDescribeModelsList;
    }

    /**********************************************************************************
    * @description Retrieve cached FieldDescribe models for a specified list of label names for SObject fields of type picklist.
    * @param  sObjectLabelName An SObject label name.
    * @param  fieldLabelNameList A list of label names for fields of type picklist on the specified SObject.
    * @return A list of MODL_PicklistFieldDescribe models corresponding to the specified list of label names for SObject fields of type picklist.
    **********************************************************************************/
    public List<MODL_PicklistFieldDescribe> getPicklistFieldDescribeModelsFromLabelNames(String sObjectLabelName, List<String> fieldLabelNameList) {
        List<MODL_PicklistFieldDescribe> picklistFieldDescribeModelsList = new List<MODL_PicklistFieldDescribe>();

        try {
            for (MODL_FieldDescribe fieldDescribeModel : this.getFieldDescribeModelsFromLabelNames(sObjectLabelName, fieldLabelNameList)){
                MODL_PicklistFieldDescribe picklistFieldDescribeModel = (MODL_PicklistFieldDescribe)fieldDescribeModel;
                picklistFieldDescribeModelsList.add(picklistFieldDescribeModel);    
            }
        // } catch(NotAPicklistException ape) {
        } catch(Exception e) {
            //TODO handle error: aField API name provided is not associated with a picklist field type
        }

        return picklistFieldDescribeModelsList;
    } 

    /**********************************************************************************
    * @description Retrieve cached PicklistFieldDescribe models for a specified list of API names for SObject fields of type picklist.
    * @param  sObjectType An SObject token.
    * @param  fieldApiNameList A list of API names for fields of type picklist on the specified SObject.
    * @return A list of MODL_PicklistFieldDescribe models corresponding to the specified list of API names for SObject fields of type picklist.
    **********************************************************************************/
    public List<MODL_PicklistFieldDescribe> getPicklistFieldDescribeModelsFromFieldApiNames(Schema.SObjectType sObjectType, List<String> fieldApiNameList) {
        List<MODL_PicklistFieldDescribe> picklistFieldDescribeModelsList = new List<MODL_PicklistFieldDescribe>();

        try {
            for (MODL_FieldDescribe fieldDescribeModel : this.getFieldDescribeModelsFromFieldApiNames(sObjectType, fieldApiNameList)){
                MODL_PicklistFieldDescribe picklistFieldDescribeModel = (MODL_PicklistFieldDescribe)fieldDescribeModel;
                picklistFieldDescribeModelsList.add(picklistFieldDescribeModel);    
            }
        // } catch(NotAPicklistException ape) {
        } catch(Exception e) {
            //TODO handle error: aField API name provided is not associated with a picklist field type
        }

        return picklistFieldDescribeModelsList;
    } 

    /**********************************************************************************
    * @description Retrieve cached PicklistFieldDescribe models for a specified list of label names for SObject fields of type picklist.
    * @param  sObjectType An SObject token.
    * @param  fieldLabelNameList A list of label names for fields of type picklist on the specified SObject.
    * @return A list of MODL_PicklistFieldDescribe models corresponding to the specified list of label names for SObject fields of type picklist.
    **********************************************************************************/
    public List<MODL_FieldDescribe> getPicklistFieldDescribeModelsFromFieldLabelNames(Schema.SObjectType sObjectType, List<String> fieldLabelNameList) {
        List<MODL_PicklistFieldDescribe> picklistFieldDescribeModelsList = new List<MODL_PicklistFieldDescribe>();

        try {
            for (MODL_FieldDescribe fieldDescribeModel : this.getFieldDescribeModelsFromFieldLabelNames(sObjectType, fieldLabelNameList)){
                MODL_PicklistFieldDescribe picklistFieldDescribeModel = (MODL_PicklistFieldDescribe)fieldDescribeModel;
                picklistFieldDescribeModelsList.add(picklistFieldDescribeModel);    
            }
        // } catch(NotAPicklistException ape) {
        } catch(Exception e) {
            //TODO handle error: aField API name provided is not associated with a picklist field type
        }

        return picklistFieldDescribeModelsList;
    } 

    /**********************************************************************************
    * @description Retrieve a list of FieldDescribeModels representing fields on an SObject with parents of a specified SObject type.
    * @param sObjectApiName The API name of an SObject.
    * @param parentSObjectApiName The API name of the SObject referenced as a parent in a lookup relationship.
    * @return A list of MODL_FieldDescribe models corresponding to fields that lookup to a specified parent object on a specified SObject.
    **********************************************************************************/ 
    public List<MODL_FieldDescribe> getFilteredLookupFieldDescribeModelsFromSObjectType(String sObjectApiName, String parentSObjectApiName){
        List<MODL_FieldDescribe> accountLookupFieldDescribeModelsList = new List<MODL_FieldDescribe>();        

        MODL_GlobalDescribe globalDescribeModel = SRVC_Schema.getInstance().getGlobalDescribeModel();
        Schema.SObjectType sObjectType = globalDescribeModel.sObjectTypeByApiName.get(sObjectApiName);
        Schema.SObjectType parentSObjectTypeToFilterBy = globalDescribeModel.sObjectTypeByApiName.get(parentSObjectApiName);
        
        List<MODL_FieldDescribe> SObjectFieldDescribeModels = this.getAllFieldDescribeModelsForSObject(sObjectType);

        for (MODL_FieldDescribe fieldDescribeModel : SObjectFieldDescribeModels){
            List<Schema.SObjectType> parentSObjectsList = fieldDescribeModel.lookupFields;

            if (parentSObjectsList.isEmpty()){
                continue;
            }

            for (Schema.SObjectType parentSObjectType : parentSObjectsList) {
                if (parentSObjectType == parentSObjectTypeToFilterBy){
                    accountLookupFieldDescribeModelsList.add(fieldDescribeModel);
                }
            }
        }

        return accountLookupFieldDescribeModelsList;
    }


    /**********************************************************************************
    * @description Retrieve the field label name for a specified field API name.
    * @param  sObjectType An SObject token.
    * @param  fieldApiNamesList A field API name on the specified SObject.
    * @return A field label name corresponding to the specified field API name.
    **********************************************************************************/
    public String getFieldLabelFromApiName(Schema.SObjectType sObjectType, String fieldApiName){
        MODL_DescribeSObject describeSObjectModel = 
            SRVC_DescribeSObject.getInstance().getSObjectDescribeModelBySObjectType(new List<Schema.SObjectType>{sObjectType})[0];
        
            return describeSObjectModel.sObjectFieldLabelByApiName.get(fieldApiName);
    }

    /**********************************************************************************
    * @description Retrieve the FieldDescribe models for all fields on a specified SObject
    * @param  sObjectType An SObject token
    * @return A list of MODL_FieldDescribe models for the specified SObject
    **********************************************************************************/ 
    public List<MODL_FieldDescribe> getAllFieldDescribeModelsForSObject(Schema.SObjectType sObjectType){
        MODL_DescribeSObject sObjectModel = 
            SRVC_DescribeSObject.getInstance().getSObjectDescribeModelBySObjectType(new List<Schema.SObjectType>{sObjectType})[0];
        
        List<String> sObjectFieldApiNamesList = new List<String>(sObjectModel.sObjectFieldByApiName.KeySet());

        return this.getFieldDescribeModelsFromFieldApiNames(sObjectType, sObjectFieldApiNamesList);
    }
}
