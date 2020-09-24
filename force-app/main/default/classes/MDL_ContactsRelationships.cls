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
