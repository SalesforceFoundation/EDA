/*
    Copyright (c) 2022, Salesforce.org
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
 * @date 2022
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
public without sharing class ObjectUsageTelemetryModel {
    public Integer countBadgeCredentials = 0;
    public Integer countHouseholdAccounts = 0;
    public Integer countLicenseCredentials = 0;
    public Integer countAdministrativeAccounts = 0;
    public Integer countCertificationCredentials = 0;
    public Integer countDegreeAcademicCertifications = 0;
    public Integer countDiplomaAcademicCertifications = 0;
    public Integer countCertificateAcademicCertifications = 0;

    public Integer numErrors;
    public Integer numFacilities;
    public Integer numTermGrades;
    public Integer numCredentials;
    public Integer numProgramPlans;
    public Integer numPlanRequirements;
    public Integer numCourseEnrollments;
    public Integer numAcademicCertifications;
    public Integer numCourseOfferingSchedules;
    public Integer numAutoEnrollmentAffMappings;
    public Integer numSeasonalAddresses;
    public Integer numCurrentYearSeasonalAddesses;

    public ObjectUsageTelemetryModel() {
        this.numErrors = [SELECT COUNT() FROM Error__c];
        this.numFacilities = [SELECT COUNT() FROM Facility__c];
        this.numTermGrades = [SELECT COUNT() FROM Term_Grade__c];
        this.numCredentials = [SELECT COUNT() FROM Credential__c];
        this.numProgramPlans = [SELECT COUNT() FROM Program_Plan__c];
        this.numPlanRequirements = [SELECT COUNT() FROM Plan_Requirement__c];
        this.numCourseEnrollments = [SELECT COUNT() FROM Course_Enrollment__c];
        this.numAcademicCertifications = [SELECT COUNT() FROM Academic_Certification__c];
        this.numCourseOfferingSchedules = [SELECT COUNT() FROM Course_Offering_Schedule__c];

        this.numAutoEnrollmentAffMappings = [
            SELECT COUNT()
            FROM Affl_Mappings__c
            WHERE Auto_Program_Enrollment__c = TRUE
        ];

        this.numSeasonalAddresses = [
            SELECT COUNT()
            FROM Address__c
            WHERE
                Seasonal_Start_Month__c != NULL
                AND Seasonal_Start_Day__c != NULL
                AND Seasonal_End_Month__c != NULL
                AND Seasonal_End_Day__c != NULL
        ];

        this.numCurrentYearSeasonalAddesses = [
            SELECT COUNT()
            FROM Address__c
            WHERE
                Seasonal_Start_Month__c != NULL
                AND Seasonal_Start_Day__c != NULL
                AND Seasonal_End_Month__c != NULL
                AND Seasonal_End_Day__c != NULL
                AND CreatedDate = LAST_N_DAYS:365
        ];

        if (UTIL_Describe.getCustomAdminAccRecTypeId() != null) {
            this.countAdministrativeAccounts = [
                SELECT COUNT()
                FROM Account
                WHERE RecordTypeId = :UTIL_Describe.getCustomAdminAccRecTypeId()
            ];
        }

        if (UTIL_Describe.getCustomHHAccRecTypeID() != null) {
            this.countHouseholdAccounts = [
                SELECT COUNT()
                FROM Account
                WHERE RecordTypeId = :UTIL_Describe.getCustomHHAccRecTypeID()
            ];
        }

        if (UTIL_Describe.getCertificateAcademicCertificationRecTypeId() != null) {
            this.countCertificateAcademicCertifications = [
                SELECT COUNT()
                FROM Academic_Certification__c
                WHERE RecordTypeId = :UTIL_Describe.getCertificateAcademicCertificationRecTypeId()
            ];
        }

        if (UTIL_Describe.getDegreeAcademicCertificationRecTypeId() != null) {
            this.countDegreeAcademicCertifications = [
                SELECT COUNT()
                FROM Academic_Certification__c
                WHERE RecordTypeId = :UTIL_Describe.getDegreeAcademicCertificationRecTypeId()
            ];
        }

        if (UTIL_Describe.getDiplomaAcademicCertificationRecTypeId() != null) {
            this.countDiplomaAcademicCertifications = [
                SELECT COUNT()
                FROM Academic_Certification__c
                WHERE RecordTypeId = :UTIL_Describe.getDiplomaAcademicCertificationRecTypeId()
            ];
        }

        if (UTIL_Describe.getBadgeCredentialRecTypeId() != null) {
            this.countBadgeCredentials = [
                SELECT COUNT()
                FROM Credential__c
                WHERE RecordTypeId = :UTIL_Describe.getBadgeCredentialRecTypeId()
            ];
        }

        if (UTIL_Describe.getLicenseCredentialRecTypeId() != null) {
            this.countLicenseCredentials = [
                SELECT COUNT()
                FROM Credential__c
                WHERE RecordTypeId = :UTIL_Describe.getLicenseCredentialRecTypeId()
            ];
        }

        if (UTIL_Describe.getCertificationCredentialRecTypeId() != null) {
            this.countCertificationCredentials = [
                SELECT COUNT()
                FROM Credential__c
                WHERE RecordTypeId = :UTIL_Describe.getCertificationCredentialRecTypeId()
            ];
        }
    }
}
