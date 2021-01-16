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
    * @description Retrieve the results for a for an AffiliationMappings health check.
    * @return A HealthCheckGroupVModel representing a HealtCheckDescription for Account.
    **********************************************************************************/ 
    public virtual HealthCheckGroupVModel getHealthCheckGroup() {
        HealthCheckGroupVModel parentHealthCheckGroupVModel = new HealthCheckGroupVModel(
            Label.stgHealthCheckAffiliationMappings,
            Label.stgHealthCheckStatusPassed,
            0,
            0,
            new List<String>(),
            new List<HealthCheckItemVModel>()
        );

        Map<Id, RecordTypeModel> accRTModelsById = this.locateRecordTypeService().getModelByIdMapForSObjectType(Account.SObjectType);
        List<AffiliationMappingsModel> affiliationMappingsModelsList = this.locateAffiliationMappingsService().getAffiliationMappingsModels();

        for (AffiliationMappingsModel affiliationMappingsModel : affiliationMappingsModelsList) {
            HealthCheckGroupVModel childAffiliationMappingsHealthCheckResults = this.getAffiliationMappingsHealthCheckResults(
                affiliationMappingsModel,
                accRTModelsById
            );

            // Add results from child health check group results to parent
            parentHealthCheckGroupVModel.passedChecks += childAffiliationMappingsHealthCheckResults.passedChecks;
            parentHealthCheckGroupVModel.totalChecks += childAffiliationMappingsHealthCheckResults.totalChecks;
            parentHealthCheckGroupVModel.expandedRowsList.addAll(childAffiliationMappingsHealthCheckResults.expandedRowsList);
            parentHealthCheckGroupVModel.healthCheckItemList.addAll(childAffiliationMappingsHealthCheckResults.healthCheckItemList);
        }

        System.debug('exited for loop');
        System.debug('parentHealthCheckGroupVModel.passedChecks: ' + parentHealthCheckGroupVModel.passedChecks);
        System.debug('parentHealthCheckGroupVModel.totalChecks: ' + parentHealthCheckGroupVModel.totalChecks);
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
    * @return A HealthCheckGroupVModel
    **********************************************************************************/
    private virtual HealthCheckGroupVModel getAffiliationMappingsHealthCheckResults(
        AffiliationMappingsModel affiliationMappingsModel,
        Map<Id, RecordTypeModel> recordTypeModelsById
    ) {
        HealthCheckGroupVModel parentHealthCheckGroupVModel = new HealthCheckGroupVModel(
            '',
            '',
            0,
            0,
            new List<String>(),
            new List<HealthCheckItemVModel>()
        );

        RecordTypeModel recordTypeModel =
            recordTypeModelsById.get(affiliationMappingsModel.accountRecordTypeId);

        HealthCheckItemVModel childHealthCheckItemVModel =
            this.getHealthCheckItemVModelForAffiliationMappingsModel(
                affiliationMappingsModel,
                recordTypeModel
            );

        List<HealthCheckGroupVModel> childHealthCheckGroupVModelList =
            new List<HealthCheckGroupVModel>();

        // add Account Record Type Health Check results
        childHealthCheckGroupVModelList.add(
            this.getValidRecordTypeHealthCheckGroupVModel(
                affiliationMappingsModel, 
                recordTypeModelsById
            )
        );

        // combine results into a single HealthCheckGroupVModel
        for (HealthCheckGroupVModel childHealthCheckGroupVModel : childHealthCheckGroupVModelList) {
            parentHealthCheckGroupVModel.passedChecks += childHealthCheckGroupVModel.passedChecks;
            parentHealthCheckGroupVModel.totalChecks += childHealthCheckGroupVModel.totalChecks;
            parentHealthCheckGroupVModel.expandedRowsList.addAll(childHealthCheckGroupVModel.expandedRowsList);

            childHealthCheckItemVModel.healthCheckItemList.addAll(childHealthCheckGroupVModel.healthCheckItemList);
        }

        if(parentHealthCheckGroupVModel.passedChecks < parentHealthCheckGroupVModel.totalChecks) {
            childHealthCheckItemVModel.status = 'Fail';
            childHealthCheckItemVModel.statusLabel = Label.stgHealthCheckStatusFailed;
            parentHealthCheckGroupVModel.expandedRowsList.add(affiliationMappingsModel.name);
        }

        childHealthCheckItemVModel.healthCheckItemList.sort();

        parentHealthCheckGroupVModel.healthCheckItemList.add(childHealthCheckItemVModel);

        return parentHealthCheckGroupVModel;
    }

    /***************************************************************************
    * @description Retrieves a formatted HealthCheckItemVModel. 
    * @return A formatted HealthCheckItemVModel.
    ***************************************************************************/
    @TestVisible
    protected virtual HealthCheckItemVModel getHealthCheckItemVModelForAffiliationMappingsModel(
        AffiliationMappingsModel affiliationMappingsModel,
        RecordTypeModel recordTypeModel
    ){
        String recordTypeModelName = affiliationMappingsModel.name;

        if(recordTypeModel != null) {
            recordTypeModelName = recordTypeModel.name;
        }

        List<String> listForSettingsLabel =
            new List<String>{affiliationMappingsModel.name};
        List<String> listForDescriptionLabel =
            new List<String>{affiliationMappingsModel.name,recordTypeModelName};

        return new HealthCheckItemVModel(
            affiliationMappingsModel.name,
            String.format(
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
    * @description Retrieves a HealthCheckGroup view model representing the health check
    * results for all affiliation mappings in EDA Settings.
    * @return A HealthCheckGroupVModel
    **********************************************************************************/ 
    @TestVisible
    private virtual HealthCheckGroupVModel getValidRecordTypeHealthCheckGroupVModel(
        AffiliationMappingsModel affliliationMappingsModel, 
        Map<Id,RecordTypeModel> recordTypeModelsById
    ) {

        System.debug('in getValidRecordTypeHealthCheckGroupVModel');
        // Retrieve model for Account RT matching value specified in affiliation mapping
        RecordTypeModel accountRTModel = this.locateRecordTypeService().getRecordTypeModelFromMap(
            affliliationMappingsModel.accountRecordTypeId, 
            recordTypeModelsById
        );

        HealthCheckGroupVModel accountRecordTypeHCGroupModelWithHCItems = this.setHealthCheckItemForAccountRTHealthCheck(
            accountRTModel,
            affliliationMappingsModel
        );

        System.debug('accountRecordTypeHCGroupModelWithHCItems total checks: ' + accountRecordTypeHCGroupModelWithHCItems.totalChecks);
        System.debug('accountRecordTypeHCGroupModelWithHCItems passed checks: ' + accountRecordTypeHCGroupModelWithHCItems.passedChecks);
        if (accountRecordTypeHCGroupModelWithHCItems.status == System.Label.stgHealthCheckStatusFailed) {
            accountRecordTypeHCGroupModelWithHCItems.expandedRowsList.add(affliliationMappingsModel.name);
        }
        accountRecordTypeHCGroupModelWithHCItems.healthCheckItemList.sort();

        return accountRecordTypeHCGroupModelWithHCItems;
    }

    /**********************************************************************************
    * @description Helper method to add a HealthCheckItem view model representing
    * the results of an Account RT health check for an affiliation mapping to the 
    * overall Account RT health check group view model.
    * @return A HealthCheckGroupVModel
    **********************************************************************************/ 
    @TestVisible
    private HealthCheckGroupVModel setHealthCheckItemForAccountRTHealthCheck(
        RecordTypeModel recordTypeModel,
        AffiliationMappingsModel affliliationMappingsModel
    ) {

        System.debug('in setHealthCheckItemForAccountRTHealthCheck');

        // Initialize temporary HCGroupVModel with default settings
        HealthCheckGroupVModel tempHCGroupVModel = 
            new HealthCheckGroupVModel(
                Label.stgHCAfflMapAccRecordTypeTitle,
                Label.stgHealthCheckStatusPassed,
                0,
                0,
                new List<String>(),
                new List<HealthCheckItemVModel>()
            );

        if (recordTypeModel == null) {
            // no matching Account RT found
            tempHCGroupVModel.healthCheckItemList.add(
                new HealthCheckItemVModel(
                    '01', 
                    Label.stgHCAfflMapAccRecordTypeTitle,
                    'Fail',
                    Label.stgHealthCheckStatusFailed,
                    String.format(
                        Label.stgHCRecordTypeNotFound, 
                        new List<Object>{affliliationMappingsModel.accountRecordTypeId}
                    ),
                    String.format(
                        Label.stgHCAfflMapAccRecordTypeNotFoundFix, 
                        new List<Object>{affliliationMappingsModel.accountRecordTypeId}
                    ),
                    new List<HealthCheckItemVModel>()
                )
            );

            tempHCGroupVModel.totalChecks++;
        }

        else if (recordTypeModel.isActive == false) {
            // Inactive Account RT matched
            tempHCGroupVModel.healthCheckItemList.add(
                new HealthCheckItemVModel(
                    '01', 
                    Label.stgHCAfflMapAccRecordTypeTitle,
                    'Fail',
                    Label.stgHealthCheckStatusFailed,
                    String.format(
                        Label.stgHCRecordTypeInactive, 
                        new List<Object>{recordTypeModel.name, recordTypeModel.developerName}
                    ),
                    String.format(
                        Label.stgHCAfflMapAccRecordTypeInactiveFix, 
                        new List<Object>{recordTypeModel.name, recordTypeModel.developerName}
                    ),
                    new List<HealthCheckItemVModel>()
                )
            );

            tempHCGroupVModel.totalChecks++;            
        }

        else {
            // Valid and active Account RT matched
            tempHCGroupVModel.healthCheckItemList.add(
                new HealthCheckItemVModel(
                    '01', 
                    Label.stgHCAfflMapAccRecordTypeTitle,
                    'Pass',
                    Label.stgHealthCheckStatusPassed,
                    String.format(
                        Label.stgHCRecordTypeValid, 
                        new List<Object>{recordTypeModel.name, recordTypeModel.developerName}
                    ),
                    Label.stgHealthCheckFixNotApplicable,
                    new List<HealthCheckItemVModel>()
                )
            );

            tempHCGroupVModel.totalChecks++;  
            tempHCGroupVModel.passedChecks++;
        }

        tempHCGroupVModel.updateHealthCheckStatus();

        return tempHCGroupVModel;
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
}
