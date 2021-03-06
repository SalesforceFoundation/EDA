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
 * @description Test class for ErrorSettingsVModel
 */
@isTest
private with sharing class ErrorSettingsVModel_TEST {
    /****************************************************************************
     * @description Test method to verify constructor returns a view model with
     * all properties populated.
     ****************************************************************************/
    @isTest
    private static void sixArugumentConstructorValid() {
        List<ComboboxValueVModel> errorNotificationsRecipientCategoryValues = new List<ComboboxValueVModel>{
            new ComboboxValueVModel('All Sys Admins Label', 'All Sys Admins')
        };
        ComboboxVModel errorNotificationsRecipientCategory = new ComboboxVModel(
            'All Sys Admins',
            errorNotificationsRecipientCategoryValues
        );
        LookupResult lookupResult = new LookupResult(
            'User Name',
            UTIL_UnitTestData_TEST.getFakeId(User.SObjectType),
            'standard:avatar',
            'https://example.com/test.png',
            'User',
            'Email'
        );

        Test.startTest();
        ErrorSettingsVModel errorSettingsVModel = new ErrorSettingsVModel(
            false,
            true,
            errorNotificationsRecipientCategory,
            true,
            true,
            lookupResult
        );
        Test.stopTest();

        System.assertEquals(false, errorSettingsVModel.storeErrors, 'Store errors functionality should be disabled.');
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
        System.assertEquals(false, errorSettingsVModel.storeErrors, 'Store errors functionality should be disabled.');
        System.assertEquals(true, errorSettingsVModel.enableDebug, 'Enable debug functionality should be enabled.');
        System.assertEquals(true, errorSettingsVModel.errorHandling, 'Error handling functionality should be enabled.');
        System.assert(
            lookupResult.equals(errorSettingsVModel.userOrChatterGroupLookupResult),
            'Lookup result for error settings should match that specified.'
        );
    }
}
