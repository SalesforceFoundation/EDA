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

	    // Store default email field mappings to preferred email pick list.
	    Map<String,String> preferredEmailMappings = new Map<String,String>{
	        'University' => 'University Email',
	        'Work' => 'Work Email',
	        'Alternate' => 'Alternate Email'
	    };

        // Build the list of email fields
        CON_EmailFieldSet emailFields = new CON_EmailFieldSet(contact);

        if( emailFields.valuedCount() > 0 ) {

            // Enforce preferred email field unless validation is disabled
            if(validatePreferred && String.isBlank(contact.Preferred_Email__c)){

                contact.addError( Label.PreferredEmailRequiredError );

            } else if ( String.isNotBlank(contact.Preferred_Email__c) ) {

                String preferredLabel = (preferredEmailMappings.containsKey(contact.Preferred_Email__c)) ? preferredEmailMappings.get(contact.Preferred_Email__c) : contact.Preferred_Email__c;

                // Make sure the value in Preferred email matches an actual field
                if(!emailFields.isValidLabel(preferredLabel)) {
                    contact.addError(Label.PreferredEmailMatchMustExist);
                }

                CON_EmailField field = emailFields.getFieldByLabel(preferredLabel);

                if( field != null) {
                    // Make sure we are not setting to a blank value
                    if(String.isNotBlank(field.value)) {
                        // Copy the value that matches preferred email to the standard email field
                        contact.Email = (String)field.value;
                    } else {
                        contact.addError(Label.PreferredEmailMatchNotNull);
                    }
                }
            }

        } else {

            // Cannot have preferred email set if there are no emails present
            if( !String.isBlank(contact.Preferred_Email__c)) {
                contact.addError(Label.PreferredEmailMatchNotNull);
            }

            // oldlist is NULL on insert so we check to make sure this logic only applies on updates.
			if( isUpdateOrDelete && String.isNotBlank(contact.Email) ) {
	            Map<ID, Contact> oldmap = new Map<ID, Contact>( (List<Contact>)oldlist);

	            // Get the old email values - if any - to compare.
	            Map<String,CON_EmailField> oldValuedEmails = getEmailFieldsWithValue( oldmap.get(contact.Id) );

	            // If this is an update and the contact contained previous emails we want to clear the standard email field
                // we do this because when a user deletes all email values in the HEDA contact without clearing
                // the value if email, there would be an emil address that the user tried to delete.
	            if (oldValuedEmails.size() > 0) {
	                contact.Email = null;
	            }
	        } else if(String.isNotBlank(contact.Email)) {
	        	copyStdEmailToAlternate(contact);
	        }
        }

        // Check if the standard email field does not match any of the custom email values
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
    * @description CHeck if the contact has any fields containing the search value
    * @param Search the contact to change
    * @param Contact the contact to change
    */
    private static Boolean contactHasEmail(String search, Contact contact) {
        Boolean hasValue = false;

        for(CON_EmailField emailField :getEmailFieldsWithValue( contact ).values()){
            if(emailField.value == contact.Email){
                hasValue = true;
            }
        }
        return hasValue;
    }

    /*******************************************************************************************************
    * @description Returns a map of emails field labels and their api name if they have a value for a Contact
    * @param Contact to populate list from
    * @return Map<String,String> Map of emails fields key is field name and value is the field value
    */
	private static Map<String,CON_EmailField> getEmailFieldsWithValue(Contact contact) {
        // Organize Email fields with a value
        Map<String,CON_EmailField> valuedEmailMap = new Map<String,CON_EmailField>();

        if(contact != null) {

            // Retreive all Email fields
            Map<String, Schema.DescribeFieldResult> emailFields = UTIL_Describe.getFieldsOfType('Contact', 'EMAIL');

            for(String fieldName : emailFields.keySet() ) {

                String emailField = (String)contact.get(fieldName);

                // if the field has a value add it to the map, excluding the standard Email field
                if ( fieldName != 'Email' && String.isNotBlank(emailField) ) {

                    //valuedEmailMap.put( emailFields.get(fieldName).getLabel(), fieldName);
                    valuedEmailMap.put(
                        emailFields.get(fieldName).getLabel(),
                        new CON_EmailField( emailField, emailFields.get(fieldName).getLabel(), fieldName )
                    );
                }
            }
        }

        return valuedEmailMap;
	}

    private class CON_EmailFieldSet {

        private Set<CON_EmailField> fieldSet {get;set;}

        public CON_EmailFieldSet(Contact contact) {

            this.fieldSet = new Set<CON_EmailField>();
            Map<String, Schema.DescribeFieldResult> fieldMap = UTIL_Describe.getFieldsOfType('Contact', 'EMAIL');

            for(String fieldName : fieldMap.keySet() ) {
                if ( fieldName != 'Email' ) {
                    String emailField = (String)contact.get(fieldName);
                    fieldSet.add( new CON_EmailField( emailField, fieldMap.get(fieldName).getLabel(), fieldName ) );
                }
            }
        }

        public Integer valuedCount() {
            Integer count = 0;
            for(CON_EmailField field : this.fieldSet) {
                count += (field.hasValue()) ? 1 : 0;
            }
            return count;
        }

        public CON_EmailField getFieldByApi(String apiSearch) {
            for(CON_EmailField field : this.fieldSet) {
                if (apiSearch == field.apiName) {
                    return field;
                }
            }
            return null;
        }

        public CON_EmailField getFieldByLabel(String labelSearch) {
            for(CON_EmailField field : this.fieldSet) {
                if (labelSearch == field.label) {
                    return field;
                }
            }
            return null;
        }

        public Boolean isValidlabel(String labelSearch) {
            Boolean isValid = false;
            for(CON_EmailField field : this.fieldSet) {
                if (labelSearch == field.label) {
                    isValid = true;
                    break;
                }
            }
            return isValid;
        }
    }

    private class CON_EmailField {

        public String value {get;set;}
        public String label {get;set;}
        public String apiName {get;set;}

        public CON_EmailField(String val, String lbl, String api ) {
            this.value = val;
            this.label = lbl;
            this.apiName = api;
        }

        public Boolean hasValue(){
            return String.isNotBlank(this.value);
        }
    }
}