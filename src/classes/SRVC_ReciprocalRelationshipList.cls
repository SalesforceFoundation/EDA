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
    /*********************************************
    * @description Instance for Singleton Pattern.
    **********************************************/
    @TestVisible
    private static SRVC_ReciprocalRelationshipList instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern.
    **********************************************************************/
    protected SRVC_ReciprocalRelationshipList() {}

    /*****************************************************************************
    * @description Static method to get the current instance for Singleton pattern.
    * @return The instance of SRVC_ReciprocalRelationshipList.
    ******************************************************************************/
    public static SRVC_ReciprocalRelationshipInversion getInstance() {
        if (SRVC_ReciprocalRelationshipList.instance == null) {
            SRVC_ReciprocalRelationshipList.instance = new SRVC_ReciprocalRelationshipList();
        }

        return SRVC_ReciprocalRelationshipList.instance;
    }

    /*****************************************************************************
    * @description Get the relationships to update from map of contact and map of relationship to update if reciprocal method is inversion.
    * @param newContactRelationshipToUpdateByIdMap Map of contact whose relationships need to be updated.
    * @param relationshipsByIdToUpdateMap Map of relationship to update.
    * @return The relationships to update.
    ******************************************************************************/
    public override List<Relationship__c> getRelationshipsToUpdateForContacts(Map<Id, Contact> newContactRelationshipToUpdateByIdMap, Map<Id, Relationship__c> relationshipsByIdToUpdateMap) {
        List<Relationship__c> relationshipsToUpdateList = new List<Relationship__c>();

        //     * Get the a ReciprocalRelationshipMappingModel by name (String) map using locateReciprocalRelationshipMapper().getActiveMappingModels()
        Map<String, MODL_ReciprocalRelationshipMapping> activeMappingModels = this.locateReciprocalRelationshipMapper().getActiveMappingModelsFromRelationshipLookups();
        //     * Get the set of female genders using  getFemaleGenderSet()
        Set<String> femaleGendersSet = this.getFemaleGenderSet();
        //     * Get the set of male genders using getMaleGenderSet()
        Set<String> maleGendersSet = this.getMaleGenderSet();
        //     * Get the set of female salutations using  getFemaleSalutationSet()
        Set<String> femaleSalutationSet = this.getFemaleSalutationSet();
        //     * Get the set of male salutations using getMaleSalutationSet()
        Set<String> maleSalutationSet = this.getMaleSalutationSet();

        for (Relationship__c relationship : relationshipsByIdToUpdateMap.values()) {
            if (this.isRelationshipReciprocal(relationship, newContactRelationshipToUpdateByIdMap.keySet()) == false) {
                //* Get the reciprocal relationship using the relationship map
                Relationship__c reciprocalRelationship = relationshipsByIdToUpdateMap.get(relationship.ReciprocalRelationship__c);

                //* Get the Mapping Model from the settings map using the Relationship’s Type
                MODL_ReciprocalRelationshipMapping reciprocalRelationshipMappingModel = activeMappingModels.get(relationship.Type__c);
       
                //* If that model is null
                if (reciprocalRelationshipMappingModel == null) {
                    //* Add getRelationshipToUpdateWithoutMapping(reciprocalRelationship,relationship.Type__c) to the list to update
                    relationshipsToUpdateList.add(this.getRelationshipToUpdateWithoutMapping(reciprocalRelationship, relationship.Type__c));
                    //continue
                    continue;
                } 

                //Get the contact for the relationship using the contact map
                Contact xxxContact = newContactRelationshipToUpdateByIdMap.get(relationship.Contact__c);
                //If the contact’s gender is not null
                if (xxxContact.Gender__c != null) {
                    //* Get getRelationshipToUpdateFromGender(reciprocalRelationship,contact,mappingModel,salutationSetsModel)
                    //* If that value is not null
                        //* If a relationship was returned
                        //* Add the relationship to the list to update
                        //* continue  
                }

                //* Add getRelationshipToUpdateFromSalutation(reciprocalRelationship,contact,mappingModel,salutationSetsModel) to the list to update
                relationshipsToUpdateList.add(this.getRelationshipToUpdateFromSalutation(reciprocalRelationship, xxxContact, reciprocalRelationshipMappingModel, salutationSetsModel));
            }
        }
            
        return relationshipsToUpdateList;
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
    * TODO: @description Retrieves an instance of the MAPR_ReciprocalRelationshipSettings service class.
    * @return An instance of MAPR_ReciprocalRelationshipSettings.
    *******************************************************************************************************/ 
    @TestVisible
    private Set<String> getFemaleGenderSet(){
        return getGenderSet(getFemaleLabelList());
    }

    /*******************************************************************************************************
    * TODO: @description Retrieves an instance of the MAPR_ReciprocalRelationshipSettings service class.
    * @return An instance of MAPR_ReciprocalRelationshipSettings.
    *******************************************************************************************************/ 
    @TestVisible
    private Set<String> getMaleGenderSet(){
        return getGenderSet(getMaleLabelList());
    }

    /*******************************************************************************************************
    * TODO: @description Retrieves an instance of the MAPR_ReciprocalRelationshipSettings service class.
    * @return An instance of MAPR_ReciprocalRelationshipSettings.
    *******************************************************************************************************/ 
    @TestVisible
    private List<String> getFemaleLabelList(){
        return (Label.Female).split(',');
    }

    /*******************************************************************************************************
    * TODO: @description Retrieves an instance of the MAPR_ReciprocalRelationshipSettings service class.
    * @return An instance of MAPR_ReciprocalRelationshipSettings.
    *******************************************************************************************************/ 
    @TestVisible
    private List<String> getMaleLabelList(){
        return (Label.Male).split(',');
    }

    /*******************************************************************************************************
    * TODO: @description Retrieves an instance of the MAPR_ReciprocalRelationshipSettings service class.
    * @return An instance of MAPR_ReciprocalRelationshipSettings.
    *******************************************************************************************************/ 
    @TestVisible
    private List<String> getFemaleSalutationSet(){
        Set<String> femaleLabelsSet = new Set<String>(this.getFemaleLabelList());

        femaleLablesSet.add('Mrs.');
        femaleLablesSet.add('Ms.');

        return femaleLablesSet;
    }

    /*******************************************************************************************************
    * TODO: @description Retrieves an instance of the MAPR_ReciprocalRelationshipSettings service class.
    * @return An instance of MAPR_ReciprocalRelationshipSettings.
    *******************************************************************************************************/ 
    @TestVisible
    private List<String> getMaleSalutationSet(){
        Set<String> maleLabelsSet = new Set<String>(this.getMmaleLabelList());

        maleLabelsSet.add('Mr.');

        return maleLabelsSet;
    }
}

