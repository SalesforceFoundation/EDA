/*
    Copyright (c) 2021, Salesforce.org
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
 * @date 2021
 * @group EDA Settings
 * @group-content ../../ApexDocContent/EdaSettings.htm
 * @description View Mapper class used to retrieve reciprocal relationship mappings
 */
public virtual with sharing class RelationshipLookupsVMapper {
    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static RelationshipLookupsVMapper instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected RelationshipLookupsVMapper() {
    }

    /*****************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of RelationshipLookupsVMapper.
     ******************************************************************************/
    public static RelationshipLookupsVMapper getInstance() {
        if (instance == null) {
            instance = new RelationshipLookupsVMapper();
        }

        return instance;
    }

    /**
     * @description Retrieve a RelationshipLookupsVModel represeting the current values specified for Reciprocal Relationship mappings.
     * @return   A RelationshipLookupsVModel instance
     */
    public virtual RelationshipLookupsVModel getRelationshipLookupsVModel() {
        List<RelationshipLookupModel> relationshipLookupModelList = this.locateRelationshipLookupSettingsService()
            .getRelationshipLookupModels();
        List<RelationshipLookupVModel> relationshipLookupVModelList = new List<RelationshipLookupVModel>();
        for (RelationshipLookupModel relLookupModel : relationshipLookupModelList) {
            relationshipLookupVModelList.add(
                new RelationshipLookupVModel(
                    relLookupModel.name,
                    relLookupModel.femaleValue,
                    relLookupModel.maleValue,
                    relLookupModel.neutralValue,
                    relLookupModel.isActive
                )
            );
        }
        return new RelationshipLookupsVModel(relationshipLookupVModelList);
    }

    /**
     * @description Gets Relationship Type picklist values for FemaleValue, MaleValue and NeutralValue
     * @param  relationshipLookupName Specifies an existing relationship lookup name.
     * @return                        A ComboBoxVModel
     */
    public virtual ComboBoxVModel getRelationshipLookupComboboxVModel(String relationshipLookupName) {
        return this.getActiveRelationshipTypesComboboxVModel(relationshipLookupName);
    }

    /**
     * @description gets all active Relationship Type picklist values
     * @param  relationshipLookupName Specifies an existing relationship lookup name.
     * @return                        A ComboBoxVModel
     */
    public virtual ComboBoxVModel getActiveRelationshipTypesComboboxVModel(String relationshipLookupName) {
        Map<String, PicklistEntryModel> picklistEntryModelsByName = this.locatePicklistEntryService()
            .getModelsByNameForSObjectField(Relationship__c.SObjectType, Relationship__c.Type__c);
        Map<String, PicklistEntryModel> activePicklistEntryModelsByName = new Map<String, PicklistEntryModel>();
        Boolean nameExists = false;
        for (PicklistEntryModel picklistEntryModel : picklistEntryModelsByName.values()) {
            if (picklistEntryModel.isActive == true || picklistEntryModel.name == relationshipLookupName) {
                nameExists |= picklistEntryModel.name == relationshipLookupName;
                activePicklistEntryModelsByName.put(picklistEntryModel.name, picklistEntryModel);
            }
        }
        List<ComboboxValueVModel> activePicklistEntryModelList = this.getComboboxValueVModelListFromPicklist(
            activePicklistEntryModelsByName
        );
        if (!nameExists && String.isNotBlank(relationshipLookupName)) {
            //if relationshipLookupName doesn't exist in picklistEntryModelsByName (for example if it is inactive or missing)
            //insert it explicitly so the dropdown control could show the current value
            activePicklistEntryModelList.add(
                0,
                new ComboboxValueVModel(relationshipLookupName, relationshipLookupName)
            );
        }
        return new ComboboxVModel(relationshipLookupName, activePicklistEntryModelList);
    }

    /**
     * @description Gets Relationship Type picklist values for the name field
     * @param  relationshipLookupName Specifies an existing relationship lookup name. Should be an empty string for a new record
     * @return                        A ComboBoxVModel model with populated active unmapped picklist items
     */
    public virtual ComboBoxVModel getRelationshipLookupNameComboboxVModel(String relationshipLookupName) {
        //For relationship lookup name field we return the active unmapped values
        return this.getActiveUnmappedRelationshipTypesComboboxVModel(relationshipLookupName);
    }

    /**
     * @description gets all active unmapped Relationship Type picklist values
     * @return   A ComboBoxVModel
     */
    public virtual ComboBoxVModel getActiveUnmappedRelationshipTypesComboboxVModel(String relationshipLookupName) {
        PicklistEntryService picklistEntryServiceInstance = this.locatePicklistEntryService();

        Map<String, PicklistEntryModel> picklistEntryModelByName = picklistEntryServiceInstance.getActivePicklistEntryModelsByName(
            picklistEntryServiceInstance.getModelsByNameForSObjectField(
                Relationship__c.SObjectType,
                Relationship__c.Type__c
            )
        );

        //filtering out mapped values
        List<RelationshipLookupModel> relationshipLookupModelList = this.locateRelationshipLookupSettingsService()
            .getRelationshipLookupModels();
        for (RelationshipLookupModel relLookupModel : relationshipLookupModelList) {
            if (relLookupModel.name != relationshipLookupName) {
                picklistEntryModelByName.remove(relLookupModel.name);
            }
        }

        List<ComboboxValueVModel> comboboxValues = this.getComboboxValueVModelListFromPicklist(
            picklistEntryModelByName
        );
        if (
            String.isNotBlank(relationshipLookupName) && !picklistEntryModelByName.containsKey(relationshipLookupName)
        ) {
            //if relationshipLookupName doesn't exist in picklistEntryModelsByName (for example if it is inactive or missing)
            //insert it explicitly so the dropdown control could show the current value
            comboboxValues.add(0, new ComboboxValueVModel(relationshipLookupName, relationshipLookupName));
        }

        return new ComboboxVModel(relationshipLookupName, comboboxValues);
    }

    /**
     * @description Maps PicklistEntryModel map to ComboboxValueVModel list
     * @param  picklistEntryModelByName a map of PicklistEntryModel items
     * @return                          a list of ComboboxValueVModel view models
     */
    @TestVisible
    private List<ComboboxValueVModel> getComboboxValueVModelListFromPicklist(
        Map<String, PicklistEntryModel> picklistEntryModelByName
    ) {
        List<ComboboxValueVModel> comboBoxValueVModelList = new List<ComboboxValueVModel>();
        for (PicklistEntryModel pickListEntry : picklistEntryModelByName.values()) {
            comboBoxValueVModelList.add(new ComboboxValueVModel(pickListEntry.label, pickListEntry.name));
        }

        return comboBoxValueVModelList;
    }

    /***************************************************************************
     * @description Retrieves an instance of PicklistEntryService.
     * @return An instance of PicklistEntryService.
     ***************************************************************************/
    @TestVisible
    private PicklistEntryService locatePicklistEntryService() {
        return PicklistEntryService.getInstance();
    }

    /*****************************************************************************
     * @description Retrieve an instance of the RelationshipLookupSettingsService class.
     * @return An instance of RelationshipLookupSettingsService.
     *****************************************************************************/
    @TestVisible
    private RelationshipLookupSettingsService locateRelationshipLookupSettingsService() {
        return RelationshipLookupSettingsService.getInstance();
    }
}
