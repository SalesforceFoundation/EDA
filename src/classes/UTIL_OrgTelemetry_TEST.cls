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
        UTIL_FeatureManagement_TEST.Mock featureManagerMock = new UTIL_FeatureManagement_TEST.Mock();
        UTIL_OrgTelemetry orgTelemetry = new UTIL_OrgTelemetry();
        orgTelemetry.featureManager = (UTIL_FeatureManagement)Test.createStub(UTIL_FeatureManagement.class, featureManagerMock);

        Test.startTest();
        orgTelemetry.processTelemetryType(UTIL_OrgTelemetry.TelemetryBatchCategory.EDA_Settings);
        Test.stopTest();

        System.assertNotEquals(
            null,
            featureManagerMock.packageIntegerValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.Data_CountCampaignMemberRelationshipRules.name()
            ),
            'setPackageIntegerValue should have been called with the feature Data_CountCampaignMemberRelationshipRules'
        );

        System.assertNotEquals(
            null,
            featureManagerMock.packageIntegerValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.Data_CountContactRelationshipRules.name()
            ),
            'setPackageIntegerValue should have been called with the feature Data_CountContactRelationshipRules'
        );

        System.assertNotEquals(
            null,
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.IsEnabled_AutomaticHouseholdNaming.name()
            ),
            'setPackageBooleanValue should have been called with the feature IsEnabled_AutomaticHouseholdNaming'
        );

        System.assertNotEquals(
            null,
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.IsEnabled_CourseConnections.name()
            ),
            'setPackageBooleanValue should have been called with the feature IsEnabled_CourseConnections'
        );

        System.assertNotEquals(
            null,
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.HasDefaultAdministrativeAccountModel.name()
            ),
            'setPackageBooleanValue should have been called with the feature HasDefaultAdministrativeAccountModel'
        );

        System.assertNotEquals(
            null,
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.HasDefaultHouseholdAccountModel.name()
            ),
            'setPackageBooleanValue should have been called with the feature HasDefaultHouseholdAccountModel'
        );

        System.assertNotEquals(
            null,
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.IsEnabled_ErrorHandling.name()
            ),
            'setPackageBooleanValue should have been called with the feature IsEnabled_ErrorHandling'
        );

        System.assertNotEquals(
            null,
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.HasCustomAdministrativeAccountNaming.name()
            ),
            'setPackageBooleanValue should have been called with the feature HasCustomAdministrativeAccountNaming'
        );

        System.assertNotEquals(
            null,
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.HasCustomHouseholdAccountNaming.name()
            ),
            'setPackageBooleanValue should have been called with the feature HasCustomHouseholdAccountNaming'
        );

        System.assertNotEquals(
            null,
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.HasValueInversionReciprocalMethod.name()
            ),
            'setPackageBooleanValue should have been called with the feature HasValueInversionReciprocalMethod'
        );

        System.assertNotEquals(
            null,
            featureManagerMock.packageBooleanValuesByName.get(
                UTIL_OrgTelemetry.TelemetryParameterName.IsEnabled_StoreErrors.name()
            ),
            'setPackageBooleanValue should have been called with the feature IsEnabled_StoreErrors'
        );
    }

    // TODO: Tests for Org_Environment & Object_Usage
    /*
    Org_Environment:
    Org_CountActiveCourseConnectionRecordTypes,
    HasEDAInactiveTDTM,
    HasUserManagedTDTM,
    UsingOldContactEthnicity,
    UsingOldCourseDescription
    */

    /*
    Object_Usage:
    Data_CountAdministrativeAccounts,
    Data_CountHouseholdAccounts,
    Data_CountCourseConnections,
    Data_CountCourseOfferingSchedules,
    Data_CountErrorLog,
    Data_CountLanguages,
    Data_CountPlanRequirements,
    Data_CountProgramPlans,
    Data_CountTermGrades,
    */
}