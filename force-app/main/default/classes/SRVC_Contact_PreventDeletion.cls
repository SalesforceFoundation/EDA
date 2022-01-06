/*
Copyright (c) 2020, Salesforce.org
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
 * @date 2020
 * @group
 * @group-content ../../ApexDocContent/Contacts.htm
 * @description Service class for CON_CannotDelete_TDTM. Returns Contact records
 * that have been prevented from deletion.
 */
public virtual with sharing class SRVC_Contact_PreventDeletion {
    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static SRVC_Contact_PreventDeletion instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected SRVC_Contact_PreventDeletion() {
    }

    /******************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of SRVC_Con_CanNotDelete.
     ******************************************************************************/
    public static SRVC_Contact_PreventDeletion getInstance() {
        if (instance == null) {
            instance = new SRVC_Contact_PreventDeletion();
        }

        return instance;
    }

    /****************************************************************************************************************
    @description Returns a list of records that have been prevented from deletion
    @param contactById The map of contacts by its Ids
    @param contactWithChildRecordsList A list of contacts with previously retrieved child relations
    @return contactPreventedFromDeletionList The list Contacts prevented from deletion
    *****************************************************************************************************************/
    public virtual List<Contact> preventDeletionForContacts(
        Map<Id, Contact> contactById,
        List<Contact> contactWithChildRecordsList
    ) {
        List<Contact> contactPreventedFromDeletionList = new List<Contact>();

        for (Contact eachContact : contactWithChildRecordsList) {
            Contact contactInContext = contactById.get(eachContact.ID);
            if (!this.contactWasMerged(contactInContext) && this.contactHasChildRecords(eachContact)) {
                contactInContext.addError(Label.CannotDelete);
                contactPreventedFromDeletionList.add(contactInContext);
            }
        }

        return contactPreventedFromDeletionList;
    }

    /****************************************************************************************************************
    @description Returns a list of Contacts and assocaited child records
    @params contactIdSet A set of Contact Id to return the records for
    @return List<Contact>
    *****************************************************************************************************************/
    public virtual List<Contact> getContactsAndChildRelationships(set<Id> contactIdSet) {
        return [
            SELECT
                ID,
                (SELECT ID FROM Addresses__r LIMIT 1),
                (SELECT ID FROM Affl_Accounts__r LIMIT 1),
                (SELECT ID FROM Applications_Applicant__r LIMIT 1),
                (SELECT ID FROM Applications_Preparer__r LIMIT 1),
                (SELECT ID FROM Attendance_Events__r LIMIT 1),
                (SELECT ID FROM Attributes__r LIMIT 1),
                (SELECT ID FROM Behavior_Involvements__r LIMIT 1),
                (SELECT ID FROM Contact_Languages__r LIMIT 1),
                (SELECT ID FROM Courses_Taught__r LIMIT 1),
                (SELECT ID FROM Education_History__r LIMIT 1),
                (SELECT ID FROM Program_Enrollments__r LIMIT 1),
                (SELECT ID FROM Student_Course_Enrollments__r LIMIT 1),
                (SELECT ID FROM Term_Grades__r LIMIT 1),
                (SELECT ID FROM Tests__r LIMIT 1)
            FROM Contact
            WHERE ID IN :contactIdSet
        ];
    }

    /*******************************************************************************************************
     * @description Evaluates whether the Contact has any child related records
     * @param con is the current Contact record
     * @return Boolean
     ********************************************************************************************************/
    @TestVisible
    protected virtual Boolean contactHasChildRecords(Contact con) {
        return (con.Addresses__r.isEmpty() == false ||
        con.Affl_Accounts__r.isEmpty() == false ||
        con.Applications_Applicant__r.isEmpty() == false ||
        con.Applications_Preparer__r.isEmpty() == false ||
        con.Attendance_Events__r.isEmpty() == false ||
        con.Attributes__r.isEmpty() == false ||
        con.Behavior_Involvements__r.isEmpty() == false ||
        con.Contact_Languages__r.isEmpty() == false ||
        con.Courses_Taught__r.isEmpty() == false ||
        con.Education_History__r.isEmpty() == false ||
        con.Program_Enrollments__r.isEmpty() == false ||
        con.Student_Course_Enrollments__r.isEmpty() == false ||
        con.Term_Grades__r.isEmpty() == false ||
        con.Tests__r.isEmpty() == false);
    }

    /**
     * @description Determines if a contact was merged and being deleted as a merge loser
     * @param  con A contact record
     * @return     True if a contact was merged and being deleted
     */
    @TestVisible
    protected virtual Boolean contactWasMerged(Contact con) {
        return (con.MasterRecordId != null) && (con.MasterRecordId.getSobjectType() == Schema.Contact.SObjectType);
    }
}
