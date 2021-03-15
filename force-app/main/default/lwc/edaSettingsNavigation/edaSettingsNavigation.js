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
                page: "accountModelSettings",
                sectionkey: "accountModelSettings",
                isActive: true,
            },
            {
                label: "Contact Information",
                page: "contactInfoSettings",
                sectionkey: "contactInfoSettings",
            },
            {
                label: "Addresses",
                page: "addressSettings",
                sectionkey: "addressSettings",
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
