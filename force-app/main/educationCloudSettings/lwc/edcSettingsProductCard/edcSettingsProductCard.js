import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

//Settings Card Labels
import stgBtnSettings from "@salesforce/label/c.stgBtnSettings";
import stgBtnSettingsActionA11y from "@salesforce/label/c.stgBtnSettingsActionA11y";
import stgBtnDocumentation from "@salesforce/label/c.stgBtnDocumentation";
import stgBtnDocumentationActionA11y from "@salesforce/label/c.stgBtnDocumentationActionA11y";
import stgBtnTrailhead from "@salesforce/label/c.stgBtnTrailhead";
import stgBtnTrailheadActionA11y from "@salesforce/label/c.stgBtnTrailheadActionA11y";

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
}
