public with sharing class VALOBJ_ContactLanguageCategorization {
    public List<Contact_Language__c> contactLanguagesToInsertList { get; private set; }
    public List<Contact_Language__c> contactLanguagesToUpdateList { get; private set; }

    public VALOBJ_ContactLanguageCategorization(List<Contact_Language__c> contactLanguagesToInsertList, 
                                            List<Contact_Language__c> contactLanguagesToUpdateList){

        this.contactLanguagesToInsertList = contactLanguagesToInsertList;
        this.contactLanguagesToUpdateList = contactLanguagesToUpdateList;
    }

    public void addContactLanguagesToUpdate(List<Contact_Language__c> contactLanguagesToAddList){
        this.contactLanguagesToUpdateList.addAll(contactLanguagesToAddList);
    } 
}
