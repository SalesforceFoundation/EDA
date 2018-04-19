/**
* @author Salesforce.org
* @date 2018
* @group API
* @group-content ../../ApexDocContent/API.htm
* @description API class that exposes the Test Data Utility methods.
*/
global class UTIL_UnitTestData_API {

    global static Contact getContact() {
    	return UTIL_UnitTestData_TEST.getContact();
    }
    
    global static List<Contact> getMultipleTestContacts(Integer n) {
        return UTIL_UnitTestData_TEST.getMultipleTestContacts(n);
    }

    global static List<Account> getMultipleTestAccounts(Integer n, ID recTypeId) {
        return UTIL_UnitTestData_TEST.getMultipleTestAccounts(n, recTypeId);
    }

    global static User createNewUserForTests(String strUsername) {
        return UTIL_UnitTestData_TEST.createNewUserForTests(strUsername);
    }
    
    /*********************************************************************************************************
    * @description Initializes (but not inserts) N new Address objects.
    * @param addrCount the number of Address objects to create
    * @return  void
    **********************************************************************************************************/
    global static List<Address__c> getMultipleTestAddresses(Integer addrCount) {
        return UTIL_UnitTestData_TEST.getMultipleTestAddresses(addrCount);
    }

}