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
 * @description Test class for EDAReleaseGateProvider
 */
@isTest
public with sharing class EDAReleaseGateProvider_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify the constructor is setting the properties correctly
     ***************************************************************************************************************************/
    @isTest
    private static void testConstructor() {
        Test.startTest();
        EDAReleaseGateProvider edaReleaseGateProvideInstance = new EDAReleaseGateProvider();
        Test.stopTest();

        System.assertEquals(
            1,
            edaReleaseGateProvideInstance.releaseGatesMap.size(),
            'There should be 1 release gates in the map'
        );
        EDALatestReleaseGate latestReleaseGate = (EDALatestReleaseGate) edaReleaseGateProvideInstance.releaseGatesMap.get(
            EDALatestReleaseGate.RELEASE_GATE_NAME
        );
        System.assertEquals(
            EDALatestReleaseGate.RELEASE_GATE_NAME,
            latestReleaseGate.getReleaseGateName(),
            'The release gate name should be ' + EDALatestReleaseGate.RELEASE_GATE_NAME
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that getReleaseGates returns a valid list
     ***************************************************************************************************************************/
    @isTest
    private static void getReleaseGates() {
        EDAReleaseGateProvider edaReleaseGateProvideInstance = new EDAReleaseGateProvider();
        edaReleaseGateProvideInstance.releaseGatesMap.clear();
        STUB_ReleaseGate stubReleaseGate = new STUB_ReleaseGate();
        edaReleaseGateProvideInstance.releaseGatesMap.put(stubReleaseGate.getReleaseGateName(), stubReleaseGate);

        Test.startTest();
        GetReleaseGateActionResultModel getReleaseGateModel = edaReleaseGateProvideInstance.getReleaseGates(53.0);
        Test.stopTest();

        System.assertEquals(1, getReleaseGateModel.result.size(), 'There should be 1 result in the list');
        System.assertEquals(
            1,
            getReleaseGateModel.result[0].gates.size(),
            'There should be 1 release gate in the list'
        );
        System.assertEquals(
            EDAReleaseGateProvider.PRODUCT_NAME,
            getReleaseGateModel.result[0].product.name,
            'Product name should be ' + EDAReleaseGateProvider.PRODUCT_NAME
        );
        System.assertEquals(
            'testReleaseGate',
            getReleaseGateModel.result[0].gates[0].name,
            'Gate name should be testReleaseGate'
        );
        System.assertEquals(
            'testLabel',
            getReleaseGateModel.result[0].gates[0].label,
            'Gate label should be testLabel'
        );
        System.assertEquals(
            'testDescription',
            getReleaseGateModel.result[0].gates[0].description,
            'Gate description should be testDescription'
        );
        System.assertEquals(
            1,
            getReleaseGateModel.result[0].gates[0].items.size(),
            'There should be 1 release gate feature in the list'
        );
        System.assertEquals(
            'testFeatureName',
            getReleaseGateModel.result[0].gates[0].items[0].name,
            'Feature name should be testFeatureName'
        );
        System.assertEquals(
            'testFeatureLabel',
            getReleaseGateModel.result[0].gates[0].items[0].label,
            'Feature label should be testFeatureLabel'
        );
        System.assertEquals(
            'testFeatureDescription',
            getReleaseGateModel.result[0].gates[0].items[0].description,
            'Feature description should be testFeatureDescription'
        );
        System.assertEquals(
            'testHelpLinkLabel',
            getReleaseGateModel.result[0].gates[0].items[0].helpLinkLabel,
            'Feature help link label should be testHelpLinkLabel'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that activateReleaseGate returns a valid result
     ***************************************************************************************************************************/
    @isTest
    private static void activateReleaseGate() {
        EDAReleaseGateProvider edaReleaseGateProvideInstance = new EDAReleaseGateProvider();
        edaReleaseGateProvideInstance.releaseGatesMap.clear();
        STUB_ReleaseGate stubReleaseGate = new STUB_ReleaseGate();
        edaReleaseGateProvideInstance.releaseGatesMap.put(stubReleaseGate.getReleaseGateName(), stubReleaseGate);

        Test.startTest();
        ActivateReleaseGateActionResultModel activateReleaseGateModel = edaReleaseGateProvideInstance.activateReleaseGate(
            53.0,
            EDAReleaseGateProvider.PRODUCT_NAME,
            'testReleaseGate'
        );
        Test.stopTest();

        System.assertEquals(1, activateReleaseGateModel.result.size(), 'There should be 1 result in the list');
        System.assertEquals(
            'testProductName',
            activateReleaseGateModel.result[0].productName,
            'Activated product name should be ' + EDAReleaseGateProvider.PRODUCT_NAME
        );
        System.assertEquals(
            'testReleaseGate',
            activateReleaseGateModel.result[0].gateName,
            'Activated gate name should be testReleaseGate'
        );
        System.assertEquals('active', activateReleaseGateModel.result[0].status, 'Activated status should be active');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that activateReleaseGate returns a valid result
     ***************************************************************************************************************************/
    @isTest
    private static void activateReleaseGateException() {
        EDAReleaseGateProvider edaReleaseGateProvideInstance = new EDAReleaseGateProvider();
        edaReleaseGateProvideInstance.releaseGatesMap.clear();
        STUB_ReleaseGate stubReleaseGate = new STUB_ReleaseGate();
        edaReleaseGateProvideInstance.releaseGatesMap.put(stubReleaseGate.getReleaseGateName(), stubReleaseGate);
        Boolean hadProductException = false;
        Boolean hadGateException = false;

        Test.startTest();
        try {
            ActivateReleaseGateActionResultModel activateReleaseGateModel = edaReleaseGateProvideInstance.activateReleaseGate(
                53.0,
                'invalidProduct',
                'testReleaseGate'
            );
        } catch (IllegalArgumentException ex) {
            hadProductException = true;
        }
        try {
            ActivateReleaseGateActionResultModel activateReleaseGateModel = edaReleaseGateProvideInstance.activateReleaseGate(
                53.0,
                EDAReleaseGateProvider.PRODUCT_NAME,
                'invalidGate'
            );
        } catch (IllegalArgumentException ex) {
            hadGateException = true;
        }
        Test.stopTest();

        System.assertEquals(true, hadProductException, 'Exception should be thrown for invalid product');
        System.assertEquals(true, hadGateException, 'Exception should be thrown for invalid gate');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that ReleaseGateAPIService.GET_ACTION returns a valid list
     ***************************************************************************************************************************/
    @isTest
    private static void getReleaseGatesCallable() {
        EDAReleaseGateProvider edaReleaseGateProvideInstance = new EDAReleaseGateProvider();
        edaReleaseGateProvideInstance.releaseGatesMap.clear();
        STUB_ReleaseGate stubReleaseGate = new STUB_ReleaseGate();
        edaReleaseGateProvideInstance.releaseGatesMap.put(stubReleaseGate.getReleaseGateName(), stubReleaseGate);

        Test.startTest();
        Object result = edaReleaseGateProvideInstance.call(
            ReleaseGateAPIService.GET_ACTION,
            new Map<String, Object>{ ReleaseGateAPIService.VERSION_PARAMETER => 53.0 }
        );
        GetReleaseGateActionResultModel getReleaseGateModel = (GetReleaseGateActionResultModel) JSON.deserialize(
            (String) result,
            GetReleaseGateActionResultModel.class
        );
        Test.stopTest();

        System.assertEquals(1, getReleaseGateModel.result.size(), 'There should be 1 result in the list');
        System.assertEquals(
            1,
            getReleaseGateModel.result[0].gates.size(),
            'There should be 1 release gate in the list'
        );
        System.assertEquals(
            EDAReleaseGateProvider.PRODUCT_NAME,
            getReleaseGateModel.result[0].product.name,
            'Product name should be ' + EDAReleaseGateProvider.PRODUCT_NAME
        );
        System.assertEquals(
            'testReleaseGate',
            getReleaseGateModel.result[0].gates[0].name,
            'Gate name should be testReleaseGate'
        );
        System.assertEquals(
            'testLabel',
            getReleaseGateModel.result[0].gates[0].label,
            'Gate label should be testLabel'
        );
        System.assertEquals(
            'testDescription',
            getReleaseGateModel.result[0].gates[0].description,
            'Gate description should be testDescription'
        );
        System.assertEquals(
            1,
            getReleaseGateModel.result[0].gates[0].items.size(),
            'There should be 1 release gate feature in the list'
        );
        System.assertEquals(
            'testFeatureName',
            getReleaseGateModel.result[0].gates[0].items[0].name,
            'Feature name should be testFeatureName'
        );
        System.assertEquals(
            'testFeatureLabel',
            getReleaseGateModel.result[0].gates[0].items[0].label,
            'Feature label should be testFeatureLabel'
        );
        System.assertEquals(
            'testFeatureDescription',
            getReleaseGateModel.result[0].gates[0].items[0].description,
            'Feature description should be testFeatureDescription'
        );
        System.assertEquals(
            'testHelpLinkLabel',
            getReleaseGateModel.result[0].gates[0].items[0].helpLinkLabel,
            'Feature help link label should be testHelpLinkLabel'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that ACTIVATE_ACTION action returns a valid result
     ***************************************************************************************************************************/
    @isTest
    private static void activateReleaseGateCallable() {
        EDAReleaseGateProvider edaReleaseGateProvideInstance = new EDAReleaseGateProvider();
        edaReleaseGateProvideInstance.releaseGatesMap.clear();
        STUB_ReleaseGate stubReleaseGate = new STUB_ReleaseGate();
        edaReleaseGateProvideInstance.releaseGatesMap.put(stubReleaseGate.getReleaseGateName(), stubReleaseGate);

        Test.startTest();
        Object result = edaReleaseGateProvideInstance.call(
            ReleaseGateAPIService.ACTIVATE_ACTION,
            new Map<String, Object>{
                ReleaseGateAPIService.VERSION_PARAMETER => 53.0,
                ReleaseGateAPIService.PRODUCT_PARAMETER => EDAReleaseGateProvider.PRODUCT_NAME,
                ReleaseGateAPIService.GATE_PARAMETER => 'testReleaseGate'
            }
        );
        ActivateReleaseGateActionResultModel activateReleaseGateModel = (ActivateReleaseGateActionResultModel) JSON.deserialize(
            (String) result,
            ActivateReleaseGateActionResultModel.class
        );
        Test.stopTest();

        System.assertEquals(1, activateReleaseGateModel.result.size(), 'There should be 1 result in the list');
        System.assertEquals(
            'testProductName',
            activateReleaseGateModel.result[0].productName,
            'Activated product name should be ' + EDAReleaseGateProvider.PRODUCT_NAME
        );
        System.assertEquals(
            'testReleaseGate',
            activateReleaseGateModel.result[0].gateName,
            'Activated gate name should be testReleaseGate'
        );
        System.assertEquals('active', activateReleaseGateModel.result[0].status, 'Activated status should be active');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that call throws an exception when invalid action is specified
     ***************************************************************************************************************************/
    @isTest
    private static void callableException() {
        EDAReleaseGateProvider edaReleaseGateProvideInstance = new EDAReleaseGateProvider();
        Boolean hadException = false;

        Test.startTest();
        try {
            Object result = edaReleaseGateProvideInstance.call(
                'InvalidAction',
                new Map<String, Object>{
                    ReleaseGateAPIService.VERSION_PARAMETER => 53.0,
                    ReleaseGateAPIService.PRODUCT_PARAMETER => EDAReleaseGateProvider.PRODUCT_NAME,
                    ReleaseGateAPIService.GATE_PARAMETER => 'testReleaseGate'
                }
            );
        } catch (IllegalArgumentException ex) {
            hadException = true;
        }
        Test.stopTest();

        System.assertEquals(true, hadException, 'An exception should be thrown for an invalid action');
    }

    /***********************************************************************************************************************************
     ****************************************************** STUBS ***********************************************************************
     ***********************************************************************************************************************************/

    /**
     * Stub class to simulate a release gate
     */
    public with sharing class STUB_ReleaseGate extends ReleaseGateBase {
        /**
         * @description Get the name of the release gate
         * @return   A string representing release gate name
         */
        public override String getReleaseGateName() {
            return 'testReleaseGate';
        }

        /**
         * @description Get a release gate instance
         * @param  version Callable API version
         * @return         A release gate instance
         */
        public override GetReleaseGateActionResultModel.ReleaseGate getReleaseGate(Decimal version) {
            return new GetReleaseGateActionResultModel.ReleaseGate(
                this.getReleaseGateName(),
                'testLabel',
                'testDescription',
                Date.newInstance(2021, 11, 16),
                null,
                'testDueDateInfo',
                null,
                ReleaseGateAPIService.ReleaseGateStatus.ACTIVE.name().toLowerCase(),
                new List<GetReleaseGateActionResultModel.ReleaseGateFeature>{
                    new GetReleaseGateActionResultModel.ReleaseGateFeature(
                        'testFeatureName',
                        'testFeatureLabel',
                        'testFeatureDescription',
                        'testUrl',
                        'testHelpLinkLabel'
                    )
                }
            );
        }

        /**
         * @description Activate a release gate
         * @param  version     Callable API version
         * @param  productName Release gate product name
         * @param  gateName    Release gate name
         * @return             Activate release gate result
         */
        public override ActivateReleaseGateActionResultModel activateReleaseGate(
            Decimal version,
            String productName,
            String gateName
        ) {
            return new ActivateReleaseGateActionResultModel(
                new List<ActivateReleaseGateActionResultModel.ActivateReleaseGateResult>{
                    new ActivateReleaseGateActionResultModel.ActivateReleaseGateResult(
                        'testProductName',
                        gateName,
                        'active'
                    )
                },
                true,
                null
            );
        }
    }
}
