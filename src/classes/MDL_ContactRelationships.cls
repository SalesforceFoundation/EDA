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
* @description Model class for REL_Relationships_Con_TDTM. 
*/
public with sharing class MDL_ContactRelationships {
    public Id contactId { get; private set; }

    // For reference: Relationship__c.Contact__c - <Relationship__c.Type__c - Relationship__c>
    private Map<Id, Map<String, Relationship__c>> relationshipByTypeByRelatedContactId { get; private set; }
    public List<Relationship__c> relationshipList { get; private set; } 

    public MDL_ContactRelationships(Id contactId) {
        this.contactId = contactId;
    }

    /************************************************************************************************************
    * @description Adds a new relationship record to the mapping by relationship type for the related Contact.
    * @param  relationshipToAdd The Relationship record to add.
    *************************************************************************************************************/
    public void addRelationship(Relationship__c relationshipToAdd){
        
        if (relationshipByTypeByRelatedContactId == null){
            relationshipByTypeByRelatedContactId = new Map<Id, Map<String, Relationship__c>>();
        }

        Map<String, Relationship__c> relationshipsByType = relationshipByTypeByRelatedContactId.get(relationshipToAdd.Contact__c);

        if (relationshipsByType == null){
            // relationship by type mapping doesn't exist for current contact 
            Map<String, Relationship__c> newRelationshipsByType = new Map<String, Relationship__c>();
            relationshipByTypeByRelatedContactId.put(relationshipToAdd.Contact__c, newRelationshipsByType);
        } 
        
        relationshipsByType.put(relationshipToAdd.Type__c, relationshipToAdd);
        relationshipList.add(relationshipToAdd);
    }

    /************************************************************************************************************
    * @description Retrieves the Contact Ids related to Relationship records.
    * @return A Set of Contact Ids.
    ************************************************************************************************************/
    public Set<Id> getRelatedContactIdSet(){
        return relationshipByTypeByRelatedContactId.keySet();
    }

    /************************************************************************************************************
     * @description Retrieves the the Relationship record associated with a given Contact and Type.
     * @param  contactId The related Contact Id for the Relationship.
     * @param  relationshipType The related Relationship type.
     * @return A matching Relationship record if one exists, null otherwise.
     ************************************************************************************************************/
    public Relationship__c getRelationship(Id contactId, String relationshipType){
        Map<String, Relationship__c> relatedRelationshipsByType = relationshipByTypeByRelatedContactId.get(contactId);

        if (relatedRelationshipsByType == null){
            return null; 
        }

        return relatedRelationshipsByType.get(relationshipType);
    }

    /************************************************************************************************************
    * @description Determines whether relationshipByTypeByRelatedContactId is an empty map.
    * @return True is relationshipByTypeByRelatedContactId is empty, False otherwise.
    ************************************************************************************************************/
    public Boolean isEmpty(){
        return relationshipByTypeByRelatedContactId.isEmpty();
    }
}
