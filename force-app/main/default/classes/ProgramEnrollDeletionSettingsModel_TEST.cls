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
 * @description Test class for ProgramEnrollmentDeletionSettingsModel.
 */
@isTest
private with sharing class ProgramEnrollDeletionSettingsModel_TEST {
    /*******************************************************************************
     * @description Test method to verify 2 argument constructor returns a
     * ProgramEnrollmentDeletionSettingsModel with all properties populated.
     *******************************************************************************/
    @isTest
    private static void twoArgumentConstructorValid() {
        Test.startTest();
        ProgramEnrollmentDeletionSettingsModel programEnrollmentDeletionSettingsModel = new ProgramEnrollmentDeletionSettingsModel(
            true,
            'Test Status'
        );
        Test.stopTest();

        System.assertEquals(
            true,
            programEnrollmentDeletionSettingsModel.programEnrollmentDeletion,
            'Program enrollment deletion enablement should match value specified.'
        );
        System.assertEquals(
            'Test Status',
            programEnrollmentDeletionSettingsModel.programEnrollmentDeletionStatus,
            'Program enrollment deletion status should match value specified.'
        );
    }

    /*******************************************************************************
     * @description Test method to verify 2 argument constructor returns a
     * ProgramEnrollmentDeletionSettingsModel with all properties populated when a blank
     * string is provided as an argument.
     *******************************************************************************/
    @isTest
    private static void twoArgumentConstructorWithBlankValid() {
        Test.startTest();
        ProgramEnrollmentDeletionSettingsModel programEnrollmentDeletionSettingsModel = new ProgramEnrollmentDeletionSettingsModel(
            false,
            ''
        );
        Test.stopTest();

        System.assertEquals(
            false,
            programEnrollmentDeletionSettingsModel.programEnrollmentDeletion,
            'Program enrollment deletion enablement should match value specified.'
        );
        System.assertEquals(
            '""',
            programEnrollmentDeletionSettingsModel.programEnrollmentDeletionStatus,
            'Program enrollment deletion status should be blank.'
        );
    }

    /*******************************************************************************
     * @description Test method to verify 2 argument constructor returns a
     * ProgramEnrollmentDeletionSettingsModel with all properties populated when a null
     * string is provided as an argument.
     *******************************************************************************/
    @isTest
    private static void twoArgumentConstructorWithNullValid() {
        Test.startTest();
        ProgramEnrollmentDeletionSettingsModel programEnrollmentDeletionSettingsModel = new ProgramEnrollmentDeletionSettingsModel(
            false,
            null
        );
        Test.stopTest();

        System.assertEquals(
            false,
            programEnrollmentDeletionSettingsModel.programEnrollmentDeletion,
            'Program enrollment deletion enablement should match value specified.'
        );
        System.assertEquals(
            '""',
            programEnrollmentDeletionSettingsModel.programEnrollmentDeletionStatus,
            'Program enrollment deletion status should be blank.'
        );
    }
}
