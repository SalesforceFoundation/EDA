/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group 
* @group-content ../../ApexDocContent/
* @description Test class for RelAutoCreateSettingsMapperService
*/
@isTest
public with sharing class RelAutoCreateSettingsMapperService_TEST {
    
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * RelAutoCreateSettingsMapperService class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        RelAutoCreateSettingsMapperService srvcRelAutoCreateSettingMapper = RelAutoCreateSettingsMapperService.getInstance();
        System.assertEquals(RelAutoCreateSettingsMapperService.instance, srvcRelAutoCreateSettingMapper, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, srvcRelAutoCreateSettingMapper != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * RelAutoCreateSettingsMapperService class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        RelAutoCreateSettingsMapperService srvcRelAutoCreateSettingsMapperInstance1 = RelAutoCreateSettingsMapperService.getInstance();
        RelAutoCreateSettingsMapperService srvcRelAutoCreateSettingsMapperInstance2 = RelAutoCreateSettingsMapperService.getInstance();
 
        System.assertEquals(RelAutoCreateSettingsMapperService.instance, srvcRelAutoCreateSettingsMapperInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(srvcRelAutoCreateSettingsMapperInstance1, srvcRelAutoCreateSettingsMapperInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, srvcRelAutoCreateSettingsMapperInstance1 != null, 'Instance of service class should not be null.');
    }

    /***************************************************************************************************************************
    * @description Test method to verify that getContactMappingModelsFromSettings() returns only the models for Relationship 
    * Auto Create mappings associated with the Contact object.
    ***************************************************************************************************************************/ 
    @isTest 
    private static void getContactMappingModelsFromSettingsTrue(){
        List<Relationship_Auto_Create__c> relAutoCreateList = new List<Relationship_Auto_Create__c>();
        Relationship_Auto_Create__c contactRelAutoCreate;
        Relationship_Auto_Create__c accountRelAutoCreate;

        for (Integer i = 0; i < 5; i++){
            contactRelAutoCreate = new Relationship_Auto_Create__c(Name = 'ConReportToAutoCreate' + i, 
                                                                                               Object__c = 'Contact',
                                                                                               Field__c = 'ReportsToId', 
                                                                                               Relationship_Type__c = 'ContactTester' + i,
                                                                                               Campaign_Types__c = '');

            accountRelAutoCreate = new Relationship_Auto_Create__c(Name = 'AccountReportToAutoCreate' + i, 
                                                                                               Object__c = 'Account',
                                                                                               Field__c = 'Name', 
                                                                                               Relationship_Type__c = 'AccountTester' + i,
                                                                                               Campaign_Types__c = '');
            relAutoCreateList.add(contactRelAutoCreate);
            relAutoCreateList.add(accountRelAutoCreate);
        }

        insert relAutoCreateList;

        Test.startTest();
        List<ContactRelAutoCreateMappingModel> conRelAutoCreateMappingList = RelAutoCreateSettingsMapperService.getInstance().getContactMappingModelsFromSettings();
        Test.stopTest();

        System.assertEquals(5, conRelAutoCreateMappingList.size(), 'There should be 5 Relationship Auto Create Mapping models for Contact.');

        for (Integer i = 0; i < conRelAutoCreateMappingList.size(); i++){
            System.assertEquals('ReportsToId', conRelAutoCreateMappingList[i].contactFieldApiName, 'The contact field name set on model should correspond to the Relationship_Type__c for the Contact Relationship Auto Create mapping.');
            System.assertEquals('Reports To ID', conRelAutoCreateMappingList[i].contactFieldLabel, 'The contact field label set on model should correspond to the Relationship_Type__c for the Contact Relationship Auto Create mapping.');
            System.assertEquals('ContactTester' + i, conRelAutoCreateMappingList[i].relationshipType, 'The relationship type set on model should correspond to the Relationship_Type__c for the Contact Relationship Auto Create mapping.');
        }
    }

    /***************************************************************************************************************************
    * @description Test method to verify that getContactMappingModelsFromSettings() returns an empty list
    * when there are no Relationship Auto Create mappings for the Contact object set.
    ***************************************************************************************************************************/ 
    @isTest 
    private static void getContactMappingModelsFromSettingsFalse(){
        List<Relationship_Auto_Create__c> relAutoCreateList = [SELECT Id 
                                                               FROM Relationship_Auto_Create__c];

        delete relAutoCreateList;

        Test.startTest();
        System.assertEquals(true, RelAutoCreateSettingsMapperService.getInstance().getContactMappingModelsFromSettings().isEmpty(), 'There should be no Relationship Auto Create Mapping models for Contact.');
        Test.stopTest();
    }

    /***************************************************************************************************************************
    * @description Test method to verify that getContactMappingModelsFromMappings() returns a list of models representing
    * the Relationship Auto Create mappings provided as input (regardless of Object).
    ***************************************************************************************************************************/ 
    @isTest 
    private static void getContactMappingModelsFromMappingsTrue(){
        List<Relationship_Auto_Create__c> relAutoCreateList = new List<Relationship_Auto_Create__c>();

        for (Integer i = 0; i < 5; i++){
            Relationship_Auto_Create__c contactRelAutoCreate = new Relationship_Auto_Create__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship_Auto_Create__c.SObjectType),
                                                                                               Name = 'ConReportToAutoCreate' + i, 
                                                                                               Object__c = 'Contact',
                                                                                               Field__c = 'reportsToId', 
                                                                                               Relationship_Type__c = 'ContactTester' + i,
                                                                                               Campaign_Types__c = '');

            Relationship_Auto_Create__c accountRelAutoCreate = new Relationship_Auto_Create__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship_Auto_Create__c.SObjectType),
                                                                                               Name = 'AccountReportToAutoCreate' + i, 
                                                                                               Object__c = 'Account',
                                                                                               Field__c = 'Name', 
                                                                                               Relationship_Type__c = 'AccountTester' + i,
                                                                                               Campaign_Types__c = '');
            relAutoCreateList.add(contactRelAutoCreate);
            relAutoCreateList.add(accountRelAutoCreate);
        }

        Test.startTest();
        List<ContactRelAutoCreateMappingModel> conRelAutoCreateMappingsList = RelAutoCreateSettingsMapperService.getInstance().getContactMappingModelsFromMappings(relAutoCreateList);
        Test.stopTest();

        System.assertEquals(10, conRelAutoCreateMappingsList.size(), 'There should be 10 ContactRelAutoCreateMappingModel returned.');
    }

    /***************************************************************************************************************************
    * @description Test method to verify that getContactMappingModelsFromMappings() returns an empty list of when no 
    * Relationships Auto Create mappings are provided as input.
    ***************************************************************************************************************************/ 
    @isTest 
    private static void getContactMappingModelsFromMappingsFalse(){
        List<Relationship_Auto_Create__c> relAutoCreateList = new List<Relationship_Auto_Create__c>();

        Test.startTest();
        List<ContactRelAutoCreateMappingModel> conRelAutoCreateMappingsList = RelAutoCreateSettingsMapperService.getInstance().getContactMappingModelsFromMappings(relAutoCreateList);
        Test.stopTest();

        System.assertEquals(true, conRelAutoCreateMappingsList.isEmpty(), 'There should be no ContactRelAutoCreateMappingModel returned.');
    }

    /***************************************************************************************************************************
    * @description Test method to verify that getModelFromMapping() returns a model representing the Relationship Auto Create 
    * mapping provided as input (regardless of Object).
    ***************************************************************************************************************************/ 
    @isTest 
    private static void getModelFromMappingTrue(){
        List<Relationship_Auto_Create__c> relAutoCreateList = new List<Relationship_Auto_Create__c>();

        for (Integer i = 0; i < 5; i++){
            Relationship_Auto_Create__c contactRelAutoCreate = new Relationship_Auto_Create__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship_Auto_Create__c.SObjectType),
                                                                                               Name = 'ConReportToAutoCreate' + i, 
                                                                                               Object__c = 'Contact',
                                                                                               Field__c = 'ReportsToId', 
                                                                                               Relationship_Type__c = 'ContactTester' + i,
                                                                                               Campaign_Types__c = '');

            Relationship_Auto_Create__c accountRelAutoCreate = new Relationship_Auto_Create__c(Id = UTIL_UnitTestData_TEST.getFakeId(Relationship_Auto_Create__c.SObjectType),
                                                                                               Name = 'AccountReportToAutoCreate' + i, 
                                                                                               Object__c = 'Account',
                                                                                               Field__c = 'Name', 
                                                                                               Relationship_Type__c = 'AccountTester' + i,
                                                                                               Campaign_Types__c = '');
            relAutoCreateList.add(contactRelAutoCreate);
            relAutoCreateList.add(accountRelAutoCreate);
        }

        Test.startTest();
        for (Relationship_Auto_Create__c relAutoCreate : relAutoCreateList){
            ContactRelAutoCreateMappingModel conRelAutoCreateMapping = RelAutoCreateSettingsMapperService.getInstance().getModelFromMapping(relAutoCreate);
            if (conRelAutoCreateMapping.relationshipType.contains('ContactTester')){
                System.assertEquals(true, conRelAutoCreateMapping.contactFieldApiName.contains('ReportsToId'));
                System.assertEquals(true, conRelAutoCreateMapping.contactFieldLabel.contains('Reports To ID'));
            } else {
                System.assertEquals(true, conRelAutoCreateMapping.settingsContactFieldValue.contains('Name'));
                System.assertEquals(true, conRelAutoCreateMapping.relationshipType.contains('AccountTester'));
            }
        }
        Test.stopTest();
    }

    /***************************************************************************************************************************
    * @description Test method to verify that getModelFromMapping() returns a model with default settings applied when an empty 
    * Relationship Auto Create mapping is provided as input.
    ***************************************************************************************************************************/ 
    @isTest 
    private static void getModelFromMappingFalse(){
        RelAutoCreateSettingsMapperService.instance = new STUB_NoRelAutoCreateMappingModel();

        Test.startTest();
        System.assertEquals(null, RelAutoCreateSettingsMapperService.getInstance().getModelFromMapping(new Relationship_Auto_Create__c()), 'Empty Relationship Auto Create record should return null');
        Test.stopTest();
    }

    /**************************************************************************************************************************
    ****************************************************** STUBS **************************************************************
    **************************************************************************************************************************/

    /************************************************************************************************************
    * @description Stub class to simulate a null response from the getModelFromMapping method in the
    * RelAutoCreateSettingsMapperService.
    *************************************************************************************************************/ 
    private class STUB_NoRelAutoCreateMappingModel extends RelAutoCreateSettingsMapperService {
        @TestVisible
        public override ContactRelAutoCreateMappingModel getModelFromMapping(Relationship_Auto_Create__c relAutoCreate){
            return null;
        }
    }
}
