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
* @group-content ../../ApexDocContent/
* @description Mapper class for Preferred Email functionality. Returns MODL_PreferredEmailSettings model.
*/
public virtual with sharing class MAPR_CON_PreferredEmailFields {

    /*********************************************
    * @description Instance for Singleton Pattern
    **********************************************/
    @TestVisible
    private static MAPR_CON_PreferredEmailFields instance;

    /***********************************************
    * @description preferredEmailFieldSettingsModel
    ***********************************************/
    @TestVisible
    private static MODL_PreferredEmailSettings preferredEmailFieldSettingsModel;

    /*****************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of MAPR_CON_PreferredEmailFields.
    ******************************************************************************/
    public static MAPR_CON_PreferredEmailFields getInstance() {

        if (instance == null) {
            instance = new MAPR_CON_PreferredEmailFields();
        }

        return instance;
    }

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************/
    protected MAPR_CON_PreferredEmailFields() {}

    /**************************************************************************************
    * @description Returns the cached MODL_PreferredEmailSettings
    * @return MODL_PreferredEmailSettings
    **************************************************************************************/
    public MODL_PreferredEmailSettings getPreferredEmailSettingsModel() {

        if (preferredEmailFieldSettingsModel != null) {
            return preferredEmailFieldSettingsModel;
        }

        preferredEmailFieldSettingsModel = this.createEmailFieldSettingsModel();
        return preferredEmailFieldSettingsModel;
    }

    /**************************************************************************************
    * @description Returns the MODL_PreferredEmailSettings
    * @return MODL_PreferredEmailSettings
    **************************************************************************************/
    @TestVisible
    private MODL_PreferredEmailSettings createEmailFieldSettingsModel() {

        Boolean isPreferredEmailValidationEnabled = this.getPreferredEmailValidationEnabled();
        Map<String, Schema.DescribeFieldResult> contactEmailFieldsByApiName = this.getContactEmailFieldByApiName();
        String standardEmailFieldLabel = contactEmailFieldsByApiName.get('Email').getLabel();
        Map<String, String> preferredEmailPicklistValuesByLabel = this.getPreferredEmailPicklistValuesByLabel();
        Map<String, String> legacyPreferredEmailPicklistValuesByLabel = this.getLegacyPreferredEmailPicklistValuesByLabel();
        Map<String, String> preferredEmailPicklistLabelByApiName = this.getPreferredEmailPicklistLabelByApiName();
        String alternateEmailFieldPrefLabel;
        Map<String, String> edaEmailFieldAPINamesByLabel = this.getEDAEmailFieldsApiNamesByLabel(contactEmailFieldsByApiName);
        List<MODL_PreferredEmailField> prefEmailFieldModels = new List<MODL_PreferredEmailField>();
        EDAEmailFieldsModel edaEmailFieldModel = new EDAEmailFieldsModel(edaEmailFieldAPINamesByLabel);

        /* Construct a List of MODL_PreferredEmailField.cls records and alternateEmailFieldPrefLabel
           to be then used to create and return MODL_PreferredEmailSettings.cls record */
        for (String contactEmailfieldAPIName: contactEmailFieldsByApiName.keySet()) {

            String contactEmailFieldLabel = contactEmailFieldsByApiName.get(contactEmailfieldAPIName).getLabel();

            if (contactEmailfieldAPIName == standardEmailFieldLabel || edaEmailFieldModel.hasDuplicateLabelForEDAField(contactEmailFieldLabel, contactEmailfieldAPIName) == true) {
                continue;
            }

            String preferredLabel = this.getPreferredLabelFromLabel(contactEmailFieldLabel, preferredEmailPicklistValuesByLabel, legacyPreferredEmailPicklistValuesByLabel);
            MODL_PreferredEmailField prefEmailFieldModel = new MODL_PreferredEmailField(contactEmailFieldLabel, contactEmailfieldAPIName, PreferredLabel);

            if (contactEmailfieldAPIName == UTIL_Namespace.StrTokenNSPrefix('AlternateEmail__c')) {
                alternateEmailFieldPrefLabel = prefEmailFieldModel.preferredLabel ;
            }
            prefEmailFieldModels.add(prefEmailFieldModel);
        }

        MODL_PreferredEmailSettings prefEmailSettingsModel = new MODL_PreferredEmailSettings(prefEmailFieldModels, alternateEmailFieldPrefLabel, standardEmailFieldLabel, isPreferredEmailValidationEnabled, preferredEmailPicklistLabelByApiName);

        return prefEmailSettingsModel;
    }

    /**************************************************************************************
    * @description Returns the prefLabel that needs to be set for Preferred Email
    * @return prefLabel the prefLabel that needs to be set for Preferred Email
    **************************************************************************************/
    @TestVisible
    private String getPreferredLabelFromLabel(String emailTypeFieldLabel, Map<String, String> preferredEmailPicklistValuesByLabel, Map<String, String> legacyPreferredEmailPicklistValuesByLabel) {
        String prefLabel;
        if (preferredEmailPicklistValuesByLabel.containsKey(emailTypeFieldLabel)) {  
            prefLabel = preferredEmailPicklistValuesByLabel.get(emailTypeFieldLabel);
            return prefLabel;  
        }

        if (legacyPreferredEmailPicklistValuesByLabel.containsKey(emailTypeFieldLabel)) {  
            prefLabel = legacyPreferredEmailPicklistValuesByLabel.get(emailTypeFieldLabel);
            return prefLabel;  
        }

        prefLabel = emailTypeFieldLabel;
        return prefLabel;
    }

    /**************************************************************************************
    * @description Returns the value of Disable Preferred Email Enforcement custom settings
    * @return Boolean
    **************************************************************************************/
    @TestVisible
    private Boolean getPreferredEmailValidationEnabled() {
        return !UTIL_CustomSettingsFacade.getSettings().Disable_Preferred_Email_Enforcement__c;
    }

    /**************************************************************************************
    * @description Returns a map of Contact Email Field Describes by their API Names
    * @return Map<String, Schema.DescribeFieldResult>
    **************************************************************************************/
    @TestVisible
    private Map<String, Schema.DescribeFieldResult> getContactEmailFieldByApiName() {
        return UTIL_Describe.getFieldsOfType('Contact', 'EMAIL');
    }

    /**************************************************************************************
    * @description Returns a map of Preferred Email's picklist values by their labels
    * @return Map<String, String>
    **************************************************************************************/
    @TestVisible
    private Map<String, String> getPreferredEmailPicklistValuesByLabel() {
        return UTIL_Describe.getpicklistEntriesLabelToAPIMap('Contact', UTIL_Namespace.StrTokenNSPrefix('') + 'Preferred_Email__c');
    }

    /**************************************************************************************
    * @description Returns a map of Preferred Email's Legacy picklist values by their labels
    * @return Map<String, String>
    **************************************************************************************/
    @TestVisible
    private Map<String, String> getLegacyPreferredEmailPicklistValuesByLabel() {

        Map<String,String> legacyPreferredEmailPicklistValuesByLabel = new Map<String,String> {
                  'University Email' => 'University',
                 'Work Email' => 'Work',
                 'Alternate Email' => 'Alternate'
                };
      
        return legacyPreferredEmailPicklistValuesByLabel;            
    }

    /**************************************************************************************
    * @description Returns a map of Preferred Email's picklist Labels by their API names
    * @return Map<String, String>
    **************************************************************************************/
    @TestVisible
    private Map<String, String> getPreferredEmailPicklistLabelByApiName() {
        return UTIL_Describe.getPicklistEntriesApiToLabelMap('Contact', UTIL_Namespace.StrTokenNSPrefix('') + 'Preferred_Email__c');
    }

    /**************************************************************************************
    * @description Returns True if the API field name passed is an EDA field else false
    * @param fieldApiName The Contact Field's API name to check for
    * @return Boolean
    **************************************************************************************/
    @TestVisible
    private Boolean isEDAField(String fieldApiName) {

        String namespace = UTIL_Namespace.getNamespace();

        if (String.isNotBlank(namespace)) {
            return fieldApiName.startsWithIgnoreCase(namespace);
        }

        return fieldApiName.endsWithIgnoreCase('__c');
    }

    /**************************************************************************************
    * @description Returns A map of EDA Email Field Names By Label
    * @param contactFieldApiNames A map of Field Describes for Contact object by API names
    * @return edaEmailFieldAPINamesByLabels A map of EDA Email Field Names By Label
    **************************************************************************************/
    @TestVisible
    private Map<String,String> getEDAEmailFieldsApiNamesByLabel(Map<String, Schema.DescribeFieldResult> contactFieldApiNames) {

        Map<String, String> edaEmailFieldAPINamesByLabels = new Map<String, String>();

        for (String fieldApiName : contactFieldApiNames.keySet()) {
            if (this.isEDAField(fieldApiName) == true) {
                edaEmailFieldAPINamesByLabels.put(contactFieldApiNames.get(fieldApiName).getLabel(), fieldApiName);
            } 
        }

        return edaEmailFieldAPINamesByLabels;
    }

    /*******************************************************************************************************
    * @description A value object to determine if a field label or API name is a part of EDA Email fields
    ********************************************************************************************************/
    private class EDAEmailFieldsModel {

        private Map<String, String> edaEmailFieldApiNamesByLabel;
 
        private EDAEmailFieldsModel(Map<String, String> edaEmailFieldApiNamesByLabel) {
            this.edaEmailFieldApiNamesByLabel = edaEmailFieldApiNamesByLabel;
        }

        private Boolean hasDuplicateLabelForEDAField(String fieldLabel, String fieldApiName) {
            if (edaEmailFieldApiNamesByLabel.keySet().contains(fieldLabel) == false || 
                edaEmailFieldApiNamesByLabel.get(fieldLabel) != fieldApiName) {
                return true;
            }
            return false;
        }
    }

}
