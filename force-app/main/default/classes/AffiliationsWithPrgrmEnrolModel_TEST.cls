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
 * @description Test class for AffiliationsWithProgramEnrollmentModel.
 */
@isTest
private with sharing class AffiliationsWithPrgrmEnrolModel_TEST {
    /*******************************************************************************
     * @description Test method to verify 5 argument constructor returns a
     * AffiliationsWithProgramEnrollmentModel with all properties populated.
     *******************************************************************************/
    @isTest
    private static void fiveArgumentConstructorValid() {
        Test.startTest();
        AffiliationsWithProgramEnrollmentModel affiliationsWithProgramEnrollmentModel = new AffiliationsWithProgramEnrollmentModel(
            true,
            AffiliationTestSetupFactory_TEST.PROG_ENROLL_ROLE_STUDENT,
            'current',
            true,
            true
        );
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
            'current',
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

    /*******************************************************************************
     * @description Test method to verify 5 argument constructor returns a
     * AffiliationsWithProgramEnrollmentModel with all properties populated when a blank
     * string is provided as an argument.
     *******************************************************************************/
    @isTest
    private static void fiveArgumentConstructorWithBlankValid() {
        Test.startTest();
        AffiliationsWithProgramEnrollmentModel affiliationsWithProgramEnrollmentModel = new AffiliationsWithProgramEnrollmentModel(
            false,
            '',
            '',
            true,
            true
        );
        Test.stopTest();

        System.assertEquals(
            false,
            affiliationsWithProgramEnrollmentModel.specifyRole,
            'Affiliations With Program Enrollment enablement should match value specified.'
        );
        System.assertEquals(
            '""',
            affiliationsWithProgramEnrollmentModel.role,
            'Affiliations With Program Enrollment role should be blank.'
        );
        System.assertEquals(
            '""',
            affiliationsWithProgramEnrollmentModel.status,
            'Affiliations With Program Enrollment Status should be blank.'
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

    /*******************************************************************************
     * @description Test method to verify 2 argument constructor returns a
     * AffiliationsWithProgramEnrollmentModel with all properties populated when a null
     * string is provided as an argument.
     *******************************************************************************/
    @isTest
    private static void fiveArgumentConstructorWithNullValid() {
        Test.startTest();
        AffiliationsWithProgramEnrollmentModel affiliationsWithProgramEnrollmentModel = new AffiliationsWithProgramEnrollmentModel(
            false,
            null,
            null,
            true,
            true
        );
        Test.stopTest();

        System.assertEquals(
            false,
            affiliationsWithProgramEnrollmentModel.specifyRole,
            'Affiliations With Program Enrollment enablement should match value specified.'
        );
        System.assertEquals(
            '""',
            affiliationsWithProgramEnrollmentModel.role,
            'Affiliations With Program Enrollment role should be blank.'
        );
        System.assertEquals(
            '""',
            affiliationsWithProgramEnrollmentModel.status,
            'Affiliations With Program Enrollment Status should be blank.'
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
}
