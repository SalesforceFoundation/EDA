import { LightningElement, api, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";

import checkAccessForCurrentUser from "@salesforce/apex/EDASettingsController.checkAccessForCurrentUser";

import stgErrorInsufficientAccess from "@salesforce/label/c.stgErrorInsufficientAccess";
import stgHealthCheckLoadingIndicator from "@salesforce/label/c.stgHealthCheckLoadingIndicator";
import EDASettingsContainerAuraComponentLabel from "@salesforce/label/c.EDASettingsContainerAuraComponentLabel";
import EDCSettingsContainerAuraComponentLabel from "@salesforce/label/c.EDCSettingsContainerAuraComponentLabel";

import namespacedEDAField from "@salesforce/schema/Course_Offering_Schedule__c.Course_Offering__c";
const EducationCloudSettingsContainerComponentName = "EducationCloudSettingsContainer";
export default class EDASettings extends NavigationMixin(LightningElement) {
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
        edaSettings: EDASettingsContainerAuraComponentLabel,
        edcSettings: EDCSettingsContainerAuraComponentLabel,
    };

    @wire(checkAccessForCurrentUser)
    currentUserHasAccessWire(result) {
        this.currentUserHasAccessWireResult = result;

        let element_edaSettingsContainer = this.template.querySelectorAll(".slds-grid")[0];
        let styling_edaSettingsContainer = "eda-height_full";

        if (result.data !== undefined) {
            result.data
                ? element_edaSettingsContainer?.classList.add(styling_edaSettingsContainer)
                : element_edaSettingsContainer?.classList.remove(styling_edaSettingsContainer);

            this.currentUserHasAccess = result.data;
        }
    }

    get currentUserHasAccessWireResolved() {
        if (this.currentUserHasAccessWireResult === undefined) {
            return false;
        }

        return (
            this.currentUserHasAccessWireResult.data !== undefined ||
            this.currentUserHasAccessWireResult.error !== undefined
        );
    }

    get edaComponentNavigationPrefix() {
        const apiName = namespacedEDAField.fieldApiName;
        const navigationPrefix = apiName.replace("Course_Offering__c", "");

        if (navigationPrefix === "") {
            return "c__";
        }

        return navigationPrefix;
    }

    get educationCloudSettingsContainerComponentNavigation() {
        return this.edaComponentNavigationPrefix + EducationCloudSettingsContainerComponentName;
    }

    settingsPageToDisplay = {
        accountModelSettings: true,
    };

    handleSettingsClick(event) {
        event.preventDefault();
        event.stopPropagation();
        const pageReference = {
            type: "standard__component",
            attributes: {
                componentName: this.educationCloudSettingsContainerComponentNavigation,
            },
        };
        this[NavigationMixin.Navigate](pageReference);
    }

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
            case "relationshipmapping":
                this.template.querySelector("c-relationship-settings").modalSave(saveModel);
                break;
            case "batchjob":
                this.template.querySelector("c-system-tools").modalConfirm(saveModel);
                break;
        }
    }
}
