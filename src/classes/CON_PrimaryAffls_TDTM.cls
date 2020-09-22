/*
    Copyright (c) 2014, Salesforce.org
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
* @date 2015
* @group Contacts
* @group-content ../../ApexDocContent/Contacts.htm
* @description
* 1)Creates Primary Affiliations when the user populates any of the Primary Affiliation lookup fields on the Contact object.
* 2)Create Primary Affiliations when the user updates any of the Primary Affiliation lookup fields on Contact and 
* resets the old Primary Affiliations to make them non-Primary.
* 3)Makes the Primary Affiliations non-Primary when Primary Affiliation Lookup fields on the Contact are cleared.
*/
public class CON_PrimaryAffls_TDTM extends TDTM_Runnable {

    /*******************************************************************************************************
    * @description Handles primary affiliation fields.
    * @param listNew the list of Accounts from trigger new.
    * @param listOld the list of Accounts from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Accounts
    * @return dmlWrapper.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newList, List<SObject> oldList,
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        if (newList == null || newList.isEmpty() == true) {
            return new DmlWrapper();
        }

        UTIL_Describe.cacheDescribeSObjectResult(objResult);

        if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
            this.handleAfterInsert(newList);
        }

        if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
            this.handleAfterUpdate(oldList, newList);
        }

        return new DmlWrapper();

    }

    /*******************************************************************************************************
    * @description Returns the instance of MAPR_PrimaryAffiliations class
    * @return The instance of MAPR_PrimaryAffiliations class
    ********************************************************************************************************/
    @TestVisible
    private MAPR_PrimaryAffiliations locateAffiliationSettingMapper() {
        return MAPR_PrimaryAffiliations.getInstance();
    }

    /*******************************************************************************************************
    * @description Returns the instance of SRVC_Contact_PrimaryAffiliations class
    * @return The instance of SRVC_Contact_PrimaryAffiliations class
    ********************************************************************************************************/
    @TestVisible
    private SRVC_Contact_PrimaryAffiliations locateContactAffiliationService() {
        return SRVC_Contact_PrimaryAffiliations.getInstance();
    }

    /*******************************************************************************************************
    * @description Returns the value of CON_PrimaryAffls_TDTM_After_Update recursion flag
    *******************************************************************************************************/
    @TestVisible
    private boolean isAffiliationUpdateRecursion() {
        return TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Update);
    }

    /*******************************************************************************************************
    * @description Sets the value of CON_PrimaryAffls_TDTM_keyAfflLookupUpdated recursion flag to true
    *******************************************************************************************************/
    @TestVisible
    private void setAffiliationUpdateRecursion() {
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_keyAfflLookupUpdated, true);
    }

    /*******************************************************************************************************
    * @description Resets the value of CON_PrimaryAffls_TDTM_keyAfflLookupUpdated recursion flag
    *******************************************************************************************************/
    @TestVisible
    private void resetAffiliationUpdateRecursion() {
        TDTM_ProcessControl.resetRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_keyAfflLookupUpdated); 
    }

    /*******************************************************************************************************
    * @description Returns the value of CON_PrimaryAffls_TDTM_After_Insert recursion flag
    *******************************************************************************************************/
    @TestVisible
    private boolean isInsertRecursion() {
        return TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Insert);
    }

    /*******************************************************************************************************
    * @description Sets the value of CON_PrimaryAffls_TDTM_After_Insert recursion flag to true
    *******************************************************************************************************/
    @TestVisible
    private void setInsertRecursion() {
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Insert, true);
    }

    /*******************************************************************************************************
    * @description Sets the value of CON_PrimaryAffls_TDTM_After_Insert recursion flag to false
    *******************************************************************************************************/
    @TestVisible
    private void unsetInsertRecursion() {
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Insert, false);
    }

    /************************************************************************************************************************************
    * @description Returns the value of operation (AFFL_AccRecordType_TDTM OR CON_PrimaryAffls_TDTM_After_Update)
    **************************************************************************************************************************************/
    @TestVisible
    private boolean isUpdateRecursion() {
        return TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_AccRecordType_TDTM) || 
            TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Update);
    }

    /************************************************************************************************************************************
    * @description Sets the recursion flag CON_PrimaryAffls_TDTM_After_Update) to true
    **************************************************************************************************************************************/
    @TestVisible
    private void setUpdateRecursion() {
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Update, true);
    }

    /************************************************************************************************************************************
    * @description unsets the recursion flag CON_PrimaryAffls_TDTM_After_Update) to false
    **************************************************************************************************************************************/
    @TestVisible
    private void unsetUpdateRecursion() {
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Update, false);
    }

    /*******************************************************************************************************
    * @description Returns if Contact Deletion Prevention custom setting is not enabled or
    * Passes a map of contacts By Id to SRVC_Contact_PreventDeletion and returns a List of Contacts that have
    * been prevented for deletion
    * @param newSObjectList list of sObject records that are being deleted
    * @return void
    ********************************************************************************************************/
    @TestVisible
    private void handleAfterInsert(List<SObject> newSObjectList) {

        if (this.isInsertRecursion() == true) {
            return;
        }

        this.setInsertRecursion();

        Map<Id, Contact> newContactById = new Map<Id, Contact>((List<Contact>)newSObjectList);

        // Get Primary Affiliation Mapping Models from the Primary Affiliation Settings Mapper
        List<MODL_PrimaryAfflMapper> primaryAffiliationModels = this.locateAffiliationSettingMapper().getModelsFromSettings();

        // Get the Affiliation records to create from the Contact Primary Affiliation Service
        List<Affiliation__c> affiliationsToInsert = this.locateContactAffiliationService().getAffiliationsToCreate(newContactById.values(), primaryAffiliationModels);

        if (affiliationsToInsert.size() == 0) {
            this.unsetInsertRecursion();
            return;
        }

        this.setAffiliationUpdateRecursion();

        DmlWrapper dmlWrapper = new DmlWrapper();
        dmlWrapper.objectsToInsert.addAll((List<SObject>)affiliationsToInsert);
        TDTM_TriggerHandler.processDML(dmlWrapper, true);
        this.resetAffiliationUpdateRecursion();
        this.unsetInsertRecursion();

    }

    /*******************************************************************************************************
    * @description Returns if Contact Deletion Prevention custom setting is not enabled or
    * Passes a map of contacts By Id to SRVC_Contact_PreventDeletion and returns a List of Contacts that have
    * been prevented for deletion
    * @param oldSObjectList list of sObject records that are being deleted
    * @return List<Contact>
    ********************************************************************************************************/
    @TestVisible
    private void handleAfterUpdate(List<SObject> oldSObjectList, List<SObject> newSObjectList) {

        if (this.isUpdateRecursion() == true) {
            return;
        }

        this.setUpdateRecursion(); 

        Map<Id, Contact> oldContactById = new Map<Id, Contact>((List<Contact>)oldSObjectList);
        Map<Id, Contact> newContactById = new Map<Id, Contact>((List<Contact>)newSObjectList);

        List<MODL_PrimaryAfflMapper> primaryAffiliationModels = this.locateAffiliationSettingMapper().getModelsFromSettings();

        SRVC_Contact_PrimaryAffiliations.AffiliationsToInsertAndUpdate affiliationsToInsertAndUpdate = this.locateContactAffiliationService().getAffiliationsToCreateOrUpdate(newContactById, oldContactById, primaryAffiliationModels);
        
        DmlWrapper dmlWrapper = new DmlWrapper();

        if (AffiliationsToInsertAndUpdate.getAffiliationListToUpdateClone().isEmpty() == false) {
            this.setAffiliationUpdateRecursion();
            dmlWrapper.objectsToUpdate.addAll((List<SObject>)(AffiliationsToInsertAndUpdate.getAffiliationListToUpdateClone()));
        }

        if (AffiliationsToInsertAndUpdate.getAffiliationListToinsertClone().isEmpty() == false) {
            if (this.isAffiliationUpdateRecursion() == false) {
                this.setAffiliationUpdateRecursion();
            }

            dmlWrapper.objectsToInsert.addAll((List<SObject>)(AffiliationsToInsertAndUpdate.getAffiliationListToInsertClone()));

        }

        TDTM_TriggerHandler.processDML(dmlWrapper, true);

        if (this.isAffiliationUpdateRecursion() == true) {
            this.resetAffiliationUpdateRecursion();
        }

        this.unsetUpdateRecursion();
    }
}