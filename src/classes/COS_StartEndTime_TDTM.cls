/*
    Copyright (c) 2019, Salesforce.org
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
* @date 2019
* @group Course Offering
* @group-content ../../ApexDocContent/CourseOfferings.htm
* @description TBD
*/
public with sharing class COS_StartEndTime_TDTM extends TDTM_Runnable {

    /*******************************************************************************************************
    * @description Iterates over all Course Offering Schedule records TBD
    * @param newList the list of Course Offering Schedules from trigger new.
    * @param oldList the list of Course Offering Schedules from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Course Offering Schedule.
    * @return dmlWrapper TBD
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newList, List<SObject> oldList,
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        DmlWrapper dmlWrapper = new DmlWrapper();

        // This only runs on before insert and before update, but check it just to be safe.
        if (triggerAction != TDTM_Runnable.Action.BeforeInsert && triggerAction != TDTM_Runnable.Action.BeforeUpdate) {
            return dmlWrapper;
        }

        // This shouldn't ever happen, but check it just to be safe.
        if (newList == null || newList.size() == 0) {
            return dmlWrapper;
        }

        Boolean isUpdateContext = (triggerAction == TDTM_Runnable.Action.BeforeUpdate);
        List<Course_Offering_Schedule__c> courseOfferingSchedules = (List<Course_Offering_Schedule__c>)newList;
        Map<Id, Course_Offering_Schedule__c> oldCourseOfferingSchedulesMap = (oldList != null && oldList.size() > 0) ? 
            new Map<Id, Course_Offering_Schedule__c>((List<Course_Offering_Schedule__c>)oldList) : new Map<Id, Course_Offering_Schedule__c>();

        Set<Id> timeBlocksIdsToQuery = new Set<Id>();
        List<Course_Offering_Schedule__c> courseOfferingSchedulesToValidate = new List<Course_Offering_Schedule__c>();

        // Loop over the Course Offering Schedules - if there is a Time Block, we'll query the Time Block later to verify the times are valid,
        // and to flow down the times to the Course Offering Schedule if necessary. We'll also do this if the Time Block lookup field is swapped.
        for (Course_Offering_Schedule__c courseOfferingSchedule : courseOfferingSchedules) {
            
            // We don't need to flow down any times or do any validation if there is no Time Block.
            if (courseOfferingSchedule.Time_Block__c == null) {
                continue;
            }

            timeBlocksIdsToQuery.add(courseOfferingSchedule.Time_Block__c);
            courseOfferingSchedulesToValidate.add(courseOfferingSchedule);

            if (isUpdateContext) {
                Course_Offering_Schedule__c oldCourseOfferingSchedule = oldCourseOfferingSchedulesMap.get(courseOfferingSchedule.Id);

                // Is the Time Block changing? We'll need to grab the Start and End Times from both Time Block records before we update the
                // Start and End Times on the Course Offering Schedule.
                if (oldCourseOfferingSchedule != null && oldCourseOfferingSchedule.Time_Block__c != courseOfferingSchedule.Time_Block__c) {
                    timeBlocksIdsToQuery.add(oldCourseOfferingSchedule.Time_Block__c);
                }
            }
        }

        // Do we need to do anything?
        if (courseOfferingSchedulesToValidate.size() == 0) {
            return dmlWrapper;
        }

        Map<Id, Time_Block__c> timeBlocksMap = new Map<Id, Time_Block__c>([SELECT Start_Time__c, 
                                                                               End_Time__c 
                                                                        FROM Time_Block__c WHERE Id IN :timeBlocksIdsToQuery]);

        for (Course_Offering_Schedule__c courseOfferingSchedule : courseOfferingSchedulesToValidate) {
            Time_Block__c timeBlock = timeBlocksMap.get(courseOfferingSchedule.Time_Block__c);
            if (timeBlock == null) {
                continue;
            }

            if (isUpdateContext) {
                Course_Offering_Schedule__c oldCourseOfferingSchedule = oldCourseOfferingSchedulesMap.get(courseOfferingSchedule.Id);
                Time_Block__c oldTimeBlock = timeBlocksMap.get(oldCourseOfferingSchedule.Time_Block__c);

                if (oldTimeBlock != null && oldTimeBlock.Id != timeBlock.Id) { // We're swapping a Time Block for another Time Block
                    
                    // Does the Start Time and End Time on the Course Offering Schedule match the values on the old Time Block? If so, 
                    // swap them with the new values.
                    if (courseOfferingSchedule.Start_Time__c == oldTimeBlock.Start_Time__c 
                            && courseOfferingSchedule.End_Time__c == oldTimeBlock.End_Time__c) {
                        courseOfferingSchedule.Start_Time__c = timeBlock.Start_Time__c;
                        courseOfferingSchedule.End_Time__c = timeBlock.End_Time__c;
                    }

                } else if (oldTimeBlock == null) { // We're setting a Time Block on the Course Offering Schedule in an update
                    if (courseOfferingSchedule.Start_Time__c == null) {
                        courseOfferingSchedule.Start_Time__c = timeBlock.Start_Time__c;
                    }

                    if (courseOfferingSchedule.End_Time__c == null) {
                        courseOfferingSchedule.End_Time__c = timeBlock.End_Time__c;
                    }
                }
            } else { // We're inserting a new Course Offering Schedule with a Time Block
                if (courseOfferingSchedule.Start_Time__c == null) { // TODO: This is repeated logic from above and can be refactored.
                    courseOfferingSchedule.Start_Time__c = timeBlock.Start_Time__c;
                }

                if (courseOfferingSchedule.End_Time__c == null) {
                    courseOfferingSchedule.End_Time__c = timeBlock.End_Time__c;
                }
            }

            // Do the Course Offering Schedule Start Time and End Time fields match the Time Block? If not, we have a problem.
            if (courseOfferingSchedule.Start_Time__c != timeBlock.Start_Time__c) {
                courseOfferingSchedule.Start_Time__c.addError(Label.timeBlockStartTimeMismatch);
            }

            if (courseOfferingSchedule.End_Time__c != timeBlock.End_Time__c) {
                courseOfferingSchedule.End_Time__c.addError(Label.timeBlockEndTimeMismatch);
            }
        }

        return dmlWrapper;
    }
}