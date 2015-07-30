/*
    Copyright (c) 2015, Salesforce.com Foundation
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Salesforce.com Foundation nor the names of
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
* @author Salesforce.com Foundation
* @date 2015
* @group Course Offering
* @description Tests specific to Course Offering. 
*/
@isTest
public with sharing class COFF_Affiliation_TEST {

	/*********************************************************************************************************
    * @description if you only want to run one test in this class, fill in its name here.
    * if you want to run all tests, then use '*'
    */
    private static string strTestOnly = '*';
    
    private static Account university;
    private static Account dpt;
    private static Course__c course;
    private static Term__c term;
    private static Contact faculty;
    
    private static void setup() {
    	//Create university
    	university = new Account(Name = 'Advanced University');
    	insert university;
    	
    	//Create department
    	dpt = new Account(Name = 'Biology Department', Parent = university);
    	insert dpt;
    	
    	//Create Course
    	course = new Course__c(Course_ID__c = 'Biology 101', Account__c = dpt.Id, Credit_Hours__c = 40, 
    	Description__c = 'Intro to Biology');
    	insert course;
    	
    	//Create Term
    	term = new Term__c(Account__c = university.Id, Start_Date__c = System.today() + 5, End_Date__c = System.today() + 90);
    	insert term;
    	
    	//Create faculty member
    	faculty = new Contact(FirstName = 'Test', LastName = 'Testerson');
    	insert faculty;
    }
    
    /*********************************************************************************************************
    * @description Verifies that an Affiliation to the Department is automatically created when a Course Offering 
    * with a value in the Faculty field is created and that Contact did not already have an Affiliation to that
    * Department.
    */
    @isTest
    public static void newCourseOffering() {
    	if (strTestOnly != '*' && strTestOnly != 'newCourseOffering') return;
    	setup();

    	//Create Course Offering with Faculty member
    	Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID, 
    	Department__c = dpt.Id, Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
    	Test.startTest();
    	insert offering;
    	Test.stopTest();
    	
    	//Since no previous Affl to the Dpt existed, an Affl should have been automatically created for the faculty member
    	List<Affiliation__c> affls = [select Contact__c, Account__c, Role__c, StartDate__c, EndDate__c from Affiliation__c 
    	where Contact__r.Id = :faculty.Id and Role__c = 'Faculty'];
    	System.assertEquals(1, affls.size());
    	System.assertEquals('Faculty', affls[0].Role__c);
    	System.assertEquals(term.Start_Date__c, affls[0].StartDate__c);
    	System.assertEquals(term.End_Date__c, affls[0].EndDate__c);
    	
    	//A Course Enrollment should have been automatically created
        List<Course_Enrollment__c> enrolls = [select Contact__c, Course_Offering__c, Affiliation__c from Course_Enrollment__c 
        where Contact__r.Id = :faculty.Id];
        System.assertEquals(1, enrolls.size());
        //The Course Enrollment should have been linked to the Affiliation that was automatically created
        System.assertEquals(affls[0].ID, enrolls[0].Affiliation__c);
    	
    	//If a new Course Offering is created under the same Department and is taught by the same Faculty member, no additional
    	//Affiliation should be created.
    	Course_Offering__c offering2 = new Course_Offering__c(Section_ID__c = 'BIO-101 Summer 16', Course__c = course.ID, 
    	Department__c = dpt.Id, Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
    	insert offering2;
    	affls = [select Contact__c, Account__c, Role__c, StartDate__c, EndDate__c from Affiliation__c 
    	where Contact__r.Id = :faculty.Id and Role__c = 'Faculty'];
    	System.assertEquals(1, affls.size());
    }
    
    @isTest
    public static void addFacultyToOfferingNoPrevAffl() {
    	if (strTestOnly != '*' && strTestOnly != 'addFacultyToOfferingNoPrevAffl') return;
    	setup();
    	List<Affiliation__c> affls = [select ID from Affiliation__c];
    	Integer afflsSize1 = affls.size();
    	
    	//Create Course Offering without Faculty member
    	Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID, 
    	Department__c = dpt.Id, Term__c = term.Id, Capacity__c = 200);
    	insert offering;
    	
    	//No affiliation should have been created
    	affls = [select ID from Affiliation__c];
    	System.assertEquals(afflsSize1, affls.size());
    	
    	//Add faculty to offering
    	offering.Faculty__c = faculty.Id;
    	Test.startTest();
    	update offering;
    	Test.stopTest();
    	
    	//An Affiliation should have been automatically created for the faculty member, if no Affiliation to that Deparment 
    	//alreadt existed.
    	affls = [select Contact__c, Account__c, Role__c, StartDate__c, EndDate__c from Affiliation__c 
    	where Contact__r.Id = :faculty.Id and Role__c = 'Faculty'];
    	System.assertEquals(1, affls.size());
    	System.assertEquals('Faculty', affls[0].Role__c);
    	System.assertEquals(term.Start_Date__c, affls[0].StartDate__c);
    	System.assertEquals(term.End_Date__c, affls[0].EndDate__c);
    	
    	//A Course Enrollment should have been automatically created
        List<Course_Enrollment__c> enrolls = [select Contact__c, Course_Offering__c, Affiliation__c from Course_Enrollment__c 
        where Contact__r.Id = :faculty.Id];
        System.assertEquals(1, enrolls.size());
        //The Course Enrollment should have been linked to the Affiliation that was automatically created
        System.assertEquals(affls[0].ID, enrolls[0].Affiliation__c);
    }
    
    @isTest
    public static void addFacultyToOfferingPrevAffl() {
    	if (strTestOnly != '*' && strTestOnly != 'addFacultyToOfferingPrevAffl') return;
    	setup();
    	
    	//Create affiliation from faculty member to dpt
    	Affiliation__c affl = new Affiliation__c(Account__c = dpt.ID, Contact__c = faculty.ID);
    	insert affl;
    	
    	List<Affiliation__c> affls = [select ID from Affiliation__c];
    	Integer afflsSize1 = affls.size();
    	
    	//Create Course Offering without Faculty member
    	Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID, 
    	Department__c = dpt.Id, Term__c = term.Id, Capacity__c = 200);
    	insert offering;
    	
    	//No affiliation should have been created
    	affls = [select ID from Affiliation__c];
    	System.assertEquals(afflsSize1, affls.size());
    	
    	//Add faculty to offering
    	offering.Faculty__c = faculty.Id;
    	Test.startTest();
    	update offering;
    	Test.stopTest();
    	
    	//Still no Affl should have been created
    	affls = [select ID from Affiliation__c];
    	System.assertEquals(afflsSize1, affls.size());
    	
    	//A Course Enrollment should have been automatically created
        List<Course_Enrollment__c> enrolls = [select Contact__c, Course_Offering__c, Affiliation__c from Course_Enrollment__c 
        where Contact__r.Id = :faculty.Id];
        System.assertEquals(1, enrolls.size());
        //The Course Enrollment should not be linked to the Affiliation that already existed (and wasn't automatically created)
        System.assertEquals(null, enrolls[0].Affiliation__c);
    }
    
    @isTest
    public static void changeFaculty() {
    	if (strTestOnly != '*' && strTestOnly != 'changeFaculty') return;
    	setup();
    	
    	//Create Course Offering with Faculty member
    	Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID, 
    	Department__c = dpt.Id, Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
    	insert offering;
    	
    	//Since no previous Affl to the Dpt existed, an Affl should have been automatically created for the faculty member
        List<Affiliation__c> affls = [select Contact__c, Account__c, Role__c, StartDate__c, EndDate__c from Affiliation__c 
        where Contact__r.Id = :faculty.Id and Role__c = 'Faculty'];
        System.assertEquals(1, affls.size());
        
        //A Course Enrollment should have been automatically created
        List<Course_Enrollment__c> enrolls = [select Contact__c, Course_Offering__c, Affiliation__c from Course_Enrollment__c 
        where Contact__r.Id = :faculty.Id];
        System.assertEquals(1, enrolls.size());
    	
    	//Create second faculty member
    	Contact faculty2 = new Contact(FirstName = 'Test', LastName = 'Testerson');
    	insert faculty2;
    	
    	//Update Offering
    	offering.Faculty__c = faculty2.Id;
    	Test.startTest();
    	update offering;
    	Test.stopTest();
    	
    	//The affiliation should have been updated to point to the second faculty member
    	affls = [select Contact__c, Account__c, Role__c, StartDate__c, EndDate__c from Affiliation__c 
    	where Contact__r.Id = :faculty2.Id and Role__c = 'Faculty' and ID = :affls[0].ID];
    	System.assertEquals(1, affls.size());
    	System.assertEquals('Faculty', affls[0].Role__c);
    	System.assertEquals(term.Start_Date__c, affls[0].StartDate__c);
    	System.assertEquals(term.End_Date__c, affls[0].EndDate__c);
    	
    	//The Course Enrollment of the old Faculty member should have been deleted
    	enrolls = [select ID from Course_Enrollment__c where Contact__r.Id = :faculty.Id];
    	System.assertEquals(0, enrolls.size());
    	
    	//A Course Enrollment should have been automatically created for the new Faculty
        List<Course_Enrollment__c> newEnrolls = [select Contact__c, Course_Offering__c, Affiliation__c from Course_Enrollment__c 
        where Contact__r.Id = :faculty2.Id];
        System.assertEquals(1, newEnrolls.size());
        //The Course Enrollment should have been linked to the Affiliation that was automatically created
        System.assertEquals(affls[0].ID, newEnrolls[0].Affiliation__c);
        
        
    }
    
    @isTest
    public static void facultyMadeNull() {
    	if (strTestOnly != '*' && strTestOnly != 'facultyMadeNull') return;
    	setup();
    	
    	//Create Course Offering with Faculty member
    	Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID, 
    	Department__c = dpt.Id, Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
    	insert offering;
    	
    	//An Affiliation should have been automatically created for the faculty member
    	List<Affiliation__c> affls = [select Contact__c, Account__c, Role__c, StartDate__c, EndDate__c from Affiliation__c 
    	where Contact__r.Id = :faculty.Id and Role__c = 'Faculty'];
    	System.assertEquals(1, affls.size());
    	
    	//A Course Enrollment should have been automatically created
        List<Course_Enrollment__c> enrolls = [select Contact__c, Course_Offering__c, Affiliation__c from Course_Enrollment__c 
        where Contact__r.Id = :faculty.Id];
        System.assertEquals(1, enrolls.size());
        //The Course Enrollment should have been linked to the Affiliation that was automatically created
        System.assertEquals(affls[0].ID, enrolls[0].Affiliation__c);
        
    	//Update Offering
    	offering.Faculty__c = null;
    	Test.startTest();
    	update offering;
    	Test.stopTest();
    	
    	//The affiliation should have been deleted
    	affls = [select Contact__c, Account__c, Role__c, StartDate__c, EndDate__c from Affiliation__c where ID = :affls[0].ID];
    	System.assertEquals(0, affls.size());
    	
    	//The Course Enrollment should have been deleted
        enrolls = [select ID from Course_Enrollment__c where Contact__r.Id = :faculty.Id];
        System.assertEquals(0, enrolls.size());
    }
    
    @isTest
    public static void deleteCourseOffering() {
        if (strTestOnly != '*' && strTestOnly != 'deleteCourseOffering') return;
        setup();
        
        //Create Course Offering with Faculty member
        Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID, 
        Department__c = dpt.Id, Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
        insert offering;
        
        //An Affiliation should have been automatically created for the faculty member
        List<Affiliation__c> affls = [select Contact__c, Account__c, Role__c, StartDate__c, EndDate__c from Affiliation__c 
        where Contact__r.Id = :faculty.Id and Role__c = 'Faculty'];
        System.assertEquals(1, affls.size());
        
        //A Course Enrollment should have been automatically created
        List<Course_Enrollment__c> enrolls = [select Contact__c, Course_Offering__c, Affiliation__c from Course_Enrollment__c 
        where Contact__r.Id = :faculty.Id];
        System.assertEquals(1, enrolls.size());
        //The Course Enrollment should have been linked to the Affiliation that was automatically created
        System.assertEquals(affls[0].ID, enrolls[0].Affiliation__c);
        
        Test.startTest();
        delete offering;
        Test.stopTest();
        
        //The affiliation should have been deleted
        affls = [select Contact__c, Account__c, Role__c, StartDate__c, EndDate__c from Affiliation__c where ID = :affls[0].ID];
        System.assertEquals(0, affls.size());
        
        //The Course Enrollment should have been deleted
        enrolls = [select ID from Course_Enrollment__c where Contact__r.Id = :faculty.Id];
        System.assertEquals(0, enrolls.size());
    }
    
    @isTest
    public static void getAfflsForContact() {
    	if (strTestOnly != '*' && strTestOnly != 'getAfflsForContact') return;
    	setup();
    	
    	Contact faculty1 = new Contact(FirstName = 'Test', LastName = 'Testerson1');
    	Contact faculty2 = new Contact(FirstName = 'Test', LastName = 'Testerson2');
    	Contact faculty3 = new Contact(FirstName = 'Test', LastName = 'Testerson3');
    	Contact faculty4 = new Contact(FirstName = 'Test', LastName = 'Testerson4');
    	insert new Contact[]{faculty1, faculty2, faculty3, faculty4};
    	
    	Account dpt1 = new Account(Name = 'English Department', Parent = university);
    	Account dpt2 = new Account(Name = 'CS Department', Parent = university);
    	Account dpt3 = new Account(Name = 'Math Department', Parent = university);
    	Account dpt4 = new Account(Name = 'Law Department', Parent = university);
    	insert new Account[]{dpt1, dpt2, dpt3, dpt4};
    	
    	Affiliation__c aff1 = new Affiliation__c(Contact__c = faculty1.ID, Account__c = dpt1.ID);
    	Affiliation__c aff2 = new Affiliation__c(Contact__c = faculty4.ID, Account__c = dpt1.ID);
    	Affiliation__c aff3 = new Affiliation__c(Contact__c = faculty2.ID, Account__c = dpt2.ID);
    	Affiliation__c aff4 = new Affiliation__c(Contact__c = faculty4.ID, Account__c = dpt3.ID);
    	Affiliation__c aff5 = new Affiliation__c(Contact__c = faculty1.ID, Account__c = dpt2.ID);
    	Affiliation__c aff6 = new Affiliation__c(Contact__c = faculty3.ID, Account__c = dpt1.ID);
    	Affiliation__c aff7 = new Affiliation__c(Contact__c = faculty1.ID, Account__c = dpt4.ID);
    	Affiliation__c aff8 = new Affiliation__c(Contact__c = faculty2.ID, Account__c = dpt3.ID);
    	insert new Affiliation__c[]{aff1, aff2, aff3, aff4, aff5, aff6, aff7, aff8};
    	
    	COFF_Affiliation_TDTM tdtm = new COFF_Affiliation_TDTM();
    	Map<ID, List<Affiliation__c>> facultyIDtoAffls = tdtm.getAfflsForContact(new ID[]{faculty1.ID, faculty2.ID, faculty3.ID, faculty4.ID});
    	
    	Set<Affiliation__c> faculty1Affls = new Set<Affiliation__c>(facultyIDtoAffls.get(faculty1.ID));
    	Set<Affiliation__c> faculty2Affls = new Set<Affiliation__c>(facultyIDtoAffls.get(faculty2.ID));
    	Set<Affiliation__c> faculty3Affls = new Set<Affiliation__c>(facultyIDtoAffls.get(faculty3.ID));
    	Set<Affiliation__c> faculty4Affls = new Set<Affiliation__c>(facultyIDtoAffls.get(faculty4.ID));
    	System.assertEquals(true, faculty1Affls.contains(aff1));
    	System.assertEquals(true, faculty1Affls.contains(aff5));
    	System.assertEquals(true, faculty1Affls.contains(aff7));
    	System.assertEquals(true, faculty2Affls.contains(aff3));
    	System.assertEquals(true, faculty2Affls.contains(aff8));
    	System.assertEquals(true, faculty3Affls.contains(aff6));
    	System.assertEquals(true, faculty4Affls.contains(aff2));
    	System.assertEquals(true, faculty4Affls.contains(aff4));
    	
    	//Create Course Offering with Faculty member
        Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID, 
        Department__c = dpt3.Id, Faculty__c = faculty2.Id, Term__c = term.Id, Capacity__c = 200);
        insert offering;
        
    	Boolean afflToDptExists = tdtm.afflToDptExists(offering, facultyIDtoAffls);
    	System.assertEquals(true, afflToDptExists);
    }
}