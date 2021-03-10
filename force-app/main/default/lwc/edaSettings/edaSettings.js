import { LightningElement, api, wire } from "lwc";

import stgErrorInsufficientAccess from "@salesforce/label/c.stgErrorInsufficientAccess";
import checkAccessForCurrentUser from "@salesforce/apex/EDASettingsController.checkAccessForCurrentUser";
export default class EDASettings extends LightningElement {
    labelReference = {
        stgErrorInsufficientAccess,
    };

    currentUserHasAccess = false;

    @wire(checkAccessForCurrentUser)
    currentUserHasAccessWire(result) {
        const { error, data } = result;
        if (data) {
            this.currentUserHasAccess = data;
        }
    }

    @track settingsPageToDisplay = {
        accountmodelsettings: true,
    };

    handleSettingsNavigation(event) {
        this.changePageToDisplay(event.detail.pageName);
        event.stopPropagation();
    }

    changePageToDisplay(pageName) {
        let settingsPageDisplay = {};
        settingsPageDisplay[pageName.toLowerCase()] = true;

        this.settingsPageToDisplay = settingsPageDisplay;

        this.template.querySelector("c-eda-settings-navigation").setActivePage(pageName);
    }
}
