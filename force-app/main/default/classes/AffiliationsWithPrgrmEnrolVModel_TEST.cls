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
 * @description Test class for AffiliationsWithProgramEnrollmentVModel.
 */
@isTest
private with sharing class AffiliationsWithPrgrmEnrolVModel_TEST {
    private static Integer loopCount = 5;

    /***********************************************************************************************************
     * @description Test to verify four argument constructor returns a AffiliationsWithProgramEnrollmentVModel
     * with all properties populated.
     ***********************************************************************************************************/
    @isTest
    private static void fourArgumentConstructorValid() {
        List<ComboboxValueVModel> affiliationsWithProgramEnrollmentRoleOptions = new List<ComboboxValueVModel>();
        List<ComboboxValueVModel> affiliationsWithProgramEnrollmentStatusOptions = new List<ComboboxValueVModel>();

        for (Integer i = 0; i < loopCount; i++) {
            affiliationsWithProgramEnrollmentRoleOptions.add(new ComboboxValueVModel('Role ' + i, 'Role_' + i));
            affiliationsWithProgramEnrollmentStatusOptions.add(new ComboboxValueVModel('Status ' + i, 'Status_' + i));
        }

        ComboboxVModel affiliationsWithProgramEnrollmentRoleComboboxVModel = new ComboboxVModel(
            'Role 1',
            affiliationsWithProgramEnrollmentRoleOptions
        );

        ComboboxVModel affiliationsWithProgramEnrollmentStatusComboboxVModel = new ComboboxVModel(
            'Status 1',
            affiliationsWithProgramEnrollmentStatusOptions
        );

        Test.startTest();
        AffiliationsWithProgramEnrollmentVModel affiliationsWithProgramEnrollmentVModel = new AffiliationsWithProgramEnrollmentVModel(
            affiliationsWithProgramEnrollmentRoleComboboxVModel,
            affiliationsWithProgramEnrollmentStatusComboboxVModel,
            true,
            true
        );
        Test.stopTest();

        System.assertEquals(
            'Role 1',
            affiliationsWithProgramEnrollmentVModel.role.value,
            'Affiliations With Program Enrollment Role selected value should not be \'Role 1\'.'
        );

        System.assertEquals(
            'Status 1',
            affiliationsWithProgramEnrollmentVModel.status.value,
            'Affiliations With Program Enrollment Status selected value should not be \'Status 1\'.'
        );

        System.assertEquals(
            loopCount,
            affiliationsWithProgramEnrollmentVModel.role.options.size(),
            'Affiliations With Program Enrollment Role should have ' +
            loopCount +
            ' options.'
        );

        System.assertEquals(
            loopCount,
            affiliationsWithProgramEnrollmentVModel.status.options.size(),
            'Affiliations With Program Enrollment Status should have ' +
            loopCount +
            ' options.'
        );

        System.assertEquals(
            true,
            affiliationsWithProgramEnrollmentVModel.copyEndDate,
            'Affiliations With Program Enrollment Copy End Date should be enabled.'
        );

        System.assertEquals(
            true,
            affiliationsWithProgramEnrollmentVModel.copyStartDate,
            'Affiliations With Program Enrollment Copy start Date should be enabled.'
        );
    }
}
