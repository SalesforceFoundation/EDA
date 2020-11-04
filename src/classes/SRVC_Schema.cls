/**
* @description Schema service that calls the appropriate mapper to return models upstream.
* This should ideally never return anything but abstracted data in the form of models.
* This is called by either another service to orchestrate functionality or by a service that maps models to view models.
*/
public virtual with sharing class SRVC_Schema {

    /**
    * @description Instance for Singleton Pattern
    */
    @TestVisible
    private static SRVC_Schema instance;

    /**
    * @description Empty constructor is not public for Singleton Pattern
    */
    protected SRVC_Schema() {}

    /**
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of MAPR_Schema.
    */
    public static SRVC_Schema getInstance() {
        if (instance == null) {
            instance = new SRVC_Schema();
        }

        return instance;
    }

    /**
    * @description Gets an sObject model list by api names. Note that this would be bulkified if it were not config
    */
    public List<MODL_DescribeSObject> getSObjectDescribeModelByApiNameList(List<String> apiNameList) {
        List<MODL_DescribeSObject> sObjectModelList = new List<MODL_DescribeSObject>();

        for(String apiName : apiNameList) {
            MODL_DescribeSObject sObjectModel =
                this.locateSchemaMapper().getSObjectDescribeModelByApiName(apiName);

            sObjectModelList.add(sObjectModel);
        }

        return sObjectModelList;
    }

    /**
     * @description Retrieve a list of FieldDescribe models for specified SObject fields.
     * @param  sOjbectApiName           The API name for the related SObject.
     * @param  sObjectFieldApiNamesList A List of API names for SObject fields to model.
     * @return                          A list of MODL_FieldDescribe modelling the specified SObject fields.
     */
    public List<MODL_FieldDescribe> getFieldDescribeModelsForSObjectByFieldApiNamesList(String sOjbectApiName, List<String> sObjectFieldApiNamesList){
        List<MODL_FieldDescribe> fieldDescribeModelsList = new List<MODL_FieldDescribe>();

        for (String fieldApi : sObjectFieldApiNamesList){
            MODL_FieldDescribe fieldDescribeModel = this.locateSchemaMapper().getSObjectFieldDescribeModelByApiNames(sOjbectApiName, fieldApi);
            fieldDescribeModelsList.add(fieldDescribeModel);
        }
        
        return fieldDescribeModelsList;
    }

    // public List<MODL_PicklistFieldDescribe> getPicklistFieldDescribeModelsByApiNamesList(){

    // }

    /**
    * @description Locates and returns an instance of the schema mapper
    */
    private MAPR_Schema locateSchemaMapper() {
        return MAPR_Schema.getInstance();
    }
}