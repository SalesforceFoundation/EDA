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
 * @description Test class for CourseConnectionSettingsVMapper.
 */
@isTest
private with sharing class CourseConnectionSettingsVMapper_TEST {
    private static Integer loopCounter = 5;
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * CourseConnectionSettingsVMapper class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        CourseConnectionSettingsVMapper courseConnectionSettingsVMapperInstance = CourseConnectionSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            CourseConnectionSettingsVMapper.instance,
            courseConnectionSettingsVMapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            courseConnectionSettingsVMapperInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * CourseConnectionSettingsVMapper class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        CourseConnectionSettingsVMapper courseConnectionSettingsVMapperInstance1 = CourseConnectionSettingsVMapper.getInstance();
        CourseConnectionSettingsVMapper courseConnectionSettingsVMapperInstance2 = CourseConnectionSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            CourseConnectionSettingsVMapper.instance,
            courseConnectionSettingsVMapperInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            courseConnectionSettingsVMapperInstance1,
            courseConnectionSettingsVMapperInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            courseConnectionSettingsVMapperInstance1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test to verify locateCourseConnectionSettingsService() returns an instance of the CourseConnectionSettingsService class.
     **************************************************************************************************************************/
    @isTest
    private static void locateCourseConnectionSettingsService() {
        CourseConnectionSettingsVMapper courseConnectionSettingsVMapperInstance = CourseConnectionSettingsVMapper.getInstance();

        Test.startTest();
        CourseConnectionSettingsService courseConnectionSettingsServiceInstance = courseConnectionSettingsVMapperInstance.locateCourseConnectionSettingsService();
        Test.stopTest();

        System.assertEquals(
            CourseConnectionSettingsService.getInstance(),
            courseConnectionSettingsServiceInstance,
            'Should return instance of locateAddressSettingsService class.'
        );
        System.assertEquals(
            true,
            courseConnectionSettingsServiceInstance != null,
            'Instance of locateAddressSettingsService class should not be null.'
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

    /*************************************************************************************************************
     * @description Test method to verify getCourseConnectionSettingsVModel() returns valid CourseConnectionSettingsVModel
     *************************************************************************************************************/
    @isTest
    private static void getCourseConnectionSettingsVModelValid() {
        RecordTypeMapper.instance = new STUB_RecordTypeMapper();
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Enable_Course_Connections__c = true,
                Student_RecType__c = '000000000000000001',
                Faculty_RecType__c = '000000000000000001'
            )
        );

        CourseConnectionSettingsVMapper courseConnectionSettingsVMapperInstance = CourseConnectionSettingsVMapper.getInstance();

        Test.startTest();
        CourseConnectionSettingsVModel courseConnectionSettingsVModel = courseConnectionSettingsVMapperInstance.getCourseConnectionSettingsVModel();
        Test.stopTest();

        System.assertEquals(
            true,
            courseConnectionSettingsVModel.courseConnectionRecordTypes,
            'courseConnectionRecordTypes should be true'
        );

        System.assertEquals(
            1,
            courseConnectionSettingsVModel.defaultStudentRecType.options.size(),
            'courseConnectionRecordTypes should be retrieved'
        );

        System.assertEquals(
            '000000000000000001',
            courseConnectionSettingsVModel.defaultFacultyRecType.value,
            'courseConnectionRecordTypes should be retrieved'
        );

        System.assertEquals(
            1,
            courseConnectionSettingsVModel.defaultFacultyRecType.options.size(),
            'courseConnectionRecordTypes should be retrieved'
        );

        System.assertEquals(
            '000000000000000001',
            courseConnectionSettingsVModel.defaultFacultyRecType.value,
            'courseConnectionRecordTypes should be true'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getComboboxVModelOptionsForActiveCourseConnRecordTypes returns an list of ComboboxValueVModels
     * corresponding to all active Course Connection Record Types.
     ***********************************************************************************************************************************/
    @isTest
    private static void getComboboxVModelOptionsForActiveCourseConnRecordTypesValid() {
        List<RecordTypeModel> recordTypeModelsList = new List<RecordTypeModel>();

        for (Integer i = 0; i < loopCounter; i++) {
            recordTypeModelsList.add(
                new RecordTypeModel('00000000000000000' + i, 'Active RecordType ' + i, 'Active_RecordType_' + i, true)
            );
        }

        CourseConnectionSettingsVMapper courseConnectionSettingsVMapperInstance = CourseConnectionSettingsVMapper.getInstance();

        Test.startTest();
        List<ComboboxValueVModel> comboboxValueVModelsList = courseConnectionSettingsVMapperInstance.getComboboxVModelOptionsForActiveCourseConnRecordTypes(
            recordTypeModelsList
        );
        Test.stopTest();

        System.assertEquals(
            loopCounter,
            comboboxValueVModelsList.size(),
            'Should return ' +
            loopCounter +
            ' ComboboxValueVModels.'
        );

        for (Integer i = 0; i < loopCounter; i++) {
            System.assertEquals(
                'Active RecordType ' + i,
                comboboxValueVModelsList[i].label,
                'Label should correspond to record type model name property.'
            );

            System.assertEquals(
                '00000000000000000' + i,
                comboboxValueVModelsList[i].value,
                'Value should correspond to record type model ID property.'
            );
        }
    }

    /**************************************************************************************************************************
     ****************************************************** STUBS **************************************************************
     **************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from RecordTypeMapper to return a map of Account Record Types, both active and inactive
     **************************************************************************************************************************************/
    private class STUB_RecordTypeMapper extends RecordTypeMapper {
        public override Map<Id, RecordTypeModel> getModelByIdMapForSObjectType(Schema.SObjectType sObjectType) {
            Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>();

            recordTypeModelsById.put(
                '000000000000000001',
                new RecordTypeModel('000000000000000001', 'Active Record Type 1', 'Active_Record_Type_1', true)
            );
            recordTypeModelsById.put(
                '000000000000000002',
                new RecordTypeModel('000000000000000002', 'Inactive Record Type 1', 'Inactive_Record_Type_1', false)
            );
            recordTypeModelsById.put(
                '000000000000000003',
                new RecordTypeModel('000000000000000003', 'Inactive Record Type 2', 'Inactive_Record_Type_2', false)
            );

            return recordTypeModelsById;
        }
    }
    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from RecordTypeMapper to return an empty map of Account Record Types
     **************************************************************************************************************************************/
    private class STUB_RecordTypeMapperEmpty extends RecordTypeMapper {
        public override Map<Id, RecordTypeModel> getModelByIdMapForSObjectType(Schema.SObjectType sObjectType) {
            return new Map<Id, RecordTypeModel>();
        }
    }
}
