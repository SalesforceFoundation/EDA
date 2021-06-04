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
 * @description Test class for ErrorSettingsController
 */
@isTest
private with sharing class ErrorSettingsController_TEST {
    /***********************************************************************************************************************************
     * @description Test method to verify that the locateErrorSettingsVMapper method returns instance of ErrorSettingsVMapper
     ***********************************************************************************************************************************/
    @isTest
    private static void locateErrorSettingsVMapperValid() {
        Test.startTest();
        ErrorSettingsVMapper ErrorSettingsVMapperInstance = ErrorSettingsController.locateErrorSettingsVMapper();
        Test.stopTest();

        System.assertEquals(
            ErrorSettingsVMapper.getInstance(),
            ErrorSettingsVMapperInstance,
            'Should return the instance of ErrorSettingsVMapper'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getErrorSettingsViewModel method returns an ErrorSettingsVModel that reflects the
     * error settings set in hierarchy settings
     ***********************************************************************************************************************************/
    @isTest
    private static void getErrorSettingsViewModelValid() {
        ErrorSettingsVMapper.instance = new STUB_ErrorSettingsVMapper();

        Test.startTest();
        ErrorSettingsVModel errorSettingsVModel = ErrorSettingsController.getErrorSettingsViewModel();
        Test.stopTest();

        System.assertEquals(
            true,
            errorSettingsVModel.storeErrors,
            'Store errors functionality should match expected value.'
        );

        System.assertEquals(
            true,
            errorSettingsVModel.sendErrorNotifications,
            'Send error notifications functionality should match expected value.'
        );

        System.assertEquals(
            'All Sys Admins',
            errorSettingsVModel.errorNotificationsRecipientCategory,
            'Error notifications recipient category should match expected value.'
        );

        System.assertEquals(
            false,
            errorSettingsVModel.enableDebug,
            'Enable debug functionality should match expected value.'
        );

        System.assertEquals(
            false,
            errorSettingsVModel.errorHandling,
            'Error handling model property should match expected value.'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getErrorSettingsViewModel method fails gracefuly when an exception is encountered.
     ***********************************************************************************************************************************/
    @isTest
    private static void getErrorSettingsViewModelException() {
        ErrorSettingsVMapper.instance = new STUB_ExceptionErrorSettingsVMapper();

        Test.startTest();
        try {
            ErrorSettingsVModel errorSettingsVModel = ErrorSettingsController.getErrorSettingsViewModel();
            System.assert(false, 'should throw an exception.');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }

        Test.stopTest();
    }

    /**************************************************************************************************************************
     ****************************************************** STUBS **************************************************************
     **************************************************************************************************************************/

    /*********************************************************************************************************************
     * @description Stub class to simulate the response from ErrorSettingsVMapper to return a valid ErrorSettingsVModel
     *********************************************************************************************************************/
    private class STUB_ErrorSettingsVMapper extends ErrorSettingsVMapper {
        public override ErrorSettingsVModel getErrorSettingsViewModel() {
            return new ErrorSettingsVModel(true, true, 'All Sys Admins', false, false);
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from ErrorSettingsVMapper to throw an exception
     **************************************************************************************************************************************/
    private class STUB_ExceptionErrorSettingsVMapper extends ErrorSettingsVMapper {
        public override ErrorSettingsVModel getErrorSettingsViewModel() {
            throw new TestException('Exception encountered!');
        }
    }

    private class TestException extends Exception {
    }
}
