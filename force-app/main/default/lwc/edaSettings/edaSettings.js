import { LightningElement, api, track, wire } from "lwc";

import stgErrorInsufficientAccess from "@salesforce/label/c.stgErrorInsufficientAccess";
import checkAccessForCurrentUser from "@salesforce/apex/EDASettingsController.checkAccessForCurrentUser";
export default class EDASettings extends LightningElement {
    @api pageReference;

    labelReference = {
        stgErrorInsufficientAccess,
    };

    @track settingsPageToDisplay = {
        accountModelSettings: true,
    };

    currentUserHasAccess = false;

    @wire(checkAccessForCurrentUser)
    currentUserHasAccessWire(result) {
        const { error, data } = result;
        if (data) {
            this.currentUserHasAccess = data;
        }
    }

    handleSettingsNavigation(event) {
        this.changePageToDisplay(event.detail.pageName);
        event.stopPropagation();
    }

    changePageToDisplay(pageName) {
        let settingsPageDisplay = {};
        settingsPageDisplay[pageName] = true;

        this.settingsPageToDisplay = settingsPageDisplay;

        this.template.querySelector("c-eda-settings-navigation").setActivePage(pageName);
    }
}
