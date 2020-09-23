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

    /*******************************************************************************************************
    * @description Get the setting of preventing Account deletion
    */
    private static Boolean enabledPreventAccountDeletion = UTIL_CustomSettingsFacade.getSettings().Prevent_Account_Deletion__c;

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
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        if (!enabledPreventAccountDeletion) {
            return new DmlWrapper(); 
        }

        Map<ID, Account> oldmap = new Map<ID, Account>((List<Account>)oldList);

        if (triggerAction == TDTM_Runnable.Action.BeforeDelete) {
            for (Account acc : [SELECT ID, 
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
                                FROM Account WHERE ID IN :oldlist]) {

                if (this.hasChildRecords(acc)) {
                    Account accountInContext = oldMap.get(acc.ID);
                    accountInContext.addError(Label.CannotDelete);
                }
            }     
        }
        return new DmlWrapper();
    }

    /*******************************************************************************************************
     * @description Evaluates whether the Account has any child related records.
     * @param a is the current Account record.
     * @return Boolean.
     ********************************************************************************************************/
    private Boolean hasChildRecords(Account acc) {
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
}