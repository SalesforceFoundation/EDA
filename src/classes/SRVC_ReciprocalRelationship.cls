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
* @description Service class for reciprocal relationships. 
*/
public virtual with sharing class SRVC_ReciprocalRelationship {    
    /*****************************************************************************
    * @description Get the relationships to update from map of contact and map of relationship to update.
    * @return The relationships to update.
    ******************************************************************************/
    public List<Relationship__c> getRelationshipsToUpdateForContacts(Map<Id, Contact> newContactRelationshipToUpdateByIdMap, Map<Id, Relationship__c> relationshipsByIdToUpdateMap) {
        List<Relationship__c> relationshipsToUpdateList = new List<Relationship__c>();

        for (Relationship__c relationship : relationshipsByIdToUpdateMap.values()) {
            if (this.isRelationshipReciprocal(relationship, newContactRelationshipToUpdateByIdMap.keySet()) == false) {
                Relationship__c reciprocalRelationship = relationshipsByIdToUpdateMap.get(relationship.ReciprocalRelationship__c);
                reciprocalRelationship.Type__c = relationship.Type__c;
                relationshipsToUpdateList.add(reciprocalRelationship);
            }
        }
            
        return relationshipsToUpdateList;
    }

    /*****************************************************************************
    * @description Check if a relationship is reciprocal.
    * @return If a relationship is reciprocal.
    ******************************************************************************/
    protected boolean isRelationshipReciprocal(Relationship__c relationship, Set<Id> contactIdsSet) {  
        return contactIdsSet.contains(relationship.RelatedContact__c);
    }

    /*****************************************************************************
    * @description Check if Contact relationships should be updated.
    * @return If Contact relationships should be updated.
    ******************************************************************************/
    public boolean shouldUpdateContactRelationships(Contact newContact, Contact oldContact) {
        return oldContact.Gender__c != newContact.Gender__c;        
    }

    /*****************************************************************************
    * @description Query reciprocal relationships for contacts.
    * @return The map of reciprocal relationship by Id for contacts.
    ******************************************************************************/
    public Map<Id, Relationship__c> getRelationshipsForContacts(Set<Id> contactIdsSet) {
        List<Relationship__c> relationshipsForContacts = [SELECT Id,
                                                                Contact__c,
                                                                RelatedContact__c,
                                                                ReciprocalRelationship__c,
                                                                Type__c
                                                        FROM Relationship__c
                                                        WHERE Contact__c IN :contactIdsSet
                                                            OR RelatedContact__c IN :contactIdsSet];
        return new Map<Id, Relationship__c>(relationshipsForContacts);
    }  
}
