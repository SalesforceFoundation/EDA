import { LightningElement, api } from "lwc";
import accountModelSettingsTitle from "@salesforce/label/c.stgAccountModelSettingsTitle";

export default class EdaSettingsNavigation extends LightningElement {
    labelReference = {
        accountModelSettingsTitle,
    };

    settingsNavigationViewModel = {
        navigationSections: [
            {
                label: "People and Groups",
                sectionkey: "peopleandgroups",
                navigationSubSections: [
                    {
                        label: this.labelReference.accountModelSettingsTitle,
                        page: "accountmodelsettings",
                        sectionkey: "accountmodelsettings",
                        menuItems: [
                            { label: "Default Account Model", sectionKey: "defaultaccountmodel" },
                            {
                                label: "Administrative Account Record Type",
                                sectionKey: "administrativeaccountrecordtype",
                            },
                            { label: "Household Account Record Type", sectionKey: "householdaccountrecordtype" },
                            {
                                label:
                                    "Select Account Record Types That Should be Deleted when no Contacts are Related",
                                sectionKey: "autodeleterecordtypes",
                            },
                            { label: "Administrative Account Naming", sectionKey: "administrativeaccountnaming" },
                            { label: "Household Account Naming", sectionKey: "householdAccountNaming" },
                            { label: "Rename Household Accounts", sectionKey: "renamehouseholdaccounts" },
                        ],
                        isActive: true,
                    },
                    {
                        label: "Contact Information",
                        page: "contactinfosettings",
                        sectionkey: "contactinfosettings",
                        menuItems: [
                            { label: "Default Contact Language Fluency", sectionKey: "defaultcontactlanguagefluency" },
                            { label: "Require Preferred Email", sectionKey: "requirepreferredemail" },
                            { label: "Enhanced Preferred Phone Functionality", sectionKey: "enhancedpreferredphone" },
                            { label: "Default Preferred Phone", sectionKey: "defaultpreferredphone" },
                        ],
                    },
                    {
                        label: "Addresses",
                        page: "addresssettings",
                        sectionkey: "addresssettings",
                        menuItems: [
                            { label: "Allow Multiple Contact Addresses", sectionKey: "contactmultipleaddresses" },
                            {
                                label: "Enable Multiple Addresses for Account Types",
                                sectionKey: "addressaccountrecordtypes",
                            },
                            {
                                label: "Update Address Records for Simple Address Changes",
                                sectionKey: "simpleaddresschangeisupdate",
                            },
                        ],
                    },
                ],
            },
            {
                label: "Affiliations",
                page: "affiliations",
                sectionkey: "affiliations",
                menuItems: [{ label: "Enforce Record Type Validation", sectionKey: "enforcerecordtypevalidation" }],
            },
            {
                label: "Courses and Enrollments",
                sectionkey: "coursesandenrollments",
            },
            {
                label: "System Tools",
                sectionkey: "systemtools",
            },
        ],
    };

    @api setActivePage(pageName) {
        this.settingsNavigationViewModel.navigationSections.forEach((navigationSection) => {
            if (navigationSection.pageName === pageName) {
                navigationSection.isActive = true;
            } else {
                navigationSection.isActive = undefined;
            }
        });
    }
}
