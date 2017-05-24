/*
    Copyright (c) 2013, Salesforce.org
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
* @date 2013
* @group Relationships
* @group-content ../../ApexDocContent/Relationships.htm
* @description Implements relationships behavior on Contact.
*/
public class REL_Relationships_Con_TDTM extends TDTM_Runnable {
	
	/*******************************************************************************************************
    * @description Trigger Handler on Contact that handles relationship autocreation and gender change.
    * @param listNew the list of Contacts from trigger new. 
    * @param listOld the list of Contacts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Contacts 
    * @return dmlWrapper Any relationships that need DML.
    ********************************************************************************************************/
	public override DmlWrapper run(List<SObject> newList, List<SObject> oldList, 
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        //Casting them to contacts, since this class should be run only for contacts
        List<Contact> newListCasted = (newList == null ? new List<Contact>(): (List<Contact>)newList);
        List<Contact> oldListCasted = (oldList == null ? new List<Contact>(): (List<Contact>)oldList);
        Map<Id, Contact> oldMap = new Map<Id, Contact>(oldListCasted);
                    
        DmlWrapper dmlWrapper = new DmlWrapper();
        
        List<Id> ContactIds = new List<Id>();
        List<Id> ReciprocalIds = new List<Id>();
        List<String> Types = new List<String>();
        
        Set<Id> changedGender = new set<Id>();        
        
        if(newlist != null && newlist.size() > 0) {
            for (Contact c : newListCasted){
                for(String s : REL_Utils.getAutoCreateMap().keySet()){
                    Relationship_Auto_Create__c rac = REL_Utils.getAutoCreateMap().get(s);
                    if (rac.Object__c == 'Contact'){
                        Id relatedContactId;
                        try{
                            //get the id from the field                        
                            relatedContactId = (Id)c.get(rac.Field__c);
                        }catch(Exception e){
                            c.addError(system.Label.AutoCreateFieldError);
                        }    
                        
                        if(triggerAction == TDTM_Runnable.Action.afterInsert && relatedContactId != null) {                        
                            ContactIds.add(c.Id);
                            ReciprocalIds.add(relatedContactId);
                            Types.add(rac.Relationship_Type__c);
                        }
                        else if (triggerAction == TDTM_Runnable.Action.afterUpdate && relatedContactId != null 
                        && relatedContactId != oldMap.get(c.id).get(rac.Field__c)){
                            ContactIds.add(c.Id);
                            ReciprocalIds.add(relatedContactId);
                            Types.add(rac.Relationship_Type__c);
                        }
                    }               
                }
                
                //handle updates to the gender field
                if (triggerAction == TDTM_Runnable.Action.afterUpdate) {
                    if (c.Gender__c != oldMap.get(c.id).Gender__c) {
                        changedGender.add(c.id);
                    }
                }           
            }
        }
        
        if(triggerAction == TDTM_Runnable.Action.AfterDelete) {
            DmlWrapper w = deleteEmptyRelationships(oldMap);
            dmlWrapper.objectsToDelete.addAll(w.objectsToDelete);
        }
        
        if (!ContactIds.isEmpty()){
            DmlWrapper w = createNewRelationships(ContactIds, ReciprocalIds, Types);
            dmlWrapper.objectsToInsert.addAll(w.objectsToInsert);
        }
        
        if (!changedGender.isEmpty()) {
            //query for a map of all relationships where where contact or related contact has changed gender
            map<id,Relationship__c> mapRelationship = new map<Id,Relationship__c>(
                [SELECT Id, Contact__c, RelatedContact__c, ReciprocalRelationship__c, Type__c 
                FROM Relationship__c WHERE Contact__c IN :changedGender OR RelatedContact__c IN :changedGender]
            );
            //make a list of "Related Contact" lookup relationships in our set, these we want to update
            list<Relationship__c> listRelsForUpdate = new list<Relationship__c>();
            //make a list of mirror relationships for our first list, we need these for the addType method
            list<Relationship__c> listMirrorRels = new list<Relationship__c>();

            //get the relationships that the gender change affects
            for (Relationship__c rel : mapRelationship.values()) {
                //add the changed gender's relationship and reciprocal
                if (changedGender.contains(rel.RelatedContact__c)) {
                    listRelsForUpdate.add(rel);
                    listMirrorRels.add(mapRelationship.get(rel.ReciprocalRelationship__c));
                }
            }

            //update type info
            REL_Relationships_TDTM.addType(listMirrorRels, listRelsForUpdate);
            dmlWrapper.objectsToUpdate.addAll((list<sObject>)listRelsForUpdate);
        }
        
        return dmlWrapper;
    }
    
    /*******************************************************************************************************
    * @description Deletes Relationships when a Contact is deleted
    * @param contacts the Map of Contacts from trigger oldMap. 
    * @return dmlWrapper Relationships to delete.
    ********************************************************************************************************/
    public static DmlWrapper deleteEmptyRelationships(Map<Id, Contact> contacts) {
        DmlWrapper dmlWrapper = new DmlWrapper();
        List<SObject> relationshipsToDelete = new List<SObject>();

        // The Contacts primary Relationships have already been cascade deleted in Contact After Delete context
        // Using ALL ROWS returns them in the query used to gather the mirror Relationships to be deleted 
        for (Relationship__c r : [Select Id, ReciprocalRelationship__c from Relationship__c 
            where Contact__c in :contacts.keySet() ALL ROWS]){
            relationshipsToDelete.add(new Relationship__c(Id = r.ReciprocalRelationship__c));
        }
        if ( relationshipsToDelete.size() > 0 ) {
            dmlWrapper.objectsToDelete.addAll(relationshipsToDelete);
        }
        return dmlWrapper;
    }
    
    public static DmlWrapper createNewRelationships(List<Id> ContactIds, List<Id> RelatedContactIds, List<String> Types) {
        
        DmlWrapper dmlWrapper = new DmlWrapper();
        Integer i = 0;
        List<SObject> relationshipsForInsert = new List<SObject>();
        
        //used to hold existing relationships for the group of contacts and check for dupes
        List<Relationship__c> existingRelationships = new List<Relationship__c>();
        Map<Id, List<Relationship__c>> relationshipsByContact = new Map<Id, List<Relationship__c>>();
        
        if (!UTIL_CustomSettingsFacade.getSettings().Allow_AutoCreated_Duplicates__c) {
            
            existingRelationships = [select Id, Contact__c, RelatedContact__c, Type__c 
            from Relationship__c where Contact__c IN :ContactIds limit 2000];
            
            //sort by Contact__c so we can pull relationships based on the inserted Contact
            for(Relationship__c r : existingRelationships){
                if(relationshipsByContact.containsKey(r.Contact__c)){
                    List<Relationship__c> rList = relationshipsByContact.get(r.Contact__c);
                    rList.add(r);
                    relationshipsByContact.put(r.Contact__c, rList);
                }
                else{
                    relationshipsByContact.put(r.Contact__c, new List<Relationship__c>{r});
                }               
            }        
        }        
            
        for (Id conId : ContactIds){
            boolean doNotCreate = false;
            
            //prevent duplicates from being created if they exist and setting is enabled
            if (relationshipsByContact.containsKey(conId)){
                for (Relationship__c r : relationshipsByContact.get(conId)){
                    if (r.Type__c == Types[i] && r.RelatedContact__c == RelatedContactIds[i]){
                        doNotCreate = true;                     
                        break;
                    }                   
                }    
            }
            
            if (!doNotCreate){
                UTIL_Debug.debug('****Creating relationship in createNewRelationships method');
                Relationship__c r = new Relationship__c(
                    Contact__c = conId, 
                    RelatedContact__c = RelatedContactIds[i],
                    Type__c = Types[i],           
                    Status__c = 'Current'                 
                );
                relationshipsForInsert.add(r);
            }
            i++;
        }       
        
        if (!relationshipsForInsert.isEmpty()){
            dmlWrapper.objectsToInsert.addAll(relationshipsForInsert);
        }
        
        return dmlWrapper;
    }
}