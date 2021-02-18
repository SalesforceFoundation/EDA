/*
    Copyright (c) 2021, Salesforce.org
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
* @date 2021
* @group Health Check
* @group-content ../../ApexDocContent/HealthCheck.htm
* @description Acts as the Mapper Layer for Lookup Field Service, 
* abstracting the data in the database so we can use mocks and stubs in our Singleton Pattern.
*/
public virtual with sharing class LookupFieldMapper {
    /**********************************************************************************
    * @description Instance for Singleton Pattern
    **********************************************************************************/
    @TestVisible
    private static LookupFieldMapper instance;

    /**********************************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************************/
    protected LookupFieldMapper() {}

    /**********************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of LookupFieldMapper.
    **********************************************************************************/
    public static LookupFieldMapper getInstance() {
        if (instance == null) {
            instance = new LookupFieldMapper();
        }

        return instance;
    }

    /**********************************************************************************************************
    * @description Retrieve a map of LookupField models representing fields on a specified owner SObject type
    * that is a lookup to a specified target SObject type by field name.
    * @param  sObjectType  The SObject type where the field originates
    * @param  lookupToSObjectType The SObject type where the field lookup targets
    * @return Map<String, LookupFieldModel>
    **********************************************************************************************************/ 
    public virtual Map<String, LookupFieldModel> getModelByNameMapForSObjectType(SObjectType sObjectType, SObjectType lookupToSObjectType) {
        Map<String, LookupFieldModel> lookupFieldModelByName = new Map<String, LookupFieldModel>();

        Map<String, Schema.DescribeFieldResult> sObjectLookupFieldsByName = 
            UTIL_Describe.getFieldsOfType(sObjectType.getDescribe().getName(), 'REFERENCE');

        for (Schema.DescribeFieldResult lookupFieldResult : sObjectLookupFieldsByName.values()){

            if (lookupFieldResult.getReferenceTo().contains(lookupToSObjectType)){
                    lookupFieldModelByName.put(
                    lookupFieldResult.getName(), 
                    new LookupFieldModel(lookupFieldResult.getName(), lookupFieldResult.getLabel())
                );
            } 
        }

        return lookupFieldModelByName;
    }
}
