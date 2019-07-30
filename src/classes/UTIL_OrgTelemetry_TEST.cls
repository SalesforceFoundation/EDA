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
* @description Contains unit tests for testing the UTIL_OrgTelemetry and UTIL_OrgTelemetry_BATCH functionality.
*/
@isTest
private class UTIL_OrgTelemetry_TEST {

    private static UTIL_FeatureManagement_TEST.Mock featureManagementMock = new UTIL_FeatureManagement_TEST.Mock();

    /*******************************************************************************************************
    * @description Executes the EDA Telemetry batch job and asserts that it runs properly.
    ********************************************************************************************************/
    @isTest
    private static void validateTelemetryBatchJob() {
        Test.startTest();
        UTIL_OrgTelemetry.dispatchTelemetryBatchJob();
        Test.stopTest();

        System.assertEquals(true, UTIL_OrgTelemetry_BATCH.jobProcessed, 'Expected the EDA Telemetry batch job to process.');
    }

    /*******************************************************************************************************
    * @description Calls the processTelemetryType() method of the UTIL_OrgTelemetry class outside of the
    * context of the batch job to synchronously process the EDA_Settings batch category. Asserts that the
    * system sends the telemetry data to the UTIL_FeatureManagement wrapper class.
    ********************************************************************************************************/
    @IsTest
    private static void validateEDASettingsTelemetry() {
        Hierarchy_Settings__c edaSettings = UTIL_CustomSettingsFacade.getSettings();
        
        UTIL_FeatureManagement_TEST.Mock featureManagerMock = new UTIL_FeatureManagement_TEST.Mock();
        UTIL_OrgTelemetry orgTelemetry = new UTIL_OrgTelemetry();
        orgTelemetry.featureManager = (UTIL_FeatureManagement)Test.createStub(UTIL_FeatureManagement.class, featureManagerMock);

        Test.startTest();
        orgTelemetry.processTelemetryType(UTIL_OrgTelemetry.TelemetryBatchCategory.EDA_Settings);
        Test.stopTest();

        System.assertEquals(
            0,
            featureManagerMock.packageIntegerValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.Data_CountCampaignMemberRelationshipRules.name()
            ),
            'setPackageIntegerValue should have been called with the feature Data_CountCampaignMemberRelationshipRules'
        );

        System.assertEquals(
            0,
            featureManagerMock.packageIntegerValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.Data_CountContactRelationshipRules.name()
            ),
            'setPackageIntegerValue should have been called with the feature Data_CountContactRelationshipRules'
        );

        System.assertEquals(
            edaSettings.Automatic_Household_Naming__c,
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.IsEnabled_AutomaticHouseholdNaming.name()
            ),
            'setPackageBooleanValue should have been called with the feature IsEnabled_AutomaticHouseholdNaming'
        );

        System.assertEquals(
            UTIL_CustomSettingsFacade.courseConnectionsEnabled(),
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.IsEnabled_CourseConnections.name()
            ),
            'setPackageBooleanValue should have been called with the feature IsEnabled_CourseConnections'
        );

        System.assertEquals(
            edaSettings.Account_Processor__c == UTIL_Describe.getAdminAccRecTypeID(),
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.HasDefaultAdministrativeAccountModel.name()
            ),
            'setPackageBooleanValue should have been called with the feature HasDefaultAdministrativeAccountModel'
        );

        System.assertEquals(
            edaSettings.Account_Processor__c == UTIL_Describe.getHhAccRecTypeID(),
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.HasDefaultHouseholdAccountModel.name()
            ),
            'setPackageBooleanValue should have been called with the feature HasDefaultHouseholdAccountModel'
        );

        System.assertEquals(
            edaSettings.Disable_Error_Handling__c == false,
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.IsEnabled_ErrorHandling.name()
            ),
            'setPackageBooleanValue should have been called with the feature IsEnabled_ErrorHandling'
        );

        System.assertEquals(
            edaSettings.Admin_Account_Naming_Format__c == Label.acctNamingOther,
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.HasCustomAdministrativeAccountNaming.name()
            ),
            'setPackageBooleanValue should have been called with the feature HasCustomAdministrativeAccountNaming'
        );

        System.assertEquals(
            edaSettings.Household_Account_Naming_Format__c == Label.acctNamingOther,
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.HasCustomHouseholdAccountNaming.name()
            ),
            'setPackageBooleanValue should have been called with the feature HasCustomHouseholdAccountNaming'
        );

        System.assertEquals(
            edaSettings.Reciprocal_Method__c == 'Value Inversion',
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.HasValueInversionReciprocalMethod.name()
            ),
            'setPackageBooleanValue should have been called with the feature HasValueInversionReciprocalMethod'
        );

        System.assertEquals(
            edaSettings.Store_Errors_On__c,
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.IsEnabled_StoreErrors.name()
            ),
            'setPackageBooleanValue should have been called with the feature IsEnabled_StoreErrors'
        );
    }

    /*******************************************************************************************************
    * @description Calls the processTelemetryType() method of the UTIL_OrgTelemetry class outside of the
    * context of the batch job to synchronously process the Org_Environment batch category. Asserts that the
    * system sends the telemetry data to the UTIL_FeatureManagement wrapper class.
    ********************************************************************************************************/
    @IsTest
    private static void validateOrgEnvironmentTelemetry() {
        // Set one of the EDA TDTM classes to inactive.
        List<Trigger_Handler__c> defaultTDTM = TDTM_DefaultConfig.getDefaultRecords();
        defaultTDTM[0].Active__c = false;
        insert defaultTDTM;

        // Create a new user-managed TDTM class.
        Trigger_Handler__c userManagedHandler = new Trigger_Handler__c(
            Active__c = true,
            Asynchronous__c = false,
            Class__c = 'Test TDTM',
            Load_Order__c = 1,
            Object__c = 'Contact',
            Trigger_Action__c = 'BeforeInsert;BeforeUpdate',
            User_Managed__c = true
        );
        insert userManagedHandler;

        UTIL_FeatureManagement_TEST.Mock featureManagerMock = new UTIL_FeatureManagement_TEST.Mock();
        UTIL_OrgTelemetry orgTelemetry = new UTIL_OrgTelemetry();
        orgTelemetry.featureManager = (UTIL_FeatureManagement)Test.createStub(UTIL_FeatureManagement.class, featureManagerMock);

        Test.startTest();
        orgTelemetry.processTelemetryType(UTIL_OrgTelemetry.TelemetryBatchCategory.Org_Environment);
        Test.stopTest();

        System.assertEquals(
            3,
            featureManagerMock.packageIntegerValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.Org_CountActiveCourseConnectionRecordTypes.name()
            ),
            'setPackageIntegerValue should have been called with the feature Org_CountActiveCourseConnectionRecordTypes'
        );

        System.assertEquals(
            true,
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.HasEDAInactiveTDTM.name()
            ),
            'setPackageBooleanValue should have been called with the feature HasEDAInactiveTDTM'
        );

        System.assertEquals(
            true,
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.HasUserManagedTDTM.name()
            ),
            'setPackageBooleanValue should have been called with the feature HasUserManagedTDTM'
        );

        System.assertEquals(
            false,
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.UsingOldContactEthnicity.name()
            ),
            'setPackageBooleanValue should have been called with the feature UsingOldContactEthnicity'
        );

        // TODO:
        /*System.assertNotEquals(
            null,
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.UsingOldCourseDescription.name()
            ),
            'setPackageBooleanValue should have been called with the feature UsingOldCourseDescription'
        );*/
    }

    /*******************************************************************************************************
    * @description Calls the processTelemetryType() method of the UTIL_OrgTelemetry class outside of the
    * context of the batch job to synchronously process the Object_Usage batch category. Asserts that the
    * system sends the telemetry data to the UTIL_FeatureManagement wrapper class.
    ********************************************************************************************************/
    @IsTest
    private static void validateObjectUsageTelemetry() {
        Integer expectedAdministrativeAccounts = 5;
        Integer expectedHouseholdAccounts = 3;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(expectedAdministrativeAccounts);
        insert contacts;

        // Insert a few household accounts.
        List<Account> householdAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(expectedHouseholdAccounts, UTIL_Describe.getHhAccRecTypeID());
        insert householdAccounts;

        // Insert a few more random accounts.
        List<Account> businessAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(10, UTIL_Describe.getBizAccRecTypeID());
        insert businessAccounts;

        // Insert other random test records to test the object usage telemetry - course offerings, course connections, etc.
        Course_Offering__c courseOffering = UTIL_UnitTestData_TEST.createCourseOffering(null, null);

        List<Course_Enrollment__c> courseConnections = new List<Course_Enrollment__c>();
        for (Contact contact : contacts) {
            courseConnections.add(UTIL_UnitTestData_TEST.getCourseConnection(contact.Id, courseOffering.Id));
        }
        insert courseConnections;

        List<Course_Offering_Schedule__c> courseOfferingSchedules = new List<Course_Offering_Schedule__c>();
        courseOfferingSchedules.add(new Course_Offering_Schedule__c(Course_Offering__c = courseOffering.Id, Monday__c = true));
        courseOfferingSchedules.add(new Course_Offering_Schedule__c(Course_Offering__c = courseOffering.Id, Tuesday__c = true));
        courseOfferingSchedules.add(new Course_Offering_Schedule__c(Course_Offering__c = courseOffering.Id, Wednesday__c = true));
        courseOfferingSchedules.add(new Course_Offering_Schedule__c(Course_Offering__c = courseOffering.Id, Thursday__c = true));
        insert courseOfferingSchedules;

        List<Error__c> errors = UTIL_UnitTestData_TEST.getListOfErrors(25);
        insert errors;

        List<Facility__c> facilities = new List<Facility__c>{ UTIL_UnitTestData_TEST.getFacility() };
        insert facilities;

        List<Plan_Requirement__c> planRequirements = UTIL_UnitTestData_TEST.getMultipleTestPlanRequirements(30);
        insert planRequirements;

        List<Program_Plan__c> programPlans = UTIL_UnitTestData_TEST.getMultipleTestProgramPlans(12);
        insert programPlans;
        
        UTIL_FeatureManagement_TEST.Mock featureManagerMock = new UTIL_FeatureManagement_TEST.Mock();
        UTIL_OrgTelemetry orgTelemetry = new UTIL_OrgTelemetry();
        orgTelemetry.featureManager = (UTIL_FeatureManagement)Test.createStub(UTIL_FeatureManagement.class, featureManagerMock);

        Test.startTest();
        orgTelemetry.processTelemetryType(UTIL_OrgTelemetry.TelemetryBatchCategory.Object_Usage);
        Test.stopTest();

        System.assertEquals(
            expectedAdministrativeAccounts,
            featureManagerMock.packageIntegerValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.Data_CountAdministrativeAccounts.name()
            ),
            'setPackageIntegerValue should have been called with the feature Data_CountAdministrativeAccounts'
        );

        System.assertEquals(
            expectedHouseholdAccounts,
            featureManagerMock.packageIntegerValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.Data_CountHouseholdAccounts.name()
            ),
            'setPackageIntegerValue should have been called with the feature Data_CountHouseholdAccounts'
        );

        System.assertEquals(
            courseConnections.size(),
            featureManagerMock.packageIntegerValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.Data_CountCourseConnections.name()
            ),
            'setPackageIntegerValue should have been called with the feature Data_CountCourseConnections'
        );

        System.assertEquals(
            courseOfferingSchedules.size(),
            featureManagerMock.packageIntegerValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.Data_CountCourseOfferingSchedules.name()
            ),
            'setPackageIntegerValue should have been called with the feature Data_CountCourseOfferingSchedules'
        );

        System.assertEquals(
            errors.size(),
            featureManagerMock.packageIntegerValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.Data_CountErrorLog.name()
            ),
            'setPackageIntegerValue should have been called with the feature Data_CountErrorLog'
        );

        System.assertEquals(
            facilities.size(),
            featureManagerMock.packageIntegerValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.Data_CountFacilities.name()
            ),
            'setPackageIntegerValue should have been called with the feature Data_CountFacilities'
        );

        System.assertEquals(
            planRequirements.size(),
            featureManagerMock.packageIntegerValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.Data_CountPlanRequirements.name()
            ),
            'setPackageIntegerValue should have been called with the feature Data_CountPlanRequirements'
        );

        System.assertEquals(
            programPlans.size(),
            featureManagerMock.packageIntegerValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.Data_CountProgramPlans.name()
            ),
            'setPackageIntegerValue should have been called with the feature Data_CountProgramPlans'
        );

        System.assertEquals(
            0,
            featureManagerMock.packageIntegerValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.Data_CountTermGrades.name()
            ),
            'setPackageIntegerValue should have been called with the feature Data_CountTermGrades'
        );
    }
}