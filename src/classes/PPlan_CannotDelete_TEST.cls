/*
    Copyright (c) 2018, Salesforce.org
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
* @date 2018
* @group Program Plan
* @group-content ../../ApexDocContent/ProgramPlans.htm
* @description Tests for PPlan_CannotDelete_TDTM.
*/
@isTest
public with sharing class PPlan_CannotDelete_TEST {
    
    /*********************************************************************************************************
    * @description Tests the deletion of Program Plan with Plan Requirement as related child records
    * and when “Prevent Program Plan Deletion” is enabled.
    */
    @isTest
    public static void pPlanCannotDeleteWithPlanRequirement() {
        
        // Enable Custom Settings
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Prevent_Program_Plan_Deletion__c = TRUE));
        
        // Insert Program Plan
        List<Program_Plan__c> pPlans = UTIL_UnitTestData_TEST.getMultipleTestProgramPlans(1);
        insert pPlans;
       
       // Insert Plan Requirement
        List<Plan_Requirement__c> prs = UTIL_UnitTestData_TEST.getMultipleTestPlanRequirements(2);
        for (Plan_Requirement__c pr : prs) {
            pr.Program_Plan__c = pPlans[0].Id;
        }
        insert prs;

        Test.startTest();
            Database.DeleteResult[] results = Database.delete(pPlans, false);
        Test.stopTest();

        //Verify pPlan was not successfully deleted
        List<Program_Plan__c> assertPps = [select ID from Program_Plan__c];
        System.assertEquals(1, assertPps.size());

        System.assertEquals(false, results[0].success);
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }
    
    /*********************************************************************************************************
    * @description Tests the deletion of Program Enrollments with Program Enrollment as related child records
    * and when “Prevent Program Plan Deletion” is enabled.
    */
    @isTest
    public static void pPlanCannotDeleteWithProgramEnrollments() {
        
        // Enable Custom Settings
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Prevent_Program_Plan_Deletion__c = TRUE));
        
        // Insert Account
        List<Account> academicPrograms = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe.getAcademicAccRecTypeID());
        insert academicPrograms;
        
        // Insert Program Plan
        List<Program_Plan__c> pPlans = UTIL_UnitTestData_TEST.getMultipleTestProgramPlans(1);
        insert pPlans;
        
        // Insert Plan Enrollment
        List<Program_Enrollment__c> pes = UTIL_UnitTestData_TEST.getMultipleTestProgramEnrollments(2, academicPrograms[0].Id);
        for (Program_Enrollment__c pe : pes) {
            pe.Program_Plan__c = pPlans[0].Id;
        }
        insert pes;

        Test.startTest();
            Database.DeleteResult[] results = Database.delete(pPlans, false);
        Test.stopTest();

        //Verify pPlan was not successfully deleted
        List<Program_Plan__c> assertPps = [select ID from Program_Plan__c];
        System.assertEquals(1, assertPps.size());

        System.assertEquals(false, results[0].success);
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }
    /*********************************************************************************************************
    * @description Tests the deletion of Program Enrollments with Program Enrollment and Plan Requirement
    * as related child records and when “Prevent Program Plan Deletion” is disabled.
    */
    @isTest
    public static void pPlanCannotDeleteWProgramEnrollmentsAndPlanReq() {
        
        // Disable Custom Settings
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Prevent_Program_Plan_Deletion__c = FALSE));

        // Insert Account
        List<Account> academicPrograms = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe.getAcademicAccRecTypeID());
        insert academicPrograms;
        
        // Insert Program plan
        List<Program_Plan__c> pPlans = UTIL_UnitTestData_TEST.getMultipleTestProgramPlans(1);
        insert pPlans;
        
        // Insert Program Enrollment
        List<Program_Enrollment__c> pes = UTIL_UnitTestData_TEST.getMultipleTestProgramEnrollments(2, academicPrograms[0].Id);
        for (Program_Enrollment__c pe : pes) {
            pe.Program_Plan__c = pPlans[0].Id;
        }
        insert pes;
        
        // Insert Plan Requirement
        List<Plan_Requirement__c> prs = UTIL_UnitTestData_TEST.getMultipleTestPlanRequirements(2);
        for (Plan_Requirement__c pr : prs) {
            pr.Program_Plan__c = pPlans[0].Id;
        }
        insert prs;
    
        Test.startTest();
           delete pPlans;
        Test.stopTest();    
        
        //Verify pPlan was successfully deleted
        List<Program_Plan__c> assertPps = [select ID from Program_Plan__c];
        System.assertEquals(0, assertPps.size());
    }
}