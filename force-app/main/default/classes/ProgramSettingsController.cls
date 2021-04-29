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
     * @description Retrieve an instance of ProgramSettingsVModel representing the current values
     * specified for Settings fields in Hierarchy Settings.
     * @return An instance of ProgramSettingsVModel
     ************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static ProgramSettingsVModel getProgramSettingsVModel() {
        try {
            return ProgramSettingsController.locateProgramSettingsVMapper().getProgramSettingsVModel();
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
            return ProgramSettingsController.locateProgramSettingsVMapper()
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
            return ProgramSettingsController.locateProgramSettingsVMapper()
                .getAutoEnrollmentMappingRoleComboboxVModel(autoProgramEnrollmentRole);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /************************************************************************************
     * @description Update the affiliation mappping which owns the auto enrollment mapping.
     * @param mappingName
     * @param accRecordType
     * @return The name of the account record type.
     ************************************************************************************/
    @AuraEnabled
    public static String updateAutoEnrollmentMapping(
        String mappingName,
        String autoProgramEnrollmentStatus,
        String autoProgramEnrollmentRole
    ) {
        try {
            AffiliationMappingsModel afflMappingModel = new AffiliationMappingsModel(
                mappingName,
                null,
                null,
                null,
                autoProgramEnrollmentStatus,
                autoProgramEnrollmentRole
            );
            ProgramSettingsController.locateAffiliationMappingsService().updateAutoEnrolllmentMapping(afflMappingModel);

            return mappingName;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**********************************************************************************
     * @description Locates and returns an instance of AffiliationsSettingsVMapper.
     **********************************************************************************/
    @TestVisible
    private static ProgramSettingsVMapper locateProgramSettingsVMapper() {
        return ProgramSettingsVMapper.getInstance();
    }

    /*****************************************************************************
     * @description Retrieve an instance of the AffiliationMappingsService class.
     * @return An instance of AffiliationMappingsService.
     *****************************************************************************/
    @TestVisible
    private static AffiliationMappingsService locateAffiliationMappingsService() {
        return AffiliationMappingsService.getInstance();
    }
}
