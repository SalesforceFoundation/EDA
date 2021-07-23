@isTest
private class CallableResult_TEST {
    @isTest
    private static void testConstructor() {
        Boolean success = false;
        CallableError error = new CallableError(1, 'testErrorMessage');

        CallableResult result;

        Test.startTest();
        result = new CallableResult(success, error);
        Test.stopTest();

        System.assertEquals(success, result.success, 'success should be: ' + success);
        System.assertEquals(1, result.error.code, 'error code should be: 1');
        System.assertEquals('testErrorMessage', result.error.message, 'error code should be: testErrorMessage');
    }
}
