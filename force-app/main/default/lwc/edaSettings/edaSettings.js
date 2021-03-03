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
    //@wire(checkAccessForCurrentUser) currentUserHasAccess;
}
