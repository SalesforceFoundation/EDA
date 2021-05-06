import { LightningElement, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
//import getEDCSettingsModels from "@salesforce/apex/EDCSettingsController.getEDCSettingsModels";
export default class EdcSettings extends NavigationMixin(LightningElement) {
    @track edcSettingsModels = [
        {
            title: "Education Data Architecture",
            description:
                "Education Data Architecture (EDA), the foundation of Education Cloud. Developed, is a flexible data architecture designed to configure Salesforce for education. Manage EDA Settings from here.",
            iconSrc: "/bad/image/url.jpg",
            iconSize: "medium",
            iconInitials: "EDA",
            iconFallbackName: "standard-avatar",
            settingsComponent: "c__edaSettingsContainer",
            documentationUrl: "https://powerofus.force.com/s/article/EDA-Documentation",
            trailheadUrl: "https://trailhead.salesforce.com/en/content/learn/trails/highered_heda",
        },
    ];
}
