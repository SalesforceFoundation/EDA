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
* @description A model representing a global schema describe.
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
            Schema.DescribeSObjectResult describeSObjectResult = sObjectType.getDescribe();
            String sObjectLabelName =  describeSObjectResult.getLabel();
            this.sObjectLabelByApiName.put(describeSObjectResult.getName(), sObjectLabelName);
            this.sObjectTypeByLabelName.put(sObjectLabelName, sObjectType);
        }

        this.sObjectModelBySObjectType = new Map<Schema.SObjectType, MODL_DescribeSObject>();
    }

    /**********************************************************************************
    * @describe Map a DescribeSObject model to map by SObject type.
    * @param  sObjectType An SObjectType token.
    * @param  describeSObjectModel A MODL_DescribeSObject model to map.
    **********************************************************************************/
    public void cacheSObjectDescribeModel(Schema.SObjectType sObjectType, MODL_DescribeSObject describeSObjectModel) {
        this.sObjectModelBySObjectType.put(sObjectType, describeSObjectModel);
    }    
}