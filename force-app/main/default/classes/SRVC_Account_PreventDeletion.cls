/*
Copyright (c) 2020, Salesforce.org
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
 * @date 2022
 * @group
 * @group-content ../../ApexDocContent/Accounts.htm
 * @description Service class for ACCT_CannotDelete_TDTM. Returns Account records
 * that have been prevented from deletion.
 */
public virtual with sharing class SRVC_Account_PreventDeletion {
    @TestVisible
    private Boolean enabledPreventAccountDeletion;

    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static SRVC_Account_PreventDeletion instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected SRVC_Account_PreventDeletion() {
        this.enabledPreventAccountDeletion = UTIL_CustomSettingsFacade.getSettings().Prevent_Account_Deletion__c;
    }

    /******************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of SRVC_Account_PreventDeletion.
     ******************************************************************************/
    public static SRVC_Account_PreventDeletion getInstance() {
        if (instance == null) {
            instance = new SRVC_Account_PreventDeletion();
        }

        return instance;
    }

    /**
     * @description Get the setting of preventing Account deletion
     * @return   Boolean account deletion prevention setting value
     */
    public Boolean isAccountDeletionPreventionEnabled() {
        return this.enabledPreventAccountDeletion;
    }

    /****************************************************************************************************************
    @description Returns a list of records that have been prevented from deletion
    @param accountById The map of accounts by their Ids
    @param accountsWithChildRecordsList A list of accounts with previously retrieved child relations
    @return The list of accounts prevented from deletion
    *****************************************************************************************************************/
    public virtual List<Account> preventDeletionForAccounts(
        Map<Id, Account> accountById,
        List<Account> accountsWithChildRecordsList
    ) {
        List<Account> accountPreventedFromDeletionList = new List<Account>();

        for (Account eachAccount : accountsWithChildRecordsList) {
            Account accountInContext = accountById.get(eachAccount.Id);
            if (!this.wasMerged(accountInContext) && this.hasChildRecords(eachAccount)) {
                accountInContext.addError(Label.CannotDelete);
                accountPreventedFromDeletionList.add(accountInContext);
            }
        }

        return accountPreventedFromDeletionList;
    }

    /****************************************************************************************************************
    @description Returns a list of Accounts and assocaited child records
    @params accountIdSet A set of Account Id to return the records for
    @return List<Account>
    *****************************************************************************************************************/
    public virtual List<Account> getAccountsAndChildRelationships(Set<Id> accountIdSet) {
        return [
            SELECT
                ID,
                (SELECT ID FROM Account.Addresses__r LIMIT 1),
                (SELECT ID FROM Account.Affl_Contacts__r LIMIT 1),
                (SELECT ID FROM Account.Attributes__r LIMIT 1),
                (SELECT ID FROM Account.Courses__r LIMIT 1),
                (SELECT ID FROM Account.Course_Enrollments__r LIMIT 1),
                (SELECT ID FROM Account.Education_History__r LIMIT 1),
                (SELECT ID FROM Account.Facilities__r LIMIT 1),
                (SELECT ID FROM Account.Household_Members__r LIMIT 1),
                (SELECT ID FROM Account.Organization_Members__r LIMIT 1),
                (SELECT ID FROM Account.Program_Enrollments__r LIMIT 1),
                (SELECT ID FROM Account.Program_Plans__r LIMIT 1),
                (SELECT ID FROM Account.Terms__r LIMIT 1),
                (SELECT ID FROM Account.Time_Blocks__r LIMIT 1)
            FROM Account
            WHERE ID IN :accountIdSet
        ];
    }

    /*******************************************************************************************************
     * @description Evaluates whether the Account has any child related records.
     * @param acc is the current Account record.
     * @return Boolean.
     ********************************************************************************************************/
    public virtual Boolean hasChildRecords(Account acc) {
        return (acc.Addresses__r.isEmpty() == false ||
        acc.Affl_Contacts__r.isEmpty() == false ||
        acc.Attributes__r.isEmpty() == false ||
        acc.Courses__r.isEmpty() == false ||
        acc.Course_Enrollments__r.isEmpty() == false ||
        acc.Education_History__r.isEmpty() == false ||
        acc.Facilities__r.isEmpty() == false ||
        acc.Household_Members__r.isEmpty() == false ||
        acc.Organization_Members__r.isEmpty() == false ||
        acc.Program_Enrollments__r.isEmpty() == false ||
        acc.Program_Plans__r.isEmpty() == false ||
        acc.Terms__r.isEmpty() == false ||
        acc.Time_Blocks__r.isEmpty() == false);
    }

    /**
     * @description Determines if an account was merged and being deleted as a merge loser
     * @param  acc An Account record
     * @return     True if an account was merged and being deleted
     */
    @TestVisible
    protected virtual Boolean wasMerged(Account acc) {
        return (acc.MasterRecordId != null) && (acc.MasterRecordId.getSobjectType() == Schema.Account.SObjectType);
    }
}
