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
 * @group
 * @group-content ../../ApexDocContent/EdaSettings.htm
 * @description View mapper to generate view models associated with Primary Affiliations Settings funtionality.
 */
public virtual with sharing class AutoEnrollmentMappingsVMapper {
    /**********************************************************************************
     * @description Instance for Singleton Pattern
     **********************************************************************************/
    @TestVisible
    private static AutoEnrollmentMappingsVMapper instance;

    /**********************************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************************/
    protected AutoEnrollmentMappingsVMapper() {
    }

    /**********************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of AffiliationsSettingsVMapper.
     **********************************************************************************/
    public static AutoEnrollmentMappingsVMapper getInstance() {
        if (instance == null) {
            instance = new AutoEnrollmentMappingsVMapper();
        }

        return instance;
    }

    /**********************************************************************************************************
     * @description Retrieve an instance of AutoEnrollmentMappingsVModel
     * @return An instance of AutoEnrollmentMappingsVModel
     *********************************************************************************************************/
    public virtual AutoEnrollmentMappingsVModel getAutoEnrollmentMappingsVModel() {
        List<AffiliationMappingsModel> affiliationMappingsModelsList = this.locateAffiliationMappingsService()
            .getAffiliationMappingsModels();

        Map<Id, RecordTypeModel> accRecordTypeModelsById = this.locateRecordTypeService()
            .getModelByIdMapForSObjectType(Account.SObjectType);

        Map<String, RecordTypeModel> accountRecordTypeModelsByName = this.locateRecordTypeService()
            .getRecordTypeModelMapByName(accRecordTypeModelsById);
        Map<String, RecordTypeModel> accountRecordTypeModelsByLabel = this.locateRecordTypeService()
            .getRecordTypeModelMapByLabel(accRecordTypeModelsById);

        List<AutoEnrollmentMappingVModel> autoEnrollmentMappingVModelsList = new List<AutoEnrollmentMappingVModel>();

        for (AffiliationMappingsModel affiliationMappingsModel : affiliationMappingsModelsList) {
            if (affiliationMappingsModel.autoProgramEnrollment != false) {
                autoEnrollmentMappingVModelsList.add(
                    this.getAutoEnrollmentMappingVModel(
                        affiliationMappingsModel,
                        accountRecordTypeModelsByName,
                        accountRecordTypeModelsByLabel
                    )
                );
            }
        }

        return new AutoEnrollmentMappingsVModel(autoEnrollmentMappingVModelsList);
    }

    /**********************************************************************************************************
     * @description Generate a view model representing the auto enrollment mapping.
     * @param  affiliationMappingsModel A model representing the affililation mapping
     * @param  accountRecordTypeModelsByName A Map of Account Record Type models by developer name
     * @param  accountRecordTypeModelsByLabel A Map of Account Record Type models by label
     * @return An instance of AutoEnrollmentMappingVModel
     **********************************************************************************************************/
    @TestVisible
    protected AutoEnrollmentMappingVModel getAutoEnrollmentMappingVModel(
        AffiliationMappingsModel affiliationMappingsModel,
        Map<String, RecordTypeModel> accountRecordTypeModelsByName,
        Map<String, RecordTypeModel> accountRecordTypeModelsByLabel
    ) {
        String accountRecordTypeName = affiliationMappingsModel.accountRecordTypeFieldValue;
        String accountRecordTypeLabel = affiliationMappingsModel.accountRecordTypeFieldValue;

        // get RecordType model matching Account Record Type specified in Affiliation mapping
        RecordTypeModel recordTypeModel = this.locateRecordTypeService()
            .getRecordTypeModelFromNameAndLabelMaps(
                affiliationMappingsModel.accountRecordTypeFieldValue,
                accountRecordTypeModelsByName,
                accountRecordTypeModelsByLabel
            );

        if (recordTypeModel != null) {
            accountRecordTypeName = recordTypeModel.developerName;
            accountRecordTypeLabel = recordTypeModel.name;
        }
        return new AutoEnrollmentMappingVModel(
            affiliationMappingsModel.Name,
            accountRecordTypeName,
            accountRecordTypeLabel,
            affiliationMappingsModel.autoProgramEnrollmentStatus == '""'
                ? ''
                : affiliationMappingsModel.autoProgramEnrollmentStatus,
            affiliationMappingsModel.autoProgramEnrollmentRole == '""'
                ? ''
                : affiliationMappingsModel.autoProgramEnrollmentRole
        );
    }

    /**********************************************************************************************************
     * @description Retrieve an integer representing the number of unmapped record types
     * @return The number of unmapped record types.
     *********************************************************************************************************/
    public virtual Boolean unmappedRecordTypesExist() {
        Map<Id, RecordTypeModel> accRecordTypeModelsById = this.locateRecordTypeService()
            .getModelByIdMapForSObjectType(Account.SObjectType);

        Map<String, RecordTypeModel> accountRecordTypeModelsByName = this.locateRecordTypeService()
            .getRecordTypeModelMapByName(accRecordTypeModelsById);
        Map<String, RecordTypeModel> accountRecordTypeModelsByLabel = this.locateRecordTypeService()
            .getRecordTypeModelMapByLabel(accRecordTypeModelsById);

        List<AffiliationMappingsModel> affiliationMappingsModels = this.locateAffiliationMappingsService()
            .getAffiliationMappingsModels();

        Set<String> accountRecordTypesWithAffiliationMapping = new Set<String>();

        for (AffiliationMappingsModel affiliationMappingsModel : affiliationMappingsModels) {
            if (affiliationMappingsModel.autoProgramEnrollment == false) {
                return true;
            }
        }

        return false;
    }

    /**********************************************************************************************************
     * @description Retrieve a ComboBoxVModel for all active account record types
     * @return  A ComboBoxVModel
     *********************************************************************************************************/
    public virtual ComboBoxVModel getAccountRecordTypeComboboxVModel(String accountRecordType) {
        String comboboxValue = accountRecordType;
        List<ComboboxValueVModel> comboboxValues = new List<ComboboxValueVModel>();

        Map<Id, RecordTypeModel> accRecordTypeModelsById = this.locateRecordTypeService()
            .getModelByIdMapForSObjectType(Account.SObjectType);

        Map<String, RecordTypeModel> accountRecordTypeModelsByName = this.locateRecordTypeService()
            .getRecordTypeModelMapByName(accRecordTypeModelsById);
        Map<String, RecordTypeModel> accountRecordTypeModelsByLabel = this.locateRecordTypeService()
            .getRecordTypeModelMapByLabel(accRecordTypeModelsById);

        if (String.isBlank(accountRecordType)) {
            comboboxValues.addAll(
                this.getComboboxVModelOptionsForActiveAccountRecordTypes(
                    accRecordTypeModelsById.values(),
                    accountRecordType
                )
            );

            return new ComboboxVModel(comboboxValue, comboboxValues);
        }

        RecordTypeModel recordTypeModel = this.locateRecordTypeService()
            .getRecordTypeModelFromNameAndLabelMaps(
                accountRecordType,
                accountRecordTypeModelsByName,
                accountRecordTypeModelsByLabel
            );

        if (recordTypeModel == null) {
            comboboxValues.add(new ComboboxValueVModel(accountRecordType, accountRecordType));
        } else {
            comboboxValue = recordTypeModel.developerName;
        }
        comboboxValues.addAll(
            this.getComboboxVModelOptionsForActiveAccountRecordTypes(
                accRecordTypeModelsById.values(),
                accountRecordType
            )
        );

        return new ComboboxVModel(comboboxValue, comboboxValues);
    }

    /**********************************************************************************************************************
     * @description Helper method to generate a list of comboboxValueVModels for all active Account record types.
     * @param  activeAccountRecordTypeModelsList A list of RecordType models corresponding to active Account record types.
     * @return A List<ComboboxValueVModel> containing comboboxValueVModels for all active Account record types.
     **********************************************************************************************************************/
    @TestVisible
    private List<ComboboxValueVModel> getComboboxVModelOptionsForActiveAccountRecordTypes(
        List<RecordTypeModel> activeAccountRecordTypeModelsList,
        String accountRecordType
    ) {
        List<ComboboxValueVModel> activeRecordTypeComboboxValueVModelsList = new List<ComboboxValueVModel>();
        List<AffiliationMappingsModel> affiliationMappingsModels = this.locateAffiliationMappingsService()
            .getAffiliationMappingsModels();
        Set<String> accountRecordTypesWithAffiliationMapping = new Set<String>();

        for (AffiliationMappingsModel affiliationMappingsModel : affiliationMappingsModels) {
            if (
                affiliationMappingsModel.autoProgramEnrollment == false ||
                affiliationMappingsModel.accountRecordTypeFieldValue == accountRecordType
            ) {
                accountRecordTypesWithAffiliationMapping.add(affiliationMappingsModel.accountRecordTypeFieldValue);
            }
        }

        for (RecordTypeModel activeAccountRecordTypeModel : activeAccountRecordTypeModelsList) {
            if (accountRecordTypesWithAffiliationMapping.contains(activeAccountRecordTypeModel.developerName)) {
                activeRecordTypeComboboxValueVModelsList.add(
                    new ComboboxValueVModel(
                        activeAccountRecordTypeModel.name,
                        activeAccountRecordTypeModel.developerName
                    )
                );
            }
        }

        return activeRecordTypeComboboxValueVModelsList;
    }

    /**********************************************************************************************************
     * @description Retrieve a ComboBoxVModel for auto enrollment mapping status
     * @return  A ComboBoxVModel
     *********************************************************************************************************/
    public virtual ComboBoxVModel getAutoEnrollmentMappingStatusComboboxVModel(String autoProgramEnrollmentStatus) {
        String comboboxValue = autoProgramEnrollmentStatus;
        List<ComboboxValueVModel> comboboxOptions = new List<ComboboxValueVModel>();

        Map<String, PicklistEntryModel> statusPicklistEntryModelByName = this.locatePicklistEntryService()
            .getModelsByNameForSObjectField(Affiliation__c.SObjectType, Affiliation__c.Status__c);

        Map<String, PicklistEntryModel> activeStatusPicklistEntryModelByName = this.locatePicklistEntryService()
            .getActivePicklistEntryModelsByName(statusPicklistEntryModelByName);

        for (PicklistEntryModel picklistEntryModel : activeStatusPicklistEntryModelByName.values()) {
            comboboxOptions.add(new ComboboxValueVModel(picklistEntryModel.label, picklistEntryModel.name));
        }

        return new ComboboxVModel(comboboxValue, comboboxOptions);
    }

    /**********************************************************************************************************
     * @description Retrieve a ComboBoxVModel for auto enrollment mapping status
     * @return  A ComboBoxVModel
     *********************************************************************************************************/
    public virtual ComboBoxVModel getAutoEnrollmentMappingRoleComboboxVModel(String autoProgramEnrollmentRole) {
        String comboboxValue = autoProgramEnrollmentRole;

        List<ComboboxValueVModel> comboboxOptions = new List<ComboboxValueVModel>();

        Map<String, PicklistEntryModel> rolePicklistEntryModelByName = this.locatePicklistEntryService()
            .getModelsByNameForSObjectField(Affiliation__c.SObjectType, Affiliation__c.Role__c);

        Map<String, PicklistEntryModel> activeRolePicklistEntryModelByName = this.locatePicklistEntryService()
            .getActivePicklistEntryModelsByName(rolePicklistEntryModelByName);

        for (PicklistEntryModel picklistEntryModel : activeRolePicklistEntryModelByName.values()) {
            comboboxOptions.add(new ComboboxValueVModel(picklistEntryModel.label, picklistEntryModel.name));
        }

        return new ComboboxVModel(comboboxValue, comboboxOptions);
    }

    /*****************************************************************************
     * @description Retrieve an instance of the AffiliationMappingsService class.
     * @return An instance of AffiliationMappingsService.
     *****************************************************************************/
    @TestVisible
    private AffiliationMappingsService locateAffiliationMappingsService() {
        return AffiliationMappingsService.getInstance();
    }

    /*****************************************************************************
     * @description Retrieve an instance of the RecordTypeService class.
     * @return An instance of RecordTypeService.
     *****************************************************************************/
    @TestVisible
    private RecordTypeService locateRecordTypeService() {
        return RecordTypeService.getInstance();
    }

    /*****************************************************************************
     * @description Retrieve an instance of the PicklistEntryService class.
     * @return An instance of PicklistEntryService.
     *****************************************************************************/
    @TestVisible
    private PicklistEntryService locatePicklistEntryService() {
        return PicklistEntryService.getInstance();
    }
}
