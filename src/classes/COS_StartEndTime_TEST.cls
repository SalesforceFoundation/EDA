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
* @description Tests specific to testing the COS_StartEndTime_TDTM logic around setting the Start Time 
* and End Time on the Course Offering Schedule record based on the associated Time Block record.
*/
@isTest
private class COS_StartEndTime_TEST {
    
    private static Course_Offering__c courseOffering;
    private static Course_Offering_Schedule__c courseOfferingSchedule;
    private static Time_Block__c timeBlock;

    private static Time startTime = Time.newInstance(8, 0, 0, 0);
    private static Time endTime = Time.newInstance(10, 0, 0, 0);

    /*******************************************************************************************************
    * @description Inserts a Course Offering and Time Block record for testing. Instantiates a new
    * Course Offering Schedule record but does not insert it.
    ********************************************************************************************************/
    private static void setup() {
        courseOffering = UTIL_UnitTestData_TEST.createCourseOffering(null, null);
        timeBlock = UTIL_UnitTestData_TEST.createTimeBlock(startTime, endTime);

        courseOfferingSchedule = new Course_Offering_Schedule__c(Course_Offering__c = courseOffering.Id);
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
    * @description Tests that when the Time Block lookup field is set on insert of a Course Offering Schedule,
    * the Start Time and End Time are sync'd from the Time Block's Start Time and End Time.
    ********************************************************************************************************/
    @isTest
    private static void setTimeBlockOnInsert() {
        setup();

        Test.startTest();
        courseOfferingSchedule.Time_Block__c = timeBlock.Id;
        insert courseOfferingSchedule;
        Test.stopTest();

        assertTimes(startTime, endTime);
    }

    /*******************************************************************************************************
    * @description Tests that when the Time Block lookup field is set on update of a Course Offering Schedule,
    * the Start Time and End Time are sync'd from the Time Block's Start Time and End Time.
    ********************************************************************************************************/
    @isTest
    private static void setTimeBlockOnUpdate() {
        setup();

        insert courseOfferingSchedule;
        assertTimes(null, null);

        Test.startTest();
        courseOfferingSchedule.Time_Block__c = timeBlock.Id;
        update courseOfferingSchedule;
        Test.stopTest();

        assertTimes(startTime, endTime);
    }

    /*******************************************************************************************************
    * @description Tests that an error is thrown when the Time Block lookup field is set on insert of a 
    * Course Offering Schedule and the Start Time on the Course Offering Schedule does not match the Time 
    * Block's Start Time.
    ********************************************************************************************************/
    @isTest
    private static void setTimeBlockOnInsertWithDifferentStartTimeThrowsError() {
        setup();
        Boolean exceptionCaught = false;

        Test.startTest();
        courseOfferingSchedule.Start_Time__c = Time.newInstance(3, 0, 0, 0);
        courseOfferingSchedule.Time_Block__c = timeBlock.Id;
        try {
            insert courseOfferingSchedule;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(Label.timeBlockStartTimeMismatch));
            exceptionCaught = true;
        }
        Test.stopTest();

        System.assert(exceptionCaught, 'Expected the insert to fail due to mismatching Start Times.');
    }

    /*******************************************************************************************************
    * @description Tests that an error is thrown when the Time Block lookup field is set on insert of a 
    * Course Offering Schedule and the End Time on the Course Offering Schedule does not match the Time 
    * Block's End Time.
    ********************************************************************************************************/
    @isTest
    private static void setTimeBlockOnInsertWithDifferentEndTimeThrowsError() {
        setup();
        Boolean exceptionCaught = false;

        Test.startTest();
        courseOfferingSchedule.End_Time__c = Time.newInstance(5, 0, 0, 0);
        courseOfferingSchedule.Time_Block__c = timeBlock.Id;
        try {
            insert courseOfferingSchedule;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(Label.timeBlockEndTimeMismatch));
            exceptionCaught = true;
        }
        Test.stopTest();

        System.assert(exceptionCaught, 'Expected the insert to fail due to mismatching End Times.');
    }

    /*******************************************************************************************************
    * @description Tests that an error is thrown when the Time Block lookup field is set on insert of a 
    * Course Offering Schedule and the Start Time and End Time on the Course Offering Schedule do not match 
    * the Time Block's Start Time and End Time.
    ********************************************************************************************************/
    @isTest
    private static void setTimeBlockOnUpdateWithExistingStartEndTimesThrowsError() {
        setup();
        Boolean exceptionCaught = false;

        courseOfferingSchedule.Start_Time__c = Time.newInstance(3, 0, 0, 0);
        courseOfferingSchedule.End_Time__c = Time.newInstance(5, 0, 0, 0);
        insert courseOfferingSchedule;
        assertTimes(Time.newInstance(3, 0, 0, 0), Time.newInstance(5, 0, 0, 0));

        Test.startTest();
        courseOfferingSchedule.Time_Block__c = timeBlock.Id;
        try {
            update courseOfferingSchedule;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(Label.timeBlockStartTimeMismatch));
            exceptionCaught = true;
        }
        Test.stopTest();

        System.assert(exceptionCaught, 'Expected the update to fail due to mismatching Start and End Times.');
    }

    /*******************************************************************************************************
    * @description Tests that when the Time Block lookup field is swapped for another Time Block record on 
    * update of a Course Offering Schedule, the Start Time and End Time are sync'd from the new Time Block's 
    * Start Time and End Time.
    ********************************************************************************************************/
    @isTest
    private static void swapTimeBlockOnUpdate() {
        setup();

        courseOfferingSchedule.Time_Block__c = timeBlock.Id;
        insert courseOfferingSchedule;
        assertTimes(startTime, endTime);

        Time_Block__c newTimeBlock = new Time_Block__c(Start_Time__c = Time.newInstance(3, 0, 0, 0), End_Time__c = Time.newInstance(5, 0, 0, 0));
        insert newTimeBlock;

        Test.startTest();
        // Assign a new Time Block to the Course Offering Schedule
        courseOfferingSchedule.Time_Block__c = newTimeBlock.Id;
        update courseOfferingSchedule;
        Test.stopTest();

        // Since the Time Block was updated, the Start Time and End Time on the Course Offering Schedule should be updated too.
        assertTimes(Time.newInstance(3, 0, 0, 0), Time.newInstance(5, 0, 0, 0));
    }
}