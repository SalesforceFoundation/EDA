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
 * @group Health Check
 * @group-content ../../ApexDocContent/HealthCheck.htm
 * @description Abstracts database data for Primary Affiliation Mappings, mapping them
 * to AffiliationMappingsModels.
 */
public virtual with sharing class AffiliationMappingsMapper {
    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static AffiliationMappingsMapper instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected AffiliationMappingsMapper() {
    }

    /*****************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of AffiliationMappingsMapper.
     ******************************************************************************/
    public static AffiliationMappingsMapper getInstance() {
        if (instance == null) {
            instance = new AffiliationMappingsMapper();
        }

        return instance;
    }

    /*****************************************************************************
     * @description Retrieves a list of models representing all Affiliation Mappings
     * configured in EDA Settings.
     * @return A list of AffiliationMappingsModel
     *****************************************************************************/
    public virtual List<AffiliationMappingsModel> getAffiliationMappingsModel() {
        List<AffiliationMappingsModel> primaryAfflMappinModelsList = new List<AffiliationMappingsModel>();
        List<Affl_Mappings__c> primaryAfflMappingsList = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();

        for (Affl_Mappings__c afflMapping : primaryAfflMappingsList) {
            primaryAfflMappinModelsList.add(
                new AffiliationMappingsModel(
                    afflMapping.Name,
                    afflMapping.Account_Record_Type__c,
                    afflMapping.Primary_Affl_Field__c,
                    afflMapping.Auto_Program_Enrollment__c,
                    afflMapping.Auto_Program_Enrollment_Status__c,
                    afflMapping.Auto_Program_Enrollment_Role__c
                )
            );
        }

        return primaryAfflMappinModelsList;
    }

    /*****************************************************************************
     * @description inserts an affiliation mapping record
     * @param affiliationMappingModel Model of an affiliation mappingto to insert
     *****************************************************************************/
    public void insertAffiliationMappingModel(AffiliationMappingsModel affiliationMappingModel) {
        Affl_Mappings__c affiliationMappings = new Affl_Mappings__c(
            name = affiliationMappingModel.name,
            Account_Record_Type__c = affiliationMappingModel.accountRecordTypeFieldValue,
            Primary_Affl_Field__c = affiliationMappingModel.primaryAffiliationField
        );
        /* sfca-disable-next-line ApexFlsViolationRule */
        insert affiliationMappings;
    }

    /*****************************************************************************
     * @description Updates affiliation mapping record
     * @param afflMappingModel Model to update affiliation mapping record from
     *****************************************************************************/
    public void updateAffiliationMappings(AffiliationMappingsModel afflMappingModel) {
        Affl_Mappings__c afflSettings = Affl_Mappings__c.getInstance(afflMappingModel.name);
        afflSettings.Account_Record_Type__c = afflMappingModel.accountRecordTypeFieldValue;
        afflSettings.Primary_Affl_Field__c = afflMappingModel.primaryAffiliationField;
        /* sfca-disable-next-line ApexFlsViolationRule */
        update afflSettings;
    }

    /*****************************************************************************
     * @description deletes an affiliation mapping record
     * @param affiliationMappingModel Model of an affiliation mappingto be deleted
     * @return A string representing the record type name associated with the deleted affiliation mapping
     *****************************************************************************/
    public String deleteAffiliationMappingModel(AffiliationMappingsModel affiliationMappingModel) {
        Affl_Mappings__c affiliationMappingsToDelete = Affl_Mappings__c.getInstance(affiliationMappingModel.name);
        String deletedPrimaryAffiliationRecordTypeName = affiliationMappingsToDelete.Account_Record_Type__c;
        /* sfca-disable-next-line ApexFlsViolationRule */
        delete affiliationMappingsToDelete;
        return deletedPrimaryAffiliationRecordTypeName;
    }
}
