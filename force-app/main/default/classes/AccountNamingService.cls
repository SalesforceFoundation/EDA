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
 * @group EDA Settings
 * @group-content ../../ApexDocContent/EdaSettings.htm
 * @description Class to act as a service layer buffer to the view mapper layer.
 */
public virtual with sharing class AccountNamingService {
    /**********************************************************************************
     * @description Instance for Singleton Pattern
     **********************************************************************************/
    @TestVisible
    private static AccountNamingService instance;

    /**********************************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************************/
    protected AccountNamingService() {
    }

    /**********************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of AccountNamingService.
     **********************************************************************************/
    public static AccountNamingService getInstance() {
        if (instance == null) {
            instance = new AccountNamingService();
        }

        return instance;
    }

    /**********************************************************************************
     * @description Runs the Administrative Account Naming Job
     * @return Boolean True is success, else throws an error
     **********************************************************************************/
    public virtual Boolean runRefreshAdministrativeAccountNamingJob() {
        ACCT_AdministrativeNameRefresh_BATCH accountRefresh = new ACCT_AdministrativeNameRefresh_BATCH();
        Id jobId = this.runAdministrativeRefreshBatch(accountRefresh);
        if (jobId == null) {
            throw new AuraHandledException(Label.BatchJobRunningProblem);
        } else {
            return true;
        }
    }

    /**********************************************************************************
     * @description Runs the Administrative Account Naming Job
     * @return Id The batch job id for the ACCT_AdministrativeNameRefresh_BATCH
     **********************************************************************************/
    @TestVisible
    private virtual Id runAdministrativeRefreshBatch(ACCT_AdministrativeNameRefresh_BATCH accountRefresh) {
        Id jobId = Database.executeBatch(accountRefresh, 200);
        return jobId;
    }

    /**********************************************************************************
     * @description Runs the Household Account Naming Job
     * @return Boolean True is success, else throws an error
     **********************************************************************************/
    public virtual Boolean runRefreshHouseHoldAccountNamingJob() {
        ACCT_HouseholdNameRefresh_BATCH accountRefresh = new ACCT_HouseholdNameRefresh_BATCH();
        Id jobId = this.runHouseholdRefreshBatch(accountRefresh);
        if (jobId == null) {
            throw new AuraHandledException(Label.BatchJobRunningProblem);
        } else {
            return true;
        }
    }

    /**********************************************************************************
     * @description Runs the Household Account Naming Job
     * @return Id The batch job id for the ACCT_HouseholdNameRefresh_BATCH
     **********************************************************************************/
    @TestVisible
    private virtual Id runHouseholdRefreshBatch(ACCT_HouseholdNameRefresh_BATCH accountRefresh) {
        Id jobId = Database.executeBatch(accountRefresh, 200);
        return jobId;
    }
}
