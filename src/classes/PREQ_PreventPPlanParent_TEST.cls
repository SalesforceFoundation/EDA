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
* @group Plan Requirement
* @group-content ../../ApexDocContent/PlanRequirements.htm
* @description Tests for PREQ_PreventPPlanParent_TDTM.
*/
@isTest
private class PREQ_PreventPPlanParent_TEST {

    @isTest
    public static void pReqInsertChildPRWithSamePP() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Unique_Program_Plan_Enforced__c = true));

        List<Program_Plan__c> pPlans = UTIL_UnitTestData_TEST.getMultipleTestProgramPlans(2);
        insert pPlans;

        List<Plan_Requirement__c> prs = UTIL_UnitTestData_TEST.getMultipleTestPlanRequirements(2);
        prs[0].Program_Plan__c = pPlans[0].Id;
        insert prs[0];

        Test.startTest();
        prs[1].Plan_Requirement__c = prs[0].Id;
        prs[1].Program_Plan__c = pPlans[0].Id;
        Database.saveResult results = Database.insert(prs[1], false);
        Test.stopTest();

        //Verify new plan requirement is not saved
        List<Plan_Requirement__c> assertPReqs = [select ID from Plan_Requirement__c];
        System.assertEquals(1, assertPReqs.size());

        System.assertEquals(false, results.success);
        System.assertEquals(Label.uniqueProgramPlanExp, results.errors[0].message);
    }

    public static void pReqInsertChildPRWithDifferentPP() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Unique_Program_Plan_Enforced__c = true));

        List<Program_Plan__c> pPlans = UTIL_UnitTestData_TEST.getMultipleTestProgramPlans(2);
        insert pPlans;

        List<Plan_Requirement__c> prs = UTIL_UnitTestData_TEST.getMultipleTestPlanRequirements(2);
        prs[0].Program_Plan__c = pPlans[0].Id;
        insert prs[0];

        Test.startTest();
        prs[1].Plan_Requirement__c = prs[0].Id;
        prs[1].Program_Plan__c = pPlans[1].Id;
        Database.saveResult results = Database.insert(prs[1], false);
        Test.stopTest();

        //Verify new plan requirement is not saved
        List<Plan_Requirement__c> assertPReqs = [select ID from Plan_Requirement__c];
        System.assertEquals(1, assertPReqs.size());

        System.assertEquals(false, results.success);
        System.assertEquals(Label.uniqueProgramPlanExp, results.errors[0].message);
    }

    @isTest
    public static void pReqUpdateChildPRWithSamePP() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Unique_Program_Plan_Enforced__c = true));

        List<Program_Plan__c> pPlans = UTIL_UnitTestData_TEST.getMultipleTestProgramPlans(2);
        insert pPlans;

        List<Plan_Requirement__c> prs = UTIL_UnitTestData_TEST.getMultipleTestPlanRequirements(2);
        prs[0].Program_Plan__c = pPlans[0].Id;
        insert prs[0];
        prs[1].Plan_Requirement__c = prs[0].Id;
        insert prs[1];

        Test.startTest();
        prs[1].Program_Plan__c = pPlans[0].Id;
        Database.saveResult results = Database.update(prs[1], false);
        Test.stopTest();

        //Verify new plan requirement is not saved
        List<Plan_Requirement__c> assertPReqs = [SELECT ID,Program_Plan__c
                                                FROM Plan_Requirement__c
                                                WHERE ID = :prs[1].Id
                                                LIMIT 1];
        System.assertEquals(null, assertPReqs[0].Program_Plan__c);
        System.assertEquals(false, results.success);
        System.assertEquals(Label.uniqueProgramPlanExp, results.errors[0].message);
    }

    @isTest
    public static void pReqUpdateChildPRWithDifferentPP() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Unique_Program_Plan_Enforced__c = true));

        List<Program_Plan__c> pPlans = UTIL_UnitTestData_TEST.getMultipleTestProgramPlans(2);
        insert pPlans;

        List<Plan_Requirement__c> prs = UTIL_UnitTestData_TEST.getMultipleTestPlanRequirements(2);
        prs[0].Program_Plan__c = pPlans[0].Id;
        insert prs[0];
        prs[1].Plan_Requirement__c = prs[0].Id;
        insert prs[1];

        Test.startTest();
        prs[1].Program_Plan__c = pPlans[1].Id;
        Database.saveResult results = Database.update(prs[1], false);
        Test.stopTest();

        //Verify new plan requirement is not saved
        List<Plan_Requirement__c> assertPReqs = [SELECT ID,Program_Plan__c
                                                FROM Plan_Requirement__c
                                                WHERE ID = :prs[1].Id
                                                LIMIT 1];
        System.assertEquals(null, assertPReqs[0].Program_Plan__c);
        System.assertEquals(false, results.success);
        System.assertEquals(Label.uniqueProgramPlanExp, results.errors[0].message);
    }
}