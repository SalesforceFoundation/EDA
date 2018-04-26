/*
    Copyright (c) 2016, Salesforce.org
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
* @group-content ../../ApexDocContent/ProgramPlan.htm
* @description Tests for PPlan_CannotDelete_TDTM.
*/
@isTest
public with sharing class PPlan_CannotDelete_TEST {

    @isTest
    public static void pPlanCannotDeleteWithPlanRequirement() {
        List<Program_Plan__c> pPlans = new List<Program_Plan__c>();
        Program_Plan__c pPlan = new Program_Plan__c(Name='pp test');
        pPlans.add(pPlan);
        insert pPlans;

        List<Plan_Requirement__c> prs = new List<Plan_Requirement__c>();
        Plan_Requirement__c pr1 = new Plan_Requirement__c(Name='pr test 1', Program_Plan__c = pPlan.Id);
        prs.add(pr1);
        Plan_Requirement__c pr2 = new Plan_Requirement__c(Name='pr test 2', Program_Plan__c = pPlan.Id);
        prs.add(pr2);
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
}