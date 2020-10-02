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
* @description Service class for reciprocal relationship inversion. 
*/
public virtual with sharing class SRVC_ReciprocalRelationshipInversion extends SRVC_ReciprocalRelationship{
    /*********************************************
    * @description Instance for Singleton Pattern.
    **********************************************/
    @TestVisible
    private static SRVC_ReciprocalRelationshipInversion instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern.
    **********************************************************************/
    protected SRVC_ReciprocalRelationshipInversion() {}

    /*****************************************************************************
    * @description Static method to get the current instance for Singleton pattern.
    * @return The instance of SRVC_ReciprocalRelationshipInversion.
    ******************************************************************************/
    public static SRVC_ReciprocalRelationshipInversion getInstance() {
        if (SRVC_ReciprocalRelationshipInversion.instance == null) {
            SRVC_ReciprocalRelationshipInversion.instance = new SRVC_ReciprocalRelationshipInversion();
        }

        return SRVC_ReciprocalRelationshipInversion.instance;
    }

    /*****************************************************************************
    * TODO: @description Get the relationships to update from map of contact and map of relationship to update
    * @return The instance of SRVC_ReciprocalRelationship.
    ******************************************************************************/
    public override List<Relationship__c> getRelationshipsToUpdateForContacts(Map<Id, Contact> newContactRelationshipToUpdateByIdMap, Map<Id, Relationship__c> relationshipsByIdToUpdateMap) {
        // Create a list of Relationships to update            
        List<Relationship__c> relationshipsToUpdateList = new List<Relationship__c>();
        // For each relationship in the map’s values
        for (Relationship__c relationship : relationshipsByIdToUpdateMap.values()) {
            // If relationshipIsReciprocal is false
            if (this.isRelationshipReciprocal(relationship, newContactRelationshipToUpdateByIdMap.keySet()) == false) {
                // Get the reciprocal relationship using the relationship map
                Relationship__c reciprocalRelationship = relationshipsByIdToUpdateMap.get(relationship.ReciprocalRelationship__c);
                // Set the reciprocal relationship’s type to the getRelationshipTypeToSet for the original relationship’s type
                // TODO
                // Add the reciprocal relationship to the list of relationships to update
                relationshipsToUpdateList.add(reciprocalRelationship);    
            }
        }
            
        // Return the list of Relationships to update
        return relationshipsToUpdateList;
    }

    /*****************************************************************************
    * TODO: @description Get the relationships to update from map of contact and map of relationship to update
    * @return The instance of SRVC_ReciprocalRelationship.
    ******************************************************************************/
    public String getRelationshipTypeToSet(String relationshipType) {

        // Takes in a String representing a relationship type
        // Get the Label Relationship_Split
            //relationshipSplit = Label.Relationship_Split
        // Split the relationship type into a list of strings using String.split(Relationship_Split)
        List<String> relationshipTypesList = relationshipType.split(Label.Relationship_Split);
        
        // If the list of strings has a size of 1
        if (relationshipTypesList.size() == 1) {
            return relationshipTypesList[0];
        }

        return relationshipTypesList[1] + Label.Relationship_Split + relationshipTypesList[0];
            // Return the relationship type;
        // Return relationshipTypeSplit[1] + Relationship_Split + relationshipTypeSplit[0] , effective swapping what is on one side of the split character with the other.
    
    
    }
}
