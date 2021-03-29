import { LightningElement, api, track } from "lwc";
import accountModelSettingsTitle from "@salesforce/label/c.stgAccountModelSettingsTitle";
import stgAffiliationsSettingsNav from "@salesforce/label/c.stgAffiliationsSettingsNav";
import afflTypeEnforced from "@salesforce/label/c.afflTypeEnforced";
import stgAccountTypesMultiAddressesEnabled from "@salesforce/label/c.stgAccountTypesMultiAddressesEnabled";
import stgAddressSettingsTitle from "@salesforce/label/c.stgAddressSettingsTitle";
import stgAffiliationsSettingsTitle from "@salesforce/label/c.stgAffiliationsSettingsTitle";
import stgContactMultiAddressesEnabled from "@salesforce/label/c.stgContactMultiAddressesEnabled";
import stgHealthCheckLoadingIndicator from "@salesforce/label/c.stgHealthCheckLoadingIndicator";
import stgSimpleAddressChangeUpdate from "@salesforce/label/c.stgSimpleAddressChangeUpdate";

export default class EdaSettingsNavigation extends LightningElement {
    labelReference = {
        accountModelSettingsTitle,
        stgAffiliationsSettingsNav,
        afflTypeEnforced,
        spinnerLoadingAltText: stgHealthCheckLoadingIndicator,
        stgAffiliationsSettingsTitle,
        stgAccountTypesMultiAddressesEnabled,
        stgAddressSettingsTitle,
        stgContactMultiAddressesEnabled,
        stgSimpleAddressChangeUpdate,
    };

    @api activePage;

    @track viewModel = {
        navigationSections: [
            {
                label: "Setup Home",
                page: "setuphome",
                id: "setuphome",
            },
            {
                label: "People and Groups",
                id: "peopleAndGroups",
                navigationSubSections: [
                    {
                        label: this.labelReference.accountModelSettingsTitle,
                        page: "accountModelSettings",
                        id: "accountModelSettings",
                        menuItems: [
                            { label: "Default Account Model", id: "defaultaccountmodel" },
                            {
                                label: "Administrative Account Record Type",
                                id: "administrativeAccountRecordType",
                            },
                            { label: "Household Account Record Type", id: "householdAccountRecordType" },
                            {
                                label:
                                    "Select Account Record Types That Should be Deleted when no Contacts are Related",
                                id: "AutodeleteRecordTypes",
                            },
                            { label: "Administrative Account Naming", id: "administrativeAccountNaming" },
                            { label: "Household Account Naming", id: "householdAccountNaming" },
                            { label: "Rename Household Accounts", id: "renameHouseholdAccounts" },
                        ],
                        isActive: true,
                    },
                    {
                        label: "Contact Information",
                        page: "contactInformationSettings",
                        id: "contactInformation",
                        menuItems: [
                            { label: "Default Contact Language Fluency", id: "defaultContactLanguageFluency" },
                            { label: "Require Preferred Email", id: "requirePreferredEmail" },
                            { label: "Enhanced Preferred Phone Functionality", id: "enhancedPreferredPhone" },
                            { label: "Default Preferred Phone", id: "defaultPreferredPhone" },
                        ],
                    },
                    {
                        label: stgAddressSettingsTitle,
                        page: "addressSettings",
                        id: "addresses",
                        menuItems: [
                            { label: stgContactMultiAddressesEnabled, id: "contactMultipleAddresses" },
                            {
                                label: stgAccountTypesMultiAddressesEnabled,
                                id: "addressAccountRecordTypes",
                            },
                            {
                                label: stgSimpleAddressChangeUpdate,
                                id: "simpleAddressChangeIsUpdate",
                            },
                        ],
                    },
                ],
            },
            {
                label: stgAffiliationsSettingsNav,
                page: "affiliationSettings",
                id: "affiliations",
                menuItems: [{ label: afflTypeEnforced, id: "enforceRecordTypeValidation" }],
            },
            {
                label: "Courses and Enrollments",
                id: "coursesAndEnrollments",
            },
            {
                label: "System Tools",
                id: "systemTools",
            },
        ],
    };
}
