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
    private static Integer loopCounter = 5;

    /****************************************************************************************
     * @description Test method to verify locateAutoEnrollmentMappingsVMapper() returns an instance of
     * the AutoEnrollmentMappingsVMapper class.
     ****************************************************************************************/
    @isTest
    private static void locateAutoEnrollmentMappingsVMapperValid() {
        Test.startTest();
        AutoEnrollmentMappingsVMapper autoEnrollmentMappingsVMapperInstance = ProgramSettingsController.locateAutoEnrollmentMappingsVMapper();
        Test.stopTest();

        System.assertEquals(
            AutoEnrollmentMappingsVMapper.getInstance(),
            autoEnrollmentMappingsVMapperInstance,
            'Should return instance of AutoEnrollmentMappingsVMapper class.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify AutoEnrollmentMappingService() returns an instance of
     * the AutoEnrollmentMappingService class.
     ****************************************************************************************/
    @isTest
    private static void locateAutoEnrollmentMappingService() {
        Test.startTest();
        AutoEnrollmentMappingService autoEnrollmentMappingServiceInstance = ProgramSettingsController.locateAutoEnrollmentMappingService();
        Test.stopTest();

        System.assertEquals(
            AutoEnrollmentMappingService.getInstance(),
            autoEnrollmentMappingServiceInstance,
            'Should return instance of AutoEnrollmentMappingService class.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getAutoEnrollmentMappingsVModel()
     * returns an instance of AutoEnrollmentMappingsVModel with valid values from valid stub.
     ****************************************************************************************/
    @isTest
    private static void getAutoEnrollmentMappingsVModelValid() {
        AutoEnrollmentMappingsVMapper.instance = new STUB_AutoEnrollmentMappingsVMapperValid();

        Test.startTest();
        AutoEnrollmentMappingsVModel autoEnrollmentMappingsVModel = ProgramSettingsController.getAutoEnrollmentMappingsVModel();
        Test.stopTest();

        System.assertEquals(
            2,
            autoEnrollmentMappingsVModel.autoEnrollmentMappingVModels.size(),
            'Should return 2 autoEnrollmentMappingVModels.'
        );

        for (Integer i = 0; i < autoEnrollmentMappingsVModel.autoEnrollmentMappingVModels.size(); i++) {
            System.assertEquals(
                'Record_Type_' + (i + 1),
                autoEnrollmentMappingsVModel.autoEnrollmentMappingVModels[i].accountRecordTypeName,
                'Account record type name should match developer name of corresponding record type model.'
            );

            System.assertEquals(
                'Record Type ' + (i + 1),
                autoEnrollmentMappingsVModel.autoEnrollmentMappingVModels[i].accountRecordTypeLabel,
                'Account record type label should match label of corresponding record type model.'
            );

            System.assertEquals(
                'autoProgramEnrollmentStatus' + (i + 1),
                autoEnrollmentMappingsVModel.autoEnrollmentMappingVModels[i].autoProgramEnrollmentStatus,
                'Auto-Enrollment status should match.'
            );

            System.assertEquals(
                'autoProgramEnrollmentRole' + (i + 1),
                autoEnrollmentMappingsVModel.autoEnrollmentMappingVModels[i].autoProgramEnrollmentRole,
                'Auto-Enrollment role should match.'
            );
        }
    }

    /****************************************************************************************
     * @description Test method to verify getAutoEnrollmentMappingsVModel()
     * throws an exception when exception occurs.
     ****************************************************************************************/
    @isTest
    private static void getAutoEnrollmentMappingsVModelException() {
        AutoEnrollmentMappingsVMapper.instance = new STUB_ExceptionAutoEnrollmentMappingsVMapper();

        try {
            Test.startTest();
            AutoEnrollmentMappingsVModel autoEnrollmentMappingsVModel = ProgramSettingsController.getAutoEnrollmentMappingsVModel();
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /****************************************************************************************
     * @description Test method to verify getAccountRecordTypeComboboxVModelValid()
     * returns an instance of ComboBoxVModel with valid values from valid stub.
     ****************************************************************************************/
    @isTest
    private static void getAccountRecordTypeComboboxVModelValid() {
        AutoEnrollmentMappingsVMapper.instance = new STUB_AutoEnrollmentMappingsVMapperValid();

        Test.startTest();
        ComboBoxVModel accountRecordTypeComboboxVModel = ProgramSettingsController.getAccountRecordTypeComboboxVModel(
            'Record_Type_1'
        );
        Test.stopTest();

        System.assertEquals(
            'Record_Type_1',
            accountRecordTypeComboboxVModel.value,
            'The value of accountRecordTypeComboboxVModel should be Record_Type_1'
        );

        System.assertEquals(
            1,
            accountRecordTypeComboboxVModel.options.size(),
            'The size of accountRecordTypeComboboxVModel options should be 1'
        );

        System.assertEquals(
            'Record_Type_1',
            accountRecordTypeComboboxVModel.options[0].value,
            'The value of accountRecordTypeComboboxVModel option 1 should be Record_Type_1'
        );

        System.assertEquals(
            'Record Type 1',
            accountRecordTypeComboboxVModel.options[0].label,
            'The label of accountRecordTypeComboboxVModel option 1 should be Record Type 1'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getAccountRecordTypeComboboxVModel()
     * throws an exception when exception occurs.
     ****************************************************************************************/
    @isTest
    private static void getAccountRecordTypeComboboxVModelException() {
        AutoEnrollmentMappingsVMapper.instance = new STUB_ExceptionAutoEnrollmentMappingsVMapper();
        try {
            Test.startTest();
            ComboBoxVModel accountRecordTypeComboboxVModel = ProgramSettingsController.getAccountRecordTypeComboboxVModel(
                'Record_Type_1'
            );
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /****************************************************************************************
     * @description Test method to verify getAutoEnrollmentMappingStatusComboboxVModel()
     * returns an instance of ComboBoxVModel with valid values from valid stub.
     ****************************************************************************************/
    @isTest
    private static void getAutoEnrollmentMappingStatusComboboxVModelValid() {
        AutoEnrollmentMappingsVMapper.instance = new STUB_AutoEnrollmentMappingsVMapperValid();

        Test.startTest();
        ComboBoxVModel autoEnrollmentMappingStatusComboboxVModel = ProgramSettingsController.getAutoEnrollmentMappingStatusComboboxVModel(
            'Test_Status'
        );
        Test.stopTest();

        System.assertEquals(
            'Test_Status',
            autoEnrollmentMappingStatusComboboxVModel.value,
            'The value of autoEnrollmentMappingStatusComboboxVModel should be Test_Status'
        );

        System.assertEquals(
            1,
            autoEnrollmentMappingStatusComboboxVModel.options.size(),
            'The size of autoEnrollmentMappingStatusComboboxVModel options should be 1'
        );

        System.assertEquals(
            'Test_Status',
            autoEnrollmentMappingStatusComboboxVModel.options[0].value,
            'The value of autoEnrollmentMappingStatusComboboxVModel option 1 should be Test_Status'
        );

        System.assertEquals(
            'Test Status',
            autoEnrollmentMappingStatusComboboxVModel.options[0].label,
            'The label of autoEnrollmentMappingStatusComboboxVModel option 1 should be Test Status'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getAutoEnrollmentMappingStatusComboboxVModel()
     * throws an exception when exception occurs.
     ****************************************************************************************/
    @isTest
    private static void getAutoEnrollmentMappingStatusComboboxVModelException() {
        AutoEnrollmentMappingsVMapper.instance = new STUB_ExceptionAutoEnrollmentMappingsVMapper();
        try {
            Test.startTest();
            ComboBoxVModel autoEnrollmentMappingStatusComboboxVModel = ProgramSettingsController.getAutoEnrollmentMappingStatusComboboxVModel(
                'Test_Status'
            );
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /****************************************************************************************
     * @description Test method to verify getAutoEnrollmentMappingRoleComboboxVModel()
     * returns an instance of ComboBoxVModel with valid values from valid stub.
     ****************************************************************************************/
    @isTest
    private static void getAutoEnrollmentMappingRoleComboboxVModelValid() {
        AutoEnrollmentMappingsVMapper.instance = new STUB_AutoEnrollmentMappingsVMapperValid();

        Test.startTest();
        ComboBoxVModel autoEnrollmentMappingRoleComboboxVModel = ProgramSettingsController.getAutoEnrollmentMappingRoleComboboxVModel(
            'Test_Role'
        );
        Test.stopTest();

        System.assertEquals(
            'Test_Role',
            autoEnrollmentMappingRoleComboboxVModel.value,
            'The value of autoEnrollmentMappingRoleComboboxVModel should be Test_Role'
        );

        System.assertEquals(
            1,
            autoEnrollmentMappingRoleComboboxVModel.options.size(),
            'The size of autoEnrollmentMappingRoleComboboxVModel options should be 1'
        );

        System.assertEquals(
            'Test_Role',
            autoEnrollmentMappingRoleComboboxVModel.options[0].value,
            'The value of autoEnrollmentMappingRoleComboboxVModel option 1 should be Test_Role'
        );

        System.assertEquals(
            'Test Role',
            autoEnrollmentMappingRoleComboboxVModel.options[0].label,
            'The label of autoEnrollmentMappingRoleComboboxVModel option 1 should be Test Role'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getAutoEnrollmentMappingRoleComboboxVModel()
     * throws an exception when exception occurs.
     ****************************************************************************************/
    @isTest
    private static void getAutoEnrollmentMappingRoleComboboxVModelException() {
        AutoEnrollmentMappingsVMapper.instance = new STUB_ExceptionAutoEnrollmentMappingsVMapper();
        try {
            Test.startTest();
            ComboBoxVModel autoEnrollmentMappingRoleComboboxVModel = ProgramSettingsController.getAutoEnrollmentMappingRoleComboboxVModel(
                'Test_Role'
            );
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /****************************************************************************************
     * @description Test method to verify getProgramEnrollmentDeletionSettingsVModel()
     * returns an instance of ProgramEnrollmentDeletionSettingsVModel with valid values from valid stub.
     ****************************************************************************************/
    @isTest
    private static void getProgramEnrollmentDeletionSettingsVModelValid() {
        ProgramEnrollmentDeletionSettingsVMapper.instance = new STUB_ProgramEnrollmentDeletionSettingsVMapperValid();

        Test.startTest();
        ProgramEnrollmentDeletionSettingsVModel programEnrollmentDeletionSettingsVModel = ProgramSettingsController.getProgramEnrollmentDeletionSettingsVModel();
        Test.stopTest();

        System.assertEquals(
            false,
            programEnrollmentDeletionSettingsVModel.programEnrollmentDeletion,
            'Program Enrollment Deletion should not be enabled.'
        );
        System.assertEquals(
            'Selected Status',
            programEnrollmentDeletionSettingsVModel.programEnrollmentDeletionStatus.value,
            'Selected Program Enrollment Deletion status should be \'Selected Status\'.'
        );
        System.assertEquals(
            loopCounter + 1,
            programEnrollmentDeletionSettingsVModel.programEnrollmentDeletionStatus.options.size(),
            'Should have ' +
            (loopCounter + 1) +
            ' status options.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getProgramEnrollmentDeletionSettingsVModel()
     * throws an exception when exception occurs.
     ****************************************************************************************/
    @isTest
    private static void getProgramEnrollmentDeletionSettingsVModelException() {
        ProgramEnrollmentDeletionSettingsVMapper.instance = new STUB_ExceptionProgramEnrollmentDeletionSettingsVMapper();

        try {
            Test.startTest();
            ProgramEnrollmentDeletionSettingsVModel programEnrollmentDeletionSettingsVModel = ProgramSettingsController.getProgramEnrollmentDeletionSettingsVModel();
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /****************************************************************************************
     * @description Test method to verify updateAutoEnrollmentMappings()
     * updates auto enrollment on affiliation mappings when account record type passed are the same
     ****************************************************************************************/
    @isTest
    private static void updateAutoEnrollmentMappingsSameAccountRecordType() {
        AutoEnrollmentMappingService.instance = new STUB_AutoEnrollmentMappingService();
        Test.startTest();
        String accountRecordTypeDeveloperName = ProgramSettingsController.updateAutoEnrollmentMappings(
            'Test Affl Mapping 1',
            'Record_Type_1',
            'Record_Type_1',
            'Test_Status_3',
            'Test_Role_3'
        );
        Test.stopTest();

        System.assertEquals(
            accountRecordTypeDeveloperName,
            'Record_Type_1',
            'The affected mapping should be that of the same account record type'
        );
    }

    /****************************************************************************************
     * @description Test method to verify updateAutoEnrollmentMappings()
     * updates auto enrollment on affiliation mappings when account record type passed are different
     ****************************************************************************************/
    @isTest
    private static void updateAutoEnrollmentMappingsDifferentAccountRecordType() {
        AutoEnrollmentMappingService.instance = new STUB_AutoEnrollmentMappingService();
        Test.startTest();
        String accountRecordTypeDeveloperName = ProgramSettingsController.updateAutoEnrollmentMappings(
            'Test Affl Mapping 1',
            'Record_Type_1',
            'Record_Type_2',
            'Test_Status_3',
            'Test_Role_3'
        );
        Test.stopTest();

        System.assertEquals(
            accountRecordTypeDeveloperName,
            'Record_Type_2',
            'The affected mapping should be that of the new account record type'
        );
    }

    /****************************************************************************************
     * @description Test method to verify updateAutoEnrollmentMappings()
     * when exception occurs
     ****************************************************************************************/
    @isTest
    private static void updateAutoEnrollmentMappingsException() {
        AutoEnrollmentMappingService.instance = new STUB_ExceptionAutoEnrollmentMappingService();

        try {
            Test.startTest();
            String mappingName = ProgramSettingsController.updateAutoEnrollmentMappings(
                'Test Affl Mapping 1',
                'Record_Type_1',
                'Record_Type_2',
                'Test_Status_3',
                'Test_Role_3'
            );
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
     * @description Stub class to simulate valid responses from AutoEnrollmentMappingsVMapper
     **************************************************************************************************************************************/
    private class STUB_AutoEnrollmentMappingsVMapperValid extends AutoEnrollmentMappingsVMapper {
        public override AutoEnrollmentMappingsVModel getAutoEnrollmentMappingsVModel() {
            List<AutoEnrollmentMappingVModel> autoEnrollmentMappingVModelsList = new List<AutoEnrollmentMappingVModel>();
            autoEnrollmentMappingVModelsList.add(
                new AutoEnrollmentMappingVModel(
                    'Mapping 1',
                    'Record_Type_1',
                    'Record Type 1',
                    'autoProgramEnrollmentStatus1',
                    'autoProgramEnrollmentRole1'
                )
            );
            autoEnrollmentMappingVModelsList.add(
                new AutoEnrollmentMappingVModel(
                    'Mapping 2',
                    'Record_Type_2',
                    'Record Type 2',
                    'autoProgramEnrollmentStatus2',
                    'autoProgramEnrollmentRole2'
                )
            );
            return new AutoEnrollmentMappingsVModel(autoEnrollmentMappingVModelsList);
        }

        public override ComboBoxVModel getAccountRecordTypeComboboxVModel(String accountRecordType) {
            List<ComboboxValueVModel> comboboxOptions = new List<ComboboxValueVModel>();
            comboboxOptions.add(new ComboboxValueVModel('Record Type 1', 'Record_Type_1'));
            return new ComboBoxVModel('Record_Type_1', comboboxOptions);
        }

        public override ComboBoxVModel getAutoEnrollmentMappingStatusComboboxVModel(
            String autoProgramEnrollmentStatus
        ) {
            List<ComboboxValueVModel> comboboxOptions = new List<ComboboxValueVModel>();
            comboboxOptions.add(new ComboboxValueVModel('Test Status', 'Test_Status'));
            return new ComboBoxVModel('Test_Status', comboboxOptions);
        }

        public override ComboBoxVModel getAutoEnrollmentMappingRoleComboboxVModel(String autoProgramEnrollmentRole) {
            List<ComboboxValueVModel> comboboxOptions = new List<ComboboxValueVModel>();
            comboboxOptions.add(new ComboboxValueVModel('Test Role', 'Test_Role'));
            return new ComboBoxVModel('Test_Role', comboboxOptions);
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate valid responses from ProgramEnrollmentDeletionSettingsVMapper
     **************************************************************************************************************************************/
    private class STUB_ProgramEnrollmentDeletionSettingsVMapperValid extends ProgramEnrollmentDeletionSettingsVMapper {
        public override ProgramEnrollmentDeletionSettingsVModel getProgramEnrollmentDeletionSettingsVModel() {
            List<ComboboxValueVModel> programEnrollmentDeletionStatusOptions = new List<ComboboxValueVModel>();

            programEnrollmentDeletionStatusOptions.add(new ComboboxValueVModel('Selected Status', 'Selected_Status'));

            for (Integer i = 0; i < loopCounter; i++) {
                programEnrollmentDeletionStatusOptions.add(new ComboboxValueVModel('Status ' + i, 'Status_' + i));
            }

            ComboboxVModel programEnrollmentDeletionStatusComboboxVModel = new ComboboxVModel(
                'Selected Status',
                programEnrollmentDeletionStatusOptions
            );
            return new ProgramEnrollmentDeletionSettingsVModel(false, programEnrollmentDeletionStatusComboboxVModel);
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate valid responses from AutoEnrollmentMappingService
     **************************************************************************************************************************************/
    private class STUB_AutoEnrollmentMappingService extends AutoEnrollmentMappingService {
        public override AutoEnrollmentMappingModel updateAutoEnrollmentMappings(
            String mappingName,
            String accountRecordType,
            String newAccountRecordType,
            String status,
            String role
        ) {
            if (accountRecordType != newAccountRecordType) {
                return new AutoEnrollmentMappingModel(accountRecordType, newAccountRecordType, status, role, true);
            }

            return new AutoEnrollmentMappingModel(mappingName, accountRecordType, status, role, true);
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate exception responses from ProgramSettingsVMapper
     **************************************************************************************************************************************/
    private class STUB_ExceptionAutoEnrollmentMappingsVMapper extends AutoEnrollmentMappingsVMapper {
        public override AutoEnrollmentMappingsVModel getAutoEnrollmentMappingsVModel() {
            throw new TestException('Exception encountered!');
        }

        public override ComboBoxVModel getAccountRecordTypeComboboxVModel(String accountRecordType) {
            throw new TestException('Exception encountered!');
        }

        public override ComboBoxVModel getAutoEnrollmentMappingStatusComboboxVModel(
            String autoProgramEnrollmentStatus
        ) {
            throw new TestException('Exception encountered!');
        }

        public override ComboBoxVModel getAutoEnrollmentMappingRoleComboboxVModel(String autoProgramEnrollmentRole) {
            throw new TestException('Exception encountered!');
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate exception responses from AutoEnrollmentMappingService
     **************************************************************************************************************************************/
    private class STUB_ExceptionAutoEnrollmentMappingService extends AutoEnrollmentMappingService {
        public override AutoEnrollmentMappingModel updateAutoEnrollmentMappings(
            String mappingName,
            String accountRecordType,
            String newAccountRecordType,
            String status,
            String role
        ) {
            throw new TestException('Exception encountered!');
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate exception responses from ProgramEnrollmentDeletionSettingsVMapper
     **************************************************************************************************************************************/
    private class STUB_ExceptionProgramEnrollmentDeletionSettingsVMapper extends ProgramEnrollmentDeletionSettingsVMapper {
        public override ProgramEnrollmentDeletionSettingsVModel getProgramEnrollmentDeletionSettingsVModel() {
            throw new TestException('Exception encountered!');
        }
    }

    private class TestException extends Exception {
    }
}
