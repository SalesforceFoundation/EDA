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
    * that is a lookup to a specified SObject type.
    * @param  sObjectType The SObject type of the field model
    * @param lookupToSObjectType The SObject type that the field model looks up to 
    * @return A Map<String, LookupFieldModel>
    ********************************************************************************************/
    public virtual Map<String, LookupFieldModel> getModelByNameMapForSObjectType(
        SObjectType sObjectType, 
        SObjectType lookupToSObjectType
    ) {
        return this.locateLookupFieldMapper().getModelByNameMapForSObjectType(sObjectType, lookupToSObjectType);
    }

    /********************************************************************************************
    * @description Retrieve a map of LookupFieldModels by Label for lookup fields on an SObject.
    * @param  lookupFieldModelsByName A map of lookup fields on an SObject by developer name.
    * @return A Map<String, LookupFieldModel>
    ********************************************************************************************/
    public Map<String,LookupFieldModel> getModelByLabelMapForSObjectType(Map<String,LookupFieldModel> lookupFieldModelsByName) {
        Map<String, LookupFieldModel> lookupFieldModelsByLabel = new Map<String, LookupFieldModel>();

        for (LookupFieldModel lookupFieldModel : lookupFieldModelsByName.values()) {
            lookupFieldModelsByLabel.put(lookupFieldModel.label, lookupFieldModel);
        }

        return lookupFieldModelsByLabel;
    }

    /********************************************************************************************
    * @description Retrieve a LookupField model corresponding to a specified field name.
    * @param  fieldName  An SObject field name
    * @return A LookupFieldModel
    ********************************************************************************************/ 
    public virtual LookupFieldModel getLookupFieldModelFromNameMap(
        String fieldName, 
        Map<String, LookupFieldModel> lookupFieldModelByName) 
    {
        return lookupFieldModelByName.get(fieldName);
    }

    /******************************************************************************
    * @description Retrieve a lookup field model for a specified lookup field name or label.
    * @param LookupFieldNameOrLabel A string representing the name or label for a lookup field
    * @param LookupFieldModelByName A map of lookup field models by name
    * @param LookupFieldModelByLabel A map of lookup field models by label
    * @return A lookup field Model corresponding to the specified lookup field label or name
    ******************************************************************************/
    public virtual LookupFieldModel getLookupFieldModelFromNameAndLabelMaps(
        String lookupFieldNameOrLabel, 
        Map<String, LookupFieldModel> lookupFieldModelByName,
        Map<String, LookupFieldModel> lookupFieldModelByLabel
    ) { 
        LookupFieldModel lookupFieldModel = lookupFieldModelByName.get(lookupFieldNameOrLabel);

        if (lookupFieldModel == null) {
            lookupFieldModel = lookupFieldModelByLabel.get(lookupFieldNameOrLabel);
        }

        return lookupFieldModel;
    }

    /********************************************************************************************
    * @description Retrieve a LookupField model corresponding to a specified field label.
    * @param  fieldLabel  An SObject field label
    * @return A LookupFieldModel
    ********************************************************************************************/ 
    public virtual LookupFieldModel getLookupFieldModelFromLabelMap(
        String fieldLabel, 
        Map<String, LookupFieldModel> lookupFieldModelByLabel) 
    {
        return lookupFieldModelByLabel.get(fieldLabel);
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
