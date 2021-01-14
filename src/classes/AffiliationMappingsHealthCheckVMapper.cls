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
    protected AffiliationMappingsHealthCheckVMapper() {}

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
    * @description Retrieve the results for a for an AccountModel health check.
    * @return A HealthCheckGroupVModel representing a HealtCheckDescription for Account.
    **********************************************************************************/ 
    public virtual HealthCheckGroupVModel getHealthCheckGroup() {

        Map<Id, RecordTypeModel> accRTModelsById = this.locateRecordTypeService().getModelByIdMapForSObjectType(Account.SObjectType);
        List<AffiliationMappingsModel> affiliationMappingsModelsList = this.locateAffiliationMappingsService().getAffiliationMappingsModels();
        Map<String, LookupFieldModel> accountLookupsOnContactFieldModelsByName = 
            this.locateLookupFieldService().getModelByNameMapForSObjectType(Contact.SObjectType, Account.SObjectType);
        Map<String, LookupFieldModel> accountLookupsOnContactFieldModelsByLabel =
            this.locateLookupFieldService().getModelByLabelMapForSObjectType(accountLookupsOnContactFieldModelsByName);

        List<HealthCheckGroupVModel> childAffiliationHCGroupVModelsList = new List<HealthCheckGroupVModel>();
        
        childAffiliationHCGroupVModelsList.add(this.getValidRecordTypeHealthCheckGroupVModel(
            affiliationMappingsModelsList, 
            accRTModelsById
        ));

        childAffiliationHCGroupVModelsList.add(this.getValidContactPrimaryFieldHealthCheckGroupVModel(
            affiliationMappingsModelsList, 
            accountLookupsOnContactFieldModelsByName,
            accountLookupsOnContactFieldModelsByLabel
        ));

        return this.combineAffiliationMappingsHealthCheckGroupViewModels(childAffiliationHCGroupVModelsList);
    }

    /**********************************************************************************
    * @description Generates a HealthCheckGroupVModel comprised of the combined health 
    * check results for Default Account, Administrative and Household accounts. 
    * @param  healthCheckGroupVModelsList A list of HealthCheckGroupVModels
    * @return A HealthCheckGroupVModel representing the health check results for 
    * Default, Administrative and Household Accounts.
    **********************************************************************************/ 
    @TestVisible
    private HealthCheckGroupVModel combineAffiliationMappingsHealthCheckGroupViewModels(List<HealthCheckGroupVModel> healthCheckGroupVModelsList) {
        HealthCheckGroupVModel parentHealthCheckGroupVModel = 
            new HealthCheckGroupVModel(
                Label.stgHealthCheckAffiliationMappings,
                Label.stgHealthCheckStatusPassed,
                0,
                0,
                new List<String>(),
                new List<HealthCheckItemVModel>()
            );

        for (HealthCheckGroupVModel healthCheckGroupVModel : healthCheckGroupVModelsList) {
            parentHealthCheckGroupVModel.passedChecks += healthCheckGroupVModel.passedChecks;
            parentHealthCheckGroupVModel.totalChecks += healthCheckGroupVModel.totalChecks;

            parentHealthCheckGroupVModel.expandedRowsList.addAll(healthCheckGroupVModel.expandedRowsList);
            parentHealthCheckGroupVModel.healthCheckItemList.addAll(healthCheckGroupVModel.healthCheckItemList);
        }

        parentHealthCheckGroupVModel.updateHealthCheckStatus();
        parentHealthCheckGroupVModel.healthCheckItemList.sort();
        
        return parentHealthCheckGroupVModel;
    }

    /**********************************************************************************
    * @description Retrieve a HealthCheckGroup view model reprenting whether primary
    * affiliation fields specified in affiliation mappings correspond to valid fields
    * on the Contact object that lookup to Account objects.
    * @return A HealthCheckGroupVModel
    **********************************************************************************/ 
    @TestVisible 
    private virtual HealthCheckGroupVModel getValidContactPrimaryFieldHealthCheckGroupVModel(
        List<AffiliationMappingsModel> affiliationMappingsModelsList,
        Map<String, LookupFieldModel> accountlookupFieldOnContactFieldModelByName,
        Map<String, LookupFieldModel> accountlookupFieldOnContactFieldModelByLabel
    ) {
        List<HealthCheckItemVModel> healthCheckItemsList = new List<HealthCheckItemVModel>();
        String healthCheckGroupLabel = Label.stgHealthCheckAffiliationMappings;

        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel(healthCheckGroupLabel,
                                                                                 Label.stgHealthCheckStatusPassed,
                                                                                 0,
                                                                                 0,
                                                                                 new List<String>(),
                                                                                 healthCheckItemsList);

        for (AffiliationMappingsModel affiliationMappingsModel : affiliationMappingsModelsList) {
            LookupFieldModel accountlookupFieldOnContactFieldModelFromName = this.locateLookupFieldService().getLookupFieldModelFromNameMap(
                affiliationMappingsModel.primaryAffiliationField, 
                accountlookupFieldOnContactFieldModelByName);

            if (accountlookupFieldOnContactFieldModelFromName == null) {
                LookupFieldModel accountlookupFieldOnContactFieldModelFromLabel = this.locateLookupFieldService().getLookupFieldModelFromLabelMap(
                    affiliationMappingsModel.primaryAffiliationField,
                    accountlookupFieldOnContactFieldModelByLabel);
                
                if (accountlookupFieldOnContactFieldModelFromLabel == null) {
                    healthCheckGroupVModel.healthCheckItemList.add(new HealthCheckItemVModel(
                        '03',
                        Label.stgHCAfflMapContactPrimaryFieldTitle,
                        'Fail',
                        Label.stgHealthCheckStatusFailed,
                        String.format(
                            Label.stgHCAfflMapContactPrimaryFieldInvalid, 
                            new List<Object>{affiliationMappingsModel.primaryAffiliationField}
                        ),
                        String.format(
                            Label.stgHCAfflMapContPrimaryFieldInvalidFix, 
                            new List<Object>{affiliationMappingsModel.primaryAffiliationField}
                        ),
                        new List<HealthCheckItemVModel>()
                    ));

                    healthCheckGroupVModel.totalChecks++;
                    continue;
                }
            }

            healthCheckGroupVModel.healthCheckItemList.add(new HealthCheckItemVModel(
                '03',
                Label.stgHCAfflMapContactPrimaryFieldTitle,
                'Pass',
                Label.stgHealthCheckStatusPassed,
                String.format(
                    Label.stgHCAfflMapContactPrimaryFieldValid, 
                    new List<Object>{
                        affiliationMappingsModel.primaryAffiliationField, 
                        affiliationMappingsModel.accountRecordTypeId
                    }
                ),
                Label.stgHealthCheckFixNotApplicable,
                new List<HealthCheckItemVModel>()
            ));

            healthCheckGroupVModel.totalChecks++;
            healthCheckGroupVModel.passedChecks++;
        }

        healthCheckGroupVModel.updateHealthCheckStatus();
        return healthCheckGroupVModel;
    }

    /**********************************************************************************
    * @description Retrieves a HealthCheckGroup view model representing the health check
    * results for all affiliation mappings in EDA Settings.
    * @return A HealthCheckGroupVModel
    **********************************************************************************/ 
    @TestVisible
    private virtual HealthCheckGroupVModel getValidRecordTypeHealthCheckGroupVModel(
        List<AffiliationMappingsModel> affiliationMappingModelsList, 
        Map<Id,RecordTypeModel> recordTypeModelsById
    ) {
        List<HealthCheckItemVModel> healthCheckItemsList = new List<HealthCheckItemVModel>();
        String healthCheckGroupLabel = Label.stgHealthCheckAffiliationMappings;

        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel(healthCheckGroupLabel,
                                                                                 Label.stgHealthCheckStatusPassed,
                                                                                 0,
                                                                                 0,
                                                                                 new List<String>(),
                                                                                 healthCheckItemsList);

        for (AffiliationMappingsModel affiliationMappingsModel : affiliationMappingModelsList) {            
            RecordTypeModel accountRTModel = this.locateRecordTypeService().getRecordTypeModelFromMap(
                affiliationMappingsModel.accountRecordTypeId, 
                recordTypeModelsById
            );

            if (accountRTModel == null) {
                healthCheckGroupVModel.healthCheckItemList.add(new HealthCheckItemVModel(
                    '01',
                    Label.stgHCAfflMapAccRecordTypeTitle,
                    'Fail',
                    Label.stgHealthCheckStatusFailed,
                    String.format(
                        Label.stgHCRecordTypeNotFound, 
                        new List<Object>{affiliationMappingsModel.accountRecordTypeId}
                    ),
                    String.format(
                        Label.stgHCAfflMapAccRecordTypeNotFoundFix, 
                        new List<Object>{affiliationMappingsModel.accountRecordTypeId}
                    ),
                    new List<HealthCheckItemVModel>()
                ));

                healthCheckGroupVModel.totalChecks++;
            }

            else if (accountRTModel.isActive == false) {
                healthCheckGroupVModel.healthCheckItemList.add(new HealthCheckItemVModel(
                    '01',
                    Label.stgHCAfflMapAccRecordTypeTitle,
                    'Fail',
                    Label.stgHealthCheckStatusFailed,
                    String.format(
                        Label.stgHCRecordTypeInactive, 
                        new List<Object>{accountRTModel.name, accountRTModel.developerName}
                    ),
                    String.format(
                        Label.stgHCAfflMapAccRecordTypeInactiveFix, 
                        new List<Object>{accountRTModel.name, accountRTModel.developerName}
                    ),
                    new List<HealthCheckItemVModel>()
                ));

                healthCheckGroupVModel.totalChecks++;
            }

            else {
                healthCheckGroupVModel.healthCheckItemList.add(new HealthCheckItemVModel(
                    '01',
                    Label.stgHCAfflMapAccRecordTypeTitle,
                    'Pass',
                    Label.stgHealthCheckStatusPassed,
                    String.format(
                        Label.stgHCRecordTypeValid, 
                        new List<Object>{accountRTModel.name, accountRTModel.developerName}
                    ),
                    Label.stgHealthCheckFixNotApplicable,
                    new List<HealthCheckItemVModel>()
                ));

                healthCheckGroupVModel.totalChecks++;
                healthCheckGroupVModel.passedChecks++;
            }
        }

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
}
