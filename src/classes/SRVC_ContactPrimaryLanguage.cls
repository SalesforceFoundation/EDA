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
        
        ContactLanguageInsertUpdate contactLanguageInsUp = new ContactLanguageInsertUpdate();

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
        
            contactLanguageInsUp = this.getPrimaryContactLanguagesToInsertOrUpdate(contactLanguageToInsertByContactId.clone(),
                                                                                    languageIdToCheckForUpdateByContactId.clone());
        }

        return contactLanguageInsUp;
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

    /**
     * @description Determines if a Contact Language record flagged for insertion is marked as primary on the corresponding contact record.  If so,
     * separates the Contact Language into a list for update; marking its Primary Language status and removing it from the insertion list.
     * @param contactLanguagesToInsertByContactId Mapping of Contact Languages to be inserted, by Contact Id
     * @param languageIdToCheckForUpdateByContactId Mapping of Language currently marked as primary by Contact Id
     * @return A ContactLanguageInsertUpdate value object containing one list containing Contact Language records to be inserted and 
     *         another containing Contact Language records to be updated                                         
     */
    @TestVisible
    private ContactLanguageInsertUpdate getPrimaryContactLanguagesToInsertOrUpdate(Map<Id, Contact_Language__c> contactLanguagesToInsertByContactId,
                                                                                    Map<Id, Id> languageIdToCheckForUpdateByContactId){

        ContactLanguageInsertUpdate contactLangInsUp = new ContactLanguageInsertUpdate();
        List<Contact_Language__c> contactLanguagesToUpdateToPrimaryList = new List<Contact_Language__c>();

        for (Contact_Language__c conLang : contactLanguagesToInsertByContactId.values()){
            if (languageIdToCheckForUpdateByContactId.containsKey(conLang.Contact__c) &&
                languageIdToCheckForUpdateByContactId.get(conLang.Contact__c) == conLang.Id){
                
                conLang.Primary_Language__c = true;
                contactLanguagesToUpdateToPrimaryList.add(conLang);
                contactLanguagesToInsertByContactId.remove(conLang.Contact__c);
            }
        }

        contactLangInsUp.contactLanguagesToInsertList = contactLanguagesToInsertByContactId.values();
        contactLangInsUp.contactLanguagesToUpdateList = contactLanguagesToUpdateToPrimaryList;

        return contactLangInsUp;
    }

    /** 
    * @description
    */
    private class ContactLanguageInsertUpdate {
        private List<Contact_Language__c> contactLanguagesToInsertList {get; set;}
        private List<Contact_Language__c> contactLanguagesToUpdateList {get; set;}
    }
}
