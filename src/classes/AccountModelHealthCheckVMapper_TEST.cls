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
    * @description Test to verify updateHealthCheckStatus() returns Pass when all health checks executed pass.
    **************************************************************************************************************************/ 
    @isTest
    private static void updateHealthCheckStatusPass(){
        Test.startTest();
        String hcStatus = AccountModelHealthCheckVMapper.getInstance().updateHealthCheckStatus(5, 5);
        Test.stopTest();

        System.assertEquals(Label.stgHealthCheckStatusPassed, hcStatus, 'Should return \'Pass\'.');
    }

    /**************************************************************************************************************************
    * @description Test to verify updateHealthCheckStatus() returns Fail when any health checks executed fail.
    **************************************************************************************************************************/ 
    @isTest
    private static void updateHealthCheckStatusFail(){
        Test.startTest();
        String hcStatus = AccountModelHealthCheckVMapper.getInstance().updateHealthCheckStatus(2, 5);
        Test.stopTest();

        System.assertEquals(Label.stgHealthCheckStatusFailed, hcStatus, 'Should return \'Fail\'.');
    }

    /**************************************************************************************************************************
    * @description Test to verify getDefaultAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * pass when the ID provided as the defaultAccountModel Id in AccountSettingsModel is valid and matches to a RT for Default 
    * Account Modelthat is valid and active.
    **************************************************************************************************************************/ 
    @isTest
    private static void getDefaultAccountModelHealthCheckItemsIdMatchFoundToRTValidAndActive(){
        RecordTypeService.instance = new STUB_RecordTypeServiceValidAndActiveDefaultModel();

        AccountModelSettingsModel accModSettMod = new AccountModelSettingsModel('000000000000000001',
                                                                                '000000000000000002',
                                                                                '000000000000000003');

        RecordTypeModel rtModel = new RecordTypeModel('000000000000000001',
                                                      'Test Default Record Name',
                                                      'testDefaultRecordDevName',
                                                      true);
                          
        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{rtModel.id => rtModel};

        Test.startTest();
        HealthCheckGroupVModel hlthChkGroupVMod = 
            AccountModelHealthCheckVMapper.getInstance().getDefaultAccountModelHealthCheckItems(accModSettMod, recordTypeModelsById);
        Test.stopTest();

        System.assertEquals(Label.stgHealthCheckAccountModel, hlthChkGroupVMod.label, 'Should have \'Account Model\' label.');
        System.assertEquals(Label.stgHealthCheckStatusPassed, hlthChkGroupVMod.status, 'Should have status of \'Pass\'.');
        System.assertEquals(1, hlthChkGroupVMod.passedChecks, 'Should have 1 passed check.');
        System.assertEquals(1, hlthChkGroupVMod.totalChecks, 'Should have 1 check.');
        System.assertEquals(true, hlthChkGroupVMod.expandedRowsList.isEmpty(), 'Should have no expanded rows.');
        System.assertEquals(1, hlthChkGroupVMod.healthCheckItemList.size(), 'Should have 1 health check item.');

        String expectedDescription = String.format(Label.stgHCRecordTypeValid, new List<Object>{'Test Default Record Name', 'testDefaultRecordDevName'});

        System.assertEquals(Label.stgAccModelTitle, hlthChkGroupVMod.healthCheckItemList[0].setting, 'Health Check Item setting should be \'Default Account Model\'.');
        System.assertEquals('Pass', hlthChkGroupVMod.healthCheckItemList[0].status, 'Health Check Item status should be \'Pass\'.');
        System.assertEquals(Label.stgHealthCheckStatusPassed, hlthChkGroupVMod.healthCheckItemList[0].statusLabel, 'Health Check Item status label should be \'Passed\'.');
        System.assertEquals(expectedDescription, hlthChkGroupVMod.healthCheckItemList[0].description, 'Health Check Item description should be correctly set.');
        System.assertEquals(Label.stgHealthCheckFixNotApplicable, hlthChkGroupVMod.healthCheckItemList[0].recommendedFix, 'Health Check Item recommended fix should be correctly set.');
    }

    /**************************************************************************************************************************
    * @description Test to verify getDefaultAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * fail when the ID provided as the defaultAccountModel Id in AccountSettingsModel is valid and matches to a RT for Default 
    * Account Modelthat is valid, but inactive.
    **************************************************************************************************************************/ 
    @isTest
    private static void getDefaultAccountModelHealthCheckItemsIdMatchFoundToRTValidAndInactive(){
        RecordTypeService.instance = new STUB_RecordTypeServiceValidAndInactiveDefaultModel();

        AccountModelSettingsModel accModSettMod = new AccountModelSettingsModel('000000000000000001',
                                                                                '000000000000000002',
                                                                                '000000000000000003');

        RecordTypeModel rtModel = new RecordTypeModel('000000000000000001',
                                                      'Test Default Record Name',
                                                      'testDefaultRecordDevName',
                                                      false);

        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{rtModel.id => rtModel};

        Test.startTest();
        HealthCheckGroupVModel hlthChkGroupVMod = 
            AccountModelHealthCheckVMapper.getInstance().getDefaultAccountModelHealthCheckItems(accModSettMod, recordTypeModelsById);
        Test.stopTest();

        System.assertEquals(Label.stgHealthCheckAccountModel, hlthChkGroupVMod.label, 'Should have \'Account Model\' label.');
        System.assertEquals(Label.stgHealthCheckStatusFailed, hlthChkGroupVMod.status, 'Should have status of \'Fail\'.');
        System.assertEquals(0, hlthChkGroupVMod.passedChecks, 'Should have 0 passed checks.');
        System.assertEquals(1, hlthChkGroupVMod.totalChecks, 'Should have 1 check.');
        System.assertEquals(true, hlthChkGroupVMod.expandedRowsList.isEmpty(), 'Should have no expanded rows.');
        System.assertEquals(1, hlthChkGroupVMod.healthCheckItemList.size(), 'Should have 1 health check item.');

        String expectedDescription = String.format(Label.stgHCRecordTypeInactive, new List<Object>{'Test Default Record Name'});
        String expectedFix = String.format(Label.stgHCAccountModelDefaultInactiveFix, new List<Object>{'testDefaultRecordDevName'});

        System.assertEquals(Label.stgAccModelTitle, hlthChkGroupVMod.healthCheckItemList[0].setting, 'Health Check Item setting should be \'Default Account Model\'.');
        System.assertEquals('Fail', hlthChkGroupVMod.healthCheckItemList[0].status, 'Health Check Item status should be \'Fail\'.');
        System.assertEquals(Label.stgHealthCheckStatusFailed, hlthChkGroupVMod.healthCheckItemList[0].statusLabel, 'Health Check Item status label should be \'Failed\'.');
        System.assertEquals(expectedDescription, hlthChkGroupVMod.healthCheckItemList[0].description, 'Health Check Item description should be correctly set.');
        System.assertEquals(expectedFix, hlthChkGroupVMod.healthCheckItemList[0].recommendedFix, 'Health Check Item recommended fix should be correctly set.');
    }

    /**************************************************************************************************************************
    * @description Test to verify getDefaultAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * fail when an the ID provided as the defaultAccountModel Id in AccountSettingsModel is not an ID.
    **************************************************************************************************************************/ 
    @isTest
    private static void getDefaultAccountModelHealthCheckItemsInvalidDefaultId(){
        RecordTypeService.instance = new STUB_RecordTypeServiceNullModel();

        AccountModelSettingsModel accModSettMod = new AccountModelSettingsModel('Not an ID default acct',
                                                                                'Not an ID admin acct',
                                                                                'Not an Id HH acct');

        RecordTypeModel rtModel = new RecordTypeModel('000000000000000111',
                                                      'Account Name',
                                                      'accountDevName',
                                                      true);

        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{rtModel.id => rtModel};

        Test.startTest();
        HealthCheckGroupVModel hlthChkGroupVMod = 
            AccountModelHealthCheckVMapper.getInstance().getDefaultAccountModelHealthCheckItems(accModSettMod, recordTypeModelsById);
        Test.stopTest();

        System.assertEquals(Label.stgHealthCheckAccountModel, hlthChkGroupVMod.label, 'Should have \'Account Model\' label.');
        System.assertEquals(Label.stgHealthCheckStatusFailed, hlthChkGroupVMod.status, 'Should have status of \'Fail\'.');
        System.assertEquals(0, hlthChkGroupVMod.passedChecks, 'Should have 0 passed checks.');
        System.assertEquals(1, hlthChkGroupVMod.totalChecks, 'Should have 1 check.');
        System.assertEquals(true, hlthChkGroupVMod.expandedRowsList.isEmpty(), 'Should have no expanded rows.');
        System.assertEquals(1, hlthChkGroupVMod.healthCheckItemList.size(), 'Should have 1 health check item.');

        String expectedDescription = String.format(Label.stgHCRecordTypeNotFound, new List<Object>{'Not an ID default acct'});
        String expectedFix = String.format(Label.stgHCAccountModelDefaultNotFoundFix, new List<Object>{'Not an ID default acct'});

        System.assertEquals(Label.stgAccModelTitle, hlthChkGroupVMod.healthCheckItemList[0].setting, 'Health Check Item setting should be \'Default Account Model\'.');
        System.assertEquals('Fail', hlthChkGroupVMod.healthCheckItemList[0].status, 'Should have status of \'Fail\'.');
        System.assertEquals(Label.stgHealthCheckStatusFailed, hlthChkGroupVMod.healthCheckItemList[0].statusLabel, 'Should have status label of \'Failed\'.');
        System.assertEquals(expectedDescription, hlthChkGroupVMod.healthCheckItemList[0].description, 'Health Check Item description should be correctly set.');
        System.assertEquals(expectedFix, hlthChkGroupVMod.healthCheckItemList[0].recommendedFix, 'Health Check Item recommended fix should be correctly set.');
    }

    /**************************************************************************************************************************
    * @description Test to verify getDefaultAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * fail when an invalid RT is specified for Default Account Model and the defaultAccountModel Id in AccountSettingsModel is a
    * valid ID, but does not match any Ids in the RecordType map.
    **************************************************************************************************************************/ 
    @isTest
    private static void getDefaultAccountModelHealthCheckItemsValidIdNoMatchingRT(){
        RecordTypeService.instance = new STUB_RecordTypeServiceNullModel();

        AccountModelSettingsModel accModSettMod = new AccountModelSettingsModel('000000000000000000',
                                                                                '000000000000000000',
                                                                                '000000000000000000');

        RecordTypeModel rtModel = new RecordTypeModel('000000000000000123',
                                                      'Different Account Name',
                                                      'differentAccountDevName',
                                                      true);

        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{rtModel.id => rtModel};

        Test.startTest();
        HealthCheckGroupVModel hlthChkGroupVMod = 
            AccountModelHealthCheckVMapper.getInstance().getDefaultAccountModelHealthCheckItems(accModSettMod, recordTypeModelsById);
        Test.stopTest();

        System.assertEquals(Label.stgHealthCheckAccountModel, hlthChkGroupVMod.label, 'Should have \'Account Model\' label.');
        System.assertEquals(Label.stgHealthCheckStatusFailed, hlthChkGroupVMod.status, 'Should have status of \'Fail\'.');
        System.assertEquals(0, hlthChkGroupVMod.passedChecks, 'Should have 0 passed checks.');
        System.assertEquals(1, hlthChkGroupVMod.totalChecks, 'Should have 1 check.');
        System.assertEquals(true, hlthChkGroupVMod.expandedRowsList.isEmpty(), 'Should have no expanded rows.');
        System.assertEquals(1, hlthChkGroupVMod.healthCheckItemList.size(), 'Should have 1 health check item.');

        String expectedDescription = String.format(Label.stgHCRecordTypeNotFound, new List<Object>{'000000000000000000'});
        String expectedFix = String.format(Label.stgHCAccountModelDefaultNotFoundFix, new List<Object>{'000000000000000000'});

        System.assertEquals(Label.stgAccModelTitle, hlthChkGroupVMod.healthCheckItemList[0].setting, 'Health Check Item setting should be \'Default Account Model\'.');
        System.assertEquals('Fail', hlthChkGroupVMod.healthCheckItemList[0].status, 'Should have status of \'Fail\'.');
        System.assertEquals(Label.stgHealthCheckStatusFailed, hlthChkGroupVMod.healthCheckItemList[0].statusLabel, 'Should have status label of \'Failed\'.');
        System.assertEquals(expectedDescription, hlthChkGroupVMod.healthCheckItemList[0].description, 'Health Check Item description should be correctly set.');
        System.assertEquals(expectedFix, hlthChkGroupVMod.healthCheckItemList[0].recommendedFix, 'Health Check Item recommended fix should be correctly set.');
    }

    /**************************************************************************************************************************
    * @description Test to verify getHealthCheckGroup() returns a HealthCheckGroupVModel with a status of
    * passed when a valid and active record type is specified for Default Account Model.
    **************************************************************************************************************************/ 
    @isTest
    private static void getHealthCheckGroupValidAndActive(){
        AccountModelSettingsService.instance = new STUB_AccountModelSettingsServiceValidDefaultAccountId();
        RecordTypeService.instance = new STUB_RecordTypeServiceForGetHealtCheckGroupValid();

        Test.startTest();
        HealthCheckGroupVModel hlthChkGroupVModel = AccountModelHealthCheckVMapper.getInstance().getHealthCheckGroup();
        Test.stopTest();

        System.assertEquals(Label.stgHealthCheckAccountModel, hlthChkGroupVModel.label, 'Label should be \'Account Model\'');
        System.assertEquals(Label.stgHealthCheckStatusPassed, hlthChkGroupVModel.status, 'Status should be \'Pass\'');
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

        System.assertEquals(Label.stgHealthCheckAccountModel, hlthChkGroupVModel.label, 'Label should be \'Account Model\'');
        System.assertEquals(Label.stgHealthCheckStatusFailed, hlthChkGroupVModel.status, 'Status should be \'Fail\'');
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

        System.assertEquals(Label.stgHealthCheckAccountModel, hlthChkGroupVModel.label, 'Label should be \'Account Model\'');
        System.assertEquals(Label.stgHealthCheckStatusFailed, hlthChkGroupVModel.status, 'Status should be \'Fail\'');
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

        System.assertEquals(Label.stgHealthCheckAccountModel, hlthChkGroupVModel.label, 'Label should be \'Account Model\'');
        System.assertEquals(Label.stgHealthCheckStatusFailed, hlthChkGroupVModel.status, 'Status should be \'Fail\'');
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
                                       'Test Default Record Name',
                                       'testDefaultRecordDevName',
                                       true);
        }
    }

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from RecordTypeService to return a valid, but inactive RecordTypeModel from getModelByIdMapForSObjectType.
    **************************************************************************************************************************************/ 
    private class STUB_RecordTypeServiceForGetHealtCheckGroupValid extends RecordTypeService {
        public override  Map<Id, RecordTypeModel> getModelByIdMapForSObjectType(Schema.SObjectType sObjectType) {
            RecordTypeModel accRTModel = new RecordTypeModel('000000000000000001',
                                                            'Test Default Record Name',
                                                            'testDefaultRecordDevName',
                                                            true);

            return new Map<Id, RecordTypeModel>{accRTModel.id => accRTModel};
        }
    }

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from RecordTypeService to return a valid, but inactive RecordTypeModel from getRecordTypeModelFromMap.
    **************************************************************************************************************************************/ 
    private class STUB_RecordTypeServiceValidAndInactiveDefaultModel extends RecordTypeService {
        @TestVisible 
        public override RecordTypeModel getRecordTypeModelFromMap(String recordTypeId, Map<Id, RecordTypeModel> recordTypeModelById) { 
            return new RecordTypeModel('000000000000000001',
                                       'Test Default Record Name',
                                       'testDefaultRecordDevName',
                                       false);
        }
    }

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from RecordTypeService to return a valid, but inactive RecordTypeModel from getModelByIdMapForSObjectType.
    **************************************************************************************************************************************/ 
    private class STUB_RecordTypeServiceForGetHealtCheckGroupInvalid extends RecordTypeService {
        public override  Map<Id, RecordTypeModel> getModelByIdMapForSObjectType(Schema.SObjectType sObjectType) {
            RecordTypeModel accRTModel = new RecordTypeModel('000000000000000001',
                                                            'Test Default Record Name',
                                                            'testDefaultRecordDevName',
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
}
