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
 * @group Health Check
 * @group-content ../../ApexDocContent/HealthCheck.htm
 * @description Generate a HealthCheckGroup view model representing the results of
 * an Affiliation Mappings health check.
 */
public virtual with sharing class AffiliationMappingsHealthCheckVMapper {
    /**********************************************************************************
     * @description Instance for Singleton Pattern
     **********************************************************************************/
    @TestVisible
    private static AffiliationMappingsHealthCheckVMapper instance;

    /**********************************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************************/
    protected AffiliationMappingsHealthCheckVMapper() {
    }

    /**********************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of AffiliationMappingsHealthCheckVMapper.
     **********************************************************************************/
    public static AffiliationMappingsHealthCheckVMapper getInstance() {
        if (instance == null) {
            instance = new AffiliationMappingsHealthCheckVMapper();
        }

        return instance;
    }

    /**********************************************************************************
     * @description Retrieve the results for a for an AffiliationMappings health check.
     * @return A HealthCheckGroupVModel representing a HealtCheckDescription for Affiliations.
     **********************************************************************************/
    public virtual HealthCheckGroupVModel getHealthCheckGroup() {
        HealthCheckGroupVModel parentHealthCheckGroupVModel = new HealthCheckGroupVModel();
        parentHealthCheckGroupVModel.label = Label.stgHealthCheckAffiliationMappings;

        List<AffiliationMappingsModel> affiliationMappingsModelsList = this.locateAffiliationMappingsService()
            .getAffiliationMappingsModels();

        Map<Id, RecordTypeModel> accRecordTypeModelsById = this.locateRecordTypeService()
            .getModelByIdMapForSObjectType(Account.SObjectType);

        Map<String, RecordTypeModel> accountRecordTypeModelsByName = this.locateRecordTypeService()
            .getRecordTypeModelMapByName(accRecordTypeModelsById);
        Map<String, RecordTypeModel> accountRecordTypeModelsByLabel = this.locateRecordTypeService()
            .getRecordTypeModelMapByLabel(accRecordTypeModelsById);
        Set<Id> duplicateAccountRecordTypeIds = this.getDuplicateAccountRecordTypeIds(
            affiliationMappingsModelsList,
            accountRecordTypeModelsByName,
            accountRecordTypeModelsByLabel
        );
        Map<String, LookupFieldModel> accountLookupsOnContactFieldModelsByName = this.locateLookupFieldService()
            .getModelByNameMapForSObjectType(Contact.SObjectType, Account.SObjectType);
        Map<String, LookupFieldModel> accountLookupsOnContactFieldModelsByLabel = this.locateLookupFieldService()
            .getModelByLabelMapForSObjectType(accountLookupsOnContactFieldModelsByName);
        Set<String> duplicateLookupFieldModelNames = this.getduplicateLookupFieldModelNames(
            affiliationMappingsModelsList,
            accountLookupsOnContactFieldModelsByName,
            accountLookupsOnContactFieldModelsByLabel
        );
        Map<String, PicklistEntryModel> affilationRolePicklistEntryModelByName = this.locatePicklistEntryService()
            .getModelsByNameForSObjectField(Affiliation__c.SObjectType, Affiliation__c.Role__c);
        Map<String, PicklistEntryModel> affilationStatusPicklistEntryModelByName = this.locatePicklistEntryService()
            .getModelsByNameForSObjectField(Affiliation__c.SObjectType, Affiliation__c.Status__c);

        List<HealthCheckGroupVModel> childHealthCheckGroupVModelsList = new List<HealthCheckGroupVModel>();

        for (AffiliationMappingsModel affiliationMappingsModel : affiliationMappingsModelsList) {
            RecordTypeModel accountRecordTypeModel = this.locateRecordTypeService()
                .getRecordTypeModelFromNameAndLabelMaps(
                    affiliationMappingsModel.accountRecordTypeFieldValue,
                    accountRecordTypeModelsByName,
                    accountRecordTypeModelsByLabel
                );

            LookupFieldModel accountLookupFieldOnContactFieldModel = this.locateLookupFieldService()
                .getLookupFieldModelFromNameAndLabelMaps(
                    affiliationMappingsModel.primaryAffiliationField,
                    accountLookupsOnContactFieldModelsByName,
                    accountLookupsOnContactFieldModelsByLabel
                );

            HealthCheckGroupVModel childAffiliationMappingsHealthCheckResults = this.getAffiliationMappingsHealthCheckResults(
                affiliationMappingsModel,
                accountRecordTypeModel,
                accountLookupFieldOnContactFieldModel,
                affilationRolePicklistEntryModelByName,
                affilationStatusPicklistEntryModelByName,
                duplicateAccountRecordTypeIds,
                duplicateLookupFieldModelNames
            );

            // Add results from child health check group results to parent
            parentHealthCheckGroupVModel.passedChecks += childAffiliationMappingsHealthCheckResults.passedChecks;
            parentHealthCheckGroupVModel.totalChecks += childAffiliationMappingsHealthCheckResults.totalChecks;
            parentHealthCheckGroupVModel.expandedRowsList.addAll(
                childAffiliationMappingsHealthCheckResults.expandedRowsList
            );
            parentHealthCheckGroupVModel.healthCheckItemList.addAll(
                childAffiliationMappingsHealthCheckResults.healthCheckItemList
            );
        }

        parentHealthCheckGroupVModel.updateHealthCheckStatus();
        parentHealthCheckGroupVModel.healthCheckItemList.sort();

        return parentHealthCheckGroupVModel;
    }

    /**********************************************************************************
     * @description generates a single Health Check Group representing the results of all
     * sub health checks for a single affiliation mapping which includes health checks for:
     * Account Record Type
     * Record Type Uniqueness
     * Contact Primary Affiliation Field
     * Contact Primary Affiliation Field Uniqueness
     * Auto-Enrollment Status
     * Auto-Enrollment Role
     * @param affiliationMappingsModel A model representing an affiliation mapping in EDA Settings
     * @param accountRecordTypeModel A model of the Account Record Type specified in an affiliation mapping in EDA Settings
     * @param accountLookupFieldOnContactFieldModel A model of the Account lookup field on Contact representing
     * the primary affiliation field specied in an affiliation mapping in EDA Settings
     * @param affilationRolePicklistEntryModelByName A map of picklist values for Affiliation Role by devloper name
     * @param affilationStatusPicklistEntryModelByName A map of picklist values for Affiliation Status by devloper name
     * @param duplicateAccountRecordTypeIds A set of duplicate record type ids from affiliation mappings
     * @param duplicateLookupFieldModelNames A set of duplicate lookup field model names from affiliation mappings
     * @return A HealthCheckGroupVModel
     **********************************************************************************/
    @TestVisible
    private virtual HealthCheckGroupVModel getAffiliationMappingsHealthCheckResults(
        AffiliationMappingsModel affiliationMappingsModel,
        RecordTypeModel accountRecordTypeModel,
        LookupFieldModel accountLookupFieldOnContactFieldModel,
        Map<String, PicklistEntryModel> affilationRolePicklistEntryModelByName,
        Map<String, PicklistEntryModel> affilationStatusPicklistEntryModelByName,
        Set<Id> duplicateAccountRecordTypeIds,
        Set<String> duplicateLookupFieldModelNames
    ) {
        HealthCheckGroupVModel parentHealthCheckGroupVModel = new HealthCheckGroupVModel();

        HealthCheckItemVModel childHealthCheckItemVModel = this.getHealthCheckItemVModelForAffiliationMappingsModel(
            affiliationMappingsModel,
            accountRecordTypeModel
        );

        List<HealthCheckGroupVModel> childHealthCheckGroupVModelList = new List<HealthCheckGroupVModel>();

        // add Account Record Type Health Check results
        childHealthCheckGroupVModelList.add(
            this.getValidRecordTypeHealthCheckGroupVModel(affiliationMappingsModel, accountRecordTypeModel)
        );

        // add Account Record Type Uniqueness Health Check results
        childHealthCheckGroupVModelList.add(
            this.getAccountRecordTypeUniquenessHealthCheckGroupVModel(
                affiliationMappingsModel,
                accountRecordTypeModel,
                duplicateAccountRecordTypeIds
            )
        );

        // add Contact Primary Affiliation Field Health Check results
        childHealthCheckGroupVModelList.add(
            this.getValidContactPrimaryFieldHealthCheckGroupVModel(
                affiliationMappingsModel,
                accountLookupFieldOnContactFieldModel
            )
        );

        // add Contact Primary Affiliation Field Uniqueness Health Check results
        childHealthCheckGroupVModelList.add(
            this.getContactPrimaryFieldUniquenessHealthCheckGroupVModel(
                affiliationMappingsModel,
                accountLookupFieldOnContactFieldModel,
                duplicateLookupFieldModelNames
            )
        );

        // add Auto Enrollment Role Health Check results
        childHealthCheckGroupVModelList.add(
            this.getActiveExistingRoleHealthCheckGroupVModel(
                affiliationMappingsModel,
                affilationRolePicklistEntryModelByName
            )
        );

        // add Auto Enrollment Status Health Check results
        childHealthCheckGroupVModelList.add(
            this.getActiveExistingStatusHealthCheckGroupVModel(
                affiliationMappingsModel,
                affilationStatusPicklistEntryModelByName
            )
        );

        // combine results into a single HealthCheckGroupVModel
        for (HealthCheckGroupVModel childHealthCheckGroupVModel : childHealthCheckGroupVModelList) {
            parentHealthCheckGroupVModel.passedChecks += childHealthCheckGroupVModel.passedChecks;
            parentHealthCheckGroupVModel.totalChecks += childHealthCheckGroupVModel.totalChecks;
            parentHealthCheckGroupVModel.expandedRowsList.addAll(childHealthCheckGroupVModel.expandedRowsList);

            childHealthCheckItemVModel.healthCheckItemList.addAll(childHealthCheckGroupVModel.healthCheckItemList);
        }

        if (parentHealthCheckGroupVModel.passedChecks < parentHealthCheckGroupVModel.totalChecks) {
            childHealthCheckItemVModel.status = 'Fail';
            childHealthCheckItemVModel.statusLabel = Label.stgHealthCheckStatusFailed;
            parentHealthCheckGroupVModel.expandedRowsList.add(affiliationMappingsModel.name);
        }

        childHealthCheckItemVModel.healthCheckItemList.sort();

        parentHealthCheckGroupVModel.updateHealthCheckStatus();
        parentHealthCheckGroupVModel.healthCheckItemList.add(childHealthCheckItemVModel);

        return parentHealthCheckGroupVModel;
    }

    /***************************************************************************
     * @description Retrieves a formatted HealthCheckItemVModel.
     * @param  affiliationMappingsModel A model representing an affiliation mapping in EDA Settings
     * @param  recordTypeModel A record type model corresponding to the Account record type specified in the affiliation mapping.
     * @return A formatted HealthCheckItemVModel.
     ***************************************************************************/
    @TestVisible
    protected virtual HealthCheckItemVModel getHealthCheckItemVModelForAffiliationMappingsModel(
        AffiliationMappingsModel affiliationMappingsModel,
        RecordTypeModel recordTypeModel
    ) {
        String recordTypeModelName = affiliationMappingsModel.name;

        if (recordTypeModel != null) {
            recordTypeModelName = recordTypeModel.name;
        }

        List<String> listForSettingsLabel = new List<String>{ affiliationMappingsModel.accountRecordTypeFieldValue };
        List<String> listForDescriptionLabel = new List<String>{ affiliationMappingsModel.name, recordTypeModelName };

        return new HealthCheckItemVModel(
            affiliationMappingsModel.name,
            this.locateStringHandlingService()
                .formatStringWithApostrophesAndParameters(
                    Label.stgHCAffiliationMappingSettingHeading,
                    listForSettingsLabel
                ),
            'Pass',
            Label.stgHealthCheckStatusPassed,
            '',
            '',
            new List<HealthCheckItemVModel>()
        );
    }

    /**********************************************************************************
     * @description Retrieve a HealthCheckGroup view model reprenting whether enrollment
     * statuses specified in affiliation mappings correspond to valid picklist field values
     * listed in the Status picklist field on Affiliation__c.
     * @param affiliationMappingsModel A model representing an affiliation mapping in EDA Settings
     * @param picklistEntryModelByName A map of picklist values for Affiliation Status by devloper name
     * @return A HealthCheckGroupVModel
     **********************************************************************************/
    @TestVisible
    private virtual HealthCheckGroupVModel getActiveExistingStatusHealthCheckGroupVModel(
        AffiliationMappingsModel affiliationMappingsModel,
        Map<String, PicklistEntryModel> picklistEntryModelByName
    ) {
        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel();
        healthCheckGroupVModel.label = Label.stgHealthCheckAffiliationMappings;

        if (affiliationMappingsModel.autoProgramEnrollment != true) {
            return healthCheckGroupVModel;
        }

        if (picklistEntryModelByName.keySet().contains(affiliationMappingsModel.autoProgramEnrollmentStatus) == false) {
            // invalid mapping
            healthCheckGroupVModel.healthCheckItemList.add(
                new HealthCheckItemVModel(
                    '05',
                    Label.stgHCAfflMapAutoEnrollStatusTitle,
                    'Fail',
                    Label.stgHealthCheckStatusFailed,
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCAfflMapAutoEnrollStatusNotFound,
                            new List<Object>{ affiliationMappingsModel.autoProgramEnrollmentStatus }
                        ),
                    Label.stgHCAfflMapAutoEnrollStatusNotFoundFix,
                    new List<HealthCheckItemVModel>()
                )
            );

            healthCheckGroupVModel.totalChecks++;
            healthCheckGroupVModel.updateHealthCheckStatus();

            return healthCheckGroupVModel;
        }

        if (picklistEntryModelByName.get(affiliationMappingsModel.autoProgramEnrollmentStatus)?.isActive == false) {
            // valid mapping, but inactive
            healthCheckGroupVModel.healthCheckItemList.add(
                new HealthCheckItemVModel(
                    '05',
                    Label.stgHCAfflMapAutoEnrollStatusTitle,
                    'Fail',
                    Label.stgHealthCheckStatusFailed,
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCAfflMapAutoEnrollStatusInactive,
                            new List<Object>{
                                affiliationMappingsModel.autoProgramEnrollmentStatus,
                                picklistEntryModelByName.get(affiliationMappingsModel.autoProgramEnrollmentStatus).name
                            }
                        ),
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCAfflMapAutoEnrollStatusInactiveFix,
                            new List<Object>{
                                affiliationMappingsModel.autoProgramEnrollmentStatus,
                                picklistEntryModelByName.get(affiliationMappingsModel.autoProgramEnrollmentStatus).name
                            }
                        ),
                    new List<HealthCheckItemVModel>()
                )
            );

            healthCheckGroupVModel.totalChecks++;
            healthCheckGroupVModel.updateHealthCheckStatus();

            return healthCheckGroupVModel;
        }

        // valid and active
        healthCheckGroupVModel.healthCheckItemList.add(
            new HealthCheckItemVModel(
                '05',
                Label.stgHCAfflMapAutoEnrollStatusTitle,
                'Pass',
                Label.stgHealthCheckStatusPassed,
                this.locateStringHandlingService()
                    .formatStringWithApostrophesAndParameters(
                        Label.stgHCAfflMapAutoEnrollStatusValid,
                        new List<Object>{
                            picklistEntryModelByName.get(affiliationMappingsModel.autoProgramEnrollmentStatus).label,
                            picklistEntryModelByName.get(affiliationMappingsModel.autoProgramEnrollmentStatus).name
                        }
                    ),
                Label.stgHealthCheckFixNotApplicable,
                new List<HealthCheckItemVModel>()
            )
        );

        healthCheckGroupVModel.totalChecks++;
        healthCheckGroupVModel.passedChecks++;
        healthCheckGroupVModel.updateHealthCheckStatus();

        return healthCheckGroupVModel;
    }

    /**********************************************************************************
     * @description Retrieve a HealthCheckGroup view model reprenting whether enrollment
     * roles specified in affiliation mappings correspond to valid picklist field values
     * listed in the Role picklist field on Affiliation__c.
     * @param affiliationMappingsModel A model representing an affiliation mapping in EDA Settings
     * @param picklistEntryModelByName A map of picklist values for Affiliation Role by devloper name
     * @return A HealthCheckGroupVModel
     **********************************************************************************/
    @TestVisible
    private virtual HealthCheckGroupVModel getActiveExistingRoleHealthCheckGroupVModel(
        AffiliationMappingsModel affiliationMappingsModel,
        Map<String, PicklistEntryModel> picklistEntryModelByName
    ) {
        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel();
        healthCheckGroupVModel.label = Label.stgHealthCheckAffiliationMappings;

        if (affiliationMappingsModel.autoProgramEnrollment != true) {
            return healthCheckGroupVModel;
        }

        if (picklistEntryModelByName.keySet().contains(affiliationMappingsModel.autoProgramEnrollmentRole) == false) {
            // invalid mapping
            healthCheckGroupVModel.healthCheckItemList.add(
                new HealthCheckItemVModel(
                    '05',
                    Label.stgHCAfflMapAutoEnrollRoleTitle,
                    'Fail',
                    Label.stgHealthCheckStatusFailed,
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCAfflMapAutoEnrollRoleNotFound,
                            new List<Object>{ affiliationMappingsModel.autoProgramEnrollmentRole }
                        ),
                    Label.stgHCAfflMapAutoEnrollRoleNotFoundFix,
                    new List<HealthCheckItemVModel>()
                )
            );

            healthCheckGroupVModel.totalChecks++;
            healthCheckGroupVModel.updateHealthCheckStatus();
            return healthCheckGroupVModel;
        }

        if (picklistEntryModelByName.get(affiliationMappingsModel.autoProgramEnrollmentRole)?.isActive == false) {
            // valid mapping, but inactive
            healthCheckGroupVModel.healthCheckItemList.add(
                new HealthCheckItemVModel(
                    '05',
                    Label.stgHCAfflMapAutoEnrollRoleTitle,
                    'Fail',
                    Label.stgHealthCheckStatusFailed,
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCAfflMapAutoEnrollRoleInactive,
                            new List<Object>{
                                affiliationMappingsModel.autoProgramEnrollmentRole,
                                picklistEntryModelByName.get(affiliationMappingsModel.autoProgramEnrollmentRole).name
                            }
                        ),
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCAfflMapAutoEnrollRoleInactiveFix,
                            new List<Object>{
                                affiliationMappingsModel.autoProgramEnrollmentRole,
                                picklistEntryModelByName.get(affiliationMappingsModel.autoProgramEnrollmentRole).name
                            }
                        ),
                    new List<HealthCheckItemVModel>()
                )
            );

            healthCheckGroupVModel.totalChecks++;
            healthCheckGroupVModel.updateHealthCheckStatus();
            return healthCheckGroupVModel;
        }

        // valid and active
        healthCheckGroupVModel.healthCheckItemList.add(
            new HealthCheckItemVModel(
                '05',
                Label.stgHCAfflMapAutoEnrollRoleTitle,
                'Pass',
                Label.stgHealthCheckStatusPassed,
                this.locateStringHandlingService()
                    .formatStringWithApostrophesAndParameters(
                        Label.stgHCAfflMapAutoEnrollRoleValid,
                        new List<Object>{
                            picklistEntryModelByName.get(affiliationMappingsModel.autoProgramEnrollmentRole).label,
                            picklistEntryModelByName.get(affiliationMappingsModel.autoProgramEnrollmentRole).name
                        }
                    ),
                Label.stgHealthCheckFixNotApplicable,
                new List<HealthCheckItemVModel>()
            )
        );

        healthCheckGroupVModel.totalChecks++;
        healthCheckGroupVModel.passedChecks++;

        healthCheckGroupVModel.updateHealthCheckStatus();
        return healthCheckGroupVModel;
    }

    /**********************************************************************************
     * @description Retrieve a HealthCheckGroup view model reprenting whether primary
     * affiliation fields specified in affiliation mappings correspond to valid fields
     * on the Contact object that lookup to Account objects.
     * @param affiliationMappingsModel A model representing an affiliation mapping in EDA Settings
     * @param accountLookupFieldOnContactFieldModel A model representing the lookup field corresponding to the
     * primary affiliation field specified for an affiliation mapping in EDA Settings
     * @return A HealthCheckGroupVModel
     **********************************************************************************/
    @TestVisible
    private virtual HealthCheckGroupVModel getValidContactPrimaryFieldHealthCheckGroupVModel(
        AffiliationMappingsModel affiliationMappingsModel,
        LookupFieldModel accountLookupFieldOnContactFieldModel
    ) {
        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel();
        healthCheckGroupVModel.label = Label.stgHealthCheckAffiliationMappings;

        if (accountLookupFieldOnContactFieldModel == null) {
            healthCheckGroupVModel.healthCheckItemList.add(
                new HealthCheckItemVModel(
                    '03',
                    Label.stgHCAfflMapContactPrimaryFieldTitle,
                    'Fail',
                    Label.stgHealthCheckStatusFailed,
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCAfflMapContactPrimaryFieldInvalid,
                            new List<Object>{ affiliationMappingsModel.primaryAffiliationField }
                        ),
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCAfflMapContPrimaryFieldInvalidFix,
                            new List<Object>{ affiliationMappingsModel.primaryAffiliationField }
                        ),
                    new List<HealthCheckItemVModel>()
                )
            );

            healthCheckGroupVModel.totalChecks++;
            healthCheckGroupVModel.updateHealthCheckStatus();

            return healthCheckGroupVModel;
        }

        healthCheckGroupVModel.healthCheckItemList.add(
            new HealthCheckItemVModel(
                '03',
                Label.stgHCAfflMapContactPrimaryFieldTitle,
                'Pass',
                Label.stgHealthCheckStatusPassed,
                this.locateStringHandlingService()
                    .formatStringWithApostrophesAndParameters(
                        Label.stgHCAfflMapContactPrimaryFieldValid,
                        new List<Object>{
                            affiliationMappingsModel.primaryAffiliationField,
                            accountLookupFieldOnContactFieldModel.name
                        }
                    ),
                Label.stgHealthCheckFixNotApplicable,
                new List<HealthCheckItemVModel>()
            )
        );

        healthCheckGroupVModel.totalChecks++;
        healthCheckGroupVModel.passedChecks++;
        healthCheckGroupVModel.updateHealthCheckStatus();

        return healthCheckGroupVModel;
    }

    /**********************************************************************************
     * @description Retrieves a HealthCheckGroup view model representing the health check
     * results for Account Record Types specified.  Determines whether the Account
     * record type included in an affiliation mapping corresponds to a record
     * type for Account in the org that is active.
     * @param  affiliationMappingsModel A model representing an affiliation mapping in EDA Settings
     * @param  accountRecordTypeModel A model representing the Account record type specified for an affiliation mapping
     * @return A HealthCheckGroupVModel
     **********************************************************************************/
    @TestVisible
    private virtual HealthCheckGroupVModel getValidRecordTypeHealthCheckGroupVModel(
        AffiliationMappingsModel affiliationMappingsModel,
        RecordTypeModel accountRecordTypeModel
    ) {
        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel();
        healthCheckGroupVModel.label = Label.stgHealthCheckAffiliationMappings;

        if (accountRecordTypeModel == null) {
            healthCheckGroupVModel.healthCheckItemList.add(
                new HealthCheckItemVModel(
                    '01',
                    Label.stgHCAfflMapAccRecordTypeTitle,
                    'Fail',
                    Label.stgHealthCheckStatusFailed,
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCRecordTypeNotFound,
                            new List<Object>{ affiliationMappingsModel.accountRecordTypeFieldValue }
                        ),
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCAfflMapAccRecordTypeNotFoundFix,
                            new List<Object>{ affiliationMappingsModel.accountRecordTypeFieldValue }
                        ),
                    new List<HealthCheckItemVModel>()
                )
            );

            healthCheckGroupVModel.totalChecks++;
        } else if (accountRecordTypeModel.isActive == false) {
            healthCheckGroupVModel.healthCheckItemList.add(
                new HealthCheckItemVModel(
                    '01',
                    Label.stgHCAfflMapAccRecordTypeTitle,
                    'Fail',
                    Label.stgHealthCheckStatusFailed,
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCRecordTypeInactive,
                            new List<Object>{ accountRecordTypeModel.name, accountRecordTypeModel.developerName }
                        ),
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCAfflMapAccRecordTypeInactiveFix,
                            new List<Object>{ accountRecordTypeModel.name, accountRecordTypeModel.developerName }
                        ),
                    new List<HealthCheckItemVModel>()
                )
            );

            healthCheckGroupVModel.totalChecks++;
        } else {
            healthCheckGroupVModel.healthCheckItemList.add(
                new HealthCheckItemVModel(
                    '01',
                    Label.stgHCAfflMapAccRecordTypeTitle,
                    'Pass',
                    Label.stgHealthCheckStatusPassed,
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCRecordTypeValid,
                            new List<Object>{ accountRecordTypeModel.name, accountRecordTypeModel.developerName }
                        ),
                    Label.stgHealthCheckFixNotApplicable,
                    new List<HealthCheckItemVModel>()
                )
            );

            healthCheckGroupVModel.totalChecks++;
            healthCheckGroupVModel.passedChecks++;
        }

        healthCheckGroupVModel.updateHealthCheckStatus();
        return healthCheckGroupVModel;
    }

    /**********************************************************************************
     * @description Retrieves a HealthCheckGroup view model representing the health check
     * results for Account Record Types specified.  Determines whether the Account
     * record type included in an affiliation mapping is unique.
     * @param  affiliationMappingsModel A model representing an affiliation mapping in EDA Settings
     * @param  accountRecordTypeModel A model representing the Account record type specified for an affiliation mapping
     * @param  duplicateAccountRecordTypeFieldValues A list of duplicate accountRecordTypeFieldValues retrieved from Affiliation Mappings
     * @return A HealthCheckGroupVModel
     **********************************************************************************/
    @TestVisible
    private virtual HealthCheckGroupVModel getAccountRecordTypeUniquenessHealthCheckGroupVModel(
        AffiliationMappingsModel affiliationMappingsModel,
        RecordTypeModel accountRecordTypeModel,
        Set<Id> duplicateAccountRecordTypeIds
    ) {
        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel();
        healthCheckGroupVModel.label = Label.stgHealthCheckAffiliationMappings;

        // check account record type first
        if (accountRecordTypeModel == null) {
            healthCheckGroupVModel.healthCheckItemList.add(
                new HealthCheckItemVModel(
                    '02',
                    Label.stgHCAfflMapAccRecordTypeUniqueTitle,
                    'Fail',
                    Label.stgHealthCheckStatusFailed,
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCRecordTypeNotFound,
                            new List<Object>{ affiliationMappingsModel.accountRecordTypeFieldValue }
                        ),
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCAfflMapAccRecordTypeNotFoundFix,
                            new List<Object>{ affiliationMappingsModel.accountRecordTypeFieldValue }
                        ),
                    new List<HealthCheckItemVModel>()
                )
            );

            healthCheckGroupVModel.totalChecks++;
            healthCheckGroupVModel.updateHealthCheckStatus();
            return healthCheckGroupVModel;
        }

        if (accountRecordTypeModel.isActive == false) {
            healthCheckGroupVModel.healthCheckItemList.add(
                new HealthCheckItemVModel(
                    '02',
                    Label.stgHCAfflMapAccRecordTypeUniqueTitle,
                    'Fail',
                    Label.stgHealthCheckStatusFailed,
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCRecordTypeInactive,
                            new List<Object>{ accountRecordTypeModel.name, accountRecordTypeModel.developerName }
                        ),
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCAfflMapAccRecordTypeInactiveFix,
                            new List<Object>{ accountRecordTypeModel.name, accountRecordTypeModel.developerName }
                        ),
                    new List<HealthCheckItemVModel>()
                )
            );

            healthCheckGroupVModel.totalChecks++;
            healthCheckGroupVModel.updateHealthCheckStatus();
            return healthCheckGroupVModel;
        }

        if (duplicateAccountRecordTypeIds.contains(accountRecordTypeModel.Id)) {
            healthCheckGroupVModel.healthCheckItemList.add(
                new HealthCheckItemVModel(
                    '02',
                    Label.stgHCAfflMapAccRecordTypeUniqueTitle,
                    'Fail',
                    Label.stgHealthCheckStatusFailed,
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCAfflMapAccRecordTypeNotUnique,
                            new List<Object>{ accountRecordTypeModel.name, accountRecordTypeModel.developerName }
                        ),
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCAfflMapAccRecordTypeUniqueFix,
                            new List<Object>{ accountRecordTypeModel.name, accountRecordTypeModel.developerName }
                        ),
                    new List<HealthCheckItemVModel>()
                )
            );

            healthCheckGroupVModel.totalChecks++;
            healthCheckGroupVModel.updateHealthCheckStatus();
            return healthCheckGroupVModel;
        }

        healthCheckGroupVModel.healthCheckItemList.add(
            new HealthCheckItemVModel(
                '02',
                Label.stgHCAfflMapAccRecordTypeUniqueTitle,
                'Pass',
                Label.stgHealthCheckStatusPassed,
                this.locateStringHandlingService()
                    .formatStringWithApostrophesAndParameters(
                        Label.stgHCAfflMapAccRecordTypeUnique,
                        new List<Object>{ accountRecordTypeModel.name, accountRecordTypeModel.developerName }
                    ),
                Label.stgHealthCheckFixNotApplicable,
                new List<HealthCheckItemVModel>()
            )
        );

        healthCheckGroupVModel.totalChecks++;
        healthCheckGroupVModel.passedChecks++;
        healthCheckGroupVModel.updateHealthCheckStatus();
        return healthCheckGroupVModel;
    }

    /**********************************************************************************
     * @description Retrieves a HealthCheckGroup view model representing the health check
     * results for Account Record Types specified.  Determines whether the Contact
     * Primary Field included in an affiliation mapping is unique.
     * @param  affiliationMappingsModel A model representing an affiliation mapping in EDA Settings
     * @param  accountLookupFieldOnContactFieldModel A model representing the Account record type specified for an affiliation mapping
     * @param  duplicateLookupFieldModelNames A set of duplicate lookup field model names from affiliation mappings
     * @return A HealthCheckGroupVModel
     **********************************************************************************/
    @TestVisible
    private virtual HealthCheckGroupVModel getContactPrimaryFieldUniquenessHealthCheckGroupVModel(
        AffiliationMappingsModel affiliationMappingsModel,
        LookupFieldModel accountLookupFieldOnContactFieldModel,
        Set<String> duplicateLookupFieldModelNames
    ) {
        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel();
        healthCheckGroupVModel.label = Label.stgHealthCheckAffiliationMappings;

        // check lookup field first
        if (accountLookupFieldOnContactFieldModel == null) {
            healthCheckGroupVModel.healthCheckItemList.add(
                new HealthCheckItemVModel(
                    '04',
                    Label.stgHCAfflMapContPrimaryFieldUniqueTitle,
                    'Fail',
                    Label.stgHealthCheckStatusFailed,
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCAfflMapContactPrimaryFieldInvalid,
                            new List<Object>{ affiliationMappingsModel.primaryAffiliationField }
                        ),
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCAfflMapContPrimaryFieldInvalidFix,
                            new List<Object>{ affiliationMappingsModel.primaryAffiliationField }
                        ),
                    new List<HealthCheckItemVModel>()
                )
            );

            healthCheckGroupVModel.totalChecks++;
            healthCheckGroupVModel.updateHealthCheckStatus();
            return healthCheckGroupVModel;
        }

        if (duplicateLookupFieldModelNames.contains(accountLookupFieldOnContactFieldModel.name)) {
            healthCheckGroupVModel.healthCheckItemList.add(
                new HealthCheckItemVModel(
                    '04',
                    Label.stgHCAfflMapContPrimaryFieldUniqueTitle,
                    'Fail',
                    Label.stgHealthCheckStatusFailed,
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCAfflMapContactPrimaryFieldNotUnique,
                            new List<Object>{
                                accountLookupFieldOnContactFieldModel.label,
                                accountLookupFieldOnContactFieldModel.name
                            }
                        ),
                    this.locateStringHandlingService()
                        .formatStringWithApostrophesAndParameters(
                            Label.stgHCAfflMapContactPrimaryFieldUniqueFix,
                            new List<Object>{
                                accountLookupFieldOnContactFieldModel.label,
                                accountLookupFieldOnContactFieldModel.name
                            }
                        ),
                    new List<HealthCheckItemVModel>()
                )
            );

            healthCheckGroupVModel.totalChecks++;
            healthCheckGroupVModel.updateHealthCheckStatus();
            return healthCheckGroupVModel;
        }

        healthCheckGroupVModel.healthCheckItemList.add(
            new HealthCheckItemVModel(
                '04',
                Label.stgHCAfflMapContPrimaryFieldUniqueTitle,
                'Pass',
                Label.stgHealthCheckStatusPassed,
                this.locateStringHandlingService()
                    .formatStringWithApostrophesAndParameters(
                        Label.stgHCAfflMapContactPrimaryFieldUnique,
                        new List<Object>{
                            accountLookupFieldOnContactFieldModel.label,
                            accountLookupFieldOnContactFieldModel.name
                        }
                    ),
                Label.stgHealthCheckFixNotApplicable,
                new List<HealthCheckItemVModel>()
            )
        );

        healthCheckGroupVModel.totalChecks++;
        healthCheckGroupVModel.passedChecks++;
        healthCheckGroupVModel.updateHealthCheckStatus();
        return healthCheckGroupVModel;
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

    /*****************************************************************************
     * @description Retrieve an instance of the PicklistEntryService class.
     * @return An instance of PicklistEntryService.
     *****************************************************************************/
    @TestVisible
    private PicklistEntryService locatePicklistEntryService() {
        return PicklistEntryService.getInstance();
    }

    /*****************************************************************************
     * @description Retrieve an instance of the StringHandlingService class.
     * @return An instance of StringHandlingService.
     *****************************************************************************/
    @TestVisible
    private StringHandlingService locateStringHandlingService() {
        return StringHandlingService.getInstance();
    }

    /**********************************************************************************
     * @description Retrieves a set of duplicate account record type ids from Affiliation Mapping Models list
     * @param  affiliationMappingsModelsList A list of models representing affiliation mappings in EDA Settings
     * @param  accountRecordTypeModelsByName A map of account record type model by name
     * @param  accountRecordTypeModelsByLabel A map of account record type model by label
     * @return A set of duplicate account record type ids
     **********************************************************************************/
    @TestVisible
    private Set<Id> getDuplicateAccountRecordTypeIds(
        List<AffiliationMappingsModel> affiliationMappingsModelsList,
        Map<String, RecordTypeModel> accountRecordTypeModelsByName,
        Map<String, RecordTypeModel> accountRecordTypeModelsByLabel
    ) {
        Set<Id> accountRecordTypeIds = new Set<Id>();
        Set<Id> duplicateRecordTypeIds = new Set<Id>();

        for (AffiliationMappingsModel affiliationMappingsModel : affiliationMappingsModelsList) {
            RecordTypeModel accountRecordTypeModel = this.locateRecordTypeService()
                .getRecordTypeModelFromNameAndLabelMaps(
                    affiliationMappingsModel.accountRecordTypeFieldValue,
                    accountRecordTypeModelsByName,
                    accountRecordTypeModelsByLabel
                );

            if (accountRecordTypeModel == null) {
                continue;
            } else {
                if (accountRecordTypeIds.contains(accountRecordTypeModel.Id)) {
                    duplicateRecordTypeIds.add(accountRecordTypeModel.Id);
                } else {
                    accountRecordTypeIds.add(accountRecordTypeModel.Id);
                }
            }
        }

        return duplicateRecordTypeIds;
    }

    /**********************************************************************************
     * @description Retrieves a set of duplicate lookup field model names in affiliation mappings
     * @param  affiliationMappingsModelsList A list of models representing affiliation mappings in EDA Settings
     * @param  accountLookupsOnContactFieldModelsByName A map of lookup field model by name
     * @param  accountLookupsOnContactFieldModelsByLabel A map of lookup field model by label
     * @return A set of duplicate lookup field model names
     **********************************************************************************/
    @TestVisible
    private Set<String> getDuplicateLookupFieldModelNames(
        List<AffiliationMappingsModel> affiliationMappingsModelsList,
        Map<String, LookupFieldModel> accountLookupsOnContactFieldModelsByName,
        Map<String, LookupFieldModel> accountLookupsOnContactFieldModelsByLabel
    ) {
        Set<String> lookupFieldModelNames = new Set<String>();
        Set<String> duplicateLookupFieldModelNames = new Set<String>();

        for (AffiliationMappingsModel affiliationMappingsModel : affiliationMappingsModelsList) {
            LookupFieldModel lookupFieldModel = this.locateLookupFieldService()
                .getLookupFieldModelFromNameAndLabelMaps(
                    affiliationMappingsModel.primaryAffiliationField,
                    accountLookupsOnContactFieldModelsByName,
                    accountLookupsOnContactFieldModelsByLabel
                );

            if (lookupFieldModel == null) {
                continue;
            } else {
                if (lookupFieldModelNames.contains(lookupFieldModel.name)) {
                    duplicateLookupFieldModelNames.add(lookupFieldModel.name);
                } else {
                    lookupFieldModelNames.add(lookupFieldModel.name);
                }
            }
        }

        return duplicateLookupFieldModelNames;
    }
}
