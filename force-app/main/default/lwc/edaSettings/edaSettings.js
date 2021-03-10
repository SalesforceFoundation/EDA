import { LightningElement, api, wire } from "lwc";
import stgErrorInsufficientAccess from "@salesforce/label/c.stgErrorInsufficientAccess";
import checkAccessForCurrentUser from "@salesforce/apex/EDASettingsController.checkAccessForCurrentUser";

export default class EDASettings extends LightningElement {
    @api pageReference;

    labelReference = {
        settingsNavigation: "Navigation Pane Here",
        settingsPage: "Settings Page Here",
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

    settingsPageToDisplay = {
        accountModelSettings: true,
    };

    changePageToDisplay(pageName) {
        let settingsPageDisplay = {};
        settingsPageDisplay[pageName.toLowerCase()] = true;

        settingsPageToDisplay = settingsPageDisplay;
    }
}
