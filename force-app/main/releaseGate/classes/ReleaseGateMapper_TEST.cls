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
 * @description Test class for ReleaseGateMapper
 */
@isTest
public with sharing class ReleaseGateMapper_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * ReleaseGateMapperInstance class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        ReleaseGateMapper releaseGateMapperInstance = ReleaseGateMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ReleaseGateMapper.instance,
            releaseGateMapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(true, releaseGateMapperInstance != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * ReleaseGateMapperInstance class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        ReleaseGateMapper releaseGateMapperInstance1 = ReleaseGateMapper.getInstance();
        ReleaseGateMapper releaseGateMapperInstance2 = ReleaseGateMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ReleaseGateMapper.instance,
            releaseGateMapperInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            releaseGateMapperInstance1,
            releaseGateMapperInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(true, releaseGateMapperInstance1 != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getReleaseGates method returns a valid ReleaseGateAPIModel.GetActionResult
     ***************************************************************************************************************************/
    @isTest
    private static void getReleaseGatesValid() {
        //TODO: Revisit this when product registry functionality is implemented

        ReleaseGateMapper releaseGateMapperInstance = ReleaseGateMapper.getInstance();

        Test.startTest();
        ReleaseGateAPIModel.GetActionResult getReleaseGatesResult = releaseGateMapperInstance.getReleaseGates('test');
        Test.stopTest();

        System.assertEquals(true, getReleaseGatesResult.success, 'Expected successful response');
        System.assertEquals(1, getReleaseGatesResult.result.size(), 'Expected 1 release gate product in the list');
        System.assertEquals(
            'DemoGlobalCallable',
            getReleaseGatesResult.result[0].product.name,
            'Product name should be DemoGlobalCallable'
        );
        System.assertEquals(1, getReleaseGatesResult.result[0].gates.size(), 'Expected 1 release gate in the list');
        System.assertEquals('summer21', getReleaseGatesResult.result[0].gates[0].name, 'Gate name should be summer21');
        System.assertEquals(
            1,
            getReleaseGatesResult.result[0].gates[0].items.size(),
            'Expected 1 release gate item in the list'
        );
        System.assertEquals(
            'FlexibleAdviseeSnapshot',
            getReleaseGatesResult.result[0].gates[0].items[0].name,
            'Gate feature name should be FlexibleAdviseeSnapshot'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the activateReleaseGate method returns a valid ReleaseGateAPIModel.ActivateActionResult
     ***************************************************************************************************************************/
    @isTest
    private static void activateReleaseGateValid() {
        //TODO: Revisit this when product registry functionality is implemented

        ReleaseGateMapper releaseGateMapperInstance = ReleaseGateMapper.getInstance();
        ReleaseGateAPIModel.GetActionResult getReleaseGatesResult = releaseGateMapperInstance.getReleaseGates('test');
        String productName = getReleaseGatesResult.result[0].product.name;
        String gateName = getReleaseGatesResult.result[0].gates[0].name;

        Test.startTest();
        ReleaseGateAPIModel.ActivateActionResult activateReleaseGateResult = releaseGateMapperInstance.activateReleaseGate(
            'test',
            productName,
            gateName
        );
        Test.stopTest();

        System.assertEquals(true, activateReleaseGateResult.success, 'Expected successful response');
        System.assertEquals(
            1,
            activateReleaseGateResult.result.size(),
            'Expected 1 activated release gate product in the list'
        );
        System.assertEquals(
            productName,
            activateReleaseGateResult.result[0].productName,
            'Expected product name should be ' + productName
        );
        System.assertEquals(
            gateName,
            activateReleaseGateResult.result[0].gateName,
            'Expected gate name should be ' + gateName
        );
        System.assertEquals('active', activateReleaseGateResult.result[0].status, 'Expected status should be active');
    }
}
