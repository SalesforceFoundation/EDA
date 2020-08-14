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

    public List<Contact_Language__c> getContactLanguagesToCreate(List<Contact> contactsList){
        List<Contact_Language__c> contactLanguagesToInsertList = new List<Contact_Language__c>();

        for (Contact con : contactsList){
            Contact_Language__c conLang = new Contact_Language__c(
                                                    Primary_Language__c = true,
                                                    Contact__c = con.Id,
                                                    Language__c = con.Primary_Language__c,
                                                    Fluency__c = this.getDefaultFluencyFromSettings()
                                                );
        }

        return contactLanguagesToInsertList;
    }

    private String getDefaultFluencyFromSettings(){
        return UTIL_CustomSettingsFacade.getSettings().Default_Contact_Language_Fluency__c;
    }
}
