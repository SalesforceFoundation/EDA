public with sharing class ObjectUsageTelemetryModel {
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
