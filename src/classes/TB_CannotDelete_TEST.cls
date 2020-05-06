/*
    Copyright (c) 2020, Salesforce.org
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
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER s
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2020
* @group Time Blocks
* @group-content ../../ApexDocContent/TimeBlocks.htm
* @description Tests for TB_CannotDelete_TDTM.
*/

@isTest
private class TB_CannotDelete_TEST {

    /*********************************************************************************************************
    * @description Retrieves the record type Ids for Household and Administrator Accounts. 
    */
    public static String deptAccRecordTypeID = UTIL_Describe.getDepAccRecTypeID(); 

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Time_Block_Deletion__c is enabled in Hierarchy 
    * Settings and Time Block has a child Course Offering record associated with it, the Time Block 
    * record cannot be deleted.
    */
    @isTest 
    private static void cannotDeleteWithChildCourseOfferingPreventDeleteOn() {

        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Prevent_Time_Block_Deletion__c = TRUE));

        Time startTime = Time.newInstance(8, 0, 0, 0);
        Time stopTime = Time.newInstance(10, 0, 0, 0);

        List<Time_Block__c> timeBlocks = new List<Time_Block__c>();

        for (Integer index = 0; index < 5; index++){
            timeBlocks.add(UTIL_UnitTestData_TEST.createTimeBlock(startTime, stopTime));
        }

        List<Account> departmentAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, TB_CannotDelete_TEST.deptAccRecordTypeID);
        insert departmentAccounts;

        Term__c testTerm = UTIL_UnitTestData_TEST.getTerm(departmentAccounts[0].Id, 'Test Term');
        insert testTerm;

        Course__c testCourse = new Course__c(Name = 'Test Course', Account__c = departmentAccounts[0].Id);
        insert testCourse;

        List<Course_Offering__c> courseOfferings = new List<Course_Offering__c>();
        for (Integer index = 0; index < 5; index++){
            courseOfferings.add(UTIL_UnitTestData_TEST.createCourseOffering(testCourse.Id, testTerm.Id));
        }

        for (Integer index = 0; index < 5; index++){
            courseOfferings[index].Time_Block__c = timeBlocks[index].Id;
        }
        update courseOfferings;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(timeBlocks, FALSE);
        Test.stopTest();

        List<Time_Block__c> returnTimeBlocks = [
            SELECT Id
            FROM Time_Block__c
            WHERE Id IN :timeBlocks
        ];

        System.assertEquals(timeBlocks.size(), returnTimeBlocks.size());
        
        for (Database.DeleteResult result : results) {
            System.assertEquals(Label.CannotDelete, result.errors[0].message);
        }
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Time_Block_Deletion__c is enabled in Hierarchy 
    * Settings and Time Block has a child Course Offering Schedule record associated with it, the Time Block 
    * record cannot be deleted.
    */
    @isTest 
    private static void cannotDeleteWithChildCourseOfferingSchedulePreventDeleteOn() {

        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Prevent_Time_Block_Deletion__c = TRUE));

        Time startTime = Time.newInstance(8, 0, 0, 0);
        Time stopTime = Time.newInstance(10, 0, 0, 0);

        List<Time_Block__c> timeBlocks = new List<Time_Block__c>();

        for (Integer index = 0; index < 5; index++){
            timeBlocks.add(UTIL_UnitTestData_TEST.createTimeBlock(startTime, stopTime));
        }

        List<Account> departmentAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, TB_CannotDelete_TEST.deptAccRecordTypeID);
        insert departmentAccounts;

        Term__c testTerm = UTIL_UnitTestData_TEST.getTerm(departmentAccounts[0].Id, 'Test Term');
        insert testTerm;

        Course__c testCourse = new Course__c(Name = 'Test Course', Account__c = departmentAccounts[0].Id);
        insert testCourse;

        List<Course_Offering__c> courseOfferings = new List<Course_Offering__c>();
        for (Integer index = 0; index < 5; index++){
            courseOfferings.add(UTIL_UnitTestData_TEST.createCourseOffering(testCourse.Id, testTerm.Id));
        }

        List<Course_Offering_Schedule__c> courseOfferingSchedules = new List<Course_Offering_Schedule__c>();
        for (Integer index = 0; index < 5; index++){
            courseOfferingSchedules.add(UTIL_UnitTestData_TEST.createCourseOfferingSchedule(courseOfferings[index].Id));
        }

        for (Integer index = 0; index < 5; index++){
            courseOfferingSchedules[index].Time_Block__c = timeBlocks[index].Id;
        }

        insert courseOfferingSchedules;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(timeBlocks, FALSE);
        Test.stopTest();

        List<Time_Block__c> returnTimeBlocks = [
            SELECT Id
            FROM Time_Block__c
            WHERE Id IN :timeBlocks
        ];

        System.assertEquals(timeBlocks.size(), returnTimeBlocks.size());
        
        for (Database.DeleteResult result : results) {
            System.assertEquals(Label.CannotDelete, result.errors[0].message);
        }
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Time_Block_Deletion__c is enabled in Hierarchy 
    * Settings and Time Block has both Course Offering and Course Offering Schedule child records associated 
    * with it, the Time Block record cannot be deleted.
    */
    @isTest 
    private static void cannotDeleteWithChildCourseOfferingAndScheduleRecordsPreventDeleteOn() {

        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Prevent_Time_Block_Deletion__c = TRUE));

        Time startTime = Time.newInstance(8, 0, 0, 0);
        Time stopTime = Time.newInstance(10, 0, 0, 0);

        List<Time_Block__c> timeBlocks = new List<Time_Block__c>();

        for (Integer index = 0; index < 5; index++){
            timeBlocks.add(UTIL_UnitTestData_TEST.createTimeBlock(startTime, stopTime));
        }

        List<Account> departmentAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, TB_CannotDelete_TEST.deptAccRecordTypeID);
        insert departmentAccounts;

        Term__c testTerm = UTIL_UnitTestData_TEST.getTerm(departmentAccounts[0].Id, 'Test Term');
        insert testTerm;

        Course__c testCourse = new Course__c(Name = 'Test Course', Account__c = departmentAccounts[0].Id);
        insert testCourse;

        List<Course_Offering__c> courseOfferings = new List<Course_Offering__c>();
        for (Integer index = 0; index < 5; index++){
            courseOfferings.add(UTIL_UnitTestData_TEST.createCourseOffering(testCourse.Id, testTerm.Id));
        }

        for (Integer index = 0; index < 5; index++){
            courseOfferings[index].Time_Block__c = timeBlocks[index].Id;
        }
        update courseOfferings;

        List<Course_Offering_Schedule__c> courseOfferingSchedules = new List<Course_Offering_Schedule__c>();
        for (Integer index = 0; index < 5; index++){
            courseOfferingSchedules.add(UTIL_UnitTestData_TEST.createCourseOfferingSchedule(courseOfferings[index].Id));
        }

        for (Integer index = 0; index < 5; index++){
            courseOfferingSchedules[index].Time_Block__c = timeBlocks[index].Id;
        }

        insert courseOfferingSchedules;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(timeBlocks, FALSE);
        Test.stopTest();

        List<Time_Block__c> returnTimeBlocks = [
            SELECT Id
            FROM Time_Block__c
            WHERE Id IN :timeBlocks
        ];

        System.assertEquals(timeBlocks.size(), returnTimeBlocks.size());
        
        for (Database.DeleteResult result : results) {
            System.assertEquals(Label.CannotDelete, result.errors[0].message);
        }
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Time_Block_Deletion__c is enabled in Hierarchy 
    * Settings and Time Block has no associated child records, the Time Block record can be deleted.
    */
    @isTest 
    private static void canDeleteWithoutChildRecordsPreventDeleteOn() {
        
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Prevent_Time_Block_Deletion__c = TRUE));

        Time startTime = Time.newInstance(8, 0, 0, 0);
        Time stopTime = Time.newInstance(10, 0, 0, 0);

        List<Time_Block__c> timeBlocks = new List<Time_Block__c>();

        for (Integer index = 0; index < 5; index++){
            timeBlocks.add(UTIL_UnitTestData_TEST.createTimeBlock(startTime, stopTime));
        }

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(timeBlocks, FALSE);
        Test.stopTest();

        List<Time_Block__c> returnTimeBlocks = [
            SELECT Id
            FROM Time_Block__c
            WHERE Id IN :timeBlocks
        ];

        System.assertEquals(TRUE, returnTimeBlocks.isEmpty());
        
        for (Database.DeleteResult result : results) {
            System.assertEquals(TRUE, result.isSuccess());
        }
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Time_Block_Deletion__c is disabled in Hierarchy 
    * Settings and Time Block has a child Course Offering record associated with it, the Time Block 
    * record can be deleted.
    */
    @isTest 
    private static void canDeleteWithChildCourseOfferingPreventDeleteOff() {

        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Prevent_Time_Block_Deletion__c = FALSE));

        Time startTime = Time.newInstance(8, 0, 0, 0);
        Time stopTime = Time.newInstance(10, 0, 0, 0);

        List<Time_Block__c> timeBlocks = new List<Time_Block__c>();

        for (Integer index = 0; index < 5; index++){
            timeBlocks.add(UTIL_UnitTestData_TEST.createTimeBlock(startTime, stopTime));
        }

        List<Account> departmentAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, TB_CannotDelete_TEST.deptAccRecordTypeID);
        insert departmentAccounts;

        Term__c testTerm = UTIL_UnitTestData_TEST.getTerm(departmentAccounts[0].Id, 'Test Term');
        insert testTerm;

        Course__c testCourse = new Course__c(Name = 'Test Course', Account__c = departmentAccounts[0].Id);
        insert testCourse;

        List<Course_Offering__c> courseOfferings = new List<Course_Offering__c>();
        for (Integer index = 0; index < 5; index++){
            courseOfferings.add(UTIL_UnitTestData_TEST.createCourseOffering(testCourse.Id, testTerm.Id));
        }

        for (Integer index = 0; index < 5; index++){
            courseOfferings[index].Time_Block__c = timeBlocks[index].Id;
        }
        update courseOfferings;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(timeBlocks, FALSE);
        Test.stopTest();

        List<Time_Block__c> returnTimeBlocks = [
            SELECT Id
            FROM Time_Block__c
            WHERE Id IN :timeBlocks
        ];

        System.assertEquals(TRUE, returnTimeBlocks.isEmpty());
        
        for (Database.DeleteResult result : results) {
            System.assertEquals(TRUE, result.isSuccess());
        }
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Time_Block_Deletion__c is disabled in Hierarchy 
    * Settings and Time Block has a child Course Offering Schedule record associated with it, the Time Block 
    * record can be deleted.
    */
    @isTest 
    private static void canDeleteWithChildCourseOfferingSchedulePreventDeleteOff() {
        
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Prevent_Time_Block_Deletion__c = FALSE));

        Time startTime = Time.newInstance(8, 0, 0, 0);
        Time stopTime = Time.newInstance(10, 0, 0, 0);

        List<Time_Block__c> timeBlocks = new List<Time_Block__c>();

        for (Integer index = 0; index < 5; index++){
            timeBlocks.add(UTIL_UnitTestData_TEST.createTimeBlock(startTime, stopTime));
        }

        List<Account> departmentAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, TB_CannotDelete_TEST.deptAccRecordTypeID);
        insert departmentAccounts;

        Term__c testTerm = UTIL_UnitTestData_TEST.getTerm(departmentAccounts[0].Id, 'Test Term');
        insert testTerm;

        Course__c testCourse = new Course__c(Name = 'Test Course', Account__c = departmentAccounts[0].Id);
        insert testCourse;

        List<Course_Offering__c> courseOfferings = new List<Course_Offering__c>();
        for (Integer index = 0; index < 5; index++){
            courseOfferings.add(UTIL_UnitTestData_TEST.createCourseOffering(testCourse.Id, testTerm.Id));
        }

        List<Course_Offering_Schedule__c> courseOfferingSchedules = new List<Course_Offering_Schedule__c>();
        for (Integer index = 0; index < 5; index++){
            courseOfferingSchedules.add(UTIL_UnitTestData_TEST.createCourseOfferingSchedule(courseOfferings[index].Id));
        }

        for (Integer index = 0; index < 5; index++){
            courseOfferingSchedules[index].Time_Block__c = timeBlocks[index].Id;
        }

        insert courseOfferingSchedules;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(timeBlocks, FALSE);
        Test.stopTest();

        List<Time_Block__c> returnTimeBlocks = [
            SELECT Id
            FROM Time_Block__c
            WHERE Id IN :timeBlocks
        ];

        System.assertEquals(TRUE, returnTimeBlocks.isEmpty());
        
        for (Database.DeleteResult result : results) {
            System.assertEquals(TRUE, result.isSuccess());
        }
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Time_Block_Deletion__c is disabled in Hierarchy 
    * Settings and Time Block has both Course Offering and Course Offering Schedule child records associated 
    * with it, the Time Block record can be deleted.
    */
    @isTest 
    private static void canDeleteWithChildCourseOfferingAndSchedulePreventDeleteOff() {
        
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Prevent_Time_Block_Deletion__c = FALSE));

        Time startTime = Time.newInstance(8, 0, 0, 0);
        Time stopTime = Time.newInstance(10, 0, 0, 0);

        List<Time_Block__c> timeBlocks = new List<Time_Block__c>();

        for (Integer index = 0; index < 5; index++){
            timeBlocks.add(UTIL_UnitTestData_TEST.createTimeBlock(startTime, stopTime));
        }

        List<Account> departmentAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, TB_CannotDelete_TEST.deptAccRecordTypeID);
        insert departmentAccounts;

        Term__c testTerm = UTIL_UnitTestData_TEST.getTerm(departmentAccounts[0].Id, 'Test Term');
        insert testTerm;

        Course__c testCourse = new Course__c(Name = 'Test Course', Account__c = departmentAccounts[0].Id);
        insert testCourse;

        List<Course_Offering__c> courseOfferings = new List<Course_Offering__c>();
        for (Integer index = 0; index < 5; index++){
            courseOfferings.add(UTIL_UnitTestData_TEST.createCourseOffering(testCourse.Id, testTerm.Id));
        }

        for (Integer index = 0; index < 5; index++){
            courseOfferings[index].Time_Block__c = timeBlocks[index].Id;
        }
        update courseOfferings;

        List<Course_Offering_Schedule__c> courseOfferingSchedules = new List<Course_Offering_Schedule__c>();
        for (Integer index = 0; index < 5; index++){
            courseOfferingSchedules.add(UTIL_UnitTestData_TEST.createCourseOfferingSchedule(courseOfferings[index].Id));
        }

        for (Integer index = 0; index < 5; index++){
            courseOfferingSchedules[index].Time_Block__c = timeBlocks[index].Id;
        }

        insert courseOfferingSchedules;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(timeBlocks, FALSE);
        Test.stopTest();

        List<Time_Block__c> returnTimeBlocks = [
            SELECT Id
            FROM Time_Block__c
            WHERE Id IN :timeBlocks
        ];

        System.assertEquals(TRUE, returnTimeBlocks.isEmpty());
        
        for (Database.DeleteResult result : results) {
            System.assertEquals(TRUE, result.isSuccess());
        }
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Time_Block_Deletion__c is disabled in Hierarchy 
    * Settings and Time Block has no associated child records, the Time Block record can be deleted.
    */
    @isTest 
    private static void canDeleteWithoutChildRecordsPreventDeleteOff() {
        
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Prevent_Time_Block_Deletion__c = FALSE));

        Time startTime = Time.newInstance(8, 0, 0, 0);
        Time stopTime = Time.newInstance(10, 0, 0, 0);

        List<Time_Block__c> timeBlocks = new List<Time_Block__c>();

        for (Integer index = 0; index < 5; index++){
            timeBlocks.add(UTIL_UnitTestData_TEST.createTimeBlock(startTime, stopTime));
        }

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(timeBlocks, FALSE);
        Test.stopTest();

        List<Time_Block__c> returnTimeBlocks = [
            SELECT Id
            FROM Time_Block__c
            WHERE Id IN :timeBlocks
        ];

        System.assertEquals(TRUE, returnTimeBlocks.isEmpty());
        
        for (Database.DeleteResult result : results) {
            System.assertEquals(TRUE, result.isSuccess());
        }
    }

    /*********************************************************************************************************
    * @description Test method for the hasChildRecords() method in TB_CannotDelete_TDTM to test that TRUE
    * is returned for a Time Block record with Course Offering child records.
    */
    @isTest 
    private static void hasCourseOfferingChildRecordsIsTrue() {
        
        Time startTime = Time.newInstance(8, 0, 0, 0);
        Time stopTime = Time.newInstance(10, 0, 0, 0);

        List<Time_Block__c> timeBlocks = new List<Time_Block__c>();

        for (Integer index = 0; index < 5; index++){
            timeBlocks.add(UTIL_UnitTestData_TEST.createTimeBlock(startTime, stopTime));
        }

        List<Account> departmentAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, TB_CannotDelete_TEST.deptAccRecordTypeID);
        insert departmentAccounts;

        Term__c testTerm = UTIL_UnitTestData_TEST.getTerm(departmentAccounts[0].Id, 'Test Term');
        insert testTerm;

        Course__c testCourse = new Course__c(Name = 'Test Course', Account__c = departmentAccounts[0].Id);
        insert testCourse;

        List<Course_Offering__c> courseOfferings = new List<Course_Offering__c>();
        for (Integer index = 0; index < 5; index++){
            courseOfferings.add(UTIL_UnitTestData_TEST.createCourseOffering(testCourse.Id, testTerm.Id));
        }

        for (Integer index = 0; index < 5; index++){
            courseOfferings[index].Time_Block__c = timeBlocks[index].Id;
        }
        update courseOfferings;

        List<Time_Block__c> returnTimeBlocks = [
            SELECT Id, 
                (SELECT Id FROM Time_Block__c.Time_Blocks__r)
            FROM Time_Block__c
            WHERE Id IN :timeBlocks
        ];

        TB_CannotDelete_TDTM tbCannotDeleteClass = new TB_CannotDelete_TDTM();

        for (Time_Block__c tb : returnTimeBlocks) {
            System.assertEquals(TRUE, tbCannotDeleteClass.hasChildRecords(tb));
        }
    }

    /*********************************************************************************************************
    * @description Test method for the hasChildRecords() method in TB_CannotDelete_TDTM to test that TRUE
    * is returned for a Time Block record with Course Offering Schedule child records.
    */
    @isTest 
    private static void hasCourseOfferingScheduleChildRecordsIsTrue() {
        
        Time startTime = Time.newInstance(8, 0, 0, 0);
        Time stopTime = Time.newInstance(10, 0, 0, 0);

        List<Time_Block__c> timeBlocks = new List<Time_Block__c>();

        for (Integer index = 0; index < 5; index++){
            timeBlocks.add(UTIL_UnitTestData_TEST.createTimeBlock(startTime, stopTime));
        }

        List<Account> departmentAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, TB_CannotDelete_TEST.deptAccRecordTypeID);
        insert departmentAccounts;

        Term__c testTerm = UTIL_UnitTestData_TEST.getTerm(departmentAccounts[0].Id, 'Test Term');
        insert testTerm;

        Course__c testCourse = new Course__c(Name = 'Test Course', Account__c = departmentAccounts[0].Id);
        insert testCourse;

        List<Course_Offering__c> courseOfferings = new List<Course_Offering__c>();
        for (Integer index = 0; index < 5; index++){
            courseOfferings.add(UTIL_UnitTestData_TEST.createCourseOffering(testCourse.Id, testTerm.Id));
        }

        List<Course_Offering_Schedule__c> courseOfferingSchedules = new List<Course_Offering_Schedule__c>();
        for (Integer index = 0; index < 5; index++){
            courseOfferingSchedules.add(UTIL_UnitTestData_TEST.createCourseOfferingSchedule(courseOfferings[index].Id));
        }

        for (Integer index = 0; index < 5; index++){
            courseOfferingSchedules[index].Time_Block__c = timeBlocks[index].Id;
        }

        insert courseOfferingSchedules;

        List<Time_Block__c> returnTimeBlocks = [
            SELECT Id, 
                (SELECT Id FROM Time_Block__c.Course_Offering_Schedules__r)
            FROM Time_Block__c
            WHERE Id IN :timeBlocks
        ];

        TB_CannotDelete_TDTM tbCannotDeleteClass = new TB_CannotDelete_TDTM();

        for (Time_Block__c tb : returnTimeBlocks) {
            System.assertEquals(TRUE, tbCannotDeleteClass.hasChildRecords(tb));
        }
    }

    /*********************************************************************************************************
    * @description Test method for the hasChildRecords() method in TB_CannotDelete_TDTM to test that TRUE
    * is returned for a Time Block record with both Course Offering and Course Offering Schedule child records.
    */
    @isTest 
    private static void hasCourseOfferingAndScheduleChildRecordsIsTrue() {
        
        Time startTime = Time.newInstance(8, 0, 0, 0);
        Time stopTime = Time.newInstance(10, 0, 0, 0);

        List<Time_Block__c> timeBlocks = new List<Time_Block__c>();

        for (Integer index = 0; index < 5; index++){
            timeBlocks.add(UTIL_UnitTestData_TEST.createTimeBlock(startTime, stopTime));
        }

        List<Account> departmentAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, TB_CannotDelete_TEST.deptAccRecordTypeID);
        insert departmentAccounts;

        Term__c testTerm = UTIL_UnitTestData_TEST.getTerm(departmentAccounts[0].Id, 'Test Term');
        insert testTerm;

        Course__c testCourse = new Course__c(Name = 'Test Course', Account__c = departmentAccounts[0].Id);
        insert testCourse;

        List<Course_Offering__c> courseOfferings = new List<Course_Offering__c>();
        for (Integer index = 0; index < 5; index++){
            courseOfferings.add(UTIL_UnitTestData_TEST.createCourseOffering(testCourse.Id, testTerm.Id));
        }

        for (Integer index = 0; index < 5; index++){
            courseOfferings[index].Time_Block__c = timeBlocks[index].Id;
        }
        update courseOfferings;

        List<Course_Offering_Schedule__c> courseOfferingSchedules = new List<Course_Offering_Schedule__c>();
        for (Integer index = 0; index < 5; index++){
            courseOfferingSchedules.add(UTIL_UnitTestData_TEST.createCourseOfferingSchedule(courseOfferings[index].Id));
        }

        for (Integer index = 0; index < 5; index++){
            courseOfferingSchedules[index].Time_Block__c = timeBlocks[index].Id;
        }

        insert courseOfferingSchedules;

        List<Time_Block__c> returnTimeBlocks = [
            SELECT Id, 
                (SELECT Id FROM Time_Block__c.Time_Blocks__r),
                (SELECT Id FROM Time_Block__c.Course_Offering_Schedules__r)
            FROM Time_Block__c
            WHERE Id IN :timeBlocks
        ];

        TB_CannotDelete_TDTM tbCannotDeleteClass = new TB_CannotDelete_TDTM();

        for (Time_Block__c tb : returnTimeBlocks) {
            System.assertEquals(TRUE, tbCannotDeleteClass.hasChildRecords(tb));
        }
    }

    /*********************************************************************************************************
    * @description Test method for the hasChildRecords() method in TB_CannotDelete_TDTM to test that FALSE
    * is returned for a Time Block record no associated child records.
    */
    @isTest 
    private static void hasChildRecordsIsFalse() {

        Time startTime = Time.newInstance(8, 0, 0, 0);
        Time stopTime = Time.newInstance(10, 0, 0, 0);

        List<Time_Block__c> timeBlocks = new List<Time_Block__c>();

        for (Integer index = 0; index < 5; index++){
            timeBlocks.add(UTIL_UnitTestData_TEST.createTimeBlock(startTime, stopTime));
        }

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(timeBlocks, FALSE);
        Test.stopTest();

        List<Time_Block__c> returnTimeBlocks = [
            SELECT Id, 
                (SELECT Id FROM Time_Block__c.Time_Blocks__r),
                (SELECT Id FROM Time_Block__c.Course_Offering_Schedules__r)
            FROM Time_Block__c
            WHERE Id IN :timeBlocks
        ];

        TB_CannotDelete_TDTM tbCannotDeleteClass = new TB_CannotDelete_TDTM();

        for (Time_Block__c tb : returnTimeBlocks) {
            System.assertEquals(FALSE, tbCannotDeleteClass.hasChildRecords(tb));
        }
    }
}
