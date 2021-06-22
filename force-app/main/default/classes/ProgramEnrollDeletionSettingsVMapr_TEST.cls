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
 * @description Test class for ProgramSettingsController class.
 */
@isTest
private with sharing class ProgramEnrollDeletionSettingsVMapr_TEST {
    private static Integer loopCounter = 5;

    /**************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * ProgramEnrollmentDeletionSettingsVMapper class when one does not already exist.
     **************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        ProgramEnrollmentDeletionSettingsVMapper programEnrollmentDeletionSettingsVMapperInstance = ProgramEnrollmentDeletionSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ProgramEnrollmentDeletionSettingsVMapper.instance,
            programEnrollmentDeletionSettingsVMapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            programEnrollmentDeletionSettingsVMapperInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * ProgramEnrollmentDeletionSettingsVMapper class when one already exists.
     **************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        ProgramEnrollmentDeletionSettingsVMapper programEnrollmentDeletionSettingsVMapperInstance1 = ProgramEnrollmentDeletionSettingsVMapper.getInstance();
        ProgramEnrollmentDeletionSettingsVMapper programEnrollmentDeletionSettingsVMapperInstance2 = ProgramEnrollmentDeletionSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ProgramEnrollmentDeletionSettingsVMapper.instance,
            programEnrollmentDeletionSettingsVMapperInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            programEnrollmentDeletionSettingsVMapperInstance1,
            programEnrollmentDeletionSettingsVMapperInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            programEnrollmentDeletionSettingsVMapperInstance1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify locateProgramEnrollmentDeletionSettingsService() returns an instance of
     * the ProgramEnrollmentDeletionSettingsService class.
     ****************************************************************************************/
    @isTest
    private static void locateProgramEnrollmentDeletionSettingsServiceValid() {
        ProgramEnrollmentDeletionSettingsVMapper programEnrollmentDeletionSettingsVMapperInstance = ProgramEnrollmentDeletionSettingsVMapper.getInstance();

        Test.startTest();
        ProgramEnrollmentDeletionSettingsService programEnrollmentDeletionSettingsServiceInstance = programEnrollmentDeletionSettingsVMapperInstance.locateProgramEnrollmentDeletionSettingsService();
        Test.stopTest();

        System.assertEquals(
            ProgramEnrollmentDeletionSettingsService.getInstance(),
            programEnrollmentDeletionSettingsServiceInstance,
            'Should return instance of ProgramEnrollmentDeletionSettingsService class.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify locatePicklistEntryService() returns an instance of
     * the PicklistEntryService class.
     ****************************************************************************************/
    @isTest
    private static void locatePicklistEntryServiceValid() {
        ProgramEnrollmentDeletionSettingsVMapper programEnrollmentDeletionSettingsVMapperInstance = ProgramEnrollmentDeletionSettingsVMapper.getInstance();

        Test.startTest();
        PicklistEntryService picklistEntryServiceInstance = programEnrollmentDeletionSettingsVMapperInstance.locatePicklistEntryService();
        Test.stopTest();

        System.assertEquals(
            PicklistEntryService.getInstance(),
            picklistEntryServiceInstance,
            'Should return instance of PicklistEntryService class.'
        );
    }

    /************************************************************************************************************************************
     * @description Test method to verify getProgramEnrollmentDeletionSettingsVModel returns a ProgramEnrollmentDeletionSettingsVModel
     * corresponding to the Program Enrollment Deletion settings specified in Hierarchy Settings and active Status picklist options for
     * Affiliations.
     ************************************************************************************************************************************/
    @isTest
    private static void getProgramEnrollmentDeletionSettingsVModelValid() {
        PicklistEntryService.instance = new STUB_PicklistEntryService();
        ProgramEnrollmentDeletionSettingsService.instance = new STUB_ProgramEnrollmentDeletionSettingsService();

        ProgramEnrollmentDeletionSettingsVMapper programEnrollmentDeletionSettingsVMapperInstance = ProgramEnrollmentDeletionSettingsVMapper.getInstance();

        Test.startTest();
        ProgramEnrollmentDeletionSettingsVModel programEnrollmentDeletionSettingsVModel = programEnrollmentDeletionSettingsVMapperInstance.getProgramEnrollmentDeletionSettingsVModel();
        Test.stopTest();

        System.assertEquals(
            false,
            programEnrollmentDeletionSettingsVModel.programEnrollmentDeletion,
            'Program Enrollment Deletion should not be enabled.'
        );
        System.assertEquals(
            'Test Active Status 2',
            programEnrollmentDeletionSettingsVModel.programEnrollmentDeletionStatus.value,
            'Selected Program Enrollment Deletion Status should match value in hierarchy settings.'
        );
        System.assertEquals(
            2,
            programEnrollmentDeletionSettingsVModel.programEnrollmentDeletionStatus.options.size(),
            'Should only include active Statuses as Program Enrollment Deletion Status options.'
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
     * @description Stub class to simulate the response from ProgramEnrollmentDeletionSettingsService to return a valid respose
     **************************************************************************************************************************************/
    private class STUB_ProgramEnrollmentDeletionSettingsService extends ProgramEnrollmentDeletionSettingsService {
        public override ProgramEnrollmentDeletionSettingsModel getProgramEnrollmentDeletionSettingsModel() {
            return new ProgramEnrollmentDeletionSettingsModel(false, 'Test Active Status 2');
        }
    }
}
