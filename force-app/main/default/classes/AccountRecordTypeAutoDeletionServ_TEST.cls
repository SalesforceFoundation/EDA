/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group
* @group-content ../../ApexDocContent/Tests.htm
* @description Test class for AccountRecordTypeAutoDeletionService class.
*/
@isTest
private with sharing class AccountRecordTypeAutoDeletionServ_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * AccountRecordTypeAutoDeletionService class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            AccountRecordTypeAutoDeletionService accountRecordTypeAutoDeletionServiceInstance = 
                AccountRecordTypeAutoDeletionService.getInstance();
        Test.stopTest();

        System.assertEquals(
            AccountRecordTypeAutoDeletionService.instance, 
            accountRecordTypeAutoDeletionServiceInstance, 
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            true, 
            accountRecordTypeAutoDeletionServiceInstance != null, 
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * AccountRecordTypeAutoDeletionService class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            AccountRecordTypeAutoDeletionService accountRecordTypeAutoDeletionServiceInstance1 = 
                AccountRecordTypeAutoDeletionService.getInstance();

            AccountRecordTypeAutoDeletionService accountRecordTypeAutoDeletionServiceInstance2 = 
                AccountRecordTypeAutoDeletionService.getInstance();
        Test.stopTest();

        System.assertEquals(
            AccountRecordTypeAutoDeletionService.instance, 
            accountRecordTypeAutoDeletionServiceInstance1, 
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            accountRecordTypeAutoDeletionServiceInstance1, 
            accountRecordTypeAutoDeletionServiceInstance2, 
            'Subsequent retrievals of service class instance should return existing instance.'
        );

        System.assertEquals(
            true, 
            accountRecordTypeAutoDeletionServiceInstance1 != null, 
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getAccountRecordTypeAutoDeletionModel method returns an AccountRecordTypeAutoDeletionModel
    * populated with a list of strings matching the semi-colon delimited list specifed in Hierarchy Settings.
    ***************************************************************************************************************************/
    @isTest 
    private static void getAccountRecordTypeAutoDeletionModelValid() {
        AccountRecordTypeAutoDeletionMapper.instance = new STUB_AccountRecordTypeAutoDeletionMapper();

        AccountRecordTypeAutoDeletionService accountRecordTypeAutoDeletionServiceInstance = 
                AccountRecordTypeAutoDeletionService.getInstance();

        Test.startTest();
        AccountRecordTypeAutoDeletionModel accountRecordTypeAutoDeletionModel = 
            accountRecordTypeAutoDeletionServiceInstance.getAccountRecordTypeAutoDeletionModel();
        Test.stopTest();

        System.assertEquals(
            'Id1', 
            accountRecordTypeAutoDeletionModel.accountRecordTypeIdsForDeletionWhenOrphanedList[0],
            'Should match value set in stubbed model.'
        );

        System.assertEquals(
            'Id2', 
            accountRecordTypeAutoDeletionModel.accountRecordTypeIdsForDeletionWhenOrphanedList[1],
            'Should match value set in stubbed model.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the locateAccountRecordTypeAutoDeletionMapper method returns an instance of 
    * the AccountRecordTypeAutoDeletionMapper class.
    ***************************************************************************************************************************/
    @isTest 
    private static void locateAccountRecordTypeAutoDeletionMapperValid() {
        AccountRecordTypeAutoDeletionService accountRecordTypeAutoDeletionServiceInstance = 
                AccountRecordTypeAutoDeletionService.getInstance();

        Test.startTest();
        AccountRecordTypeAutoDeletionMapper accountRecordTypeAutoDeletionMapperInstance = 
            accountRecordTypeAutoDeletionServiceInstance.locateAccountRecordTypeAutoDeletionMapper();
        Test.stopTest();

        System.assertEquals(
            AccountRecordTypeAutoDeletionMapper.getInstance(), 
            accountRecordTypeAutoDeletionMapperInstance,
            'Should return an instance of AccountRecordTypeAutoDeletionMapper.');
    }


    /**************************************************************************************************************************
    ****************************************************** STUB CLASS *********************************************************
    **************************************************************************************************************************/

    /*************************************************************************************************************
    * @description Stub class to simulate the response from AccountRecordTypeAutoDeletionMapper to return an 
    * AccountRecordTypeAutoDeletionModel for testing.
    *************************************************************************************************************/
    private class STUB_AccountRecordTypeAutoDeletionMapper extends AccountRecordTypeAutoDeletionMapper {
        public override AccountRecordTypeAutoDeletionModel getAccountRecordTypeAutoDeletionModel() {
            List<String> recordTypeIdsList = new List<String>{
                'Id1',
                'Id2'
            };

            return new AccountRecordTypeAutoDeletionModel(recordTypeIdsList);
        }
    }    
}
