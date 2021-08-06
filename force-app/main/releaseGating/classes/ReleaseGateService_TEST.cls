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
            List<GetReleaseGateActionResultModel.GetReleaseGateResult> resultList = new List<GetReleaseGateActionResultModel.GetReleaseGateResult>();
            GetReleaseGateActionResultModel.GetReleaseGateResult releaseGate = new GetReleaseGateActionResultModel.GetReleaseGateResult();
            releaseGate.product = new GetReleaseGateActionResultModel.ReleaseGateProduct();
            releaseGate.product.label = 'test product';
            releaseGate.product.name = 'testproduct';
            releaseGate.gates = new List<GetReleaseGateActionResultModel.ReleaseGate>();
            resultList.add(releaseGate);
            GetReleaseGateActionResultModel releaseGateModel = new GetReleaseGateActionResultModel(
                resultList,
                true,
                null
            );
            return releaseGateModel;
        }
    }
}
