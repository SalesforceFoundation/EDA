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
 * @description Test class for ReleaseGateVModel
 */
@isTest
public with sharing class ReleaseGateVModel_TEST {
    /***********************************************************************************************************
     * @description Test to verify constructor returns a ReleaseGateVModel
     * with all properties populated.
     ***********************************************************************************************************/
    @isTest
    private static void constructorValid() {
        String productName = 'testproduct';
        String productLabel = 'test product';
        String nextRelease = 'January 2022';
        String gateName = 'testgate';
        String gateLabel = 'test gate';
        String gateDescription = 'test gate description';
        Date releaseDate = Date.today();
        Date dueDate = Date.today().addMonths(6);
        String dueDateInfoText = 'Due date info text';
        Datetime activationDate = Datetime.now();
        String status = 'inactive';
        String featureName = 'testfeature';
        String featureLabel = 'test feature';
        String featureDescription = 'test gate description';
        String helpLink = 'https://www.salesforce.com';
        String helpLinkLabel = 'Test help link label';

        Test.startTest();
        ReleaseGateVModel releaseGateViewModel = new ReleaseGateVModel(
            new ReleaseGateVModel.ReleaseGateProduct(productName, productLabel, nextRelease),
            new List<ReleaseGateVModel.ReleaseGate>{
                new ReleaseGateVModel.ReleaseGate(
                    gateName,
                    gateLabel,
                    gateDescription,
                    releaseDate,
                    dueDate,
                    dueDateInfoText,
                    activationDate,
                    status,
                    new List<ReleaseGateVModel.ReleaseGateFeature>{
                        new ReleaseGateVModel.ReleaseGateFeature(
                            featureName,
                            featureLabel,
                            featureDescription,
                            helpLink,
                            helpLinkLabel
                        )
                    }
                )
            }
        );
        Test.stopTest();

        System.assertEquals(productName, releaseGateViewModel.product.name, 'Product name should be ' + productName);
        System.assertEquals(
            productLabel,
            releaseGateViewModel.product.label,
            'Product label should be ' + productLabel
        );
        System.assertEquals(
            nextRelease,
            releaseGateViewModel.product.nextReleaseDate,
            'Product nextReleaseDate should be ' + nextRelease
        );
        System.assertEquals(1, releaseGateViewModel.gates.size(), 'Gates size should be 1');
        System.assertEquals(gateName, releaseGateViewModel.gates[0].name, 'Gate name should be ' + gateName);
        System.assertEquals(gateLabel, releaseGateViewModel.gates[0].label, 'Gate label should be ' + gateLabel);
        System.assertEquals(
            gateDescription,
            releaseGateViewModel.gates[0].description,
            'Gate description should be ' + gateDescription
        );
        System.assertEquals(
            releaseDate,
            releaseGateViewModel.gates[0].releaseDate,
            'Gate releaseDate should be ' + releaseDate
        );
        System.assertEquals(dueDate, releaseGateViewModel.gates[0].dueDate, 'Gate dueDate should be ' + dueDate);
        System.assertEquals(
            dueDateInfoText,
            releaseGateViewModel.gates[0].dueDateInfoText,
            'Gate dueDateInfoText should be ' + dueDateInfoText
        );
        System.assertEquals(
            activationDate,
            releaseGateViewModel.gates[0].activationDate,
            'Gate activationDate should be ' + activationDate
        );
        System.assertEquals(status, releaseGateViewModel.gates[0].status, 'Gate status should be ' + status);
        System.assertEquals(1, releaseGateViewModel.gates[0].features.size(), 'Gate feature size should be 1');
        System.assertEquals(
            featureName,
            releaseGateViewModel.gates[0].features[0].name,
            'Feature name should be ' + featureName
        );
        System.assertEquals(
            featureLabel,
            releaseGateViewModel.gates[0].features[0].label,
            'Feature label should be ' + featureLabel
        );
        System.assertEquals(
            featureDescription,
            releaseGateViewModel.gates[0].features[0].description,
            'Feature description should be ' + featureDescription
        );
        System.assertEquals(
            helpLink,
            releaseGateViewModel.gates[0].features[0].helpLink,
            'Feature helpLink should be ' + helpLink
        );
        System.assertEquals(
            helpLinkLabel,
            releaseGateViewModel.gates[0].features[0].helpLinkLabel,
            'Feature helpLinkLabel should be ' + helpLinkLabel
        );
    }
}
