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
private class ProductRegistryService_TEST {
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
        prodRegistryModelList = ProductRegistryService.getInstance().getProductRegistrySettingsProductInformation();
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
     * @description Test method to verify the getProductRegistryReleaseGates method returns the list
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
        prodRegistryModelList = ProductRegistryService.getInstance().getProductRegistryReleaseGates();
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
     * @description Test method to verify the getProductRegistryModelByName method returns an instance
     * of ProductRegistryModel correctly
     ***************************************************************************************************************************/
    @isTest
    private static void testGetProductRegistryModelByName() {
        String name = 'testName';
        String action = 'testAction';
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 52.0;

        ProductRegistryMapper.instance = new ProductRegistryMapperStub();
        ProductRegistryModel prodRegistryModel;

        Test.startTest();
        prodRegistryModel = ProductRegistryService.getInstance().getProductRegistryModelByName('testName');
        Test.stopTest();

        System.assert(prodRegistryModel != null, 'prodRegistryModel should not be null');
        System.assertEquals(name, prodRegistryModel.name, 'name should be set with the value: ' + name);
        System.assertEquals(action, prodRegistryModel.action, 'action should be set with the value: ' + action);
        System.assertEquals(
            namespace,
            prodRegistryModel.namespace,
            'namespace should be set with the value: ' + namespace
        );
        System.assertEquals(
            classname,
            prodRegistryModel.classname,
            'classname should be set with the value: ' + classname
        );
        System.assertEquals(
            apiVersion,
            prodRegistryModel.apiVersion,
            'apiVersion should be set with the value: ' + apiVersion
        );
    }

    /**************************************************************************************************************************
     * @description Stub class for ProductRegistryMapper returning some sample data
     ***************************************************************************************************************************/
    private class ProductRegistryMapperStub extends ProductRegistryMapper {
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

        public override ProductRegistryModel getProductRegistryModelByName(String developerName) {
            return new ProductRegistryModel('testName', 'testAction', 'testNamespace', 'testClassname', 52.0);
        }
    }
}
