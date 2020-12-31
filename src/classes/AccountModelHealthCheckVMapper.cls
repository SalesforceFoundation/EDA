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
* @description Class to ....
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
    * @description Generates a default HealthCheckGroupVModel for an AccountModel health check
    * @param  acctModelSettingsMod An AccountModelSettingsModel
    * @param  recordTypeModelsById A map of Record Type models by Id
    * @return A HealthCheckGroupVModel with default values set for AccountModel
    **********************************************************************************/
    @TestVisible
    private HealthCheckGroupVModel getDefaultAccountModelHealthCheckItems(AccountModelSettingsModel acctModelSettingsMod, 
                                                                          Map<Id,RecordTypeModel> recordTypeModelsById) {
        
        List<HealthCheckItemVModel> hlthCheckItems = new List<HealthCheckItemVModel>();
        Integer hlthChkGroupPassedChecks = 0;
        Integer hlthChkGroupTotalChecks = 0;
        String hlthChkGroupStatus = (hlthChkGroupPassedChecks == hlthChkGroupTotalChecks) ? Label.stgHealthCheckStatusPassed : Label.stgHealthCheckStatusFailed;

        HealthCheckGroupVModel hlthChkGroupVMod = new HealthCheckGroupVModel('AccountModel',
                                                                             hlthChkGroupStatus,
                                                                             hlthChkGroupPassedChecks,
                                                                             hlthChkGroupTotalChecks,
                                                                             new List<String>(),
                                                                             hlthCheckItems);
        RecordTypeModel accountRTModel = 
            this.locateRecordTypeService().getRecordTypeModelFromMap(acctModelSettingsMod.defaultAccountModelId, recordTypeModelsById);

        if (accountRTModel == null) {
            hlthCheckItems.add(new HealthCheckItemVModel('01',
                                                         Label.stgAccModelTitle,
                                                         'Fail',
                                                         Label.stgHealthCheckStatusFailed,
                                                         String.format(Label.stgHCRecordTypeNotFound, 
                                                                        new List<Object>{acctModelSettingsMod.defaultAccountModelId}),
                                                         String.format(Label.stgHCAccountModelDefaultNotFoundFix, 
                                                                        new List<Object>{acctModelSettingsMod.defaultAccountModelId})));
            hlthChkGroupTotalChecks++;
            return hlthChkGroupVMod;
        }

        if (accountRTModel.isActive == false) {
            hlthCheckItems.add(new HealthCheckItemVModel('01',
                                                         Label.stgAccModelTitle,
                                                         'Fail',
                                                         Label.stgHealthCheckStatusFailed,
                                                         String.format(Label.stgHCRecordTypeInactive, 
                                                                        new List<Object>{accountRTModel.name}),
                                                         String.format(Label.stgHCAccountModelDefaultInactiveFix, 
                                                                        new List<Object>{accountRTModel.developerName})));
            hlthChkGroupTotalChecks++;
            return hlthChkGroupVMod;
        }

        hlthCheckItems.add(new HealthCheckItemVModel('01',
                                                     Label.stgAccModelTitle,
                                                     'Pass',
                                                     Label.stgHealthCheckStatusPassed,
                                                     String.format(Label.stgHCRecordTypeValid, 
                                                                   new List<Object>{accountRTModel.name, accountRTModel.developerName}),
                                                     Label.stgHealthCheckFixNotApplicable));
        hlthChkGroupTotalChecks++;
        hlthChkGroupPassedChecks++;
        return hlthChkGroupVMod;
    }

    /**********************************************************************************
    * @description Retrieve a HealthCheckGroup view model for Account.
    * @return A HealthCheckGroupVModel.
    **********************************************************************************/ 
    public virtual HealthCheckGroupVModel getHealthCheckGroup() {
        AccountModelSettingsModel acctModSettingMod = this.locateAccountModelSettingsService().getAccountModelSettingsModel();
        Map<Id, RecordTypeModel> accountRTModelsById = this.locateRecordTypeService().getModelByIdMapForSObjectType(Account.SObjectType);

        String hlthCheckGroupLabel = Label.stgHealthCheckAccountModel;
        Integer hlthChkGroupPassedChecks = 0;
        Integer hlthChkGroupTotalChecks = 0;
        String hlthChkGroupStatus = (hlthChkGroupPassedChecks == hlthChkGroupTotalChecks) ? Label.stgHealthCheckStatusPassed : Label.stgHealthCheckStatusFailed;

        List<String> hlthChkGroupExpandedRowsList = new List<String>();
        List<HealthCheckItemVModel> hlthChkGroupHlthChkItemsList = new List<HealthCheckItemVModel>();

        HealthCheckGroupVModel hlthChkGroupVMod = new HealthCheckGroupVModel(hlthCheckGroupLabel,
                                                                             hlthChkGroupStatus,
                                                                             hlthChkGroupPassedChecks,
                                                                             hlthChkGroupTotalChecks,
                                                                             hlthChkGroupExpandedRowsList,
                                                                             hlthChkGroupHlthChkItemsList);
        hlthChkGroupVMod.hlthChkGroupHlthChkItemsList.sort();
        return hlthChkGroupVMod;
        // HealthCheckGroupVModel hlthChkGroupVMod = this.getDefaultAccountModelHealthCheckItems(acctModSettingMod, accountRTModelsById);
        

        // return hlthChkGroupVMod;

        // List<HealthCheckItemVModel> healthCheckItemList = new List<HealthCheckItemVModel>();

        // HealthCheckItemVModel hcItem1 = new HealthCheckItemVModel('01',
        //                                                            Label.stgAccModelTitle,
        //                                                            'Fail',
        //                                                            Label.stgHealthCheckStatusFailed,
        //                                                            String.format(Label.stgHCRecordTypeNotFound, 
        //                                                                          new List<Object>{'000000000000000000'}),
        //                                                            String.format(Label.stgHCAccountModelDefaultNotFoundFix,
        //                                                                          new List<Object>{acctModSettingMod.defaultAccountModelId}),
        //                                                            new List<HealthCheckItemVModel>());
                                                                   
        // HealthCheckItemVModel hcItem2 = new HealthCheckItemVModel('02',
        //                                                            Label.stgAdminAccountRecordType,
        //                                                            'Fail',
        //                                                            Label.stgHealthCheckStatusFailed,
        //                                                            String.format(Label.stgHCRecordTypeInactive,
        //                                                                          new List<Object>{'Mock Admin Label', 'mock_admin_api'}),
        //                                                            String.format(Label.stgHCAccountModelAdminInactiveFix,
        //                                                                          new List<Object>{'Mock Admin Label', 'mock_admin_api'}),
        //                                                            new List<HealthCheckItemVModel>());


        // healthCheckItemList.add(hcItem1);
        // healthCheckItemList.add(hcItem2);

        // return new HealthCheckGroupVModel(Label.stgHealthCheckAccountModel,
        //                                   'Fail',
        //                                   2,
        //                                   4,
        //                                   new List<String>(),
        //                                   healthCheckItemList);
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
