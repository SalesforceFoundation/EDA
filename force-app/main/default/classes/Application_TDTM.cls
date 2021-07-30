/*
    Copyright (c) 2021, Salesforce.org
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
 * @date 2021
 * @group Applications
 * @group-content ../../ApexDocContent/Application.htm
 * @description This class prevents saving applications when the due date is prior to the open date.
 */
public with sharing class Application_TDTM extends TDTM_Runnable {
    /*******************************************************************************************************
     * @description Prevent an Application from being inserted when the Due Date is prior to the Open Date.
     * @param listNew the list of Applications from trigger new.
     * @param listOld the list of Applications from trigger old.
     * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
     * @param objResult the describe for Application
     * @return dmlWrapper.
     ********************************************************************************************************/
    public override DmlWrapper run(
        List<SObject> newList,
        List<SObject> oldList,
        TDTM_Runnable.Action triggerAction,
        Schema.DescribeSObjectResult objResult
    ) {
        if (newList == null || newList.isEmpty()) {
            return new DmlWrapper();
        }

        if (triggerAction == TDTM_Runnable.Action.BeforeInsert) {
            this.handleBeforeInsert(newList);
        }

        if (triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
            this.handleBeforeUpdate(oldList, newList);
        }

        return null;
    }

    /*******************************************************************************************************
     * @description Checks for applications with invalid open/due date range and marks them as invalid
     * @param newSObjectList list of sObject records that are being inserted
     * @return void
     ********************************************************************************************************/
    @TestVisible
    private void handleBeforeInsert(List<SObject> newSObjectList) {
        if (this.applicationWindowValidationIsEnabled() == false) {
            return;
        }
        List<Application__c> newApplications = (List<Application__c>) newSObjectList;

        for (Application__c newApplication : newApplications) {
            if (this.openDateIsAfterDueDate(newApplication)) {
                newApplication.addError(Label.stgErrorAppDueDate);
            }
        }
    }

    /*******************************************************************************************************
     * @description Checks for applications with invalid open/due date range and marks them as invalid
     * @param oldSObjectList list of sObject records that are being updated
     * @param newSObjectList list of sObject records that contain the record state prior to the update
     * @return void
     ********************************************************************************************************/
    @TestVisible
    private void handleBeforeUpdate(List<SObject> oldSObjectList, List<SObject> newSObjectList) {
        if (this.applicationWindowValidationIsEnabled() == false) {
            return;
        }
        List<Application__c> updatedApplications = (List<Application__c>) newSObjectList;
        Map<Id, Application__c> oldApplicationsById = new Map<Id, Application__c>(
            (List<Application__c>) oldSObjectList
        );

        for (Application__c updatedApplication : updatedApplications) {
            Application__c oldApplication = oldApplicationsById.get(updatedApplication.Id);

            if (
                this.openOrDueDateHasChanged(updatedApplication, oldApplication) &&
                this.openDateIsAfterDueDate(updatedApplication)
            ) {
                updatedApplication.addError(Label.stgErrorAppDueDate);
            }
        }
    }

    /*************************************************************************************************************************
     * @description Returns true when the application due/open date are both set, and the due date is prior to the open date.
     *************************************************************************************************************************/
    private Boolean openDateIsAfterDueDate(Application__c applicationToValidate) {
        if (
            !applicationToValidate.isSet(Application__c.Open_Date__c) ||
            !applicationToValidate.isSet(Application__c.Due_Date__c)
        ) {
            return false;
        }

        return applicationToValidate.Open_Date__c >= applicationToValidate.Due_Date__c;
    }

    /*************************************************************************************************************************
     * @description Returns true when either open date or due date on an application has been updated
     *************************************************************************************************************************/
    private Boolean openOrDueDateHasChanged(Application__c newApplication, Application__c oldApplication) {
        return newApplication.Open_Date__c != oldApplication.Open_Date__c ||
            newApplication.Due_Date__c != oldApplication.Due_Date__c;
    }

    /*******************************************************************************************************
     * @description Returns true when the application window validation trigger is enabled via custom settings
     ******************************************************************************************************/
    private Boolean applicationWindowValidationIsEnabled() {
        return UTIL_CustomSettingsFacade.getSettings().Application_Window_Validation__c;
    }
}
