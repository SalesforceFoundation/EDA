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
* @description Test class for RecordTypeService
*/
@isTest
private class RecordTypeService_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * RecordTypeService class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        RecordTypeService recordTypeServiceInstance = RecordTypeService.getInstance();
        Test.stopTest();

        System.assertEquals(RecordTypeService.instance, recordTypeServiceInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, recordTypeServiceInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * RecordTypeService class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        RecordTypeService recordTypeServiceInstance1 = RecordTypeService.getInstance();

        Test.startTest();
            RecordTypeService recordTypeServiceInstance2 = RecordTypeService.getInstance();
        Test.stopTest();

        System.assertEquals(RecordTypeService.instance, recordTypeServiceInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(recordTypeServiceInstance1, recordTypeServiceInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertNotEquals(null, recordTypeServiceInstance1, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that a map of Record Type model by Id is returned by getModelByIdMapForSObjectType correctly
    ***************************************************************************************************************************/
    @isTest
    private static void getModelByIdMapForSObjectTypeTest() {
        RecordTypeMapper.instance = new STUB_RecordTypeMapper();

        Test.startTest();
            Map<Id, RecordTypeModel> recordTypeModelById = RecordTypeService.getInstance().getModelByIdMapForSObjectType(Account.getSobjectType());
        Test.stopTest();

        RecordTypeModel recordTypeModel = recordTypeModelById.get('000000000000000000');

        System.assertNotEquals(null, recordTypeModel, 'A record type model should be retrieved for a valid record type Id.');
        System.assertEquals(Id.valueOf('000000000000000000'), recordTypeModel.id,'The record type model for a record type should have the specified Id.');
        System.assertEquals('Household', recordTypeModel.name, 'The record type model for a record type should have the specified name.');
        System.assertEquals('Household Account', recordTypeModel.developerName, 'The record type model for a record type should have the specified developer name.');
        System.assertEquals(true, recordTypeModelById.get('000000000000000000').isActive, 'The record type model for a record type should have the specified is active flag.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that null is returned for valid id not in the map
    ***************************************************************************************************************************/
    @isTest
    private static void getRecordTypeModelFromMapValidIdNotInMapTest() {
        RecordTypeMapper.instance = new STUB_RecordTypeMapper();
        Map<Id, RecordTypeModel> recordTypeModelById = RecordTypeService.getInstance(
            ).getModelByIdMapForSObjectType(Account.getSobjectType());

        Test.startTest();
            RecordTypeModel recordTypeModel = RecordTypeService.getInstance(
                ).getRecordTypeModelFromMap('000000000000000001', recordTypeModelById);
        Test.stopTest();
        
        System.assertEquals(null, recordTypeModel, 'A record type model should not be returned for a record type that does not exist.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that null is returned for invalid id
    ***************************************************************************************************************************/
    @isTest
    private static void getRecordTypeModelFromMapInvalidIdTest() {
        RecordTypeMapper.instance = new STUB_RecordTypeMapper();
        Map<Id, RecordTypeModel> recordTypeModelById = RecordTypeService.getInstance(
            ).getModelByIdMapForSObjectType(Account.getSobjectType());

        Test.startTest();
            RecordTypeModel recordTypeModel = RecordTypeService.getInstance(
                ).getRecordTypeModelFromMap('invalid', recordTypeModelById);
        Test.stopTest();

        System.assertEquals(null, recordTypeModel, 'A record type model should not be returned for a non-id string value.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that a valid record type model is returned.
    ***************************************************************************************************************************/
    @isTest
    private static void getRecordTypeModelFromMapValidIdInMapTest() {
        RecordTypeMapper.instance = new STUB_RecordTypeMapper();

        Map<Id, RecordTypeModel> recordTypeModelById = RecordTypeService.getInstance().getModelByIdMapForSObjectType(Account.getSobjectType());
        
        Test.startTest();
            RecordTypeModel recordTypeModel = RecordTypeService.getInstance(
                ).getRecordTypeModelFromMap('000000000000000000', recordTypeModelById);
        Test.stopTest();

        System.assertNotEquals(null, recordTypeModel, 'A record type model should be retrieved for a valid record type Id.');
        System.assertEquals(Id.valueOf('000000000000000000'), recordTypeModel.id,'The record type model for a record type should have the specified Id.');
        System.assertEquals('Household', recordTypeModel.name, 'The record type model for a record type should have the specified name.');
        System.assertEquals('Household Account', recordTypeModel.developerName, 'The record type model for a record type should have the specified developer name.');
        System.assertEquals(true, recordTypeModelById.get('000000000000000000').isActive, 'The record type model for a record type should have the specified is active flag.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getRecordTypeModelFromNameAndLabelMaps returns a valid record type model when a match is found
    * for a specified developer name.
    ***************************************************************************************************************************/
    @isTest 
    private static void getRecordTypeModelFromNameAndLabelMapsByName() {
        Map<String, RecordTypeModel> recordTypeModelsByName = new Map<String, RecordTypeModel>{
            'Record_Type_1' => new RecordTypeModel(
                '000000000000000001', 
                'Record Type 1', 
                'Record_Type_1',
                true
            )
        };

        Map<String, RecordTypeModel> recordTypeModelsByLabel = new Map<String, RecordTypeModel>{
            'Record Type Label' => new RecordTypeModel(
                '000000000000000001', 
                'Record Type Label', 
                'Record_Type_Label',
                false
            )
        };

        RecordTypeService recordTypeServiceInstance = RecordTypeService.getInstance();

        Test.startTest();
        RecordTypeModel recordTypeModelResult = 
            recordTypeServiceInstance.getRecordTypeModelFromNameAndLabelMaps(
                'Record_Type_1',
                recordTypeModelsByName,
                recordTypeModelsByLabel
            );
        Test.stopTest();

        System.assertEquals('000000000000000001', recordTypeModelResult.id, 'Record type model name should be \'000000000000000001\'.');
        System.assertEquals('Record Type 1', recordTypeModelResult.name, 'Record type model name should be \'Record Type 1\'.');
        System.assertEquals('Record_Type_1', recordTypeModelResult.developerName, 'Record type model name should be \'Record_Type_1\'.');
        System.assertEquals(true, recordTypeModelResult.isActive, 'Record type model name should be \'true\'.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getRecordTypeModelFromNameAndLabelMaps returns a valid record type model when a match is found
    * for a specified label name.
    ***************************************************************************************************************************/
    @isTest 
    private static void getRecordTypeModelFromNameAndLabelMapsByLabel() {
        Map<String, RecordTypeModel> recordTypeModelsByName = new Map<String, RecordTypeModel>{
            'Record_Type_1' => new RecordTypeModel(
                '000000000000000001', 
                'Record Type 1', 
                'Record_Type_1',
                true
            )
        };

        Map<String, RecordTypeModel> recordTypeModelsByLabel = new Map<String, RecordTypeModel>{
            'Record Type Label' => new RecordTypeModel(
                '123000000000000000', 
                'Record Type Label', 
                'Record_Type_Label',
                false
            )
        };

        RecordTypeService recordTypeServiceInstance = RecordTypeService.getInstance();

        Test.startTest();
        RecordTypeModel recordTypeModelResult = 
            recordTypeServiceInstance.getRecordTypeModelFromNameAndLabelMaps(
                'Record Type Label',
                recordTypeModelsByName,
                recordTypeModelsByLabel
            );
        Test.stopTest();

        System.assertEquals('123000000000000000', recordTypeModelResult.id, 'Record type model name should be \'123000000000000000\'.');
        System.assertEquals('Record Type Label', recordTypeModelResult.name, 'Record type model name should be \'Record Type Label\'.');
        System.assertEquals('Record_Type_Label', recordTypeModelResult.developerName, 'Record type model name should be \'Record_Type_Label\'.');
        System.assertEquals(false, recordTypeModelResult.isActive, 'Record type model name should be \'false\'.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getRecordTypeModelFromNameAndLabelMaps returns a null record type model when no match is found
    * for a specified developer or label name.
    ***************************************************************************************************************************/
    @isTest 
    private static void getRecordTypeModelFromNameAndLabelMapsNull() {
        Map<String, RecordTypeModel> recordTypeModelsByName = new Map<String, RecordTypeModel>{
            'Record_Type_1' => new RecordTypeModel(
                '000000000000000001', 
                'Record Type 1', 
                'Record_Type_1',
                true
            )
        };

        Map<String, RecordTypeModel> recordTypeModelsByLabel = new Map<String, RecordTypeModel>{
            'Record Type Label' => new RecordTypeModel(
                '123000000000000000', 
                'Record Type Label', 
                'Record_Type_Label',
                false
            )
        };

        RecordTypeService recordTypeServiceInstance = RecordTypeService.getInstance();

        Test.startTest();
        RecordTypeModel recordTypeModelResult = 
            recordTypeServiceInstance.getRecordTypeModelFromNameAndLabelMaps(
                'Non Existent Record Type Name',
                recordTypeModelsByName,
                recordTypeModelsByLabel
            );
        Test.stopTest();

        System.assertEquals(null, recordTypeModelResult, 'Record type model should be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getRecordTypeModelByLabelPositive returns a map of record type models by label.
    ***************************************************************************************************************************/
    @isTest 
    private static void getRecordTypeModelByLabelPositive() {
        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{
            '000000000000000001' => new RecordTypeModel(
                '000000000000000001', 
                'Record Type 1', 
                'Record_Type_1',
                true
            ),

            '000000000000000002' => new RecordTypeModel(
                '000000000000000002', 
                'Record Type 2', 
                'Record_Type_2',
                false
            )
        };

        RecordTypeService recordTypeServiceInstance = RecordTypeService.getInstance();

        Test.startTest();
        Map<String, RecordTypeModel> recordTypeModelsByLabelResult = 
            recordTypeServiceInstance.getRecordTypeModelByLabel(recordTypeModelsById);
        Test.stopTest();

        System.assertEquals(true, recordTypeModelsByLabelResult.keySet().contains('Record Type 1'), 'Record type should be mapped by label name.');
        System.assertEquals(true, recordTypeModelsByLabelResult.keySet().contains('Record Type 2'), 'Record type should be mapped by label name.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getRecordTypeModelByLabelPositive returns a map of record type models by name.
    ***************************************************************************************************************************/
    @isTest 
    private static void getRecordTypeModelByNamePositive() {
        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{
            '000000000000000001' => new RecordTypeModel(
                '000000000000000001', 
                'Record Type 1', 
                'Record_Type_1',
                true
            ),

            '000000000000000002' => new RecordTypeModel(
                '000000000000000002', 
                'Record Type 2', 
                'Record_Type_2',
                false
            )
        };

        RecordTypeService recordTypeServiceInstance = RecordTypeService.getInstance();

        Test.startTest();
        Map<String, RecordTypeModel> recordTypeModelsByNameResult = 
            recordTypeServiceInstance.getRecordTypeModelByName(recordTypeModelsById);
        Test.stopTest();

        System.assertEquals(true, recordTypeModelsByNameResult.keySet().contains('Record_Type_1'), 'Record type should be mapped by developer name.');
        System.assertEquals(true, recordTypeModelsByNameResult.keySet().contains('Record_Type_2'), 'Record type should be mapped by developer name.');
    }

    /**************************************************************************************************************************
    ****************************************************** STUB CLASS *********************************************************
    **************************************************************************************************************************/

    /*************************************************************************************************************
    * @description Stub class to simulate the response from RecordTypeMapper to return a map of Record Type model by Id
    */
    private class STUB_RecordTypeMapper extends RecordTypeMapper {
        public override Map<Id, RecordTypeModel> getModelByIdMapForSObjectType(Schema.SObjectType sObjectType) {
            Map<Id, RecordTypeModel> stubRecordTypeModelById = new Map<Id, RecordTypeModel>();

            RecordTypeModel recordTypeModel = new RecordTypeModel('000000000000000000', 'Household', 'Household Account', true);

            stubRecordTypeModelById.put('000000000000000000', recordTypeModel);
            
            return stubRecordTypeModelById;         
        }
    }
}
