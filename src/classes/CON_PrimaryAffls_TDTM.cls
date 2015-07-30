/*
    Copyright (c) 2014, Salesforce.com Foundation
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Salesforce.com Foundation nor the names of
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
* @author Salesforce.com Foundation
* @date 2015
* @group Program Enrollment
* @description Creates Affiliations when the user manually populates
* any of the primary affiliation lookup fields. 
*/
public with sharing class CON_PrimaryAffls_TDTM extends TDTM_Runnable {
    
    /*******************************************************************************************************
    * @description Handles primary affiliation fields.
    * @param listNew the list of Accounts from trigger new. 
    * @param listOld the list of Accounts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Accounts 
    * @return dmlWrapper.  
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        DmlWrapper dmlWrapper = new DmlWrapper();
        
        //Get the primary affiliation fields defined in the Affiliation Mappings
        List<String> primaryAfflFields = getPrimaryAfflFields();
        
        for (integer i=0; i<newlist.size();i++) {
            Contact con = (Contact)newlist[i];
            
        }
        
        return dmlWrapper;
    }
    
    private List<String> getPrimaryAfflFields() {
        List<Affl_Mappings__c> mappings = [select Primary_Affl_Field__c from Affl_Mappings__c];
        List<String> primaryAfflFields = new List<String>();
        for(Affl_Mappings__c mapping : mappings) {
            if(mapping.Primary_Affl_Field__c != null) {
                primaryAfflFields.add(mapping.Primary_Affl_Field__c);
            }
        }
        return primaryAfflFields;
    }
}