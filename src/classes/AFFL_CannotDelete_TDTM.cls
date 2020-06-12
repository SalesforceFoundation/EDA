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
* @group Affiliations
* @group-content ../../ApexDocContent/Affiliations.htm
* @description Stops an Affiliation from being deleted if it is associated with
* any child records. 
*/

public with sharing class AFFL_CannotDelete_TDTM extends TDTM_runnable {

    /*******************************************************************************************************
    * @description Get the setting for Prevent Affiliation Block Deletion
    */
    private static Boolean enabledPreventAffiliationDeletion = UTIL_CustomSettingsFacade.getSettings().Prevent_Affiliation_Deletion__c;
    
    /*******************************************************************************************************
    * @description Stops an Affiliation from being deleted if it has any child (Course Connection) records. 
    * @param newlist the list of Affiliations from trigger new. 
    * @param oldlist the list of Affiliations from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Affiliations. 
    * @return DmlWrapper.  
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        if (AFFL_CannotDelete_TDTM.enabledPreventAffiliationDeletion == FALSE) {
            return new DmlWrapper(); 
        }
        
        Map<Id, Affiliation__c> oldmap = new Map<Id, Affiliation__c>((List<Affiliation__c>)oldList);
        
        if (triggerAction == TDTM_Runnable.Action.BeforeDelete) {
            for (Affiliation__c affl : [ SELECT Id, 
                                            (SELECT Id FROM Course_Enrollment__r LIMIT 1)
                                         FROM Affiliation__c WHERE Id IN :oldlist
                                        ]) {
                
                if (this.hasChildRecords(affl)) {
                    Affiliation__c affiliationInContext = oldMap.get(affl.ID);
                    affiliationInContext.addError(Label.CannotDelete);
                }
            }     
        }
        
        return new DmlWrapper();
    }
    
    /*******************************************************************************************************
     * @description Evaluates whether the Affiliation has any child (Course Connection) related records.
     * @param affl is the current Affiliation record.
     * @return Boolean.
     ********************************************************************************************************/
    @testVisible
    private Boolean hasChildRecords(Affiliation__c affl) {
        return ( affl.Course_Enrollment__r.isEmpty() == FALSE ); 
    }
}
