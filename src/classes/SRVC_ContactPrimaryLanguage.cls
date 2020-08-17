public virtual with sharing class SRVC_ContactPrimaryLanguage {

    /*********************************************
    * @description Instance for Singleton Pattern
    **********************************************/
    @TestVisible
    private static SRVC_ContactPrimaryLanguage instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************/
    protected SRVC_ContactPrimaryLanguage() {}

    /*****************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of SRVC_ContactPrimaryLanguage.
    ******************************************************************************/
    public static SRVC_ContactPrimaryLanguage getInstance() {
        if (instance == NULL) {
            instance = new SRVC_ContactPrimaryLanguage();
        }

        return instance;
    }

    /**
     * @description Generate a list of Contact Language records for a list of specified Contacts.
     * @param  contactsList List of Contacts from which to generate Contact Language records for insertion
     * @return              Returns a list of Contact Language records to be inserted
     */
    public List<Contact_Language__c> getContactLanguagesToCreate(List<Contact> contactsList){
        List<Contact_Language__c> contactLanguagesToInsertList = new List<Contact_Language__c>();

        for (Contact con : contactsList){
            Contact_Language__c conLang = new Contact_Language__c(
                                                    Primary_Language__c = true,
                                                    Contact__c = con.Id,
                                                    Language__c = con.Primary_Language__c,
                                                    Fluency__c = this.getDefaultFluencyFromSettings()
                                                );

            contactLanguagesToInsertList.add(conLang);
        }

        return contactLanguagesToInsertList;
    }

    /**
     * @description
     * @param  newContactsById newContactsById description
     * @param  oldContactsById oldContactsById description
     * @return                 return description
     */
    public ContactLanguageInsertUpdate getContactLanguagesToCreateOrUpdate(Map<Id, Contact> newContactsById, Map<Id, Contact> oldContactsById){
        
        ContactLanguageInsertUpdate conLangInsUp = new ContactLanguageInsertUpdate();

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

            if (String.isBlank(oldContact.Primary_Language__c) || String.isNotBlank(con.Primary_Language__c)){
                    Contact_Language__c conLang = new Contact_Language__c(
                                                    Primary_Language__c = true,
                                                    Contact__c = con.Id,
                                                    Language__c = con.Primary_Language__c,
                                                    Fluency__c = this.getDefaultFluencyFromSettings()
                                                );

                contactLanguageToInsertByContactId.put(con.Id, conLang);     
                languageIdToCheckForUpdateByContactId.put(con.Id, con.Primary_Language__c);
            }

            if (String.isNotBlank(oldContact.Primary_Language__c) || String.isBlank(con.Primary_Language__c)){
                contactIdsToUpdateConLangsToNonPrimarySet.add(con.Id);
            }

            List<Contact_Language__c> contactLanguagesToUpdateAsNonPrimaryList = this.getContactLanguagesToUpdateAsNonPrimary(contactIdsToUpdateConLangsToNonPrimarySet);
        
            conLangInsUp.contactLanguagesToInsertList = this.getPrimaryContactLanguagesToInsertOrUpdate(contactLanguageToInsertByContactId.clone(),
                                                                                                        languageIdToCheckForUpdateByContactId.clone());

            conLangInsUp.contactLanguagesToUpdateList = this.getPrimaryContactLanguagesToInsertOrUpdate(contactLanguageToInsertByContactId.clone(),
                                                                                                        languageIdToCheckForUpdateByContactId.clone());
        }

        return conLangInsUp;
    }

    /**
     * @description
     * @param  contactIdsToMarkAsNonPrimarySet Set of Contact Ids to process
     * @return Return a list of Contact Language records corresponding to the Contact Ids provided for processing.
     */
    public List<Contact_Language__c> getContactLanguagesToUpdateAsNonPrimary(Set<Id> contactIdsToMarkAsNonPrimarySet){

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

    /**
     * @description Retrieves the default language fluency setting specified in EDA Settings.
     * @return   returns the default language fluency value set in EDA Settings
     */
    @TestVisible
    private String getDefaultFluencyFromSettings(){
        return UTIL_CustomSettingsFacade.getSettings().Default_Contact_Language_Fluency__c;
    }

    @TestVisible
    private List<Contact_Language__c> getPrimaryContactLanguagesToInsertOrUpdate(Map<Id, Contact_Language__c> contactLanguagesToInsertByContactId,
                                                            Map<Id, Id> languageIdToCheckForUpdateByContactId){

        return new List<Contact_Language__c>(); // placeholder

    //     List<Contact_Language__c> contactLanguagesToUpdateToPrimaryList = new List<Contact_Language__c>();

    //     for (Id conId : contactLanguagesListByContactId.keySet()){
    //         for (Contact_Language__c conLang : contactLanguagesListByContactId.get(conId)){
    //             if (languageIdsListByContactId.containsKey(conId)){
    //                 List<Id> conLanguagesToUpdate = languageIdsListByContactId.get(conId);
    //                 for(Id langId : conLanguagesToUpdate){
    //                     if (langId == conLang.Language__c){
    //                         // update current conLang record instead of inserting
    //                     }
    //                 }
    //             }
    //         }
    //     }

    }

    private class ContactLanguageInsertUpdate {
        private List<Contact_Language__c> contactLanguagesToInsertList {get; set;}
        private List<Contact_Language__c> contactLanguagesToUpdateList {get; set;}
    }
}
