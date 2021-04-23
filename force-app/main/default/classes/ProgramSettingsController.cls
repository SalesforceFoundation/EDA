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
 * @description Apex controller for Program Settings page.
 */
public with sharing class ProgramSettingsController {
    /************************************************************************************
     * @description Retrieve an AffiliationsSettingsVModel representing the current values
     * specified for Affiliations Settings fields in Hierarchy Settings.
     * @return An AffiliationsSettingsVModel
     ************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static AffiliationsSettingsVModel getAffiliationsSettingsVModel() {
        try {
            return AffiliationsSettingsController.locateAffiliationsSettingsVMapper()
                .getAffiliationsSettingsViewModel();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /********************************************************************************************************************************************
     * @description Insert a new Affiliation Mapping custom setting; auto-enrollment settings are defaulted to false and blank values.
     * @param  mappingName A string representing the name of the new affiliation mapping
     * @param  recordTypeName A string representing the Record Type name for the new affiliation mapping
     * @param  contactFieldName A string representing the field label for the Contact primary affiliation field associated with the new affiliation mapping
     ********************************************************************************************************************************************/
    @AuraEnabled
    public static String insertAffiliationMappings(String mappingName, String recordTypeName, String contactFieldName) {
        try {
            AffiliationsSettingsController.locateAffiliationMappingsService()
                .insertAffiliationMappings(mappingName, recordTypeName, contactFieldName);

            RecordTypeModel accRecTypeModel = AffiliationsSettingsController.locateRecordTypeService()
                .getRecordTypeModelFromRecTypeDevName('Account', recordTypeName);

            if (accRecTypeModel == null) {
                return recordTypeName;
            }

            return accRecTypeModel.name;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /************************************************************************************
     * @description Retrieve a PrimaryAffiliationSettingsVModel representing the current values
     * specified for Affiliations Mappings.
     * @return A PrimaryAffiliationSettingsVModel
     ************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static PrimaryAffiliationSettingsVModel getPrimaryAffiliationsSettingsVModel() {
        try {
            return AffiliationsSettingsController.locatePrimaryAffiliationsSettingsVMapper()
                .getPrimaryAffiliationsSettingsVModel();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /************************************************************************************
     * @description Updates Affiliation mapping custom settings
     * @param mappingName
     * @param accRecordType
     * @param conPrimaryAfflField
     * @return An AffiliationsSettingsVModel
     ************************************************************************************/
    @AuraEnabled
    public static String updateAffiliationMappings(
        String mappingName,
        String accRecordType,
        String conPrimaryAfflField
    ) {
        try {
            AffiliationsSettingsController.locateAffiliationMappingsService()
                .updateAffiliationMappings(mappingName, accRecordType, conPrimaryAfflField);

            RecordTypeModel accRecTypeModel = AffiliationsSettingsController.locateRecordTypeService()
                .getRecordTypeModelFromRecTypeDevName('Account', accRecordType);

            if (accRecTypeModel == null) {
                return accRecordType;
            }

            return accRecTypeModel.name;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /********************************************************************************************************************************************
     * @description Overloaded method to insert a new Affiliation Mapping custom setting with auto-enrollment settings specified.
     * @param  mappingName A string representing the name of the new affiliation mapping
     * @return A string representing the Account Record Name associated with the deleted affiliation mapping.
     ********************************************************************************************************************************************/
    @AuraEnabled
    public static String deleteAffiliationMapping(String mappingName) {
        try {
            return AffiliationsSettingsController.locateAffiliationMappingsService()
                .deleteAffiliationMapping(mappingName);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /************************************************************************************
     * @description Retrieve a ComoboxVModel representing the list of active Account
     * Record Types
     * @return A ComboboxVModel
     ************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static ComboBoxVModel getAccountRecordTypeComboboxVModel(String recordTypeToCheck) {
        try {
            return AffiliationsSettingsController.locatePrimaryAffiliationsSettingsVMapper()
                .getAccountRecordTypeComboboxVModel(recordTypeToCheck);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /************************************************************************************
     * @description Retrieve a ComoboxVModel representing the list of active Account
     * Record Types
     * @return A ComboboxVModel
     ************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static ComboBoxVModel getContactAccountLookupFieldComboboxVModel(String contactFieldToCheck) {
        try {
            return AffiliationsSettingsController.locatePrimaryAffiliationsSettingsVMapper()
                .getContactAccountLookupFieldComboboxVModel(contactFieldToCheck);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**********************************************************************************
     * @description Locates and returns an instance of AffiliationsSettingsVMapper.
     **********************************************************************************/
    @TestVisible
    private static AffiliationsSettingsVMapper locateAffiliationsSettingsVMapper() {
        return AffiliationsSettingsVMapper.getInstance();
    }

    /**********************************************************************************
     * @description Locates and returns an instance of AffiliationMappingsService.
     **********************************************************************************/
    @TestVisible
    private static AffiliationMappingsService locateAffiliationMappingsService() {
        return AffiliationMappingsService.getInstance();
    }

    /**********************************************************************************
     * @description Locates and returns an instance of PrimaryAffiliationsSettingsVMapper.
     **********************************************************************************/
    @TestVisible
    private static PrimaryAffiliationsSettingsVMapper locatePrimaryAffiliationsSettingsVMapper() {
        return PrimaryAffiliationsSettingsVMapper.getInstance();
    }

    /**********************************************************************************
     * @description Locates and returns an instance of RecordTypeService.
     **********************************************************************************/
    @TestVisible
    private static RecordTypeService locateRecordTypeService() {
        return RecordTypeService.getInstance();
    }
}
