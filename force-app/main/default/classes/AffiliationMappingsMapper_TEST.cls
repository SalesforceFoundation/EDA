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
 * @description Test class for AfffiliationMappingsMapper class.
 */
@isTest
public with sharing class AffiliationMappingsMapper_TEST {
    /*****************************************************************************
     * @description Test to verify getAffiliationMappingsModelValid() generates
     * models matching the affiliation mappings set in EDA Settings.
     *****************************************************************************/
    @isTest
    private static void getAffiliationMappingsModelValid() {
        List<Affl_Mappings__c> primaryAfflMappingsList = new List<Affl_Mappings__c>();
        primaryAfflMappingsList.add(
            new Affl_Mappings__c(
                Name = 'Invalid Affiliation Mapping',
                Account_Record_Type__c = 'Invalid_Mapping',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Invalid_Mapping__c')
            )
        );

        insert primaryAfflMappingsList;

        Test.startTest();
        List<AffiliationMappingsModel> afflMappingModelsList = AffiliationMappingsMapper.getInstance()
            .getAffiliationMappingsModel();
        Test.stopTest();

        System.assertEquals(
            'Invalid Affiliation Mapping',
            afflMappingModelsList[0].name,
            'Affiliation Mapping Model name should match Primary Affiliation.'
        );

        System.assertEquals(
            UTIL_Namespace.StrTokenNSPrefix('Invalid_Mapping__c'),
            afflMappingModelsList[0].primaryAffiliationField,
            'Affiliation Mapping Model Field Name should match Primary Affiliation.'
        );

        System.assertEquals(
            'Invalid_Mapping',
            afflMappingModelsList[0].accountRecordTypeFieldValue,
            'Affiliation Mapping Model account record type should match account record type name in affiliation mapping.'
        );

        System.assertEquals(
            false,
            afflMappingModelsList[0].autoProgramEnrollment,
            'Affiliation Mapping Model auto enrollment should match Primary Affiliation.'
        );
        System.assertEquals(
            '""',
            afflMappingModelsList[0].autoProgramEnrollmentStatus,
            'Affiliation Mapping Model auto enrollment status should match Primary Affiliation.'
        );

        System.assertEquals(
            '""',
            afflMappingModelsList[0].autoProgramEnrollmentRole,
            'Affiliation Mapping Model auto enrollment role should match Primary Affiliation.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * AffiliationMappingsMapper class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        AffiliationMappingsMapper AffiliationMappingsMapperInstance = AffiliationMappingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            AffiliationMappingsMapper.instance,
            AffiliationMappingsMapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            AffiliationMappingsMapperInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * AffiliationMappingsMapper class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        AffiliationMappingsMapper AffiliationMappingsMapperInstance1 = AffiliationMappingsMapper.getInstance();
        AffiliationMappingsMapper AffiliationMappingsMapperInstance2 = AffiliationMappingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            AffiliationMappingsMapper.instance,
            AffiliationMappingsMapperInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            AffiliationMappingsMapperInstance1,
            AffiliationMappingsMapperInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            AffiliationMappingsMapperInstance1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /*******************************************************************************************************
     * @description Test to verify insertAffiliationMappingModel() inserts a new affiliation mapping.
     *******************************************************************************************************/
    @isTest
    private static void insertAffiliationMappingModelValid() {
        AffiliationMappingsModel affiliationMappingsModelToInsert = new AffiliationMappingsModel(
            'Test Affiliation Mapping',
            'Test_Record_Type',
            'Test Contact Primary Affl Field'
        );

        AffiliationMappingsMapper affiliationMappingsMapperInstance = AffiliationMappingsMapper.getInstance();

        Test.startTest();
        affiliationMappingsMapperInstance.insertAffiliationMappingModel(affiliationMappingsModelToInsert);
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
            WHERE Name = :affiliationMappingsModelToInsert.name
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
     * @description Test method to verify that the updateAffiliationMappings method updates the affiliation Mappings
     ***************************************************************************************************************************/
    @isTest
    public static void updateAffiliationMappings() {
        Affl_Mappings__c afflMapping = new Affl_Mappings__c(
            Name = 'Household Account',
            Account_Record_Type__c = 'HH_Account',
            Primary_Affl_Field__c = 'Primary_Household__c'
        );
        insert afflMapping;

        AffiliationMappingsModel afflMappingModel = new AffiliationMappingsModel(
            'Household Account',
            'Business_Organization',
            'Primary_Department__c'
        );

        Test.startTest();
        AffiliationMappingsMapper.getInstance().updateAffiliationMappings(afflMappingModel);
        Test.stopTest();

        Affl_Mappings__c afflSettings = Affl_Mappings__c.getInstance(afflMappingModel.name);
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
     * @description Test method to verify that the updateAutoEnrollmentMapping method updates the auto enrollment on affiliation Mappings
     ***************************************************************************************************************************/
    @isTest
    public static void updateAutoEnrollmentMappingValid() {
        Affl_Mappings__c afflMapping = new Affl_Mappings__c(
            Name = 'Household Account',
            Account_Record_Type__c = 'HH_Account',
            Primary_Affl_Field__c = 'Primary_Household__c',
            Auto_Program_Enrollment__c = true,
            Auto_Program_Enrollment_Status__c = 'Test_Status',
            Auto_Program_Enrollment_Role__c = 'Test_Role'
        );
        insert afflMapping;

        AffiliationMappingsModel afflMappingModel = new AffiliationMappingsModel(
            'Household Account',
            null,
            null,
            null,
            'Test_Status2',
            'Test_Role2'
        );

        Test.startTest();
        AffiliationMappingsMapper.getInstance().updateAutoEnrollmentMapping(afflMappingModel);
        Test.stopTest();

        Affl_Mappings__c assertAfflMapping = Affl_Mappings__c.getInstance(afflMappingModel.name);
        System.assertEquals(
            'Household Account',
            assertAfflMapping.name,
            'Household account mapping should be retrieved'
        );
        System.assertEquals(
            'Test_Status2',
            assertAfflMapping.Auto_Program_Enrollment_Status__c,
            'Auto_Program_Enrollment_Status__c should be changed to Test_Status2'
        );
        System.assertEquals(
            'Test_Role2',
            assertAfflMapping.Auto_Program_Enrollment_Role__c,
            'Auto_Program_Enrollment_Role__c should be changed to Test_Role2'
        );
    }

    /*******************************************************************************************************
     * @description Test to verify deleteAffiliationMappingModel() deletes a specified affiliation mapping.
     *******************************************************************************************************/
    @isTest
    private static void deleteAffiliationMappingModelValid() {
        Affl_Mappings__c affiliationMappingToDelete = new Affl_Mappings__c(
            Name = 'Test Affiliation Mapping',
            Account_Record_Type__c = 'Test_Record_Type',
            Primary_Affl_Field__c = 'Test Contact Primary Affl Field',
            Auto_Program_Enrollment__c = true,
            Auto_Program_Enrollment_Status__c = 'Test Auto Enrollment Status',
            Auto_Program_Enrollment_Role__c = 'Test Auto Enrollment Role'
        );

        insert affiliationMappingToDelete;

        AffiliationMappingsModel affiliationMappingsModelToDelete = new AffiliationMappingsModel(
            affiliationMappingToDelete.name,
            affiliationMappingToDelete.Account_Record_Type__c,
            affiliationMappingToDelete.Primary_Affl_Field__c,
            affiliationMappingToDelete.Auto_Program_Enrollment__c,
            affiliationMappingToDelete.Auto_Program_Enrollment_Status__c,
            affiliationMappingToDelete.Auto_Program_Enrollment_Role__c
        );

        AffiliationMappingsMapper affiliationMappingsMapperInstance = AffiliationMappingsMapper.getInstance();

        Test.startTest();
        String primaryAffiliationRecordTypeName = affiliationMappingsMapperInstance.deleteAffiliationMappingModel(
            affiliationMappingsModelToDelete
        );
        Test.stopTest();

        List<Affl_Mappings__c> affiliationMappingsResultsList = [
            SELECT Name
            FROM Affl_Mappings__c
            WHERE Name = :affiliationMappingsModelToDelete.name
        ];

        System.assertEquals(0, affiliationMappingsResultsList.size(), 'New affiliation mapping should be deleted.');
        System.assertEquals(
            'Test_Record_Type',
            primaryAffiliationRecordTypeName,
            'Should return name of account record type associated with deleted primary affiliation.'
        );
    }
}
