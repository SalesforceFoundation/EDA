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
* @description Test class for LookupFieldService class.
*/
@isTest
public with sharing class LookupFieldService_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * LookupFieldService class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            LookupFieldService LookupFieldServiceInstance = LookupFieldService.getInstance();
        Test.stopTest();

        System.assertEquals(LookupFieldService.instance, LookupFieldServiceInstance, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(true, LookupFieldServiceInstance != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * LookupFieldService class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            LookupFieldService LookupFieldServiceInstance1 = LookupFieldService.getInstance();
            LookupFieldService LookupFieldServiceInstance2 = LookupFieldService.getInstance();
        Test.stopTest();

        System.assertEquals(LookupFieldService.instance, LookupFieldServiceInstance1, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(LookupFieldServiceInstance1, LookupFieldServiceInstance2, 'Subsequent retrievals of mapper class instance should return existing instance.');
        System.assertEquals(true, LookupFieldServiceInstance1 != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getModelByNameMapForSObjectType method returns the a map of LookupField models
    * by name when an SObject contains fields that lookup to the specified SObject type.
    ***************************************************************************************************************************/
    @isTest 
    private static void getModelByNameMapForSObjectTypeValid(){
        LookupFieldMapper.instance = new STUB_LookupFieldMapperValid();
        LookupFieldService lookupFieldServiceInstance = LookupFieldService.getInstance();

        Test.startTest();
        Map<String, LookupFieldModel> lookupFieldModelByNameResults = 
            lookupFieldServiceInstance.getModelByNameMapForSObjectType(Contact.SObjectType, Account.SObjectType);
        Test.stopTest();

        System.assertEquals(3, lookupFieldModelByNameResults.values().size(), 'Should return 3 mappings to Account lookup fields.');
        System.assertEquals(true, lookupFieldModelByNameResults.containsKey('testName1'), 'Should contain mapping for \'testName1\' field name.');
        System.assertEquals(true, lookupFieldModelByNameResults.containsKey('testName2'), 'Should contain mapping for \'testName2\' field name.');
        System.assertEquals(true, lookupFieldModelByNameResults.containsKey('testName3'), 'Should contain mapping for \'testName3\' field name.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getModelByNameMapForSObjectType method returns an empty map of LookupField models
    * by name when an SObject does not contain fields that lookup to the specified SObject type.
    ***************************************************************************************************************************/
    @isTest 
    private static void getModelByNameMapForSObjectTypeEmpty(){
        LookupFieldMapper.instance = new STUB_LookupFieldMapperEmpty();
        LookupFieldService lookupFieldServiceInstance = LookupFieldService.getInstance();

        Test.startTest();
        Map<String, LookupFieldModel> lookupFieldModelByNameResults = 
            lookupFieldServiceInstance.getModelByNameMapForSObjectType(Trigger_Handler__c.SObjectType, Error__c.SObjectType);
        Test.stopTest();

        System.assertEquals(0, lookupFieldModelByNameResults.values().size(), 'Trigger Handler should have no mappings to Error__c lookup fields.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getModelByLabelMapForSObjectType method returns an map of LookupField models
    * by label when a valid map of lookup field models by name is provided.
    ***************************************************************************************************************************/
    @isTest 
    private static void getModelByLabelMapForSObjectTypeValid(){
        Map<String, LookupFieldModel> lookupFieldsByName = new Map<String, LookupFieldModel>();
        lookupFieldsByName.put('LookupFieldName1', new LookupFieldModel('LookupFieldName1', 'LookupFieldLabel1'));
        lookupFieldsByName.put('LookupFieldName2', new LookupFieldModel('LookupFieldName2', 'LookupFieldLabel2'));
        lookupFieldsByName.put('LookupFieldName3', new LookupFieldModel('LookupFieldName3', 'LookupFieldLabel3'));

        LookupFieldService lookupFieldServiceInstance = LookupFieldService.getInstance();

        Test.startTest();
        Map<String, LookupFieldModel> lookupFieldModelByLabelResults = 
            lookupFieldServiceInstance.getModelByLabelMapForSObjectType(lookupFieldsByName);
        Test.stopTest();

        for (String lookupFieldKey : lookupFieldModelByLabelResults.keySet()) {
            System.assertEquals(true, lookupFieldKey.containsIgnoreCase('LookupFieldLabel'), 'Lookup field models should be mapped by Label');
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getLookupFieldModelFromNameMap method returns a valid LookupField model when
    * searching by a name that matches one of the values in the provided map.
    ***************************************************************************************************************************/
    @isTest 
    private static void getLookupFieldModelFromNameMapValid() {
        Map<String, LookupFieldModel> lookupFieldModelByName = new Map<String, LookupFieldModel>();

        lookupFieldModelByName.put('TestName1', new LookupFieldModel('TestName1', 'TestLabel1'));
        lookupFieldModelByName.put('TestName2', new LookupFieldModel('TestName2', 'TestLabel2'));
        lookupFieldModelByName.put('TestName3', new LookupFieldModel('TestName3', 'TestLabel3'));

        LookupFieldService lookupFieldServiceInstance = LookupFieldService.getInstance();

        Test.startTest();
        LookupFieldModel lookupFieldModelResult = lookupFieldServiceInstance.getLookupFieldModelFromNameMap('TestName1', lookupFieldModelByName);
        Test.stopTest();

        System.assertEquals('TestLabel1', LookupFieldModelResult.label, 'Field model should have \'TestLabel1\' as label value.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getLookupFieldModelFromLabelMap method returns a valid LookupField model when
    * searching by a label that matches one of the values in the provided map.
    ***************************************************************************************************************************/
    @isTest 
    private static void getLookupFieldModelFromLabelMapValid() {
        Map<String, LookupFieldModel> lookupFieldModelByLabel = new Map<String, LookupFieldModel>();

        lookupFieldModelByLabel.put('TestLabel1', new LookupFieldModel('TestName1', 'TestLabel1'));
        lookupFieldModelByLabel.put('TestLabel2', new LookupFieldModel('TestName2', 'TestLabel2'));
        lookupFieldModelByLabel.put('TestLabel3', new LookupFieldModel('TestName3', 'TestLabel3'));

        LookupFieldService lookupFieldServiceInstance = LookupFieldService.getInstance();

        Test.startTest();
        LookupFieldModel lookupFieldModelResult = lookupFieldServiceInstance.getLookupFieldModelFromLabelMap('TestLabel1', lookupFieldModelByLabel);
        Test.stopTest();

        System.assertEquals('TestName1', LookupFieldModelResult.name, 'Field model should have \'TestName1\' as name value.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getLookupFieldModelFromNameMap method returns a null LookupField model when
    * searching by name that does not match the values in the provided map.
    ***************************************************************************************************************************/
    @isTest 
    private static void getLookupFieldModelFromNameMapInValid() {
        Map<String, LookupFieldModel> lookupFieldModelByName = new Map<String, LookupFieldModel>();

        lookupFieldModelByName.put('TestName1', new LookupFieldModel('TestName1', 'TestLabel1'));
        lookupFieldModelByName.put('TestName2', new LookupFieldModel('TestName2', 'TestLabel2'));
        lookupFieldModelByName.put('TestName3', new LookupFieldModel('TestName3', 'TestLabel3'));

        LookupFieldService lookupFieldServiceInstance = LookupFieldService.getInstance();

        Test.startTest();
        LookupFieldModel lookupFieldModelResult = lookupFieldServiceInstance.getLookupFieldModelFromNameMap('InvalidName', lookupFieldModelByName);
        Test.stopTest();

        System.assertEquals(null, lookupFieldModelResult, 'Should return null value.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getLookupFieldModelFromLabelMap method returns a null LookupField model when
    * searching by label that does not match the values in the provided map.
    ***************************************************************************************************************************/
    @isTest 
    private static void getLookupFieldModelFromLabelMapInValid() {
        Map<String, LookupFieldModel> lookupFieldModelByLabel = new Map<String, LookupFieldModel>();

        lookupFieldModelByLabel.put('TestLabel1', new LookupFieldModel('TestName1', 'TestLabel1'));
        lookupFieldModelByLabel.put('TestLabel2', new LookupFieldModel('TestName2', 'TestLabel2'));
        lookupFieldModelByLabel.put('TestLabel3', new LookupFieldModel('TestName3', 'TestLabel3'));

        LookupFieldService lookupFieldServiceInstance = LookupFieldService.getInstance();

        Test.startTest();
        LookupFieldModel lookupFieldModelResult = lookupFieldServiceInstance.getLookupFieldModelFromLabelMap('InvalidName', lookupFieldModelByLabel);
        Test.stopTest();

        System.assertEquals(null, lookupFieldModelResult, 'Should return null value.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getLookupFieldModelFromNameAndLabelMaps returns a valid record type model when a match is found
    * for a specified developer name.
    ***************************************************************************************************************************/
    @isTest 
    private static void getLookupFieldModelFromNameAndLabelMapsByName() {
        Map<String, LookupFieldModel> lookupFieldModelsByName = new Map<String, LookupFieldModel>{
            'Lookup_Field_1' => new LookupFieldModel(
                'Lookup_Field_1',    
                'Lookup Field 1'
            )
        };

        Map<String, LookupFieldModel> lookupFieldModelsByLabel = new Map<String, LookupFieldModel>{
            'Lookup Field' => new LookupFieldModel(
                'Lookup_Field',
                'Lookup Field'
            )
        };

        LookupFieldService lookupFieldServiceInstance = LookupFieldService.getInstance();

        Test.startTest();
        LookupFieldModel lookupFieldModelResult = 
            lookupFieldServiceInstance.getLookupFieldModelFromNameAndLabelMaps(
                'Lookup_Field_1',
                lookupFieldModelsByName,
                lookupFieldModelsByLabel
            );
        Test.stopTest();

        System.assertEquals('Lookup_Field_1', lookupFieldModelResult.name, 'Record type model name should be \'Lookup_Field_1\'.');
        System.assertEquals('Lookup Field 1', lookupFieldModelResult.label, 'Record type model label should be \'Lookup Field 1\'.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getLookupFieldModelFromNameAndLabelMaps returns a valid record type model when a match is found
    * for a specified label name.
    ***************************************************************************************************************************/
    @isTest 
    private static void getLookupFieldModelFromNameAndLabelMapsByLabel() {
        Map<String, LookupFieldModel> lookupFieldModelsByName = new Map<String, LookupFieldModel>{
            'Lookup_Field_1' => new LookupFieldModel(
                'Lookup_Field_1',    
                'Lookup Field 1' 
            )
        };

        Map<String, LookupFieldModel> lookupFieldModelsByLabel = new Map<String, LookupFieldModel>{
            'Lookup Field' => new LookupFieldModel(
                'Lookup_Field',
                'Lookup Field'
            )
        };

        LookupFieldService lookupFieldServiceInstance = LookupFieldService.getInstance();

        Test.startTest();
        LookupFieldModel lookupFieldModelResult = 
            lookupFieldServiceInstance.getLookupFieldModelFromNameAndLabelMaps(
                'Lookup Field',
                lookupFieldModelsByName,
                lookupFieldModelsByLabel
            );
        Test.stopTest();

        System.assertEquals('Lookup_Field', lookupFieldModelResult.name, 'Lookup field model name should be \'Lookup_Field\'.');
        System.assertEquals('Lookup Field', lookupFieldModelResult.label, 'Lookup field model label should be \'Lookup Field\'.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that getLookupFieldModelFromNameAndLabelMaps returns a null record type model when no match is found
    * for a specified developer or label name.
    ***************************************************************************************************************************/
    @isTest 
    private static void getLookupFieldModelFromNameAndLabelMapsNull() {
        Map<String, LookupFieldModel> lookupFieldModelsByName = new Map<String, LookupFieldModel>{
            'Lookup_Field_1' => new LookupFieldModel(
                'Lookup_Field_1', 
                'Lookup Field 1'
            )
        };

        Map<String, LookupFieldModel> lookupFieldModelsByLabel = new Map<String, LookupFieldModel>{
            'Lookup Field' => new LookupFieldModel(
                'Lookup_Field', 
                'Lookup Field'
            )
        };

        LookupFieldService lookupFieldServiceInstance = LookupFieldService.getInstance();

        Test.startTest();
        LookupFieldModel lookupFieldModelResult = 
            lookupFieldServiceInstance.getLookupFieldModelFromNameAndLabelMaps(
                'Non Existent Lookup Field Name',
                lookupFieldModelsByName,
                lookupFieldModelsByLabel
            );
        Test.stopTest();

        System.assertEquals(null, lookupFieldModelResult, 'Lookup field model should be null.');
    }

    /**************************************************************************************************************************
    ****************************************************** STUB CLASS *********************************************************
    **************************************************************************************************************************/

    /*************************************************************************************************************
    * @description Stub class to simulate the response from LookupFieldMapper to return Map<String, LookupFieldModel> 
    * for LookupField models by name and by label with valid mappings
    *************************************************************************************************************/
    private class STUB_LookupFieldMapperValid extends LookupFieldMapper {
        public override Map<String, LookupFieldModel> getModelByNameMapForSObjectType(SObjectType sObjectType, SObjectType lookupToSObjectType) {
            Map<String, LookupFieldModel> testLookupFieldModelsByName = new Map<String, LookupFieldModel>();

            testLookupFieldModelsByName.put('testName1', new LookupFieldModel('testName1', 'testLabel1'));
            testLookupFieldModelsByName.put('testName2', new LookupFieldModel('testName2', 'testLabel2'));
            testLookupFieldModelsByName.put('testName3', new LookupFieldModel('testName3', 'testLabel3'));

            return testLookupFieldModelsByName;
        }
    }

    /*************************************************************************************************************
    * @description Stub class to simulate the response from LookupFieldMapper to return Map<String, LookupFieldModel> 
    * for LookupField models by name and by label with empty mappings
    *************************************************************************************************************/
    private class STUB_LookupFieldMapperEmpty extends LookupFieldMapper {
        public override Map<String, LookupFieldModel> getModelByNameMapForSObjectType(SObjectType sObjectType, SObjectType lookupToSObjectType) {
            return new Map<String, LookupFieldModel>();
        }
    }
}


