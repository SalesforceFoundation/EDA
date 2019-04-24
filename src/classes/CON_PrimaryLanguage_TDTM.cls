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
    * @param listNew the list of Contacts from trigger new.
    * @param listOld the list of Contacts from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Contact.
    * @return dmlWrapper Any Contact Language records that need to be inserted or updated.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        DmlWrapper dmlWrapper = new DmlWrapper();

        // If this trigger is running as a result of the Contact Language trigger, just exit early - that trigger
        // already did the work for us!
        if (TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CLAN_PrimaryLanguage_TDTM)) {
            return dmlWrapper;
        }

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM, true);

        if (newlist != null && newlist.size() > 0) {

            // After Insert
            if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
                for (Contact newContact : (List<Contact>)newlist) {
                    if (newContact.Primary_Language__c == null) { 
                        // No Primary Language, so let's continue.
                        continue;
                    }

                    primaryLanguageByContact.put(newContact.Id, newContact.Primary_Language__c);
                }
            } 

            // After Update
            else if (triggerAction == TDTM_Runnable.Action.AfterUpdate && oldlist != null && oldlist.size() > 0) {
                for (Integer i = 0; i < newlist.size(); i++) {
                    Contact newContact = (Contact)newlist[i];
                    Contact oldContact = (Contact)oldlist[i];

                    if (newContact.Primary_Language__c == oldContact.Primary_Language__c) {
                        // The Primary Language field isn't changing, so let's continue.
                        continue;
                    }

                    primaryLanguageByContact.put(newContact.Id, newContact.Primary_Language__c);
                }
            }
        }

        syncPrimaryContactLanguageRecords();

        dmlWrapper.objectsToUpdate.addAll((List<SObject>)contactLanguagesToUpdate);
        dmlWrapper.objectsToInsert.addAll((List<SObject>)contactLanguagesToInsert);

        TDTM_TriggerHandler.processDML(dmlWrapper, true);
        dmlWrapper = null;

        // We're done with our updates, unset the recursion flag.
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_PrimaryLanguage_TDTM, false);

        return dmlWrapper;
    }

    private void syncPrimaryContactLanguageRecords() {
        if (primaryLanguageByContact == null || primaryLanguageByContact.size() == 0) {
            return;
        }

        Set<Id> contactsWithPrimaryContactLanguages = new Set<Id>();

        // Query for all existing Contact Language records that are for the given Contacts and Primary Languages,
        // or any Contact Language records that are marked as Primary that may need to be updated.
        List<Contact_Language__c> existingContactLanguages = [SELECT Id, Language__c, Contact__c, Primary_Language__c
            FROM Contact_Language__c
            WHERE Contact__c IN :primaryLanguageByContact.keySet()
                AND (Language__c IN :primaryLanguageByContact.values() OR Primary_Language__c = true)];

        // Iterate over all existing Contact Languages and verify that the appropriate records are set as the Primary Language.
        for (Contact_Language__c existingContactLanguage : existingContactLanguages) {
            Id primaryLanguageId = primaryLanguageByContact.get(existingContactLanguage.Contact__c);
            
            if (existingContactLanguage.Language__c == primaryLanguageId) {
                // A Contact Language record was found matching the Primary Language on the Contact, so we won't need to create a new record.
                contactsWithPrimaryContactLanguages.add(existingContactLanguage.Contact__c);

                if(!existingContactLanguage.Primary_Language__c) {
                    // This Contact Language record needs to be updated to be the Primary Language.
                    contactLanguagesToUpdate.add(new Contact_Language__c(Id = existingContactLanguage.Id, Primary_Language__c = true));
                }

            } else if (existingContactLanguage.Language__c != primaryLanguageId && existingContactLanguage.Primary_Language__c) {
                // This Contact Language record needs to be updated to no longer be the Primary Language.
                contactLanguagesToUpdate.add(new Contact_Language__c(Id = existingContactLanguage.Id, Primary_Language__c = false));

            }
        }

        // Create new Contact Language records for Contacts that don't have one yet.
        // We don't need to create Contact Language records for Contacts that already have a Primary Contact Language record.
        Set<Id> contactsToEvaluate = primaryLanguageByContact.keySet();
        contactsToEvaluate.removeAll(contactsWithPrimaryContactLanguages);

        if (contactsToEvaluate.size() == 0) {
            return;
        }

        String fluencyValue = UTIL_CustomSettingsFacade.getSettings().Default_Contact_Language_Fluency__c;
        for (Id contactId : primaryLanguageByContact.keySet()) {
            Id primaryLanguageId = primaryLanguageByContact.get(contactId);

            // This shouldn't happen, but just in case - don't create a Contact Language record for a blank Language
            if (primaryLanguageId == null) {
                continue;
            }

            contactLanguagesToInsert.add(new Contact_Language__c(
                Language__c = primaryLanguageId, Contact__c = contactId, Fluency__c = fluencyValue, Primary_Language__c = true
            ));
        }
    }
}