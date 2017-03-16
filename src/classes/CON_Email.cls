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

        // No need to run if we are in a delete context
        if(contact == null) {
            return;
        }

		Boolean isUpdateOrDelete = (oldlist != null) ? true : false;

	    // Store default email field mappings to preferred email pick list.
	    Map<String,String> preferredEmailMappings = new Map<String,String>{   
	        'University' => 'UniversityEmail__c',
	        'Work' => 'WorkEmail__c',
	        'Alternate' => 'AlternateEmail__c'
	    };

	    Map<String,String> valuedEmailMap = getEmailFieldsWithValue(contact);

        if( valuedEmailMap.size() > 0 ) {

            // Enforce preferred email field
            if(String.isBlank(contact.Preferred_Email__c)){
                contact.addError( Label.PreferredEmailRequiredError );
            }

            // Get the Api name that matches the value in Preferred Email
            String preferredApiField = ( preferredEmailMappings.containsKey(contact.Preferred_Email__c) ) ? preferredEmailMappings.get(contact.Preferred_Email__c) : valuedEmailMap.get(contact.Preferred_Email__c);

            String prefEmailVal = (String)contact.get(preferredApiField);

            if (  String.isNotBlank( prefEmailVal ) ) { 
                contact.Email = prefEmailVal;
            } else {
                contact.addError(Label.PreferredEmailMatchNotNull);
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
	            Map<String,String> oldValuedEmails = getEmailFieldsWithValue( oldmap.get(contact.Id) );

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
    * @description Returns a map of emails field labels and their api name if they have a value
    * @param Contact contact object to populate list from
    * @return Map<String,String> Map of emails fields key is field name and value is the field value
    */
	private static Map<String,String> getEmailFieldsWithValue(Contact contact) {
        // Organize Email fields with a value
        Map<String,String> valuedEmailMap = new Map<String,String>(); 

        if(contact != null) {

            // Retreive all Email fields
            Map<String, Schema.DescribeFieldResult> emailFields = UTIL_Describe.getFieldsOfType('Contact', 'EMAIL');

            for(String fieldName : emailFields.keySet() ) {

                String emailField = (String)contact.get(fieldName);

                // if the field has a value add it to the map, excluding the standard Email field
                if ( fieldName != 'Email' && String.isNotBlank(emailField) ) {
                    valuedEmailMap.put( emailFields.get(fieldName).getLabel(), fieldName);
                }
            }

        }

        return valuedEmailMap;
	}
}
