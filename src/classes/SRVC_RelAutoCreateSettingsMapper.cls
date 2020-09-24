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
* @group 
* @group-content ../../ApexDocContent/
* @description Service class for REL_Relationships_Con_TDTM. 
*/
public virtual with sharing class SRVC_RelAutoCreateSettingsMapper {
    /*********************************************
    * @description Instance for Singleton Pattern.
    **********************************************/
    @TestVisible
    private static SRVC_RelAutoCreateSettingsMapper instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern.
    **********************************************************************/
    protected SRVC_RelAutoCreateSettingsMapper() {}

    /*****************************************************************************
    * @description Static method to get the current instance for Singleton pattern.
    * @return The instance of SRVC_RelAutoCreateSettingsMapper.
    ******************************************************************************/
    public static SRVC_RelAutoCreateSettingsMapper getInstance() {
        if (SRVC_RelAutoCreateSettingsMapper.instance == null) {
            SRVC_RelAutoCreateSettingsMapper.instance = new SRVC_RelAutoCreateSettingsMapper();
        }

        return SRVC_RelAutoCreateSettingsMapper.instance;
    }

    /*****************************************************************************
    * @description
    * @return A list of ContactRelationshipAutoCreateMapping models
    *****************************************************************************/
    public virtual List<MDL_ContactRelationshipAutoCreateMapping> getContactMappingModelsFromSettings(){
        Map<Schema.SObjectType, List<Relationship_Auto_Create__c>> relAutoCreateListBySObjectType = UTIL_CustomSettingsFacade.getAutoCreateSettingsForContact();
        System.debug('MK DEBUG SRVC REL AUTOCREATE SETTINGS MAPPER: relAutoCreateListBySObjectType: ' + relAutoCreateListBySObjectType);
        return this.getContactMappingModelsFromMappings(relAutoCreateListBySObjectType.get(Contact.SObjectType));
    }

    /**
    * getContactMappingModelsFromMappings description
    * @param  relAutoCreateList relAutoCreateList description
    * @return                   return description
    */ 
    public virtual List<MDL_ContactRelationshipAutoCreateMapping> getContactMappingModelsFromMappings(List<Relationship_Auto_Create__c> relAutoCreateList){
        List<MDL_ContactRelationshipAutoCreateMapping> conRelAutoCreateMapModelsList = new List<MDL_ContactRelationshipAutoCreateMapping>();

        for (Relationship_Auto_Create__c relAutoCreate : relAutoCreateList){
            MDL_ContactRelationshipAutoCreateMapping relatedModel = this.getModelFromMapping(relAutoCreate);

            if (relatedModel != null){
                conRelAutoCreateMapModelsList.add(relatedModel);
            }
        }

        return conRelAutoCreateMapModelsList;
    }

    /**
    * getModelFromMapping description
    * @param  relAutoCreate relAutoCreate description
    * @return               return description
    */ 
    public virtual MDL_ContactRelationshipAutoCreateMapping getModelFromMapping(Relationship_Auto_Create__c relAutoCreate){
        Schema.DescribeFieldResult fieldDescribe = UTIL_Describe.getFieldDescribe('Relationship_Auto_Create__c', 'Field__c');

        if (fieldDescribe == null){
            return null;
        }

        //MDL_ContactRelationshipAutoCreateMapping conRelationshipAutoCreateMapMdl = new MDL_ContactRelationshipAutoCreateMapping(fieldDescribe, relAutoCreate.Relationship_Type__c, relAutoCreate.Field__c);
        return new MDL_ContactRelationshipAutoCreateMapping(fieldDescribe, relAutoCreate.Relationship_Type__c, relAutoCreate.Field__c);
    }
}
