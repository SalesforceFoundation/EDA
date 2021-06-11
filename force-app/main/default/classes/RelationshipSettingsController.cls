/*
    Copyright (c) 2021, Salesforce.org
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
 * @date 2021
 * @group EDA Settings
 * @group-content ../../ApexDocContent/EdaSettings.htm
 * @description Apex controller for Relationship settings LWC component.
 */
public with sharing class RelationshipSettingsController {
    /************************************************************************************
     * @description Retrieve an RelationshipSettingsVModel represeting the current values
     * specified for Relationship Settings fields in Hierarchy Settings.
     * @return An RelationshipSettingsVModel
     ************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static RelationshipSettingsVModel getRelationshipSettingsVModel() {
        try {
            return RelationshipSettingsController.locateRelationshipSettingsVMapper().getRelationshipSettingsVModel();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /************************************************************************************
     * @description Retrieve an RelationshipLookupsVModel represeting the current values
     * specified for Reciprocal Relationship mappings.
     * @return An RelationshipLookupsVModel
     ************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static RelationshipLookupsVModel getRelationshipLookupsVModel() {
        try {
            return RelationshipSettingsController.locateRelationshipLookupsVMapper().getRelationshipLookupsVModel();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description gets all active Relationship Type picklist values
     * @return   A ComboBoxVModel
     */
    @AuraEnabled(cacheable=true)
    public static ComboBoxVModel getActiveRelationshipTypesComboboxVModel() {
        try {
            return RelationshipSettingsController.locateRelationshipLookupsVMapper()
                .getActiveRelationshipTypesComboboxVModel();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Gets picklist values for a relationship name lookup.
     * For a new record returns all active unmapped Relationship Type picklist values
     * For an existing record returns all active Relationship Type picklist values plus the existing one if it is not active
     * @param  relationshipLookupName Specifies and existing relationship lookup name. Should be an empty string for a new record
     * @return                        A ComboBoxVModel
     */
    @AuraEnabled(cacheable=true)
    public static ComboBoxVModel getRelationshipLookupNameComboboxVModel(String relationshipLookupName) {
        try {
            return RelationshipSettingsController.locateRelationshipLookupsVMapper()
                .getRelationshipLookupNameComboboxVModel(relationshipLookupName);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description inserts a relationship lookup
     * @param  relationshipLookupName relationship lookup name
     * @param  femaleValue            female relationship type value
     * @param  maleValue              male relationship type value
     * @param  neutralValue           neutral relationship type value
     * @param  isActive               specifies if the lookup is active
     * @return                        inserted relationship lookup name
     */
    @AuraEnabled
    public static String createRelationshipLookup(
        String relationshipLookupName,
        String femaleValue,
        String maleValue,
        String neutralValue,
        Boolean isActive
    ) {
        try {
            return RelationshipSettingsController.locateRelationshipLookupSettingsService()
                .insertRelationshipLookup(relationshipLookupName, femaleValue, maleValue, neutralValue, isActive)
                .name;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description updates a relationship lookup
     * @param  oldRelationshipLookupName old relationship lookup name
     * @param  newRelationshipLookupName new relationship lookup name
     * @param  femaleValue               female relationship type value
     * @param  maleValue                 male relationship type value
     * @param  neutralValue              neutral relationship type value
     * @param  isActive                  specifies if the lookup is active
     * @return                           updated relationship lookup name
     */
    @AuraEnabled
    public static String updateRelationshipLookup(
        String oldRelationshipLookupName,
        String newRelationshipLookupName,
        String femaleValue,
        String maleValue,
        String neutralValue,
        Boolean isActive
    ) {
        try {
            return RelationshipSettingsController.locateRelationshipLookupSettingsService()
                .updateRelationshipLookup(
                    oldRelationshipLookupName,
                    newRelationshipLookupName,
                    femaleValue,
                    maleValue,
                    neutralValue,
                    isActive
                )
                .name;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description deletes a relationship lookup
     * @param  relationshipLookupName relationship lookup name to delete
     * @return                        deleted relationship lookup name or null if the record was not found
     */
    @AuraEnabled
    public static String deleteRelationshipLookup(String relationshipLookupName) {
        try {
            return RelationshipSettingsController.locateRelationshipLookupSettingsService()
                .deleteRelationshipLookup(relationshipLookupName)
                .name;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**********************************************************************************
     * @description Locates and returns an instance of RelationshipSettingsVMapper.
     **********************************************************************************/
    @TestVisible
    private static RelationshipSettingsVMapper locateRelationshipSettingsVMapper() {
        return RelationshipSettingsVMapper.getInstance();
    }

    /**********************************************************************************
     * @description Locates and returns an instance of RelationshipLookupsVMapper.
     * @return An instance of RelationshipLookupsVMapper
     **********************************************************************************/
    @TestVisible
    private static RelationshipLookupsVMapper locateRelationshipLookupsVMapper() {
        return RelationshipLookupsVMapper.getInstance();
    }

    /*****************************************************************************
     * @description Retrieve an instance of the RelationshipLookupSettingsService class.
     * @return An instance of RelationshipLookupSettingsService.
     *****************************************************************************/
    @TestVisible
    private static RelationshipLookupSettingsService locateRelationshipLookupSettingsService() {
        return RelationshipLookupSettingsService.getInstance();
    }
}
