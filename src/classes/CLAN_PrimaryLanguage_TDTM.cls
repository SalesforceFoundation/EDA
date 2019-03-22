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

        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
        Map<Id, Contact_Language__c> contactLanguagesToUpdate = new Map<Id, Contact_Language__c>();
        Map<Id, Id> existingPrimaryContactLanguageByContact = new Map<Id, Id>();

        // TODO: Refactor similar logic. Pull out into private method(s)

        if (newlist != null && newlist.size() > 0) {
            if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
                for (Contact_Language__c newContactLanguage : (List<Contact_Language__c>)newlist) {
                    if (!newContactLanguage.Primary_Language__c) { 
                        // This is not a Primary Language, so let's continue.
                        continue;
                    }

                    // Update the Primary Language lookup on the Contact to the Language record.
                    Id contactId = newContactLanguage.Contact__c;
                    contactsToUpdate.put(contactId, 
                        new Contact(Id = contactId, Primary_Language__c = newContactLanguage.Language__c));

                    // Is there more than one Primary Language for the same Contact being set in the same transaction? That's not allowed, 
                    // so set the other one to false.
                    if (existingPrimaryContactLanguageByContact.containsKey(contactId)) {
                        Id contactLanguageToUpdateId = existingPrimaryContactLanguageByContact.get(contactId);
                        contactLanguagesToUpdate.put(contactLanguageToUpdateId, 
                            new Contact_Language__c(Id = contactLanguageToUpdateId, Primary_Language__c = false));
                    }

                    existingPrimaryContactLanguageByContact.put(contactId, newContactLanguage.Id);
                }

                if (contactsToUpdate.size() > 0) {
                    // Query for any existing Contact Language records for the Contacts with Primary Language set to true.
                    List<Contact_Language__c> oldPrimaryContactLanguages = 
                        [SELECT Id, Primary_Language__c FROM Contact_Language__c 
                            WHERE Id NOT IN :newlist AND Contact__c IN :contactsToUpdate.keySet() AND Primary_Language__c = true];
                    
                    // Update the Contact Language records to no longer be marked as the Primary Language.
                    for (Contact_Language__c oldPrimaryContactLanguage : oldPrimaryContactLanguages) {
                        oldPrimaryContactLanguage.Primary_Language__c = false;
                        contactLanguagesToUpdate.put(oldPrimaryContactLanguage.Id, oldPrimaryContactLanguage);
                    }
                }
            } else if (triggerAction == TDTM_Runnable.Action.AfterUpdate && oldlist != null && oldlist.size() > 0) {

                Map<Id, Id> languageByContact = new Map<Id, Id>();

                for (Integer i = 0; i < newlist.size(); i++) {
                    Contact_Language__c newContactLanguage = (Contact_Language__c)newlist[i];
                    Contact_Language__c oldContactLanguage = (Contact_Language__c)oldlist[i];

                    if (newContactLanguage.Primary_Language__c == oldContactLanguage.Primary_Language__c) {
                        // The Primary Language field isn't changing, so let's continue.
                        continue;
                    }

                    // The Contact Language is being set as the Primary Language.
                    if (newContactLanguage.Primary_Language__c) {
                        // TODO: THIS CODE BLOCK IS BASICALLY THE SAME AS THE ABOVE.

                        // Update the Primary Language lookup on the Contact to the Language record.
                        Id contactId = newContactLanguage.Contact__c;
                        contactsToUpdate.put(contactId, 
                            new Contact(Id = contactId, Primary_Language__c = newContactLanguage.Language__c));

                        // Is there more than one Primary Language for the same Contact being set in the same transaction? That's not allowed, 
                        // so set the other one to false.
                        if (existingPrimaryContactLanguageByContact.containsKey(contactId)) {
                            Id contactLanguageToUpdateId = existingPrimaryContactLanguageByContact.get(contactId);
                            contactLanguagesToUpdate.put(contactLanguageToUpdateId, 
                                new Contact_Language__c(Id = contactLanguageToUpdateId, Primary_Language__c = false));
                        }

                        existingPrimaryContactLanguageByContact.put(contactId, newContactLanguage.Id);
                    } else { // The Contact Language is no longer the Primary Language.
                        languageByContact.put(newContactLanguage.Contact__c, newContactLanguage.Language__c);
                    }
                }

                if (contactsToUpdate.size() > 0) {
                    // Query for any existing Contact Language records for the Contacts with Primary Language set to true.
                    List<Contact_Language__c> oldPrimaryContactLanguages = 
                        [SELECT Id, Primary_Language__c FROM Contact_Language__c 
                            WHERE Id NOT IN :newlist AND Contact__c IN :contactsToUpdate.keySet() AND Primary_Language__c = true];
                    
                    // Update the Contact Language records to no longer be marked as the Primary Language.
                    for (Contact_Language__c oldPrimaryContactLanguage : oldPrimaryContactLanguages) {
                        oldPrimaryContactLanguage.Primary_Language__c = false;
                        contactLanguagesToUpdate.put(oldPrimaryContactLanguage.Id, oldPrimaryContactLanguage);
                    }
                }

                // Finally, clear the Primary Language lookup for all Contacts that no longer have a Primary Language.
                if (languageByContact.size() > 0) {
                    contactsToUpdate.putAll(clearContactPrimaryLanguage(languageByContact));
                }
            }
        }

        if (triggerAction == TDTM_Runnable.Action.AfterDelete && oldlist != null && oldlist.size() > 0) {
            // TODO: THIS CODE BLOCK IS BASICALLY THE SAME AS THE ABOVE. Mostly refactored, but could maybe be further refined.
            Map<Id, Id> languageByContact = new Map<Id, Id>();

            for (Contact_Language__c oldContactLanguage : (List<Contact_Language__c>)oldlist) {
                if (!oldContactLanguage.Primary_Language__c) { 
                    // This is not a Primary Language, so let's continue.
                    continue;
                }

                languageByContact.put(oldContactLanguage.Contact__c, oldContactLanguage.Language__c);
            }

            // Clear the Primary Language lookup for all Contacts that no longer have a Primary Language.
            if (languageByContact.size() > 0) {
                contactsToUpdate.putAll(clearContactPrimaryLanguage(languageByContact));
            }
        }

        // TODO: Remember to set recursion flag so that if we're updating contact language records to false we don't run through this trigger again.
        dmlWrapper.objectsToUpdate.addAll((List<SObject>)contactsToUpdate.values());
        dmlWrapper.objectsToUpdate.addAll((List<SObject>)contactLanguagesToUpdate.values());

        return dmlWrapper;
    }

    private Map<Id, Contact> clearContactPrimaryLanguage(Map<Id, Id> expectedLanguageByContact) {
        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();

        if (expectedLanguageByContact == null || expectedLanguageByContact.size() == 0) {
            return contactsToUpdate;
        }

        List<Contact> contactsToEvaluate = [SELECT Id, Primary_Language__c FROM Contact 
            WHERE Id IN :expectedLanguageByContact.keySet() AND Primary_Language__c != null];

        for (Contact contactToEvaluate : contactsToEvaluate) {
            if (contactToEvaluate.Primary_Language__c == expectedLanguageByContact.get(contactToEvaluate.Id)) {
                contactsToUpdate.put(contactToEvaluate.Id, 
                    new Contact(Id = contactToEvaluate.Id, Primary_Language__c = null));
            }
        }

        return contactsToUpdate;
    }
}