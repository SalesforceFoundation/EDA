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
* @description Synchronizes Household naming exclusions and communication preferences 
* with changes to the Deceased and Do Not Contact fields for the Contact object.
*/
public class CON_DoNotContact_TDTM extends TDTM_Runnable {

    /*******************************************************************************************************
    * @description Synchronizes Household naming exclusions and communication preferences 
    * with changes to the Deceased and Do Not Contact fields for the Contact object.
    * @param newList the list of Contacts from trigger new
    * @param oldList the list of Contacts from trigger old
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.)
    * @param objResult the describe for Contacts
    * @return dmlWrapper.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newList, List<SObject> oldList,
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        List<Contact> newContactsList = (List<Contact>)newList;

        if (this.isBeforeInsert(triggerAction)) {
            this.processBeforeInsert(newContactsList);
        }

        if (this.isBeforeUpdate(triggerAction)) {
            Map<Id, Contact> oldUpdatedContactsById = new Map<Id, Contact>((List<Contact>)oldlist);
            this.processBeforeUpdate(newContactsList, oldUpdatedContactsById);
        }

        return new DmlWrapper();
    }
    
    /**
    * @description Determine if trigger fired is the result of a BeforeInsert action. 
    * @param triggerAction The current trigger action
    * @return returns true is trigger context is BeforeInsert, false otherwise
    */ 
    @TestVisible
    private Boolean isBeforeInsert(TDTM_Runnable.Action triggerAction) {
        return triggerAction == TDTM_Runnable.Action.BeforeInsert;
    }

    /**
    * @description Determine if trigger fired is the result of a BeforeUpdate action. 
    * @param triggerAction The current trigger action
    * @return returns true if trigger context is BeforeUpdate, false otherwise
    */ 
    @TestVisible
    private Boolean isBeforeUpdate(TDTM_Runnable.Action triggerAction) {
        return triggerAction == TDTM_Runnable.Action.BeforeUpdate;
    }

    /**
     * @description Execute the logic necessary for a BeforeInsert trigger action.
     * @param newContactsList List of Contacts inserted
     */ 
    @TestVisible
    private void processBeforeInsert(List<Contact> newContactsList) {
        List<Contact> contactsMarkedDeceasedList = new List<Contact>();
        List<Contact> contactsMarkedDoNotContactList = new List<Contact>();

        for (Contact con : newContactsList){
            if (con.Deceased__c == true){
                con.Do_Not_Contact__c = con.Deceased__c;
                contactsMarkedDeceasedList.add(con);
            }

            if (con.Do_Not_Contact__c == true){
                contactsMarkedDoNotContactList.add(con);
            }
        }

        if (contactsMarkedDeceasedList.isEmpty() == false){
            this.syncNamingExclusionsOnContacts(contactsMarkedDeceasedList);
        }

        if (contactsMarkedDoNotContactList.isEmpty() == false){
            this.syncDoNotContactFieldsOnContacts(contactsMarkedDoNotContactList);
        }
    }

    /**
    * @description Execute the logic necessary for a BeforeUpdate trigger action.
    * @param newContactsList List of updated contacts
    * @param oldContactsById Map of contacts' state prior to update
    */ 
    @TestVisible
    private void processBeforeUpdate(List<Contact> newContactsList, Map<Id, Contact> oldContactsById) {
        List<Contact> contactsWithDeceasedChangeList = new List<Contact>();
        List<Contact> contactsWithDoNotContactChangeList = new List<Contact>();

        for (Contact con : newContactsList){
            Contact oldCon = oldContactsById.get(con.Id);

            if (con.Deceased__c != oldCon.Deceased__c){
                con.Do_Not_Contact__c = con.Deceased__c;
                contactsWithDeceasedChangeList.add(con);
            }

            if (con.Do_Not_Contact__c != oldCon.Do_Not_Contact__c){
                contactsWithDoNotContactChangeList.add(con);
            }
        }

        if (contactsWithDeceasedChangeList.isEmpty() == false){
            this.syncNamingExclusionsOnContacts(contactsWithDeceasedChangeList);
        }

        if (contactsWithDoNotContactChangeList.isEmpty() == false){
            this.syncDoNotContactFieldsOnContacts(contactsWithDoNotContactChangeList);
        }
    }

    /**
    * @description Synchronizes the communication preference fields
    * (Do not Call, Email Opt Out, Fax Opt Out) on a contact record
    * to match the status specified by the "Do Not Contact" field.
    * @param contactsList List of contacts to synchronize
    */ 
    @TestVisible
    private void syncDoNotContactFieldsOnContacts(List<Contact> contactsList){
        for (Contact con : contactsList){
            con.HasOptedOutOfEmail = con.Do_Not_Contact__c;
            con.DoNotCall = con.Do_Not_Contact__c;
            con.HasOptedOutOfFax  = con.Do_Not_Contact__c;
        }
    }

    /**
    * @description Synchronizes the Household Naming Exclusion fields 
    * (checkboxes and picklist) on a contact record to match the status 
    * specified by the "Deceased" field.
    * @param contactsList List of contacts to synchronize
    */ 
    @TestVisible
    private void syncNamingExclusionsOnContacts(List<Contact> contactsList){
        for (Contact con : contactsList){
            con.Exclude_from_Household_Name__c = con.Deceased__c;
            con.Exclude_from_Household_Formal_Greeting__c = con.Deceased__c;
            con.Exclude_from_Household_Informal_Greeting__c = con.Deceased__c;
        }
    }

}
