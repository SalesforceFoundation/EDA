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
* @description Ensure that plan requirement always has the same program plan as its immediate parent has
*/
public with sharing class PREQ_UniqueProgramPlan_TDTM extends TDTM_Runnable {
    /*******************************************************************************************************
    * @description If unique Program Plan for plan requirements validation enabled.
    */
    private static boolean stgUniqueProgramPlanEnabled = UTIL_CustomSettingsFacade.getSettings().Unique_Program_Plan_Enforced__c;

    /*******************************************************************************************************
    * @description Populate an error when creating a Plan Requirement or updating a plan requirement who has
    * different program as its immediate parent plan requirement has
    * @param listNew the list of Plan Requirement from trigger new.
    * @param listOld the list of Plan Requirement from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Plan Requirement
    * @return dmlWrapper.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
            TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        if (triggerAction == TDTM_Runnable.Action.AfterInsert
            || triggerAction == TDTM_Runnable.Action.AfterUpdate) {
            for (Plan_Requirement__c planReq : [SELECT ID,
                                                    Program_Plan__c,
                                                    Plan_Requirement__c,
                                                    Plan_Requirement__r.Program_Plan__c
                                                FROM Plan_Requirement__c
                                                WHERE ID in :newlist]) {
                if (stgUniqueProgramPlanEnabled == true
                        && planReq.Plan_Requirement__r.Program_Plan__c != null
                        && planReq.Plan_Requirement__c != null
                        && planReq.Program_Plan__c != planReq.Plan_Requirement__r.Program_Plan__c) {
                    //throw an error
                    throw new ERR_ExceptionHandler.UniqueProgramPlanException(Label.uniqueProgramPlanExp);
                }
            }
        }
        return new DmlWrapper();
    }
}