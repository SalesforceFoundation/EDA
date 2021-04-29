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
 * @description Test class for ProgramSettingsVMapper class.
 */
@isTest
private with sharing class ProgramSettingsVMapper_TEST {
    private static Integer loopCounter = 5;

    /**************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * ProgramSettingsVMapper class when one does not already exist.
     **************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        ProgramSettingsVMapper programSettingsVMapperInstance = ProgramSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ProgramSettingsVMapper.instance,
            programSettingsVMapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            programSettingsVMapperInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * ProgramSettingsVMapper class when one already exists.
     **************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        ProgramSettingsVMapper programSettingsVMapperInstance1 = ProgramSettingsVMapper.getInstance();
        ProgramSettingsVMapper programSettingsVMapperInstance2 = ProgramSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ProgramSettingsVMapper.instance,
            programSettingsVMapperInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            programSettingsVMapperInstance1,
            programSettingsVMapperInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            programSettingsVMapperInstance1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify locateRecordTypeService() returns an instance of
     * the RecordTypeService class.
     ****************************************************************************************/
    @isTest
    private static void locateRecordTypeServiceValid() {
        ProgramSettingsVMapper programSettingsVMapperInstance = ProgramSettingsVMapper.getInstance();

        Test.startTest();
        RecordTypeService recordTypeServiceInstance = programSettingsVMapperInstance.locateRecordTypeService();
        Test.stopTest();

        System.assertEquals(
            RecordTypeService.getInstance(),
            recordTypeServiceInstance,
            'Should return instance of RecordTypeService class.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify locateAffiliationMappingsService() returns an instance of
     * the AffiliationMappingsService class.
     ****************************************************************************************/
    @isTest
    private static void locateAffiliationMappingsServiceValid() {
        ProgramSettingsVMapper programSettingsVMapperInstance = ProgramSettingsVMapper.getInstance();

        Test.startTest();
        AffiliationMappingsService affiliationMappingsServiceInstance = programSettingsVMapperInstance.locateAffiliationMappingsService();
        Test.stopTest();

        System.assertEquals(
            AffiliationMappingsService.getInstance(),
            affiliationMappingsServiceInstance,
            'Should return instance of AffiliationMappingsService class.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify locatePicklistEntryService() returns an instance of
     * the PicklistEntryService class.
     ****************************************************************************************/
    @isTest
    private static void locatePicklistEntryServiceValid() {
        ProgramSettingsVMapper programSettingsVMapperInstance = ProgramSettingsVMapper.getInstance();

        Test.startTest();
        PicklistEntryService picklistEntryServiceInstance = programSettingsVMapperInstance.locatePicklistEntryService();
        Test.stopTest();

        System.assertEquals(
            PicklistEntryService.getInstance(),
            picklistEntryServiceInstance,
            'Should return instance of PicklistEntryService class.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getAutoEnrollmentMappingVModel()
     * returns an instance of AutoEnrollmentMappingVModel with account record type
     * corresponding to the matching model properties when matching models exists.
     ****************************************************************************************/
    @isTest
    private static void getAutoEnrollmentMappingVModelValid() {
        RecordTypeService.instance = new STUB_RecordTypeServiceValid();

        AffiliationMappingsModel affiliationMappingsModel = new AffiliationMappingsModel(
            'Affliation Name',
            'Account Record Type',
            'Primary Affiliation Field',
            true,
            'autoProgramEnrollmentStatus',
            'autoProgramEnrollmentRole'
        );
        Map<String, RecordTypeModel> accountRecordTypeModelsByName = new Map<String, RecordTypeModel>{
            'Account_Record_Type' => new RecordTypeModel(
                '000000000000000009',
                'Account Record Type',
                'Account_Record_Type',
                true
            )
        };

        Map<String, RecordTypeModel> accountRecordTypeModelsByLabel = new Map<String, RecordTypeModel>{
            'Account Record Type' => new RecordTypeModel(
                '000000000000000009',
                'Account Record Type',
                'Account_Record_Type',
                true
            )
        };

        ProgramSettingsVMapper programSettingsVMapperInstance = ProgramSettingsVMapper.getInstance();

        Test.startTest();
        AutoEnrollmentMappingVModel autoEnrollmentMappingVModel = programSettingsVMapperInstance.getAutoEnrollmentMappingVModel(
            affiliationMappingsModel,
            accountRecordTypeModelsByName,
            accountRecordTypeModelsByLabel
        );
        Test.stopTest();

        System.assertEquals(
            'Account_Record_Type',
            autoEnrollmentMappingVModel.accountRecordTypeName,
            'Account Record Type name should match developer name of Record Type model corresponding to record type specified for the affiliation mapping.'
        );

        System.assertEquals(
            'Account Record Type',
            autoEnrollmentMappingVModel.accountRecordTypeLabel,
            'Account Record Type label should match label of Record Type model corresponding to record type specified for the affiliation mapping.'
        );

        System.assertEquals(
            'autoProgramEnrollmentStatus',
            autoEnrollmentMappingVModel.autoProgramEnrollmentStatus,
            'Auto enrollment status should match the auto enrollment status of the affiliation mapping.'
        );

        System.assertEquals(
            'autoProgramEnrollmentRole',
            autoEnrollmentMappingVModel.autoProgramEnrollmentRole,
            'Auto enrollment role should match the auto enrollment role of the affiliation mapping.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getAutoEnrollmentMappingVModel()
     * returns a AutoEnrollmentMappingVModel with account record type and lookup field names
     * and labels corresponding to the properties specified for the affiliation mapping
     * when matching models do not exist.
     ****************************************************************************************/
    @isTest
    private static void getAutoEnrollmentMappingVModelInValidRecordType() {
        RecordTypeService.instance = new STUB_RecordTypeServiceInvalid();

        AffiliationMappingsModel affiliationMappingsModel = new AffiliationMappingsModel(
            'Affliation Name',
            'Invalid Account Record Type',
            'Invalid Primary Affiliation Field',
            false,
            'autoProgramEnrollmentStatus',
            'autoProgramEnrollmentRole'
        );

        Map<String, RecordTypeModel> accountRecordTypeModelsByName = new Map<String, RecordTypeModel>{
            'Account_Record_Type' => new RecordTypeModel(
                '000000000000000009',
                'Account Record Type',
                'Account_Record_Type',
                true
            )
        };

        Map<String, RecordTypeModel> accountRecordTypeModelsByLabel = new Map<String, RecordTypeModel>{
            'Account Record Type' => new RecordTypeModel(
                '000000000000000009',
                'Account Record Type',
                'Account_Record_Type',
                true
            )
        };

        ProgramSettingsVMapper programSettingsVMapperInstance = ProgramSettingsVMapper.getInstance();

        Test.startTest();
        AutoEnrollmentMappingVModel autoEnrollmentMappingVModel = programSettingsVMapperInstance.getAutoEnrollmentMappingVModel(
            affiliationMappingsModel,
            accountRecordTypeModelsByName,
            accountRecordTypeModelsByLabel
        );
        Test.stopTest();

        System.assertEquals(
            'Invalid Account Record Type',
            autoEnrollmentMappingVModel.accountRecordTypeName,
            'Account Record Type name should match value specified for the affiliation mapping.'
        );

        System.assertEquals(
            'Invalid Account Record Type',
            autoEnrollmentMappingVModel.accountRecordTypeLabel,
            'Account Record Type label should match value specified for the affiliation mapping.'
        );

        System.assertEquals(
            'autoProgramEnrollmentStatus',
            autoEnrollmentMappingVModel.autoProgramEnrollmentStatus,
            'Auto enrollment status should match the auto enrollment status of the affiliation mapping.'
        );

        System.assertEquals(
            'autoProgramEnrollmentRole',
            autoEnrollmentMappingVModel.autoProgramEnrollmentRole,
            'Auto enrollment role should match the auto enrollment role of the affiliation mapping.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getProgramSettingsVModel()
     * returns a ProgramSettingsVModel with proper values
     * when active auto enrollment exists.
     ****************************************************************************************/
    @isTest
    private static void getProgramSettingsVModelActiveAutoEnrollmentExists() {
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsService();
        RecordTypeService.instance = new STUB_RecordTypeService();

        ProgramSettingsVMapper programSettingsVMapperInstance = ProgramSettingsVMapper.getInstance();

        Test.startTest();
        ProgramSettingsVModel programSettingsVModel = programSettingsVMapperInstance.getProgramSettingsVModel();
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
     * returns a ProgramSettingsVModel with proper values
     * when no active auto enrollment exists.
     ****************************************************************************************/
    @isTest
    private static void getProgramSettingsVModelActiveAutoEnrollmentNotExists() {
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsServiceInactiveAutoEnrollment();
        RecordTypeService.instance = new STUB_RecordTypeService();

        ProgramSettingsVMapper programSettingsVMapperInstance = ProgramSettingsVMapper.getInstance();

        Test.startTest();
        ProgramSettingsVModel programSettingsVModel = programSettingsVMapperInstance.getProgramSettingsVModel();
        Test.stopTest();

        System.assertEquals(
            0,
            programSettingsVModel.autoEnrollmentMappingVModels.size(),
            'Should return 0 autoEnrollmentMappingVModels.'
        );
    }

    /***********************************************************************************************************************************
     ****************************************************** STUBS ***********************************************************************
     ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate valid responses from AffiliationMappingsService
     **************************************************************************************************************************************/
    private class STUB_AffiliationMappingsService extends AffiliationMappingsService {
        public override List<AffiliationMappingsModel> getAffiliationMappingsModels() {
            return new List<AffiliationMappingsModel>{
                new AffiliationMappingsModel(
                    'Affiliation Name 1',
                    'Record Type 1',
                    'Contact Account Lookup Label 1',
                    true,
                    'autoProgramEnrollmentStatus1',
                    'autoProgramEnrollmentRole1'
                ),
                new AffiliationMappingsModel(
                    'Affiliation Name 2',
                    'Record Type 2',
                    'Contact Account Lookup Label 2',
                    true,
                    'autoProgramEnrollmentStatus2',
                    'autoProgramEnrollmentRole2'
                )
            };
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate valid responses from AffiliationMappingsService
     **************************************************************************************************************************************/
    private class STUB_AffiliationMappingsServiceInactiveAutoEnrollment extends AffiliationMappingsService {
        public override List<AffiliationMappingsModel> getAffiliationMappingsModels() {
            return new List<AffiliationMappingsModel>{
                new AffiliationMappingsModel(
                    'Affiliation Name 1',
                    'Record Type 1',
                    'Contact Account Lookup Label 1',
                    false,
                    'autoProgramEnrollmentStatus1',
                    'autoProgramEnrollmentRole1'
                ),
                new AffiliationMappingsModel(
                    'Affiliation Name 2',
                    'Record Type 2',
                    'Contact Account Lookup Label 2',
                    false,
                    'autoProgramEnrollmentStatus2',
                    'autoProgramEnrollmentRole2'
                )
            };
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate valid responses from RecordTypeService
     **************************************************************************************************************************************/
    private class STUB_RecordTypeService extends RecordTypeService {
        public override Map<Id, RecordTypeModel> getModelByIdMapForSObjectType(Schema.SObjectType sObjectType) {
            return new Map<Id, RecordTypeModel>{
                '000000000000000001' => new RecordTypeModel(
                    '000000000000000001',
                    'Record Type 1',
                    'Record_Type_1',
                    true
                ),
                '000000000000000002' => new RecordTypeModel(
                    '000000000000000002',
                    'Record Type 2',
                    'Record_Type_2',
                    true
                ),
                '000000000000000003' => new RecordTypeModel(
                    '000000000000000003',
                    'Record Type 3',
                    'Record_Type_3',
                    false
                )
            };
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate valid responses from RecordTypeService
     **************************************************************************************************************************************/
    private class STUB_RecordTypeServiceValid extends RecordTypeService {
        public override RecordTypeModel getRecordTypeModelFromNameAndLabelMaps(
            String recordTypeNameOrLabel,
            Map<String, RecordTypeModel> recordTypeModelByName,
            Map<String, RecordTypeModel> recordTypeModelByLabel
        ) {
            return new RecordTypeModel('000000000000000009', 'Account Record Type', 'Account_Record_Type', true);
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate invalid responses from RecordTypeService
     **************************************************************************************************************************************/
    private class STUB_RecordTypeServiceInvalid extends RecordTypeService {
        public override RecordTypeModel getRecordTypeModelFromNameAndLabelMaps(
            String recordTypeNameOrLabel,
            Map<String, RecordTypeModel> recordTypeModelByName,
            Map<String, RecordTypeModel> recordTypeModelByLabel
        ) {
            return null;
        }
    }
}
