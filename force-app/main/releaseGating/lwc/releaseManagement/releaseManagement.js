import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//Release Management Labels
import stgReleaseManagementTitle from "@salesforce/label/c.stgReleaseManagementTitle";
import EDCSettingsContainerAuraComponentLabel from "@salesforce/label/c.EDCSettingsContainerAuraComponentLabel";
import stgToastError from "@salesforce/label/c.stgToastError";

import namespacedEDAField from "@salesforce/schema/Course_Offering_Schedule__c.Course_Offering__c";
const EducationCloudSettingsContainerComponentName = "EducationCloudSettingsContainer";

export default class EdcReleaseManagement extends NavigationMixin(LightningElement) {
    labelReference = {
        releaseManagementTitle: stgReleaseManagementTitle,
        educationCloudSettings: EDCSettingsContainerAuraComponentLabel,
        errorToastTitle: stgToastError,
    };

    iconReference = {
        highlightsIcon: "standard:activations",
    };

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

    @api modalSave(saveModel) {
        switch (saveModel.modalType) {
            case "releasegate":
                this.template.querySelector("c-release-gates").modalSave(saveModel);
                break;
        }
    }

    handleErrorMessage(event) {
        event.stopPropagation();
        this.displayErrorMessage(this.getErrorMessage(event.detail));
    }

    displayErrorMessage(errorMessage) {
        console.error(errorMessage);
        this.dispatchEvent(
            new ShowToastEvent({
                title: this.labelReference.errorToastTitle,
                message: errorMessage,
                variant: "error",
                mode: "sticky",
            })
        );
    }

    getErrorMessage(error) {
        let errorMessage = "Unknown error";
        if (Array.isArray(error)) {
            errorMessage = error.map((e) => this.getErrorMessage(e)).join(";\r\n");
        } else if (Array.isArray(error.body)) {
            errorMessage = error.body.map((e) => e.message).join(", ");
        } else if (typeof error === "string" || error instanceof String) {
            errorMessage = error;
        } else {
            if (error.body && typeof error.body.message === "string") {
                errorMessage = error.body.message;
            } else {
                errorMessage = error.message;
            }
        }
        return errorMessage;
    }
}
