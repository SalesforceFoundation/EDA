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
* @group Terms
* @group-content ../../ApexDocContent/Terms.htm
* @description This class prevents Term records from being deleted if it has any Term Grade associations. 
*/
public with sharing class TERM_CannotDelete_TDTM extends TDTM_Runnable {
    /*******************************************************************************************************
    * @description Prevents Term records from being deleted if it has any Term Grade associations.   
    * @param newList the list of Terms from trigger new. 
    * @param oldList the list of Terms from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).  
    * @param objResult the describe for Terms
    * @return dmlWrapper.  
    ********************************************************************************************************/
     public override DmlWrapper run(List<SObject> newList, List<SObject> oldList, 
     TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        Map<ID, Term__c> oldmap = new Map<ID, Term__c>((List<Term__c>)oldlist);

        if (triggerAction == TDTM_Runnable.Action.BeforeDelete) {
            for (Term__c term : [SELECT Id, (SELECT Id FROM Term_Grades__r LIMIT 1) FROM Term__c WHERE Id IN :oldlist]) {
                if (term.Term_Grades__r.size() > 0) {
                    Term__c termInContext = oldmap.get(term.Id);
                    termInContext.addError(Label.CannotDeleteTerm);
                }
            }
        }
        return new DmlWrapper();
    }
}