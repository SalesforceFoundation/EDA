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
public virtual with sharing class PrimaryAffiliationsSettingsVMapper {
    /**********************************************************************************
     * @description Instance for Singleton Pattern
     **********************************************************************************/
    @TestVisible
    private static PrimaryAffiliationsSettingsVMapper instance;

    /**********************************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************************/
    protected PrimaryAffiliationsSettingsVMapper() {
    }

    /**********************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of AffiliationsSettingsVMapper.
     **********************************************************************************/
    public static PrimaryAffiliationsSettingsVMapper getInstance() {
        if (instance == null) {
            instance = new PrimaryAffiliationsSettingsVMapper();
        }

        return instance;
    }

    /**********************************************************************************************************
     * @description Retrieve a PrimaryffiliationsSettingsVModel for affiliations mappings
     * @return  A PrimaryffiliationsSettingsVModel
     *********************************************************************************************************/
    public virtual PrimaryAffiliationSettingsVModel getPrimaryAffiliationsSettingsVModel() {
        List<AffiliationMappingsModel> affiliationMappingsModelsList = this.locateAffiliationMappingsService()
            .getAffiliationMappingsModels();

        Map<Id, RecordTypeModel> accRecordTypeModelsById = this.locateRecordTypeService()
            .getModelByIdMapForSObjectType(Account.SObjectType);

        Map<String, RecordTypeModel> accountRecordTypeModelsByName = this.locateRecordTypeService()
            .getRecordTypeModelMapByName(accRecordTypeModelsById);
        Map<String, RecordTypeModel> accountRecordTypeModelsByLabel = this.locateRecordTypeService()
            .getRecordTypeModelMapByLabel(accRecordTypeModelsById);

        Map<String, LookupFieldModel> accountLookupsOnContactFieldModelsByName = this.locateLookupFieldService()
            .getModelByNameMapForSObjectType(Contact.SObjectType, Account.SObjectType);
        Map<String, LookupFieldModel> accountLookupsOnContactFieldModelsByLabel = this.locateLookupFieldService()
            .getModelByLabelMapForSObjectType(accountLookupsOnContactFieldModelsByName);

        List<PrimaryAffiliationMappingVModel> primaryAffiliationMappingVModelList = new List<PrimaryAffiliationMappingVModel>();

        for (AffiliationMappingsModel affiliationMappingsModel : affiliationMappingsModelsList) {
            primaryAffiliationMappingVModelList.add(
                this.getPrimaryAffiliationsMappingVModel(
                    affiliationMappingsModel,
                    accountRecordTypeModelsByName,
                    accountRecordTypeModelsByLabel,
                    accountLookupsOnContactFieldModelsByName,
                    accountLookupsOnContactFieldModelsByLabel
                )
            );
        }

        return new PrimaryAffiliationSettingsVModel(primaryAffiliationMappingVModelList);
    }

    /**********************************************************************************************************
     * @description Generate a view model representing the settings specified for an affiliation mapping.
     * @param  affiliationMappingsModel A model representing the affililation mapping
     * @param  accountRecordTypeModelsByName A Map of Account Record Type models by developer name
     * @param  accountRecordTypeModelsByLabel A Map of Account Record Type models by label
     * @param  accountLookupsOnContactFieldModelsByName A Map of Lookup fields of type Account on the Contact object by name
     * @param  accountLookupsOnContactFieldModelsByLabel A Map of Lookup fields of type Account on the Contact object by label
     * @return A PrimaryAffiliationMappingVModel
     **********************************************************************************************************/
    @TestVisible
    protected PrimaryAffiliationMappingVModel getPrimaryAffiliationsMappingVModel(
        AffiliationMappingsModel affiliationMappingsModel,
        Map<String, RecordTypeModel> accountRecordTypeModelsByName,
        Map<String, RecordTypeModel> accountRecordTypeModelsByLabel,
        Map<String, LookupFieldModel> accountLookupsOnContactFieldModelsByName,
        Map<String, LookupFieldModel> accountLookupsOnContactFieldModelsByLabel
    ) {
        String accountRecordTypeName = affiliationMappingsModel.accountRecordTypeFieldValue;
        String accountRecordTypeLabel = affiliationMappingsModel.accountRecordTypeFieldValue;
        String contactFieldName = affiliationMappingsModel.primaryAffiliationField;
        String contactFieldLabel = affiliationMappingsModel.primaryAffiliationField;

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

        // get LookupField model matching Primary Affiliation Field specified in Affiliation mapping
        LookupFieldModel lookupFieldModel = this.locateLookupFieldService()
            .getLookupFieldModelFromNameAndLabelMaps(
                affiliationMappingsModel.primaryAffiliationField,
                accountLookupsOnContactFieldModelsByName,
                accountLookupsOnContactFieldModelsByLabel
            );

        if (lookupFieldModel != null) {
            contactFieldName = lookupFieldModel.name;
            contactFieldLabel = lookupFieldModel.label;
        }

        return new PrimaryAffiliationMappingVModel(
            affiliationMappingsModel.name,
            accountRecordTypeName,
            accountRecordTypeLabel,
            contactFieldName,
            contactFieldLabel,
            affiliationMappingsModel.autoProgramEnrollment
        );
    }

    /**********************************************************************************************************
     * @description Retrieve a ComboBoxVModel for all active account record types
     * @return  A ComboBoxVModel
     *********************************************************************************************************/
    public virtual ComboBoxVModel getAccountRecordTypeComboboxVModel(String recordTypeToCheck) {
        String comboboxValue = recordTypeToCheck;
        List<ComboboxValueVModel> comboboxValues = new List<ComboboxValueVModel>();

        Map<Id, RecordTypeModel> accRecordTypeModelsById = this.locateRecordTypeService()
            .getModelByIdMapForSObjectType(Account.SObjectType);

        Map<String, RecordTypeModel> accountRecordTypeModelsByName = this.locateRecordTypeService()
            .getRecordTypeModelMapByName(accRecordTypeModelsById);
        Map<String, RecordTypeModel> accountRecordTypeModelsByLabel = this.locateRecordTypeService()
            .getRecordTypeModelMapByLabel(accRecordTypeModelsById);

        if (String.isBlank(recordTypeToCheck)) {
            comboboxValues.addAll(
                this.getComboboxVModelOptionsForActiveAccountRecordTypes(accRecordTypeModelsById.values())
            );

            return new ComboboxVModel(comboboxValue, comboboxValues);
        }

        RecordTypeModel recordTypeModel = this.locateRecordTypeService()
            .getRecordTypeModelFromNameAndLabelMaps(
                recordTypeToCheck,
                accountRecordTypeModelsByName,
                accountRecordTypeModelsByLabel
            );

        if (recordTypeModel == null) {
            comboboxValues.add(new ComboboxValueVModel(recordTypeToCheck, recordTypeToCheck));
        } else {
            comboboxValue = recordTypeModel.developerName;
        }

        comboboxValues.addAll(
            this.getComboboxVModelOptionsForActiveAccountRecordTypes(accRecordTypeModelsById.values())
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
        List<RecordTypeModel> activeAccountRecordTypeModelsList
    ) {
        List<ComboboxValueVModel> activeRecordTypeComboboxValueVModelsList = new List<ComboboxValueVModel>();

        for (RecordTypeModel activeAccountRecordTypeModel : activeAccountRecordTypeModelsList) {
            activeRecordTypeComboboxValueVModelsList.add(
                new ComboboxValueVModel(activeAccountRecordTypeModel.name, activeAccountRecordTypeModel.developerName)
            );
        }

        return activeRecordTypeComboboxValueVModelsList;
    }

    /**********************************************************************************************************
     * @description Retrieve a ComboBoxVModel for all Contact Account Lookup Fields
     * @return  A ComboBoxVModel
     *********************************************************************************************************/
    public virtual ComboBoxVModel getContactAccountLookupFieldComboboxVModel(String contactFieldToCheck) {
        String comboboxValue = contactFieldToCheck;
        List<ComboboxValueVModel> comboboxValues = new List<ComboboxValueVModel>();

        Map<String, LookupFieldModel> accountLookupsOnContactFieldModelsByName = this.locateLookupFieldService()
            .getModelByNameMapForSObjectType(Contact.SObjectType, Account.SObjectType);
        Map<String, LookupFieldModel> accountLookupsOnContactFieldModelsByLabel = this.locateLookupFieldService()
            .getModelByLabelMapForSObjectType(accountLookupsOnContactFieldModelsByName);

        if (String.isBlank(contactFieldToCheck)) {
            comboboxValues.addAll(
                this.getComboboxVModelOptionsForContactAccountLookupFields(
                    accountLookupsOnContactFieldModelsByName.values()
                )
            );

            return new ComboboxVModel(comboboxValue, comboboxValues);
        }

        LookupFieldModel lookupFieldModel = this.locateLookupFieldService()
            .getLookupFieldModelFromNameAndLabelMaps(
                contactFieldToCheck,
                accountLookupsOnContactFieldModelsByName,
                accountLookupsOnContactFieldModelsByLabel
            );

        if (lookupFieldModel == null) {
            comboboxValues.add(new ComboboxValueVModel(contactFieldToCheck, contactFieldToCheck));
        } else {
            comboboxValue = lookupFieldModel.name;
        }

        comboboxValues.addAll(
            this.getComboboxVModelOptionsForContactAccountLookupFields(
                accountLookupsOnContactFieldModelsByName.values()
            )
        );

        return new ComboboxVModel(comboboxValue, comboboxValues);
    }

    /**********************************************************************************************************************
     * @description Helper method to generate a list of comboboxValueVModels for all Contact Account Lookup Fields.
     * @param  contactLookupFieldModelList A list of LookupField models corresponding to Contact Account Lookup Fields.
     * @return A List<ComboboxValueVModel> containing comboboxValueVModels for all Contact Account Lookup Fields.
     **********************************************************************************************************************/
    @TestVisible
    private List<ComboboxValueVModel> getComboboxVModelOptionsForContactAccountLookupFields(
        List<LookupFieldModel> contactLookupFieldModelList
    ) {
        List<ComboboxValueVModel> contactAccountLookupFieldComboboxValueVModelsList = new List<ComboboxValueVModel>();

        for (LookupFieldModel contactLookupFieldModel : contactLookupFieldModelList) {
            contactAccountLookupFieldComboboxValueVModelsList.add(
                new ComboboxValueVModel(contactLookupFieldModel.label, contactLookupFieldModel.name)
            );
        }

        return contactAccountLookupFieldComboboxValueVModelsList;
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
     * @description Retrieve an instance of the LookupFieldService class.
     * @return An instance of LookupFieldService.
     *****************************************************************************/
    @TestVisible
    private LookupFieldService locateLookupFieldService() {
        return LookupFieldService.getInstance();
    }
}
