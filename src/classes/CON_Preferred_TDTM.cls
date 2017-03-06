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

    /*******************************************************************************************************
    * @description Updates default email and phone fields based to the preferred email and preferred phone values.
    * @return dmlWrapper
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
             
        if((triggerAction == TDTM_Runnable.Action.BeforeInsert || triggerAction == TDTM_Runnable.Action.BeforeUpdate) && newlist != null) {

            for(SObject so : newlist) {
                Contact contact = (Contact)so;

                // Process the prefered Email
                CON_Email.processPreferredEmail(contact, oldlist);
                
                // Process the Preferred Phone
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