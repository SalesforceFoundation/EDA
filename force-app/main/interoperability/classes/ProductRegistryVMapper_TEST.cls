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
 * @description Test class for ProductRegistryService
 */
@isTest
private class ProductRegistryVMapper_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify the getProductRegistrySettingsProductInformation method returns the list
     * of ProductRegistryVModel correctly
     ***************************************************************************************************************************/
    @isTest
    private static void testGetProductRegistrySettingsProductInformation() {
        String action = 'testAction';
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 52.0;

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

    /**************************************************************************************************************************
     * @description Test method to verify the getProductRegistrySettingsProductInformation method returns null
     ***************************************************************************************************************************/
    @isTest
    private static void testNullProductRegistryModelList() {
        ProductRegistryService.instance = new ProductRegistryServiceNullProductRegistriesStub();

        Test.startTest();
        List<ProductRegistryVModel> prodRegistryModelList = ProductRegistryVMapper.getInstance()
            .getProductRegistrySettingsProductInformation();
        Test.stopTest();

        System.assertEquals(null, prodRegistryModelList, 'prodRegistryModelList should  be null');
    }

    /**************************************************************************************************************************
     * @description Test method to verify the getProductRegistryReleaseGates method returns the list
     * of ProductRegistryVModel correctly
     ***************************************************************************************************************************/
    @isTest
    private static void testGetProductRegistryReleaseGates() {
        String action = 'testAction';
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 52.0;

        ProductRegistryService.instance = new ProductRegistryServiceStub();
        List<ProductRegistryVModel> prodRegistryModelList;

        Test.startTest();
        prodRegistryModelList = ProductRegistryVMapper.getInstance().getProductRegistryReleaseGates();
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

    /**************************************************************************************************************************
     * @description Test method to verify the getProductRegistryReleaseGates method returns null
     ***************************************************************************************************************************/
    @isTest
    private static void testNullReleaseGatesList() {
        ProductRegistryService.instance = new ProductRegistryServiceNullProductRegistriesStub();

        Test.startTest();
        List<ProductRegistryVModel> prodRegistryModelList = ProductRegistryVMapper.getInstance()
            .getProductRegistryReleaseGates();
        Test.stopTest();

        System.assertEquals(null, prodRegistryModelList, 'prodRegistryModelList should  be null');
    }

    /**************************************************************************************************************************
     * @description Test method to verify the LocateProductRegistryService returns an instance
     ***************************************************************************************************************************/
    @isTest
    private static void testLocateProductRegistryService() {
        Test.startTest();
        ProductRegistryService instance = ProductRegistryService.getInstance();
        Test.stopTest();

        System.assertNotEquals(null, instance, 'instance should not be null');
    }

    /**************************************************************************************************************************
     * @description Stub class for ProductRegistryService where the getProductRegistrySettingsProductInformation method
     * returns some ProductRegistryModel sample data
     ***************************************************************************************************************************/
    private class ProductRegistryServiceStub extends ProductRegistryService {
        public override List<ProductRegistryModel> getProductRegistrySettingsProductInformation() {
            ProductRegistryModel prodRegistryModel = new ProductRegistryModel(
                'testName',
                'testAction',
                'testNamespace',
                'testClassname',
                52.0
            );
            return new List<ProductRegistryModel>{ prodRegistryModel };
        }

        public override List<ProductRegistryModel> getProductRegistryReleaseGates() {
            ProductRegistryModel prodRegistryModel = new ProductRegistryModel(
                'testName',
                'testAction',
                'testNamespace',
                'testClassname',
                52.0
            );
            return new List<ProductRegistryModel>{ prodRegistryModel };
        }
    }

    /**************************************************************************************************************************
     * @description Stub class for ProductRegistryService which returns a null list of ProductRegistryModel
     ***************************************************************************************************************************/
    private class ProductRegistryServiceNullProductRegistriesStub extends ProductRegistryService {
        public override List<ProductRegistryModel> getProductRegistrySettingsProductInformation() {
            return null;
        }

        public override List<ProductRegistryModel> getProductRegistryReleaseGates() {
            return null;
        }
    }
}
