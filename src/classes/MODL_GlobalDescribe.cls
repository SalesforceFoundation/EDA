/**
* @description A model representing a global schema describe
* This should only be instantiated by a mapper.
* This should not be converted to a view model and not be exposed to controllers.
*/
public with sharing class MODL_GlobalDescribe {

    public Map<String, Schema.SObjectType> sObjectTypeByApiName { get; private set; }
    public Map<Schema.SObjectType, MODL_DescribeSObject> sObjectModelBySObjectType { get; private set; }

    public MODL_GlobalDescribe(Map<String, Schema.SObjectType> sObjectTypeByApiName) {
        this.sObjectTypeByApiName = sObjectTypeByApiName;
        this.sObjectModelBySObjectType = new Map<Schema.SObjectType, MODL_DescribeSObject>();
    }

    public void addSObjectDescribeModelToMap(Schema.SObjectType sObjectType, MODL_DescribeSObject describeSObjectModel) {
        this.sObjectModelBySObjectType.put(sObjectType,describeSObjectModel);
    }    
}