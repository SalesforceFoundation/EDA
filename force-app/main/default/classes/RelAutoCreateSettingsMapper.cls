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
* @description Mapper class for REL_Relationships_Con_TDTM; used to generate ContactRelAutoCreateMappingModel
* models representing Relationship Auto Create mappings set for the Contact object. 
*/
public virtual with sharing class MAPR_RELAutoCreateSettings {
    /***************************************************************************************************************************
    * @description Instance for Singleton Pattern.
    ***************************************************************************************************************************/
    @TestVisible
    private static MAPR_RELAutoCreateSettings instance;

    /***************************************************************************************************************************
    * @description Cache for the relationship autocreate mappings
    ***************************************************************************************************************************/
    @TestVisible
    private static List<ContactRelAutoCreateMappingModel> relationshipAutocreateMappingsCache;

    /***************************************************************************************************************************
    * @description Empty constructor is not public for Singleton Pattern.
    ***************************************************************************************************************************/
    protected MAPR_RELAutoCreateSettings() {}

    /***************************************************************************************************************************
    * @description Static method to get the current instance for Singleton pattern.
    * @return The instance of MAPR_RELAutoCreateSettings.
    ***************************************************************************************************************************/
    public static MAPR_RELAutoCreateSettings getInstance() {
        if (MAPR_RELAutoCreateSettings.instance == null) {
            MAPR_RELAutoCreateSettings.instance = new MAPR_RELAutoCreateSettings();
        }

        return MAPR_RELAutoCreateSettings.instance;
    }

    /***************************************************************************************************************************
    * @description Retrieves a list of ContactRelAutoCreateMappingModel representing the Relationship Auto Create
    * mappings set for the Contact object.
    * @return A list of ContactRelationshipAutoCreateMapping models.
    **************************************************************************************************************************/
<<<<<<< HEAD:force-app/main/default/classes/RelAutoCreateSettingsMapper.cls
    public virtual List<MODL_ConRelationshipAutoCreateMapping> getContactMappingModelsFromSettings(){
        if(MAPR_RELAutoCreateSettings.relationshipAutocreateMappingsCache != null) {
            return MAPR_RELAutoCreateSettings.relationshipAutocreateMappingsCache;
=======
    public virtual List<ContactRelAutoCreateMappingModel> getContactMappingModelsFromSettings(){
        if(RelAutoCreateSettingsMapper.relationshipAutocreateMappingsCache != null) {
            return RelAutoCreateSettingsMapper.relationshipAutocreateMappingsCache;
>>>>>>> renamed MODL_ConRelationshipAutoCreateMapping to ContactRelAutoCreateMappingModel:src/classes/RelAutoCreateSettingsMapper.cls
        }

        List<Relationship_Auto_Create__c> relAutoCreateForContactsList = 
            UTIL_CustomSettingsFacade.getAutoCreateSettingsForContact();
            
        MAPR_RELAutoCreateSettings.relationshipAutocreateMappingsCache =
            this.getContactMappingModelsFromMappings(relAutoCreateForContactsList);

        return MAPR_RELAutoCreateSettings.relationshipAutocreateMappingsCache;
    }

    /***************************************************************************************************************************
    * @description Generates a list of ContactRelAutoCreateMappingModel representing a specified list of Relationship
    * Auto Create mappings.
    * @param relAutoCreateList List of Relationship Auto Create settings to be used to generate mapping models.
    * @return A list of ContactRelAutoCreateMappingModel representing the Relationship Auto Create mappings provided.
    ***************************************************************************************************************************/ 
    @TestVisible
    protected  virtual List<ContactRelAutoCreateMappingModel> getContactMappingModelsFromMappings(List<Relationship_Auto_Create__c> relAutoCreateList){
        List<ContactRelAutoCreateMappingModel> conRelAutoCreateMapModelsList = new List<ContactRelAutoCreateMappingModel>();

        for (Relationship_Auto_Create__c relAutoCreate : relAutoCreateList){
            ContactRelAutoCreateMappingModel relatedModel = this.getModelFromMapping(relAutoCreate);

            if (relatedModel != null){
                conRelAutoCreateMapModelsList.add(relatedModel);
            }
        }

        return conRelAutoCreateMapModelsList;
    }

    /***************************************************************************************************************************
    * @description Generates a single of ContactRelAutoCreateMappingModel representing a specified Relationship
    * Auto Create mapping.
    * @param relAutoCreate A Relationship Auto Create mapping from which to generate a model.
    * @return A ContactRelAutoCreateMappingModel representing the specified Relationship Auto Create mapping.
    ***************************************************************************************************************************/
        @TestVisible
    protected virtual ContactRelAutoCreateMappingModel getModelFromMapping(Relationship_Auto_Create__c relAutoCreate){
        Schema.DescribeFieldResult fieldDescribe = UTIL_Describe.getFieldDescribe(relAutoCreate.Object__c, relAutoCreate.Field__c);
  
        if (fieldDescribe == null){
            return null;
        }
        
        return new ContactRelAutoCreateMappingModel(fieldDescribe, relAutoCreate.Relationship_Type__c, relAutoCreate.Field__c);
    }
}