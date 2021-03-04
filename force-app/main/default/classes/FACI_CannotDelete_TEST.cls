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
* @group Facility
* @group-content ../../ApexDocContent/Facility.htm
* @description Tests for FACI_CannotDelete_TDTM
*/
@isTest
private class FACI_CannotDelete_TEST {
    /*********************************************************************************************************
    * @description Retrieves the Administrative record type Id. 
    */
    public static String adminAccRecTypeId = UTIL_Describe.getAdminAccRecTypeID(); 
    
    /*********************************************************************************************************
    * @description Retrieves the Academic Program record type Id. 
    */
    public static String academicAccRecTypeId = UTIL_Describe.getAcademicAccRecTypeID(); 
    
    /*********************************************************************************************************
    * @description Test method to test if Prevent_Facility_Deletion__c is enabled in Hierarchy Settings, and
    * Facilities has a Facilities record associated to it, then it cannot be deleted.
    */
    @isTest
    public static void cannotDeleteFacilitiesWithFacilities() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = FACI_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Facility_Deletion__c = True));

        List<Facility__c> parentFacilitiesToInsert = new List<Facility__c>(); 
        Facility__c parentFacility = UTIL_UnitTestData_TEST.getFacility(); 
        Facility__c parentFacility2 = UTIL_UnitTestData_TEST.getFacility();
        parentFacilitiesToInsert.add(parentFacility); 
        parentFacilitiesToInsert.add(parentFacility2); 
        insert parentFacilitiesToInsert; 

        List<Facility__c> childFacilitiesToInsert = new List<Facility__c>(); 
        Facility__c childFacility1 = UTIL_UnitTestData_TEST.getFacility(); 
        Facility__c childFacility2 = UTIL_UnitTestData_TEST.getFacility(); 
        childFacility1.Parent_Facility__c = parentFacility.Id; 
        childFacility2.Parent_Facility__c = parentFacility2.Id; 
        childFacilitiesToInsert.add(childFacility1); 
        childFacilitiesToInsert.add(childFacility2); 
        insert childFacilitiesToInsert; 

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(parentFacilitiesToInsert, false);
        Test.stopTest();

        List<Facility__c> returnParentFacilities = [SELECT Id
                                                    FROM Facility__c
                                                    WHERE Id IN :parentFacilitiesToInsert]; 
        System.assertEquals(2, returnParentFacilities.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);  
    }
    
    /*********************************************************************************************************
    * @description Test method to test if Prevent_Facility_Deletion__c is enabled in Hierarchy Settings, and
    * Facilities has a Course Offering record associated to it, then it cannot be deleted.
    */
    @isTest
    public static void cannotDeleteFacilitiesWithCourseOffering() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = FACI_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Facility_Deletion__c = True));

        List<Facility__c> parentFacilitiesToInsert = new List<Facility__c>(); 
        Facility__c parentFacility = UTIL_UnitTestData_TEST.getFacility(); 
        Facility__c parentFacility2 = UTIL_UnitTestData_TEST.getFacility();
        parentFacilitiesToInsert.add(parentFacility); 
        parentFacilitiesToInsert.add(parentFacility2); 
        insert parentFacilitiesToInsert; 

        List<Account> department = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, academicAccRecTypeId);
        insert department; 
        Course__c course = new Course__c(Account__c = department[0].Id, Name = 'Bio'); 
        insert course; 
        Term__c term = UTIL_UnitTestData_TEST.getTerm(department[0].Id, 'Fall'); 
        insert term; 
        
        List<Course_Offering__c> courseOfferingsToInsert = new List<Course_Offering__c>(); 
        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id); 
        Course_Offering__c courseOffering2 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id); 
        courseOffering1.Facility__c = parentFacilitiesToInsert[0].Id;
        courseOffering2.Facility__c = parentFacilitiesToInsert[1].Id;
        courseOfferingsToInsert.add(courseOffering1); 
        courseOfferingsToInsert.add(courseOffering2);
        update courseOfferingsToInsert; 

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(parentFacilitiesToInsert, false);
        Test.stopTest();

        List<Facility__c> returnParentFacilities = [SELECT Id
                                                    FROM Facility__c
                                                    WHERE Id IN :parentFacilitiesToInsert]; 
        System.assertEquals(2, returnParentFacilities.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);  
    }
    
    /*********************************************************************************************************
    * @description Test method to test if Prevent_Facility_Deletion__c is enabled in Hierarchy Settings, and
    * Facilities has a Facilities and Course Offering record associated to it, then it cannot be deleted.
    */
    @isTest
    public static void cannotDeleteFacilitiesWithChildRecords() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = FACI_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Facility_Deletion__c = True));

        List<Facility__c> parentFacilitiesToInsert = new List<Facility__c>(); 
        Facility__c parentFacility = UTIL_UnitTestData_TEST.getFacility(); 
        Facility__c parentFacility2 = UTIL_UnitTestData_TEST.getFacility();
        parentFacilitiesToInsert.add(parentFacility); 
        parentFacilitiesToInsert.add(parentFacility2); 
        insert parentFacilitiesToInsert; 
        
        List<Facility__c> childFacilitiesToInsert = new List<Facility__c>(); 
        Facility__c childFacility1 = UTIL_UnitTestData_TEST.getFacility(); 
        Facility__c childFacility2 = UTIL_UnitTestData_TEST.getFacility(); 
        childFacility1.Parent_Facility__c = parentFacility.Id; 
        childFacility2.Parent_Facility__c = parentFacility2.Id; 
        childFacilitiesToInsert.add(childFacility1); 
        childFacilitiesToInsert.add(childFacility2); 
        insert childFacilitiesToInsert; 

        List<Account> department = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, academicAccRecTypeId);
        insert department; 
        Course__c course = new Course__c(Account__c = department[0].Id, Name = 'Bio'); 
        insert course; 
        Term__c term = UTIL_UnitTestData_TEST.getTerm(department[0].Id, 'Fall'); 
        insert term; 
        
        List<Course_Offering__c> courseOfferingsToInsert = new List<Course_Offering__c>(); 
        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id); 
        Course_Offering__c courseOffering2 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id); 
        courseOffering1.Facility__c = parentFacilitiesToInsert[0].Id;
        courseOffering2.Facility__c = parentFacilitiesToInsert[1].Id;
        courseOfferingsToInsert.add(courseOffering1); 
        courseOfferingsToInsert.add(courseOffering2);
        update courseOfferingsToInsert; 

        Test.startTest();
        Database.DeleteResult[] results = Database.delete(parentFacilitiesToInsert, false);
        Test.stopTest();

        List<Facility__c> returnParentFacilities = [SELECT Id
                                                    FROM Facility__c
                                                    WHERE Id IN :parentFacilitiesToInsert]; 
        System.assertEquals(2, returnParentFacilities.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);  
    }
    
    /*********************************************************************************************************
    * @description Test method to test if Prevent_Facility_Deletion__c is enabled in Hierarchy Settings, and
    * Facilities has a Facilities or Course Offering record associated to it, then it cannot be deleted.
    */
    @isTest
    public static void cannotDeleteFacilitiesWithSomeChildRecords() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = FACI_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Facility_Deletion__c = True));
                            
        List<Facility__c> parentFacilitiesToInsert = new List<Facility__c>(); 
        Facility__c parentFacility = UTIL_UnitTestData_TEST.getFacility(); 
        Facility__c parentFacility2 = UTIL_UnitTestData_TEST.getFacility();
        parentFacilitiesToInsert.add(parentFacility); 
        parentFacilitiesToInsert.add(parentFacility2); 
        insert parentFacilitiesToInsert; 
        
        Facility__c childFacility1 = UTIL_UnitTestData_TEST.getFacility(); 
        childFacility1.Parent_Facility__c = parentFacility.Id; 
        insert childFacility1;
        
        List<Account> department = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, academicAccRecTypeId);
        insert department; 
        Course__c course = new Course__c(Account__c = department[0].Id, Name = 'Bio'); 
        insert course; 
        Term__c term = UTIL_UnitTestData_TEST.getTerm(department[0].Id, 'Fall'); 
        insert term; 
        
        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id); 
        courseOffering1.Facility__c = parentFacilitiesToInsert[1].Id;
        update courseOffering1; 
        
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(parentFacilitiesToInsert, false);
        Test.stopTest();
        
        List<Facility__c> returnParentFacilities = [SELECT Id
                                                    FROM Facility__c
                                                    WHERE Id IN :parentFacilitiesToInsert]; 
        System.assertEquals(2, returnParentFacilities.size());
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);  
    }
    
    /*********************************************************************************************************
    * @description Test method to test if Prevent_Facility_Deletion__c is disabled in Hierarchy Settings, and
    * Facilities has a Facilities record associated to it, then it can be deleted.
    */
    @isTest
    public static void canDeleteFacilitiesWithFacilities() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = FACI_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Facility_Deletion__c = False));
        
        List<Facility__c> parentFacilitiesToInsert = new List<Facility__c>(); 
        Facility__c parentFacility = UTIL_UnitTestData_TEST.getFacility(); 
        Facility__c parentFacility2 = UTIL_UnitTestData_TEST.getFacility();
        parentFacilitiesToInsert.add(parentFacility); 
        parentFacilitiesToInsert.add(parentFacility2); 
        insert parentFacilitiesToInsert; 
        
        List<Facility__c> childFacilitiesToInsert = new List<Facility__c>();
        Facility__c childFacility1 = UTIL_UnitTestData_TEST.getFacility(); 
        Facility__c childFacility2 = UTIL_UnitTestData_TEST.getFacility(); 
        childFacility1.Parent_Facility__c = parentFacility.Id; 
        childFacility2.Parent_Facility__c = parentFacility2.Id; 
        childFacilitiesToInsert.add(childFacility1); 
        childFacilitiesToInsert.add(childFacility2); 
        insert childFacilitiesToInsert; 
        
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(parentFacilitiesToInsert, false);
        Test.stopTest();

        List<Facility__c> returnParentFacilities = [SELECT Id
                                                    FROM Facility__c
                                                    WHERE Id IN :parentFacilitiesToInsert]; 
        System.assertEquals(0, returnParentFacilities.size());
    }
    
    /*********************************************************************************************************
    * @description Test method to test if Prevent_Facility_Deletion__c is disabled in Hierarchy Settings, and
    * Facilities has a Course Offering record associated to it, then it can be deleted.
    */
    @isTest
    public static void canDeleteFacilitiesWithCourseOffering() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = FACI_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Facility_Deletion__c = False));
        
        List<Facility__c> parentFacilitiesToInsert = new List<Facility__c>(); 
        Facility__c parentFacility = UTIL_UnitTestData_TEST.getFacility(); 
        Facility__c parentFacility2 = UTIL_UnitTestData_TEST.getFacility();
        parentFacilitiesToInsert.add(parentFacility); 
        parentFacilitiesToInsert.add(parentFacility2); 
        insert parentFacilitiesToInsert; 
        
        List<Account> department = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, academicAccRecTypeId);
        insert department; 
        Course__c course = new Course__c(Account__c = department[0].Id, Name = 'Bio'); 
        insert course; 
        Term__c term = UTIL_UnitTestData_TEST.getTerm(department[0].Id, 'Fall'); 
        insert term; 
        
        List<Course_Offering__c> courseOfferingsToInsert = new List<Course_Offering__c>(); 
        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id); 
        Course_Offering__c courseOffering2 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id); 
        courseOffering1.Facility__c = parentFacilitiesToInsert[0].Id;
        courseOffering2.Facility__c = parentFacilitiesToInsert[1].Id;
        courseOfferingsToInsert.add(courseOffering1); 
        courseOfferingsToInsert.add(courseOffering2);
        update courseOfferingsToInsert; 
        
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(parentFacilitiesToInsert, false);
        Test.stopTest();

        List<Facility__c> returnParentFacilities = [SELECT Id
                                                    FROM Facility__c
                                                    WHERE Id IN :parentFacilitiesToInsert]; 
        System.assertEquals(0, returnParentFacilities.size());
    }
    
    /*********************************************************************************************************
    * @description Test method to test if Prevent_Facility_Deletion__c is disabled in Hierarchy Settings, and
    * Facilities has Facilities and Course Offering record associated to it, then it can be deleted.
    */
    @isTest
    public static void canDeleteFacilitiesWithChildRecords() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = FACI_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Facility_Deletion__c = False));
        
        List<Facility__c> parentFacilitiesToInsert = new List<Facility__c>(); 
        Facility__c parentFacility = UTIL_UnitTestData_TEST.getFacility(); 
        Facility__c parentFacility2 = UTIL_UnitTestData_TEST.getFacility();
        parentFacilitiesToInsert.add(parentFacility); 
        parentFacilitiesToInsert.add(parentFacility2); 
        insert parentFacilitiesToInsert; 
        
        List<Facility__c> childFacilitiesToInsert = new List<Facility__c>();
        Facility__c childFacility1 = UTIL_UnitTestData_TEST.getFacility(); 
        Facility__c childFacility2 = UTIL_UnitTestData_TEST.getFacility(); 
        childFacility1.Parent_Facility__c = parentFacility.Id; 
        childFacility2.Parent_Facility__c = parentFacility2.Id; 
        childFacilitiesToInsert.add(childFacility1); 
        childFacilitiesToInsert.add(childFacility2); 
        insert childFacilitiesToInsert; 
 
        List<Account> department = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, academicAccRecTypeId);
        insert department; 
        Course__c course = new Course__c(Account__c = department[0].Id, Name = 'Bio'); 
        insert course; 
        Term__c term = UTIL_UnitTestData_TEST.getTerm(department[0].Id, 'Fall'); 
        insert term; 
        
        List<Course_Offering__c> courseOfferingsToInsert = new List<Course_Offering__c>(); 
        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id); 
        Course_Offering__c courseOffering2 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id); 
        courseOffering1.Facility__c = parentFacilitiesToInsert[0].Id;
        courseOffering2.Facility__c = parentFacilitiesToInsert[1].Id;
        courseOfferingsToInsert.add(courseOffering1); 
        courseOfferingsToInsert.add(courseOffering2);
        update courseOfferingsToInsert;  
        
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(parentFacilitiesToInsert, false);
        Test.stopTest();

        List<Facility__c> returnParentFacilities = [SELECT Id
                                                    FROM Facility__c
                                                    WHERE Id IN :parentFacilitiesToInsert]; 
        System.assertEquals(0, returnParentFacilities.size());
    }

    /*********************************************************************************************************
    * @description Test method to test if Prevent_Facility_Deletion__c is disabled in Hierarchy Settings, and
    * Facilities has Facilities or Course Offering record associated to it, then it can be deleted.
    */
    @isTest
    public static void canDeleteFacilitiesWithSomeChildRecords() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = FACI_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Facility_Deletion__c = False));
        
        List<Facility__c> parentFacilitiesToInsert = new List<Facility__c>(); 
        Facility__c parentFacility = UTIL_UnitTestData_TEST.getFacility(); 
        Facility__c parentFacility2 = UTIL_UnitTestData_TEST.getFacility();
        parentFacilitiesToInsert.add(parentFacility); 
        parentFacilitiesToInsert.add(parentFacility2); 
        insert parentFacilitiesToInsert; 
        
        Facility__c childFacility1 = UTIL_UnitTestData_TEST.getFacility(); 
        childFacility1.Parent_Facility__c = parentFacility.Id; 
        insert childFacility1;
        
        List<Account> department = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, academicAccRecTypeId);
        insert department; 
        Course__c course = new Course__c(Account__c = department[0].Id, Name = 'Bio'); 
        insert course; 
        Term__c term = UTIL_UnitTestData_TEST.getTerm(department[0].Id, 'Fall'); 
        insert term; 
        
        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id); 
        courseOffering1.Facility__c = parentFacilitiesToInsert[1].Id;
        update courseOffering1; 
        
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(parentFacilitiesToInsert, false);
        Test.stopTest();
        
        List<Facility__c> returnParentFacilities = [SELECT Id
                                                    FROM Facility__c
                                                    WHERE Id IN :parentFacilitiesToInsert]; 
        System.assertEquals(0, returnParentFacilities.size());
    }
    
    /*********************************************************************************************************
    * @description Tests the hasChildRecords method that the Facilities record has child records. 
    */
    @isTest
    public static void testFacilitiesHasChildRecords() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = FACI_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Facility_Deletion__c = False));
        List<Facility__c> parentFacilitiesToInsert = new List<Facility__c>(); 
        Facility__c parentFacility = UTIL_UnitTestData_TEST.getFacility(); 
        Facility__c parentFacility2 = UTIL_UnitTestData_TEST.getFacility();
        parentFacilitiesToInsert.add(parentFacility); 
        parentFacilitiesToInsert.add(parentFacility2); 
        insert parentFacilitiesToInsert; 
        
        List<Facility__c> childFacilitiesToInsert = new List<Facility__c>();
        Facility__c childFacility1 = UTIL_UnitTestData_TEST.getFacility(); 
        Facility__c childFacility2 = UTIL_UnitTestData_TEST.getFacility(); 
        childFacility1.Parent_Facility__c = parentFacility.Id; 
        childFacility2.Parent_Facility__c = parentFacility2.Id; 
        childFacilitiesToInsert.add(childFacility1); 
        childFacilitiesToInsert.add(childFacility2); 
        insert childFacilitiesToInsert; 
        
        List<Account> department = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, academicAccRecTypeId);
        insert department; 
        Course__c course = new Course__c(Account__c = department[0].Id, Name = 'Bio'); 
        insert course; 
        Term__c term = UTIL_UnitTestData_TEST.getTerm(department[0].Id, 'Fall'); 
        insert term; 
        
        List<Course_Offering__c> courseOfferingsToInsert = new List<Course_Offering__c>(); 
        Course_Offering__c courseOffering1 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id); 
        Course_Offering__c courseOffering2 = UTIL_UnitTestData_TEST.createCourseOffering(course.Id, term.Id); 
        courseOffering1.Facility__c = parentFacilitiesToInsert[0].Id;
        courseOffering2.Facility__c = parentFacilitiesToInsert[1].Id;
        courseOfferingsToInsert.add(courseOffering1); 
        courseOfferingsToInsert.add(courseOffering2);
        update courseOfferingsToInsert; 
        
        List<Facility__c> returnParentFacilities = [SELECT Id,
                                                    (SELECT Id FROM Facility__c.Facilities__r LIMIT 1), 
                                                    (SELECT Id FROM Facility__c.Course_Offerings__r LIMIT 1)
                                                    FROM Facility__c 
                                                    WHERE Id IN :parentFacilitiesToInsert]; 
        FACI_CannotDelete_TDTM myClass = new FACI_CannotDelete_TDTM(); 
        for (Facility__c facilities: returnParentFacilities) {
            System.assertEquals(True, myClass.hasChildRecords(facilities)); 
        }
    }
    
    /*********************************************************************************************************
    * @description Tests the hasChildRecords method that the Facilities record has no child records. 
    */
    @isTest
    public static void testFacilitiesHasNoChildRecords() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = FACI_CannotDelete_TEST.adminAccRecTypeId,
                                                        Prevent_Facility_Deletion__c = False));
        List<Facility__c> parentFacilitiesToInsert = new List<Facility__c>(); 
        Facility__c parentFacility = UTIL_UnitTestData_TEST.getFacility(); 
        Facility__c parentFacility2 = UTIL_UnitTestData_TEST.getFacility();
        parentFacilitiesToInsert.add(parentFacility); 
        parentFacilitiesToInsert.add(parentFacility2); 
        insert parentFacilitiesToInsert; 
        
        List<Facility__c> returnParentFacilities = [SELECT Id,
                                                    (SELECT Id FROM Facility__c.Facilities__r LIMIT 1), 
                                                    (SELECT Id FROM Facility__c.Course_Offerings__r LIMIT 1)
                                                    FROM Facility__c 
                                                    WHERE Id IN :parentFacilitiesToInsert]; 
        FACI_CannotDelete_TDTM myClass = new FACI_CannotDelete_TDTM(); 
        for (Facility__c facilities: returnParentFacilities) {
            System.assertEquals(False, myClass.hasChildRecords(facilities)); 
        }
    }
}