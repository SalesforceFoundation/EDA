/*
    Copyright (c) 2016, Salesforce.org
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
* @date 2016
* @group Course Enrollments
* @group-content ../../ApexDocContent/CourseEnrollments.htm
* @description Tests for CENR_AcademicProgram_TDTM.
*/
@isTest
public with sharing class CENR_AcademicProgram_TEST {
   	/*******************************************************************************************************
  	* @description This tests when multiple Student Course Connection records are inserted and
	* Populate_Affil_on_Student_Couse_Cxn__c is enabled, Affiliation lookup field on Student Course Connection
	* should be populated if the Student Course Connection record has a Program Enrollment with an Affiliation
	* record associated to the Program Enrollment.
  	********************************************************************************************************/
  	@isTest
  	public static void testBulkInserts() {
    	STG_InstallScript.insertMappings();
      	UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
          												Populate_Affil_on_Student_Couse_Cxn__c = true));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Account academicProgram = new Account(Name = 'BS in Biology', RecordTypeId = UTIL_Describe.getAcademicAccRecTypeID());
        Account department = new Account(Name = 'Biology Department', RecordTypeId = UTIL_Describe.getDepAccRecTypeID());
        insert new Account[]{academicProgram, department};

        Course__c course = new Course__c(Account__c = department.Id);
        insert course;

        Term__c term = new Term__c(Account__c = department.Id);
        insert term;

        Course_Offering__c cOffering = new Course_Offering__c(Course__c = course.Id, Term__c = term.Id);
        insert cOffering;

        List<Program_Enrollment__c> pEnrolls = new List<Program_Enrollment__c>{
        	new Program_Enrollment__c(Contact__c = contacts[0].Id, Account__c = academicProgram.Id),
            new Program_Enrollment__c(Contact__c = contacts[1].Id, Account__c = academicProgram.Id)
        };
        insert pEnrolls;

        Id studentCourseCxnRecTypeId = Schema.SObjectType.Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        List<Course_Enrollment__c> cEnrolls = new List<Course_Enrollment__c>{
            new Course_Enrollment__c(Contact__c = contacts[0].Id, Program_Enrollment__c = pEnrolls[0].Id, Course_Offering__c = cOffering.Id, RecordTypeId = studentCourseCxnRecTypeId),
            new Course_Enrollment__c(Contact__c = contacts[1].Id, Program_Enrollment__c = pEnrolls[1].Id, Course_Offering__c = cOffering.Id, RecordTypeId = studentCourseCxnRecTypeId)
        };

        Test.startTest();
        insert cEnrolls;
        Test.stopTest();

        List<Course_Enrollment__c> returnCourseEnrollments = [SELECT Account__c, Affiliation__c
                                                              FROM Course_Enrollment__c
                                                              WHERE ID IN :cEnrolls];
        System.assertEquals(academicProgram.Id, returnCourseEnrollments[0].Account__c);
        System.assertNotEquals(NULL, returnCourseEnrollments[0].Affiliation__c);
    }

    /*******************************************************************************************************
  	* @description This tests when mutilple Student Course Connection are inserted and
	* Populate_Affil_on_Student_Couse_Cxn__c is disabled, Affiliation lookup field on Student Course Connection
	* should not be populated even if the Student Course Connection has a Program Enrollment with Affiliation.
  	********************************************************************************************************/
  	@isTest
  	public static void testBulkInsertWithAffiliationLookupDisabled() {
    	STG_InstallScript.insertMappings();
		UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
      													Populate_Affil_on_Student_Couse_Cxn__c = false));

      	List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Account academicProgram = new Account(Name = 'BS in Biology', RecordTypeId = UTIL_Describe.getAcademicAccRecTypeID());
        Account department = new Account(Name = 'Biology Department', RecordTypeId = UTIL_Describe.getDepAccRecTypeID());
        insert new Account[]{academicProgram, department};

        Course__c course = new Course__c(Account__c = department.Id);
        insert course;

        Term__c term = new Term__c(Account__c = department.Id);
        insert term;

        Course_Offering__c cOffering = new Course_Offering__c(Course__c = course.Id, Term__c = term.Id);
        insert cOffering;

        List<Program_Enrollment__c> pEnrolls = new List<Program_Enrollment__c>{
        	new Program_Enrollment__c(Contact__c = contacts[0].Id, Account__c = academicProgram.Id),
            new Program_Enrollment__c(Contact__c = contacts[1].Id, Account__c = academicProgram.Id)
        };
        insert pEnrolls;

        Id studentCourseCxnRecTypeId = Schema.SObjectType.Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        List<Course_Enrollment__c> cEnrolls = new List<Course_Enrollment__c>{
            new Course_Enrollment__c(Contact__c = contacts[0].Id, Program_Enrollment__c = pEnrolls[0].Id, Course_Offering__c = cOffering.Id, RecordTypeId = studentCourseCxnRecTypeId),
            new Course_Enrollment__c(Contact__c = contacts[1].Id, Program_Enrollment__c = pEnrolls[1].Id, Course_Offering__c = cOffering.Id, RecordTypeId = studentCourseCxnRecTypeId)
        };

      	Test.startTest();
      	insert cEnrolls;
      	Test.stopTest();

      	List<Course_Enrollment__c> returnCourseEnrollments = [SELECT Account__c, Affiliation__c
                                                              FROM Course_Enrollment__c
                                                              WHERE ID IN :cEnrolls];
      	System.assertEquals(academicProgram.Id, returnCourseEnrollments[1].Account__c);
      	System.assertEquals(NULL, returnCourseEnrollments[0].Affiliation__c);
  	}

    /*******************************************************************************************************
  	* @description This tests when Populate_Affil_on_Student_Couse_Cxn__c is enabled, and  multiple existing
	* Student Course Connection records are updated with Program Enrollment records and these
	* Program Enrollment records have Affiliation records, the existing Student Course Connection's
	* Affiliation and Account lookup fields should be updated.
  	********************************************************************************************************/
  	@isTest
  	public static void testBulkUpdates() {
    	STG_InstallScript.insertMappings();
      	UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
          												Populate_Affil_on_Student_Couse_Cxn__c = true));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Account academicProgram = new Account(Name = 'BS in Biology', RecordTypeId = UTIL_Describe.getAcademicAccRecTypeID());
        Account department = new Account(Name = 'Biology Department', RecordTypeId = UTIL_Describe.getDepAccRecTypeID());
        insert new Account[]{academicProgram, department};

        Course__c course = new Course__c(Account__c = department.Id);
        insert course;

        Term__c term = new Term__c(Account__c = department.Id);
        insert term;

        Course_Offering__c cOffering = new Course_Offering__c(Course__c = course.Id, Term__c = term.Id);
        insert cOffering;

        List<Program_Enrollment__c> pEnrolls = new List<Program_Enrollment__c>{
        	new Program_Enrollment__c(Contact__c = contacts[0].Id, Account__c = academicProgram.Id),
            new Program_Enrollment__c(Contact__c = contacts[1].Id, Account__c = academicProgram.Id)
        };
        insert pEnrolls;

        Id studentCourseCxnRecTypeId = Schema.SObjectType.Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        List<Course_Enrollment__c> cEnrolls = new List<Course_Enrollment__c>{
            new Course_Enrollment__c(Contact__c = contacts[0].Id, Course_Offering__c = cOffering.Id, RecordTypeId = studentCourseCxnRecTypeId),
            new Course_Enrollment__c(Contact__c = contacts[1].Id, Course_Offering__c = cOffering.Id, RecordTypeId = studentCourseCxnRecTypeId)
        };
        insert cEnrolls;

        List<Course_Enrollment__c> returnCourseEnrollments = [SELECT Account__c, Affiliation__c
                                                              FROM Course_Enrollment__c
                                                              WHERE ID IN :cEnrolls];
        System.assertEquals(NULL, returnCourseEnrollments[0].Account__c);
        System.assertEquals(NULL, returnCourseEnrollments[0].Affiliation__c);

        cEnrolls[0].Program_Enrollment__c = pEnrolls[0].Id;
        cEnrolls[1].Program_Enrollment__c = pEnrolls[1].Id;

        Test.startTest();
        update cEnrolls;
        Test.stopTest();

        List<Course_Enrollment__c> returnCEnrollments = [SELECT Account__c, Affiliation__c
                                                              FROM Course_Enrollment__c
                                                              WHERE ID IN :cEnrolls];
        System.assertEquals(academicProgram.Id, returnCEnrollments[0].Account__c);
        System.assertNotEquals(NULL, returnCEnrollments[0].Affiliation__c);
    }

    /*******************************************************************************************************
  	* @description This tests when Populate_Affil_on_Student_Couse_Cxn__c is disabled, and  multiple existing
	* Student Course Connection records are updated with Program Enrollment records and these
	* Program Enrollment records have Affiliation records, the existing Student Course Connection's
	* Affiliation lookup fields should not be updated.
  	********************************************************************************************************/
  	@isTest
  	public static void testBulkUpdatesWithAffiliationLookupDisabled() {
    	STG_InstallScript.insertMappings();
      	UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
          												Populate_Affil_on_Student_Couse_Cxn__c = false));

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        insert contacts;

        Account academicProgram = new Account(Name = 'BS in Biology', RecordTypeId = UTIL_Describe.getAcademicAccRecTypeID());
        Account department = new Account(Name = 'Biology Department', RecordTypeId = UTIL_Describe.getDepAccRecTypeID());
        insert new Account[]{academicProgram, department};

        Course__c course = new Course__c(Account__c = department.Id);
        insert course;

        Term__c term = new Term__c(Account__c = department.Id);
        insert term;

        Course_Offering__c cOffering = new Course_Offering__c(Course__c = course.Id, Term__c = term.Id);
        insert cOffering;

        List<Program_Enrollment__c> pEnrolls = new List<Program_Enrollment__c>{
        	new Program_Enrollment__c(Contact__c = contacts[0].Id, Account__c = academicProgram.Id),
            new Program_Enrollment__c(Contact__c = contacts[1].Id, Account__c = academicProgram.Id)
        };
        insert pEnrolls;

        Id studentCourseCxnRecTypeId = Schema.SObjectType.Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        List<Course_Enrollment__c> cEnrolls = new List<Course_Enrollment__c>{
            new Course_Enrollment__c(Contact__c = contacts[0].Id, Course_Offering__c = cOffering.Id, RecordTypeId = studentCourseCxnRecTypeId),
            new Course_Enrollment__c(Contact__c = contacts[1].Id, Course_Offering__c = cOffering.Id, RecordTypeId = studentCourseCxnRecTypeId)
        };
        insert cEnrolls;

        List<Course_Enrollment__c> returnCourseEnrollments = [SELECT Account__c, Affiliation__c
                                                              FROM Course_Enrollment__c
                                                              WHERE ID IN :cEnrolls];
        System.assertEquals(NULL, returnCourseEnrollments[0].Account__c);
        System.assertEquals(NULL, returnCourseEnrollments[0].Affiliation__c);

        cEnrolls[0].Program_Enrollment__c = pEnrolls[0].Id;
        cEnrolls[1].Program_Enrollment__c = pEnrolls[1].Id;

        Test.startTest();
        update cEnrolls;
        Test.stopTest();

        List<Course_Enrollment__c> returnCEnrollments = [SELECT Account__c, Affiliation__c
                                                              FROM Course_Enrollment__c
                                                              WHERE ID IN :cEnrolls];
        System.assertEquals(academicProgram.Id, returnCEnrollments[0].Account__c);
        System.assertEquals(NULL, returnCEnrollments[0].Affiliation__c);
    }
}