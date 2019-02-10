/*
    Copyright (c) 2015, Salesforce.org
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
* @date 2015
* @group Program Enrollment
* @group-content ../../ApexDocContent/ProgramEnrollments.htm
* @description Tests specific to Progran Enrollment. 
*/
@isTest
public with sharing class PREN_Affiliation_TEST {

    /*********************************************************************************************************
    * @description Verifies that an Affiliation is automatically created when a Program Enrollment record is 
    * manually created from a Contact.
    */
    @isTest
    public static void createAfflFromProgramEnrollment() {
        STG_InstallScript.insertMappings();

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;
        
        ID orgRecTypeID = UTIL_Describe_API.getBizAccRecTypeID();
        
        //Create account of Business Organization record type
        Account acc = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert acc;
        
        //Create Program Enrollment
        Program_Enrollment__c enrollment = new Program_Enrollment__c(Contact__c = contact.ID, Account__c = acc.ID);
        Test.startTest();
        insert enrollment;
        Test.stopTest();
        
        //An Affiliation should have been automatically created fron the Program Enrollment
        List<Affiliation__c> affls = [SELECT Contact__c, Account__c FROM Affiliation__c WHERE Account__r.ID = :acc.ID];
        System.assertEquals(1, affls.size());
        
        //The Program Enrollment record should be related to the Affiliation just created
        enrollment = [SELECT Affiliation__r.ID FROM Program_Enrollment__c WHERE ID = :enrollment.ID];
        System.assertEquals(affls[0].ID, enrollment.Affiliation__r.ID);

        //Only should one program enrollment exist
        List<Program_Enrollment__c> assertProgramEnrollments = [SELECT Id FROM Program_Enrollment__c];
        System.assertEquals(1, assertProgramEnrollments.size());
    }
    
    /*********************************************************************************************************
    * @description Creating a Program Enrollment copies the related Affiliation End Date when 
    * Affl_ProgEnroll_Copy_End_Date__c setting is set to true.
    */
    @isTest
    public static void copyAfflFromProgramEnrollmentEndDateYes() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Affl_ProgEnroll_Copy_End_Date__c = true));
        
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;
        
        ID orgRecTypeID = UTIL_Describe_API.getBizAccRecTypeID();
        
        //Create account of Business Organization record type
        Account acc = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert acc;
        
        //Test for end date
        Date testDate = Date.newInstance(1970, 1, 1);
        
        //Create Program Enrollment
        Program_Enrollment__c enrollment = new Program_Enrollment__c(Contact__c = contact.ID, Account__c = acc.ID, End_Date__c = testDate);
        Test.startTest();
        insert enrollment;
        Test.stopTest();
        
        //An Affiliation should have been automatically created fron the Program Enrollment
        List<Affiliation__c> affls = [SELECT EndDate__c FROM Affiliation__c WHERE Account__r.ID = :acc.ID];
        System.assertEquals(1, affls.size());
        System.assertEquals(testDate, affls[0].EndDate__c);

        //Only should one program enrollment exist
        List<Program_Enrollment__c> assertProgramEnrollments = [SELECT Id FROM Program_Enrollment__c];
        System.assertEquals(1, assertProgramEnrollments.size());
    }
    
    /*********************************************************************************************************
    * @description Creating a Program Enrollment doesn't copy the related Affiliation End Date when 
    * Affl_ProgEnroll_Copy_End_Date__c setting is set to false.
    */
    @isTest
    public static void copyAfflFromProgramEnrollmentEndDateNo() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Affl_ProgEnroll_Copy_End_Date__c = false));
        
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;
        
        ID orgRecTypeID = UTIL_Describe_API.getBizAccRecTypeID();
        
        //Create account of Business Organization record type
        Account acc = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert acc;
        
        //Test for end date
        Date testDate = Date.newInstance(1970, 1, 1);
        
        //Create Program Enrollment
        Program_Enrollment__c enrollment = new Program_Enrollment__c(Contact__c = contact.ID, Account__c = acc.ID, End_Date__c = testDate);
        Test.startTest();
        insert enrollment;
        Test.stopTest();
        
        //An Affiliation should have been automatically created fron the Program Enrollment
        List<Affiliation__c> affls = [SELECT EndDate__c FROM Affiliation__c WHERE Account__r.ID = :acc.ID];
        System.assertEquals(1, affls.size());
        System.assertEquals(null, affls[0].EndDate__c);

        //Only should one program enrollment exist
        List<Program_Enrollment__c> assertProgramEnrollments = [SELECT Id FROM Program_Enrollment__c];
        System.assertEquals(1, assertProgramEnrollments.size());
    }
    
    /*********************************************************************************************************
    * @description Creating a Program Enrollment copies the related Affiliation Start Date when 
    * Affl_ProgEnroll_Copy_Start_Date__c setting is set to true.
    */
    @isTest
    public static void copyAfflFromProgramEnrollmentStartDateYes() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Affl_ProgEnroll_Copy_Start_Date__c = true));
        
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;
        
        ID orgRecTypeID = UTIL_Describe_API.getBizAccRecTypeID();
        
        //Create account of Business Organization record type
        Account acc = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert acc;
        
        //Test for end date
        Date testDate = Date.newInstance(1970, 1, 1);
        
        //Create Program Enrollment
        Program_Enrollment__c enrollment = new Program_Enrollment__c(Contact__c = contact.ID, Account__c = acc.ID, Start_Date__c = testDate);
        Test.startTest();
        insert enrollment;
        Test.stopTest();
        
        //An Affiliation should have been automatically created fron the Program Enrollment
        List<Affiliation__c> affls = [SELECT StartDate__c FROM Affiliation__c WHERE Account__r.ID = :acc.ID];
        System.assertEquals(1, affls.size());
        System.assertEquals(testDate, affls[0].StartDate__c);

        //Only should one program enrollment exist
        List<Program_Enrollment__c> assertProgramEnrollments = [SELECT Id FROM Program_Enrollment__c];
        System.assertEquals(1, assertProgramEnrollments.size());
    }
    
    /*********************************************************************************************************
    * @description Creating a Program Enrollment doesn't copy the related Affiliation Start Date when 
    * Affl_ProgEnroll_Copy_Start_Date__c setting is set to false.
    */
    @isTest
    public static void copyAfflFromProgramEnrollmentStartDateNo() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Affl_ProgEnroll_Copy_Start_Date__c = false));
        
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;
        
        ID orgRecTypeID = UTIL_Describe_API.getBizAccRecTypeID();
        
        //Create account of Business Organization record type
        Account acc = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert acc;
        
        //Test for end date
        Date testDate = Date.newInstance(1970, 1, 1);
        
        //Create Program Enrollment
        Program_Enrollment__c enrollment = new Program_Enrollment__c(Contact__c = contact.ID, Account__c = acc.ID, Start_Date__c = testDate);
        Test.startTest();
        insert enrollment;
        Test.stopTest();
        
        //An Affiliation should have been automatically created fron the Program Enrollment
        List<Affiliation__c> affls = [SELECT StartDate__c FROM Affiliation__c WHERE Account__r.ID = :acc.ID];
        System.assertEquals(1, affls.size());
        System.assertNotEquals(testDate, affls[0].StartDate__c);

        //Only should one program enrollment exist
        List<Program_Enrollment__c> assertProgramEnrollments = [SELECT Id FROM Program_Enrollment__c];
        System.assertEquals(1, assertProgramEnrollments.size());
    }
    
    /*********************************************************************************************************
    * @description Creating a Program Enrollment sets the related Affiliation Role when 
    * Affl_ProgEnroll_Set_Role__c setting is set to true.
    */
    @isTest
    public static void setAfflFromProgramEnrollmentRoleYes() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Affl_ProgEnroll_Set_Role__c = true, Affl_ProgEnroll_Role_Map__c='Student'));
        
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;
        
        ID orgRecTypeID = UTIL_Describe_API.getBizAccRecTypeID();
        
        //Create account of Business Organization record type
        Account acc = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert acc;
        
        //Create Program Enrollment
        Program_Enrollment__c enrollment = new Program_Enrollment__c(Contact__c = contact.ID, Account__c = acc.ID);
        Test.startTest();
        insert enrollment;
        Test.stopTest();
        
        //An Affiliation should have been automatically created fron the Program Enrollment
        List<Affiliation__c> affls = [SELECT Role__c FROM Affiliation__c WHERE Account__r.ID = :acc.ID];
        System.assertEquals(1, affls.size());
        System.assertEquals('Student', affls[0].Role__c);

        //Only should one program enrollment exist
        List<Program_Enrollment__c> assertProgramEnrollments = [SELECT Id FROM Program_Enrollment__c];
        System.assertEquals(1, assertProgramEnrollments.size());
    }
    
    /*********************************************************************************************************
    * @description Creating a Program Enrollment does not set the related Affiliation Role when 
    * Affl_ProgEnroll_Set_Role__c setting is set to false.
    */
    @isTest
    public static void setAfflFromProgramEnrollmentRoleNo() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Affl_ProgEnroll_Set_Role__c = false, Affl_ProgEnroll_Role_Map__c='Student'));
        
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;
        
        ID orgRecTypeID = UTIL_Describe_API.getBizAccRecTypeID();
        
        //Create account of Business Organization record type
        Account acc = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert acc;
        
        //Create Program Enrollment
        Program_Enrollment__c enrollment = new Program_Enrollment__c(Contact__c = contact.ID, Account__c = acc.ID);
        Test.startTest();
        insert enrollment;
        Test.stopTest();
        
        //An Affiliation should have been automatically created fron the Program Enrollment
        List<Affiliation__c> affls = [SELECT Role__c FROM Affiliation__c WHERE Account__r.ID = :acc.ID];
        System.assertEquals(1, affls.size());
        System.assertEquals(null, affls[0].Role__c);

        //Only should one program enrollment exist
        List<Program_Enrollment__c> assertProgramEnrollments = [SELECT Id FROM Program_Enrollment__c];
        System.assertEquals(1, assertProgramEnrollments.size());
    }
    
    /*********************************************************************************************************
    * @description Creating a Program Enrollment sets the related Affiliation Status when 
    * to Affiliation_Program_Enrollment_Stat_Map.
    */
    @isTest
    public static void setAfflFromProgramEnrollmentStatus() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Affl_ProgEnroll_Status_Map__c='Former'));
        
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;
        
        ID orgRecTypeID = UTIL_Describe_API.getBizAccRecTypeID();
        
        //Create account of Business Organization record type
        Account acc = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert acc;
        
        //Create Program Enrollment
        Program_Enrollment__c enrollment = new Program_Enrollment__c(Contact__c = contact.ID, Account__c = acc.ID);
        Test.startTest();
        insert enrollment;
        Test.stopTest();
        
        //An Affiliation should have been automatically created fron the Program Enrollment
        List<Affiliation__c> affls = [SELECT Status__c FROM Affiliation__c WHERE Account__r.ID = :acc.ID];
        System.assertEquals(1, affls.size());
        System.assertEquals('Former', affls[0].Status__c);

        //Only should one program enrollment exist
        List<Program_Enrollment__c> assertProgramEnrollments = [SELECT Id FROM Program_Enrollment__c];
        System.assertEquals(1, assertProgramEnrollments.size());
    }

    /*********************************************************************************************************
    * @description Creating a Program Enrollment sets the related Affiliation Role when
    * Affl_ProgEnroll_Set_Role__c setting is set to true and sets the related Affiliation Status
    * to Affiliation_Program_Enrollment_Stat_Map
    */
    @isTest
    public static void setAfflFromProgramEnrollmentRoleYesStatus() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Affl_ProgEnroll_Set_Role__c = true,
                                                                                Affl_ProgEnroll_Role_Map__c='Student',
                                                                                Affl_ProgEnroll_Status_Map__c='Current'));

        STG_InstallScript.insertMappings();

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;

        //Craete account of Business Organization record type
        Account acc = new Account(Name='Acme', RecordTypeId = UTIL_Describe_API.getAcademicAccRecTypeID());
        insert acc;

        //Create Program Enrollment
        Program_Enrollment__c enrollment = new Program_Enrollment__c(Contact__c = contact.ID, Account__c = acc.ID);
        Test.startTest();
        insert enrollment;
        Test.stopTest();

        //An Affiliation should have been automatically created fron the Program Enrollment
        List<Affiliation__c> affls = [SELECT Role__c FROM Affiliation__c WHERE Account__r.ID = :acc.ID];
        System.assertEquals(1, affls.size());
        System.assertEquals('Student', affls[0].Role__c);

        //Only should one program enrollment exist
        List<Program_Enrollment__c> assertProgramEnrollments = [SELECT Id FROM Program_Enrollment__c];
        System.assertEquals(1, assertProgramEnrollments.size());
    }
    /*********************************************************************************************************
    * @description Deleting a Program Enrollment deletes the related Affiliation when Affl_ProgEnroll_Del__c setting
    * is set to true.
    */
    @isTest
    public static void deletePEnrollDelAfflYes() {
        STG_InstallScript.insertMappings();

        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Affl_ProgEnroll_Del__c = true));
        
        Contact contact = UTIL_UnitTestData_TEST.getContact();
        insert contact;

        //Create account of Business Organization record type
        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;
        
        //Create Program Enrollment
        Program_Enrollment__c enrollment = new Program_Enrollment__c(Contact__c = contact.ID, Account__c = acc.ID);
        insert enrollment;
        
        //An Affiliation should have been automatically created fron the Program Enrollment
        List<Affiliation__c> affls = [SELECT Contact__c, Account__c FROM Affiliation__c WHERE Account__r.ID = :acc.ID];
        System.assertEquals(1, affls.size());
        
        //The Program Enrollment record should be related to the Affiliation just created
        enrollment = [SELECT Affiliation__r.ID FROM Program_Enrollment__c WHERE ID = :enrollment.ID];
        System.assertEquals(affls[0].ID, enrollment.Affiliation__r.ID);
        ID enrollmentAfflID = enrollment.Affiliation__r.ID; //Storing it to use it in next query

        //Create additional Program Enrollment
        Program_Enrollment__c enrollment2 = new Program_Enrollment__c(Contact__c = contact.ID, Account__c = acc.ID, Affiliation__c = enrollmentAfflID);
        insert enrollment2;
        
        //Delete both Program Enrollments
        Test.startTest();
        delete new List<Program_Enrollment__c>{ enrollment, enrollment2 };
        Test.stopTest();
        
        //Related Affiliation should have been automatically deleted
        affls = [SELECT ID FROM Affiliation__c WHERE ID = :enrollmentAfflID];
        System.assertEquals(0, affls.size());
    }

    /*********************************************************************************************************
    * @description Deleting a Program Enrollment does not delete the related Affiliation when Affl_ProgEnroll_Del__c setting
    * is set to true but other Program Enrollments are associated to the same Affiliation.
    */
    @isTest
    public static void deletePEnrollDelAfflYes_existingPEPreventsAffiliationDeletion() {
        STG_InstallScript.insertMappings();

        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Affl_ProgEnroll_Del__c = true));
        
        Contact contact = UTIL_UnitTestData_TEST.getContact();
        insert contact;

        //Create account of Business Organization record type
        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;
        
        //Create Program Enrollment
        Program_Enrollment__c enrollment = new Program_Enrollment__c(Contact__c = contact.ID, Account__c = acc.ID);
        insert enrollment;
        
        //An Affiliation should have been automatically created fron the Program Enrollment
        List<Affiliation__c> affls = [SELECT Contact__c, Account__c FROM Affiliation__c WHERE Account__r.ID = :acc.ID];
        System.assertEquals(1, affls.size());
        
        //The Program Enrollment record should be related to the Affiliation just created
        enrollment = [SELECT Affiliation__r.ID FROM Program_Enrollment__c WHERE ID = :enrollment.ID];
        System.assertEquals(affls[0].ID, enrollment.Affiliation__r.ID);
        ID enrollmentAfflID = enrollment.Affiliation__r.ID; //Storing it to use it in next query

        //Create additional Program Enrollment
        Program_Enrollment__c enrollment2 = new Program_Enrollment__c(Contact__c = contact.ID, Account__c = acc.ID, Affiliation__c = enrollmentAfflID);
        insert enrollment2;
        
        //Delete Program Enrollment
        Test.startTest();
        delete enrollment;
        Test.stopTest();
        
        //Related Affiliation should have NOT been automatically deleted
        affls = [SELECT ID FROM Affiliation__c WHERE ID = :enrollmentAfflID];
        System.assertEquals(1, affls.size());
    }
    
    /*********************************************************************************************************
    * @description Deleting a Program Enrollment doesn't delete the related Affiliation when Affl_ProgEnroll_Del__c setting
    * is set to false. It just changes the status to what is defined in Affl_ProgEnroll_Del_Status__c.
    */
    @isTest
    public static void deletePEnrollDelAfflNo() {
        STG_InstallScript.insertMappings();

        String afflStatus = 'Former';
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Affl_ProgEnroll_Del__c = false, 
        Affl_ProgEnroll_Del_Status__c = afflStatus));

        Contact contact = UTIL_UnitTestData_TEST.getContact();
        insert contact;

        //Create account of Business Organization record type
        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;
        
        //Create Program Enrollment
        Program_Enrollment__c enrollment = new Program_Enrollment__c(Contact__c = contact.ID, Account__c = acc.ID);
        insert enrollment;
        
        //An Affiliation should have been automatically created fron the Program Enrollment
        List<Affiliation__c> affls = [SELECT Contact__c, Account__c FROM Affiliation__c WHERE Account__r.ID = :acc.ID];
        System.assertEquals(1, affls.size());
        
        //The Program Enrollment record should be related to the Affiliation just created
        enrollment = [SELECT Affiliation__r.ID FROM Program_Enrollment__c WHERE ID = :enrollment.ID];
        System.assertEquals(affls[0].ID, enrollment.Affiliation__r.ID);
        
        ID enrollmentAfflID = enrollment.Affiliation__r.ID; //Storing it to use it in next query
        
        //Delete Program Enrollment
        Test.startTest();
        delete enrollment;
        Test.stopTest();
        
        //Related Affiliation status should have been automatically updated
        affls = [SELECT Status__c FROM Affiliation__c WHERE ID = :enrollmentAfflID];
        System.assertEquals(1, affls.size());
        System.assertEquals(afflStatus, affls[0].Status__c);
    }
}