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
* @description Test class for AccountModelHealthCheckVMapper.
*/
@isTest
public with sharing class AccountModelHealthCheckVMapper_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * AccountModelHealthCheckVMapper class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            AccountModelHealthCheckVMapper accountModelHealthCheckVMapperInstance = AccountModelHealthCheckVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(AccountModelHealthCheckVMapper.instance, accountModelHealthCheckVMapperInstance, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(true, accountModelHealthCheckVMapperInstance != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * AccountModelHealthCheckVMapper class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            AccountModelHealthCheckVMapper accountModelHealthCheckVMapperInstance1 = AccountModelHealthCheckVMapper.getInstance();
            AccountModelHealthCheckVMapper accountModelHealthCheckVMapperInstance2 = AccountModelHealthCheckVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(AccountModelHealthCheckVMapper.instance, accountModelHealthCheckVMapperInstance1, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(accountModelHealthCheckVMapperInstance1, accountModelHealthCheckVMapperInstance2, 'Subsequent retrievals of mapper class instance should return existing instance.');
        System.assertEquals(true, accountModelHealthCheckVMapperInstance1 != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test to verify locateRecordTypeService() returns an instance of the RecordTypeService class.
    **************************************************************************************************************************/ 
    @isTest
    private static void locateRecordTypeServiceValid(){
        Test.startTest();
        RecordTypeService rtServiceInstance = AccountModelHealthCheckVMapper.getInstance().locateRecordTypeService();
        Test.stopTest();

        System.assertEquals(RecordTypeService.getInstance(), rtServiceInstance, 'Should return instance of RecordTypeService class.');
        System.assertEquals(true, rtServiceInstance != null, 'Instance of RecordTypeService class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test to verify locateAccountModelSettingsService() returns an instance of the AccountModelSettingsService class.
    **************************************************************************************************************************/ 
    @isTest
    private static void locateAccountModelSettingsServiceValid(){
        Test.startTest();
        AccountModelSettingsService accModSettingsServiceInstance = AccountModelHealthCheckVMapper.getInstance().locateAccountModelSettingsService();
        Test.stopTest();

        System.assertEquals(AccountModelSettingsService.getInstance(), accModSettingsServiceInstance, 'Should return instance of AccountModelSettingsService class.');
        System.assertEquals(true, accModSettingsServiceInstance != null, 'Instance of AccountModelSettingsService class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test to verify locateStringHandlingService() returns an instance of the StringHandlingService class.
    **************************************************************************************************************************/ 
    @isTest
    private static void locateStringHandlingServiceValid(){
        Test.startTest();
        StringHandlingService stringHandlingServiceInstance = AccountModelHealthCheckVMapper.getInstance().locateStringHandlingService();
        Test.stopTest();

        System.assertEquals(StringHandlingService.getInstance(), stringHandlingServiceInstance, 'Should return instance of StringHandlingService class.');
        System.assertEquals(true, stringHandlingServiceInstance != null, 'Instance of StringHandlingService class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test to verify combineAccountHealthCheckGroupViewModels() returns a combined HealthCheckGroupVModel comprised of
    * the combined properties of the group view models passed as arguments.
    **************************************************************************************************************************/ 
    @isTest 
    private static void combineAccountHealthCheckGroupViewModelsValid(){

        List<HealthCheckGroupVModel> testHealthCheckGroupModelsList = new List<HealthCheckGroupVModel>();
        List<HealthCheckItemVModel> group1HealthCheckItemList = new List<HealthCheckItemVModel>();

        group1HealthCheckItemList.add(new HealthCheckItemVModel('Key1',
                                                            'Setting-X',
                                                            'Pass',
                                                            'PassedLabel',
                                                            'Description',
                                                            'RecommendedFix',
                                                            new List<HealthCheckItemVModel>()));
                                                            
        group1HealthCheckItemList.add(new HealthCheckItemVModel('Key2',
                                                            'Setting-B',
                                                            'Pass',
                                                            'PassedLabel',
                                                            'Description',
                                                            'RecommendedFix',
                                                            new List<HealthCheckItemVModel>()));

        group1HealthCheckItemList.add(new HealthCheckItemVModel('Key3',
                                                            'Setting-Y',
                                                            'Fail',
                                                            'FailedLabel',
                                                            'Description',
                                                            'RecommendedFix',
                                                            new List<HealthCheckItemVModel>()));


        testHealthCheckGroupModelsList.add(new HealthCheckGroupVModel('SubGroup1',
                                                                 'Fail',
                                                                 2,
                                                                 3,
                                                                 new List<String>(),
                                                                 group1HealthCheckItemList));

        testHealthCheckGroupModelsList.add(new HealthCheckGroupVModel('SubGroup2',
                                                                 'Pass',
                                                                 1,
                                                                 1,
                                                                 new List<String>(),
                                                                 new List<HealthCheckItemVModel>()));


        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModel = AccountModelHealthCheckVMapper.getInstance().combineAccountHealthCheckGroupViewModels(testHealthCheckGroupModelsList);
        Test.stopTest();

        System.assertEquals(Label.stgHealthCheckAccountModel, healthCheckGroupVModel.label, 'Group label should be \'' + Label.stgHealthCheckAccountModel + '\'');
        System.assertEquals(Label.stgHealthCheckStatusFailed, healthCheckGroupVModel.status, 'Group status should be \'' + Label.stgHealthCheckStatusFailed + '\'');
        System.assertEquals(3, healthCheckGroupVModel.passedChecks, 'Group passed checks should be \'' + healthCheckGroupVModel.passedChecks + '\'');
        System.assertEquals(4, healthCheckGroupVModel.totalChecks, 'Group total checks should be \'' + healthCheckGroupVModel.totalChecks + '\'');
        System.assertEquals(3, healthCheckGroupVModel.healthCheckItemList.size(), 'Group HealthCheckItems list should have \'' + healthCheckGroupVModel.healthCheckItemList.size() + '\' items');

        System.assertEquals('Setting-Y', healthCheckGroupVModel.healthCheckItemList[0].setting, 'HealthCheckItemList should be sorted alphabetically by Setting, with Failed items prioritized.');
        System.assertEquals('Setting-B', healthCheckGroupVModel.healthCheckItemList[1].setting, 'HealthCheckItemList should be sorted alphabetically by Setting, with Failed items prioritized.');
        System.assertEquals('Setting-X', healthCheckGroupVModel.healthCheckItemList[2].setting, 'HealthCheckItemList should be sorted alphabetically by Setting, with Failed items prioritized.');
    }

    /**************************************************************************************************************************
    * @description Test to verify getDefaultAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * pass when the ID provided as the defaultAccountModel Id in AccountSettingsModel is valid and matches to a RT for Default 
    * Account Modelthat is valid and active.
    **************************************************************************************************************************/ 
    @isTest
    private static void getDefaultAccountModelHealthCheckItemsIdMatchFoundToRTValidAndActive(){
        RecordTypeService.instance = new STUB_RecordTypeServiceValidAndActiveDefaultModel();

        AccountModelSettingsModel accountModelSettingsModel = new AccountModelSettingsModel('000000000000000001',
                                                                                '000000000000000002',
                                                                                '000000000000000003');

        RecordTypeModel recordTypeModel = new RecordTypeModel('000000000000000001',
                                                              'Test Record Name',
                                                              'testRecordDevName',
                                                              true);
                          
        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{recordTypeModel.id => recordTypeModel};

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModel = 
            AccountModelHealthCheckVMapper.getInstance().getDefaultAccountModelHealthCheckItems(accountModelSettingsModel, recordTypeModelsById);
        Test.stopTest();

        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions(Label.stgHealthCheckAccountModel,
                                                                                   Label.stgHealthCheckStatusPassed,
                                                                                   1,
                                                                                   1,
                                                                                   0,
                                                                                   1,
                                                                                   healthCheckGroupVModel);

        String expectedDescription = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCRecordTypeValid, 
            new List<Object>{'Test Record Name', 'testRecordDevName'}
        );
        String expectedFix = Label.stgHealthCheckFixNotApplicable;

        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgAccModelTitle, 
                                                                                'Pass', 
                                                                                Label.stgHealthCheckStatusPassed, 
                                                                                expectedDescription, 
                                                                                expectedFix, 
                                                                                healthCheckGroupVModel.healthCheckItemList);
    }

    /**************************************************************************************************************************
    * @description Test to verify getDefaultAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * fail when the ID provided as the defaultAccountModel Id in AccountSettingsModel is valid and matches to a RT for Default 
    * Account Modelthat is valid, but inactive.
    **************************************************************************************************************************/ 
    @isTest
    private static void getDefaultAccountModelHealthCheckItemsIdMatchFoundToRTValidAndInactive(){
        RecordTypeService.instance = new STUB_RecordTypeServiceValidAndInactiveDefaultModel();

        AccountModelSettingsModel accountModelSettingsModel = new AccountModelSettingsModel('000000000000000001',
                                                                                            '000000000000000002',
                                                                                            '000000000000000003');

        RecordTypeModel recordTypeModel = new RecordTypeModel('000000000000000001',
                                                              'Test Record Name',
                                                              'testRecordDevName',
                                                              false);

        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{recordTypeModel.id => recordTypeModel};

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModel = 
            AccountModelHealthCheckVMapper.getInstance().getDefaultAccountModelHealthCheckItems(accountModelSettingsModel, recordTypeModelsById);
        Test.stopTest();

        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions(Label.stgHealthCheckAccountModel,
                                                                                   Label.stgHealthCheckStatusFailed,
                                                                                   0,
                                                                                   1,
                                                                                   0,
                                                                                   1,
                                                                                   healthCheckGroupVModel);

        String expectedDescription = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCRecordTypeInactive, 
            new List<Object>{'Test Record Name', 'testRecordDevName'}
        );
        String expectedFix = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCAccountModelDefaultInactiveFix, 
            new List<Object>{'Test Record Name', 'testRecordDevName'}
        );

        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgAccModelTitle, 
                                                                                'Fail', 
                                                                                Label.stgHealthCheckStatusFailed, 
                                                                                expectedDescription, 
                                                                                expectedFix, 
                                                                                healthCheckGroupVModel.healthCheckItemList);
    }

    /**************************************************************************************************************************
    * @description Test to verify getDefaultAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * fail when an the ID provided as the defaultAccountModel Id in AccountSettingsModel is not an ID.
    **************************************************************************************************************************/ 
    @isTest
    private static void getDefaultAccountModelHealthCheckItemsInvalidDefaultId(){
        RecordTypeService.instance = new STUB_RecordTypeServiceNullModel();

        AccountModelSettingsModel accountModelSettingsModel = new AccountModelSettingsModel('Not an ID default acct',
                                                                                            'Not an ID admin acct',
                                                                                            'Not an Id HH acct');

        RecordTypeModel recordTypeModel = new RecordTypeModel('000000000000000111',
                                                              'Account Name',
                                                              'accountDevName',
                                                              true);

        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{recordTypeModel.id => recordTypeModel};

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModel = 
            AccountModelHealthCheckVMapper.getInstance().getDefaultAccountModelHealthCheckItems(accountModelSettingsModel, recordTypeModelsById);
        Test.stopTest();

        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions(Label.stgHealthCheckAccountModel,
                                                                                   Label.stgHealthCheckStatusFailed,
                                                                                   0,
                                                                                   1,
                                                                                   0,
                                                                                   1,
                                                                                   healthCheckGroupVModel);

        String expectedDescription = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCRecordTypeNotFound, 
            new List<Object>{'Not an ID default acct'}
        );
        String expectedFix = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCAccountModelDefaultNotFoundFix, 
            new List<Object>{'Not an ID default acct'}
        );

        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgAccModelTitle, 
                                                                                'Fail', 
                                                                                Label.stgHealthCheckStatusFailed, 
                                                                                expectedDescription, 
                                                                                expectedFix, 
                                                                                healthCheckGroupVModel.healthCheckItemList);
    }

    /**************************************************************************************************************************
    * @description Test to verify getDefaultAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * fail when an invalid RT is specified for Default Account Model and the defaultAccountModel Id in AccountSettingsModel is a
    * valid ID, but does not match any Ids in the RecordType map.
    **************************************************************************************************************************/ 
    @isTest
    private static void getDefaultAccountModelHealthCheckItemsValidIdNoMatchingRT(){
        RecordTypeService.instance = new STUB_RecordTypeServiceNullModel();

        AccountModelSettingsModel accountModelSettingsModel = new AccountModelSettingsModel('000000000000000000',
                                                                                            '000000000000000000',
                                                                                            '000000000000000000');

        RecordTypeModel recordTypeModel = new RecordTypeModel('000000000000000123',
                                                              'Different Account Name',
                                                              'differentAccountDevName',
                                                              true);

        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{recordTypeModel.id => recordTypeModel};

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModel = 
            AccountModelHealthCheckVMapper.getInstance().getDefaultAccountModelHealthCheckItems(accountModelSettingsModel, recordTypeModelsById);
        Test.stopTest();

        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions(Label.stgHealthCheckAccountModel,
                                                                                   Label.stgHealthCheckStatusFailed,
                                                                                   0,
                                                                                   1,
                                                                                   0,
                                                                                   1,
                                                                                   healthCheckGroupVModel);

        String expectedDescription = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCRecordTypeNotFound, 
            new List<Object>{'000000000000000000'}
        );
        String expectedFix = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCAccountModelDefaultNotFoundFix, 
            new List<Object>{'000000000000000000'}
        );

        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgAccModelTitle, 
                                                                                'Fail', 
                                                                                Label.stgHealthCheckStatusFailed, 
                                                                                expectedDescription, 
                                                                                expectedFix, 
                                                                                healthCheckGroupVModel.healthCheckItemList);
    }

    /**************************************************************************************************************************
    * @description Test to verify getAdministrativeAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * pass when the ID provided as the administrative AccountModel Id in AccountSettingsModel is valid and matches to a RT for Admin 
    * Account Modelthat is valid and active.
    **************************************************************************************************************************/ 
    @isTest
    private static void getAdministrativeAccountModelHealthCheckItemsIdMatchFoundToRTValidAndActive(){
        RecordTypeService.instance = new STUB_RecordTypeServiceValidAndActiveDefaultModel();

        AccountModelSettingsModel accountModelSettingsModel = new AccountModelSettingsModel('000000000000000001',
                                                                                            '000000000000000002',
                                                                                            '000000000000000003');

        RecordTypeModel recordTypeModel = new RecordTypeModel('000000000000000002',
                                                              'Test Record Name',
                                                              'testRecordDevName',
                                                              true);
                          
        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{recordTypeModel.id => recordTypeModel};

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModel = 
            AccountModelHealthCheckVMapper.getInstance().getAdministrativeAccountModelHealthCheckItems(accountModelSettingsModel, recordTypeModelsById);
        Test.stopTest();

        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions(Label.stgHealthCheckAccountModel,
                                                                                   Label.stgHealthCheckStatusPassed,
                                                                                   1,
                                                                                   1,
                                                                                   0,
                                                                                   1,
                                                                                   healthCheckGroupVModel);

        String expectedDescription = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCRecordTypeValid, 
            new List<Object>{'Test Record Name', 'testRecordDevName'}
        );
        String expectedFix = Label.stgHealthCheckFixNotApplicable;
        
        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgAdminAccountRecordType, 
                                                                                'Pass', 
                                                                                Label.stgHealthCheckStatusPassed, 
                                                                                expectedDescription, 
                                                                                expectedFix, 
                                                                                healthCheckGroupVModel.healthCheckItemList);
    }

    /**************************************************************************************************************************
    * @description Test to verify getAdministrativeAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * fail when the ID provided as the administrativeAccountModel Id in AccountSettingsModel is valid and matches to a RT for Admin 
    * Account Modelthat is valid, but inactive.
    **************************************************************************************************************************/ 
    @isTest
    private static void getAdministrativeAccountModelHealthCheckItemsIdMatchFoundToRTValidAndInactive(){
        RecordTypeService.instance = new STUB_RecordTypeServiceValidAndInactiveDefaultModel();

        AccountModelSettingsModel accountModelSettingsModel = new AccountModelSettingsModel('000000000000000001',
                                                                                            '000000000000000002',
                                                                                            '000000000000000003');

        RecordTypeModel recordTypeModel = new RecordTypeModel('000000000000000002',
                                                              'Test Record Name',
                                                              'testRecordDevName',
                                                              false);

        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{recordTypeModel.id => recordTypeModel};

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModel = 
            AccountModelHealthCheckVMapper.getInstance().getAdministrativeAccountModelHealthCheckItems(accountModelSettingsModel, recordTypeModelsById);
        Test.stopTest();

        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions(Label.stgHealthCheckAccountModel,
                                                                                   Label.stgHealthCheckStatusFailed,
                                                                                   0,
                                                                                   1,
                                                                                   0,
                                                                                   1,
                                                                                   healthCheckGroupVModel);

        String expectedDescription = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCRecordTypeInactive, 
            new List<Object>{'Test Record Name', 'testRecordDevName'}
        );
        String expectedFix = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCAccountModelAdminInactiveFix, 
            new List<Object>{'Test Record Name', 'testRecordDevName'}
        );
        
        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgAdminAccountRecordType, 
                                                                                'Fail', 
                                                                                Label.stgHealthCheckStatusFailed, 
                                                                                expectedDescription, 
                                                                                expectedFix, 
                                                                                healthCheckGroupVModel.healthCheckItemList);
    }

    /**************************************************************************************************************************
    * @description Test to verify getAdministrativeAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * fail when an the ID provided as the administrativeAccountModel Id in AccountSettingsModel is not an ID.
    **************************************************************************************************************************/ 
    @isTest
    private static void getAdministrativeAccountModelHealthCheckItemsInvalidDefaultId(){
        RecordTypeService.instance = new STUB_RecordTypeServiceNullModel();

        AccountModelSettingsModel accountModelSettingsModel = new AccountModelSettingsModel('Not an ID default acct',
                                                                                            'Not an ID admin acct',
                                                                                            'Not an Id HH acct');

        RecordTypeModel recordTypeModel = new RecordTypeModel('000000000000000111',
                                                              'Account Name',
                                                              'accountDevName',
                                                              true);

        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{recordTypeModel.id => recordTypeModel};

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModel = 
            AccountModelHealthCheckVMapper.getInstance().getAdministrativeAccountModelHealthCheckItems(accountModelSettingsModel, recordTypeModelsById);
        Test.stopTest();

        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions(Label.stgHealthCheckAccountModel,
                                                                                   Label.stgHealthCheckStatusFailed,
                                                                                   0,
                                                                                   1,
                                                                                   0,
                                                                                   1,
                                                                                   healthCheckGroupVModel);

        String expectedDescription = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCRecordTypeNotFound, 
            new List<Object>{'Not an ID admin acct'}
        );
        String expectedFix = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCAccountModelAdminNotFoundFix, 
            new List<Object>{'Not an ID admin acct'}
        );
        
        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgAdminAccountRecordType, 
                                                                                'Fail', 
                                                                                Label.stgHealthCheckStatusFailed, 
                                                                                expectedDescription, 
                                                                                expectedFix, 
                                                                                healthCheckGroupVModel.healthCheckItemList);
    }

    /**************************************************************************************************************************
    * @description Test to verify getAdministrativeAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * fail when an invalid RT is specified for Administrative Account Model and the adminAccountModel Id in AccountSettingsModel is a
    * valid ID, but does not match any Ids in the RecordType map.
    **************************************************************************************************************************/ 
    @isTest
    private static void getAdministrativeAccountModelHealthCheckItemsValidIdNoMatchingRT(){
        RecordTypeService.instance = new STUB_RecordTypeServiceNullModel();

        AccountModelSettingsModel accountModelSettingsModel = new AccountModelSettingsModel('000000000000000000',
                                                                                            '000000000000000000',
                                                                                            '000000000000000000');

        RecordTypeModel recordTypeModel = new RecordTypeModel('000000000000000123',
                                                              'Different Account Name',
                                                              'differentAccountDevName',
                                                              true);

        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{recordTypeModel.id => recordTypeModel};

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModel = 
            AccountModelHealthCheckVMapper.getInstance().getAdministrativeAccountModelHealthCheckItems(accountModelSettingsModel, recordTypeModelsById);
        Test.stopTest();

        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions(Label.stgHealthCheckAccountModel,
                                                                                   Label.stgHealthCheckStatusFailed,
                                                                                   0,
                                                                                   1,
                                                                                   0,
                                                                                   1,
                                                                                   healthCheckGroupVModel);

        String expectedDescription = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCRecordTypeNotFound, 
            new List<Object>{'000000000000000000'}
        );
        String expectedFix = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCAccountModelAdminNotFoundFix, 
            new List<Object>{'000000000000000000'}
        );
        
        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgAdminAccountRecordType, 
                                                                                'Fail', 
                                                                                Label.stgHealthCheckStatusFailed, 
                                                                                expectedDescription, 
                                                                                expectedFix, 
                                                                                healthCheckGroupVModel.healthCheckItemList);
    }

    /**************************************************************************************************************************
    * @description Test to verify getHouseholdAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * pass when the ID provided as the household AccountModel Id in AccountSettingsModel is valid and matches to a RT for HH 
    * Account Modelthat is valid and active.
    **************************************************************************************************************************/ 
    @isTest
    private static void getHouseholdAccountModelHealthCheckItemsIdMatchFoundToRTValidAndActive(){
        RecordTypeService.instance = new STUB_RecordTypeServiceValidAndActiveDefaultModel();

        AccountModelSettingsModel accountModelSettingsModel = new AccountModelSettingsModel('000000000000000001',
                                                                                            '000000000000000002',
                                                                                            '000000000000000003');

        RecordTypeModel recordTypeModel = new RecordTypeModel('000000000000000003',
                                                              'Test Record Name',
                                                              'testRecordDevName',
                                                              true);
                          
        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{recordTypeModel.id => recordTypeModel};

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModel = 
            AccountModelHealthCheckVMapper.getInstance().getHouseholdAccountModelHealthCheckItems(accountModelSettingsModel, recordTypeModelsById);
        Test.stopTest();

        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions(Label.stgHealthCheckAccountModel,
                                                                                   Label.stgHealthCheckStatusPassed,
                                                                                   1,
                                                                                   1,
                                                                                   0,
                                                                                   1,
                                                                                   healthCheckGroupVModel);

        String expectedDescription = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCRecordTypeValid, 
            new List<Object>{'Test Record Name', 'testRecordDevName'}
        );
        String expectedFix = Label.stgHealthCheckFixNotApplicable;
        
        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgAccountRecordTypeSupportsHHAddress, 
                                                                                'Pass', 
                                                                                Label.stgHealthCheckStatusPassed, 
                                                                                expectedDescription, 
                                                                                expectedFix, 
                                                                                healthCheckGroupVModel.healthCheckItemList);
    }

    /**************************************************************************************************************************
    * @description Test to verify getHouseholdAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * fail when the ID provided as the householdAccountModel Id in AccountSettingsModel is valid and matches to a RT for HH 
    * Account Model that is valid, but inactive.
    **************************************************************************************************************************/ 
    @isTest
    private static void getHouseholdAccountModelHealthCheckItemsIdMatchFoundToRTValidAndInactive(){
        RecordTypeService.instance = new STUB_RecordTypeServiceValidAndInactiveDefaultModel();

        AccountModelSettingsModel accountModelSettingsModel = new AccountModelSettingsModel('000000000000000001',
                                                                                            '000000000000000002',
                                                                                            '000000000000000003');

        RecordTypeModel recordTypeModel = new RecordTypeModel('000000000000000003',
                                                              'Test HH Record Name',
                                                              'testHHRecordDevName',
                                                              false);

        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{recordTypeModel.id => recordTypeModel};

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModel = 
            AccountModelHealthCheckVMapper.getInstance().getHouseholdAccountModelHealthCheckItems(accountModelSettingsModel, recordTypeModelsById);
        Test.stopTest();

        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions(Label.stgHealthCheckAccountModel,
                                                                                   Label.stgHealthCheckStatusFailed,
                                                                                   0,
                                                                                   1,
                                                                                   0,
                                                                                   1,
                                                                                   healthCheckGroupVModel);

        String expectedDescription = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCRecordTypeInactive, 
            new List<Object>{'Test Record Name', 'testRecordDevName'}
        );
        String expectedFix = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCAccountModelHHInactiveFix, 
            new List<Object>{'Test Record Name', 'testRecordDevName'}
        );
        
        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgAccountRecordTypeSupportsHHAddress, 
                                                                                'Fail', 
                                                                                Label.stgHealthCheckStatusFailed, 
                                                                                expectedDescription, 
                                                                                expectedFix, 
                                                                                healthCheckGroupVModel.healthCheckItemList);
    }

    /**************************************************************************************************************************
    * @description Test to verify getHouseholdAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * fail when an the ID provided as the administrativeAccountModel Id in AccountSettingsModel is not an ID.
    **************************************************************************************************************************/ 
    @isTest
    private static void getHouseholdAccountModelHealthCheckItemsInvalidDefaultId(){
        RecordTypeService.instance = new STUB_RecordTypeServiceNullModel();

        AccountModelSettingsModel accountModelSettingsModel = new AccountModelSettingsModel('Not an ID default acct',
                                                                                            'Not an ID admin acct',
                                                                                            'Not an ID HH acct');

        RecordTypeModel recordTypeModel = new RecordTypeModel('000000000000000111',
                                                              'Account Name',
                                                              'accountDevName',
                                                              true);

        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{recordTypeModel.id => recordTypeModel};

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModel = 
            AccountModelHealthCheckVMapper.getInstance().getHouseholdAccountModelHealthCheckItems(accountModelSettingsModel, recordTypeModelsById);
        Test.stopTest();

        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions(Label.stgHealthCheckAccountModel,
                                                                                   Label.stgHealthCheckStatusFailed,
                                                                                   0,
                                                                                   1,
                                                                                   0,
                                                                                   1,
                                                                                   healthCheckGroupVModel);

        String expectedDescription = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCRecordTypeNotFound, 
            new List<Object>{'Not an ID HH acct'}
        );
        String expectedFix = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCAccountModelHHNotFoundFix, 
            new List<Object>{'Not an ID HH acct'}
        );
        
        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgAccountRecordTypeSupportsHHAddress, 
                                                                                'Fail', 
                                                                                Label.stgHealthCheckStatusFailed, 
                                                                                expectedDescription, 
                                                                                expectedFix, 
                                                                                healthCheckGroupVModel.healthCheckItemList);
    }

    /**************************************************************************************************************************
    * @description Test to verify getHouseholdAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * fail when an invalid RT is specified for Administrative Account Model and the adminAccountModel Id in AccountSettingsModel is a
    * valid ID, but does not match any Ids in the RecordType map.
    **************************************************************************************************************************/ 
    @isTest
    private static void getHouseholdAccountModelHealthCheckItemsValidIdNoMatchingRT(){
        RecordTypeService.instance = new STUB_RecordTypeServiceNullModel();

        AccountModelSettingsModel accountModelSettingsModel = new AccountModelSettingsModel('000000000000000000',
                                                                                            '000000000000000000',
                                                                                            '000000000000000000');

        RecordTypeModel recordTypeModel = new RecordTypeModel('000000000000000123',
                                                              'Different Account Name',
                                                              'differentAccountDevName',
                                                              true);

        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{recordTypeModel.id => recordTypeModel};

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModel = 
            AccountModelHealthCheckVMapper.getInstance().getHouseholdAccountModelHealthCheckItems(accountModelSettingsModel, recordTypeModelsById);
        Test.stopTest();

        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions(Label.stgHealthCheckAccountModel,
                                                                                   Label.stgHealthCheckStatusFailed,
                                                                                   0,
                                                                                   1,
                                                                                   0,
                                                                                   1,
                                                                                   healthCheckGroupVModel);

        String expectedDescription = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCRecordTypeNotFound, 
            new List<Object>{'000000000000000000'}
        );
        String expectedFix = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCAccountModelHHNotFoundFix, 
            new List<Object>{'000000000000000000'}
        );
        
        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgAccountRecordTypeSupportsHHAddress, 
                                                                                'Fail', 
                                                                                Label.stgHealthCheckStatusFailed, 
                                                                                expectedDescription, 
                                                                                expectedFix, 
                                                                                healthCheckGroupVModel.healthCheckItemList);
    }

    /**************************************************************************************************************************
    * @description Test to verify getHealthCheckGroup() returns a HealthCheckGroupVModel with a status of
    * passed when valid and active record types are specified for Default, Administrative and Household Account Models and the
    * record types specified for HH and Admin accounts are unique.
    **************************************************************************************************************************/ 
    @isTest
    private static void getHealthCheckGroupValidAndActive(){
        AccountModelSettingsService.instance = new STUB_AccountModelSettingsServiceValidDefaultAccountId();
        RecordTypeService.instance = new STUB_RecordTypeServiceForGetHealtCheckGroupValid();

        Test.startTest();
        HealthCheckGroupVModel hlthChkGroupVModel = AccountModelHealthCheckVMapper.getInstance().getHealthCheckGroup();
        Test.stopTest();

        System.assertEquals(
            Label.stgHealthCheckAccountModel, 
            hlthChkGroupVModel.label, 
            'Label should be \'' + Label.stgHealthCheckAccountModel + '\''
        );
        System.assertEquals(
            Label.stgHealthCheckStatusPassed, 
            hlthChkGroupVModel.status, 
            'Status should be \'' + Label.stgHealthCheckStatusPassed + '\''
        );
        System.assertEquals(
            4, 
            hlthChkGroupVModel.healthCheckItemList.size(), 
            'Should contain Health Check Items for Default, Admin and HH Account models and Admin and HH Account Uniqueness.'
        );
    }

    /**************************************************************************************************************************
    * @description Test to verify getHealthCheckGroup() returns a HealthCheckGroupVModel with a status of
    * failed when a valid, but inactive record type is specified for Default Account Model.
    **************************************************************************************************************************/ 
    @isTest
    private static void getHealthCheckGroupValidAndInactive(){
        AccountModelSettingsService.instance = new STUB_AccountModelSettingsServiceValidDefaultAccountId();
        RecordTypeService.instance = new STUB_RecordTypeServiceValidAndInactiveDefaultModel();

        Test.startTest();
        HealthCheckGroupVModel hlthChkGroupVModel = AccountModelHealthCheckVMapper.getInstance().getHealthCheckGroup();
        Test.stopTest();

        System.assertEquals(
            Label.stgHealthCheckAccountModel, 
            hlthChkGroupVModel.label, 
            'Label should be \'' + Label.stgHealthCheckAccountModel + '\''
        );
        System.assertEquals(
            Label.stgHealthCheckStatusFailed, 
            hlthChkGroupVModel.status, 
            'Status should be \'' + Label.stgHealthCheckStatusFailed + '\''
        );
        System.assertEquals(
            4, 
            hlthChkGroupVModel.healthCheckItemList.size(), 
            'Should contain Health Check Items for Default, Admin and HH Account models and Admin and HH Account Uniqueness.'
        );
    }

    /**************************************************************************************************************************
    * @description Test to verify getHealthCheckGroup() returns a HealthCheckGroupVModel with a status of
    * failed when a record type id that is not an ID is specified for Default Account Model.
    **************************************************************************************************************************/ 
    @isTest
    private static void getHealthCheckGroupInvalidIdSpecified(){
        AccountModelSettingsService.instance = new STUB_AccountModelSettingsServiceInvalidDefaultAccountId();
        RecordTypeService.instance = new STUB_RecordTypeServiceForGetHealtCheckGroupInvalid();

        Test.startTest();
        HealthCheckGroupVModel hlthChkGroupVModel = AccountModelHealthCheckVMapper.getInstance().getHealthCheckGroup();
        Test.stopTest();

        System.assertEquals(
            Label.stgHealthCheckAccountModel, 
            hlthChkGroupVModel.label, 
            'Label should be \'' + Label.stgHealthCheckAccountModel + '\''
        );
        System.assertEquals(
            Label.stgHealthCheckStatusFailed, 
            hlthChkGroupVModel.status, 
            'Status should be \'' + Label.stgHealthCheckStatusFailed + '\''
        );
        System.assertEquals(
            4, 
            hlthChkGroupVModel.healthCheckItemList.size(), 
            'Should contain Health Check Items for Default, Admin and HH Account models and Admin and HH Account Uniqueness.'
        );
    }

    /**************************************************************************************************************************
    * @description Test to verify getHealthCheckGroup() returns a HealthCheckGroupVModel with a status of
    * failed when a record type id that is not an ID is specified for Default Account Model.
    **************************************************************************************************************************/ 
    @isTest
    private static void getHealthCheckGroupNotAnIdSpecified(){
        AccountModelSettingsService.instance = new STUB_AccountModelSettingsServiceNotId();
        RecordTypeService.instance = new STUB_RecordTypeServiceForGetHealtCheckGroupValid();

        Test.startTest();
        HealthCheckGroupVModel hlthChkGroupVModel = AccountModelHealthCheckVMapper.getInstance().getHealthCheckGroup();
        Test.stopTest();

        System.assertEquals(
            Label.stgHealthCheckAccountModel, 
            hlthChkGroupVModel.label, 
            'Label should be \'' + Label.stgHealthCheckAccountModel + '\''
        );
        System.assertEquals(
            Label.stgHealthCheckStatusFailed, 
            hlthChkGroupVModel.status, 
            'Status should be \'' + Label.stgHealthCheckStatusFailed + '\''
        );
        System.assertEquals(
            4, 
            hlthChkGroupVModel.healthCheckItemList.size(), 
            'Should contain Health Check Items for Default, Admin and HH Account models and Admin and HH Account Uniqueness.'
        );
    }

    /**************************************************************************************************************************
    * @description Test to verify getHealthCheckGroup() returns a HealthCheckGroupVModel with a status of
    * failed when Admin and HH account record types are the same.
    **************************************************************************************************************************/ 
    @isTest
    private static void getHealthCheckGroupNotUnique(){
        AccountModelSettingsService.instance = new STUB_AccountModelSettingsServiceNotUnique();
        RecordTypeService.instance = new STUB_RecordTypeServiceForGetHealtCheckGroupValid();

        Test.startTest();
        HealthCheckGroupVModel hlthChkGroupVModel = AccountModelHealthCheckVMapper.getInstance().getHealthCheckGroup();
        Test.stopTest();

        System.assertEquals(
            Label.stgHealthCheckAccountModel, 
            hlthChkGroupVModel.label, 
            'Label should be \'' + Label.stgHealthCheckAccountModel + '\''
        );
        System.assertEquals(
            Label.stgHealthCheckStatusFailed, 
            hlthChkGroupVModel.status, 
            'Status should be \'' + Label.stgHealthCheckStatusFailed + '\''
        );
        System.assertEquals(
            4, 
            hlthChkGroupVModel.healthCheckItemList.size(), 
            'Should contain Health Check Items for Default, Admin and HH Account models and Admin and HH Account Uniqueness.'
        );
    }

    /**************************************************************************************************************************
    * @description Test to verify getAccountRecordTypeUniquenessHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * passed when Admin and HH account record types are not the same.
    **************************************************************************************************************************/ 
    private static void getHouseholdAccountModelHealthCheckItemsUnique(){
        AccountModelSettingsModel accountModelSettingsModel = new AccountModelSettingsModel('000000000000000001',
                                                                                '000000000000000002',
                                                                                '000000000000000003');

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModel = 
            AccountModelHealthCheckVMapper.getInstance().getAccountRecordTypeUniquenessHealthCheckItems(accountModelSettingsModel);
        Test.stopTest();

        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions(Label.stgHealthCheckAccountModel,
                                                                                   Label.stgHealthCheckStatusPassed,
                                                                                   1,
                                                                                   1,
                                                                                   0,
                                                                                   1,
                                                                                   healthCheckGroupVModel);

        String expectedDescription = Label.stgHCAccountRecordTypesUnique;
        String expectedFix = Label.stgHealthCheckFixNotApplicable;
        
        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgHCAccountRecordTypeSettingsUnique, 
                                                                                'Pass', 
                                                                                Label.stgHealthCheckStatusPassed, 
                                                                                expectedDescription, 
                                                                                expectedFix, 
                                                                                healthCheckGroupVModel.healthCheckItemList);
    }

    /**************************************************************************************************************************
    * @description Test to verify getAccountRecordTypeUniquenessHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * failed when Admin and HH account record types are the same.
    **************************************************************************************************************************/ 
    private static void getHouseholdAccountModelHealthCheckItemsNotUnique(){
        AccountModelSettingsModel accountModelSettingsModel = new AccountModelSettingsModel('000000000000000001',
                                                                                            '000000000000000005',
                                                                                            '000000000000000005');

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModel = 
            AccountModelHealthCheckVMapper.getInstance().getAccountRecordTypeUniquenessHealthCheckItems(accountModelSettingsModel);
        Test.stopTest();

        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions(Label.stgHealthCheckAccountModel,
                                                                                   Label.stgHealthCheckStatusFailed,
                                                                                   0,
                                                                                   1,
                                                                                   0,
                                                                                   1,
                                                                                   healthCheckGroupVModel);

        String expectedDescription = Label.stgHCAccountRecordTypesNotUnique;
        String expectedFix = Label.stgHCAccountRecordTypesNotUniqueFix;
        
        AccountModelHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgHCAccountRecordTypeSettingsUnique, 
                                                                                'Fail', 
                                                                                Label.stgHealthCheckStatusFailed, 
                                                                                expectedDescription, 
                                                                                expectedFix, 
                                                                                healthCheckGroupVModel.healthCheckItemList);
    }

    /**************************************************************************************************************************
    ****************************************************** STUBS **************************************************************
    **************************************************************************************************************************/
    
    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from RecordTypeService to return a valid and active RecordTypeModel from getRecordTypeModelFromMap.
    **************************************************************************************************************************************/ 
    private class STUB_RecordTypeServiceValidAndActiveDefaultModel extends RecordTypeService {
        @TestVisible 
        public override RecordTypeModel getRecordTypeModelFromMap(String recordTypeId, Map<Id, RecordTypeModel> recordTypeModelById) { 
            return new RecordTypeModel('000000000000000001',
                                       'Test Record Name',
                                       'testRecordDevName',
                                       true);
        }
    }

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from RecordTypeService to return a valid, but inactive RecordTypeModel from getModelByIdMapForSObjectType.
    **************************************************************************************************************************************/ 
    private class STUB_RecordTypeServiceForGetHealtCheckGroupValid extends RecordTypeService {
        public override  Map<Id, RecordTypeModel> getModelByIdMapForSObjectType(Schema.SObjectType sObjectType) {

            Map<Id, RecordTypeModel> accRTModelsById = new Map<Id, RecordTypeModel>();

            RecordTypeModel defaultAccRTModel = new RecordTypeModel('000000000000000001',
                                                                    'Test Record Name',
                                                                    'testRecordDevName',
                                                                    true);
                                                                    
            RecordTypeModel adminAccRTModel = new RecordTypeModel('000000000000000002',
                                                                  'Test Admin Record Name',
                                                                  'testAdminRecordDevName',
                                                                  true);
                                                                    
            RecordTypeModel hhAccRTModel = new RecordTypeModel('000000000000000003',
                                                               'Test HH Record Name',
                                                               'testHHRecordDevName',
                                                               true);
                                                                    
            accRTModelsById.put(defaultAccRTModel.id, defaultAccRTModel);
            accRTModelsById.put(adminAccRTModel.id, adminAccRTModel);
            accRTModelsById.put(hhAccRTModel.id, hhAccRTModel);
            
            return accRTModelsById;
        }
    }

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from RecordTypeService to return a valid, but inactive RecordTypeModel from getRecordTypeModelFromMap.
    **************************************************************************************************************************************/ 
    private class STUB_RecordTypeServiceValidAndInactiveDefaultModel extends RecordTypeService {
        @TestVisible 
        public override RecordTypeModel getRecordTypeModelFromMap(String recordTypeId, Map<Id, RecordTypeModel> recordTypeModelById) { 
            return new RecordTypeModel('000000000000000001',
                                       'Test Record Name',
                                       'testRecordDevName',
                                       false);
        }
    }

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from RecordTypeService to return a valid, but inactive RecordTypeModel from getModelByIdMapForSObjectType.
    **************************************************************************************************************************************/ 
    private class STUB_RecordTypeServiceForGetHealtCheckGroupInvalid extends RecordTypeService {
        public override  Map<Id, RecordTypeModel> getModelByIdMapForSObjectType(Schema.SObjectType sObjectType) {
            RecordTypeModel accRTModel = new RecordTypeModel('000000000000000001',
                                                            'Test Record Name',
                                                            'testRecordDevName',
                                                            false);

            return new Map<Id, RecordTypeModel>{accRTModel.id => accRTModel};
        }
    }

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from RecordTypeService to return null.
    **************************************************************************************************************************************/ 
    private class STUB_RecordTypeServiceNullModel extends RecordTypeService {
        @TestVisible 
        public override RecordTypeModel getRecordTypeModelFromMap(String recordTypeId, Map<Id, RecordTypeModel> recordTypeModelById) { 
            return null;
        }

        public override  Map<Id, RecordTypeModel> getModelByIdMapForSObjectType(Schema.SObjectType sObjectType) {
            return new Map<Id, RecordTypeModel>();
        }
    }

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from AccountModelSettingsService to return a valid set of account model settings.
    **************************************************************************************************************************************/ 
    private class STUB_AccountModelSettingsServiceValidDefaultAccountId extends AccountModelSettingsService {
        public override AccountModelSettingsModel getAccountModelSettingsModel() {
            return new AccountModelSettingsModel('000000000000000001',
                                                 '000000000000000002',
                                                 '000000000000000003');
        }
    }

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from AccountModelSettingsService to return a set of invalid account model settings.
    **************************************************************************************************************************************/ 
    private class STUB_AccountModelSettingsServiceInvalidDefaultAccountId extends AccountModelSettingsService {
        public override AccountModelSettingsModel getAccountModelSettingsModel() {
            return new AccountModelSettingsModel('000aaaaaaaaaaaaaaa',
                                                 '000aaaaaaaaaaaaaab',
                                                 '000aaaaaaaaaaaaaac');
        }
    }

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from AccountModelSettingsService to return a set of account model settings that are not Ids.
    **************************************************************************************************************************************/ 
    private class STUB_AccountModelSettingsServiceNotId extends AccountModelSettingsService {
        public override AccountModelSettingsModel getAccountModelSettingsModel() {
            return new AccountModelSettingsModel('Not an ID 1',
                                                 'Not an ID 2',
                                                 'Not an ID 3');
        }
    }

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from AccountModelSettingsService to return a set of account model settings with the
    * same RT set for both Admin and HH accounts.
    **************************************************************************************************************************************/ 
    private class STUB_AccountModelSettingsServiceNotUnique extends AccountModelSettingsService {
        public override AccountModelSettingsModel getAccountModelSettingsModel() {
            return new AccountModelSettingsModel('123000000000000001',
                                                 '123000000000000005',
                                                 '123000000000000005');
        }
    }

    /**************************************************************************************************************************
    ************************************************* HELPER METHODS **********************************************************
    **************************************************************************************************************************/

    /**************************************************************************************************************************
    * @description Helper method to validate assertions for HealthCheckGroupVModel tests.
    **************************************************************************************************************************/
    private static void verifyHealthCheckGroupVModelAssertions(String expectedLabel, 
                                                               String expectedStatus, 
                                                               Integer expectedPassedCheckCount, 
                                                               Integer expectedTotalCheckCount, 
                                                               Integer expectedExpandedRowSize, 
                                                               Integer expectedHealthCheckItemListSize,
                                                               HealthCheckGroupVModel healthCheckGroupResult){

        System.assertEquals(expectedLabel, healthCheckGroupResult.label, 'Should have \'' + expectedLabel + '\' label.');
        System.assertEquals(expectedStatus, healthCheckGroupResult.status, 'Should have status of \'' + expectedStatus + '\'.');
        System.assertEquals(expectedPassedCheckCount, healthCheckGroupResult.passedChecks, 'Should have ' + expectedPassedCheckCount + ' passed checks.');
        System.assertEquals(expectedTotalCheckCount, healthCheckGroupResult.totalChecks, 'Should have ' + expectedTotalCheckCount + ' check.');
        System.assertEquals(expectedExpandedRowSize, healthCheckGroupResult.expandedRowsList.size(), 'Should have ' + expectedExpandedRowSize + ' expanded rows.');
        System.assertEquals(expectedHealthCheckItemListSize, healthCheckGroupResult.healthCheckItemList.size(), 'Should have ' + expectedHealthCheckItemListSize + ' health check item.');
    }

    /**************************************************************************************************************************
    * @description Helper method to validate assertions for HealthCheckGroupVModel HealthCheckItems.
    **************************************************************************************************************************/
    private static void verifyHealthCheckItemListAssertions(String expectedSetting,
                                                            String expectedStatus, 
                                                            String expectedStatusLabel,
                                                            String expectedDescription,
                                                            String expectedFix,
                                                            List<HealthCheckItemVModel> healthCheckItemList){

        for (HealthCheckItemVModel healthCheckItemVModel : healthCheckItemList){
            System.assertEquals(expectedSetting, healthCheckItemVModel.setting, 'Health Check Item setting should be \'' + expectedSetting + '\'.');
            System.assertEquals(expectedStatus, healthCheckItemVModel.status, 'Health Check Item status should be \'' + expectedStatus + '\'.');
            System.assertEquals(expectedStatusLabel, healthCheckItemVModel.statusLabel, 'Health Check Item status label should be \'' + expectedStatusLabel + '\'.');
            System.assertEquals(expectedDescription, healthCheckItemVModel.description, 'Health Check Item description should be correctly set.');
            System.assertEquals(expectedFix, healthCheckItemVModel.recommendedFix, 'Health Check Item recommended fix should be correctly set.');
        }        
    }
}
