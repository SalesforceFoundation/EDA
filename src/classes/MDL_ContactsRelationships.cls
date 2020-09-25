/*
    Copyright (c) 2020 Salesforce.org
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
* @date 2020
* @group Contact Relationships
* @group-content ../../ApexDocContent/Relationships.htm
* @description Model class for REL_Relationships_Con_TDTM.
*/
public with sharing class MDL_ContactsRelationships {
    public Set<Id> contactIdsSet { get; private set; }
    public Set<Id> relatedContactIdSet { get; private set; }
    public Map<Id, MDL_ContactRelationships> contactRelationshipsModelsByContactId;
    public List<Relationship__c> relationshipList { get; private set; }

    public MDL_ContactsRelationships(){
        contactIdsSet = new Set<Id>();
        relatedContactIdSet = new Set<Id>();
        contactRelationshipsModelsByContactId = new Map<Id, MDL_ContactRelationships>();
        relationshipList = new List<Relationship__c>();
    }
    
    /**
     * addContactRelationshipsModel description
     * @param  conRelationshipsModel conRelationshipsModel description
     */ 
    public void addContactRelationshipsModel(MDL_ContactRelationships conRelationshipsModel){
        contactRelationshipsModelsByContactId.put(conRelationshipsModel.contactId, conRelationshipsModel);
        contactIdsSet.add(conRelationshipsModel.contactId);
        relatedContactIdSet.addAll(conRelationshipsModel.getRelatedContactIdSet());
    }

    /**
     * hasRelationship description
     * @param  relationship relationship description
     * @return              return description
     */ 
    public Boolean hasRelationship(Relationship__c relationship){
        MDL_ContactRelationships contactRelationshipModel = contactRelationshipsModelsByContactId.get(relationship.Contact__c);
    
        if (contactRelationshipModel == null){
            return false;
        }

        return (contactRelationshipModel.getRelationship(relationship.Contact__c, relationship.Type__c) != null) ? true : false;
    }

    /**
     * isEmpty description
     * @return   return description
     */ 
    public Boolean isEmpty(){
        return contactRelationshipsModelsByContactId.isEmpty();
    }

    /************************************************************************************************************
    * @description Remove a specified Relationship record from relationshipList.
    * @param relationshipToRemove The Relationship to remove
    ************************************************************************************************************/
    public void removeRelationshipFromList(Relationship__c relationshipToRemove){
        for (Integer i = 0; i < relationshipList.size(); i++){
            if (relationshipList[i].Id == relationshipToRemove.Id){
                relationshipList.remove(i);
                break;
            }
        }
    }
}
