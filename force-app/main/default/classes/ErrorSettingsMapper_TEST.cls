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
 * @description Test class for ErrorSettingsMapper
 */
@isTest
private with sharing class ErrorSettingsMapper_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * ErrorSettingsMapper class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        ErrorSettingsMapper errorSettingsMapperInstance = ErrorSettingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ErrorSettingsMapper.instance,
            errorSettingsMapperInstance,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(true, errorSettingsMapperInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * ErrorSettingsMapper class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        ErrorSettingsMapper errorSettingsMapperInstance1 = ErrorSettingsMapper.getInstance();

        ErrorSettingsMapper errorSettingsMapperInstance2 = ErrorSettingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ErrorSettingsMapper.instance,
            errorSettingsMapperInstance1,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            errorSettingsMapperInstance1,
            errorSettingsMapperInstance2,
            'Subsequent retrievals of service class instance should return existing instance.'
        );

        System.assertEquals(
            true,
            errorSettingsMapperInstance1 != null,
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getErrorSettingsModel method returns an ErrorSettingsModel with properties
     * set to match those in Hierarchy Settings when the send error notifications recipient is all sys admins.
     ***************************************************************************************************************************/
    @isTest
    private static void getErrorSettingsModelValidAllSysAdmins() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Store_Errors_On__c = true,
                Error_Notifications_On__c = true,
                Error_Notifications_To__c = 'All Sys Admins',
                Enable_Debug__c = false,
                Disable_Error_Handling__c = false
            )
        );

        ErrorSettingsMapper errorSettingsMapperInstance = ErrorSettingsMapper.getInstance();

        Test.startTest();
        ErrorSettingsModel errorSettingsModel = errorSettingsMapperInstance.getErrorSettingsModel();
        Test.stopTest();

        ErrorSettingsMapper_TEST.assertSettingBooleans(errorSettingsModel);

        System.assertEquals(
            'All Sys Admins',
            errorSettingsModel.errorNotificationsRecipientCategory,
            'Send Error Notifications Recipient category on resulting model should match determination based on value set in hierarchy settings.'
        );

        System.assertEquals(
            'All Sys Admins',
            errorSettingsModel.errorNotificationsRecipient,
            'Send Error Notifications Recipient on resulting model should match value set in hierarchy settings.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getErrorSettingsModel method returns an ErrorSettingsModel with properties
     * set to match those in Hierarchy Settings when the send error notifications recipient is a user.
     ***************************************************************************************************************************/
    @isTest
    private static void getErrorSettingsModelValidUser() {
        String fakeUserId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Store_Errors_On__c = true,
                Error_Notifications_On__c = true,
                Error_Notifications_To__c = fakeUserId,
                Enable_Debug__c = false,
                Disable_Error_Handling__c = false
            )
        );

        ErrorSettingsMapper errorSettingsMapperInstance = ErrorSettingsMapper.getInstance();

        Test.startTest();
        ErrorSettingsModel errorSettingsModel = errorSettingsMapperInstance.getErrorSettingsModel();
        Test.stopTest();

        ErrorSettingsMapper_TEST.assertSettingBooleans(errorSettingsModel);

        System.assertEquals(
            'User',
            errorSettingsModel.errorNotificationsRecipientCategory,
            'Send Error Notifications Recipient category on resulting model should match determination based on value set in hierarchy settings.'
        );

        System.assertEquals(
            fakeUserId,
            errorSettingsModel.errorNotificationsRecipient,
            'Send Error Notifications Recipient on resulting model should match value set in hierarchy settings.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getErrorSettingsModel method returns an ErrorSettingsModel with properties
     * set to match those in Hierarchy Settings when the send error notifications recipient is a chatter group
     ***************************************************************************************************************************/
    @isTest
    private static void getErrorSettingsModelValidChatterGroup() {
        if (!Schema.SObjectType.User.isFeedEnabled()) {
            return;
        }

        String fakeChatterGroupId = UTIL_UnitTestData_TEST.getChatterGroupNoDependencyFakeId();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Store_Errors_On__c = true,
                Error_Notifications_On__c = true,
                Error_Notifications_To__c = fakeChatterGroupId,
                Enable_Debug__c = false,
                Disable_Error_Handling__c = false
            )
        );

        ErrorSettingsMapper errorSettingsMapperInstance = ErrorSettingsMapper.getInstance();

        Test.startTest();
        ErrorSettingsModel errorSettingsModel = errorSettingsMapperInstance.getErrorSettingsModel();
        Test.stopTest();

        ErrorSettingsMapper_TEST.assertSettingBooleans(errorSettingsModel);

        System.assertEquals(
            'Chatter Group',
            errorSettingsModel.errorNotificationsRecipientCategory,
            'Send Error Notifications Recipient category on resulting model should match determination based on value set in hierarchy settings.'
        );

        System.assertEquals(
            fakeChatterGroupId,
            errorSettingsModel.errorNotificationsRecipient,
            'Send Error Notifications Recipient on resulting model should match value set in hierarchy settings.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getErrorSettingsModel method returns an ErrorSettingsModel with properties
     * set to match those in Hierarchy Settings when the send error notifications recipient is a chatter group when chatter is
     * disabled
     ***************************************************************************************************************************/
    @isTest
    private static void getErrorSettingsModelValidChatterGroupChatterDisabled() {
        if (Schema.SObjectType.User.isFeedEnabled()) {
            return;
        }
        String fakeChatterGroupId = UTIL_UnitTestData_TEST.getChatterGroupNoDependencyFakeId();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Store_Errors_On__c = true,
                Error_Notifications_On__c = true,
                Error_Notifications_To__c = fakeChatterGroupId,
                Enable_Debug__c = false,
                Disable_Error_Handling__c = false
            )
        );

        ErrorSettingsMapper errorSettingsMapperInstance = ErrorSettingsMapper.getInstance();

        Test.startTest();
        ErrorSettingsModel errorSettingsModel = errorSettingsMapperInstance.getErrorSettingsModel();
        Test.stopTest();

        ErrorSettingsMapper_TEST.assertSettingBooleans(errorSettingsModel);

        System.assertEquals(
            null,
            errorSettingsModel.errorNotificationsRecipientCategory,
            'Error recipient category should be null if chatter is not enabled.'
        );

        System.assertEquals(
            fakeChatterGroupId,
            errorSettingsModel.errorNotificationsRecipient,
            'Send Error Notifications Recipient on resulting model should match value set in hierarchy settings.'
        );
    }

    /**************************************************************************************************************************
     * @description Helper assert method to assert error settings model booleans to make permutations easier to read
     ***************************************************************************************************************************/
    private static void assertSettingBooleans(ErrorSettingsModel errorSettingsModel) {
        System.assertEquals(
            true,
            errorSettingsModel.storeErrors,
            'Store Errors on resulting model should match value set in hierarchy settings.'
        );

        System.assertEquals(
            true,
            errorSettingsModel.sendErrorNotifications,
            'Send Error Notifications on resulting model should match value set in hierarchy settings.'
        );

        System.assertEquals(
            false,
            errorSettingsModel.enableDebug,
            'Enable Debug on resulting model should match value set in hierarchy settings.'
        );

        System.assertEquals(
            true,
            errorSettingsModel.errorHandling,
            'Error handling on resulting model should be inverse of value set in hierarchy settings.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the user id prefix retrieves the appropriate prefix for the user SObject
     ***************************************************************************************************************************/
    @isTest
    private static void getUserIdPrefix() {
        ErrorSettingsMapper errorSettingsMapperInstance = ErrorSettingsMapper.getInstance();

        Test.startTest();
        String userIdPrefix = errorSettingsMapperInstance.getUserIdPrefix();
        Test.stopTest();

        System.assertEquals(
            User.SObjectType.getDescribe().getKeyPrefix(),
            userIdPrefix,
            'User Id Prefix identified should match the prefix from the schema.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the chatter group id prefix retrieves the appropriate prefix for the user SObject
     ***************************************************************************************************************************/
    @isTest
    private static void getChatterGroupIdPrefix() {
        //Avoid hard chatter dependency
        if (!Schema.SObjectType.User.isFeedEnabled()) {
            return;
        }

        ErrorSettingsMapper errorSettingsMapperInstance = ErrorSettingsMapper.getInstance();

        String expectedKeyPrefix = UTIL_Describe.getObjectDescribe('CollaborationGroup').getKeyPrefix();

        Test.startTest();
        String chatterGroupIdPrefix = errorSettingsMapperInstance.getChatterGroupIdPrefix();
        Test.stopTest();

        System.assertEquals(
            expectedKeyPrefix,
            chatterGroupIdPrefix,
            'Chatter Group Id Prefix identified should match the prefix from the schema.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the expected valid error notification recipient categories are pulled
     ***************************************************************************************************************************/
    @isTest
    private static void getValidErrorNotificationRecipientCategoryLabelsByValue() {
        if (!Schema.SObjectType.User.isFeedEnabled()) {
            return;
        }
        ErrorSettingsMapper errorSettingsMapperInstance = ErrorSettingsMapper.getInstance();

        Test.startTest();
        Map<String, String> validErrorNotificationRecipientCategoryLabelsByValue = errorSettingsMapperInstance.getValidErrorNotificationRecipientCategoryLabelsByValue();
        Test.stopTest();

        System.assertEquals(
            3,
            validErrorNotificationRecipientCategoryLabelsByValue.size(),
            'Only 3 values should be pulled for valid error notification recipient categories.'
        );
        System.assertEquals(
            Label.stgOptAllSysAdmins,
            validErrorNotificationRecipientCategoryLabelsByValue.get('All Sys Admins'),
            'The label for \'All Sys Admins\' should be the expected value.'
        );
        System.assertEquals(
            Label.stgOptUser,
            validErrorNotificationRecipientCategoryLabelsByValue.get('User'),
            'The label for \'User\' should be the expected value.'
        );
        System.assertEquals(
            Label.stgOptChatterGroup,
            validErrorNotificationRecipientCategoryLabelsByValue.get('Chatter Group'),
            'The label for \'Chatter Group\' should be the expected value.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the expected valid error notification recipient categories are pulled
     ***************************************************************************************************************************/
    @isTest
    private static void getValidErrorNotificationRecipientCategoryLabelsByValueChatterDisabled() {
        if (Schema.SObjectType.User.isFeedEnabled()) {
            return;
        }

        ErrorSettingsMapper errorSettingsMapperInstance = ErrorSettingsMapper.getInstance();

        Test.startTest();
        Map<String, String> validErrorNotificationRecipientCategoryLabelsByValue = errorSettingsMapperInstance.getValidErrorNotificationRecipientCategoryLabelsByValue();
        Test.stopTest();

        System.assertEquals(
            2,
            validErrorNotificationRecipientCategoryLabelsByValue.size(),
            'Only 3 values should be pulled for valid error notification recipient categories.'
        );
        System.assertEquals(
            Label.stgOptAllSysAdmins,
            validErrorNotificationRecipientCategoryLabelsByValue.get('All Sys Admins'),
            'The label for \'All Sys Admins\' should be the expected value.'
        );
        System.assertEquals(
            Label.stgOptUser,
            validErrorNotificationRecipientCategoryLabelsByValue.get('User'),
            'The label for \'User\' should be the expected value.'
        );
        System.assertEquals(
            null,
            validErrorNotificationRecipientCategoryLabelsByValue.get('Chatter Group'),
            'No label should exist for chatter group when chatter is disabled.'
        );
    }
}
