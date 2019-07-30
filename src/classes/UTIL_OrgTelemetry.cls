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
        UsingOldContactEthnicity,
        UsingOldCourseDescription
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

        featureManager.setPackageIntegerValue(TelemetryParameterName.Data_CountCampaignMemberRelationshipRules.name(), campaignMemberRelationshipRules);
        
        featureManager.setPackageIntegerValue(TelemetryParameterName.Data_CountContactRelationshipRules.name(), contactRelationshipRules);
        
        featureManager.setPackageBooleanValue(TelemetryParameterName.IsEnabled_AutomaticHouseholdNaming.name(), edaSettings.Automatic_Household_Naming__c);
        
        featureManager.setPackageBooleanValue(TelemetryParameterName.IsEnabled_CourseConnections.name(), UTIL_CustomSettingsFacade.courseConnectionsEnabled());
        
        featureManager.setPackageBooleanValue(TelemetryParameterName.HasDefaultAdministrativeAccountModel.name(), 
            edaSettings.Account_Processor__c != null && edaSettings.Account_Processor__c == UTIL_Describe.getAdminAccRecTypeID());
        
        featureManager.setPackageBooleanValue(TelemetryParameterName.HasDefaultHouseholdAccountModel.name(), 
            edaSettings.Account_Processor__c != null && edaSettings.Account_Processor__c == UTIL_Describe.getHhAccRecTypeID());

        featureManager.setPackageBooleanValue(TelemetryParameterName.IsEnabled_ErrorHandling.name(), edaSettings.Disable_Error_Handling__c == false);

        featureManager.setPackageBooleanValue(TelemetryParameterName.HasCustomAdministrativeAccountNaming.name(), edaSettings.Admin_Account_Naming_Format__c == Label.acctNamingOther);

        featureManager.setPackageBooleanValue(TelemetryParameterName.HasCustomHouseholdAccountNaming.name(), edaSettings.Household_Account_Naming_Format__c == Label.acctNamingOther);

        featureManager.setPackageBooleanValue(TelemetryParameterName.HasValueInversionReciprocalMethod.name(), edaSettings.Reciprocal_Method__c == 'Value Inversion');

        featureManager.setPackageBooleanValue(TelemetryParameterName.IsEnabled_StoreErrors.name(), edaSettings.Store_Errors_On__c);
    }

    /**
     * @description Handles the calculation of all EDA feature telemetry that involves org-related
     configuration.
     */
    private void handleOrgEnvironmentTelemetry() {
        Integer activeCourseConnectionRecordTypes = 0;
        Integer activeEthnicityPicklistValues = 0;

        // Determine the number of active Course Connection record types.
        Map<String, Schema.RecordTypeInfo> courseConnectionRecordTypesByDeveloperName = 
                Schema.SObjectType.Course_Enrollment__c.getRecordTypeInfosByDeveloperName();
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

        featureManager.setPackageIntegerValue(TelemetryParameterName.Org_CountActiveCourseConnectionRecordTypes.name(), activeCourseConnectionRecordTypes);

        featureManager.setPackageBooleanValue(TelemetryParameterName.HasEDAInactiveTDTM.name(), 
                [SELECT COUNT() FROM Trigger_Handler__c WHERE Owned_By_Namespace__c = 'hed' AND Active__c = false] > 0);

        featureManager.setPackageBooleanValue(TelemetryParameterName.HasUserManagedTDTM.name(), 
                [SELECT COUNT() FROM Trigger_Handler__c WHERE User_Managed__c = true AND Active__c = true] > 0);

        featureManager.setPackageBooleanValue(TelemetryParameterName.UsingOldContactEthnicity.name(), activeEthnicityPicklistValues > 2);

        // TODO: Do we actually want to do this? We can't filter on Extended_Description__c and may not be able to select Description__c if its encrypted...
        //featureManager.setPackageBooleanValue(TelemetryParameterName.UsingOldCourseDescription.name(), 
                //[SELECT Id FROM Course__c WHERE Extended_Description__c = null AND Description__c != null LIMIT 1] > 0);
    }

    /**
     * @description Handles the calculation of all EDA feature telemetry that involves counting
     * custom object record count.
     */
    private void handleObjectUsageTelemetry() {
        Integer countAdministrativeAccounts = 0;
        if (UTIL_Describe.getAdminAccRecTypeID() != null) {
            countAdministrativeAccounts = [SELECT COUNT() FROM Account WHERE RecordTypeId = :UTIL_Describe.getAdminAccRecTypeID()];
        }

        Integer countHouseholdAccounts = 0;
        if (UTIL_Describe.getHhAccRecTypeID() != null) {
            countHouseholdAccounts = [SELECT COUNT() FROM Account WHERE RecordTypeId = :UTIL_Describe.getHhAccRecTypeID()];
        }
        
        featureManager.setPackageIntegerValue(TelemetryParameterName.Data_CountAdministrativeAccounts.name(), countAdministrativeAccounts);

        featureManager.setPackageIntegerValue(TelemetryParameterName.Data_CountHouseholdAccounts.name(), countHouseholdAccounts);

        featureManager.setPackageIntegerValue(TelemetryParameterName.Data_CountCourseConnections.name(), [SELECT COUNT() FROM Course_Enrollment__c]);

        featureManager.setPackageIntegerValue(TelemetryParameterName.Data_CountCourseOfferingSchedules.name(), [SELECT COUNT() FROM Course_Offering_Schedule__c]);

        featureManager.setPackageIntegerValue(TelemetryParameterName.Data_CountErrorLog.name(), [SELECT COUNT() FROM Error__c]);

        featureManager.setPackageIntegerValue(TelemetryParameterName.Data_CountFacilities.name(), [SELECT COUNT() FROM Facility__c]);

        featureManager.setPackageIntegerValue(TelemetryParameterName.Data_CountPlanRequirements.name(), [SELECT COUNT() FROM Plan_Requirement__c]);

        featureManager.setPackageIntegerValue(TelemetryParameterName.Data_CountProgramPlans.name(), [SELECT COUNT() FROM Program_Plan__c]);

        featureManager.setPackageIntegerValue(TelemetryParameterName.Data_CountTermGrades.name(), [SELECT COUNT() FROM Term_Grade__c]);
    }
}