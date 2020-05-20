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
* @group Tests
* @group-content ../../ApexDocContent/Tests.htm
* @description Stops a Test from being deleted if it has any Test Score child records. 
*/
public with sharing class TST_CannotDelete_TDTM extends TDTM_runnable {

    /*******************************************************************************************************
    * @description Get the setting for Prevent Test Deletion
    */
    private static Boolean enabledPreventTestDeletion = UTIL_CustomSettingsFacade.getSettings().Prevent_Test_Deletion__c;

    /*******************************************************************************************************
    * @description Stops a Test from being deleted if it has any Test Score child records. 
    * @param newlist the list of Tests from trigger new. 
    * @param oldlist the list of Tests from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Tests 
    * @return DmlWrapper.  
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
    
        if (TST_CannotDelete_TDTM.enabledPreventTestDeletion == FALSE) {
            return new DmlWrapper(); 
        }
        
        Map<Id, Test__c> oldmap = new Map<Id, Test__c>((List<Test__c>)oldList);
        
        if (triggerAction == TDTM_Runnable.Action.BeforeDelete) {
            for (Test__c tst : [ SELECT Id, 
                                (SELECT Id FROM Test__c.Test_Scores__r LIMIT 1)
                                FROM Test__c WHERE Id IN :oldlist
                               ]) {
                
                if (this.hasChildRecords(tst)) {
                    Test__c testInContext = oldMap.get(tst.ID);
                    testInContext.addError(Label.CannotDelete);
                }
            }
        }
        return new DmlWrapper();
    }
    
    /*******************************************************************************************************
     * @description Evaluates whether the Test has any child (Test Score) related records.
     * @param tst is the current Test record.
     * @return Boolean.
     ********************************************************************************************************/
    @testVisible
    private Boolean hasChildRecords(Test__c tst) {
        return ( tst.Test_Scores__r.isEmpty() == FALSE ); 
    }
}
