import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class EdcSettingsCard extends LightningElement {
    //Avatar
    @api iconSrc = "/bad/image/url.jpg";
    @api iconSize = "medium";
    @api iconInitials = "EDA";
    @api iconFallbackName = "standard-avatar";

    //Body
    @api title = "Education Data Architecture";
    @api description =
        "Education Data Architecture (EDA), the foundation of Education Cloud. Developed, is a flexible data architecture designed to configure Salesforce for education. Manage EDA Settings from here.";
    //Links
    @api settingsComponent = "c__edaSettingsContainer";
    @api documentationUrl = "https://powerofus.force.com/s/article/EDA-Documentation";
    @api trailheadUrl = "https://trailhead.salesforce.com/en/content/learn/trails/highered_heda";

    labelReference = {
        settingsButton: "Settings",
        settingsButtonA11y: "Manage Settings",
        documentationButton: "Documentation",
        documentationButtonA11y: "Visit Documentation",
        trailheadButton: "Trailhead",
        trailheadButtonA11y: "Visit Trailhead",
    };

    handleSettingsClick(event) {
        console.log("Settings clicked");
        event.preventDefault();
        console.log("Navigating to: " + settingsComponent);
        const pageReference = {
            type: "standard__component",
            attributes: {
                componentName: settingsComponent,
            },
            state: {},
        };
        this[NavigationMixin.Navigate](pageReference);
    }

    handleDocumentationClick(event) {
        console.log("Documentation clicked");
        event.preventDefault();
        console.log("Navigating to: " + documentationUrl);
        const pageReference = {
            type: "standard__webPage",
            attributes: {
                url: documentationUrl,
            },
        };
        this[NavigationMixin.Navigate](pageReference);
    }

    handleTrailheadClick(event) {
        console.log("Trailhead clicked");
        event.preventDefault();
        console.log("Navigating to: " + trailheadUrl);
        const pageReference = {
            type: "standard__webPage",
            attributes: {
                url: trailheadUrl,
            },
        };
        this[NavigationMixin.Navigate](pageReference);
    }
}
