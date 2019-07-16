/*
    Copyright (c) 2019 Salesforce.org
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
* @date 2019
* @group Contacts
* @group-content ../../ApexDocContent/Contacts.htm
* @description Handles processing of Contact Preferred Phone. Copies custom Phone fields to the standard field.
* Ensures a phone is selected when Preferred phone is set.
*/
public with sharing class CON_Phone {
    /*******************************************************************************************************
    * @description Sets the Phone field depending on the value of Preferred Phone
    * @param Contact the contact to update
    * @param oldlist list of old contacts from update or delete context of a trigger
    */
    public static void processPreferredPhone(Contact contact, List<Contact> oldlist) {
        
        Boolean validatePreferredPhone = !UTIL_CustomSettingsFacade.getSettings().Disable_Preferred_Phone_Enforcement__c;
        String selectedPreferredPhone = UTIL_CustomSettingsFacade.getSettings().Preferred_Phone_Selection__c; 
       
        // No need to run if we are in a delete context
        if (contact == null) {
            return;
        }

        Boolean isUpdateOrDelete = (oldlist != null) ? true : false;

        // Build the list of phone fields
        CON_PhoneFieldList phoneFields = new CON_PhoneFieldList(contact);

        if( phoneFields.valuedCount() > 0 ) {
            // Check the presence of a special cases when running a batch process.
            // This will prevent some validation errors below to allow batches to complete successfully.
            if( validatePreferredPhone && System.isBatch() ) {
                   
                // Catch a special case when there is a value in Phone that doesn't match the 
                // other fields and Preferred Phone is blank
                if(String.isNotBlank(contact.Phone) && phoneFields.valueExists(contact.Phone) == null && String.isBlank(contact.PreferredPhone__c)) {
                   
                    contact.PreferredPhone__c = Label.preferredBatchDefaultPhone;
                }

                // Process when Phone matches an existing value
                if(String.isNotBlank(contact.Phone) && phoneFields.valueExists(contact.Phone) != null && String.isBlank(contact.PreferredPhone__c)) {
                    contact.PreferredPhone__c = phoneFields.valueExists(contact.Phone).prefLabel;
                }

                // We are catching a special case here when there are multiple Phones but Phone is blank.
                // If there is only one custom Phone present, we will set it as preferred. When multiple
                // Phones are present the first in the list will be set to preferred if a selection
                // is not made in EDA settings.
                if(String.isBlank(contact.Phone) ) {
                    
                    if (phoneFields.valuedFields.size() > 1 && selectedPreferredPhone != NULL && selectedPreferredPhone != '') {
                    
                        for (CON_PhoneField eachField : phoneFields.valuedFields)  {
                                                     
                            if (eachField.apiName == selectedPreferredPhone) {
                            
                                contact.Phone = eachField.value;
                                contact.PreferredPhone__c = eachField.prefLabel;
                                
                            }    
                            
                        }

                        if (contact.Phone == NULL && Contact.PreferredPhone__c == NULL) {

                              contact.Phone = phoneFields.valuedFields[0].value;
                              contact.PreferredPhone__c = phoneFields.valuedFields[0].prefLabel;

                        }
                    }
                    
                     // Get the first item from the list either one or many
                     
                    else {
                        
                        contact.Phone = phoneFields.valuedFields[0].value;
                        contact.PreferredPhone__c = phoneFields.valuedFields[0].prefLabel;
                        
                    }
                }
            }

            // Only one phone field, so we can intelligently set Preferred Phone.
            if(validatePreferredPhone && phoneFields.valuedCount() == 1 && String.isBlank(contact.PreferredPhone__c)){

                contact.PreferredPhone__c = phoneFields.valuedFields[0].prefLabel;
                contact.Phone = phoneFields.valuedFields[0].value;

            // Enforce Preferred Phone field unless validation is disabled
            } else if(validatePreferredPhone && String.isBlank(contact.PreferredPhone__c)){

                contact.addError( Label.PreferredPhoneRequiredError );

            // Make Sure preferred isn't blank making an exception for a special case to prevent errors.
            } else if ( String.isNotBlank(contact.PreferredPhone__c) && contact.PreferredPhone__c != Label.preferredBatchDefaultPhone && contact.PreferredPhone__c != phoneFields.phoneLabel ) {

                CON_PhoneField field = phoneFields.getFieldByPrefLabel(contact.PreferredPhone__c);
                if( field != null) {
                    // Make sure we are not setting to a blank value
                    if(String.isNotBlank(field.value)) {
                        // Copy the value that matches preferred Phone to the standard Phone field
                        contact.Phone = field.value;
                    } else {
                        contact.addError(Label.PreferredPhoneMatchNotNull);
                    }

                // Make sure the value in Preferred Phone matches an actual field 
                } else {
                    contact.addError(Label.PreferredPhoneMatchMustExist);
                }
            }

        } else {
                   
            // Cannot have Preferred Phone set if there are no phones present
            if( String.isNotBlank(contact.PreferredPhone__c)) {
                contact.addError(Label.PreferredPhoneMatchNotNull);
            }

            // We are not going to format data for orgs that are not enforcing the Preferred Phone field
            if(validatePreferredPhone && String.isNotBlank(contact.Phone)) {

                // oldlist is NULL on insert so we check to make sure this logic only applies on updates.
                // We make sure this isn't a batch, because the batch relies on this trigger while
                // updating contacts
                if( isUpdateOrDelete && !System.isBatch() ) {
                    Map<ID, Contact> oldmap = new Map<ID, Contact>( (List<Contact>)oldlist);

                    // Get the old phone values - if any - to compare.
                    CON_PhoneFieldList oldPhoneFields = new CON_PhoneFieldList( oldmap.get(contact.Id) );

                    // If this is an update and the contact contained previous phones we want to clear the standard phone field
                    // we do this because when a user deletes all phone values in the EDA contact without clearing
                    // the value if phone, there would be an phone number that the user tried to delete.
                    if (oldPhoneFields.valuedCount() > 0) {
                        contact.Phone = null;
                    } else {

                        copyStdPhoneToOther(contact, phoneFields);
                    }
                } else {

                    copyStdPhoneToOther(contact, phoneFields);
                }
            }
        }


    } 

    /*******************************************************************************************************
    * @description Copies the value of the standard Phone field to the Other Phone field if Phone has a value and no other phones.
    * @param contact the contact to change
    * @param fieldList an instance of the CON_PhoneFieldList class
    */
    public static void copyStdPhoneToOther(Contact contact, CON_PhoneFieldList fieldList) {
        if(contact.Phone != null) {

            String namespace = UTIL_Namespace.getNamespace();
            String prefix = ( String.isNotBlank(namespace) ) ? namespace + '__' : '';
            // Retrieve field from field list using the known API name.
            CON_PhoneField otherField = fieldList.getFieldByApiName(prefix + 'OtherPhone');
            if (otherField != NULL) {
                contact.PreferredPhone__c = otherField.prefLabel;
                contact.OtherPhone = contact.Phone;
            }
            else {
                contact.PreferredPhone__c = 'Other';
                contact.OtherPhone = contact.Phone;
            }
        }
    }

    private static Map<String, Schema.DescribeFieldResult> contactPhoneFieldMap;

    /*******************************************************************************************************
    * @description An inner wrapper class to contain a list of phone fields and perform functions on them
    * @param Contact the contact to build list from.
    */

    private class CON_PhoneFieldList {

        private List<CON_PhoneField> allFields {get;set;}
        private List<CON_PhoneField> valuedFields {get;set;}
        public String phoneLabel {get;set;}

        public CON_PhoneFieldList(Contact contact) {

            this.allFields = new List<CON_PhoneField>();
            this.valuedFields = new List<CON_PhoneField>();

            if (contactPhoneFieldMap == null) {
                contactPhoneFieldMap = UTIL_Describe.getFieldsOfType('Contact', 'Phone');
            }
            this.phoneLabel = contactPhoneFieldMap.get('Phone').getLabel();

            Map<String, String> edaPhoneField = new Map<String, String>();
            //build map for EDA phone field map (Label, API Name)
            for(String fieldName : contactPhoneFieldMap.keySet() ) {
                if(String.isNotBlank(UTIL_Namespace.getNamespace()) && fieldName.startsWithIgnoreCase(UTIL_Namespace.getNamespace())) {
                    edaPhoneField.put(contactPhoneFieldMap.get(fieldName).getLabel(), fieldName);
                }
            }

            for(String fieldName : contactPhoneFieldMap.keySet()) {
                String fieldLabel = contactPhoneFieldMap.get(fieldName).getLabel();
                
                //If the field is not a standard phone field and it is not duplicate with EDA phone, then add it to the list
                if (fieldName != phoneLabel && 
                        !(edaPhoneField.get(fieldLabel) != null && fieldName != edaPhoneField.get(fieldLabel)) && fieldName != 'Phone') {
                    String phoneField = (String)contact.get(fieldName);

                    allFields.add(new CON_PhoneField(phoneField, fieldLabel, fieldName));
                    if(String.isNotBlank(phoneField)) {
                        valuedFields.add(new CON_PhoneField(phoneField, fieldLabel, fieldName));
                    }
                }
            }
        }

        public Integer valuedCount() {
            Integer count = 0;
            for(CON_PhoneField field : this.allFields) {
                count += (field.hasValue()) ? 1 : 0;
            }
            return count;
        }

        public CON_PhoneField getFieldByPrefLabel(String labelSearch) {
            labelSearch = getCustomPicklistValue(labelSearch);
            for(CON_PhoneField field : this.allFields) {
                if (labelSearch == field.label || labelSearch == field.prefLabel) {
                    return field;
                }
            }
            return null;
        }

        public CON_PhoneField getFieldByApiName(String apiSearch) {
            for(CON_PhoneField field : this.allFields) {
                if (apiSearch == field.apiName ) {
                    return field;
                }
            }
            return null;
        }

        private CON_PhoneField valueExists(String search) {
            for(CON_PhoneField field : this.valuedFields ){
                if(String.isNotBlank(search) && field.value == search){
                    return field;
                }
            }
            return null;
        }

        //Check if transalted picklist value of preferred phone exist
        private String getCustomPicklistValue(String lableSearch)
        {       
            Map<String,String> apiLabelMappings = new Map<String,String>();       
            Schema.DescribeFieldResult fieldResult = Contact.PreferredPhone__c.getDescribe();
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
    * @description An inner wrapper class to represent a phone field on a contact
    * @param val The value of the phone field
    * @param lbl The label of the phone field
    * @param api The API name of the phone field
    */
    private class CON_PhoneField {

        public String value {get;set;}
        public String label {get;set;}
        public String apiName {get;set;}
        public String prefLabel {get;set;}

        public CON_PhoneField(String val, String lbl, String api ) {
            // Store default phone field mappings to preferred phone pick list.
            Map<String,String> preferredPhoneMappings = new Map<String,String>{
                'Home Phone' => 'Home',
                'Work Phone' => 'Work',
                'Mobile' => 'Mobile',
                'Other Phone' => 'Other'
            };

            this.value = val;
            this.label = lbl;
            this.apiName = api;
            this.prefLabel = (preferredPhoneMappings.containsKey(lbl)) ? preferredPhoneMappings.get(lbl) : lbl;
        }

        public Boolean hasValue(){
            return String.isNotBlank(this.value);
        }
    }   
}