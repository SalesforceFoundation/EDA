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

    @testVisible
    private static Boolean reentrancyPrevented;
	
	/*******************************************************************************************************
    * @description Trigger Handler on Contact that handles relationship autocreation and gender change.
    * @param newList the list of Contacts from trigger new. 
    * @param oldList the list of Contacts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Contacts 
    * @return dmlWrapper Any relationships that need DML.
    ********************************************************************************************************/
	public override DmlWrapper run(List<SObject> newList, List<SObject> oldList, 
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        DmlWrapper dmlWrapper = new DmlWrapper();

        if (newList == null || newList.isEmpty() == true){
            return dmlWrapper;
        }

        UTIL_Describe.cacheDescribeSObjectResult(Contact.SObjectType.getDescribe());

        if (triggerAction == TDTM_Runnable.Action.AfterInsert){
            return this.handleAfterInsert(newList);
        }

        if (triggerAction == TDTM_Runnable.Action.AfterUpdate){
            return handleAfterUpdate(newList, oldList);
        }


        System.debug('MK DEBUG: Continuing to old code');
        /******************************************************************************************************************** */
         //Casting them to contacts, since this class should be run only for contacts
         List<Contact> newListCasted = (newList == null ? new List<Contact>(): (List<Contact>)newList);
         List<Contact> oldListCasted = (oldList == null ? new List<Contact>(): (List<Contact>)oldList);
         Map<Id, Contact> oldMap = new Map<Id, Contact>(oldListCasted);
                      
         if (TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_Con_TDTM)) {
             reentrancyPrevented = true;
             return dmlWrapper;
          }
         
         List<Id> contactIds = new List<Id>();
         List<Id> reciprocalIds = new List<Id>();
         List<String> types = new List<String>();
         
         Set<Id> changedGender = new Set<Id>();        
         
         if(newlist != null && newlist.size() > 0) {
             for (Contact c : newListCasted){
                 for(String s : REL_Utils.getAutoCreateMap().keySet()){
                     Relationship_Auto_Create__c rac = REL_Utils.getAutoCreateMap().get(s);
                     if (rac.Object__c != 'Contact') {
                         continue;
                     }
                     
                     Id relatedContactId;
                     try{
                         //get the id from the field                        
                         relatedContactId = (Id)c.get(rac.Field__c);
                     }catch(Exception e){
                         c.addError(system.Label.AutoCreateFieldError);
                     }    
                     
                     if(triggerAction == TDTM_Runnable.Action.afterInsert && relatedContactId != null) {                        
                         contactIds.add(c.Id);
                         reciprocalIds.add(relatedContactId);
                         types.add(rac.Relationship_Type__c);
                     } else if (triggerAction == TDTM_Runnable.Action.afterUpdate && relatedContactId != null 
                             && relatedContactId != oldMap.get(c.id).get(rac.Field__c)){
                         contactIds.add(c.Id);
                         reciprocalIds.add(relatedContactId);
                         types.add(rac.Relationship_Type__c);
                     }         
                 }
                 
                 //handle updates to the gender field
                 if (triggerAction == TDTM_Runnable.Action.afterUpdate && oldMap.get(c.id) != null) {
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
         
         if (!contactIds.isEmpty()){
             DmlWrapper w = createNewRelationships(contactIds, reciprocalIds, types);
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
 
         TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_Con_TDTM, true);
         TDTM_TriggerHandler.processDML(dmlWrapper, true);
         dmlWrapper = null;
         TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_Con_TDTM, false);
         /********************************************************************************************************/


         return dmlWrapper;
    }


    /********************************************************************************************************
    * @description Handles processing of logic necessary for an After Insert trigger action.
    * @param newList The list of inserted objects.
    * @return A DmlWrapper
    ********************************************************************************************************/ 
    @TestVisible
    private DmlWrapper handleAfterInsert(List<SObject> newList){        
        if (this.isInsertRecursion() == true){
            return null;
        }

        this.setInsertRecursion();

        List<Contact> newContactsList = (List<Contact>)newList;
        List<MDL_ContactRelationshipAutocreateMapping> contactRelAutoCreateModelsList = this.locateRelationshipAutoCreateMappingService().getContactMappingModelsFromSettings();        
        MDL_ContactsRelationships contactsRelationshipsMdl = this.locateRelationshipAutoCreateService().getRelationshipsToCreateForContacts(newContactsList, contactRelAutoCreateModelsList);

        if (contactsRelationshipsMdl != null){
            List<Relationship__c> contactRelationshipsToCreate = contactsRelationshipsMdl.relationshipList;

            if (contactRelationshipsToCreate != null && contactRelationshipsToCreate.isEmpty() == false){
                DmlWrapper dmlWrapper = new DmlWrapper();
                
                dmlWrapper.objectsToInsert.addAll((List<SObject>)contactRelationshipsToCreate);
                TDTM_TriggerHandler.processDML(dmlWrapper, true);
            }
        }
        
        this.unsetInsertRecursion();

        return null;
    }

    /********************************************************************************************************
    * @description Handles processing of logic necessary for an After Update trigger action.
    * @param newList The list of updated objects.
    * @param oldList The list of objects to be updated
    * @return A DmlWrapper
    ********************************************************************************************************/ 
    @TestVisible
    private DmlWrapper handleAfterUpdate(List<SObject> newList, List<SObject> oldList){
        DmlWrapper dmlWrapper = new DmlWrapper();

        if (this.isUpdateRecursion() == true){
            return null;
        }

        this.setUpdateRecursion();

        Map<Id, Contact> newContactsById = new Map<Id, Contact>((List<Contact>)newSObjectsList);
        Map<Id, Contact> oldContactsById = new Map<Id, Contact>((List<Contact>)oldSObjectsList);
        
        List<MDL_ContactRelationshipAutocreateMapping> contactRelAutoCreateModelsList = this.locateRelationshipAutoCreateMappingService().getContactMappingModelsFromSettings();

        /** 
         * Under construction
         * TODO: get rid of comments when this is done!
        */

        //Create a ContactsRelationshipsModel for Contacts to Insert
        //? Should this be relationships?
        MDL_ContactsRelationships contactRelationshipsToCreate = new MDL_ContactsRelationships();

        //Create a Map<Id,Contact> to update
        //? Should this be relationships?
        Map<Id,Contact> contactRelationshipsToUpdate = new Map<Id,Contact>();

        //loop through contacts in newContactsById
        for (Contact newContact : newContactsById.values()) {
            Contact oldContact = oldContactsById.get(newContact.Id);
            MDL_ContactRelationships contactRelationshipsModel = this.locateRelationshipAutoCreateService().getRelationshipsToCreateForUpdatedContact(contactRelAutoCreateModelsList, newContact, oldContact);
            // if the ContactRelationshipsModel is not empty
            if (contactRelationshipsModel.isEmpty == false) {
                // Add the model to the the ContactsRelationshipsModel
                contactsToInsert.addContactRelationshipsModel(contactRelationshipsModel);   
            }
                
            // If relationships should be updated for the contact per locateReciprocalRelationshipService().shouldUpdateContactRelationships(newContact,oldContact)
            if (this.locateReciprocalRelationshipService().shouldUpdateContactRelationships(newContact, oldContact) == true) {
                // Add the new contact to the map of contactsby id to update.
                contactsToUpdate.put(newContact.Id, newContact);
            }
        }
            
        // If the ContactsRelationshipsModel is not empty
        if (contactsToInsert.isEmpty == false) {
            // get the relationships to create using locateRelationshipAutoCreateService().getRelationshipsToInsertFromModel(contactsRelationshipsModel)
            List<Relationship__c> relationshipsToInsert = this.locateRelationshipAutoCreateService().getRelationshipsToInsertFromModel(contactsToInsert);
            // Add those relationships to the DmlWrapper
            dmlWrapper.objectsToInsert.addAll((List<SObject>)relationshipsToInsert);

        }

        // If the map of contact by Id is not empty
        if (contactRelationshipsToUpdate.values().isEmpty() == false) {
            // Get relationships to update using getRelationshipsToUpdate
            List<Relationship__c> relationshipsToUpdate = this.getRelationshipsToUpdate(contactsToUpdate);
            // Add those relationships to the DmlWrapper
            dmlWrapper.objectsToUpdate.addAll((List<SObject>)relationshipsToUpdate);
        }
        
        //  If we have relationships to insert or update
            // Add the relationships to insert to a new dml wrapper
            // process the wrapper
        TDTM_TriggerHandler.processDML(dmlWrapper, true);
                
        this.unsetUpdateRecursion();

        return dmlWrapper;
    }

    /*******************************************************************************************************
    * @description Retrieves an instance of the SRVC_RelAutoCreateSettingsMapper service class.
    * @return An instance of SRVC_RelAutoCreateSettingsMapper.
    *******************************************************************************************************/ 
    @TestVisible
    private SRVC_RelAutoCreateSettingsMapper locateRelationshipAutoCreateMappingService(){
        return SRVC_RelAutoCreateSettingsMapper.getInstance();
    }

    /*******************************************************************************************************
    * @description Retrieves an instance of the SRVC_ContactRelationshipAutoCreate service class.
    * @return An instance of SRVC_ContactRelationshipAutoCreate.
    *******************************************************************************************************/ 
    @TestVisible
    private SRVC_ContactRelationshipAutoCreate locateRelationshipAutoCreateService(){
        return SRVC_ContactRelationshipAutoCreate.getInstance();
    }

    /*******************************************************************************************************
    * TODO: @description Retrieves an instance of the SRVC_ContactRelationshipAutoCreate service class.
    * @return An instance of SRVC_ContactRelationshipAutoCreate.
    *******************************************************************************************************/ 
    @TestVisible
    private SRVC_ContactRelationshipAutoCreate locateReciprocalRelationshipService(){
        return SRVC_ContactRelationshipAutoCreate.getInstance();
    }

    /*******************************************************************************************************
    * @description Determines whether current context is associated with an insert recursion.
    * @return True if After Insert recursion flag for REL_Relationships_Con_TDTM is set, False otherwise.
    *******************************************************************************************************/ 
    @TestVisible
    private Boolean isInsertRecursion(){
        return TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_Con_TDTM);
    }
    
    /*******************************************************************************************************
    * @description Sets the After Insert recursion flag for REL_Relationships_Con_TDTM.
    *******************************************************************************************************/    
    @TestVisible
    private void setInsertRecursion(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_Con_TDTM, true);
    }

    /*******************************************************************************************************
    * @description Clears the After Insert recursion flag for REL_Relationships_Con_TDTM.
    *******************************************************************************************************/ 
    @TestVisible
    private void unsetInsertRecursion(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_Con_TDTM, false);
    }

    /*******************************************************************************************************
    * @description Determines whether current context is associated with an update recursion.
    * @return True if After Update recursion flag for REL_Relationships_Con_TDTM is set, False otherwise.
    *******************************************************************************************************/ 
    @TestVisible
    private Boolean isUpdateRecursion(){
        return TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_TDTM_After_Update);
    }

    /*******************************************************************************************************
    * @description Sets the After Update recursion flag for REL_Relationships_Con_TDTM.
    *******************************************************************************************************/    
    @TestVisible
    private void setUpdateRecursion(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_TDTM_After_Update, true);
    }

    /*******************************************************************************************************
    * @description Clears the After Update recursion flag for REL_Relationships_Con_TDTM.
    *******************************************************************************************************/ 
    @TestVisible
    private void unsetUpdateRecursion(){
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_TDTM_After_Update, false);
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
        for (Relationship__c r : [SELECT Id, ReciprocalRelationship__c FROM Relationship__c 
                WHERE Contact__c IN :contacts.keySet() ALL ROWS]){
            if (r.ReciprocalRelationship__c != null) {
                relationshipsToDelete.add(new Relationship__c(Id = r.ReciprocalRelationship__c));
            }
        }
        if ( relationshipsToDelete.size() > 0 ) {
            dmlWrapper.objectsToDelete.addAll(relationshipsToDelete);
        }
        return dmlWrapper;
    }
    
    public static DmlWrapper createNewRelationships(List<Id> contactIds, List<Id> relatedContactIds, List<String> types) {
        
        DmlWrapper dmlWrapper = new DmlWrapper();
        Integer i = 0;
        List<SObject> relationshipsForInsert = new List<SObject>();
        
        //used to hold existing relationships for the group of contacts and check for dupes
        List<Relationship__c> existingRelationships = new List<Relationship__c>();
        Map<Id, List<Relationship__c>> relationshipsByContact = new Map<Id, List<Relationship__c>>();
        
        if (!UTIL_CustomSettingsFacade.getSettings().Allow_AutoCreated_Duplicates__c) {
            
            existingRelationships = [SELECT Id, Contact__c, RelatedContact__c, Type__c 
                FROM Relationship__c WHERE Contact__c IN :contactIds LIMIT 2000];
            
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
            
        for (Id conId : contactIds){
            boolean doNotCreate = false;
            
            //prevent duplicates from being created if they exist and setting is enabled
            if (relationshipsByContact.containsKey(conId)){
                for (Relationship__c r : relationshipsByContact.get(conId)){
                    if (r.Type__c == types[i] && r.RelatedContact__c == relatedContactIds[i]){
                        doNotCreate = true;                     
                        break;
                    }                   
                }    
            }
            
            if (!doNotCreate){
                UTIL_Debug.debug('****Creating relationship in createNewRelationships method');
                Relationship__c r = new Relationship__c(
                    Contact__c = conId, 
                    RelatedContact__c = relatedContactIds[i],
                    Type__c = types[i],           
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