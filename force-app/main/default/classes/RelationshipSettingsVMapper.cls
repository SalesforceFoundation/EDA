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
 * @group EDA Settings
 * @group-content ../../ApexDocContent/edaSettings.htm
 * @description View Mapper class used to retrieve hierarchy setting mappings
 * related to Relationship settings.
 */
public virtual with sharing class RelationshipSettingsVMapper {
    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static RelationshipSettingsVMapper instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected RelationshipSettingsVMapper() {
    }

    /*****************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of RelationshipSettingsVMapper.
     ******************************************************************************/
    public static RelationshipSettingsVMapper getInstance() {
        if (instance == null) {
            instance = new RelationshipSettingsVMapper();
        }

        return instance;
    }

    /*****************************************************************************
     * @description Retrieve a model representing relationship settings values
     * from hierarchy settings and all available values
     * @return An RelationshipSettingsVModel
     *****************************************************************************/
    public virtual RelationshipSettingsVModel getRelationshipSettingsVModel() {
        // retrieve current relationship settings from Hierarchy settings
        RelationshipSettingsModel currentRelationshipSettingsModel = this.locateRelationshipSettingsService()
            .getRelationshipSettingsModel();

        // populate available combobox options with available reciprocal method values
        List<ComboboxValueVModel> relationshipTypeComboboxValueVModelsList = this.getReciprocalMethodTypesComboboxValueVModelList();

        // generate comboboxVModels for each reciprocal setting with selected value set as current value in hierarchy settings
        ComboboxVModel defaultRelationshipComboboxVModel = new ComboboxVModel(
            currentRelationshipSettingsModel.reciprocalMethod,
            relationshipTypeComboboxValueVModelsList
        );

        return new RelationshipSettingsVModel(defaultRelationshipComboboxVModel);
    }

    /*****************************************************************************
     * @description Returns a List of ComboboxValueVModel for reciporcal methods
     * @return Returns a List of ComboboxValueVModel for reciporcal methods
     ******************************************************************************/
    @TestVisible
    private List<ComboboxValueVModel> getReciprocalMethodTypesComboboxValueVModelList() {
        ComboboxValueVModel listSettingComboboxValueVModel = new ComboboxValueVModel(
            Label.stgReciprocalMethodListSetting,
            'List Setting'
        );
        ComboboxValueVModel valueInversionComboboxValueVModel = new ComboboxValueVModel(
            Label.stgReciprocalMethodValueInversion,
            'Value Inversion'
        );
        List<ComboboxValueVModel> relationshipTypeComboboxValueVModelsList = new List<ComboboxValueVModel>();

        relationshipTypeComboboxValueVModelsList.add(listSettingComboboxValueVModel);
        relationshipTypeComboboxValueVModelsList.add(valueInversionComboboxValueVModel);

        return relationshipTypeComboboxValueVModelsList;
    }

    /*****************************************************************************
     * @description Retrieves an instance of the RelationshipSettingsService class.
     * @return An instance of RelationshipSettingsService.
     ******************************************************************************/
    @TestVisible
    private RelationshipSettingsService locateRelationshipSettingsService() {
        return RelationshipSettingsService.getInstance();
    }
}
