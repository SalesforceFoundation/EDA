import { LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";

// import custom labels
import stgHealthCheckTitle from "@salesforce/label/c.stgHealthCheckTitle";
import EDCSettingsContainerAuraComponentLabel from "@salesforce/label/c.EDCSettingsContainerAuraComponentLabel";

import namespacedEDAField from "@salesforce/schema/Course_Offering_Schedule__c.Course_Offering__c";
const EducationCloudSettingsContainerComponentName = "EducationCloudSettingsContainer";

export default class HealthCheckHighlightsPanel extends NavigationMixin(LightningElement) {
    labelReference = {
        healthCheck: stgHealthCheckTitle,
        educationCloudSettings: EDCSettingsContainerAuraComponentLabel,
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
}
