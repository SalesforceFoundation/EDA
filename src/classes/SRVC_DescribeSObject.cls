public virtual with sharing class SRVC_DescribeSObject {
    /**********************************************************************************
    * @description Instance for Singleton Pattern
    **********************************************************************************/
    @TestVisible
    private static SRVC_DescribeSObject instance;

    /**********************************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************************/
    protected SRVC_DescribeSObject() {}

    /**********************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of SRVC_DescribeSObject.
    **********************************************************************************/
    public static SRVC_DescribeSObject getInstance() {
        if (instance == null) {
            instance = new SRVC_DescribeSObject();
        }

        return instance;
    }

    /**********************************************************************************
    * @description Locates and returns an instance of the DescribeSObject mapper
    **********************************************************************************/
    private MAPR_DescribeSObject locateDescribeSObjectMapper() {
        return MAPR_DescribeSObject.getInstance();
    }

    /**********************************************************************************
    * @description Retrieve a list of DescribeSObject models by SObject API name.
    * @param  apiNameList A list of SObject API names.
    * @return A list of MODL_DescribeSObject models corresponding to the specified API names.
    **********************************************************************************/
    public List<MODL_DescribeSObject> getSObjectDescribeModelByApiNameList(List<String> apiNameList) {

        List<MODL_DescribeSObject> sObjectModelList = new List<MODL_DescribeSObject>();
        MODL_GlobalDescribe globalDescribeModel = SRVC_Schema.getInstance().getGlobalDescribeModel();

        for(String apiName : apiNameList) {
            Schema.SObjectType sObjectType = globalDescribeModel.sObjectTypeByApiName.get(apiName);

            if (sObjectType == null){
                // TODO: throw exception: sObjectApiName not associated with valid SObject token
            }

            MODL_DescribeSObject sObjectModel = globalDescribeModel.sObjectModelBySObjectType.get(sObjectType);

            if (sObjectModel == null){
                sObjectModel = this.locateDescribeSObjectMapper().createAndCacheDescribeSObjectModelByApiName(globalDescribeModel, apiName);
            }

            sObjectModelList.add(sObjectModel);
        }

        return sObjectModelList;
    }

    /**********************************************************************************
    * @description Retrieve a list of DesribeSObject models by SObject label name.
    * @param  labelNameList A list of SObject label names.
    * @return A list of MODL_DescribeSObject models corresponding to the specified label names.
    **********************************************************************************/ 
    public List<MODL_DescribeSObject> getSObjectDescribeModelByLabelNameList(List<String> labelNameList) {
        List<MODL_DescribeSObject> sObjectModelList = new List<MODL_DescribeSObject>();
        MODL_GlobalDescribe globalDescribeModel = SRVC_Schema.getInstance().getGlobalDescribeModel();

        for(String labelName : labelNameList) {
            Schema.SObjectType sObjectType = globalDescribeModel.sObjectTypeByLabelName.get(labelName);

            if (sObjectType == null){
                // TODO: throw exception: sObject Label Name not associated with valid SObject token
            }

            MODL_DescribeSObject sObjectModel = globalDescribeModel.sObjectModelBySObjectType.get(sObjectType);

            if (sObjectModel == null){
                sObjectModel = this.locateDescribeSObjectMapper().createAndCacheDescribeSObjectModelByLabel(globalDescribeModel, labelName);
            }

            sObjectModelList.add(sObjectModel);
        }

        return sObjectModelList;
    }


    /**********************************************************************************
    * @description Retrieve a list of cached DesribeSObject models by SObject type.
    * @param  labelNameList A list of SObject types.
    * @return A list of MODL_DescribeSObject models corresponding to the specified SObject types.
    **********************************************************************************/ 
    public List<MODL_DescribeSObject> getSObjectDescribeModelBySObjectType(List<Schema.SObjectType> sObjectTypesList) {
        List<MODL_DescribeSObject> sObjectModelList = new List<MODL_DescribeSObject>();
        MODL_GlobalDescribe globalDescribeModel = SRVC_Schema.getInstance().getGlobalDescribeModel();

        for (Schema.SObjectType sObjectType : sObjectTypesList){
            MODL_DescribeSObject sObjectModel = globalDescribeModel.sObjectModelBySObjectType.get(sObjectType);

            if (sObjectModel == null){
                sObjectModel = this.locateDescribeSObjectMapper().createAndCacheDescribeSObjectModelByApiName(globalDescribeModel, sObjectType.getDescribe().getName());
            }

            sObjectModelList.add(sObjectModel);
        }

        return sObjectModelList;
    }
    
    public Set<String> getAllSObjectFieldApiNames(Schema.SObjectType sObjectType){
        return this.getSObjectDescribeModelBySObjectType(new List<Schema.SObjectType>{sObjectType})[0].sObjectFieldByApiName.KeySet();
    }

    public Set<String> getAllSObjectFieldLabels(Schema.SObjectType sObjectType){
        return this.getSObjectDescribeModelBySObjectType(new List<Schema.SObjectType>{sObjectType})[0].sObjectFieldByLabel.KeySet();
    }

    public List<MODL_FieldDescribe> getAllSObjectFieldDescribeModels(Schema.SObjectType sObjectType){
        return this.getSObjectDescribeModelBySObjectType(new List<Schema.SObjectType>{sObjectType})[0].sObjectFieldModelBySObjectField.values();
    }
}
