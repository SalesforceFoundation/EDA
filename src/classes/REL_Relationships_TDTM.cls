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

    /* @description Provides process control to prevent relationship creation recursion in triggers. */ 
    public static boolean hasRun = false;
    
    public override DmlWrapper run(List<SObject> newList, List<SObject> oldList, 
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
    	
    	List<Relationship__c> newListCasted = (newList == null ? new List<Relationship__c>(): (List<Relationship__c>)newList);
        List<Relationship__c> oldListCasted = (oldList == null ? new List<Relationship__c>(): (List<Relationship__c>)oldList);
    	
    	if(triggerAction != TDTM_Runnable.Action.afterDelete) {
    		return runForRelationships(newListCasted, oldListCasted, triggerAction);
        } else {
        	return runForRelationships(oldListCasted, null, triggerAction);
        }
    }
    
    /// <name> REL_Relationships </name>
    /// <summary> Overloads the REL_Relationships object constructor to handle Relationship processing </summary>
    /// <param name="Relationships"> Relationship objects that are being triggered </param>
    /// <param name="oldRelationships"> Relationships object values before trigger event </param>
    /// <param name="ta"> Trigger action that is occurring </param>
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

        if (triggerAction == TDTM_Runnable.Action.afterUpdate) {
            hasRun = true;
        }

        if (triggerAction == TDTM_Runnable.Action.afterDelete) {
            hasBeenDeleted.addAll((new Map<Id, Relationship__c>(newList)).keySet());
        }
        
        Integer i = 0;          // processing counter            
        for(Relationship__c r : newList) {
            // AFTER INSERT
            if (triggerAction == TDTM_Runnable.Action.afterInsert) {
                if (r.ReciprocalRelationship__c == null) {
                    relationshipsToCreate.add(r);
                }
                if (r.ReciprocalRelationship__c != null) {
                    reciprocalsToUpdate.add(r);
                }
            }
            
            // AFTER UPDATE
            if (triggerAction == TDTM_Runnable.Action.afterUpdate) {   
                if (r.ReciprocalRelationship__c == oldList[i].ReciprocalRelationship__c 
                && r.RelatedContact__c != null) {
                    relationshipsToUpdate.add(r);
                    origRelationships.add(oldList[i]);
                }
                if (r.RelatedContact__c == null) {
                    relationshipsToDelete.add(r);
                }
            }

            // AFTER DELETE
            if (triggerAction == TDTM_Runnable.Action.afterDelete) {
                if (r.ReciprocalRelationship__c != null && !hasBeenDeleted.contains(r.ReciprocalRelationship__c)) {
                    relationshipsToDelete.add(r);
                }
            }

            i++;
        }

        if (relationshipsToCreate.size() > 0 ) {
        	DmlWrapper wrapper = createRelationship(relationshipsToCreate);
            mainWrapper.objectsToInsert.addAll(wrapper.objectsToInsert);
            mainWrapper.objectsToUpdate.addAll(wrapper.objectsToUpdate);
        }
        if (relationshipsToUpdate.size() > 0 ) {
            DmlWrapper wrapper = updateRelationship(relationshipsToUpdate, origRelationships);
            mainWrapper.objectsToUpdate.addAll(wrapper.objectsToUpdate);
        }
        if (reciprocalsToUpdate.size() > 0 ) {
            DmlWrapper wrapper = reciprocate(reciprocalsToUpdate);
            mainWrapper.objectsToUpdate.addAll(wrapper.objectsToUpdate);
            
        }
        if (relationshipsToDelete.size() > 0 ) {
            DmlWrapper wrapper = deleteRelationships(relationshipsToDelete);
            mainWrapper.objectsToDelete.addAll(wrapper.objectsToDelete);
        }

        if (triggerAction == TDTM_Runnable.Action.afterUpdate) {
            hasRun = false;
        }
        return mainWrapper;
    }


    /// <name> deleteRelationships </name>
    /// <summary> Deletes Reciprocal Relationships when a Relationship is deleted </summary>
    /// <param name="relationships">  </param>
    public static DmlWrapper deleteRelationships(Relationship__c[] relationships) {
    	UTIL_Debug.debug('****Deleting relationships: ' + relationships);
    	DmlWrapper dmlWrapper = new DmlWrapper();
        List<SObject> relationshipsToDelete = new List<SObject>();
        for(Relationship__c r : Relationships) {
        	Relationship__c relationshipToDelete;
            if(r.ReciprocalRelationship__c != null) {
            	relationshipToDelete = new Relationship__c(Id = r.ReciprocalRelationship__c);
            } else if(r.RelatedContact__c == null) {
            	relationshipToDelete = new Relationship__c(Id = r.Id);
	        }
	        relationshipsToDelete.add(relationshipToDelete);
        }
        if ( relationshipsToDelete.size() > 0 ) {
            dmlWrapper.objectsToDelete.addAll(relationshipsToDelete);
        }
        return dmlWrapper;
    }
    
    /// <name> reciprocate </name>
    /// <summary>  </summary>
    /// <param name="Relationships">  </param>
    public static DmlWrapper reciprocate(Relationship__c[] Relationships) {
    	DmlWrapper dmlWrapper = new DmlWrapper();
        List<SObject> relationshipsToUpdate = new List<SObject>();
        for(Relationship__c r : Relationships) {
        	UTIL_Debug.debug('****Creating reciprocal relatioship');
            Relationship__c copy = new Relationship__c(Id = r.ReciprocalRelationship__c, 
                                                                    ReciprocalRelationship__c = r.Id);
            relationshipsToUpdate.add(copy);
        }
        dmlWrapper.objectsToUpdate.addAll(relationshipsToUpdate);
        return dmlWrapper;
    }
    
    /// <name> createRelationship </name>
    /// <summary> Inserts a new reciprocal Relationship After a relationship is Inserted</summary>
    /// <param name="Relationships">  </param>
    public static DmlWrapper createRelationship(Relationship__c[] Relationships) {
    	
    	DmlWrapper dmlWrapper = new DmlWrapper();
    	
        List<SObject> relationshipsToCreate = new List<SObject>();
                
        for(Relationship__c r : Relationships) {
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
        addType(Relationships, relationshipstoCreate);      
        dmlWrapper.objectsToInsert.addAll(relationshipsToCreate);
        //inspectSaveResults(sr, relationshipsToCreate);
        
        return dmlWrapper;
    }

    /// <name> updateRelationship </name>
    /// <summary> Updates the Status and/or Type of a relationship After its reciprocal has been updated </summary>
    /// <param name="Relationships">  </param>
    /// <param name="oldRelationships">  </param>
    public static DmlWrapper updateRelationship(Relationship__c[] Relationships, 
    Relationship__c[] oldRelationships){
    	
    	DmlWrapper dmlWrapper = new DmlWrapper();
    	
        List<Relationship__c> originalRelationships = new List<Relationship__c>();
        List<SObject> relationshipsTypesToUpdate = new List<SObject>();
        List<SObject> reciprocalsToUpdate = new List<SObject>();
        Integer counter = 0;                                            // processing counter       

        for(Relationship__c r : Relationships) {
        	
            //SWA 2009-05-13 removed a duplicate check for change to Status__c from this OR statement
            if ((r.Status__c != oldRelationships[counter].Status__c 
            || r.Type__c != oldRelationships[counter].Type__c 
            || r.Description__c != oldRelationships[counter].Description__c) 
            && r.ReciprocalRelationship__c != null) {
            	UTIL_Debug.debug('****Creating relationship in updateRelationship method');
                Relationship__c copy = new Relationship__c(Id=r.ReciprocalRelationship__c);
                
                //SWA 2009-05-13 - only attempt to modify the Contact field if the Related Contact  has changed
                if(oldRelationships[counter].RelatedContact__c!=r.RelatedContact__c) {
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
        if (!reciprocalsToUpdate.isEmpty()){
            dmlWrapper.objectsToUpdate.addAll(reciprocalsToUpdate);
        }
        return dmlWrapper;
    }
    
    public static void addType(List<Relationship__c> rList, List<SObject> rCopy) {
        
        Hierarchy_Settings__c rs = UTIL_CustomSettingsFacade.getSettings();
        
        //used for tracking place in array
        integer counter = 0;            
        
        if (rs.Reciprocal_Method__c == 'List Setting'){ 
            List<Relationship_Lookup__c> settings = UTIL_CustomSettingsFacade.getReciprocalSettings().clone();           
            Map<String, Relationship_Lookup__c> rlMap = new Map<String, Relationship_Lookup__c>();
            for(Relationship_Lookup__c setting : settings) {
                rlMap.put(setting.Name, setting);
            }
        
            //remove inactive values
            for(String s : rlMap.keySet()){
                Relationship_Lookup__c thisRl = rlMap.get(s);
                if (thisRl.Active__c != true){
                    rlMap.remove(s);
                }
            }
        
            List<id> rIDs = new List<id>();
                
            for (Relationship__c r : rList){
            //    rIDs.add(r.RelatedContact__c);
                rIDs.add(r.Contact__c);
            }            
            
            String query_String = 'select id, Salutation, Gender__c from Contact where Id IN :rIDs';                         
            
            Map<id, Contact> cMap = new Map<id,Contact>((List<Contact>)database.query(query_String));
            
            for(Relationship__c r : rList){
                
                Relationship__c copy = (Relationship__c)rCopy[counter];

                Contact relatedContact = cMap.get(r.Contact__c);
            
                if (rlMap.containsKey(r.Type__c)){
                    List<String> maleList = system.label.Male.split(',');                                                                                                        
                    List<String> femaleList = system.label.Female.split(',');
                    
                    Set<String> maleset = new Set<String>();
                    Set<String> femaleset = new Set<String>();
                    maleset.addAll(maleList);
                    femaleset.addAll(femaleList);                    
                                        
                    //was a gender field defined? 
                    if (relatedContact.Gender__c != null){
                        String match_type = '';                        
                        
                        //try male
                        for (String s : maleList){
                            if (relatedContact.Gender__c.toLowerCase() == s.toLowerCase().trim()){
                                match_type = 'male';
                                break;
                            }
                        }
                        //if we haven't found it, try female
                        if(match_type == ''){
                            for (String s : femaleList){
                                if (relatedContact.Gender__c.toLowerCase() == s.toLowerCase().trim()){
                                    match_type = 'female';
                                    break;
                                }
                            }
                        }     
                        
                        if (match_type == 'male' && rlMap.get(r.Type__c).Male__c != null)
                            copy.Type__c = rlMap.get(r.Type__c).Male__c;
                        else if (match_type == 'female' && rlMap.get(r.Type__c).Female__c != null)                            
                            copy.Type__c = rlMap.get(r.Type__c).Female__c;
                        else
                            copy.Type__c = rlMap.get(r.Type__c).Neutral__c;
                    }
                    else if ((relatedContact.Salutation == 'Mr.' || maleset.contains(relatedContact.Salutation))  
                    && rlMap.get(r.Type__c).Male__c != null){
                        copy.Type__c = rlMap.get(r.Type__c).Male__c;
                    }
                    else if (((relatedContact.Salutation == 'Ms.' || relatedContact.Salutation == 'Mrs.') 
                    || femaleset.contains(relatedContact.Salutation)) && rlMap.get(r.Type__c).Female__c 
                    != null){
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
        }
        
        else if(rs.Reciprocal_Method__c == 'Value Inversion'){
            for (Relationship__c r : rList){                           
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
        }
        else{
            for (Relationship__c r : rList){
            	Relationship__c castedObject = (Relationship__c)rCopy[counter];
                castedObject.Type__c = r.Type__c;
                counter++; 
            }   
        }
    }
}