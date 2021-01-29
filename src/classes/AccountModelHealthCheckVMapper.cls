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
* an Account model health check.  Verifies that mapped record types for 
* Default Account, Administrative and Household Account Models are valid and active.
*/
public virtual with sharing class AccountModelHealthCheckVMapper {
    /**********************************************************************************
    * @description Instance for Singleton Pattern
    **********************************************************************************/
    @TestVisible
    private static AccountModelHealthCheckVMapper instance;

    /**********************************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************************/
    protected AccountModelHealthCheckVMapper() {}

    /**********************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of AccountModelHealthCheckVMapper.
    **********************************************************************************/
    public static AccountModelHealthCheckVMapper getInstance() {
        if (instance == null) {
            instance = new AccountModelHealthCheckVMapper();
        }

        return instance;
    }

    /**********************************************************************************
    * @description Retrieve the results for a for an AccountModel health check.
    * @return A HealthCheckGroupVModel representing a HealtCheckDescription for Account.
    **********************************************************************************/ 
    public virtual HealthCheckGroupVModel getHealthCheckGroup() {
        AccountModelSettingsModel accountModelSettingModel = this.locateAccountModelSettingsService().getAccountModelSettingsModel();
        Map<Id, RecordTypeModel> accountRTModelsById = this.locateRecordTypeService().getModelByIdMapForSObjectType(Account.SObjectType);

        List<HealthCheckGroupVModel> accountHealthCheckGroupVModelsList = new List<HealthCheckGroupVModel>();

        accountHealthCheckGroupVModelsList.add(this.getDefaultAccountModelHealthCheckItems(accountModelSettingModel, accountRTModelsById));        
        accountHealthCheckGroupVModelsList.add(this.getAdministrativeAccountModelHealthCheckItems(accountModelSettingModel, accountRTModelsById));        
        accountHealthCheckGroupVModelsList.add(this.getHouseholdAccountModelHealthCheckItems(accountModelSettingModel, accountRTModelsById));        
        accountHealthCheckGroupVModelsList.add(this.getAccountRecordTypeUniquenessHealthCheckItems(accountModelSettingModel));        

        return this.combineAccountHealthCheckGroupViewModels(accountHealthCheckGroupVModelsList);
    }

    /**********************************************************************************
    * @description Generates a HealthCheckGroupVModel comprised of the combined health 
    * check results for Default Account, Administrative and Household accounts. 
    * @param  healthCheckGroupVModelsList A list of HealthCheckGroupVModels
    * @return A HealthCheckGroupVModel representing the health check results for 
    * Default, Administrative and Household Accounts.
    **********************************************************************************/ 
    @TestVisible
    private HealthCheckGroupVModel combineAccountHealthCheckGroupViewModels(List<HealthCheckGroupVModel> healthCheckGroupVModelsList) {
        HealthCheckGroupVModel parentHealthCheckGroupVModel = new HealthCheckGroupVModel(Label.stgHealthCheckAccountModel,
                                                                                        '',
                                                                                        0,
                                                                                        0,
                                                                                        new List<String>(),
                                                                                        new List<HealthCheckItemVModel>());

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
    * @description Generates a HealthCheckGroupVModel for a Default Account Model health check
    * @param  accountModelSettingsModel An AccountModelSettingsModel
    * @param  recordTypeModelsById A map of Record Type models by Id
    * @return A HealthCheckGroupVModel with representing a Default Account Model Health Check
    **********************************************************************************/
    @TestVisible
    private virtual HealthCheckGroupVModel getDefaultAccountModelHealthCheckItems(AccountModelSettingsModel accountModelSettingsModel, 
                                                                                    Map<Id,RecordTypeModel> recordTypeModelsById) {
        String healthCheckGroupLabel = Label.stgHealthCheckAccountModel;
        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel(healthCheckGroupLabel,
                                                                             Label.stgHealthCheckStatusPassed,
                                                                             0,
                                                                             0,
                                                                             new List<String>(),
                                                                             new List<HealthCheckItemVModel>());
        RecordTypeModel defaultAccountRTModel = 
            this.locateRecordTypeService().getRecordTypeModelFromMap(accountModelSettingsModel.defaultAccountModelId, recordTypeModelsById);

        if (defaultAccountRTModel == null) {
            healthCheckGroupVModel.healthCheckItemList.add(new HealthCheckItemVModel('01',
                                                                                Label.stgAccModelTitle,
                                                                                'Fail',
                                                                                Label.stgHealthCheckStatusFailed,
                                                                                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                    Label.stgHCRecordTypeNotFound, 
                                                                                    new List<Object>{accountModelSettingsModel.defaultAccountModelId}
                                                                                ),
                                                                                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                    Label.stgHCAccountModelDefaultNotFoundFix, 
                                                                                    new List<Object>{accountModelSettingsModel.defaultAccountModelId}
                                                                                ),
                                                                                new List<HealthCheckItemVModel>()));
            healthCheckGroupVModel.totalChecks++;
            healthCheckGroupVModel.updateHealthCheckStatus();
            return healthCheckGroupVModel;
        }

        if (defaultAccountRTModel.isActive == false) {
            healthCheckGroupVModel.healthCheckItemList.add(new HealthCheckItemVModel('01',
                                                                                Label.stgAccModelTitle,
                                                                                'Fail',
                                                                                Label.stgHealthCheckStatusFailed,
                                                                                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                    Label.stgHCRecordTypeInactive, 
                                                                                    new List<Object>{defaultAccountRTModel.name, defaultAccountRTModel.developerName}
                                                                                ),
                                                                                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                    Label.stgHCAccountModelDefaultInactiveFix, 
                                                                                    new List<Object>{defaultAccountRTModel.name, defaultAccountRTModel.developerName}
                                                                                ),
                                                                                new List<HealthCheckItemVModel>()));
            healthCheckGroupVModel.totalChecks++;
            healthCheckGroupVModel.updateHealthCheckStatus();
            return healthCheckGroupVModel;
        }

        healthCheckGroupVModel.healthCheckItemList.add(new HealthCheckItemVModel('01',
                                                                            Label.stgAccModelTitle,
                                                                            'Pass',
                                                                            Label.stgHealthCheckStatusPassed,
                                                                            this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                Label.stgHCRecordTypeValid, 
                                                                                new List<Object>{defaultAccountRTModel.name, defaultAccountRTModel.developerName}
                                                                            ),
                                                                            Label.stgHealthCheckFixNotApplicable,
                                                                            new List<HealthCheckItemVModel>()));
        healthCheckGroupVModel.totalChecks++;
        healthCheckGroupVModel.passedChecks++;
        healthCheckGroupVModel.updateHealthCheckStatus();

        return healthCheckGroupVModel;
    }

    /**********************************************************************************
    * @description Generates a HealthCheckGroupVModel for an Administrative Account Model health check
    * @param  accountModelSettingsModel An AccountModelSettingsModel
    * @param  recordTypeModelsById A map of Record Type models by Id
    * @return A HealthCheckGroupVModel with representing an Administrative Account Model Health Check
    **********************************************************************************/
    @TestVisible
    private virtual HealthCheckGroupVModel getAdministrativeAccountModelHealthCheckItems(AccountModelSettingsModel accountModelSettingsModel, 
                                                                                    Map<Id,RecordTypeModel> recordTypeModelsById) {
                                                                                  
        String healthCheckGroupLabel = Label.stgHealthCheckAccountModel;
        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel(healthCheckGroupLabel,
                                                                             Label.stgHealthCheckStatusPassed,
                                                                             0,
                                                                             0,
                                                                             new List<String>(),
                                                                             new List<HealthCheckItemVModel>());

        RecordTypeModel adminAccountRTModel = this.locateRecordTypeService().getRecordTypeModelFromMap(
                                                    accountModelSettingsModel.administrativeAccountRecordTypeId, 
                                                    recordTypeModelsById
                                                );

        if (adminAccountRTModel == null) {
            healthCheckGroupVModel.healthCheckItemList.add(new HealthCheckItemVModel('02',
                                                                                Label.stgAdminAccountRecordType,
                                                                                'Fail',
                                                                                Label.stgHealthCheckStatusFailed,
                                                                                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                    Label.stgHCRecordTypeNotFound, 
                                                                                    new List<Object>{accountModelSettingsModel.administrativeAccountRecordTypeId}
                                                                                ),
                                                                                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                    Label.stgHCAccountModelAdminNotFoundFix, 
                                                                                    new List<Object>{accountModelSettingsModel.administrativeAccountRecordTypeId}
                                                                                ),
                                                                                new List<HealthCheckItemVModel>()));
            healthCheckGroupVModel.totalChecks++;
            healthCheckGroupVModel.updateHealthCheckStatus();
            return healthCheckGroupVModel;
        }

        if (adminAccountRTModel.isActive == false) {
            healthCheckGroupVModel.healthCheckItemList.add(new HealthCheckItemVModel('02',
                                                                                Label.stgAdminAccountRecordType,
                                                                                'Fail',
                                                                                Label.stgHealthCheckStatusFailed,
                                                                                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                    Label.stgHCRecordTypeInactive, 
                                                                                    new List<Object>{adminAccountRTModel.name, adminAccountRTModel.developerName}
                                                                                ),
                                                                                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                    Label.stgHCAccountModelAdminInactiveFix, 
                                                                                    new List<Object>{adminAccountRTModel.name, adminAccountRTModel.developerName}
                                                                                ),
                                                                                new List<HealthCheckItemVModel>()));
            healthCheckGroupVModel.totalChecks++;
            healthCheckGroupVModel.updateHealthCheckStatus();
            return healthCheckGroupVModel;
        }
    
        healthCheckGroupVModel.healthCheckItemList.add(new HealthCheckItemVModel('02',
                                                                            Label.stgAdminAccountRecordType,
                                                                            'Pass',
                                                                            Label.stgHealthCheckStatusPassed,
                                                                            this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                Label.stgHCRecordTypeValid, 
                                                                                new List<Object>{adminAccountRTModel.name, adminAccountRTModel.developerName}
                                                                            ),
                                                                            Label.stgHealthCheckFixNotApplicable,
                                                                            new List<HealthCheckItemVModel>()));
        healthCheckGroupVModel.totalChecks++;
        healthCheckGroupVModel.passedChecks++;
        healthCheckGroupVModel.updateHealthCheckStatus();
        return healthCheckGroupVModel;
    }

    /**********************************************************************************
    * @description Generates a HealthCheckGroupVModel for a Household Account Model health check
    * @param  accountModelSettingsModel An AccountModelSettingsModel
    * @param  recordTypeModelsById A map of Record Type models by Id
    * @return A HealthCheckGroupVModel with representing an Household Account Model Health Check
    **********************************************************************************/
    @TestVisible
    private virtual HealthCheckGroupVModel getHouseholdAccountModelHealthCheckItems(AccountModelSettingsModel accountModelSettingsModel, 
                                                                                    Map<Id,RecordTypeModel> recordTypeModelsById) {
                                                                                  
        String healthCheckGroupLabel = Label.stgHealthCheckAccountModel;
        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel(healthCheckGroupLabel,
                                                                             Label.stgHealthCheckStatusPassed,
                                                                             0,
                                                                             0,
                                                                             new List<String>(),
                                                                             new List<HealthCheckItemVModel>());

        RecordTypeModel hhAccountRTModel = this.locateRecordTypeService().getRecordTypeModelFromMap(
                                                    accountModelSettingsModel.householdAccountRecordTypeId, 
                                                    recordTypeModelsById
                                                );

        if (hhAccountRTModel == null) {
            healthCheckGroupVModel.healthCheckItemList.add(new HealthCheckItemVModel('03',
                                                                                Label.stgAccountRecordTypeSupportsHHAddress,
                                                                                'Fail',
                                                                                Label.stgHealthCheckStatusFailed,
                                                                                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                    Label.stgHCRecordTypeNotFound, 
                                                                                    new List<Object>{accountModelSettingsModel.householdAccountRecordTypeId}
                                                                                ),
                                                                                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                    Label.stgHCAccountModelHHNotFoundFix, 
                                                                                    new List<Object>{accountModelSettingsModel.householdAccountRecordTypeId}
                                                                                ),
                                                                                new List<HealthCheckItemVModel>()));
            healthCheckGroupVModel.totalChecks++;
            healthCheckGroupVModel.updateHealthCheckStatus();
            return healthCheckGroupVModel;
        }

        if (hhAccountRTModel.isActive == false) {
            healthCheckGroupVModel.healthCheckItemList.add(new HealthCheckItemVModel('03',
                                                                                Label.stgAccountRecordTypeSupportsHHAddress,
                                                                                'Fail',
                                                                                Label.stgHealthCheckStatusFailed,
                                                                                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                    Label.stgHCRecordTypeInactive, 
                                                                                    new List<Object>{hhAccountRTModel.name, hhAccountRTModel.developerName}
                                                                                ),
                                                                                this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                    Label.stgHCAccountModelHHInactiveFix, 
                                                                                    new List<Object>{hhAccountRTModel.name, hhAccountRTModel.developerName}
                                                                                ),
                                                                                new List<HealthCheckItemVModel>()));
            healthCheckGroupVModel.totalChecks++;
            healthCheckGroupVModel.updateHealthCheckStatus();
            return healthCheckGroupVModel;
        }
    
        healthCheckGroupVModel.healthCheckItemList.add(new HealthCheckItemVModel('03',
                                                                            Label.stgAccountRecordTypeSupportsHHAddress,
                                                                            'Pass',
                                                                            Label.stgHealthCheckStatusPassed,
                                                                            this.locateStringHandlingService().formatStringWithApostrophesAndParameters(
                                                                                Label.stgHCRecordTypeValid, 
                                                                                new List<Object>{hhAccountRTModel.name, hhAccountRTModel.developerName}
                                                                            ),
                                                                            Label.stgHealthCheckFixNotApplicable,
                                                                            new List<HealthCheckItemVModel>()));
        healthCheckGroupVModel.totalChecks++;
        healthCheckGroupVModel.passedChecks++;
        healthCheckGroupVModel.updateHealthCheckStatus();
        return healthCheckGroupVModel;
    }

    /**********************************************************************************
    * @description Generates a HealthCheckGroupVModel for an Account Model health check based
    * on whether the Administrative and Household RT settings are the same.
    * @param  accountModelSettingsModel An AccountModelSettingsModel
    * @return A HealthCheckGroupVModel with a status of Fail if the Admin and HH Accounts are not
    * unique; a HealthCheckGroupVModel with a status of Pass otherwise.
    **********************************************************************************/
    @TestVisible
    private HealthCheckGroupVModel getAccountRecordTypeUniquenessHealthCheckItems(AccountModelSettingsModel accountModelSettingsModel) {

        List<HealthCheckItemVModel> healthCheckItemsList = new List<HealthCheckItemVModel>();
        String healthCheckGroupLabel = Label.stgHealthCheckAccountModel;

        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel(healthCheckGroupLabel,
                                                                             Label.stgHealthCheckStatusPassed,
                                                                             0,
                                                                             0,
                                                                             new List<String>(),
                                                                             healthCheckItemsList);
                                                                             
        Boolean isAdminEqualToHHAcctRT = 
            (accountModelSettingsModel.administrativeAccountRecordTypeId == accountModelSettingsModel.householdAccountRecordTypeId);

        if (isAdminEqualToHHAcctRT == true) {
            healthCheckItemsList.add(new HealthCheckItemVModel('04',
                                                           Label.stgHCAccountRecordTypeSettingsUnique,
                                                           'Fail',
                                                           Label.stgHealthCheckStatusFailed,
                                                           Label.stgHCAccountRecordTypesNotUnique,
                                                           Label.stgHCAccountRecordTypesNotUniqueFix,
                                                           new List<HealthCheckItemVModel>()));

            healthCheckGroupVModel.totalChecks++;
            healthCheckGroupVModel.updateHealthCheckStatus();
            return healthCheckGroupVModel;
        }

        healthCheckItemsList.add(new HealthCheckItemVModel('04',
                                                       Label.stgHCAccountRecordTypeSettingsUnique,
                                                       'Pass',
                                                       Label.stgHealthCheckStatusPassed,
                                                       Label.stgHCAccountRecordTypesUnique,
                                                       Label.stgHealthCheckFixNotApplicable,
                                                       new List<HealthCheckItemVModel>()));

        healthCheckGroupVModel.totalChecks++;
        healthCheckGroupVModel.passedChecks++;
        healthCheckGroupVModel.updateHealthCheckStatus();
        
        return healthCheckGroupVModel;
    }

    /*****************************************************************************
    * @description Retrieve an instance of the AccountModelSettingsService class.
    * @return An instance of AccountModelSettingsService.
    *****************************************************************************/
    @TestVisible
    private AccountModelSettingsService locateAccountModelSettingsService() {
        return AccountModelSettingsService.getInstance();
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
    * @description Retrieve an instance of the StringHandlingService class.
    * @return An instance of StringHandlingService.
    *****************************************************************************/
    @TestVisible
    private StringHandlingService locateStringHandlingService() {
        return StringHandlingService.getInstance();
    }
}
