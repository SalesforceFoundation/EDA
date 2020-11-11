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
* @description Schema service that calls the appropriate mapper to return models upstream.
* This should ideally never return anything but abstracted data in the form of models.
* This is called by either another service to orchestrate functionality or by a service that maps models to view models.
*/
public virtual with sharing class SRVC_Schema {
    /**********************************************************************************
    * @description Lazy loading cache for global describes.
    **********************************************************************************/
    private MODL_GlobalDescribe globalDescribeModel {
        get {
            if(this.globalDescribeModel != null) {
                return this.globalDescribeModel;
            }

            this.globalDescribeModel = new MODL_GlobalDescribe(Schema.getGlobalDescribe());
            return this.globalDescribeModel;
        }
        set;
    }

    /**********************************************************************************
    * @description Retrive a cached GlobalDescribe model.
    * @return A cached MODL_GlobalDescribe representing the Global Describe schema.
    **********************************************************************************/
    public MODL_GlobalDescribe getGlobalDescribeModel() {
        return this.globalDescribeModel;
    }

    /**********************************************************************************
    * @description Instance for Singleton Pattern
    **********************************************************************************/
    @TestVisible
    private static SRVC_Schema instance;

    /**********************************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************************/
    protected SRVC_Schema() {}

    /**********************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of MAPR_Schema.
    **********************************************************************************/
    public static SRVC_Schema getInstance() {
        if (instance == null) {
            instance = new SRVC_Schema();
        }

        return instance;
    }

    /**********************************************************************************
    * @description Locates and returns an instance of the schema mapper
    **********************************************************************************/
    private MAPR_Schema locateSchemaMapper() {
        return MAPR_Schema.getInstance();
    }

    /**********************************************************************************
    * @description Helper method to retrieve an SObjectType token by API name.
    * @param  apiName The API name of an SObjectType.
    * @return The SObjectType token corresponding to the specified API name.
    **********************************************************************************/ 
    public Schema.SObjectType getSObjectTypeByApiName(String apiName) {
        Schema.SObjectType sObjectType =
            this.getGlobalDescribeModel().sObjectTypeByApiName.get(apiName);

        if(sObjectType != null) {
            return sObjectType;
        }

        //TODO: Labelify
        throw new InvalidParameterValueException('Object Name',apiName);
    }

    /**********************************************************************************
    * @description Helper method to retrieve an SObjectType token by Label name.
    * @param  labelName The label name of an SObjectType.
    * @return The SObjectType token corresponding to the specified label name.
    **********************************************************************************/ 
    public Schema.SObjectType getSObjectTypeByLabel(String labelName) {
        Schema.SObjectType sObjectType =
            this.getGlobalDescribeModel().sObjectTypeByLabelName.get(labelName);

        if(sObjectType != null) {
            return sObjectType;
        }

        //TODO: Labelify
        throw new InvalidParameterValueException('Object Name', labelName);
    }
}