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
 * @description Returns a list of RelationshipLookup models
 */
public virtual with sharing class RelationshipLookupSettingsService {
    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static RelationshipLookupSettingsService instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected RelationshipLookupSettingsService() {
    }

    /*****************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of RelationshipLookupSettingsService.
     ******************************************************************************/
    public static RelationshipLookupSettingsService getInstance() {
        if (instance == null) {
            instance = new RelationshipLookupSettingsService();
        }

        return instance;
    }

    /*******************************************************************************************************
     * @description Returns a List of RelationshipLookupModels
     * @return List<RelationshipLookupModel> The list of RelationshipLookupModels
     ********************************************************************************************************/
    public virtual List<RelationshipLookupModel> getRelationshipLookupModels() {
        return this.locateRelationshipLookupMapper().getRelationshipLookupModels();
    }

    /***************************************************************************
     * @description Retrieves a set of duplicate names from a list of models
     * @param relationshipLookupModelList The relationship lookup model list to
     * retrieve names from
     * @return The set of duplicate names
     ***************************************************************************/
    public Set<String> getDuplicateRelationshipModelNamesFromList(
        List<RelationshipLookupModel> relationshipLookupModelList
    ) {
        Set<String> nameSet = new Set<String>();
        Set<String> duplicateSet = new Set<String>();

        for (RelationshipLookupModel relationshipLookupModel : relationshipLookupModelList) {
            if (nameSet.contains(relationshipLookupModel.name)) {
                duplicateSet.add(relationshipLookupModel.name);
            } else {
                nameSet.add(relationshipLookupModel.name);
            }
        }

        return duplicateSet;
    }

    /**
     * @description inserts a relationship lookup
     * @param  relationshipLookupName relationship lookup name
     * @param  femaleValue            female relationship type value
     * @param  maleValue              male relationship type value
     * @param  neutralValue           neutral relationship type value
     * @param  isActive               specifies if the lookup is active
     * @return                        inserted relationship lookup model
     */
    public virtual RelationshipLookupModel insertRelationshipLookup(
        String relationshipLookupName,
        String femaleValue,
        String maleValue,
        String neutralValue,
        Boolean isActive
    ) {
        this.locateUserPermissionService().checkCustomizeApplicationForCurrentUser();
        RelationshipLookupModel relationshipLookupModelToInsert = new RelationshipLookupModel(
            relationshipLookupName,
            isActive,
            femaleValue,
            maleValue,
            neutralValue
        );

        this.locateRelationshipLookupMapper().insertRelationshipLookupModel(relationshipLookupModelToInsert);
        return relationshipLookupModelToInsert;
    }

    /**
     * @description updates a relationship lookup
     * @param  oldRelationshipLookupName old relationship lookup name
     * @param  newRelationshipLookupName new relationship lookup name
     * @param  femaleValue               female relationship type value
     * @param  maleValue                 male relationship type value
     * @param  neutralValue              neutral relationship type value
     * @param  isActive                  specifies if the lookup is active
     * @return                           updated relationship lookup model
     */
    public virtual RelationshipLookupModel updateRelationshipLookup(
        String oldRelationshipLookupName,
        String newRelationshipLookupName,
        String femaleValue,
        String maleValue,
        String neutralValue,
        Boolean isActive
    ) {
        this.locateUserPermissionService().checkCustomizeApplicationForCurrentUser();
        RelationshipLookupModel relationshipLookupModelToUpdate = new RelationshipLookupModel(
            newRelationshipLookupName,
            isActive,
            femaleValue,
            maleValue,
            neutralValue
        );
        this.locateRelationshipLookupMapper()
            .updateRelationshipLookupModel(oldRelationshipLookupName, relationshipLookupModelToUpdate);
        return relationshipLookupModelToUpdate;
    }

    /**
     * @description deletes a relationship lookup
     * @param  relationshipLookupName relationship lookup name to delete
     * @return                        deleted relationship lookup model or null if the record was not found
     */
    public virtual RelationshipLookupModel deleteRelationshipLookup(String relationshipLookupName) {
        if (this.locateUserPermissionService().checkCustomizeApplicationForCurrentUser() != true) {
            return null;
        }

        Relationship_Lookup__c relationshipLookupToDelete = Relationship_Lookup__c.getInstance(relationshipLookupName);

        if (relationshipLookupToDelete == null) {
            // no relationship lookup matching specified name
            return null;
        }

        RelationshipLookupModel relationshipLookupModelToDelete = new RelationshipLookupModel(
            relationshipLookupToDelete.name,
            relationshipLookupToDelete.Active__c,
            relationshipLookupToDelete.Female__c,
            relationshipLookupToDelete.Male__c,
            relationshipLookupToDelete.Neutral__c
        );

        this.locateRelationshipLookupMapper().deleteRelationshipLookupModel(relationshipLookupModelToDelete);
        return relationshipLookupModelToDelete;
    }

    /*****************************************************************************
     * @description Retrieves an instance of the UserPermissionService.
     * @return The instance of UserPermissionService.
     ******************************************************************************/
    @TestVisible
    private UserPermissionService locateUserPermissionService() {
        return UserPermissionService.getInstance();
    }

    /*******************************************************************************************************
     * @description Returns the instance of RelationshipLookupMapper class
     * @return The instance of RelationshipLookupMapper class
     ********************************************************************************************************/
    @TestVisible
    private RelationshipLookupMapper locateRelationshipLookupMapper() {
        return RelationshipLookupMapper.getInstance();
    }
}
