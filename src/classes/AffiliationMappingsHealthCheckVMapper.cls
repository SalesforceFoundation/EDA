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
        HealthCheckGroupVModel healthCheckGroupVMod = new HealthCheckGroupVModel(
            Label.stgHealthCheckAffiliationMappings,
            Label.stgHealthCheckStatusPassed,
            0,
            0,
            new List<String>(),
            new List<HealthCheckItemVModel>()
        );

        Map<Id, RecordTypeModel> accRTModelsById = this.locateRecordTypeService().getModelByIdMapForSObjectType(Account.SObjectType);
        List<AffiliationMappingsModel> afflMappingSettingMod = this.locateAffiliationMappingsService().getAffiliationMappingsModels();

        HealthCheckGroupVModel afflMappingsHealthCheckCombinedGroupModel = 
            this.getValidRecordTypeHealthCheckGroupVModel(afflMappingSettingMod, accRTModelsById);

        healthCheckGroupVMod.passedChecks += afflMappingsHealthCheckCombinedGroupModel.passedChecks;
        healthCheckGroupVMod.totalChecks += afflMappingsHealthCheckCombinedGroupModel.totalChecks;
        healthCheckGroupVMod.expandedRowsList.addAll(afflMappingsHealthCheckCombinedGroupModel.expandedRowsList);
        healthCheckGroupVMod.healthCheckItemList.addAll(afflMappingsHealthCheckCombinedGroupModel.healthCheckItemList);

        healthCheckGroupVMod.updateHealthCheckStatus();
        healthCheckGroupVMod.healthCheckItemList.sort();
        
        return healthCheckGroupVMod;
    }

    /**********************************************************************************
    * @description Retrieves a HealthCheckGroup view model representing the health check
    * results for all affiliation mappings in EDA Settings.
    * @return A HealthCheckGroupVModel
    **********************************************************************************/ 
    private HealthCheckGroupVModel getValidRecordTypeHealthCheckGroupVModel(
        List<AffiliationMappingsModel> affiliationMappingModels, 
        Map<Id,RecordTypeModel> recordTypeModelsById
    ) {
        List<HealthCheckItemVModel> healthCheckItemsList = new List<HealthCheckItemVModel>();
        String healthCheckGroupLabel = Label.stgHealthCheckAffiliationMappings;

        HealthCheckGroupVModel healthCheckGroupVMod = new HealthCheckGroupVModel(healthCheckGroupLabel,
                                                                                 Label.stgHealthCheckStatusPassed,
                                                                                 0,
                                                                                 0,
                                                                                 new List<String>(),
                                                                                 healthCheckItemsList);

        for (AffiliationMappingsModel afflMappingMod : affiliationMappingModels) {            
            RecordTypeModel acctRTModel = this.locateRecordTypeService().getRecordTypeModelFromMap(
                afflMappingMod.accountRecordTypeId, 
                recordTypeModelsById
            );

            if (acctRTModel == null) {
                healthCheckGroupVMod.healthCheckItemList.add(new HealthCheckItemVModel(
                    '01',
                    Label.stgHCAfflMapAccRecordTypeTitle,
                    'Fail',
                    Label.stgHealthCheckStatusFailed,
                    String.format(
                        Label.stgHCRecordTypeNotFound, 
                        new List<Object>{afflMappingMod.accountRecordTypeId}
                    ),
                    String.format(
                        Label.stgHCAfflMapAccRecordTypeNotFoundFix, 
                        new List<Object>{afflMappingMod.accountRecordTypeId}
                    ),
                    new List<HealthCheckItemVModel>()
                ));

                healthCheckGroupVMod.totalChecks++;
                // healthCheckGroupVMod.updateHealthCheckStatus();
                
                // return healthCheckGroupVMod;
            }

            else if (acctRTModel.isActive == false) {
                healthCheckGroupVMod.healthCheckItemList.add(new HealthCheckItemVModel(
                    '01',
                    Label.stgHCAfflMapAccRecordTypeTitle,
                    'Fail',
                    Label.stgHealthCheckStatusFailed,
                    String.format(
                        Label.stgHCRecordTypeInactive, 
                        new List<Object>{acctRTModel.name, acctRTModel.developerName}
                    ),
                    String.format(
                        Label.stgHCAfflMapAccRecordTypeInactiveFix, 
                        new List<Object>{acctRTModel.name, acctRTModel.developerName}
                    ),
                    new List<HealthCheckItemVModel>()
                ));

                healthCheckGroupVMod.totalChecks++;
                //healthCheckGroupVMod.updateHealthCheckStatus();

                //return healthCheckGroupVMod;
            }

            else {
                healthCheckGroupVMod.healthCheckItemList.add(new HealthCheckItemVModel(
                    '01',
                    Label.stgHCAfflMapAccRecordTypeTitle,
                    'Pass',
                    Label.stgHealthCheckStatusPassed,
                    String.format(
                        Label.stgHCRecordTypeValid, 
                        new List<Object>{acctRTModel.name, acctRTModel.developerName}
                    ),
                    Label.stgHealthCheckFixNotApplicable,
                    new List<HealthCheckItemVModel>()
                ));

                healthCheckGroupVMod.totalChecks++;
                healthCheckGroupVMod.passedChecks++;
            }
        }

        healthCheckGroupVMod.updateHealthCheckStatus();
        return healthCheckGroupVMod;
    }

    

    /**********************************************************************************
    * @description Generates a HealthCheckGroupVModel comprised of the combined health 
    * check results for Default Account, Administrative and Household accounts. 
    * @param  healthCheckGroupVModelsList A list of HealthCheckGroupVModels
    * @return A HealthCheckGroupVModel representing the health check results for 
    * Default, Administrative and Household Accounts.
    **********************************************************************************/ 
    // @TestVisible
    // private HealthCheckGroupVModel combineAffiliationMappingHealthCheckGroupViewModels(List<HealthCheckGroupVModel> healthCheckGroupVModelsList) {
    //     String healthCheckGroupLabel = Label.stgHealthCheckAffiliationMappings;
    //     Integer hlthChkGroupPassedChecks = 0;
    //     Integer hlthChkGroupTotalChecks = 0;

    //     List<String> hlthChkGroupExpandedRowsList = new List<String>();
    //     List<HealthCheckItemVModel> hlthChkGroupHlthChkItemsList = new List<HealthCheckItemVModel>();

    //     for (HealthCheckGroupVModel healthCheckGroupVMod : healthCheckGroupVModelsList) {
    //         hlthChkGroupPassedChecks += healthCheckGroupVMod.passedChecks;
    //         hlthChkGroupTotalChecks += healthCheckGroupVMod.totalChecks;

    //         hlthChkGroupExpandedRowsList.addAll(healthCheckGroupVMod.expandedRowsList);
    //         hlthChkGroupHlthChkItemsList.addAll(healthCheckGroupVMod.healthCheckItemList);
    //     }

    //     String hlthChkGroupStatus = this.updateHealthCheckStatus(hlthChkGroupPassedChecks, hlthChkGroupTotalChecks);

    //     HealthCheckGroupVModel healthCheckGroupVMod = new HealthCheckGroupVModel(healthCheckGroupLabel,
    //                                                                          hlthChkGroupStatus,
    //                                                                          hlthChkGroupPassedChecks,
    //                                                                          hlthChkGroupTotalChecks,
    //                                                                          hlthChkGroupExpandedRowsList,
    //                                                                          hlthChkGroupHlthChkItemsList);
    //     healthCheckGroupVMod.healthCheckItemList.sort();
    //     return healthCheckGroupVMod;
    // }

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
