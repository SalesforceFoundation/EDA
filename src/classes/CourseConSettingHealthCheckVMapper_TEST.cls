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
    ************************ HEALTH CHECK GROUP ********************************
    ***************************************************************************/

    /***************************************************************************
    * @description Test method to verify that getHealthCheckGroup handles all
    * passed health checks
    ***************************************************************************/
    @isTest
    private static void getHealthCheckGroupAllPassed() {

        CourseConnectionSettingsService.instance = 
            new STUB_CourseConnectionSettingsService_Enabled();

        RecordTypeService.instance =
            new STUB_RecordTypeServiceAll();

        CourseConSettingHealthCheckVMapper courseConHealthCheckVMapperInstance =
            CourseConSettingHealthCheckVMapper.getInstance();
 
        Test.startTest();
            HealthCheckGroupVModel healthChkVModel = courseConHealthCheckVMapperInstance.getHealthCheckGroup();
        Test.stopTest();

        System.assertEquals(
            Label.stgHCCourseConnectionsTitle,
            healthChkVModel.label,
            'Label of returned health check should match expected custom label.'
        );
        System.assertEquals(
            Label.stgHealthCheckStatusPassed,
            healthChkVModel.status,
            'Status of returned health check should match expected custom label.'
        );
        System.assertEquals(
            3,
            healthChkVModel.passedChecks,
            'Number of passed checks of returned health check should be 3.'
        );
        System.assertEquals(
            3,
            healthChkVModel.totalChecks,
            'Number of total checks of returned health check should be 3.'
        );
        System.assertEquals(
            0,
            healthChkVModel.expandedRowsList.size(),
            'No health checks should fail, making expanded rows list size 0.'
        );
        System.assertEquals(
            3,
            healthChkVModel.healthCheckItemList.size(),
            'Number of health check items of returned health check should be 3.'
        );
    }

    /***************************************************************************
    * @description Test method to verify that getHealthCheckGroup handles all
    * failed health checks when Course Connection is enabled
    ***************************************************************************/
    @isTest
    private static void getHealthCheckGroupAllFailedWhenCourseConnEnabled() {

        CourseConnectionSettingsService.instance = 
            new STUB_CourseConnectionSettingsService_EnabledWithSameIds();

        RecordTypeService.instance =
            new STUB_RecordTypeServiceAll();

        CourseConSettingHealthCheckVMapper courseConHealthCheckVMapperInstance =
            CourseConSettingHealthCheckVMapper.getInstance();
 
        Test.startTest();
            HealthCheckGroupVModel healthChkVModel = courseConHealthCheckVMapperInstance.getHealthCheckGroup();
        Test.stopTest();

        System.assertEquals(
            Label.stgHCCourseConnectionsTitle,
            healthChkVModel.label,
            'Label of returned health check should match expected custom label.'
        );
        System.assertEquals(
            Label.stgHealthCheckStatusFailed,
            healthChkVModel.status,
            'Status of returned health check should match expected custom label.'
        );
        System.assertEquals(
            0,
            healthChkVModel.passedChecks,
            'No health check should be passed.'
        );
        System.assertEquals(
            3,
            healthChkVModel.totalChecks,
            'Number of total checks of returned health check should be 4.'
        );
        System.assertEquals(
            0,
            healthChkVModel.expandedRowsList.size(),
            'No health checks should fail, making expanded rows list size 0.'
        );
        System.assertEquals(
            3,
            healthChkVModel.healthCheckItemList.size(),
            'Number of health check items of returned health check should be 4.'
        );
    }

    /***************************************************************************
    * @description Test method to verify that getHealthCheckGroup handles only
    * one health check when Course Connection is disabled
    ***************************************************************************/
    @isTest
    private static void getHealthCheckGroupCourseConDisabled() {

        CourseConnectionSettingsService.instance = 
            new STUB_CourseConnectionSettingsService_Disabled();

        RecordTypeService.instance =
            new STUB_RecordTypeServiceAll();

        CourseConSettingHealthCheckVMapper courseConHealthCheckVMapperInstance =
            CourseConSettingHealthCheckVMapper.getInstance();
 
        Test.startTest();
            HealthCheckGroupVModel healthChkVModel = courseConHealthCheckVMapperInstance.getHealthCheckGroup();
        Test.stopTest();

        System.assertEquals(
            Label.stgHCCourseConnectionsTitle,
            healthChkVModel.label,
            'Label of returned health check should match expected custom label.'
        );
        System.assertEquals(
            Label.stgHealthCheckStatusFailed,
            healthChkVModel.status,
            'Status of returned health check should match expected custom label.'
        );
        System.assertEquals(
            0,
            healthChkVModel.passedChecks,
            'No health check should be passed.'
        );
        System.assertEquals(
            1,
            healthChkVModel.totalChecks,
            'Number of total checks of returned health check should be 1 as we do not run other health checks if Course Connection is disabled.'
        );
        System.assertEquals(
            0,
            healthChkVModel.expandedRowsList.size(),
            'No health checks should fail, making expanded rows list size 0.'
        );
        System.assertEquals(
            1,
            healthChkVModel.healthCheckItemList.size(),
            'Number of health check items of returned health check should be 4.'
        );
    }

    /*************************************************************************************
    *************** combineAccountHealthCheckGroupViewModels *****************************
    *************************************************************************************/

    /**************************************************************************************************************************
    * @description Test to verify combineAccountHealthCheckGroupViewModels() returns a combined HealthCheckGroupVModel comprised of
    * the combined properties of the group view models passed as arguments.
    **************************************************************************************************************************/ 
    @isTest 
    private static void combineAccountHealthCheckGroupViewModelsValid(){

        List<HealthCheckGroupVModel> tstHlthChkGroupModelsList = new List<HealthCheckGroupVModel>();
        List<HealthCheckItemVModel> group1HlthChkItemList = new List<HealthCheckItemVModel>();

        group1HlthChkItemList.add(new HealthCheckItemVModel('Key1',
                                                            'Setting-X',
                                                            'Pass',
                                                            'PassedLabel',
                                                            'Description',
                                                            'RecommendedFix',
                                                            new List<HealthCheckItemVModel>()));
                                                            
        group1HlthChkItemList.add(new HealthCheckItemVModel('Key2',
                                                            'Setting-B',
                                                            'Pass',
                                                            'PassedLabel',
                                                            'Description',
                                                            'RecommendedFix',
                                                            new List<HealthCheckItemVModel>()));

        group1HlthChkItemList.add(new HealthCheckItemVModel('Key3',
                                                            'Setting-Y',
                                                            'Fail',
                                                            'FailedLabel',
                                                            'Description',
                                                            'RecommendedFix',
                                                            new List<HealthCheckItemVModel>()));


        tstHlthChkGroupModelsList.add(new HealthCheckGroupVModel('SubGroup1',
                                                                 'Fail',
                                                                 2,
                                                                 3,
                                                                 new List<String>(),
                                                                 group1HlthChkItemList));

        tstHlthChkGroupModelsList.add(new HealthCheckGroupVModel('SubGroup2',
                                                                 'Pass',
                                                                 1,
                                                                 1,
                                                                 new List<String>(),
                                                                 new List<HealthCheckItemVModel>()));


        Test.startTest();
            HealthCheckGroupVModel hlthChkGroupVMod = CourseConSettingHealthCheckVMapper.getInstance().combineAccountHealthCheckGroupViewModels(tstHlthChkGroupModelsList);
        Test.stopTest();

        System.assertEquals(Label.stgHCCourseConnectionsTitle, hlthChkGroupVMod.label, 'Group label should be \'' + Label.stgHCCourseConnectionsTitle + '\'');
        System.assertEquals(Label.stgHealthCheckStatusFailed, hlthChkGroupVMod.status, 'Group status should be \'' + Label.stgHealthCheckStatusFailed + '\'');
        System.assertEquals(3, hlthChkGroupVMod.passedChecks, 'Group passed checks should be \'' + hlthChkGroupVMod.passedChecks + '\'');
        System.assertEquals(4, hlthChkGroupVMod.totalChecks, 'Group total checks should be \'' + hlthChkGroupVMod.totalChecks + '\'');
        System.assertEquals(3, hlthChkGroupVMod.healthCheckItemList.size(), 'Group HealthCheckItems list should have \'' + hlthChkGroupVMod.healthCheckItemList.size() + '\' items');

        System.assertEquals('Setting-Y', hlthChkGroupVMod.healthCheckItemList[0].setting, 'HealthCheckItemList should be sorted alphabetically by Setting, with Failed items prioritized.');
        System.assertEquals('Setting-B', hlthChkGroupVMod.healthCheckItemList[1].setting, 'HealthCheckItemList should be sorted alphabetically by Setting, with Failed items prioritized.');
        System.assertEquals('Setting-X', hlthChkGroupVMod.healthCheckItemList[2].setting, 'HealthCheckItemList should be sorted alphabetically by Setting, with Failed items prioritized.');
    }

    /***************************************************************************
    *************** Course Connection Enable/Disable ***************************
    ***************************************************************************/

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
                                                                                       0,
                                                                                       0,
                                                                                       0,
                                                                                       0,
                                                                                       hCGroupVMdl);

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

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions('',
                                                                                       '',
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       1,
                                                                                       hCGroupVMdl);

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgEnableCourseConnectionsTitle,
                                                                                    'Fail',
                                                                                    Label.stgHealthCheckStatusWarning,
                                                                                    Label.stgHCCourseConEnable,
                                                                                    Label.stgHCCourseConEnableFix,
                                                                                    hCGroupVMdl.healthCheckItemList); 
    }

    /***************************************************************************
    *************** Student Health Check Items ********************************
    ***************************************************************************/

    /**************************************************************************************************************************
    * @description Test to verify getHouseholdAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * pass when the ID provided as the household AccountModel Id in AccountSettingsModel is valid and matches to a RT for HH 
    * Account Modelthat is valid and active.
    **************************************************************************************************************************/ 
    @isTest
    private static void getStudentHealthCheckItemsNotAnID(){
        RecordTypeService.instance = new STUB_RecordTypeServiceNUllModel();

        CourseConnectionSettingsModel courseConnModSettMod = 
                                            new CourseConnectionSettingsModel(true,
                                                                              '000000000000000002',
                                                                              'test');

        RecordTypeModel rtModel = new RecordTypeModel('000000000000000003',
                                                      'Test Record Name',
                                                      'testRecordDevName',
                                                      true);
                          
        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{rtModel.id => rtModel};

        Test.startTest();
        HealthCheckGroupVModel hlthChkGroupVMod = 
            CourseConSettingHealthCheckVMapper.getInstance().getStudentHealthCheckItems(courseConnModSettMod, recordTypeModelsById);
        Test.stopTest();

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions('',
                                                                                       '',
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       1,
                                                                                       hlthChkGroupVMod);

        String expectedDescription = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCRecordTypeNotFound, 
            new List<Object>{courseConnModSettMod.studentRecordTypeId}
        );
        String expectedFix = Label.stgHCCourseConStudentNotFoundFix;
        
        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgDefaultStudentTypeTitle, 
                                                                                   'Fail', 
                                                                                   Label.stgHealthCheckStatusFailed, 
                                                                                   expectedDescription, 
                                                                                   expectedFix, 
                                                                                   hlthChkGroupVMod.healthCheckItemList);
    }

    /**************************************************************************************************************************
    * @description Test to verify getHouseholdAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * pass when the ID provided as the household AccountModel Id in AccountSettingsModel is valid and matches to a RT for HH 
    * Account Modelthat is valid and active.
    **************************************************************************************************************************/ 
    @isTest
    private static void getStudentHealthCheckItemsIDNotInTheMap(){
        RecordTypeService.instance = new STUB_RecordTypeServiceNUllModel();

        CourseConnectionSettingsModel courseConnModSettMod = new CourseConnectionSettingsModel(true,
                                                                                        '000000000000000002',
                                                                                        '000000000000000003');

        RecordTypeModel rtModel = new RecordTypeModel('000000000000000004',
                                                      'Test Record Name',
                                                      'testRecordDevName',
                                                      true);

        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{rtModel.id => rtModel};

        Test.startTest();
        HealthCheckGroupVModel hlthChkGroupVMod = 
            CourseConSettingHealthCheckVMapper.getInstance().getStudentHealthCheckItems(courseConnModSettMod, recordTypeModelsById);
        Test.stopTest();

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions('',
                                                                                       '',
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       1,
                                                                                       hlthChkGroupVMod);

        String expectedDescription = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCRecordTypeNotFound, 
            new List<Object>{courseConnModSettMod.studentRecordTypeId}
        );
        String expectedFix = Label.stgHCCourseConStudentNotFoundFix;

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgDefaultStudentTypeTitle, 
                                                                                   'Fail', 
                                                                                   Label.stgHealthCheckStatusFailed, 
                                                                                   expectedDescription, 
                                                                                   expectedFix, 
                                                                                   hlthChkGroupVMod.healthCheckItemList);
    }

    /**************************************************************************************************************************
    * @description Test to verify getHouseholdAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * pass when the ID provided as the household AccountModel Id in AccountSettingsModel is valid and matches to a RT for HH 
    * Account Modelthat is valid and active.
    **************************************************************************************************************************/ 
    @isTest
    private static void getStudentHealthCheckItemsNotActive(){
        RecordTypeService.instance = new STUB_RecordTypeServiceValidInactive();

        CourseConnectionSettingsModel courseConnModSettMod = new CourseConnectionSettingsModel(true,
                                                                                              '000000000000000001',
                                                                                              '000000000000000002');

        RecordTypeModel rtModel = new RecordTypeModel('000000000000000001',
                                                      'Test Record Name',
                                                      'testRecordDevName',
                                                      false);

        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{rtModel.id => rtModel};

        Test.startTest();
        HealthCheckGroupVModel hlthChkGroupVMod = 
            CourseConSettingHealthCheckVMapper.getInstance().getStudentHealthCheckItems(courseConnModSettMod, recordTypeModelsById);
        Test.stopTest();

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions('',
                                                                                       '',
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       1,
                                                                                       hlthChkGroupVMod);

        String expectedDescription = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCRecordTypeInactive, 
            new List<Object>{rtModel.name, rtModel.developerName}
        );
        String expectedFix = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCCourseConStudentInactiveFix, 
            new List<Object>{rtModel.name, rtModel.developerName}
        );

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgDefaultStudentTypeTitle, 
                                                                                   'Fail', 
                                                                                   Label.stgHealthCheckStatusFailed, 
                                                                                   expectedDescription, 
                                                                                   expectedFix, 
                                                                                   hlthChkGroupVMod.healthCheckItemList);
    }

    /**************************************************************************************************************************
    * @description Test to verify getHouseholdAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * pass when the ID provided as the household AccountModel Id in AccountSettingsModel is valid and matches to a RT for HH 
    * Account Modelthat is valid and active.
    **************************************************************************************************************************/ 
    @isTest
    private static void getStudentHealthCheckItems(){
        RecordTypeService.instance = new STUB_RecordTypeServiceValidActive();

        CourseConnectionSettingsModel courseConnModSettMod = new CourseConnectionSettingsModel(true,
                                                                                              '000000000000000001',
                                                                                              '000000000000000002');

        RecordTypeModel rtModel = new RecordTypeModel('000000000000000001',
                                                      'Test Record Name',
                                                      'testRecordDevName',
                                                      true);

        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{rtModel.id => rtModel};

        Test.startTest();
        HealthCheckGroupVModel hlthChkGroupVMod = 
            CourseConSettingHealthCheckVMapper.getInstance().getStudentHealthCheckItems(courseConnModSettMod, recordTypeModelsById);
        Test.stopTest();

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions('',
                                                                                       '',
                                                                                       1,
                                                                                       1,
                                                                                       0,
                                                                                       1,
                                                                                       hlthChkGroupVMod);

        String expectedDescription = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCRecordTypeValid, 
            new List<Object>{rtModel.name, rtModel.developerName}
        );
        String expectedFix = Label.stgHealthCheckFixNotApplicable;

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgDefaultStudentTypeTitle, 
                                                                                   'Pass', 
                                                                                   Label.stgHealthCheckStatusPassed, 
                                                                                   expectedDescription, 
                                                                                   expectedFix, 
                                                                                   hlthChkGroupVMod.healthCheckItemList);
    }

    /***************************************************************************
    *************** Faculty Health Check Items ********************************
    ***************************************************************************/

    /**************************************************************************************************************************
    * @description Test to verify getHouseholdAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * pass when the ID provided as the household AccountModel Id in AccountSettingsModel is valid and matches to a RT for HH 
    * Account Modelthat is valid and active.
    **************************************************************************************************************************/ 
    @isTest
    private static void getFacultyHealthCheckItemsNotAnID(){
        RecordTypeService.instance = new STUB_RecordTypeServiceNUllModel();

        CourseConnectionSettingsModel courseConnModSettMod = new CourseConnectionSettingsModel(true,
                                                                                        '000000000000000002',
                                                                                        'test');

        RecordTypeModel rtModel = new RecordTypeModel('000000000000000003',
                                                      'Test Record Name',
                                                      'testRecordDevName',
                                                      true);
                          
        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{rtModel.id => rtModel};

        Test.startTest();
        HealthCheckGroupVModel hlthChkGroupVMod = 
            CourseConSettingHealthCheckVMapper.getInstance().getFacultyHealthCheckItems(courseConnModSettMod, recordTypeModelsById);
        Test.stopTest();

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions('',
                                                                                       '',
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       1,
                                                                                       hlthChkGroupVMod);

        String expectedDescription = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCRecordTypeNotFound, 
            new List<Object>{courseConnModSettMod.facultyRecordTypeId}
        );
        String expectedFix = Label.stgHCCourseConFacultyNotFoundFix;
        
        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgDefaultFacultyTypeTitle, 
                                                                                   'Fail', 
                                                                                   Label.stgHealthCheckStatusFailed, 
                                                                                   expectedDescription, 
                                                                                   expectedFix, 
                                                                                   hlthChkGroupVMod.healthCheckItemList);
    }

    /**************************************************************************************************************************
    * @description Test to verify getHouseholdAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * pass when the ID provided as the household AccountModel Id in AccountSettingsModel is valid and matches to a RT for HH 
    * Account Modelthat is valid and active.
    **************************************************************************************************************************/ 
    @isTest
    private static void getFacultyHealthCheckItemsIDNotInTheMap(){
        RecordTypeService.instance = new STUB_RecordTypeServiceNUllModel();

        CourseConnectionSettingsModel courseConnModSettMod = new CourseConnectionSettingsModel(true,
                                                                                        '000000000000000002',
                                                                                        '000000000000000003');

        RecordTypeModel rtModel = new RecordTypeModel('000000000000000004',
                                                      'Test Record Name',
                                                      'testRecordDevName',
                                                      true);

        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{rtModel.id => rtModel};

        Test.startTest();
        HealthCheckGroupVModel hlthChkGroupVMod = 
            CourseConSettingHealthCheckVMapper.getInstance().getFacultyHealthCheckItems(courseConnModSettMod, recordTypeModelsById);
        Test.stopTest();

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions('',
                                                                                       '',
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       1,
                                                                                       hlthChkGroupVMod);

        String expectedDescription = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCRecordTypeNotFound, 
            new List<Object>{courseConnModSettMod.facultyRecordTypeId}
        );
        String expectedFix = Label.stgHCCourseConFacultyNotFoundFix;

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgDefaultFacultyTypeTitle, 
                                                                                   'Fail', 
                                                                                   Label.stgHealthCheckStatusFailed, 
                                                                                   expectedDescription, 
                                                                                   expectedFix, 
                                                                                   hlthChkGroupVMod.healthCheckItemList);
    }

    /**************************************************************************************************************************
    * @description Test to verify getHouseholdAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * pass when the ID provided as the household AccountModel Id in AccountSettingsModel is valid and matches to a RT for HH 
    * Account Modelthat is valid and active.
    **************************************************************************************************************************/ 
    @isTest
    private static void getFacultyHealthCheckItemsNotActive(){
        RecordTypeService.instance = new STUB_RecordTypeServiceValidInactive();

        CourseConnectionSettingsModel courseConnModSettMod = new CourseConnectionSettingsModel(true,
                                                                                              '000000000000000001',
                                                                                              '000000000000000002');

        RecordTypeModel rtModel = new RecordTypeModel('000000000000000002',
                                                      'Test Record Name',
                                                      'testRecordDevName',
                                                      false);

        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{rtModel.id => rtModel};

        Test.startTest();
        HealthCheckGroupVModel hlthChkGroupVMod = 
            CourseConSettingHealthCheckVMapper.getInstance().getFacultyHealthCheckItems(courseConnModSettMod, recordTypeModelsById);
        Test.stopTest();

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions('',
                                                                                       '',
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       1,
                                                                                       hlthChkGroupVMod);

        String expectedDescription = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCRecordTypeInactive, 
            new List<Object>{rtModel.name, rtModel.developerName}
        );
        String expectedFix = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCCourseConFacultyInactiveFix, 
            new List<Object>{rtModel.name, rtModel.developerName}
        );

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgDefaultFacultyTypeTitle, 
                                                                                   'Fail', 
                                                                                   Label.stgHealthCheckStatusFailed, 
                                                                                   expectedDescription, 
                                                                                   expectedFix, 
                                                                                   hlthChkGroupVMod.healthCheckItemList);
    }

    /**************************************************************************************************************************
    * @description Test to verify getHouseholdAccountModelHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * pass when the ID provided as the household AccountModel Id in AccountSettingsModel is valid and matches to a RT for HH 
    * Account Modelthat is valid and active.
    **************************************************************************************************************************/ 
    @isTest
    private static void getFacultyHealthCheckItems(){
        RecordTypeService.instance = new STUB_RecordTypeServiceValidActive();

        CourseConnectionSettingsModel courseConnModSettMod = new CourseConnectionSettingsModel(true,
                                                                                              '000000000000000001',
                                                                                              '000000000000000002');

        RecordTypeModel rtModel = new RecordTypeModel('000000000000000002',
                                                      'Test Record Name',
                                                      'testRecordDevName',
                                                      true);

        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{rtModel.id => rtModel};

        Test.startTest();
        HealthCheckGroupVModel hlthChkGroupVMod = 
            CourseConSettingHealthCheckVMapper.getInstance().getFacultyHealthCheckItems(courseConnModSettMod, recordTypeModelsById);
        Test.stopTest();

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions('',
                                                                                       '',
                                                                                       1,
                                                                                       1,
                                                                                       0,
                                                                                       1,
                                                                                       hlthChkGroupVMod);

        String expectedDescription = StringHandlingService.getInstance().formatStringWithApostrophesAndParameters(
            Label.stgHCRecordTypeValid, 
            new List<Object>{rtModel.name, rtModel.developerName}
        );
        String expectedFix = Label.stgHealthCheckFixNotApplicable;

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgDefaultFacultyTypeTitle, 
                                                                                   'Pass', 
                                                                                   Label.stgHealthCheckStatusPassed, 
                                                                                   expectedDescription, 
                                                                                   expectedFix, 
                                                                                   hlthChkGroupVMod.healthCheckItemList);
    }

    /*******************************************************************************************************
    *************** getCourseConnectionRecordTypeUniquenessHealthCheckItems ********************************
    *******************************************************************************************************/

    /**************************************************************************************************************************
    * @description Test to verify getAccountRecordTypeUniquenessHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * passed when Admin and HH account record types are not the same.
    **************************************************************************************************************************/ 
    @isTest
    private static void getCourseConnectionRecordTypeUniquenessHealthCheckItemsPass(){

        CourseConnectionSettingsModel courseConnSettingsModel = new CourseConnectionSettingsModel(
            true,
            '01217000002Zs0pAAC',
            '01217000002Zs0pAAZ'
        );

        Test.startTest();
        HealthCheckGroupVModel hlthChkGroupVMod = 
            CourseConSettingHealthCheckVMapper.getInstance().getCourseConnectionRecordTypeUniquenessHealthCheckItems(courseConnSettingsModel);
        Test.stopTest();

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions('',
                                                                                       '',
                                                                                       1,
                                                                                       1,
                                                                                       0,
                                                                                       1,
                                                                                       hlthChkGroupVMod);

        String expectedDescription = Label.stgHCCourseConRecordTypesUniqueDesc;
        String expectedFix = Label.stgHealthCheckFixNotApplicable;

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgHCCourseConRecordTypesUnique, 
                                                                                    'Pass', 
                                                                                    Label.stgHealthCheckStatusPassed, 
                                                                                    expectedDescription, 
                                                                                    expectedFix, 
                                                                                    hlthChkGroupVMod.healthCheckItemList);
    }

    /**************************************************************************************************************************
    * @description Test to verify getAccountRecordTypeUniquenessHealthCheckItems() returns a HealthCheckGroupVModel with a status of
    * passed when Admin and HH account record types are not the same.
    **************************************************************************************************************************/ 
    @isTest
    private static void getCourseConnectionRecordTypeUniquenessHealthCheckItemsFail(){

        CourseConnectionSettingsModel courseConnSettingsModel = new CourseConnectionSettingsModel(
            true,
            '01217000002Zs0pAAz',
            '01217000002Zs0pAAz'
        );

        Test.startTest();
        HealthCheckGroupVModel hlthChkGroupVMod = 
            CourseConSettingHealthCheckVMapper.getInstance().getCourseConnectionRecordTypeUniquenessHealthCheckItems(courseConnSettingsModel);
        Test.stopTest();

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckGroupVModelAssertions('',
                                                                                       '',
                                                                                       0,
                                                                                       1,
                                                                                       0,
                                                                                       1,
                                                                                       hlthChkGroupVMod);

        String expectedDescription = Label.stgHCCourseConRecordTypesNotUnique;
        String expectedFix = Label.stgHCCourseConRecordTypesNotUniqueFix;

        CourseConSettingHealthCheckVMapper_TEST.verifyHealthCheckItemListAssertions(Label.stgHCCourseConRecordTypesUnique, 
                                                                                    'Fail', 
                                                                                    Label.stgHealthCheckStatusFailed, 
                                                                                    expectedDescription, 
                                                                                    expectedFix, 
                                                                                    hlthChkGroupVMod.healthCheckItemList);
    }

    /***************************************************************************
    *****************************  LOCATORS ************************************
    ***************************************************************************/
    
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

    /***************************************************************************
    * @description Test method to verify that a
    * StringHandlingService is retrieved by the locator method.
    ***************************************************************************/
    @isTest 
    private static void locateStringHandlingService(){
        StringHandlingService expectedStringHandlingService
            = StringHandlingService.getInstance();

        CourseConSettingHealthCheckVMapper courseConHealthCheckVMapper =
            CourseConSettingHealthCheckVMapper.getInstance();

        Test.startTest();
            StringHandlingService stringHandlingService
                = courseConHealthCheckVMapper.locateStringHandlingService();
        Test.stopTest();

        System.assertNotEquals(
            null,
            stringHandlingService,
            'Instance of service class should not be null.'
        );

        System.assertEquals(
            expectedStringHandlingService,
            stringHandlingService,
            'Instance of service class from view model mapper should match the singleton instance.'
        );
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

    /*********************************************************************************************************
    ********************************* STUB *******************************************************************
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
                    '0121A000002Zs0pAAC',
                    '0121A000002Zs0pAAB'
                );

            return courseConnSettingsModel;
        }
    }
    
    /*************************************************************************************************
    * @description Stub class to simulate the response from CourseConnectionSettingsService
    *  to return a predetermined a Course Connection model with Course Connection Enabled as False.
    **************************************************************************************************/
    private class STUB_CourseConnectionSettingsService_Disabled extends CourseConnectionSettingsService {

        public override CourseConnectionSettingsModel getCourseConnectionSettingsModel() {

            CourseConnectionSettingsModel courseConnSettingsModel = 
                new CourseConnectionSettingsModel(
                    false,
                    '000000000000000000',
                    '000000000000000000'
                );

            return courseConnSettingsModel;
        }
    }
    
    /*************************************************************************************************
    * @description Stub class to simulate the response from CourseConnectionSettingsService
    *  to return a predetermined a Course Connection model with Course Connection Enabled as True.
    **************************************************************************************************/
    private class STUB_CourseConnectionSettingsService_EnabledWithSameIds extends CourseConnectionSettingsService {

        public override CourseConnectionSettingsModel getCourseConnectionSettingsModel() {

            CourseConnectionSettingsModel courseConnSettingsModel = 
                new CourseConnectionSettingsModel(
                    true,
                    '000000000000000000',
                    '000000000000000000'
                );

            return courseConnSettingsModel;
        }
    }

    /****************************************************************************
    * @description Stub class to simulate the response from
    * RecordTypeService to return a predetermined map of Id to Record type models
    *****************************************************************************/
    private class STUB_RecordTypeServiceAll extends RecordTypeService {

        public override  Map<Id, RecordTypeModel> getModelByIdMapForSObjectType(Schema.SObjectType sObjectType) {

            RecordTypeModel recTypeModel1 = 
                new RecordTypeModel(
                    '01217000002Zs0pAAC',
                    'test1 name',
                    'test1 dev name',
                    true
                );

            RecordTypeModel recTypeModel2 = 
                new RecordTypeModel(
                    '01217000002Zs0pAAB',
                    'test2 name',
                    'test2 dev name',
                    true
                );

            Map<Id, RecordTypeModel> recTypemodelByID = new Map<Id, RecordTypeModel>{'0121A000002Zs0pAAC' => recTypeModel1, 
                                                                                     '0121A000002Zs0pAAB' => recTypeModel2};

            return recTypemodelByID;
        }
    }

    /****************************************************************************************************************************************************
    * @description Stub class to simulate the response from RecordTypeService to return a valid and active RecordTypeModel from getRecordTypeModelFromMap.
    *****************************************************************************************************************************************************/ 
    private class STUB_RecordTypeServiceNUllModel extends RecordTypeService {
        public override RecordTypeModel getRecordTypeModelFromMap(String recordTypeId, Map<Id, RecordTypeModel> recordTypeModelById) { 
            return null;
        }
    }

    /****************************************************************************************************************************************************
    * @description Stub class to simulate the response from RecordTypeService to return a valid and active RecordTypeModel from getRecordTypeModelFromMap.
    ****************************************************************************************************************************************************/ 
    private class STUB_RecordTypeServiceValidInactive extends RecordTypeService {
        public override RecordTypeModel getRecordTypeModelFromMap(String recordTypeId, Map<Id, RecordTypeModel> recordTypeModelById) { 
            RecordTypeModel rtModel = new RecordTypeModel('000000000000000002',
                                                          'Test Record Name',
                                                          'testRecordDevName',
                                                          false);
            return rtModel;
        }
    }

    /****************************************************************************************************************************************************
    * @description Stub class to simulate the response from RecordTypeService to return a valid and active RecordTypeModel from getRecordTypeModelFromMap.
    ****************************************************************************************************************************************************/ 
    private class STUB_RecordTypeServiceValidActive extends RecordTypeService {
        public override RecordTypeModel getRecordTypeModelFromMap(String recordTypeId, Map<Id, RecordTypeModel> recordTypeModelById) { 
            RecordTypeModel rtModel = new RecordTypeModel('000000000000000002',
                                                          'Test Record Name',
                                                          'testRecordDevName',
                                                          true);
            return rtModel;
        }
    }
}