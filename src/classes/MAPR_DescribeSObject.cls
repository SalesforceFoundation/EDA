public virtual with sharing class MAPR_DescribeSObject {
    /**********************************************************************************
    * @description Instance for Singleton Pattern
    **********************************************************************************/
    @TestVisible
    private static MAPR_DescribeSObject instance;

    /**********************************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************************/
    protected MAPR_DescribeSObject() {}

    /**********************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of MAPR_DescribeSObject.
    **********************************************************************************/
    public static MAPR_DescribeSObject getInstance() {
        if (instance == null) {
            instance = new MAPR_DescribeSObject();
        }

        return instance;
    }

    /**********************************************************************************
    * createAndCacheDescribeSObjectModel description
    * @param  globalDescribeModel globalDescribeModel description
    * @param  sObjectApiName      sObjectApiName description
    * @return                     return description
    **********************************************************************************/ 
    public MODL_DescribeSObject createAndCacheDescribeSObjectModel(MODL_GlobalDescribe globalDescribeModel, String sObjectApiName){

        if (globalDescribeModel.sObjectTypeByApiName.containsKey(sObjectApiName) == false){
            // TODO: throw exception: invalid SObject API name provided
        }
    
        Schema.SObjectType sObjectType = globalDescribeModel.sObjectTypeByApiName.get(sObjectApiName);
        MODL_DescribeSObject describeSObjectModel = this.createDescribeSObjectModel(sObjectType.getDescribe());

        System.debug('MK DEBUG: describeSObjectModel-----: ' + describeSObjectModel);
        globalDescribeModel.cacheSObjectDescribeModel(sObjectType, describeSObjectModel);

        return describeSObjectModel;
    }

    /**********************************************************************************
    * @description Helper method to create a new DescribeSObject model for a specified SObject.
    * @param sObjectDescribeResult The DescribeSObjectResult for an SObject.
    * @return A MODL_DescribeSObject corresponding to the specified SObject API name.
    **********************************************************************************/
    private MODL_DescribeSObject createDescribeSObjectModel(Schema.DescribeSObjectResult sObjectDescribeResult){
        return new MODL_DescribeSObject(sObjectDescribeResult);
    }
















    /**********************************************************************************
    * @description Retrieve a cached DescribeSObject model for a specified SObject API name.
    * @param  apiName The API name of an SObject.
    * @return A cached MODL_DescribeSObject model representing the schema of the 
    * specified SObject API name.
    **********************************************************************************/
    // public MODL_DescribeSObject getSObjectDescribeModelByApiName(String apiName) {
    //     Schema.SObjectType sObjectType = SRVC_Schema.getInstance().getSObjectTypeByApiName(apiName);

    //     MODL_DescribeSObject describeSObjectModel =
    //         SRVC_Schema.getInstance().getGlobalDescribeModel().sObjectModelBySObjectType.get(sObjectType);

    //     if(describeSObjectModel != null) {
    //         return describeSObjectModel;
    //     }

    //     return this.getAndCacheSObjectDescribeModels(new List<Schema.SObjectType>{sObjectType})[0];
    // }

    /**********************************************************************************
    * @description Retrieve a cached DescribeSObject model for a specified SObject label name.
    * @param  labelName The label name of an SObject.
    * @return A MODL_DescribeObject model representing the schema of the specified SObject label name.
    **********************************************************************************/ 
    // public MODL_DescribeSObject getSObjectDescribeModelByLabelName(String labelName) {
    //     Schema.SObjectType sObjectType = SRVC_Schema.getInstance().getSObjectTypeByLabel(labelName);

    //     MODL_DescribeSObject describeSObjectModel =
    //         SRVC_Schema.getInstance().getGlobalDescribeModel().sObjectModelBySObjectType.get(sObjectType);

    //     if(describeSObjectModel != null) {
    //         return describeSObjectModel;
    //     }

    //     return this.getAndCacheSObjectDescribeModels(new List<Schema.SObjectType>{sObjectType})[0];
    // }

    /**********************************************************************************
    * @description Helper method to retreive SObject Describes for a list of SObject types and 
    * cache them in the Global Describe model.
    * @param  sObjectTypesList A list os SObject types
    * @return A list of MODL_DescribeSObject model representin the SObject types specified.
    **********************************************************************************/
    // public List<MODL_DescribeSObject> getAndCacheSObjectDescribeModels(List<Schema.SObjectType> sObjectTypesList) {
    //     List<MODL_DescribeSObject> describeSObjectModelsList = this.getDescribeSObjectModelBySObjectType(sObjectTypesList);

    //     for (MODL_DescribeSObject describeSObjModel : describeSObjectModelsList){
    //         Schema.SObjectType sObjectType = describeSObjModel.sObjectDescribeResult.getSObjectType();
    //         SRVC_Schema.getInstance().getGlobalDescribeModel().cacheSObjectDescribeModel(sObjectType, describeSObjModel);
    //     }

    //     return describeSObjectModelsList;
    // }

    /**********************************************************************************
    * @description Retrieve a list of DescribeSObject models corresponding to a specified list of SObject types.
    * @param  sObjectTypesList A list of SObject types
    * @return A list of MODL_DescribeSObject models corresponding to the specified SObject types.
    **********************************************************************************/
    // private List<MODL_DescribeSObject> getDescribeSObjectModelBySObjectType(List<Schema.SObjectType> sObjectTypesList) {
    //     List<MODL_DescribeSObject> describeSObjectModelsList = new List<MODL_DescribeSObject>();

    //     for (Schema.SObjectType sObjectType : sObjectTypesList){
    //         describeSObjectModelsList.add(new MODL_DescribeSObject(sObjectType.getDescribe()));
    //     }

    //     return describeSObjectModelsList;
    // }
}
