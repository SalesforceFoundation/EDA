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
* @group Languages
* @group-content ../../ApexDocContent/Languages.htm
* @description Creates or modifies existing Contact Language records when the Contact's "Primary Language" 
* lookup field is manually changed.
*/
public with sharing class CON_PrimaryLanguage_TDTM extends TDTM_Runnable {

    private List<Contact_Language__c> contactLanguagesToUpdate = new List<Contact_Language__c>();
    private List<Contact_Language__c> contactLanguagesToInsert = new List<Contact_Language__c>();
    private Map<Id, Id> primaryLanguageByContact = new Map<Id, Id>();

    /*******************************************************************************************************
    * @description Iterates over all Contact records being inserted, updated, or deleted and ensures that if
    * a Primary Language is set, updated, or cleared, the corresponding Contact Language record is created or
    * updated accordingly.
    * @param newList the list of Contacts from trigger new.
    * @param oldList the list of Contacts from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Contact.
    * @return dmlWrapper A null or empty dmlWrapper, since this TDTM class does its own DML processing.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newList, List<SObject> oldList,
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

            DmlWrapper dmlWrapper = new DmlWrapper();

            if (newList == null || newList.isEmpty()){
                return dmlWrapper;
            }

            // After Insert
            if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
                this.handleAfterInsert(newList);
            } 

            //After Udpate
            if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                this.handleAfterUpdate(newList, oldList);
            } 

        //After Update
        // else if (triggerAction == TDTM_Runnable.Action.AfterUpdate && oldList != null && oldList.size() > 0) {
        //     for (Integer i = 0; i < newList.size(); i++) {
        //         Contact newContact = (Contact)newList[i];
        //         Contact oldContact = (Contact)oldList[i];

        //         if (newContact.Primary_Language__c == oldContact.Primary_Language__c) {
        //             // The Primary Language field isn't changing, so let's continue.
        //             continue;
        //         }

        //         primaryLanguageByContact.put(newContact.Id, newContact.Primary_Language__c);
        //     }
        // }

        // syncPrimaryContactLanguageRecords();

        // dmlWrapper.objectsToUpdate.addAll((List<SObject>)contactLanguagesToUpdate);
        // dmlWrapper.objectsToInsert.addAll((List<SObject>)contactLanguagesToInsert);

        // TDTM_TriggerHandler.processDML(dmlWrapper, true);
        // dmlWrapper = null;

        // // We're done with our updates, unset the recursion flag.
        // TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM, false);

        return dmlWrapper;
    }

    @TestVisible
    private SRVC_ContactPrimaryLanguage locateContactPrimaryLanguageService(){
        return SRVC_ContactPrimaryLanguage.getInstance();
    }

    @TestVisible
    private void setInsertRecursion(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM_After_Insert, true);
    }

    @TestVisible
    private void unsetInsertRecursion(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM_After_Insert, false);
    }

    @TestVisible
    private Boolean isInsertRecursion(){
        return TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CLAN_PrimaryLanguage_TDTM) ||
        TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM_After_Insert);
    }

    @TestVisible
    private void setUpdateRecursion(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM_After_Update, true);
    }

    @TestVisible
    private void unsetUpdateRecursion(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM_After_Update, false);
    }

    @TestVisible
    private Boolean isUpdateRecursion(){
        return TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CLAN_PrimaryLanguage_TDTM) ||
        TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM_After_Update);
    }

    /** 
     * 
    */
    private void handleAfterInsert(List<SObject> newObjectsList){
        if (this.isInsertRecursion()) {
            return;
        }

        this.setInsertRecursion();
        Map<Id, Contact> newContactsById = new Map<Id, Contact>((List<Contact>)newObjectsList);

        List<Contact_Language__c> contactLanguagesToCreateList = this.locateContactPrimaryLanguageService().getContactLanguagesToCreate(newContactsById.values());

        if (contactLanguagesToCreateList.isEmpty()){
            this.unsetInsertRecursion();
            return;
        }

        DmlWrapper dmlWrapper = new DmlWrapper();
        dmlWrapper.objectsToInsert.addAll((List<SObject>)contactLanguagesToCreateList);
        TDTM_TriggerHandler.processDML(dmlWrapper, true);

        this.unsetInsertRecursion();
    }

    private void handleAfterUpdate(List<SObject> newObjectsList, List<SObject> oldObjectsList){
        if (this.isUpdateRecursion()){
            return;
        }

        this.setUpdateRecursion();
        Map<Id, Contact> newContactsById = new Map<Id, Contact>((List<Contact>)newObjectsList);
        Map<Id, Contact> oldContactsById = new Map<Id, Contact>((List<Contact>)oldObjectsList);
        Map<Id, Id> primaryLanguageByContactId = new Map<Id, Id>();
        
        List<Contact_Language__c> conLanguagesToInsertList = this.locateContactPrimaryLanguageService().getContactLanguagesToCreateOrUpdate(newContactsById, oldContactsById).getConLanguagesToInsert();
        List<Contact_Language__c> conLanguagesToUpdateList = this.locateContactPrimaryLanguageService().getContactLanguagesToCreateOrUpdate(newContactsById, oldContactsById).getConLanguagesToUpdate();

        DmlWrapper dmlWrapper = new DmlWrapper();

        if (conLanguagesToInsertList.isEmpty()){
            this.unsetInsertRecursion();
            return;
        }

        // if (conLanguagesToUpdateList.isEmpty()){
        //     this.unsetUpdateRecursion();
        // }
        dmlWrapper.objectsToInsert.addAll((List<SObject>)conLanguagesToInsertList);
        dmlWrapper.objectsToUpdate.addAll((List<SObject>)conLanguagesToUpdateList);
        TDTM_TriggerHandler.processDML(dmlWrapper, true);
        
        this.unsetUpdateRecursion();
    }

    // private void syncPrimaryContactLanguageRecords() {
    //     if (primaryLanguageByContact == null || primaryLanguageByContact.size() == 0) {
    //         return;
    //     }

    //     Set<Id> contactsWithPrimaryContactLanguages = new Set<Id>();

    //     // Query for all existing Contact Language records that are for the given Contacts and Primary Languages,
    //     // or any Contact Language records that are marked as Primary that may need to be updated.
    //     List<Contact_Language__c> existingContactLanguages = [SELECT Id, Language__c, Contact__c, Primary_Language__c
    //         FROM Contact_Language__c
    //         WHERE Contact__c IN :primaryLanguageByContact.keySet()
    //             AND (Language__c IN :primaryLanguageByContact.values() OR Primary_Language__c = true)];

    //     // Iterate over all existing Contact Languages and verify that the appropriate records are set as the Primary Language.
    //     for (Contact_Language__c existingContactLanguage : existingContactLanguages) {
    //         Id primaryLanguageId = primaryLanguageByContact.get(existingContactLanguage.Contact__c);
            
    //         if (existingContactLanguage.Language__c == primaryLanguageId) {
    //             // A Contact Language record was found matching the Primary Language on the Contact, so we won't need to create a new record.
    //             contactsWithPrimaryContactLanguages.add(existingContactLanguage.Contact__c);

    //             if(!existingContactLanguage.Primary_Language__c) {
    //                 // This Contact Language record needs to be updated to be the Primary Language.
    //                 contactLanguagesToUpdate.add(new Contact_Language__c(Id = existingContactLanguage.Id, Primary_Language__c = true));
    //             }

    //         } else if (existingContactLanguage.Language__c != primaryLanguageId && existingContactLanguage.Primary_Language__c) {
    //             // This Contact Language record needs to be updated to no longer be the Primary Language.
    //             contactLanguagesToUpdate.add(new Contact_Language__c(Id = existingContactLanguage.Id, Primary_Language__c = false));

    //         }
    //     }

    //     // Create new Contact Language records for Contacts that don't have one yet.
    //     // We don't need to create Contact Language records for Contacts that already have a Primary Contact Language record.
    //     Set<Id> contactsToEvaluate = primaryLanguageByContact.keySet();
    //     contactsToEvaluate.removeAll(contactsWithPrimaryContactLanguages);

    //     if (contactsToEvaluate.size() == 0) {
    //         return;
    //     }

    //     String fluencyValue = UTIL_CustomSettingsFacade.getSettings().Default_Contact_Language_Fluency__c;
    //     for (Id contactId : primaryLanguageByContact.keySet()) {
    //         Id primaryLanguageId = primaryLanguageByContact.get(contactId);

    //         // This shouldn't happen, but just in case - don't create a Contact Language record for a blank Language
    //         if (primaryLanguageId == null) {
    //             continue;
    //         }

    //         contactLanguagesToInsert.add(new Contact_Language__c(
    //             Language__c = primaryLanguageId, Contact__c = contactId, Fluency__c = fluencyValue, Primary_Language__c = true
    //         ));
    //     }
    // }
}