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
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2020
* @group
* @group-content ../../ApexDocContent/Tests.htm
* @description Test class for CourseConnectionSettingsMapper
*/
@isTest
private class  CourseConnectionSettingsMapper_TEST {

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * CourseConnectionSettingsMapper class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            CourseConnectionSettingsMapper courseConnSettingsMapperInstance = CourseConnectionSettingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(CourseConnectionSettingsMapper.instance, courseConnSettingsMapperInstance, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(true, courseConnSettingsMapperInstance != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * CourseConnectionSettingsMapper class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            CourseConnectionSettingsMapper courseConnectionSettingsMapperInstance1 = CourseConnectionSettingsMapper.getInstance();
            CourseConnectionSettingsMapper courseConnectionSettingsMapperInstance2 = CourseConnectionSettingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(CourseConnectionSettingsMapper.instance, courseConnectionSettingsMapperInstance1, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(courseConnectionSettingsMapperInstance1, courseConnectionSettingsMapperInstance2, 'Subsequent retrievals of mapper class instance should return existing instance.');
        System.assertEquals(true, courseConnectionSettingsMapperInstance1 != null, 'Instance of mapper class should not be null.');
    }

    /*******************************************************************************************************************************
    * @description Test method to verify that the getCourseConnectionSettingsModel method returns the CourseConnectionSettingsModel
    ********************************************************************************************************************************/
    @isTest
    private static void getCourseConnectionSettingsModel() {

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettingsFacade.getSettingsForTests(
                                                      new Hierarchy_Settings__c(
                                                          Enable_Course_Connections__c = true,
                                                          Faculty_RecType__c = '01217000002Zs0pAAC',
                                                          Student_RecType__c = '01217000002Zs0pAAD'
                                                       )
                                                  );

        Test.startTest();
            CourseConnectionSettingsModel courseConnSettingsModel = CourseConnectionSettingsMapper.getInstance().getCourseConnectionSettingsModel();
        Test.stopTest();

        System.assertEquals(hierarchySettings.Enable_Course_Connections__c, courseConnSettingsModel.courseConnectionsEnabled, 'Retrieved model\'s courseConnectionsEnabled should be same as \'Enable Course Connections\' from settings.');
        System.assertEquals(hierarchySettings.Student_RecType__c, courseConnSettingsModel.studentRecordTypeId, 'Retrieved model\'s Student RecordType Id should be same as \'Student RecType\' from settings.');
        System.assertEquals(hierarchySettings.Faculty_RecType__c, courseConnSettingsModel.facultyRecordTypeId, 'Retrieved model\'s Faculty RecordType Id should be same as \'Faculty RecType\' from settings.');
    }
}