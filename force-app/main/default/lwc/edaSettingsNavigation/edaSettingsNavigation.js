import { LightningElement, api } from "lwc";
import accountModelSettingsTitle from "@salesforce/label/c.stgAccountModelSettingsTitle";

export default class EdaSettingsNavigation extends LightningElement {
    labelReference = {
        accountModelSettingsTitle,
    };

    settingsNavigationViewModel = {
        navigationSections: [
            {
                label: this.labelReference.accountModelSettingsTitle,
                page: "accountmodelsettings",
                sectionkey: "accountmodelsettings",
                isActive: true,
            },
            {
                label: "Contact Information",
                page: "contactinfosettings",
                sectionkey: "contactinfosettings",
            },
            {
                label: "Addresses",
                page: "addresssettings",
                sectionkey: "addresssettings",
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
