/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group Program Enrollment
* @group-content ../../ApexDocContent/ProgramEnrollment.htm
* @description Stops a Program Enrollment from being deleted if it has any Course Connection child records.
*/
public with sharing class PREN_CannotDelete_TDTM extends TDTM_Runnable {
    /*******************************************************************************************************
    * @description Get the setting of preventing Program Enrollment deletion
    */
    private static Boolean enabledPreventProgramEnrollmentDeletion = UTIL_CustomSettingsFacade.getSettings().Prevent_Program_Enrollment_Deletion__c;
    
    /*******************************************************************************************************
    * @description Stops a Program Enrollment from being deleted if it has any Course Connection 
    * child records.
    * @param listNew the list of Program Enrollment from trigger new.
    * @param listOld the list of Program Enrollment from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Program Enrollment
    * @return dmlWrapper.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        if (!PREN_CannotDelete_TDTM.enabledPreventProgramEnrollmentDeletion) {
            return new DmlWrapper(); 
        }

        Map<Id, Program_Enrollment__c> oldMap = new Map<Id, Program_Enrollment__c>((List<Program_Enrollment__c>)oldList);

        if (triggerAction == TDTM_Runnable.Action.BeforeDelete) {
            for (Program_Enrollment__c programEnrollment : [SELECT ID,
                                                            (SELECT ID FROM Program_Enrollment__c.Course_Enrollments__r LIMIT 1)
                                                            FROM Program_Enrollment__c
                                                            WHERE ID IN :oldlist])
            {
                if (this.hasChildRecords(programEnrollment)) {
                    Program_Enrollment__c programEnrollmentInContext = oldmap.get(programEnrollment.ID);
                    programEnrollmentInContext.addError(Label.CannotDelete);
                }
            }
        }

        return new DmlWrapper();
    }

    /*******************************************************************************************************
    * @description Evaluates whether the Program Enrollment has any child related records.
    * @param programEnrollment is the current Program Enrollment record.
    * @return Boolean.
    ********************************************************************************************************/
    @testVisible
    private Boolean hasChildRecords(Program_Enrollment__c programEnrollment) {
        return (!programEnrollment.Course_Enrollments__r.isEmpty());
    }
}