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
 * @group-content ../../ApexDocContent/Tests.htm
 * @description Test class for PrimaryAffiliationSettingsVModel class
 */
@isTest
private with sharing class PrimaryAffiliationSettingsVModel_TEST {
    private static Integer loopCounter = 5;

    /****************************************************************************************
     * @description Test method to verify constructor returns a PrimaryAffiliationSettingsVModel
     * with all properties populated.
     ****************************************************************************************/
    @isTest
    private static void singleArgumentConstructorValid() {
        List<PrimaryAffiliationMappingVModel> primaryAffiliationMappings = new List<PrimaryAffiliationMappingVModel>();

        for (Integer i = 0; i < loopCounter; i++) {
            primaryAffiliationMappings.add(
                new PrimaryAffiliationMappingVModel(
                    'mappingName' + i,
                    'accountRecordTypeName' + i,
                    'accountRecordTypeLabel' + i,
                    'contactFieldName' + i,
                    'contactFieldLabel' + i,
                    true
                )
            );
        }

        Test.startTest();
        PrimaryAffiliationSettingsVModel primaryAffiliationSettingsVModel = new PrimaryAffiliationSettingsVModel(
            primaryAffiliationMappings
        );
        Test.stopTest();

        System.assertEquals(
            loopCounter,
            primaryAffiliationSettingsVModel.primaryAffiliationMappings.size(),
            'Settings View model should contain ' +
            loopCounter +
            ' primary affiliation mapping models.'
        );

        for (Integer i = 0; i < loopCounter; i++) {
            System.assertEquals(
                'mappingName' + i,
                primaryAffiliationSettingsVModel.primaryAffiliationMappings[i].mappingName,
                'Mapping name of primary affiliation mapping model should match value provided as argument.'
            );

            System.assertEquals(
                'accountRecordTypeName' + i,
                primaryAffiliationSettingsVModel.primaryAffiliationMappings[i].accountRecordTypeName,
                'Account Record Type Name of primary affiliation mapping model should match value provided as argument.'
            );

            System.assertEquals(
                'accountRecordTypeLabel' + i,
                primaryAffiliationSettingsVModel.primaryAffiliationMappings[i].accountRecordTypeLabel,
                'Account Record Type Label of primary affiliation mapping model should match value provided as argument.'
            );

            System.assertEquals(
                'contactFieldName' + i,
                primaryAffiliationSettingsVModel.primaryAffiliationMappings[i].contactFieldName,
                'Contact Field Name of primary affiliation mapping model should match value provided as argument.'
            );

            System.assertEquals(
                'contactFieldLabel' + i,
                primaryAffiliationSettingsVModel.primaryAffiliationMappings[i].contactFieldLabel,
                'Contact Field Label of primary affiliation mapping model should match value provided as argument.'
            );
        }
    }
}
