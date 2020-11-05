/**
* @description A model representing a global schema describe
* This should only be instantiated by a mapper.
* This should not be converted to a view model and not be exposed to controllers.
*/
public with sharing class MODL_GlobalDescribe {

    public Map<String, String> sObjectLabelByApiName { get; private set; }
    public Map<String, Schema.SObjectType> sObjectTypeByApiName { get; private set; }
    public Map<String, Schema.SObjectType> sObjectTypeByLabelName { get; private set; }
    public Map<Schema.SObjectType, MODL_DescribeSObject> sObjectModelBySObjectType { get; private set; }

    public MODL_GlobalDescribe(Map<String, Schema.SObjectType> sObjectTypeByApiName) {
        this.sObjectTypeByApiName = sObjectTypeByApiName;
        this.sObjectLabelByApiName = new Map<String, String>();
        this.sObjectTypeByLabelName = new Map<String, Schema.SObjectType>();

        for (Schema.SObjectType sObjectType : sObjectTypeByApiName.values()){
            String sObjectLabelName =  sObjectType.getDescribe().getLabel();
            this.sObjectLabelByApiName.put(sObjectType.getDescribe().getName(), sObjectLabelName);
            this.sObjectTypeByLabelName.put(sObjectLabelName, sObjectType);
        }

        this.sObjectModelBySObjectType = new Map<Schema.SObjectType, MODL_DescribeSObject>();
    }

    public void addSObjectDescribeModelToMap(Schema.SObjectType sObjectType, MODL_DescribeSObject describeSObjectModel) {
        this.sObjectModelBySObjectType.put(sObjectType,describeSObjectModel);
    }    
}