@isTest
private class ProductRegistryModel_TEST {
    @isTest
    private static void testConstructor() {
        String action = 'testAction';
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 50.0;

        ProductRegistryModel model;

        Test.startTest();
        model = new ProductRegistryModel(action, namespace, classname, apiVersion);
        Test.stopTest();

        System.assertEquals(action, model.action, 'action should be set with the value it is passed');
        System.assertEquals(namespace, model.namespace, 'namespace should be set with the value it is passed');
        System.assertEquals(classname, model.classname, 'classname should be set with the value it is passed');
        System.assertEquals(apiVersion, model.apiVersion, 'apiVersion should be set with the value it is passed');
    }
}
