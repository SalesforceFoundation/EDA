import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

//Settings Card Labels
import stgBtnSettings from "@salesforce/label/c.stgBtnSettings";
import stgBtnSettingsActionA11y from "@salesforce/label/c.stgBtnSettingsActionA11y";
import stgBtnDocumentation from "@salesforce/label/c.stgBtnDocumentation";
import stgBtnDocumentationActionA11y from "@salesforce/label/c.stgBtnDocumentationActionA11y";
import stgBtnTrailhead from "@salesforce/label/c.stgBtnTrailhead";
import stgBtnTrailheadActionA11y from "@salesforce/label/c.stgBtnTrailheadActionA11y";

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

    labelReference = {
        settingsButton: stgBtnSettings,
        settingsButtonA11y: stgBtnSettingsActionA11y,
        documentationButton: stgBtnDocumentation,
        documentationButtonA11y: stgBtnDocumentationActionA11y,
        trailheadButton: stgBtnTrailhead,
        trailheadButtonA11y: stgBtnTrailheadActionA11y,
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
        if (this.displayProductCards && 
            this.showThisProduct) {
            return true;
        }
        return false;
    }

    connectedCallback(){
        getEDCSettingsProductVModel({
            classname: this.productRegistry.classname,
            namespace: this.productRegistry.namespace,
            apiVersion: this.productRegistry.apiVersion
        })
        .then((result) => {
            this.title = result.name;
            this.description = result.description;
            this.iconInitials = result.initials;
            this.iconFallbackName = result.icon;
            this.settingsComponent = result.settingsComponent;
            this.documentationUrl = result.documentationUrl;
            this.trailheadUrl = result.trailheadUrl;
            this.showThisProduct = true;
            this.dispatchEvent(new CustomEvent("settingsproductloaded"));
        })
        .catch((error) => {
            this.showThisProduct = false;
            let errorMessage = this.getErrorMessage(error);
            this.dispatchEvent(
                new CustomEvent("settingsproducterror",
                { detail : 
                    { errorMessage : errorMessage }
                }
            ));
        });
    }

    getErrorMessage(error) {
        let errorMessage = 'Unknown error';
        if (Array.isArray(error.body)) {
            errorMessage = error.body.map(e => e.message).join(', ');
        } else {
            if (error.body && typeof error.body.message === 'string') {
                errorMessage = error.body.message;
            } else {
                errorMessage = error.message;     
            }
        }
        return errorMessage;
    }
}
