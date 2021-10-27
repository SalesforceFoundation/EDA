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
 * @group-content ../../ApexDocContent/
 * @description Test class for ReleaseGateService
 */
@isTest
public with sharing class ReleaseGateService_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * ReleaseGateService class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        ReleaseGateService releaseGateServiceInstance = ReleaseGateService.getInstance();
        Test.stopTest();

        System.assertEquals(
            ReleaseGateService.instance,
            releaseGateServiceInstance,
            'Instance of service class returned should match static instance variable.'
        );
        System.assertEquals(true, ReleaseGateServiceInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * ReleaseGateService class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        ReleaseGateService releaseGateServiceInstance1 = ReleaseGateService.getInstance();
        ReleaseGateService releaseGateServiceInstance2 = ReleaseGateService.getInstance();
        Test.stopTest();

        System.assertEquals(
            ReleaseGateService.instance,
            releaseGateServiceInstance1,
            'Instance of service class returned should match static instance variable.'
        );
        System.assertEquals(
            releaseGateServiceInstance1,
            releaseGateServiceInstance2,
            'Subsequent retrievals of service class instance should return existing instance.'
        );
        System.assertEquals(true, releaseGateServiceInstance1 != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the locateProductRegistryService method returns an instance
     * of the ProductRegistryService class.
     ***************************************************************************************************************************/
    @isTest
    private static void locateProductRegistryServiceValid() {
        ReleaseGateService releaseGateServiceInstance = ReleaseGateService.getInstance();

        Test.startTest();
        ProductRegistryService productRegistryServiceInstance = releaseGateServiceInstance.locateProductRegistryService();
        Test.stopTest();

        System.assertEquals(
            ProductRegistryService.getInstance(),
            productRegistryServiceInstance,
            'Should return instance of ProductRegistryService class.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the locateReleaseGateAPIService method returns an instance
     * of the ReleaseGateAPIService class.
     ***************************************************************************************************************************/
    @isTest
    private static void locateReleaseGateAPIServiceValid() {
        ReleaseGateService releaseGateServiceInstance = ReleaseGateService.getInstance();
        ProductRegistryModel productRegistryModelInstance = new ProductRegistryModel(
            'testName',
            ProductRegistryMapper.RELEASE_GATING_ACTION,
            'testNamespace',
            'testClass',
            1
        );

        Test.startTest();
        ReleaseGateAPIService releaseGateAPIServiceInstance = releaseGateServiceInstance.locateReleaseGateAPIService(
            productRegistryModelInstance
        );
        Test.stopTest();

        System.assertNotEquals(null, releaseGateAPIServiceInstance, 'releaseGateAPIServiceInstance should not be null');
        System.assertEquals(
            productRegistryModelInstance,
            releaseGateAPIServiceInstance.releaseGateRegistry,
            'releaseGateRegistry should be assigned to the provided parameter'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getReleaseGateModel method returns a ReleaseGateModel
     ***************************************************************************************************************************/
    @isTest
    private static void getReleaseGateModelValid() {
        ReleaseGateService.instance = new STUB_ReleaseGateService();
        ProductRegistryService.instance = new STUB_ProductRegistryService();

        ReleaseGateService releaseGateServiceInstance = ReleaseGateService.getInstance();

        Test.startTest();
        GetReleaseGateActionResultModel getReleaseGatesResult = releaseGateServiceInstance.getReleaseGateModel(
            'testName'
        );
        Test.stopTest();

        System.assertEquals(true, getReleaseGatesResult.success, 'The result should be successful');
        System.assertEquals(1, getReleaseGatesResult.result.size(), 'There should be 1 result');
        System.assertEquals(
            'testproduct',
            getReleaseGatesResult.result.get(0).product.name,
            'Expected product name should be \'testproduct\''
        );
        System.assertEquals(
            'test product',
            getReleaseGatesResult.result.get(0).product.label,
            'Expected product label should be \'test product\''
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getReleaseGateModel method throws an exception if prod registry not found
     ***************************************************************************************************************************/
    @isTest
    private static void getReleaseGateModelNotFound() {
        ReleaseGateService.instance = new STUB_ReleaseGateService();

        ReleaseGateService releaseGateServiceInstance = ReleaseGateService.getInstance();

        Test.startTest();
        try {
            GetReleaseGateActionResultModel getReleaseGatesResult = releaseGateServiceInstance.getReleaseGateModel(
                'testName'
            );
            System.assert(false, 'Should always throw an exception');
        } catch (ReleaseGateAPIService.ReleaseGateProductNotFoundException ex) {
            System.assertEquals(
                true,
                ex.getMessage().contains('testName'),
                'The exception should contain product registry name'
            );
        }
        Test.stopTest();
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the activateReleaseGate method returns a successful result
     ***************************************************************************************************************************/
    @isTest
    private static void activateReleaseGate() {
        ReleaseGateService.instance = new STUB_ReleaseGateService();
        ProductRegistryService.instance = new STUB_ProductRegistryService();

        ReleaseGateService releaseGateServiceInstance = ReleaseGateService.getInstance();
        String productName = 'testProduct';
        String gateName = 'testGate';
        String productRegistryName = 'testName';

        Test.startTest();
        ActivateReleaseGateActionResultModel activateReleaseGatesResult = releaseGateServiceInstance.activateReleaseGate(
            productRegistryName,
            productName,
            gateName
        );
        Test.stopTest();
        System.assertEquals(true, activateReleaseGatesResult.success, 'The result should be successful');
        System.assertEquals(1, activateReleaseGatesResult.result.size(), 'There should be 1 result');
        System.assertEquals(
            productName,
            activateReleaseGatesResult.result.get(0).productName,
            'Expected product name should be ' + productName
        );
        System.assertEquals(
            gateName,
            activateReleaseGatesResult.result.get(0).gateName,
            'Expected gate name should be ' + gateName
        );
        System.assertEquals(
            'active',
            activateReleaseGatesResult.result.get(0).status,
            'Expected status should be active'
        );
    }

    /***********************************************************************************************************************************
     ****************************************************** STUBS ***********************************************************************
     ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from ProductRegistryService to return
     * a mock ProductRegistryModel
     **************************************************************************************************************************************/
    private class STUB_ProductRegistryService extends ProductRegistryService {
        public override ProductRegistryModel getProductRegistryModelByName(String developerName) {
            return new ProductRegistryModel(
                'testName',
                ProductRegistryMapper.RELEASE_GATING_ACTION,
                'testNamespace',
                'testClass',
                1
            );
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from ReleaseGateService to return
     * a mock ReleaseGateAPIService
     **************************************************************************************************************************************/
    private class STUB_ReleaseGateService extends ReleaseGateService {
        protected override ReleaseGateAPIService locateReleaseGateAPIService(ProductRegistryModel productRegistry) {
            return new STUB_ReleaseGateAPIService(productRegistry);
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from ReleaseGateAPIService to return
     * a valid GetReleaseGateActionResultModel
     **************************************************************************************************************************************/
    private class STUB_ReleaseGateAPIService extends ReleaseGateAPIService {
        public STUB_ReleaseGateAPIService(ProductRegistryModel releaseGateRegistry) {
            super(releaseGateRegistry);
        }

        public override GetReleaseGateActionResultModel getReleaseGates() {
            List<GetReleaseGateActionResultModel.GetReleaseGateResult> resultList = new List<GetReleaseGateActionResultModel.GetReleaseGateResult>{
                new GetReleaseGateActionResultModel.GetReleaseGateResult(
                    new GetReleaseGateActionResultModel.ReleaseGateProduct(
                        'testproduct',
                        'test product',
                        'January 2022'
                    ),
                    new List<GetReleaseGateActionResultModel.ReleaseGate>{
                        new GetReleaseGateActionResultModel.ReleaseGate(
                            'testgate',
                            'test gate',
                            'test gate description',
                            null,
                            Date.today().addMonths(6),
                            'On this date, we activate the current release on all sandboxes that are still on the previous release.',
                            null,
                            'inactive',
                            new List<GetReleaseGateActionResultModel.ReleaseGateFeature>{
                                new GetReleaseGateActionResultModel.ReleaseGateFeature(
                                    'testfeature',
                                    'test feature',
                                    'test feature description',
                                    'https://www.google.com',
                                    'help link label'
                                )
                            }
                        )
                    }
                )
            };
            GetReleaseGateActionResultModel releaseGateResultModel = new GetReleaseGateActionResultModel(
                resultList,
                true,
                null
            );
            return releaseGateResultModel;
        }

        public override ActivateReleaseGateActionResultModel activateReleaseGate(String productName, String gateName) {
            return new ActivateReleaseGateActionResultModel(
                new List<ActivateReleaseGateActionResultModel.ActivateReleaseGateResult>{
                    new ActivateReleaseGateActionResultModel.ActivateReleaseGateResult(productName, gateName, 'active')
                },
                true,
                null
            );
        }
    }
}
