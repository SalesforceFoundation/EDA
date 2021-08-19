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
 * @description Test class for ProductRegistryMapper
 */
@isTest
private class ProductRegistryMapper_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify the getProductRegistrySettingsProductInformation method returns the list
     * of ProductRegistryModel correctly
     ***************************************************************************************************************************/
    @isTest
    private static void testGetProductRegistrySettingsProductInformation() {
        String name = 'testName';
        String action = 'testAction';
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 52.0;

        ProductRegistryMapper.instance = new ProductRegistryMapperStub();
        List<ProductRegistryModel> prodRegistryModelList;

        Test.startTest();
        prodRegistryModelList = ProductRegistryMapper.getInstance().getProductRegistrySettingsProductInformation();
        Test.stopTest();

        System.assert(prodRegistryModelList != null, 'prodRegistryModelList should not be null');
        System.assert(!prodRegistryModelList.isEmpty(), 'prodRegistryModelList should not be empty');
        System.assertEquals(1, prodRegistryModelList.size(), 'prodRegistryModelList should have 1 element');

        ProductRegistryModel model = prodRegistryModelList.get(0);

        System.assertEquals(name, model.name, 'name should be set with the value: ' + name);
        System.assertEquals(action, model.action, 'action should be set with the value: ' + action);
        System.assertEquals(namespace, model.namespace, 'namespace should be set with the value: ' + namespace);
        System.assertEquals(classname, model.classname, 'classname should be set with the value: ' + classname);
        System.assertEquals(apiVersion, model.apiVersion, 'apiVersion should be set with the value: ' + apiVersion);
    }

    /**************************************************************************************************************************
     * @description Test method to verify the getProductRegistrySettingsProductInformation method returns the list
     * of ProductRegistryModel correctly
     ***************************************************************************************************************************/
    @isTest
    private static void testGetProductRegistryReleaseGates() {
        String name = 'testName';
        String action = 'testAction';
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 52.0;

        ProductRegistryMapper.instance = new ProductRegistryMapperStub();
        List<ProductRegistryModel> prodRegistryModelList;

        Test.startTest();
        prodRegistryModelList = ProductRegistryMapper.getInstance().getProductRegistryReleaseGates();
        Test.stopTest();

        System.assert(prodRegistryModelList != null, 'prodRegistryModelList should not be null');
        System.assert(!prodRegistryModelList.isEmpty(), 'prodRegistryModelList should not be empty');
        System.assertEquals(1, prodRegistryModelList.size(), 'prodRegistryModelList should have 1 element');

        ProductRegistryModel model = prodRegistryModelList.get(0);

        System.assertEquals(name, model.name, 'name should be set with the value: ' + name);
        System.assertEquals(action, model.action, 'action should be set with the value: ' + action);
        System.assertEquals(namespace, model.namespace, 'namespace should be set with the value: ' + namespace);
        System.assertEquals(classname, model.classname, 'classname should be set with the value: ' + classname);
        System.assertEquals(apiVersion, model.apiVersion, 'apiVersion should be set with the value: ' + apiVersion);
    }

    /**************************************************************************************************************************
     * @description Test method to assert getProductRegistriesByAction method returns a valid response
     ***************************************************************************************************************************/
    @isTest
    private static void testGetProductRegistriesByAction() {
        String action = 'Settings Product Information';
        List<Product_Registry__mdt> prodRegistryModelList;

        List<Product_Registry__mdt> registriesFromTestList = [
            SELECT Action__c, API_Version__c, Class_Name__c, Enabled__c, Namespace__c
            FROM Product_Registry__mdt
            WHERE Action__c = :action AND Enabled__c = TRUE
        ];

        Test.startTest();
        prodRegistryModelList = ProductRegistryMapper.getInstance().getProductRegistriesByAction(action);
        Test.stopTest();

        System.assertEquals(registriesFromTestList.size(), prodRegistryModelList.size());

        Map<String, Product_Registry__mdt> registriesByClassnameAction = new Map<String, Product_Registry__mdt>();

        if (!registriesFromTestList.isEmpty()) {
            //Store in a map the registries by classname+action as key
            for (Product_Registry__mdt registry : registriesFromTestList) {
                String registryKey = registry.Class_Name__c + registry.Action__c;
                registriesByClassnameAction.put(registryKey, registry);
            }
            //For each registry value returned by getProductRegistriesByAction verify the properties are the same
            for (Product_Registry__mdt registry : prodRegistryModelList) {
                String registryKey = registry.Class_Name__c + registry.Action__c;
                if (registriesByClassnameAction.containsKey(registryKey)) {
                    Product_Registry__mdt registryFromTest = registriesByClassnameAction.get(registryKey);
                    System.assertEquals(
                        registryFromTest.API_Version__c,
                        registry.API_Version__c,
                        'Api version should be: ' + registryFromTest.API_Version__c
                    );
                    System.assertEquals(
                        registryFromTest.Enabled__c,
                        registry.Enabled__c,
                        'Enabled should be: ' + registryFromTest.Enabled__c
                    );
                    System.assertEquals(
                        registryFromTest.Namespace__c,
                        registry.Namespace__c,
                        'Namespace should be: ' + registryFromTest.Namespace__c
                    );
                }
            }
        }
    }

    /**************************************************************************************************************************
     * @description Test method to assert getProductRegistryByName method returns a valid response
     ***************************************************************************************************************************/
    @isTest
    private static void testGetProductRegistriesByName() {
        String action = 'Settings Product Information';
        List<Product_Registry__mdt> prodRegistryModelList;

        List<Product_Registry__mdt> registriesFromTestList = [
            SELECT DeveloperName, Action__c, API_Version__c, Class_Name__c, Enabled__c, Namespace__c
            FROM Product_Registry__mdt
            WHERE Action__c = :action AND Enabled__c = TRUE
        ];

        prodRegistryModelList = ProductRegistryMapper.getInstance().getProductRegistriesByAction(action);

        Test.startTest();
        Product_Registry__mdt registryByName = ProductRegistryMapper.getInstance()
            .getProductRegistryByName(registriesFromTestList[0].DeveloperName);
        Test.stopTest();

        System.assertEquals(
            registriesFromTestList[0].API_Version__c,
            registryByName.API_Version__c,
            'Api version should be: ' + registryByName.API_Version__c
        );
        System.assertEquals(
            registriesFromTestList[0].Enabled__c,
            registryByName.Enabled__c,
            'Enabled should be: ' + registryByName.Enabled__c
        );
        System.assertEquals(
            registriesFromTestList[0].Namespace__c,
            registryByName.Namespace__c,
            'Namespace should be: ' + registryByName.Namespace__c
        );
    }

    /**************************************************************************************************************************
     * @description Test method to assert getProductRegistryByName method returns null for nonexistent name
     ***************************************************************************************************************************/
    @isTest
    private static void testGetProductRegistryByNameNonexistent() {
        Test.startTest();
        Product_Registry__mdt registryByName = ProductRegistryMapper.getInstance()
            .getProductRegistryByName('nonexistent name');
        Test.stopTest();

        System.assertEquals(null, registryByName, 'registryByName should be null');
    }

    /**************************************************************************************************************************
     * @description Test method to assert getProductRegistryModelByName method returns null for nonexistent name
     ***************************************************************************************************************************/
    @isTest
    private static void testGetProductRegistryModelByNameNonexistent() {
        Test.startTest();
        ProductRegistryModel registryModel = ProductRegistryMapper.getInstance()
            .getProductRegistryModelByName('nonexistent name');
        Test.stopTest();

        System.assertEquals(null, registryModel, 'registryModel should be null');
    }

    /**************************************************************************************************************************
     * @description Test method to assert getProductRegistryModelByName method returns a valid model
     ***************************************************************************************************************************/
    @isTest
    private static void testGetProductRegistryModelByName() {
        String action = 'Settings Product Information';

        List<Product_Registry__mdt> registriesFromTestList = [
            SELECT DeveloperName, Action__c, API_Version__c, Class_Name__c, Enabled__c, Namespace__c
            FROM Product_Registry__mdt
            WHERE Action__c = :action AND Enabled__c = TRUE
        ];
        Product_Registry__mdt prodRegistryCMT = registriesFromTestList[0];

        Test.startTest();
        ProductRegistryModel registryModel = ProductRegistryMapper.getInstance()
            .getProductRegistryModelByName(prodRegistryCMT.DeveloperName);
        Test.stopTest();

        System.assertEquals(
            prodRegistryCMT.DeveloperName,
            registryModel.name,
            'name should be set with the value: ' + prodRegistryCMT.DeveloperName
        );
        System.assertEquals(
            prodRegistryCMT.Action__c,
            registryModel.action,
            'action should be set with the value: ' + prodRegistryCMT.Action__c
        );
        System.assertEquals(
            prodRegistryCMT.Namespace__c,
            registryModel.namespace,
            'namespace should be set with the value: ' + prodRegistryCMT.Namespace__c
        );
        System.assertEquals(
            prodRegistryCMT.Class_Name__c,
            registryModel.classname,
            'classname should be set with the value: ' + prodRegistryCMT.Class_Name__c
        );
        System.assertEquals(
            prodRegistryCMT.API_Version__c,
            registryModel.apiVersion,
            'apiVersion should be set with the value: ' + prodRegistryCMT.API_Version__c
        );
    }

    /**************************************************************************************************************************
     * @description Test method to assess a scenraio where getProductRegistrySettingsProductInformation method returns null
     ***************************************************************************************************************************/
    @isTest
    private static void testGetProductRegistrySettingsProductInformationNullRegistries() {
        ProductRegistryMapper.instance = new ProductRegistryMapperNullRegistriesStub();
        List<ProductRegistryModel> prodRegistryModelList;

        Test.startTest();
        prodRegistryModelList = ProductRegistryMapper.getInstance().getProductRegistrySettingsProductInformation();
        Test.stopTest();

        System.assertEquals(null, prodRegistryModelList, 'prodRegistryModelList should be null');
    }

    /**************************************************************************************************************************
     * @description Stub class for ProductRegistryMapper returning some sample data
     ***************************************************************************************************************************/
    private class ProductRegistryMapperStub extends ProductRegistryMapper {
        private override List<Product_Registry__mdt> getProductRegistriesByAction(String action) {
            Product_Registry__mdt prodRegistryCMT = new Product_Registry__mdt();
            prodRegistryCMT.DeveloperName = 'testName';
            prodRegistryCMT.Action__c = 'testAction';
            prodRegistryCMT.Namespace__c = 'testNamespace';
            prodRegistryCMT.Class_Name__c = 'testClassname';
            prodRegistryCMT.API_Version__c = 52.0;
            return new List<Product_Registry__mdt>{ prodRegistryCMT };
        }
    }

    /**************************************************************************************************************************
     * @description Stub class for ProductRegistryMapper, where getProductRegistriesByAction returns null
     ***************************************************************************************************************************/
    private class ProductRegistryMapperNullRegistriesStub extends ProductRegistryMapper {
        private override List<Product_Registry__mdt> getProductRegistriesByAction(String action) {
            return null;
        }
    }
}
