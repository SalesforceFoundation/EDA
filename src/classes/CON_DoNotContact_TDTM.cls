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
* @description Synchronizes the "Do Not Contact" fields and naming exclusions for deceased contacts.
*/
public class CON_DoNotContact_TDTM extends TDTM_Runnable {

    /*******************************************************************************************************
    * @description Synchronizes the "Do Not Contact" fields and naming exclusions for deceased contacts.
    * @param listNew the list of Contacts from trigger new.
    * @param listOld the list of Contacts from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Contacts
    * @return dmlWrapper.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newList, List<SObject> oldList,
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        List<Contact> newContacts = (List<Contact>)newList;

        if (this.isBeforeInsert(triggerAction)) {
            this.processBeforeInsert(newContacts);
        }

        if (this.isBeforeUpdate(triggerAction)) {
            Map<Id, Contact> oldUpdatedContactsById = new Map<Id, Contact>((List<Contact>)oldlist);
            this.processBeforeUpdate(newContacts, oldUpdatedContactsById);
        }

        return new DmlWrapper();
    }
    
    /**
     * @description Determine if trigger fired is the result of a Before Insert action. 
     * @param  triggerAction The current trigger action
     * @return               return true is trigger context is Before Insert, 
     *                       false otherwise
     */ 
    @TestVisible
    private Boolean isBeforeInsert(TDTM_Runnable.Action triggerAction) {
        return triggerAction == TDTM_Runnable.Action.BeforeInsert;
    }

    /**
     * @description Determine if trigger fired is the result of a Before Update action. 
     * @param  triggerAction The current trigger action
     * @return               return description true if trigger context is Before Update,
     *                       false otherwise
     */ 
    @TestVisible
    private Boolean isBeforeUpdate(TDTM_Runnable.Action triggerAction) {
        return triggerAction == TDTM_Runnable.Action.BeforeUpdate;
    }

    /**
     * @description Execute the logic necessary for a Before Insert trigger
     * action.
     * @param  newContactsList List of Contacts being inserted
     */ 
    @TestVisible
    private void processBeforeInsert(List<Contact> newContactsList) {
        List<Contact> deceasedContacts = new List<Contact>();
        List<Contact> doNotContactContacts = new List<Contact>();

        for (Contact con : newContactsList){
            if (con.Deceased__c == true){
                con.Do_Not_Contact__c = con.Deceased__c;
                deceasedContacts.add(con);
            }

            if (con.Do_Not_Contact__c == true){
                doNotContactContacts.add(con);
            }
        }

        if (deceasedContacts.isEmpty() == false){
            this.syncNamingExclusionsOnContacts(deceasedContacts);
            this.syncDoNotContactFieldsOnContacts(deceasedContacts);
        }

        if (doNotContactContacts.isEmpty() == false){
            this.syncDoNotContactFieldsOnContacts(doNotContactContacts);
        }


        // for (Contact con : newContactsList){
        //     if (con.Deceased__c == true){
        //         con.Do_Not_Contact__c = con.Deceased__c;
        //         this.syncNamingExclusionsOnContact(con);
        //     } 
        //     if (con.Do_Not_Contact__c == true){
        //         this.syncDoNotContactFieldsOnContact(con);
        //     }
        // }
    }

    /**
     * @description Execute the logic necessary for a Before Update trigger
     * action.
     * @param  newContactsList     List of updated Contact state 
     * @param  oldContactsById     Map of Contact state prior to update
     */ 
    @TestVisible
    private void processBeforeUpdate(List<Contact> newContactsList, Map<Id, Contact> oldContactsById) {
        List<Contact> deceasedContacts = new List<Contact>();
        List<Contact> doNotContactContacts = new List<Contact>();
        
        for (Contact con : newContactsList){
            Contact oldCon = oldContactsById.get(con.Id);

            if (con.Deceased__c != oldCon.Deceased__c){
                // Deceased status changed
                con.Do_Not_Contact__c = con.Deceased__c;
                deceasedContacts.add(con);
            }

            if (con.Do_Not_Contact__c != oldCon.Do_Not_Contact__c){
                // Do Not Contact flag changed
                doNotContactContacts.add(con);
            }
        }

        if (deceasedContacts.isEmpty() == false){
            this.syncNamingExclusionsOnContacts(deceasedContacts);
            this.syncDoNotContactFieldsOnContacts(deceasedContacts);
        }

        if (doNotContactContacts.isEmpty() == false){
            this.syncDoNotContactFieldsOnContacts(doNotContactContacts);
        }

        // for (Contact con : newContactsList){

        //     Contact oldCon = oldContactsById.get(con.Id);

        //     if (con.Deceased__c != oldCon.Deceased__c){
        //         // Deceased status changed
        //         con.Do_Not_Contact__c = con.Deceased__c;
        //         this.syncNamingExclusionsOnContact(con);
        //     } 
            
        //     if (con.Do_Not_Contact__c != oldCon.Do_Not_Contact__c){
        //         // Do Not Contact flag changed
        //         this.syncDoNotContactFieldsOnContact(con);
        //     }            
        // }
    }

    /**
     * @description Synchronizes the communication preference fields
     * (Do not Call, Email Opt Out, Fax Opt Out) on a contact record
     * to match the status specified by the "Do Not Contact" field.
     * @param  contactsList List of contacts to synchronize
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
     * @param  contactsList List of contacts to synchronize
     */ 
    @TestVisible
    private void syncNamingExclusionsOnContacts(List<Contact> contactsList){
        for (Contact con : contactsList){
            con.Exclude_from_Household_Name__c = con.Deceased__c;
            con.Exclude_from_Household_Formal_Greeting__c = con.Deceased__c;
            con.Exclude_from_Household_Informal_Greeting__c = con.Deceased__c;
        }

        this.syncSelectedHHNamingExclusionsFromCheckboxes(contactsList);
    }

    /**
     * @description Retrieves the naming exclusions specified by the selected checkboxes and synchronizes
     * the values in Naming Exclusion multiselect picklist to match.
     * @param  contactsList List of contacts to synchronize
     */ 
    @TestVisible
    private void syncSelectedHHNamingExclusionsFromCheckboxes(List<Contact> contactsList) {
        for (Contact con : contactsList){
            List<String> selectedNamingExclusionList = new List<String>();
            String selectedNamingExclusions = '';
    
            if (con.Exclude_from_Household_Name__c == true) {
                selectedNamingExclusionList.add('Household__c.Name');
            }
    
            if (con.Exclude_from_Household_Formal_Greeting__c == true) {
                selectedNamingExclusionList.add('Household__c.Formal_Greeting__c');
            }
    
            if (con.Exclude_from_Household_Informal_Greeting__c == true) {
                selectedNamingExclusionList.add('Household__c.Informal_Greeting__c');
            }
    
            con.Naming_Exclusions__c = String.join(selectedNamingExclusionList, ';');
        }
    }
}