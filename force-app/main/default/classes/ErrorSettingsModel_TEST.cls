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
 * @description Test class for ErrorSettingsModel
 */
@isTest
public with sharing class ErrorSettingsModel_TEST {
    /********************************************************************************************
     * @description Test to verify the constructor returns a model with all properties populated.
     ********************************************************************************************/
    @isTest
    private static void SevenArgumentConstructorValid() {
        Map<String, String> validErrorNotificationRecipientCategoryLabelsByValue = new Map<String, String>{
            'All Sys Admins' => 'All Sys Admins Label'
        };

        Test.startTest();
        ErrorSettingsModel errorSettingsModel = new ErrorSettingsModel(
            true,
            true,
            'All Sys Admins',
            'All Sys Admins',
            true,
            false,
            validErrorNotificationRecipientCategoryLabelsByValue
        );
        Test.stopTest();

        System.assertEquals(true, errorSettingsModel.storeErrors, 'Store errors functionality should be enabled.');
        System.assertEquals(
            true,
            errorSettingsModel.sendErrorNotifications,
            'Send error notifications functionality should be enabled.'
        );
        System.assertEquals(
            'All Sys Admins',
            errorSettingsModel.errorNotificationsRecipientCategory,
            'Send error notifications recipient category should be \'All Sys Admins\'.'
        );
        System.assertEquals(
            'All Sys Admins',
            errorSettingsModel.errorNotificationsRecipient,
            'Send error notifications recipient should be \'All Sys Admins\'.'
        );
        System.assertEquals(true, errorSettingsModel.enableDebug, 'Debug functionality should be enabled.');
        System.assertEquals(
            false,
            errorSettingsModel.errorHandling,
            'Error handling functionality should not be enabled.'
        );
        System.assertEquals(
            1,
            errorSettingsModel.validErrorNotificationsRecipientCategoryLabelsByValue.size(),
            'Valid error notification recipient categories should have 1 value.'
        );
        System.assertEquals(
            'All Sys Admins Label',
            errorSettingsModel.validErrorNotificationsRecipientCategoryLabelsByValue.get('All Sys Admins'),
            'Valid error notification recipient categories label for \'All Sys Admins\' should be \'All Sys Admins Label\'.'
        );
    }
}
