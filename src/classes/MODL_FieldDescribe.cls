public virtual with sharing class MODL_FieldDescribe {
    public MODL_PicklistFieldDescribe pickListFieldDescribeModel { get; private set; }
    public Schema.DescribeFieldResult describeFieldResult { get; private set; }

    public String label { 
        get { return describeFieldResult.getLabel(); }
    }

    public String apiName { 
        get { return describeFieldResult.getName(); }
    }

    public String localName { 
        get { return describeFieldResult.getLocalName(); }
    }

    public MODL_FieldDescribe(){}

    public MODL_FieldDescribe(Schema.DescribeFieldResult describeFieldResult) {
        this.describeFieldResult = describeFieldResult;
    }

    /**
     * @description Creates a MODL_PicklistFieldDescribe for SObject fields of type picklist.
     */
    public void addPicklistFieldDescribeModel(Schema.SObjectField sObjectField){
       pickListFieldDescribeModel = new MODL_PicklistFieldDescribe(sObjectField);
    }
}
