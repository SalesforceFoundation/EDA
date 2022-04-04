/*
    Copyright (c) 2016, Salesforce.org
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
 * @date 2016
 * @group Accounts
 * @group-content ../../ApexDocContent/Accounts.htm
 * @description Stops an Account from being deleted if it has any Address, Affiliation,
 * Attribute, Course, Contact(Household), Contact(Business Organization), Course Connection,
 * Education History, Facility, Program Enrollment, Program Plan, Term, or Time Block child records.
 */
public with sharing class ACCT_CannotDelete_TDTM extends TDTM_Runnable {
    //This variable has to be static because TDTM doesn't preserve TDTM_Runnable instance
    //between Before* and After* calls
    @TestVisible
    private static List<Account> accountsWithChildRelations;

    /*******************************************************************************************************
     * @description Stops an Account from being deleted if it has any Address, Affiliation,
     * Attribute, Course, Contact(Household), Contact(Business Organization), Course Connection,
     * Facility, Program Enrollment, Program Plan, Term, or Time Block child records.
     * @param listNew the list of Accounts from trigger new.
     * @param listOld the list of Accounts from trigger old.
     * @param triggerAction which trigger event (BeforeDelete).
     * @param objResult the describe for Accounts
     * @return dmlWrapper.
     ********************************************************************************************************/
    public override DmlWrapper run(
        List<SObject> newlist,
        List<SObject> oldlist,
        TDTM_Runnable.Action triggerAction,
        Schema.DescribeSObjectResult objResult
    ) {
        if (!this.locateAccountPreventDeletionService().isAccountDeletionPreventionEnabled()) {
            return new DmlWrapper();
        }

        if (triggerAction == TDTM_Runnable.Action.BeforeDelete) {
            accountsWithChildRelations = this.handleBeforeDelete(oldList);
        } else if (triggerAction == TDTM_Runnable.Action.AfterDelete) {
            this.handleAfterDelete(oldList);
            accountsWithChildRelations = null;
        }

        return new DmlWrapper();
    }

    /*******************************************************************************************************
     * @description Returns a List of Accounts with retrieved child relationships
     * @param oldSObjectList list of sObject records that are being deleted
     * @return List<Account>
     ********************************************************************************************************/
    @TestVisible
    private List<Account> handleBeforeDelete(List<SObject> oldSObjectList) {
        Map<Id, Account> oldAccountById = new Map<Id, Account>((List<Account>) oldSObjectList);
        return this.locateAccountPreventDeletionService().getAccountsAndChildRelationships(oldAccountById.keySet());
    }

    /*******************************************************************************************************
     * @description Passes a map of accounts By Id to SRVC_Account_PreventDeletion and returns a List of Accounts that have
     * been prevented for deletion
     * @param oldSObjectList list of sObject records that are being deleted
     * @return List<Account>
     ********************************************************************************************************/
    @TestVisible
    private List<Account> handleAfterDelete(List<SObject> oldSObjectList) {
        Map<Id, Account> oldAccountById = new Map<Id, Account>((List<Account>) oldSObjectList);
        return this.locateAccountPreventDeletionService()
            .preventDeletionForAccounts(oldAccountById, accountsWithChildRelations);
    }

    /*******************************************************************************************************
     * @description Returns the instance of SRVC_Account_PreventDeletion class
     * @return The instance of SRVC_Account_PreventDeletion class
     ********************************************************************************************************/
    @TestVisible
    private SRVC_Account_PreventDeletion locateAccountPreventDeletionService() {
        return SRVC_Account_PreventDeletion.getInstance();
    }
}
