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
private with sharing class AccountNamingService_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * AccountNamingService class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        AccountNamingService accountNamingServiceInstance = AccountNamingService.getInstance();
        Test.stopTest();

        System.assertEquals(
            AccountNamingService.instance,
            accountNamingServiceInstance,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            true,
            accountNamingServiceInstance != null,
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * AccountNamingService class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        AccountNamingService accountNamingServiceInstance1 = AccountNamingService.getInstance();

        AccountNamingService accountNamingServiceInstance2 = AccountNamingService.getInstance();
        Test.stopTest();

        System.assertEquals(
            AccountNamingService.instance,
            accountNamingServiceInstance1,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            accountNamingServiceInstance1,
            accountNamingServiceInstance2,
            'Subsequent retrievals of service class instance should return existing instance.'
        );

        System.assertEquals(
            true,
            accountNamingServiceInstance1 != null,
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify runRefreshAdministrativeAccountNamingJob runs succesfully
     ***************************************************************************************************************************/
    @isTest
    private static void runRefreshAdministrativeAccountNamingJobValid() {
        Hierarchy_Settings__c hs = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                Admin_Account_Naming_Format__c = '{!LastName} Administrative'
            )
        );
        insert hs;

        AccountNamingService.instance = new STUB_AdminAccountNamingServiceBatchNotNull();

        Test.startTest();
        Boolean apexJobSuccess = AccountNamingService.getInstance().runRefreshAdministrativeAccountNamingJob();
        Test.stopTest();
        System.assertEquals(true, apexJobSuccess, 'Ensure apex batch job has run successfully');
    }

    /**************************************************************************************************************************
     * @description Test method to verify runRefreshAdministrativeAccountNamingJob thorws an error if batch job fails to run
     ***************************************************************************************************************************/
    @isTest
    private static void runRefreshAdministrativeAccountNamingJobInvalid() {
        AccountNamingService.instance = new STUB_AdminAccountNamingServiceBatchNull();
        try {
            Test.startTest();
            Boolean apexJobSuccess = AccountNamingService.getInstance().runRefreshAdministrativeAccountNamingJob();
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /**************************************************************************************************************************
     * @description Test method to verify runAdministrativeRefreshBatch runs successfully
     ***************************************************************************************************************************/
    @isTest
    private static void runAdministrativeRefreshBatch() {
        Hierarchy_Settings__c hs = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                Admin_Account_Naming_Format__c = '{!LastName} Administrative'
            )
        );
        insert hs;

        ACCT_AdministrativeNameRefresh_BATCH accountRefresh = new ACCT_AdministrativeNameRefresh_BATCH();
        Test.startTest();
        Id batchJobId = AccountNamingService.getInstance().runAdministrativeRefreshBatch(accountRefresh);
        Test.stopTest();
        System.assertNotEquals(null, batchJobId, 'Ensure apex batch job has run successfully');
    }

    /**************************************************************************************************************************
     * @description Test method to verify runRefreshHouseHoldAccountNamingJob runs succesfully
     ***************************************************************************************************************************/
    @isTest
    private static void runRefreshHouseHoldAccountNamingJobValid() {
        Hierarchy_Settings__c hs = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = '{!LastName} ' + Label.DefaultHouseholdName
            )
        );
        insert hs;

        AccountNamingService.instance = new STUB_HHAccountNamingServiceBatchNotNull();

        Test.startTest();
        Boolean apexJobSuccess = AccountNamingService.getInstance().runRefreshHouseHoldAccountNamingJob();
        Test.stopTest();
        System.assertEquals(true, apexJobSuccess, 'Ensure apex batch job has run successfully');
    }

    /**************************************************************************************************************************
     * @description Test method to verify runRefreshHouseHoldAccountNamingJob thorws an error if batch job fails to run
     ***************************************************************************************************************************/
    @isTest
    private static void runRefreshHouseHoldAccountNamingJobInvalid() {
        AccountNamingService.instance = new STUB_HHAccountNamingServiceBatchNull();
        try {
            Test.startTest();
            Boolean apexJobSuccess = AccountNamingService.getInstance().runRefreshHouseHoldAccountNamingJob();
            Test.stopTest();
            System.assert(false, 'should always throw an exception');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /**************************************************************************************************************************
     * @description Test method to verify runHouseholdRefreshBatch runs successfully
     ***************************************************************************************************************************/
    @isTest
    private static void runHouseholdRefreshBatch() {
        Hierarchy_Settings__c hs = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = '{!LastName} ' + Label.DefaultHouseholdName
            )
        );
        insert hs;

        ACCT_HouseholdNameRefresh_BATCH accountRefresh = new ACCT_HouseholdNameRefresh_BATCH();
        Test.startTest();
        Id batchJobId = AccountNamingService.getInstance().runHouseholdRefreshBatch(accountRefresh);
        Test.stopTest();
        System.assertNotEquals(null, batchJobId, 'Ensure apex batch job has run successfully');
    }

    /**************************************************************************************************************************
     ****************************************************** STUB CLASS *********************************************************
     **************************************************************************************************************************/

    /*************************************************************************************************************
     * @description Stub class to simulate the response from AccountNamingService to null for the Administrative
     * Account Naming batch job Id
     */
    private class STUB_AdminAccountNamingServiceBatchNull extends AccountNamingService {
        private override Id runAdministrativeRefreshBatch(ACCT_AdministrativeNameRefresh_BATCH accountRefresh) {
            return null;
        }
    }

    /*******************************************************************************************************************
     * @description Stub class to simulate the response from AccountNamingService to return an Id for the Administrative
     * Account Naming batch job Id
     */
    private class STUB_AdminAccountNamingServiceBatchNotNull extends AccountNamingService {
        private override Id runAdministrativeRefreshBatch(ACCT_AdministrativeNameRefresh_BATCH accountRefresh) {
            return '01217000002Zs0pAAC';
        }
    }

    /*************************************************************************************************************
     * @description Stub class to simulate the response from AccountNamingService to null for the Household Account
     * naming batch job Id
     */
    private class STUB_HHAccountNamingServiceBatchNull extends AccountNamingService {
        private override Id runHouseholdRefreshBatch(ACCT_HouseholdNameRefresh_BATCH accountRefresh) {
            return null;
        }
    }

    /***********************************************************************************************************************
     * @description Stub class to simulate the response from AccountNamingService to return an Id for the Household Account
     * naming batch job Id
     */
    private class STUB_HHAccountNamingServiceBatchNotNull extends AccountNamingService {
        private override Id runHouseholdRefreshBatch(ACCT_HouseholdNameRefresh_BATCH accountRefresh) {
            return '01217000002Zs0pAAC';
        }
    }
}
