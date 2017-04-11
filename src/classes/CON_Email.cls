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
                    contact.Preferred_Email__c = 'Email (standard)';
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

            // Enforce preferred email field unless validation is disabled
            if(validatePreferred && String.isBlank(contact.Preferred_Email__c)){

                contact.addError( Label.PreferredEmailRequiredError );

            // Make Sure pteferrd isn't blank making an exception for a special case to prevent errors.
            } else if ( String.isNotBlank(contact.Preferred_Email__c) && contact.Preferred_Email__c != 'Email (standard)' && contact.Preferred_Email__c != 'Email' ) {

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

            // oldlist is NULL on insert so we check to make sure this logic only applies on updates.
            // We make sure this isnt a batch, because the batch relies on this trigger while
            // updating contact
			if( isUpdateOrDelete && String.isNotBlank(contact.Email) && !System.isBatch() ) {
	            Map<ID, Contact> oldmap = new Map<ID, Contact>( (List<Contact>)oldlist);

	            // Get the old email values - if any - to compare.
                CON_EmailFieldList oldEmailFields = new CON_EmailFieldList( oldmap.get(contact.Id) );

	            // If this is an update and the contact contained previous emails we want to clear the standard email field
                // we do this because when a user deletes all email values in the HEDA contact without clearing
                // the value if email, there would be an email address that the user tried to delete.
	            if (oldEmailFields.valuedCount() > 0) {
	                contact.Email = null;
	            }
	        } else if(String.isNotBlank(contact.Email)) {
	        	copyStdEmailToAlternate(contact);
	        }
        }

	}

    /*******************************************************************************************************
    * @description Copies the value of the standard Email field to the Alternate Email field if Email has a value and no other emails.
    * @param Contact the contact to change
    */
    public static void copyStdEmailToAlternate(Contact contact) {
        if(contact.Email != null) {
            contact.Preferred_Email__c = 'Alternate';
            contact.AlternateEmail__c = contact.Email;
        }
    }

    /*******************************************************************************************************
    * @description An inner wrapper class to contain a list of email fields and perform functions on them
    * @param Contact the contact to build list from.
    */
    private class CON_EmailFieldList {

        private List<CON_EmailField> allFields {get;set;}
        private List<CON_EmailField> valuedFields {get;set;}

        public CON_EmailFieldList(Contact contact) {

            this.allFields = new List<CON_EmailField>();
            this.valuedFields = new List<CON_EmailField>();
            Map<String, Schema.DescribeFieldResult> fieldMap = UTIL_Describe.getFieldsOfType('Contact', 'EMAIL');

            for(String fieldName : fieldMap.keySet() ) {
                if ( fieldName != 'Email' ) {
                    String emailField = (String)contact.get(fieldName);

                    allFields.add( new CON_EmailField( emailField, fieldMap.get(fieldName).getLabel(), fieldName ) );
                    if(String.isNotBlank(emailField)) {
                        valuedFields.add( new CON_EmailField( emailField, fieldMap.get(fieldName).getLabel(), fieldName ) );
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
            for(CON_EmailField field : this.allFields) {
                if (labelSearch == field.label || labelSearch == field.prefLabel) {
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
    }

    /*******************************************************************************************************
    * @description An inner wrapper class to represent a custom email field on a contact
    * @param val The value of the email field
    * @param lbl The label of the email field
    * @param api The Api name of the email field
    */
    private class CON_EmailField {

        public String value {get;set;}
        public String label {get;set;}
        public String apiName {get;set;}
        public String prefLabel {get;set;}

        public CON_EmailField(String val, String lbl, String api ) {
            // Store default email field mappings to preferred email pick list.
            Map<String,String> preferredEmailMappings = new Map<String,String>{
                'University Email' => 'University',
                'Work Email' => 'Work',
                'Alternate Email' => 'Alternate'
            };

            this.value = val;
            this.label = lbl;
            this.apiName = api;
            this.prefLabel = (preferredEmailMappings.containsKey(lbl)) ? preferredEmailMappings.get(lbl) : lbl;
        }

        public Boolean hasValue(){
            return String.isNotBlank(this.value);
        }
    }
}