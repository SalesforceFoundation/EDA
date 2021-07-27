@isTest
private class EDCSettingsProductVMapper_TEST {
    @isTest
    private static void testGetEDCSettingsProductVModel() {
        String initials = 'testInitials';
        String name = 'testName';
        String description = 'testDescription';
        String settingsComponent = 'c__testSettingsComponent';
        String documentationUrl = 'testDocumentationUrl';
        String trailheadUrl = 'testTrailheadUrl';
        String icon = 'testIcon';
        String action = 'testAction';
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 50.0;

        ProductRegistryVModel registryModel = new ProductRegistryVModel(action, namespace, classname, apiVersion);
        String productRegistry = JSON.serialize(registryModel);

        EDCSettingsProductAPIService.instance = new EDCSettingsProductAPIServiceStub();
        EDCSettingsProductVModel productVModel;

        Test.startTest();
        productVModel = EDCSettingsProductVMapper.getInstance().getEDCSettingsProductVModel(productRegistry);
        Test.stopTest();

        System.assertEquals(initials, productVModel.initials, 'initials should be set to ' + initials);
        System.assertEquals(name, productVModel.name, 'name should be set to ' + name);
        System.assertEquals(description, productVModel.description, 'description should be set to ' + description);
        System.assertEquals(
            settingsComponent,
            productVModel.settingsComponent,
            'settingsComponent should be set to ' + settingsComponent
        );
        System.assertEquals(
            documentationUrl,
            productVModel.documentationUrl,
            'documentationUrl should be set to ' + documentationUrl
        );
        System.assertEquals(trailheadUrl, productVModel.trailheadUrl, 'trailheadUrl should be set to ' + trailheadUrl);
        System.assertEquals(icon, productVModel.icon, 'icon should be set to ' + icon);
    }

    @isTest
    private static void testExceptionGetEDCSettingsProductVModel() {
        String initials = 'testInitials';
        String name = 'testName';
        String description = 'testDescription';
        String settingsComponent = 'c__testSettingsComponent';
        String documentationUrl = 'testDocumentationUrl';
        String trailheadUrl = 'testTrailheadUrl';
        String icon = 'testIcon';
        String action = 'testAction';
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 50.0;
        String exceptionMessage;

        ProductRegistryVModel registryModel = new ProductRegistryVModel(action, namespace, classname, apiVersion);
        String productRegistry = JSON.serialize(registryModel);

        EDCSettingsProductAPIService.instance = new EDCSettingsProductAPIServiceErrorStub();
        EDCSettingsProductVModel productVModel;

        Test.startTest();
        try {
            productVModel = EDCSettingsProductVMapper.getInstance().getEDCSettingsProductVModel(productRegistry);
            System.assert(true, 'this should not happen');
        } catch (EDCSettingsProductVMapper.SettingsProductException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertNotEquals(null, exceptionMessage, 'exception message should not be null');
    }

    private class EDCSettingsProductAPIServiceStub extends EDCSettingsProductAPIService {
        public override EDCSettingsProductAPIModel.SettingsProductInformationActionResult getSettingsProductInformation(
            String className,
            String namespace,
            Decimal apiVersion
        ) {
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
            return actionResult;
        }
    }
    private class EDCSettingsProductAPIServiceErrorStub extends EDCSettingsProductAPIService {
        public override EDCSettingsProductAPIModel.SettingsProductInformationActionResult getSettingsProductInformation(
            String className,
            String namespace,
            Decimal apiVersion
        ) {
            CallableError error = new CallableError(400, 'testErrorMessage');
            EDCSettingsProductAPIModel.SettingsProductInformationActionResult actionResult = new EDCSettingsProductAPIModel.SettingsProductInformationActionResult(
                null,
                false,
                error
            );
            return actionResult;
        }
    }
}
