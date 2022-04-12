/*
    Copyright (c) 2022, Salesforce.org
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
 * @date 2022
 * @group
 * @group-content ../../ApexDocContent/
 * @description Test class for EDALatestReleaseGate
 */
@isTest
public with sharing class EDALatestReleaseGate_TEST {
    /**
     * @description test method to verify that getReleaseGate returns a valid release gate model
     */
    @isTest
    private static void getReleaseGate() {
        EDALatestReleaseGate latestReleaseGate = new EDALatestReleaseGate();

        Test.startTest();
        GetReleaseGateActionResultModel.ReleaseGate latestReleaseGateModel = latestReleaseGate.getReleaseGate(1);
        Test.stopTest();

        System.assertEquals(
            EDALatestReleaseGate.RELEASE_GATE_NAME,
            latestReleaseGateModel.name,
            'Release gate name should be ' + EDALatestReleaseGate.RELEASE_GATE_NAME
        );
        System.assertEquals('active', latestReleaseGateModel.status, 'Status name should be active');
        System.assertEquals(null, latestReleaseGateModel.activationDate, 'Activation date should be null');
        System.assertEquals(1, latestReleaseGateModel.items.size(), 'There should be 1 feature');
        System.assertEquals(
            EDALatestReleaseGate.RELEASE_GATE_FEATURE_NAME,
            latestReleaseGateModel.items[0].name,
            'Feature name should be ' + EDALatestReleaseGate.RELEASE_GATE_FEATURE_NAME
        );
        System.assertEquals(
            Label.stgReleaseGateEDALatestFeatureDescription,
            latestReleaseGateModel.items[0].description,
            'Incorrect feature description'
        );
        System.assertEquals(
            EDALatestReleaseGate.FEATURE_HELP_LINK,
            latestReleaseGateModel.items[0].helpLink,
            'Incorrect feature help link'
        );
    }

    /**
     * @description test method to verify that activateReleaseGate throws an exception
     */
    @isTest
    private static void activateReleaseGate() {
        EDALatestReleaseGate latestReleaseGate = new EDALatestReleaseGate();
        Boolean hadException = false;

        Test.startTest();
        try {
            ActivateReleaseGateActionResultModel latestReleaseGateModel = latestReleaseGate.activateReleaseGate(
                1,
                'EDA',
                EDALatestReleaseGate.RELEASE_GATE_NAME
            );
            System.assert(false, 'activateReleaseGate should throw an illegal argument exception');
            Test.stopTest();
        } catch (IllegalArgumentException iae) {
        } catch (Exception genericException) {
            System.assert(false, 'activateReleaseGate should throw an illegal argument exception');
        }
    }
}
