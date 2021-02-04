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
private class TERM_CourseOff_TEST {

    private static Account university;
    private static Course__c course;

    private static void setup() {
        //create university
        university = new Account(Name = 'Advanced University');
        insert university;
        
        //create department
        Account dpt = new Account(Name = 'Biology Department', Parent = university);
        insert dpt;
        
        //create Course
        course = new Course__c(Course_ID__c = 'Biology 101', Account__c = dpt.Id, Credit_Hours__c = 40, 
            Description__c = 'Intro to Biology');
        insert course;
    }

    /*******************************************************************************************************
    * @description Tests that when a Term Start and End Date is updated, any child Course Offerings are 
    * updated with the new Start and End Dates, but only if the Course Offering fields were previously blank.
    ********************************************************************************************************/
    @isTest
    public static void datesAddedToTerm() {
        setup();
        
        //create term without start and end dates
        Term__c term1 = new Term__c(Account__c = university.Id);
        
        //create another term, just to create some children course offering and check they were not modified
        Term__c term2 = new Term__c(Account__c = university.Id);
        
        insert new List<Term__c>{term1, term2};
        
        //create child course offering without start or end date
        Course_Offering__c off1 = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', 
            Course__c = course.Id, Term__c = term1.Id, Capacity__c = 200);
        
        //create child course offering with start date
        Course_Offering__c off2 = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 17', 
            Course__c = course.Id, Term__c = term1.Id, Capacity__c = 200, Start_Date__c = system.today().addMonths(6));
        
        //create child course offering with end date
        Course_Offering__c off3 = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 18', 
            Course__c = course.Id, Term__c = term1.Id, Capacity__c = 200, End_Date__c = system.today().addMonths(6));
        
        //create child course offering with start and end dates
        Course_Offering__c off4 = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 19', 
            Course__c = course.Id, Term__c = term1.Id, Capacity__c = 200, Start_Date__c = system.today().addMonths(6),
            End_Date__c = system.today().addMonths(6));
        
        //child course offering from term2, that should not be automatically modified
        Course_Offering__c off5 = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 20', 
            Course__c = course.Id, Term__c = term2.Id, Capacity__c = 200);
        
        List<Course_Offering__c> coffs = new List<Course_Offering__c>{off1, off2, off3, off4, off5};
        insert coffs;
        
        //add start and end dates to term
        term1.Start_Date__c = system.today();
        term1.End_Date__c = system.today().addMonths(4);
        Test.startTest();
        update term1;
        Test.stopTest();
        
        //To avoid using potentially encryptable fields to ensure a specific order in our testing
        //we will create a map based on the above inserted test data to ensure we have the correct 
        //record to test against rather than relying on order.
        coffs = [SELECT Start_Date__c, 
                        End_Date__c, 
                        Section_ID__c 
                FROM Course_Offering__c 
                WHERE Id IN :coffs];
        Map<String, Course_Offering__c> courseOfferingsBySection = new Map<String, Course_Offering__c>();
        
        for (Course_Offering__c co : coffs) {
          courseOfferingsBySection.put(co.Section_ID__c, co);
        }
        
        //course offering start and end date should have been copied from parent term 
        System.assertEquals(term1.Start_Date__c, courseOfferingsBySection.get('BIO-101 Spring 16').Start_Date__c);
        System.assertEquals(term1.End_Date__c, courseOfferingsBySection.get('BIO-101 Spring 16').End_Date__c);
        
        //only end date should have been copied from parent term
        System.assertEquals(system.today().addMonths(6), courseOfferingsBySection.get('BIO-101 Spring 17').Start_Date__c);
        System.assertEquals(term1.End_Date__c, courseOfferingsBySection.get('BIO-101 Spring 17').End_Date__c);
        
        //only start date should have been copied from parent term
        System.assertEquals(term1.Start_Date__c, courseOfferingsBySection.get('BIO-101 Spring 18').Start_Date__c);
        System.assertEquals(system.today().addMonths(6), courseOfferingsBySection.get('BIO-101 Spring 18').End_Date__c);
        
        //neither start or end dates should have been copied from parent term
        System.assertNotEquals(term1.Start_Date__c, courseOfferingsBySection.get('BIO-101 Spring 19').Start_Date__c);
        System.assertNotEquals(term1.End_Date__c, courseOfferingsBySection.get('BIO-101 Spring 19').End_Date__c);
        
        //neither start or end dates should have been copied from parent term
        System.assertEquals(null, courseOfferingsBySection.get('BIO-101 Spring 20').Start_Date__c);
        System.assertEquals(null, courseOfferingsBySection.get('BIO-101 Spring 20').End_Date__c);

        System.assert(TERM_CourseOff_TDTM.reentrancyPrevented != true, 
            'Did not expect the reentrancy check to have prevented the TERM_CourseOff_TDTM trigger from processing again.');
    }

    /*******************************************************************************************************
    * @description Tests that when the TERM_CourseOff_TDTM class runs, reentrancy is prevented.
    ********************************************************************************************************/
    @isTest
    public static void termUpdateReentrancyCheck() {
        setup();

        // Install Default EDA TDTM Configuration
        List<TDTM_Global_API.TdtmToken> defaultTokens = TDTM_Global_API.getDefaultTdtmConfig();
        TDTM_Global_API.setTdtmConfig(defaultTokens, 'hed');

        // Add the Test TDTM for the Course Offering object. This Test TDTM will simply update the term that caused the course offering to be updated.
        // So the flow would be: Term updated -> course offering updated -> term updated again
        Trigger_Handler__c newTDTM = new Trigger_Handler__c(Active__c = true, Asynchronous__c = false,
            Class__c = 'UTIL_UnitTestData_TEST.Test_TDTM', Load_Order__c = 1, Object__c = 'Course_Offering__c',
            Owned_by_Namespace__c = 'hed', Trigger_Action__c = 'AfterInsert;AfterUpdate');
        insert newTDTM;
        
        //create term without start and end dates
        Term__c term = new Term__c(Account__c = university.Id);
        insert term;
        
        //create child course offering without start or end date
        Course_Offering__c courseOffering = new Course_Offering__c(Section_ID__c = 'BIO-101 Spring 16', 
            Course__c = course.Id, Term__c = term.Id, Capacity__c = 200);
        insert courseOffering;
        
        //add start and end dates to term
        term.Start_Date__c = system.today();
        term.End_Date__c = system.today().addMonths(4);

        //ensure that the term gets updated recursively
        UTIL_UnitTestData_TEST.sObjectsToUpdate = new List<SObject>{ term };

        Test.startTest();
        update term;
        Test.stopTest();

        courseOffering = [SELECT Start_Date__c, 
                                End_Date__c, 
                                Section_ID__c 
                          FROM Course_Offering__c 
                          WHERE Id = :courseOffering.Id][0];

        //course offering start and end date should have been copied from parent term 
        System.assertEquals(term.Start_Date__c, courseOffering.Start_Date__c);
        System.assertEquals(term.End_Date__c, courseOffering.End_Date__c);

        System.assert(TERM_CourseOff_TDTM.reentrancyPrevented == true, 
            'Expected the reentrancy check to have prevented the TERM_CourseOff_TDTM trigger from processing again.');
    }
}