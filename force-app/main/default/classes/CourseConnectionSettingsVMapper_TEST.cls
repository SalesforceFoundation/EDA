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
 * @group-content ../../ApexDocContent/Tests.htm
 * @description Test class for CourseConnectionSettingsVMapper.
 */
@isTest
private with sharing class CourseConnectionSettingsVMapper_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * CourseConnectionSettingsVMapper class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        CourseConnectionSettingsVMapper courseConnectionSettingsVMapperInstance = CourseConnectionSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            CourseConnectionSettingsVMapper.instance,
            courseConnectionSettingsVMapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            courseConnectionSettingsVMapperInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * CourseConnectionSettingsVMapper class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        CourseConnectionSettingsVMapper courseConnectionSettingsVMapperInstance1 = CourseConnectionSettingsVMapper.getInstance();
        CourseConnectionSettingsVMapper courseConnectionSettingsVMapperInstance2 = CourseConnectionSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            CourseConnectionSettingsVMapper.instance,
            courseConnectionSettingsVMapperInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            courseConnectionSettingsVMapperInstance1,
            courseConnectionSettingsVMapperInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            courseConnectionSettingsVMapperInstance1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test to verify locateCourseConnectionSettingsService() returns an instance of the CourseConnectionSettingsService class.
     **************************************************************************************************************************/
    @isTest
    private static void locateCourseConnectionSettingsService() {
        CourseConnectionSettingsVMapper courseConnectionSettingsVMapperInstance = CourseConnectionSettingsVMapper.getInstance();

        Test.startTest();
        CourseConnectionSettingsService courseConnectionSettingsServiceInstance = courseConnectionSettingsVMapperInstance.locateCourseConnectionSettingsService();
        Test.stopTest();

        System.assertEquals(
            CourseConnectionSettingsService.getInstance(),
            courseConnectionSettingsServiceInstance,
            'Should return instance of locateAddressSettingsService class.'
        );
        System.assertEquals(
            true,
            courseConnectionSettingsServiceInstance != null,
            'Instance of locateAddressSettingsService class should not be null.'
        );
    }

    /*************************************************************************************************************
     * @description Test method to verify getCourseConnectionSettingsVModel() returns valid CourseConnectionSettingsVModel
     *************************************************************************************************************/
    @isTest
    private static void getCourseConnectionSettingsVModelValid() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Enable_Course_Connections__c = true)
        );

        CourseConnectionSettingsVMapper courseConnectionSettingsVMapperInstance = CourseConnectionSettingsVMapper.getInstance();

        Test.startTest();
        CourseConnectionSettingsVModel courseConnectionSettingsVModel = courseConnectionSettingsVMapperInstance.getCourseConnectionSettingsVModel();
        Test.stopTest();

        System.assertEquals(
            true,
            courseConnectionSettingsVModel.courseConnectionRecordTypes,
            'courseConnectionRecordTypes should be true'
        );
    }
}
