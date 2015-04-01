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
    
    //Map of Contact field names to Contact field labels.
	Map<String, String> contactLabelNames;
		
    //Affiliation Account-record-type-to-Contact-field mappings.
    Map<String, String> mappingsRecTypesToLabels;
    
    //List of primary affiliation lookup fields names.
    List<String> primaryAfflFieldNames;
    
    public AFFL_MultiRecordType_TDTM() {
		//List of Contact field names.
		List<SObjectField> contactFields = Contact.sObjectType.getDescribe().fields.getMap().values();
		
		//Map of Contact field names to Contact field labels.
		contactLabelNames = getContactLabelsNamesMap(contactFields);
		
		//List of primary affiliation lookup fields names.
		List<String> contactFieldNames = contactLabelNames.values();
		
		//Affiliation Account-record-type-to-Contact-field mappings.
		mappingsRecTypesToLabels = getPrimaryAfflMappings();
		UTIL_Debug.debug('****MRT: primaryAfflMappings: ' + JSON.serializePretty(mappingsRecTypesToLabels)); 
		
		//List of primary affiliation lookup fields names.
		List<String> primaryAfflFieldLabels = mappingsRecTypesToLabels.values();
		UTIL_Debug.debug('****MRT: primaryAfflFieldLabels: ' + JSON.serializePretty(primaryAfflFieldLabels));
		
		//List of primary affiliation Contact fields.
		List<SObjectField> primaryAfflFields = getPrimaryAfflFields(contactFields, primaryAfflFieldLabels);
		UTIL_Debug.debug('****MRT: primaryAfflFieldNames: ' + JSON.serializePretty(primaryAfflFieldNames));
    }
    
    private Map<String, String> getContactLabelsNamesMap(List<SObjectField> cf) {
    	Map<String, String> labelsnames = new Map<String, String>();
		for(SObjectField field : cf) {
			labelsnames.put(field.getDescribe().getLabel(), field.getDescribe().getName());
		}
		return labelsnames;
    }
    
    private Map<String, String> getPrimaryAfflMappings() {
		Map<String, String> mappings = new Map<String, String>();
		//Get the affiliation Account-record-type-to-Contact-field mappings.
		List<Affl_Mappings__c> primaryAfflMappings = [select Account_Record_Type__c, Primary_Affl_Field__c from Affl_Mappings__c];
		//Put them in a map.
		for(Affl_Mappings__c mapping : primaryAfflMappings) {
			if(!String.isBlank(mapping.Account_Record_Type__c) && !String.isBlank(mapping.Primary_Affl_Field__c)) {
				mappings.put(mapping.Account_Record_Type__c, mapping.Primary_Affl_Field__c);
			}
		}
		return mappings;
	}
	
	private List<SObjectField> getPrimaryAfflFields(List<SObjectField> cf, List<String> primaryAfflFieldLabels) {
		Set<String> primaryAfflFieldLabelsSet = new Set<String>(primaryAfflFieldLabels);
		List<SObjectField> primaryFields = new List<SObjectField>();
		primaryAfflFieldNames = new List<String>();
		for(SObjectField field : cf) {
			if(primaryAfflFieldLabelsSet.contains(field.getDescribe().getLabel())) {
				primaryAfflFieldNames.add(field.getDescribe().getName());
				primaryFields.add(field);
			}
		}
		return primaryFields;
	}
    
    private Contact queryAfflLookupFields(Affiliation__c affl) {
    	String dynamicQuery = 'select ID';
		for(String primaryField : primaryAfflFieldNames) {
			dynamicQuery = dynamicQuery + ', ' + primaryField; 	
		}
		dynamicQuery += ' from Contact where ID = \''+ affl.Contact__c + '\'';
		UTIL_Debug.debug('****MRT: Dynamic query: ' + dynamicQuery);
		return (Contact)Database.query(dynamicQuery)[0];
    }
    
	public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
    
    	 DmlWrapper dmlWrapper = new DmlWrapper();

		 if(!afflMultiHasRun) {
			 //WARNING: NOT BULK SAFE! WE'LL NEED TO OPTIMIZE IT, IF WE GO FOR THIS DESIGN!
			 
			 Integer i = 0;
			 if(newlist != null && newlist.size() > 0) {
		    	 for (SObject so : newlist) {
		            Affiliation__c affl = (Affiliation__c)so;
					
					UTIL_Debug.debug('****MRT: affl type: ' + affl.Affiliation_Type__c);
					String lookupFieldLabel = mappingsRecTypesToLabels.get(affl.Affiliation_Type__c);
					UTIL_Debug.debug('****MRT: lookup field label: ' + lookupFieldLabel);
					String lookupFieldName = contactLabelNames.get(lookupFieldLabel);
					UTIL_Debug.debug('****MRT: lookup field name: ' + lookupFieldName);
					
					//Query all the primary affiliation lookup fields on the contact - they are not available in the trigger.
					Contact relatedContact = queryAfflLookupFields(affl);
						
		            //BEFORE INSERT - so we don't get the affiliation we just created when we query for affls of the same type
		            if (triggerAction == TDTM_Runnable.Action.BeforeInsert) {
		            	
		            	List<Affiliation__c> otherPrimaries;
		            	
		            	//If the account doesn't have a record type, find any other primary affiliations with no record type for this contact.
		            	if(affl.Affiliation_Type__c == null) {
							otherPrimaries = [select ID, Organization__c, Primary__c from Affiliation__c 
															where Affiliation_Type__c = null 
															and Contact__c = :affl.Contact__c and Primary__c = true];
		            	//If the account has a record type, find any other primary affiliations of this record type for this contact.
		            	} else {
							otherPrimaries = [select ID, Organization__c, Primary__c from Affiliation__c 
															where Affiliation_Type__c = :affl.Affiliation_Type__c 
															and Contact__c = :affl.Contact__c and Primary__c = true];
		            	}
						UTIL_Debug.debug('****MRT: Number of existing primary affiliations with the same record type: ' + otherPrimaries.size());
						
		                if (affl.Primary__c && affl.Contact__c != null && affl.Organization__c != null) {
		                    List<ID> oldLookups = new List<ID>();
		                    //If the newly created affiliation is the primary, uncheck other primary affiliations of the same type.
		                    for(Affiliation__c otherAffl : otherPrimaries) {
		                		otherAffl.Primary__c = false;
		                		dmlWrapper.objectsToUpdate.add(otherAffl);
		                		oldLookups.add(otherAffl.Organization__c);
		                    }
		                    UTIL_Debug.debug('****MRT: Number of lookups of this type:' + oldLookups.size());
		                    
		                    //If there is no affiliation lookup of this type and we have a mapping, populate the lookup field
		                    //defined in the mapping. 
		                    if((oldLookups.size() == 0 || oldLookups.size() == 1) && !String.isBlank(lookupFieldName)) {
		                    	UTIL_Debug.debug('****MRT: populating lookup field ' + lookupFieldName + ' on contact');
								relatedContact.put(lookupFieldName, affl.Organization__c);
			                    dmlWrapper.objectsToUpdate.add(relatedContact); 
		                    //If there's more than one, throw an error.
		                    } else if(oldLookups.size() > 1) {
		                    	affl.addError('Multiple primary affiliations of the same type to the same contact exist. Leave only one before proceeding.');
		                    }
		                }
		            }
		            
		            // AFTER UPDATE
		            if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
		                Affiliation__c afflOld = (Affiliation__c)oldlist[i];
		                if (affl.Primary__c != afflOld.Primary__c) {
		                                       
		                }
		            }      
		        	i++;
		    	 }
			 }
	    	 
	    	 if(oldlist != null && oldlist.size() > 0) {
		    	 for(SObject so : oldlist) {
		    	 	Affiliation__c affl = (Affiliation__c)so;
		    	 	
		    	 	UTIL_Debug.debug('****MRT: affl type: ' + affl.Affiliation_Type__c);
					String lookupFieldLabel = mappingsRecTypesToLabels.get(affl.Affiliation_Type__c);
					UTIL_Debug.debug('****MRT: lookup field label: ' + lookupFieldLabel);
					String lookupFieldName = contactLabelNames.get(lookupFieldLabel);
					UTIL_Debug.debug('****MRT: lookup field name: ' + lookupFieldName);
					
		    	 	//Query all the primary affiliation lookup fields on the contact - they are not available in the trigger.
					Contact relatedContact = queryAfflLookupFields(affl);
					
		    	 	//AFTER DELETE - delete lookup relationship, if necessary
		            if (triggerAction == TDTM_Runnable.Action.AfterDelete) {
		            	UTIL_Debug.debug('****MRT: after delete');
		            	//If the affl is primary, and the lookup field of this type is pointing to the account that is part of the affl ==> clear the lookup
		            	if(affl.Primary__c && relatedContact.get(lookupFieldName) == affl.Organization__c) {
		            		UTIL_Debug.debug('****MRT: clearing lookup field');
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
    
    
}