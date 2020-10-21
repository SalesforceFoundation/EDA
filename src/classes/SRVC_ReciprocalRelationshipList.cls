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
* @description Service class for reciprocal relationship list. 
*/
public virtual with sharing class SRVC_ReciprocalRelationshipList extends SRVC_ReciprocalRelationship{

    /*****************************************************************************
    * @description Get the relationships to update from map of contact and map of relationship to update if reciprocal method is list.
    * @param newContactRelationshipToUpdateByIdMap Map of contact whose relationships need to be updated.
    * @param relationshipsByIdToUpdateMap Map of relationship to update.
    * @return The relationships to update.
    ******************************************************************************/
    public override List<Relationship__c> getRelationshipsToUpdateForContacts(Map<Id, Contact> newContactRelationshipToUpdateByIdMap, Map<Id, Relationship__c> relationshipsByIdToUpdateMap) {
        List<Relationship__c> relationshipsToUpdateList = new List<Relationship__c>();

        Map<String, MODL_ReciprocalRelationshipMapping> activeMappingModels = this.locateReciprocalRelationshipMapper().getActiveMappingModelsFromRelationshipLookups();
        Set<String> femaleGenderSet = this.getFemaleGenderSet();
        Set<String> maleGenderSet = this.getMaleGenderSet();
        Set<String> femaleSalutationSet = this.getFemaleSalutationSet();
        Set<String> maleSalutationSet = this.getMaleSalutationSet();

        for (Relationship__c relationship : relationshipsByIdToUpdateMap.values()) {
            if (this.isRelationshipReciprocal(relationship, newContactRelationshipToUpdateByIdMap.keySet()) == true) {
                continue;
            }

            Relationship__c reciprocalRelationship = relationshipsByIdToUpdateMap.get(relationship.ReciprocalRelationship__c);

            MODL_ReciprocalRelationshipMapping reciprocalRelationshipMappingModel = activeMappingModels.get(relationship.Type__c);
    
            if (reciprocalRelationshipMappingModel == null) {
                relationshipsToUpdateList.add(this.getRelationshipToUpdateWithoutMapping(reciprocalRelationship, relationship.Type__c));                
                continue;
            } 

            Contact relatedContact = newContactRelationshipToUpdateByIdMap.get(reciprocalRelationship.RelatedContact__c);

            if (String.isNotBlank(relatedContact.Gender__c)) {
                Relationship__c relationshipToUpdate = this.getRelationshipToUpdateFromGender(reciprocalRelationship, relatedContact, reciprocalRelationshipMappingModel, femaleGenderSet, maleGenderSet); 
                
                if (relationshipToUpdate != null) {
                    relationshipsToUpdateList.add(this.getRelationshipToUpdateFromGender(reciprocalRelationship, relatedContact, reciprocalRelationshipMappingModel, femaleGenderSet, maleGenderSet));                    
                    continue;
                }    
            }

            relationshipsToUpdateList.add(this.getRelationshipToUpdateFromSalutation(reciprocalRelationship, relatedContact, reciprocalRelationshipMappingModel, femaleSalutationSet, maleSalutationSet));
        }
            
        return relationshipsToUpdateList;
    }

    /*******************************************************************************************************
    * @description Get the reciprocal relationship to update if without reciprocal relationship mapping. 
    * @param reciprocalRelationship A reciprocal relationship.
    * @param relationshipType The type of the relationship.
    * @return The reciprocal relationship to update.
    *******************************************************************************************************/ 
    @TestVisible
    private Relationship__c getRelationshipToUpdateWithoutMapping(Relationship__c reciprocalRelationship, String relationshipType) {
        reciprocalRelationship.Type__c = relationshipType;

        return reciprocalRelationship;
    }

    /*******************************************************************************************************
    * @description Get the reciprocal relationship to update from gender set. 
    * @param reciprocalRelationship A reciprocal relationship.
    * @param relatedContact The related contact determining the gender.
    * @param reciprocalRelationshipMappingModel The reciprocal relationship mapping model.
    * @param femaleGenderSet A set of female labels.
    * @param maleGenderSet A set of male labels.
    * @return The reciprocal relationship to update.
    *******************************************************************************************************/ 
    @TestVisible
    private Relationship__c getRelationshipToUpdateFromGender(Relationship__c reciprocalRelationship, Contact relatedContact, 
                                                            MODL_ReciprocalRelationshipMapping reciprocalRelationshipMappingModel, 
                                                            Set<String> femaleGenderSet, Set<String> maleGenderSet) {
        if (reciprocalRelationshipMappingModel.hasFemaleValue() == true
            && femaleGenderSet.contains(relatedContact.Gender__c.toLowerCase())
        ) {
            reciprocalRelationship.Type__c =
                reciprocalRelationshipMappingModel.getFemaleRelationshipType();
            
            return reciprocalRelationship;
        }

        if (reciprocalRelationshipMappingModel.hasMaleValue() == true
            && maleGenderSet.contains(relatedContact.Gender__c.toLowerCase())
        ) {
            reciprocalRelationship.Type__c =
                reciprocalRelationshipMappingModel.getMaleRelationshipType();
            
            return reciprocalRelationship;
        }
            
        return null;                                                       
    }

    /*******************************************************************************************************
    * @description Get the reciprocal relationship to update from gender set. 
    * @param reciprocalRelationship A reciprocal relationship.
    * @param relatedContact The related contact determining the gender.
    * @param reciprocalRelationshipMappingModel The reciprocal relationship mapping model.
    * @param femaleSalutationSet set of female salutations.
    * @param maleSalutationSet A set of male salutations.
    * @return The reciprocal relationship to update.
    *******************************************************************************************************/ 
    @TestVisible
    private Relationship__c getRelationshipToUpdateFromSalutation(Relationship__c reciprocalRelationship, Contact relatedContact, 
                                                            MODL_ReciprocalRelationshipMapping reciprocalRelationshipMappingModel, 
                                                            Set<String> femaleSalutationSet, Set<String> maleSalutationSet) {
        if (String.isNotBlank(relatedContact.Salutation)) {
            if (reciprocalRelationshipMappingModel.hasFemaleValue() == true
                && femaleSalutationSet.contains(relatedContact.Salutation)
            ) {
                reciprocalRelationship.Type__c =
                    reciprocalRelationshipMappingModel.getFemaleRelationshipType();
                
                return reciprocalRelationship;
            }

            if (reciprocalRelationshipMappingModel.hasMaleValue() == true
                && maleSalutationSet.contains(relatedContact.Salutation)
            ) {
                reciprocalRelationship.Type__c =
                    reciprocalRelationshipMappingModel.getMaleRelationshipType();
                
                return reciprocalRelationship;
            }
        }
            
        reciprocalRelationship.Type__c = reciprocalRelationshipMappingModel.getNeutralRelationshipType();
        
        return reciprocalRelationship;
    }

    /*******************************************************************************************************
    * @description Retrieves an instance of the MAPR_ReciprocalRelationshipSettings service class.
    * @return An instance of MAPR_ReciprocalRelationshipSettings.
    *******************************************************************************************************/ 
    @TestVisible
    private MAPR_ReciprocalRelationshipSettings locateReciprocalRelationshipMapper(){
        return MAPR_ReciprocalRelationshipSettings.getInstance();
    }

    /*******************************************************************************************************
    * @description Get a set of female genders from female labels.
    * @return A set of female genders.
    *******************************************************************************************************/ 
    @TestVisible
    private Set<String> getFemaleGenderSet(){
        return new Set<String>(this.getFemaleLabelList());
    }

    /*******************************************************************************************************
    * @description Get a set of male genders from male labels.
    * @return A set of male genders.
    *******************************************************************************************************/ 
    @TestVisible
    private Set<String> getMaleGenderSet(){
        return new Set<String>(this.getMaleLabelList());
    }

    /*******************************************************************************************************
    * @description Get a list of female genders from female labels.
    * @return A list of female genders.
    *******************************************************************************************************/ 
    @TestVisible
    private List<String> getFemaleLabelList(){
        List<String> femaleLabelList = new List<String>();
        for (String femaleLabel : (Label.Female).split(',')) {
            femaleLabelList.add(femaleLabel.toLowerCase());
        }
        return femaleLabelList;
    }

    /*******************************************************************************************************
    * @description Get a list of male genders from male labels.
    * @return A list of male genders.
    *******************************************************************************************************/ 
    @TestVisible
    private List<String> getMaleLabelList(){
        List<String> maleLabelList = new List<String>();
        for (String maleLabel : (Label.Male).split(',')) {
            maleLabelList.add(maleLabel.toLowerCase());
        }
        return maleLabelList;    
    }

    /*******************************************************************************************************
    * TODO: @description Retrieves an instance of the MAPR_ReciprocalRelationshipSettings service class.
    * @return An instance of MAPR_ReciprocalRelationshipSettings.
    *******************************************************************************************************/ 
    @TestVisible
    private Set<String> getFemaleSalutationSet(){
        Set<String> femaleLabelsSet = new Set<String>(this.getFemaleLabelList());

        femaleLabelsSet.add('Mrs.');
        femaleLabelsSet.add('Ms.');

        return femaleLabelsSet;
    }

    /*******************************************************************************************************
    * TODO: @description Retrieves an instance of the MAPR_ReciprocalRelationshipSettings service class.
    * @return An instance of MAPR_ReciprocalRelationshipSettings.
    *******************************************************************************************************/ 
    @TestVisible
    private Set<String> getMaleSalutationSet(){
        Set<String> maleLabelsSet = new Set<String>(this.getMaleLabelList());

        maleLabelsSet.add('Mr.');

        return maleLabelsSet;
    }
}
