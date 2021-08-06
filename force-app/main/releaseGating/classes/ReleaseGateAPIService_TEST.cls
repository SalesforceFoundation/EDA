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
 * @description Test class for ReleaseGateAPIService
 */
@isTest
public with sharing class ReleaseGateAPIService_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the constructor is assigning the values correctly
     ***************************************************************************************************************************/
    @isTest
    private static void createInstance() {
        ProductRegistryModel releaseGateRegistry = new ProductRegistryModel(
            'testName',
            ProductRegistryMapper.RELEASE_GATING_ACTION,
            'testNamespace',
            'testClass',
            1
        );
        Test.startTest();
        ReleaseGateAPIService releaseGateApiServiceInstance = new ReleaseGateAPIService(releaseGateRegistry);
        Test.stopTest();

        System.assertEquals(
            releaseGateRegistry,
            releaseGateApiServiceInstance.releaseGateRegistry,
            'releaseGateRegistry instance is incorrect'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getReleaseGateAPIModel method returns a ReleaseGateAPIModel
     * from the current package
     ***************************************************************************************************************************/
    @isTest
    private static void getReleaseGatesCurrentPackage() {
        ProductRegistryModel releaseGateRegistry = new ProductRegistryModel(
            'testName',
            ProductRegistryMapper.RELEASE_GATING_ACTION,
            '',
            'ReleaseGateAPIService_TEST.TestReleaseGateCallableImpl',
            1
        );
        ReleaseGateAPIService callableService = new ReleaseGateAPIService(releaseGateRegistry);

        Test.startTest();
        GetReleaseGateActionResultModel getReleaseGatesResult = callableService.getReleaseGates();
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
            getReleaseGatesResult.result[0].product.label,
            'Expected product label should be \'test product\''
        );
        System.assertEquals(
            1,
            getReleaseGatesResult.result[0].gates.size(),
            'There should be 1 item in the list of release gates'
        );
        System.assertEquals(
            'testgate',
            getReleaseGatesResult.result[0].gates[0].name,
            'Expected gate name should be \'testgate\''
        );
        System.assertEquals(
            'test gate',
            getReleaseGatesResult.result[0].gates[0].label,
            'Expected gate label should be \'test gate\''
        );
        System.assertEquals(
            1,
            getReleaseGatesResult.result[0].gates[0].items.size(),
            'There should be 1 item in the list of release gate features'
        );
        System.assertEquals(
            'testfeature',
            getReleaseGatesResult.result[0].gates[0].items[0].name,
            'Expected feature name should be \'testfeature\''
        );
        System.assertEquals(
            'test feature',
            getReleaseGatesResult.result[0].gates[0].items[0].label,
            'Expected feature label should be \'test feature\''
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getReleaseGateAPIModel method throws ReleaseGateCallableException
     ***************************************************************************************************************************/
    @isTest
    private static void getReleaseGatesErrorCurrentPackage() {
        ProductRegistryModel releaseGateRegistry = new ProductRegistryModel(
            'testName',
            ProductRegistryMapper.RELEASE_GATING_ACTION,
            '',
            'ReleaseGateAPIService_TEST.TestReleaseGateCallableErrorImpl',
            1
        );
        ReleaseGateAPIService callableService = new ReleaseGateAPIService(releaseGateRegistry);

        try {
            Test.startTest();
            GetReleaseGateActionResultModel getReleaseGatesResult = callableService.getReleaseGates();
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (ReleaseGateAPIService.ReleaseGateCallableException ex) {
            System.assertEquals(false, ex.result.success, 'Expected success to be false');

            System.assertEquals(
                'Test callable error',
                ex.result.error.message,
                'Expected error message should be \'Test callable error\''
            );
        }
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getReleaseGateAPIModel method throws ReleaseGateCallableException
     ***************************************************************************************************************************/
    @isTest
    private static void getReleaseGatesNotFoundCurrentPackage() {
        ProductRegistryModel releaseGateRegistry = new ProductRegistryModel(
            'testName',
            ProductRegistryMapper.RELEASE_GATING_ACTION,
            '',
            'ReleaseGateAPIService_TEST.TestReleaseGateCallableNotFound',
            1
        );
        ReleaseGateAPIService callableService = new ReleaseGateAPIService(releaseGateRegistry);

        try {
            Test.startTest();
            GetReleaseGateActionResultModel getReleaseGatesResult = callableService.getReleaseGates();
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (ReleaseGateAPIService.ReleaseGateProductNotFoundException ex) {
            System.assertEquals(releaseGateRegistry, ex.productRegistry, 'Exception product registry should match');

            System.assertEquals(
                true,
                ex.getMessage().contains('could not get loaded'),
                'Expected error message should contain \'could not get loaded\''
            );
        }
    }

    /***********************************************************************************************************************************
     ************************************************* Test Callable classes ***********************************************************
     ***********************************************************************************************************************************/

    /**
     * Test Callable class with successful response
     */
    public class TestReleaseGateCallableImpl implements Callable {
        public TestReleaseGateCallableImpl() {
        }

        public String getReleaseGates(Decimal version) {
            List<GetReleaseGateActionResultModel.GetReleaseGateResult> resultList = new List<GetReleaseGateActionResultModel.GetReleaseGateResult>();
            GetReleaseGateActionResultModel.GetReleaseGateResult releaseGate = new GetReleaseGateActionResultModel.GetReleaseGateResult();
            releaseGate.product = new GetReleaseGateActionResultModel.ReleaseGateProduct();
            releaseGate.product.label = 'test product';
            releaseGate.product.name = 'testproduct';
            releaseGate.gates = new List<GetReleaseGateActionResultModel.ReleaseGate>();
            GetReleaseGateActionResultModel.ReleaseGate gate = new GetReleaseGateActionResultModel.ReleaseGate();
            gate.name = 'testgate';
            gate.label = 'test gate';
            gate.items = new List<GetReleaseGateActionResultModel.ReleaseGateFeature>();
            GetReleaseGateActionResultModel.ReleaseGateFeature feature = new GetReleaseGateActionResultModel.ReleaseGateFeature();
            feature.name = 'testfeature';
            feature.label = 'test feature';
            gate.items.add(feature);
            releaseGate.gates.add(gate);
            resultList.add(releaseGate);
            GetReleaseGateActionResultModel releaseGateResultModel = new GetReleaseGateActionResultModel(
                resultList,
                true,
                null
            );
            return JSON.serialize(releaseGateResultModel);
        }

        public String activateReleaseGate(Decimal version, String productName, String gateName) {
            //TODO: This will be implemented in another user story
            throw new IllegalArgumentException('Method not implemented');
        }

        public Object call(String action, Map<String, Object> args) {
            System.debug('Execution callable action: ' + action);
            String result;
            if (action == ReleaseGateAPIService.GET_ACTION) {
                result = this.getReleaseGates((Decimal) args.get('version'));
            } else if (action == ReleaseGateAPIService.ACTIVATE_ACTION) {
                result = this.activateReleaseGate(
                    (Decimal) args.get('version'),
                    (String) args.get('product'),
                    (String) args.get('gate')
                );
            } else {
                throw new IllegalArgumentException('Method not implemented');
            }
            System.debug('Action finished, result: \r\n' + result);
            return result;
        }
    }

    /**
     * Test Callable class with error response
     */
    public class TestReleaseGateCallableErrorImpl implements Callable {
        public TestReleaseGateCallableErrorImpl() {
        }

        public String getReleaseGates(Decimal version) {
            GetReleaseGateActionResultModel releaseGateResultModel = new GetReleaseGateActionResultModel(
                null,
                false,
                new CallableError(400, 'Test callable error')
            );
            return JSON.serialize(releaseGateResultModel);
        }

        public String activateReleaseGate(Decimal version, String productName, String gateName) {
            //TODO: This will be implemented in another user story
            throw new IllegalArgumentException('Method not implemented');
        }

        public Object call(String action, Map<String, Object> args) {
            System.debug('Execution callable action: ' + action);
            String result;
            if (action == ReleaseGateAPIService.GET_ACTION) {
                result = this.getReleaseGates((Decimal) args.get('version'));
            } else if (action == ReleaseGateAPIService.ACTIVATE_ACTION) {
                result = this.activateReleaseGate(
                    (Decimal) args.get('version'),
                    (String) args.get('product'),
                    (String) args.get('gate')
                );
            } else {
                throw new IllegalArgumentException('Method not implemented');
            }
            System.debug('Action finished, result: \r\n' + result);
            return result;
        }
    }
}
