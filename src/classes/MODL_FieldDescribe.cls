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
* @description Model to represent the schema of an SObject field.
*/
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

    /**********************************************************************************
    * @description Populates the MODL_PicklistFieldDescribe variable.
    * @param  pickListFieldDescribeModel A PicklistFieldDescribe model.
    **********************************************************************************/ 
    public void populatePicklistFieldDescribeModel(MODL_PicklistFieldDescribe pickListFieldDescribeModel){
        this.pickListFieldDescribeModel = pickListFieldDescribeModel;
    }
}
