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
* @date 2021
* @group Health Check
* @group-content ../../ApexDocContent/HealthCheck.htm
* @description View Model Mapper providing a Health Check Group View Model
* for Reciprocal Relationship Mappings and Settings.
*/
public virtual with sharing class ReciprocalRelHealthCheckVMapper {

    /***************************************************************************
    * @description Instance for Singleton Pattern
    ******************************************************************************/
    @TestVisible
    private static ReciprocalRelHealthCheckVMapper instance;

    /***************************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    ***************************************************************************/
    protected ReciprocalRelHealthCheckVMapper() {}

    /***************************************************************************
    * @description Static method to get the current instance for Singleton
    * pattern
    * @return The instance of ReciprocalRelHealthCheckVMapper.
    ***************************************************************************/
    public static ReciprocalRelHealthCheckVMapper getInstance() {

        if (instance == null) {
            instance = new ReciprocalRelHealthCheckVMapper();
        }

        return instance;
    }

    /***************************************************************************
    * @description Provides comprehensive Health Check Group View Model for
    * Reciprocal Relationship Settings
    * @return The Health Check Group View Model for Reciprocal Relationship
    * Settings
    ***************************************************************************/
    public virtual HealthCheckGroupVModel getHealthCheckGroup() {
        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel(
            Label.stgHealthCheckReciprocalRelTitle,
            Label.stgHealthCheckStatusPassed,
            0,
            0,
            new List<String>(),
            new List<HealthCheckItemVModel>()
        );

        List<RelationshipLookupModel> relationshipLookupModelList =
            this.locateRelationshipLookupSettingsService(
            ).getRelationshipLookupModels();

        Map<String,PicklistEntryModel> picklistEntryModelByName =
            this.locatePicklistEntryService(
            ).getModelsByNameForSObjectField(
                Relationship__c.SObjectType,
                Relationship__c.Type__c
            );

        Set<String> duplicateMappingKeys = new Set<String>();

        for(RelationshipLookupModel relationshipLookupModel : relationshipLookupModelList) {
            HealthCheckGroupVModel relationshipLookupCheckResult =
                this.getRelationshipLookupHealthCheckGroup(
                    relationshipLookupModel,
                    picklistEntryModelByName,
                    duplicateMappingKeys
                );

            healthCheckGroupVModel.passedChecks += 
                relationshipLookupCheckResult.passedChecks;
            healthCheckGroupVModel.totalChecks += 
                relationshipLookupCheckResult.totalChecks;
            
            healthCheckGroupVModel.expandedRowsList.addAll(
                relationshipLookupCheckResult.expandedRowsList
            );
            healthCheckGroupVModel.healthCheckItemList.addAll(
                relationshipLookupCheckResult.healthCheckItemList
            );
        }

        if(healthCheckGroupVModel.passedChecks < healthCheckGroupVModel.totalChecks) {
            healthCheckGroupVModel.status = Label.stgHealthCheckStatusFailed;
        }

        healthCheckGroupVModel.healthCheckItemList.sort();

        return healthCheckGroupVModel;
    }

    /***************************************************************************
    * @description Retrieves the health check for an individual Relationship
    * Lookup Model 
    * @param relationshipLookupModel The relationship lookup model to perform
    * the health check on.
    * @param picklistEntryModelByName The picklist entry model map by value for
    * Relationship__c.Type__c
    * @param duplicateMappingKeys The set of duplicate relationship mapping key
    * values
    * @return The health check for an individual Relationship Lookup Model 
    ***************************************************************************/
    @TestVisible
    protected virtual HealthCheckGroupVModel getRelationshipLookupHealthCheckGroup(
        RelationshipLookupModel relationshipLookupModel,
        Map<String,PicklistEntryModel> picklistEntryModelByName,
        Set<String> duplicateMappingKeys
    ) {
        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel(
            '',
            '',
            0,
            0,
            new List<String>(),
            new List<HealthCheckItemVModel>()
        );

        return healthCheckGroupVModel;
    }

    /***************************************************************************
    * @description Retrieves an instance of PicklistEntryService. 
    * @return An instance of PicklistEntryService.
    ***************************************************************************/
    @TestVisible
    private PicklistEntryService locatePicklistEntryService(){
        return PicklistEntryService.getInstance();
    }

    /***************************************************************************
    * @description Retrieves an instance of RelationshipLookupSettingsService. 
    * @return An instance of RelationshipLookupSettingsService.
    ***************************************************************************/
    @TestVisible
    private RelationshipLookupSettingsService locateRelationshipLookupSettingsService(){
        return RelationshipLookupSettingsService.getInstance();
    }
}