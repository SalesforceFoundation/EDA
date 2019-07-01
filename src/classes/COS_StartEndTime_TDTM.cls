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
* @description Syncs the Start Time and End Time from the associated Time Block record on insert and update
* of Course Offering Schedule records. Throws an error if the times on the Course Offering Schedule do not
* match the times on the Time Block.
*/
public with sharing class COS_StartEndTime_TDTM extends TDTM_Runnable {

    /*******************************************************************************************************
    * @description Iterates over all Course Offering Schedule records and syncs the Start Time and End Time
    * from the associated Time Block record. Throws errors if the times on the Course Offering Schedule do
    * not match the times on the Time Block.
    * @param newList the list of Course Offering Schedules from trigger new.
    * @param oldList the list of Course Offering Schedules from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Course Offering Schedule.
    * @return dmlWrapper A null or empty dmlWrapper, since this TDTM class does its own DML processing in a
    * before insert or before update context.
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

        Set<Id> timeBlockIdsToQuery = new Set<Id>();
        List<Course_Offering_Schedule__c> courseOfferingSchedulesToValidate = new List<Course_Offering_Schedule__c>();

        // Loop over the Course Offering Schedules - if there is a Time Block, we'll query the Time Block later to verify the times are valid,
        // and to flow down the times to the Course Offering Schedule if necessary. We'll also do this if the Time Block lookup field is swapped.
        for (Course_Offering_Schedule__c courseOfferingSchedule : courseOfferingSchedules) {
            
            // We don't need to flow down any times or do any validation if there is no Time Block.
            if (courseOfferingSchedule.Time_Block__c == null) {
                continue;
            }

            timeBlockIdsToQuery.add(courseOfferingSchedule.Time_Block__c);
            courseOfferingSchedulesToValidate.add(courseOfferingSchedule);

            if (isUpdateContext) {
                Course_Offering_Schedule__c oldCourseOfferingSchedule = oldCourseOfferingSchedulesMap.get(courseOfferingSchedule.Id);

                // Is the Time Block changing? We'll need to grab the Start and End Times from both Time Block records before we update the
                // Start and End Times on the Course Offering Schedule.
                if (oldCourseOfferingSchedule != null && oldCourseOfferingSchedule.Time_Block__c != courseOfferingSchedule.Time_Block__c) {
                    timeBlockIdsToQuery.add(oldCourseOfferingSchedule.Time_Block__c);
                }
            }
        }

        // Exit early if there are no Course Offering Schedules to validate.
        if (courseOfferingSchedulesToValidate.size() == 0) {
            return dmlWrapper;
        }

        // Query the Time Blocks to verify the times are valid and flow down the times to the Course Offering Schedules if necessary.
        validateCourseOfferingSchedules(timeBlockIdsToQuery, courseOfferingSchedulesToValidate, oldCourseOfferingSchedulesMap, isUpdateContext);

        return dmlWrapper;
    }

    /*******************************************************************************************************
    * @description Queries for Time Blocks related to the Course Offering Schedules to validate. The times
    * from these Time Block records are then flowed down to the Course Offering Schedules. An error is thrown
    * if the times on the Course Offering Schedule do not match the times on the Time Block.
    * @param timeBlockIdsToQuery The Set of Time Block IDs that should be queried.
    * @param courseOfferingSchedulesToValidate The list of Course Offering Schedule records to validate and
    * flow times down to.
    * @param oldCourseOfferingSchedulesMap The map of old Course Offering Schedule records prior to the update,
    * if in an update context.
    * @param isUpdateContext True if the trigger is currently executing in a BeforeUpdate context.
    ********************************************************************************************************/
    private void validateCourseOfferingSchedules(Set<Id> timeBlockIdsToQuery, List<Course_Offering_Schedule__c> courseOfferingSchedulesToValidate, 
            Map<Id, Course_Offering_Schedule__c> oldCourseOfferingSchedulesMap, Boolean isUpdateContext) {

        Map<Id, Time_Block__c> timeBlocksMap = new Map<Id, Time_Block__c>([SELECT Start_Time__c, 
                                                                                  End_Time__c 
                                                                             FROM Time_Block__c WHERE Id IN :timeBlockIdsToQuery]);

        for (Course_Offering_Schedule__c courseOfferingSchedule : courseOfferingSchedulesToValidate) {
            Time_Block__c timeBlock = timeBlocksMap.get(courseOfferingSchedule.Time_Block__c);
            if (timeBlock == null) {
                continue;
            }

            // We're updating an existing Course Offering Schedule
            if (isUpdateContext) {
                Course_Offering_Schedule__c oldCourseOfferingSchedule = oldCourseOfferingSchedulesMap.get(courseOfferingSchedule.Id);
                Time_Block__c oldTimeBlock = timeBlocksMap.get(oldCourseOfferingSchedule.Time_Block__c);

                // We're swapping a Time Block for another Time Block
                if (oldTimeBlock != null && oldTimeBlock.Id != timeBlock.Id) {
                    
                    // Does the Start Time and End Time on the Course Offering Schedule match the values on the old Time Block? If so, 
                    // swap them with the new values.
                    if (courseOfferingSchedule.Start_Time__c == oldTimeBlock.Start_Time__c 
                            && courseOfferingSchedule.End_Time__c == oldTimeBlock.End_Time__c) {
                        courseOfferingSchedule.Start_Time__c = timeBlock.Start_Time__c;
                        courseOfferingSchedule.End_Time__c = timeBlock.End_Time__c;
                    }

                } 
                
                // We're updating an existing Course Offering Schedule and setting the Time Block
                else if (oldTimeBlock == null) {
                    updateCourseOfferingScheduleTimes(courseOfferingSchedule, timeBlock);
                }
            } 
            
            // We're inserting a new Course Offering Schedule with a Time Block
            else {
                updateCourseOfferingScheduleTimes(courseOfferingSchedule, timeBlock);
            }

            validateCourseOfferingScheduleTimes(courseOfferingSchedule, timeBlock);
        }
    }

    /*******************************************************************************************************
    * @description Compares the Start Time and End Time on the Course Offering Schedule to the Start Time and
    * End Time on the Time Block. If they do not match, an error is added to the Course Offering Schedule.
    * @param courseOfferingSchedule The Course Offering Schedule record to validate.
    * @param timeBlock The Time Block record.
    ********************************************************************************************************/
    private void validateCourseOfferingScheduleTimes(Course_Offering_Schedule__c courseOfferingSchedule, Time_Block__c timeBlock) {
        if (courseOfferingSchedule.Start_Time__c != timeBlock.Start_Time__c) {
            courseOfferingSchedule.Start_Time__c.addError(Label.timeBlockStartTimeMismatch);
        }

        if (courseOfferingSchedule.End_Time__c != timeBlock.End_Time__c) {
            courseOfferingSchedule.End_Time__c.addError(Label.timeBlockEndTimeMismatch);
        }
    }

    /*******************************************************************************************************
    * @description Updates the Start Time and End Time on the Course Offering Schedule to the Start Time and 
    * End Time on the Time Block if they are not currently set.
    * @param courseOfferingSchedule The Course Offering Schedule record to update.
    * @param timeBlock The Time Block record.
    ********************************************************************************************************/
    private void updateCourseOfferingScheduleTimes(Course_Offering_Schedule__c courseOfferingSchedule, Time_Block__c timeBlock) {
        if (courseOfferingSchedule.Start_Time__c == null) {
            courseOfferingSchedule.Start_Time__c = timeBlock.Start_Time__c;
        }

        if (courseOfferingSchedule.End_Time__c == null) {
            courseOfferingSchedule.End_Time__c = timeBlock.End_Time__c;
        }
    }
}