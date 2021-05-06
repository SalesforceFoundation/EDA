import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class EdcSettingsCard extends NavigationMixin(LightningElement) {
    //Avatar
    @api iconSrc = "/bad/image/url.jpg";
    @api iconSize = "medium";
    @api iconInitials = "EDA";
    @api iconFallbackName = "standard:avatar";

    //Body
    @api title;
    @api description;
    //Links
    @api settingsComponent;
    @api documentationUrl;
    @api trailheadUrl;

    labelReference = {
        settingsButton: "Settings",
        settingsButtonA11y: "Manage Settings",
        documentationButton: "Documentation",
        documentationButtonA11y: "Visit Documentation",
        trailheadButton: "Trailhead",
        trailheadButtonA11y: "Visit Trailhead",
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
