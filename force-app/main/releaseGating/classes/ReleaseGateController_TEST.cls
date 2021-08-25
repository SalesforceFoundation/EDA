/*
    Copyright (c) 2021, Salesforce.org
    All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
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
 * @group-content ../../ApexDocContent/Tests.htm
 * @description Test class for ReleaseGateController class.
 */
@isTest
private with sharing class ReleaseGateController_TEST {
    /****************************************************************************************
     * @description Test method to verify locateReleaseGateVMapper() returns an instance of
     * the ReleaseGateVMapper class.
     ****************************************************************************************/
    @isTest
    private static void locateReleaseGateVMapperValid() {
        Test.startTest();
        ReleaseGateVMapper releaseGateVMapperInstance = ReleaseGateController.locateReleaseGateVMapper();
        Test.stopTest();

        System.assertEquals(
            ReleaseGateVMapper.getInstance(),
            releaseGateVMapperInstance,
            'Should return instance of ReleaseGateVMapper class.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify ReleaseGateService() returns an instance of
     * the ReleaseGateService class.
     ****************************************************************************************/
    @isTest
    private static void locateReleaseGateService() {
        Test.startTest();
        ReleaseGateService releaseGateServiceInstance = ReleaseGateController.locateReleaseGateService();
        Test.stopTest();

        System.assertEquals(
            ReleaseGateService.getInstance(),
            releaseGateServiceInstance,
            'Should return instance of ReleaseGateService class.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getReleaseGateVModel()
     * returns an instance of ReleaseGateVModel with valid values from valid stub.
     ****************************************************************************************/
    @isTest
    private static void getReleaseGateVModelValid() {
        ReleaseGateVMapper.instance = new STUB_ReleaseGateVMapperValid();

        Test.startTest();
        List<ReleaseGateVModel> releaseGateVModelList = ReleaseGateController.getReleaseGateVModel(
            'testProductRegistry'
        );
        Test.stopTest();

        System.assertEquals(1, releaseGateVModelList.size(), 'There should be 1 product in the list');
        System.assertEquals(
            'testproduct',
            releaseGateVModelList[0].product.name,
            'Expected product name should be \'testproduct\''
        );
        System.assertEquals(
            'test product',
            releaseGateVModelList[0].product.label,
            'Expected product label should be \'test product\''
        );
        System.assertEquals(
            'next release date',
            releaseGateVModelList[0].product.nextReleaseDate,
            'Expected product release date should be \'next release date\''
        );
    }

    /****************************************************************************************
     * @description Test method to verify getReleaseGateVModel()
     * throws an exception when exception occurs.
     ****************************************************************************************/
    @isTest
    private static void getReleaseGateVModelException() {
        ReleaseGateVMapper.instance = new STUB_ExceptionReleaseGateVMapper();

        try {
            Test.startTest();
            List<ReleaseGateVModel> releaseGateVModelList = ReleaseGateController.getReleaseGateVModel(
                'testProductRegistry'
            );
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /****************************************************************************************
     * @description Test method to verify getProductRegistryReleaseGateVModels()
     * returns an instance of List<ProductRegistryVModel> with valid values from valid stub.
     ****************************************************************************************/
    @isTest
    private static void getProductRegistryReleaseGateVModelsValid() {
        String name = 'testName';
        String action = 'testAction';
        String namespace = 'testNamespace';
        String classname = 'testClassname';
        Decimal apiVersion = 52.0;
        ProductRegistryVMapper.instance = new ProductRegistryVMapperStub();

        Test.startTest();
        List<ProductRegistryVModel> productRegistryVModelList = ReleaseGateController.getProductRegistryReleaseGateVModels();
        Test.stopTest();

        System.assertEquals(1, productRegistryVModelList.size(), 'productRegistryVModelList size should be 1');

        ProductRegistryVModel model = productRegistryVModelList.get(0);
        System.assertEquals(name, model.name, 'name should be set with the value: ' + name);
        System.assertEquals(action, model.action, 'action should be set with the value: ' + action);
        System.assertEquals(namespace, model.namespace, 'namespace should be set with the value: ' + namespace);
        System.assertEquals(classname, model.classname, 'classname should be set with the value: ' + classname);
        System.assertEquals(apiVersion, model.apiVersion, 'apiVersion should be set with the value: ' + apiVersion);
    }

    /****************************************************************************************
     * @description Test method to verify getProductRegistryReleaseGateVModels()
     * throws an exception when exception occurs.
     ****************************************************************************************/
    @isTest
    private static void getProductRegistryReleaseGateVModelsException() {
        ProductRegistryVMapper.instance = new ProductRegistryVMapperExceptionStub();
        try {
            Test.startTest();
            List<ProductRegistryVModel> productRegistryList = ReleaseGateController.getProductRegistryReleaseGateVModels();
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /****************************************************************************************
     * @description Test method to verify activateReleaseGate()
     * returns an instance of ReleaseGateVModel with valid values from valid stub.
     ****************************************************************************************/
    @isTest
    private static void activateReleaseGateValid() {
        ReleaseGateVMapper.instance = new STUB_ReleaseGateVMapperValid();
        String productRegistryName = 'testName';
        String productName = 'testProduct';
        String gateName = 'testGate';

        Test.startTest();
        List<ActivateReleaseGateVModel> activateReleaseGateVModelList = ReleaseGateController.activateReleaseGate(
            productRegistryName,
            productName,
            gateName
        );
        Test.stopTest();

        System.assertEquals(1, activateReleaseGateVModelList.size(), 'There should be 1 result in the list');
        System.assertEquals(
            productName,
            activateReleaseGateVModelList[0].productName,
            'Expected product name should be ' + productName
        );
        System.assertEquals(
            gateName,
            activateReleaseGateVModelList[0].gateName,
            'Expected gate name should be ' + gateName
        );
        System.assertEquals('active', activateReleaseGateVModelList[0].status, 'Expected status should be active');
    }

    /****************************************************************************************
     * @description Test method to verify activateReleaseGate()
     * throws an exception when exception occurs.
     ****************************************************************************************/
    @isTest
    private static void activateReleaseGateVModelException() {
        ReleaseGateVMapper.instance = new STUB_ExceptionReleaseGateVMapper();

        try {
            Test.startTest();
            List<ActivateReleaseGateVModel> activateReleaseGateVModelList = ReleaseGateController.activateReleaseGate(
                'testProductRegistry',
                'testProduct',
                'testGate'
            );
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /***********************************************************************************************************************************
     ****************************************************** STUBS ***********************************************************************
     ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate valid responses from ReleaseGateVMapper
     **************************************************************************************************************************************/
    private class STUB_ReleaseGateVMapperValid extends ReleaseGateVMapper {
        public override List<ReleaseGateVModel> getReleaseGateVModel(String productRegistryName) {
            List<ReleaseGateVModel> releaseGateVModelList = new List<ReleaseGateVModel>();
            releaseGateVModelList.add(
                new ReleaseGateVModel(
                    new ReleaseGateVModel.ReleaseGateProduct('testproduct', 'test product', 'next release date'),
                    new List<ReleaseGateVModel.ReleaseGate>()
                )
            );
            return releaseGateVModelList;
        }

        public override List<ActivateReleaseGateVModel> activateReleaseGate(
            String productRegistryName,
            String productName,
            String gateName
        ) {
            return new List<ActivateReleaseGateVModel>{
                new ActivateReleaseGateVModel('testProduct', 'testGate', 'active')
            };
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate exception responses from ReleaseGateVMapper
     **************************************************************************************************************************************/
    private class STUB_ExceptionReleaseGateVMapper extends ReleaseGateVMapper {
        public override List<ReleaseGateVModel> getReleaseGateVModel(String productRegistryName) {
            throw new TestException('Exception encountered!');
        }

        public override List<ActivateReleaseGateVModel> activateReleaseGate(
            String productRegistryName,
            String productName,
            String gateName
        ) {
            throw new TestException('Exception encountered!');
        }
    }

    /**************************************************************************************************************************
     * @description Stub class for ProductRegistryVMapper returning some sample data
     ***************************************************************************************************************************/
    private class ProductRegistryVMapperStub extends ProductRegistryVMapper {
        public override List<ProductRegistryVModel> getProductRegistryReleaseGates() {
            ProductRegistryVModel model = new ProductRegistryVModel(
                'testName',
                'testAction',
                'testNamespace',
                'testClassname',
                52.0
            );
            return new List<ProductRegistryVModel>{ model };
        }
    }

    /**************************************************************************************************************************
     * @description Stub class for ProductRegistryVMapper, where the method getProductRegistryReleaseGates
     * throws an AuraHandledException
     ***************************************************************************************************************************/
    private class ProductRegistryVMapperExceptionStub extends ProductRegistryVMapper {
        public override List<ProductRegistryVModel> getProductRegistryReleaseGates() {
            throw new AuraHandledException('testExceptionMessage');
        }
    }

    private class TestException extends Exception {
    }
}
