@isTest
private class ProductRegistryMapper_TEST {
    @isTest
    private static void testGetProductRegistrySettingsProductInformation() {
        String action = 'testAction';
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 50.0;

        ProductRegistryMapper.instance = new ProductRegistryMapperStub();
        List<ProductRegistryModel> prodRegistryModelList;

        Test.startTest();
        prodRegistryModelList = ProductRegistryMapper.getInstance().getProductRegistrySettingsProductInformation();
        Test.stopTest();

        System.assert(prodRegistryModelList != null, 'prodRegistryModelList should not be null');
        System.assert(!prodRegistryModelList.isEmpty(), 'prodRegistryModelList should not be empty');
        System.assertEquals(1, prodRegistryModelList.size(), 'prodRegistryModelList should have 1 element');

        ProductRegistryModel model = prodRegistryModelList.get(0);

        System.assertEquals(action, model.action, 'action should be set with the value: ' + action);
        System.assertEquals(namespace, model.namespace, 'namespace should be set with the value: ' + namespace);
        System.assertEquals(classname, model.classname, 'classname should be set with the value: ' + classname);
        System.assertEquals(apiVersion, model.apiVersion, 'apiVersion should be set with the value: ' + apiVersion);
    }

    @isTest
    private static void testJustForCoverage() {
        List<ProductRegistryModel> prodRegistryModelList;
        Test.startTest();
        prodRegistryModelList = ProductRegistryMapper.getInstance().getProductRegistrySettingsProductInformation();
        Test.stopTest();
    }

    private class ProductRegistryMapperStub extends ProductRegistryMapper {
        public override List<Product_Registry__mdt> getProductRegistriesByAction(String action) {
            Product_Registry__mdt prodRegistryCMT = new Product_Registry__mdt();
            prodRegistryCMT.Action__c = 'testAction';
            prodRegistryCMT.Namespace__c = 'testNamespace';
            prodRegistryCMT.Class_Name__c = 'testClassname';
            prodRegistryCMT.API_Version__c = 50.0;
            return new List<Product_Registry__mdt>{ prodRegistryCMT };
        }
    }
}
