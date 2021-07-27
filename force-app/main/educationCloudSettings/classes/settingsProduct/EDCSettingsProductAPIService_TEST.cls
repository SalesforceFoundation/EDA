@isTest
private class EDCSettingsProductAPIService_TEST {
    @isTest
    private static void testGetSettingsProductInformation() {
        String classname = 'EDASettingsProductInformationAPIService';
        String namespace = 'hed';
        Decimal apiVersion = 50.0;
        String initials = 'testInitials';
        String name = 'testName';
        String description = 'testDescription';
        String settingsComponent = 'testSettingsComponent';
        String documentationUrl = 'testDocumentationUrl';
        String trailheadUrl = 'testTrailheadUrl';
        String icon = 'testIcon';

        EDCSettingsProductAPIService.instance = new EDCSettingsProductAPIServiceStub();
        EDCSettingsProductAPIModel.SettingsProductInformationActionResult actionResult;

        Test.startTest();
        actionResult = EDCSettingsProductAPIService.getInstance()
            .getSettingsProductInformation(classname, namespace, apiVersion);
        Test.stopTest();

        System.assertEquals(true, actionResult.success, 'success should be true');
        System.assertEquals(null, actionResult.error, 'error should be null');
        System.assertNotEquals(null, actionResult.result, 'result should not be null');
        System.assertNotEquals(null, actionResult.result.productInformation, 'productInformation should not be null');

        EDCSettingsProductAPIModel.SettingsProductInformation product = actionResult.result.productInformation;
        System.assertEquals(initials, product.initials, 'initials should be set to ' + initials);
        System.assertEquals(name, product.name, 'name should be set to ' + name);
        System.assertEquals(description, product.description, 'description should be set to ' + description);
        System.assertEquals(
            settingsComponent,
            product.settingsComponent,
            'settingsComponent should be set to ' + settingsComponent
        );
        System.assertEquals(
            documentationUrl,
            product.documentationUrl,
            'documentationUrl should be set to ' + documentationUrl
        );
        System.assertEquals(trailheadUrl, product.trailheadUrl, 'trailheadUrl should be set to ' + trailheadUrl);
        System.assertEquals(icon, product.icon, 'icon should be set to ' + icon);
    }

    @isTest
    private static void testExceptionLocateSettingsProductInfoApiService() {
        String classname = 'ABadClass';
        String namespace = 'hed';
        Callable edaCallable;
        String exceptionMessage;

        Test.startTest();
        try {
            edaCallable = EDCSettingsProductAPIService.getInstance()
                .locateSettingsProductInformationAPIService(classname, namespace);
            System.assert(true, 'this should not happen');
        } catch (EDCSettingsProductApiService.SettingsProductNotFoundException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertNotEquals(null, exceptionMessage, 'exception message should not be null');
    }

    @isTest
    private static void testMakeCallForCoverage() {
        String settingsInformationJSON;
        String classname = 'EDASettingsProductInformationAPIService';
        Decimal apiVersion = 50.0;
        Map<String, Object> args = new Map<String, Object>{ 'Api Version' => apiVersion };

        Test.startTest();

        Type settingsProductInformationAPIServiceType = Type.forName('', classname);
        Callable settingsProductInformationAPIService = (Callable) settingsProductInformationAPIServiceType.newInstance();

        settingsInformationJSON = EDCSettingsProductAPIService.getInstance()
            .makeCall(settingsProductInformationAPIService, apiVersion);

        Test.stopTest();

        EDCSettingsProductAPIModel.SettingsProductInformationActionResult actionResult = (EDCSettingsProductAPIModel.SettingsProductInformationActionResult) JSON.deserialize(
            settingsInformationJSON,
            EDCSettingsProductAPIModel.SettingsProductInformationActionResult.class
        );

        System.assertEquals(true, actionResult.success, 'success should be true');
        System.assertEquals(null, actionResult.error, 'error should be null');
        System.assertNotEquals(null, actionResult.result, 'result should not be null');
        System.assertNotEquals(null, actionResult.result.productInformation, 'productInformation should not be null');
    }

    private class EDCSettingsProductAPIServiceStub extends EDCSettingsProductAPIService {
        private override String makeCall(Callable settingsProductInformationAPIService, Decimal apiVersion) {
            EDCSettingsProductAPIModel.SettingsProductInformation productInformation = new EDCSettingsProductAPIModel.SettingsProductInformation(
                'testInitials',
                'testName',
                'testDescription',
                'testSettingsComponent',
                'testDocumentationUrl',
                'testTrailheadUrl',
                'testIcon'
            );
            EDCSettingsProductAPIModel.SettingsProductinformationResult productInformationResult = new EDCSettingsProductAPIModel.SettingsProductinformationResult(
                productInformation
            );
            EDCSettingsProductAPIModel.SettingsProductInformationActionResult actionResult = new EDCSettingsProductAPIModel.SettingsProductInformationActionResult(
                productInformationResult,
                true,
                null
            );
            return JSON.serialize(actionResult);
        }
    }
}
