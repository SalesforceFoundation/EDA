/*
    Copyright (c) 2013, Salesforce.org
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
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
* @date 2013
* @group Relationships
* @group-content ../../ApexDocContent/Relationships.htm
* @description Implements relationships behavior on Relationship__c.
*/
public class REL_Relationships_TDTM extends TDTM_Runnable {
    
    @testVisible
    private static Boolean reentrancyPrevented;
    
    /*******************************************************************************************************
    * @description Handles Relationship management.
    * @param newList the list of Relationships from trigger new. 
    * @param oldList the list of Relationships from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Relationship.
    * @return dmlWrapper.  
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newList, List<SObject> oldList, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        if (TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_TDTM_After_Update)) {
            reentrancyPrevented = true;
            return new DmlWrapper();
        }
    	
    	List<Relationship__c> newListCasted = (newList == null ? new List<Relationship__c>(): (List<Relationship__c>)newList);
        List<Relationship__c> oldListCasted = (oldList == null ? new List<Relationship__c>(): (List<Relationship__c>)oldList);
    	
    	if (triggerAction != TDTM_Runnable.Action.AfterDelete) {
    		return runForRelationships(newListCasted, oldListCasted, triggerAction);
        } else {
        	return runForRelationships(oldListCasted, null, triggerAction);
        }
    }
    
    /*******************************************************************************************************
    * @description Handles Relationship management.
    * @param newList the list of Relationships from trigger new. 
    * @param oldList the list of Relationships from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @return dmlWrapper.  
    ********************************************************************************************************/
    private DmlWrapper runForRelationships(List<Relationship__c> newList, List<Relationship__c> oldList, 
        TDTM_Runnable.Action triggerAction) {
    	    
    	DmlWrapper mainWrapper = new DmlWrapper();
    	
        // Relationship List for termination updates
        List<Relationship__c> origrelationships = new List<Relationship__c>();
        List<Relationship__c> relationshipsToCreate = new List<Relationship__c>();
        List<Relationship__c> relationshipsToUpdate = new List<Relationship__c>();
        List<Relationship__c> relationshipsToDelete = new List<Relationship__c>();
        List<Relationship__c> reciprocalsToUpdate = new List<Relationship__c>();

        //Keeps track of relationships that have already been deleted to prevent Entity is Deleted error
        Set<Id> hasBeenDeleted = new Set<Id>();

        if (triggerAction == TDTM_Runnable.Action.AfterDelete) {
            hasBeenDeleted.addAll((new Map<Id, Relationship__c>(newList)).keySet());
        }
        
        Integer i = 0;          // processing counter            
        for (Relationship__c r : newList) {
            // AFTER INSERT
            if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
                if (r.ReciprocalRelationship__c == null) {
                    relationshipsToCreate.add(r);
                } else {
                    reciprocalsToUpdate.add(r);
                }
            }
            
            // AFTER UPDATE
            if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {   
                if (r.ReciprocalRelationship__c == oldList[i].ReciprocalRelationship__c && 
                        r.RelatedContact__c != null) {
                    relationshipsToUpdate.add(r);
                    origRelationships.add(oldList[i]);
                }
                
                if (r.RelatedContact__c == null) {
                    relationshipsToDelete.add(r);
                }
            }

            // AFTER DELETE
            if (triggerAction == TDTM_Runnable.Action.AfterDelete) {
                if (r.ReciprocalRelationship__c != null && !hasBeenDeleted.contains(r.ReciprocalRelationship__c)) {
                    relationshipsToDelete.add(r);
                }
            }

            i++;
        }

        if (relationshipsToCreate.size() > 0) {
        	DmlWrapper wrapper = createRelationship(relationshipsToCreate);
            mainWrapper.objectsToInsert.addAll(wrapper.objectsToInsert);
            mainWrapper.objectsToUpdate.addAll(wrapper.objectsToUpdate);
        }

        if (relationshipsToUpdate.size() > 0) {
            // relationshipsToUpdate is only populated in the AfterUpdate sequence.
            // In this sequence, we're updating reciprocal relationships after the other relationship has been updated.
            // So, let's prevent reentrancy here so that the code doesn't run through for a second time.
            DmlWrapper wrapper = updateRelationship(relationshipsToUpdate, origRelationships);
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_TDTM_After_Update, true);
            TDTM_TriggerHandler.processDML(wrapper, true);
            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_TDTM_After_Update, false);
        }
        
        if (reciprocalsToUpdate.size() > 0) {
            DmlWrapper wrapper = reciprocate(reciprocalsToUpdate);
            mainWrapper.objectsToUpdate.addAll(wrapper.objectsToUpdate);
        }
        
        if (relationshipsToDelete.size() > 0) {
            DmlWrapper wrapper = deleteRelationships(relationshipsToDelete);
            mainWrapper.objectsToDelete.addAll(wrapper.objectsToDelete);
        }

        return mainWrapper;
    }

    /*******************************************************************************************************
    * @description Deletes Reciprocal Relationships when a Relationship is deleted
    * @param relationships the list of Relationships that are being deleted
    * @return dmlWrapper 
    ********************************************************************************************************/
    private static DmlWrapper deleteRelationships(List<Relationship__c> relationships) {
    	UTIL_Debug.debug('****Deleting relationships: ' + relationships);
    	DmlWrapper dmlWrapper = new DmlWrapper();
        List<SObject> relationshipsToDelete = new List<SObject>();
        
        for (Relationship__c r : relationships) {
        	Relationship__c relationshipToDelete;
            if (r.ReciprocalRelationship__c != null) {
            	relationshipToDelete = new Relationship__c(Id = r.ReciprocalRelationship__c);
            } else if (r.RelatedContact__c == null) {
            	relationshipToDelete = new Relationship__c(Id = r.Id);
	        }

	        relationshipsToDelete.add(relationshipToDelete);
        }
        
        dmlWrapper.objectsToDelete.addAll(relationshipsToDelete);
        return dmlWrapper;
    }
    
    /*******************************************************************************************************
    * @description Updates the existing Reciprocal Relationships for new Relationship records
    * @param relationships the list of new Relationships
    * @return dmlWrapper 
    ********************************************************************************************************/
    private static DmlWrapper reciprocate(List<Relationship__c> relationships) {
    	DmlWrapper dmlWrapper = new DmlWrapper();
        List<SObject> relationshipsToUpdate = new List<SObject>();
        
        for (Relationship__c r : relationships) {
        	UTIL_Debug.debug('****Updating reciprocal relationship');
            Relationship__c copy = new Relationship__c(Id = r.ReciprocalRelationship__c, 
                                                        ReciprocalRelationship__c = r.Id);
            relationshipsToUpdate.add(copy);
        }
        
        dmlWrapper.objectsToUpdate.addAll(relationshipsToUpdate);
        return dmlWrapper;
    }
    
    /*******************************************************************************************************
    * @description Creates the new Reciprocal Relationships for new Relationship records
    * @param relationships the list of new Relationships
    * @return dmlWrapper 
    ********************************************************************************************************/
    private static DmlWrapper createRelationship(List<Relationship__c> relationships) {
    	
    	DmlWrapper dmlWrapper = new DmlWrapper();
    	
        List<SObject> relationshipsToCreate = new List<SObject>();
                
        for (Relationship__c r : relationships) {
        	UTIL_Debug.debug('****Creating relationship in createRelationship method');
            Relationship__c copy = new Relationship__c();              
            copy.Contact__c = r.RelatedContact__c;
            copy.RelatedContact__c = r.Contact__c;
            copy.Status__c = r.Status__c;
            copy.ReciprocalRelationship__c = r.Id;
            copy.Description__c = r.Description__c;
            copy.SYSTEM_SystemCreated__c = true;
            relationshipsToCreate.add(copy);
        }
        
        //evaluate and add the type
        addType(relationships, relationshipsToCreate);      
        dmlWrapper.objectsToInsert.addAll(relationshipsToCreate);
        
        return dmlWrapper;
    }

    /*******************************************************************************************************
    * @description Updates the Status and/or Type of a Relationship after its reciprocal has been updated
    * @param relationships the list of Reciprocal Relationships that were updated
    * @param oldRelationships the old list of Reciprocal Relationships prior to the update
    * @return dmlWrapper 
    ********************************************************************************************************/
    private static DmlWrapper updateRelationship(List<Relationship__c> relationships, 
            List<Relationship__c> oldRelationships) {
    	
    	DmlWrapper dmlWrapper = new DmlWrapper();
    	
        List<Relationship__c> originalRelationships = new List<Relationship__c>();
        List<SObject> relationshipsTypesToUpdate = new List<SObject>();
        List<SObject> reciprocalsToUpdate = new List<SObject>();
        Integer counter = 0;                                            // processing counter       

        for (Relationship__c r : relationships) {
        	
            //SWA 2009-05-13 removed a duplicate check for change to Status__c from this OR statement
            if ((r.Status__c != oldRelationships[counter].Status__c 
                    || r.Type__c != oldRelationships[counter].Type__c 
                    || r.Description__c != oldRelationships[counter].Description__c) 
                    && r.ReciprocalRelationship__c != null) {
            	
                UTIL_Debug.debug('****Updating relationship in updateRelationship method');
                Relationship__c copy = new Relationship__c(Id = r.ReciprocalRelationship__c);
                
                //SWA 2009-05-13 - only attempt to modify the Contact field if the Related Contact  has changed
                if (oldRelationships[counter].RelatedContact__c != r.RelatedContact__c) {
                    copy.Contact__c = r.RelatedContact__c;
                }

                copy.Status__c = r.Status__c;
                copy.Description__c = r.Description__c;
                
                //only recalculate type on reciprocal if the original type has changed
                if (r.Type__c != oldRelationships[counter].Type__c) {
                    relationshipsTypesToUpdate.add(copy);
                    originalRelationships.add(r);
                } else {
                    reciprocalsToUpdate.add(copy);
                }

            }
            counter++;
        }

        //add type info as needed and update
        if (!originalRelationships.isEmpty() && !relationshipsTypesToUpdate.isEmpty()) {
            addType(originalRelationships, relationshipsTypesToUpdate);
            dmlWrapper.objectsToUpdate.addAll(relationshipsTypesToUpdate);
        }
        
        //update reciprocals without type change
        dmlWrapper.objectsToUpdate.addAll(reciprocalsToUpdate);
        
        return dmlWrapper;
    }
    
    /*******************************************************************************************************
    * @description Updates the Type of a list of Relationships based on the defined settings in the org.
    * @param rList the original list of new or updated Relationships
    * @param rCopy the reciprocals of the original list of new or updated Relationships
    ********************************************************************************************************/
    public static void addType(List<Relationship__c> rList, List<SObject> rCopy) {
        
        Hierarchy_Settings__c rs = UTIL_CustomSettingsFacade.getSettings();
        
        //used for tracking place in array
        Integer counter = 0;            
        
        if (rs.Reciprocal_Method__c == 'List Setting') { 
            List<Relationship_Lookup__c> settings = UTIL_CustomSettingsFacade.getReciprocalSettings().clone();           
            Map<String, Relationship_Lookup__c> rlMap = new Map<String, Relationship_Lookup__c>();
            for (Relationship_Lookup__c setting : settings) {
                rlMap.put(setting.Name, setting);
            }
        
            //remove inactive values
            for (String s : rlMap.keySet()) {
                Relationship_Lookup__c thisRl = rlMap.get(s);
                if (thisRl.Active__c != true) {
                    rlMap.remove(s);
                }
            }
        
            List<Id> rIDs = new List<Id>();
            for (Relationship__c r : rList) {
                rIDs.add(r.Contact__c);
            }            
            
            String queryString = 'SELECT Id, Salutation, Gender__c FROM Contact WHERE Id IN :rIDs';                         
            
            Map<Id, Contact> cMap = new Map<Id, Contact>((List<Contact>)Database.query(queryString));
            
            for (Relationship__c r : rList) {
                
                Relationship__c copy = (Relationship__c)rCopy[counter];

                Contact relatedContact = cMap.get(r.Contact__c);
            
                if (rlMap.containsKey(r.Type__c)) {
                    List<String> maleList = system.label.Male.split(',');                                                                                                        
                    List<String> femaleList = system.label.Female.split(',');
                    
                    Set<String> maleSet = new Set<String>();
                    Set<String> femaleSet = new Set<String>();
                    maleSet.addAll(maleList);
                    femaleSet.addAll(femaleList);                    
                                        
                    //was a gender field defined? 
                    if (relatedContact.Gender__c != null) {
                        String match_type = '';                        
                        
                        //try male
                        for (String s : maleList) {
                            if (relatedContact.Gender__c.toLowerCase() == s.toLowerCase().trim()) {
                                match_type = 'male';
                                break;
                            }
                        }

                        //if we haven't found it, try female
                        if (match_type == '') {
                            for (String s : femaleList) {
                                if (relatedContact.Gender__c.toLowerCase() == s.toLowerCase().trim()) {
                                    match_type = 'female';
                                    break;
                                }
                            }
                        }     
                        
                        if (match_type == 'male' && rlMap.get(r.Type__c).Male__c != null) {
                            copy.Type__c = rlMap.get(r.Type__c).Male__c;
                        } else if (match_type == 'female' && rlMap.get(r.Type__c).Female__c != null) {
                            copy.Type__c = rlMap.get(r.Type__c).Female__c;
                        } else {
                            copy.Type__c = rlMap.get(r.Type__c).Neutral__c;
                        }
                    } else if ((relatedContact.Salutation == 'Mr.' || maleSet.contains(relatedContact.Salutation))  
                            && rlMap.get(r.Type__c).Male__c != null) {
                        copy.Type__c = rlMap.get(r.Type__c).Male__c;
                    } else if (((relatedContact.Salutation == 'Ms.' || relatedContact.Salutation == 'Mrs.') 
                            || femaleSet.contains(relatedContact.Salutation)) && rlMap.get(r.Type__c).Female__c != null) {
                        copy.Type__c = rlMap.get(r.Type__c).Female__c;
                    
                    //can't match up gender, bad field or otherwise
                    } else {
                        copy.Type__c = rlMap.get(r.Type__c).Neutral__c;                     
                    }                                     
                //no matching custom List setting, use provided type
                } else {
                    copy.Type__c = r.Type__c;
                }                
                counter++;
            }            
        } else if (rs.Reciprocal_Method__c == 'Value Inversion') {
            
            for (Relationship__c r : rList) {                           
                //instead lets split the type
                List<String> splitrelationship = r.Type__c.split(system.label.Relationship_Split);
                String newString = '';
                if (splitrelationship.size() > 1)
                    newString = splitrelationship[1] + system.label.Relationship_Split + splitrelationship[0];
                else
                    newString = r.Type__c;
            
                Relationship__c castedObject = (Relationship__c)rCopy[counter];
                castedObject.Type__c = newString;
                counter++;
            }
        } else {
            for (Relationship__c r : rList) {
            	Relationship__c castedObject = (Relationship__c)rCopy[counter];
                castedObject.Type__c = r.Type__c;
                counter++; 
            }   
        }
    }
}