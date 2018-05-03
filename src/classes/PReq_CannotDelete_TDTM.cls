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
* @description Stops an Plan Requirement from being deleted if it has any child Plan Requirement
*/
public with sharing class PReq_CannotDelete_TDTM extends TDTM_Runnable {
    /*******************************************************************************************************
    * @description Stops an Plan Requirement from being deleted if it has any child Plan Requirement
    * @param listNew the list of Plan Requirement from trigger new.
    * @param listOld the list of Plan Requirement from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Plan Requirement
    * @return dmlWrapper.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        Map<ID, SObject> oldmap = new Map<ID, SObject>(oldlist);

        if (triggerAction == TDTM_Runnable.Action.BeforeDelete) {
            for (Plan_Requirement__c planReq : [SELECT ID,
                                                        (SELECT ID FROM Plan_Requirements__r)
                                                    FROM Plan_Requirement__c
                                                    WHERE ID in :oldlist]) {
                if(planReq.Plan_Requirements__r.size() > 0 ) {
                    Plan_Requirement__c planReqInContext = (Plan_Requirement__c)oldmap.get(planReq.ID);
                    planReqInContext.addError(Label.CannotDelete);
                }
            }
        }
        return new DmlWrapper();
    }
}