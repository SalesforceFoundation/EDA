/*
    Copyright (c) 2021, Salesforce.org
    All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
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
 * @group EDA Settings
 * @group-content ../../ApexDocContent/EdaSettings.htm
 * @description Test class for VersionCleanupBatchJobService.
 */
@isTest
private with sharing class VersionCleanupBatchJobService_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * VersionCleanupBatchJobService class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        VersionCleanupBatchJobService versionCleanupBatchJobServiceInstance = VersionCleanupBatchJobService.getInstance();
        Test.stopTest();

        System.assertEquals(
            VersionCleanupBatchJobService.instance,
            versionCleanupBatchJobServiceInstance,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            true,
            versionCleanupBatchJobServiceInstance != null,
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * VersionCleanupBatchJobService class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        VersionCleanupBatchJobService versionCleanupBatchJobServiceInstance1 = VersionCleanupBatchJobService.getInstance();

        VersionCleanupBatchJobService versionCleanupBatchJobServiceInstance2 = VersionCleanupBatchJobService.getInstance();
        Test.stopTest();

        System.assertEquals(
            VersionCleanupBatchJobService.instance,
            versionCleanupBatchJobServiceInstance1,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            versionCleanupBatchJobServiceInstance1,
            versionCleanupBatchJobServiceInstance2,
            'Subsequent retrievals of service class instance should return existing instance.'
        );

        System.assertEquals(
            true,
            versionCleanupBatchJobServiceInstance1 != null,
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify runEthnicityAndRaceBackfillJob runs succesfully
     ***************************************************************************************************************************/
    @isTest
    private static void runEthnicityAndRaceBackfillJobValid() {
        VersionCleanupBatchJobService.instance = new STUB_AdminVersionCleanupBatchJobServiceBatchNotNull();

        Test.startTest();
        Boolean apexJobSuccess = VersionCleanupBatchJobService.getInstance().runEthnicityAndRaceBackfillJob();
        Test.stopTest();
        System.assertEquals(true, apexJobSuccess, 'Ensure apex batch job has run successfully');
    }

    /**************************************************************************************************************************
     * @description Test method to verify runEthnicityAndRaceBackfillJob thorws an error if batch job fails to run
     ***************************************************************************************************************************/
    @isTest
    private static void runrunEthnicityAndRaceBackfillJobInvalid() {
        VersionCleanupBatchJobService.instance = new STUB_AdminVersionCleanupBatchJobServiceBatchNull();
        try {
            Test.startTest();
            Boolean apexJobSuccess = VersionCleanupBatchJobService.getInstance().runEthnicityAndRaceBackfillJob();
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /**************************************************************************************************************************
     * @description Test method to verify runEthnicityAndRaceBackfillBatch runs successfully
     ***************************************************************************************************************************/
    @isTest
    private static void runEthnicityAndRaceBackfillBatch() {
        CON_EthnicityRace_BATCH backFill = new CON_EthnicityRace_BATCH();
        Test.startTest();
        Id batchJobId = VersionCleanupBatchJobService.getInstance().runEthnicityAndRaceBackfillBatch(backFill);
        Test.stopTest();
        System.assertNotEquals(null, batchJobId, 'Ensure apex batch job has run successfully');
    }

    /**************************************************************************************************************************
     * @description Test method to verify runCourseDescriptionCopyBatchJob runs succesfully
     ***************************************************************************************************************************/
    @isTest
    private static void runCourseDescriptionCopyBatchJobValid() {
        VersionCleanupBatchJobService.instance = new STUB_runCourseDescriptionCopyBatchNotNull();

        Test.startTest();
        Boolean apexJobSuccess = VersionCleanupBatchJobService.getInstance().runCourseDescriptionCopyBatchJob();
        Test.stopTest();
        System.assertEquals(true, apexJobSuccess, 'Ensure apex batch job has run successfully');
    }

    /**************************************************************************************************************************
     * @description Test method to verify runCourseDescriptionCopyBatchJob thorws an error if batch job fails to run
     ***************************************************************************************************************************/
    @isTest
    private static void runCourseDescriptionCopyBatchJobInvalid() {
        VersionCleanupBatchJobService.instance = new STUB_runCourseDescriptionCopyBatchNull();
        try {
            Test.startTest();
            Boolean apexJobSuccess = VersionCleanupBatchJobService.getInstance().runCourseDescriptionCopyBatchJob();
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /**************************************************************************************************************************
     * @description Test method to verify runCourseDescriptionCopyBatch runs successfully
     ***************************************************************************************************************************/
    @isTest
    private static void runCourseDescriptionCopyBatch() {
        COUR_DescriptionCopy_BATCH copyCourseDescriptionBatch = new COUR_DescriptionCopy_BATCH();
        Test.startTest();
        Id batchJobId = VersionCleanupBatchJobService.getInstance()
            .runCourseDescriptionCopyBatch(copyCourseDescriptionBatch);
        Test.stopTest();
        System.assertNotEquals(null, batchJobId, 'Ensure apex batch job has run successfully');
    }

    /**************************************************************************************************************************
     ****************************************************** STUB CLASS *********************************************************
     **************************************************************************************************************************/

    /*************************************************************************************************************
     * @description Stub class to simulate the response from VersionCleanupBatchJobService to null for the Ethnicity
     * and RaceBackFill batch job Id
     */
    private class STUB_AdminVersionCleanupBatchJobServiceBatchNull extends VersionCleanupBatchJobService {
        private override Id runEthnicityAndRaceBackfillBatch(CON_EthnicityRace_BATCH ethnicityAndRaceBatch) {
            return null;
        }
    }

    /*******************************************************************************************************************
     * @description Stub class to simulate the response from AccountNamingService to return an Id for the Ethnicity
     * and RaceBackFill batch job Id
     */
    private class STUB_AdminVersionCleanupBatchJobServiceBatchNotNull extends VersionCleanupBatchJobService {
        private override Id runEthnicityAndRaceBackfillBatch(CON_EthnicityRace_BATCH ethnicityAndRaceBatch) {
            return '01217000002Zs0pAAC';
        }
    }

    /*************************************************************************************************************
     * @description Stub class to simulate the response from VersionCleanupBatchJobService to null for the Copy
     * Course batch job Id
     */
    private class STUB_runCourseDescriptionCopyBatchNull extends VersionCleanupBatchJobService {
        private override Id runCourseDescriptionCopyBatch(COUR_DescriptionCopy_BATCH copyCourseDescriptionBatch) {
            return null;
        }
    }

    /*******************************************************************************************************************
     * @description Stub class to simulate the response from VersionCleanupBatchJobService to an Id for the Copy
     * Course batch job Id
     */
    private class STUB_runCourseDescriptionCopyBatchNotNull extends VersionCleanupBatchJobService {
        private override Id runCourseDescriptionCopyBatch(COUR_DescriptionCopy_BATCH copyCourseDescriptionBatch) {
            return '01217000002Zs0pAAC';
        }
    }
}
