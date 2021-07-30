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
 * @description Test class for ApplicationSettingsController class
 */
@isTest
private with sharing class ApplicationSettingsController_TEST {
    /**************************************************************************************************************************************************
     * @description Test method to verify that the locateApplicationSettingsVMapper method returns instance of locateApplicationSettingsVMapper.
     *************************************************************************************************************************************************/
    @isTest
    private static void locateApplicationSettingsVMapper() {
        Test.startTest();
        ApplicationSettingsVMapper applicationSettingsVMapperInstance = ApplicationSettingsController.locateApplicationSettingsVMapper();
        Test.stopTest();

        System.assertEquals(
            ApplicationSettingsVMapper.getInstance(),
            applicationSettingsVMapperInstance,
            'Should return the instance of locateApplicationSettingsVMapper'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getApplicationSettingsVModel method returns an ApplicationSettingsVModel
     * representing Application Settings in Hierarchy Settings.
     ****************************************************************************************************************************/
    @isTest
    private static void getRelationshipSettingsVModelValid() {
        ApplicationSettingsVMapper.instance = new STUB_ApplicationSettingsVMapper();

        Test.startTest();
        ApplicationSettingsVModel applicationSettingsVModel = ApplicationSettingsController.getApplicationSettingsVModel();
        Test.stopTest();

        System.assertEquals(
            true,
            applicationSettingsVModel.enableApplicationWindowValidation,
            'Selected value should be retrieved for application window validation'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getApplicationSettingsVModel method fails gracefully when an exception is
     * encountered.
     ****************************************************************************************************************************/
    @isTest
    private static void getRelationshipSettingsVModelException() {
        ApplicationSettingsVMapper.instance = new STUB_ExceptionApplicationSettingsVMapper();

        try {
            Test.startTest();
            ApplicationSettingsVModel applicationSettingsVModel = ApplicationSettingsController.getApplicationSettingsVModel();
            Test.stopTest();
            System.assert(false, 'Should have thrown an AuraHandledException.');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from ApplicationSettingsVMapper to return a valid ApplicationSettingsVModel
     **************************************************************************************************************************************/
    private class STUB_ApplicationSettingsVMapper extends ApplicationSettingsVMapper {
        public override ApplicationSettingsVModel getApplicationSettingsVModel() {
            return new ApplicationSettingsVModel(true);
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from ApplicationSettingsVMapper to throw an exception
     **************************************************************************************************************************************/
    private class STUB_ExceptionApplicationSettingsVMapper extends ApplicationSettingsVMapper {
        public override ApplicationSettingsVModel getApplicationSettingsVModel() {
            throw new TestException('Exception encountered!');
        }
    }

    private class TestException extends Exception {
    }
}
