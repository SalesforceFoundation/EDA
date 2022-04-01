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
public virtual with sharing class AFFL_MultiRecordTypeMapper {
    /*******************************************************************************************************
     * @description Map of Contact field names to Contact field labels.
     ********************************************************************************************************/
    public Map<String, String> contactFieldAPINameByLabel;

    /*******************************************************************************************************
     * @description Affiliation Account-record-type-to-Contact-field mappings.
     ********************************************************************************************************/
    public Map<String, String> primaryAfflFieldInMappingsByAccRecType;

    /*******************************************************************************************************
     * @description Account record type info, cached separately to maintain current functionality.
     ********************************************************************************************************/
    private static Map<String, Schema.RecordTypeInfo> accountRecordTypeInfosByName;
    @TestVisible
    private static Map<String, Schema.RecordTypeInfo> accountRecordTypeInfosByDeveloperName;
    //NOTE: Consider for refactor. This is a high risk area

    /*******************************************************************************************************
     * @description List of account record types in mappings.
     ********************************************************************************************************/
    public List<String> accountRecordTypesInMappings;

    /*******************************************************************************************************
     * @description List of valid account record types in mappings.
     ********************************************************************************************************/
    public List<String> validAccRecordTypesInMappings;

    /*******************************************************************************************************
     * @description Map of account record type names to primary affiliation mappings
     ********************************************************************************************************/
    private Map<String, Affl_Mappings__c> primaryAffiliationMappingsByAccountRecordTypeName;

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
        //NOTE: Target for Refactor to use UTIL_Describe in the future. Changing this is high-risk and disruptive
        List<SObjectField> contactFields = Contact.sObjectType.getDescribe().fields.getMap().values();
        //Map of Contact field labels to Contact field Names.
        this.contactFieldAPINameByLabel = this.getContactLabelsNamesMap(contactFields);
        //List of primary affiliation lookup fields names.
        List<String> contactFieldNames = this.contactFieldAPINameByLabel.values();

        //Get and cache account record type info by name.
        //NOTE: Consider refactor of this high-risk area
        AFFL_MultiRecordTypeMapper.accountRecordTypeInfosByName = SObjectType.Account.getRecordTypeInfosByName();
        AFFL_MultiRecordTypeMapper.accountRecordTypeInfosByDeveloperName = SObjectType.Account.getRecordTypeInfosByDeveloperName();
        // Map of Account RecordType Label To API
        //NOTE: Consider a refactor relative to case sensitivity
        this.accRecTypeLabelToAPI = this.getAccRecTypeLabelToAPIMap();

        //Note: Given the supportable number of records for affiliation mappings, having multiple small loops
        //is an acceptable and negligible performance hit so we can apply a separation of concerns for future refactoring.

        //Get the affiliation mappings we have available that do not have blank fields
        List<Affl_Mappings__c> populatedAffiliationMappings = this.getPopulatedAffiliationMappings();
        //Make a map of the raw account record types to contact fields
        this.primaryAfflFieldInMappingsByAccRecType = this.getRawContactFieldsByAccountRecordType(
            populatedAffiliationMappings
        );
        //Get all mapped account record types
        this.accountRecordTypesInMappings = this.getRawAccountRecordTypes(populatedAffiliationMappings);
        //List of Valid Account Record types in mappings
        //NOTE: Consider a refactor relative to case sensitivity. This is a high-risk area
        this.validAccRecordTypesInMappings = this.getValidAccRecordTypesInMappings(this.accountRecordTypesInMappings);
        //Get a map of account record type labels to Primary Affiliation Mapping
        this.primaryAffiliationMappingsByAccountRecordTypeName = this.getPrimaryAffiliationMappingsByAccountRecordTypeName(
            populatedAffiliationMappings,
            this.validAccRecordTypesInMappings,
            AFFL_MultiRecordTypeMapper.accountRecordTypeInfosByDeveloperName
        );

        //Contact Fields
        //List of primary affiliation lookup fields labels/API names from settings.
        List<String> primaryAfflFieldsInMappings = this.primaryAfflFieldInMappingsByAccRecType.values();
        //List of primary affiliation Contact fields.
        List<SObjectField> primaryAfflFields = this.getPrimaryAfflFields(contactFields, primaryAfflFieldsInMappings);
        //List of Valid Primary Contact Fields in mappings
        List<String> validContactAfflFields = this.getValidPrimaryAfflFields(primaryAfflFieldsInMappings);

        //Check if any mismatch in mappings
        if (
            UTIL_CustomSettingsFacade.getSettings().Affiliation_Record_Type_Enforced__c &&
            (primaryAfflFieldsInMappings.size() != validContactAfflFields.size() ||
            this.accountRecordTypesInMappings.size() != this.validAccRecordTypesInMappings.size())
        ) {
            throw new ERR_ExceptionHandler.AffAccountRecordTypeMappingsException(Label.afflAccoutMappingError);
        }

        UTIL_Debug.debug('****MRT: primaryAfflFieldNames: ' + JSON.serializePretty(primaryAfflFieldNames));
    }

    /**
     * @description Gets the contact field labels from the list of fields and produces a map of field names by labels
     * @param contactFieldsList The list of contact fields to parse into a map of names by labels
     * @return A map of contact field names by their labels
     */
    private Map<String, String> getContactLabelsNamesMap(List<SObjectField> contactFieldsList) {
        Map<String, String> labelsnames = new Map<String, String>();
        for (SObjectField field : contactFieldsList) {
            //NOTE: Consider this for a future refactor. This is a high-risk area
            labelsnames.put(field.getDescribe().getLabel(), field.getDescribe().getName());
        }
        return labelsnames;
    }

    // @Desription Returns a Map of Record type label to its API
    private Map<String, String> getAccRecTypeLabelToAPIMap() {
        Map<String, String> labelsnames = new Map<String, String>();
        for (RecordType field : [SELECT Name, DeveloperName FROM RecordType WHERE SobjectType = 'Account']) {
            labelsnames.put(field.Name, field.DeveloperName);
        }
        return labelsnames;
    }

    /**
     * @description Gets affiliation mappings that have a populated Account Record Type field and a populated Primary Affiliation Field
     * @return The List of affiliation mappings that do not have a blank Account Record Type or a blank Primary Affiliation Field
     */
    @TestVisible
    private List<Affl_Mappings__c> getPopulatedAffiliationMappings() {
        List<Affl_Mappings__c> affiliationMappings = UTIL_CustomSettingsFacade.getAfflMappings();
        List<Affl_Mappings__c> populatedAffiliationMappings = new List<Affl_Mappings__c>();

        for (Affl_Mappings__c mapping : affiliationMappings) {
            if (String.isBlank(mapping.Account_Record_Type__c) || String.isBlank(mapping.Primary_Affl_Field__c)) {
                continue;
            }
            populatedAffiliationMappings.add(mapping);
        }
        return populatedAffiliationMappings;
    }

    /**
     * @description Gets the account record types from a list of affiliation mappings
     * @param affiliationMappings The affiliation mappings to get the account record types from
     * @return The List of raw Account record types specified in the mappings
     */
    @TestVisible
    private List<String> getRawAccountRecordTypes(List<Affl_Mappings__c> affiliationMappings) {
        List<String> accountRecordTypes = new List<String>();

        for (Affl_Mappings__c mapping : affiliationMappings) {
            accountRecordTypes.add(mapping.Account_Record_Type__c);
        }
        return accountRecordTypes;
    }

    /**
     * @description Gets the Contact fields by the Account Record Type
     * @param affiliationMappings The affiliation mappings to get the Contact fields and Account Record Types from
     * @return The map of raw Account Record Types to raw Contact Primary Affiliation fields
     */
    @TestVisible
    private Map<String, String> getRawContactFieldsByAccountRecordType(List<Affl_Mappings__c> affiliationMappings) {
        Map<String, String> contactFieldsByAccountRecordType = new Map<String, String>();

        for (Affl_Mappings__c mapping : affiliationMappings) {
            contactFieldsByAccountRecordType.put(mapping.Account_Record_Type__c, mapping.Primary_Affl_Field__c);
        }
        return contactFieldsByAccountRecordType;
    }

    /**
     * @description Gets the map of valid Account Record Type labels to Primary Affiliation Mappings. Preserves behavior
     * of last in taking precedence to avoid a breaking change.
     * @param affiliationMappings The Affiliation Mappings to validate and map
     * @param validRawAccountRecordTypesInMappings The raw Account Record Types from the Primary Affiliation Mappings
     * @param accountRecordTypeInfosByDeveloperName The map of Account Recorc
     * @return The map of valid Account Record Type labels to Primary Affiliation Mappings
     */
    @TestVisible
    Map<String, Affl_Mappings__c> getPrimaryAffiliationMappingsByAccountRecordTypeName(
        List<Affl_Mappings__c> affiliationMappings,
        List<String> validRawAccountRecordTypesInMappings,
        Map<String, Schema.RecordTypeInfo> accountRecordTypeInfosByDeveloperName
    ) {
        Map<String, Affl_Mappings__c> primaryAffiliationsByAccountRecordTypeNames = new Map<String, Affl_Mappings__c>();

        for (Affl_Mappings__c affiliationMapping : affiliationMappings) {
            String rawAccountRecordType = affiliationMapping.Account_Record_Type__c;

            //This isn't a valid account record type, as previously confirmed
            if (validRawAccountRecordTypesInMappings.contains(rawAccountRecordType) == false) {
                continue;
            }

            //This isn't an API Name, so we know it's a label
            if (accountRecordTypeInfosByDeveloperName.containsKey(rawAccountRecordType) == false) {
                primaryAffiliationsByAccountRecordTypeNames.put(rawAccountRecordType, affiliationMapping);
                continue;
            }

            //This is an API name, so we need the label
            String accountRecordTypeName = accountRecordTypeInfosByDeveloperName.get(rawAccountRecordType).getName();
            primaryAffiliationsByAccountRecordTypeNames.put(accountRecordTypeName, affiliationMapping);
        }

        return primaryAffiliationsByAccountRecordTypeNames;
    }

    /***************************************************************************************************************
     * @description Returns those fields from the provided list that are in the provided list of labels or API names.
     * @param contactFields List of fields on Contact.
     * @param primaryAfflFieldsInMappings List of field labels or API Names.
     * @return List<SObjectField> List of fields in object that are in the provided list of labels or API names.
     ****************************************************************************************************************/
    private List<SObjectField> getPrimaryAfflFields(
        List<SObjectField> contactFields,
        List<String> primaryAfflFieldsInMappings
    ) {
        Set<String> uniqueprimaryAfflFieldsInMappings = new Set<String>(primaryAfflFieldsInMappings);
        List<SObjectField> primaryFields = new List<SObjectField>();
        primaryAfflFieldNames = new List<String>();
        //NOTE: Consider this for a future refactor. This is a high-risk area
        for (SObjectField field : contactFields) {
            if (
                uniqueprimaryAfflFieldsInMappings.contains(field.getDescribe().getLabel()) ||
                uniqueprimaryAfflFieldsInMappings.contains(field.getDescribe().getName())
            ) {
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
            String primaryAfflField = null;
            if (Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(recTypeName) != null) {
                ID rcId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
                if (rcId == recordTypeId) {
                    primaryAfflField = primaryAfflFieldInMappingsByAccRecType.get(recTypeName);
                }
            } else if (Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recTypeName) != null) {
                ID rcId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                    .get(recTypeName)
                    .getRecordTypeId();
                if (rcId == recordTypeId) {
                    primaryAfflField = primaryAfflFieldInMappingsByAccRecType.get(recTypeName);
                }
            } else {
                //Setup null pointer error message
                String[] params = new List<String>{ recTypeName };
                String nullPointerMsg = String.format(Label.afflNullPointerError, params);
                throw new AfflNullPointerException(nullPointerMsg);
            }
            if (primaryAfflField != null) {
                //Trying to find the mapped field by the field label first
                //Some customers might still have field labels stored in Affl_Mappings__c.Primary_Affl_Field__c
                String fieldName = contactFieldAPINameByLabel.get(primaryAfflField);
                if (fieldName != null) {
                    return fieldName;
                } else {
                    //If not found primaryAfflField should contain the field api name
                    return primaryAfflField;
                }
            }
        }
        return null;
    }

    public class AfflNullPointerException extends Exception {
    }

    /*******************************************************************************************************
     * @description Whether or not the affiliation requires a program enrollment to be auto-created.
     * @param affiliation The affiliation to check for program enrollment creations
     * @return Whether or not the affiliation requires a program enrollment to be auto-created.
     ********************************************************************************************************/
    public virtual Boolean needsProgramEnrollment(Affiliation__c affiliation) {
        if (affiliation?.Affiliation_Type__c == null) {
            return false;
        }

        Affl_Mappings__c affiliationMapping = primaryAffiliationMappingsByAccountRecordTypeName.get(
            affiliation.Affiliation_Type__c
        );

        if (affiliationMapping?.Auto_Program_Enrollment__c != true) {
            return false;
        }

        if (String.isBlank(affiliation.Role__c) || String.isBlank(affiliation.Status__c)) {
            return false;
        }

        if (
            affiliationMapping.Auto_Program_Enrollment_Role__c != affiliation.Role__c ||
            affiliationMapping.Auto_Program_Enrollment_Status__c != affiliation.Status__c
        ) {
            return false;
        }

        return true;
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
            if (
                AFFL_MultiRecordTypeMapper.accountRecordTypeInfosByName.containsKey(accRecordTypesInMapping) ||
                AFFL_MultiRecordTypeMapper.accountRecordTypeInfosByDeveloperName.containsKey(accRecordTypesInMapping)
            ) {
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
            if (
                this.contactFieldAPINameByLabel.keySet().contains(primaryAfflField) ||
                this.contactFieldAPINameByLabel.values().contains(primaryAfflField)
            ) {
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

        if (
            contactFieldAPINamesList != null &&
            contactFieldAPINamesList.isEmpty() == false &&
            contactFieldAPINamesList.contains(contactFieldFromSettings) == true
        ) {
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
