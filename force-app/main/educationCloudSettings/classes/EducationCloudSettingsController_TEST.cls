@isTest
private class EducationCloudSettingsController_TEST {
    @isTest
    private static void testGetProductRegistrySettingsProductInformationVModels() {
        String action = 'testAction';
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 50.0;
        ProductRegistryVMapper.instance = new ProductRegistryVMapperStub();

        Test.startTest();
        List<ProductRegistryVModel> productRegistryList = EducationCloudSettingsController.getProductRegistrySettingsProductInformationVModels();
        Test.stopTest();

        System.assertEquals(1, productRegistryList.size(), 'productRegistryList size should be 1');

        ProductRegistryVModel model = productRegistryList.get(0);
        System.assertEquals(action, model.action, 'action should be set with the value: ' + action);
        System.assertEquals(namespace, model.namespace, 'namespace should be set with the value: ' + namespace);
        System.assertEquals(classname, model.classname, 'classname should be set with the value: ' + classname);
        System.assertEquals(apiVersion, model.apiVersion, 'apiVersion should be set with the value: ' + apiVersion);
    }

    @isTest
    private static void testExceptionGetProductRegistrySettingsProductInformationVModels() {
        String action = 'testAction';
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 50.0;
        String exceptionMessage;
        ProductRegistryVMapper.instance = new ProductRegistryVMapperExceptionStub();

        Test.startTest();
        try {
            List<ProductRegistryVModel> productRegistryList = EducationCloudSettingsController.getProductRegistrySettingsProductInformationVModels();
            System.assert(true, 'this should not happen');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        System.assert(String.isNotBlank(exceptionMessage), 'exceptionMessage should be not be blank');
    }

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

        EDCSettingsProductVModel productVModel;
        EDCSettingsProductVMapper.instance = new EDCSettingsProductVMapperStub();

        Test.startTest();
        productVModel = EducationCloudSettingsController.getEDCSettingsProductVModel(productRegistry);
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
        String action = 'testAction';
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 50.0;
        String exceptionMessage;
        ProductRegistryVModel registryModel = new ProductRegistryVModel(action, namespace, classname, apiVersion);
        String productRegistry = JSON.serialize(registryModel);

        EDCSettingsProductVModel productVModel;
        EDCSettingsProductVMapper.instance = new EDCSettingsProductVMapperExceptionStub();

        Test.startTest();
        try {
            productVModel = EducationCloudSettingsController.getEDCSettingsProductVModel(productRegistry);
            System.assert(true, 'this should not happen');
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();

        System.assert(String.isNotBlank(exceptionMessage), 'exceptionMessage should be not be blank');
    }

    private class ProductRegistryVMapperStub extends ProductRegistryVMapper {
        public override List<ProductRegistryVModel> getProductRegistrySettingsProductInformation() {
            ProductRegistryVModel model = new ProductRegistryVModel(
                'testAction',
                'testNamespace',
                'testClassname',
                50.0
            );
            return new List<ProductRegistryVModel>{ model };
        }
    }

    private class ProductRegistryVMapperExceptionStub extends ProductRegistryVMapper {
        public override List<ProductRegistryVModel> getProductRegistrySettingsProductInformation() {
            throw new AuraHandledException('testExceptionMessage');
        }
    }

    private class EDCSettingsProductVMapperStub extends EDCSettingsProductVMapper {
        public override EDCSettingsProductVModel getEDCSettingsProductVModel(String productRegistry) {
            EDCSettingsProductVModel model = new EDCSettingsProductVModel(
                'testInitials',
                'testName',
                'testDescription',
                'c__testSettingsComponent',
                'testDocumentationUrl',
                'testTrailheadUrl',
                'testIcon'
            );
            return model;
        }
    }

    private class EDCSettingsProductVMapperExceptionStub extends EDCSettingsProductVMapper {
        public override EDCSettingsProductVModel getEDCSettingsProductVModel(String productRegistry) {
            throw new AuraHandledException('testExceptionMessage');
        }
    }
}
