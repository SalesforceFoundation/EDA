import { LightningElement, api } from "lwc";
import accountModelSettingsTitle from "@salesforce/label/c.stgAccountModelSettingsTitle";

export default class EdaSettingsNavigation extends LightningElement {
    labelReference = {
        accountModelSettingsTitle,
    };

    edaNavigationViewModel = {
        navigationSections: [
            {
                label: labelReference.accountModelSettingsTitle,
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
        this.edaNavigationViewModel.navigationSections.forEach((navigationSection) => {
            if (navigationSection.pageName === pageName) {
                navigationSection.isActive = true;
            } else {
                navigationSection.isActive = undefined;
            }
        });
    }
}
