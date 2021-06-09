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
     * @description Test method to verify that the locateUserService method returns instance of UserService
     ***********************************************************************************************************************************/
    @isTest
    private static void locateUserServiceValid() {
        ErrorSettingsVMapper errorSettingsVMapperInstance = ErrorSettingsVMapper.getInstance();

        Test.startTest();
        UserService userServiceInstance = errorSettingsVMapperInstance.locateUserService();
        Test.stopTest();

        System.assertEquals(
            UserService.getInstance(),
            userServiceInstance,
            'Should return the instance of UserService'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the locateUserLookupResultVMapper method returns instance of UserLookupResultVMapper
     ***********************************************************************************************************************************/
    @isTest
    private static void locateUserLookupResultVMapperValid() {
        ErrorSettingsVMapper errorSettingsVMapperInstance = ErrorSettingsVMapper.getInstance();

        Test.startTest();
        UserLookupResultVMapper userLookupResultVMapperInstance = errorSettingsVMapperInstance.locateUserLookupResultVMapper();
        Test.stopTest();

        System.assertEquals(
            UserLookupResultVMapper.getInstance(),
            userLookupResultVMapperInstance,
            'Should return the instance of UserLookupResultVMapper'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getErrorSettingsViewModel method returns an ErrorSettingsVModel that reflects the
     * error settings set in hierarchy settings
     ***********************************************************************************************************************************/
    @isTest
    private static void getErrorSettingsViewModelValid() {
        ErrorSettingsService.instance = new STUB_ErrorSettingsServiceAllSysAdmins();
        ErrorSettingsVMapper errorSettingsVMapperInstance = ErrorSettingsVMapper.getInstance();

        Test.startTest();
        ErrorSettingsVModel errorSettingsVModel = errorSettingsVMapperInstance.getErrorSettingsViewModel();
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
            null,
            errorSettingsVModel.userOrChatterGroupLookupResult,
            'Send Error Notification recipient lookup should be null.'
        );

        System.assertEquals(
            false,
            errorSettingsVModel.enableDebug,
            'Enable debug functionality should match expected value.'
        );

        System.assertEquals(
            true,
            errorSettingsVModel.errorHandling,
            'Error handling model property should match expected value.'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getErrorSettingsViewModel method returns an ErrorSettingsVModel that reflects the
     * error settings set in hierarchy settings for user notification sending
     ***********************************************************************************************************************************/
    @isTest
    private static void getErrorSettingsViewModelUser() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.getSObjectType());
        ErrorSettingsService.instance = new STUB_ErrorSettingsServiceUser(userId);
        UserService.instance = new STUB_UserService(userId);
        ErrorSettingsVMapper errorSettingsVMapperInstance = ErrorSettingsVMapper.getInstance();

        Test.startTest();
        ErrorSettingsVModel errorSettingsVModel = errorSettingsVMapperInstance.getErrorSettingsViewModel();
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
            'User',
            errorSettingsVModel.errorNotificationsRecipientCategory.value,
            'Send Error Notificiation recipient category should match expected value.'
        );
        System.assertEquals(
            1,
            errorSettingsVModel.errorNotificationsRecipientCategory.options.size(),
            'Number of Send Error Notificiation recipient category valid options should match expected size.'
        );
        System.assertEquals(
            'User',
            errorSettingsVModel.errorNotificationsRecipientCategory.options[0].value,
            'Send Error Notificiation recipient category valid option for User should have expected value.'
        );
        System.assertEquals(
            'User Label',
            errorSettingsVModel.errorNotificationsRecipientCategory.options[0].label,
            'Send Error Notificiation recipient category valid option for User should have expected label.'
        );

        ErrorSettingsVMapper_TEST.assertUserLookupResult(errorSettingsVModel.userOrChatterGroupLookupResult, userId);

        System.assertEquals(
            false,
            errorSettingsVModel.enableDebug,
            'Enable debug functionality should match expected value.'
        );

        System.assertEquals(
            true,
            errorSettingsVModel.errorHandling,
            'Error handling model property should match expected value.'
        );
    }

    /**
     * @description Helper method to assert user lookup results for user service stub
     */
    private static void assertUserLookupResult(LookupResult lookupResult, String userId) {
        System.assertNotEquals(null, lookupResult, 'Lookup Result should not be null.');
        System.assertEquals(
            'User Name',
            lookupResult.label,
            'Send Error Notification recipient lookup label should be the expected label.'
        );
        System.assertEquals(
            userId,
            lookupResult.value,
            'Send Error Notification recipient lookup value should be the expected value.'
        );
        System.assertEquals(
            'standard:avatar',
            lookupResult.icon,
            'Send Error Notification recipient lookup icon should be the expected icon.'
        );
        System.assertEquals(
            'User SObject Label',
            lookupResult.alternativeText,
            'Send Error Notification recipient lookup alternative text should be the expected value.'
        );
        System.assertEquals(
            'https://example.com/user.png',
            lookupResult.imageUrl,
            'Send Error Notification recipient lookup image url should be the expected value.'
        );
        System.assertEquals(
            'user@test.com',
            lookupResult.meta,
            'Send Error Notification recipient lookup meta should be the expected value.'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getErrorSettingsViewModelValid method returns a ComboboxVModel that reflects the
     * error settings set in hierarchy settings
     ***********************************************************************************************************************************/
    @isTest
    private static void getErrorNotificationsRecipientCategoryVModel() {
        ErrorSettingsVMapper errorSettingsVMapperInstance = ErrorSettingsVMapper.getInstance();
        ErrorSettingsService.instance = new STUB_ErrorSettingsServiceAllSysAdmins();

        ErrorSettingsModel errorSettingsModel = ErrorSettingsService.getInstance().getErrorSettingsModel();

        Test.startTest();
        ComboboxVModel comboboxVModel = errorSettingsVMapperInstance.getErrorNotificationsRecipientCategoryVModel(
            errorSettingsModel
        );
        Test.stopTest();

        System.assertEquals(
            'All Sys Admins',
            comboboxVModel.value,
            'Combobox View Model value should match expected value.'
        );
        System.assertEquals(
            1,
            comboboxVModel.options.size(),
            'Combobox View Model valid options should match expected size.'
        );
        System.assertEquals(
            'All Sys Admins',
            comboboxVModel.options[0].value,
            'Combobox View Model valid option for All Sys Admins should have expected value.'
        );
        System.assertEquals(
            'All Sys Admins Label',
            comboboxVModel.options[0].label,
            'Combobox View Model valid option for All Sys Admins should have expected label.'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getLookupResultForSetting method returns a LookupResult that reflects the error
     * settings set in hierarchy settings
     ***********************************************************************************************************************************/
    @isTest
    private static void getLookupResultForSettingAllSysAdmins() {
        ErrorSettingsVMapper errorSettingsVMapperInstance = ErrorSettingsVMapper.getInstance();

        Test.startTest();
        LookupResult lookupResult = errorSettingsVMapperInstance.getLookupResultForSetting(
            'All Sys Admins',
            'All Sys Admins'
        );
        Test.stopTest();

        System.assertEquals(null, lookupResult, 'Lookup result should be null for \'All Sys Admins\'.');
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getLookupResultForSetting method returns a LookupResult that reflects the error
     * settings set in hierarchy settings
     ***********************************************************************************************************************************/
    @isTest
    private static void getLookupResultForSettingInvalid() {
        ErrorSettingsVMapper errorSettingsVMapperInstance = ErrorSettingsVMapper.getInstance();

        Test.startTest();
        LookupResult lookupResult = errorSettingsVMapperInstance.getLookupResultForSetting('Bad Value', 'Bad Value');
        Test.stopTest();

        System.assertEquals(null, lookupResult, 'Lookup result should be null for invalid values.');
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getLookupResultForSetting method returns a LookupResult that reflects the error
     * settings set in hierarchy settings
     ***********************************************************************************************************************************/
    @isTest
    private static void getLookupResultForSettingUserValid() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.getSObjectType());
        ErrorSettingsService.instance = new STUB_ErrorSettingsServiceUser(userId);
        UserService.instance = new STUB_UserService(userId);
        ErrorSettingsVMapper errorSettingsVMapperInstance = ErrorSettingsVMapper.getInstance();

        Test.startTest();
        LookupResult lookupResult = errorSettingsVMapperInstance.getLookupResultForSetting('User', userId);
        Test.stopTest();

        ErrorSettingsVMapper_TEST.assertUserLookupResult(lookupResult, userId);
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getLookupResultForSetting method returns a LookupResult that reflects the error
     * settings set in hierarchy settings
     ***********************************************************************************************************************************/
    @isTest
    private static void getLookupResultForSettingUserInvalidId() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.getSObjectType());
        Id unfoundUserId = UTIL_UnitTestData_TEST.getFakeId(User.getSObjectType());
        ErrorSettingsService.instance = new STUB_ErrorSettingsServiceUser(unfoundUserId);
        UserService.instance = new STUB_UserService(userId);
        ErrorSettingsVMapper errorSettingsVMapperInstance = ErrorSettingsVMapper.getInstance();

        Test.startTest();
        LookupResult lookupResult = errorSettingsVMapperInstance.getLookupResultForSetting('User', unfoundUserId);
        Test.stopTest();

        System.assertEquals(null, lookupResult, 'Lookup result should be null for an unfound user id.');
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getLookupResultForSetting method returns a LookupResult that reflects the error
     * settings set in hierarchy settings
     ***********************************************************************************************************************************/
    @isTest
    private static void getUserLookupResultByIdValid() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.getSObjectType());
        ErrorSettingsService.instance = new STUB_ErrorSettingsServiceUser(userId);
        UserService.instance = new STUB_UserService(userId);
        ErrorSettingsVMapper errorSettingsVMapperInstance = ErrorSettingsVMapper.getInstance();

        Test.startTest();
        LookupResult lookupResult = errorSettingsVMapperInstance.getUserLookupResultById(userId);
        Test.stopTest();

        ErrorSettingsVMapper_TEST.assertUserLookupResult(lookupResult, userId);
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getLookupResultForSetting method returns a LookupResult that reflects the error
     * settings set in hierarchy settings
     ***********************************************************************************************************************************/
    @isTest
    private static void getUserLookupResultByIdUnfoundUserId() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.getSObjectType());
        Id unfoundUserId = UTIL_UnitTestData_TEST.getFakeId(User.getSObjectType());
        ErrorSettingsService.instance = new STUB_ErrorSettingsServiceUser(unfoundUserId);
        UserService.instance = new STUB_UserService(userId);
        ErrorSettingsVMapper errorSettingsVMapperInstance = ErrorSettingsVMapper.getInstance();

        Test.startTest();
        LookupResult lookupResult = errorSettingsVMapperInstance.getUserLookupResultById(unfoundUserId);
        Test.stopTest();

        System.assertEquals(null, lookupResult, 'Lookup result should be null for an unfound user id.');
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getLookupResultForSetting method returns a LookupResult that reflects the error
     * settings set in hierarchy settings
     ***********************************************************************************************************************************/
    @isTest
    private static void getUserLookupResultByIdNonId() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.getSObjectType());
        ErrorSettingsService.instance = new STUB_ErrorSettingsServiceUser(userId);
        UserService.instance = new STUB_UserService(userId);
        ErrorSettingsVMapper errorSettingsVMapperInstance = ErrorSettingsVMapper.getInstance();

        Test.startTest();
        LookupResult lookupResult = errorSettingsVMapperInstance.getUserLookupResultById('Not an Id.');
        Test.stopTest();

        System.assertEquals(null, lookupResult, 'Lookup result should be null for a non-id.');
    }

    /**************************************************************************************************************************
     ****************************************************** STUBS **************************************************************
     **************************************************************************************************************************/

    /*********************************************************************************************************************
     * @description Stub class to simulate the response from ErrorSettingsService to return a valid ErrorSettingsModel
     *********************************************************************************************************************/
    private class STUB_ErrorSettingsServiceAllSysAdmins extends ErrorSettingsService {
        public Map<String, String> validErrorNotificationRecipientCategoryLabelsByValue = new Map<String, String>{
            'All Sys Admins' => 'All Sys Admins Label'
        };

        public override ErrorSettingsModel getErrorSettingsModel() {
            return new ErrorSettingsModel(
                true,
                true,
                'All Sys Admins',
                'All Sys Admins',
                false,
                true,
                this.validErrorNotificationRecipientCategoryLabelsByValue
            );
        }
    }

    /*********************************************************************************************************************
     * @description Stub class to simulate the response from ErrorSettingsService to return a valid ErrorSettingsModel
     *********************************************************************************************************************/
    private class STUB_ErrorSettingsServiceUser extends ErrorSettingsService {
        public String userId;

        public STUB_ErrorSettingsServiceUser(String userId) {
            this.userId = userId;
        }

        public Map<String, String> validErrorNotificationRecipientCategoryLabelsByValue = new Map<String, String>{
            'User' => 'User Label'
        };

        public override ErrorSettingsModel getErrorSettingsModel() {
            return new ErrorSettingsModel(
                true,
                true,
                'User',
                this.userId,
                false,
                true,
                this.validErrorNotificationRecipientCategoryLabelsByValue
            );
        }
    }

    /*********************************************************************************************************************
     * @description Stub class to simulate the response from ErrorSettingsService to return a valid ErrorSettingsModel
     *********************************************************************************************************************/
    private class STUB_UserService extends UserService {
        public Id userId;

        public STUB_UserService(Id userId) {
            this.userId = userId;
        }

        public override UserModel getUserModelById(Id userId) {
            if (userId != this.userId) {
                return null;
            }

            return new UserModel(
                Id.valueOf(this.userId),
                'User Name',
                true,
                'user@test.com',
                'https://example.com/user.png'
            );
        }

        public override String getModelObjectLabel() {
            return 'User SObject Label';
        }
    }
}
