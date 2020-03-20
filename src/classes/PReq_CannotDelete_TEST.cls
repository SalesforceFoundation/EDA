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
* @group Plan Requirement
* @group-content ../../ApexDocContent/PlanRequirements.htm
* @description Tests for PReq_CannotDelete_TDTM.
*/
@isTest
public with sharing class PReq_CannotDelete_TEST {
    /*********************************************************************************************************
    * @description Retrieves the Business Account record type Id. 
    */
    public static String bizAccRecordTypeId = UTIL_Describe_API.getBizAccRecTypeID(); 
    
    /*********************************************************************************************************
    * @description Test method to test if Prevent_Plan_Requirement_Deletion__c is enabled in Hierarchy Settings, 
    * and Plan Requirement has a Plan Requirement record associated to it, then it cannot be deleted.
    */
    @isTest
    public static void pReqCannotDeleteWithPlanRequirement() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = bizAccRecordTypeId,
                                                          Prevent_Plan_Requirement_Deletion__c = TRUE));
        
        List<Program_Plan__c> pPlans = UTIL_UnitTestData_TEST.getMultipleTestProgramPlans(1);
        insert pPlans;
        
        List<Plan_Requirement__c> parentPReqs = UTIL_UnitTestData_TEST.getMultipleTestPlanRequirements(2); 
        insert parentPReqs; 
        
        List<Plan_Requirement__c> childrenPReqs = UTIL_UnitTestData_TEST.getMultipleTestPlanRequirements(2); 
        childrenPReqs[0].Plan_Requirement__c = parentPReqs[0].Id;
        childrenPReqs[1].Plan_Requirement__c = parentPReqs[1].Id;
        insert childrenPReqs; 

        Test.startTest(); 
        Database.DeleteResult[] results = Database.delete(parentPReqs, false);
        Test.stopTest();

        //Verify Plan Requirement was not successfully deleted
        List<Plan_Requirement__c> returnParentPReqs = [SELECT ID
                                                       FROM Plan_Requirement__c
                                                       WHERE ID IN :parentPReqs];
        System.assertEquals(2, returnParentPReqs.size());
        System.assertEquals(false, results[0].success);
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }
    
    /*********************************************************************************************************
    * @description Test method to test if Prevent_Plan_Requirement_Deletion__c is enabled in Hierarchy Settings, 
    * and if some Plan Requirement records do not have Plan Requirement child records, then the Plan Requirement
    * record can be deleted. 
    */
    @isTest
    public static void pReqCanDeleteSomePlanRequirement() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = bizAccRecordTypeId,
                                                          Prevent_Plan_Requirement_Deletion__c = TRUE));
        
        List<Program_Plan__c> pPlans = UTIL_UnitTestData_TEST.getMultipleTestProgramPlans(1);
        insert pPlans;
        
        List<Plan_Requirement__c> parentPReqs = UTIL_UnitTestData_TEST.getMultipleTestPlanRequirements(2);
        insert parentPReqs; 
       
        List<Plan_Requirement__c> childrenPReqs = UTIL_UnitTestData_TEST.getMultipleTestPlanRequirements(2); 
        childrenPReqs[0].Plan_Requirement__c = parentPReqs[0].Id;
        insert childrenPReqs; 

        Test.startTest(); 
        Database.DeleteResult[] results = Database.delete(parentPReqs, false);
        Test.stopTest();

        //Verify Plan Requirement was not successfully deleted
        List<Plan_Requirement__c> returnParentPReqs = [SELECT ID
                                                       FROM Plan_Requirement__c
                                                       WHERE ID IN :parentPReqs];
        
        System.assertEquals(1, returnParentPReqs.size());
        System.assertEquals(true, results[1].success);
        System.assertEquals(false, results[0].success);
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
    }
    
    /*********************************************************************************************************
    * @description Test method to test if Prevent_Plan_Requirement_Deletion__c is disabled in Hierarchy Settings, 
    * and Plan Requirement has a Plan Requirement record associated to it, then it can be deleted.
    */
    @isTest
    public static void pReqCanDeleteWithPlanRequirement() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Account_Processor__c = bizAccRecordTypeId,
                                                          Prevent_Plan_Requirement_Deletion__c = FALSE));
        
        List<Program_Plan__c> pPlans = UTIL_UnitTestData_TEST.getMultipleTestProgramPlans(1);
        insert pPlans;
        
        List<Plan_Requirement__c> parentPReqs = UTIL_UnitTestData_TEST.getMultipleTestPlanRequirements(2); 
        insert parentPReqs; 
        
        List<Plan_Requirement__c> childrenPReqs = UTIL_UnitTestData_TEST.getMultipleTestPlanRequirements(2); 
        childrenPReqs[0].Plan_Requirement__c = parentPReqs[0].Id;
        childrenPReqs[1].Plan_Requirement__c = parentPReqs[1].Id;
        insert childrenPReqs; 

        Test.startTest(); 
        Database.DeleteResult[] results = Database.delete(parentPReqs, false);
        Test.stopTest();

        //Verify Plan Requirement was not successfully deleted
        List<Plan_Requirement__c> returnParentPReqs = [SELECT ID
                                                       FROM Plan_Requirement__c
                                                       WHERE ID IN :parentPReqs];
        System.assertEquals(0, returnParentPReqs.size());
        System.assertEquals(true, results[0].success);
    }
}