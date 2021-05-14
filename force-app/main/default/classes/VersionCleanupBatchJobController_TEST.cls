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
 * @group-content ../../ApexDocContent/
 * @description Test class for  VersionCleanupBatchJobController
 */
@isTest
private with sharing class VersionCleanupBatchJobController_TEST {
    /***********************************************************************************************************************************
     * @description Test method to verify that the locateVersionCleanUpBatchJobService method returns instance of locateVersionCleanUpBatchJobService
     ***********************************************************************************************************************************/
    @isTest
    private static void locateVersionCleanUpBatchJobService() {
        Test.startTest();
        VersionCleanupBatchJobService versionCleanupBatchJobServiceInstance = VersionCleanupBatchJobService.getInstance();
        Test.stopTest();

        System.assertEquals(
            VersionCleanupBatchJobService.getInstance(),
            versionCleanupBatchJobServiceInstance,
            'Should return the instance of VersionCleanupBatchJobService'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify runEthnicityAndRaceBackfillJob method runs successfully
     ***********************************************************************************************************************************/
    @isTest
    private static void runEthnicityAndRaceBackfillJobValid() {
        VersionCleanupBatchJobService.instance = new STUB_EthnicityAndRaceBackfillJobServiceValid();
        Test.startTest();
        Boolean batchJobSuccessful = VersionCleanupBatchJobController.runEthnicityAndRaceBackfillJob();
        Test.stopTest();

        System.assertEquals(true, batchJobSuccessful, 'Should return true if the batch job has run successfully');
    }

    /***********************************************************************************************************************************
     * @description Test method to verify runEthnicityAndRaceBackfillJob method throws an error
     ***********************************************************************************************************************************/
    @isTest
    private static void runEthnicityAndRaceBackfillJobError() {
        VersionCleanupBatchJobService.instance = new STUB_EthnicityAndRaceBackfillJobServiceInvalid();
        try {
            Test.startTest();
            Boolean batchJobSuccessful = VersionCleanupBatchJobController.runEthnicityAndRaceBackfillJob();
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /***********************************************************************************************************************************
     * @description Test method to verify runCourseDescriptionCopyBatchJob method runs successfully
     ***********************************************************************************************************************************/
    @isTest
    private static void runCourseDescriptionCopyBatchJobValid() {
        VersionCleanupBatchJobService.instance = new STUB_CopyCourseDescriptionJobServiceValid();
        Test.startTest();
        Boolean batchJobSuccessful = VersionCleanupBatchJobController.runCourseDescriptionCopyBatchJob();
        Test.stopTest();

        System.assertEquals(true, batchJobSuccessful, 'Should return true if the batch job has run successfully');
    }

    /***********************************************************************************************************************************
     * @description Test method to verify runCourseDescriptionCopyBatchJobJob method throws an error
     ***********************************************************************************************************************************/
    @isTest
    private static void runCourseDescriptionCopyBatchJobError() {
        VersionCleanupBatchJobService.instance = new STUB_CopyCourseDescriptionJobServiceInvalid();
        try {
            Test.startTest();
            Boolean batchJobSuccessful = VersionCleanupBatchJobController.runCourseDescriptionCopyBatchJob();
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /**************************************************************************************************************************
     ****************************************************** STUBS **************************************************************
     **************************************************************************************************************************/

    /**************************************************************************************************************************************************
     * @description Stub class to simulate the response from VersionCleanupBatchJobService to return a true for runEthnicityAndRaceBackfillJob method .
     **************************************************************************************************************************************************/
    private class STUB_EthnicityAndRaceBackfillJobServiceValid extends VersionCleanupBatchJobService {
        public override Boolean runEthnicityAndRaceBackfillJob() {
            return true;
        }
    }

    /***************************************************************************************************************************************************
     * @description Stub class to simulate the response from VersionCleanupBatchJobService to throw an error for runEthnicityAndRaceBackfillJob method
     ***************************************************************************************************************************************************/
    private class STUB_EthnicityAndRaceBackfillJobServiceInvalid extends VersionCleanupBatchJobService {
        public override Boolean runEthnicityAndRaceBackfillJob() {
            throw new AuraHandledException(Label.BatchJobRunningProblem);
        }
    }

    /**************************************************************************************************************************************************
     * @description Stub class to simulate the response from VersionCleanupBatchJobService to return a true for runCourseDescriptionCopyBatchJob method .
     **************************************************************************************************************************************************/
    private class STUB_CopyCourseDescriptionJobServiceValid extends VersionCleanupBatchJobService {
        public override Boolean runCourseDescriptionCopyBatchJob() {
            return true;
        }
    }

    /***************************************************************************************************************************************************
     * @description Stub class to simulate the response from VersionCleanupBatchJobService to throw an error for runCourseDescriptionCopyBatchJob method
     ***************************************************************************************************************************************************/
    private class STUB_CopyCourseDescriptionJobServiceInvalid extends VersionCleanupBatchJobService {
        public override Boolean runCourseDescriptionCopyBatchJob() {
            throw new AuraHandledException(Label.BatchJobRunningProblem);
        }
    }
}
