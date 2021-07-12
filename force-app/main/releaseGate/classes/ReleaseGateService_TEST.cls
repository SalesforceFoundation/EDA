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
     * @description Test method to verify that the locateReleaseGateMapper method returns an instance
     * of the ReleaseGateMapper class.
     ***************************************************************************************************************************/
    @isTest
    private static void locateReleaseGateMapperValid() {
        ReleaseGateService releaseGateServiceInstance = ReleaseGateService.getInstance();

        Test.startTest();
        ReleaseGateMapper releaseGateMapperInstance = releaseGateServiceInstance.locateReleaseGateMapper();
        Test.stopTest();

        System.assertEquals(
            ReleaseGateMapper.getInstance(),
            releaseGateMapperInstance,
            'Should return instance of ReleaseGateMapper class.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getReleaseGates method returns a ReleaseGateModel
     ***************************************************************************************************************************/
    @isTest
    private static void getReleaseGatesValid() {
        ReleaseGateMapper.instance = new STUB_ReleaseGateMapper();

        ReleaseGateService releaseGateServiceInstance = ReleaseGateService.getInstance();

        Test.startTest();
        ReleaseGateAPIModel.GetReleaseGateResult[] getReleaseGatesResults = releaseGateServiceInstance.getReleaseGates(
            'TestName'
        );
        Test.stopTest();

        System.assertEquals(1, getReleaseGatesResults.size(), 'Expected 1 release gate product in the list');
        System.assertEquals(
            'TestProduct',
            getReleaseGatesResults[0].product.name,
            'Product name should be TestProduct'
        );
        System.assertEquals(1, getReleaseGatesResults[0].gates.size(), 'Expected 1 release gate in the list');
        System.assertEquals(
            'TestReleaseGate',
            getReleaseGatesResults[0].gates[0].name,
            'Gate name should be TestReleaseGate'
        );
    }

    /***********************************************************************************************************************************
     ****************************************************** STUBS ***********************************************************************
     ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from ReleaseGateMapper to return
     * a valid ReleaseGateModel
     **************************************************************************************************************************************/
    private class STUB_ReleaseGateMapper extends ReleaseGateMapper {
        public override ReleaseGateAPIModel.GetActionResult getReleaseGates(String productRegistryName) {
            ReleaseGateAPIModel.GetActionResult getResult = new ReleaseGateAPIModel.GetActionResult();
            getResult.success = true;
            getResult.result = new List<ReleaseGateAPIModel.GetReleaseGateResult>();
            ReleaseGateAPIModel.GetReleaseGateResult releaseGateResult = new ReleaseGateAPIModel.GetReleaseGateResult();
            getResult.result.add(releaseGateResult);
            releaseGateResult.product = new ReleaseGateAPIModel.ReleaseGateProduct();
            releaseGateResult.product.name = 'TestProduct';
            releaseGateResult.gates = new List<ReleaseGateAPIModel.ReleaseGate>();
            ReleaseGateAPIModel.ReleaseGate releaseGate = new ReleaseGateAPIModel.ReleaseGate();
            releaseGate.name = 'TestReleaseGate';
            releaseGateResult.gates.add(releaseGate);
            return getResult;
        }

        public override ReleaseGateAPIModel.ActivateActionResult activateReleaseGate(
            String productRegistryName,
            String productName,
            String gateName
        ) {
            ReleaseGateAPIModel.ActivateActionResult activateResult = new ReleaseGateAPIModel.ActivateActionResult();
            activateResult.result = new List<ReleaseGateAPIModel.ActivateReleaseGateResult>();
            ReleaseGateAPIModel.ActivateReleaseGateResult activateReleaseGateResult = new ReleaseGateAPIModel.ActivateReleaseGateResult();
            activateReleaseGateResult.productName = 'TestProduct';
            activateReleaseGateResult.gateName = 'TestReleaseGate';
            activateReleaseGateResult.status = 'active';
            activateResult.result.add(activateReleaseGateResult);
            return activateResult;
        }
    }
}
