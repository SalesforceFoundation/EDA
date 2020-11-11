public virtual with sharing class MAPR_FieldDescribe {
    /**********************************************************************************
    * @description Instance for Singleton Pattern
    **********************************************************************************/
    @TestVisible
    private static MAPR_FieldDescribe instance;

    /**********************************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************************/
    protected MAPR_FieldDescribe() {}

    /**********************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of MAPR_FieldDescribe.
    **********************************************************************************/
    public static MAPR_FieldDescribe getInstance() {
        if (instance == null) {
            instance = new MAPR_FieldDescribe();
        }

        return instance;
    }

    /**********************************************************************************
    * @description Create and cache a FieldDescribe model in DescribeSObject for a specified SObject field.
    * @param  sObjectDescribeModel A cached version of the associated DescribeSObject model.
    * @param  fieldApiName An API name for an SObject field.
    * @return A MODL_FieldDescribe model for the specified SObject field.  Throws an error if SObjectField is not
    * valid for specified SObject token.
    **********************************************************************************/
    public MODL_FieldDescribe createAndCacheFieldDescribeModel(MODL_DescribeSObject sObjectDescribeModel, String fieldApiName){
        if (sObjectDescribeModel.sObjectFieldByApiName.containsKey(fieldApiName) == false){
            // TODO: throw exception: invalid SObject/field name pair
        }

        Schema.SObjectField sObjectField = sObjectDescribeModel.sObjectFieldByApiName.get(fieldApiName);

        if (sObjectField.getDescribe().getType() == Schema.DisplayType.PICKLIST){
            return this.createAndCachePicklistFieldDescribeModel(sObjectDescribeModel, fieldApiName);
        }

        MODL_FieldDescribe fieldDescribeModel = this.createFieldDescribeModel(sObjectField);
        sObjectDescribeModel.cacheFieldDescribeModel(sObjectField, fieldDescribeModel);
        return fieldDescribeModel;
    }

    /**********************************************************************************
    * @description Create and cache a PicklistFieldDescribe model in SObjectDescribe for a specified SObject field.
    * @param  sObjectDescribeModel A cached version of the associated DescribeSObject model.
    * @param  fieldApiName An API name for an SObject field.
    * @return A MODL_PicklistFieldDescribe model for the specified SObject field.  Throws an error if SObjectField is not
    * valid for specified SObject token.
    **********************************************************************************/
    public MODL_PicklistFieldDescribe createAndCachePicklistFieldDescribeModel(MODL_DescribeSObject sObjectDescribeModel, String fieldApiName){
        if (sObjectDescribeModel.sObjectFieldByApiName.containsKey(fieldApiName) == false){
            // TODO: throw exception: invalid SObject/field name pair
        }

        Schema.SObjectField sObjectField = sObjectDescribeModel.sObjectFieldByApiName.get(fieldApiName);
        MODL_PicklistFieldDescribe picklistFieldDescribeModel = this.createPicklistFieldDescribeModel(sObjectField);
        sObjectDescribeModel.cacheFieldDescribeModel(sObjectField, (MODL_FieldDescribe)picklistFieldDescribeModel);

        return picklistFieldDescribeModel;
    }

    /**********************************************************************************
    * @description Helper method to create a new FieldDescribe model for a specified SObject field.
    * @param sObjectField An SObjectField token.
    * @return A MODL_FieldDescribe corresponding to the specified SObject field.
    **********************************************************************************/
    private MODL_FieldDescribe createFieldDescribeModel(Schema.SObjectField sObjectField){
        return new MODL_FieldDescribe(sObjectField);
    }

    /**********************************************************************************
    * @description Helper method to create a new PicklistFieldDescribe model for a specified SObject picklist field.
    * @param sObjectField An SObjectField token of type picklist.
    * @return A MODL_PicklistFieldDescribe corresponding to the specified SObject picklist field.
    **********************************************************************************/
    private MODL_PicklistFieldDescribe createPicklistFieldDescribeModel(Schema.SObjectField sObjectField){
        return new MODL_PicklistFieldDescribe(sObjectField);
    }
}
