/*
    Copyright (c) 2021, Salesforce.org
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
 * @date 2021
 * @group
 * @group-content ../../ApexDocContent/
 * @description Mapper class to return a list of RelationshipLookup models
 */
public virtual with sharing class RelationshipLookupMapper {
    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static RelationshipLookupMapper instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected RelationshipLookupMapper() {
    }

    /*****************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of RelationshipLookupMapper.
     ******************************************************************************/
    public static RelationshipLookupMapper getInstance() {
        if (instance == null) {
            instance = new RelationshipLookupMapper();
        }

        return instance;
    }

    /**********************************************************************************
     * @description Returns a list of RelationshipLookup models
     * @return List<RelationshipLookupModel> A list of RelationshipLookup models
     **********************************************************************************/
    public virtual List<RelationshipLookupModel> getRelationshipLookupModels() {
        List<RelationshipLookupModel> relationshipLookupModelsList = new List<RelationshipLookupModel>();
        List<Relationship_Lookup__c> relationshipLookupSettingsList = UTIL_CustomSettingsFacade.getReciprocalSettings();

        for (Relationship_Lookup__c each : relationshipLookupSettingsList) {
            RelationshipLookupModel relLookUpModel = new RelationshipLookupModel(
                each.Name,
                each.Active__c,
                each.Female__c,
                each.Male__c,
                each.Neutral__c
            );
            relationshipLookupModelsList.add(relLookUpModel);
        }

        return relationshipLookupModelsList;
    }

    /**
     * @description inserts a relationship lookup record
     * @param  relLookupModel A RelationshipLookupModel model of a new relationship lookup
     */
    public virtual void insertRelationshipLookupModel(RelationshipLookupModel relLookupModel) {
        Relationship_Lookup__c relLookupRecord = new Relationship_Lookup__c(
            Name = relLookupModel.name,
            Female__c = relLookupModel.femaleValue,
            Male__c = relLookupModel.maleValue,
            Neutral__c = relLookupModel.neutralValue,
            Active__c = relLookupModel.isActive
        );
        /* sfca-disable-next-line ApexFlsViolationRule */
        insert relLookupRecord;
    }

    /**
     * @description updates a relationship lookup record
     * @param  relationshipLookupName An old relationship lookup record name to update
     * @param  relLookupModel         A RelationshipLookupModel model of a relationship lookup to update
     */
    public virtual void updateRelationshipLookupModel(
        String relationshipLookupName,
        RelationshipLookupModel relLookupModel
    ) {
        Relationship_Lookup__c relLookupRecord = Relationship_Lookup__c.getInstance(relationshipLookupName);
        relLookupRecord.Name = relLookupModel.name;
        relLookupRecord.Female__c = relLookupModel.femaleValue;
        relLookupRecord.Male__c = relLookupModel.maleValue;
        relLookupRecord.Neutral__c = relLookupModel.neutralValue;
        relLookupRecord.Active__c = relLookupModel.isActive;
        /* sfca-disable-next-line ApexFlsViolationRule */
        update relLookupRecord;
    }

    /**
     * @description deletes a relationship lookup record
     * @param  relLookupModel A RelationshipLookupModel model of a relationship lookup to delete
     */
    public virtual void deleteRelationshipLookupModel(RelationshipLookupModel relLookupModel) {
        Relationship_Lookup__c relationshipLookupToDelete = Relationship_Lookup__c.getInstance(relLookupModel.name);
        String deletedRelationshipLookupName = relationshipLookupToDelete.Name;
        /* sfca-disable-next-line ApexFlsViolationRule */
        delete relationshipLookupToDelete;
    }
}
