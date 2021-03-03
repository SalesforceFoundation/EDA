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
* @group Course
* @group-content ../../ApexDocContent/Course.htm
* @description Tests for COUR_CannotDelete_TDTM
*/
@isTest
private class COUR_CannotDelete_TEST {
    /*********************************************************************************************************
    * @description Retrieves the Administrative record type Id. 
    */
    public static String adminAccRecTypeId = UTIL_Describe.getAdminAccRecTypeID(); 
    
    /*********************************************************************************************************
    * @description Test method to test if Prevent_Course_Deletion__c is enabled in Hierarchy Settings, and
    * Course has a Course Offering record associated to it, then it cannot be deleted.
    */
    @isTest
    public static void cannotDeleteCourseWithCourseOffering() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                (Account_Processor__c = COUR_CannotDelete_TEST.adminAccRecTypeId,
                                                Prevent_Course_Deletion__c = True));

        //We're using "Administrative" record type for this new Account since
        //we're not ready (we need to determine how best to handle retrieving recordTypeIds that are not
        //in EDA Settings) to create a new method to retrieve the Universtiy_Department Account
        //record type in UTIL_Describe. 
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, COUR_CannotDelete_TEST.adminAccRecTypeId); 
        insert accounts; 

        List<Course__c> courses = new List<Course__c> {
            new Course__c (Name = 'Course1', Account__c  = accounts[0].Id),
            new Course__c (Name = 'Course2', Account__c  = accounts[0].Id)
        };        
        insert courses; 

        List<Term__c> terms = new List<Term__c> {
            new Term__c(Name = 'Fall', Account__c = accounts[0].Id),
            new Term__c(Name = 'Spring', Account__c = accounts[0].Id)  
        }; 
        insert terms; 

        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(courses[0].Id, terms[0].Id); 
        Course_Offering__c courseOffering2 = UTIL_UnitTestData_TEST.createCourseOffering(courses[1].Id, terms[1].Id);

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(courses, false);
        Test.stopTest();

        List<Course__c> returnCourses = [SELECT Id
                                        FROM Course__c
                                        WHERE Id IN :courses]; 
        System.assertEquals(2, returnCourses.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);  
    }
    
    /*********************************************************************************************************
    * @description Test method to test if Prevent_Course_Deletion__c is enabled in Hierarchy Settings, and
    * Course has a Plan Requirement record associated to it, then it cannot be deleted.
    */
    @isTest
    public static void cannotDeleteCourseWithPlanRequirements() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = COUR_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Course_Deletion__c = True));

        //We're using "Administrative" record type for this new Account since
        //we're not ready (we need to determine how best to handle retrieving recordTypeIds that are not
        //in EDA Settings) to create a new method to retrieve the Universtiy_Department Account
        //record type in UTIL_Describe. 
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, COUR_CannotDelete_TEST.adminAccRecTypeId); 
        insert accounts; 

        List<Course__c> courses = new List<Course__c> {
            new Course__c (Name = 'Course1', Account__c  = accounts[0].Id),
            new Course__c (Name = 'Course2', Account__c  = accounts[0].Id)
        };        
        insert courses; 

        List<Plan_Requirement__c> planReqs = UTIL_UnitTestData_TEST.getMultipleTestPlanRequirements(2); 
        planReqs[0].Course__c = courses[0].Id;
        planReqs[1].Course__c = courses[1].Id;
        insert planReqs; 

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(courses, false);
        Test.stopTest();

        List<Course__c> returnCourses = [SELECT Id
                                        FROM Course__c
                                        WHERE Id IN :courses]; 
        System.assertEquals(2, returnCourses.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);  
    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Course_Deletion__c is enabled in Hierarchy Settings, and
    * Courses have a Course Offering and Plan Requirement record associated to it, then it cannot be deleted.
    */
    @isTest
    public static void cannotDeleteCourseWithChildRecords() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = COUR_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Course_Deletion__c = True));

        //We're using "Administrative" record type for this new Account since
        //we're not ready (we need to determine how best to handle retrieving recordTypeIds that are not
        //in EDA Settings) to create a new method to retrieve the Universtiy_Department Account
        //record type in UTIL_Describe. 
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, COUR_CannotDelete_TEST.adminAccRecTypeId); 
        insert accounts; 

        List<Course__c> courses = new List<Course__c>{
            new Course__c (Name = 'Course1', Account__c  = accounts[0].Id),
            new Course__c (Name = 'Course2', Account__c  = accounts[0].Id)
        };        
        insert courses; 

        List<Term__c> terms = new List<Term__c>{
            new Term__c(Name = 'Fall', Account__c = accounts[0].Id),
            new Term__c(Name = 'Spring', Account__c = accounts[0].Id)  
        }; 
        insert terms; 

        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(courses[0].Id, terms[0].Id); 
        Course_Offering__c courseOffering2 = UTIL_UnitTestData_TEST.createCourseOffering(courses[1].Id, terms[1].Id); 

        List<Plan_Requirement__c> planReqs = UTIL_UnitTestData_TEST.getMultipleTestPlanRequirements(2); 
        planReqs[0].Course__c = courses[0].Id;
        planReqs[1].Course__c = courses[1].Id;
        insert planReqs; 

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(courses, false);
        Test.stopTest();

        List<Course__c> returnCourses = [SELECT Id
                                        FROM Course__c
                                        WHERE Id IN :courses]; 
        System.assertEquals(2, returnCourses.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }
    
    /*********************************************************************************************************
    * @description Test method to test if Prevent_Course_Deletion__c is enabled in Hierarchy Settings, and
    * Course has a Course Offering and Plan Requirement record associated to it, then it cannot be deleted.
    */
    @isTest
    public static void cannotDeleteCourseWithSomeChildRecords() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = COUR_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Course_Deletion__c = True));

        //We're using "Administrative" record type for this new Account since
        //we're not ready (we need to determine how best to handle retrieving recordTypeIds that are not
        //in EDA Settings) to create a new method to retrieve the Universtiy_Department Account
        //record type in UTIL_Describe. 
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, COUR_CannotDelete_TEST.adminAccRecTypeId); 
        insert accounts; 

        List<Course__c> courses = new List<Course__c>{
            new Course__c (Name = 'Course1', Account__c  = accounts[0].Id),
            new Course__c (Name = 'Course2', Account__c  = accounts[0].Id)
        };        
        insert courses; 

        List<Term__c> terms = new List<Term__c>{
            new Term__c(Name = 'Fall', Account__c = accounts[0].Id),
            new Term__c(Name = 'Spring', Account__c = accounts[0].Id)  
        }; 
        insert terms; 

        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(courses[0].Id, terms[0].Id); 

        List<Plan_Requirement__c> planReqs = UTIL_UnitTestData_TEST.getMultipleTestPlanRequirements(1); 
        planReqs[0].Course__c = courses[0].Id;
        insert planReqs; 

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(courses, false);
        Test.stopTest();

        List<Course__c> returnCourses = [SELECT Id
                                        FROM Course__c
                                        WHERE Id IN :courses]; 
        System.assertEquals(1, returnCourses.size());
    }
    
    /*********************************************************************************************************
    * @description Test method to test if Prevent_Course_Deletion__c is disabled in Hierarchy Settings, and
    * Course has a Course Offering record associated to it, then it can be deleted.
    */
    @isTest
    public static void canDeleteCourseWithCourseOffering() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = COUR_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Course_Deletion__c = False));

        //We're using "Administrative" record type for this new Account since
        //we're not ready (we need to determine how best to handle retrieving recordTypeIds that are not
        //in EDA Settings) to create a new method to retrieve the Universtiy_Department Account
        //record type in UTIL_Describe. 
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, COUR_CannotDelete_TEST.adminAccRecTypeId); 
        insert accounts; 

        List<Course__c> courses = new List<Course__c>{
            new Course__c (Name = 'Course1', Account__c  = accounts[0].Id),
            new Course__c (Name = 'Course2', Account__c  = accounts[0].Id)
        };        
        insert courses; 

        List<Term__c> terms = new List<Term__c>{
            new Term__c(Name = 'Fall', Account__c = accounts[0].Id),
            new Term__c(Name = 'Spring', Account__c = accounts[0].Id)  
        }; 
        insert terms; 

        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(courses[0].Id, terms[0].Id); 
        Course_Offering__c courseOffering2 = UTIL_UnitTestData_TEST.createCourseOffering(courses[1].Id, terms[1].Id);

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(courses, false);
        Test.stopTest();

        List<Course__c> returnCourses = [SELECT Id
                                        FROM Course__c
                                        WHERE Id IN :courses]; 
        System.assertEquals(0, returnCourses.size());
    }
    
    /*********************************************************************************************************
    * @description Test method to test if Prevent_Course_Deletion__c is disabled in Hierarchy Settings, and
    * Course has a Plan Requirement record associated to it, then it can be deleted.
    */
    @isTest
    public static void canDeleteCourseWithPlanRequirements() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = COUR_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Course_Deletion__c = False));

        //We're using "Administrative" record type for this new Account since
        //we're not ready (we need to determine how best to handle retrieving recordTypeIds that are not
        //in EDA Settings) to create a new method to retrieve the Universtiy_Department Account
        //record type in UTIL_Describe. 
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, COUR_CannotDelete_TEST.adminAccRecTypeId); 
        insert accounts; 

        List<Course__c> courses = new List<Course__c>{
            new Course__c (Name = 'Course1', Account__c  = accounts[0].Id),
            new Course__c (Name = 'Course2', Account__c  = accounts[0].Id)
        };        
        insert courses; 

        List<Plan_Requirement__c> planReqs = UTIL_UnitTestData_TEST.getMultipleTestPlanRequirements(2); 
        planReqs[0].Course__c = courses[0].Id;
        planReqs[1].Course__c = courses[1].Id;
        insert planReqs; 

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(courses, false);
        Test.stopTest();

        List<Course__c> returnCourses = [SELECT Id
                                        FROM Course__c
                                        WHERE Id IN :courses]; 
        System.assertEquals(0, returnCourses.size());
    }
    
    /*********************************************************************************************************
    * @description Test method to test if Prevent_Course_Deletion__c is disabled in Hierarchy Settings, and
    * Courses have a Course Offering and Plan Requirement record associated to it, then it can be deleted.
    */
    @isTest
    public static void canDeleteCourseWithChildRecords() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = COUR_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Course_Deletion__c = False));

        //We're using "Administrative" record type for this new Account since
        //we're not ready (we need to determine how best to handle retrieving recordTypeIds that are not
        //in EDA Settings) to create a new method to retrieve the Universtiy_Department Account
        //record type in UTIL_Describe. 
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, COUR_CannotDelete_TEST.adminAccRecTypeId); 
        insert accounts; 

        List<Course__c> courses = new List<Course__c>{
            new Course__c (Name = 'Course1', Account__c  = accounts[0].Id),
            new Course__c (Name = 'Course2', Account__c  = accounts[0].Id)
        };        
        insert courses; 

        List<Term__c> terms = new List<Term__c>{
            new Term__c(Name = 'Fall', Account__c = accounts[0].Id),
            new Term__c(Name = 'Spring', Account__c = accounts[0].Id)  
        }; 
        insert terms; 

        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(courses[0].Id, terms[0].Id); 
        Course_Offering__c courseOffering2 = UTIL_UnitTestData_TEST.createCourseOffering(courses[1].Id, terms[1].Id); 

        List<Plan_Requirement__c> planReqs = UTIL_UnitTestData_TEST.getMultipleTestPlanRequirements(2); 
        planReqs[0].Course__c = courses[0].Id;
        planReqs[1].Course__c = courses[1].Id;
        insert planReqs; 

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(courses, false);
        Test.stopTest();

        List<Course__c> returnCourses = [SELECT Id
                                        FROM Course__c
                                        WHERE Id IN :courses]; 
        System.assertEquals(0, returnCourses.size());
    }
    
    /*********************************************************************************************************
    * @description Test method to test if Prevent_Course_Deletion__c is disabled in Hierarchy Settings, and
    * Course has a Course Offering and Plan Requirement record associated to it, then it can be deleted.
    */
    @isTest
    public static void canDeleteCourseWithSomeChildRecords() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = COUR_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Course_Deletion__c = False));
            
        //We're using "Administrative" record type for this new Account since
        //we're not ready (we need to determine how best to handle retrieving recordTypeIds that are not
        //in EDA Settings) to create a new method to retrieve the Universtiy_Department Account
        //record type in UTIL_Describe. 
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, COUR_CannotDelete_TEST.adminAccRecTypeId); 
        insert accounts; 
        
        List<Course__c> courses = new List<Course__c>{
            new Course__c (Name = 'Course1', Account__c  = accounts[0].Id),
            new Course__c (Name = 'Course2', Account__c  = accounts[0].Id)
        };        
        insert courses; 
        
        List<Term__c> terms = new List<Term__c>{
            new Term__c(Name = 'Fall', Account__c = accounts[0].Id),
            new Term__c(Name = 'Spring', Account__c = accounts[0].Id)  
        }; 
        insert terms; 
        
        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(courses[0].Id, terms[0].Id); 
        
        List<Plan_Requirement__c> planReqs = UTIL_UnitTestData_TEST.getMultipleTestPlanRequirements(1); 
        planReqs[0].Course__c = courses[0].Id;
        insert planReqs; 
        
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(courses, false);
        Test.stopTest();
        
        List<Course__c> returnCourses = [SELECT Id
                                        FROM Course__c
                                        WHERE Id IN :courses]; 
        System.assertEquals(0, returnCourses.size());
    }
    
    /*********************************************************************************************************
    * @description Tests the hasChildRecords method that the Course record has child records. 
    */
    @isTest
    public static void testCourseHasChildRecords() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = COUR_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Course_Deletion__c = True));
        
        //We're using "Administrative" record type for this new Account since
        //we're not ready (we need to determine how best to handle retrieving recordTypeIds that are not
        //in EDA Settings) to create a new method to retrieve the Universtiy_Department Account
        //record type in UTIL_Describe. 
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, COUR_CannotDelete_TEST.adminAccRecTypeId); 
        insert accounts; 
        
        List<Course__c> courses = new List<Course__c>{
            new Course__c (Name = 'Course1', Account__c  = accounts[0].Id),
            new Course__c (Name = 'Course2', Account__c  = accounts[0].Id)
        };        
        insert courses; 
        
        List<Term__c> terms = new List<Term__c>{
            new Term__c(Name = 'Fall', Account__c = accounts[0].Id),
            new Term__c(Name = 'Spring', Account__c = accounts[0].Id)  
        }; 
        insert terms; 
        
        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(courses[0].Id, terms[0].Id); 
        Course_Offering__c courseOffering2 = UTIL_UnitTestData_TEST.createCourseOffering(courses[1].Id, terms[1].Id); 
        
        List<Plan_Requirement__c> planReqs = UTIL_UnitTestData_TEST.getMultipleTestPlanRequirements(2); 
        planReqs[0].Course__c = courses[0].Id;
        planReqs[1].Course__c = courses[1].Id;
        insert planReqs; 
        
        List<Course__c> returnCourses = [SELECT Id,
                                        (SELECT Id, Name FROM Course_Offerings__r LIMIT 1),
                                        (SELECT Id, Name FROM Plan_Requirements__r LIMIT 1)
                                        FROM Course__c
                                        WHERE Id IN :courses]; 
        
        COUR_CannotDelete_TDTM myClass = new COUR_CannotDelete_TDTM();
        for (Course__c cour : returnCourses) { 
            System.assertEquals(True, myClass.hasChildRecords(cour)); 
        }
    }
	
    /*********************************************************************************************************
    * @description Tests the hasChildRecords method that the Course record has no child records. 
    */
    @isTest
    public static void testCourseHasNoChildRecords() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = COUR_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Course_Deletion__c = True));
        
        //We're using "Administrative" record type for this new Account since
        //we're not ready (we need to determine how best to handle retrieving recordTypeIds that are not
        //in EDA Settings) to create a new method to retrieve the Universtiy_Department Account
        //record type in UTIL_Describe. 
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, COUR_CannotDelete_TEST.adminAccRecTypeId); 
        insert accounts; 
        
        List<Course__c> courses = new List<Course__c>{
            new Course__c (Name = 'Course1', Account__c  = accounts[0].Id),
            new Course__c (Name = 'Course2', Account__c  = accounts[0].Id)
        };        
        insert courses; 
        
        List<Course__c> returnCourses = [SELECT Id,
                                        (SELECT Id, Name FROM Course_Offerings__r LIMIT 1),
                                        (SELECT Id, Name FROM Plan_Requirements__r LIMIT 1)
                                        FROM Course__c
                                        WHERE Id IN :courses]; 
        
        COUR_CannotDelete_TDTM myClass = new COUR_CannotDelete_TDTM();
        for (Course__c cour : returnCourses) {
            System.assertEquals(False, myClass.hasChildRecords(cour)); 
        }
    }
}