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
    
    /*********************************************************************************************************
    * @description Verifies that an Affiliation is automatically created when a Course Offering with a value
    * in the Faculty field is created.
    */
    @isTest
    public static void createAfflFromCourseOffering() {
    	//Create faculty member
    	Contact faculty = new Contact(FirstName = 'Test', LastName = 'Testerson');
    	insert faculty;
    	
    	//Create university
    	Account university = new Account(Name = 'Advanced University');
    	insert university;
    	
    	//Create department
    	Account dpt = new Account(Name = 'Biology Department', Parent = university);
    	insert dpt;
    	
    	//Create Course
    	Course__c course = new Course__c(Course_ID__c = 'Biology 101', Account__c = dpt.Id, Credit_Hours__c = 40, 
    	Description__c = 'Intro to Biology');
    	insert course;
    	
    	//Create Term
    	Term__c term = new Term__c(Account__c = university.Id, Start_Date__c = System.today() + 5, End_Date__c = System.today() + 90);
    	insert term;
    	
    	//Create Course Offering with Faculty member
    	Course_Offering__c offering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', Course__c = course.ID, Department__c = dpt.Id, 
    	Faculty__c = faculty.Id, Term__c = term.Id, Capacity__c = 200);
    	Test.startTest();
    	insert offering;
    	Test.stopTest();
    	
    	//An Affiliation should have been automatically created fron the faculty member
    	List<Affiliation__c> affls = [select Contact__c, Account__c, Role__c, StartDate__c, EndDate__c from Affiliation__c 
    	where Contact__r.Id = :faculty.Id and Role__c = 'Faculty'];
    	System.assertEquals(1, affls.size());
    	System.assertEquals('Faculty', affls[0].Role__c);
    	System.assertEquals(term.Start_Date__c, affls[0].StartDate__c);
    	System.assertEquals(term.End_Date__c, affls[0].EndDate__c);
    }
}