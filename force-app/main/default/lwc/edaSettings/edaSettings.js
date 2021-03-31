import { LightningElement, api, track, wire } from "lwc";

import checkAccessForCurrentUser from "@salesforce/apex/EDASettingsController.checkAccessForCurrentUser";

import stgErrorInsufficientAccess from "@salesforce/label/c.stgErrorInsufficientAccess";
import stgHealthCheckLoadingIndicator from "@salesforce/label/c.stgHealthCheckLoadingIndicator";

export default class EDASettings extends LightningElement {
    @api pageReference;

    currentUserHasAccessWireResult;
    currentUserHasAccess;

    activePage = "accountModelSettings";

    @track settingsPageToDisplay = {
        accountModelSettings: true,
    };

    labelReference = {
        insufficientAccessError: stgErrorInsufficientAccess,
        spinnerLoadingAltText: stgHealthCheckLoadingIndicator,
    };

    @wire(checkAccessForCurrentUser)
    currentUserHasAccessWire(result) {
        this.currentUserHasAccessWireResult = result;
        if (result.data) {
            this.currentUserHasAccess = result.data;
        }
    }

    get currentUserDoesNotHaveAccess() {
        if (this.currentUserHasAccess === false) {
            return true;
        }
        return undefined;
    }

    settingsPageToDisplay = {
        accountModelSettings: true,
    };

    handleSettingsNavigation(event) {
        this.changePageToDisplay(event.detail.pageName);
        event.stopPropagation();
    }

    changePageToDisplay(pageName) {
        let settingsPageDisplay = {};
        settingsPageDisplay[pageName] = true;

        this.settingsPageToDisplay = settingsPageDisplay;
        this.activePage = pageName;
    }

    @api modalSave(saveModel) {
        console.log("entering save model:" + JSON.stringify(saveModel));
        switch (saveModel.modalType) {
            case "affiliations":
                this.template.querySelector("c-affiliation-settings").modalSave(saveModel);
                break;
        }
    }
}
