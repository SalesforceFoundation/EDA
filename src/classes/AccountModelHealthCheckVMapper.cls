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
* @group-content ../../ApexDocContent/
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
        AccountModelSettingsModel acctModSettingMod = this.locateAccountModelSettingsService().getAccountModelSettingsModel();
        Map<Id, RecordTypeModel> accountRTModelsById = this.locateRecordTypeService().getModelByIdMapForSObjectType(Account.SObjectType);

        String hlthCheckGroupLabel = Label.stgHealthCheckAccountModel;
        Integer hlthChkGroupPassedChecks = 0;
        Integer hlthChkGroupTotalChecks = 0;

        List<String> hlthChkGroupExpandedRowsList = new List<String>();
        List<HealthCheckItemVModel> hlthChkGroupHlthChkItemsList = new List<HealthCheckItemVModel>();

        HealthCheckGroupVModel defaultHlthChkGroupVMod = this.getDefaultAccountModelHealthCheckItems(acctModSettingMod, accountRTModelsById);        
        
        hlthChkGroupPassedChecks += defaultHlthChkGroupVMod.passedChecks;
        hlthChkGroupTotalChecks += defaultHlthChkGroupVMod.totalChecks;

        String hlthChkGroupStatus = this.updateHealthCheckStatus(hlthChkGroupPassedChecks, hlthChkGroupTotalChecks);

        hlthChkGroupExpandedRowsList.addAll(defaultHlthChkGroupVMod.expandedRowsList);
        hlthChkGroupHlthChkItemsList.addAll(defaultHlthChkGroupVMod.healthCheckItemList);

        HealthCheckGroupVModel hlthChkGroupVMod = new HealthCheckGroupVModel(hlthCheckGroupLabel,
                                                                             hlthChkGroupStatus,
                                                                             hlthChkGroupPassedChecks,
                                                                             hlthChkGroupTotalChecks,
                                                                             hlthChkGroupExpandedRowsList,
                                                                             hlthChkGroupHlthChkItemsList);

        hlthChkGroupVMod.healthCheckItemList.sort();
        return hlthChkGroupVMod;
    }

    /**********************************************************************************
    * @description Generates a HealthCheckGroupVModel for a Default Account Model health check
    * @param  acctModelSettingsMod An AccountModelSettingsModel
    * @param  recordTypeModelsById A map of Record Type models by Id
    * @return A HealthCheckGroupVModel with representing a Default Account Model Health Check
    **********************************************************************************/
    @TestVisible
    private virtual HealthCheckGroupVModel getDefaultAccountModelHealthCheckItems(AccountModelSettingsModel acctModelSettingsMod, 
                                                                                    Map<Id,RecordTypeModel> recordTypeModelsById) {
                                                                                  
        String hlthCheckGroupLabel = Label.stgHealthCheckAccountModel;
        HealthCheckGroupVModel hlthChkGroupVMod = new HealthCheckGroupVModel(hlthCheckGroupLabel,
                                                                             Label.stgHealthCheckStatusPassed,
                                                                             0,
                                                                             0,
                                                                             new List<String>(),
                                                                             new List<HealthCheckItemVModel>());
        RecordTypeModel defaultAccountRTModel = 
            this.locateRecordTypeService().getRecordTypeModelFromMap(acctModelSettingsMod.defaultAccountModelId, recordTypeModelsById);

        if (defaultAccountRTModel == null) {
            hlthChkGroupVMod.healthCheckItemList.add(new HealthCheckItemVModel('01',
                                                                                Label.stgAccModelTitle,
                                                                                'Fail',
                                                                                Label.stgHealthCheckStatusFailed,
                                                                                String.format(Label.stgHCRecordTypeNotFound, 
                                                                                                new List<Object>{acctModelSettingsMod.defaultAccountModelId}),
                                                                                String.format(Label.stgHCAccountModelDefaultNotFoundFix, 
                                                                                                new List<Object>{acctModelSettingsMod.defaultAccountModelId}),
                                                                                new List<HealthCheckItemVModel>()));
            hlthChkGroupVMod.totalChecks++;
            hlthChkGroupVMod.status = this.updateHealthCheckStatus(hlthChkGroupVMod.passedChecks, hlthChkGroupVMod.totalChecks);
            return hlthChkGroupVMod;
        }

        if (defaultAccountRTModel.isActive == false) {
            hlthChkGroupVMod.healthCheckItemList.add(new HealthCheckItemVModel('01',
                                                                                Label.stgAccModelTitle,
                                                                                'Fail',
                                                                                Label.stgHealthCheckStatusFailed,
                                                                                String.format(Label.stgHCRecordTypeInactive, 
                                                                                                new List<Object>{defaultAccountRTModel.name, defaultAccountRTModel.developerName}),
                                                                                String.format(Label.stgHCAccountModelDefaultInactiveFix, 
                                                                                                new List<Object>{defaultAccountRTModel.name, defaultAccountRTModel.developerName}),
                                                                                new List<HealthCheckItemVModel>()));
            hlthChkGroupVMod.totalChecks++;
            hlthChkGroupVMod.status = this.updateHealthCheckStatus(hlthChkGroupVMod.passedChecks, hlthChkGroupVMod.totalChecks);
            return hlthChkGroupVMod;
        }
    
        hlthChkGroupVMod.healthCheckItemList.add(new HealthCheckItemVModel('01',
                                                                            Label.stgAccModelTitle,
                                                                            'Pass',
                                                                            Label.stgHealthCheckStatusPassed,
                                                                            String.format(Label.stgHCRecordTypeValid, 
                                                                                        new List<Object>{defaultAccountRTModel.name, defaultAccountRTModel.developerName}),
                                                                            Label.stgHealthCheckFixNotApplicable,
                                                                            new List<HealthCheckItemVModel>()));
        hlthChkGroupVMod.totalChecks++;
        hlthChkGroupVMod.passedChecks++;
        hlthChkGroupVMod.status = this.updateHealthCheckStatus(hlthChkGroupVMod.passedChecks, hlthChkGroupVMod.totalChecks);
        return hlthChkGroupVMod;
    }

    /**********************************************************************************
    * @description Generates a HealthCheckGroupVModel for an Administrative Account Model health check
    * @param  acctModelSettingsMod An AccountModelSettingsModel
    * @param  recordTypeModelsById A map of Record Type models by Id
    * @return A HealthCheckGroupVModel with representing an Administrative Account Model Health Check
    **********************************************************************************/
    @TestVisible
    private virtual HealthCheckGroupVModel getAdministrativeAccountModelHealthCheckItems(AccountModelSettingsModel acctModelSettingsMod, 
                                                                                    Map<Id,RecordTypeModel> recordTypeModelsById) {
                                                                                  
        String hlthCheckGroupLabel = Label.stgHealthCheckAccountModel;
        HealthCheckGroupVModel hlthChkGroupVMod = new HealthCheckGroupVModel(hlthCheckGroupLabel,
                                                                             Label.stgHealthCheckStatusPassed,
                                                                             0,
                                                                             0,
                                                                             new List<String>(),
                                                                             new List<HealthCheckItemVModel>());

        RecordTypeModel adminAccountRTModel = this.locateRecordTypeService().getRecordTypeModelFromMap(
                                                    acctModelSettingsMod.administrativeAccountRecordTypeId, 
                                                    recordTypeModelsById
                                                );

        if (adminAccountRTModel == null) {
            hlthChkGroupVMod.healthCheckItemList.add(new HealthCheckItemVModel('02',
                                                                                Label.stgAdminAccountRecordType,
                                                                                'Fail',
                                                                                Label.stgHealthCheckStatusFailed,
                                                                                String.format(Label.stgHCRecordTypeNotFound, 
                                                                                                new List<Object>{acctModelSettingsMod.administrativeAccountRecordTypeId}),
                                                                                String.format(Label.stgHCAccountModelAdminNotFoundFix, 
                                                                                                new List<Object>{acctModelSettingsMod.administrativeAccountRecordTypeId}),
                                                                                new List<HealthCheckItemVModel>()));
            hlthChkGroupVMod.totalChecks++;
            hlthChkGroupVMod.status = this.updateHealthCheckStatus(hlthChkGroupVMod.passedChecks, hlthChkGroupVMod.totalChecks);
            return hlthChkGroupVMod;
        }

        if (adminAccountRTModel.isActive == false) {
            hlthChkGroupVMod.healthCheckItemList.add(new HealthCheckItemVModel('02',
                                                                                Label.stgAdminAccountRecordType,
                                                                                'Fail',
                                                                                Label.stgHealthCheckStatusFailed,
                                                                                String.format(Label.stgHCRecordTypeInactive, 
                                                                                                new List<Object>{adminAccountRTModel.name, adminAccountRTModel.developerName}),
                                                                                String.format(Label.stgHCAccountModelAdminInactiveFix, 
                                                                                                new List<Object>{adminAccountRTModel.name, adminAccountRTModel.developerName}),
                                                                                new List<HealthCheckItemVModel>()));
            hlthChkGroupVMod.totalChecks++;
            hlthChkGroupVMod.status = this.updateHealthCheckStatus(hlthChkGroupVMod.passedChecks, hlthChkGroupVMod.totalChecks);
            return hlthChkGroupVMod;
        }
    
        hlthChkGroupVMod.healthCheckItemList.add(new HealthCheckItemVModel('02',
                                                                            Label.stgAdminAccountRecordType,
                                                                            'Pass',
                                                                            Label.stgHealthCheckStatusPassed,
                                                                            String.format(Label.stgHCRecordTypeValid, 
                                                                                        new List<Object>{adminAccountRTModel.name, adminAccountRTModel.developerName}),
                                                                            Label.stgHealthCheckFixNotApplicable,
                                                                            new List<HealthCheckItemVModel>()));
        hlthChkGroupVMod.totalChecks++;
        hlthChkGroupVMod.passedChecks++;
        hlthChkGroupVMod.status = this.updateHealthCheckStatus(hlthChkGroupVMod.passedChecks, hlthChkGroupVMod.totalChecks);
        return hlthChkGroupVMod;
    }

    /*********************************************************************************************************************
    * @description Helper method to update the status of a HealthCheckGroupVModel based on the number of passing health checks. 
    * @param  passedCheckCount The number of health checks passed.
    * @param  totalCheckCount The total number of health checks executed.
    * @return Pass if all checks executed passed, Fail otherwise
    *********************************************************************************************************************/
    @TestVisible
    private String updateHealthCheckStatus(Integer passedCheckCount, Integer totalCheckCount){      
        if (passedCheckCount == totalCheckCount){
            return Label.stgHealthCheckStatusPassed;
        }

        return Label.stgHealthCheckStatusFailed;
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
}
