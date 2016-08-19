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
    * @description Updates Course Offerings based on a Course Connection being made Primary.
    * @param listNew the list of Course Connections from trigger new.
    * @param listOld the list of Coursen Connections from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Course Connections.
    * @return dmlWrapper
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

         DmlWrapper dmlWrapper = new DmlWrapper();

         if (!COFF_Affiliation_TDTM.hasRunCoffTrigger) {
             // Check that Course Connections is enabled
             if (UTIL_CustomSettingsFacade.courseConnectionsEnabled()) {
                 List<Course_Offering__c> courseOfferingsToUpdate = new List<Course_Offering__c>();

                 if(newlist != null && newlist.size() > 0) {

                     for (Integer i = 0; i < newlist.size(); i++) {
                        Course_Enrollment__c enroll = (Course_Enrollment__c)newlist[i];

                        //AFTER INSERT
                        if(triggerAction == TDTM_Runnable.Action.AfterInsert) {
                            if(enroll.RecordTypeId == (Id)UTIL_CustomSettingsFacade.getFacultyConnectionRecTypeID() &&
                               enroll.Primary__c) {
                                Course_Offering__c cOff = new Course_Offering__c(
                                    Id = enroll.Course_Offering__c,
                                    Faculty__c = enroll.Contact__c
                                );
                                courseOfferingsToUpdate.add(cOff);
                            }
                        }

                        //AFTER UPDATE
                        if(triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                            Course_Enrollment__c oldEnroll = (Course_Enrollment__c)oldList[i];

                            if (enroll.RecordTypeId == (Id)UTIL_CustomSettingsFacade.getFacultyConnectionRecTypeID()) {
                                if (enroll.Primary__c && !oldEnroll.Primary__c) {
                                    // Update Course Offering to add new Primary Faculty
                                    Course_Offering__c cOff = new Course_Offering__c(
                                        Id = enroll.Course_Offering__c,
                                        Faculty__c = enroll.Contact__c
                                    );
                                    courseOfferingsToUpdate.add(cOff);
                                } else if (!enroll.Primary__c && oldEnroll.Primary__c) {
                                    // Update Course Offering to remove Primary Faculty
                                    Course_Offering__c cOff = new Course_Offering__c(
                                        Id = enroll.Course_Offering__c,
                                        Faculty__c = null
                                    );
                                    courseOfferingsToUpdate.add(cOff);
                                }
                            }
                        }
                    }
                }

                //AFTER DELETE
                if(triggerAction == TDTM_Runnable.Action.AfterDelete) {

                    if(oldList != null && oldList.size() > 0) {

                        for (Integer i = 0; i < oldList.size(); i++) {

                            Course_Enrollment__c oldEnroll = (Course_Enrollment__c)oldList[i];

                            if (oldEnroll.RecordTypeId == (Id)UTIL_CustomSettingsFacade.getFacultyConnectionRecTypeID()) {
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
            }
        }

        return dmlWrapper;
    }
}