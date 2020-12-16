@isTest 
public with sharing class HealthCheckItemVModel_TEST {

    /*****************************************************************************************
    * @description Test to verify constructor with 5 parameters generates model as expected.
    *****************************************************************************************/
    @isTest 
    private static void constructorWithFiveParamsValid(){
        Test.startTest();
        HealthCheckItemVModel hlthChkItemVMod = new HealthCheckItemVModel('TestKey', 
                                                                          'TestSetting', 
                                                                          'TestStatus', 
                                                                          'TestStatusLabel',
                                                                          'TestDescription', 
                                                                          'TextRecommendedFix');
        Test.stopTest();

        System.assertEquals('TestKey', hlthChkItemVMod.key, 'HealthCheckItemVModel key should be set to \'TestKey\'');
        System.assertEquals('TestSetting', hlthChkItemVMod.setting, 'HealthCheckItemVModel setting should be set to \'TestSetting\'');
        System.assertEquals('TestStatus', hlthChkItemVMod.status, 'HealthCheckItemVModel status should be set to \'TestStatus\'');
        System.assertEquals('TestStatusLabel', hlthChkItemVMod.statusLabel, 'HealthCheckItemVModel statuslabel should be set to \'TestStatusLabel\'');
        System.assertEquals('TestDescription', hlthChkItemVMod.description, 'HealthCheckItemVModel description should be set to \'TestDescription\'');
        System.assertEquals('TextRecommendedFix', hlthChkItemVMod.recommendedFix, 'HealthCheckItemVModel recommendedFix should be set to \'TextRecommendedFix\'');
    }

    /*****************************************************************************************
    * @description Test to verify that compareTo() sorts by....
    *****************************************************************************************/
    private static void sortValid(){
        List<HealthCheckItemVModel> hlthChkItemVModelsList = new List<HealthCheckItemVModel>();

        Test.startTest();
        hlthChkItemVModelsList.sort();
        Test.stopTest();
    }
}
