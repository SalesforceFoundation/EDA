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
 * @description Test class for ApplicationSettingsVMapper class
 */
@isTest
private with sharing class ApplicationSettingsVMapper_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * ApplicationSettingsVMapper class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        ApplicationSettingsVMapper applicationSettingsVMapperInstance = ApplicationSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ApplicationSettingsVMapper.instance,
            applicationSettingsVMapperInstance,
            'Instance of service class returned should match static instance variable.'
        );

        System.assert(applicationSettingsVMapperInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * ApplicationSettingsVMapper class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        ApplicationSettingsVMapper applicationSettingsVMapperInstance1 = ApplicationSettingsVMapper.getInstance();
        ApplicationSettingsVMapper applicationSettingsVMapperInstance2 = ApplicationSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ApplicationSettingsVMapper.instance,
            applicationSettingsVMapperInstance1,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            applicationSettingsVMapperInstance1,
            applicationSettingsVMapperInstance2,
            'Subsequent retrievals of service class instance should return existing instance.'
        );

        System.assert(applicationSettingsVMapperInstance1 != null, 'Instance of service class should not be null.');
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the locateApplicationSettingsService method returns instance of locateApplicationSettingsService
     ***********************************************************************************************************************************/
    @isTest
    private static void locateApplicationSettingsService() {
        ApplicationSettingsVMapper applicationSettingsVMapperInstance = ApplicationSettingsVMapper.getInstance();

        Test.startTest();
        ApplicationSettingsService applicationSettingsServiceInstance = ApplicationSettingsVMapperInstance.locateApplicationSettingsService();
        Test.stopTest();

        System.assertEquals(
            ApplicationSettingsService.getInstance(),
            applicationSettingsServiceInstance,
            'Should return the instance of ApplicationSettingsService'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getApplicationSettingsVModel returns an ApplicationSettingsVModel with the selected
     * value set to the value specified in the associated Hierarchy Settings fields
     ***********************************************************************************************************************************/
    @isTest
    private static void getApplicationSettingsVModel() {
        ApplicationSettingsService.instance = new STUB_ApplicationSettingsService();

        ApplicationSettingsVMapper applicationSettingsVMapperInstance = ApplicationSettingsVMapper.getInstance();

        Test.startTest();
        ApplicationSettingsVModel applicationSettingsVModel = applicationSettingsVMapperInstance.getApplicationSettingsVModel();
        Test.stopTest();

        System.assertEquals(
            true,
            applicationSettingsVModel.enableApplicationWindowValidation,
            'Correct value for Application Window Validation should be retreived.'
        );
    }

    /**************************************************************************************************************************
     ****************************************************** STUBS **************************************************************
     **************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from ApplicationSettingsService to return a ApplicationSettingsModel
     **************************************************************************************************************************************/
    private class STUB_ApplicationSettingsService extends ApplicationSettingsService {
        public override ApplicationSettingsModel getApplicationSettingsModel() {
            return new ApplicationSettingsModel(true);
        }
    }
}
