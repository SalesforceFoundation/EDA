/*
    Copyright (c) 2016, Salesforce.org
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
 * @date 2016
 * @group Accounts
 * @group-content ../../ApexDocContent/Contacts.htm
 * @description Stops a Contact from being deleted if it has any Address, Affiliation,
 * Application, Attendance Event, Attribute, Behavior Involement, Contact Language,
 * Course Offering, Course Enrollment, Education History, Program Enrollment,
 * Term Grade, or Test child records.
 */
public with sharing class CON_CannotDelete_TDTM extends TDTM_Runnable {
    //TODO: This variable has to be static because TDTM doesn't preserve TDTM_Runnable instance
    //between Before* and After* calls
    @TestVisible
    private static List<Contact> contactsWithChildRelations;

    /*******************************************************************************************************
     * @description Stops a Contact from being deleted if it has any Address, Affiliation,
     * Application, Attendance Event, Attribute, Behavior Involement, Contact Language,
     * Course Offering, Course Enrollment, Program Enrollment,
     * Term Grade, or Test child records
     * @param listNew the list of Contacts from trigger new
     * @param listOld the list of Contacts from trigger old
     * @param triggerAction which trigger event (BeforeDelete)
     * @param objResult the describe for Contact
     * @return dmlWrapper
     ********************************************************************************************************/
    public override DmlWrapper run(
        List<SObject> newList,
        List<SObject> oldList,
        TDTM_Runnable.Action triggerAction,
        Schema.DescribeSObjectResult objResult
    ) {
        if (oldlist == null || oldlist.isEmpty() == true) {
            return new DmlWrapper();
        }

        if (triggerAction == TDTM_Runnable.Action.BeforeDelete) {
            contactsWithChildRelations = this.handleBeforeDelete(oldList);
        } else if (triggerAction == TDTM_Runnable.Action.AfterDelete) {
            this.handleAfterDelete(oldList);
            contactsWithChildRelations = null;
        }

        return new DmlWrapper();
    }

    /*******************************************************************************************************
     * @description Returns if Contact Deletion Prevention custom setting is not enabled or
     * Returns a List of Contacts with retrieved child relationships
     * @param oldSObjectList list of sObject records that are being deleted
     * @return List<Contact>
     ********************************************************************************************************/
    @TestVisible
    private List<Contact> handleBeforeDelete(List<SObject> oldSObjectList) {
        if (!this.isContactDeletionPreventionEnabled()) {
            return null;
        }

        Map<Id, Contact> oldContactById = new Map<Id, Contact>((List<Contact>) oldSObjectList);
        return this.locateContactPreventDeletionService().getContactsAndChildRelationships(oldContactById.keySet());
    }

    /*******************************************************************************************************
     * @description Returns if Contact Deletion Prevention custom setting is not enabled or
     * Passes a map of contacts By Id to SRVC_Contact_PreventDeletion and returns a List of Contacts that have
     * been prevented for deletion
     * @param oldSObjectList list of sObject records that are being deleted
     * @return List<Contact>
     ********************************************************************************************************/
    @TestVisible
    private List<Contact> handleAfterDelete(List<SObject> oldSObjectList) {
        if (!this.isContactDeletionPreventionEnabled()) {
            return null;
        }

        Map<Id, Contact> oldContactById = new Map<Id, Contact>((List<Contact>) oldSObjectList);
        return this.locateContactPreventDeletionService()
            .preventDeletionForContacts(oldContactById, contactsWithChildRelations);
    }

    /*******************************************************************************************************
     * @description Returns the instance of SRVC_Contact_PreventDeletion class
     * @return The instance of SRVC_Contact_PreventDeletion class
     ********************************************************************************************************/
    @TestVisible
    private SRVC_Contact_PreventDeletion locateContactPreventDeletionService() {
        return SRVC_Contact_PreventDeletion.getInstance();
    }

    /*******************************************************************************************************
     * @description Returns the value of Prevent Contact deleteion custom settings
     * @return Boolean
     ********************************************************************************************************/
    @TestVisible
    private Boolean isContactDeletionPreventionEnabled() {
        return UTIL_CustomSettingsFacade.getSettings().Prevent_Contact_Deletion__c;
    }
}
