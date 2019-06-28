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
* @description Ensure that child plan requirement does not have program plan associated
*/
public with sharing class PREQ_PreventPPlanParent_TDTM extends TDTM_Runnable {
    /*******************************************************************************************************
    * @description If unique Program Plan for plan requirements validation enabled.
    */
    private static boolean stgUniqueProgramPlanEnabled = UTIL_CustomSettingsFacade.getSettings().Validate_Program_Plan_for_Nested_PR__c;

    /*******************************************************************************************************
    * @description Display an error when populating program plan on a child plan requirement
    * @param listNew the list of Plan Requirement from trigger new.
    * @param listOld the list of Plan Requirement from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Plan Requirement
    * @return dmlWrapper.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
            TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        List<Plan_Requirement__c> planReqs = (List<Plan_Requirement__c>)newlist;
                
        if (triggerAction == TDTM_Runnable.Action.AfterInsert
            || triggerAction == TDTM_Runnable.Action.AfterUpdate) {
            for (Plan_Requirement__c planReq : planReqs) {
                if (stgUniqueProgramPlanEnabled == true
                        && planReq.Plan_Requirement__c != null
                        && planReq.Program_Plan__c != null) {
                    //throw an error
                    throw new ERR_ExceptionHandler.NestedPlanRequirementPPException(Label.nestedPlanRequirementPPExp);
                }
            }
        }
        return new DmlWrapper();
    }
}