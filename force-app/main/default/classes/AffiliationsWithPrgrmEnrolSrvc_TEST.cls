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
 * @description Test class for AffiliationsWithProgramEnrollmentService.
 */
@isTest
private with sharing class AffiliationsWithPrgrmEnrolSrvc_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * AffiliationsWithProgramEnrollmentService class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        AffiliationsWithProgramEnrollmentService affiliationsWithProgramEnrollmentServiceInstance = AffiliationsWithProgramEnrollmentService.getInstance();
        Test.stopTest();

        System.assertEquals(
            AffiliationsWithProgramEnrollmentService.instance,
            affiliationsWithProgramEnrollmentServiceInstance,
            'Instance of service class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            AffiliationsWithProgramEnrollmentServiceInstance != null,
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * AffiliationsWithProgramEnrollmentService class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        AffiliationsWithProgramEnrollmentService affiliationsWithProgramEnrollmentServiceInstance1 = AffiliationsWithProgramEnrollmentService.getInstance();
        AffiliationsWithProgramEnrollmentService affiliationsWithProgramEnrollmentServiceInstance2 = AffiliationsWithProgramEnrollmentService.getInstance();
        Test.stopTest();

        System.assertEquals(
            AffiliationsWithProgramEnrollmentService.instance,
            affiliationsWithProgramEnrollmentServiceInstance1,
            'Instance of service class returned should match static instance variable.'
        );
        System.assertEquals(
            affiliationsWithProgramEnrollmentServiceInstance1,
            affiliationsWithProgramEnrollmentServiceInstance2,
            'Subsequent retrievals of service class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            affiliationsWithProgramEnrollmentServiceInstance1 != null,
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the locateAffiliationsWithProgramEnrollmentMapper method returns an instance
     * of the AffiliationsWithProgramEnrollmentMapper class.
     ***************************************************************************************************************************/
    @isTest
    private static void locateAffiliationsWithProgramEnrollmentMapper() {
        AffiliationsWithProgramEnrollmentService affiliationsWithProgramEnrollmentServiceInstance = AffiliationsWithProgramEnrollmentService.getInstance();

        Test.startTest();
        AffiliationsWithProgramEnrollmentMapper affiliationsWithProgramEnrollmentMapperInstance = AffiliationsWithProgramEnrollmentServiceInstance.locateAffiliationsWithProgramEnrollmentMapper();
        Test.stopTest();

        System.assertEquals(
            AffiliationsWithProgramEnrollmentMapper.getInstance(),
            affiliationsWithProgramEnrollmentMapperInstance,
            'Should return instance of AffiliationsWithProgramEnrollmentMapper class.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getAffiliationsWithProgramEnrollmentModel method returns a AffiliationsWithProgramEnrollmentModel
     ***************************************************************************************************************************/
    @isTest
    private static void getAffiliationsWithProgramEnrollmentModelValid() {
        AffiliationsWithProgramEnrollmentMapper.instance = new STUB_AffiliationsWithProgramEnrollmentMapper();

        AffiliationsWithProgramEnrollmentService affiliationsWithProgramEnrollmentServiceInstance = AffiliationsWithProgramEnrollmentService.getInstance();

        Test.startTest();
        AffiliationsWithProgramEnrollmentModel affiliationsWithProgramEnrollmentModel = AffiliationsWithProgramEnrollmentServiceInstance.getAffiliationsWithProgramEnrollmentModel();
        Test.stopTest();

        System.assertEquals(
            true,
            affiliationsWithProgramEnrollmentModel.specifyRole,
            'Affiliations With Program Enrollment Specify Role should match value specified.'
        );
        System.assertEquals(
            AffiliationTestSetupFactory_TEST.PROG_ENROLL_ROLE_STUDENT,
            affiliationsWithProgramEnrollmentModel.role,
            'Affiliations With Program Enrollment Role should match value specified.'
        );
        System.assertEquals(
            AffiliationTestSetupFactory_TEST.PROG_ENROLL_STATUS_CURRENT,
            affiliationsWithProgramEnrollmentModel.status,
            'Affiliations With Program Enrollment Status should match value specified.'
        );
        System.assertEquals(
            true,
            affiliationsWithProgramEnrollmentModel.copyEndDate,
            'Affiliations With Program Enrollment Copy End Date should match value specified.'
        );
        System.assertEquals(
            true,
            affiliationsWithProgramEnrollmentModel.copyStartDate,
            'Affiliations With Program Enrollment Copy Start Date should match value specified.'
        );
    }

    /***********************************************************************************************************************************
     ****************************************************** STUBS ***********************************************************************
     ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AffiliationsWithProgramEnrollmentMapper to return
     * a valid AffiliationsWithProgramEnrollmentModel
     **************************************************************************************************************************************/
    private class STUB_AffiliationsWithProgramEnrollmentMapper extends AffiliationsWithProgramEnrollmentMapper {
        public override AffiliationsWithProgramEnrollmentModel getAffiliationsWithProgramEnrollmentModel() {
            return new AffiliationsWithProgramEnrollmentModel(
                true,
                AffiliationTestSetupFactory_TEST.PROG_ENROLL_ROLE_STUDENT,
                AffiliationTestSetupFactory_TEST.PROG_ENROLL_STATUS_CURRENT,
                true,
                true
            );
        }
    }
}
