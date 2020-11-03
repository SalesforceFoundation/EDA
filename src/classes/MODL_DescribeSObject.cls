public with sharing class MODL_DescribeSObject {

    public Schema.DescribeSObjectResult sObjectDescribeResult { get; private set; }
    public Map<String, Schema.SObjectField> sObjectFieldByApiName { get; private set; }
    public Map<String,Schema.SObjectField> sObjectFieldByLabel { get; private set; }
    public Map<Schema.SObjectField, MODL_FieldDescribe> sObjectFieldModelBySObjectField { get; private set; }

    public MODL_DescribeSObject(Schema.DescribeSObjectResult sObjectDescribeResult){
        this.sObjectDescribeResult = sObjectDescribeResult;
        this.sObjectFieldModelBySObjectField = new Map<Schema.SObjectField, MODL_FieldDescribe>();

        Map<String, Schema.SObjectField> sObjectFieldByApiName = sObjectDescribeResult.fields.getMap();

        this.sObjectFieldByLabel = new Map<String,Schema.SObjectField>();
        for (Schema.SObjectField objectField : sObjectFieldByApiName.values()){
            sObjectFieldByLabel.put(objectField.getDescribe().getLabel(), objectField);
        }
    }

    public void addFieldDescribeModel(Schema.SObjectField sObjectField, MODL_FieldDescribe sObjectFieldDescribeModel){
        sObjectFieldModelBySObjectField.put(sObjectField, sObjectFieldDescribeModel);
    }

    public String label {
        get {
            return sObjectDescribeResult.getLabel();
        }
    }

    public String apiName {
        get {
            return sObjectDescribeResult.getName();
        }
    }

    public String localApiName {
        get {
            return sObjectDescribeResult.getLocalName();
        }
    }
}