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
 * @description Test class for ProgramSettingsController class.
 */
@isTest
private with sharing class ProgramSettingsController_TEST {
    /****************************************************************************************
     * @description Test method to verify locateProgramSettingsVMapper() returns an instance of
     * the ProgramSettingsVMapper class.
     ****************************************************************************************/
    @isTest
    private static void locateProgramSettingsVMapperValid() {
        Test.startTest();
        ProgramSettingsVMapper programSettingsVMapperInstance = ProgramSettingsController.locateProgramSettingsVMapper();
        Test.stopTest();

        System.assertEquals(
            ProgramSettingsVMapper.getInstance(),
            programSettingsVMapperInstance,
            'Should return instance of ProgramSettingsVMapper class.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getProgramSettingsVModel()
     * returns an instance of ProgramSettingsVModel with valid values from valid stub.
     ****************************************************************************************/
    @isTest
    private static void getProgramSettingsVModelValid() {
        ProgramSettingsVMapper.instance = new STUB_ProgramSettingsVMapperValid();

        Test.startTest();
        ProgramSettingsVModel programSettingsVModel = ProgramSettingsController.getProgramSettingsVModel();
        Test.stopTest();

        System.assertEquals(
            2,
            programSettingsVModel.autoEnrollmentMappingVModels.size(),
            'Should return 2 autoEnrollmentMappingVModels.'
        );

        for (Integer i = 0; i < programSettingsVModel.autoEnrollmentMappingVModels.size(); i++) {
            System.assertEquals(
                'Record_Type_' + (i + 1),
                programSettingsVModel.autoEnrollmentMappingVModels[i].accountRecordTypeName,
                'Account record type name should match developer name of corresponding record type model.'
            );

            System.assertEquals(
                'Record Type ' + (i + 1),
                programSettingsVModel.autoEnrollmentMappingVModels[i].accountRecordTypeLabel,
                'Account record type label should match label of corresponding record type model.'
            );

            System.assertEquals(
                'autoProgramEnrollmentStatus' + (i + 1),
                programSettingsVModel.autoEnrollmentMappingVModels[i].autoProgramEnrollmentStatus,
                'Auto-Enrollment status should match.'
            );

            System.assertEquals(
                'autoProgramEnrollmentRole' + (i + 1),
                programSettingsVModel.autoEnrollmentMappingVModels[i].autoProgramEnrollmentRole,
                'Auto-Enrollment role should match.'
            );
        }
    }

    /****************************************************************************************
     * @description Test method to verify getProgramSettingsVModel()
     * throws an exception when exception occurs.
     ****************************************************************************************/
    @isTest
    private static void getProgramSettingsVModelException() {
        ProgramSettingsVMapper.instance = new STUB_ExceptionProgramSettingsVMapper();

        try {
            Test.startTest();
            ProgramSettingsVModel programSettingsVModel = ProgramSettingsController.getProgramSettingsVModel();
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /***********************************************************************************************************************************
     ****************************************************** STUBS ***********************************************************************
     ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate valid responses from ProgramSettingsVMapper
     **************************************************************************************************************************************/
    private class STUB_ProgramSettingsVMapperValid extends ProgramSettingsVMapper {
        public override ProgramSettingsVModel getProgramSettingsVModel() {
            List<AutoEnrollmentMappingVModel> autoEnrollmentMappingVModelsList = new List<AutoEnrollmentMappingVModel>();
            autoEnrollmentMappingVModelsList.add(
                new AutoEnrollmentMappingVModel(
                    'Record_Type_1',
                    'Record Type 1',
                    'autoProgramEnrollmentStatus1',
                    'autoProgramEnrollmentRole1'
                )
            );
            autoEnrollmentMappingVModelsList.add(
                new AutoEnrollmentMappingVModel(
                    'Record_Type_2',
                    'Record Type 2',
                    'autoProgramEnrollmentStatus2',
                    'autoProgramEnrollmentRole2'
                )
            );
            return new ProgramSettingsVModel(autoEnrollmentMappingVModelsList);
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate exception responses from ProgramSettingsVMapper
     **************************************************************************************************************************************/
    private class STUB_ExceptionProgramSettingsVMapper extends ProgramSettingsVMapper {
        public override ProgramSettingsVModel getProgramSettingsVModel() {
            throw new TestException('Exception encountered!');
        }
    }

    private class TestException extends Exception {
    }
}
