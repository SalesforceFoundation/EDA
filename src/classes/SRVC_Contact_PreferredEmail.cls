/*
Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group
* @group-content ../../ApexDocContent/Contacts.htm
* @description Service class for CON_Preferred_TDTM. Returns Contact modified for Preferred Email
*/
public virtual with sharing class SRVC_Contact_PreferredEmail {

    /*********************************************
    * @description Instance for Singleton Pattern
    **********************************************/
    @TestVisible
    private static SRVC_Contact_PreferredEmail instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************/
    protected SRVC_Contact_PreferredEmail() {}

    /******************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of SRVC_Contact_PreferredEmail.
    ******************************************************************************/
    public static SRVC_Contact_PreferredEmail getInstance() {

        if (instance == null) {
            instance = new SRVC_Contact_PreferredEmail();
        }

        return instance;
    }

    /******************************************************************************
    * @description Method to process for Preferred Email functionality on Insert
    * @param newContact The contact record being inserted
    * @param preferredEmailSettings The MODL_PreferredEmailSettings record
    * @return The Contact modified for Preferred Email
    ******************************************************************************/
    public Contact processPreferredEmailForInsert(Contact newContact,  MODL_PreferredEmailSettings preferredEmailSettings) {
        
        MODL_Contact newContactModel = this.getModelFromContact(newContact, preferredEmailSettings);

        if (newContactModel.isEmpty()) {
            return this.handleEmptyContactEmailFieldsForInsert(newContactModel, preferredEmailSettings);
        }
        return this.handleContactEmailFields(newContactModel, preferredEmailSettings);

    }

    /******************************************************************************
    * @description Method to process for Preferred Email functionality on Update
    * @param newContact The contact record being updated
    * @param preferredEmailSettings The MODL_PreferredEmailSettings record
    * @return The Contact modified for Preferred Email
    ******************************************************************************/
    public Contact processPreferredEmailForUpdate(Contact newContact,  Contact oldContact, MODL_PreferredEmailSettings preferredEmailSettings) {
        
        MODL_Contact newContactModel = this.getModelFromContact(newContact, preferredEmailSettings);

        if (newContactModel.isEmpty()) {
            return this.handleEmptyContactEmailFieldsForUpdate(newContactModel, oldContact, preferredEmailSettings);
        }
        return this.handleContactEmailFields(newContactModel, preferredEmailSettings);

    }

    /************************************************************************************************************************************
    * @description Method to process for Preferred Email functionality on Insert on Contact with no values in custom email fields
    * @param contactModel The contact model corresponding to the record being inserted
    * @param preferredEmailSettingsModel The MODL_PreferredEmailSettings record
    * @return The Contact modified for Preferred Email
    ************************************************************************************************************************************/
    @testVisible
    private Contact handleEmptyContactEmailFieldsForInsert(SRVC_Contact_PreferredEmail.MODL_Contact contactModel, MODL_PreferredEmailSettings preferredEmailSettingsModel) {

        if (String.isNotBlank(contactModel.preferredEmail)) {
            contactModel.addError(Label.PreferredEmailMatchNotNull);
            return contactModel.Contact;
        }

        if (preferredEmailSettingsModel.preferredEmailValidationEnabled == false || String.isBlank(contactModel.email) == true) {
            return null;
        }

        return populateAlternateEmailAndSetAsPreffered(contactModel, preferredEmailSettingsModel);
    }

    /************************************************************************************************************************************
    * @description Method to process for Preferred Email functionality on Update on Contact with no values in custom email fields
    * @param contactModel The contact model corresponding to the record being updated
    * @param oldContact The contact record in Trigger.old
    * @param preferredEmailSettingsModel The MODL_PreferredEmailSettings record
    * @return The Contact modified for Preferred Email
    ************************************************************************************************************************************/
    @testVisible
    private Contact handleEmptyContactEmailFieldsForUpdate(SRVC_Contact_PreferredEmail.MODL_Contact contactModel, Contact oldContact, MODL_PreferredEmailSettings preferredEmailSettingsModel) {

        if (String.isNotBlank(contactModel.preferredEmail)) {
            contactModel.addError(Label.PreferredEmailMatchNotNull);
            return contactModel.Contact;
        }

        if (preferredEmailSettingsModel.preferredEmailValidationEnabled == false || String.isBlank(contactModel.email) == true) {
            return null;
        }

        if (System.isBatch() && preferredEmailSettingsModel.preferredEmailValidationEnabled == true && String.isBlank(contactModel.Email) == true) {
            return this.populateAlternateEmailAndSetAsPreffered(contactModel, preferredEmailSettingsModel);
        }

        MODL_Contact oldContactModel = this.getModelFromContact(oldContact, preferredEmailSettingsModel);
        
        if (oldContactModel.isEmpty() == false) {
            contactModel.email = null;
            return contactModel.contact;
        }
        return populateAlternateEmailAndSetAsPreffered(contactModel, preferredEmailSettingsModel);
    }

    /************************************************************************************************************************************
    * @description Method to process for Preferred Email functionality on Update on Contact with values in custom email fields
    * @param contactModel The contact model corresponding to the record being updated
    * @param emailFieldSettingsModel The MODL_PreferredEmailSettings record
    * @return The Contact modified for Preferred Email
    ************************************************************************************************************************************/
    @testVisible
    private Contact handleContactEmailFields(SRVC_Contact_PreferredEmail.MODL_Contact contactModel, MODL_PreferredEmailSettings emailFieldSettingsModel) {

        if (emailFieldSettingsModel.preferredEmailValidationEnabled == false) {
            return this.handleContactEmailFieldsForInsertAndUpdate(contactModel, emailFieldSettingsModel);
        }

        if (System.isBatch()) {
            contactModel = this.handleContactEmailFieldsForBatch(contactModel, emailFieldSettingsModel);
            return contactModel.contact;
        }

        if (String.isNotBlank(contactModel.preferredEmail)) {
            return this.handleContactEmailFieldsForInsertAndUpdate(contactModel,  emailFieldSettingsModel);
        }

        if (contactModel.size() > 1) {
            contactModel.addError(Label.PreferredEmailRequiredError);
            return contactModel.contact;
        }
        
        MODL_ContactEmailField firstEmailFieldModel = contactModel.getFirstEmailFieldModel();
        contactModel.preferredEmail = firstEmailFieldModel.preferredLabel;
        contactModel.email = firstEmailFieldModel.value;
        return contactModel.contact;

    }

    /**************************************************************************************************************************************************
    * @description Method to further process for Preferred Email functionality called from handleContactEmailFields method for insert/updates scenarios
    * @param contactModel The contact model corresponding to the record being updated
    * @param emailFieldSettingsModel The MODL_PreferredEmailSettings record
    * @return The Contact modified for Preferred Email
    **************************************************************************************************************************************************/
    @testVisible
    private Contact handleContactEmailFieldsForInsertAndUpdate(SRVC_Contact_PreferredEmail.MODL_Contact contactModel, MODL_PreferredEmailSettings emailFieldSettingsModel) {

        if (String.isBlank(contactModel.preferredEmail) || contactModel.preferredEmail == Label.preferredBatchDefaultEmail || 
            contactModel.preferredEmail == emailFieldSettingsModel.emailLabel) {
            return null;
        }

        if (contactModel.hasPrefEmailField == false) {
            contactModel.addError(Label.PreferredEmailMatchMustExist);
            return contactModel.contact;
        }
        
        if (String.isBlank(contactModel.prefEmailFieldValue)) {
            contactModel.addError(Label.PreferredEmailMatchNotNull);
            return contactModel.contact;
        }

        contactModel.email = contactModel.prefEmailFieldValue;
        return contactModel.contact;
    }

    /**************************************************************************************************************************************************
    * @description Method to further process for Preferred Email functionality called from handleContactEmailFields method for batch
    * @param contactModel The contact model corresponding to the record being updated
    * @param emailFieldSettingsModel The MODL_PreferredEmailSettings record
    * @return The Contact modified for Preferred Email
    **************************************************************************************************************************************************/
    @testVisible
    private SRVC_Contact_PreferredEmail.MODL_Contact handleContactEmailFieldsForBatch(SRVC_Contact_PreferredEmail.MODL_Contact contactModel, MODL_PreferredEmailSettings emailFieldSettingsModel) {

        if (String.isBlank(contactModel.email)) {
            MODL_ContactEmailField firstEmailFieldModel = contactModel.getFirstEmailFieldModel();
            contactModel.email = firstEmailFieldModel.value;
            contactModel.preferredEmail = firstEmailFieldModel.preferredLabel;
            return contactModel;
        }
        
        if (String.isNotBlank(contactModel.preferredEmail)) {
            return contactModel;
        }
        
        MODL_ContactEmailField emailFieldModel = contactModel.currentEmailModel;
       
        if (emailFieldModel != null) {
            contactModel.preferredEmail = emailFieldModel.preferredLabel;
            return contactModel;
        }

        contactModel.preferredEmail = Label.preferredBatchDefaultEmail;
        return contactModel;
    }

    /**************************************************************************************************************************************************
    * @description Method to populate Preferred_Email__c with alternateEmailPreferredLabel and AlternateEmail__c with Standrd Email label
    * @param contactModel The contact model corresponding to the record being updated
    * @param emailFieldSettingsModel The MODL_PreferredEmailSettings record
    * @return The Contact populated with Preferred Email and Alternate Email
    **************************************************************************************************************************************************/
    @testVisible
    private Contact populateAlternateEmailAndSetAsPreffered(SRVC_Contact_PreferredEmail.MODL_Contact contactModel, MODL_PreferredEmailSettings preferredEmailSettingsModel) {
        contactModel.preferredEmail = preferredEmailSettingsModel.alternateEmailPreferredLabel;
        contactModel.alternateEmail = contactModel.email;
        return contactModel.contact;
    }

    /**************************************************************************************************************************************************
    * @description Returns a MODL_Contact for a given Contact and MODL_PreferredEmailSettings
    * @param emailFieldSettingsModel The MODL_PreferredEmailSettings record
    * @return The MODL_Contact for the given Contact and MODL_PreferredEmailSettings
    **************************************************************************************************************************************************/
    @testVisible
    private MODL_Contact getModelFromContact(Contact contact, MODL_PreferredEmailSettings preferredEmailSettingsModel) {

        List<MODL_ContactEmailField> contactEmailFieldModelList = new List<MODL_ContactEmailField>();

        Boolean hasPrefEmailField = false;
        String prefEmailFieldValue;
        
        MODL_ContactEmailField currentEmailFieldModel;
        String preferredEmailLabel = preferredEmailSettingsModel.preferredEmailPicklistLabelByApiName.get(contact.Preferred_Email__c);

        for (MODL_PreferredEmailField each: preferredEmailSettingsModel.preferredEmailFieldModels) {
            
            String fieldValue = (String)contact.get(each.emailTypeFieldApiName);
            MODL_ContactEmailField contactEmailFieldModel;
                        
            if (hasPrefEmailField == false) {

                if (each.emailTypeFieldLabel == contact.Preferred_Email__c || each.preferredLabel ==  contact.Preferred_Email__c) {  
                    hasPrefEmailField = true;
                    prefEmailFieldValue = fieldValue;
                }
            }
            
            if (fieldValue == null) {
                continue;
            }
            
            if (contactEmailFieldModel == null) {
                contactEmailFieldModel = new MODL_ContactEmailField(each.emailTypeFieldApiName, each.emailTypeFieldLabel, each.preferredLabel, fieldValue);
            }

            contactEmailFieldModelList.add(contactEmailFieldModel);

            if (System.isBatch() && currentEmailFieldModel == null && contactEmailFieldModel.value == Contact.Email) {
                currentEmailFieldModel = contactEmailFieldModel;
            }
        }

        MODL_Contact contactModel = new MODL_Contact(contact, contactEmailFieldModelList, currentEmailFieldModel, hasPrefEmailField, prefEmailFieldValue);
        return contactModel;
    }

    /**********************************************************************************************************************************
    * @description Inner model class to set Contact, contactEmailFieldModels, currentEmailModel, Preferred Email field and its value
    ************************************************************************************************************************************/
    @testVisible
    private class MODL_Contact {

        public Contact contact {get; private set; }
        public List<MODL_ContactEmailField> contactEmailFieldModels {get; private set; }
        public MODL_ContactEmailField currentEmailModel {get; private set; }
        public Boolean hasPrefEmailField {get; private set;}
        public String prefEmailFieldValue {get; private set;}
            
        public String alternateEmail { 
            get {
                return this.contact.AlternateEmail__c;
            }
            set {
                this.contact.AlternateEmail__c = value;
            } 
        }

        public String email { 
            get {
                return this.contact.Email;
            }
            set {
                this.contact.Email = value;
            }
        }

        public String preferredEmail {
            get {
                return this.contact.Preferred_Email__c;
            }
            set {
                this.contact.Preferred_Email__c = value;
            }
        }

        public MODL_Contact() {}

        public MODL_Contact(Contact contact, List<MODL_ContactEmailField> contactEmailFieldModels, MODL_ContactEmailField currentEmailModel, Boolean hasPrefEmailField, String prefEmailFieldValue) {
            this.contact = contact;
            this.contactEmailFieldModels = contactEmailFieldModels;
            this.currentEmailModel = currentEmailModel;
            this.hasPrefEmailField = hasPrefEmailField;
            this.prefEmailFieldValue = prefEmailFieldValue;
        }

        public void addError(String errorToAdd) {
            this.contact.addError(errorToAdd);
        }

        public MODL_ContactEmailField getFirstEmailFieldModel() {
            return this.contactEmailFieldModels[0];
        }

        public Boolean isEmpty() {
            return this.contactEmailFieldModels.isEmpty();    
        }

        public Integer size() {
            return this.contactEmailFieldModels.size();
        } 

    }

    /**********************************************************************************************
    * @description Inner model class to set a Contact's label, API, Preferred Label and its value
    ***********************************************************************************************/
    @testVisible
    private class MODL_ContactEmailField extends MODL_PreferredEmailField {

        public String value { get; private set; }

        public MODL_ContactEmailField(String apiName, String label, String preferredLabel, String value) {
            super(label, apiName, preferredLabel);
            this.value = value;
        }
    }

}