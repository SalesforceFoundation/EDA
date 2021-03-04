/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group 
* @group-content ../../ApexDocContent/
* @description Service class for REL_Relationships_Con_TDTM.  Handles functionality
* associated with Auto-creation of relationships.
*/
public virtual with sharing class ContactRelAutoCreateService {
    /**************************************************************************************************************************
    * @description Instance for Singleton Pattern.
    **************************************************************************************************************************/
    @TestVisible
    private static ContactRelAutoCreateService instance;

    /**************************************************************************************************************************
    * @description Empty constructor is not public for Singleton Pattern.
    **************************************************************************************************************************/
    protected ContactRelAutoCreateService() {}

    /**************************************************************************************************************************
    * @description Static method to get the current instance for Singleton pattern.
    * @return The instance of ContactRelAutoCreateService.
    **************************************************************************************************************************/
    public static ContactRelAutoCreateService getInstance() {
        if (ContactRelAutoCreateService.instance == null) {
            ContactRelAutoCreateService.instance = new ContactRelAutoCreateService();
        }

        return ContactRelAutoCreateService.instance;
    }

    /**************************************************************************************************************************
    * @description Retrieves a model representing the Relationship records to be created for a list of Contact records.
    * @param contactsList A list of Contact records from which to retrieve associated Relationship records.
    * @param contactRelationShipAutoCreateMapModelsList A List of ContactRelAutoCreateMappingModel representing Relationship Auto Create mappings for Contact.
    * @return A ContactsRelationshipsModel model representing the Relationships associated with a list of Contacts. 
    **************************************************************************************************************************/ 
    public virtual ContactsRelationshipsModel getRelationshipsToCreateForContacts(List<Contact> contactsList, List<ContactRelAutoCreateMappingModel> contactRelationShipAutoCreateMapModelsList){
        ContactsRelationshipsModel contactsRelationshipsModel = new ContactsRelationshipsModel();

        for (Contact con : contactsList){
            ContactRelationshipsModel conRelationshipsModel = this.getRelationshipsToCreateForContact(con, contactRelationShipAutoCreateMapModelsList);

            if (conRelationshipsModel != null){
                contactsRelationshipsModel.addContactRelationshipsModel(conRelationshipsModel);
            }
        }

        return contactsRelationshipsModel;
    }

    /**************************************************************************************************************************
    * @description Retrieves a model representing the Relationship records to be created for a single Contact record.
    * @param  contact The Contact record to be used to create the ContactRelationships model.
    * @param  contactRelationShipAutoCreateMapModelsList A List of ContactRelAutoCreateMappingModel representing Relationship Auto Create mappings for Contact.
    * @return A ContactRelationshipsModel model representing the Relationships associated with the specified Contact record. 
    **************************************************************************************************************************/ 
    @TestVisible
    protected virtual ContactRelationshipsModel getRelationshipsToCreateForContact(Contact contact, List<ContactRelAutoCreateMappingModel> contactRelationShipAutoCreateMapModelsList){
        ContactRelationshipsModel conRelationshipsModel = new ContactRelationshipsModel(contact.Id); 
        Id contactFieldValue; 
        
        for (ContactRelAutoCreateMappingModel conRelAutoCreateMap : contactRelationShipAutoCreateMapModelsList){
            try{
                contactFieldValue = (Id)contact.get(conRelAutoCreateMap.contactFieldApiName);
            } catch (System.StringException ex){
                contact.addError(Label.AutoCreateFieldError);
            }
            
            if (contactFieldValue != null){
                Relationship__c conRelationshipToAdd = new Relationship__c(Contact__c = contact.Id,
                                                                           RelatedContact__c = (Id)contactFieldValue,
                                                                           Type__c = conRelAutoCreateMap.relationshipType,
                                                                           Status__c = 'Current');

                conRelationshipsModel.addRelationship(conRelationshipToAdd);
            }
        }

        return conRelationshipsModel;
    }

    /**************************************************************************************************************************
    * @description Retrieves a model representing the Relationship records to be created for a single updated Contact record.
    * @param  newContact The Contact record in its updated state.
    * @param  oldContact The Contact record in its state prior to update.
    * @param  contactRelationShipAutoCreateMapModelsList List of Relationships Auto Create mappings for Contact.
    * @return A ContactRelationshipsModel object representing the relationships records to be created for the specified Contact.
    **************************************************************************************************************************/
    public virtual ContactRelationshipsModel getRelationshipsToCreateForUpdatedContact(Contact newContact, Contact oldContact, List<ContactRelAutoCreateMappingModel> contactRelationShipAutoCreateMapModelsList){
        ContactRelationshipsModel contactRelationshipsModel = new ContactRelationshipsModel(newContact.Id);

        for (ContactRelAutoCreateMappingModel conRelAutoCreateMappingMdl : contactRelationShipAutoCreateMapModelsList){
            Object newContactFieldValue = newContact.get(conRelAutoCreateMappingMdl.contactFieldApiName);
            Object oldContactFieldValue = oldContact.get(conRelAutoCreateMappingMdl.contactFieldApiName);
    
            if (newContactFieldValue != null && newContactFieldValue != oldContactFieldValue){
                Relationship__c relationshipToAdd = new Relationship__c(Contact__c = newContact.Id,
                                                                        RelatedContact__c = (Id)newContactFieldValue,
                                                                        Type__c = conRelAutoCreateMappingMdl.relationshipType,
                                                                        Status__c = 'Current');

                contactRelationshipsModel.addRelationship(relationshipToAdd);
            }
        }

        return contactRelationshipsModel;
    }

    /**************************************************************************************************************************
    * @description Retrieves the Relationship records to insert from a specified ContactsRelationships model.
    * @param contactRelationshipsModel The ContactsRelationshipsModel model from which to retrieve Relationship records to insert.
    * @return A list of Relationship records to be inserted.
    **************************************************************************************************************************/
    public virtual List<Relationship__c> getRelationshipsToInsertFromModel(ContactsRelationshipsModel contactsRelationshipsModel){
        if (UTIL_CustomSettingsFacade.getSettings().Allow_AutoCreated_Duplicates__c == true){
            return contactsRelationshipsModel.relationshipList;
        }

        List<Relationship__c> contactRelationships = [SELECT Id,
                                                             Contact__c,
                                                             RelatedContact__c,
                                                             Type__c
                                                      FROM Relationship__c
                                                      WHERE Contact__c in :contactsRelationshipsModel.contactIdsSet
                                                      AND RelatedContact__c in :contactsRelationshipsModel.relatedContactIdSet
                                                      LIMIT 2000];

        Set<Relationship__c> relationshipsToInsert = new Set<Relationship__c>(contactsRelationshipsModel.relationshipList);

        for (Relationship__c rel : contactRelationships){
            Relationship__c relToRemove = this.getDuplicateRelationship(rel, contactsRelationshipsModel);
            if (relToRemove != null){
                relationshipsToInsert.remove(relToRemove);
            } 
        }

        return new List<Relationship__c>(relationshipsToInsert);
    }

    /**************************************************************************************************************************
    * @description Determines if a Contact record has an existing Relationship record that matches a specified Relationship.
    * @param relationship The Relationships to check for a duplicate.
    * @param contactRelationshipsModel The Contact Relationships model containing all existing Relationships for a Contact.
    * @return True if a duplicate Relationship record is found, False otherwise.
    **************************************************************************************************************************/ 
    @TestVisible
    private Relationship__c getDuplicateRelationship(Relationship__c relationship, ContactsRelationshipsModel contactsRelationshipsModel){
        return contactsRelationshipsModel.getRelationship(relationship);
    }
}
