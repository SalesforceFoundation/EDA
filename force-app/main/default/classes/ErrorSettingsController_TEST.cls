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
    /**
     * @description Test method to verify that the locateErrorSettingsVMapper method returns instance of ErrorSettingsVMapper
     */
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

    /**
     * @description Test method to verify that the locateUserLookupResultVMapper method returns instance of UserLookupResultVMapper
     */
    @isTest
    private static void locateUserLookupResultVMapperValid() {
        Test.startTest();
        UserLookupResultVMapper UserLookupResultVMapperInstance = ErrorSettingsController.locateUserLookupResultVMapper();
        Test.stopTest();

        System.assertEquals(
            UserLookupResultVMapper.getInstance(),
            UserLookupResultVMapperInstance,
            'Should return the instance of UserLookupResultVMapper'
        );
    }

    /**
     * @description Test method to verify that the getErrorSettingsViewModel method returns an ErrorSettingsVModel that reflects the
     * error settings set in hierarchy settings
     */
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
            errorSettingsVModel.errorNotificationsRecipientCategory.value,
            'Send Error Notificiation recipient category should match expected value.'
        );
        System.assertEquals(
            1,
            errorSettingsVModel.errorNotificationsRecipientCategory.options.size(),
            'Number of Send Error Notificiation recipient category valid options should match expected size.'
        );
        System.assertEquals(
            'All Sys Admins',
            errorSettingsVModel.errorNotificationsRecipientCategory.options[0].value,
            'Send Error Notificiation recipient category valid option for All Sys Admins should have expected value.'
        );
        System.assertEquals(
            'All Sys Admins Label',
            errorSettingsVModel.errorNotificationsRecipientCategory.options[0].label,
            'Send Error Notificiation recipient category valid option for All Sys Admins should have expected label.'
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

    /**
     * @description Test method to verify that the getErrorSettingsViewModel method fails gracefuly when an exception is encountered.
     */
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

    /**
     * @description Test method to verify that the getLookupResultsLikeName method returns a List of LookupResults that reflects the
     * search string
     */
    @isTest
    private static void getLookupResultsLikeNameValid() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        UserLookupResultVMapper.instance = new STUB_UserLookupResultVMapper(userId);

        Test.startTest();
        List<LookupResult> lookupResultList = ErrorSettingsController.getLookupResultsLikeName('User');
        Test.stopTest();

        System.assertEquals(1, lookupResultList.size(), 'Only 1 Lookup result should be retrieved.');

        LookupResult lookupResult = lookupResultList[0];

        System.assertEquals('User Name', lookupResult.label, 'Lookup Result label should be the expected label.');
        System.assertEquals(userId, lookupResult.value, 'Lookup Result value should be the expected value.');
        System.assertEquals('standard:avatar', lookupResult.icon, 'Lookup Result icon should be the expected icon.');
        System.assertEquals(
            'User',
            lookupResult.alternativeText,
            'Lookup Result alternative text should be the expected value.'
        );
        System.assertEquals(
            'https://example.com/user.png',
            lookupResult.imageUrl,
            'Lookup Result image url should be the expected value.'
        );
        System.assertEquals('user@test.com', lookupResult.meta, 'Lookup Result meta should be the expected value.');
    }

    /**
     * @description Test method to verify that the getLookupResultsLikeName method fails gracefuly when an exception is encountered.
     */
    @isTest
    private static void getLookupResultsLikeNameException() {
        UserLookupResultVMapper.instance = new STUB_UserLookupResultVMapperError();

        try {
            Test.startTest();
            List<LookupResult> lookupResultList = ErrorSettingsController.getLookupResultsLikeName('User');
            Test.stopTest();

            System.assert(false, 'should throw an exception.');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }

        Test.stopTest();
    }

    /**************************************************************************************************************************
     ****************************************************** STUBS **************************************************************
     **************************************************************************************************************************/

    /**
     * @description Stub class to simulate the response from ErrorSettingsVMapper to return a valid ErrorSettingsVModel
     */
    private class STUB_ErrorSettingsVMapper extends ErrorSettingsVMapper {
        public override ErrorSettingsVModel getErrorSettingsViewModel() {
            List<ComboboxValueVModel> errorNotificationsRecipientCategoryValues = new List<ComboboxValueVModel>{
                new ComboboxValueVModel('All Sys Admins Label', 'All Sys Admins')
            };
            ComboboxVModel errorNotificationsRecipientCategory = new ComboboxVModel(
                'All Sys Admins',
                errorNotificationsRecipientCategoryValues
            );

            return new ErrorSettingsVModel(true, true, errorNotificationsRecipientCategory, false, false, null);
        }
    }

    /**
     * @description Stub class to simulate the response from ErrorSettingsVMapper to throw an exception
     */
    private class STUB_ExceptionErrorSettingsVMapper extends ErrorSettingsVMapper {
        public override ErrorSettingsVModel getErrorSettingsViewModel() {
            throw new TestException('Exception encountered!');
        }
    }

    /**
     * @description Stub class to simulate the response from UserLookupResultVMapper for valid information
     */
    private class STUB_UserLookupResultVMapper extends UserLookupResultVMapper {
        public Id userId;

        public STUB_UserLookupResultVMapper(Id userId) {
            this.userId = userId;
        }

        public override List<LookupResult> getLookupResultsLikeName(String userNameMatch, Integer recordLimit) {
            if (userId != this.userId) {
                return new List<LookupResult>();
            }

            return new List<LookupResult>{
                new LookupResult(
                    'User Name',
                    userId,
                    'standard:avatar',
                    'User',
                    'https://example.com/user.png',
                    'user@test.com'
                )
            };
        }
    }

    /**
     * @description Stub class to simulate the response from UserLookupResultVMapper to throw an exception
     */
    private class STUB_UserLookupResultVMapperError extends UserLookupResultVMapper {
        public override List<LookupResult> getLookupResultsLikeName(String userNameMatch, Integer recordLimit) {
            throw new TestException('Exception encountered!');
        }
    }

    private class TestException extends Exception {
    }
}
