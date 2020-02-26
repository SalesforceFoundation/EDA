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
* @group Behavior Involvement
* @group-content ../../ApexDocContent/BehaviorInvolvement.htm
* @description Stops a Behavior Involvement from being deleted if has any Behavior Response child record. 
*/
public with sharing class BEH_CannotDelete_TDTM extends TDTM_Runnable{
    /*******************************************************************************************************
    * @description Get the setting of preventing behavior involvement deletion
    */
    private static Boolean enabledPreventBehaviorInvolvementDeletion = UTIL_CustomSettingsFacade.getSettings().Prevent_Behavior_Involvement_Deletion__c;
    
    /*******************************************************************************************************
     * @description Stops a Behavior Involvement from being deleted
     * if it has any associated Behavior Response. 
     * @param listNew the list of Behavior Involvement from trigger new.
     * @param listOld the list of Behavior Involvement from trigger old.
     * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
     * @param objResult the describe for Behavior Involvement
     * @return dmlWrapper.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
      
        if (!enabledPreventBehaviorInvolvementDeletion) {
            return new DmlWrapper();
        }
        
        Map<Id, Behavior_Involvement__c> oldMap = new Map<Id, Behavior_Involvement__c>((List<Behavior_Involvement__c>)oldList);
        
        if (triggerAction == TDTM_Runnable.Action.BeforeDelete) {
            for (Behavior_Involvement__c beh : [SELECT Id,
                                                   (SELECT Id FROM Behavior_Responses__r LIMIT 1)
                                                 FROM Behavior_Involvement__c
                                                WHERE Id IN :oldlist]) 
            {
                if (hasChildRecords(beh)) {
                    Behavior_Involvement__c behInContext = oldmap.get(beh.Id);
                    behInContext.addError(Label.CannotDelete);
                }
            }
        }
        return new DmlWrapper();
    }
    
   /*******************************************************************************************************
   * @description Evaluates whether the Behavior Involvement has any child related records.
   * @param beh is the current Behavior Involvement record.
   * @return Boolean.
   ********************************************************************************************************/
   private static Boolean hasChildRecords(Behavior_Involvement__c beh) {
        return (beh.Behavior_Responses__r.size() > 0); 
   }
}