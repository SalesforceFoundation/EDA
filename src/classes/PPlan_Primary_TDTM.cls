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
* @group ProgramPlan
* @group-content ../../ApexDocContent/ProgramPlans.htm
* @description Handles primary program plans under accounts
*/
public with sharing class PPlan_Primary_TDTM extends TDTM_Runnable {
   
    /*******************************************************************************************************
    * @description The Plan status value of Current.
    */
    @testVisible private static final String STATUS_CURRENT_VAL = 'Current';
	@testVisible private static final String STATUS_ARCHIVED_VAL = 'Archived';
   
    /*******************************************************************************************************
    * @description Handles primary program plans.
    * @param listNew the list of Accounts from trigger new.
    * @param listOld the list of Accounts from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Accounts
    * @return dmlWrapper.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        DmlWrapper dmlWrapper = new DmlWrapper();

        Set<Id> acccountIdsNeedNonPrimarycount = new Set<Id>();
        Set<Id> primaryProgramIds = new Set<Id>();
        // BEFORE INSERT
        if ( newlist != null && triggerAction == TDTM_Runnable.Action.BeforeInsert && !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.PPlan_Primary_TDTM_Before_Insert)) {
            for (integer i=0; i<newlist.size(); i++) {
                Program_Plan__c newPPlan = (Program_Plan__c)newlist[i];
                if (newPPlan.Is_Primary__c == true) {
                    // Make Plan "Current" if "Is Primary" is checked.
					newPPlan.Status__c = STATUS_CURRENT_VAL;
                }
            }
        }
        // AFTER INSERT
        if ( newlist != null && triggerAction == TDTM_Runnable.Action.AfterInsert && !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.PPlan_Primary_TDTM_After_Insert)) {
            for (integer i=0; i<newlist.size(); i++) {
                Program_Plan__c newPPlan = (Program_Plan__c)newlist[i];
                if (newPPlan.Is_Primary__c == true) {
                    //if multiple program plans under one single account are set as primary in same transation
                    //Use the first program plan as the primary
					if (!acccountIdsNeedNonPrimarycount.contains(newPPlan.Account__c)) {
                        primaryProgramIds.add(newPPlan.Id);
                    }
                    acccountIdsNeedNonPrimarycount.add(newPPlan.Account__c);
                }
            }
        }
 		// BEFORE UPDATE
        if ( newlist != null && triggerAction == TDTM_Runnable.Action.BeforeUpdate && !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.PPlan_Primary_TDTM_Before_Update)) {
           for (integer i=0; i<newlist.size(); i++) {
                Program_Plan__c newPPlan = (Program_Plan__c)newlist[i];
                Program_Plan__c oldPPlan = (Program_Plan__c)oldlist[i];
                if (newPPlan.Is_Primary__c == true&& newPPlan.Is_Primary__c != oldPPlan.Is_Primary__c) {
					// Make Plan "Current" if "Is Primary" is checked.
					newPPlan.Status__c = STATUS_CURRENT_VAL;
                }
            }

        }
		System.debug('Groucho');
        // AFTER UPDATE
        if ( newlist != null && triggerAction == TDTM_Runnable.Action.AfterUpdate && !TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.PPlan_Primary_TDTM_After_Update)) {
            for (integer i=0; i<newlist.size(); i++) {
                Program_Plan__c newPPlan = (Program_Plan__c)newlist[i];
                Program_Plan__c oldPPlan = (Program_Plan__c)oldlist[i];
                if (newPPlan.Is_Primary__c == true
                    && (newPPlan.Is_Primary__c != oldPPlan.Is_Primary__c
                        || newPPlan.Account__c != oldPPlan.Account__c)) {
					//if multiple program plans under one single account are set as primary in same transation
                    //Use the first program plan as the primary
                    if (!acccountIdsNeedNonPrimarycount.contains(newPPlan.Account__c)) {
                        primaryProgramIds.add(newPPlan.Id);
                    }
                    acccountIdsNeedNonPrimarycount.add(newPPlan.Account__c);
                }
            }
        }
        
        if (acccountIdsNeedNonPrimarycount.size()>0) {
            dmlWrapper.objectsToUpdate.addAll(makeOtherPPlanNotPrimary(acccountIdsNeedNonPrimarycount, primaryProgramIds));
        }
		
        if (triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.PPlan_Primary_TDTM_Before_Update, false);
        }else if (triggerAction == TDTM_Runnable.Action.BeforeInsert) {
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.PPlan_Primary_TDTM_Before_Insert, false);
        }else if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.PPlan_Primary_TDTM_After_Update, false);
        }else if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.PPlan_Primary_TDTM_After_Insert, false);
        }
        return dmlWrapper;
    }

    private List<Program_Plan__c> makeOtherPPlanNotPrimary(Set<Id> accountIdsNeedNonPrimary, Set<Id> primaryProgramIds) {
        List<Program_Plan__c> pPlansNeedNonPrimary = new List<Program_Plan__c>();
        for (Program_Plan__c pPlan : [SELECT Id,
                                            Is_Primary__c
                                    From Program_Plan__c
                                    WHERE Account__c IN :accountIdsNeedNonPrimary
                                        AND Id NOT IN :primaryProgramIds]) {
            pPlan.Is_Primary__c = false;
            pPlansNeedNonPrimary.add(pPlan);
        }
        return pPlansNeedNonPrimary;
    }
}