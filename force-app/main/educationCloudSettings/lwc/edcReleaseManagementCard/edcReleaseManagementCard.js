import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

//Release Management Labels
import stgReleaseManagementCardTitle from "@salesforce/label/c.stgReleaseManagementCardTitle";
import stgReleaseManagementDescription from "@salesforce/label/c.stgReleaseManagementDescription";
import stgBtnReleaseManagement from "@salesforce/label/c.stgBtnReleaseManagement";
import stgBtnReleaseManagementA11y from "@salesforce/label/c.stgBtnReleaseManagementA11y";

export default class EdcReleaseManagementCard extends NavigationMixin(LightningElement) {
    @api navigationTarget;

    labelReference = {
        releaseManagementButton: stgBtnReleaseManagement,
        releaseManagementButtonA11y: stgBtnReleaseManagementA11y,
        releaseManagementTitle: stgReleaseManagementCardTitle,
        releaseManagementDescription: stgReleaseManagementDescription,
    };

    handleNavigationClick(event) {
        event.preventDefault();
        event.stopPropagation();
        this.navigateToComponent();
        return;
    }

    navigateToComponent() {
        const pageReference = {
            type: "standard__component",
            attributes: {
                componentName: this.navigationTarget,
            },
        };
        this[NavigationMixin.Navigate](pageReference);
    }
}
