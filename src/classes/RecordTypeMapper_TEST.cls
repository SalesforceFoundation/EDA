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
* @description Test class for RecordTypeMapper
*/
@isTest
private class RecordTypeMapper_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * RecordTypeMapper class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        RecordTypeMapper recordTypeMapperInstance = RecordTypeMapper.getInstance();
        Test.stopTest();

        System.assertEquals(RecordTypeMapper.instance, recordTypeMapperInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, recordTypeMapperInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * RecordTypeMapper class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        RecordTypeMapper recordTypeMapperInstance1 = RecordTypeMapper.getInstance();

        Test.startTest();
            RecordTypeMapper recordTypeMapperInstance2 = RecordTypeMapper.getInstance();
        Test.stopTest();

        System.assertEquals(RecordTypeMapper.instance, recordTypeMapperInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(recordTypeMapperInstance1, recordTypeMapperInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, recordTypeMapperInstance1 != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getModelByIdMapForSObjectType returns correct record type model by id map.
    * Since unit tests have access to record types in the org, we will only check if admin record type exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getModelByIdMapForSObjectTypeAccountTest() {
        UTIL_Describe.populateRecordTypeInfoForSObject('Account');

        Map<String, Schema.RecordTypeInfo> accountDeveloperNameMap =
            UTIL_Describe.recordTypeInfoByDeveloperName.get('Account');

        Test.startTest();
            Map<Id, RecordTypeModel> recordTypeModelById = RecordTypeMapper.getInstance().getModelByIdMapForSObjectType(Account.getSobjectType());
        Test.stopTest();

        System.assertEquals(
            accountDeveloperNameMap.size(),
            recordTypeModelById.size(),
            'The number of record types for an object and the number of record type models for an object should be the same.'
        );

        for(Schema.RecordTypeInfo recordTypeInfo : accountDeveloperNameMap.values()) {
            RecordTypeModel recordTypeModel = recordTypeModelById.get(recordTypeInfo.getRecordTypeId());

            System.assertNotEquals(null,recordTypeModel,'All record types for an object should have a corresponding record type model.');
            System.assertEquals(recordTypeInfo.getRecordTypeId(),recordTypeModel.id,'The record type model for a record type should have the same Id.');
            System.assertEquals(recordTypeInfo.getName(),recordTypeModel.name,'The record type model for a record type should have the same name.');
            System.assertEquals(recordTypeInfo.getDeveloperName(),recordTypeModel.developerName,'The record type model for a record type should have the same developer name.');
            System.assertEquals(recordTypeInfo.isActive(),recordTypeModel.isActive,'The record type model for a record type should have the same is active flag.');
        }
    }
}