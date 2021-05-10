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

    /***********************************************************************************************************************************
     * @description Test method to verify that the locateAffiliationMappingsMapper method returns instance of AffiliationMappingsMapper
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
     * @description Test method to verify that the updateAutoEnrollmentMappings method updates the auto enrollment on affiliation Mappings
     * when passed account record type are the same
     ***************************************************************************************************************************/
    /*@isTest
    public static void updateAutoEnrollmentMappingSameAccountRecordType() {
        List<Affl_Mappings__c> afflMappings = new List<Affl_Mappings__c>();
        Affl_Mappings__c afflMapping1 = new Affl_Mappings__c(
            Name = 'Test Affl Mapping 1',
            Account_Record_Type__c = 'Record_Type_1',
            Primary_Affl_Field__c = 'Primary_Field_1',
            Auto_Program_Enrollment__c = true,
            Auto_Program_Enrollment_Status__c = 'Test_Status_1',
            Auto_Program_Enrollment_Role__c = 'Test_Role_1'
        );
        afflMappings.add(afflMapping1);
        Affl_Mappings__c afflMapping2 = new Affl_Mappings__c(
            Name = 'Test Affl Mapping 2',
            Account_Record_Type__c = 'Record_Type_2',
            Primary_Affl_Field__c = 'Primary_Field_2',
            Auto_Program_Enrollment__c = true,
            Auto_Program_Enrollment_Status__c = 'Test_Status_2',
            Auto_Program_Enrollment_Role__c = 'Test_Role_2'
        );
        afflMappings.add(afflMapping2);
        insert afflMappings;

        UserPermissionService.instance = new STUB_UserPermissionServiceTrue();

        Test.startTest();
        AutoEnrollmentMappingService.getInstance()
            .updateAutoEnrollmentMappings(
                'Test Affl Mapping 1',
                'Record_Type_1',
                'Record_Type_1',
                'Test_Status_3',
                'Test_Role_3'
            );
        Test.stopTest();

        Affl_Mappings__c assertAfflMapping = Affl_Mappings__c.getInstance('Test Affl Mapping 1');
        System.assertEquals('Test Affl Mapping 1', assertAfflMapping.name, 'Test Affl Mapping 1 should be retrieved');
        System.assertEquals(
            'Test_Status_3',
            assertAfflMapping.Auto_Program_Enrollment_Status__c,
            'Auto_Program_Enrollment_Status__c should be changed to Test_Status_3'
        );
        System.assertEquals(
            'Test_Role_3',
            assertAfflMapping.Auto_Program_Enrollment_Role__c,
            'Auto_Program_Enrollment_Role__c should be changed to Test_Role_3'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the updateAutoEnrollmentMappings method updates the auto enrollment on affiliation Mappings
     * when passed account record type are the same
     ***************************************************************************************************************************/
    /*@isTest
    public static void updateAutoEnrollmentMappingDifferentAccountRecordType() {
        List<Affl_Mappings__c> afflMappings = new List<Affl_Mappings__c>();
        Affl_Mappings__c afflMapping1 = new Affl_Mappings__c(
            Name = 'Test Affl Mapping 1',
            Account_Record_Type__c = 'Record_Type_1',
            Primary_Affl_Field__c = 'Primary_Field_1',
            Auto_Program_Enrollment__c = true,
            Auto_Program_Enrollment_Status__c = 'Test_Status_1',
            Auto_Program_Enrollment_Role__c = 'Test_Role_1'
        );
        afflMappings.add(afflMapping1);
        Affl_Mappings__c afflMapping2 = new Affl_Mappings__c(
            Name = 'Test Affl Mapping 2',
            Account_Record_Type__c = 'Record_Type_2',
            Primary_Affl_Field__c = 'Primary_Field_2',
            Auto_Program_Enrollment__c = true,
            Auto_Program_Enrollment_Status__c = 'Test_Status_2',
            Auto_Program_Enrollment_Role__c = 'Test_Role_2'
        );
        afflMappings.add(afflMapping2);
        insert afflMappings;

        UserPermissionService.instance = new STUB_UserPermissionServiceTrue();

        Test.startTest();
        AutoEnrollmentMappingService.getInstance()
            .updateAutoEnrollmentMappings(
                'Test Affl Mapping 1',
                'Record_Type_1',
                'Record_Type_2',
                'Test_Status_3',
                'Test_Role_3'
            );
        Test.stopTest();

        Affl_Mappings__c assertAfflMapping1 = Affl_Mappings__c.getInstance('Test Affl Mapping 1');
        System.assertEquals('Test Affl Mapping 1', assertAfflMapping1.name, 'Test Affl Mapping 1 should be retrieved');
        System.assertEquals(
            false,
            assertAfflMapping1.Auto_Program_Enrollment__c,
            'Auto_Program_Enrollment__c should be false'
        );
        System.assertEquals(
            null,
            assertAfflMapping1.Auto_Program_Enrollment_Status__c,
            'Auto_Program_Enrollment_Status__c should be empty'
        );
        System.assertEquals(
            null,
            assertAfflMapping1.Auto_Program_Enrollment_Role__c,
            'Auto_Program_Enrollment_Role__c should be empty'
        );

        Affl_Mappings__c assertAfflMapping2 = Affl_Mappings__c.getInstance('Test Affl Mapping 2');
        System.assertEquals('Test Affl Mapping 2', assertAfflMapping2.name, 'Test Affl Mapping 2 should be retrieved');
        System.assertEquals(
            true,
            assertAfflMapping2.Auto_Program_Enrollment__c,
            'Auto_Program_Enrollment__c should be true'
        );
        System.assertEquals(
            'Test_Status_3',
            assertAfflMapping2.Auto_Program_Enrollment_Status__c,
            'Auto_Program_Enrollment_Status__c should be changed to Test_Status_3'
        );
        System.assertEquals(
            'Test_Role_3',
            assertAfflMapping2.Auto_Program_Enrollment_Role__c,
            'Auto_Program_Enrollment_Role__c should be changed to Test_Role_3'
        );
    }

    /***********************************************************************************************************************************
     ****************************************************** STUBS ***********************************************************************
     ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AutoEnrollmentMappingMapper to return models representing Primary
     * Affiliation Mappings.
     **************************************************************************************************************************************/
    /*private class STUB_AutoEnrollmentMappingMapper extends AutoEnrollmentMappingMapper {
        public override List<AffiliationMappingsModel> getAffiliationMappingsModel() {
            List<AffiliationMappingsModel> afflMappingsModelsList = new List<AffiliationMappingsModel>();

            afflMappingsModelsList.add(
                new AffiliationMappingsModel(
                    'Test Academic Program',
                    'Test_Academic_Program',
                    'Test Primary Academic Program',
                    true,
                    'Test Current',
                    'Test Student'
                )
            );

            afflMappingsModelsList.add(
                new AffiliationMappingsModel(
                    'Test Household Account',
                    'Test_HH_Account',
                    'Test Primary Household',
                    false,
                    '',
                    ''
                )
            );

            return afflMappingsModelsList;
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

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from UserPermissionService to return false
     **************************************************************************************************************************************/
    private class STUB_UserPermissionServiceFalse extends UserPermissionService {
        public override Boolean checkViewSetupForCurrentUser() {
            return false;
        }
    }
}
