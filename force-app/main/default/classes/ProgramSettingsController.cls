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
     * @description Retrieve an instance of AutoEnrollmentMappingsVModel representing the current values
     * specified for Settings fields in Hierarchy Settings.
     * @return An instance of AutoEnrollmentMappingsVModel
     ************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static AutoEnrollmentMappingsVModel getAutoEnrollmentMappingsVModel() {
        try {
            return ProgramSettingsController.locateAutoEnrollmentMappingsVMapper().getAutoEnrollmentMappingsVModel();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**********************************************************************************************************
     * @description Retrieve an integer representing the number of unmapped record types
     * @return The number of unmapped record types.
     *********************************************************************************************************/
    @AuraEnabled
    public static Boolean unmappedRecordTypesExist() {
        try {
            return ProgramSettingsController.locateAutoEnrollmentMappingsVMapper().unmappedRecordTypesExist();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /************************************************************************************
     * @description Retrieve a ComoboxVModel representing the list of active Account
     * Record Types
     * @return A ComboboxVModel
     ************************************************************************************/
    @AuraEnabled
    public static ComboBoxVModel getAccountRecordTypeComboboxVModel(String accountRecordType) {
        try {
            return ProgramSettingsController.locateAutoEnrollmentMappingsVMapper()
                .getAccountRecordTypeComboboxVModel(accountRecordType);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /************************************************************************************
     * @description Retrieve a ComoboxVModel for auto enrollment status.
     * @return A ComboboxVModel
     ************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static ComboBoxVModel getAutoEnrollmentMappingStatusComboboxVModel(String autoProgramEnrollmentStatus) {
        try {
            return ProgramSettingsController.locateAutoEnrollmentMappingsVMapper()
                .getAutoEnrollmentMappingStatusComboboxVModel(autoProgramEnrollmentStatus);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /************************************************************************************
     * @description Retrieve a ComoboxVModel for auto enrollment role.
     * @return A ComboboxVModel
     ************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static ComboBoxVModel getAutoEnrollmentMappingRoleComboboxVModel(String autoProgramEnrollmentRole) {
        try {
            return ProgramSettingsController.locateAutoEnrollmentMappingsVMapper()
                .getAutoEnrollmentMappingRoleComboboxVModel(autoProgramEnrollmentRole);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /***
     * @description Update the affiliation mappping with new auto enrollment mapping.
     * @param accountRecordType The account record type for the auto enrollment mapping
     * @param status The status for the auto enrollment mapping
     * @param role The role for the auto enrollment mapping
     * @return The account record type of the mapping updated.
     */
    @AuraEnabled
    public static String createAutoEnrollmentMapping(String accountRecordType, String status, String role) {
        try {
            return ProgramSettingsController.locateAutoEnrollmentMappingService()
                .createAutoEnrollmentMapping(accountRecordType, status, role)
                .accountRecordTypeFieldValue;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Updates auto enrollment mappings
     * @param mappingName The name of the original auto enrollment mapping
     * @param accountRecordType The account record type for the original auto enrollment mapping
     * @param newAccountRecordType The account record type for the updated auto enrollment mapping
     * @param status The status for the auto enrollment mapping
     * @param role The role for the auto enrollment mapping
     * @return The account record type of the mapping updated.
     */
    @AuraEnabled
    public static String updateAutoEnrollmentMappings(
        String mappingName,
        String accountRecordType,
        String newAccountRecordType,
        String status,
        String role
    ) {
        try {
            return ProgramSettingsController.locateAutoEnrollmentMappingService()
                .updateAutoEnrollmentMappings(mappingName, accountRecordType, newAccountRecordType, status, role)
                .accountRecordTypeFieldValue;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Deletes auto enrollment mapping
     * @param mappingName The name of the original auto enrollment mapping
     * @return The account record type of the mapping deleted or null if no mapping found.
     */
    @AuraEnabled
    public static String deleteAutoEnrollmentMappings(String mappingName) {
        try {
            AutoEnrollmentMappingModel deletedMappingModel = ProgramSettingsController.locateAutoEnrollmentMappingService()
                .deleteAutoEnrollmentMappings(mappingName);
            return deletedMappingModel == null ? null : deletedMappingModel.accountRecordTypeFieldValue;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /********************************************************************************
     * @description Retrieve a view model representing the Program Enrollment Deletion
     * settings specified in Hierarchy Settings.
     * @return A ProgramEnrollmentDeletionSettingsVModel.
     ********************************************************************************/
    @AuraEnabled(cacheable=true)
    public static ProgramEnrollmentDeletionSettingsVModel getProgramEnrollmentDeletionSettingsVModel() {
        try {
            return ProgramSettingsController.locateProgramEnrollmentDeletionSettingsVMapper()
                .getProgramEnrollmentDeletionSettingsVModel();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**********************************************************************************
     * @description Locates and returns an instance of ProgramSettingsVMapper.
     * @return An instance of ProgramSettingsVMapper
     **********************************************************************************/
    @TestVisible
    private static AutoEnrollmentMappingsVMapper locateAutoEnrollmentMappingsVMapper() {
        return AutoEnrollmentMappingsVMapper.getInstance();
    }

    /*****************************************************************************
     * @description Retrieve an instance of the AutoEnrollmentMappingService class.
     * @return An instance of AutoEnrollmentMappingService.
     *****************************************************************************/
    @TestVisible
    private static AutoEnrollmentMappingService locateAutoEnrollmentMappingService() {
        return AutoEnrollmentMappingService.getInstance();
    }

    /**********************************************************************************
     * @description Locates and returns an instance of ProgramEnrollmentDeletionSettingsVMapper.
     * @return An instance of ProgramEnrollmentDeletionSettingsVMapper
     **********************************************************************************/
    @TestVisible
    private static ProgramEnrollmentDeletionSettingsVMapper locateProgramEnrollmentDeletionSettingsVMapper() {
        return ProgramEnrollmentDeletionSettingsVMapper.getInstance();
    }
}
