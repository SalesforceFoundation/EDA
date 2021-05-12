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

//EDA Services Labels
import stgHealthCheckTitle from "@salesforce/label/c.stgHealthCheckTitle";
import stgHealthCheckDescription from "@salesforce/label/c.stgHealthCheckDescription";
import stgHealthCheckAction from "@salesforce/label/c.stgHealthCheckAction";

//EDA Resources Labels
import stgBtnTrailhead from "@salesforce/label/c.stgBtnTrailhead";
import stgBtnTrailheadAction from "@salesforce/label/c.stgBtnTrailheadAction";
import stgCommunityTitle from "@salesforce/label/c.stgCommunityTitle";
import stgBtnCommunityAction from "@salesforce/label/c.stgBtnCommunityAction";
import stgVideosTitle from "@salesforce/label/c.stgVideosTitle";
import stgBtnVideosAction from "@salesforce/label/c.stgBtnVideosAction";
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
            title: stgHealthCheckTitle,
            description: stgHealthCheckDescription,
            buttonLabel: stgHealthCheckAction,
            navigationType: "standard__component",
            navigationTarget: "c__HealthCheckContainer",
        },
    ];

    @track edcResourceModels = [
        {
            title: stgBtnTrailhead,
            buttonLabel: stgBtnTrailheadAction,
            navigationType: "standard__webPage",
            navigationTarget:
                "https://trailhead.salesforce.com/en/users/sfdo/trailmixes/get-started-with-education-cloud",
        },
        {
            title: stgCommunityTitle,
            buttonLabel: stgBtnCommunityAction,
            navigationType: "standard__webPage",
            navigationTarget: "https://trailblazers.salesforce.com/successHome",
        },
        {
            title: stgVideosTitle,
            buttonLabel: stgBtnVideosAction,
            navigationType: "standard__webPage",
            navigationTarget: "https://www.youtube.com/user/SalesforceFoundation",
        },
    ];
}
