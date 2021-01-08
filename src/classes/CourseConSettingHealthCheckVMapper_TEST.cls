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
* @date 2021
* @group
* @group-content ../../ApexDocContent/Tests.htm
* @description Test class for CourseConSettingHealthCheckVMapper
*/
@isTest
private class CourseConSettingHealthCheckVMapper_TEST {

    /***************************************************************************
    *******************************INSTANCE*************************************
    ***************************************************************************/

    /***************************************************************************
    * @description Test method to verify that the getInstance method returns a
    * new instance of the CourseConSettingHealthCheckVMapper class when one does
    * not already exist.
    ***************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
        CourseConSettingHealthCheckVMapper courseConSettingHealthCheckVMapperInstance =
            CourseConSettingHealthCheckVMapper.getInstance();
        Test.stopTest();

        System.assertNotEquals(
            null,
            courseConSettingHealthCheckVMapperInstance,
            'Instance of view model mapper class should not be null.'
        );

        System.assertEquals(
            CourseConSettingHealthCheckVMapper.instance,
            courseConSettingHealthCheckVMapperInstance,
            'Instance of view model mapper class returned should match static instance variable.'
        );
    }

    /***************************************************************************
    * @description Test method to verify that the getInstance method returns the
    * existing instance of the CourseConSettingHealthCheckVMapper class when one
    * already exists.
    ***************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        CourseConSettingHealthCheckVMapper expectedCourseConSettingHealthCheckVMapperInstance =
            CourseConSettingHealthCheckVMapper.getInstance();

        Test.startTest();
            CourseConSettingHealthCheckVMapper courseConHealthCheckVMapperInstance =
                CourseConSettingHealthCheckVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            expectedCourseConSettingHealthCheckVMapperInstance,
            courseConHealthCheckVMapperInstance,
            'Instance of mapper class returned should match cached value.'
        );
    }

    
    /***************************************************************************
    * @description Test method to verify that getHealthCheckGroup handles
    * passed health check when Course Connection is enabled
    ***************************************************************************/
    @isTest
    private static void getHealthCheckGroupCourseConnectionEnabled() {
        
        RecordTypeService.instance = 
            new STUB_RecordTypeService();

        CourseConnectionSettingsService.instance =
            new STUB_CourseConnectionSettingsService_Enabled();

        CourseConSettingHealthCheckVMapper courseConSettingHealthCheckVMapperInstance =
            CourseConSettingHealthCheckVMapper.getInstance();

        Test.startTest();
            HealthCheckGroupVModel hCGroupVMdl = CourseConSettingHealthCheckVMapper.getInstance().getHealthCheckGroup();
        Test.stopTest();

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions('Label.stgHCCourseConnectionsTitle',
                                                                              Label.stgHealthCheckStatusPassed,
                                                                              1,
                                                                              1,
                                                                              0,
                                                                              0,
                                                                              hCGroupVMdl);
        
    }
    
    /***************************************************************************
    * @description Test method to verify that getHealthCheckGroup handles
    * failed health check when Course Connection disabled
    ***************************************************************************/
    @isTest
    private static void getHealthCheckGroupCourseConnectionDisabled() {
        
        RecordTypeService.instance = 
            new STUB_RecordTypeService();

        CourseConnectionSettingsService.instance =
            new STUB_CourseConnectionSettingsService_Disbaled();

        CourseConSettingHealthCheckVMapper courseConSettingHealthCheckVMapperInstance =
            CourseConSettingHealthCheckVMapper.getInstance();

        Test.startTest();
            HealthCheckGroupVModel hCGroupVMdl = CourseConSettingHealthCheckVMapper.getInstance().getHealthCheckGroup();
        Test.stopTest();

        System.assertEquals('Label.stgHCCourseConnectionsTitle', hCGroupVMdl.label, 'The label of the Course Connection Health Check should be retrieved.');
        System.assertEquals(1, hCGroupVMdl.healthCheckItemList.size(), 'No group items should be in the item list as Course Connection is enabled.');
        System.assertEquals('Label.stgEnableCourseConnectionsTitle', hCGroupVMdl.healthCheckItemList[0].setting, 'The setting in the group item should be of Course Connection Enablement');
        System.assertEquals(Label.stgHealthCheckStatusFailed, hCGroupVMdl.status, 'The status of the checks should be fail.');
        
        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions('Label.stgHCCourseConnectionsTitle',
                                                                                       Label.stgHealthCheckStatusFailed,
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       1,
                                                                                       hCGroupVMdl);
        
                
       CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions('Label.stgEnableCourseConnectionsTitle',
                                                                                  'Fail',
                                                                                  Label.stgHealthCheckStatusFailed,
                                                                                  'Label.stgHCCourseConEnable',
                                                                                  'Label.stgHCCourseConEnableFix',
                                                                                  hCGroupVMdl.healthCheckItemList); 
    }
    
    /*****************************************************************************************
    * @description Test method to verify that getCourseConnectionsNotEnabledHealthCheckItems
    * handles all failed check when Course Connection is disabled
    *****************************************************************************************/
    @isTest
    private static void getCourseConnectionsNotEnabledHealthCheckItemsFail() {

        CourseConnectionSettingsModel courseConnSettingsModel = new CourseConnectionSettingsModel(
            false,
            '01217000002Zs0pAAC',
            '01217000002Zs0pAAC'
        );

        Test.startTest();
            HealthCheckGroupVModel hCGroupVMdl = CourseConSettingHealthCheckVMapper.getInstance().getCourseConnectionsNotEnabledHealthCheckItems(courseConnSettingsModel);
        Test.stopTest();


        System.assertEquals(0, hCGroupVMdl.passedChecks, 'The setting in the group item should be of Course Connection Enablement');
        System.assertEquals(1, hCGroupVMdl.totalChecks, 'The setting in the group item should be of Course Connection Enablement');
        
        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions('',
                                                                                       '',
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       1,
                                                                                       hCGroupVMdl);
        
        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions('Label.stgEnableCourseConnectionsTitle',
                                                                                    'Fail',
                                                                                    Label.stgHealthCheckStatusFailed,
                                                                                    'Label.stgHCCourseConEnable',
                                                                                    'Label.stgHCCourseConEnableFix',
                                                                                    hCGroupVMdl.healthCheckItemList); 
    }
    
    /*********************************************************************************************
    * @description Test method to verify that getCourseConnectionsNotEnabledHealthCheckItems
    * handles all passed checks when Course Connection is enabled
    *********************************************************************************************/
    @isTest
    private static void getCourseConnectionsNotEnabledHealthCheckItemsPass() {

        CourseConnectionSettingsModel courseConnSettingsModel = new CourseConnectionSettingsModel(
            true,
            '01217000002Zs0pAAC',
            '01217000002Zs0pAAC'
        );

        Test.startTest();
            HealthCheckGroupVModel hCGroupVMdl = CourseConSettingHealthCheckVMapper.getInstance().getCourseConnectionsNotEnabledHealthCheckItems(courseConnSettingsModel);
        Test.stopTest();

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions('',
                                                                                       '',
                                                                                       1,
                                                                                       1,
                                                                                       0,
                                                                                       0,
                                                                                       hCGroupVMdl);
   
    }

    /******************************************************************************
    * @description Test method to verify that a CourseConnectionSettingsService is
    * retrieved by the locator method.
    ******************************************************************************/
    @isTest 
    private static void locateCourseConnectionSettingsService(){
        CourseConnectionSettingsService expectedCourseConnectionSettingsService
            = CourseConnectionSettingsService.getInstance();

        CourseConSettingHealthCheckVMapper courseConHealthCheckVMapper =
            CourseConSettingHealthCheckVMapper.getInstance();

        Test.startTest();
            CourseConnectionSettingsService courseConSettingsService
                = courseConHealthCheckVMapper.locateCourseConnectionSettingsService();
        Test.stopTest();

        System.assertNotEquals(
            null,
            courseConSettingsService,
            'Instance of service class should not be null.'
        );

        System.assertEquals(
            expectedCourseConnectionSettingsService,
            courseConSettingsService,
            'Instance of service class from view model mapper should match the singleton instance.'
        );
    }

    /***************************************************************************
    * @description Test method to verify that a
    * RecordTypeService is retrieved by the locator method.
    ***************************************************************************/
    @isTest 
    private static void locateRecordTypeService(){
        RecordTypeService expectedRecordTypeService
            = RecordTypeService.getInstance();

        CourseConSettingHealthCheckVMapper courseConHealthCheckVMapper =
            CourseConSettingHealthCheckVMapper.getInstance();

        Test.startTest();
            RecordTypeService recTypeService
                = courseConHealthCheckVMapper.locateRecordTypeService();
        Test.stopTest();

        System.assertNotEquals(
            null,
            recTypeService,
            'Instance of service class should not be null.'
        );

        System.assertEquals(
            expectedRecordTypeService,
            recTypeService,
            'Instance of service class from view model mapper should match the singleton instance.'
        );
    }


    /*********************************************************************************************************
    ******************************* STUB *******************************************************************
    *********************************************************************************************************/

    /*************************************************************************************************
    * @description Stub class to simulate the response from CourseConnectionSettingsService
    *  to return a predetermined a Course Connection model with Course Connection Enabled as True.
    **************************************************************************************************/
    private class STUB_CourseConnectionSettingsService_Enabled extends CourseConnectionSettingsService {

        public override CourseConnectionSettingsModel getCourseConnectionSettingsModel() {
            
            CourseConnectionSettingsModel courseConnSettingsModel = 
                new CourseConnectionSettingsModel(
                    true,
                    '01217000002Zs0pAAC',
                    '01217000002Zs0pAAC'
                );

            return courseConnSettingsModel;
        }
    }
    
    /*************************************************************************************************
    * @description Stub class to simulate the response from CourseConnectionSettingsService
    *  to return a predetermined a Course Connection model with Course Connection Enabled as False.
    **************************************************************************************************/
    private class STUB_CourseConnectionSettingsService_Disbaled extends CourseConnectionSettingsService {

        public override CourseConnectionSettingsModel getCourseConnectionSettingsModel() {
            
            CourseConnectionSettingsModel courseConnSettingsModel = 
                new CourseConnectionSettingsModel(
                    false,
                    '01217000002Zs0pAAC',
                    '01217000002Zs0pAAC'
                );

            return courseConnSettingsModel;
        }
    }
    
    /****************************************************************************
    * @description Stub class to simulate the response from
    * RecordTypeService to return a predetermined map of Id to Record type models
    ***************************************************************************/
    private class STUB_RecordTypeService extends RecordTypeService {

        public override  Map<Id, RecordTypeModel> getModelByIdMapForSObjectType(Schema.SObjectType sObjectType) {
            
            RecordTypeModel recTypeModel = 
                new RecordTypeModel(
                    '0121A000002Zs0pAAA',
                    'Faculty',
                    'Faculty',
                    true
                );
            
            Map<Id, RecordTypeModel> recTypemodelByID = new Map<Id, RecordTypeModel>{'0121A000002Zs0pAAA' => recTypeModel};
            
            return recTypemodelByID;
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
                                                               HealthCheckGroupVModel hlthCheckGroupResult){

        System.assertEquals(expectedLabel, hlthCheckGroupResult.label, 'Should have \'' + expectedLabel + '\' label.');
        System.assertEquals(expectedStatus, hlthCheckGroupResult.status, 'Should have status of \'' + expectedStatus + '\'.');
        System.assertEquals(expectedPassedCheckCount, hlthCheckGroupResult.passedChecks, 'Should have ' + expectedPassedCheckCount + ' passed checks.');
        System.assertEquals(expectedTotalCheckCount, hlthCheckGroupResult.totalChecks, 'Should have ' + expectedTotalCheckCount + ' check.');
        System.assertEquals(expectedExpandedRowSize, hlthCheckGroupResult.expandedRowsList.size(), 'Should have ' + expectedExpandedRowSize + ' expanded rows.');
        System.assertEquals(expectedHealthCheckItemListSize, hlthCheckGroupResult.healthCheckItemList.size(), 'Should have ' + expectedHealthCheckItemListSize + ' health check item.');
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

        for (HealthCheckItemVModel hlthChkItmVMod : healthCheckItemList){
            System.assertEquals(expectedSetting, hlthChkItmVMod.setting, 'Health Check Item setting should be \'' + expectedSetting + '\'.');
            System.assertEquals(expectedStatus, hlthChkItmVMod.status, 'Health Check Item status should be \'' + expectedStatus + '\'.');
            System.assertEquals(expectedStatusLabel, hlthChkItmVMod.statusLabel, 'Health Check Item status label should be \'' + expectedStatusLabel + '\'.');
            System.assertEquals(expectedDescription, hlthChkItmVMod.description, 'Health Check Item description should be correctly set.');
            System.assertEquals(expectedFix, hlthChkItmVMod.recommendedFix, 'Health Check Item recommended fix should be correctly set.');
        }        
    }
}