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
 * @description Test class for AutoEnrollmentMappingsVModel class.
 */
@isTest
private with sharing class AutoEnrollmentMappingsVModel_TEST {
    /*****************************************************************************
     * @description Test to verify constructor instantiates a
     * model with the appropriate data.
     *****************************************************************************/
    @isTest
    private static void autoEnrollmentMappingsModelValid() {
        Test.startTest();
        List<AutoEnrollmentMappingVModel> autoEnrollmentMappingVModels = new List<AutoEnrollmentMappingVModel>();
        for (Integer i = 0; i < 5; i++) {
            AutoEnrollmentMappingVModel autoEnrollmentMappingVModel = new AutoEnrollmentMappingVModel(
                'Test Mapping' + i,
                'Test Account Record Type Name' + i,
                'Test Account Record Type Label' + i,
                'Test Status' + i,
                'Test Role' + i
            );
            autoEnrollmentMappingVModels.add(autoEnrollmentMappingVModel);
        }
        AutoEnrollmentMappingsVModel programSettingsVModel = new AutoEnrollmentMappingsVModel(
            autoEnrollmentMappingVModels
        );
        Test.stopTest();

        System.assertEquals(
            5,
            programSettingsVModel.autoEnrollmentMappingVModels.size(),
            'The size of autoEnrollmentMappingVModels under programSettingsVModel should be 5'
        );
        System.assertEquals(
            'Test Mapping0',
            programSettingsVModel.autoEnrollmentMappingVModels[0].mappingName,
            'Mapping name should be \'Test Mapping Name0\'.'
        );
        System.assertEquals(
            'Test Account Record Type Name0',
            programSettingsVModel.autoEnrollmentMappingVModels[0].accountRecordTypeName,
            'Record Type name should be \'Test Account Record Type Name0\'.'
        );
        System.assertEquals(
            'Test Account Record Type Label0',
            programSettingsVModel.autoEnrollmentMappingVModels[0].accountRecordTypeLabel,
            'Record Type label should be \'Test Account Record Type Label0\'.'
        );
        System.assertEquals(
            'Test Status0',
            programSettingsVModel.autoEnrollmentMappingVModels[0].autoProgramEnrollmentStatus,
            'Enrollment Status should be \'Test Status0\'.'
        );
        System.assertEquals(
            'Test Role0',
            programSettingsVModel.autoEnrollmentMappingVModels[0].autoProgramEnrollmentRole,
            'Enrollment Role should be \'Test Role0\'.'
        );
    }
}
