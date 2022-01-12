/*
    Copyright (c) 2019, Salesforce.org
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
 * @date 2019
 * @group Utilities
 * @group-content ../../ApexDocContent/Utilities.htm
 * @description Collects information about the current org and EDA setup information
 * and sends it back to the EDA License Management Application to assist with better
 * understanding of how our customers use our application. This logic is called on
 * every push upgrade by the STG_InstallScript class.
 *
 * Uses "without sharing" so that it has full rights to query all records in all objects.
 * This is needed to ensure a consistent return of telemetry data even if the process is
 * called by different users with different permissions. Specifie PII is never queried or
 * returned by this class.
 */
public without sharing class UTIL_OrgTelemetry {
    @testVisible
    private UTIL_FeatureManagement featureManager = new UTIL_FeatureManagement();

    /**
     * @description A complete list of the Telemetry Types (at a high level) that are handled by this service class.
     * These are used by the batch job to process feature parameters in asynchronous groups to avoid governor
     * limit issues. The concept is that by separating each of these into smaller groupings that are processed
     * as separate child batch iterations, the entire process can complete even if for some reason one of the queries
     * against a table were to fail.
     */
    public enum TelemetryBatchCategory {
        EDA_Settings,
        Org_Environment,
        Object_Usage
    }

    /**
     * @description Each of these corresponds to the exact name of a FeatureParameter in the managed package.
     */
    public enum TelemetryParameterName {
        Data_CountAdministrativeAccounts,
        Data_CountHouseholdAccounts,
        Org_CountActiveCourseConnectionRecordTypes,
        Data_CountCampaignMemberRelationshipRules,
        Data_CountContactRelationshipRules,
        Data_CountCourseConnections,
        Data_CountCourseOfferingSchedules,
        Data_CountErrorLog,
        Data_CountFacilities,
        Data_CountPlanRequirements,
        Data_CountProgramPlans,
        Data_CountTermGrades,
        Data_CountAcademicCertifications,
        Data_CountCertificateAcademicCertifications,
        Data_CountDegreeAcademicCertifications,
        Data_CountDiplomaAcademicCertifications,
        Data_CountCredentials,
        Data_CountBadgeCredentials,
        Data_CountCertificationCredentials,
        Data_CountLicenseCredentials,
        IsEnabled_AutomaticHouseholdNaming,
        IsEnabled_CourseConnections,
        HasDefaultAdministrativeAccountModel,
        HasDefaultHouseholdAccountModel,
        IsEnabled_ErrorHandling,
        HasCustomAdministrativeAccountNaming,
        HasCustomHouseholdAccountNaming,
        HasEDAInactiveTDTM,
        HasUserManagedTDTM,
        HasValueInversionReciprocalMethod,
        IsEnabled_StoreErrors,
        HasErrorNotificationsAdminRecipients,
        UsingOldContactEthnicity,
        UsingOldCourseDescription,
        HasAffiliationsRelatedToDeletedProgramEnrollments,
        HasAffiliationStartDate,
        HasAffiliationEndDate,
        HasApplicationWindowValidation,
        Data_CountSeasonalAddresses,
        Data_CountCurrentYearSeasonalAddresses,
        AutodeleteNoContactHouseholdAcc,
        AutodeleteNoContactProgramAcc,
        AutodeleteNoContactEducationalInstitutionAcc,
        AutodeleteNoContactBusinessOrganizationAcc,
        AutodeleteNoContactUniversityDepartmentAcc,
        Data_CountAutoEnrollmentMappings
    }

    /**
     * @description Execute the batch job that will process each telemetry FeatureParameter type one at a time
     * as individual batch iterations. This process has to be asynchronous to handle governor limits against
     * huge queries as well as to avoid MixedDML errors in case a calling process were to modify a record.
     */
    public static void dispatchTelemetryBatchJob() {
        Database.executeBatch(new UTIL_OrgTelemetry_BATCH(), 1);
    }

    /**
     * @description Called by the batch job to process an individual telemetry type.
     * Submits specific feature telemetry statistics back to the License Management Org to assist
     * with understanding how our customers are using EDA functionality.
     * Each feature below must be matched to a SubscriberToLmo feature of the same name.
     * @param telemetryCategory The individual telemetry type to process.
     */
    public void processTelemetryType(TelemetryBatchCategory telemetryCategory) {
        switch on (telemetryCategory) {
            when EDA_Settings {
                handleEDASettingsTelemetry();
            }
            when Org_Environment {
                handleOrgEnvironmentTelemetry();
            }
            when Object_Usage {
                handleObjectUsageTelemetry();
            }
        }
    }

    /**
     * @description Handles the calculation of all EDA feature telemetry that involves the EDA
     * custom settings.
     */
    private void handleEDASettingsTelemetry() {
        Hierarchy_Settings__c edaSettings = UTIL_CustomSettingsFacade.getSettings();

        Integer campaignMemberRelationshipRules = 0;
        Integer contactRelationshipRules = 0;

        // Count the number of CampaignMember and Contact auto-create relationship rules.
        for (Relationship_Auto_Create__c rac : UTIL_CustomSettingsFacade.getAutoCreateSettings()) {
            if (rac.Object__c == 'CampaignMember') {
                campaignMemberRelationshipRules++;
            } else if (rac.Object__c == 'Contact') {
                contactRelationshipRules++;
            }
        }

        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountCampaignMemberRelationshipRules.name(),
            campaignMemberRelationshipRules
        );

        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountContactRelationshipRules.name(),
            contactRelationshipRules
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.IsEnabled_AutomaticHouseholdNaming.name(),
            edaSettings.Automatic_Household_Naming__c
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.IsEnabled_CourseConnections.name(),
            UTIL_CustomSettingsFacade.courseConnectionsEnabled()
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.HasDefaultAdministrativeAccountModel.name(),
            edaSettings.Account_Processor__c != null &&
            edaSettings.Account_Processor__c == UTIL_Describe.getAdminAccRecTypeID()
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.HasDefaultHouseholdAccountModel.name(),
            edaSettings.Account_Processor__c != null &&
            edaSettings.Account_Processor__c == UTIL_Describe.getCustomHHAccRecTypeID()
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.IsEnabled_ErrorHandling.name(),
            edaSettings.Disable_Error_Handling__c == false
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.HasCustomAdministrativeAccountNaming.name(),
            edaSettings.Admin_Account_Naming_Format__c == Label.acctNamingOther
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.HasCustomHouseholdAccountNaming.name(),
            edaSettings.Household_Account_Naming_Format__c == Label.acctNamingOther
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.HasValueInversionReciprocalMethod.name(),
            edaSettings.Reciprocal_Method__c == 'Value Inversion'
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.IsEnabled_StoreErrors.name(),
            edaSettings.Store_Errors_On__c
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.HasErrorNotificationsAdminRecipients.name(),
            edaSettings.Error_Notifications_To__c == 'All Sys Admins'
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.AutodeleteNoContactHouseholdAcc.name(),
            this.hasAutoDeletionHouseholdAccts(edaSettings)
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.AutodeleteNoContactProgramAcc.name(),
            this.hasAutoDeletionProgramAccts(edaSettings)
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.AutodeleteNoContactEducationalInstitutionAcc.name(),
            this.hasAutoDeletionEducationalInstitutionAccts(edaSettings)
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.AutodeleteNoContactBusinessOrganizationAcc.name(),
            this.hasAutoDeletionBusinessOrgAccts(edaSettings)
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.AutodeleteNoContactUniversityDepartmentAcc.name(),
            this.hasAutoDeletionUniversityDeptAccts(edaSettings)
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.HasAffiliationsRelatedToDeletedProgramEnrollments.name(),
            edaSettings.Affl_ProgEnroll_Del__c
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.HasAffiliationStartDate.name(),
            edaSettings.Affl_ProgEnroll_Copy_Start_Date__c
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.HasAffiliationEndDate.name(),
            edaSettings.Affl_ProgEnroll_Copy_End_Date__c
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.HasApplicationWindowValidation.name(),
            edaSettings.Application_Window_Validation__c
        );        
    }

    /**
     * @description Handles the calculation of all EDA feature telemetry that involves org-related
     configuration.
     */
    private void handleOrgEnvironmentTelemetry() {
        Integer activeCourseConnectionRecordTypes = 0;
        Integer activeEthnicityPicklistValues = 0;
        Boolean usingOldCourseDescription = false;

        // Determine the number of active Course Connection record types.
        Map<String, Schema.RecordTypeInfo> courseConnectionRecordTypesByDeveloperName = Schema.SObjectType.Course_Enrollment__c.getRecordTypeInfosByDeveloperName();

        for (String developerName : courseConnectionRecordTypesByDeveloperName.keySet()) {
            Schema.RecordTypeInfo rti = courseConnectionRecordTypesByDeveloperName.get(developerName);
            if (rti.getDeveloperName() != 'Master' && rti.isActive()) {
                activeCourseConnectionRecordTypes++;
            }
        }

        // Determine the number of active Ethnicity picklist values.
        Schema.DescribeFieldResult fieldResult = Contact.Ethnicity__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry pe : picklistEntries) {
            if (pe.isActive()) {
                activeEthnicityPicklistValues++;
            }
        }

        // Determine if the customer is using the new Extended Description field on the Course object.
        // For this, we look at the 500 most recently modified Course records.
        for (Course__c course : [
            SELECT Description__c, Extended_Description__c
            FROM Course__c
            ORDER BY LastModifiedDate DESC
            LIMIT 500
        ]) {
            if (course.Description__c != null && course.Extended_Description__c == null) {
                usingOldCourseDescription = true;
                break;
            }
        }

        integer numInactiveEDATriggers = [
            SELECT COUNT()
            FROM Trigger_Handler__c
            WHERE Owned_By_Namespace__c = 'hed' AND Active__c = FALSE
        ];

        integer numUserManagedTriggers = [
            SELECT COUNT()
            FROM Trigger_Handler__c
            WHERE User_Managed__c = TRUE AND Active__c = TRUE
        ];

        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Org_CountActiveCourseConnectionRecordTypes.name(),
            activeCourseConnectionRecordTypes
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.HasEDAInactiveTDTM.name(),
            numInactiveEDATriggers > 0
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.HasUserManagedTDTM.name(),
            numUserManagedTriggers > 0
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.UsingOldContactEthnicity.name(),
            activeEthnicityPicklistValues > 2
        );

        featureManager.setPackageBooleanValue(
            TelemetryParameterName.UsingOldCourseDescription.name(),
            usingOldCourseDescription
        );
    }

    /**
     * @description Handles the calculation of all EDA feature telemetry that involves counting
     * custom object record count.
     */
    private void handleObjectUsageTelemetry() {
        ObjectUsageTelemetryModel objectMetrics = new ObjectUsageTelemetryModel();

        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountAdministrativeAccounts.name(),
            objectMetrics.countAdministrativeAccounts
        );

        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountHouseholdAccounts.name(),
            objectMetrics.countHouseholdAccounts
        );

        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountCourseConnections.name(),
            objectMetrics.numCourseEnrollments
        );

        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountCourseOfferingSchedules.name(),
            objectMetrics.numCourseOfferingSchedules
        );

        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountErrorLog.name(),
            objectMetrics.numErrors
        );

        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountFacilities.name(),
            objectMetrics.numFacilities
        );

        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountPlanRequirements.name(),
            objectMetrics.numPlanRequirements
        );

        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountProgramPlans.name(),
            objectMetrics.numProgramPlans
        );

        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountTermGrades.name(),
            objectMetrics.numTermGrades
        );

        //Academic Certifications
        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountAcademicCertifications.name(),
            objectMetrics.numAcademicCertifications
        );

        //Academic Certifications - Certificate
        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountCertificateAcademicCertifications.name(),
            objectMetrics.countCertificateAcademicCertifications
        );

        //Academic Certifications - Degree
        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountDegreeAcademicCertifications.name(),
            objectMetrics.countDegreeAcademicCertifications
        );

        //Academic Certifications - Diploma
        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountDiplomaAcademicCertifications.name(),
            objectMetrics.countDiplomaAcademicCertifications
        );

        //Credentials
        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountCredentials.name(),
            objectMetrics.numCredentials
        );

        //Credentials - Badge
        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountBadgeCredentials.name(),
            objectMetrics.countBadgeCredentials
        );

        //Credentials - Certification
        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountCertificationCredentials.name(),
            objectMetrics.countCertificationCredentials
        );

        //Credentials - License
        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountLicenseCredentials.name(),
            objectMetrics.countLicenseCredentials
        );

        // Seasonal Addresses
        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountSeasonalAddresses.name(),
            objectMetrics.numSeasonalAddresses
        );

        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountCurrentYearSeasonalAddresses.name(),
            objectMetrics.numCurrentYearSeasonalAddesses
        );

        // Affilliation Mappings - Auto Enrollment
        featureManager.setPackageIntegerValue(
            TelemetryParameterName.Data_CountAutoEnrollmentMappings.name(),
            objectMetrics.numAutoEnrollmentAffMappings
        );
    }

    /**
     * @description Returns true if household accounts without contacts are marked
     * for deletion.
     */
    @TestVisible
    private Boolean hasAutoDeletionHouseholdAccts(Hierarchy_Settings__c edaSettings) {
        return this.hasContactAutoDeletionEnabled(edaSettings, Util_Describe.getHhAccRecTypeID());
    }

    /**
     * @description Returns true if academic program accounts without contacts are marked
     * for deletion.
     */
    @TestVisible
    private Boolean hasAutoDeletionProgramAccts(Hierarchy_Settings__c edaSettings) {
        return this.hasContactAutoDeletionEnabled(edaSettings, Util_Describe.getAcademicAccRecTypeID());
    }

    /**
     * @description Returns true if educational institution accounts without contacts are marked
     * for deletion.
     */
    @TestVisible
    private Boolean hasAutoDeletionEducationalInstitutionAccts(Hierarchy_Settings__c edaSettings) {
        return this.hasContactAutoDeletionEnabled(edaSettings, Util_Describe.getEducationalInstitutionAccRecTypeID());
    }

    /**
     * @description Returns true if business organization accounts without contacts are marked
     * for deletion.
     */
    @TestVisible
    private Boolean hasAutoDeletionBusinessOrgAccts(Hierarchy_Settings__c edaSettings) {
        return this.hasContactAutoDeletionEnabled(edaSettings, Util_Describe.getBizAccRecTypeID());
    }

    /**
     * @description Returns true if university department accounts without contacts are marked
     * for deletion.
     */
    @TestVisible
    private Boolean hasAutoDeletionUniversityDeptAccts(Hierarchy_Settings__c edaSettings) {
        return this.hasContactAutoDeletionEnabled(edaSettings, Util_Describe.getUniversityAccRecTypeID());
    }

    /**
     * @description Returns true if the specified account record type is enabled for contacts
     * auto-deletion.
     */
    private Boolean hasContactAutoDeletionEnabled(Hierarchy_Settings__c edaSettings, String accountRT) {
        Boolean isAutoDeleteConfigured = String.IsNotBlank(edaSettings.Accounts_to_Delete__c);
        Boolean isRecordTypeDefined = String.IsNotBlank(accountRT);

        if (isAutoDeleteConfigured && isRecordTypeDefined) {
            return edaSettings.Accounts_to_Delete__c.contains(accountRT);
        } else {
            return false;
        }
    }
}
