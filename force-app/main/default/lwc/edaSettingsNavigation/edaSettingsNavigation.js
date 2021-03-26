import { LightningElement, api, track } from "lwc";
import accountModelSettingsTitle from "@salesforce/label/c.stgAccountModelSettingsTitle";
import stgAffiliationsSettingsTitle from "@salesforce/label/c.stgAffiliationsSettingsTitle";
import afflTypeEnforced from "@salesforce/label/c.afflTypeEnforced";
import stgAddressSettingsTitle from "@salesforce/label/c.stgAddressSettingsTitle";
import stgContactMultiAddressesEnabled from "@salesforce/label/c.stgContactMultiAddressesEnabled";
import stgAccountTypesMultiAddressesEnabled from "@salesforce/label/c.stgAccountTypesMultiAddressesEnabled";
import stgSimpleAddressChangeUpdate from "@salesforce/label/c.stgSimpleAddressChangeUpdate";

export default class EdaSettingsNavigation extends LightningElement {
    labelReference = {
        accountModelSettingsTitle,
        stgAffiliationsSettingsTitle,
        afflTypeEnforced,
        stgAddressSettingsTitle,
        stgContactMultiAddressesEnabled,
        stgAccountTypesMultiAddressesEnabled,
        stgSimpleAddressChangeUpdate,
    };

    @track settingsNavigationViewModel = {
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
                label: "stgAffiliationsSettingsTitle",
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

    @api setActivePage(pageName) {
        this.settingsNavigationViewModel.navigationSections.forEach((navigationSection) => {
            if (navigationSection.page === pageName) {
                navigationSection.isActive = true;
            } else {
                navigationSection.isActive = undefined;
                this.setActiveSubpage(pageName, navigationSection);
            }
        });
    }

    setActiveSubpage(pageName, navigationSection) {
        if (!navigationSection.navigationSubSections) {
            return;
        }

        navigationSection.navigationSubSections.forEach((navigationSubSection) => {
            if (navigationSubSection.page === pageName) {
                navigationSubSection.isActive = true;
            } else {
                navigationSubSection.isActive = undefined;
            }
        });
    }
}
