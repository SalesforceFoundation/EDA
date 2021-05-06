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
 * @group
 * @group-content ../../ApexDocContent/EdaSettings.htm
 * @description View mapper to generate view models associated with Affiliations with Program Enrollment funtionality.
 */
public virtual with sharing class AffiliationsWithProgramEnrollmentVMapper {
    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static AffiliationsWithProgramEnrollmentVMapper instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected AffiliationsWithProgramEnrollmentVMapper() {
    }

    /*****************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of AffiliationsWithProgramEnrollmentVMapper.
     ******************************************************************************/
    public static AffiliationsWithProgramEnrollmentVMapper getInstance() {
        if (instance == null) {
            instance = new AffiliationsWithProgramEnrollmentVMapper();
        }

        return instance;
    }

    /*****************************************************************************
     * @description Retrieve a vmodel representing the values available in Role
     * and settings picklist values of affiliaitons, and boolean values representing
     * Specify role, copy affiliaiton start date and copy affiliation end date.
     * @return An AffiliationsWithProgramEnrollmentVModel
     *****************************************************************************/
    public virtual AffiliationsWithProgramEnrollmentVModel getAffiliationsWithProgramEnrollmentVModel() {
        // get model representing current Affiliations With Program Enrollment settings in Hierarchy Settings
        AffiliationsWithProgramEnrollmentModel currentAffiliationsWithProgramEnrollmentModel = this.locateAffiliationsWithProgramEnrollmentService()
            .getAffiliationsWithProgramEnrollmentModel();

        /***** Get the comboboxvmodel for role *****/
        Map<String, PicklistEntryModel> allAffiliationRolePicklistEntryModelsByName = this.locatePicklistEntryService()
            .getModelsByNameForSObjectField(Affiliation__c.SObjectType, Affiliation__c.Role__c);

        Map<String, PicklistEntryModel> activeAffiliationRolePicklistEntryModelsByName = this.locatePicklistEntryService()
            .getActivePicklistEntryModelsByName(allAffiliationRolePicklistEntryModelsByName);

        List<ComboboxValueVModel> affiliationRoleComboboxValueVModelsList = new List<ComboboxValueVModel>();

        // add None option, maps to a blank value in hierarchy settings field
        affiliationRoleComboboxValueVModelsList.add(new ComboboxValueVModel(label.NoneOption, '""'));

        for (PicklistEntryModel picklistEntryModel : activeAffiliationRolePicklistEntryModelsByName.values()) {
            affiliationRoleComboboxValueVModelsList.add(
                new ComboboxValueVModel(picklistEntryModel.label, picklistEntryModel.name)
            );
        }

        String roleToDispaly = currentAffiliationsWithProgramEnrollmentModel.role;
        if (currentAffiliationsWithProgramEnrollmentModel.specifyRole == false) {
            roleToDispaly = '""';
        }

        ComboboxVModel affiliationRoleComboboxVModel = new ComboboxVModel(
            roleToDispaly,
            affiliationRoleComboboxValueVModelsList
        );

        /***** Get the comboboxvmodel for status *****/
        Map<String, PicklistEntryModel> allAffiliationStatusPicklistEntryModelsByName = this.locatePicklistEntryService()
            .getModelsByNameForSObjectField(Affiliation__c.SObjectType, Affiliation__c.Status__c);

        Map<String, PicklistEntryModel> activeAffiliationStatusPicklistEntryModelsByName = this.locatePicklistEntryService()
            .getActivePicklistEntryModelsByName(allAffiliationStatusPicklistEntryModelsByName);

        List<ComboboxValueVModel> affiliationStatusComboboxValueVModelsList = new List<ComboboxValueVModel>();
        // add None option, maps to a blank value in hierarchy settings field
        affiliationStatusComboboxValueVModelsList.add(new ComboboxValueVModel(label.NoneOption, '""'));

        for (PicklistEntryModel picklistEntryModel : activeAffiliationStatusPicklistEntryModelsByName.values()) {
            affiliationStatusComboboxValueVModelsList.add(
                new ComboboxValueVModel(picklistEntryModel.label, picklistEntryModel.name)
            );
        }

        ComboboxVModel affiliationStatusComboboxVModel = new ComboboxVModel(
            currentAffiliationsWithProgramEnrollmentModel.status,
            affiliationStatusComboboxValueVModelsList
        );

        return new AffiliationsWithProgramEnrollmentVModel(
            affiliationRoleComboboxVModel,
            affiliationStatusComboboxVModel,
            currentAffiliationsWithProgramEnrollmentModel.copyEndDate,
            currentAffiliationsWithProgramEnrollmentModel.copyStartDate
        );
    }

    /*****************************************************************************
     * @description Retrieves an instance of the AffiliationsWithProgramEnrollmentService class.
     * @return An instance of AffiliationsWithProgramEnrollmentService.
     ******************************************************************************/
    @TestVisible
    private AffiliationsWithProgramEnrollmentService locateAffiliationsWithProgramEnrollmentService() {
        return AffiliationsWithProgramEnrollmentService.getInstance();
    }

    /*****************************************************************************
     * @description Retrieves an instance of the PicklistEntryService class.
     * @return An instance of PicklistEntryService.
     ******************************************************************************/
    @TestVisible
    private PicklistEntryService locatePicklistEntryService() {
        return PicklistEntryService.getInstance();
    }
}
