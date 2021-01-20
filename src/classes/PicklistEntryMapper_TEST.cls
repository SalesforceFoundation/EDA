/*
    Copyright (c) 2021, Salesforce.org
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
* @description Test class for PicklistEntryMapper
*/
@isTest
private class  PicklistEntryMapper_TEST {

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * PicklistEntryMapper class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            PicklistEntryMapper picklistEntryMapperInstance = PicklistEntryMapper.getInstance();
        Test.stopTest();

        System.assertEquals(PicklistEntryMapper.instance, picklistEntryMapperInstance, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(true, picklistEntryMapperInstance != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * PicklistEntryMapper class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            PicklistEntryMapper picklistEntryMapperInstance1 = PicklistEntryMapper.getInstance();
            PicklistEntryMapper picklistEntryMapperInstance2 = PicklistEntryMapper.getInstance();
        Test.stopTest();

        System.assertEquals(PicklistEntryMapper.instance, picklistEntryMapperInstance1, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(picklistEntryMapperInstance1, picklistEntryMapperInstance2, 'Subsequent retrievals of mapper class instance should return existing instance.');
        System.assertEquals(true, picklistEntryMapperInstance1 != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getModelsByNameForSObjectField method returns the picklist entry models
    ***************************************************************************************************************************/
    @isTest
    private static void getModelsByNameForSObjectField() {

        String prefix = UTIL_Namespace.StrTokenNSPrefix('');
        String objectName = UTIL_Namespace.StrTokenNSPrefix('Relationship__c');
        String fieldName = UTIL_Namespace.StrTokenNSPrefix('Type__c');

        SObjectType sObjectTypeName = UTIL_Describe.getObjectDescribe(objectName).getSObjectType();
        SObjectField sObjectFieldName = UTIL_Describe.getFieldDescribe(objectName, fieldName).getSObjectField();

        Test.startTest();
            Map<String, PicklistEntryModel> picklistEntryModelByPicklistEntryName = 
                PicklistEntryMapper.getInstance().getModelsByNameForSObjectField(sObjectTypeName, sObjectFieldName);
        Test.stopTest();

        List<Schema.PicklistEntry> picklistEntriesList = UTIL_Describe.getFieldPicklistEntries(objectName, fieldName);

        System.assertEquals(picklistEntriesList.size(), picklistEntryModelByPicklistEntryName.size(), 'Each picklist entry should have a corresponding model');

        for (Schema.PicklistEntry each: picklistEntriesList) {
            System.assertEquals(each.getValue(), picklistEntryModelByPicklistEntryName.get(each.getValue()).name, 'The value of the picklist entry should match with name property on the model');
            System.assertEquals(each.getLabel(), picklistEntryModelByPicklistEntryName.get(each.getValue()).label, 'The Label of the picklist entry should match with label property on the model');
            System.assertEquals(each.isActive(), picklistEntryModelByPicklistEntryName.get(each.getValue()).isActive, 'The active status of the picklist entry should match with isActive property on the model');
        }
    }
}