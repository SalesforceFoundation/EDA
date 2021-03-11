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
* @description Test class for AccountRecordTypeAutoDeletionMapper class.
*/
@isTest
private with sharing class AccountRecordTypeAutoDeletionMapper_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * AccountRecordTypeAutoDeletionMapper class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            AccountRecordTypeAutoDeletionMapper accountRecordTypeAutoDeletionMapperInstance = 
                AccountRecordTypeAutoDeletionMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            AccountRecordTypeAutoDeletionMapper.instance, 
            accountRecordTypeAutoDeletionMapperInstance, 
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            true, 
            accountRecordTypeAutoDeletionMapperInstance != null, 
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * AccountRecordTypeAutoDeletionMapper class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            AccountRecordTypeAutoDeletionMapper accountRecordTypeAutoDeletionMapperInstance1 = 
                AccountRecordTypeAutoDeletionMapper.getInstance();

            AccountRecordTypeAutoDeletionMapper accountRecordTypeAutoDeletionMapperInstance2 = 
                AccountRecordTypeAutoDeletionMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            AccountRecordTypeAutoDeletionMapper.instance, 
            accountRecordTypeAutoDeletionMapperInstance1, 
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            accountRecordTypeAutoDeletionMapperInstance1, 
            accountRecordTypeAutoDeletionMapperInstance2, 
            'Subsequent retrievals of service class instance should return existing instance.'
        );

        System.assertEquals(
            true, 
            accountRecordTypeAutoDeletionMapperInstance1 != null, 
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getAccountRecordTypeAutoDeletionModel method correctly returns a list of
    * Ids corresponding to those specified by the semi-colon delimited list in Hierarchy Settings.
    ***************************************************************************************************************************/
    @isTest
    private static void getAccountRecordTypeAutoDeletionModelValid() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Accounts_to_Delete__c = 'Id1;Id2;Id3; Id4; Id5'
            )
        );

        AccountRecordTypeAutoDeletionMapper accountRecordTypeAutoDeletionMapperInstance = 
                AccountRecordTypeAutoDeletionMapper.getInstance();

        Test.startTest();
        AccountRecordTypeAutoDeletionModel accountRecordTypeAutoDeletionModel = 
            accountRecordTypeAutoDeletionMapperInstance.getAccountRecordTypeAutoDeletionModel();
        Test.stopTest();

        for (Integer i = 0; i<5; i++) {
            System.assertEquals(
                'Id' + (i+1), 
                accountRecordTypeAutoDeletionModel.accountRecordTypeIdsForDeletionWhenOrphanedList[i],
                'Id in list should match value at location ' + (i+1) + ' in semi-colon delimited list in hierarchy settings.'
            );
        }        
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getAccountRecordTypeAutoDeletionModel method correctly returns an empty list
    * Ids when there are no Account Record Types marked for deletion in Hierarchy Settings.
    ***************************************************************************************************************************/
    @isTest
    private static void getAccountRecordTypeAutoDeletionModelEmpty() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Accounts_to_Delete__c = null
            )
        );

        AccountRecordTypeAutoDeletionMapper accountRecordTypeAutoDeletionMapperInstance = 
                AccountRecordTypeAutoDeletionMapper.getInstance();

        Test.startTest();
        AccountRecordTypeAutoDeletionModel accountRecordTypeAutoDeletionModel = 
            accountRecordTypeAutoDeletionMapperInstance.getAccountRecordTypeAutoDeletionModel();
        Test.stopTest();

        System.assertEquals(
            0,
            accountRecordTypeAutoDeletionModel.accountRecordTypeIdsForDeletionWhenOrphanedList.size(),
            'accountRecordTypeAutoDeletionModel should contain an empty list of Strings.'
        );     
    }
}
