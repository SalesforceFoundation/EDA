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
* @description .
*/
public virtual with sharing class LookupFieldService {
    /*********************************************
    * @description Instance for Singleton Pattern
    **********************************************/
    @TestVisible
    private static LookupFieldService instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************/
    protected LookupFieldService() {}

    /*****************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of LookupFieldService.
    ******************************************************************************/
    public static LookupFieldService getInstance() {
            if (instance == null) {
                    instance = new LookupFieldService();
            }

            return instance;
    }

    /********************************************************************************************
    * @description Retrieve a map of LookupFieldModels by Name for a specified SObject 
    * that is a lookup to the same SObject type.
    * @param  sObjectType An SObject type 
    * @return A Map<String, LookupFieldModel>
    ********************************************************************************************/
    public Map<String, LookupFieldModel> getModelByNameMapForSObjectType(SObjectType sObjectType) {
        Map<String,LookupFieldModel> lookupFieldModelByName = new Map<String, LookupFieldModel>();

        List<LookupFieldModel> lookupFieldModelList = 
            this.locateLookupFieldMapper().getLookupFieldModelsForSObjectType(sObjectType, sObjectType);

        for (LookupFieldModel lookupFieldMod : lookupFieldModelList) {
            lookupFieldModelByName.put(lookupFieldMod.name, lookupFieldMod);
        }

        return lookupFieldModelByName;
    }

    /********************************************************************************************
    * @description Retrieve a map of LookupFieldModels by Label for a specified SObject 
    * that is a lookup to the same SObject type.
    * @param  sObjectType An SObject type 
    * @return A Map<String, LookupFieldModel>
    ********************************************************************************************/
    public Map<String, LookupFieldModel> getModelByLabelMapForSObjectType(SObjectType sObjectType) {
        Map<String,LookupFieldModel> lookupFieldModelByLabel = new Map<String, LookupFieldModel>();

        List<LookupFieldModel> lookupFieldModelList = 
            this.locateLookupFieldMapper().getLookupFieldModelsForSObjectType(sObjectType, sObjectType);

        for (LookupFieldModel lookupFieldMod : lookupFieldModelList) {
            lookupFieldModelByLabel.put(lookupFieldMod.label, lookupFieldMod);
        }

        return lookupFieldModelByLabel;
    }

    /********************************************************************************************
    * @description Retrieve a LookupField model for a specified SObject and field name.
    * @param  sObjectType An SObject Type
    * @param  fieldName  An SObject field name
    * @return A LookupFieldModel
    ********************************************************************************************/ 
    public LookupFieldModel getLookupFieldModelFromNameMap(SObjectType sObjectType, String fieldName) {
        return this.getModelByNameMapForSObjectType(sObjectType)?.get(fieldName);
    }

    /********************************************************************************************
    * @description Retrieve a LookupField model for a specified SObject and field label.
    * @param  sObjectType An SObject Type
    * @param  fieldLabel  An SObject field name
    * @return A LookupFieldModel
    ********************************************************************************************/ 
    public LookupFieldModel getLookupFieldModelFromLabelMap(SObjectType sObjectType, String fieldLabel) {
        return this.getModelByLabelMapForSObjectType(sObjectType)?.get(fieldLabel);
    }

    /*****************************************************************************
    * @description Retrieves an instance of the LookupFieldMapper.
    * @return The instance of LookupFieldMapper.
    ******************************************************************************/
    @TestVisible
    private LookupFieldMapper locateLookupFieldMapper(){
        return LookupFieldMapper.getInstance();
    }
}
