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
        Test.startTest();
            RecordTypeService recordTypeServiceInstance1 = RecordTypeService.getInstance();
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

        System.assertEquals(true, recordTypeModelById.keySet().contains('000000000000000000'));
        System.assertEquals('Household', recordTypeModelById.get('000000000000000000').name);
        System.assertEquals('Household Account', recordTypeModelById.get('000000000000000000').developerName);
        System.assertEquals(true, recordTypeModelById.get('000000000000000000').isActive);
    }

    /**************************************************************************************************************************
    * @description Test method to verify that null is returned for valid id not in the map
    ***************************************************************************************************************************/
    @isTest
    private static void getRecordTypeModelFromMapValidIdNotInMapTest() {
        RecordTypeMapper.instance = new STUB_RecordTypeMapper();

        Test.startTest();
            Map<Id, RecordTypeModel> recordTypeModelById = RecordTypeService.getInstance().getModelByIdMapForSObjectType(Account.getSobjectType());
        Test.stopTest();
        
        System.assertEquals(null, RecordTypeService.getInstance().getRecordTypeModelFromMap('000000000000000001', recordTypeModelById));
    }

    /**************************************************************************************************************************
    * @description Test method to verify that null is returned for invalid id
    ***************************************************************************************************************************/
    @isTest
    private static void getRecordTypeModelFromMapInvalidIdTest() {
        RecordTypeMapper.instance = new STUB_RecordTypeMapper();

        Test.startTest();
            Map<Id, RecordTypeModel> recordTypeModelById = RecordTypeService.getInstance().getModelByIdMapForSObjectType(Account.getSobjectType());
        Test.stopTest();
        
        System.assertEquals(null, RecordTypeService.getInstance().getRecordTypeModelFromMap('invalid', recordTypeModelById));
    }

    /**************************************************************************************************************************
    * @description Test method to verify that a valid record type model is returned.
    ***************************************************************************************************************************/
    @isTest
    private static void getRecordTypeModelFromMapValidIdInMapTest() {
        RecordTypeMapper.instance = new STUB_RecordTypeMapper();

        Map<Id, RecordTypeModel> recordTypeModelById = RecordTypeService.getInstance().getModelByIdMapForSObjectType(Account.getSobjectType());
        
        Test.startTest();
            RecordTypeModel recordTypeModel = RecordTypeService.getInstance().getRecordTypeModelFromMap('000000000000000000', recordTypeModelById);
        Test.stopTest();

        System.assertEquals('000000000000000000', recordTypeModel.Id);
        System.assertEquals('Household', recordTypeModel.name);
        System.assertEquals('Household Account', recordTypeModel.developerName);
        System.assertEquals(true, recordTypeModel.isActive);
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
