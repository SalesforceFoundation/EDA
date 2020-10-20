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
* @group-content ../../ApexDocContent/Contacts.htm
* @description Mapper class for CON_PrimaryLanguage_TDTM.
*/
public virtual with sharing class MAPR_PrimaryAffiliations {

    /*********************************************
    * @description Instance for Singleton Pattern
    **********************************************/
    @TestVisible
    private static MAPR_PrimaryAffiliations instance;

    /*****************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of MAPR_PrimaryAffiliations.
    ******************************************************************************/
    public static MAPR_PrimaryAffiliations getInstance() {
        if (instance == null) {
            instance = new MAPR_PrimaryAffiliations();
        }

        return instance;
    }

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************/
    protected MAPR_PrimaryAffiliations() {}

    /**************************************************************************************
    * @description Returns the value of Affiliation_Record_Type_Enforced__c custom setting
    * @return boolean
    **************************************************************************************/
    @testVisible
    protected virtual boolean isPrimaryAffiliationValidationOn() {
        return UTIL_CustomSettingsFacade.getSettings().Affiliation_Record_Type_Enforced__c;
    }

    /**************************************************************************************
    * @description Returns a list of Models for Affiliation mappings
    * @return List<MODL_PrimaryAfflMapper>
    **************************************************************************************/
    public List<MODL_PrimaryAfflMapper> getModelsFromSettings() {
        List<Affl_Mappings__c> afflMappingsFromSettingsList = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();
        return getModelsFromMappings(afflMappingsFromSettingsList);
    }

    /*********************************************************************************************************************
    * @description Returns a list of Models for Affiliation mappings for a given list of Affl_Mappings__c custom settings
    * @param afflMappingsList List of Affl_Mappings__c custom settings
    * @return List<MODL_PrimaryAfflMapper> List of models for the given list of Affl_Mappings__c custom settings
    *********************************************************************************************************************/
    @testVisible
    private List<MODL_PrimaryAfflMapper> getModelsFromMappings(List<Affl_Mappings__c> afflMappingsList) {

       List<MODL_PrimaryAfflMapper> affiliationModelsList = new List<MODL_PrimaryAfflMapper>();

       // Sets to ensure duplicate mappings won't have models added to the list to return
       Set<String> contactFieldAPINamesSet = new Set<String>();
       Set<String> accountRecordTypeIdsSet = new Set<String>();

        for (Affl_Mappings__c mapping: afflMappingsList) {

            MODL_PrimaryAfflMapper modelFromMapping = this.getModelFromMapping(mapping);

            if (modelFromMapping == null) {
                // Contact field affiliation mapping invalid
                continue;
            }

            if ((contactFieldAPINamesSet.isEmpty() == false && contactFieldAPINamesSet.contains(modelFromMapping.getContactFieldApiName())) || 
                (accountRecordTypeIdsSet.isEmpty() == false && accountRecordTypeIdsSet.contains(modelFromMapping.getAccountRecordTypeId()))) {      
                continue;
            }

            affiliationModelsList.add(modelFromMapping);
            contactFieldAPINamesSet.add(modelFromMapping.getContactFieldApiName());
            accountRecordTypeIdsSet.add(modelFromMapping.getAccountRecordTypeId());

        }
       return affiliationModelsList;
    }

    /*****************************************************************************************************
    * @description Returns a Model for a given Affl_Mappings__c record
    * @param afflMapping An Affl_Mappings__c custom settings record
    * @return MODL_PrimaryAfflMapper A model for given Affl_Mappings__c record
    *****************************************************************************************************/
    @testVisible
    private MODL_PrimaryAfflMapper getModelFromMapping(Affl_Mappings__c afflMapping) {

        Boolean isValid = true;

        List<MODL_PrimaryAfflMapper> primaryAfflModelsList = new List<MODL_PrimaryAfflMapper>();
        Set<Affl_Mappings__c> afflMappingSet = new Set<Affl_Mappings__c>();

        // Check if the Primary Affl Field an API name
        Schema.DescribeFieldResult primaryAfflFieldDescribe;

        try {
            primaryAfflFieldDescribe = UTIL_Describe.getFieldDescribe('Contact', afflMapping.Primary_Affl_Field__c);
        } catch (UTIL_Describe.SchemaDescribeException ex) {
            try{
                primaryAfflFieldDescribe = UTIL_Describe.getFieldDescribeByLabel('Contact', afflMapping.Primary_Affl_Field__c);
            } catch (UTIL_Describe.SchemaDescribeException exp) {
                return null;
            }
        }

        if (primaryAfflFieldDescribe == null) {
            // Affiliation mapping to Contact field that doesn't exist - skip mapping
            return null;
        }
        
        // Get the record type info by developer name
        Schema.RecordTypeInfo accountRecTypeInfo = UTIL_Describe.getRecordTypeInfoByDeveloperName('Account', afflMapping.Account_Record_Type__c);

        // If we don’t have a record type info, get the record type info by name
        if (accountRecTypeInfo == null) {
            accountRecTypeInfo = UTIL_Describe.getRecordTypeInfoByName('Account', afflMapping.Account_Record_Type__c);
        }

        if (accountRecTypeInfo == null) {
            if (this.isPrimaryAffiliationValidationOn() == true) {
                // Affiliation mapping to invalid record type
                isValid = false;
            }

            MODL_PrimaryAfflMapper primaryAfflModel = new MODL_PrimaryAfflMapper(primaryAfflFieldDescribe, afflMapping.Primary_Affl_Field__c, afflMapping.Account_Record_Type__c, isValid);       
            return primaryAfflModel;
        }

        MODL_PrimaryAfflMapper primaryAfflModel = new MODL_PrimaryAfflMapper(accountRecTypeInfo, primaryAfflFieldDescribe, afflMapping.Primary_Affl_Field__c, afflMapping.Account_Record_Type__c, isValid);
        return primaryAfflModel;
    }

}
