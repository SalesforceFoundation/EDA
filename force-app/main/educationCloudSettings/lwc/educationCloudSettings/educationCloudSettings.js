import { LightningElement, track, wire, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

//Column Header Labels
import stgColProducts from "@salesforce/label/c.stgColProducts";
import stgColResources from "@salesforce/label/c.stgColResources";
import stgColTools from "@salesforce/label/c.stgColTools";
import stgReleaseManagementCardTitle from "@salesforce/label/c.stgReleaseManagementCardTitle";
import EDCSettingsContainerAuraComponentLabel from "@salesforce/label/c.EDCSettingsContainerAuraComponentLabel";

//EDA Services Labels
import stgHealthCheckTitle from "@salesforce/label/c.stgHealthCheckTitle";
import stgEDCSettingsHealthCheckDescription from "@salesforce/label/c.stgEDCSettingsHealthCheckDescription";
import stgBtnHealthCheck from "@salesforce/label/c.stgBtnHealthCheck";
import stgHealthCheckA11y from "@salesforce/label/c.stgHealthCheckA11y";

//EDA Resources Labels
import stgTrailheadTitle from "@salesforce/label/c.stgTrailheadTitle";
import stgBtnEDCTrailhead from "@salesforce/label/c.stgBtnEDCTrailhead";
import stgBtnEDCTrailheadActionA11y from "@salesforce/label/c.stgBtnEDCTrailheadActionA11y";
import stgCommunityTitle from "@salesforce/label/c.stgCommunityTitle";
import stgBtnCommunity from "@salesforce/label/c.stgBtnCommunity";
import stgBtnCommunityActionA11y from "@salesforce/label/c.stgBtnCommunityActionA11y";
import stgVideosTitle from "@salesforce/label/c.stgVideosTitle";
import stgBtnVideos from "@salesforce/label/c.stgBtnVideos";
import stgBtnVideosActionA11y from "@salesforce/label/c.stgBtnVideosActionA11y";

import namespacedEDAField from "@salesforce/schema/Course_Offering_Schedule__c.Course_Offering__c";

import getProductRegistrySettingsProductInformationVModels from "@salesforce/apex/EducationCloudSettingsController.getProductRegistrySettingsProductInformationVModels";

const HealthCheckContainerComponentName = "HealthCheckContainer";
const ReleaseManagementContainerComponentName = "releaseManagementContainer";

const EDCTrailheadUrl = "https://trailhead.salesforce.com/en/users/sfdo/trailmixes/get-started-with-education-cloud";
const TrailblazerCommunityUrl = "https://trailblazers.salesforce.com/successHome";
const YoutubeUrl = "https://www.youtube.com/user/SalesforceFoundation";

export default class EducationCloudSettings extends NavigationMixin(LightningElement) {
    @track edcProductRegistryVModels;

    labelReference = {
        productsTitle: stgColProducts,
        resourcesTitle: stgColResources,
        releaseManagementTitle: stgReleaseManagementCardTitle,
        toolsTitle: stgColTools,
        pageTitle: EDCSettingsContainerAuraComponentLabel,
    };

    get edaComponentNavigationPrefix() {
        const apiName = namespacedEDAField.fieldApiName;
        const navigationPrefix = apiName.replace("Course_Offering__c", "");

        if (navigationPrefix === "") {
            return "c__";
        }

        return navigationPrefix;
    }

    get healthCheckContainerComponentNavigation() {
        return this.edaComponentNavigationPrefix + HealthCheckContainerComponentName;
    }

    get releaseManagementContainerComponentNavigation() {
        return this.edaComponentNavigationPrefix + ReleaseManagementContainerComponentName;
    }

    @api handleNavigate(pageReference) {
        this.template.querySelector("c-edc-release-management-card").refresh();
    }

    @wire(getProductRegistrySettingsProductInformationVModels)
    edcSettingsProductRegistryVModels({ error, data }) {
        if (data) {
            this.edcProductRegistryVModels = data;
        } else if (error) {
            this.showErrorToast(error);
        }
    }

    @track edcToolModels = [
        {
            title: stgHealthCheckTitle,
            description: stgEDCSettingsHealthCheckDescription,
            iconName: "custom:custom94",
            buttonLabel: stgBtnHealthCheck,
            buttonTitle: stgHealthCheckA11y,
            navigationType: "standard__component",
            navigationTarget: this.healthCheckContainerComponentNavigation,
        },
    ];

    @track edcResourceModels = [
        {
            title: stgTrailheadTitle,
            iconName: "standard:trailhead",
            buttonLabel: stgBtnEDCTrailhead,
            buttonTitle: stgBtnEDCTrailheadActionA11y,
            navigationType: "standard__webPage",
            navigationTarget: EDCTrailheadUrl,
        },
        {
            title: stgCommunityTitle,
            iconName: "standard:groups",
            buttonLabel: stgBtnCommunity,
            buttonTitle: stgBtnCommunityActionA11y,
            navigationType: "standard__webPage",
            navigationTarget: TrailblazerCommunityUrl,
        },
        {
            title: stgVideosTitle,
            iconName: "standard:video",
            buttonLabel: stgBtnVideos,
            buttonTitle: stgBtnVideosActionA11y,
            navigationType: "standard__webPage",
            navigationTarget: YoutubeUrl,
        },
    ];

    showErrorToast(error) {
        let errorMessage = "Unknown error";
        if (Array.isArray(error.body)) {
            errorMessage = error.body.map((e) => e.message).join(", ");
        } else {
            if (error.body && typeof error.body.message === "string") {
                errorMessage = error.body.message;
            } else {
                errorMessage = error.message;
            }
        }

        const evt = new ShowToastEvent({
            title: "Error",
            message: errorMessage,
            variant: "error",
            mode: "sticky",
        });
        this.dispatchEvent(evt);
    }
}
