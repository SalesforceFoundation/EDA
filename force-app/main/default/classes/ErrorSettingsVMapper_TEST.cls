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
 * @group-content ../../ApexDocContent/Tests
 * @description Test class for ErrorSettingsVMapper
 */
@isTest
private with sharing class ErrorSettingsVMapper_TEST {
    private static Integer loopCounter = 5;

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * ErrorSettingsVMapper class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        ErrorSettingsVMapper errorSettingsVMapperInstance = ErrorSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ErrorSettingsVMapper.instance,
            errorSettingsVMapperInstance,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            true,
            errorSettingsVMapperInstance != null,
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * ErrorSettingsVMapper class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        ErrorSettingsVMapper errorSettingsVMapperInstance1 = ErrorSettingsVMapper.getInstance();
        ErrorSettingsVMapper errorSettingsVMapperInstance2 = ErrorSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ErrorSettingsVMapper.instance,
            errorSettingsVMapperInstance1,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            errorSettingsVMapperInstance1,
            errorSettingsVMapperInstance2,
            'Subsequent retrievals of service class instance should return existing instance.'
        );

        System.assertEquals(
            true,
            errorSettingsVMapperInstance1 != null,
            'Instance of service class should not be null.'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the locateErrorSettingsService method returns instance of ErrorSettingsService
     ***********************************************************************************************************************************/
    @isTest
    private static void locateErrorSettingsServiceValid() {
        ErrorSettingsVMapper errorSettingsVMapperInstance = ErrorSettingsVMapper.getInstance();

        Test.startTest();
        ErrorSettingsService errorSettingsServiceInstance = errorSettingsVMapperInstance.locateErrorSettingsService();
        Test.stopTest();

        System.assertEquals(
            ErrorSettingsService.getInstance(),
            errorSettingsServiceInstance,
            'Should return the instance of ErrorSettingsService'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getErrorSettingsViewModel method returns an ErrorSettingsVModel that reflects the
     * error settings set in hierarchy settings
     ***********************************************************************************************************************************/
    @isTest
    private static void getErrorSettingsViewModelValid() {
        ErrorSettingsMapper.instance = new STUB_ErrorSettingsMapper();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Store_Errors_On__c = true, Disable_Error_Handling__c = false)
        );

        ErrorSettingsVMapper errorSettingsVMapperInstance = ErrorSettingsVMapper.getInstance();

        Test.startTest();
        ErrorSettingsVModel errorSettingsVModel = errorSettingsVMapperInstance.getErrorSettingsViewModel();
        Test.stopTest();

        System.assertEquals(
            true,
            errorSettingsVModel.storeErrors,
            'Store errors functionality should match value set in hierarchy settings.'
        );

        System.assertEquals(
            true,
            errorSettingsVModel.errorHandling,
            'Error handling model property should be inverse of value set in hierarchy settings.'
        );
    }

    /**************************************************************************************************************************
     ****************************************************** STUBS **************************************************************
     **************************************************************************************************************************/

    /*********************************************************************************************************************
     * @description Stub class to simulate the response from ErrorSettingsMapper to return a valid ErrorSettingsModel
     *********************************************************************************************************************/
    private class STUB_ErrorSettingsMapper extends ErrorSettingsMapper {
        public override ErrorSettingsModel getErrorSettingsModel() {
            return new ErrorSettingsModel(true, true);
        }
    }
}
