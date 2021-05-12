import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

//Settings Card Labels
import stgBtnSettings from "@salesforce/label/c.stgBtnSettings";
import stgBtnSettingsAction from "@salesforce/label/c.stgBtnSettingsAction";
import stgBtnDocumentation from "@salesforce/label/c.stgBtnDocumentation";
import stgBtnDocumentationAction from "@salesforce/label/c.stgBtnDocumentationAction";
import stgBtnTrailhead from "@salesforce/label/c.stgBtnTrailhead";
import stgBtnTrailheadAction from "@salesforce/label/c.stgBtnTrailheadAction";

export default class EdcSettingsCard extends NavigationMixin(LightningElement) {
    iconSize = "medium";

    //Avatar
    @api iconSrc;
    @api iconInitials;
    @api iconFallbackName;

    //Body
    @api title;
    @api description;
    //Links
    @api settingsComponent;
    @api documentationUrl;
    @api trailheadUrl;

    labelReference = {
        settingsButton: stgBtnSettings,
        settingsButtonA11y: stgBtnSettingsAction,
        documentationButton: stgBtnDocumentation,
        documentationButtonA11y: stgBtnDocumentationAction,
        trailheadButton: stgBtnTrailhead,
        trailheadButtonA11y: stgBtnTrailheadAction,
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
}
