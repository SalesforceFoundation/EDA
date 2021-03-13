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
 * @description View mapper to generate view models associated with Account Auto Deletion funtionality.
 */
public virtual with sharing class AccountAutoDeletionSettingsVMapper {
    /**********************************************************************************
     * @description Instance for Singleton Pattern
     **********************************************************************************/
    @TestVisible
    private static AccountAutoDeletionSettingsVMapper instance;

    /**********************************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************************/
    protected AccountAutoDeletionSettingsVMapper() {
    }

    /**********************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of AccountAutoDeletionSettingsVMapper.
     **********************************************************************************/
    public static AccountAutoDeletionSettingsVMapper getInstance() {
        if (instance == null) {
            instance = new AccountAutoDeletionSettingsVMapper();
        }

        return instance;
    }

    public DualListboxVModel getAccountAutoDeletionSettingsViewModel() {
        // get current values set for deletion from hierarchy settings
        AccountRecordTypeAutoDeletionModel currentAutoDeletionSettings = this.locateAccountRecordTypeAutoDeletionService()
            .getAccountRecordTypeAutoDeletionModel();

        // get all active account record types in org
        Map<Id, RecordTypeModel> activeAccountRecordTypeModelsById = this.locateRecordTypeService()
            .getModelByIdMapForSObjectType(Account.SObjectType);

        // filter out inactive record types
        for (Id accountRecordTypeModelId : activeAccountRecordTypeModelsById.keySet()) {
            if (activeAccountRecordTypeModelsById.get(accountRecordTypeModelId).isActive == false) {
                activeAccountRecordTypeModelsById.remove(accountRecordTypeModelId);
            }
        }

        // create DualListboxValueVModels for each of the selected and available options
        List<DualListboxValueVModel> selectedDualListboxValuesList = new List<DualListboxValueVModel>();
        List<DualListboxValueVModel> availableDualListboxValuesList = new List<DualListboxValueVModel>(); // should be all active record types - selected record types
        for (
            String accountRecordTypeIdToDelete : currentAutoDeletionSettings.accountRecordTypeIdsForDeletionWhenOrphanedList
        ) {
            selectedDualListboxValuesList.add(
                //TODO: what is selected account RT is inactive?  Does is show?
                new DualListboxValueVModel(
                    activeAccountRecordTypeModelsById.get((Id) accountRecordTypeIdToDelete)?.name,
                    accountRecordTypeIdToDelete
                )
            );
        }

        return new DualListboxVModel(selectedDualListboxValuesList, availableDualListboxValuesList);
    }

    /*****************************************************************************
     * @description Retrieve an instance of the AccountRecordTypeAutoDeletionService class.
     * @return An instance of AccountRecordTypeAutoDeletionService.
     *****************************************************************************/
    @TestVisible
    private AccountRecordTypeAutoDeletionService locateAccountRecordTypeAutoDeletionService() {
        return AccountRecordTypeAutoDeletionService.getInstance();
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
