/*
    Copyright (c) 2021, Salesforce.org
    All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
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
* @date 2021
* @group 
* @group-content ../../ApexDocContent/
* @description Test class for CourseConnectionSettingsService class
*/
@isTest
private class CourseConnectionSettingsService_TEST {

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * CourseConnectionSettingsService class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            CourseConnectionSettingsService courseConnectionSettingsServiceInstance = CourseConnectionSettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(CourseConnectionSettingsService.instance, courseConnectionSettingsServiceInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, courseConnectionSettingsServiceInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * CourseConnectionSettingsService class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            CourseConnectionSettingsService courseConnectionSettingsServiceInstance1 = CourseConnectionSettingsService.getInstance();
            CourseConnectionSettingsService courseConnectionSettingsServiceInstance2 = CourseConnectionSettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(CourseConnectionSettingsService.instance, courseConnectionSettingsServiceInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(courseConnectionSettingsServiceInstance1, courseConnectionSettingsServiceInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, courseConnectionSettingsServiceInstance1 != null, 'Instance of service class should not be null.');
    }

    /********************************************************************************************************************************************
    * @description Test method to verify that the locateCourseConnectionSettingsMapper method returns instance of CourseConnectionSettingsService
    *********************************************************************************************************************************************/
    @isTest
    private static void locateCourseConnectionSettingsMapper() {

        Test.startTest();
            CourseConnectionSettingsMapper courseConnSettingsMapper = CourseConnectionSettingsService.getInstance().locateCourseConnectionSettingsMapper();
        Test.stopTest();

        System.assertEquals(CourseConnectionSettingsMapper.getInstance(), courseConnSettingsMapper, 'Should return the instance of CourseConnectionSettingsService');

    }

    /****************************************************************************************************************************************
    * @description Test method to verify that the getCourseConnectionSettingsModel method returns instance of CourseConnectionsSettings Model
    ****************************************************************************************************************************************/
    @isTest
    private static void getCourseConnectionSettingsModel() {

        CourseConnectionSettingsMapper.instance = new STUB_CourseConnectionSettingsMapper();

        Test.startTest();
            CourseConnectionSettingsModel courseConnectionSettingsModel = CourseConnectionSettingsService.getInstance().getCourseConnectionSettingsModel();
        Test.stopTest();

        System.assertEquals(true, courseConnectionSettingsModel.courseConnectionsEnabled, 'courseConnectionsEnabled property on the CourseConnectionSettings model should be set with the value that is passed.');
        System.assertEquals('01217000002Zs0pAAC', courseConnectionSettingsModel.studentRecordTypeId, 'studentRecordTypeId property on the CourseConnectionSettings model should be set with the value that is passed.');
        System.assertEquals('01217000002Zs0sAAC', courseConnectionSettingsModel.facultyRecordTypeId, 'facultyRecordTypeId property on the CourseConnectionSettings model should be set with the value that is passed.');

    }

    /***********************************************************************************************************************************
    ****************************************************** STUBS ***********************************************************************
    ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from CourseConnectionSettingsMapper to return a CourseConnectionSettings model
    **************************************************************************************************************************************/ 
    private class STUB_CourseConnectionSettingsMapper extends CourseConnectionSettingsMapper {
 
        public override CourseConnectionSettingsModel getCourseConnectionSettingsModel() {
            CourseConnectionSettingsModel courseConnSettingsModel = new CourseConnectionSettingsModel(true, '01217000002Zs0pAAC', '01217000002Zs0sAAC');

            return courseConnSettingsModel;
        }
    }
}