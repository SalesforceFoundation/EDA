/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group Tests
* @group-content ../../ApexDocContent/Tests.htm
* @description Tests for TST_CannotDelete_TDTM.
*/


@isTest
private class TST_CannotDelete_TEST {

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Test_Deletion__c is enabled in Hierarchy Settings and
    * Test has a child Test Score record associated with it, the Test record cannot be deleted.
    */
    @isTest 
    private static void cannotDeleteWithChildPreventDeleteOn() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Prevent_Test_Deletion__c = TRUE));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        insert contacts;

        List<Test__c> tests = new List<Test__c>();
        for (Contact contact : contacts) {
            Test__c tst = new Test__c(Contact__c = contact.Id, Test_Type__c = 'SAT', Test_Date__c = System.today() - 30);
            tests.add(tst);
        }
        insert tests;

        List<Test_Score__c> testScores = new List<Test_Score__c>();
        for (Test__c tst : tests) {
            Test_Score__c tstScr = new Test_Score__c(Test__c = tst.Id, Subject_Area__c = 'Language');
            testScores.add(tstScr);
        }
        insert testScores;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(tests, FALSE);
        Test.stopTest();

        List<Test__c> returnTests = [
            SELECT Id
            FROM Test__c
            WHERE Id IN :tests
        ];

        System.assertEquals(tests.size(), returnTests.size());

        for (Database.DeleteResult result : results) {
            System.assertEquals(Label.Cannotdelete, result.errors[0].message);
        }
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Test_Deletion__c is enabled in Hierarchy Settings and
    * Test is not associated with any child Test Score records, the Test record can be deleted.
    */
    @isTest 
    private static void canDeleteWithoutChildPreventDeleteOn() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Prevent_Test_Deletion__c = TRUE));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        insert contacts;

        List<Test__c> tests = new List<Test__c>();
        for (Contact contact : contacts) {
            Test__c tst = new Test__c(Contact__c = contact.Id, Test_Type__c = 'SAT', Test_Date__c = System.today() - 30);
            tests.add(tst);
        }
        insert tests;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(tests, FALSE);
        Test.stopTest();

        List<Test__c> returnTests = [
            SELECT Id
            FROM Test__c
            WHERE Id IN :tests
        ];

        System.assertEquals(TRUE, returnTests.isEmpty());

        for (Database.DeleteResult result : results) {
            System.assertEquals(TRUE, result.success);
        }
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Test_Deletion__c is disabled in Hierarchy Settings and
    * Test has a child Test Score record associated to it, the Test record can be deleted.
    */
    @isTest 
    private static void canDeleteWithChildPreventDeleteOff() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Prevent_Test_Deletion__c = FALSE));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        insert contacts;

        List<Test__c> tests = new List<Test__c>();
        for (Contact contact : contacts) {
            Test__c tst = new Test__c(Contact__c = contact.Id, Test_Type__c = 'SAT', Test_Date__c = System.today() - 30);
            tests.add(tst);
        }
        insert tests;

        List<Test_Score__c> testScores = new List<Test_Score__c>();
        for (Test__c tst : tests) {
            Test_Score__c tstScr = new Test_Score__c(Test__c = tst.Id, Subject_Area__c = 'Language');
            testScores.add(tstScr);
        }
        insert testScores;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(tests, FALSE);
        Test.stopTest();

        List<Test__c> returnTests = [
            SELECT Id
            FROM Test__c
            WHERE Id IN :tests
        ];

        System.assertEquals(TRUE, returnTests.isEmpty());

        for (Database.DeleteResult result : results) {
            System.assertEquals(TRUE, result.success);
        }
    }

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Test_Deletion__c is disabled in Hierarchy Settings and
    * Test is not associated with any child Test Score records, the Test record can be deleted.
    */
    @isTest 
    private static void canDeleteWithoutChildPreventDeleteOff() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Prevent_Test_Deletion__c = FALSE));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        insert contacts;

        List<Test__c> tests = new List<Test__c>();
        for (Contact contact : contacts) {
            Test__c tst = new Test__c(Contact__c = contact.Id, Test_Type__c = 'SAT', Test_Date__c = System.today() - 30);
            tests.add(tst);
        }
        insert tests;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(tests, FALSE);
        Test.stopTest();

        List<Test__c> returnTests = [
            SELECT Id
            FROM Test__c
            WHERE Id IN :tests
        ];

        System.assertEquals(TRUE, returnTests.isEmpty());

        for (Database.DeleteResult result : results) {
            System.assertEquals(TRUE, result.success);
        }
    }

    /*********************************************************************************************************
    * @description Test method for the hasChildRecords() method in TST_CannotDelete_TDTM to test that TRUE
    * is returned for a Test record with Test Score child records.
    */
    @isTest
    private static void hasChildRecordsIsTrue() {
        
        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        insert contacts;

        List<Test__c> tests = new List<Test__c>();
        for (Contact contact : contacts) {
            Test__c tst = new Test__c(Contact__c = contact.Id, Test_Type__c = 'SAT', Test_Date__c = System.today() - 30);
            tests.add(tst);
        }
        insert tests;

        List<Test_Score__c> testScores = new List<Test_Score__c>();
        for (Test__c tst : tests) {
            Test_Score__c tstScr = new Test_Score__c(Test__c = tst.Id, Subject_Area__c = 'Language');
            testScores.add(tstScr);
        }
        insert testScores;

        List<Test__c> returnTests = [
            SELECT Id, 
                (SELECT Id FROM Test__c.Test_Scores__r)
            FROM Test__c
            WHERE Id IN :tests
        ];

        TST_CannotDelete_TDTM tstCannotDeleteClass = new TST_CannotDelete_TDTM();

        for (Test__c tst : returnTests) {
            System.assertEquals(TRUE, tstCannotDeleteClass.hasChildRecords(tst));
        }
    }

    /*********************************************************************************************************
    * @description Test method for the hasChildRecords() method in TST_CannotDelete_TDTM to test that FALSE
    * is returned for a Test record with no child records.
    */
    @isTest
    private static void hasChildRecordsIsFalse() {
        
        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(5);
        insert contacts;

        List<Test__c> tests = new List<Test__c>();
        for (Contact contact : contacts) {
            Test__c tst = new Test__c(Contact__c = contact.Id, Test_Type__c = 'SAT', Test_Date__c = System.today() - 30);
            tests.add(tst);
        }
        insert tests;

        List<Test__c> returnTests = [
            SELECT Id, 
                (SELECT Id FROM Test__c.Test_Scores__r)
            FROM Test__c
            WHERE Id IN :tests
        ];

        TST_CannotDelete_TDTM tstCannotDeleteClass = new TST_CannotDelete_TDTM();

        for (Test__c tst : returnTests) {
            System.assertEquals(FALSE, tstCannotDeleteClass.hasChildRecords(tst));
        }
    }
}
