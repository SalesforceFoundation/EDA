@isTest
private class EDASettingsProductInfoAPIService_TEST {
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
