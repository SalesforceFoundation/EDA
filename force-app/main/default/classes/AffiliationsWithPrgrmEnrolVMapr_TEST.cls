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
 * @description Test class for AffiliationsWithProgramEnrollmentVMapper class.
 */
@isTest
private with sharing class AffiliationsWithPrgrmEnrolVMapr_TEST {
    private static Integer loopCounter = 5;

    /**************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * AffiliationsWithProgramEnrollmentVMapper class when one does not already exist.
     **************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        AffiliationsWithProgramEnrollmentVMapper affiliationsWithProgramEnrollmentVMapperInstance = AffiliationsWithProgramEnrollmentVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            affiliationsWithProgramEnrollmentVMapper.instance,
            AffiliationsWithProgramEnrollmentVMapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            AffiliationsWithProgramEnrollmentVMapperInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * AffiliationsWithProgramEnrollmentVMapper class when one already exists.
     **************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        AffiliationsWithProgramEnrollmentVMapper affiliationsWithProgramEnrollmentVMapperInstance1 = AffiliationsWithProgramEnrollmentVMapper.getInstance();
        AffiliationsWithProgramEnrollmentVMapper affiliationsWithProgramEnrollmentVMapperInstance2 = AffiliationsWithProgramEnrollmentVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            affiliationsWithProgramEnrollmentVMapper.instance,
            AffiliationsWithProgramEnrollmentVMapperInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            AffiliationsWithProgramEnrollmentVMapperInstance1,
            AffiliationsWithProgramEnrollmentVMapperInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            AffiliationsWithProgramEnrollmentVMapperInstance1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify locateAffiliationsWithProgramEnrollmentService() returns an instance of
     * the AffiliationsWithProgramEnrollmentService class.
     ****************************************************************************************/
    @isTest
    private static void locateAffiliationsWithProgramEnrollmentServiceValid() {
        AffiliationsWithProgramEnrollmentVMapper affiliationsWithProgramEnrollmentVMapperInstance = AffiliationsWithProgramEnrollmentVMapper.getInstance();

        Test.startTest();
        AffiliationsWithProgramEnrollmentService affiliationsWithProgramEnrollmentServiceInstance = AffiliationsWithProgramEnrollmentVMapperInstance.locateAffiliationsWithProgramEnrollmentService();
        Test.stopTest();

        System.assertEquals(
            AffiliationsWithProgramEnrollmentService.getInstance(),
            affiliationsWithProgramEnrollmentServiceInstance,
            'Should return instance of AffiliationsWithProgramEnrollmentService class.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify locatePicklistEntryService() returns an instance of
     * the PicklistEntryService class.
     ****************************************************************************************/
    @isTest
    private static void locatePicklistEntryServiceValid() {
        AffiliationsWithProgramEnrollmentVMapper affiliationsWithProgramEnrollmentVMapperInstance = AffiliationsWithProgramEnrollmentVMapper.getInstance();

        Test.startTest();
        PicklistEntryService picklistEntryServiceInstance = affiliationsWithProgramEnrollmentVMapperInstance.locatePicklistEntryService();
        Test.stopTest();

        System.assertEquals(
            PicklistEntryService.getInstance(),
            picklistEntryServiceInstance,
            'Should return instance of PicklistEntryService class.'
        );
    }

    /************************************************************************************************************************************
     * @description Test method to verify getAffiliationsWithProgramEnrollmentVModel returns a AffiliationsWithProgramEnrollmentVModel
     * corresponding to the Program Enrollment Deletion settings specified in Hierarchy Settings and active Status picklist options for
     * Affiliations.
     ************************************************************************************************************************************/
    @isTest
    private static void getAffiliationsWithProgramEnrollmentVModelValid() {
        PicklistEntryService.instance = new STUB_PicklistEntryService();
        AffiliationsWithProgramEnrollmentService.instance = new STUB_AffiliationsWithProgramEnrollmentService();

        AffiliationsWithProgramEnrollmentVMapper affiliationsWithProgramEnrollmentVMapperInstance = AffiliationsWithProgramEnrollmentVMapper.getInstance();

        Test.startTest();
        AffiliationsWithProgramEnrollmentVModel affiliationsWithProgramEnrollmentVModel = affiliationsWithProgramEnrollmentVMapperInstance.getAffiliationsWithProgramEnrollmentVModel();
        Test.stopTest();

        System.assertEquals(
            '""',
            affiliationsWithProgramEnrollmentVModel.role.value,
            'Role should be null in vmodel since secify role is false.'
        );

        System.assertEquals(
            3,
            affiliationsWithProgramEnrollmentVModel.role.options.size(),
            'Should only include active Statuses and None as Affiliations With Program Enrollment Role options.'
        );

        System.assertEquals(
            'Test Active Status 2',
            affiliationsWithProgramEnrollmentVModel.status.value,
            'Selected Affiliations With Program Enrollment Status should match value in hierarchy settings.'
        );

        System.assertEquals(
            3,
            affiliationsWithProgramEnrollmentVModel.status.options.size(),
            'Should only include active Statuses and None as Affiliations With Program Enrollment Status options.'
        );

        System.assertEquals(
            false,
            affiliationsWithProgramEnrollmentVModel.copyEndDate,
            'Affiliations With Program Enrollment end date should not be enabled.'
        );

        System.assertEquals(
            false,
            affiliationsWithProgramEnrollmentVModel.copyStartDate,
            'Affiliations With Program Enrollment start date should not be enabled.'
        );
    }

    /************************************************************************************************************************************
     * @description Test method to verify getAffiliationsWithProgramEnrollmentVModel returns a AffiliationsWithProgramEnrollmentVModel
     * corresponding to the Program Enrollment Deletion settings specified in Hierarchy Settings and active Status picklist options for
     * Affiliations.
     ************************************************************************************************************************************/
    @isTest
    private static void getAffiliationsWithProgramEnrollmentVModelValidWithSpecifyRoleTrue() {
        PicklistEntryService.instance = new STUB_PicklistEntryService();
        AffiliationsWithProgramEnrollmentService.instance = new STUB_AffiliationsWithProgramEnrollmentServiceSpecifyRole();

        AffiliationsWithProgramEnrollmentVMapper affiliationsWithProgramEnrollmentVMapperInstance = AffiliationsWithProgramEnrollmentVMapper.getInstance();

        Test.startTest();
        AffiliationsWithProgramEnrollmentVModel affiliationsWithProgramEnrollmentVModel = affiliationsWithProgramEnrollmentVMapperInstance.getAffiliationsWithProgramEnrollmentVModel();
        Test.stopTest();

        System.assertEquals(
            'Test Active Status 1',
            affiliationsWithProgramEnrollmentVModel.role.value,
            'Role should be null in vmodel since secify role is false.'
        );

        System.assertEquals(
            3,
            affiliationsWithProgramEnrollmentVModel.role.options.size(),
            'Should only include active Statuses and None as Affiliations With Program Enrollment Role options.'
        );

        System.assertEquals(
            'Test Active Status 2',
            affiliationsWithProgramEnrollmentVModel.status.value,
            'Selected Affiliations With Program Enrollment Status should match value in hierarchy settings.'
        );

        System.assertEquals(
            3,
            affiliationsWithProgramEnrollmentVModel.status.options.size(),
            'Should only include active Statuses and None as Affiliations With Program Enrollment Status options.'
        );

        System.assertEquals(
            false,
            affiliationsWithProgramEnrollmentVModel.copyEndDate,
            'Affiliations With Program Enrollment end date should not be enabled.'
        );

        System.assertEquals(
            false,
            affiliationsWithProgramEnrollmentVModel.copyStartDate,
            'Affiliations With Program Enrollment start date should not be enabled.'
        );
    }

    /***********************************************************************************************************************************
     ****************************************************** STUBS ***********************************************************************
     ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from PicklistEntryService to return a valid respose
     **************************************************************************************************************************************/
    private class STUB_PicklistEntryService extends PicklistEntryService {
        public override Map<String, PicklistEntryModel> getModelsByNameForSObjectField(
            SObjectType sObjectTypeName,
            SObjectField SObjectFieldName
        ) {
            return new Map<String, PicklistEntryModel>{
                'Test Active Status 1' => new PicklistEntryModel('Test Active Status 1', 'Test_Active_Status_1', true),
                'Test Active Status 2' => new PicklistEntryModel('Test Active Status 2', 'Test_Active_Status_2', true),
                'Test Inactive Status 3' => new PicklistEntryModel(
                    'Test Inactive Status 3',
                    'Test_Inactive_Status_3',
                    false
                )
            };
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AffiliationsWithProgramEnrollmentService to return a valid respose
     **************************************************************************************************************************************/
    private class STUB_AffiliationsWithProgramEnrollmentService extends AffiliationsWithProgramEnrollmentService {
        public override AffiliationsWithProgramEnrollmentModel getAffiliationsWithProgramEnrollmentModel() {
            return new AffiliationsWithProgramEnrollmentModel(
                false,
                'Test Active Status 1',
                'Test Active Status 2',
                false,
                false
            );
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AffiliationsWithProgramEnrollmentService to return a valid respose
     **************************************************************************************************************************************/
    private class STUB_AffiliationsWithProgramEnrollmentServiceSpecifyRole extends AffiliationsWithProgramEnrollmentService {
        public override AffiliationsWithProgramEnrollmentModel getAffiliationsWithProgramEnrollmentModel() {
            return new AffiliationsWithProgramEnrollmentModel(
                true,
                'Test Active Status 1',
                'Test Active Status 2',
                false,
                false
            );
        }
    }
}
