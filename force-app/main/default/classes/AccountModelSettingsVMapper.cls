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
 * @description View model mapper class used to retrieve hierarchy setting mappings
 * related to Account model settings.
 */
public virtual with sharing class AccountModelSettingsVMapper {
    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static AccountModelSettingsVMapper instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected AccountModelSettingsVMapper() {
    }

    /*****************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of AccountModelSettingsVMapper.
     ******************************************************************************/
    public static AccountModelSettingsVMapper getInstance() {
        if (instance == null) {
            instance = new AccountModelSettingsVMapper();
        }

        return instance;
    }

    /*****************************************************************************
     * @description Retrieve a model representing active Account record types available
     * for selection in Account settings and the current values set in the Hierarchy Settings
     * fields for: Account Processor, Administrative Account Record Type and
     * Household Addresses Acc Record Type
     * @return An AccountModelSettingsVModel
     *****************************************************************************/
    public virtual AccountModelSettingsVModel getAccountModelSettingsViewModel() {
        Map<Id, RecordTypeModel> activeAccountRecordTypeModelsById = new Map<Id, RecordTypeModel>();

        // retrieve current account settings from Hierarchy settings
        AccountModelSettingsModel currentAccountSettingsModel = this.locateAccountModelSettingsService()
            .getAccountModelSettingsModel();

        Map<Id, RecordTypeModel> allAccountRecordTypeModelsById = this.locateRecordTypeService()
            .getModelByIdMapForSObjectType(Account.SObjectType);

        activeAccountRecordTypeModelsById = this.locateRecordTypeService()
            .getActiveRecordTypeModelsById(allAccountRecordTypeModelsById.values());

        // populate available combobox options with active Account record types
        List<ComboboxValueVModel> activeRecordTypeComboboxValueVModelsList = this.getComboboxVModelOptionsForActiveAccountRecordTypes(
            activeAccountRecordTypeModelsById.values()
        );

        // generate comboboxVModels for each account setting with selected value set as current value in hierarchy settings
        ComboboxVModel defaultAccountComboboxVModel = new ComboboxVModel(
            currentAccountSettingsModel.defaultAccountModelId,
            activeRecordTypeComboboxValueVModelsList
        );

        ComboboxVModel hhAccountComboboxVModel = new ComboboxVModel(
            currentAccountSettingsModel.householdAccountRecordTypeId,
            activeRecordTypeComboboxValueVModelsList
        );

        ComboboxVModel adminAccountComboboxVModel = new ComboboxVModel(
            currentAccountSettingsModel.administrativeAccountRecordTypeId,
            activeRecordTypeComboboxValueVModelsList
        );

        return new AccountModelSettingsVModel(
            defaultAccountComboboxVModel,
            hhAccountComboboxVModel,
            adminAccountComboboxVModel
        );
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
                new ComboboxValueVModel(activeAccountRecordTypeModel.name, activeAccountRecordTypeModel.id)
            );
        }

        return activeRecordTypeComboboxValueVModelsList;
    }

    /*****************************************************************************
     * @description Retrieves an instance of the AccountModelSettingsService class.
     * @return An instance of AccountModelSettingsService.
     ******************************************************************************/
    @TestVisible
    private AccountModelSettingsService locateAccountModelSettingsService() {
        return AccountModelSettingsService.getInstance();
    }

    /*****************************************************************************
     * @description Retrieves an instance of the AccountRecordTypeAutoDeletionService class.
     * @return An instance of AccountRecordTypeAutoDeletionService.
     ******************************************************************************/
    @TestVisible
    private AccountRecordTypeAutoDeletionService locateAccountRecordTypeAutoDeletionService() {
        return AccountRecordTypeAutoDeletionService.getInstance();
    }

    /*****************************************************************************
     * @description Retrieves an instance of the RecordTypeService class.
     * @return An instance of RecordTypeService.
     ******************************************************************************/
    @TestVisible
    private RecordTypeService locateRecordTypeService() {
        return RecordTypeService.getInstance();
    }
}
