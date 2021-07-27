/*
    Copyright (c) 2021, Salesforce.org
    All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
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
 * @group-content
 * @description Test class for EDASettingsProductInformationAPIService
 */
@isTest
private class EDASettingsProductInfoAPIService_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify the call method of EDASettingsProductInformationAPIService
     * returns the EDCSettingsProductAPIModel.SettingsProductInformationActionResult instance correctly
     ***************************************************************************************************************************/
    @isTest
    private static void testCallable() {
        String settingsInformationJSON;
        String classname = 'EDASettingsProductInformationAPIService';
        String action = 'Settings Product Information';
        Decimal apiVersion = 50.0;
        Map<String, Object> args = new Map<String, Object>{ 'Api Version' => apiVersion };

        Test.startTest();

        Type settingsProductInformationAPIServiceType = Type.forName('', classname);
        Callable settingsProductInformationAPIService = (Callable) settingsProductInformationAPIServiceType.newInstance();

        settingsInformationJSON = (String) settingsProductInformationAPIService.call(action, args);

        Test.stopTest();

        EDCSettingsProductAPIModel.SettingsProductInformationActionResult actionResult = (EDCSettingsProductAPIModel.SettingsProductInformationActionResult) JSON.deserialize(
            settingsInformationJSON,
            EDCSettingsProductAPIModel.SettingsProductInformationActionResult.class
        );

        System.assertEquals(true, actionResult.success, 'success should be true');
        System.assertEquals(null, actionResult.error, 'error should be null');
        System.assertNotEquals(null, actionResult.result, 'result should not be null');
        System.assertNotEquals(null, actionResult.result.productInformation, 'productInformation should not be null');

        EDCSettingsProductAPIModel.SettingsProductInformation product = actionResult.result.productInformation;
        System.assertEquals(
            EDASettingsProductInformationAPIService.PRODUCT_EDA_DESCRIPTION,
            product.description,
            'description should be set to ' + EDASettingsProductInformationAPIService.PRODUCT_EDA_DESCRIPTION
        );
        System.assertEquals(
            EDASettingsProductInformationAPIService.PRODUCT_EDA_INITIALS,
            product.initials,
            'initials should be set to ' + EDASettingsProductInformationAPIService.PRODUCT_EDA_INITIALS
        );
        System.assertEquals(
            EDASettingsProductInformationAPIService.PRODUCT_EDA_NAME,
            product.name,
            'name should be set to ' + EDASettingsProductInformationAPIService.PRODUCT_EDA_NAME
        );
        System.assertEquals(
            EDASettingsProductInformationAPIService.PRODUCT_EDA_SETTINGSCOMPONENT,
            product.settingsComponent,
            'settingsComponent should be set to ' +
            EDASettingsProductInformationAPIService.PRODUCT_EDA_SETTINGSCOMPONENT
        );
        System.assertEquals(
            EDASettingsProductInformationAPIService.PRODUCT_EDA_DOCUMENTATIONURL,
            product.documentationUrl,
            'documentationUrl should be set to ' + EDASettingsProductInformationAPIService.PRODUCT_EDA_DOCUMENTATIONURL
        );
        System.assertEquals(
            EDASettingsProductInformationAPIService.PRODUCT_EDA_TRAILHEADURL,
            product.trailheadUrl,
            'trailheadUrl should be set to ' + EDASettingsProductInformationAPIService.PRODUCT_EDA_TRAILHEADURL
        );
        System.assertEquals(
            EDASettingsProductInformationAPIService.PRODUCT_EDA_ICON,
            product.icon,
            'icon should be set to ' + EDASettingsProductInformationAPIService.PRODUCT_EDA_ICON
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify an instance of EDCSettingsProductAPIModel.SettingsProductInformationActionResult
     * is returned with the success property set to false and the error property populated, when the provided Action is incorrect
     ***************************************************************************************************************************/
    @isTest
    private static void testCallableWrongAction() {
        String settingsInformationJSON;
        String classname = 'EDASettingsProductInformationAPIService';
        String action = 'Edit Info';
        Decimal apiVersion = 50.0;
        Map<String, Object> args = new Map<String, Object>{ 'Api Version' => apiVersion };

        Test.startTest();

        Type settingsProductInformationAPIServiceType = Type.forName('', classname);
        Callable settingsProductInformationAPIService = (Callable) settingsProductInformationAPIServiceType.newInstance();

        settingsInformationJSON = (String) settingsProductInformationAPIService.call(action, args);

        Test.stopTest();

        EDCSettingsProductAPIModel.SettingsProductInformationActionResult actionResult = (EDCSettingsProductAPIModel.SettingsProductInformationActionResult) JSON.deserialize(
            settingsInformationJSON,
            EDCSettingsProductAPIModel.SettingsProductInformationActionResult.class
        );

        System.assertEquals(false, actionResult.success, 'success should be false');
        System.assertEquals(null, actionResult.result, 'result should be null');
        System.assertNotEquals(null, actionResult.error, 'error should not be null');
        System.assertEquals(400, actionResult.error.code, 'error code should be 400');
        System.assertEquals(
            'Method: ' +
            action +
            ' not implemented',
            actionResult.error.message,
            'the error message is incorrect'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify an instance of EDCSettingsProductAPIModel.SettingsProductInformationActionResult
     * is returned with the success property set to false and the error property populated, when the provided apiVesrion is null
     ***************************************************************************************************************************/
    @isTest
    private static void testCallableNoApiVersion() {
        String settingsInformationJSON;
        String classname = 'EDASettingsProductInformationAPIService';
        String action = 'Settings Product Information';
        Decimal apiVersion;
        Map<String, Object> args = new Map<String, Object>{ 'Api Version' => apiVersion };

        Test.startTest();

        Type settingsProductInformationAPIServiceType = Type.forName('', classname);
        Callable settingsProductInformationAPIService = (Callable) settingsProductInformationAPIServiceType.newInstance();

        settingsInformationJSON = (String) settingsProductInformationAPIService.call(action, args);

        Test.stopTest();

        EDCSettingsProductAPIModel.SettingsProductInformationActionResult actionResult = (EDCSettingsProductAPIModel.SettingsProductInformationActionResult) JSON.deserialize(
            settingsInformationJSON,
            EDCSettingsProductAPIModel.SettingsProductInformationActionResult.class
        );

        System.assertEquals(false, actionResult.success, 'success should be false');
        System.assertEquals(null, actionResult.result, 'result should be null');
        System.assertNotEquals(null, actionResult.error, 'error should not be null');
        System.assertEquals(400, actionResult.error.code, 'error code should be 400');
        System.assertEquals(
            'You gotta have an API version!',
            actionResult.error.message,
            'the error message is incorrect'
        );
    }
}
