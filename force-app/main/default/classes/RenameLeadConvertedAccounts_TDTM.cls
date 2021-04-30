/*
    Copyright (c) 2009, Salesforce.org
    All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
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
 * @date 2011 (1.x)
 * @group Accounts
 * @group-content ../../ApexDocContent/Accounts.htm
 * @description Names Accounts involved in a Lead Conversion based on EDA Settings
 */
public class RenameLeadConvertedAccounts_TDTM extends TDTM_Runnable {
    private TDTM_Runnable.Action triggerAction;
    LeadConversionAccountNamingModel leadConversionNamingModel = LeadConversionAccountNamingService.getInstance()
        .getLeadConversionAccountNamingModel();

    /*******************************************************************************************************
     * @description Trigger Handler on lead that handles account management. Depending on the Account
     * Model, names the Accounts based on EDA Settings
     * @param newlist a list of leads from trigger new.
     * @param oldlist a list of leads from trigger old.
     * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
     * @param objResult the describe for leads.
     * @return dmlWrapper.
     */
    public override DmlWrapper run(
        List<SObject> newlist,
        List<SObject> oldlist,
        TDTM_Runnable.Action triggerAction,
        Schema.DescribeSObjectResult objResult
    ) {
        if (newList == null || newList.isEmpty() == true) {
            return new DmlWrapper();
        }

        if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
            this.handleAfterUpdate(newList, oldList);
        }

        return new DmlWrapper();
    }

    /*******************************************************************************************************
     * @description Calls correct methods to process after update
     * logic and sets recursion flag.
     * @param newList a list of SObjects with updates
     * @param oldList a list of SObjects prior to update
     */
    private void handleAfterUpdate(List<SObject> newList, List<SObject> oldList) {
        if (this.isUpdateRecursion() == true) {
            return;
        }
        if (leadConversionNamingModel.accountRecordTypeIdsForLeadConversionWhenOrphanedList.isEmpty()) {
            return;
        }

        this.setUpdateRecursion();

        List<lead> newLeadList = (List<lead>) newlist;

        List<Id> contactIdsToUpdate = new List<Id>();
        List<Account> accountsToUpdate = new List<Account>();

        for (Lead aLead : newLeadList) {
            if (aLead.IsConverted) {
                contactIdsToUpdate.add(aLead.ConvertedContactId);
            }
        }

        for (Contact aContact : [
            SELECT Account.Id, Account.Phone, Account.Fax, Account.OwnerId, Account.RecordTypeId, FirstName, LastName
            FROM Contact
            WHERE Id IN :contactIdsToUpdate
        ]) {
            if (
                UTIL_CustomSettingsFacade.getSettings().Lead_Converted_Account_RTypes__c != null &&
                aContact.Account.RecordTypeId != null &&
                UTIL_CustomSettingsFacade.getSettings()
                    .Lead_Converted_Account_RTypes__c.contains(aContact.Account.RecordTypeId)
            ) {
                Account anAccount = new Account(
                    Phone = aContact.Account.Phone,
                    Fax = aContact.Account.Fax,
                    OwnerId = aContact.Account.OwnerId,
                    Id = aContact.Account.Id,
                    RecordTypeId = aContact.Account.RecordTypeId
                );

                anAccount.Name = UTIL_ACCT_Naming.updateNameFromContact(new List<Contact>{ aContact }, anAccount);
                accountsToUpdate.add(anAccount);
            }

            if (accountsToUpdate.size() > 0) {
                DmlWrapper dmlWrapper = new DmlWrapper();
                dmlWrapper.objectsToUpdate.addAll((List<SObject>) accountsToUpdate);
                TDTM_TriggerHandler.processDML(dmlWrapper, true);
            }
        }

        TDTM_ProcessControl.setRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.RenameLeadConvertedAccounts_TDTM_After_Update,
            false
        );
    }

    /*******************************************************************************************************
     * @description Checks after update recursion flag for this class.
     * @return Boolean.
     */
    private Boolean triggerActionAfterUpdate() {
        return TDTM_ProcessControl.getRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.RenameLeadConvertedAccounts_TDTM_After_Update
        );
    }

    /************************************************************************************************************************************
     * @description Returns the value of operation (RenameLeadConvertedAccounts_TDTM OR RenameLeadConvertedAccounts_TDTM_After_Update)
     **************************************************************************************************************************************/
    @TestVisible
    private boolean isUpdateRecursion() {
        return TDTM_ProcessControl.getRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.RenameLeadConvertedAccounts_TDTM_After_Update
        );
    }

    /************************************************************************************************************************************
     * @description Sets the recursion flag RenameLeadConvertedAccounts_TDTM_After_Update) to true
     **************************************************************************************************************************************/
    @TestVisible
    private void setUpdateRecursion() {
        TDTM_ProcessControl.setRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.RenameLeadConvertedAccounts_TDTM_After_Update,
            true
        );
    }
}
