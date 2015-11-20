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
* @group Term
* @description Tests for TERM_CourseOff_TDTM. 
*/

@isTest
public with sharing class TERM_CourseOff_TEST {

    @isTest
    public static void datesAddedToTerm() {
        //create university
        Account university = new Account(Name = 'Advanced University');
        insert university;
        
        //create department
        Account dpt = new Account(Name = 'Biology Department', Parent = university);
        insert dpt;
        
        //create Course
        Course__c course = new Course__c(Course_ID__c = 'Biology 101', Account__c = dpt.Id, Credit_Hours__c = 40, 
        Description__c = 'Intro to Biology');
        insert course;
        
        //create term without start and end dates
        Term__c term1 = new Term__c(Account__c = university.Id);
        
        //create another term, just to create some children course offering and check they were not modified
        Term__c term2 = new Term__c(Account__c = university.Id);
        
        insert new Term__c[] {term1, term2};
        
        //create child course offering without start or end date
        Course_Offering__c off1 = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', 
        Course__c = course.ID, Term__c = term1.Id, Capacity__c = 200);
        
        //create child course offering with start date
        Course_Offering__c off2 = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 17', 
        Course__c = course.ID, Term__c = term1.Id, Capacity__c = 200, Start_Date__c = system.today().addMonths(6));
        
        //create child course offering with end date
        Course_Offering__c off3 = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 18', 
        Course__c = course.ID, Term__c = term1.Id, Capacity__c = 200, End_Date__c = system.today().addMonths(6));
        
        //create child course offering with start and end dates
        Course_Offering__c off4 = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 19', 
        Course__c = course.ID, Term__c = term1.Id, Capacity__c = 200, Start_Date__c = system.today().addMonths(6),
        End_Date__c = system.today().addMonths(6));
        
        //child course offering from term2, that should not be automatically modified
        Course_Offering__c off5 = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 20', 
        Course__c = course.ID, Term__c = term2.Id, Capacity__c = 200);
        
        Course_Offering__c[] coffs = new Course_Offering__c[]{off1, off2, off3, off4, off5};
        insert coffs;
        
        //add start and end dates to term
        term1.Start_Date__c = system.today();
        term1.End_Date__c = system.today().addMonths(4);
        Test.startTest();
        update term1;
        Test.stopTest();
        
        coffs = [select Start_Date__c, End_Date__c from Course_Offering__c 
        where ID IN :coffs order by Section_ID__c];
        
        //course offering start and end date should have been copied from parent term 
        System.assertEquals(term1.Start_Date__c, coffs[0].Start_Date__c);
        System.assertEquals(term1.End_Date__c, coffs[0].End_Date__c);
        
        //only end date should have been copied from parent term
        System.assertEquals(system.today().addMonths(6), coffs[1].Start_Date__c);
        System.assertEquals(term1.End_Date__c, coffs[1].End_Date__c);
        
        //only start date should have been copied from parent term
        System.assertEquals(term1.Start_Date__c, coffs[2].Start_Date__c);
        System.assertEquals(system.today().addMonths(6), coffs[2].End_Date__c);
        
        //neither start of end dates should have been copied from parent term
        System.assertNotEquals(term1.Start_Date__c, coffs[3].Start_Date__c);
        System.assertNotEquals(term1.End_Date__c, coffs[3].End_Date__c);
        
        //neither start of end dates should have been copied from parent term
        System.assertEquals(null, coffs[4].Start_Date__c);
        System.assertEquals(null, coffs[4].End_Date__c);
    }
}