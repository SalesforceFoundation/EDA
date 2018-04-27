/*
    Copyright (c) 2018 Salesforce.org
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
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

    /*******************************************************************************************************
    * @description Static method that detects if we are running in a sandbox.
    * @return true if running in sandbox. false otherwise.
    */
    global static Boolean isSandbox() {
        return UTIL_Namespace.isSandbox();
    }

    /*******************************************************************************************************
    * @description Static method that returns the real email if it's a sandbox email.
    * @return string with user's email.
    */
    global static String sandboxEmailToRealEmail(String email) {
        return UTIL_Namespace.sandboxEmailToRealEmail(email);
    }

}