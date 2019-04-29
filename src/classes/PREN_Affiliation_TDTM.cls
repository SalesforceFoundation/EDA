/*
    Copyright (c) 2014, Salesforce.org
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
* @date 2015
* @group Program Enrollment
* @group-content ../../ApexDocContent/ProgramEnrollments.htm
* @description Keeps Program Enrollment and Affiliation records for a Contact in sync.
*/
public class PREN_Affiliation_TDTM extends TDTM_Runnable {

    /*******************************************************************************************************
    * @description Handles Affiliation management for Program Enrollment.
    * @param listNew the list of Accounts from trigger new. 
    * @param listOld the list of Accounts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Program Enrollment. 
    * @return dmlWrapper.  
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
    
        DmlWrapper dmlWrapper = new DmlWrapper();

        if(newlist != null && newlist.size() > 0) {
            createRelatedAffls(newlist, triggerAction);
        }
        
        if(oldlist != null && oldlist.size() > 0) {
            updateDeleteRelatedAffls(getDeletedPEsAfflIDs(oldlist, triggerAction), oldlist, dmlWrapper);
        }
        
        return dmlWrapper;
    }

    private void createRelatedAffls(List<SObject> newlist, TDTM_Runnable.Action triggerAction) {
        List<Affiliation__c> newAffls = new List<Affiliation__c>();

        for (SObject so : newlist) {
            Program_Enrollment__c enrollment = (Program_Enrollment__c)so;

            if (triggerAction == TDTM_Runnable.Action.BeforeInsert) {
                //Automatically create an Affiliation record if a Program Enrollment record has been created without an affiliation.
                if(enrollment.Contact__c != null && enrollment.Account__c != null && enrollment.Affiliation__c == null) {
                    Date afflEndDate = (UTIL_CustomSettingsFacade.getSettings().Affl_ProgEnroll_Copy_End_Date__c == true ? enrollment.End_Date__c : null);
                    Date afflStartDate = (UTIL_CustomSettingsFacade.getSettings().Affl_ProgEnroll_Copy_Start_Date__c == true ? enrollment.Start_Date__c : null);
                    String afflRole = (UTIL_CustomSettingsFacade.getSettings().Affl_ProgEnroll_Set_Role__c == true ? UTIL_CustomSettingsFacade.getSettings().Affl_ProgEnroll_Role_Map__c : null);

                    Affiliation__c affl = new Affiliation__c(Contact__c = enrollment.Contact__c,
                                                            Account__c = enrollment.Account__c,
                                                            EndDate__c = afflEndDate,
                                                            StartDate__c = afflStartDate,
                                                            Status__c = UTIL_CustomSettingsFacade.getSettings().Affl_ProgEnroll_Status_Map__c,
                                                            Role__c = afflRole);
                    newAffls.add(affl);
                }
            }
        }
        
        if(newAffls.size() > 0) {
            //Turn off AFFL_MultiRecordType_TDTM_After_Insert so EDA won't create duplicate program enrollment
            TDTM_ProcessControl.turnOffRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_MultiRecordType_TDTM_After_Insert);
            //We manually insert the affiliations because we need the IDs, in order to link the Program Enrollments with the Affls.
            insert newAffls;
            
            for(Integer i = 0; i < newAffls.size(); i++) {
                Program_Enrollment__c enrollment = (Program_Enrollment__c)newlist[i];
                enrollment.Affiliation__c = newAffls[i].ID;
            }
            //We don't need to add these enrollment records to dmlWrapper because we are in BeforeInsert.
        }
    }
    
    private List<ID> getDeletedPEsAfflIDs(List<SObject> oldlist, TDTM_Runnable.Action triggerAction) {
        List<ID> afflsToUpdateDelIDs = new List<ID>();
        //Only need to loop through the list when deleting Program Enrollment records
        if(triggerAction == TDTM_Runnable.Action.AfterDelete) {  
            
            for (SObject so : oldlist) {            
                Program_Enrollment__c oldEnrollment = (Program_Enrollment__c)so;
                
                if(oldEnrollment.Affiliation__c != null) {
                    //Get related Affls ids
                    afflsToUpdateDelIDs.add(oldEnrollment.Affiliation__c);
                }
            }
            
        }
        return afflsToUpdateDelIDs;
    }
    
    private void updateDeleteRelatedAffls(List<ID> afflsToUpdateDelIDs, List<SObject> oldlist, DmlWrapper dmlWrapper) {
        //Delete or update related affiliations when Program Enrollment records are deleted.
        List<Affiliation__c> afflsToUpdateDel = new List<Affiliation__c>();
        
        List<Program_Enrollment__c> otherProgramEnrollments = [SELECT Id, Affiliation__c FROM Program_Enrollment__c WHERE Affiliation__c IN :afflsToUpdateDelIDs AND Id NOT IN :oldList];
        Set<Id> affiliationIdsToIgnore = new Set<Id>();
        
        for(Program_Enrollment__c otherProgramEnrollment : otherProgramEnrollments) {
            affiliationIdsToIgnore.add(otherProgramEnrollment.Affiliation__c);
        }
        
        if(UTIL_CustomSettingsFacade.getSettings().Affl_ProgEnroll_Del__c) {
            
            for(ID affiliationId : afflsToUpdateDelIDs) {
                //Only delete the Affiliation if there are no other Program Enrollment records associated to it.
                if (!affiliationIdsToIgnore.contains(affiliationId)) {
                    afflsToUpdateDel.add(new Affiliation__c(ID = affiliationId));
                }
            }
            
            dmlWrapper.objectsToDelete.addAll((List<SObject>)afflsToUpdateDel);
        } else {
            String affiliationStatusOnPEDelete = UTIL_CustomSettingsFacade.getSettings().Affl_ProgEnroll_Del_Status__c;
            List<Affiliation__c> potentialAffiliationsToUpdate = [SELECT Id, Status__c FROM Affiliation__c WHERE ID IN :afflsToUpdateDelIDs];
            
            for(Affiliation__c affl : potentialAffiliationsToUpdate) {
                //Only update the Affiliation if there are no other Program Enrollment records associated to it.
                if (!affiliationIdsToIgnore.contains(affl.Id)) {
                    affl.Status__c = affiliationStatusOnPEDelete;
                    afflsToUpdateDel.add(affl);
                }
            }
            
            dmlWrapper.objectsToUpdate.addAll((List<SObject>)afflsToUpdateDel);
        }
    }
}
