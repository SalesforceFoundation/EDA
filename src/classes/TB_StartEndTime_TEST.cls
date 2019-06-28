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
* @description Tests specific to testing the logic around TBD
*/
@isTest
private class TB_StartEndTime_TEST {
    // TODO - finish these. ApexDocs for all methods!

    private static Course_Offering__c courseOffering;
    private static Course_Offering_Schedule__c courseOfferingSchedule;
    private static Time_Block__c timeBlock;

    private static Time startTime = Time.newInstance(8, 0, 0, 0);
    private static Time endTime = Time.newInstance(10, 0, 0, 0);

    private static void setup(Time sTime, Time eTime) {
        // TODO: Move all of this to UTIL_UnitTestData_TEST?
        Account acct = UTIL_UnitTestData_API.getMultipleTestAccounts(1, UTIL_Describe_API.getAdminAccRecTypeID())[0];
        insert acct;

        Term__c term = new Term__c(Name = '2019-2020 School Year', Account__c = acct.Id);
        insert term;

        Course__c course = new Course__c(Name = 'ECON 101', Account__c = acct.Id);
        insert course;

        courseOffering = new Course_Offering__c(Name = 'ECON-101-19-01', Course__c = course.Id, Term__c = term.Id);
        insert courseOffering;

        timeBlock = new Time_Block__c(Start_Time__c = sTime, End_Time__c = eTime);
        insert timeBlock;

        courseOfferingSchedule = new Course_Offering_Schedule__c(Course_Offering__c = courseOffering.Id, Time_Block__c = timeBlock.Id);
        insert courseOfferingSchedule;
    }

    private static void assertTimes(Time expectedStartTime, Time expectedEndTime) {
        Course_Offering_Schedule__c queriedCourseOfferingSchedule = [SELECT Start_Time__c, End_Time__c FROM Course_Offering_Schedule__c WHERE Id = :courseOfferingSchedule.Id];
        System.assertEquals(expectedStartTime, queriedCourseOfferingSchedule.Start_Time__c, 'The Course Offering Schedule Start Time was not set as expected.');
        System.assertEquals(expectedEndTime, queriedCourseOfferingSchedule.End_Time__c, 'The Course Offering Schedule End Time was not set as expected.');
    }

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
    }

    // TODO: Reentrancy Prevented
}