import { LightningElement, api, track } from "lwc";
import accountModelSettingsTitle from "@salesforce/label/c.stgAccountModelSettingsTitle";

export default class EdaSettingsNavigation extends LightningElement {
    labelReference = {
        accountModelSettingsTitle,
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
                                menuitemkey: "administrativeAccountRecordType",
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
                        page: "contactInformation",
                        id: "contactInformation",
                        menuItems: [
                            { label: "Default Contact Language Fluency", id: "defaultContactLanguageFluency" },
                            { label: "Require Preferred Email", id: "requirePreferredEmail" },
                            { label: "Enhanced Preferred Phone Functionality", id: "enhancedPreferredPhone" },
                            { label: "Default Preferred Phone", id: "defaultPreferredPhone" },
                        ],
                    },
                    {
                        label: "Addresses",
                        page: "addresses",
                        id: "addresses",
                        menuItems: [
                            { label: "Allow Multiple Contact Addresses", id: "contactMultipleAddresses" },
                            {
                                label: "Enable Multiple Addresses for Account Types",
                                id: "addressAccountRecordTypes",
                            },
                            {
                                label: "Update Address Records for Simple Address Changes",
                                id: "simpleAddressChangeIsUpdate",
                            },
                        ],
                    },
                ],
            },
            {
                label: "Affiliations",
                page: "affiliations",
                id: "affiliations",
                menuItems: [{ label: "Enforce Record Type Validation", id: "enforceRecordTypeValidation" }],
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
