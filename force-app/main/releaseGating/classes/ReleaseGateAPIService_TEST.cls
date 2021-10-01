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
     * @description Test method to verify that the callable namespace is returned correctly
     ***************************************************************************************************************************/
    @isTest
    private static void getCallableNamespace() {
        String edaNamespace = 'hed';
        String nonEdaNamespace = 'testNamespace';
        ProductRegistryModel edaReleaseGateRegistry = new ProductRegistryModel(
            'testName',
            ProductRegistryMapper.RELEASE_GATING_ACTION,
            edaNamespace,
            'testClass',
            1
        );
        ProductRegistryModel nonEdaReleaseGateRegistry = new ProductRegistryModel(
            'testName',
            ProductRegistryMapper.RELEASE_GATING_ACTION,
            nonEdaNamespace,
            'testClass',
            1
        );
        String currentNamespace = UTIL_Namespace.getNamespace();
        ReleaseGateAPIService apiServiceEda = new ReleaseGateAPIService(edaReleaseGateRegistry);
        ReleaseGateAPIService apiServiceNonEda = new ReleaseGateAPIService(nonEdaReleaseGateRegistry);
        Test.startTest();
        String edaCallableNamespace = apiServiceEda.getCallableNamespace();
        String nonEdaCallableNamespace = apiServiceNonEda.getCallableNamespace();
        Test.stopTest();

        System.assertEquals(nonEdaNamespace, nonEdaCallableNamespace, 'Incorrect non-EDA namespace');
        String expectedEdaNamespace = currentNamespace == '' ? '' : edaNamespace;
        System.assertEquals(expectedEdaNamespace, edaCallableNamespace, 'Incorrect EDA namespace');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the constructor is throwing ReleaseGateProductNotFoundException exception
     ***************************************************************************************************************************/
    @isTest
    private static void createInstanceException() {
        ProductRegistryModel releaseGateRegistry = new ProductRegistryModel(
            'testName',
            ProductRegistryMapper.SETTINGS_INFORMATION_ACTION,
            'testNamespace',
            'testClass',
            1
        );
        Test.startTest();
        try {
            ReleaseGateAPIService releaseGateApiServiceInstance = new ReleaseGateAPIService(releaseGateRegistry);
            System.assert(false, 'Should always throw an exception');
        } catch (ReleaseGateAPIService.ReleaseGateProductRegistryException ex) {
            System.assertEquals(releaseGateRegistry, ex.productRegistry, 'Exception productRegistry is not valid');
        }
        Test.stopTest();
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getReleaseGateAPIModel method returns a GetReleaseGateActionResultModel
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
     * @description Test method to verify that the activateReleaseGate method returns a ActivateReleaseGateActionResultModel
     * from the current package
     ***************************************************************************************************************************/
    @isTest
    private static void activateReleaseGateCurrentPackage() {
        ProductRegistryModel releaseGateRegistry = new ProductRegistryModel(
            'testName',
            ProductRegistryMapper.RELEASE_GATING_ACTION,
            '',
            'ReleaseGateAPIService_TEST.TestReleaseGateCallableImpl',
            1
        );
        ReleaseGateAPIService callableService = new ReleaseGateAPIService(releaseGateRegistry);
        String productName = 'productName1';
        String gateName = 'gateName1';

        Test.startTest();
        ActivateReleaseGateActionResultModel activateReleaseGatesResult = callableService.activateReleaseGate(
            productName,
            gateName
        );
        Test.stopTest();

        System.assertEquals(true, activateReleaseGatesResult.success, 'The result should be successful');
        System.assertEquals(1, activateReleaseGatesResult.result.size(), 'There should be 1 result');
        System.assertEquals(
            productName,
            activateReleaseGatesResult.result[0].productName,
            'Expected product name should be ' + productName
        );
        System.assertEquals(
            gateName,
            activateReleaseGatesResult.result[0].gateName,
            'Expected gate name should be ' + gateName
        );
        System.assertEquals(
            'active',
            activateReleaseGatesResult.result[0].status,
            'Expected gate status should be active'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getReleaseGateAPIModel method returns error result
     ***************************************************************************************************************************/
    @isTest
    private static void getReleaseGatesErrorResponseCurrentPackage() {
        ProductRegistryModel releaseGateRegistry = new ProductRegistryModel(
            'testName',
            ProductRegistryMapper.RELEASE_GATING_ACTION,
            '',
            'ReleaseGateAPIService_TEST.TestReleaseGateCallableErrorImpl',
            1
        );
        ReleaseGateAPIService callableService = new ReleaseGateAPIService(releaseGateRegistry);

        Test.startTest();
        GetReleaseGateActionResultModel getReleaseGatesResult = callableService.getReleaseGates();
        Test.stopTest();
        System.assertEquals(false, getReleaseGatesResult.success, 'Expected success to be false');
        System.assertEquals(
            'Test callable error',
            getReleaseGatesResult.error.message,
            'Expected error message should be \'Test callable error\''
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the activateReleaseGate method throws ReleaseGateCallableException
     ***************************************************************************************************************************/
    @isTest
    private static void activateReleaseGatesErrorResponseCurrentPackage() {
        ProductRegistryModel releaseGateRegistry = new ProductRegistryModel(
            'testName',
            ProductRegistryMapper.RELEASE_GATING_ACTION,
            '',
            'ReleaseGateAPIService_TEST.TestReleaseGateCallableErrorImpl',
            1
        );
        ReleaseGateAPIService callableService = new ReleaseGateAPIService(releaseGateRegistry);

        Test.startTest();
        ActivateReleaseGateActionResultModel activateReleaseGatesResult = callableService.activateReleaseGate(
            'testProduct',
            'testGate'
        );
        Test.stopTest();
        System.assertEquals(false, activateReleaseGatesResult.success, 'Expected success to be false');

        System.assertEquals(
            true,
            activateReleaseGatesResult.error.message.contains('Test callable error'),
            'Expected error message should contain \'Test callable error\''
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getReleaseGateAPIModel method returns unsuccessful result and null error
     ***************************************************************************************************************************/
    @isTest
    private static void getReleaseGatesNullErrorResponseCurrentPackage() {
        ProductRegistryModel releaseGateRegistry = new ProductRegistryModel(
            'testName',
            ProductRegistryMapper.RELEASE_GATING_ACTION,
            '',
            'ReleaseGateAPIService_TEST.TestReleaseGateCallableNullErrorImpl',
            1
        );
        ReleaseGateAPIService callableService = new ReleaseGateAPIService(releaseGateRegistry);

        Test.startTest();
        GetReleaseGateActionResultModel getReleaseGatesResult = callableService.getReleaseGates();
        Test.stopTest();
        System.assertEquals(false, getReleaseGatesResult.success, 'Expected success to be false');
        System.assertEquals(null, getReleaseGatesResult.error, 'Expected error should be null');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getReleaseGateAPIModel method handles exceptions
     * and throws ReleaseGateCallableException
     ***************************************************************************************************************************/
    @isTest
    private static void getReleaseGatesUnhandledExceptionCurrentPackage() {
        ProductRegistryModel releaseGateRegistry = new ProductRegistryModel(
            'testName',
            ProductRegistryMapper.RELEASE_GATING_ACTION,
            '',
            'ReleaseGateAPIService_TEST.TestReleaseGateExceptionCallableImpl',
            1
        );
        ReleaseGateAPIService callableService = new ReleaseGateAPIService(releaseGateRegistry);

        try {
            Test.startTest();
            GetReleaseGateActionResultModel getReleaseGatesResult = callableService.getReleaseGates();
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (ReleaseGateAPIService.ReleaseGateCallableException ex) {
            System.assertEquals(true, ex.getCause() != null, 'Exception cause should not be null');
            System.assertEquals(releaseGateRegistry, ex.productRegistry, 'Exception product registry should match');
        }
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the activateReleaseGate method handles exceptions
     * and throws ReleaseGateCallableException
     ***************************************************************************************************************************/
    @isTest
    private static void activateReleaseGatesUnhandledExceptionCurrentPackage() {
        ProductRegistryModel releaseGateRegistry = new ProductRegistryModel(
            'testName',
            ProductRegistryMapper.RELEASE_GATING_ACTION,
            '',
            'ReleaseGateAPIService_TEST.TestReleaseGateExceptionCallableImpl',
            1
        );
        ReleaseGateAPIService callableService = new ReleaseGateAPIService(releaseGateRegistry);

        try {
            Test.startTest();
            ActivateReleaseGateActionResultModel activateReleaseGatesResult = callableService.activateReleaseGate(
                'testProduct',
                'testGate'
            );
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (ReleaseGateAPIService.ReleaseGateCallableException ex) {
            System.assertEquals(true, ex.getCause() != null, 'Exception cause should not be null');
            System.assertEquals(releaseGateRegistry, ex.productRegistry, 'Exception product registry should match');
        }
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getReleaseGateAPIModel method handles json exceptions
     * and throws ReleaseGateCallableException
     ***************************************************************************************************************************/
    @isTest
    private static void getReleaseGatesJsonExceptionCurrentPackage() {
        ProductRegistryModel releaseGateRegistry = new ProductRegistryModel(
            'testName',
            ProductRegistryMapper.RELEASE_GATING_ACTION,
            '',
            'ReleaseGateAPIService_TEST.TestReleaseGateJsonExceptionCallableImpl',
            1
        );
        ReleaseGateAPIService callableService = new ReleaseGateAPIService(releaseGateRegistry);

        try {
            Test.startTest();
            GetReleaseGateActionResultModel getReleaseGatesResult = callableService.getReleaseGates();
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (ReleaseGateAPIService.ReleaseGateCallableException ex) {
            System.assertEquals(true, ex.getCause() != null, 'Exception cause should not be null');
            System.assertEquals(
                true,
                ex.getCause() instanceof JSONException,
                'Inner exception should be JSONException'
            );
            System.assertEquals(releaseGateRegistry, ex.productRegistry, 'Exception product registry should match');
        }
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the activateReleaseGate method handles json exceptions
     * and throws ReleaseGateCallableException
     ***************************************************************************************************************************/
    @isTest
    private static void activateReleaseGatesJsonExceptionCurrentPackage() {
        ProductRegistryModel releaseGateRegistry = new ProductRegistryModel(
            'testName',
            ProductRegistryMapper.RELEASE_GATING_ACTION,
            '',
            'ReleaseGateAPIService_TEST.TestReleaseGateJsonExceptionCallableImpl',
            1
        );
        ReleaseGateAPIService callableService = new ReleaseGateAPIService(releaseGateRegistry);

        try {
            Test.startTest();
            ActivateReleaseGateActionResultModel activateReleaseGatesResult = callableService.activateReleaseGate(
                'testProduct',
                'testGate'
            );
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (ReleaseGateAPIService.ReleaseGateCallableException ex) {
            System.assertEquals(true, ex.getCause() != null, 'Exception cause should not be null');
            System.assertEquals(
                true,
                ex.getCause() instanceof JSONException,
                'Inner exception should be JSONException'
            );
            System.assertEquals(releaseGateRegistry, ex.productRegistry, 'Exception product registry should match');
        }
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getReleaseGateAPIModel method throws ReleaseGateProductNotFoundException
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
        }
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the activateReleaseGate method throws ReleaseGateProductNotFoundException
     ***************************************************************************************************************************/
    @isTest
    private static void activateReleaseGatesNotFoundCurrentPackage() {
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
            ActivateReleaseGateActionResultModel activateReleaseGatesResult = callableService.activateReleaseGate(
                'testProduct',
                'testGate'
            );
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (ReleaseGateAPIService.ReleaseGateProductNotFoundException ex) {
            System.assertEquals(releaseGateRegistry, ex.productRegistry, 'Exception product registry should match');
        }
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getReleaseGateAPIModel method throws ReleaseGateProductNotFoundException
     * when non Callable class is specified
     ***************************************************************************************************************************/
    @isTest
    private static void getReleaseGatesNotFoundNonCallable() {
        ProductRegistryModel releaseGateRegistry = new ProductRegistryModel(
            'testName',
            ProductRegistryMapper.RELEASE_GATING_ACTION,
            '',
            'ReleaseGateAPIService',
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
        }
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the locateUserPermissionService method returns a valid instance of
     * UserPermissionService.
     ***************************************************************************************************************************/
    @isTest
    private static void locateUserPermissionServiceValid() {
        ProductRegistryModel releaseGateRegistry = new ProductRegistryModel(
            'testName',
            ProductRegistryMapper.RELEASE_GATING_ACTION,
            '',
            'ReleaseGateAPIService',
            1
        );
        ReleaseGateAPIService callableService = new ReleaseGateAPIService(releaseGateRegistry);

        Test.startTest();
        UserPermissionService userPermissionServiceInstance = callableService.locateUserPermissionService();
        Test.stopTest();

        System.assertEquals(
            UserPermissionService.getInstance(),
            userPermissionServiceInstance,
            'Should return instance of UserPermissionService.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that getReleaseGates throws NoAccessException under a standard user
     ***************************************************************************************************************************/
    @isTest
    private static void getReleaseGatesStandardUser() {
        ProductRegistryModel releaseGateRegistry = new ProductRegistryModel(
            'testName',
            ProductRegistryMapper.RELEASE_GATING_ACTION,
            '',
            'ReleaseGateAPIService_TEST.TestReleaseGateCallableImpl',
            1
        );
        ReleaseGateAPIService callableService = new ReleaseGateAPIService(releaseGateRegistry);

        User stdUser = UTIL_UnitTestData_TEST.getStandardUser();
        System.runAs(stdUser) {
            try {
                Test.startTest();
                GetReleaseGateActionResultModel getReleaseGatesResult = callableService.getReleaseGates();
                Test.stopTest();
                System.assert(false, 'should always throw an exception');
            } catch (NoAccessException ex) {
            }
        }
    }

    /**************************************************************************************************************************
     * @description Test method to verify that activateReleaseGate throws NoAccessException under a standard user
     ***************************************************************************************************************************/
    @isTest
    private static void activateReleaseGateStandardUser() {
        ProductRegistryModel releaseGateRegistry = new ProductRegistryModel(
            'testName',
            ProductRegistryMapper.RELEASE_GATING_ACTION,
            '',
            'ReleaseGateAPIService_TEST.TestReleaseGateCallableImpl',
            1
        );
        ReleaseGateAPIService callableService = new ReleaseGateAPIService(releaseGateRegistry);

        User stdUser = UTIL_UnitTestData_TEST.getStandardUser();
        System.runAs(stdUser) {
            try {
                Test.startTest();
                ActivateReleaseGateActionResultModel activateReleaseGateResult = callableService.activateReleaseGate(
                    'productName',
                    'gateName'
                );
                Test.stopTest();
                System.assert(false, 'should always throw an exception');
            } catch (NoAccessException ex) {
            }
        }
    }

    /***********************************************************************************************************************************
     ************************************************* Test Callable classes ***********************************************************
     ***********************************************************************************************************************************/

    /**
     * Test Callable class with successful response
     */
    public class TestReleaseGateCallableImpl implements Callable {
        public String getReleaseGates(Decimal version) {
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
            return JSON.serialize(releaseGateResultModel);
        }

        public String activateReleaseGate(Decimal version, String productName, String gateName) {
            return JSON.serialize(
                new ActivateReleaseGateActionResultModel(
                    new List<ActivateReleaseGateActionResultModel.ActivateReleaseGateResult>{
                        new ActivateReleaseGateActionResultModel.ActivateReleaseGateResult(
                            productName,
                            gateName,
                            'active'
                        )
                    },
                    true,
                    null
                )
            );
        }

        public Object call(String action, Map<String, Object> args) {
            System.debug('Executing callable action: ' + action);
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
        public String getReleaseGates(Decimal version) {
            GetReleaseGateActionResultModel releaseGateResultModel = new GetReleaseGateActionResultModel(
                null,
                false,
                new CallableError(400, 'Test callable error')
            );
            return JSON.serialize(releaseGateResultModel);
        }

        public String activateReleaseGate(Decimal version, String productName, String gateName) {
            return JSON.serialize(
                new ActivateReleaseGateActionResultModel(null, false, new CallableError(400, 'Test callable error'))
            );
        }

        public Object call(String action, Map<String, Object> args) {
            System.debug('Executing callable action: ' + action);
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
     * Test Callable class with error response and null error
     */
    public class TestReleaseGateCallableNullErrorImpl implements Callable {
        public String getReleaseGates(Decimal version) {
            GetReleaseGateActionResultModel releaseGateResultModel = new GetReleaseGateActionResultModel(
                null,
                false,
                null
            );
            return JSON.serialize(releaseGateResultModel);
        }

        public String activateReleaseGate(Decimal version, String productName, String gateName) {
            return JSON.serialize(new ActivateReleaseGateActionResultModel(null, false, null));
        }

        public Object call(String action, Map<String, Object> args) {
            System.debug('Executing callable action: ' + action);
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
     * Test Callable class with unhandled exception
     */
    public class TestReleaseGateExceptionCallableImpl implements Callable {
        public Object call(String action, Map<String, Object> args) {
            System.debug('Executing callable action: ' + action);
            throw new IllegalArgumentException('Throwing an unhandled exception');
        }
    }

    /**
     * Test Callable class with JSON exception
     */
    public class TestReleaseGateJsonExceptionCallableImpl implements Callable {
        public Object call(String action, Map<String, Object> args) {
            return 'json exception';
        }
    }
}
