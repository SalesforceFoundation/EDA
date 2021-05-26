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
 * @description Test class for CourseConnectionSettingsController class
 */
@isTest
private with sharing class CourseConnectionSettingsController_TEST {
    /**************************************************************************************************************************************************
     * @description Test method to verify that the locateCourseConnectionSettingsVMapper method returns instance of CourseConnectionSettingsVMapper.
     *************************************************************************************************************************************************/
    @isTest
    private static void locateCourseConnectionSettingsVMapper() {
        Test.startTest();
        CourseConnectionSettingsVMapper courseConnectionSettingsVMapperInstance = CourseConnectionSettingsController.locateCourseConnectionSettingsVMapper();
        Test.stopTest();

        System.assertEquals(
            CourseConnectionSettingsVMapper.getInstance(),
            courseConnectionSettingsVMapperInstance,
            'Should return the instance of CourseConnectionSettingsVMapper.'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getCourseConnectionSettingsVModel method returns a valid CourseConnectionSettingsVModel
     ****************************************************************************************************************************/
    @isTest
    private static void getCourseConnectionSettingsVModelValid() {
        CourseConnectionSettingsVMapper.instance = new STUB_CourseConnectionSettingsVMapper();

        Test.startTest();
        CourseConnectionSettingsVModel courseConnectionSettingsVModel = CourseConnectionSettingsController.getCourseConnectionSettingsVModel();
        Test.stopTest();

        System.assertEquals(
            true,
            courseConnectionSettingsVModel.courseConnectionRecordTypes,
            'courseConnectionRecordTypes should be true.'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getAddressSettingsViewModel method fails gracefully when an exception is
     * encountered.
     ****************************************************************************************************************************/
    @isTest
    private static void getAddressSettingsViewModelException() {
        CourseConnectionSettingsVMapper.instance = new STUB_ExceptionCourseConnectionSettingsVMapper();

        try {
            Test.startTest();
            CourseConnectionSettingsVModel courseConnectionSettingsVModel = CourseConnectionSettingsController.getCourseConnectionSettingsVModel();
            Test.stopTest();
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /**************************************************************************************************************************
     ****************************************************** STUBS **************************************************************
     **************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from CourseConnectionSettingsVMapper to return a valid CourseConnectionSettingsVModel
     **************************************************************************************************************************************/
    private class STUB_CourseConnectionSettingsVMapper extends CourseConnectionSettingsVMapper {
        public override CourseConnectionSettingsVModel getCourseConnectionSettingsVModel() {
            return new CourseConnectionSettingsVModel(true);
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from CourseConnectionSettingsVMapper to throw an exception
     **************************************************************************************************************************************/
    private class STUB_ExceptionCourseConnectionSettingsVMapper extends CourseConnectionSettingsVMapper {
        public override CourseConnectionSettingsVModel getCourseConnectionSettingsVModel() {
            throw new TestException('Exception encountered!');
        }
    }

    private class TestException extends Exception {
    }
}
