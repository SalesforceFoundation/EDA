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

    public MODL_FieldDescribe(Schema.SObjectField sobjectField) {
        this.describeFieldResult = sobjectField.getDescribe();
    }

    public void populatePicklistFieldDescribeModel(MODL_PicklistFieldDescribe pickListFieldDescribeModel){
        this.pickListFieldDescribeModel = pickListFieldDescribeModel;
    }
}
