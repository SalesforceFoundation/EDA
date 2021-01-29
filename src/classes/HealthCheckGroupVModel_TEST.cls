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
* @description Test class for HealthCheckGroupVModel class.
*/
@isTest 
public with sharing class HealthCheckGroupVModel_TEST {
    /*****************************************************************************************
    * @description Test to verify empty constructor generates model as expected.
    *****************************************************************************************/
    @isTest 
    private static void constructorWithNoParametersValid(){
        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel();
        Test.stopTest();

        System.assertEquals('', healthCheckGroupVModel.label, 'HealthCheckGroupVModel label should be blank.');
        System.assertEquals(Label.stgHealthCheckStatusPassed, healthCheckGroupVModel.status, 'HealthCheckGroupVModel status should be set to \'' + Label.stgHealthCheckStatusPassed + ' \'.');
        System.assertEquals(0, healthCheckGroupVModel.passedChecks, 'HealthCheckGroupVModel passedChecks should be 0.');
        System.assertEquals(0, healthCheckGroupVModel.totalChecks, 'HealthCheckGroupVModel totalChecks should be 0.');
        System.assertEquals(true, healthCheckGroupVModel.expandedRowsList.isEmpty(), 'HealthCheckGroupVModel expandedRowsList should be empty.');
        System.assertEquals(true, healthCheckGroupVModel.healthCheckItemList.isEmpty(), 'HealthCheckGroupVModel healthCheckItemList should be empty.');
    }

    /*****************************************************************************************
    * @description Test to verify constructor with 7 parameters generates model as expected.
    *****************************************************************************************/
    @isTest 
    private static void constructorWithSevenParametersValid(){
        List<String> expandedRowsList = new List<String>{'aString', 'bString', 'cString'};
        List<HealthCheckItemVModel> healthCheckItemList = new List<HealthCheckItemVModel>();
        for (Integer i = 0; i<5; i++){
            HealthCheckItemVModel healthCheckItemVModel = new HealthCheckItemVModel('TestKey' + i, 
                                                                          'TestSetting' + i, 
                                                                          'TestStatus' + i, 
                                                                          'TestStatusLabel' + i,
                                                                          'TestDescription' + i, 
                                                                          'TextRecommendedFix' + i,
                                                                          new List<HealthCheckItemVModel>());
            healthCheckItemList.add(healthCheckItemVModel);
        }

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel('TestLabel',
                                                                          'TestStatus', 
                                                                          5, 
                                                                          8,
                                                                          expandedRowsList, 
                                                                          healthCheckItemList);
        Test.stopTest();

        System.assertEquals('TestLabel', healthCheckGroupVModel.label, 'HealthCheckGroupVModel label should be set to \'TestLabel\'..');
        System.assertEquals('TestStatus', healthCheckGroupVModel.status, 'HealthCheckGroupVModel status should be set to \'TestStatus\'.');
        System.assertEquals(5, healthCheckGroupVModel.passedChecks, 'HealthCheckGroupVModel passedChecks should be 5.');
        System.assertEquals(8, healthCheckGroupVModel.totalChecks, 'HealthCheckGroupVModel totalChecks should be 8.');
        System.assertEquals(3, healthCheckGroupVModel.expandedRowsList.size(), 'HealthCheckGroupVModel expandedRowsList should contain 3 strings.');
        System.assertEquals(5, healthCheckGroupVModel.healthCheckItemList.size(), 'HealthCheckGroupVModel healthCheckItemList should contain 5 healthCheckItem view models.');
    }

    /*****************************************************************************************
    * @description Test to verify compareTo() implementation separates HealthCheckGroupVModels 
    * with 'Fail' status from those with 'Pass' status (Fail above Pass) and in ascending 
    * alphabetical order by label within each group when duplicates do not exist.
    *****************************************************************************************/
    @isTest
    private static void sortByStatusThenLabelWithoutDuplicates(){
        List<HealthCheckGroupVModel> healthCheckGroupVModelsList = new List<HealthCheckGroupVModel>();


        HealthCheckGroupVModel healthCheckGroupVModel1 = new HealthCheckGroupVModel('Zebra',
                                                                           'Fail', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());

        HealthCheckGroupVModel healthCheckGroupVModel2 = new HealthCheckGroupVModel('zebra',
                                                                           'pass', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());
        
        HealthCheckGroupVModel healthCheckGroupVModel3 = new HealthCheckGroupVModel('Baboon',
                                                                           'Pass', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());
       
        HealthCheckGroupVModel healthCheckGroupVModel4 = new HealthCheckGroupVModel('Giraffe',
                                                                           'Fail', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());
        
        HealthCheckGroupVModel healthCheckGroupVModel5 = new HealthCheckGroupVModel('Lion',
                                                                           'Pass', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());
        
        HealthCheckGroupVModel healthCheckGroupVModel6 = new HealthCheckGroupVModel('Antelope',
                                                                           'Fail', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());

        healthCheckGroupVModelsList.add(healthCheckGroupVModel1);
        healthCheckGroupVModelsList.add(healthCheckGroupVModel2);
        healthCheckGroupVModelsList.add(healthCheckGroupVModel3);        
        healthCheckGroupVModelsList.add(healthCheckGroupVModel4);
        healthCheckGroupVModelsList.add(healthCheckGroupVModel5);
        healthCheckGroupVModelsList.add(healthCheckGroupVModel6);

        Test.startTest();
        healthCheckGroupVModelsList.sort();
        Test.stopTest();

        System.assertEquals(true, healthCheckGroupVModelsList[0].label.equalsIgnoreCase('Antelope'));
        System.assertEquals(true, healthCheckGroupVModelsList[0].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, healthCheckGroupVModelsList[1].label.equalsIgnoreCase('Giraffe'));
        System.assertEquals(true, healthCheckGroupVModelsList[1].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, healthCheckGroupVModelsList[2].label.equalsIgnoreCase('Zebra'));
        System.assertEquals(true, healthCheckGroupVModelsList[2].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, healthCheckGroupVModelsList[3].label.equalsIgnoreCase('Baboon'));
        System.assertEquals(true, healthCheckGroupVModelsList[3].status.equalsIgnoreCase('Pass'));
        System.assertEquals(true, healthCheckGroupVModelsList[4].label.equalsIgnoreCase('Lion'));
        System.assertEquals(true, healthCheckGroupVModelsList[4].status.equalsIgnoreCase('Pass'));
        System.assertEquals(true, healthCheckGroupVModelsList[5].label.equalsIgnoreCase('Zebra'));
        System.assertEquals(true, healthCheckGroupVModelsList[5].status.equalsIgnoreCase('Pass'));
    }

    /*****************************************************************************************
    * @description Test to verify compareTo() implementation separates HealthCheckGroupVModels 
    * with 'Fail' status from those with 'Pass' status (Fail above Pass) and in ascending 
    * alphabetical order by label within each group when duplicates exist.
    *****************************************************************************************/
    @isTest
    private static void sortByStatusThenLabelWithDuplicates(){
        List<HealthCheckGroupVModel> healthCheckGroupVModelsList = new List<HealthCheckGroupVModel>();


        HealthCheckGroupVModel healthCheckGroupVModel1 = new HealthCheckGroupVModel('Zebra',
                                                                           'Pass', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());

        HealthCheckGroupVModel healthCheckGroupVModel2 = new HealthCheckGroupVModel('zebra',
                                                                           'pass', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());
        
        HealthCheckGroupVModel healthCheckGroupVModel3 = new HealthCheckGroupVModel('Meerkat',
                                                                           'Fail', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());
       
        HealthCheckGroupVModel healthCheckGroupVModel4 = new HealthCheckGroupVModel('lion',
                                                                           'fail', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());
        
        HealthCheckGroupVModel healthCheckGroupVModel5 = new HealthCheckGroupVModel('Lion',
                                                                           'fail', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());
        
        HealthCheckGroupVModel healthCheckGroupVModel6 = new HealthCheckGroupVModel('Antelope',
                                                                           'Pass', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());

        healthCheckGroupVModelsList.add(healthCheckGroupVModel1);
        healthCheckGroupVModelsList.add(healthCheckGroupVModel2);
        healthCheckGroupVModelsList.add(healthCheckGroupVModel3);        
        healthCheckGroupVModelsList.add(healthCheckGroupVModel4);
        healthCheckGroupVModelsList.add(healthCheckGroupVModel5);
        healthCheckGroupVModelsList.add(healthCheckGroupVModel6);

        Test.startTest();
        healthCheckGroupVModelsList.sort();
        Test.stopTest();

        System.assertEquals(true, healthCheckGroupVModelsList[0].label.equalsIgnoreCase('Lion'));
        System.assertEquals(true, healthCheckGroupVModelsList[0].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, healthCheckGroupVModelsList[1].label.equalsIgnoreCase('Lion'));
        System.assertEquals(true, healthCheckGroupVModelsList[1].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, healthCheckGroupVModelsList[2].label.equalsIgnoreCase('Meerkat'));
        System.assertEquals(true, healthCheckGroupVModelsList[2].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, healthCheckGroupVModelsList[3].label.equalsIgnoreCase('Antelope'));
        System.assertEquals(true, healthCheckGroupVModelsList[3].status.equalsIgnoreCase('Pass'));
        System.assertEquals(true, healthCheckGroupVModelsList[4].label.equalsIgnoreCase('Zebra'));
        System.assertEquals(true, healthCheckGroupVModelsList[4].status.equalsIgnoreCase('Pass'));
        System.assertEquals(true, healthCheckGroupVModelsList[5].label.equalsIgnoreCase('Zebra'));
        System.assertEquals(true, healthCheckGroupVModelsList[5].status.equalsIgnoreCase('Pass'));
    }

    /*****************************************************************************************
    * @description Test to verify compareTo() implementation does not sort lists that 
    * contain Object of type other than HealthCheckGroupVModel, when the HealthCheckGroupVModel
    * is first in the list. 
    *****************************************************************************************/
    private static void sortWithIncomparableObjectTypesRightFirstInList(){
        List<Object> objectsToSort = new List<Object>();
        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel('Antelope',
                                                                           'Pass', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());

        Account testAccount = new Account(Name = 'TestAccount');
        Contact testContact = new Contact(LastName = 'Testerson');

        objectsToSort.add(healthCheckGroupVModel);
        objectsToSort.add(testContact);
        objectsToSort.add(testAccount);

        Test.startTest();
        objectsToSort.sort();
        Test.stopTest();

        System.assertEquals(true, objectsToSort[0] instanceof HealthCheckGroupVModel, 'List should not be sorted when object types are not equal.');
        System.assertEquals(true, objectsToSort[1] instanceof Contact, 'List should not be sorted when object types are not equal.');
        System.assertEquals(true, objectsToSort[2] instanceof Account, 'List should not be sorted when object types are not equal.');
    }

    /*****************************************************************************************
    * @description Test to verify compareTo() implementation does not sort lists that 
    * contain Object of type other than HealthCheckGroupVModel, when the HealthCheckGroupVModel
    * is not first in the list. 
    *****************************************************************************************/
    private static void sortWithIncomparableObjectTypesWrongFirstInList(){
        List<Object> objectsToSort = new List<Object>();
        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel('Antelope',
                                                                           'Pass', 
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

        objectsToSort.add(healthCheckItemVModel1);
        objectsToSort.add(healthCheckGroupVModel);
        objectsToSort.add(healthCheckItemVModel1);
        objectsToSort.add(testAccount);
        objectsToSort.add(testContact);

        Test.startTest();
        objectsToSort.sort();
        Test.stopTest();

        System.assertEquals(true, objectsToSort[0] instanceof HealthCheckItemVModel, 'List should not be sorted when object types are not equal.');
        System.assertEquals(true, objectsToSort[1] instanceof HealthCheckGroupVModel, 'List should not be sorted when object types are not equal.');
        System.assertEquals(true, objectsToSort[2] instanceof HealthCheckItemVModel, 'List should not be sorted when object types are not equal.');
        System.assertEquals(true, objectsToSort[3] instanceof Account, 'List should not be sorted when object types are not equal.');
        System.assertEquals(true, objectsToSort[4] instanceof Contact, 'List should not be sorted when object types are not equal.');
    }

    /*****************************************************************************************
    * @description Test to verify compareTo() method returns 0 when an object that is not of 
    * type HealthCheckGroupVModel is provided for comparison.
    *****************************************************************************************/
    @isTest 
    private static void compareToIncompatibleObjectType(){
        Account acct = new Account(Name = 'Test Account');

        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel('TestLabel',
                                                                          'TestStatus', 
                                                                          5, 
                                                                          8,
                                                                          new List<String>{'TestString'}, 
                                                                          new List<HealthCheckItemVModel>());

        Test.startTest();
        Integer compareToResult = healthCheckGroupVModel.compareTo(acct);
        Test.stopTest();

        System.assertEquals(0, compareToResult, 'Result comparing incompatible object types should be 0.');
    }

    /**************************************************************************************************************************
    * @description Test to verify updateHealthCheckStatus() returns Pass when all health checks executed pass.
    **************************************************************************************************************************/ 
    @isTest
    private static void updateHealthCheckStatusPass(){
        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel('TestLabel',
                                                                          'TestStatus', 
                                                                          5, 
                                                                          5,
                                                                          new List<String>{'TestString'}, 
                                                                          new List<HealthCheckItemVModel>());
        Test.startTest();
        healthCheckGroupVModel.updateHealthCheckStatus();
        Test.stopTest();

        System.assertEquals(Label.stgHealthCheckStatusPassed, healthCheckGroupVModel.status, 'Should return \'' + Label.stgHealthCheckStatusPassed + '\'.');
    }

    /**************************************************************************************************************************
    * @description Test to verify updateHealthCheckStatus() returns Fail when any health checks executed fail.
    **************************************************************************************************************************/ 
    @isTest
    private static void updateHealthCheckStatusFail(){
        HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel('TestLabel',
                                                                          'TestStatus', 
                                                                          5, 
                                                                          10,
                                                                          new List<String>{'TestString'}, 
                                                                          new List<HealthCheckItemVModel>());
        Test.startTest();
        healthCheckGroupVModel.updateHealthCheckStatus();
        Test.stopTest();

        System.assertEquals(Label.stgHealthCheckStatusFailed, healthCheckGroupVModel.status, 'Should return \'' + Label.stgHealthCheckStatusFailed + '\'.');
    }
}
