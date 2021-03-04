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
* @description Service class for REL_Relationships_Con_TDTM; used to generate ContactRelAutoCreateMappingModel
* models representing Relationship Auto Create mappings set for the Contact object. 
*/
public virtual with sharing class RelAutoCreateSettingsMapperService {
    /***************************************************************************************************************************
    * @description Instance for Singleton Pattern.
    ***************************************************************************************************************************/
    @TestVisible
    private static RelAutoCreateSettingsMapperService instance;

    /***************************************************************************************************************************
    * @description Empty constructor is not public for Singleton Pattern.
    ***************************************************************************************************************************/
    protected RelAutoCreateSettingsMapperService() {}

    /***************************************************************************************************************************
    * @description Static method to get the current instance for Singleton pattern.
    * @return The instance of RelAutoCreateSettingsMapperService.
    ***************************************************************************************************************************/
    public static RelAutoCreateSettingsMapperService getInstance() {
        if (RelAutoCreateSettingsMapperService.instance == null) {
            RelAutoCreateSettingsMapperService.instance = new RelAutoCreateSettingsMapperService();
        }

        return RelAutoCreateSettingsMapperService.instance;
    }

    /***************************************************************************************************************************
    * @description Retrieves a list of ContactRelAutoCreateMappingModel representing the Relationship Auto Create
    * mappings set for the Contact object.
    * @return A list of ContactRelationshipAutoCreateMapping models.
    **************************************************************************************************************************/
    public virtual List<ContactRelAutoCreateMappingModel> getContactMappingModelsFromSettings(){
        List<Relationship_Auto_Create__c> relAutoCreateForContactList = UTIL_CustomSettingsFacade.getAutoCreateSettingsForContact();
        return this.getContactMappingModelsFromMappings(relAutoCreateForContactList);
    }

    /***************************************************************************************************************************
    * @description Generates a list of ContactRelAutoCreateMappingModel representing a specified list of Relationship
    * Auto Create mappings.
    * @param relAutoCreateList List of Relationship Auto Create settings to be used to generate mapping models.
    * @return A list of ContactRelAutoCreateMappingModel representing the Relationship Auto Create mappings provided.
    ***************************************************************************************************************************/ 
    public virtual List<ContactRelAutoCreateMappingModel> getContactMappingModelsFromMappings(List<Relationship_Auto_Create__c> relAutoCreateList){
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
    public virtual ContactRelAutoCreateMappingModel getModelFromMapping(Relationship_Auto_Create__c relAutoCreate){
        Schema.DescribeFieldResult fieldDescribe = UTIL_Describe.getFieldDescribe(relAutoCreate.Object__c, relAutoCreate.Field__c);
  
        if (fieldDescribe == null){
            return null;
        }
        
        return new ContactRelAutoCreateMappingModel(fieldDescribe, relAutoCreate.Relationship_Type__c, relAutoCreate.Field__c);
    }
}
