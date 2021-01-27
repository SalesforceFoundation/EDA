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

        Set<String> duplicateMappingKeys = this.locateRelationshipLookupSettingsService(
            ).getDuplicateRelationshipModelNamesFromList(relationshipLookupModelList);

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

        PicklistEntryModel picklistEntryModel =
            picklistEntryModelByName.get(relationshipLookupModel.name);

        HealthCheckItemVModel healthCheckItemVModel =
            this.getHealthCheckItemVModelForRelationshipLookupModel(
                relationshipLookupModel,
                picklistEntryModel
            );

        List<HealthCheckGroupVModel> healthCheckGroupVModelList =
            new List<HealthCheckGroupVModel>();

        healthCheckGroupVModelList.add(
            this.getNameHealthCheckGroup(
                relationshipLookupModel,
                picklistEntryModel
            )
        );
        healthCheckGroupVModelList.add(
            this.getFemaleHealthCheckGroup(
                relationshipLookupModel,
                picklistEntryModelByName
            )
        );
        healthCheckGroupVModelList.add(
            this.getMaleHealthCheckGroup(
                relationshipLookupModel,
                picklistEntryModelByName
            )
        );
        healthCheckGroupVModelList.add(
            this.getNeutralHealthCheckGroup(
                relationshipLookupModel,
                picklistEntryModelByName
            )
        );

        healthCheckGroupVModelList.add(
            this.getUniquenessHealthCheckGroup(
                relationshipLookupModel,
                picklistEntryModel,
                duplicateMappingKeys
            )
        );

        for(HealthCheckGroupVModel healthCheckGroupVModelItem : healthCheckGroupVModelList) {
            healthCheckGroupVModel.passedChecks += healthCheckGroupVModelItem.passedChecks;
            healthCheckGroupVModel.totalChecks += healthCheckGroupVModelItem.totalChecks;
            healthCheckGroupVModel.expandedRowsList.addAll(healthCheckGroupVModelItem.expandedRowsList);
            healthCheckItemVModel.healthCheckItemList.addAll(healthCheckGroupVModelItem.healthCheckItemList);
        }

        if(healthCheckGroupVModel.passedChecks < healthCheckGroupVModel.totalChecks) {
            healthCheckItemVModel.status = 'Fail';
            healthCheckItemVModel.statusLabel = Label.stgHealthCheckStatusFailed;
            healthCheckGroupVModel.expandedRowsList.add(relationshipLookupModel.name);
        }

        healthCheckItemVModel.healthCheckItemList.sort();

        healthCheckGroupVModel.healthCheckItemList.add(healthCheckItemVModel);

        return healthCheckGroupVModel;
    }

    /***************************************************************************
    * @description Retrieves the health check for the Relationship Lookup Model
    * Name
    * @param relationshipLookupModel The relationship lookup model to perform
    * the health check on.
    * @param picklistEntryModel The picklist entry model for the Relationship
    * Lookup Model Name
    * @return The health check for the Relationship Lookup Model Name
    ***************************************************************************/
    @TestVisible
    protected virtual HealthCheckGroupVModel getNameHealthCheckGroup(
        RelationshipLookupModel relationshipLookupModel,
        PicklistEntryModel picklistEntryModel
    ) {
        return this.getHealthCheckGroupForPicklistSetting(
            picklistEntryModel,
            relationshipLookupModel.name,
            '01',
            Label.stgHCReciprocalRelNameTitle,
            Label.stgHCReciprocalRelNameNotFoundFix,
            Label.stgHCReciprocalRelNameInactiveFix
        );
    }

    /***************************************************************************
    * @description Retrieves the health check for the Relationship Lookup Model
    * Female Value
    * @param relationshipLookupModel The relationship lookup model to perform
    * the health check on.
    * @param picklistEntryModelByName The picklist entry model map by value for
    * Relationship__c.Type__c
    * @return The health check for the Relationship Lookup Model Female Value
    ***************************************************************************/
    @TestVisible
    protected virtual HealthCheckGroupVModel getFemaleHealthCheckGroup(
        RelationshipLookupModel relationshipLookupModel,
        Map<String,PicklistEntryModel> picklistEntryModelByName
    ) {

        PicklistEntryModel picklistEntryModel =
            picklistEntryModelByName.get(relationshipLookupModel.femaleValue);

        return this.getHealthCheckGroupForPicklistSetting(
            picklistEntryModel,
            relationshipLookupModel.femaleValue,
            '02',
            Label.stgHCReciprocalRelFemaleTitle,
            Label.stgHCReciprocalRelFemaleNotFoundFix,
            Label.stgHCReciprocalRelFemaleInactiveFix
        );
    }

    /***************************************************************************
    * @description Retrieves the health check for the Relationship Lookup Model
    * Male Value
    * @param relationshipLookupModel The relationship lookup model to perform
    * the health check on.
    * @param picklistEntryModelByName The picklist entry model map by value for
    * Relationship__c.Type__c
    * @return The health check for the Relationship Lookup Model Male Value
    ***************************************************************************/
    @TestVisible
    protected virtual HealthCheckGroupVModel getMaleHealthCheckGroup(
        RelationshipLookupModel relationshipLookupModel,
        Map<String,PicklistEntryModel> picklistEntryModelByName
    ) {
        PicklistEntryModel picklistEntryModel =
            picklistEntryModelByName.get(relationshipLookupModel.maleValue);

        return this.getHealthCheckGroupForPicklistSetting(
            picklistEntryModel,
            relationshipLookupModel.maleValue,
            '03',
            Label.stgHCReciprocalRelMaleTitle,
            Label.stgHCReciprocalRelMaleNotFoundFix,
            Label.stgHCReciprocalRelMaleInactiveFix
        );
    }

    /***************************************************************************
    * @description Retrieves the health check for the Relationship Lookup Model
    * Neutral Value
    * @param relationshipLookupModel The relationship lookup model to perform
    * the health check on.
    * @param picklistEntryModelByName The picklist entry model map by value for
    * Relationship__c.Type__c
    * @return The health check for the Relationship Lookup Model Neutral Value
    ***************************************************************************/
    @TestVisible
    protected virtual HealthCheckGroupVModel getNeutralHealthCheckGroup(
        RelationshipLookupModel relationshipLookupModel,
        Map<String,PicklistEntryModel> picklistEntryModelByName
    ) {
        PicklistEntryModel picklistEntryModel =
            picklistEntryModelByName.get(relationshipLookupModel.neutralValue);

        return this.getHealthCheckGroupForPicklistSetting(
            picklistEntryModel,
            relationshipLookupModel.neutralValue,
            '04',
            Label.stgHCReciprocalRelNeutralTitle,
            Label.stgHCReciprocalRelNeutralNotFoundFix,
            Label.stgHCReciprocalRelNeutralInactiveFix
        );
    }

    /***************************************************************************
    * @description Retrieves the health check for an arbitrary picklist entry
    * model
    * @param picklistEntryModel The picklist entry model to perform the check
    * against
    * @param relationshipLookupModelFieldValue The value from the relationship
    * lookup model to use for the key and label formatting
    * @param indexString The index to use for the key
    * @param settingsLabel The label for the setting of the Health Check
    * @param notFoundFix The fix label for when a picklist entry model is
    * unfound
    * @param inactiveFix The fix label for when a picklist entry model is
    * inactive
    * @return The health check for the picklist entry model
    ***************************************************************************/
    @TestVisible
    protected virtual HealthCheckGroupVModel getHealthCheckGroupForPicklistSetting(
        PicklistEntryModel picklistEntryModel,
        String relationshipLookupModelFieldValue,
        String indexString,
        String settingsLabel,
        String notFoundFix,
        String inactiveFix
    ) {
        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel(
            '',
            '',
            0,
            0,
            new List<String>(),
            new List<HealthCheckItemVModel>()
        );
    
        List<String> modelNameListForFormat =
            new List<String>{relationshipLookupModelFieldValue};
    
        String key = relationshipLookupModelFieldValue + indexString;
    
        HealthCheckItemVModel healthCheckItemVModel =
            new healthCheckItemVModel(
                key,
                settingsLabel,
                'Fail',
                Label.stgHealthCheckStatusFailed,
                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                    Label.stgHCPicklistValueNotFound,
                    modelNameListForFormat
                ),
                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                    notFoundFix,
                    modelNameListForFormat
                ),
                new List<HealthCheckItemVModel>()
            );
    
        healthCheckGroupVModel.totalChecks++;
        healthCheckGroupVModel.healthCheckItemList.add(healthCheckItemVModel);
    
        if(picklistEntryModel == null) {
            return healthCheckGroupVModel;
        }
    
        List<String> picklistLabelAndNameForFormat =
            new List<String>{picklistEntryModel.label,picklistEntryModel.name};
    
        if(picklistEntryModel.isActive == false) {
            healthCheckItemVModel.description =
                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                    Label.stgHCPicklistValueInactive, 
                    picklistLabelAndNameForFormat
                );
            healthCheckItemVModel.recommendedFix = 
                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                    inactiveFix, 
                    picklistLabelAndNameForFormat
                );
            return healthCheckGroupVModel;
        }
    
        healthCheckItemVModel.status = 'Pass';
        healthCheckItemVModel.statusLabel = Label.stgHealthCheckStatusPassed;
        healthCheckItemVModel.description = this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                Label.stgHCPicklistValueValid,
                picklistLabelAndNameForFormat
            );
        healthCheckItemVModel.recommendedFix = Label.stgHealthCheckFixNotApplicable;
    
        healthCheckGroupVModel.passedChecks++;
    
        return healthCheckGroupVModel;
    }

    /***************************************************************************
    * @description Retrieves the health check for the Relationship Lookup Model
    * Name Uniqueness
    * @param relationshipLookupModel The relationship lookup model to perform
    * the health check on.
    * @param picklistEntryModelByName The picklist entry model map by value for
    * Relationship__c.Type__c
    * @param duplicateMappingKeys The set of duplicate relationship mapping key
    * values
    * @return The health check for the Relationship Lookup Model Name Uniqueness
    ***************************************************************************/
    @TestVisible
    protected virtual HealthCheckGroupVModel getUniquenessHealthCheckGroup(
        RelationshipLookupModel relationshipLookupModel,
        PicklistEntryModel picklistEntryModel,
        Set<String> duplicateNameSet
    ) {
        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel(
            '',
            '',
            0,
            0,
            new List<String>(),
            new List<HealthCheckItemVModel>()
        );
    
        List<String> modelNameListForFormat =
            new List<String>{relationshipLookupModel.name,relationshipLookupModel.name};

        if(picklistEntryModel != null) {
            modelNameListForFormat =
                new List<String>{picklistEntryModel.label,picklistEntryModel.name};
        }
    
        String key = relationshipLookupModel.name + '05';
    
        HealthCheckItemVModel healthCheckItemVModel =
            new healthCheckItemVModel(
                key,
                Label.stgHCReciprocalRelNameUniqueTitle,
                'Fail',
                Label.stgHealthCheckStatusFailed,
                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                    Label.stgHCReciprocalRelNameNotUniqueDesc,
                    modelNameListForFormat
                ),
                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                    Label.stgHCReciprocalRelNameNotUniqueFix,
                    modelNameListForFormat
                ),
                new List<HealthCheckItemVModel>()
            );
    
        healthCheckGroupVModel.totalChecks++;
        healthCheckGroupVModel.healthCheckItemList.add(healthCheckItemVModel);
    
        if(duplicateNameSet.contains(relationshipLookupModel.name)) {
            return healthCheckGroupVModel;
        }
    
        healthCheckItemVModel.status = 'Pass';
        healthCheckItemVModel.statusLabel = Label.stgHealthCheckStatusPassed;
        healthCheckItemVModel.description = this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                Label.stgHCReciprocalRelNameUniqueDesc,
                modelNameListForFormat
            );
        healthCheckItemVModel.recommendedFix = Label.stgHealthCheckFixNotApplicable;
    
        healthCheckGroupVModel.passedChecks++;
    
        return healthCheckGroupVModel;
    }

    /***************************************************************************
    * @description Retrieves a formatted HealthCheckItemVModel. 
    * @return A formatted HealthCheckItemVModel.
    ***************************************************************************/
    @TestVisible
    protected virtual HealthCheckItemVModel getHealthCheckItemVModelForRelationshipLookupModel(
        RelationshipLookupModel relationshipLookupModel,
        PicklistEntryModel picklistEntryModel
    ){
        String picklistEntryModelName = relationshipLookupModel.name;

        if(picklistEntryModel != null) {
            picklistEntryModelName = picklistentryModel.name;
        }

        List<String> listForSettingsLabel =
            new List<String>{relationshipLookupModel.name};
        List<String> listForDescriptionLabel =
            new List<String>{relationshipLookupModel.name,picklistEntryModelName};

        return new HealthCheckItemVModel(
            relationshipLookupModel.name,
            this.locateStringHandlingService().formatStringWithApostrophesAndParameters(Label.stgHCReciprocalRelSetting,listForSettingsLabel),
            'Pass',
            Label.stgHealthCheckStatusPassed,
            '',
            '',
            new List<HealthCheckItemVModel>()
        );
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

    /***************************************************************************
    * @description Retrieves an instance of StringHandlingService. 
    * @return An instance of StringHandlingService.
    ***************************************************************************/
    @TestVisible
    private StringHandlingService locateStringHandlingService(){
        return StringHandlingService.getInstance();
    }
}