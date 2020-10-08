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
* @group-content ../../ApexDocContent/Relationships.htm
* @description Service class for reciprocal relationship inversion. 
*/
public virtual with sharing class SRVC_ReciprocalRelationshipInversion extends SRVC_ReciprocalRelationship{

    /*****************************************************************************
    * @description Get the relationships to update from map of contact and map of relationship to update if reciprocal method is inversion.
    * @param newContactRelationshipToUpdateByIdMap Map of contact whose relationships need to be updated.
    * @param relationshipsByIdToUpdateMap Map of relationship to update.
    * @return The relationships to update.
    ******************************************************************************/
    public override List<Relationship__c> getRelationshipsToUpdateForContacts(Map<Id, Contact> newContactRelationshipToUpdateByIdMap, Map<Id, Relationship__c> relationshipsByIdToUpdateMap) {
        List<Relationship__c> relationshipsToUpdateList = new List<Relationship__c>();
        
        for (Relationship__c relationship : relationshipsByIdToUpdateMap.values()) {
            if (this.isRelationshipReciprocal(relationship, newContactRelationshipToUpdateByIdMap.keySet()) == false) {
                Relationship__c reciprocalRelationship = relationshipsByIdToUpdateMap.get(relationship.ReciprocalRelationship__c);
                reciprocalRelationship.Type__c = this.getInversedRelationshipType(reciprocalRelationship.Type__c);
                relationshipsToUpdateList.add(reciprocalRelationship);    
            }
        }
            
        return relationshipsToUpdateList;
    }

    /*****************************************************************************
    * @description Get the inversed relationship type from the relationship type.
    * @param relationshipType The type of relationship.
    * @return The string of the inversed relationship type.
    ******************************************************************************/
    @TestVisible
    private String getInversedRelationshipType(String relationshipType) {
        List<String> relationshipTypesList = relationshipType.split(Label.Relationship_Split);
        
        if (relationshipTypesList.size() == 1) {
            return relationshipTypesList[0];
        }

        return relationshipTypesList[1] + Label.Relationship_Split + relationshipTypesList[0];         
    }
}
