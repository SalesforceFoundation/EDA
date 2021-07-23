@isTest
private class CallableError_TEST {
    @isTest
    private static void testConstructor() {
        String errorMessage = 'testErrorMessage';
        Integer code = 1;

        CallableError error;

        Test.startTest();
        error = new CallableError(code, errorMessage);
        Test.stopTest();

        System.assertEquals(errorMessage, error.message, 'error.message should be: ' + errorMessage);
        System.assertEquals(code, error.code, 'error code should be: ' + code);
    }
}
