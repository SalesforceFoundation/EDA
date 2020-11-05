public with sharing class MODL_DescribeSObject {

    public Schema.DescribeSObjectResult sObjectDescribeResult { get; private set; }

    public Map<String, String> sObjectFieldLabelByApiName { get; private set; }
    public Map<String, Schema.SObjectField> sObjectFieldByApiName { get; private set; }
    public Map<String,Schema.SObjectField> sObjectFieldByLabel { get; private set; }
    public Map<Schema.SObjectField, MODL_FieldDescribe> sObjectFieldModelBySObjectField { get; private set; }

    public MODL_DescribeSObject(Schema.DescribeSObjectResult sObjectDescribeResult){
        this.sObjectDescribeResult = sObjectDescribeResult;
        this.sObjectFieldLabelByApiName = new Map<String, String>();
        this.sObjectFieldByLabel = new Map<String,Schema.SObjectField>();
        this.sObjectFieldModelBySObjectField = new Map<Schema.SObjectField, MODL_FieldDescribe>();

        Map<String, Schema.SObjectField> sObjectFieldByApiName = sObjectDescribeResult.fields.getMap();

        for (Schema.SObjectField objectField : sObjectFieldByApiName.values()){
            sObjectFieldLabelByApiName.put(objectField.getDescribe().getName(), objectField.getDescribe().getLabel());
            sObjectFieldByLabel.put(objectField.getDescribe().getLabel(), objectField);
        }
    }

    /**
     * addFieldDescribeModel description
     * @param  sObjectField              sObjectField description
     * @param  sObjectFieldDescribeModel sObjectFieldDescribeModel description
     */
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