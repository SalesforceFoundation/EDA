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
* @description Test class for HealthCheckItemVModel class.
*/
@isTest 
public with sharing class HealthCheckItemVModel_TEST {

    /*****************************************************************************************
    * @description Test to verify constructor with 5 parameters generates model as expected.
    *****************************************************************************************/
    @isTest 
    private static void constructorWithFiveParamsValid(){

        List<HealthCheckItemVModel> sampleHCItemVModelList = new List<HealthCheckItemVModel>();

        Test.startTest();
        HealthCheckItemVModel healthCheckItemVModel = new HealthCheckItemVModel('TestKey', 
                                                                          'TestSetting', 
                                                                          'TestStatus', 
                                                                          'TestStatusLabel',
                                                                          'TestDescription', 
                                                                          'TextRecommendedFix',
                                                                          sampleHCItemVModelList);
        Test.stopTest();

        System.assertEquals('TestKey', healthCheckItemVModel.key, 'HealthCheckItemVModel key should be set to \'TestKey\'');
        System.assertEquals('TestSetting', healthCheckItemVModel.setting, 'HealthCheckItemVModel setting should be set to \'TestSetting\'');
        System.assertEquals('TestStatus', healthCheckItemVModel.status, 'HealthCheckItemVModel status should be set to \'TestStatus\'');
        System.assertEquals('TestStatusLabel', healthCheckItemVModel.statusLabel, 'HealthCheckItemVModel statuslabel should be set to \'TestStatusLabel\'');
        System.assertEquals('TestDescription', healthCheckItemVModel.description, 'HealthCheckItemVModel description should be set to \'TestDescription\'');
        System.assertEquals('TextRecommendedFix', healthCheckItemVModel.recommendedFix, 'HealthCheckItemVModel recommendedFix should be set to \'TextRecommendedFix\'');
        System.assertEquals(sampleHCItemVModelList, healthCheckItemVModel.healthCheckItemList, 'List of HealthCheckItemVModel should not change.');
    }

    /*****************************************************************************************
    * @description Test to verify compareTo() implementation separates HealthCheckGroupVModels 
    * with 'Fail' status from those with 'Pass' status (Fail above Pass) and in ascending 
    * alphabetical order by label within each group when duplicates do not exist.
    *****************************************************************************************/
    @isTest
    private static void sortByStatusThenLabelWithoutDuplicates(){
        List<HealthCheckItemVModel> healthCheckItemVModelsList = new List<HealthCheckItemVModel>();


        HealthCheckItemVModel healthCheckItemVModel1 = new HealthCheckItemVModel('key-1',
                                                                           'Zebra',
                                                                           'Fail', 
                                                                           'Fail-Label', 
                                                                           'Test Description',
                                                                           'Test Recommended fix', 
                                                                           new List<HealthCheckItemVModel>());

        HealthCheckItemVModel healthCheckItemVModel2 = new HealthCheckItemVModel('key-2',
                                                                            'Zebra',
                                                                            'pass', 
                                                                            'pass-Label', 
                                                                            'Test Description',
                                                                            'Test Recommended fix', 
                                                                            new List<HealthCheckItemVModel>());
        
        HealthCheckItemVModel healthCheckItemVModel3 = new HealthCheckItemVModel('key-3',
                                                                            'Baboon',
                                                                            'Pass', 
                                                                            'Pass-Label', 
                                                                            'Test Description',
                                                                            'Test Recommended fix', 
                                                                            new List<HealthCheckItemVModel>());
       
        HealthCheckItemVModel healthCheckItemVModel4 = new HealthCheckItemVModel('key-4',
                                                                            'Giraffe',
                                                                            'Fail', 
                                                                            'Fail-Label', 
                                                                            'Test Description',
                                                                            'Test Recommended fix', 
                                                                            new List<HealthCheckItemVModel>());
        
        HealthCheckItemVModel healthCheckItemVModel5 = new HealthCheckItemVModel('key-5',
                                                                            'Lion',
                                                                            'Pass', 
                                                                            'Pass-Label', 
                                                                            'Test Description',
                                                                            'Test Recommended fix', 
                                                                            new List<HealthCheckItemVModel>());
        
        HealthCheckItemVModel healthCheckItemVModel6 = new HealthCheckItemVModel('key-1',
                                                                            'Antelope',
                                                                            'Fail', 
                                                                            'Fail-Label', 
                                                                            'Test Description',
                                                                            'Test Recommended fix', 
                                                                            new List<HealthCheckItemVModel>());

        healthCheckItemVModelsList.add(healthCheckItemVModel1);
        healthCheckItemVModelsList.add(healthCheckItemVModel2);
        healthCheckItemVModelsList.add(healthCheckItemVModel3);        
        healthCheckItemVModelsList.add(healthCheckItemVModel4);
        healthCheckItemVModelsList.add(healthCheckItemVModel5);
        healthCheckItemVModelsList.add(healthCheckItemVModel6);

        Test.startTest();
        healthCheckItemVModelsList.sort();
        Test.stopTest();

        System.assertEquals(true, healthCheckItemVModelsList[0].setting.equalsIgnoreCase('Antelope'));
        System.assertEquals(true, healthCheckItemVModelsList[0].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, healthCheckItemVModelsList[1].setting.equalsIgnoreCase('Giraffe'));
        System.assertEquals(true, healthCheckItemVModelsList[1].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, healthCheckItemVModelsList[2].setting.equalsIgnoreCase('Zebra'));
        System.assertEquals(true, healthCheckItemVModelsList[2].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, healthCheckItemVModelsList[3].setting.equalsIgnoreCase('Baboon'));
        System.assertEquals(true, healthCheckItemVModelsList[3].status.equalsIgnoreCase('Pass'));
        System.assertEquals(true, healthCheckItemVModelsList[4].setting.equalsIgnoreCase('Lion'));
        System.assertEquals(true, healthCheckItemVModelsList[4].status.equalsIgnoreCase('Pass'));
        System.assertEquals(true, healthCheckItemVModelsList[5].setting.equalsIgnoreCase('Zebra'));
        System.assertEquals(true, healthCheckItemVModelsList[5].status.equalsIgnoreCase('Pass'));
    }

    /*****************************************************************************************
    * @description Test to verify compareTo() implementation separates HealthCheckGroupVModels 
    * with 'Fail' status from those with 'Pass' status (Fail above Pass) and in ascending 
    * alphabetical order by label within each group when duplicates exist.
    *****************************************************************************************/
    @isTest
    private static void sortByStatusThenLabelWithDuplicates(){
        List<HealthCheckItemVModel> healthCheckItemVModelsList = new List<HealthCheckItemVModel>();


        HealthCheckItemVModel healthCheckItemVModel1 = new HealthCheckItemVModel('key-1',
                                                                          'Zebra',
                                                                          'Pass', 
                                                                          'Pass-label', 
                                                                          'Test Description',
                                                                          'Test Recommended Fix', 
                                                                          new List<HealthCheckItemVModel>());

                                                                          

        HealthCheckItemVModel healthCheckItemVModel2 = new HealthCheckItemVModel('key-2',
                                                                          'zebra',
                                                                          'pass', 
                                                                          'pass-label', 
                                                                          'Test Description',
                                                                          'Test Recommended Fix', 
                                                                          new List<HealthCheckItemVModel>());


        HealthCheckItemVModel healthCheckItemVModel3 = new HealthCheckItemVModel('key-3',
                                                                          'Meerkat',
                                                                          'Fail', 
                                                                          'Fail-label', 
                                                                          'Test Description',
                                                                          'Test Recommended Fix', 
                                                                          new List<HealthCheckItemVModel>());


        HealthCheckItemVModel healthCheckItemVModel4 = new HealthCheckItemVModel('key-4',
                                                                          'lion',
                                                                          'fail', 
                                                                          'fail-label', 
                                                                          'Test Description',
                                                                          'Test Recommended Fix', 
                                                                          new List<HealthCheckItemVModel>());


        HealthCheckItemVModel healthCheckItemVModel5 = new HealthCheckItemVModel('key-5',
                                                                          'Lion',
                                                                          'fail', 
                                                                          'fail-label', 
                                                                          'Test Description',
                                                                          'Test Recommended Fix', 
                                                                          new List<HealthCheckItemVModel>());


        HealthCheckItemVModel healthCheckItemVModel6 = new HealthCheckItemVModel('key-6',
                                                                          'Antelope',
                                                                          'Pass', 
                                                                          'Pass-label', 
                                                                          'Test Description',
                                                                          'Test Recommended Fix', 
                                                                          new List<HealthCheckItemVModel>());


        healthCheckItemVModelsList.add(healthCheckItemVModel1);
        healthCheckItemVModelsList.add(healthCheckItemVModel2);
        healthCheckItemVModelsList.add(healthCheckItemVModel3);        
        healthCheckItemVModelsList.add(healthCheckItemVModel4);
        healthCheckItemVModelsList.add(healthCheckItemVModel5);
        healthCheckItemVModelsList.add(healthCheckItemVModel6);

        Test.startTest();
        healthCheckItemVModelsList.sort();
        Test.stopTest();

        System.assertEquals(true, healthCheckItemVModelsList[0].setting.equalsIgnoreCase('Lion'));
        System.assertEquals(true, healthCheckItemVModelsList[0].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, healthCheckItemVModelsList[1].setting.equalsIgnoreCase('Lion'));
        System.assertEquals(true, healthCheckItemVModelsList[1].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, healthCheckItemVModelsList[2].setting.equalsIgnoreCase('Meerkat'));
        System.assertEquals(true, healthCheckItemVModelsList[2].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, healthCheckItemVModelsList[3].setting.equalsIgnoreCase('Antelope'));
        System.assertEquals(true, healthCheckItemVModelsList[3].status.equalsIgnoreCase('Pass'));
        System.assertEquals(true, healthCheckItemVModelsList[4].setting.equalsIgnoreCase('Zebra'));
        System.assertEquals(true, healthCheckItemVModelsList[4].status.equalsIgnoreCase('Pass'));
        System.assertEquals(true, healthCheckItemVModelsList[5].setting.equalsIgnoreCase('Zebra'));
        System.assertEquals(true, healthCheckItemVModelsList[5].status.equalsIgnoreCase('Pass'));
    }

    /*****************************************************************************************
    * @description Test to verify compareTo() implementation does not sort lists that 
    * contain Object of type other than HealthCheckItemVModel, when the HealthCheckItemVModel
    * is first in the list. 
    *****************************************************************************************/
    private static void sortWithIncomparableObjectTypesRightFirstInList(){
        List<Object> objectsToSort = new List<Object>();
        HealthCheckItemVModel healthCheckItemVModel = new HealthCheckItemVModel('key-1',
                                                                         'Antelope',
                                                                         'Pass', 
                                                                         'Pass-label', 
                                                                         'Test Description',
                                                                         'Test Recommended Fix', 
                                                                         new List<HealthCheckItemVModel>());

        Account testAccount = new Account(Name = 'TestAccount');
        Contact testContact = new Contact(LastName = 'Testerson');

        objectsToSort.add(healthCheckItemVModel);
        objectsToSort.add(testContact);
        objectsToSort.add(testAccount);

        Test.startTest();
        objectsToSort.sort();
        Test.stopTest();

        System.assertEquals(true, objectsToSort[0] instanceof HealthCheckItemVModel, 'List should not be sorted when object types are not equal.');
        System.assertEquals(true, objectsToSort[1] instanceof Contact, 'List should not be sorted when object types are not equal.');
        System.assertEquals(true, objectsToSort[2] instanceof Account, 'List should not be sorted when object types are not equal.');
    }

    /*****************************************************************************************
    * @description Test to verify compareTo() implementation does not sort lists that 
    * contain Object of type other than HealthCheckItemVModel, when the HealthCheckItemVModel
    * is not first in the list. 
    *****************************************************************************************/
    private static void sortWithIncomparableObjectTypesWrongFirstInList(){
        List<Object> objectsToSort = new List<Object>();

        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel('Zebra',
                                                                             'Fail', 
                                                                             5, 
                                                                             8,
                                                                             new List<String>(), 
                                                                             new List<HealthCheckItemVModel>());

        HealthCheckItemVModel healthCheckItemVModel1 = new HealthCheckItemVModel('TestKey1', 
                                                                           'TestSetting', 
                                                                           'Fail', 
                                                                           'TestStatusLabel',
                                                                           'TestDescription', 
                                                                           'TextRecommendedFix',
                                                                           new List<HealthCheckItemVModel>());

        HealthCheckItemVModel healthCheckItemVModel2 = new HealthCheckItemVModel('TestKey2', 
                                                                           'TestSetting', 
                                                                           'Fail', 
                                                                           'TestStatusLabel',
                                                                           'TestDescription', 
                                                                           'TextRecommendedFix',
                                                                           new List<HealthCheckItemVModel>());
        Account testAccount = new Account(Name = 'TestAccount');
        Contact testContact = new Contact(LastName = 'Testerson');

        objectsToSort.add(healthCheckGroupVModel);
        objectsToSort.add(healthCheckItemVModel1);
        objectsToSort.add(healthCheckItemVModel2);
        objectsToSort.add(testAccount);
        objectsToSort.add(testContact);

        Test.startTest();
        objectsToSort.sort();
        Test.stopTest();

        System.assertEquals(true, objectsToSort[0] instanceof HealthCheckGroupVModel, 'List should not be sorted when object types are not equal.');
        System.assertEquals(true, objectsToSort[1] instanceof HealthCheckItemVModel, 'List should not be sorted when object types are not equal.');
        System.assertEquals(true, objectsToSort[2] instanceof HealthCheckItemVModel, 'List should not be sorted when object types are not equal.');
        System.assertEquals(true, objectsToSort[3] instanceof Account, 'List should not be sorted when object types are not equal.');
        System.assertEquals(true, objectsToSort[4] instanceof Contact, 'List should not be sorted when object types are not equal.');
    }

    /*****************************************************************************************
    * @description Test to verify compareTo() method returns 0 when an object that is not of 
    * type HealthCheckItemVModel is provided for comparison.
    *****************************************************************************************/
    @isTest 
    private static void compareToIncompatibleObjectType(){
        Account acct = new Account(Name = 'Test Account');

        HealthCheckItemVModel healthCheckItemVModel = new HealthCheckItemVModel('TestKey1', 
                                                                           'TestSetting', 
                                                                           'Fail', 
                                                                           'TestStatusLabel',
                                                                           'TestDescription', 
                                                                           'TextRecommendedFix',
                                                                           new List<HealthCheckItemVModel>());

        Test.startTest();
        Integer compareToResult = healthCheckItemVModel.compareTo(acct);
        Test.stopTest();

        System.assertEquals(0, compareToResult, 'Result comparing incompatible object types should be 0.');
    }
}
