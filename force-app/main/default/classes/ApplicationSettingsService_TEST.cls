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
 * @description Test class for ApplicationSettingsService class.
 */
@isTest
private with sharing class ApplicationSettingsService_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * ApplicationSettingsService class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        ApplicationSettingsService applicationSettingsServiceInstance = ApplicationSettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(
            ApplicationSettingsService.instance,
            applicationSettingsServiceInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assert(applicationSettingsServiceInstance != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * ApplicationSettingsService class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        ApplicationSettingsService applicationSettingsServiceInstance1 = ApplicationSettingsService.getInstance();
        ApplicationSettingsService applicationSettingsServiceInstance2 = ApplicationSettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(
            ApplicationSettingsService.instance,
            applicationSettingsServiceInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            applicationSettingsServiceInstance1,
            applicationSettingsServiceInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assert(applicationSettingsServiceInstance1 != null, 'Instance of mapper class should not be null.');
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the locateApplicationSettingsMapper method returns instance of ApplicationSettingsMapper
     ***********************************************************************************************************************************/
    @isTest
    private static void locateApplicationSettingsMapper() {
        ApplicationSettingsService applicationSettingsServiceInstance = ApplicationSettingsService.getInstance();

        Test.startTest();
        ApplicationSettingsMapper applicationSettingsMapperInstance = applicationSettingsServiceInstance.locateApplicationSettingsMapper();
        Test.stopTest();

        System.assertEquals(
            ApplicationSettingsMapper.getInstance(),
            applicationSettingsMapperInstance,
            'Should return the instance of ApplicationSettingsMapperInstance'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getApplicationSettingsModel method returns a valid ApplicationSettingsModel
     ***********************************************************************************************************************************/
    @isTest
    private static void getApplicationSettingsModelValid() {
        ApplicationSettingsMapper.instance = new STUB_ApplicationSettingsMapper();

        ApplicationSettingsService applicationSettingsServiceInstance = ApplicationSettingsService.getInstance();

        Test.startTest();
        ApplicationSettingsModel applicationSettingsModel = applicationSettingsServiceInstance.getApplicationSettingsModel();
        Test.stopTest();

        System.assertEquals(
            true,
            applicationSettingsModel.applicationWindowValidation,
            'Should be set to the value of hierarchy settings.'
        );
    }

    /***********************************************************************************************************************************
     ****************************************************** STUBS ***********************************************************************
     ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from ApplicationSettingsMapper to return a valid ApplicationSettingsModel
     **************************************************************************************************************************************/
    private class STUB_ApplicationSettingsMapper extends ApplicationSettingsMapper {
        public override ApplicationSettingsModel getApplicationSettingsModel() {
            return new ApplicationSettingsModel(true);
        }
    }
}
