import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

//Settings Card Labels
import stgBtnSettings from "@salesforce/label/c.stgBtnSettings";
import stgBtnDocumentation from "@salesforce/label/c.stgBtnDocumentation";
import stgBtnTrailhead from "@salesforce/label/c.stgBtnTrailhead";

import getEDCSettingsProductVModel from "@salesforce/apex/EducationCloudSettingsController.getEDCSettingsProductVModel";

export default class EdcSettingsProductCard extends NavigationMixin(LightningElement) {
    @api displayProductCards;
    @api productRegistry;

    @track showThisProduct = false;

    iconSize = "medium";

    //Avatar
    @track iconSrc;
    @track iconInitials;
    @track iconFallbackName;

    //Body
    @track title;
    @track description;
    //Links
    @track settingsComponent;
    @track documentationUrl;
    @track trailheadUrl;
    //Titles for Links
    @track settingsButtonA11y;
    @track documentationButtonA11y;
    @track trailheadButtonA11y;

    labelReference = {
        settingsButton: stgBtnSettings,
        documentationButton: stgBtnDocumentation,
        trailheadButton: stgBtnTrailhead
    };

    handleSettingsClick(event) {
        event.preventDefault();
        event.stopPropagation();
        const pageReference = {
            type: "standard__component",
            attributes: {
                componentName: this.settingsComponent,
            },
        };
        this[NavigationMixin.Navigate](pageReference);
    }

    handleDocumentationClick(event) {
        event.preventDefault();
        event.stopPropagation();
        const pageReference = {
            type: "standard__webPage",
            attributes: {
                url: this.documentationUrl,
            },
        };
        this[NavigationMixin.Navigate](pageReference);
    }

    handleTrailheadClick(event) {
        event.preventDefault();
        event.stopPropagation();
        const pageReference = {
            type: "standard__webPage",
            attributes: {
                url: this.trailheadUrl,
            },
        };
        this[NavigationMixin.Navigate](pageReference);
    }

    get showProductCard() {
        if (this.displayProductCards && this.showThisProduct) {
            return true;
        }
        return false;
    }

    connectedCallback() {
        getEDCSettingsProductVModel({
            classname: this.productRegistry.classname,
            namespace: this.productRegistry.namespace,
            apiVersion: this.productRegistry.apiVersion,
        })
            .then((result) => {
                this.title = result.name;
                this.description = result.description;
                this.iconInitials = result.initials;
                this.iconFallbackName = result.icon;
                this.settingsComponent = result.settingsComponent;
                this.settingsButtonA11y = result.settingsButtonA11y;
                this.documentationUrl = result.documentationUrl;
                this.documentationButtonA11y = result.documentationButtonA11y;
                this.trailheadUrl = result.trailheadUrl;
                this.trailheadButtonA11y = result.trailheadButtonA11y;
                this.showThisProduct = true;
                this.dispatchEvent(new CustomEvent("settingsproductloaded"));
            })
            .catch((error) => {
                this.showThisProduct = false;
                let errorMessage = this.getErrorMessage(error);
                this.dispatchEvent(new CustomEvent("settingsproducterror", { detail: { errorMessage: errorMessage } }));
            });
    }

    getErrorMessage(error) {
        let errorMessage = "Unknown error";
        if (Array.isArray(error.body)) {
            errorMessage = error.body.map((e) => e.message).join(", ");
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
