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
 * @description Test class for EDAWinter22ReleaseGate
 */
@isTest
public with sharing class EDAWinter22ReleaseGate_TEST {
    /**
     * @description test method to verify that getReleaseGate returns a valid release gate model
     */
    @isTest
    private static void getReleaseGate() {
        EDAWinter22ReleaseGate winter22ReleaseGate = new EDAWinter22ReleaseGate();

        Test.startTest();
        GetReleaseGateActionResultModel.ReleaseGate winter22ReleaseGateModel = winter22ReleaseGate.getReleaseGate(1);
        Test.stopTest();

        System.assertEquals(
            EDAWinter22ReleaseGate.RELEASE_GATE_NAME,
            winter22ReleaseGateModel.name,
            'Release gate name should be ' + EDAWinter22ReleaseGate.RELEASE_GATE_NAME
        );
        System.assertEquals('active', winter22ReleaseGateModel.status, 'Status name should be active');
        System.assertEquals(null, winter22ReleaseGateModel.activationDate, 'Activation date should be null');
        System.assertEquals(1, winter22ReleaseGateModel.items.size(), 'There should be 1 feature');
        System.assertEquals(
            EDAWinter22ReleaseGate.RELEASE_GATE_FEATURE_NAME,
            winter22ReleaseGateModel.items[0].name,
            'Feature name should be ' + EDAWinter22ReleaseGate.RELEASE_GATE_FEATURE_NAME
        );
        System.assertEquals(
            Label.stgReleaseGateEDAWinter22FeatureDescription,
            winter22ReleaseGateModel.items[0].description,
            'Incorrect feature description'
        );
        System.assertEquals(
            EDAWinter22ReleaseGate.FEATURE_HELP_LINK,
            winter22ReleaseGateModel.items[0].helpLink,
            'Incorrect feature help link'
        );
    }

    /**
     * @description test method to verify that activateReleaseGate throws an exception
     */
    @isTest
    private static void activateReleaseGate() {
        EDAWinter22ReleaseGate winter22ReleaseGate = new EDAWinter22ReleaseGate();
        Boolean hadException = false;

        Test.startTest();
        try {
            ActivateReleaseGateActionResultModel winter22ReleaseGateModel = winter22ReleaseGate.activateReleaseGate(
                1,
                'EDA',
                EDAWinter22ReleaseGate.RELEASE_GATE_NAME
            );
        } catch (IllegalArgumentException ex) {
            hadException = true;
        }
        Test.stopTest();

        System.assertEquals(true, hadException, 'activateReleaseGate should throw an exception');
    }
}
