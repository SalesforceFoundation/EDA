/*
    Copyright (c) 2019, Salesforce.org
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
* @date 2019
* @group Course Enrollments
* @group-content ../../ApexDocContent/CourseEnrollments.htm
* @description Tests class for backfilling Affiliation on Student Course Connection.
*/
@isTest
public class CCON_AffiliationBackfill_TEST {

    private static Account university;
    private static Account biologyDept;
    private static Course__c biologyCourse;
    private static Term__c term;
    private static List<Course_Offering__c> offeringsList;
    private static List<Contact> studentContacts;
    private static List<Program_Enrollment__c> programEnrollments;
    private static List<Course_Enrollment__c> studentConnections;

    /*********************************************************************************************************
    * @description Test setup.
    */
    @testSetup
    public static void setup() {
        // Enable Course Connections
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Enable_Course_Connections__c = true,
                Populate_Affil_on_Student_Couse_Cxn__c = false,
                Student_RecType__c = UTIL_Describe_API.getStudentConnectionRecType()
            )
        );

        // Create university
        university = new Account(Name = 'Advanced University');
        insert university;

        // Create Biology department
        biologyDept = new Account(Name = 'Biology Department', Parent = university);
		insert biologyDept;

        // Create Term
        term = new Term__c(Account__c = university.Id, Start_Date__c = System.today() + 5, End_Date__c = System.today() + 90);

        // Create Biology Course
        biologyCourse = new Course__c(Course_ID__c = 'Biology 101', Account__c = biologyDept.Id, Credit_Hours__c = 40,
           Description__c = 'Biology 101');

        insert new List<SObject>{
            term,
            biologyCourse
        };

        studentContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(20);
        for (Integer i=0; i<studentContacts.size(); i++) {
            for (Contact c : studentContacts) {
                c.LastName = 'Backfill' + i;
            }
        }
        insert studentContacts;

        offeringsList = new List<Course_Offering__c>();
		createCourseOffering(biologyCourse, term);
        insert offeringsList;

        programEnrollments = new List<Program_Enrollment__c>();
        createProgramEnrollment(biologyDept);
        insert programEnrollments;

        studentConnections = new List<Course_Enrollment__c>();
        createCourseConnections(studentContacts);
        insert studentConnections;
    }

    /*********************************************************************************************************
    * @description method responsible for creating Course Offerings.
    * @param biologyCourse is a Course record.
    * @param term is a Term record.
    */
    private static void createCourseOffering(Course__c biologyCourse, Term__c term) {
        for (Integer i=0; i<studentContacts.size(); i++) {
            Course_Offering__c coff = new Course_Offering__c(
                Name = 'IntroBio' + i,
                Course__c = biologyCourse.Id,
                Term__c = term.Id
            );
            offeringsList.add(coff);
        }
    }

    /*********************************************************************************************************
    * @description method responsible for creating Program Enrollments.
    * @param biologyDept is an Account record.
    */
    private static void createProgramEnrollment(Account biologyDept) {
        for (Integer i=0; i<studentContacts.size(); i++) {
            Program_Enrollment__c pe = new Program_Enrollment__c(
                Contact__c = studentContacts[i].Id,
                Account__c = biologyDept.Id
            );
            programEnrollments.add(pe);
        }
    }

    /*********************************************************************************************************
    * @description method responsible for creating Course Connections.
    * @param students is a list of Contacts.
    */
    private static void createCourseConnections(List<Contact> students) {
        for (Integer i=0; i<students.size(); i++) {
            Course_Enrollment__c conn = new Course_Enrollment__c(
                Contact__c = students[i].Id,
                Program_Enrollment__c = programEnrollments[i].Id,
                Course_Offering__c = offeringsList[i].Id
            );
            conn.put('RecordTypeId', UTIL_CustomSettingsFacade.getSettings().Student_RecType__c);
            studentConnections.add(conn);
        }
    }

    /*********************************************************************************************************
    * @description testing the backfill functionality if Affiliation and Account lookup fields on existing
    * Student Course Connection are populated if Affiliation lookup field is blank.
    */
    @isTest
    public static void checkBackfillSuccess()  {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Enable_Course_Connections__c = true,
                Populate_Affil_on_Student_Couse_Cxn__c  = true,
                Faculty_RecType__c = UTIL_Describe_API.getFacultyConnectionRecType(),
                Student_RecType__c = UTIL_Describe_API.getStudentConnectionRecType()
            )
        );

        List<Contact> studentContacts = [SELECT Id, LastName
                                         FROM Contact
                                         WHERE LastName LIKE 'Backfill%' LIMIT 20];
        List<Course_Enrollment__c> studentConnections = [SELECT Id, Program_Enrollment__c, Affiliation__c, Contact__c
                                                         FROM Course_Enrollment__c
                                                         WHERE Affiliation__c = NULL AND Program_Enrollment__c != NULL
														 AND Contact__c = :studentContacts];

        for (Course_Enrollment__c studentCE : studentConnections) {
            System.assertEquals(NULL, studentCE.Affiliation__c);
        }

        Test.StartTest();
        CCON_AffiliationBackfill_BATCH batch = new CCON_AffiliationBackfill_BATCH();
        ID ApexJobId = Database.executeBatch(batch, 200);
        Test.stopTest();

        List<Course_Enrollment__c> studentConns = [SELECT Id, Affiliation__c, Account__c
                                                   FROM Course_Enrollment__c WHERE Id = :studentConnections];

        for (Course_Enrollment__c ce : studentConns) {
            System.assertNotEquals(NULL, ce.Affiliation__c);
            System.assertNotEquals(NULL, ce.Account__c);
        }
	}
}