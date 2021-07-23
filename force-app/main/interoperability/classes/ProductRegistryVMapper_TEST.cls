@isTest
private class ProductRegistryVMapper_TEST {
    @isTest
    private static void testGetProductRegistrySettingsProductInformation() {
        String action = 'testAction';
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 50.0;

        ProductRegistryService.instance = new ProductRegistryServiceStub();
        List<ProductRegistryVModel> prodRegistryModelList;

        Test.startTest();
        prodRegistryModelList = ProductRegistryVMapper.getInstance().getProductRegistrySettingsProductInformation();
        Test.stopTest();

        System.assert(prodRegistryModelList != null, 'prodRegistryModelList should not be null');
        System.assert(!prodRegistryModelList.isEmpty(), 'prodRegistryModelList should not be empty');
        System.assertEquals(1, prodRegistryModelList.size(), 'prodRegistryModelList should have 1 element');

        ProductRegistryVModel model = prodRegistryModelList.get(0);

        System.assertEquals(action, model.action, 'action should be set with the value: ' + action);
        System.assertEquals(namespace, model.namespace, 'namespace should be set with the value: ' + namespace);
        System.assertEquals(classname, model.classname, 'classname should be set with the value: ' + classname);
        System.assertEquals(apiVersion, model.apiVersion, 'apiVersion should be set with the value: ' + apiVersion);
    }

    private class ProductRegistryServiceStub extends ProductRegistryService {
        public override List<ProductRegistryModel> getProductRegistrySettingsProductInformation() {
            ProductRegistryModel prodRegistryModel = new ProductRegistryModel(
                'testAction',
                'testNamespace',
                'testClassname',
                50.0
            );
            return new List<ProductRegistryModel>{ prodRegistryModel };
        }
    }
}
