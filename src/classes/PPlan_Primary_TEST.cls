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
* @description Testing for the Primary Program Plan.
*/
@IsTest
private class PPlan_Primary_TEST {
    /*********************************************************************************************************
    * @description Set other program plans as non-primary
    * when a program plan is set as primary
    */
    @IsTest
    static void setOtherProgramPlanNonPrimaryUpdate() {
        List<Account> accts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe.getAdminAccRecTypeID());
        insert accts[0];

        List<Program_Plan__c> pPlans = UTIL_UnitTestData_TEST.getMultipleTestProgramPlans(3);
        for (Program_Plan__c pPlan : pPlans) {
            pPlan.Account__c = accts[0].Id;
        }
        insert pPlans;

        pPlans[0].Is_Primary__c = true;
        update pPlans[0];

        Test.startTest();
        pPlans[1].Is_Primary__c = true;
        update pPlans[1];
        Test.stopTest();

        //assert
        List<Program_Plan__c> assertProgramPlans = [SELECT Is_Primary__c FROM Program_Plan__c where Account__c = :accts[0].Id];
        for (Program_Plan__c pPlan : assertProgramPlans) {
            if (pPlan.Id != pPlans[1].Id) {
                system.assertEquals(false, pPlan.Is_Primary__c);
            }else {
                system.assertEquals(true, pPlan.Is_Primary__c);
            }
        }
    }

    /*********************************************************************************************************
     * @description Set other program plans as non-primary
     * when a new program plan is inserted and set as primary
     */
    @IsTest
    static void setOtherProgramPlanNonPrimaryInsert() {
        List<Account> accts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe.getAdminAccRecTypeID());
        insert accts[0];

        List<Program_Plan__c> pPlans = UTIL_UnitTestData_TEST.getMultipleTestProgramPlans(3);
        for (Program_Plan__c pPlan : pPlans) {
            pPlan.Account__c = accts[0].Id;
        }
        insert pPlans;

        pPlans[0].Is_Primary__c = true;
        update pPlans[0];

        Test.startTest();
        Program_Plan__c newPPlan = UTIL_UnitTestData_TEST.getProgramPlan();
        newPPlan.Account__c = accts[0].Id;
        newPPlan.Is_Primary__c = true;
        insert newPPlan;
        Test.stopTest();

        //assert
        List<Program_Plan__c> assertProgramPlans = [SELECT Is_Primary__c FROM Program_Plan__c where Account__c = :accts[0].Id];
        for (Program_Plan__c pPlan : assertProgramPlans) {
            if (pPlan.Id != newPPlan.Id) {
                system.assertEquals(false, pPlan.Is_Primary__c);
            }else {
                system.assertEquals(true, pPlan.Is_Primary__c);
            }
        }
    }

    /*********************************************************************************************************
     * @description Set other program plans as non-primary
     * when a program plan is set as primary and linked to the account
     */
    @IsTest
    static void setOtherProgramPlanNonPrimaryLinkToAccount() {
        List<Account> accts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe.getAdminAccRecTypeID());
        insert accts[0];

        List<Program_Plan__c> pPlans = UTIL_UnitTestData_TEST.getMultipleTestProgramPlans(3);
        for (Program_Plan__c pPlan : pPlans) {
            pPlan.Account__c = accts[0].Id;
        }
        insert pPlans;

        pPlans[0].Is_Primary__c = true;
        update pPlans[0];

        Test.startTest();
        Program_Plan__c newPPlan = UTIL_UnitTestData_TEST.getProgramPlan();
        newPPlan.Is_Primary__c = true;
        insert newPPlan;
        newPPlan.Account__c = accts[0].Id;
        update newPPlan;
        Test.stopTest();

        //assert
        List<Program_Plan__c> assertProgramPlans = [SELECT Is_Primary__c FROM Program_Plan__c where Account__c = :accts[0].Id];
        for (Program_Plan__c pPlan : assertProgramPlans) {
            if (pPlan.Id != newPPlan.Id) {
                system.assertEquals(false, pPlan.Is_Primary__c);
            }else {
                system.assertEquals(true, pPlan.Is_Primary__c);
            }
        }
    }
	
	/*********************************************************************************************************
     * @description Confirm Program Plan Status is set to "Current"
     * if program plan is set as Primary on insert
     */
    @IsTest
	static void setProgramPlanStatusToCurrentIfPrimary_Insert() {
		List<Account> accts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe.getAdminAccRecTypeID());
        insert accts[0];

        List<Program_Plan__c> pPlans = UTIL_UnitTestData_TEST.getMultipleTestProgramPlans(3);
        for (Program_Plan__c pPlan : pPlans) {
            pPlan.Account__c = accts[0].Id;
			pplan.Status__c = PPlan_Primary_TDTM.STATUS_ARCHIVED_VAL;
        }
		
		pplans[0].Is_Primary__c = true;

        insert pPlans;
		
		List<Program_Plan__c> assertProgramPlans = [SELECT Is_Primary__c, Status__c FROM Program_Plan__c where Account__c = :accts[0].Id];
        Integer cntPrimary = 0;
		for (Program_Plan__c pPlan : assertProgramPlans) {
            if (pPlan.Is_Primary__c) {
                System.assertEquals(PPlan_Primary_TDTM.STATUS_CURRENT_VAL, pPlan.Status__c);
				cntPrimary++;
            }else {
                system.assertEquals(PPlan_Primary_TDTM.STATUS_ARCHIVED_VAL, pPlan.Status__c);
            }
        }
		System.assertEquals (1, cntPrimary, 'One and only one primary program plan expected');
	}
	
	/*********************************************************************************************************
     * @description Confirm Program Plan Status is set to "Current"
     * if program plan is set as Primary on Update
     */
    @IsTest
	static void setProgramPlanStatusToCurrentIfPrimary_Update() {
		List<Account> accts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe.getAdminAccRecTypeID());
        insert accts[0];

        List<Program_Plan__c> pPlans = UTIL_UnitTestData_TEST.getMultipleTestProgramPlans(3);
        for (Program_Plan__c pPlan : pPlans) {
            pPlan.Account__c = accts[0].Id;
			pplan.Status__c = PPlan_Primary_TDTM.STATUS_ARCHIVED_VAL;
        }
		
        insert pPlans;

		List<Program_Plan__c> assertProgramPlans = [SELECT Is_Primary__c, Status__c FROM Program_Plan__c where Account__c = :accts[0].Id];
        
		for (Program_Plan__c pPlan : assertProgramPlans) {
			System.assertEquals (PPlan_Primary_TDTM.STATUS_ARCHIVED_VAL, pPlan.Status__c);
		}
		
		pPlans[0].Is_Primary__c = true;
		update pPlans;
		
		assertProgramPlans = [SELECT Is_Primary__c, Status__c FROM Program_Plan__c where Account__c = :accts[0].Id];
        Integer cntPrimary = 0;
		for (Program_Plan__c pPlan : assertProgramPlans) {
            if (pPlan.Is_Primary__c) {
                System.assertEquals(pPlans[0].Id, pPlan.Id);
				System.assertEquals(PPlan_Primary_TDTM.STATUS_CURRENT_VAL, pPlan.Status__c);
				cntPrimary++;
            }else {
                system.assertEquals(PPlan_Primary_TDTM.STATUS_ARCHIVED_VAL, pPlan.Status__c);
            }
        }
		System.assertEquals (1, cntPrimary, 'One and only one primary program plan expected');
	}
    
}