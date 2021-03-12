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
                id: "peopleandgroups",
                navigationSubSections: [
                    {
                        label: this.labelReference.accountModelSettingsTitle,
                        page: "accountmodelsettings",
                        id: "accountmodelsettings",
                        menuItems: [
                            { label: "Default Account Model", id: "defaultaccountmodel" },
                            {
                                label: "Administrative Account Record Type",
                                menuitemkey: "administrativeaccountrecordtype",
                            },
                            { label: "Household Account Record Type", id: "householdaccountrecordtype" },
                            {
                                label:
                                    "Select Account Record Types That Should be Deleted when no Contacts are Related",
                                id: "autodeleterecordtypes",
                            },
                            { label: "Administrative Account Naming", id: "administrativeaccountnaming" },
                            { label: "Household Account Naming", id: "householdAccountNaming" },
                            { label: "Rename Household Accounts", id: "renamehouseholdaccounts" },
                        ],
                        isActive: true,
                    },
                    {
                        label: "Contact Information",
                        page: "contactinfosettings",
                        id: "contactinfosettings",
                        menuItems: [
                            { label: "Default Contact Language Fluency", id: "defaultcontactlanguagefluency" },
                            { label: "Require Preferred Email", id: "requirepreferredemail" },
                            { label: "Enhanced Preferred Phone Functionality", id: "enhancedpreferredphone" },
                            { label: "Default Preferred Phone", id: "defaultpreferredphone" },
                        ],
                    },
                    {
                        label: "Addresses",
                        page: "addresssettings",
                        id: "addresssettings",
                        menuItems: [
                            { label: "Allow Multiple Contact Addresses", id: "contactmultipleaddresses" },
                            {
                                label: "Enable Multiple Addresses for Account Types",
                                id: "addressaccountrecordtypes",
                            },
                            {
                                label: "Update Address Records for Simple Address Changes",
                                id: "simpleaddresschangeisupdate",
                            },
                        ],
                    },
                ],
            },
            {
                label: "Affiliations",
                page: "affiliations",
                id: "affiliations",
                menuItems: [{ label: "Enforce Record Type Validation", id: "enforcerecordtypevalidation" }],
            },
            {
                label: "Courses and Enrollments",
                id: "coursesandenrollments",
            },
            {
                label: "System Tools",
                id: "systemtools",
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
