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
        
        List<Affiliation__c> afflsToInsert = new List<Affiliation__c>();
        //Map of Contact ID to list of Account IDs that represent key Affl fields that have been cleared.
        Map<ID, List<ID>> deletedContactAccsMap = new Map<ID, List<ID>>();
        //Map of Contact ID to Acc ID that is new primary. All other Affls of the same type for each Contact need to be made non-primary.
        Map<ID, ID> contactIdPrimaryAccIdMap = new Map<ID, ID>();
        
        //Get the primary affiliation fields defined in the Affiliation Mappings
        AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper(); 
        
        if(newlist != null) {
            for (integer i=0; i<newlist.size(); i++) {
                Contact newContact = (Contact)newlist[i];
                
                if(triggerAction == TDTM_Runnable.Action.AfterInsert) {
                    
                    //If the Contact has been created with one of the Key Affiliation fields populated 
                    //  --> Create a matching primary Affiliation for the Contact
                    for(Integer j = 0; j < afflMapper.primaryAfflFieldNames.size(); j++) {
                        try {
		                    if(newContact.get(afflMapper.primaryAfflFieldNames[j]) != null) {
		                        ID accID = (ID)newContact.get(afflMapper.primaryAfflFieldNames[j]);
		                        afflsToInsert.add(new Affiliation__c(Contact__c = newContact.ID, Account__c = accID, Primary__c = true)); //Role and Status?                            
		                    }
                        } catch(Exception e) {
                            UTIL_Debug.debug('****Exception message: ' + e.getMessage());
                            UTIL_Debug.debug('****Stack trace: \n' + e.getStackTraceString());
                            newContact.addError(e.getMessage());
                        }
                    }
                    
                } else if(triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
                    Contact oldContact = (Contact)oldlist[i];
                    
                    for(Integer j = 0; j < afflMapper.primaryAfflFieldNames.size(); j++) {
	                    try {
		                    //If any Key Affiliation field has been set
		                    //  --> Create a matching primary Affiliation for the Contact
		                    //  --> If another Affiliation to the same Account exists, it should be made not primary. But this is AFFL_MultiRecordType_TDTM's responsibility. 
		                    if(newContact.get(afflMapper.primaryAfflFieldNames[j]) != null && oldContact.get(afflMapper.primaryAfflFieldNames[j]) == null) {
		                        ID accID = (ID)newContact.get(afflMapper.primaryAfflFieldNames[j]);
		                        afflsToInsert.add(new Affiliation__c(Contact__c = newContact.ID, Account__c = accID, Primary__c = true)); //Role and Status? 
		                    }
		                    
		                    //If any Key Affiliation field has been changed to point to another Account
		                    //  --> Create new Affiliation (even if another one exists to the same Account - used should have made existing one primary if that was his intention)
		                    //  --> Make the old Affiliations non-primary
		                    if(newContact.get(afflMapper.primaryAfflFieldNames[j]) != null && newContact.get(afflMapper.primaryAfflFieldNames[j]) != oldContact.get(afflMapper.primaryAfflFieldNames[j])) {
                                ID accID = (ID)newContact.get(afflMapper.primaryAfflFieldNames[j]);
                                afflsToInsert.add(new Affiliation__c(Contact__c = newContact.ID, Account__c = accID, Primary__c = true)); //Role and Status? 
                                contactIdPrimaryAccIdMap.put(newContact.ID, accID);
                            }
		                    
		                    //If any Key Affiliation field has been cleared
		                    //  --> Make the matching Affiliation non-primary
	                        if(newContact.get(afflMapper.primaryAfflFieldNames[j]) == null && oldContact.get(afflMapper.primaryAfflFieldNames[j]) != null) {
                                List<ID> accIDs = deletedContactAccsMap.get(newContact.ID);
                                if(accIDs == null) {
                                    accIDs = new List<ID>();
                                }
                                accIDs.add((ID)oldContact.get(afflMapper.primaryAfflFieldNames[j]));
                                deletedContactAccsMap.put(newContact.ID, accIDs);
                            }
                            
	                    } catch(Exception e) {
                            newContact.addError('Field ' + afflMapper.primaryAfflFieldNames[j] + ' does not exist in Contact. Please review the Affiliation Mappings settings.');
                        }
                    }
                }
            }
        }
        
        if(afflsToInsert.size() > 0) {
            UTIL_Debug.debug('****Inserting ' + afflsToInsert.size() + ' affiliations.');
            dmlWrapper.objectsToInsert.addAll((List<SObject>)afflsToInsert);
        }
        if(deletedContactAccsMap.size() > 0) {
            for(ID contactID : deletedContactAccsMap.keySet()) {
                List<ID> clearedKeyAfflsAccIDs = deletedContactAccsMap.get(contactID);
                for(ID accID : clearedKeyAfflsAccIDs) {
                    //Find primary affiliation from this contact to this account --> NOT HERE, it needs to be bulk!!!
                    
                    //If one exists, make it non-primary
                }
            }
        }
        if(contactIdPrimaryAccIdMap.size() > 0) {
            //Find all the affiliations and make them non-primary
            List<Affiliation__c> afflsToMakeNonPrimary = [select Primary__c from Affiliation__c where Contact__c in :contactIdPrimaryAccIdMap.keySet() 
                                                            and Account__c in :contactIdPrimaryAccIdMap.values()];
        }
        return dmlWrapper;
    }
}