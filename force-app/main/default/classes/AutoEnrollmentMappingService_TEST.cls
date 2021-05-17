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
 * @description Test class for AutoEnrollmentMappingService class.
 */
@isTest
public with sharing class AutoEnrollmentMappingService_TEST {
    /**
     * @description Test method to verify that the getInstance method returns a new instance of the
     * AutoEnrollmentMappingService class when one does not already exist.
     */
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        AutoEnrollmentMappingService autoEnrollmentMappingServiceInstance = AutoEnrollmentMappingService.getInstance();
        Test.stopTest();

        System.assertEquals(
            AutoEnrollmentMappingService.instance,
            autoEnrollmentMappingServiceInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            autoEnrollmentMappingServiceInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * AutoEnrollmentMappingService class when one already exists.
     */
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        AutoEnrollmentMappingService autoEnrollmentMappingServiceInstance1 = AutoEnrollmentMappingService.getInstance();
        AutoEnrollmentMappingService autoEnrollmentMappingServiceInstance2 = AutoEnrollmentMappingService.getInstance();
        Test.stopTest();

        System.assertEquals(
            AutoEnrollmentMappingService.instance,
            autoEnrollmentMappingServiceInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            autoEnrollmentMappingServiceInstance1,
            autoEnrollmentMappingServiceInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            autoEnrollmentMappingServiceInstance1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the locateAffiliationMappingsService method returns a valid instance of
     * AffiliationMappingsService.
     ***************************************************************************************************************************/
    @isTest
    private static void locateAffiliationMappingsServiceValid() {
        AutoEnrollmentMappingService autoEnrollmentMappingServiceInstance = AutoEnrollmentMappingService.getInstance();

        Test.startTest();
        AffiliationMappingsService affiliationMappingsServiceInstance = autoEnrollmentMappingServiceInstance.locateAffiliationMappingsService();
        Test.stopTest();

        System.assertEquals(
            AffiliationMappingsService.getInstance(),
            affiliationMappingsServiceInstance,
            'Should return instance of AffiliationMappingsService.'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the locateAutoEnrollmentMapper method returns instance of AutoEnrollmentMappingMapper
     ***********************************************************************************************************************************/
    @isTest
    private static void locateAutoEnrollmentMappingMapper() {
        AutoEnrollmentMappingService autoEnrollmentMappingServiceInstance = AutoEnrollmentMappingService.getInstance();

        Test.startTest();
        AutoEnrollmentMappingMapper autoEnrollmentMappingMapperInstance = autoEnrollmentMappingServiceInstance.locateAutoEnrollmentMappingMapper();
        Test.stopTest();

        System.assertEquals(
            AutoEnrollmentMappingMapper.getInstance(),
            autoEnrollmentMappingMapperInstance,
            'Should return the instance of AutoEnrollmentMappingMapper'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the locateRecordTypeService method returns a valid instance of
     * RecordTypeService.
     ***************************************************************************************************************************/
    @isTest
    private static void locateRecordTypeServiceValid() {
        AutoEnrollmentMappingService autoEnrollmentMappingServiceInstance = AutoEnrollmentMappingService.getInstance();

        Test.startTest();
        RecordTypeService recordTypeServiceInstance = autoEnrollmentMappingServiceInstance.locateRecordTypeService();
        Test.stopTest();

        System.assertEquals(
            RecordTypeService.getInstance(),
            recordTypeServiceInstance,
            'Should return instance of RecordTypeService.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the locateUserPermissionService method returns a valid instance of
     * UserPermissionService.
     ***************************************************************************************************************************/
    @isTest
    private static void locateUserPermissionServiceValid() {
        AutoEnrollmentMappingService autoEnrollmentMappingServiceInstance = AutoEnrollmentMappingService.getInstance();

        Test.startTest();
        UserPermissionService userPermissionServiceInstance = autoEnrollmentMappingServiceInstance.locateUserPermissionService();
        Test.stopTest();

        System.assertEquals(
            UserPermissionService.getInstance(),
            userPermissionServiceInstance,
            'Should return instance of UserPermissionService.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the createAutoEnrollmentMapping method updates the auto enrollment on affiliation
     * Mappings
     ***************************************************************************************************************************/
    @isTest
    public static void createAutoEnrollmentMapping() {
        UserPermissionService.instance = new STUB_UserPermissionServiceTrue();
        AutoEnrollmentMappingMapper.instance = new STUB_AutoEnrollmentMappingMapper();
        RecordTypeService.instance = new STUB_RecordTypeService('Record_Type1', 'Record Type1');
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsService();

        AutoEnrollmentMappingService autoEnrollmentMappingService = AutoEnrollmentMappingService.getInstance();

        String accountRecordType = 'Record_Type1';
        String status = 'Status';
        String role = 'Role';

        Test.startTest();
        AutoEnrollmentMappingModel autoEnrollmentMappingModel = autoEnrollmentMappingService.createAutoEnrollmentMapping(
            accountRecordType,
            status,
            role
        );
        Test.stopTest();

        System.assertEquals(
            accountRecordType,
            autoEnrollmentMappingModel.name,
            'Auto Enrollment Name should be ' + accountRecordType
        );
        System.assertEquals(
            accountRecordType,
            autoEnrollmentMappingModel.accountRecordTypeFieldValue,
            'Auto Enrollment Account Record Type should be ' + accountRecordType
        );
        System.assertEquals(status, autoEnrollmentMappingModel.status, 'Auto Enrollment Status should be ' + status);
        System.assertEquals(role, autoEnrollmentMappingModel.role, 'Auto Enrollment Role should be ' + role);
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the updateAutoEnrollmentMappings method updates the auto enrollment on affiliation
     * Mappings when passed account record type are the same
     ***************************************************************************************************************************/
    @isTest
    public static void updateAutoEnrollmentMappingsSameAccountRecordType() {
        UserPermissionService.instance = new STUB_UserPermissionServiceTrue();
        AutoEnrollmentMappingMapper.instance = new STUB_AutoEnrollmentMappingMapper();
        AutoEnrollmentMappingService autoEnrollmentMappingService = AutoEnrollmentMappingService.getInstance();

        String mappingName = 'mapping';
        String accountRecordType = 'Academic_Program';
        String status = 'Status';
        String role = 'Role';

        Test.startTest();
        AutoEnrollmentMappingModel autoEnrollmentMappingModel = autoEnrollmentMappingService.updateAutoEnrollmentMappings(
            mappingName,
            accountRecordType,
            accountRecordType,
            status,
            role
        );
        Test.stopTest();

        System.assertEquals(
            mappingName,
            autoEnrollmentMappingModel.name,
            'Auto Enrollment Name should be ' + mappingName
        );
        System.assertEquals(
            accountRecordType,
            autoEnrollmentMappingModel.accountRecordTypeFieldValue,
            'Auto Enrollment Account Record Type should be ' + accountRecordType
        );
        System.assertEquals(status, autoEnrollmentMappingModel.status, 'Auto Enrollment Status should be ' + status);
        System.assertEquals(role, autoEnrollmentMappingModel.role, 'Auto Enrollment Role should be ' + role);
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the updateAutoEnrollmentMappings method updates the auto enrollment on affiliation
     * Mappings when passed account record type are note the same
     ***************************************************************************************************************************/
    @isTest
    public static void updateAutoEnrollmentMappingDifferentAccountRecordType() {
        UserPermissionService.instance = new STUB_UserPermissionServiceTrue();
        AutoEnrollmentMappingMapper.instance = new STUB_AutoEnrollmentMappingMapper();
        RecordTypeService.instance = new STUB_RecordTypeService('Record_Type1', 'Record Type1');
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsService();

        AutoEnrollmentMappingService autoEnrollmentMappingService = AutoEnrollmentMappingService.getInstance();

        String mappingName = 'mapping';
        String accountRecordType = 'Record_Type';
        String newAccountRecordType = 'Record_Type1';
        String status = 'Status';
        String role = 'Role';

        Test.startTest();
        AutoEnrollmentMappingModel autoEnrollmentMappingModel = autoEnrollmentMappingService.updateAutoEnrollmentMappings(
            mappingName,
            accountRecordType,
            newAccountRecordType,
            status,
            role
        );
        Test.stopTest();

        System.assertEquals(
            newAccountRecordType,
            autoEnrollmentMappingModel.name,
            'Auto Enrollment Name should be ' + newAccountRecordType
        );
        System.assertEquals(
            newAccountRecordType,
            autoEnrollmentMappingModel.accountRecordTypeFieldValue,
            'Auto Enrollment Account Record Type should be ' + newAccountRecordType
        );
        System.assertEquals(status, autoEnrollmentMappingModel.status, 'Auto Enrollment Status should be ' + status);
        System.assertEquals(role, autoEnrollmentMappingModel.role, 'Auto Enrollment Role should be ' + role);
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the updateAutoEnrollmentMapping method updates the auto enrollment mapping
     ***************************************************************************************************************************/
    @isTest
    public static void updateAutoEnrollmentMapping() {
        AutoEnrollmentMappingMapper.instance = new STUB_AutoEnrollmentMappingMapper();
        AutoEnrollmentMappingService autoEnrollmentMappingService = AutoEnrollmentMappingService.getInstance();

        String mappingName = 'mapping';
        String accountRecordType = 'Academic_Program';
        String status = 'Status';
        String role = 'Role';

        Test.startTest();
        AutoEnrollmentMappingModel autoEnrollmentMappingModel = autoEnrollmentMappingService.updateAutoEnrollmentMapping(
            mappingName,
            accountRecordType,
            status,
            role
        );
        Test.stopTest();

        System.assertEquals(
            mappingName,
            autoEnrollmentMappingModel.name,
            'Auto Enrollment Name should be ' + mappingName
        );
        System.assertEquals(
            accountRecordType,
            autoEnrollmentMappingModel.accountRecordTypeFieldValue,
            'Auto Enrollment Account Record Type should be ' + accountRecordType
        );
        System.assertEquals(status, autoEnrollmentMappingModel.status, 'Auto Enrollment Status should be ' + status);
        System.assertEquals(role, autoEnrollmentMappingModel.role, 'Auto Enrollment Role should be ' + role);
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the shiftAutoEnrollmentMapping method updates two auto enrollment mappings
     ***************************************************************************************************************************/
    @isTest
    public static void shiftAutoEnrollmentMapping() {
        AutoEnrollmentMappingMapper.instance = new STUB_AutoEnrollmentMappingMapper();
        RecordTypeService.instance = new STUB_RecordTypeService('Record_Type1', 'Record Type1');
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsService();

        AutoEnrollmentMappingService autoEnrollmentMappingService = AutoEnrollmentMappingService.getInstance();

        String mappingName = 'mapping';
        String accountRecordType = 'Record_Type';
        String newAccountRecordType = 'Record_Type1';
        String status = 'Status';
        String role = 'Role';

        Test.startTest();
        AutoEnrollmentMappingModel autoEnrollmentMappingModel = autoEnrollmentMappingService.shiftAutoEnrollmentMapping(
            mappingName,
            accountRecordType,
            newAccountRecordType,
            status,
            role
        );
        Test.stopTest();

        System.assertEquals(
            newAccountRecordType,
            autoEnrollmentMappingModel.name,
            'Auto Enrollment Name should be ' + newAccountRecordType
        );
        System.assertEquals(
            newAccountRecordType,
            autoEnrollmentMappingModel.accountRecordTypeFieldValue,
            'Auto Enrollment Account Record Type should be ' + newAccountRecordType
        );
        System.assertEquals(status, autoEnrollmentMappingModel.status, 'Auto Enrollment Status should be ' + status);
        System.assertEquals(role, autoEnrollmentMappingModel.role, 'Auto Enrollment Role should be ' + role);
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getMappingNameByRecordTypeDeveloperNameOrName method retrieves the mapping
     * name when the record type matches on developer name
     ***************************************************************************************************************************/
    @isTest
    public static void getMappingNameByRecordTypeDeveloperNameOrNameDN() {
        String expectedMappingName = 'Record_Type1';
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsService();

        AutoEnrollmentMappingService autoEnrollmentMappingService = AutoEnrollmentMappingService.getInstance();

        Test.startTest();
        String mappingName = autoEnrollmentMappingService.getMappingNameByRecordTypeDeveloperNameOrName(
            expectedMappingName,
            'Invalid'
        );
        Test.stopTest();

        System.assertEquals(expectedMappingName, mappingName, 'Mapping name should be ' + expectedMappingName);
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getMappingNameByRecordTypeDeveloperNameOrName method retrieves the mapping
     * name when the record type matches on name
     ***************************************************************************************************************************/
    @isTest
    public static void getMappingNameByRecordTypeDeveloperNameOrNameN() {
        String expectedMappingName = 'Record_Type1';
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsService();

        AutoEnrollmentMappingService autoEnrollmentMappingService = AutoEnrollmentMappingService.getInstance();

        Test.startTest();
        String mappingName = autoEnrollmentMappingService.getMappingNameByRecordTypeDeveloperNameOrName(
            'Invalid',
            expectedMappingName
        );
        Test.stopTest();

        System.assertEquals(expectedMappingName, mappingName, 'Mapping name should be ' + expectedMappingName);
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getMappingNameByRecordTypeDeveloperNameOrName method retrieves the mapping
     * name when the record type matches on developer name after matching on name
     ***************************************************************************************************************************/
    @isTest
    public static void getMappingNameByRecordTypeDeveloperNameOrNameDN1st() {
        String expectedMappingName = 'Record_Type1';
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsService();

        AutoEnrollmentMappingService autoEnrollmentMappingService = AutoEnrollmentMappingService.getInstance();

        Test.startTest();
        String mappingName = autoEnrollmentMappingService.getMappingNameByRecordTypeDeveloperNameOrName(
            expectedMappingName,
            'Record_Type'
        );
        Test.stopTest();

        System.assertEquals(expectedMappingName, mappingName, 'Mapping name should be ' + expectedMappingName);
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getMappingNameByRecordTypeDeveloperNameOrName method retrieves null when
     * the record type does not match
     ***************************************************************************************************************************/
    @isTest
    public static void getMappingNameByRecordTypeDeveloperNameOrNameNone() {
        String expectedMappingName = null;
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsService();

        AutoEnrollmentMappingService autoEnrollmentMappingService = AutoEnrollmentMappingService.getInstance();

        Test.startTest();
        String mappingName = autoEnrollmentMappingService.getMappingNameByRecordTypeDeveloperNameOrName(
            'Invalid',
            'Invalid'
        );
        Test.stopTest();

        System.assertEquals(expectedMappingName, mappingName, 'Mapping name should be null');
    }

    /***********************************************************************************************************************************
     ****************************************************** STUBS ***********************************************************************
     ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the valid response from AutoEnrollmentMappingMapper
     **************************************************************************************************************************************/
    private class STUB_AutoEnrollmentMappingMapper extends AutoEnrollmentMappingMapper {
        public override List<AutoEnrollmentMappingModel> updateAffiliationMappingsFromModelList(
            List<AutoEnrollmentMappingModel> autoEnrollmentMappingModelList
        ) {
            List<AutoEnrollmentMappingModel> returnList = new List<AutoEnrollmentMappingModel>();

            for (AutoEnrollmentMappingModel autoEnrollmentMappingModel : autoEnrollmentMappingModelList) {
                returnList.add(
                    new AutoEnrollmentMappingModel(
                        (autoEnrollmentMappingModelList.size() == 1
                            ? autoEnrollmentMappingModel.name
                            : autoEnrollmentMappingModel.accountRecordTypeFieldValue),
                        autoEnrollmentMappingModel.accountRecordTypeFieldValue,
                        autoEnrollmentMappingModel.role,
                        autoEnrollmentMappingModel.status,
                        autoEnrollmentMappingModel.active
                    )
                );
            }

            return returnList;
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AffiliationMappingsService to return Affiliation Mapping Models
     **************************************************************************************************************************************/
    private class STUB_AffiliationMappingsService extends AffiliationMappingsService {
        public override List<AffiliationMappingsModel> getAffiliationMappingsModels() {
            return new List<AffiliationMappingsModel>{
                new AffiliationMappingsModel(
                    'Record_Type',
                    'Record_Type',
                    'Primary_Affiliation_Field__c',
                    true,
                    'Status',
                    'Role'
                ),
                new AffiliationMappingsModel(
                    'Record_Type1',
                    'Record_Type1',
                    'Primary_Affiliation_Field1__c',
                    true,
                    'Status',
                    'Role'
                )
            };
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from RecordTypeService to return an arbitrary Record Type Model
     **************************************************************************************************************************************/
    private class STUB_RecordTypeService extends RecordTypeService {
        private String recordTypeDeveloperName;
        private String recordTypeName;

        STUB_RecordTypeService(String recordTypeDeveloperName, String recordTypeName) {
            this.recordTypeDeveloperName = recordTypeDeveloperName;
            this.recordTypeName = recordTypeName;
        }

        public override RecordTypeModel getRecordTypeModelFromRecTypeDevName(String objectAPI, String recTypeDevName) {
            return new RecordTypeModel('000000000000000000', recordTypeName, recordTypeDeveloperName, true);
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from UserPermissionService to return true
     **************************************************************************************************************************************/
    private class STUB_UserPermissionServiceTrue extends UserPermissionService {
        public override Boolean checkViewSetupForCurrentUser() {
            return true;
        }
    }
}
