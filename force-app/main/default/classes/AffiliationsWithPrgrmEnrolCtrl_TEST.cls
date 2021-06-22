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
 * @description Test class for AffiliationsWithProgramEnrollmentController class.
 */
@isTest
private with sharing class AffiliationsWithPrgrmEnrolCtrl_TEST {
    private static Integer loopCounter = 5;

    /****************************************************************************************
     * @description Test method to verify locateAffiliationsWithProgramEnrollmentVMapper() returns an instance of
     * the AffiliationsWithProgramEnrollmentVMapper class.
     ****************************************************************************************/
    @isTest
    private static void locateAffiliationsWithProgramEnrollmentVMapper() {
        Test.startTest();
        AffiliationsWithProgramEnrollmentVMapper affiliationsWithProgramEnrollmentVMapperInstance = AffiliationsWithProgramEnrollController.locateAffiliationsWithProgramEnrollmentVMapper();
        Test.stopTest();

        System.assertEquals(
            AffiliationsWithProgramEnrollmentVMapper.getInstance(),
            affiliationsWithProgramEnrollmentVMapperInstance,
            'Should return instance of AffiliationsWithProgramEnrollmentVMapper class.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getAffiliationsWithProgramEnrollmentVModel()
     * returns an instance of AffiliationsWithProgramEnrollmentVModel with valid values from valid stub.
     ****************************************************************************************/
    @isTest
    private static void getAffiliationsWithProgramEnrollmentVModelValid() {
        AffiliationsWithProgramEnrollmentVMapper.instance = new STUB_AffiliationsWithProgramEnrollmentVMapperValid();

        Test.startTest();
        AffiliationsWithProgramEnrollmentVModel affiliationsWithProgramEnrollmentVModel = AffiliationsWithProgramEnrollController.getAffiliationsWithProgramEnrollmentVModel();
        Test.stopTest();

        System.assertEquals(
            'Selected Role',
            affiliationsWithProgramEnrollmentVModel.role.value,
            'Selected  Affiliations With Program Enrollmentstatus should be \'Selected Role\'.'
        );

        System.assertEquals(
            loopCounter,
            affiliationsWithProgramEnrollmentVModel.role.options.size(),
            'Should have ' +
            loopCounter +
            ' status options.'
        );

        System.assertEquals(
            'Selected Status',
            affiliationsWithProgramEnrollmentVModel.status.value,
            'Selected  Affiliations With Program Enrollmentstatus should be \'Selected Status\'.'
        );
        System.assertEquals(
            loopCounter,
            affiliationsWithProgramEnrollmentVModel.status.options.size(),
            'Should have ' +
            loopCounter +
            ' status options.'
        );

        System.assertEquals(
            false,
            affiliationsWithProgramEnrollmentVModel.copyEndDate,
            ' Affiliations With Program Enrollment copy end date should not be enabled.'
        );

        System.assertEquals(
            false,
            affiliationsWithProgramEnrollmentVModel.copyStartDate,
            ' Affiliations With Program Enrollment copy start date should not be enabled.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getAffiliationsWithProgramEnrollmentVModel()
     * throws an exception when exception occurs.
     ****************************************************************************************/
    @isTest
    private static void getAffiliationsWithProgramEnrollmentVModelException() {
        AffiliationsWithProgramEnrollmentVMapper.instance = new STUB_ExceptionAffiliationsWithProgramEnrollmentVMapper();

        try {
            Test.startTest();
            AffiliationsWithProgramEnrollmentVModel AffiliationsWithProgramEnrollmentVModel = AffiliationsWithProgramEnrollController.getAffiliationsWithProgramEnrollmentVModel();
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
     * @description Stub class to simulate valid responses from AffiliationsWithProgramEnrollmentVMapper
     **************************************************************************************************************************************/
    private class STUB_AffiliationsWithProgramEnrollmentVMapperValid extends AffiliationsWithProgramEnrollmentVMapper {
        public override AffiliationsWithProgramEnrollmentVModel getAffiliationsWithProgramEnrollmentVModel() {
            List<ComboboxValueVModel> affiliationsWithProgramEnrollmentRoleOptions = new List<ComboboxValueVModel>();
            List<ComboboxValueVModel> affiliationsWithProgramEnrollmentStatusOptions = new List<ComboboxValueVModel>();

            for (Integer i = 0; i < loopCounter; i++) {
                affiliationsWithProgramEnrollmentRoleOptions.add(new ComboboxValueVModel('Role ' + i, 'Role_' + i));
                affiliationsWithProgramEnrollmentStatusOptions.add(
                    new ComboboxValueVModel('Status ' + i, 'Status_' + i)
                );
            }

            ComboboxVModel affiliationsWithProgramEnrollmentRoleComboBox = new ComboboxVModel(
                'Selected Role',
                affiliationsWithProgramEnrollmentRoleOptions
            );

            ComboboxVModel affiliationsWithProgramEnrollmentStatusComboBox = new ComboboxVModel(
                'Selected Status',
                affiliationsWithProgramEnrollmentStatusOptions
            );

            return new AffiliationsWithProgramEnrollmentVModel(
                affiliationsWithProgramEnrollmentRoleComboBox,
                affiliationsWithProgramEnrollmentStatusComboBox,
                false,
                false
            );
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate exception responses from AffiliationsWithProgramEnrollmentVMapper
     **************************************************************************************************************************************/
    private class STUB_ExceptionAffiliationsWithProgramEnrollmentVMapper extends AffiliationsWithProgramEnrollmentVMapper {
        public override AffiliationsWithProgramEnrollmentVModel getAffiliationsWithProgramEnrollmentVModel() {
            throw new TestException('Exception encountered!');
        }
    }

    private class TestException extends Exception {
    }
}
