public with sharing class MODL_DescribeSObject {

    public MODL_DescribeSObject(Schema.DescribeSObjectResult sObjectDescribeResult) {
        this.sObjectDescribeResult = sObjectDescribeResult;
    }

    public Schema.DescribeSObjectResult sObjectDescribeResult {
        get; private set;
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