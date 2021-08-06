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
 * @description Test class for ReleaseGateVMapper
 */
@isTest
public with sharing class ReleaseGateVMapper_TEST {
    /**************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * ReleaseGateVMapper class when one does not already exist.
     **************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        ReleaseGateVMapper releaseGateVMapperInstance = ReleaseGateVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ReleaseGateVMapper.instance,
            releaseGateVMapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(true, releaseGateVMapperInstance != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * ReleaseGateVMapper class when one already exists.
     **************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        ReleaseGateVMapper releaseGateVMapperInstance1 = ReleaseGateVMapper.getInstance();
        ReleaseGateVMapper releaseGateVMapperInstance2 = ReleaseGateVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ReleaseGateVMapper.instance,
            releaseGateVMapperInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            releaseGateVMapperInstance1,
            releaseGateVMapperInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(true, releaseGateVMapperInstance1 != null, 'Instance of mapper class should not be null.');
    }

    /****************************************************************************************
     * @description Test method to verify locateReleaseGateService() returns an instance of
     * the ReleaseGateService class.
     ****************************************************************************************/
    @isTest
    private static void locateReleaseGateServiceValid() {
        ReleaseGateVMapper releaseGateVMapperInstance = ReleaseGateVMapper.getInstance();

        Test.startTest();
        ReleaseGateService releaseGateServiceInstance = releaseGateVMapperInstance.locateReleaseGateService();
        Test.stopTest();

        System.assertEquals(
            ReleaseGateService.getInstance(),
            releaseGateServiceInstance,
            'Should return instance of ReleaseGateService class.'
        );
    }

    /************************************************************************************************************************************
     * @description Test method to verify getReleaseGateVModel returns a ReleaseGateVModel
     ************************************************************************************************************************************/
    @isTest
    private static void getReleaseGateVModelValid() {
        ReleaseGateService.instance = new STUB_ReleaseGateService();

        ReleaseGateVMapper releaseGateVMapperInstance = ReleaseGateVMapper.getInstance();

        Test.startTest();
        List<ReleaseGateVModel> releaseGateVModelList = releaseGateVMapperInstance.getReleaseGateVModel(
            'testProductRegistry'
        );
        Test.stopTest();

        System.assertEquals(
            1,
            releaseGateVModelList.size(),
            'There should be 1 item in the list of release gate products'
        );
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
            1,
            releaseGateVModelList[0].gates.size(),
            'There should be 1 item in the list of release gates'
        );
        System.assertEquals(
            'testgate',
            releaseGateVModelList[0].gates[0].name,
            'Expected gate name should be \'testgate\''
        );
        System.assertEquals(
            'test gate',
            releaseGateVModelList[0].gates[0].label,
            'Expected gate label should be \'test gate\''
        );
        System.assertEquals(
            1,
            releaseGateVModelList[0].gates[0].features.size(),
            'There should be 1 item in the list of release gate features'
        );
        System.assertEquals(
            'testfeature',
            releaseGateVModelList[0].gates[0].features[0].name,
            'Expected feature name should be \'testfeature\''
        );
        System.assertEquals(
            'test feature',
            releaseGateVModelList[0].gates[0].features[0].label,
            'Expected feature label should be \'test feature\''
        );
    }

    /***********************************************************************************************************************************
     ****************************************************** STUBS ***********************************************************************
     ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from ReleaseGateService to return a valid respose
     **************************************************************************************************************************************/
    private class STUB_ReleaseGateService extends ReleaseGateService {
        public override GetReleaseGateActionResultModel getReleaseGateModel(String productRegistryName) {
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
            GetReleaseGateActionResultModel releaseGateModel = new GetReleaseGateActionResultModel(
                resultList,
                true,
                null
            );
            return releaseGateModel;
        }
    }
}
