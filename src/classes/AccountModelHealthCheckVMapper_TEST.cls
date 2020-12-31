@isTest
public with sharing class AccountModelHealthCheckVMapper_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * AccountModelHealthCheckVMapper class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            AccountModelHealthCheckVMapper accountModelHealthCheckVMapperInstance = AccountModelHealthCheckVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(AccountModelHealthCheckVMapper.instance, accountModelHealthCheckVMapperInstance, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(true, accountModelHealthCheckVMapperInstance != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * AccountModelHealthCheckVMapper class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            AccountModelHealthCheckVMapper accountModelHealthCheckVMapperInstance1 = AccountModelHealthCheckVMapper.getInstance();
            AccountModelHealthCheckVMapper accountModelHealthCheckVMapperInstance2 = AccountModelHealthCheckVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(AccountModelHealthCheckVMapper.instance, accountModelHealthCheckVMapperInstance1, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(accountModelHealthCheckVMapperInstance1, accountModelHealthCheckVMapperInstance2, 'Subsequent retrievals of mapper class instance should return existing instance.');
        System.assertEquals(true, accountModelHealthCheckVMapperInstance1 != null, 'Instance of mapper class should not be null.');
    }
}
