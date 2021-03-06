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
 * @description Apex controller for AddressSettings LWC component.
 */
public with sharing class AccountNamingBatchController {
    /************************************************************************************
     * @description Runs AccountNamingBatchController and returns true if the Administrative
     * Account Name Refresh batch job runs successfully else throws an error
     * @return Boolean True if the batch job runs successfully
     ************************************************************************************/
    @AuraEnabled
    public static Boolean runRefreshAdministrativeAccountNamingJob() {
        try {
            Boolean batchJobSuccessful = AccountNamingBatchController.locateAccountNamingService()
                .runRefreshAdministrativeAccountNamingJob();
            return batchJobSuccessful;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /************************************************************************************
     * @description Runs AccountNamingBatchController and returns true if the Household
     * Account Name Refresh batch job runs successfully else throws an error
     * @return Boolean True if the batch job runs successfully
     ************************************************************************************/
    @AuraEnabled
    public static Boolean runRefreshHouseholdAccountNamingJob() {
        try {
            Boolean batchJobSuccessful = AccountNamingBatchController.locateAccountNamingService()
                .runRefreshHouseHoldAccountNamingJob();
            return batchJobSuccessful;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**********************************************************************************
     * @description Locates and returns an instance of AccountNamingService.
     **********************************************************************************/
    @TestVisible
    private static AccountNamingService locateAccountNamingService() {
        return AccountNamingService.getInstance();
    }
}
