/*
    Copyright (c) 2011, Salesforce.org
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
 * @date 2011 (1.x)
 * @group Utilities
 * @group-content ../../ApexDocContent/Utilities.htm
 * @description Class to act as a service layer for running Ethnicity and Racebackfill.
 */
public virtual with sharing class VersionCleanupBatchJobService {
    /**********************************************************************************
     * @description Instance for Singleton Pattern
     **********************************************************************************/
    @TestVisible
    private static VersionCleanupBatchJobService instance;

    /**********************************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************************/
    protected VersionCleanupBatchJobService() {
    }

    /**********************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of VersionCleanupBatchJobService.
     **********************************************************************************/
    public static VersionCleanupBatchJobService getInstance() {
        if (instance == null) {
            instance = new VersionCleanupBatchJobService();
        }

        return instance;
    }

    /**********************************************************************************
     * @description Calls the runEthnicityAndRaceBackfillBatch method which inturn runs
     * CON_EthnicityRace_BATCH job
     * @return Boolean True is success, else throws an error
     **********************************************************************************/
    public virtual Boolean runEthnicityAndRaceBackfillJob() {
        CON_EthnicityRace_BATCH ethnicityAndRaceBatch = new CON_EthnicityRace_BATCH();
        Id jobId = this.runEthnicityAndRaceBackfillBatch(ethnicityAndRaceBatch);
        if (jobId == null) {
            throw new AuraHandledException(Label.BatchJobRunningProblem);
        } else {
            return true;
        }
    }

    /**********************************************************************************
     * @description Calls the runCourseDescriptionCopyBatchJob which inturn runs
     * COUR_DescriptionCopy_BATCH job.
     * @return Id The batch job id for the CON_EthnicityRace_BATCH
     **********************************************************************************/
    @TestVisible
    private virtual Id runEthnicityAndRaceBackfillBatch(CON_EthnicityRace_BATCH ethnicityAndRaceBatch) {
        Id jobId = Database.executeBatch(ethnicityAndRaceBatch, 200);
        return jobId;
    }

    /**********************************************************************************
     * @description Runs the COUR_DescriptionCopy_BATCH Job
     * @return Boolean True is success, else throws an error
     **********************************************************************************/
    public virtual Boolean runCourseDescriptionCopyBatchJob() {
        COUR_DescriptionCopy_BATCH copyCourseDescription = new COUR_DescriptionCopy_BATCH();
        Id jobId = this.runCourseDescriptionCopyBatch(copyCourseDescription);
        if (jobId == null) {
            throw new AuraHandledException(Label.BatchJobRunningProblem);
        } else {
            return true;
        }
    }

    /**********************************************************************************
     * @description Runs the CourseDescriptionBatch Job
     * @return Id The batch job id for the COUR_DescriptionCopy_BATCH
     **********************************************************************************/
    @TestVisible
    private virtual Id runCourseDescriptionCopyBatch(COUR_DescriptionCopy_BATCH copyCourseDescriptionBatch) {
        Id jobId = Database.executeBatch(copyCourseDescriptionBatch, 200);
        return jobId;
    }
}
