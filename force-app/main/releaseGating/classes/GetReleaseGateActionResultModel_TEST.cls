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
 * @description Test class for GetReleaseGateActionResultModel
 */
@isTest
public with sharing class GetReleaseGateActionResultModel_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify the constructor is setting the properties correctly
     ***************************************************************************************************************************/
    @isTest
    private static void testConstructor() {
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
        List<GetReleaseGateActionResultModel.GetReleaseGateResult> resultList = new List<GetReleaseGateActionResultModel.GetReleaseGateResult>{
            new GetReleaseGateActionResultModel.GetReleaseGateResult(
                new GetReleaseGateActionResultModel.ReleaseGateProduct(productName, productLabel, nextRelease),
                new List<GetReleaseGateActionResultModel.ReleaseGate>{
                    new GetReleaseGateActionResultModel.ReleaseGate(
                        gateName,
                        gateLabel,
                        gateDescription,
                        releaseDate,
                        dueDate,
                        dueDateInfoText,
                        activationDate,
                        status,
                        new List<GetReleaseGateActionResultModel.ReleaseGateFeature>{
                            new GetReleaseGateActionResultModel.ReleaseGateFeature(
                                featureName,
                                featureLabel,
                                featureDescription,
                                helpLink,
                                helpLinkLabel
                            )
                        }
                    )
                }
            )
        };
        GetReleaseGateActionResultModel releaseGateModel = new GetReleaseGateActionResultModel(resultList, true, null);
        Test.stopTest();

        System.assertEquals(true, releaseGateModel.success, 'success should be true');
        System.assertEquals(null, releaseGateModel.error, 'error should be null');
        System.assertEquals(resultList, releaseGateModel.result, 'result is not correct');
        System.assertEquals(1, releaseGateModel.result.size(), 'result size should be 1');
        System.assertEquals(
            productName,
            releaseGateModel.result[0].product.name,
            'Product name should be ' + productName
        );
        System.assertEquals(
            productLabel,
            releaseGateModel.result[0].product.label,
            'Product label should be ' + productLabel
        );
        System.assertEquals(
            nextRelease,
            releaseGateModel.result[0].product.nextReleaseDate,
            'Product nextReleaseDate should be ' + nextRelease
        );
        System.assertEquals(1, releaseGateModel.result[0].gates.size(), 'Gates size should be 1');
        System.assertEquals(gateName, releaseGateModel.result[0].gates[0].name, 'Gate name should be ' + gateName);
        System.assertEquals(gateLabel, releaseGateModel.result[0].gates[0].label, 'Gate label should be ' + gateLabel);
        System.assertEquals(
            gateDescription,
            releaseGateModel.result[0].gates[0].description,
            'Gate description should be ' + gateDescription
        );
        System.assertEquals(
            releaseDate,
            releaseGateModel.result[0].gates[0].releaseDate,
            'Gate releaseDate should be ' + releaseDate
        );
        System.assertEquals(dueDate, releaseGateModel.result[0].gates[0].dueDate, 'Gate dueDate should be ' + dueDate);
        System.assertEquals(
            dueDateInfoText,
            releaseGateModel.result[0].gates[0].dueDateInfoText,
            'Gate dueDateInfoText should be ' + dueDateInfoText
        );
        System.assertEquals(
            activationDate,
            releaseGateModel.result[0].gates[0].activationDate,
            'Gate activationDate should be ' + activationDate
        );
        System.assertEquals(status, releaseGateModel.result[0].gates[0].status, 'Gate status should be ' + status);
        System.assertEquals(1, releaseGateModel.result[0].gates[0].items.size(), 'Gate feature size should be 1');
        System.assertEquals(
            featureName,
            releaseGateModel.result[0].gates[0].items[0].name,
            'Feature name should be ' + featureName
        );
        System.assertEquals(
            featureLabel,
            releaseGateModel.result[0].gates[0].items[0].label,
            'Feature label should be ' + featureLabel
        );
        System.assertEquals(
            featureDescription,
            releaseGateModel.result[0].gates[0].items[0].description,
            'Feature description should be ' + featureDescription
        );
        System.assertEquals(
            helpLink,
            releaseGateModel.result[0].gates[0].items[0].helpLink,
            'Feature helpLink should be ' + helpLink
        );
        System.assertEquals(
            helpLinkLabel,
            releaseGateModel.result[0].gates[0].items[0].helpLinkLabel,
            'Feature helpLinkLabel should be ' + helpLinkLabel
        );
    }
}
