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
    * @description Test method to test that when Prevent_Time_Block_Deletion__c is enabled in Hierarchy 
    * Settings and Time Block has a child Course Offering record associated with it, the Time Block 
    * record cannot be deleted.
    */
    @isTest 
    private static void cannotDeleteWithChildCourseOfferingPreventDeleteOn() {
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Time_Block_Deletion__c is enabled in Hierarchy 
    * Settings and Time Block has a child Course Offering Schedule record associated with it, the Time Block 
    * record cannot be deleted.
    */
    @isTest 
    private static void cannotDeleteWithChildCourseOfferingSchedulePreventDeleteOn() {
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Time_Block_Deletion__c is enabled in Hierarchy 
    * Settings and Time Block has both Course Offering and Course Offering Schedule child records associated 
    * with it, the Time Block record cannot be deleted.
    */
    @isTest 
    private static void cannotDeleteWithChildCourseOfferingAndScheduleRecordsPreventDeleteOn() {
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Time_Block_Deletion__c is enabled in Hierarchy 
    * Settings and Time Block has no associated child records, the Time Block record can be deleted.
    */
    @isTest 
    private static void canDeleteWithoutChildRecordsPreventDeleteOn() {
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Time_Block_Deletion__c is disabled in Hierarchy 
    * Settings and Time Block has a child Course Offering record associated with it, the Time Block 
    * record can be deleted.
    */
    @isTest 
    private static void canDeleteWithChildCourseOfferingPreventDeleteOff() {
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Time_Block_Deletion__c is disabled in Hierarchy 
    * Settings and Time Block has a child Course Offering Schedule record associated with it, the Time Block 
    * record can be deleted.
    */
    @isTest 
    private static void canDeleteWithChildCourseOfferingSchedulePreventDeleteOff() {
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Time_Block_Deletion__c is disabled in Hierarchy 
    * Settings and Time Block has both Course Offering and Course Offering Schedule child records associated 
    * with it, the Time Block record can be deleted.
    */
    @isTest 
    private static void canDeleteWithChildCourseOfferingAndSchedulePreventDeleteOff() {
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Time_Block_Deletion__c is disabled in Hierarchy 
    * Settings and Time Block has no associated child records, the Time Block record can be deleted.
    */
    @isTest 
    private static void canDeleteWithoutChildRecordsPreventDeleteOff() {
    }

    /*********************************************************************************************************
    * @description Test method for the hasChildRecords() method in TB_CannotDelete_TDTM to test that TRUE
    * is returned for a Time Block record with Course Offering child records.
    */
    @isTest 
    private static void hasCourseOfferingChildRecordsIsTrue() {
    }

    /*********************************************************************************************************
    * @description Test method for the hasChildRecords() method in TB_CannotDelete_TDTM to test that TRUE
    * is returned for a Time Block record with Course Offering Schedule child records.
    */
    @isTest 
    private static void hasCourseOfferingScheduleChildRecordsIsTrue() {
    }

    /*********************************************************************************************************
    * @description Test method for the hasChildRecords() method in TB_CannotDelete_TDTM to test that TRUE
    * is returned for a Time Block record with both Course Offering and Course Offering Schedule child records.
    */
    @isTest 
    private static void hasCourseOfferingAndScheduleChildRecordsIsTrue() {
    }

    /*********************************************************************************************************
    * @description Test method for the hasChildRecords() method in TB_CannotDelete_TDTM to test that FALSE
    * is returned for a Time Block record no associated child records.
    */
    @isTest 
    private static void hasChildRecordsIsFalse() {
    }

}
