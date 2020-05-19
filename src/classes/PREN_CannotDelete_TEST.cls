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
* @group Program Enrollment
* @group-content ../../ApexDocContent/ProgramEnrollment.htm
* @description Tests for PREN_CannotDelete_TDTM
*/
@isTest
private class PREN_CannotDelete_TEST {
    /*********************************************************************************************************
    * @description Retrieves the Administrative record type Id. 
    */
    public static String adminAccRecTypeId = UTIL_Describe.getAdminAccRecTypeID(); 
    
    /*********************************************************************************************************
    * @description Retrieves the Academic Program record type Id. 
    */
    public static String academicAccRecTypeId = UTIL_Describe.getAcademicAccRecTypeID(); 
    
    /*********************************************************************************************************
    * @description Test method to test if Prevent_Program_Enrollment_Deletion__c is enabled in Hierarchy Settings, and
    * Program Enrollment has a Course Connection record associated to it, then it cannot be deleted.
    */
    @isTest
    public static void cannotDeleteProgramEnrollmentWithCourseConn(){
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = PREN_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Program_Enrollment_Deletion__c = True));
        
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, PREN_CannotDelete_TEST.academicAccRecTypeId); 
        insert accounts; 
        
        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts; 
        
        List<Program_Enrollment__c> programEnrollments = UTIL_UnitTestData_TEST.getMultipleTestProgramEnrollments(2, accounts[0].Id); 
        programEnrollments[0].Contact__c = contacts[0].Id; 
        programEnrollments[1].Contact__c = contacts[1].Id; 
        insert programEnrollments; 
        
        Course__c course = new Course__c(Name = 'Intro to Neuroscience', Account__c = accounts[0].Id); 
        insert course; 
        
        Term__c term = UTIL_UnitTestData_TEST.getTerm(accounts[0].Id, 'Fall'); 
        insert term; 

        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id); 
        Course_Offering__c courseOffering2 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);
        
        Course_Enrollment__c courseConnection1 = UTIL_UnitTestData_TEST.getCourseConnection(contacts[0].Id, courseOffering1.Id); 
        Course_Enrollment__c courseConnection2 = UTIL_UnitTestData_TEST.getCourseConnection(contacts[1].Id, courseOffering2.Id);
        courseConnection1.Program_Enrollment__c = programEnrollments[0].Id; 
        courseConnection2.Program_Enrollment__c = programEnrollments[1].Id; 
        insert courseConnection1;
        insert courseConnection2; 
        
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(programEnrollments, false);
        Test.stopTest();

        List<Program_Enrollment__c> returnProgramEnrollments = [SELECT Id
                                                                FROM Program_Enrollment__c
                                                                WHERE Id IN :programEnrollments]; 
        System.assertEquals(2, returnProgramEnrollments.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);  
    }
    
    /*********************************************************************************************************
    * @description Test method to test if Prevent_Program_Enrollment_Deletion__c is disabled in Hierarchy Settings, and
    * Program Enrollment has a Course Connection record associated to it, then it can be deleted.
    */
    @isTest
    public static void canDeleteProgramEnrollmentWithCourseConn(){
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = PREN_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Program_Enrollment_Deletion__c = False));

        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, PREN_CannotDelete_TEST.academicAccRecTypeId); 
        insert accounts; 

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts; 

        List<Program_Enrollment__c> programEnrollments = UTIL_UnitTestData_TEST.getMultipleTestProgramEnrollments(2, accounts[0].Id); 
        programEnrollments[0].Contact__c = contacts[0].Id; 
        programEnrollments[1].Contact__c = contacts[1].Id; 
        insert programEnrollments; 

        Course__c course = new Course__c(Name = 'Intro to Neuroscience', Account__c = accounts[0].Id); 
        insert course; 

        Term__c term = UTIL_UnitTestData_TEST.getTerm(accounts[0].Id, 'Fall'); 
        insert term; 

        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id); 
        Course_Offering__c courseOffering2 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);

        Course_Enrollment__c courseConnection1 = UTIL_UnitTestData_TEST.getCourseConnection(contacts[0].Id, courseOffering1.Id); 
        Course_Enrollment__c courseConnection2 = UTIL_UnitTestData_TEST.getCourseConnection(contacts[1].Id, courseOffering2.Id);
        courseConnection1.Program_Enrollment__c = programEnrollments[0].Id; 
        courseConnection2.Program_Enrollment__c = programEnrollments[1].Id; 
        insert courseConnection1;
        insert courseConnection2; 

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(programEnrollments, false);
        Test.stopTest();

        List<Program_Enrollment__c> returnProgramEnrollments = [SELECT Id
                                                                FROM Program_Enrollment__c
                                                                WHERE Id IN :programEnrollments]; 
        System.assertEquals(0, returnProgramEnrollments.size());
    }
    
    /*********************************************************************************************************
    * @description Tests the hasChildRecords method that the Program Enrollment record has child records. 
    */
    @isTest
    public static void testProgramEnrollmentHasChildRecords(){
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = PREN_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Program_Enrollment_Deletion__c = True));
        
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, PREN_CannotDelete_TEST.academicAccRecTypeId); 
        insert accounts; 
        
        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts; 
        
        List<Program_Enrollment__c> programEnrollments = UTIL_UnitTestData_TEST.getMultipleTestProgramEnrollments(2, accounts[0].Id); 
        programEnrollments[0].Contact__c = contacts[0].Id; 
        programEnrollments[1].Contact__c = contacts[1].Id; 
        insert programEnrollments; 
        
        Course__c course = new Course__c(Name = 'Intro to Neuroscience', Account__c = accounts[0].Id); 
        insert course; 
        
        Term__c term = UTIL_UnitTestData_TEST.getTerm(accounts[0].Id, 'Fall'); 
        insert term; 

        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id); 
        Course_Offering__c courseOffering2 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id);
        
        Course_Enrollment__c courseConnection1 = UTIL_UnitTestData_TEST.getCourseConnection(contacts[0].Id, courseOffering1.Id); 
        Course_Enrollment__c courseConnection2 = UTIL_UnitTestData_TEST.getCourseConnection(contacts[1].Id, courseOffering2.Id);
        courseConnection1.Program_Enrollment__c = programEnrollments[0].Id; 
        courseConnection2.Program_Enrollment__c = programEnrollments[1].Id; 
        insert courseConnection1;
        insert courseConnection2; 
        
        List<Program_Enrollment__c> returnProgramEnrollments = [SELECT Id,
                                                                (SELECT Id FROM Program_Enrollment__c.Course_Enrollments__r LIMIT 1)
                                                                FROM Program_Enrollment__c
                                                                WHERE Id IN :programEnrollments]; 
        
        PREN_CannotDelete_TDTM myClass = new PREN_CannotDelete_TDTM(); 
        for (Program_Enrollment__c programEnroll: returnProgramEnrollments) {
            System.assertEquals(True, myClass.hasChildRecords(programEnroll)); 
        }
    }
    
    /*********************************************************************************************************
    * @description Tests the hasChildRecords method that the Program Enrollment record has no child records. 
    */
    @isTest
    public static void testProgramEnrollmentHasNoChildRecords(){
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = PREN_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Program_Enrollment_Deletion__c = True));
        
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, PREN_CannotDelete_TEST.academicAccRecTypeId); 
        insert accounts; 
        
        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts; 
        
        List<Program_Enrollment__c> programEnrollments = UTIL_UnitTestData_TEST.getMultipleTestProgramEnrollments(2, accounts[0].Id); 
        programEnrollments[0].Contact__c = contacts[0].Id; 
        programEnrollments[1].Contact__c = contacts[1].Id; 
        insert programEnrollments; 

        List<Program_Enrollment__c> returnProgramEnrollments = [SELECT Id,
                                                                (SELECT Id FROM Program_Enrollment__c.Course_Enrollments__r LIMIT 1)
                                                                FROM Program_Enrollment__c
                                                                WHERE Id IN :programEnrollments]; 
        
        PREN_CannotDelete_TDTM myClass = new PREN_CannotDelete_TDTM(); 
        for (Program_Enrollment__c programEnroll: returnProgramEnrollments) {
            System.assertEquals(False, myClass.hasChildRecords(programEnroll)); 
        }
    }
}