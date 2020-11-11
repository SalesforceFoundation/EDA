/*
    Copyright (c) 2020, Salesforce.org
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
 
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2020
* @group Schema
* @group-content ../../ApexDocContent/Schema.htm
* @description Model to represent the schema of an SObject.
*/
public with sharing class MODL_DescribeSObject {

    public Schema.DescribeSObjectResult sObjectDescribeResult { get; private set; }

    public Map<String, String> sObjectFieldLabelByApiName { get; private set; }
    public Map<String, Schema.SObjectField> sObjectFieldByApiName { get; private set; }
    public Map<String,Schema.SObjectField> sObjectFieldByLabel { get; private set; }
    public Map<Schema.SObjectField, MODL_FieldDescribe> sObjectFieldModelBySObjectField { get; private set; }

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

    public MODL_DescribeSObject(Schema.DescribeSObjectResult sObjectDescribeResult){
        this.sObjectDescribeResult = sObjectDescribeResult;

        this.sObjectFieldLabelByApiName = new Map<String, String>();
        this.sObjectFieldByLabel = new Map<String,Schema.SObjectField>();
        this.sObjectFieldModelBySObjectField = new Map<Schema.SObjectField, MODL_FieldDescribe>();
        this.sObjectFieldByApiName = sObjectDescribeResult.fields.getMap();

        for (Schema.SObjectField objectField : this.sObjectFieldByApiName.values()){
            Schema.DescribeFieldResult describeFieldResult = objectField.getDescribe();
            this.sObjectFieldLabelByApiName.put(describeFieldResult.getName(), describeFieldResult.getLabel());
            this.sObjectFieldByLabel.put(describeFieldResult.getLabel(), objectField);
        }
    }

    /**
     * cacheFieldDescribeModel description
     * @param  sObjectField              sObjectField description
     * @param  sObjectFieldDescribeModel sObjectFieldDescribeModel description
     */
    public void cacheFieldDescribeModel(Schema.SObjectField sObjectField, MODL_FieldDescribe sObjectFieldDescribeModel){
        sObjectFieldModelBySObjectField.put(sObjectField, sObjectFieldDescribeModel);
    }
}