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
 * @description Test class for PreferredPhoneEmailBatchController
 */
@isTest
private with sharing class PreferredPhoneEmailBatchController_TEST {
    /***********************************************************************************************************************************
     * @description Test method to verify that the locatePrefEmailPhoneService method returns instance of locatePrefEmailPhoneService
     ***********************************************************************************************************************************/
    @isTest
    private static void locatePrefEmailPhoneService() {
        Test.startTest();
        SRVC_Contact_PreferredEmail prefEmailPhoneServiceInstance = PreferredPhoneEmailBatchController.locatePrefEmailPhoneService();
        Test.stopTest();

        System.assertEquals(
            SRVC_Contact_PreferredEmail.getInstance(),
            prefEmailPhoneServiceInstance,
            'Should return the instance of SRVC_Contact_PreferredEmail'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify runPreferredPhoneAndEmailCleanupJob method runs successfully
     ***********************************************************************************************************************************/
    @isTest
    private static void runPreferredPhoneAndEmailCleanupJobValid() {
        SRVC_Contact_PreferredEmail.instance = new STUB_PrefEmailPhoneServiceValid();
        Test.startTest();
        Boolean batchJobSuccessful = PreferredPhoneEmailBatchController.runPreferredPhoneAndEmailCleanupJob();
        Test.stopTest();

        System.assertEquals(true, batchJobSuccessful, 'Should return true if the batch job has run successfully');
    }

    /***********************************************************************************************************************************
     * @description Test method to verify runPreferredPhoneAndEmailCleanupJob method throws an error
     ***********************************************************************************************************************************/
    @isTest
    private static void runPreferredPhoneAndEmailCleanupJobError() {
        SRVC_Contact_PreferredEmail.instance = new STUB_PrefEmailPhoneServiceError();
        try {
            Test.startTest();
            Boolean batchJobSuccessful = PreferredPhoneEmailBatchController.runPreferredPhoneAndEmailCleanupJob();
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
     * @description Stub class to simulate the response from SRVC_Contact_PreferredEmail to return a true for runPreferredPhoneAndEmailCleanupJob method .
     **************************************************************************************************************************************************/
    private class STUB_PrefEmailPhoneServiceValid extends SRVC_Contact_PreferredEmail {
        public override Boolean runPreferredPhoneAndEmailCleanupJob() {
            return true;
        }
    }

    /***************************************************************************************************************************************************
     * @description Stub class to simulate the response from SRVC_Contact_PreferredEmail to throw an error for runPreferredPhoneAndEmailCleanupJob method
     ***************************************************************************************************************************************************/
    private class STUB_PrefEmailPhoneServiceError extends SRVC_Contact_PreferredEmail {
        public override Boolean runPreferredPhoneAndEmailCleanupJob() {
            throw new AuraHandledException(Label.BatchJobRunningProblem);
        }
    }
}
