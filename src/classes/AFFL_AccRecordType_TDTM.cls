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
* @group Affiliations
* @description Supports changing the record type of an account.
*/
public class AFFL_AccRecordType_TDTM extends TDTM_Runnable {
	
	/*******************************************************************************************************
    * @description Updates key affiliation lookups on contact, and any other primary affiliation of the new type.
    * @return dmlWrapper
    ********************************************************************************************************/
	public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
    
    	 DmlWrapper dmlWrapper = new DmlWrapper();
    	 List<AccWithTypes> accsWithTypes = new List<AccWithTypes>();
 
    	 //When a user changes the record type of an Account, if that account was part of any primary affiliation:
         //   --> the key affl lookup field on the contacts needs to be updated
         //   --> other primary affiliations of the same NEW type need to be changed to not primary
                    
    	 if(newlist != null && newlist.size() > 0 && oldlist != null && oldlist.size() > 0) {
    	 	for (Integer i = 0; i < newlist.size(); i++) {
    	 	    SObject so = newlist[i];
    	 	    //AFTER UPDATE
    	 		if(triggerAction == TDTM_Runnable.Action.AfterUpdate) {
	    	 		Account acc = (Account)so;
			        Account oldAcc = (Account)oldList[i];

			        if(acc.RecordTypeId != oldAcc.RecordTypeId) {
			        	AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper(); 
			        	
			        	//Find the lookup field that matches the old record type
			        	String keyAfflFieldOldType = afflMapper.getKeyAfflFieldByAccRecordType(oldAcc.RecordTypeId);
			        	
			        	//Find the lookup field that matches the new record type
			        	String keyAfflFieldNewType = afflMapper.getKeyAfflFieldByAccRecordType(acc.RecordTypeId);
			        	
			        	accsWithTypes.add(new AccWithTypes(acc.ID, keyAfflFieldOldType, keyAfflFieldNewType));
			        }
    	 		}
		    }
		    
		    //Find all contacts that had a value in one of the primary affiliation fields of the type of the
            //accounts that have changed.
		    List<Contact> relatedContacts;
		    if(accsWithTypes.size() > 0) {
		        String relatedContactsQuery = 'select ID from Contact where ';
		        relatedContactsQuery += accsWithTypes[0].oldType + ' != null';
		        for(Integer i = 1; i < accsWithTypes.size(); i++) {
		            relatedContactsQuery += ' OR ' + accsWithTypes[i].oldType + ' != null';
                }
                UTIL_Debug.debug('****relatedContactsQuery: ' + relatedContactsQuery);
                relatedContacts = Database.query(relatedContactsQuery);
		    }

            //Replace primary affiliation fields in all contacts that need it.
            if(relatedContacts != null && relatedContacts.size() > 0) {
                List<ID> contactIDs = new List<ID>();
                List<ID> accountIDs = new List<ID>();
                
			    for(Contact contact : relatedContacts) {			        
			        for(AccWithTypes accWithTypes : accsWithTypes) {
			            if(!containsNew(accsWithTypes, accWithTypes.oldType)) {
			                UTIL_Debug.debug('****Setting primary field of type ' + accWithTypes.oldType + ' to null');
	                        contact.put(accWithTypes.oldType, null);
			            }
	                   UTIL_Debug.debug('****Setting primary field of type ' + accWithTypes.newType + ' to ' + accWithTypes.accId);
	                   contact.put(accWithTypes.newType, accWithTypes.accId);
	                   dmlWrapper.objectsToUpdate.add(contact);
	                   
	                   //Save the Contact ID and the Account ID of the Affiliation that has been made
	                   //primary so we can update all others of the same type for the same Contact and
	                   //make them not primary.
	                   contactIds.add(contact.ID);
	                   accountIds.add(accWithTypes.accId);
			        }
	            }
	            //Change all affiliations that are not primary any more
	            List<Affiliation__c> afflsMadePrimary = [select Contact__c, Account__c, Affiliation_Type__c 
	                      from Affiliation__c where Contact__c IN :contactIds and Account__c IN :accountIds];
	            AFFL_MultiRecordType_TDTM afflMulti = new AFFL_MultiRecordType_TDTM();
	            afflMulti.uncheckOtherPrimariesSameType(afflsMadePrimary, dmlWrapper);
            } 
    	 }
    	 return dmlWrapper;
    }
    
    /*******************************************************************************************************
    * @description Class used to store an Account ID, its old record type, and its new record type. Used to 
    * track those Accounts whose record type has changed.
    ********************************************************************************************************/
    class AccWithTypes {
        ID accId;
        String oldType;
        String newType;
        
        AccWithTypes(ID accId, String oldType, String newType) {
            this.accId = accId;
            this.oldType = oldType;
            this.newType = newType;
        }
    }
    
    
    /*******************************************************************************************************
    * @description Tells the caller if the oldType account record type has become the new type of any of the 
    * accounts that have changed record type.
    * @return Boolean
    ********************************************************************************************************/
    boolean containsNew(List<AccWithTypes> accWithTypes, String oldType) {
        for(AccWithTypes acc : accWithTypes) {
            if(acc.newType == oldType) {
                UTIL_Debug.debug('****Some other Account has been changed to type ' + oldType);
                return true;
            }
        }
        UTIL_Debug.debug('****No other account has been set to record type ' + oldType);
        return false;
    }
}