/*
    Copyright (c) 2015, Salesforce.org
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
* @date 2015
* @group Contacts
* @group-content ../../ApexDocContent/Contacts.htm
* @description Populates default email and phone fields according to user preferences.
*/
public class CON_Preferred_TDTM extends TDTM_Runnable {

    // Store default email field mappings to preferred email pick list.
    private Map<String,String> preferredEmailMappings = new Map<String,String>{   
        'University' => 'UniversityEmail__c',
        'Work' => 'WorkEmail__c',
        'Alternate' => 'AlternateEmail__c'
    };

    /*******************************************************************************************************
    * @description Updates default email and phone fields based to the preferred email and preferred phone values.
    * @return dmlWrapper
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
             
         if((triggerAction == TDTM_Runnable.Action.BeforeInsert || triggerAction == TDTM_Runnable.Action.BeforeUpdate) && newlist != null) {
            
            for(SObject so : newlist) {
                Contact contact = (Contact)so;



                // Copy custom email fields to standard if only one is present
                Map<String, Schema.DescribeFieldResult> emailFields = UTIL_Describe.getFieldsOfType('Contact', 'EMAIL');

                // Organize Email fields with a value
                Map<String,String> valuedEmailMap = new Map<String,String>(); 
                for(String fieldName : emailFields.keySet() ) {

                    String emailField = (String)contact.get(fieldName);

                    if ( fieldName != 'Email' && String.isNotBlank(emailField) ) {
                        valuedEmailMap.put( emailFields.get(fieldName).getLabel(), fieldName);
                    }
                }

                // Enforce preferred email field
                if(valuedEmailMap.size() > 0 && String.isBlank(contact.Preferred_Email__c) ) {
                    contact.addError( Label.PreferredEmailRequiredError );
                }
            
                if(!String.isBlank(contact.Preferred_Email__c) && valuedEmailMap.size() > 1 ) {

                    // Get the Api name that matches the value in Preferred Email
                    String preferredApiField = ( preferredEmailMappings.containsKey(contact.Preferred_Email__c) ) ? preferredEmailMappings.get(contact.Preferred_Email__c) : valuedEmailMap.get(contact.Preferred_Email__c);

                    String prefEmailVal = (String)contact.get(preferredApiField);

                    if (  String.isNotBlank( prefEmailVal ) ) { 
                        contact.put('Email',  prefEmailVal );
                    } else {
                        contact.addError(Label.PreferredEmailMatchNotNull);
                    }                    
                }
                
                if(!String.isBlank(contact.PreferredPhone__c)) {
                    if(contact.PreferredPhone__c == 'Home') {
                        contact.Phone = contact.HomePhone;
                    } else if(contact.PreferredPhone__c == 'Work') {
                        contact.Phone = contact.WorkPhone__c;
                    } else if(contact.PreferredPhone__c == 'Mobile') {
                        contact.Phone = contact.MobilePhone;
                    } else if(contact.PreferredPhone__c == 'Other') {
                        contact.Phone = contact.OtherPhone;
                    }
                }
            }
         }
         
         return null;
    }
}