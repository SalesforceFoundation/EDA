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
    * @description Retrieve cached FieldDescribe models for a specified list of SObject fields.
    * @param  sObjectApiName The API name for and SObject token.
    * @param  apiNameList A list of API names for fields on the same SObject.
    * @return A list of MODL_FieldDescribe models corresponding to the specified list of SObject fields.
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
    *  @description Retrieve cached PicklistFieldDescribe models for a specified list of SObject fields of type picklist.
    * @param  sObjectApiName The API name for and SObject token.
    * @param  apiNameList A list of API names for picklist fields on the same SObject.
    * @return A list of MODL_FieldDescribe models corresponding to the specified list of SObject fields of type picklist.
    **********************************************************************************/
    public List<MODL_PicklistFieldDescribe> getPicklistFieldDescribeModelsFromApiNames(String sObjectApiName, List<String> apiNameList){
        List<MODL_PicklistFieldDescribe> picklistFieldDescribeModelsList = new List<MODL_PicklistFieldDescribe>();

        try {
            for (MODL_FieldDescribe fieldDescribeModel : this.getFieldDescribeModelsFromApiNames(sObjectApiName, apiNameList)){
                MODL_PicklistFieldDescribe picklistFieldDescribeModel = (MODL_PicklistFieldDescribe)fieldDescribeModel;
                picklistFieldDescribeModelsList.add(picklistFieldDescribeModel);
                
            }

            // picklistFieldDescribeModelsList = 
            //     (List<MODL_PicklistFieldDescribe>)this.getFieldDescribeModelsFromApiNames(sObjectApiName, apiNameList);
        // } catch(NotAPicklistException ape) {
        } catch(Exception e) {
            //TODO handle error: at least one of field API names provided are not associated with a picklist field
        }
        
        return picklistFieldDescribeModelsList;
    }
}
