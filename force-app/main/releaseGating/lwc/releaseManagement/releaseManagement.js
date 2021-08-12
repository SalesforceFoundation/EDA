import { LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";
//Release Management Labels
import stgReleaseManagementTitle from "@salesforce/label/c.stgReleaseManagementTitle";
import EDCSettingsContainerAuraComponentLabel from "@salesforce/label/c.EDCSettingsContainerAuraComponentLabel";

import namespacedEDAField from "@salesforce/schema/Course_Offering_Schedule__c.Course_Offering__c";
const EducationCloudSettingsContainerComponentName = "EducationCloudSettingsContainer";

export default class EdcReleaseManagement extends NavigationMixin(LightningElement) {
    labelReference = {
        releaseManagementTitle: stgReleaseManagementTitle,
        educationCloudSettings: EDCSettingsContainerAuraComponentLabel,
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
}
