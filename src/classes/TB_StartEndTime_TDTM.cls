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
* @description Updates associated Course Offering Schedules' Start Time and End Time fields when the Start Time
* and/or End Time fields are updated on the Time Block.
*/
public with sharing class TB_StartEndTime_TDTM extends TDTM_Runnable {

    @testVisible
    private static Boolean reentrancyPrevented;
    
    /*******************************************************************************************************
    * @description Iterates over all Time Block records and updates associated Course Offering Schedules'
    * Start Time and End Time fields when the Start Time and/or End Time fields are updated on the Time Block.
    * @param newList the list of Time Blocks from trigger new.
    * @param oldList the list of Time Blocks from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Time Block.
    * @return dmlWrapper A null or empty dmlWrapper, since this TDTM class does its own DML processing.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newList, List<SObject> oldList,
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        DmlWrapper dmlWrapper = new DmlWrapper();

        // Exit early if this trigger is currently running.
        if (TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.TB_StartEndTime_TDTM)) {
            reentrancyPrevented = true;
            return dmlWrapper;
        }

        // This only runs on after update, but check just to be safe, as well as our parameters.
        if (triggerAction != TDTM_Runnable.Action.AfterUpdate || newList == null || newList.size() == 0 || oldList == null || oldList.size() == 0) {
            return dmlWrapper;
        }

        Map<Id, Time_Block__c> timeBlocksMap = new Map<Id, Time_Block__c>((List<Time_Block__c>)newList);
        Map<Id, Time_Block__c> oldTimeBlocksMap = new Map<Id, Time_Block__c>((List<Time_Block__c>)oldList);

        // Get all Time Blocks where the Start Time and/or End Time is changing.
        Set<Id> timeBlocksWithUpdatedTimes = getTimeBlocksWithUpdatedTimes(timeBlocksMap.values(), oldTimeBlocksMap);

        // Exit if there are no Time Blocks with times changing.
        if (timeBlocksWithUpdatedTimes.size() == 0) {
            return dmlWrapper;
        }

        // For the Time Blocks with times changing, update their associated Course Offering Schedules.
        List<Course_Offering_Schedule__c> courseOfferingSchedulesToUpdate = getCourseOfferingSchedulesToUpdate(timeBlocksWithUpdatedTimes, timeBlocksMap, oldTimeBlocksMap);

        dmlWrapper.objectsToUpdate.addAll((List<SObject>)courseOfferingSchedulesToUpdate);
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.TB_StartEndTime_TDTM, true);
        TDTM_TriggerHandler.processDML(dmlWrapper, true);
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.TB_StartEndTime_TDTM, false);
        dmlWrapper = null;

        return dmlWrapper;
    }

    /*******************************************************************************************************
    * @description Iterates over the Time Blocks and determines which ones have an updated Start Time and/or 
    * End Time.
    * @param timeBlocks The updated Time Blocks.
    * @param oldTimeBlocksMap The map of old Time Block records prior to the update.
    * @return The Set of Time Block IDs that have an updated Start Time and/or End Time.
    ********************************************************************************************************/
    private Set<Id> getTimeBlocksWithUpdatedTimes(List<Time_Block__c> timeBlocks, Map<Id, Time_Block__c> oldTimeBlocksMap) {
        Set<Id> timeBlocksWithUpdatedTimes = new Set<Id>();

        // Loop through all Time Blocks and determine if there are any where the Start Time and/or End Time is changing.
        for (Time_Block__c timeBlock : timeBlocks) {
            Time_Block__c oldTimeBlock = oldTimeBlocksMap.get(timeBlock.Id);

            // This shouldn't ever happen, but check it just to be safe.
            if (oldTimeBlock == null) {
                continue;
            }

            if (timeBlock.Start_Time__c != oldTimeBlock.Start_Time__c || timeBlock.End_Time__c != oldTimeBlock.End_Time__c) {
                timeBlocksWithUpdatedTimes.add(timeBlock.Id);
            }
        }

        return timeBlocksWithUpdatedTimes;
    }

    /*******************************************************************************************************
    * @description Queries for Course Offering Schedules related to the Time Blocks that have an updated
    * Start Time and/or End Time and updates the Start Time and End Time on the Course Offering Schedules to
    * match the new values.
    * @param timeBlocksWithUpdatedTimes The Set of Time Block IDs that have an updated Start Time and/or End Time.
    * @param timeBlocksMap The map of updated Time Blocks.
    * @param oldTimeBlocksMap The map of old Time Block records prior to the update.
    * @return The updated Course Offering Schedules.
    ********************************************************************************************************/
    private List<Course_Offering_Schedule__c> getCourseOfferingSchedulesToUpdate(Set<Id> timeBlocksWithUpdatedTimes, Map<Id, Time_Block__c> timeBlocksMap, Map<Id, Time_Block__c> oldTimeBlocksMap) {
        List<Course_Offering_Schedule__c> courseOfferingSchedulesToUpdate = new List<Course_Offering_Schedule__c>();

        // Query for all related Course Offering Schedules.
        List<Course_Offering_Schedule__c> courseOfferingSchedules = [SELECT Start_Time__c, 
                                                                            End_Time__c, 
                                                                            Time_Block__c 
                                                                       FROM Course_Offering_Schedule__c 
                                                                      WHERE Time_Block__c IN :timeBlocksWithUpdatedTimes];
        
        for (Course_Offering_Schedule__c courseOfferingSchedule : courseOfferingSchedules) {
            Time_Block__c timeBlock = timeBlocksMap.get(courseOfferingSchedule.Time_Block__c);
            Time_Block__c oldTimeBlock = oldTimeBlocksMap.get(courseOfferingSchedule.Time_Block__c);

            // This shouldn't ever happen, but check it just to be safe.
            if (timeBlock == null || oldTimeBlock == null) {
                continue;
            }

            // Does the Course Offering Schedule Start Time and End Time align with the previous Time Block Start Time and End Time?
            // It should because we have TDTM logic that prevents this from happening. If so, update the Course Offering Schedule to
            // match the new values.
            Boolean updated = false;
            if (courseOfferingSchedule.Start_Time__c == null || courseOfferingSchedule.Start_Time__c == oldTimeBlock.Start_Time__c) {
                courseOfferingSchedule.Start_Time__c = timeBlock.Start_Time__c;
                updated = true;
            }

            if (courseOfferingSchedule.End_Time__c == null || courseOfferingSchedule.End_Time__c == oldTimeBlock.End_Time__c) {
                courseOfferingSchedule.End_Time__c = timeBlock.End_Time__c;
                updated = true;
            }

            if (updated) {
                courseOfferingSchedulesToUpdate.add(courseOfferingSchedule);
            }
        }

        return courseOfferingSchedulesToUpdate;
    }
}