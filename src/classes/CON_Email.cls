/*
    Copyright (c) 2017 Salesforce.org
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
/**
* @author Salesforce.org
* @date 2017
* @group Contacts
* @group-content ../../ApexDocContent/Contacts.htm
* @description Handles processing of COntact preferred emails. Copies custom email fields to the standard field.
*
*/
public class CON_Email {
    /*******************************************************************************************************
    * @description Sets the Email field depending on the value of Preferred Email
    * @param Contact the contact to update
    * @param oldlist list of old contacts from update or delete context of a trigger
    */
    public static void processPreferredEmail(Contact contact, List<Contact> oldlist) {

        Boolean validatePreferred = !UTIL_CustomSettingsFacade.getSettings().Disable_Preferred_Email_Enforcement__c;

        // No need to run if we are in a delete context
        if(contact == null) {
            return;
        }

        Boolean isUpdateOrDelete = (oldlist != null) ? true : false;

        // Build the list of email fields
        CON_EmailFieldList emailFields = new CON_EmailFieldList(contact);

        if( emailFields.valuedCount() > 0 ) {

            // Check the presence of a special cases when running a batch process.
            // This will prevent some validation errors below to allow batches to complete successfully.
            if( validatePreferred && System.isBatch() ) {

                // Catch a special case when there is a value in Email that doesn't match the 
                // other fields and Preferred Email is blank
                if(String.isNotBlank(contact.Email) && emailFields.valueExists(contact.Email) == null && String.isBlank(contact.Preferred_Email__c)) {
                    contact.Preferred_Email__c = Label.preferredBatchDefaultEmail;
                }

                // Process when Email matches an existing value
                if(String.isNotBlank(contact.Email) && emailFields.valueExists(contact.Email) != null && String.isBlank(contact.Preferred_Email__c)) {
                    contact.Preferred_Email__c = emailFields.valueExists(contact.Email).prefLabel;
                }

                // We are catching a special case here when there are Custom Emails but Email is blank.
                // If there is only one custom email present, we will set it as preferred. When multiple
                // custom emails are present the first in the list will be set to preferred.
                if(String.isBlank(contact.Email) ) {
                    // Get the first item from the list either one or many
                    contact.Email = emailFields.valuedFields[0].value;
                    contact.Preferred_Email__c = emailFields.valuedFields[0].prefLabel;
                }
            }

            // Only one email field, so we can intelligently set preferred email.
            if(validatePreferred && emailFields.valuedCount() == 1 && String.isBlank(contact.Preferred_Email__c)){

                contact.Preferred_Email__c = emailFields.valuedFields[0].prefLabel;
                contact.Email = emailFields.valuedFields[0].value;

            // Enforce preferred email field unless validation is disabled
            } else if(validatePreferred && String.isBlank(contact.Preferred_Email__c)){

                contact.addError( Label.PreferredEmailRequiredError );

            // Make Sure preferred isn't blank making an exception for a special case to prevent errors.
            } else if ( String.isNotBlank(contact.Preferred_Email__c) && contact.Preferred_Email__c != Label.preferredBatchDefaultEmail && contact.Preferred_Email__c != emailFields.emailLabel ) {

                CON_EmailField field = emailFields.getFieldByPrefLabel(contact.Preferred_Email__c);
                if( field != null) {
                    // Make sure we are not setting to a blank value
                    if(String.isNotBlank(field.value)) {
                        // Copy the value that matches preferred email to the standard email field
                        contact.Email = field.value;
                    } else {
                        contact.addError(Label.PreferredEmailMatchNotNull);
                    }

                // Make sure the value in Preferred email matches an actual field 
                } else {
                    contact.addError(Label.PreferredEmailMatchMustExist);
                }
            }

        } else {

            // Cannot have preferred email set if there are no emails present
            if( String.isNotBlank(contact.Preferred_Email__c)) {
                contact.addError(Label.PreferredEmailMatchNotNull);
            }

            // We are not going to format data for orgs that are not enforcing the preferred email field
            if(validatePreferred && String.isNotBlank(contact.Email)) {

                // oldlist is NULL on insert so we check to make sure this logic only applies on updates.
                // We make sure this isn't a batch, because the batch relies on this trigger while
                // updating contacts
                if( isUpdateOrDelete && !System.isBatch() ) {
                    Map<ID, Contact> oldmap = new Map<ID, Contact>( (List<Contact>)oldlist);

                    // Get the old email values - if any - to compare.
                    CON_EmailFieldList oldEmailFields = new CON_EmailFieldList( oldmap.get(contact.Id) );

                    // If this is an update and the contact contained previous emails we want to clear the standard email field
                    // we do this because when a user deletes all email values in the EDA contact without clearing
                    // the value if email, there would be an email address that the user tried to delete.
                    if (oldEmailFields.valuedCount() > 0) {
                        contact.Email = null;
                    } else {
                        copyStdEmailToAlternate(contact, emailFields);
                    }
                } else {
                    copyStdEmailToAlternate(contact, emailFields);
                }
            }
        }

    }

    /*******************************************************************************************************
    * @description Copies the value of the standard Email field to the Alternate Email field if Email has a value and no other emails.
    * @param contact the contact to change
    * @param fieldList an instance of the CON_EmailFieldList class
    */
    public static void copyStdEmailToAlternate(Contact contact, CON_EmailFieldList fieldList) {
        if(contact.Email != null) {
            String namespace = UTIL_Namespace.getNamespace();
            String prefix = ( String.isNotBlank(namespace) ) ? namespace + '__' : '';
            // Retrieve field from field list using the known API name.
            CON_EmailField alternateField = fieldList.getFieldByApiName(prefix + 'AlternateEmail__c');
            contact.Preferred_Email__c = alternateField.prefLabel;
            contact.AlternateEmail__c = contact.Email;
        }
    }

    /*******************************************************************************************************
    * @description Creates a map with Preferred Email picklist value's label as key and picklist API as value
    * @retun Map<String, String> A key value pair of Preferred Email picklist value's picklist label and API respectively
    */
    private static Map<String, String> createPreferredLabelToAPIMap() {        
        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';
        List<Schema.PicklistEntry> preferredEmailPicklist = UTIL_Describe.getFieldPicklistEntries('Contact', prefix+'Preferred_Email__c');
        Map<String, String> preferredEmailLabelToApi = new Map<String, String>();
        for (Schema.PicklistEntry eachValue: preferredEmailPicklist) {
            PreferredEmailLabelToApi.put(eachValue.getLabel(), eachValue.getValue());
        }
        return PreferredEmailLabelToApi;
    }

    private static Map<String, Schema.DescribeFieldResult> contactEmailFieldMap;

    /*******************************************************************************************************
    * @description An inner wrapper class to contain a list of email fields and perform functions on them
    * @param Contact the contact to build list from.
    */
    private class CON_EmailFieldList {

        private List<CON_EmailField> allFields {get;set;}
        private List<CON_EmailField> valuedFields {get;set;}
        public String emailLabel {get;set;}

        public CON_EmailFieldList(Contact contact) {

            this.allFields = new List<CON_EmailField>();
            this.valuedFields = new List<CON_EmailField>();

            if (contactEmailFieldMap == null) {
                contactEmailFieldMap = UTIL_Describe.getFieldsOfType('Contact', 'EMAIL');
            }
            this.emailLabel = contactEmailFieldMap.get('Email').getLabel();

            Map<String, String> hedaEmailField = new Map<String, String>();
            //build map for EDA email field map (Label, API Name)
            for(String fieldName : contactEmailFieldMap.keySet() ) {
                if(String.isNotBlank(UTIL_Namespace.getNamespace()) && fieldName.startsWithIgnoreCase(UTIL_Namespace.getNamespace())) {
                    hedaEmailField.put(contactEmailFieldMap.get(fieldName).getLabel(), fieldName);
                }
            }

            for(String fieldName : contactEmailFieldMap.keySet()) {
                String fieldLabel = contactEmailFieldMap.get(fieldName).getLabel();
                
                //If the field is not a standard email field and it is not duplicate with EDA email, then add it to the list
                if (fieldName != emailLabel && 
                        !(hedaEmailField.get(fieldLabel) != null && fieldName != hedaEmailField.get(fieldLabel))) {
                    String emailField = (String)contact.get(fieldName);

                    allFields.add(new CON_EmailField(emailField, fieldLabel, fieldName));
                    if(String.isNotBlank(emailField)) {
                        valuedFields.add(new CON_EmailField(emailField, fieldLabel, fieldName));
                    }
                }
            }
        }

        public Integer valuedCount() {
            Integer count = 0;
            for(CON_EmailField field : this.allFields) {
                count += (field.hasValue()) ? 1 : 0;
            }
            return count;
        }

        public CON_EmailField getFieldByPrefLabel(String labelSearch) {
            labelSearch = getCustomPicklistValue(labelSearch);
            for(CON_EmailField field : this.allFields) {
                if (labelSearch == field.label || labelSearch == field.prefLabel) {
                    return field;
                }
            }
            return null;
        }

        public CON_EmailField getFieldByApiName(String apiSearch) {
            for(CON_EmailField field : this.allFields) {
                if (apiSearch == field.apiName ) {
                    return field;
                }
            }
            return null;
        }

        private CON_EmailField valueExists(String search) {
            for(CON_EmailField field : this.valuedFields ){
                if(String.isNotBlank(search) && field.value == search){
                    return field;
                }
            }
            return null;
        }

        //Check if transalted picklist value of preferred email exist
        private String getCustomPicklistValue(String lableSearch)
        {       
            Map<String,String> apiLabelMappings = new Map<String,String>();       
            Schema.DescribeFieldResult fieldResult = Contact.Preferred_Email__c.getDescribe();
            List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
                if (entry.getValue() == lableSearch)
                {
                    return entry.getLabel();
                }
            }
            return lableSearch;         
        }

    }

    /*******************************************************************************************************
    * @description An inner wrapper class to represent a custom email field on a contact
    * @param val The value of the email field
    * @param lbl The label of the email field
    * @param api The API name of the email field
    */
    private class CON_EmailField {

        public String value {get;set;}
        public String label {get;set;}
        public String apiName {get;set;}
        public String prefLabel {get;set;}

        public CON_EmailField(String val, String lbl, String api ) {
            // Store default email field mappings to preferred email picklist values prior to EDA 1.86.
            // The mapping is used when Preferred Email picklist values do not match corresponding the field labels.
            Map<String,String> preferredEmailMappings = new Map<String,String>{
                'University Email' => 'University',
                'Work Email' => 'Work',
                'Alternate Email' => 'Alternate'
            };
                     
            Map<String, String> preferredLabelToApi = createPreferredLabelToAPIMap();
             
            this.value = val;
            this.label = lbl;
            this.apiName = api;

            /* If the field label is not in Preferrred Email picklist API values then check if it is in PreferredEmailMappings, if yes then take the value from mappings
             else keep the label as label. If the field label is in the Preferrred Email picklist API values then assign the picklist API value that matches the field label 
             such that Preferred Email field will reflect the translated value when users use a language that is not English. */
            if (!PreferredLabelToApi.keySet().contains(lbl)) {
                this.prefLabel = (preferredEmailMappings.containsKey(lbl)) ? preferredEmailMappings.get(lbl) : lbl;
            } else {
                this.prefLabel = PreferredLabelToApi.get(lbl);
            }    
        }

        public Boolean hasValue(){
            return String.isNotBlank(this.value);
        }
    }
}