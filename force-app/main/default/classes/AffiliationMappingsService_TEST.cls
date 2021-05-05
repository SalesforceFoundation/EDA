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
 * @description Test class for AffiliationMappingsService class.
 */
@isTest
public with sharing class AffiliationMappingsService_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * AffiliationMappingsService class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        AffiliationMappingsService AffiliationMappingsServiceInstance = AffiliationMappingsService.getInstance();
        Test.stopTest();

        System.assertEquals(
            AffiliationMappingsService.instance,
            AffiliationMappingsServiceInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            AffiliationMappingsServiceInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * AffiliationMappingsService class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        AffiliationMappingsService AffiliationMappingsServiceInstance1 = AffiliationMappingsService.getInstance();
        AffiliationMappingsService AffiliationMappingsServiceInstance2 = AffiliationMappingsService.getInstance();
        Test.stopTest();

        System.assertEquals(
            AffiliationMappingsService.instance,
            AffiliationMappingsServiceInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            AffiliationMappingsServiceInstance1,
            AffiliationMappingsServiceInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            AffiliationMappingsServiceInstance1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getAffiliationMappingsModels method returns a list of Affiliation Mappings
     * models corresponding to affiliation mappings specified in EDA Settings.
     ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationMappingsModelsValid() {
        AffiliationMappingsMapper.instance = new STUB_AffiliationMappingsMapper();

        AffiliationMappingsService affiliationMappingsServiceInstance = AffiliationMappingsService.getInstance();

        Test.startTest();
        List<AffiliationMappingsModel> afflMappingsModelList = affiliationMappingsServiceInstance.getAffiliationMappingsModels();
        Test.stopTest();

        System.assertEquals(
            'Test Academic Program',
            afflMappingsModelList[0].name,
            'Affiliation Model name should match primary affiliation.'
        );

        System.assertEquals(
            'Test_Academic_Program',
            afflMappingsModelList[0].accountRecordTypeFieldValue,
            'Affiliation Model record type should match primary affiliation.'
        );

        System.assertEquals(
            'Test Primary Academic Program',
            afflMappingsModelList[0].primaryAffiliationField,
            'Affiliation Model primary affiliation field should match primary affiliation.'
        );

        System.assertEquals(
            true,
            afflMappingsModelList[0].autoProgramEnrollment,
            'Affiliation Model auto enrollment should match primary affiliation.'
        );

        System.assertEquals(
            'Test Current',
            afflMappingsModelList[0].autoProgramEnrollmentStatus,
            'Affiliation Model auto enrollment status should match primary affiliation.'
        );

        System.assertEquals(
            'Test Student',
            afflMappingsModelList[0].autoProgramEnrollmentRole,
            'Affiliation Model auto enrollment role should match primary affiliation.'
        );

        System.assertEquals(
            'Test Household Account',
            afflMappingsModelList[1].name,
            'Affiliation Model name should match primary affiliation.'
        );

        System.assertEquals(
            'Test_HH_Account',
            afflMappingsModelList[1].accountRecordTypeFieldValue,
            'Affiliation Model record type should match primary affiliation.'
        );

        System.assertEquals(
            'Test Primary Household',
            afflMappingsModelList[1].primaryAffiliationField,
            'Affiliation Model primary affiliation field should match primary affiliation.'
        );

        System.assertEquals(
            false,
            afflMappingsModelList[1].autoProgramEnrollment,
            'Affiliation Model auto enrollment should match primary affiliation.'
        );

        System.assertEquals(
            '""',
            afflMappingsModelList[1].autoProgramEnrollmentStatus,
            'Affiliation Model auto enrollment status should match primary affiliation.'
        );

        System.assertEquals(
            '""',
            afflMappingsModelList[1].autoProgramEnrollmentRole,
            'Affiliation Model auto enrollment role should match primary affiliation.'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the locateAffiliationMappingsMapper method returns instance of AffiliationMappingsMapper
     ***********************************************************************************************************************************/
    @isTest
    private static void locateAffiliationMappingsMapper() {
        AffiliationMappingsService affiliationMappingsServiceInstance = AffiliationMappingsService.getInstance();

        Test.startTest();
        AffiliationMappingsMapper affiliationMappingsMapperInstance = affiliationMappingsServiceInstance.locateAffiliationMappingsMapper();
        Test.stopTest();

        System.assertEquals(
            AffiliationMappingsMapper.getInstance(),
            affiliationMappingsMapperInstance,
            'Should return the instance of AffiliationMappingsMapper'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the locateUserPermissionService method returns a valid instance of
     * UserPermissionService.
     ***************************************************************************************************************************/
    @isTest
    private static void locateUserPermissionServiceValid() {
        AffiliationMappingsService affiliationMappingsServiceInstance = AffiliationMappingsService.getInstance();

        Test.startTest();
        UserPermissionService userPermissionServiceInstance = affiliationMappingsServiceInstance.locateUserPermissionService();
        Test.stopTest();

        System.assertEquals(
            UserPermissionService.getInstance(),
            userPermissionServiceInstance,
            'Should return instance of UserPermissionService.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify insertAffiliationMappings inserts a new affiliation mapping.
     **************************************************************************************************************************/
    @isTest
    private static void insertAffiliationMappingsValid() {
        UserPermissionService.instance = new STUB_UserPermissionServiceTrue();

        AffiliationMappingsService affiliationMappingsServiceInstance = AffiliationMappingsService.getInstance();

        Test.startTest();
        affiliationMappingsServiceInstance.insertAffiliationMappings(
            'Test Affiliation Mapping',
            'Test_Record_Type',
            'Test Contact Primary Affl Field'
        );
        Test.stopTest();

        List<Affl_Mappings__c> affiliationMappingsResultsList = [
            SELECT
                Name,
                Account_Record_Type__c,
                Auto_Program_Enrollment__c,
                Auto_Program_Enrollment_Role__c,
                Auto_Program_Enrollment_Status__c,
                Primary_Affl_Field__c
            FROM Affl_Mappings__c
            WHERE Name = 'Test Affiliation Mapping'
        ];

        System.assertEquals(1, affiliationMappingsResultsList.size(), 'New affiliation mapping should be inserted.');
        System.assertEquals(
            'Test Affiliation Mapping',
            affiliationMappingsResultsList[0].Name,
            'Name of new affiliation mapping should match specified value.'
        );
        System.assertEquals(
            'Test_Record_Type',
            affiliationMappingsResultsList[0].Account_Record_Type__c,
            'Account Record Type of new affiliation mapping should match specified value.'
        );
        System.assertEquals(
            'Test Contact Primary Affl Field',
            affiliationMappingsResultsList[0].Primary_Affl_Field__c,
            'Contact primary affiliation field of new affiliation mapping should match specified value.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the updateAffiliationMappings method updates Affiliation custom settings
     ***************************************************************************************************************************/
    @isTest
    private static void updateAffiliationMappingsPoisitve() {
        Affl_Mappings__c afflMapping = new Affl_Mappings__c(
            Name = 'Household Account',
            Account_Record_Type__c = 'HH_Account',
            Primary_Affl_Field__c = 'Primary_Household__c'
        );
        insert afflMapping;

        UserPermissionService.instance = new STUB_UserPermissionServiceTrue();

        Test.startTest();

        AffiliationMappingsService.getInstance()
            .updateAffiliationMappings('Household Account', 'Business_Organization', 'Primary_Department__c');
        Test.stopTest();

        Affl_Mappings__c afflSettings = Affl_Mappings__c.getInstance('Household Account');
        System.assertEquals('Household Account', afflSettings.name, 'Household account mappings should be retrieved');
        System.assertEquals(
            'Business_Organization',
            afflSettings.Account_Record_Type__c,
            'Account record type should be changed to Business organization'
        );
        System.assertEquals(
            'Primary_Department__c',
            afflSettings.Primary_Affl_Field__c,
            'Primary Affiliation Field should change to Primary Department'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the updateAutoEnrollmentMappings method updates the auto enrollment on affiliation Mappings
     * when passed account record type are the same
     ***************************************************************************************************************************/
    @isTest
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
        AffiliationMappingsService.getInstance()
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
    @isTest
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
        AffiliationMappingsService.getInstance()
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

    /**************************************************************************************************************************
     * @description Test method to verify deleteAffiliationMapping deletes a specified affiliation mapping when it exists.
     **************************************************************************************************************************/
    @isTest
    private static void deleteAffiliationMappingValid() {
        UserPermissionService.instance = new STUB_UserPermissionServiceTrue();

        AffiliationMappingsService affiliationMappingsServiceInstance = AffiliationMappingsService.getInstance();
        Affl_Mappings__c affiliationMappingToDelete = new Affl_Mappings__c(
            Name = 'Test Affiliation Mapping',
            Account_Record_Type__c = 'Test_Record_Type',
            Primary_Affl_Field__c = 'Test Contact Primary Affl Field',
            Auto_Program_Enrollment__c = false,
            Auto_Program_Enrollment_Status__c = '',
            Auto_Program_Enrollment_Role__c = 'Test Auto Enrollment Role'
        );

        insert affiliationMappingToDelete;

        Test.startTest();
        String primaryAccountRecordTypeName = affiliationMappingsServiceInstance.deleteAffiliationMapping(
            'Test Affiliation Mapping'
        );
        Test.stopTest();

        List<Affl_Mappings__c> affiliationMappingsResultsList = [
            SELECT
                Name,
                Account_Record_Type__c,
                Auto_Program_Enrollment__c,
                Auto_Program_Enrollment_Role__c,
                Auto_Program_Enrollment_Status__c,
                Primary_Affl_Field__c
            FROM Affl_Mappings__c
            WHERE Name = 'Test Affiliation Mapping'
        ];

        System.assertEquals(0, affiliationMappingsResultsList.size(), 'New affiliation mapping should be deleted.');
        System.assertEquals(
            'Test_Record_Type',
            primaryAccountRecordTypeName,
            'Should return  name of record type associated with deleted affiliation mapping.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify deleteAffiliationMapping exits gracefully when an affiliation mapping specified for
     * deletion does not exist.
     **************************************************************************************************************************/
    @isTest
    private static void deleteAffiliationMappingInvalid() {
        UserPermissionService.instance = new STUB_UserPermissionServiceTrue();

        AffiliationMappingsService affiliationMappingsServiceInstance = AffiliationMappingsService.getInstance();

        Test.startTest();
        String primaryAccountRecordTypeName = affiliationMappingsServiceInstance.deleteAffiliationMapping(
            'Non-Existent Affiliation Mapping'
        );
        Test.stopTest();

        System.assertEquals(
            null,
            primaryAccountRecordTypeName,
            'Deleting non-existent affiliation mapping should return null value.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify deleteAffiliationMapping does not delete an affiliation mapping without sufficient
     * user permissions.
     **************************************************************************************************************************/
    @isTest
    private static void deleteAffiliationMappingNoPermission() {
        UserPermissionService.instance = new STUB_UserPermissionServiceFalse();
        AffiliationMappingsService affiliationMappingsServiceInstance = AffiliationMappingsService.getInstance();

        Affl_Mappings__c affiliationMappingToDelete = new Affl_Mappings__c(
            Name = 'Test Affiliation Mapping',
            Account_Record_Type__c = 'Test_Record_Type',
            Primary_Affl_Field__c = 'Test Contact Primary Affl Field',
            Auto_Program_Enrollment__c = false,
            Auto_Program_Enrollment_Status__c = '',
            Auto_Program_Enrollment_Role__c = 'Test Auto Enrollment Role'
        );

        insert affiliationMappingToDelete;

        Test.startTest();
        String primaryAccountRecordTypeName = affiliationMappingsServiceInstance.deleteAffiliationMapping(
            'Test Affiliation Mapping'
        );
        Test.stopTest();

        List<Affl_Mappings__c> affiliationMappingsResultsList = [
            SELECT Name
            FROM Affl_Mappings__c
            WHERE Name = 'Test Affiliation Mapping'
        ];

        System.assertEquals(
            1,
            affiliationMappingsResultsList.size(),
            'Affiliation mapping should not be deleted due to insufficient user permissions.'
        );

        System.assertEquals(
            null,
            primaryAccountRecordTypeName,
            'Deleting affiliation mapping without appropriate permissions should return null value.'
        );
    }

    /***********************************************************************************************************************************
     ****************************************************** STUBS ***********************************************************************
     ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AffiliationMappingsMapper to return a valid list of models representing Primary
     * Affiliation Mappings.
     **************************************************************************************************************************************/
    private class STUB_AffiliationMappingsMapper extends AffiliationMappingsMapper {
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
