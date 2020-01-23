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
* Course Offering, Course Enrollment, Program Enrollment,
* Term Grade, or Test child records.
*/
public with sharing class CON_CannotDelete_TDTM extends TDTM_Runnable {
    /*******************************************************************************************************
    * @description Stops a Contact from being deleted if it has any Address, Affiliation,
    * Application, Attendance Event, Attribute, Behavior Involement, Contact Language,
    * Course Offering, Course Enrollment, Program Enrollment,
    * Term Grade, or Test child records.
    * @param listNew the list of Contacts from trigger new.
    * @param listOld the list of Contacts from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Contact
    * @return dmlWrapper.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

      Map<Id, Contact> oldMap = new Map<Id, Contact>((List<Contact>)oldList);
      Boolean isConDeletionPreventionEnabled = UTIL_CustomSettingsFacade.getSettings().Prevent_Contact_Deletion__c;

        if (triggerAction == TDTM_Runnable.Action.BeforeDelete && isConDeletionPreventionEnabled) {
            for (Contact c : [SELECT ID,
                            (SELECT ID FROM Contact.Addresses__r LIMIT 1),
                            (SELECT ID FROM Contact.Affl_Accounts__r LIMIT 1),
                            (SELECT ID FROM Contact.Applications_Applicant__r LIMIT 1),
                            (SELECT ID FROM Contact.Applications_Preparer__r LIMIT 1),
                            (SELECT ID FROM Contact.Attendance_Events__r LIMIT 1),
                            (SELECT ID FROM Contact.Attributes__r LIMIT 1),
                            (SELECT ID FROM Contact.Behavior_Involvements__r LIMIT 1),
                            (SELECT ID FROM Contact.Contact_Languages__r LIMIT 1),
                            (SELECT ID FROM Contact.Courses_Taught__r LIMIT 1),
                            (SELECT ID FROM Contact.Program_Enrollments__r LIMIT 1),
                            (SELECT ID FROM Contact.Student_Course_Enrollments__r LIMIT 1),
                            (SELECT ID FROM Contact.Term_Grades__r LIMIT 1),
                            (SELECT ID FROM Contact.Tests__r LIMIT 1)
                            FROM Contact
                            WHERE ID IN :oldlist])
            {
                if (hasChildRecords(c)) {
                    Contact contactInContext = oldmap.get(c.ID);
                    contactInContext.addError(Label.CannotDelete);
                }
            }
        }

      return new DmlWrapper();
   }

   /*******************************************************************************************************
   * @description Evaluates whether the Contact has any child related records.
   * @param c is the current Contact record.
   * @return Boolean.
   ********************************************************************************************************/
   private static Boolean hasChildRecords(Contact c) {
        return (c.Addresses__r.size() > 0 || c.Affl_Accounts__r.size() > 0 ||
                c.Applications_Applicant__r.size() > 0  || c.Applications_Preparer__r.size() > 0 ||
                c.Attendance_Events__r.size() > 0 || c.Attributes__r.size () > 0 ||
                c.Behavior_Involvements__r.size() > 0 || c.Contact_Languages__r.size() > 0 ||
                c.Courses_Taught__r.size() > 0 || c.Program_Enrollments__r.size() > 0 ||
                c.Student_Course_Enrollments__r.size() > 0 || c.Term_Grades__r.size() > 0 || c.Tests__r.size() > 0);
   }
}