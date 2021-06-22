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
 * @description Test class for ErrorSettingsController
 */
@isTest
private with sharing class AccountNamingBatchController_TEST {
    /***********************************************************************************************************************************
     * @description Test method to verify that the locateAccountNamingService method returns instance of locateAccountNamingService
     ***********************************************************************************************************************************/
    @isTest
    private static void locateAccountNamingService() {
        Test.startTest();
        AccountNamingService accountNamingServiceInstance = AccountNamingBatchController.locateAccountNamingService();
        Test.stopTest();

        System.assertEquals(
            AccountNamingService.getInstance(),
            accountNamingServiceInstance,
            'Should return the instance of AccountNamingService'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify runRefreshAdministrativeAccountNamingJob method runs successfully
     ***********************************************************************************************************************************/
    @isTest
    private static void runRefreshAdministrativeAccountNamingJobValid() {
        AccountNamingService.instance = new STUB_AdminAccountNamingServiceValid();
        Test.startTest();
        Boolean batchJobSuccessful = AccountNamingBatchController.runRefreshAdministrativeAccountNamingJob();
        Test.stopTest();

        System.assertEquals(true, batchJobSuccessful, 'Should return true if the batch job has run successfully');
    }

    /***********************************************************************************************************************************
     * @description Test method to verify runRefreshAdministrativeAccountNamingJob method throws an error
     ***********************************************************************************************************************************/
    @isTest
    private static void runRefreshAdministrativeAccountNamingJobError() {
        AccountNamingService.instance = new STUB_AdminAccountNamingServiceError();
        try {
            Test.startTest();
            Boolean batchJobSuccessful = AccountNamingBatchController.runRefreshAdministrativeAccountNamingJob();
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /***********************************************************************************************************************************
     * @description Test method to verify runRefreshHouseholdAccountNamingJob method runs successfully
     ***********************************************************************************************************************************/
    @isTest
    private static void runRefreshHouseholdAccountNamingJobValid() {
        AccountNamingService.instance = new STUB_HHAccountNamingServiceValid();
        Test.startTest();
        Boolean batchJobSuccessful = AccountNamingBatchController.runRefreshHouseholdAccountNamingJob();
        Test.stopTest();

        System.assertEquals(true, batchJobSuccessful, 'Should return true if the batch job has run successfully');
    }

    /***********************************************************************************************************************************
     * @description Test method to verify runRefreshHouseholdAccountNamingJob method throws an error
     ***********************************************************************************************************************************/
    @isTest
    private static void runRefreshHouseholdAccountNamingJobError() {
        AccountNamingService.instance = new STUB_HHAccountNamingServiceError();
        try {
            Test.startTest();
            Boolean batchJobSuccessful = AccountNamingBatchController.runRefreshHouseholdAccountNamingJob();
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
     * @description Stub class to simulate the response from AccountNamingService to return a true for runRefreshAdministrativeAccountNamingJob method .
     **************************************************************************************************************************************************/
    private class STUB_AdminAccountNamingServiceValid extends AccountNamingService {
        public override Boolean runRefreshAdministrativeAccountNamingJob() {
            return true;
        }
    }

    /***************************************************************************************************************************************************
     * @description Stub class to simulate the response from AccountNamingService to throw an error for runRefreshAdministrativeAccountNamingJob method
     ***************************************************************************************************************************************************/
    private class STUB_AdminAccountNamingServiceError extends AccountNamingService {
        public override Boolean runRefreshAdministrativeAccountNamingJob() {
            throw new AuraHandledException(Label.BatchJobRunningProblem);
        }
    }

    /******************************************************************************************************************************************
     * @description Stub class to simulate the response from AccountNamingService to return true for runRefreshHouseHoldAccountNamingJob method.
     ******************************************************************************************************************************************/
    private class STUB_HHAccountNamingServiceValid extends AccountNamingService {
        public override Boolean runRefreshHouseHoldAccountNamingJob() {
            return true;
        }
    }

    /**********************************************************************************************************************************************
     * @description Stub class to simulate the response from AccountNamingService to throw an error for runRefreshHouseHoldAccountNamingJob method.
     **********************************************************************************************************************************************/
    private class STUB_HHAccountNamingServiceError extends AccountNamingService {
        public override Boolean runRefreshHouseHoldAccountNamingJob() {
            throw new AuraHandledException(Label.BatchJobRunningProblem);
        }
    }
}
