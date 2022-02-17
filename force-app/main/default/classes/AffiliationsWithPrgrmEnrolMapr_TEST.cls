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
 * @group Test
 * @group-content ../../ApexDocContent/Test.htm
 * @description Test class for AffiliationsWithProgramEnrollmentMapper.
 */
@isTest
private with sharing class AffiliationsWithPrgrmEnrolMapr_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * AffiliationsWithProgramEnrollmentMapper class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        AffiliationsWithProgramEnrollmentMapper affiliationsWithProgramEnrollmentMapperInstance = AffiliationsWithProgramEnrollmentMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            AffiliationsWithProgramEnrollmentMapper.instance,
            affiliationsWithProgramEnrollmentMapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            AffiliationsWithProgramEnrollmentMapperInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * AffiliationsWithProgramEnrollmentMapper class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        AffiliationsWithProgramEnrollmentMapper affiliationsWithProgramEnrollmentMapper1 = AffiliationsWithProgramEnrollmentMapper.getInstance();
        AffiliationsWithProgramEnrollmentMapper affiliationsWithProgramEnrollmentMapper2 = AffiliationsWithProgramEnrollmentMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            AffiliationsWithProgramEnrollmentMapper.instance,
            affiliationsWithProgramEnrollmentMapper1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            affiliationsWithProgramEnrollmentMapper1,
            affiliationsWithProgramEnrollmentMapper2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            affiliationsWithProgramEnrollmentMapper1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getAffiliationsWithProgramEnrollmentModel method returns a
     * AffiliationsWithProgramEnrollmentModel matching with the values specified in hierarchy
     * settings.
     ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationsWithProgramEnrollmentModelValid() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Affl_ProgEnroll_Set_Role__c = true,
                Affl_ProgEnroll_Role_Map__c = AffiliationTestSetupFactory_TEST.PROG_ENROLL_ROLE_STUDENT,
                Affl_ProgEnroll_Status_Map__c = AffiliationTestSetupFactory_TEST.PROG_ENROLL_STATUS_CURRENT,
                Affl_ProgEnroll_Copy_End_Date__c = true,
                Affl_ProgEnroll_Copy_Start_Date__c = true
            )
        );

        AffiliationsWithProgramEnrollmentMapper AffiliationsWithProgramEnrollmentMapperInstance = AffiliationsWithProgramEnrollmentMapper.getInstance();

        Test.startTest();
        AffiliationsWithProgramEnrollmentModel AffiliationsWithProgramEnrollmentModel = AffiliationsWithProgramEnrollmentMapperInstance.getAffiliationsWithProgramEnrollmentModel();
        Test.stopTest();

        System.assertEquals(
            true,
            AffiliationsWithProgramEnrollmentModel.specifyRole,
            'Affil Set Role When Create Prog Enroll should be enabled.'
        );
        System.assertEquals(
            AffiliationTestSetupFactory_TEST.PROG_ENROLL_ROLE_STUDENT,
            AffiliationsWithProgramEnrollmentModel.role,
            'Affil Role When Create Prog Enroll should be set to \'Student\''
        );
        System.assertEquals(
            AffiliationTestSetupFactory_TEST.PROG_ENROLL_STATUS_CURRENT,
            AffiliationsWithProgramEnrollmentModel.status,
            'Affil Status When Create Prog Enroll should be set to \'Current\''
        );
        System.assertEquals(
            true,
            AffiliationsWithProgramEnrollmentModel.copyEndDate,
            'Affil End Date Copy from Prog Enroll should be enabled'
        );
        System.assertEquals(
            true,
            AffiliationsWithProgramEnrollmentModel.copyStartDate,
            'Affil Start Date Copy from Prog Enroll should be enabled'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getAffiliationsWithProgramEnrollmentModel method returns a
     * AffiliationsWithProgramEnrollmentModel matching the program enrollment deletion settings specified in hierarchy
     * settings with a blank string for the deletion status when the corresponding hierarchy setting field is blank.
     ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationsWithProgramEnrollmentModelEmptyValid() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Affl_ProgEnroll_Set_Role__c = true,
                Affl_ProgEnroll_Role_Map__c = '',
                Affl_ProgEnroll_Status_Map__c = '',
                Affl_ProgEnroll_Copy_End_Date__c = true,
                Affl_ProgEnroll_Copy_Start_Date__c = true
            )
        );

        AffiliationsWithProgramEnrollmentMapper AffiliationsWithProgramEnrollmentMapperInstance = AffiliationsWithProgramEnrollmentMapper.getInstance();

        Test.startTest();
        AffiliationsWithProgramEnrollmentModel AffiliationsWithProgramEnrollmentModel = AffiliationsWithProgramEnrollmentMapperInstance.getAffiliationsWithProgramEnrollmentModel();
        Test.stopTest();

        System.assertEquals(
            true,
            AffiliationsWithProgramEnrollmentModel.specifyRole,
            'Affil Set Role When Create Prog Enroll should be enabled.'
        );
        System.assertEquals(
            '""',
            AffiliationsWithProgramEnrollmentModel.role,
            'Affil Role When Create Prog Enroll should be a blank string'
        );
        System.assertEquals(
            '""',
            AffiliationsWithProgramEnrollmentModel.status,
            'Affil Status When Create Prog Enroll should be a blank string'
        );
        System.assertEquals(
            true,
            AffiliationsWithProgramEnrollmentModel.copyEndDate,
            'Affil End Date Copy from Prog Enroll should be enabled'
        );
        System.assertEquals(
            true,
            AffiliationsWithProgramEnrollmentModel.copyStartDate,
            'Affil Start Date Copy from Prog Enroll should be enabled'
        );
    }
}
