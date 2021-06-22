/**
 * @author Salesforce.org
 * @date 2021
 * @group
 * @group-content ../../ApexDocContent/
 * @description Model to represent data required for Primary Affiliation Mappings functionality.
 */

public with sharing class PrimaryAffiliationSettingsVModel {
    @AuraEnabled
    public List<PrimaryAffiliationMappingVModel> primaryAffiliationMappings { get; private set; }

    /*****************************************************************************************************************
     * @description one argument constructor
     * @param primaryAffiliationMappings The list of primary affiliation mappings view models
     *****************************************************************************************************************/
    public PrimaryAffiliationSettingsVModel(List<PrimaryAffiliationMappingVModel> primaryAffiliationMappings) {
        this.primaryAffiliationMappings = primaryAffiliationMappings;
    }
}
