@isTest 
public with sharing class HealthCheckGroupService_TEST {

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * HealthCheckGroupService class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
            HealthCheckGroupService HealthCheckGroupServiceInstance = HealthCheckGroupService.getInstance();
        Test.stopTest();

        System.assertEquals(HealthCheckGroupService.instance, HealthCheckGroupServiceInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, HealthCheckGroupServiceInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * HealthCheckGroupService class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
            HealthCheckGroupService HealthCheckGroupServiceInstance1 = HealthCheckGroupService.getInstance();
            HealthCheckGroupService HealthCheckGroupServiceInstance2 = HealthCheckGroupService.getInstance();
        Test.stopTest();

        System.assertEquals(HealthCheckGroupService.instance, HealthCheckGroupServiceInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(HealthCheckGroupServiceInstance1, HealthCheckGroupServiceInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, HealthCheckGroupServiceInstance1 != null, 'Instance of service class should not be null.');
    }
}
