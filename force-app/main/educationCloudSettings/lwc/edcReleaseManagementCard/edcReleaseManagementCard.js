import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

//ReleaseGateController methods
import getProductRegistryReleaseGateVModels from "@salesforce/apex/ReleaseGateController.getProductRegistryReleaseGateVModels";
import getReleaseGateVModel from "@salesforce/apex/ReleaseGateController.getReleaseGateVModel";

//Release Management Labels
import stgReleaseManagementCardTitle from "@salesforce/label/c.stgReleaseManagementCardTitle";
import stgReleaseManagementDescription from "@salesforce/label/c.stgReleaseManagementDescription";
import stgBtnReleaseManagement from "@salesforce/label/c.stgBtnReleaseManagement";
import stgBtnReleaseManagementA11y from "@salesforce/label/c.stgBtnReleaseManagementA11y";
import stgReleaseGateProgressIndicatorIncomplete from "@salesforce/label/c.stgReleaseGateProgressIndicatorIncomplete";
import stgReleaseGateProgressIndicatorComplete from "@salesforce/label/c.stgReleaseGateProgressIndicatorComplete";

const ReleaseGateStatus = {
    ACTIVE: "active",
    INACTIVE: "inactive",
    DISABLED: "disabled",
    INPROGRESS: "inprogress",
};

export default class EdcReleaseManagementCard extends NavigationMixin(LightningElement) {
    @api navigationTarget;
    activeReleaseGatesCount = 0;
    inactiveReleaseGatesCount = 0;
    totalReleaseGatesCount = 0;
    releaseGateRequestFinished = false;
    productRegistryReleaseGateVModels;
    productRegistryReleaseGateWireResult;
    releaseGateVModel;

    get notificationsVisible() {
        return this.releaseGateRequestFinished && this.totalReleaseGatesCount > 0;
    }

    get allReleaseGatesActive() {
        return this.activeReleaseGatesCount === this.totalReleaseGatesCount;
    }

    get activatedPercentage() {
        return this.totalReleaseGatesCount > 0
            ? (this.activeReleaseGatesCount / this.totalReleaseGatesCount) * 100.0
            : 100;
    }

    get releaseStatusText() {
        if (this.allReleaseGatesActive) {
            return this.labelReference.releaseProgressComplete;
        } else {
            return this.labelReference.releaseProgressIncomptete
                .replace("{0}", this.activeReleaseGatesCount)
                .replace("{1}", this.totalReleaseGatesCount);
        }
    }

    get progressVariant() {
        return this.allReleaseGatesActive ? "base-autocomplete" : "warning";
    }

    labelReference = {
        releaseManagementButton: stgBtnReleaseManagement,
        releaseManagementButtonA11y: stgBtnReleaseManagementA11y,
        releaseManagementTitle: stgReleaseManagementCardTitle,
        releaseManagementDescription: stgReleaseManagementDescription,
        releaseProgressIncomptete: stgReleaseGateProgressIndicatorIncomplete,
        releaseProgressComplete: stgReleaseGateProgressIndicatorComplete,
    };

    connectedCallback() {
        this.refresh();
    }

    @api refresh() {
        getProductRegistryReleaseGateVModels()
            .then((result) => {
                this.productRegistryReleaseGateWire({ data: result });
            })
            .catch((error) => {
                this.productRegistryReleaseGateWire({ error: error });
            });
    }

    productRegistryReleaseGateWire(result) {
        this.releaseGateErrorList = [];
        this.productRegistryReleaseGateWireResult = result;
        if (result.data) {
            this.productRegistryReleaseGateVModels = result.data;
            Promise.allSettled(
                this.productRegistryReleaseGateVModels.map((releaseGateProductRegistry) =>
                    getReleaseGateVModel({ productRegistryName: releaseGateProductRegistry.name })
                )
            ).then((getResult) => {
                this.releaseGateVModel = getResult
                    .filter((r) => r.status == "fulfilled" && r.value)
                    .flatMap((r) => r.value);
                this.calculateReleaseProgress();
                this.releaseGateRequestFinished = true;
            });
        } else if (result.error) {
            this.sendErrorMessage(result.error);
        }
    }

    calculateReleaseProgress() {
        let numActivated = 0,
            numInactive = 0;
        this.releaseGateVModel
            .flatMap((rgModel) => rgModel.gates)
            .forEach((rg) => {
                if (rg.status == ReleaseGateStatus.ACTIVE) {
                    numActivated++;
                } else if (rg.status != ReleaseGateStatus.DISABLED) {
                    numInactive++;
                }
            });
        this.activeReleaseGatesCount = numActivated;
        this.inactiveReleaseGatesCount = numInactive;
        this.totalReleaseGatesCount = numInactive + numActivated;
    }

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

    sendErrorMessage(error) {
        console.error(error);
    }
}
