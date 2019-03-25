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
* @description Keeps the Contact "Primary Language" lookup field in sync with the Language associated to the
* Contact's primary Contact Language record.
*/
public with sharing class CLAN_PrimaryLanguage_TDTM extends TDTM_Runnable {

    private Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
    private Map<Id, Contact_Language__c> contactLanguagesToUpdate = new Map<Id, Contact_Language__c>();
    private Map<Id, Id> existingPrimaryContactLanguageByContact = new Map<Id, Id>();

    /*******************************************************************************************************
    * @description Iterates over all Contact Language records being inserted, updated, or deleted and performs
    * various actions for the records defined as the Primary Language or formerly defined as the Primary 
    * Language. Associated Contact records are updated to reflect the current Primary Language.
    * @param listNew the list of Contact Languages from trigger new.
    * @param listOld the list of Contact Languages from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Contact Languages.
    * @return dmlWrapper Any Contact Language and Contact records that need to be updated.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        DmlWrapper dmlWrapper = new DmlWrapper();

        if (TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CLAN_PrimaryLanguage_TDTM)) {
            return dmlWrapper;
        }

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CLAN_PrimaryLanguage_TDTM, true);

        if (newlist != null && newlist.size() > 0) {
            
            // After Insert
            if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
                for (Contact_Language__c newContactLanguage : (List<Contact_Language__c>)newlist) {
                    if (!newContactLanguage.Primary_Language__c) { 
                        // This is not a Primary Language, so let's continue.
                        continue;
                    }

                    // Update the Primary Language lookup on the Contact to the Language record. Ensure there is only one Primary Language.
                    setPrimaryLanguageOnContact(newContactLanguage.Contact__c, newContactLanguage.Id, newContactLanguage.Language__c);
                }

                if (contactsToUpdate.size() > 0) {
                    // Update old Primary Contact Language records to no longer be marked as the Primary Language.
                    clearOldPrimaryContactLanguages(contactsToUpdate.keySet(), new Set<Id>(existingPrimaryContactLanguageByContact.values()));
                }
            } 
            
            // After Update
            else if (triggerAction == TDTM_Runnable.Action.AfterUpdate && oldlist != null && oldlist.size() > 0) {

                Map<Id, Id> languageByContact = new Map<Id, Id>();

                for (Integer i = 0; i < newlist.size(); i++) {
                    Contact_Language__c newContactLanguage = (Contact_Language__c)newlist[i];
                    Contact_Language__c oldContactLanguage = (Contact_Language__c)oldlist[i];

                    if (newContactLanguage.Primary_Language__c == oldContactLanguage.Primary_Language__c) {
                        // The Primary Language field isn't changing, so let's continue.
                        continue;
                    }

                    if (newContactLanguage.Primary_Language__c) {
                        // Update the Primary Language lookup on the Contact to the Language record. Ensure there is only one Primary Language.
                        setPrimaryLanguageOnContact(newContactLanguage.Contact__c, newContactLanguage.Id, newContactLanguage.Language__c);
                    } else { 
                        // The Contact Language is no longer the Primary Language. Store the Language ID in a map to clear from the Contact later.
                        languageByContact.put(newContactLanguage.Contact__c, newContactLanguage.Language__c);
                    }
                }

                if (contactsToUpdate.size() > 0) {
                    // Update old Contact Language records to no longer be marked as the Primary Language.
                    clearOldPrimaryContactLanguages(contactsToUpdate.keySet(), new Set<Id>(existingPrimaryContactLanguageByContact.values()));
                }

                // Finally, clear the Primary Language lookup for all Contacts that no longer have a Primary Language.
                if (languageByContact.size() > 0) {
                    clearPrimaryLanguageOnContacts(contactsToUpdate.keySet(), languageByContact);
                }
            }
        }

        // After Delete
        if (triggerAction == TDTM_Runnable.Action.AfterDelete && oldlist != null && oldlist.size() > 0) {
            Map<Id, Id> languageByContact = new Map<Id, Id>();

            for (Contact_Language__c oldContactLanguage : (List<Contact_Language__c>)oldlist) {
                if (!oldContactLanguage.Primary_Language__c) { 
                    // This is not a Primary Language, so let's continue.
                    continue;
                }

                // The Contact Language is no longer the Primary Language. Store the Language ID in a map to clear from the Contact later.
                languageByContact.put(oldContactLanguage.Contact__c, oldContactLanguage.Language__c);
            }

            // Clear the Primary Language lookup for all Contacts that no longer have a Primary Language.
            if (languageByContact.size() > 0) {
                clearPrimaryLanguageOnContacts(contactsToUpdate.keySet(), languageByContact);
            }
        }

        // Add Contact records to dmlWrapper to be updated by the TDTM_TriggerHandler class
        dmlWrapper.objectsToUpdate.addAll((List<SObject>)contactsToUpdate.values());

        // Are there any Contact Language records to update? Update them now so that we prevent trigger recursion.
        if (contactLanguagesToUpdate.size() > 0) {
            update contactLanguagesToUpdate.values();
        }

        // We're done with our updates, unset the recursion flag.
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CLAN_PrimaryLanguage_TDTM, false);

        return dmlWrapper;
    }

    /*******************************************************************************************************
    * @description Queries for Contact Language records that are marked as the Primary Language for the given
    * set of Contacts, but not identified in the given set of primary Contact Languages. These Contact Languages 
    * are then added to the contactLanguagesToUpdate private map to be updated to no longer have the Primary 
    * Language checkbox set.
    * @param contacts The set of Contacts associated to the new Primary Contact Language records.
    * @param primaryContactLanguages The set of new Primary Contact Language records.
    ********************************************************************************************************/
    private void clearOldPrimaryContactLanguages(Set<Id> contacts, Set<Id> primaryContactLanguages) {
        if (contacts == null || primaryContactLanguages == null) { // Should never happen, but check it just in case...
            return;
        }

        // Query for any existing Contact Language records for the Contacts with Primary Language set to true, but not
        // in the given set of primary Contact Languages.
        List<Contact_Language__c> oldPrimaryContactLanguages = 
            [SELECT Id, Primary_Language__c FROM Contact_Language__c 
                WHERE Id NOT IN :primaryContactLanguages AND Contact__c IN :contacts AND Primary_Language__c = true];
        
        // Update the Contact Language records to no longer be marked as the Primary Language.
        for (Contact_Language__c oldPrimaryContactLanguage : oldPrimaryContactLanguages) {
            oldPrimaryContactLanguage.Primary_Language__c = false;
            contactLanguagesToUpdate.put(oldPrimaryContactLanguage.Id, oldPrimaryContactLanguage);
        }
    }

    /*******************************************************************************************************
    * @description Adds the given Contact to the contactsToUpdate private map to be updated with the new
    * Primary Language. If more than one Primary Language is being defined in the same transaction for the 
    * Contact, the other Contact Languages are added to the contactLanguagesToUpdate private map to be updated
    * to no longer have the Primary Checkbox set.
    * @param contactId The Contact whose Primary Language should be set.
    * @param contactLanguageId The Contact Language that is being marked as the Primary Language.
    * @param language The Primary Language to be set on the Contact. 
    ********************************************************************************************************/
    private void setPrimaryLanguageOnContact(Id contactId, Id contactLanguageId, Id languageId) {
        if (contactId == null || contactLanguageId == null) { // Should never happen, but check it just in case...
            return;
        }

        contactsToUpdate.put(contactId, new Contact(Id = contactId, Primary_Language__c = languageId));

        // Is there more than one Primary Language for the same Contact being set in the same transaction? That's not allowed, 
        // so set the other one to false.
        if (existingPrimaryContactLanguageByContact.containsKey(contactId)) {
            Id contactLanguageToUpdateId = existingPrimaryContactLanguageByContact.get(contactId);
            contactLanguagesToUpdate.put(contactLanguageToUpdateId, 
                new Contact_Language__c(Id = contactLanguageToUpdateId, Primary_Language__c = false));
        }

        existingPrimaryContactLanguageByContact.put(contactId, contactLanguageId);
    }

    /*******************************************************************************************************
    * @description Adds Contacts to the contactsToUpdate private map to be updated with a blank Primary
    * Language as long as the Primary Language lookup is set to the expected Language. Contacts in the set
    * of contactsWithNewPrimaryLanguage will be ignored, as these Contacts are being updated with a new
    * Primary Language instead.
    * @param contactsWithNewPrimaryLanguage The set of Contacts that should be ignored.
    * @param expectedLanguageByContact The expected value of the Primary Language lookup keyed by Contact ID. 
    ********************************************************************************************************/
    private void clearPrimaryLanguageOnContacts(Set<Id> contactsWithNewPrimaryLanguage, Map<Id, Id> expectedLanguageByContact) {
        if (expectedLanguageByContact == null || expectedLanguageByContact.size() == 0) {
            return;
        }

        Set<Id> contactsToQuery = new Set<Id>();
        // Build the list of contact IDs to query. We ignore contacts with a new primary language, as those records do not need to be cleared.
        for (Id contactId : expectedLanguageByContact.keySet()) {
            if (!contactsWithNewPrimaryLanguage.contains(contactId)) {
                contactsToQuery.add(contactId);
            }
        }

        // Query for all contacts to evaluate.
        List<Contact> contactsToEvaluate = [SELECT Id, Primary_Language__c FROM Contact 
            WHERE Id IN :contactsToQuery AND Primary_Language__c != null];

        for (Contact contactToEvaluate : contactsToEvaluate) {
            // Only update the Contact if the current value of its Primary Language matches the expected value.
            if (contactToEvaluate.Primary_Language__c == expectedLanguageByContact.get(contactToEvaluate.Id)) {
                contactsToUpdate.put(contactToEvaluate.Id, 
                    new Contact(Id = contactToEvaluate.Id, Primary_Language__c = null));
            }
        }
    }
}