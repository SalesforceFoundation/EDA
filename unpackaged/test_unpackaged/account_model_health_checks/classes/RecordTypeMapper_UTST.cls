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
* @description Unmanaged test class for RecordTypeMapper
*/
@isTest
private class RecordTypeMapper_UTST {

    /**************************************************************************************************************************
    * @description Test method to verify that the getModelByIdMapForSObjectType returns correct record type model by id map.
    * Make sure that no inactive record type is included in this map.
    ***************************************************************************************************************************/
    @isTest
    private static void getModelByIdMapForSObjectTypeAccountInactiveRecordTypeTest() {
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

        Boolean foundInactiveRecordType = false;

        for(Schema.RecordTypeInfo recordTypeInfo : accountDeveloperNameMap.values()) {
            RecordTypeModel recordTypeModel = recordTypeModelById.get(recordTypeInfo.getRecordTypeId());

            System.assertNotEquals(null,recordTypeModel,'All record types for an object should have a corresponding record type model.');

            if(recordTypeModel.developerName == 'An_Inactive_Record_Type') {
                foundInactiveRecordType = true;
            }

            System.assertEquals(recordTypeInfo.getRecordTypeId(),recordTypeModel.id,'The record type model for a record type should have the same Id.');
            System.assertEquals(recordTypeInfo.getName(),recordTypeModel.name,'The record type model for a record type should have the same name.');
            System.assertEquals(recordTypeInfo.getDeveloperName(),recordTypeModel.developerName,'The record type model for a record type should have the same developer name.');
            System.assertEquals(recordTypeInfo.isActive(),recordTypeModel.isActive,'The record type model for a record type should have the same is active flag.');
        }

        System.assertEquals(true,foundInactiveRecordType,'The inactive record type provided by the configuration should be found.');
    }
}
