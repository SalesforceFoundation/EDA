import { LightningElement, api, track, wire } from "lwc";

import checkAccessForCurrentUser from "@salesforce/apex/EDASettingsController.checkAccessForCurrentUser";

import stgErrorInsufficientAccess from "@salesforce/label/c.stgErrorInsufficientAccess";
import stgHealthCheckLoadingIndicator from "@salesforce/label/c.stgHealthCheckLoadingIndicator";

export default class EDASettings extends LightningElement {
    @api pageReference;
    @api navigationClicked;

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
        event.stopPropagation();
        this.navigationClicked = true;

        const isCurrentPage = this.changePageToDisplay(event.detail.pageName);

        if (isCurrentPage) {
            this.navigateToCurrentPage();
        }
    }

    navigateToCurrentPage() {
        const settingsPage = this.template.querySelector(".eda-settings-page");
        settingsPage.handleSaveCanvasRender();
    }

    handleSaveCanvasRendered(event) {
        event.stopPropagation();

        if (!this.navigationClicked || !this.activePage) {
            return;
        }

        this.navigationClicked = false;
        const settingsPage = this.template.querySelector(event.target.tagName);
        settingsPage.handleSaveCanvasRender();
    }

    changePageToDisplay(pageName) {
        let isCurrentPage = this.settingsPageToDisplay[pageName];

        let settingsPageDisplay = {};
        settingsPageDisplay[pageName] = true;

        this.settingsPageToDisplay = settingsPageDisplay;
        this.activePage = pageName;

        return isCurrentPage;
    }

    @api modalSave(saveModel) {
        switch (saveModel.modalType) {
            case "affiliations":
                this.template.querySelector("c-affiliation-settings").modalSave(saveModel);
                break;
            case "autoenrollmentmapping":
                this.template.querySelector("c-program-settings").modalSave(saveModel);
                break;
            case "batchjob":
                this.template.querySelector("c-system-tools").modalConfirm(saveModel);
                break;
        }
    }
}
