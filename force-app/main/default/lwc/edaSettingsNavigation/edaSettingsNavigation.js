import { LightningElement, api, track } from "lwc";
import stgHealthCheckLoadingIndicator from "@salesforce/label/c.stgHealthCheckLoadingIndicator";
//People and Group Settings Labels
import stgPeopleAndGroupsNav from "@salesforce/label/c.stgPeopleAndGroupsNav";
//Account Model Settings Labels
import stgAccountModelNav from "@salesforce/label/c.stgAccountModelNav";
import stgAccModelTitle from "@salesforce/label/c.stgAccModelTitle";
import stgAdminAccountRecordType from "@salesforce/label/c.stgAdminAccountRecordType";
import stgAccountRecordTypeSupportsHHAddress from "@salesforce/label/c.stgAccountRecordTypeSupportsHHAddress";
import stgAccoutTypesWithoutContactsDelete from "@salesforce/label/c.stgAccoutTypesWithoutContactsDelete";
import stgLeadConversionAccountNaming from "@salesforce/label/c.stgLeadConversionAccountNaming";
import adminAccNameFormat from "@salesforce/label/c.adminAccNameFormat";
import hhAccNameFormat from "@salesforce/label/c.hhAccNameFormat";
import automaticHHNaming from "@salesforce/label/c.automaticHHNaming";
//Contact Information Settings Labels
import stgContactInformationSettingsNav from "@salesforce/label/c.stgContactInformationSettingsNav";
import stgDefaultContactLanguageFluency from "@salesforce/label/c.stgDefaultContactLanguageFluency";
import stgDisablePreferredEmailEnforcement from "@salesforce/label/c.stgDisablePreferredEmailEnforcement";
import stgEnablePreferredPhoneSync from "@salesforce/label/c.stgEnablePreferredPhoneSync";
import stgPreferredPhoneDefault from "@salesforce/label/c.stgPreferredPhoneDefault";
//Address Settings Labels
import stgAccountTypesMultiAddressesEnabled from "@salesforce/label/c.stgAccountTypesMultiAddressesEnabled";
import stgAddressSettingsNav from "@salesforce/label/c.stgAddressSettingsNav";
import stgContactMultiAddressesEnabled from "@salesforce/label/c.stgContactMultiAddressesEnabled";
import stgSimpleAddressChangeUpdate from "@salesforce/label/c.stgSimpleAddressChangeUpdate";
//Affiliation Settings Labels
import stgTabAfflMappings from "@salesforce/label/c.stgTabAfflMappings";
import stgAffiliationsSettingsNav from "@salesforce/label/c.stgAffiliationsSettingsNav";
import afflTypeEnforced from "@salesforce/label/c.afflTypeEnforced";
//Course Enrollment Labels
import stgCoursesAndEnrollmentsNav from "@salesforce/label/c.stgCoursesAndEnrollmentsNav";
import stgProgramsSettingsNav from "@salesforce/label/c.stgProgramsSettingsNav";
import stgAutoEnrollmentProgramTitle from "@salesforce/label/c.stgAutoEnrollmentProgramTitle";
import stgAfflProgEnrollSetRoleValue from "@salesforce/label/c.stgAfflProgEnrollSetRoleValue";
import stgAfflProgEnrollSetStatusValue from "@salesforce/label/c.stgAfflProgEnrollSetStatusValue";
import stgAfflCopyProgramEnrollmentEndDate from "@salesforce/label/c.stgAfflCopyProgramEnrollmentEndDate";
import stgAfflCopyProgramEnrollmentStartDate from "@salesforce/label/c.stgAfflCopyProgramEnrollmentStartDate";
import stgAfflProgEnrollDeleteTitle from "@salesforce/label/c.stgAfflProgEnrollDeleteTitle";
//Program Plan Settings Labels
import stgProgramPlanSettingsNav from "@salesforce/label/c.stgProgramPlanSettingsNav";
import stgNestedPlanRequirementPP from "@salesforce/label/c.stgNestedPlanRequirementPP";
import stgCourseConnectionsNav from "@salesforce/label/c.stgCourseConnectionsNav";
import stgEnableCourseConnectionsTitle from "@salesforce/label/c.stgEnableCourseConnectionsTitle";
// Relationship Labels
import stgDuplicateRelationships from "@salesforce/label/c.stgDuplicateRelationships";
import stgTitleReciMethod from "@salesforce/label/c.stgTitleReciMethod";
import stgRelationshipSettingsNav from "@salesforce/label/c.stgRelationshipSettingsNav";
import stgTitleNewReciSetting from "@salesforce/label/c.stgTitleNewReciSetting";
//System Settings Labels
import stgSystemSettingsNav from "@salesforce/label/c.stgSystemSettingsNav";
//System Tools Labels
import stgSystemToolsNav from "@salesforce/label/c.stgSystemToolsNav";
import stgRefreshAdminAcctNameTitle from "@salesforce/label/c.stgRefreshAdminAcctNameTitle";
import stgRefreshHHAcctNameTitle from "@salesforce/label/c.stgRefreshHHAcctNameTitle";
import stgPreferredEmailDataCleanup from "@salesforce/label/c.stgPreferredEmailDataCleanup";
import stgTitleCourseConnectionBackfill from "@salesforce/label/c.stgTitleCourseConnectionBackfill";
import stgTitleCoursesDescriptionDataMigration from "@salesforce/label/c.stgTitleCoursesDescriptionDataMigration";
import stgEthnicityRaceBackfillContacts from "@salesforce/label/c.stgEthnicityRaceBackfillContacts";
//Error Settings Labels
import stgErrorSettingsNav from "@salesforce/label/c.stgErrorSettingsNav";
import stgSendErrorsTitle from "@salesforce/label/c.stgSendErrorsTitle";
import stgStoreErrorsTitle from "@salesforce/label/c.stgStoreErrorsTitle";
import stgEnableDebugTitle from "@salesforce/label/c.stgEnableDebugTitle";
import stgDisableErrorHandlingTitle from "@salesforce/label/c.stgDisableErrorHandlingTitle";
import stgSendErrorsTitle from "@salesforce/label/c.stgSendErrorsTitle";

export default class EdaSettingsNavigation extends LightningElement {
    labelReference = {
        peopleAndGroups: stgPeopleAndGroupsNav,
        spinnerLoadingAltText: stgHealthCheckLoadingIndicator,
        systemSettings: stgSystemSettingsNav,
        accountModel: {
            accountAutoDeletionModel: stgAccoutTypesWithoutContactsDelete,
            accountModelSettings: stgAccountModelNav,
            adminAccountModel: stgAdminAccountRecordType,
            defaultAccountModel: stgAccModelTitle,
            hhAccountModel: stgAccountRecordTypeSupportsHHAddress,
            adminAccountNaming: adminAccNameFormat,
            hhAccountNaming: hhAccNameFormat,
            autoHHAccountNaming: automaticHHNaming,
            leadConversionAutoAccountNaming: stgLeadConversionAccountNaming,
        },
        addressSettings: {
            addressAccountRecordTypes: stgAccountTypesMultiAddressesEnabled,
            addressSettings: stgAddressSettingsNav,
            contactMultipleAddresses: stgContactMultiAddressesEnabled,
            simpleAddressChangeIsUpdate: stgSimpleAddressChangeUpdate,
        },
        affiliationSettings: {
            affiliationMappings: stgTabAfflMappings,
            affiliationSettings: stgAffiliationsSettingsNav,
            enforceRecordTypeValidation: afflTypeEnforced,
        },
        contactInformation: {
            contactInformation: stgContactInformationSettingsNav,
            defaultContactLanguageFluency: stgDefaultContactLanguageFluency,
            defaultPreferredPhone: stgPreferredPhoneDefault,
            enhancedPhoneFunctionality: stgEnablePreferredPhoneSync,
            requirePreferredEmail: stgDisablePreferredEmailEnforcement,
        },
        coursesAndEnrollmentsSettings: {
            coursesAndEnrollmentsSettings: stgCoursesAndEnrollmentsNav,
            courseConnectionSettings: stgCourseConnectionsNav,
            stgEnableCourseConnectionsTitle: stgEnableCourseConnectionsTitle,
        },
        errorSettings: {
            enableDebug: stgEnableDebugTitle,
            enableErrorHandling: stgDisableErrorHandlingTitle,
            errorSettings: stgErrorSettingsNav,
            sendErrorNotifications: stgSendErrorsTitle,
            storeErrors: stgStoreErrorsTitle,
        },
        programSettings: {
            programSettings: stgProgramsSettingsNav,
            programAutoEnrollmentMappings: stgAutoEnrollmentProgramTitle,
            programEnrollmentDeletions: stgAfflProgEnrollDeleteTitle,
            roleForCreatedAffl: stgAfflProgEnrollSetRoleValue,
            statusForCreatedAffl: stgAfflProgEnrollSetStatusValue,
            afflEndDate: stgAfflCopyProgramEnrollmentEndDate,
            afflStartDate: stgAfflCopyProgramEnrollmentStartDate,
        },
        programPlanSettings: {
            programPlans: stgProgramPlanSettingsNav,
            programPlanRequirementHierarchy: stgNestedPlanRequirementPP,
        },
        relationshipSettings: {
            preventAutoCreatedDuplicateRelationships: stgDuplicateRelationships,
            reciprocalMethod: stgTitleReciMethod,
            reciprocalRelationshipMappings: stgTitleNewReciSetting,
            relationshipSettings: stgRelationshipSettingsNav,
        },
        systemTools: {
            courseConnectionBackfill: stgTitleCourseConnectionBackfill,
            courseDescriptionMigration: stgTitleCoursesDescriptionDataMigration,
            ethnicityAndRaceBackfill: stgEthnicityRaceBackfillContacts,
            preferredEmailCleanup: stgPreferredEmailDataCleanup,
            systemToolsNav: stgSystemToolsNav,
            refreshAdministrativeAccountNames: stgRefreshAdminAcctNameTitle,
            refreshHouseholdAccountNames: stgRefreshHHAcctNameTitle,
        },
    };

    @api activePage;

    @track viewModel = {
        navigationSections: [
            {
                label: this.labelReference.peopleAndGroups,
                id: "peopleAndGroups",
                navigationSubSections: [
                    {
                        label: this.labelReference.accountModel.accountModelSettings,
                        page: "accountModelSettings",
                        id: "accountModelSettings",
                        menuItems: [
                            { label: this.labelReference.accountModel.defaultAccountModel, id: "defaultAccountModel" },
                            {
                                label: this.labelReference.accountModel.adminAccountModel,
                                id: "adminAccountModel",
                            },
                            { label: this.labelReference.accountModel.hhAccountModel, id: "hhAccountModel" },
                            {
                                label: this.labelReference.accountModel.accountAutoDeletionModel,
                                id: "accountAutoDeletionModel",
                            },
                            { label: this.labelReference.accountModel.adminAccountNaming, id: "adminAccountNaming" },
                            { label: this.labelReference.accountModel.hhAccountNaming, id: "hhAccountNaming" },
                            { label: this.labelReference.accountModel.autoHHAccountNaming, id: "autoHHAccountNaming" },
                            {
                                label: this.labelReference.accountModel.leadConversionAutoAccountNaming,
                                id: "leadConversionAutoAccountNaming",
                            },
                        ],
                        isActive: true,
                    },
                    {
                        label: this.labelReference.contactInformation.contactInformation,
                        page: "contactInformationSettings",
                        id: "contactInformation",
                        menuItems: [
                            {
                                label: this.labelReference.contactInformation.defaultContactLanguageFluency,
                                id: "defaultContactLanguageFluency",
                            },
                            {
                                label: this.labelReference.contactInformation.requirePreferredEmail,
                                id: "requirePreferredEmail",
                            },
                            {
                                label: this.labelReference.contactInformation.enhancedPhoneFunctionality,
                                id: "enhancedPhoneFunctionality",
                            },
                            {
                                label: this.labelReference.contactInformation.defaultPreferredPhone,
                                id: "defaultPreferredPhone",
                            },
                        ],
                    },
                    {
                        label: this.labelReference.addressSettings.addressSettings,
                        page: "addressSettings",
                        id: "addresses",
                        menuItems: [
                            {
                                label: this.labelReference.addressSettings.contactMultipleAddresses,
                                id: "contactMultipleAddresses",
                            },
                            {
                                label: this.labelReference.addressSettings.simpleAddressChangeIsUpdate,
                                id: "addressAccountRecordTypes",
                            },
                            {
                                label: this.labelReference.addressSettings.addressAccountRecordTypes,
                                id: "simpleAddressChangeIsUpdate",
                            },
                        ],
                    },
                ],
            },
            {
                label: this.labelReference.affiliationSettings.affiliationSettings,
                page: "affiliationSettings",
                id: "affiliations",
                menuItems: [
                    {
                        label: this.labelReference.affiliationSettings.enforceRecordTypeValidation,
                        id: "enforceRecordTypeValidation",
                    },
                    {
                        label: this.labelReference.affiliationSettings.affiliationMappings,
                        id: "affiliationMappings",
                    },
                ],
            },
            {
                label: this.labelReference.relationshipSettings.relationshipSettings,
                page: "relationshipSettings",
                id: "relationshipSettings",
                menuItems: [
                    {
                        label: this.labelReference.relationshipSettings.reciprocalMethod,
                        id: "reciprocalMethod",
                    },
                    {
                        label: this.labelReference.relationshipSettings.preventAutoCreatedDuplicateRelationships,
                        id: "preventAutoCreatedDuplicateRelationships",
                    },
                    {
                        label: this.labelReference.relationshipSettings.reciprocalRelationshipMappings,
                        id: "reciprocalRelationshipMappings",
                    },
                ],
            },
            {
                label: this.labelReference.coursesAndEnrollmentsSettings.coursesAndEnrollmentsSettings,
                id: "coursesAndEnrollments",
                navigationSubSections: [
                    {
                        label: this.labelReference.programSettings.programSettings,
                        page: "programSettings",
                        id: "programSettings",
                        menuItems: [
                            {
                                label: this.labelReference.programSettings.programEnrollmentDeletions,
                                id: "programEnrollmentDeletions",
                            },
                            {
                                label: this.labelReference.programSettings.roleForCreatedAffl,
                                id: "roleForCreatedAffiliations",
                            },
                            {
                                label: this.labelReference.programSettings.statusForCreatedAffl,
                                id: "statusForCreatedAffiliations",
                            },
                            {
                                label: this.labelReference.programSettings.afflEndDate,
                                id: "copyEndDate",
                            },
                            {
                                label: this.labelReference.programSettings.afflStartDate,
                                id: "copyStartDate",
                            },
                            {
                                label: this.labelReference.programSettings.programAutoEnrollmentMappings,
                                id: "programAutoEnrollmentMappings",
                            },
                        ],
                    },
                    {
                        label: this.labelReference.programPlanSettings.programPlans,
                        page: "programPlanSettings",
                        id: "programPlans",
                        menuItems: [
                            {
                                label: this.labelReference.programPlanSettings.programPlanRequirementHierarchy,
                                id: "programPlanRequirementHierarchy",
                            },
                        ],
                    },
                    {
                        label: this.labelReference.coursesAndEnrollmentsSettings.courseConnectionSettings,
                        page: "courseConnectionSettings",
                        id: "courseConnectionSettings",
                        menuItems: [
                            {
                                label: this.labelReference.coursesAndEnrollmentsSettings
                                    .stgEnableCourseConnectionsTitle,
                                id: "programEnrollmentDeletions",
                            },
                        ],
                    },
                ],
            },
            {
                label: this.labelReference.systemSettings,
                id: "systemSettings",
                navigationSubSections: [
                    {
                        label: this.labelReference.errorSettings.errorSettings,
                        page: "errorSettings",
                        id: "errorSettings",
                        menuItems: [
                            { label: this.labelReference.errorSettings.storeErrors, id: "storeErrors" },
                            {
                                label: this.labelReference.errorSettings.sendErrorNotifications,
                                id: "sendErrorNotifications",
                            },
                            {
                                label: this.labelReference.errorSettings.enableErrorHandling,
                                id: "enableErrorHandling",
                            },
                            { label: this.labelReference.errorSettings.enableDebug, id: "enableDebug" },
                        ],
                    },
                    {
                        label: this.labelReference.systemTools.systemToolsNav,
                        page: "systemTools",
                        id: "systemTools",
                        menuItems: [
                            {
                                label: this.labelReference.systemTools.refreshAdministrativeAccountNames,
                                id: "refreshAdministrativeAccountNames",
                            },
                            {
                                label: this.labelReference.systemTools.refreshHouseholdAccountNames,
                                id: "refreshHouseholdAccountNames",
                            },
                            {
                                label: this.labelReference.systemTools.preferredEmailCleanup,
                                id: "preferredEmailCleanup",
                            },
                            {
                                label: this.labelReference.systemTools.ethnicityAndRaceBackfill,
                                id: "ethnicityAndRaceBackfill",
                            },
                            {
                                label: this.labelReference.systemTools.courseConnectionBackfill,
                                id: "courseConnectionBackfill",
                            },
                            {
                                label: this.labelReference.systemTools.courseDescriptionMigration,
                                id: "courseDescriptionMigration",
                            },
                        ],
                    },
                ],
            },
        ],
    };
}
