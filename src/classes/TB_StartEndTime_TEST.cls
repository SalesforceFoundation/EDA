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
* @description Tests specific to testing the TB_StartEndTime_TDTM logic around updating the Start Time 
* and End Time on associated Course Offering Schedule records when the Time Block Start Time and/or
* End Time is updated.
*/
@isTest
private class TB_StartEndTime_TEST {
    
    private static Course_Offering__c courseOffering;
    private static Course_Offering_Schedule__c courseOfferingSchedule;
    private static Time_Block__c timeBlock;

    private static Time startTime = Time.newInstance(8, 0, 0, 0);
    private static Time endTime = Time.newInstance(10, 0, 0, 0);

    /*******************************************************************************************************
    * @description Inserts a Course Offering and Time Block record for testing. Instantiates a new
    * Course Offering Schedule record but does not insert it.
    * @param sTime The Start Time for the Time Block.
    * @param eTime The End Time for the Time Block.
    ********************************************************************************************************/
    private static void setup(Time sTime, Time eTime) {
        courseOffering = UTIL_UnitTestData_TEST.createCourseOffering(null, null);
        timeBlock = UTIL_UnitTestData_TEST.createTimeBlock(sTime, eTime);

        courseOfferingSchedule = new Course_Offering_Schedule__c(Course_Offering__c = courseOffering.Id, Time_Block__c = timeBlock.Id);
        insert courseOfferingSchedule;
    }

    /*******************************************************************************************************
    * @description Asserts that the given Start Time and End Time match the Start Time and End Time on the
    * Course Offering Schedule test record.
    * @param expectedStartTime The expected Start Time.
    * @param expectedEndTime The expected End Time.
    ********************************************************************************************************/
    private static void assertTimes(Time expectedStartTime, Time expectedEndTime) {
        Course_Offering_Schedule__c queriedCourseOfferingSchedule = [SELECT Start_Time__c, End_Time__c FROM Course_Offering_Schedule__c WHERE Id = :courseOfferingSchedule.Id];
        System.assertEquals(expectedStartTime, queriedCourseOfferingSchedule.Start_Time__c, 'The Course Offering Schedule Start Time was not set as expected.');
        System.assertEquals(expectedEndTime, queriedCourseOfferingSchedule.End_Time__c, 'The Course Offering Schedule End Time was not set as expected.');
    }

    /*******************************************************************************************************
    * @description Tests that when the Time Block's Start Time is changed, any Course Offering Schedule tied
    * to that Time Block record is also updated with the new Start Time.
    ********************************************************************************************************/
    @isTest
    private static void updateTimeBlockStartTimeUpdatesCourseOfferingSchedules() {
        setup(null, null);

        assertTimes(null, null);

        Test.startTest();
        timeBlock.Start_Time__c = Time.newInstance(3, 0, 0, 0);
        update timeBlock;
        Test.stopTest();

        assertTimes(Time.newInstance(3, 0, 0, 0), null);
    }

    /*******************************************************************************************************
    * @description Tests that when the Time Block's End Time is changed, any Course Offering Schedule tied
    * to that Time Block record is also updated with the new End Time.
    ********************************************************************************************************/
    @isTest
    private static void updateTimeBlockEndTimeUpdatesCourseOfferingSchedules() {
        setup(null, null);

        assertTimes(null, null);

        Test.startTest();
        timeBlock.End_Time__c = Time.newInstance(3, 0, 0, 0);
        update timeBlock;
        Test.stopTest();

        assertTimes(null, Time.newInstance(3, 0, 0, 0));
    }

    /*******************************************************************************************************
    * @description Tests that when the Time Block's Start Time and End Time is changed, any Course Offering 
    * Schedule tied to that Time Block record is also updated with the new Start Time and End Time.
    ********************************************************************************************************/
    @isTest
    private static void updateTimeBlockTimesUpdatesCourseOfferingSchedules() {
        setup(startTime, endTime);

        assertTimes(startTime, endTime);

        Test.startTest();
        timeBlock.Start_Time__c = Time.newInstance(1, 0, 0, 0);
        timeBlock.End_Time__c = Time.newInstance(3, 0, 0, 0);
        update timeBlock;
        Test.stopTest();

        assertTimes(Time.newInstance(1, 0, 0, 0), Time.newInstance(3, 0, 0, 0));

        System.assert(TB_StartEndTime_TDTM.reentrancyPrevented != true, 
            'Did not expect the reentrancy check to have prevented the TB_StartEndTime_TDTM trigger from processing again.');
    }

    /*******************************************************************************************************
    * @description Tests that when the Time Block update causes Course Offering Schedules to update, any 
    * custom logic that might recursively update Time Block records does not run the Time Block TDTM logic
    * again. Reentrancy into the TB_StartEndTime_TDTM class is prevented.
    ********************************************************************************************************/
    @isTest
    private static void updateTimeBlockTimesUpdatesCourseOfferingSchedulesReentrancyCheck() {
        // Install Default EDA TDTM Configuration
        List<TDTM_Global_API.TdtmToken> defaultTokens = TDTM_Global_API.getDefaultTdtmConfig();
        TDTM_Global_API.setTdtmConfig(defaultTokens, 'hed');

        // Add the Test TDTM for the Course Offering Schedule object. This Test TDTM will simply 
        // update the Time Block that caused the Course Offering Schedule to be updated.
        // So the flow would be: Time Block updated -> Course Offering Schedule updated -> Time Block updated again
        Trigger_Handler__c newTDTM = new Trigger_Handler__c(Active__c = true, Asynchronous__c = false,
            Class__c = 'UTIL_UnitTestData_TEST.Test_TDTM', Load_Order__c = 1, Object__c = 'Course_Offering_Schedule__c',
            Owned_by_Namespace__c = 'hed', Trigger_Action__c = 'AfterUpdate');
        insert newTDTM;
        
        setup(startTime, endTime);
        assertTimes(startTime, endTime);

        Test.startTest();
        timeBlock.Start_Time__c = Time.newInstance(1, 0, 0, 0);
        timeBlock.End_Time__c = Time.newInstance(3, 0, 0, 0);

        // Ensure that the Time Block gets updated recursively
        UTIL_UnitTestData_TEST.sObjectsToUpdate = new List<SObject>{ timeBlock };

        update timeBlock;
        Test.stopTest();

        assertTimes(Time.newInstance(1, 0, 0, 0), Time.newInstance(3, 0, 0, 0));

        System.assert(TB_StartEndTime_TDTM.reentrancyPrevented == true, 
            'Expected the reentrancy check to have prevented the TB_StartEndTime_TDTM trigger from processing again.');
    }
}