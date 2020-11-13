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
    * createAndCacheDescribeSObjectModelByApiName description
    * @param  globalDescribeModel globalDescribeModel description
    * @param  sObjectApiName      sObjectApiName description
    * @return                     return description
    **********************************************************************************/ 
    public MODL_DescribeSObject createAndCacheDescribeSObjectModelByApiName(MODL_GlobalDescribe globalDescribeModel, String sObjectApiName){

        if (globalDescribeModel.sObjectTypeByApiName.containsKey(sObjectApiName) == false){
            // TODO: throw exception: invalid SObject API name provided
        }
    
        Schema.SObjectType sObjectType = globalDescribeModel.sObjectTypeByApiName.get(sObjectApiName);
        MODL_DescribeSObject describeSObjectModel = this.createDescribeSObjectModel(sObjectType.getDescribe());

        globalDescribeModel.cacheSObjectDescribeModel(sObjectType, describeSObjectModel);

        return describeSObjectModel;
    }

    
    public MODL_DescribeSObject createAndCacheDescribeSObjectModelByLabel(MODL_GlobalDescribe globalDescribeModel, String sObjectLabelName){

        if (globalDescribeModel.sObjectTypeByLabelName.containsKey(sObjectLabelName) == false){
            // TODO: throw exception: invalid SObject Label name provided
        }
    
        Schema.SObjectType sObjectType = globalDescribeModel.sObjectTypeByLabelName.get(sObjectLabelName);
        MODL_DescribeSObject describeSObjectModel = this.createDescribeSObjectModel(sObjectType.getDescribe());

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
}
