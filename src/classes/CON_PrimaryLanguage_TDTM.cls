/*
    Copyright (c) 2019, Salesforce.org
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
* @date 2019
* @group Contacts
* @group-content ../../ApexDocContent/Contacts.htm
* @description Ensures that Contact records are associated with Contact Language records corresponding to
* the language specified by the Primary Language field.  Creates new or modifies existing Contact Language
* records when applicable for Contacts inserted with a language specified as the Primary Language 
* or updated with changes to the Primary Language field.
*/
public with sharing class CON_PrimaryLanguage_TDTM extends TDTM_Runnable {

    /*******************************************************************************************************
    * @description Iterates over all Contact records being inserted or updated and ensures that if
    * a Primary Language is set, updated, or cleared, the corresponding Contact Language record is created or
    * updated accordingly.
    * @param newList the list of Contacts from trigger new.
    * @param oldList the list of Contacts from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Contact.
    * @return A null or empty dmlWrapper, since this TDTM class does its own DML processing.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newList, List<SObject> oldList,
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

            DmlWrapper dmlWrapper = new DmlWrapper();

            if (newList == null || newList.isEmpty() == true){
                return dmlWrapper;
            }

            if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
                this.handleAfterInsert(newList);
            } 

            if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                this.handleAfterUpdate(newList, oldList);
            } 

        return dmlWrapper;
    }

    /*******************************************************************************************************
     * @description Handles processing required for an After Insert trigger.
     * @param newSObjectsList The list of SObjects inserted.
     *******************************************************************************************************/ 
    @TestVisible
    private void handleAfterInsert(List<SObject> newSObjectsList){
        if (this.isInsertRecursion() == true) {
            return;
        }

        this.setInsertRecursion();
        Map<Id, Contact> newContactsById = new Map<Id, Contact>((List<Contact>)newSObjectsList);
        List<Contact_Language__c> contactLanguagesToCreateList = 
            this.locateContactPrimaryLanguageService().getContactLanguagesToCreate(newContactsById.values());
        
        if (contactLanguagesToCreateList.isEmpty() == true){
            this.unsetInsertRecursion();
            return;
        }

        DmlWrapper dmlWrapper = new DmlWrapper();
        dmlWrapper.objectsToInsert.addAll((List<SObject>)contactLanguagesToCreateList);
        TDTM_TriggerHandler.processDML(dmlWrapper, true);
        this.unsetInsertRecursion();
    }

    /*******************************************************************************************************
    * @description Handles processing required for an After Update trigger.
    * @param newSObjectsList The list of updated SObjects.
    * @param oldSObjectsList The list of SObjects in their state prior to update.
    *******************************************************************************************************/ 
    @TestVisible
    private void handleAfterUpdate(List<SObject> newSObjectsList, List<SObject> oldSObjectsList){
        if (this.isUpdateRecursion() == true){
            return;
        }

        this.setUpdateRecursion();
        
        Map<Id, Contact> newContactsById = new Map<Id, Contact>((List<Contact>)newSObjectsList);
        Map<Id, Contact> oldContactsById = new Map<Id, Contact>((List<Contact>)oldSObjectsList);

        List<Contact_Language__c> conLanguagesToInsertList = new List<Contact_Language__c>();
        List<Contact_Language__c> conLanguagesToUpdateList = new List<Contact_Language__c>();

        SRVC_ContactPrimaryLanguage.ContactLanguagesToProcess conLangToProcess = 
            this.locateContactPrimaryLanguageService().getContactLanguagesToCreateOrUpdate(newContactsById, oldContactsById);
        
        conLanguagesToInsertList = conLangToProcess.contactLanguagesToInsertList;
        conLanguagesToUpdateList = conLangToProcess.contactLanguagesToUpdateList;

        DmlWrapper dmlWrapper = new DmlWrapper();

        if (conLanguagesToUpdateList.isEmpty() == true && conLanguagesToInsertList.isEmpty() == true){
            this.unsetUpdateRecursion();
            return;
        } 
        
        dmlWrapper.objectsToInsert.addAll((List<SObject>)conLanguagesToInsertList);
        dmlWrapper.objectsToUpdate.addAll((List<SObject>)conLanguagesToUpdateList);
        TDTM_TriggerHandler.processDML(dmlWrapper, true);
        
        this.unsetUpdateRecursion();
    }

    /*******************************************************************************************************
    * @description Retrieves an instance of the SRVC_ContactPrimaryLanguage service class.
    * @return An instance of SRVC_ContactPrimaryLanguage.
    *******************************************************************************************************/ 
    @TestVisible
    private SRVC_ContactPrimaryLanguage locateContactPrimaryLanguageService(){
        return SRVC_ContactPrimaryLanguage.getInstance();
    }

    /*******************************************************************************************************
    * @description Sets the After Insert recursion flag for CON_PrimaryLanguage_TDTM.
    *******************************************************************************************************/ 
    @TestVisible
    private void setInsertRecursion(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM, true);
    }

    /*******************************************************************************************************
    * @description Clears the After Insert recursion flag for CON_PrimaryLanguage_TDTM.
    *******************************************************************************************************/ 
    @TestVisible
    private void unsetInsertRecursion(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM, false);
    }

    /*******************************************************************************************************
    * @description Determines whether current context is associated with an insert recursion.
    * @return False if both After Insert recursion flags for CLAN_PrimaryLanguage_TDTM and CON_PrimaryLanguage_TDTM are not set, true otherwise.
    *******************************************************************************************************/ 
    @TestVisible
    private Boolean isInsertRecursion(){
        return TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CLAN_PrimaryLanguage_TDTM) ||
        TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM);

    }

    /*******************************************************************************************************
    * @description Sets the After Update recurtion flag for CON_PrimaryLanguage_TDTM.
    *******************************************************************************************************/
    @TestVisible
    private void setUpdateRecursion(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM, true);
    }

    /*******************************************************************************************************
    * @description Clears the After Update recurtion flag for CON_PrimaryLanguage_TDTM.
    *******************************************************************************************************/
    @TestVisible
    private void unsetUpdateRecursion(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM, false);
    }

    /*******************************************************************************************************
    * @description Determines whether current context is associated with an update recursion.
    * @return False if both After Update recursion flags for CLAN_PrimaryLanguage_TDTM and CON_PrimaryLanguage_TDTM are unset, true otherwise.
    *******************************************************************************************************/ 
    @TestVisible
    private Boolean isUpdateRecursion(){
        return TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CLAN_PrimaryLanguage_TDTM) ||
        TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM);
    }
}