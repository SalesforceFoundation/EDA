/**
* @description A mapper that retrieves schema information and creates models
* This should only be called by a service.
* This should only return models.
* Since the data is schema-based, we make the assumption that it does not change and cache it
* Note that if this dealt with data, it could be used to perform DML operations based on the models, converting back from the model to underlying data.
*/
public virtual with sharing class MAPR_Schema {

    /**
    * @description Lazy loading cache for global describes
    */
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

    /**
    * @description Instance for Singleton Pattern
    */
    @TestVisible
    private static MAPR_Schema instance;

    /**
    * @description Empty constructor is not public for Singleton Pattern
    */
    protected MAPR_Schema() {}

    /**
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of MAPR_Schema.
    */
    public static MAPR_Schema getInstance() {
        if (instance == null) {
            instance = new MAPR_Schema();
        }

        return instance;
    }

    /**
    * @description A simple method to retrive a model.
    */
    public MODL_GlobalDescribe getGlobalDescribeModel() {
        return this.globalDescribeModel;
    }

    /**
    * @description A simple method to retrive a model based on a parameter.
    * Note that a method that returns a list might be used in the case of SObject data to bulkify SOQL queries
    */
    private MODL_DescribeSObject getDescribeSObjectModelBySObjectType(
        Schema.SObjectType sObjectType
    ) {
        return new MODL_DescribeSObject(sObjectType.getDescribe());
    }

    /*
    * @description Gets an sObject model by its api name
    */
    public MODL_DescribeSObject getSObjectDescribeModelByApiName(String apiName) {
        Schema.SObjectType sObjectType = this.getSObjectTypeByApiName(apiName);

        MODL_DescribeSObject describeSObjectModel =
            this.globalDescribeModel.sObjectModelBySObjectType.get(sObjectType);

        if(describeSObjectModel != null) {
            return describeSObjectModel;
        }

        return this.getAndCacheSObjectDescribeModel(sObjectType);
    }

    /**
    * @description Helper method that gets an sObject token by its api name
    */
    private Schema.SObjectType getSObjectTypeByApiName(String apiName) {
        Schema.SObjectType sObjectType =
            this.globalDescribeModel.sObjectTypeByApiName.get(apiName);

        if(sObjectType != null) {
            return sObjectType;
        }

        //TODO: Labelify
        throw new InvalidParameterValueException('Object Name',apiName);
    }

    /**
    * @description Helper method that gets an SObject Describe and caches it
    */
    public MODL_DescribeSObject getAndCacheSObjectDescribeModel(Schema.SObjectType sObjectType) {
        MODL_DescribeSObject describeSObjectModel =
            this.getDescribeSObjectModelBySObjectType(sObjectType);
        
        this.globalDescribeModel.addSObjectDescribeModelToMap(
            sObjectType,
            describeSObjectModel
        );

        return describeSObjectModel;
    }
}