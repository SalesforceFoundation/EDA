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
    * @return A list of MODL_DescribeSObject models mapped by SObject API name, or label names if API name not found.
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

            // if (sObjectModel == null){
            //     // model not found by apiName, search by labelName
            //     String sObjectLabel = globalDescribeModel.sObjectLabelByApiName(apiName);
            //     Schema.SObjectType sObjectType = globalDescribeModel.sObjectTypeByLabelName(sObjectLabel);
            //     MODL_DescribeSObject sObjectModel = globalDescribeModel.sObjectModelBySObjectType.get(sObjectType);
            // } 

            if (sObjectModel == null){
                sObjectModel = this.locateDescribeSObjectMapper().createAndCacheDescribeSObjectModel(globalDescribeModel, apiName);
            }

            sObjectModelList.add(sObjectModel);
        }

        System.debug('SRVC_DescribeSObject sObjectModelList: ' + sObjectModelList);
        return sObjectModelList;
    }

    /**********************************************************************************
    * @description Retrieve a list of DesribeSObject models by SObject label name.
    * @param  labelNameList A list of SObject label names.
    * @return A list of MODL_DescribeSObject models mapped by SObject lable names.
    **********************************************************************************/ 
    // public List<MODL_DescribeSObject> getSObjectDescribeModelByLabelNameList(List<String> labelNameList) {
    //     List<MODL_DescribeSObject> sObjectModelList = new List<MODL_DescribeSObject>();

    //     for(String labelName : labelNameList) {
    //         MODL_DescribeSObject sObjectModel = this.locateDescribeSObjectMapper().getSObjectDescribeModelByLabelName(labelName);

    //         if (sObjectModel == null){
    //             continue;
    //         }

    //         sObjectModelList.add(sObjectModel);
    //     }

    //     return sObjectModelList;
    // }

}
