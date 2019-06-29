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
public with sharing class TB_StartEndTime_TDTM extends TDTM_Runnable {

    @testVisible
    private static Boolean reentrancyPrevented;
    
    /*******************************************************************************************************
    * @description Iterates over all Time Block records TBD
    * @param newList the list of Time Blocks from trigger new.
    * @param oldList the list of Time Blocks from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Time Block.
    * @return dmlWrapper TBD
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
        Set<Id> timeBlocksWithUpdatedTimes = new Set<Id>();

        // Loop through all Time Blocks and determine if there are any where the Start Time and/or End Time is changing.
        for (Time_Block__c timeBlock : timeBlocksMap.values()) {
            Time_Block__c oldTimeBlock = oldTimeBlocksMap.get(timeBlock.Id);

            // This shouldn't ever happen, but check it just to be safe.
            if (oldTimeBlock == null) {
                continue;
            }

            if (timeBlock.Start_Time__c != oldTimeBlock.Start_Time__c || timeBlock.End_Time__c != oldTimeBlock.End_Time__c) {
                timeBlocksWithUpdatedTimes.add(timeBlock.Id);
            }
        }

        // Do we need to do anything?
        if (timeBlocksWithUpdatedTimes.size() == 0) {
            return dmlWrapper;
        }

        // Query for all related Course Offering Schedules and update their Start Time and/or End Times if they are blank or 
        // if they were previously aligned with the Time Block's Start Time and End Time.
        List<Course_Offering_Schedule__c> courseOfferingSchedules = [SELECT Start_Time__c, 
                                                                            End_Time__c, 
                                                                            Time_Block__c 
                                                                       FROM Course_Offering_Schedule__c 
                                                                      WHERE Time_Block__c IN :timeBlocksWithUpdatedTimes];

        List<Course_Offering_Schedule__c> courseOfferingSchedulesToUpdate = new List<Course_Offering_Schedule__c>();
        
        for (Course_Offering_Schedule__c courseOfferingSchedule : courseOfferingSchedules) {
            Time_Block__c timeBlock = timeBlocksMap.get(courseOfferingSchedule.Time_Block__c);
            Time_Block__c oldTimeBlock = oldTimeBlocksMap.get(courseOfferingSchedule.Time_Block__c);

            // This shouldn't ever happen, but check it just to be safe.
            if (timeBlock == null || oldTimeBlock == null) {
                continue;
            }

            // Does the Course Offering Schedule Start Time and End Time align with the previous Time Block Start Time and End Time?
            // It should because we have TDTM logic that prevents this from happening.
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

        dmlWrapper.objectsToUpdate.addAll((List<SObject>)courseOfferingSchedulesToUpdate);
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.TB_StartEndTime_TDTM, true);
        TDTM_TriggerHandler.processDML(dmlWrapper, true);
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.TB_StartEndTime_TDTM, false);
        dmlWrapper = null;

        return dmlWrapper;
    }
}