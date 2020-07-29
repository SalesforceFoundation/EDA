/*
    Copyright (c) 2014, Salesforce.org
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
* @date 2015
* @group Affiliations
* @group-content ../../ApexDocContent/Affiliations.htm
* @description Helps with the mapping of Account record types to Account lookup fields on Contact defined
*				in the Affiliation Mapping custom settings.
*/
public with sharing class AFFL_MultiRecordTypeMapper {

    /*******************************************************************************************************
    * @description Map of Contact field names to Contact field labels.
    ********************************************************************************************************/
    public Map<String, String> contactFieldAPINameByLabel;
        
    /*******************************************************************************************************
    * @description Affiliation Account-record-type-to-Contact-field mappings.
    ********************************************************************************************************/
    public Map<String, String> primaryAfflFieldInMappingsByAccRecType;
    
    /*******************************************************************************************************
    * @description Affiliation Account-record-type-to-Academic-auto-create-field mappings.
    ********************************************************************************************************/
    public Map<String, Boolean> accTypeToEnrollCreate;
    public Map<String, String> accTypeToEnrollCreateRole;
    public Map<String, String> accTypeToEnrollCreateStatus;

    /*******************************************************************************************************
    * @description List of account record types in mappings.
    ********************************************************************************************************/
    public List<String> accountRecordTypes;

    /*******************************************************************************************************
    * @description List of valid account record types in mappings.
    ********************************************************************************************************/
    public List<String> validAccRecordTypesInMappings;

    /*******************************************************************************************************
    * @description List of primary affiliation lookup fields names on Contact.
    ********************************************************************************************************/
    public List<String> primaryAfflFieldNames;

    /*******************************************************************************************************
    * @description Map of Account Record Type Label to API
    ********************************************************************************************************/
    public Map<String, String> accRecTypeLabelToAPI;
    
    /*******************************************************************************************************
    * @description Constructor that initializes class properties.
    ********************************************************************************************************/
    public AFFL_MultiRecordTypeMapper() {
        //List of Contact field names.
        List<SObjectField> contactFields = Contact.sObjectType.getDescribe().fields.getMap().values();
        
        //Map of Contact field labels to Contact field Names.
        contactFieldAPINameByLabel = getContactLabelsNamesMap(contactFields);
        
        //List of primary affiliation lookup fields names.
        List<String> contactFieldNames = contactFieldAPINameByLabel.values();
        
        //Affiliation Account-record-type-to-Contact-field mappings.
        populateMaps();

        // Map of Account RecordType Label To API
        accRecTypeLabelToAPI = getAccRecTypeLabelToAPIMap();
        
        //List of primary affiliation lookup fields labels/API names from settings.
        List<String> primaryAfflFieldsInMappings = primaryAfflFieldInMappingsByAccRecType.values();
        
        //List of primary affiliation Contact fields.
        List<SObjectField> primaryAfflFields = getPrimaryAfflFields(contactFields, primaryAfflFieldsInMappings);

        //List of Valid Account Record types in mappings
        validAccRecordTypesInMappings = getValidAccRecordTypesInMappings(accountRecordTypes);

        //List of Valid Primary Contact Fields in mappings
        List<String> validContactAfflFields = getValidPrimaryAfflFields(primaryAfflFieldsInMappings);
        
        //Check if any mismatch in mappings
        if (UTIL_CustomSettingsFacade.getSettings().Affiliation_Record_Type_Enforced__c
                && (primaryAfflFieldsInMappings.size() != validContactAfflFields.size()
                    || accountRecordTypes.size() != validAccRecordTypesInMappings.size())) {
            throw new ERR_ExceptionHandler.AffAccountRecordTypeMappingsException(Label.afflAccoutMappingError);
        }

        UTIL_Debug.debug('****MRT: primaryAfflFieldNames: ' + JSON.serializePretty(primaryAfflFieldNames));
    }
    
    private Map<String, String> getContactLabelsNamesMap(List<SObjectField> contactFieldsList) {
        Map<String, String> labelsnames = new Map<String, String>();
        for (SObjectField field : contactFieldsList) {
            labelsnames.put(field.getDescribe().getLabel(), field.getDescribe().getName());
        }
        return labelsnames;
    }
    
    // @Desription Returns a Map of Record type label to its API
    private Map<String, String> getAccRecTypeLabelToAPIMap() {
        Map<String, String> labelsnames = new Map<String, String>();
        for (RecordType field : [SELECT  Name, DeveloperName FROM RecordType Where SobjectType = 'Account']) {
            labelsnames.put(field.Name, field.DeveloperName);
        }
        return labelsnames;
    }
    
    @testVisible
    private void populateMaps() {
        primaryAfflFieldInMappingsByAccRecType = new Map<String, String>();
        accTypeToEnrollCreate = new Map<String, Boolean>();
        accTypeToEnrollCreateRole = new Map<String, String>();
        accTypeToEnrollCreateStatus = new Map<String, String>();
        accountRecordTypes = new List<String>();

        //Put affl mappings in a map.
        for (Affl_Mappings__c mapping : UTIL_CustomSettingsFacade.getAfflMappings()) {
            if (!String.isBlank(mapping.Account_Record_Type__c) && !String.isBlank(mapping.Primary_Affl_Field__c)) {
                primaryAfflFieldInMappingsByAccRecType.put(mapping.Account_Record_Type__c, mapping.Primary_Affl_Field__c);
                accTypeToEnrollCreate.put(mapping.Account_Record_Type__c, mapping.Auto_Program_Enrollment__c);
                accTypeToEnrollCreateRole.put(mapping.Account_Record_Type__c, mapping.Auto_Program_Enrollment_Role__c);
                accTypeToEnrollCreateStatus.put(mapping.Account_Record_Type__c, mapping.Auto_Program_Enrollment_Status__c);
                accountRecordTypes.add(mapping.Account_Record_Type__c);
            }
        }
    }
    
    /***************************************************************************************************************
    * @description Returns those fields from the provided list that are in the provided list of labels or API names. 
    * @param contactFields List of fields on Contact.
    * @param primaryAfflFieldsInMappings List of field labels or API Names.
    * @return List<SObjectField> List of fields in object that are in the provided list of labels or API names.
    ****************************************************************************************************************/
    private List<SObjectField> getPrimaryAfflFields(List<SObjectField> contactFields, List<String> primaryAfflFieldsInMappings) {
        Set<String> uniqueprimaryAfflFieldsInMappings = new Set<String>(primaryAfflFieldsInMappings);
        List<SObjectField> primaryFields = new List<SObjectField>();
        primaryAfflFieldNames = new List<String>();
        for (SObjectField field : contactFields) {
            if (uniqueprimaryAfflFieldsInMappings.contains(field.getDescribe().getLabel()) || uniqueprimaryAfflFieldsInMappings.contains(field.getDescribe().getName())) {
                primaryAfflFieldNames.add(field.getDescribe().getName());
                primaryFields.add(field);
            }
        }
        return primaryFields;
    }
    
    /*******************************************************************************************************
    * @description Returns the name of the key affiliation Contact field that matches the Account record type provided.
    * @param recordTypeId The ID of an Account record type.
    * @return String The name of the key affiliation Contact field.
    ********************************************************************************************************/
    public String getKeyAfflFieldByAccRecordType(ID recordTypeId) {
        for (String recTypeName : primaryAfflFieldInMappingsByAccRecType.keySet()) {
            if (Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(recTypeName) != null) {
                ID rcId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
                if (rcId == recordTypeId) {
                    String fieldLabel = primaryAfflFieldInMappingsByAccRecType.get(recTypeName);
                    String fieldName = contactFieldAPINameByLabel.get(fieldLabel);
                    return fieldName;
                }
            } else if (Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recTypeName) != null) {
                ID rcId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recTypeName).getRecordTypeId();
                if(rcId == recordTypeId) {
                    String fieldLabel = primaryAfflFieldInMappingsByAccRecType.get(recTypeName);
                    String fieldName = contactFieldAPINameByLabel.get(fieldLabel);
                    return fieldName;
                }
            } else {
                //Setup null pointer error message
                String[] params = new String[]{
                    recTypeName
                };
                String nullPointerMsg = String.format(Label.afflNullPointerError, params);
                throw new AfflNullPointerException(nullPointerMsg);
            }
        }
        return null;
    }
    
    public class AfflNullPointerException extends Exception {}

    
    /*******************************************************************************************************
    * @description Tells caller if Account record type needs Program Enrollment auto-creation.
    * @param accountRecordType The name of the Account record type as entered in the Affiliation Mappings.
    * @return Boolean Whether the Account record type has been flagged as needing Academic Record auto-creation.
    ********************************************************************************************************/
    public Boolean needsProgramEnrollment(Affiliation__c affl) {
        Boolean autoEnrollment = false;
        String autoRole, autoStatus;
        if (affl.Affiliation_Type__c != null) {
            if (accTypeToEnrollCreate.get(affl.Affiliation_Type__c) != null) {
               autoEnrollment = accTypeToEnrollCreate.get(affl.Affiliation_Type__c);
            }
            autoRole = accTypeToEnrollCreateRole.get(affl.Affiliation_Type__c);
            autoStatus = accTypeToEnrollCreateStatus.get(affl.Affiliation_Type__c);
        }
        if (autoEnrollment && affl != null && affl.Role__c != null && autoRole == affl.Role__c && affl.Status__c != null 
        && autoStatus == affl.Status__c) { 
           return true;
        }
        return false;
    }

    /*******************************************************************************************************
    * @description Returns valid record types in Account Record type and contact primary field mapping.
    * @param accRecordTypesInMappings List of record types in mapping.
    * @return List<String> List of Valid record types in mapping.
    ********************************************************************************************************/
    @testVisible
    private List<String> getValidAccRecordTypesInMappings(List<String> accRecordTypesInMappings) {
        List<String> validAccRecordTypesInMappings = new List<String>();
        for (String accRecordTypesInMapping : accRecordTypesInMappings) {
            if (SObjectType.Account.getRecordTypeInfosByName().containsKey(accRecordTypesInMapping)
                 || SObjectType.Account.getRecordTypeInfosByDeveloperName().containsKey(accRecordTypesInMapping)) {
                validAccRecordTypesInMappings.add(accRecordTypesInMapping);
            }
        }
        return validAccRecordTypesInMappings;
    }

    /*******************************************************************************************************
    * @description Returns valid contact primary affiliation fields from mappings.
    * @param primaryAfflFieldsInMappings List of field labels/API Names from settings.
    * @return List<SObjectField> List of valid contact primary affiliation fields from mappings.
    ********************************************************************************************************/
    @testVisible
    private List<String> getValidPrimaryAfflFields(List<String> primaryAfflFieldsInMappings) {
        List<String> validPrimaryAfflFields = new List<String>();
        for (String primaryAfflField : primaryAfflFieldsInMappings) {
            if (this.contactFieldAPINameByLabel.keySet().contains(primaryAfflField) || this.contactFieldAPINameByLabel.values().contains(primaryAfflField)) {
                validPrimaryAfflFields.add(primaryAfflField);
            }
        }

        return validPrimaryAfflFields;
    }

    /*******************************************************************************************************************************
    * @description Returns the API name of the Primary Affiliation Lookup field from Affiliation_Type__c(Account Record Type Label)
    * @param affiliationType The value of Affiliation_Type__c on Affiliation which is also related Account's Record Type Label Name
    * @return primaryAfflLookupAPIName The API name of the Primary Affiliation Lookup field or null if not found
    *********************************************************************************************************************************/
    public String getPrimaryAffiliationLookupAPIFromAffiliationType(String affiliationType) {

        if (String.isBlank(affiliationType)) {
            return null;
        }

        String contactFieldFromSettings = this.getContactFieldFromSettings(affiliationType);

        if (String.isBlank(contactFieldFromSettings)) {
            return null;
        }

        String primaryAfflLookupAPIName = this.getPrimaryAffiliationLookupAPI(contactFieldFromSettings);

        if (String.isBlank(primaryAfflLookupAPIName)) {
            return null;
        }

        return primaryAfflLookupAPIName;
    }

    /*******************************************************************************************************************************
    * @description Returns the value in 'Contact Primary Affl Field' in EDA settings
    * @param affiliationType The value of Affiliation_Type__c on Affiliation which is also related Account's Record Type Label Name
    * @return contactFieldFromSettings The value in 'Contact Primary Affl Field' in EDA settings for a given Affiliation_Type__c or
              null if not found
    *********************************************************************************************************************************/
    @testVisible
    private String getContactFieldFromSettings(String affiliationType) {

        String contactFieldFromSettings = this.primaryAfflFieldInMappingsByAccRecType.get(affiliationType);

        if (String.isBlank(contactFieldFromSettings) == false) {
            return contactFieldFromSettings;
        }

        if (String.isBlank(contactFieldFromSettings)) {
            /* This means 'Account Record Type' in EDA settings is using API names for 'Account Record Type' in Affiliations mappings
            and we are trying to find by label name, which is Affiliation_Type__c. So first get the API name of the Account Record type
            from its label (affiliationType). Then use the record type's  API name to get the Contact's Priamry Affiliation's name
            from settings which could be either API or label. */

            String affiliationTypeAPI = this.accRecTypeLabelToAPI.get(affiliationType);
            contactFieldFromSettings = this.primaryAfflFieldInMappingsByAccRecType.get(affiliationTypeAPI);

            if (String.isBlank(contactFieldFromSettings) == false) {
                return contactFieldFromSettings;
            }
        }

        return null;
    }

    /*******************************************************************************************************************************
    * @description Returns the Primary Affiliation Lookup API name for the given Contact field on the settings
    * @param contactFieldFromSettings The value in 'Contact Primary Affl Field' from Settings
    * @return primaryAfflLookupAPIName The API name of the Primary Affiliation Lookup field or null if not found
    *********************************************************************************************************************************/
    @testVisible
    private String getPrimaryAffiliationLookupAPI(String contactFieldFromSettings) {

        /* Check if contactFieldFromSettings is in the List of Contact field API names,
         if yes, assign contactFieldFromSettings to primaryAfflLookupAPIName */

        List<String> contactFieldAPINamesList = this.contactFieldAPINameByLabel.values();
        String primaryAfflLookupAPIName;

        if (contactFieldAPINamesList != null && contactFieldAPINamesList.isEmpty() == false &&
            contactFieldAPINamesList.contains(contactFieldFromSettings) == true) {

            primaryAfflLookupAPIName = contactFieldFromSettings;

            if (String.isBlank(primaryAfflLookupAPIName) == false) {
                return primaryAfflLookupAPIName;
            }
        }

        /* If contactFieldFromSettings is not in the List of Contact field API names,
         assume it is Label and get the API name from it. */

        if (String.isBlank(primaryAfflLookupAPIName)) {
            primaryAfflLookupAPIName = this.contactFieldAPINameByLabel.get(contactFieldFromSettings);

            if (String.isBlank(primaryAfflLookupAPIName) == false) {
                return primaryAfflLookupAPIName;
            }
        }

        return null;
    }       
}