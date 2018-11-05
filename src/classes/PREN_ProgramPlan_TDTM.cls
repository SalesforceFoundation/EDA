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
* @group Program Enrollment
* @group-content ../../ApexDocContent/ProgramEnrollments.htm
* @description Handles Program Enrollment and Program Plan.
*/
public with sharing class PREN_ProgramPlan_TDTM extends TDTM_Runnable{

    /*******************************************************************************************************
    * @description Handles Program Plan management for Program Enrollment.
    * @param listNew the list of Program Enrollments from trigger new.
    * @param listOld the list of Program Enrollments from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Program Enrollment.
    * @return dmlWrapper.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
            TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        DmlWrapper dmlWrapper = new DmlWrapper();

        //Before Insert
        if (triggerAction == TDTM_Runnable.Action.BeforeInsert) {
            if(newlist != null && newlist.size() > 0) {
                populatePrimaryProgramPlan(newlist);
            }
        }

        return dmlWrapper;
    }

    /*******************************************************************************************************
    * @description Populate primary program plan when a program enrollment is created
    * @param List<SObject> newList the Contact
    * @return void
    */
    private void populatePrimaryProgramPlan(List<SObject> newlist) {
        Set<Id> setAcademicProgramIds = new Set<Id>();
        Map<Id, Id> mapAcademicProgramIdToPrimaryPPId = new Map<Id, Id>();
        for (SObject so : newlist) {
            Program_Enrollment__c newPe = (Program_Enrollment__c)so;
            //Build a set of academic program ids
            setAcademicProgramIds.add(newPe.Account__c);
        }

        //Query academic program and build a map of
        //Academic Program id and Primary Program Plan id
        for (Program_Plan__c pp : [SELECT Id, Account__c
                                    FROM Program_Plan__c
                                    WHERE Account__c in :setAcademicProgramIds
                                        AND Is_Primary__c = TRUE]) {
            if (pp.Account__c != null) {
                mapAcademicProgramIdToPrimaryPPId.put(pp.Account__c, pp.Id);
            }
        }

        //Loop through program enrollment again and populate primary program plan
        for (SObject so : newlist) {
            Program_Enrollment__c newPe = (Program_Enrollment__c) so;
            if (mapAcademicProgramIdToPrimaryPPId.containsKey(newPe.Account__c)
                    && mapAcademicProgramIdToPrimaryPPId.get(newPe.Account__c) != null) {
                newPe.Program_Plan__c = mapAcademicProgramIdToPrimaryPPId.get(newPe.Account__c);
            }
        }
    }

}