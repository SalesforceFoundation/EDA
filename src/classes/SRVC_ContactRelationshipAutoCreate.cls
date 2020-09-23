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
public virtual with sharing class SRVC_ContactRelationshipAutoCreate {
    /*********************************************
    * @description Instance for Singleton Pattern.
    **********************************************/
    @TestVisible
    private static SRVC_ContactRelationshipAutoCreate instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern.
    **********************************************************************/
    protected SRVC_ContactRelationshipAutoCreate() {}

    /*****************************************************************************
    * @description Static method to get the current instance for Singleton pattern.
    * @return The instance of SRVC_ContactRelationshipAutoCreate.
    ******************************************************************************/
    public static SRVC_ContactRelationshipAutoCreate getInstance() {
        if (SRVC_ContactRelationshipAutoCreate.instance == NULL) {
            SRVC_ContactRelationshipAutoCreate.instance = new SRVC_ContactRelationshipAutoCreate();
        }

        return SRVC_ContactRelationshipAutoCreate.instance;
    }

    /******************************************************************************
    * getRelationshipsToCreateForContacts description
    * @param contactsList contactsList description
    * @param contactRelationShipAutoCreateMapModelsList contactRelationShipAutoCreateMapModelsList description
    * @return return description
    ******************************************************************************/ 
    public virtual MDL_ContactsRelationships getRelationshipsToCreateForContacts(List<Contact> contactsList, List<MDL_ContactRelationshipAutoCreateMapping> contactRelationShipAutoCreateMapModelsList){
        MDL_ContactsRelationships contactsRelationshipsModel = new MDL_ContactsRelationships();

        for (Contact con : contactsList){
            MDL_ContactRelationships conRelationshipsModel = this.getRelationshipsToCreateForContact(con, contactRelationShipAutoCreateMapModelsList);

            if (conRelationshipsModel != null){
                contactsRelationshipsModel.addContactRelationshipsModel(conRelationshipsModel);
            }
        }

        return contactsRelationshipsModel;
    }

    /**
     * getRelationshipsToCreateForContact description
     * @param  contact                                    contact description
     * @param  contactRelationShipAutoCreateMapModelsList contactRelationShipAutoCreateMapModelsList description
     * @return                                            return description
     */ 
    public virtual MDL_ContactRelationships getRelationshipsToCreateForContact(Contact contact, List<MDL_ContactRelationshipAutoCreateMapping> contactRelationShipAutoCreateMapModelsList){
        MDL_ContactRelationships conRelationshipsModel = new MDL_ContactRelationships(contact.Id);

        for (MDL_ContactRelationshipAutoCreateMapping conRelAutoCreateMap : contactRelationShipAutoCreateMapModelsList){
            System.debug('MK DEBUG: conRelAutoCreateMap: ' + conRelAutoCreateMap);
            
            String contactFieldApiName = conRelAutoCreateMap.settingsContactFieldValue;
            Object contactFieldValue = contact.get(contactFieldApiName);
            
            System.debug('MK DEBUG: contactFieldValue: ' + contactFieldValue);
            if (contactFieldValue != null){
                Relationship__c conRelationshipToAdd = new Relationship__c(Contact__c = contact.Id,
                                                                           RelatedContact__c = (Id)contactFieldValue,
                                                                           Type__c = conRelAutoCreateMap.relationshipType,
                                                                           Status__c = 'Current');

                conRelationshipsModel.addRelationship(conRelationshipToAdd);
            }
        }

        System.debug('MK DEBUG conRelationshipsModel: ' + conRelationshipsModel);
        return conRelationshipsModel;
    }

    /**
    * getRelationshipsToCreateForUpdatedContact description
    * @param  newContact                                 newContact description
    * @param  oldContact                                 oldContact description
    * @param  contactRelationShipAutoCreateMapModelsList contactRelationShipAutoCreateMapModelsList description
    * @return                                            return description
    */
    public virtual MDL_ContactRelationships getRelationshipsToCreateForUpdatedContact(Contact newContact, Contact oldContact, List<MDL_ContactRelationshipAutoCreateMapping> contactRelationShipAutoCreateMapModelsList){
        MDL_ContactRelationships contactRelationshipsModel = new MDL_ContactRelationships(newContact.Id);

        for (MDL_ContactRelationshipAutoCreateMapping conRelAutoCreateMappingMdl : contactRelationShipAutoCreateMapModelsList){
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

    /**
    * getRelationshipsToInsertFromModel description
    * @param  contactRelationshipsModel contactRelationshipsModel description
    * @return                           return description
    */
    public virtual List<Relationship__c> getRelationshipsToInsertFromModel(MDL_ContactsRelationships contactsRelationshipsModel){
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

        for (Relationship__c rel : contactRelationships){
            if (this.isADuplicateRelationship(rel, contactsRelationshipsModel) == true){
                contactsRelationshipsModel.removeRelationshipFromList(rel);
            }
        }

        return contactsRelationshipsModel.relationshipList;
    }

    /**
    * isADuplicateRelationship description
    * @param  relationship               relationship description
    * @param  contactRelationshipsModel contactsRelationshipsModel description
    * @return                            return description
    */ 
    private Boolean isADuplicateRelationship(Relationship__c relationship, MDL_ContactsRelationships contactsRelationshipsModel){
        return contactsRelationshipsModel.hasRelationship(relationship);
    }
}
