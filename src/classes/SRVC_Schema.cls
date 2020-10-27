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
    * @description Locates and returns an instance of the schema mapper
    */
    private MAPR_Schema locateSchemaMapper() {
        return MAPR_Schema.getInstance();
    }
}