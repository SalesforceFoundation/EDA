/*
    Copyright (c) 2016, Salesforce.org
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
* @date 2016
* @group Affiliations
* @description Handles the Account in a primary Affiliation being changed or cleared. 
*/
public with sharing class AFFL_AccChange_TDTM extends TDTM_Runnable {

    /*******************************************************************************************************
    * @description Static flags to prevent recursive call.
    ********************************************************************************************************/
    public static boolean afflAccChangeAlreadyRun = false;    

    /*******************************************************************************************************
    * @description Handles Affiliation management.
    * @param listNew the list of Accounts from trigger new. 
    * @param listOld the list of Accounts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Accounts 
    * @return dmlWrapper.  
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        DmlWrapper dmlWrapper = new DmlWrapper();
         
        if(!afflAccChangeAlreadyRun) {
            
            AFFL_MultiRecordType_TDTM afflMulti = new AFFL_MultiRecordType_TDTM(); 
        
            if(newlist != null && newlist.size() > 0) {
                Integer i = 0;
                for (SObject so : newlist) {
                   Affiliation__c affl = (Affiliation__c)so;
                   String lookupFieldLabel = AFFL_MultiRecordType_TDTM.afflMapper.mapAccRecTypeToContactLabel.get(affl.Affiliation_Type__c);
                   String lookupFieldName = AFFL_MultiRecordType_TDTM.afflMapper.contactLabelNames.get(lookupFieldLabel);
                   
                   Affiliation__c afflOld;
                   String lookupFieldLabelOld, lookupFieldNameOld;
                   if(oldlist[i] != null) {
                       afflOld = (Affiliation__c)oldlist[i];
                       lookupFieldLabelOld = AFFL_MultiRecordType_TDTM.afflMapper.mapAccRecTypeToContactLabel.get(afflOld.Affiliation_Type__c);
                       lookupFieldNameOld = AFFL_MultiRecordType_TDTM.afflMapper.contactLabelNames.get(lookupFieldLabelOld);
                   }
               
                   //BEFORE UPDATE
                   if(triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
                       
                       //Query all the primary affiliation lookup fields on the contact - they are not available in the trigger.
                       Map<ID, Contact> relatedContactsMap;
                       Contact relatedContact;
                       if(newlist != null) {
                          relatedContactsMap = afflMulti.queryAfflLookupFields(newlist);
                          relatedContact = relatedContactsMap.get(affl.Contact__c);
                       }
                       
                       //ACCOUNT FIELD CHANGED
                       if(affl.Primary__c && affl.Account__c != null && afflOld.Account__c != null 
                       && affl.Account__c != afflOld.Account__c) {
                           
                           if(affl.Affiliation_Type__c == afflOld.Affiliation_Type__c) {
                               //If the primary affl now points to an Account of the same type, update the
                               //same primary field in Contact.
                               relatedContact.put(lookupFieldName, affl.Account__c);    
                           } else { 
                               //If the primary affl now points to an Account of different type, clear the old
                               //primary field in Contact and populate the matching new field.
                               relatedContact.put(lookupFieldNameOld, null);
                               relatedContact.put(lookupFieldName, affl.Account__c);
                           }
                           dmlWrapper.objectsToUpdate.add(relatedContact);
                           
                           //afflMulti.uncheckOtherPrimariesSameType(); --> we don't need to call this because 
                           //AFFL_MultiRecordType_TDTM will run after this class, and will take care of that.
                       }
                    
                       //ACCOUNT FIELD CLEARED - the matching primary field in Contact needs to be cleared.
                       if(affl.Primary__c && afflOld.Account__c != null && affl.Account__c == null) {
                           relatedContact.put(lookupFieldNameOld, null);
                           dmlWrapper.objectsToUpdate.add(relatedContact);
                       }
                   }
                   i++;
               }
           }
           afflAccChangeAlreadyRun = true;
        }
        return dmlWrapper;
    }
}