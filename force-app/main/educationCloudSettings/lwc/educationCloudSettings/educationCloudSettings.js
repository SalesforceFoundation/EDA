import { LightningElement, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";

//Column Header Labels
import stgColProducts from "@salesforce/label/c.stgColProducts";
import stgColResources from "@salesforce/label/c.stgColResources";
import stgColServices from "@salesforce/label/c.stgColServices";

//EDA Labels
import stgEDAAppDesc from "@salesforce/label/c.stgEDAAppDesc";
import stgEDAAppTitle from "@salesforce/label/c.stgEDAAppTitle";
import stgEDAAppInitials from "@salesforce/label/c.stgEDAAppInitials";
export default class EducationCloudSettings extends NavigationMixin(LightningElement) {
    labelReference = {
        productsTitle: stgColProducts,
        resourcesTitle: stgColResources,
        servicesTitle: stgColServices,
    };

    @track edcProductModels = [
        {
            title: stgEDAAppTitle,
            description: stgEDAAppDesc,
            iconSrc: "/bad/image/url.jpg",
            iconInitials: stgEDAAppInitials,
            iconFallbackName: "standard:avatar",
            settingsComponent: "c__EdaSettingsContainer",
            documentationUrl: "https://powerofus.force.com/s/article/EDA-Documentation",
            trailheadUrl: "https://trailhead.salesforce.com/en/content/learn/trails/highered_heda",
        },
    ];

    @track edcServiceModels = [
        {
            title: "Settings Health Check",
            description:
                "Settings Health Check checks your org Education Settings for invalid configurations. When complete, use the results to identify and fix any invalid settings. Launch Settings Health Check from here.",
            buttonLabel: "Launch Health Check",
            navigationType: "standard__component",
            navigationTarget: "c__HealthCheckContainer",
        },
    ];

    @track edcResourceModels = [
        {
            title: "Trailhead",
            buttonLabel: "Visit Trailhead",
            navigationType: "standard__webPage",
            navigationTarget:
                "https://trailhead.salesforce.com/en/users/sfdo/trailmixes/get-started-with-education-cloud",
        },
        {
            title: "Trailblazer Community",
            buttonLabel: "Visit Trailblazer Community",
            navigationType: "standard__webPage",
            navigationTarget: "https://trailblazers.salesforce.com/successHome",
        },
        {
            title: "Youtube",
            buttonLabel: "Visit Salesforce.org on YouTube",
            navigationType: "standard__webPage",
            navigationTarget: "https://www.youtube.com/user/SalesforceFoundation",
        },
    ];
}
