import { LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";

// import custom labels
import stgHealthCheckTitle from "@salesforce/label/c.stgHealthCheckTitle";
import EDCSettingsContainerAuraComponentLabel from "@salesforce/label/c.EDCSettingsContainerAuraComponentLabel";

export default class HealthCheckHighlightsPanel extends NavigationMixin(LightningElement) {
    labelReference = {
        healthCheck: stgHealthCheckTitle,
        educationCloudSettings: EDCSettingsContainerAuraComponentLabel,
    };

    handleSettingsClick(event) {
        event.preventDefault();
        event.stopPropagation();
        const pageReference = {
            type: "standard__component",
            attributes: {
                componentName: "c__EducationCloudSettingsContainer",
            },
        };
        this[NavigationMixin.Navigate](pageReference);
    }
}
