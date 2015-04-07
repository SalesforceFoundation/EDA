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
public with sharing class AFFL_MultiRecordType_TDTM extends TDTM_Runnable {

	//Static flags to prevent recursive call.
    public static boolean afflMultiHasRun = false;

	public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
    
    	 DmlWrapper dmlWrapper = new DmlWrapper();

		 if(!afflMultiHasRun) {
			 
			 AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();

			 //Query all the primary affiliation lookup fields on the contact - they are not available in the trigger.
			 Map<ID, Contact> relatedContactsMap;
			 if(newlist != null) {
			 	relatedContactsMap = queryAfflLookupFields(newlist, afflMapper);
			 } else if(oldlist != null) {
			 	relatedContactsMap = queryAfflLookupFields(oldlist, afflMapper);
			 }
				 
			 if(newlist != null && newlist.size() > 0) { 
			 	 Integer i = 0;
		    	 for (SObject so : newlist) {
		            Affiliation__c affl = (Affiliation__c)so;
					String lookupFieldLabel = afflMapper.mappingsRecTypesToLabels.get(affl.Affiliation_Type__c);
					String lookupFieldName = afflMapper.contactLabelNames.get(lookupFieldLabel);
					
					//Query all the primary affiliation lookup fields on the contact - they are not available in the trigger.
					Contact relatedContact = relatedContactsMap.get(affl.Contact__c);
					
		            //BEFORE INSERT - we do it in the Before so we don't get the affiliation we just created when we query for 
		            //affls of the same type.
		            if (triggerAction == TDTM_Runnable.Action.BeforeInsert) {
		            	uncheckOtherPrimariesPopulateKeyAffls(affl, lookupFieldName, relatedContact, dmlWrapper);
		            }
		            
		            // AFTER UPDATE
		            if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
		                Affiliation__c afflOld = (Affiliation__c)oldlist[i];

		                //If a primary affiliation is made nonprimary the key affiliation field on the contact needs to be cleared.
		                if (afflOld.Primary__c && !affl.Primary__c) {
		                	relatedContact.put(lookupFieldName, null);
		                	dmlWrapper.objectsToUpdate.add(relatedContact);
		                }
		                
		                //If a non-primary affiliation is made primary the key affiliation field on the contact needs to be filled,
		                //an any other primary affiliation of the same type needs to be made non-primary.
		                if (affl.Primary__c && !afflOld.Primary__c) {
		                	uncheckOtherPrimariesPopulateKeyAffls(affl, lookupFieldName, relatedContact, dmlWrapper);
		                }
		            }      
		        	i++;
		    	 }
			 }
	    	 
	    	 if(oldlist != null && oldlist.size() > 0) {
		    	 for(SObject so : oldlist) {
		    	 	Affiliation__c afflOld = (Affiliation__c)so;
					String lookupFieldLabel = afflMapper.mappingsRecTypesToLabels.get(afflOld.Affiliation_Type__c);
					String lookupFieldName = afflMapper.contactLabelNames.get(lookupFieldLabel);

					Contact relatedContact = relatedContactsMap.get(afflOld.Contact__c);
					
		    	 	//AFTER DELETE - delete lookup relationship, if necessary
		            if (triggerAction == TDTM_Runnable.Action.AfterDelete) {
		            	//If the affl is primary, and the lookup field of this type is pointing to the account that is part of the affl ==> clear the lookup
		            	if(afflOld.Primary__c && relatedContact.get(lookupFieldName) == afflOld.Organization__c) {
		            		relatedContact.put(lookupFieldName, null);
		            		dmlWrapper.objectsToUpdate.add(relatedContact);
		            	}
		            }
		    	 }
	    	 }
	    	 afflMultiHasRun = true;  
        } 
        return dmlWrapper;  	
    }
    
    private Map<ID, Contact> queryAfflLookupFields(List<SObject> newlist, AFFL_MultiRecordTypeMapper afflMapper) {
    	//Query the primary affiliation fields for all contacts at once
		String contactIDs = '(';
		Map<ID, Contact> relatedContactsMap = new Map<ID, Contact>();
		if(newlist != null && newlist.size() > 0) {
			Affiliation__c firstAffl = (Affiliation__c)newlist[0];
			contactIDs += '\'' + firstAffl.Contact__c + '\'';
			Integer i = 1;
			while(i < newlist.size()) {
				Affiliation__c affl = (Affiliation__c)newlist[i];
		        contactIDs += ', \'' + affl.Contact__c + '\'';
			}
			i++;
			contactIDs += ')';
			
			//Query all the primary affiliation lookup fields on the contact - they are not available in the trigger.
			String dynamicQuery = 'select ID';
			for(String primaryField : afflMapper.primaryAfflFieldNames) {
				dynamicQuery = dynamicQuery + ', ' + primaryField; 	
			}
			dynamicQuery += ' from Contact where ID IN '+ contactIDs;
			UTIL_Debug.debug('****MRT: Dynamic query: ' + dynamicQuery);
			List<Contact> relatedContactsList = Database.query(dynamicQuery);
			for(Contact contact : relatedContactsList) {
			 	relatedContactsMap.put(contact.ID, contact);
			}
		}
		return relatedContactsMap;
    }
    
    private void uncheckOtherPrimariesPopulateKeyAffls(Affiliation__c affl, String lookupFieldName, Contact relatedContact, DmlWrapper dmlWrapper) {

        if (affl.Primary__c && affl.Contact__c != null && affl.Organization__c != null) {
            Integer oldLookupsSameTypeCount = uncheckOtherPrimariesSameType(affl, dmlWrapper);
            
            //If there is no affiliation lookup of this type and we have a mapping, populate the lookup field
            //defined in the mapping. 
            if((oldLookupsSameTypeCount == 0 || oldLookupsSameTypeCount == 1) && !String.isBlank(lookupFieldName)) {
            	UTIL_Debug.debug('****MRT: populating lookup field ' + lookupFieldName + ' on contact');
				relatedContact.put(lookupFieldName, affl.Organization__c);
                dmlWrapper.objectsToUpdate.add(relatedContact); 
            //If there's more than one, throw an error.
            } else if(oldLookupsSameTypeCount > 1) {
            	affl.addError('Multiple primary affiliations of the same type to the same contact exist. Leave only one before proceeding.');
            }
        }
    }
    
    private Integer uncheckOtherPrimariesSameType(Affiliation__c affl, DmlWrapper dmlWrapper) {
    	List<Affiliation__c> otherPrimariesSameType;
		            	
    	//If the account doesn't have a record type, find any other primary affiliations with no record type for this contact.
    	if(affl.Affiliation_Type__c == null) {
			otherPrimariesSameType = [select ID, Organization__c, Primary__c from Affiliation__c 
											where Affiliation_Type__c = null 
											and Contact__c = :affl.Contact__c and Primary__c = true];
    	//If the account has a record type, find any other primary affiliations of this record type for this contact.
    	} else {
			otherPrimariesSameType = [select ID, Organization__c, Primary__c from Affiliation__c 
											where Affiliation_Type__c = :affl.Affiliation_Type__c 
											and Contact__c = :affl.Contact__c and Primary__c = true];
    	}
		UTIL_Debug.debug('****MRT: Number of existing primary affiliations with the same record type: ' + otherPrimariesSameType.size());
		
		List<ID> oldLookupsSameType = new List<ID>();
        
        //If the newly created affiliation is the primary, uncheck other primary affiliations of the same type.
        for(Affiliation__c otherAffl : otherPrimariesSameType) {
    		otherAffl.Primary__c = false;
    		dmlWrapper.objectsToUpdate.add(otherAffl);
    		oldLookupsSameType.add(otherAffl.Organization__c);
        }
        UTIL_Debug.debug('****MRT: Number of lookups of this type:' + oldLookupsSameType.size());
        
        return oldLookupsSameType.size();
    }
}