@isTest 
public with sharing class HealthCheckItemVModel_TEST {

    /*****************************************************************************************
    * @description Test to verify constructor with 5 parameters generates model as expected.
    *****************************************************************************************/
    @isTest 
    private static void constructorWithFiveParamsValid(){

        List<HealthCheckItemVModel> sampleHCItemVModList = new List<HealthCheckItemVModel>();

        Test.startTest();
        HealthCheckItemVModel hlthChkItemVMod = new HealthCheckItemVModel('TestKey', 
                                                                          'TestSetting', 
                                                                          'TestStatus', 
                                                                          'TestStatusLabel',
                                                                          'TestDescription', 
                                                                          'TextRecommendedFix',
                                                                          sampleHCItemVModList);
        Test.stopTest();

        System.assertEquals('TestKey', hlthChkItemVMod.key, 'HealthCheckItemVModel key should be set to \'TestKey\'');
        System.assertEquals('TestSetting', hlthChkItemVMod.setting, 'HealthCheckItemVModel setting should be set to \'TestSetting\'');
        System.assertEquals('TestStatus', hlthChkItemVMod.status, 'HealthCheckItemVModel status should be set to \'TestStatus\'');
        System.assertEquals('TestStatusLabel', hlthChkItemVMod.statusLabel, 'HealthCheckItemVModel statuslabel should be set to \'TestStatusLabel\'');
        System.assertEquals('TestDescription', hlthChkItemVMod.description, 'HealthCheckItemVModel description should be set to \'TestDescription\'');
        System.assertEquals('TextRecommendedFix', hlthChkItemVMod.recommendedFix, 'HealthCheckItemVModel recommendedFix should be set to \'TextRecommendedFix\'');
        System.assertEquals(sampleHCItemVModList, hlthChkItemVMod.healthCheckItemList, 'List of HealthCheckItemVModel should not change.');
    }

    /*****************************************************************************************
    * @description Test to verify compareTo() implementation separates HealthCheckGroupVModels 
    * with 'Fail' status from those with 'Pass' status (Fail above Pass) and in ascending 
    * alphabetical order by label within each group when duplicates do not exist.
    *****************************************************************************************/
    @isTest
    private static void sortByStatusThenLabelWithoutDuplicates(){
        List<HealthCheckItemVModel> hlthChkItemModelsList = new List<HealthCheckItemVModel>();


        HealthCheckItemVModel hlthChkItemMod1 = new HealthCheckItemVModel('key-1',
                                                                           'Zebra',
                                                                           'Fail', 
                                                                           'Fail-Label', 
                                                                           'Test Description',
                                                                           'Test Recommended fix', 
                                                                           new List<HealthCheckItemVModel>());

        HealthCheckItemVModel hlthChkItemMod2 = new HealthCheckItemVModel('key-2',
                                                                            'Zebra',
                                                                            'pass', 
                                                                            'pass-Label', 
                                                                            'Test Description',
                                                                            'Test Recommended fix', 
                                                                            new List<HealthCheckItemVModel>());
        
        HealthCheckItemVModel hlthChkItemMod3 = new HealthCheckItemVModel('key-3',
                                                                            'Baboon',
                                                                            'Pass', 
                                                                            'Pass-Label', 
                                                                            'Test Description',
                                                                            'Test Recommended fix', 
                                                                            new List<HealthCheckItemVModel>());
       
        HealthCheckItemVModel hlthChkItemMod4 = new HealthCheckItemVModel('key-4',
                                                                            'Giraffe',
                                                                            'Fail', 
                                                                            'Fail-Label', 
                                                                            'Test Description',
                                                                            'Test Recommended fix', 
                                                                            new List<HealthCheckItemVModel>());
        
        HealthCheckItemVModel hlthChkItemMod5 = new HealthCheckItemVModel('key-5',
                                                                            'Lion',
                                                                            'Pass', 
                                                                            'Pass-Label', 
                                                                            'Test Description',
                                                                            'Test Recommended fix', 
                                                                            new List<HealthCheckItemVModel>());
        
        HealthCheckItemVModel hlthChkItemMod6 = new HealthCheckItemVModel('key-1',
                                                                            'Antelope',
                                                                            'Fail', 
                                                                            'Fail-Label', 
                                                                            'Test Description',
                                                                            'Test Recommended fix', 
                                                                            new List<HealthCheckItemVModel>());

        hlthChkItemModelsList.add(hlthChkItemMod1);
        hlthChkItemModelsList.add(hlthChkItemMod2);
        hlthChkItemModelsList.add(hlthChkItemMod3);        
        hlthChkItemModelsList.add(hlthChkItemMod4);
        hlthChkItemModelsList.add(hlthChkItemMod5);
        hlthChkItemModelsList.add(hlthChkItemMod6);

        Test.startTest();
        hlthChkItemModelsList.sort();
        Test.stopTest();

        System.assertEquals(true, hlthChkItemModelsList[0].setting.equalsIgnoreCase('Antelope'));
        System.assertEquals(true, hlthChkItemModelsList[0].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, hlthChkItemModelsList[1].setting.equalsIgnoreCase('Giraffe'));
        System.assertEquals(true, hlthChkItemModelsList[1].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, hlthChkItemModelsList[2].setting.equalsIgnoreCase('Zebra'));
        System.assertEquals(true, hlthChkItemModelsList[2].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, hlthChkItemModelsList[3].setting.equalsIgnoreCase('Baboon'));
        System.assertEquals(true, hlthChkItemModelsList[3].status.equalsIgnoreCase('Pass'));
        System.assertEquals(true, hlthChkItemModelsList[4].setting.equalsIgnoreCase('Lion'));
        System.assertEquals(true, hlthChkItemModelsList[4].status.equalsIgnoreCase('Pass'));
        System.assertEquals(true, hlthChkItemModelsList[5].setting.equalsIgnoreCase('Zebra'));
        System.assertEquals(true, hlthChkItemModelsList[5].status.equalsIgnoreCase('Pass'));
    }

    /*****************************************************************************************
    * @description Test to verify compareTo() implementation separates HealthCheckGroupVModels 
    * with 'Fail' status from those with 'Pass' status (Fail above Pass) and in ascending 
    * alphabetical order by label within each group when duplicates exist.
    *****************************************************************************************/
    @isTest
    private static void sortByStatusThenLabelWithDuplicates(){
        List<HealthCheckItemVModel> hlthChkItemModelsList = new List<HealthCheckItemVModel>();


        HealthCheckItemVModel hlthChkItemMod1 = new HealthCheckItemVModel('key-1',
                                                                          'Zebra',
                                                                          'Pass', 
                                                                          'Pass-label', 
                                                                          'Test Description',
                                                                          'Test Recommended Fix', 
                                                                          new List<HealthCheckItemVModel>());

                                                                          

        HealthCheckItemVModel hlthChkItemMod2 = new HealthCheckItemVModel('key-2',
                                                                          'zebra',
                                                                          'pass', 
                                                                          'pass-label', 
                                                                          'Test Description',
                                                                          'Test Recommended Fix', 
                                                                          new List<HealthCheckItemVModel>());


        HealthCheckItemVModel hlthChkItemMod3 = new HealthCheckItemVModel('key-3',
                                                                          'Meerkat',
                                                                          'Fail', 
                                                                          'Fail-label', 
                                                                          'Test Description',
                                                                          'Test Recommended Fix', 
                                                                          new List<HealthCheckItemVModel>());


        HealthCheckItemVModel hlthChkItemMod4 = new HealthCheckItemVModel('key-4',
                                                                          'lion',
                                                                          'fail', 
                                                                          'fail-label', 
                                                                          'Test Description',
                                                                          'Test Recommended Fix', 
                                                                          new List<HealthCheckItemVModel>());


        HealthCheckItemVModel hlthChkItemMod5 = new HealthCheckItemVModel('key-5',
                                                                          'Lion',
                                                                          'fail', 
                                                                          'fail-label', 
                                                                          'Test Description',
                                                                          'Test Recommended Fix', 
                                                                          new List<HealthCheckItemVModel>());


        HealthCheckItemVModel hlthChkItemMod6 = new HealthCheckItemVModel('key-6',
                                                                          'Antelope',
                                                                          'Pass', 
                                                                          'Pass-label', 
                                                                          'Test Description',
                                                                          'Test Recommended Fix', 
                                                                          new List<HealthCheckItemVModel>());


        hlthChkItemModelsList.add(hlthChkItemMod1);
        hlthChkItemModelsList.add(hlthChkItemMod2);
        hlthChkItemModelsList.add(hlthChkItemMod3);        
        hlthChkItemModelsList.add(hlthChkItemMod4);
        hlthChkItemModelsList.add(hlthChkItemMod5);
        hlthChkItemModelsList.add(hlthChkItemMod6);

        Test.startTest();
        hlthChkItemModelsList.sort();
        Test.stopTest();

        System.assertEquals(true, hlthChkItemModelsList[0].setting.equalsIgnoreCase('Lion'));
        System.assertEquals(true, hlthChkItemModelsList[0].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, hlthChkItemModelsList[1].setting.equalsIgnoreCase('Lion'));
        System.assertEquals(true, hlthChkItemModelsList[1].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, hlthChkItemModelsList[2].setting.equalsIgnoreCase('Meerkat'));
        System.assertEquals(true, hlthChkItemModelsList[2].status.equalsIgnoreCase('Fail'));
        System.assertEquals(true, hlthChkItemModelsList[3].setting.equalsIgnoreCase('Antelope'));
        System.assertEquals(true, hlthChkItemModelsList[3].status.equalsIgnoreCase('Pass'));
        System.assertEquals(true, hlthChkItemModelsList[4].setting.equalsIgnoreCase('Zebra'));
        System.assertEquals(true, hlthChkItemModelsList[4].status.equalsIgnoreCase('Pass'));
        System.assertEquals(true, hlthChkItemModelsList[5].setting.equalsIgnoreCase('Zebra'));
        System.assertEquals(true, hlthChkItemModelsList[5].status.equalsIgnoreCase('Pass'));
    }

    /*****************************************************************************************
    * @description Test to verify compareTo() implementation does not sort lists that 
    * contain Object of type other than HealthCheckItemVModel, when the HealthCheckItemVModel
    * is first in the list. 
    *****************************************************************************************/
    private static void sortWithIncomparableObjectTypesRightFirstInList(){
        List<Object> objectsToSort = new List<Object>();
        HealthCheckItemVModel hlthChkItemMod = new HealthCheckItemVModel('key-1',
                                                                         'Antelope',
                                                                         'Pass', 
                                                                         'Pass-label', 
                                                                         'Test Description',
                                                                         'Test Recommended Fix', 
                                                                         new List<HealthCheckItemVModel>());

        Account testAccount = new Account(Name = 'TestAccount');
        Contact testContact = new Contact(LastName = 'Testerson');

        objectsToSort.add(hlthChkItemMod);
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

        HealthCheckGroupVModel hlthChkGroupVMod = new HealthCheckGroupVModel('Zebra',
                                                                             'Fail', 
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

        objectsToSort.add(hlthChkGroupVMod);
        objectsToSort.add(hlthChkItemVMod1);
        objectsToSort.add(hlthChkItemVMod2);
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
}
