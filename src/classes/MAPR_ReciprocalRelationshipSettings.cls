/*
    Copyright (c) 2020, Salesforce.org
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
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
* @group Relationships
* @group-content ../../ApexDocContent/Relationships.htm
* @description Mapper for Reciprocal Relationship Settings.
*/
public virtual with sharing class MAPR_ReciprocalRelationshipSettings {
    /*********************************************
    * @description Instance for Singleton Pattern.
    **********************************************/
    @TestVisible
    private static MAPR_ReciprocalRelationshipSettings instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern.
    **********************************************************************/
    protected MAPR_ReciprocalRelationshipSettings() {}

    /*****************************************************************************
    * @description Static method to get the current instance for Singleton pattern.
    * @return The instance of MAPR_ReciprocalRelationshipSettings.
    ******************************************************************************/
    public static MAPR_ReciprocalRelationshipSettings getInstance() {
        if (MAPR_ReciprocalRelationshipSettings.instance == null) {
            MAPR_ReciprocalRelationshipSettings.instance = new MAPR_ReciprocalRelationshipSettings();
        }

        return MAPR_ReciprocalRelationshipSettings.instance;
    }

    /*****************************************************************************
    * TODO: @description Check if Contact relationships should be updated.
    * @return If Contact relationships should be updated.
    ******************************************************************************/
    @TestVisible
    private Map<String, MODL_ReciprocalRelationshipMapping> getActiveMappingsModels() {
        //Get the relationship autocreate mappings using UTIL_CustomSettingsFacade.getActiveRelationshipLookups()
        //Return getActiveMappingModelsFromMappings() 
        List<Relationship_Lookup__c> relationshipLookupsList = UTIL_CustomSettingsFacade.getActiveRelationshipLookups();
        return this.getActiveMappingModelsFromMappings(relationshipLookupsList);  
    }

    /*****************************************************************************
    * TODO: @description Check if Contact relationships should be updated.
    * @return If Contact relationships should be updated.
    ******************************************************************************/
    @TestVisible
    private Map<String, MODL_ReciprocalRelationshipMapping> getActiveMappingModelsFromMappings(List<Relationship_Lookup__c> relationshipLookupsList) {
        // Takes in a List<Relationship_Lookup__c>
        // Create a Map<String,MODL_ReciprocalRelationshipMapping>
        // For each mapping
            // Add getModelFromMapping() to the map of models by names
        // Return the map of models
        Map<String, MODL_ReciprocalRelationshipMapping> reciprocalRelationshipMappingByNameMap = new Map<String, MODL_ReciprocalRelationshipMapping>();
        for (Relationship_Lookup__c relationshipLookup : relationshipLookupsList) {
            reciprocalRelationshipMappingByNameMap.put(getModelFromMapping(relationshipLookup).getRelationshipName(), getModelFromMapping(relationshipLookup));
        }
        return reciprocalRelationshipMappingByNameMap;
    }

    /*****************************************************************************
    * TODO: @description Check if Contact relationships should be updated.
    * @return If Contact relationships should be updated.
    ******************************************************************************/
    @TestVisible
    private MODL_ReciprocalRelationshipMapping getModelFromMapping(Relationship_Lookup__c relationshipLookup) {
        // Takes in a Relationship_Lookup__c
        // Create a ReciprocalRelationshipMappingModel using the mapping
        // return the model
        return new MODL_ReciprocalRelationshipMapping(relationshipLookup);
    }
}