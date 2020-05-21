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
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER s
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2020
* @group Affiliations
* @group-content ../../ApexDocContent/Affiliations.htm
* @description Tests for AFFL_CannotDelete_TDTM.
*/

@isTest
private class AFFL_CannotDelete_TEST {
    /*********************************************************************************************************
    * @description Retrieves the record type Id for Academic Programs. 
    */
    public static String academicAccRecordTypeID = UTIL_Describe.getAcademicAccRecTypeID(); 

    /*********************************************************************************************************
    * @description Test method to test when Prevent_Affiliation_Deletion__c is enabled in Hierarchy 
    * Settings and Affiliation has a child Course Connection record associated with it, the Affiliation 
    * record cannot be deleted.
    */
    @isTest 
    private static void cannotDeleteWithChildCourseConnectionPreventDeleteOn() {

        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Prevent_Affiliation_Deletion__c = TRUE));

        Contact testContact = UTIL_UnitTestData_TEST.getContact();
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, academicAccRecordTypeID);

        insert testContact;
        insert accounts;

        List<Affiliation__c> affiliations = new List<Affiliation__c>();
        for (Integer index = 0; index < 5; index++){
            affiliations.add(UTIL_UnitTestData_TEST.getAffiliation(testContact.Id, accounts[0].Id, TRUE));
        }
        insert affiliations;

        Course__c course = new Course__c(Name = 'Test Course', Account__c = accounts[0].Id);
        insert course;

        Term__c term = UTIL_UnitTestData_TEST.getTerm(accounts[0].Id, 'Test Term');
        insert term;

        Course_Offering__c courseOffering = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);

        List<Course_Enrollment__c> courseConnections = new List<Course_Enrollment__c>();
        for (Integer index = 0; index < 5; index++){
            Course_Enrollment__c courseConnection = UTIL_UnitTestData_TEST.getCourseConnection(testContact.Id, courseOffering.Id);
            courseConnection.Affiliation__c = affiliations[index].Id;
            courseConnections.add(courseConnection);
        }
        insert courseConnections;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(affiliations, FALSE);
        Test.stopTest();

        List<Affiliation__c> returnAffiliations = [
            SELECT Id
            FROM Affiliation__c
            WHERE Id IN :affiliations
        ];

        System.assertEquals(affiliations.size(), returnAffiliations.size());
        
        for (Database.DeleteResult result : results) {
            System.assertEquals(Label.CannotDelete, result.errors[0].message);
        }
    }

    /*********************************************************************************************************
    * @description Test method to test when Prevent_Affiliation_Deletion__c is enabled in Hierarchy 
    * Settings and Affiliation has no child records associated with it, the Affiliation 
    * record can be deleted.
    */
    @isTest 
    private static void canDeleteWithoutChildCourseConnectionPreventDeleteOn() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Prevent_Affiliation_Deletion__c = TRUE));

        Contact testContact = UTIL_UnitTestData_TEST.getContact();
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, academicAccRecordTypeID);

        insert testContact;
        insert accounts;

        List<Affiliation__c> affiliations = new List<Affiliation__c>();
        for (Integer index = 0; index < 5; index++){
            affiliations.add(UTIL_UnitTestData_TEST.getAffiliation(testContact.Id, accounts[0].Id, TRUE));
        }
        insert affiliations;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(affiliations, FALSE);
        Test.stopTest();

        List<Affiliation__c> returnAffiliations = [
            SELECT Id
            FROM Affiliation__c
            WHERE Id IN :affiliations
        ];

        System.assertEquals(TRUE, returnAffiliations.isEmpty());
        
        for (Database.DeleteResult result : results) {
            System.assertEquals(TRUE, result.isSuccess());
        }
    }

    /*********************************************************************************************************
    * @description Test method to test when Prevent_Affiliation_Deletion__c is disabled in Hierarchy 
    * Settings and Affiliation has Course Connection child records associated with it, the Affiliation 
    * record can be deleted.
    */
    @isTest 
    private static void canDeleteWithChildCourseConnectionPreventDeleteOff() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Prevent_Affiliation_Deletion__c = FALSE));

        Contact testContact = UTIL_UnitTestData_TEST.getContact();
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, academicAccRecordTypeID);

        insert testContact;
        insert accounts;

        List<Affiliation__c> affiliations = new List<Affiliation__c>();
        for (Integer index = 0; index < 5; index++){
            affiliations.add(UTIL_UnitTestData_TEST.getAffiliation(testContact.Id, accounts[0].Id, TRUE));
        }
        insert affiliations;

        Course__c course = new Course__c(Name = 'Test Course', Account__c = accounts[0].Id);
        insert course;

        Term__c term = UTIL_UnitTestData_TEST.getTerm(accounts[0].Id, 'Test Term');
        insert term;

        Course_Offering__c courseOffering = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);

        List<Course_Enrollment__c> courseConnections = new List<Course_Enrollment__c>();
        for (Integer index = 0; index < 5; index++){
            Course_Enrollment__c courseConnection = UTIL_UnitTestData_TEST.getCourseConnection(testContact.Id, courseOffering.Id);
            courseConnection.Affiliation__c = affiliations[index].Id;
            courseConnections.add(courseConnection);
        }
        insert courseConnections;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(affiliations, FALSE);
        Test.stopTest();

        List<Affiliation__c> returnAffiliations = [
            SELECT Id
            FROM Affiliation__c
            WHERE Id IN :affiliations
        ];

        System.assertEquals(TRUE, returnAffiliations.isEmpty());
        
        for (Database.DeleteResult result : results) {
            System.assertEquals(TRUE, result.isSuccess());
        }
    }

    /*********************************************************************************************************
    * @description Test method to test when Prevent_Affiliation_Deletion__c is disabled in Hierarchy 
    * Settings and Affiliation has no child records associated with it, the Affiliation 
    * record can be deleted.
    */
    @isTest 
    private static void canDeleteWithoutChildCourseConnectionPreventDeleteOff() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Prevent_Affiliation_Deletion__c = FALSE));

        Contact testContact = UTIL_UnitTestData_TEST.getContact();
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, academicAccRecordTypeID);

        insert testContact;
        insert accounts;

        List<Affiliation__c> affiliations = new List<Affiliation__c>();
        for (Integer index = 0; index < 5; index++){
            affiliations.add(UTIL_UnitTestData_TEST.getAffiliation(testContact.Id, accounts[0].Id, TRUE));
        }
        insert affiliations;

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(affiliations, FALSE);
        Test.stopTest();

        List<Affiliation__c> returnAffiliations = [
            SELECT Id
            FROM Affiliation__c
            WHERE Id IN :affiliations
        ];

        System.assertEquals(TRUE, returnAffiliations.isEmpty());
        
        for (Database.DeleteResult result : results) {
            System.assertEquals(TRUE, result.isSuccess());
        }
    }

    /*********************************************************************************************************
    * @description Test method for the hasChildRecords() method in AFFL_CannotDelete_TDTM to test that TRUE
    * is returned for an Affiliation record with associated Course Connection child records.
    */
    @isTest 
    private static void hasChildRecordsIsTrue() {
        Contact testContact = UTIL_UnitTestData_TEST.getContact();
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, academicAccRecordTypeID);

        insert testContact;
        insert accounts;

        List<Affiliation__c> affiliations = new List<Affiliation__c>();
        for (Integer index = 0; index < 5; index++){
            affiliations.add(UTIL_UnitTestData_TEST.getAffiliation(testContact.Id, accounts[0].Id, TRUE));
        }
        insert affiliations;

        Course__c course = new Course__c(Name = 'Test Course', Account__c = accounts[0].Id);
        insert course;

        Term__c term = UTIL_UnitTestData_TEST.getTerm(accounts[0].Id, 'Test Term');
        insert term;

        Course_Offering__c courseOffering = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);

        List<Course_Enrollment__c> courseConnections = new List<Course_Enrollment__c>();
        for (Integer index = 0; index < 5; index++){
            Course_Enrollment__c courseConnection = UTIL_UnitTestData_TEST.getCourseConnection(testContact.Id, courseOffering.Id);
            courseConnection.Affiliation__c = affiliations[index].Id;
            courseConnections.add(courseConnection);
        }
        insert courseConnections;

        List<Affiliation__c> returnAffiliations = [
            SELECT Id,
                (SELECT Id FROM Course_Enrollment__r)
            FROM Affiliation__c
            WHERE Id IN :affiliations
        ];

        AFFL_CannotDelete_TDTM afflCannotDelete = new AFFL_CannotDelete_TDTM();
        for (Affiliation__c affl : returnAffiliations){
            System.assertEquals(TRUE, afflCannotDelete.hasChildRecords(affl));
        }
    }

    /*********************************************************************************************************
    * @description Test method for the hasChildRecords() method in AFFL_CannotDelete_TDTM to test that FALSE
    * is returned for an Affiliation record with no associated child records.
    */
    @isTest 
    private static void hasChildRecordsIsFalse() {
        Contact testContact = UTIL_UnitTestData_TEST.getContact();
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, academicAccRecordTypeID);

        insert testContact;
        insert accounts;

        List<Affiliation__c> affiliations = new List<Affiliation__c>();
        for (Integer index = 0; index < 5; index++){
            affiliations.add(UTIL_UnitTestData_TEST.getAffiliation(testContact.Id, accounts[0].Id, TRUE));
        }
        insert affiliations;

        List<Affiliation__c> returnAffiliations = [
            SELECT Id,
                (SELECT Id FROM Course_Enrollment__r)
            FROM Affiliation__c
            WHERE Id IN :affiliations
        ];

        AFFL_CannotDelete_TDTM afflCannotDelete = new AFFL_CannotDelete_TDTM();
        for (Affiliation__c affl : returnAffiliations){
            System.assertEquals(FALSE, afflCannotDelete.hasChildRecords(affl));
        }
    }
}
