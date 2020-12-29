@isTest 
public with sharing class HealthCheckGroupVModel_TEST {

    /*****************************************************************************************
    * @description Test to verify constructor with 7 parameters generates model as expected.
    *****************************************************************************************/
    @isTest 
    private static void constructorWithSevenParametersValid(){
        List<String> expandedRowsList = new List<String>{'aString', 'bString', 'cString'};
        List<HealthCheckItemVModel> healthCheckItemList = new List<HealthCheckItemVModel>();
        for (Integer i = 0; i<5; i++){
            HealthCheckItemVModel hlthChkItemVMod = new HealthCheckItemVModel('TestKey' + i, 
                                                                          'TestSetting' + i, 
                                                                          'TestStatus' + i, 
                                                                          'TestStatusLabel' + i,
                                                                          'TestDescription' + i, 
                                                                          'TextRecommendedFix' + i,
                                                                          new List<HealthCheckItemVModel>());
            healthCheckItemList.add(hlthChkItemVMod);
        }

        Test.startTest();
        HealthCheckGroupVModel hlthChkGroupMod = new HealthCheckGroupVModel('TestLabel',
                                                                          'TestStatus', 
                                                                          5, 
                                                                          8,
                                                                          expandedRowsList, 
                                                                          healthCheckItemList);
        Test.stopTest();

        System.assertEquals('TestLabel', hlthChkGroupMod.label, 'HealthCheckGroupVModel label should be set to \'TestLabel\'..');
        System.assertEquals('TestStatus', hlthChkGroupMod.status, 'HealthCheckGroupVModel status should be set to \'TestStatus\'.');
        System.assertEquals(5, hlthChkGroupMod.passedChecks, 'HealthCheckGroupVModel passedChecks should be 5.');
        System.assertEquals(8, hlthChkGroupMod.totalChecks, 'HealthCheckGroupVModel totalChecks should be 8.');
        System.assertEquals(3, hlthChkGroupMod.expandedRowsList.size(), 'HealthCheckGroupVModel expandedRowsList should contain 3 strings.');
        System.assertEquals(5, hlthChkGroupMod.healthCheckItemList.size(), 'HealthCheckGroupVModel healthCheckItemList should contain 5 healthCheckItem view models.');
    }

    /*****************************************************************************************
    * @description Test to verify compareTo() implementation separates HealthCheckGroupVModels 
    * with 'Fail' status from those with 'Pass' status (Fail above Pass) and in ascending 
    * alphabetical order by label within each group when duplicates do not exist.
    *****************************************************************************************/
    @isTest
    private static void sortByStatusThenLabelWithoutDuplicates(){
        List<HealthCheckGroupVModel> hlthChkGroupModelsList = new List<HealthCheckGroupVModel>();


        HealthCheckGroupVModel hlthChkGroupMod1 = new HealthCheckGroupVModel('Zebra',
                                                                           'Fail', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());

        HealthCheckGroupVModel hlthChkGroupMod2 = new HealthCheckGroupVModel('zebra',
                                                                           'pass', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());
        
        HealthCheckGroupVModel hlthChkGroupMod3 = new HealthCheckGroupVModel('Baboon',
                                                                           'Pass', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());
       
        HealthCheckGroupVModel hlthChkGroupMod4 = new HealthCheckGroupVModel('Giraffe',
                                                                           'Fail', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());
        
        HealthCheckGroupVModel hlthChkGroupMod5 = new HealthCheckGroupVModel('Lion',
                                                                           'Pass', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());
        
        HealthCheckGroupVModel hlthChkGroupMod6 = new HealthCheckGroupVModel('Antelope',
                                                                           'Fail', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());

        hlthChkGroupModelsList.add(hlthChkGroupMod1);
        hlthChkGroupModelsList.add(hlthChkGroupMod2);
        hlthChkGroupModelsList.add(hlthChkGroupMod3);        
        hlthChkGroupModelsList.add(hlthChkGroupMod4);
        hlthChkGroupModelsList.add(hlthChkGroupMod5);
        hlthChkGroupModelsList.add(hlthChkGroupMod6);

        Test.startTest();
        hlthChkGroupModelsList.sort();
        Test.stopTest();

        System.assertEquals(true, hlthChkGroupModelsList[0].label.equalsIgnoreCase('Antelope'));
        System.assertEquals(true, hlthChkGroupModelsList[0].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, hlthChkGroupModelsList[1].label.equalsIgnoreCase('Giraffe'));
        System.assertEquals(true, hlthChkGroupModelsList[1].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, hlthChkGroupModelsList[2].label.equalsIgnoreCase('Zebra'));
        System.assertEquals(true, hlthChkGroupModelsList[2].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, hlthChkGroupModelsList[3].label.equalsIgnoreCase('Baboon'));
        System.assertEquals(true, hlthChkGroupModelsList[3].status.equalsIgnoreCase('Pass'));
        System.assertEquals(true, hlthChkGroupModelsList[4].label.equalsIgnoreCase('Lion'));
        System.assertEquals(true, hlthChkGroupModelsList[4].status.equalsIgnoreCase('Pass'));
        System.assertEquals(true, hlthChkGroupModelsList[5].label.equalsIgnoreCase('Zebra'));
        System.assertEquals(true, hlthChkGroupModelsList[5].status.equalsIgnoreCase('Pass'));
    }

    /*****************************************************************************************
    * @description Test to verify compareTo() implementation separates HealthCheckGroupVModels 
    * with 'Fail' status from those with 'Pass' status (Fail above Pass) and in ascending 
    * alphabetical order by label within each group when duplicates exist.
    *****************************************************************************************/
    @isTest
    private static void sortByStatusThenLabelWithDuplicates(){
        List<HealthCheckGroupVModel> hlthChkGroupModelsList = new List<HealthCheckGroupVModel>();


        HealthCheckGroupVModel hlthChkGroupMod1 = new HealthCheckGroupVModel('Zebra',
                                                                           'Pass', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());

        HealthCheckGroupVModel hlthChkGroupMod2 = new HealthCheckGroupVModel('zebra',
                                                                           'pass', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());
        
        HealthCheckGroupVModel hlthChkGroupMod3 = new HealthCheckGroupVModel('Meerkat',
                                                                           'Fail', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());
       
        HealthCheckGroupVModel hlthChkGroupMod4 = new HealthCheckGroupVModel('lion',
                                                                           'fail', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());
        
        HealthCheckGroupVModel hlthChkGroupMod5 = new HealthCheckGroupVModel('Lion',
                                                                           'fail', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());
        
        HealthCheckGroupVModel hlthChkGroupMod6 = new HealthCheckGroupVModel('Antelope',
                                                                           'Pass', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());

        hlthChkGroupModelsList.add(hlthChkGroupMod1);
        hlthChkGroupModelsList.add(hlthChkGroupMod2);
        hlthChkGroupModelsList.add(hlthChkGroupMod3);        
        hlthChkGroupModelsList.add(hlthChkGroupMod4);
        hlthChkGroupModelsList.add(hlthChkGroupMod5);
        hlthChkGroupModelsList.add(hlthChkGroupMod6);

        Test.startTest();
        hlthChkGroupModelsList.sort();
        Test.stopTest();

        System.assertEquals(true, hlthChkGroupModelsList[0].label.equalsIgnoreCase('Lion'));
        System.assertEquals(true, hlthChkGroupModelsList[0].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, hlthChkGroupModelsList[1].label.equalsIgnoreCase('Lion'));
        System.assertEquals(true, hlthChkGroupModelsList[1].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, hlthChkGroupModelsList[2].label.equalsIgnoreCase('Meerkat'));
        System.assertEquals(true, hlthChkGroupModelsList[2].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, hlthChkGroupModelsList[3].label.equalsIgnoreCase('Antelope'));
        System.assertEquals(true, hlthChkGroupModelsList[3].status.equalsIgnoreCase('Pass'));
        System.assertEquals(true, hlthChkGroupModelsList[4].label.equalsIgnoreCase('Zebra'));
        System.assertEquals(true, hlthChkGroupModelsList[4].status.equalsIgnoreCase('Pass'));
        System.assertEquals(true, hlthChkGroupModelsList[5].label.equalsIgnoreCase('Zebra'));
        System.assertEquals(true, hlthChkGroupModelsList[5].status.equalsIgnoreCase('Pass'));
    }

    /*****************************************************************************************
    * @description Test to verify compareTo() implementation does not sort lists that 
    * contain Object of type other than HealthCheckGroupVModel, when the HealthCheckGroupVModel
    * is first in the list. 
    *****************************************************************************************/
    private static void sortWithIncomparableObjectTypesRightFirstInList(){
        List<Object> objectsToSort = new List<Object>();
        HealthCheckGroupVModel hlthChkGroupMod = new HealthCheckGroupVModel('Antelope',
                                                                           'Pass', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());

        Account testAccount = new Account(Name = 'TestAccount');
        Contact testContact = new Contact(LastName = 'Testerson');

        objectsToSort.add(hlthChkGroupMod);
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
        HealthCheckGroupVModel hlthChkGroupMod = new HealthCheckGroupVModel('Antelope',
                                                                           'Pass', 
                                                                           5, 
                                                                           8,
                                                                           new List<String>(), 
                                                                           new List<HealthCheckItemVModel>());


        HealthCheckItemVModel hlthChkItemVMod1 = new HealthCheckItemVModel('TestKey1', 
                                                                          'TestSetting', 
                                                                          'Fail', 
                                                                          'TestStatusLabel',
                                                                          'TestDescription', 
                                                                          'TextRecommendedFix',
                                                                          new List<HealthCheckItemVModel>());

        HealthCheckItemVModel hlthChkItemVMod2 = new HealthCheckItemVModel('TestKey2', 
                                                                          'TestSetting', 
                                                                          'Fail', 
                                                                          'TestStatusLabel',
                                                                          'TestDescription', 
                                                                          'TextRecommendedFix',
                                                                          new List<HealthCheckItemVModel>());
        Account testAccount = new Account(Name = 'TestAccount');
        Contact testContact = new Contact(LastName = 'Testerson');

        objectsToSort.add(hlthChkItemVMod1);
        objectsToSort.add(hlthChkGroupMod);
        objectsToSort.add(hlthChkItemVMod1);
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
}
