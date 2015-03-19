public with sharing class AFFL_MultiRecordType_TDTM extends TDTM_Runnable {

	public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
    
    	 DmlWrapper dmlWrapper = new DmlWrapper();

		 //WARNING: NOT BULK SAFE! WE'LL NEED TO OPTIMIZE IT, IF WE GO FOR THIS DESIGN!
		 
		 List<Schema.SObjectField> primaryAfflFields = getContactPrimaryAfflFields();
		 
		 Integer i = 0;
    	 for (SObject so : newlist) {
            Affiliation__c affl = (Affiliation__c)so;
			
            //BEFORE INSERT - so we don't get the affiliation we just created when we query for affls of the same type
            if (triggerAction == TDTM_Runnable.Action.BeforeInsert) {
            	
            	//Find any other primary affiliations of this record type for this contact
				List<Affiliation__c> otherPrimaries = [select ID, Organization__c, Primary__c from Affiliation__c 
													where Affiliation_Type__c = :affl.Affiliation_Type__c 
													and Contact__c = :affl.Contact__c and Primary__c = true];
				System.debug('****MRT: Number of existing primary affiliations with the same record type: ' + otherPrimaries.size());
				
				//Query all the primary affiliation lookup fields on the contact
				Contact relatedContact = queryAfflLookupFields(primaryAfflFields, affl);
            	
                if (affl.Primary__c && affl.Contact__c != null && affl.Organization__c != null) {
                    List<ID> oldLookups = new List<ID>();
                    //If the newly created affiliation is the primary, uncheck other primary affiliations of the same type.
                    for(Affiliation__c otherAffl : otherPrimaries) {
                		otherAffl.Primary__c = false;
                		dmlWrapper.objectsToUpdate.add(otherAffl);
                		oldLookups.add(otherAffl.Organization__c);
                    }
                    System.debug('****MRT: Number of lookups of this type:' + oldLookups.size());
                    
                    //If there is no affiliation lookup of this type, find the first empty primary affiliation lookup field and set it. 
                    if(oldLookups.size() == 0) {
	                    for(Schema.SObjectField primaryField : primaryAfflFields) {
	                    	System.debug('****MRT: existing affl lookup field: ' + primaryField); 
	                    	if(relatedContact.get(primaryField) == null) {
	                    		relatedContact.put(primaryField, affl.Organization__c);
	                    		dmlWrapper.objectsToUpdate.add(relatedContact);
	                    		break;	
	                    	}
	                    	//If there are no empty fields, tell the user he needs to add one.
	                    	affl.addError('You need to add another lookup field to Contact. The field label should start with "Primary Affiliation"');
	                    }
	                //If there is an affiliation lookup of this type, replace it.
                    } else if(oldLookups.size() == 1) {
                    	System.debug('****MRT: the primary affiliation lookup of this type needs to be replaced');
                    	ID oldLookup = oldLookups[0];
                    	for(Schema.SObjectField primaryField : primaryAfflFields) {
                    		if(relatedContact.get(primaryField) == oldLookup) {
                    			System.debug('****MRT: lookup field found: ' + primaryField);
                    			relatedContact.put(primaryField, affl.Organization__c);
                    			dmlWrapper.objectsToUpdate.add(relatedContact);
	                    		break;
                    		}
                    	}
                    //If there's more than one, throw an error.
                    } else if(oldLookups.size() > 1) {
                    	affl.addError('Multiple primary affiliations of the same type to the same contact exist. Leave only one before proceeding.');
                    	return dmlWrapper;
                    }
                }
            }
            
            // AFTER UPDATE
            if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                Affiliation__c afflOld = (Affiliation__c)oldlist[i];
                if (affl.Primary__c != afflOld.Primary__c) {
                                       
                }
            }
            
            //AFTER DELETE - delete lookup relationship, if necessary
            if (triggerAction == TDTM_Runnable.Action.AfterDelete) {
            	
            }         
        	i++;            
        } 
        return dmlWrapper;  	
    }
    
    private Contact queryAfflLookupFields(List<Schema.SObjectField> primaryAfflFields, Affiliation__c affl) {
    	String dynamicQuery = 'select ID';
		for(Schema.SObjectField primaryField : primaryAfflFields) {
			dynamicQuery = dynamicQuery + ', ' + primaryField; 	
		}
		dynamicQuery += ' from Contact where ID = \''+ affl.Contact__c + '\'';
		System.debug('****MRT: Dynamic query: ' + dynamicQuery);
		return (Contact)Database.query(dynamicQuery)[0];
    }
    
    private List<Schema.SObjectField> getContactPrimaryAfflFields() {
		List<Schema.SObjectField> primaryAfflFields = new List<Schema.SObjectField>();
		Map<String, Schema.SObjectField> fieldsMap = Contact.sObjectType.getDescribe().fields.getMap();
		
		//Doing our own sorting, because if we call sort on the list we get an exception. Apparently someone forgot to implement
		//Comparable on SObjectField.
		List<String> keys = new List<String>(fieldsMap.keySet());
		keys.sort();
		List<Schema.SObjectField> fieldsList = new List<Schema.SObjectField>();
		for(String key : keys) {
			fieldsList.add(fieldsMap.get(key));
		}
		
		for(Schema.SObjectField field : fieldsList) {
			if(field.getDescribe().getLabel().startsWith('Primary Affiliation')) {
				primaryAfflFields.add(field);
			}
		}
		return primaryAfflFields;		
	}
}