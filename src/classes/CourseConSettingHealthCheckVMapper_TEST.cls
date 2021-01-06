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
    * @description Tests for getHealthCheckGroup method
    ***************************************************************************/
    @isTest
    private static void getHealthCheckGroup() {
        CourseConSettingHealthCheckVMapper courseConSettingHealthCheckVMapperInstance =
            CourseConSettingHealthCheckVMapper.getInstance();
        
        Test.startTest();
            HealthCheckGroupVModel hCGroupVMdl = courseConSettingHealthCheckVMapperInstance.getHealthCheckGroup();
        Test.stopTest();

    }
    
    /***************************************************************************
    * @description Test method to verify that getHealthCheckGroup handles all
    * passed health checks
    ***************************************************************************/
    @isTest
    private static void getHealthCheckGroupAllFail() {
        
        RecordTypeService.instance = 
            new STUB_RecordTypeService();

        CourseConnectionSettingsService.instance =
            new STUB_CourseConnectionSettingsService();

        CourseConSettingHealthCheckVMapper courseConSettingHealthCheckVMapperInstance =
            CourseConSettingHealthCheckVMapper.getInstance();

        Test.startTest();
            HealthCheckGroupVModel hCGroupVMdl = CourseConSettingHealthCheckVMapper.getInstance().getHealthCheckGroup();
        Test.stopTest();

        System.assertEquals('Label.stgHCCourseConnectionsTitle', hCGroupVMdl.label, 'The label of the Course Connection Health Check should be retrieved');
        System.assertEquals('Label.stgDefaultFacultyTypeTitle', hCGroupVMdl.healthCheckItemList[0].setting, 'Faculty should be sorted as first element');
        System.assertEquals('Label.stgDefaultStudentTypeTitle', hCGroupVMdl.healthCheckItemList[1].setting, 'Student should be sorted as first element');
        System.assertEquals('Label.stgEnableCourseConnectionsTitle', hCGroupVMdl.healthCheckItemList[2].setting, 'Course Connection Enable check should be sorted last');
        System.assertEquals(Label.stgHealthCheckStatusFailed, hCGroupVMdl.status, 'The status of the checks should be retrieved');

    }

    /***************************************************************************
    * @description Test method to verify that a CourseConnectionSettingsService is
    * retrieved by the locator method.
    ***************************************************************************/
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
    ******************************* STUBS *************************************
    ***************************************************************************/

    /***************************************************************************
    * @description Stub class to simulate the response from
    * CourseConnectionSettingsService to return a predetermined set of models.
    ***************************************************************************/
    private class STUB_CourseConnectionSettingsService extends CourseConnectionSettingsService {

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
    
    
}