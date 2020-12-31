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
    * pass when a valid and active RT is specified for Default Account Model.
    **************************************************************************************************************************/ 
    @isTest
    private static void getDefaultAccountModelHealthCheckItemsValidAndActive(){
        RecordTypeService.instance = new STUB_RecordTypeServiceValidAndActiveDefaultModel();

        AccountModelSettingsModel accModSettMod = new AccountModelSettingsModel('000000000000000001',
                                                                                '000000000000000002',
                                                                                '000000000000000003');

        Map<Id,RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>();

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
        System.assertEquals(expectedDescription, hlthChkGroupVMod.healthCheckItemList[0].description, 'Health Check Item description should be set.');
        System.assertEquals(Label.stgHealthCheckFixNotApplicable, hlthChkGroupVMod.healthCheckItemList[0].recommendedFix, 'Health Check Item recommended fix should be set.');
    }

    /**************************************************************************************************************************
    * @description Test to verify getDefaultAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * fail when a valid, but inactive RT is specified for Default Account Model.
    **************************************************************************************************************************/ 
    @isTest
    private static void getDefaultAccountModelHealthCheckItemsValidAndInactive(){
        RecordTypeService.instance = new STUB_RecordTypeServiceValidAndInactiveDefaultModel();

        AccountModelSettingsModel accModSettMod = new AccountModelSettingsModel('000000000000000001',
                                                                                '000000000000000002',
                                                                                '000000000000000003');

        Map<Id,RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>();

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
        System.assertEquals(expectedDescription, hlthChkGroupVMod.healthCheckItemList[0].description, 'Health Check Item description should be set.');
        System.assertEquals(expectedFix, hlthChkGroupVMod.healthCheckItemList[0].recommendedFix, 'Health Check Item recommended fix should be set.');
    }

     /**************************************************************************************************************************
    * @description Test to verify getDefaultAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * fail when an invalid RT is specified for Default Account Model.
    **************************************************************************************************************************/ 
    @isTest
    private static void getDefaultAccountModelHealthCheckItemsInvalid(){
        RecordTypeService.instance = new STUB_RecordTypeServiceNullModel();

        AccountModelSettingsModel accModSettMod = new AccountModelSettingsModel('000000000000000001',
                                                                                '000000000000000002',
                                                                                '000000000000000003');

        Map<Id,RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>();

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

        String expectedDescription = String.format(Label.stgHCRecordTypeNotFound, new List<Object>{'000000000000000001'});
        String expectedFix = String.format(Label.stgHCAccountModelDefaultNotFoundFix, new List<Object>{'000000000000000001'});

        System.assertEquals(Label.stgAccModelTitle, hlthChkGroupVMod.healthCheckItemList[0].setting, 'Health Check Item setting should be \'Default Account Model\'.');
        System.assertEquals('Fail', hlthChkGroupVMod.healthCheckItemList[0].status, 'Should have status of \'Fail\'.');
        System.assertEquals(Label.stgHealthCheckStatusFailed, hlthChkGroupVMod.healthCheckItemList[0].statusLabel, 'Should have status label of \'Failed\'.');
        System.assertEquals(expectedDescription, hlthChkGroupVMod.healthCheckItemList[0].description, 'Health Check Item description should be set.');
        System.assertEquals(expectedFix, hlthChkGroupVMod.healthCheckItemList[0].recommendedFix, 'Health Check Item recommended fix should be set.');
    }

    /**************************************************************************************************************************
    ****************************************************** STUBS **************************************************************
    **************************************************************************************************************************/
    
    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from RecordTypeService to return a valid and active RecordTypeModel.
    **************************************************************************************************************************************/ 
    private class STUB_RecordTypeServiceValidAndActiveDefaultModel extends RecordTypeService {
        @TestVisible 
        public override RecordTypeModel getRecordTypeModelFromMap(String recordTypeId, Map<Id, RecordTypeModel> recordTypeModelById) { 
            return new RecordTypeModel('000000000000000001',
                                       'Test Default Record Name',
                                       'testDefaultRecordDevName',
                                       true);
        }

        public override  Map<Id, RecordTypeModel> getModelByIdMapForSObjectType(Schema.SObjectType sObjectType) {
            RecordTypeModel accRTModel = new RecordTypeModel('000000000000000001',
                                                             'Test Default Record Name',
                                                             'testDefaultRecordDevName',
                                                             true);

            return new Map<Id, RecordTypeModel>{accRTModel.id => accRTModel};
        }
    }

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from RecordTypeService to return a valid, but inactive RecordTypeModel.
    **************************************************************************************************************************************/ 
    private class STUB_RecordTypeServiceValidAndInactiveDefaultModel extends RecordTypeService {
        @TestVisible 
        public override RecordTypeModel getRecordTypeModelFromMap(String recordTypeId, Map<Id, RecordTypeModel> recordTypeModelById) { 
            return new RecordTypeModel('000000000000000001',
                                       'Test Default Record Name',
                                       'testDefaultRecordDevName',
                                       false);
        }
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
    private class STUB_AccountModelSettingsServiceValid extends AccountModelSettingsService {
        public override AccountModelSettingsModel getAccountModelSettingsModel() {
            return new AccountModelSettingsModel('000000000000000001',
                                                 '000000000000000002',
                                                 '000000000000000003');
        }
    }
}
