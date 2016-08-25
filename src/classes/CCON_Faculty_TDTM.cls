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
* @group CourseEnrollments
* @group-content ../../ApexDocContent/CourseEnrollments.htm
* @description Automatically handles syncing of Primary Faculty in a Course Connection.
*/
public with sharing class CCON_Faculty_TDTM extends TDTM_Runnable {

    /*******************************************************************************************************
    * @description Updates Course Offerings based on a Course Connection being made Primary. Sets Academic
    * Program on create and manages Affiliation creation and deletion for Faculty Course Connections.
    * @param listNew the list of Course Connections from trigger new.
    * @param listOld the list of Coursen Connections from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Course Connections.
    * @return dmlWrapper
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        DmlWrapper dmlWrapper = new DmlWrapper();

        // Check that Course Connections is enabled
        if (UTIL_CustomSettingsFacade.courseConnectionsEnabled()) {

            Id facultyRecType = (Id)UTIL_CustomSettingsFacade.getFacultyConnectionRecTypeID();

            List<Course_Offering__c> courseOfferingsToUpdate = new List<Course_Offering__c>();
            List<Course_Enrollment__c> courseConnsBeforeInsert = new List<Course_Enrollment__c>();

            List<Affiliation__c> affiliationsToInsert = new List<Affiliation__c>();
            List<Course_Enrollment__c> connsNeedingAffls = new List<Course_Enrollment__c>();

            List<Affiliation__c> affiliationsToDelete = new List<Affiliation__c>();

            Map<Id, Map<Id, List<Affiliation__c>>> contactIdAccountIdAfflList = new Map<Id, Map<Id, List<Affiliation__c>>>();

            Set<Id> courseOfferingIds = new Set<Id>();
            Set<Id> contactIds = new Set<Id>();
            Map<Id, Course_Offering__c> offerings = new Map<Id, Course_Offering__c>();

            if(newlist != null && newlist.size() > 0) {
                for (Integer i = 0; i < newlist.size(); i++) {
                    Course_Enrollment__c enroll = (Course_Enrollment__c)newlist[i];
                    if (enroll.get('RecordTypeId') == facultyRecType) {
                        courseOfferingIds.add(enroll.Course_Offering__c);
                        contactIds.add(enroll.Contact__c);
                    }
                }
            }

            if (courseOfferingIds.size() > 0) {
                // Query for all the related Course Offerings
                offerings = getCourseOfferings(courseOfferingIds);
            }

            if(newlist != null && newlist.size() > 0) {

                //BEFORE INSERT
                if(triggerAction == TDTM_Runnable.Action.BeforeInsert) {

                    if (offerings.size() > 0) {
                        contactIdAccountIdAfflList = getContactIdAccountIdAffiliationsList(contactIds);
                    }

                    for (Integer i = 0; i < newlist.size(); i++) {
                        Course_Enrollment__c enroll = (Course_Enrollment__c)newlist[i];

                        if(enroll.get('RecordTypeId') == facultyRecType) {
                            enroll.Account__c = offerings.get(enroll.Course_Offering__c).Course__r.Account__c;

                            if (contactIdAccountIdAfflList.containsKey(enroll.Contact__c) && (
                                 contactIdAccountIdAfflList.get(enroll.Contact__c).containsKey(enroll.Account__c))) {
                                enroll.Affiliation__c = contactIdAccountIdAfflList.get(enroll.Contact__c).get(enroll.Account__c)[0].Id;
                            } else {
                                Affiliation__c affl = new Affiliation__c(
                                    Contact__c = enroll.Contact__c,
                                    Account__c = enroll.Account__c,
                                    Role__c = 'Faculty'
                                );
                                affiliationsToInsert.add(affl);
                                connsNeedingAffls.add(enroll);
                            }
                        }
                    }

                    if (affiliationsToInsert.size() > 0) {
                        insert affiliationsToInsert;

                        for (Integer i = 0; i < affiliationsToInsert.size(); i++) {
                            connsNeedingAffls[i].Affiliation__c = affiliationsToInsert[i].Id;
                        }
                    }
                }

                for (Integer i = 0; i < newlist.size(); i++) {
                    Course_Enrollment__c enroll = (Course_Enrollment__c)newlist[i];

                    //AFTER INSERT
                    if(triggerAction == TDTM_Runnable.Action.AfterInsert) {
                        // Faculty Marked as Primary on Insert
                        if(enroll.get('RecordTypeId') == facultyRecType &&
                           enroll.Primary__c) {
                            Course_Offering__c offering = offerings.get(enroll.Course_Offering__c);
                            if (offering.Faculty__c != enroll.Contact__c) {
                                offering.Faculty__c = enroll.Contact__c;
                                courseOfferingsToUpdate.add(offering);
                            }
                        }
                    }

                    //AFTER UPDATE
                    if(triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                        Course_Enrollment__c oldEnroll = (Course_Enrollment__c)oldList[i];

                        if (enroll.get('RecordTypeId') == facultyRecType) {
                            if (enroll.Primary__c && !oldEnroll.Primary__c) {
                                // Update Course Offering to add new Primary Faculty
                                Course_Offering__c offering = offerings.get(enroll.Course_Offering__c);
                                if (offering.Faculty__c != enroll.Contact__c) {
                                    offering.Faculty__c = enroll.Contact__c;
                                }
                                courseOfferingsToUpdate.add(offering);
                            } else if (!enroll.Primary__c && oldEnroll.Primary__c) {
                                // Update Course Offering to remove Primary Faculty
                                Course_Offering__c offering = offerings.get(enroll.Course_Offering__c);
                                if (offering.Faculty__c == oldEnroll.Contact__c) {
                                    offering.Faculty__c = null;
                                }
                                courseOfferingsToUpdate.add(offering);
                            }
                        }
                    }
                }
            }

            //AFTER DELETE
            if(triggerAction == TDTM_Runnable.Action.AfterDelete) {

                Set<Id> potentialAfflDeletionsIds = new Set<Id>();
                Map<Id, Affiliation__c> potentialAfflDeletions = new Map<Id, Affiliation__c>();
                Set<Id> afflIdsToDelete = new Set<Id>();

                if(oldList != null && oldList.size() > 0) {

                    for (Integer i = 0; i < oldList.size(); i++) {
                        Course_Enrollment__c oldEnroll = (Course_Enrollment__c)oldList[i];
                        potentialAfflDeletionsIds.add(oldEnroll.Affiliation__c);
                    }

                    potentialAfflDeletions = getAffiliations(potentialAfflDeletionsIds);

                    for (Integer i = 0; i < oldList.size(); i++) {

                        Course_Enrollment__c oldEnroll = (Course_Enrollment__c)oldList[i];

                        if (oldEnroll.get('RecordTypeId') == facultyRecType) {
                            if (potentialAfflDeletions.containsKey(oldEnroll.Affiliation__c)) {
                                Affiliation__c affl = potentialAfflDeletions.get(oldEnroll.Affiliation__c);
                                if (affl.Course_Enrollment__r.size() == 0) {
                                    affiliationsToDelete.add(affl);
                                }
                            }
                            if (oldEnroll.Primary__c) {
                                // Update Course Offering to remove Primary Faculty
                                Course_Offering__c cOff = new Course_Offering__c(
                                    Id = oldEnroll.Course_Offering__c,
                                    Faculty__c = null
                                );
                                courseOfferingsToUpdate.add(cOff);
                            }
                        }
                    }
                }
            }

            if(courseOfferingsToUpdate.size() > 0) {
                dmlWrapper.objectsToUpdate.addAll((List<SObject>)courseOfferingsToUpdate);
            }

            if(affiliationsToDelete.size() > 0) {
                dmlWrapper.objectsToDelete.addAll((List<SObject>)affiliationsToDelete);
            }
        }


        return dmlWrapper;
    }

    /*******************************************************************************************************
     * @description Gets all Course Offerings related to Course Connections in order to get the Course
     * account for Academic Program.
     * @param courseOfferingIds A set of Course Offering Ids
     * @return Map<Id, Course_Offering__c>
     ********************************************************************************************************/
    private Map<Id, Course_Offering__c> getCourseOfferings(Set<Id> courseOfferingIds) {
        return new Map<Id, Course_Offering__c>([
            SELECT
                Id,
                Faculty__c,
                Course__r.Account__c
            FROM
                Course_Offering__c
            WHERE
                Id
            IN
                :courseOfferingIds
        ]);
    }

    /*******************************************************************************************************
     * @description Gets all Affiliations related to Course Connections in order to get the number of
     * Course Connections affiliated.
     * @param afflIds A set of Affiliation Ids
     * @return Map<Id, Affiliation__c>
     ********************************************************************************************************/
    private Map<Id, Affiliation__c> getAffiliations(Set<Id> afflIds) {
        return new Map<Id, Affiliation__c>( [
            SELECT
                Id,
                (
                    SELECT
                        Id
                    FROM
                        Course_Enrollment__r
                )
            FROM
                Affiliation__c
            WHERE
                Id
            IN
                :afflIds
        ]);
    }

    /*******************************************************************************************************
     * @description Gets all Affiliations related to Course Connections Contact in order to determine if
     * an Affiliation needs to be created or deleted. Returns a Map with the Contact ids as the key and a
     * Map as the value. The Map as a value has an Account Id as key and a List of Affiliations as values.
     * definition: Map<CONTACT_ID, Map<ACCOUNT_ID, List<Affiliation__c>>>
     * @param contactIds A Set of Contact Ids
     * @return Map<Id, Map<Id, List<Affiliation__c>>>
     ********************************************************************************************************/
    private Map<Id, Map<Id, List<Affiliation__c>>> getContactIdAccountIdAffiliationsList(Set<Id> contactIds) {
        List<Affiliation__c> affls = [
            SELECT
                Id,
                Account__c,
                Contact__c,
                Role__c,
                CreatedDate
            FROM
                Affiliation__c
            WHERE
                Contact__c
            IN
                :contactIds
            AND
                Role__c = 'Faculty'
            ORDER BY
                CreatedDate
            ASC
        ];

        Map<Id, Map<Id, List<Affiliation__c>>> contactIdAccountIdAfflList = new Map<Id, Map<Id, List<Affiliation__c>>>();
        Map<Id, List<Affiliation__c>> acctAffl = new Map<Id, List<Affiliation__c>>();

        for(Affiliation__c affl : affls) {
            // Check if Contact ID key exists
            if (contactIdAccountIdAfflList.containsKey(affl.Contact__c)) {
                // Check if Account ID key exists
                if (contactIdAccountIdAfflList.get(affl.Contact__c).containsKey(affl.Account__c)) {
                    // Add Affiliation to List
                    contactIdAccountIdAfflList.get(affl.Contact__c).get(affl.Account__c).add(affl);
                } else {
                    // Create empty map and add Account ID to Affiliation Map
                    acctAffl.clear();
                    acctAffl.put(affl.Account__c, new List<Affiliation__c>{affl});
                    contactIdAccountIdAfflList.get(affl.Contact__c).putAll(acctAffl);
                }
            } else {
                acctAffl.clear();
                acctAffl.put(affl.Account__c, new List<Affiliation__c>{affl});
                contactIdAccountIdAfflList.put(affl.Contact__c, acctAffl);
            }
        }
        return contactIdAccountIdAfflList;
    }
}