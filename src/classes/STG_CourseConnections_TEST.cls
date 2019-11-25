/*
    Copyright (c) 2016 Salesforce.org
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
/**
* @author Salesforce.org
* @date 2016
* @group Course Enrollments
* @group-content ../../ApexDocContent/CourseEnrollments.htm
* @description Test specific to Course Connection Settings.
*/
@isTest
public with sharing class STG_CourseConnections_TEST {
    /*********************************************************************************************************
    * @description Tests if backfill of Course Connection batch class is successfully run.
    */
    @isTest
    public static void checkGetEnqueueCourseConnectionsBackfill() {
        Id apexJobId = STG_CourseConnections.getEnqueueCourseConnectionsBackfill();
        System.assertNotEquals(null, apexJobId);
    }

    /*********************************************************************************************************
    * @description Tests if backfill of Affiliation on Student Course Connection batch class is successfully run.
    */
    @isTest
    public static void checkExecuteAffiliationBackfillOnCourseConnection() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(
        												Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
            											Enable_Course_Connections__c = true,
        												Populate_Affil_on_Student_Couse_Cxn__c = true
        												));
        Id apexJobId = STG_CourseConnections.executeAffiliationBackfillOnCourseConnection();
        System.assertNotEquals(null, apexJobId);
    }
}