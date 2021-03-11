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
* @description Test class for AccountModelSettingsVMapper class
*/
@isTest
public with sharing class AccountModelSettingsVMapper_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * AccountModelSettingsVMapper class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            AccountModelSettingsVMapper accountModelSettingsVMapperInstance = AccountModelSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            AccountModelSettingsVMapper.instance, 
            accountModelSettingsVMapperInstance, 
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            true, 
            accountModelSettingsVMapperInstance != null, 
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * AccountModelSettingsVMapper class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            AccountModelSettingsVMapper accountModelSettingsVMapperInstance1 = AccountModelSettingsVMapper.getInstance();
            AccountModelSettingsVMapper accountModelSettingsVMapperInstance2 = AccountModelSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            AccountModelSettingsVMapper.instance, 
            accountModelSettingsVMapperInstance1, 
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            accountModelSettingsVMapperInstance1, 
            accountModelSettingsVMapperInstance2, 
            'Subsequent retrievals of service class instance should return existing instance.'
        );

        System.assertEquals(
            true, 
            accountModelSettingsVMapperInstance1 != null, 
            'Instance of service class should not be null.'
        );
    }

    /***********************************************************************************************************************************
    * @description Test method to verify that the locateAccountModelSettingsService method returns instance of AccountModelSettingsMapper
    ***********************************************************************************************************************************/
    @isTest
    private static void locateAccountModelSettingsServiceValid() {
        AccountModelSettingsVMapper accountModelSettingsVMapperInstance = AccountModelSettingsVMapper.getInstance();

        Test.startTest();
        AccountModelSettingsService accountModelSettingsServiceInstance = accountModelSettingsVMapperInstance.locateAccountModelSettingsService();
        Test.stopTest();

        System.assertEquals(
            AccountModelSettingsService.getInstance(), 
            accountModelSettingsServiceInstance, 
            'Should return the instance of AccountModelSettingsService'
        );
    }

    /***********************************************************************************************************************************
    * @description Test method to verify that the locateAccountRecordTypeAutoDeletionService method returns instance of 
    * AccountRecordTypeAutoDeletionService
    ***********************************************************************************************************************************/
    @isTest
    private static void locateAccountRecordTypeAutoDeletionServiceValid() {
        AccountModelSettingsVMapper accountModelSettingsVMapperInstance = AccountModelSettingsVMapper.getInstance();

        Test.startTest();
        AccountRecordTypeAutoDeletionService accountRecordTypeAutoDeletionServiceInstance = 
            accountModelSettingsVMapperInstance.locateAccountRecordTypeAutoDeletionService();
        Test.stopTest();

        System.assertEquals(
            AccountRecordTypeAutoDeletionService.getInstance(), 
            accountRecordTypeAutoDeletionServiceInstance, 
            'Should return the instance of AccountModelSettingsService'
        );
    }

    /***********************************************************************************************************************************
    * @description Test method to verify that the locateRecordTypeService method returns instance of RecordTypeService
    ***********************************************************************************************************************************/
    @isTest
    private static void locateRecordTypeServiceValid() {
        AccountModelSettingsVMapper accountModelSettingsVMapperInstance = AccountModelSettingsVMapper.getInstance();

        Test.startTest();
        RecordTypeService recordTypeServiceInstance = accountModelSettingsVMapperInstance.locateRecordTypeService();
        Test.stopTest();

        System.assertEquals(
            RecordTypeService.getInstance(), 
            recordTypeServiceInstance, 
            'Should return the instance of RecordTypeService'
        );
    }
}

