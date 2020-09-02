/*
    Copyright (c) 2020, Salesforce.org
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
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
* @date 2020
* @group 
* @group-content ../../ApexDocContent/
* @description Service class for CON_PrimaryLanguage_TDTM.  Identifies new Contact Language records
* to create and existing Contact Language records to update.
*/
public virtual with sharing class SRVC_ContactPrimaryLanguage {

    /*********************************************
    * @description Instance for Singleton Pattern.
    **********************************************/
    @TestVisible
    private static SRVC_ContactPrimaryLanguage instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern.
    **********************************************************************/
    protected SRVC_ContactPrimaryLanguage() {}

    /*****************************************************************************
    * @description Static method to get the current instance for Singleton pattern.
    * @return The instance of SRVC_ContactPrimaryLanguage.
    ******************************************************************************/
    public static SRVC_ContactPrimaryLanguage getInstance() {
        if (SRVC_ContactPrimaryLanguage.instance == NULL) {
            SRVC_ContactPrimaryLanguage.instance = new SRVC_ContactPrimaryLanguage();
        }

        return SRVC_ContactPrimaryLanguage.instance;
    }

    /************************************************************************************************************
    * @description Generates a list of Contact Language records for a list of specified Contacts.
    * @param  contactsList A list of Contacts from which to generate Contact Language records for insertion.
    * @return A list of Contact Language records to be inserted.
    ************************************************************************************************************/
    public virtual List<Contact_Language__c> getContactLanguagesToCreate(List<Contact> contactsList){
        List<Contact_Language__c> contactLanguagesToInsertList = new List<Contact_Language__c>();

        for (Contact con : contactsList){
            if (String.isNotBlank(con.Primary_Language__c)){
                Contact_Language__c conLang = new Contact_Language__c(
                                                    Primary_Language__c = true,
                                                    Contact__c = con.Id,
                                                    Language__c = con.Primary_Language__c,
                                                    Fluency__c = this.getDefaultFluencyFromSettings()
                                                );

                contactLanguagesToInsertList.add(conLang);
            }
        }

        return contactLanguagesToInsertList;
    }

    /************************************************************************************************************
    * @description Determines if changes to the Primary Language on Contact records are associated with existing 
    * Contact Language records or if they require the creation of new Contact Language records.             
    * @param  newContactsById A map of updated contact records by Id.
    * @param  oldContactsById A map containing the previous state of the updated contact records by Id.
    * @return A ContactLanguagesToProcess value object containing a list of new Contact Language records to insert and a list of existing Contact Language records to update.
    ************************************************************************************************************/
    public virtual ContactLanguagesToProcess getContactLanguagesToCreateOrUpdate(Map<Id, Contact> newContactsById, Map<Id, Contact> oldContactsById){
        Set<Id> contactIdsToUpdateConLangsToNonPrimarySet = new Set<Id>();
        Map<Id, Contact_Language__c> contactLanguageToInsertByContactId = new Map<Id, Contact_Language__c>();
        Map<Id, Id> languageIdToCheckForUpdateByContactId = new Map<Id, Id>();

        for (Contact con : newContactsById.values()){
            List<Contact_Language__c> relatedContactLanguagesList = new List<Contact_Language__c>();
            List<Id> languageIdsToCheckList = new List<Id>();
            Contact oldContact = oldContactsById.get(con.Id);

            if (con.Primary_Language__c == oldContact.Primary_Language__c){
                continue;
            }

            if (oldContact.Primary_Language__c == null || con.Primary_Language__c != null ){
                Contact_Language__c conLang = new Contact_Language__c(
                                                Primary_Language__c = true,
                                                Contact__c = con.Id,
                                                Language__c = con.Primary_Language__c,
                                                Fluency__c = this.getDefaultFluencyFromSettings()
                                            );

                contactLanguageToInsertByContactId.put(con.Id, conLang); 
                languageIdToCheckForUpdateByContactId.put(con.Id, con.Primary_Language__c);
            }

            if (oldContact.Primary_Language__c != null || con.Primary_Language__c == null){
                contactIdsToUpdateConLangsToNonPrimarySet.add(con.Id);
            }
        }

        List<Contact_Language__c> contactLanguagesToUpdateAsNonPrimaryList = this.getContactLanguagesToUpdateAsNonPrimary(contactIdsToUpdateConLangsToNonPrimarySet);
        ContactLanguagesToProcess contactLanguageInsUp = this.getPrimaryContactLanguagesToInsertOrUpdate(contactLanguageToInsertByContactId.clone(),
                                                                                                                languageIdToCheckForUpdateByContactId.clone());
        
        contactLanguageInsUp.addContactLanguagesToUpdate(contactLanguagesToUpdateAsNonPrimaryList);
        return contactLanguageInsUp;
    }


    /************************************************************************************************************
    * @description Retrieves a list of Contact Languages currently marked as primary that are to be updated as non-primary.
    * @param  contactIdsToMarkAsNonPrimarySet A set of Contact Ids associated with Contact Languages to process.
    * @return A list of Contact Language records to be updated as non-primary.
    ************************************************************************************************************/
    @TestVisible
    protected virtual List<Contact_Language__c> getContactLanguagesToUpdateAsNonPrimary(Set<Id> contactIdsToMarkAsNonPrimarySet){

        List<Contact_Language__c> contactLanguagesToUpdateAsNonPrimary = new List<Contact_Language__c>();

        contactLanguagesToUpdateAsNonPrimary = [SELECT Id,
                                                       Contact__c,
                                                       Language__c,
                                                       Primary_Language__c
                                                FROM Contact_Language__c
                                                WHERE Contact__c IN :contactIdsToMarkAsNonPrimarySet
                                                AND Primary_Language__c = true];

        for (Contact_Language__c conLang : contactLanguagesToUpdateAsNonPrimary){
            conLang.Primary_Language__c = false;
        }

        return contactLanguagesToUpdateAsNonPrimary;
    }

    /************************************************************************************************************
    * @description Retrieves the default language fluency setting specified in EDA Settings.
    * @return   The default language fluency value set in EDA Settings.
    ************************************************************************************************************/
    @TestVisible
    private String getDefaultFluencyFromSettings(){
        return UTIL_CustomSettingsFacade.getSettings().Default_Contact_Language_Fluency__c;
    }

    /************************************************************************************************************
    * @description Determines if a Contact Language record flagged for insertion is marked as primary on the 
    * corresponding contact record.  If so, separates the Contact Language into a list for update; marking its 
    * Primary Language status and removing it from the insertion list.
    * @param contactLanguagesToInsertByContactId A map of Contact Languages to be inserted by Contact Id.
    * @param languageIdToCheckForUpdateByContactId A map of Languages currently marked as primary by Contact Id.
    * @return A ContactLanguagesToProcess value object containing one list containing Contact Language records to 
    *         be inserted and one list containing Contact Language records to be updated.                                         
    ************************************************************************************************************/
    @TestVisible
    protected virtual ContactLanguagesToProcess getPrimaryContactLanguagesToInsertOrUpdate(Map<Id, Contact_Language__c> contactLanguagesToInsertByContactId,
                                                                                    Map<Id, Id> languageIdToCheckForUpdateByContactId){

        List<Contact_Language__c> contactLanguagesToUpdateToPrimaryList = new List<Contact_Language__c>();

        List<Contact_Language__c> existingContactLanguagesList = [SELECT Id,
                                                                          Language__c,
                                                                          Contact__c,
                                                                          Primary_Language__c
                                                                  FROM Contact_Language__c
                                                                  WHERE Contact__c IN :languageIdToCheckForUpdateByContactId.keySet()
                                                                  AND (Language__c IN :languageIdToCheckForUpdateByContactId.values()
                                                                                   OR Primary_Language__c = true)];
                                                                        
        for (Contact_Language__c conLang : existingContactLanguagesList){
            if (languageIdToCheckForUpdateByContactId.containsKey(conLang.Contact__c) &&
                languageIdToCheckForUpdateByContactId.get(conLang.Contact__c) == conLang.Language__c){
                
                conLang.Primary_Language__c = true;
                contactLanguagesToUpdateToPrimaryList.add(conLang);
                contactLanguagesToInsertByContactId.remove(conLang.Contact__c);
            } 
        }

        ContactLanguagesToProcess conLangsToProcess = new ContactLanguagesToProcess(contactLanguagesToInsertByContactId.values(), 
                                                                                            contactLanguagesToUpdateToPrimaryList);

        return conLangsToProcess;
    }

    /************************************************************************************************************
    * @description Value object specifying a list of new Contact Language records to be inserted 
    * and a list of existing Contact Language records to be updated.
    ************************************************************************************************************/
    public class ContactLanguagesToProcess{
        public List<Contact_Language__c> contactLanguagesToInsertList { get; private set; }
        public List<Contact_Language__c> contactLanguagesToUpdateList { get; private set; }
        
        public ContactLanguagesToProcess(List<Contact_Language__c> contactLanguagesToInsertList, 
                                            List<Contact_Language__c> contactLanguagesToUpdateList){

            this.contactLanguagesToInsertList = contactLanguagesToInsertList;
            this.contactLanguagesToUpdateList = contactLanguagesToUpdateList;
        }

        /************************************************************************************************************
        * @description Combines a list of Contact Language records with existing records in contactLanguagesToUpdateList.
        * @param  contactLanguagesToAddList A list of Contact Languages to add.
        ************************************************************************************************************/ 
        public void addContactLanguagesToUpdate(List<Contact_Language__c> contactLanguagesToAddList){
            this.contactLanguagesToUpdateList.addAll(contactLanguagesToAddList);
        } 
    }
}


