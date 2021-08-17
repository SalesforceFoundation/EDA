import { LightningElement, track, wire, api } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import stgReleaseGateInProgress from "@salesforce/label/c.stgReleaseGateInProgress";
import stgReleaseGateActivateSuccess from "@salesforce/label/c.stgReleaseGateActivateSuccess";
import stgSuccess from "@salesforce/label/c.stgSuccess";
import getProductRegistryReleaseGateVModels from "@salesforce/apex/ReleaseGateController.getProductRegistryReleaseGateVModels";
import activateReleaseGate from "@salesforce/apex/ReleaseGateController.activateReleaseGate";

export default class ReleaseGates extends LightningElement {
    @track productRegistryReleaseGateVModels;
    @track productRegistryReleaseGateWireResult;

    labelReference = {
        releaseGateActivateSuccess: stgReleaseGateActivateSuccess,
        releaseGateInProgress: stgReleaseGateInProgress,
        success: stgSuccess,
    };

    @wire(getProductRegistryReleaseGateVModels)
    productRegistryReleaseGateWire(result) {
        this.productRegistryReleaseGateWireResult = result;
        if (result.data) {
            this.productRegistryReleaseGateVModels = result.data;
        } else if (result.error) {
            //console.log("error retrieving productRegistryReleaseGateVModels");
        }
    }

    @api modalSave(saveModel) {
        switch (saveModel.releaseGateAction) {
            case "activate":
                this.executeActivateReleaseGate(saveModel);
                break;
        }
    }

    executeActivateReleaseGate(saveModel) {
        activateReleaseGate({
            productRegistryName: saveModel.productRegistryName,
            productName: saveModel.productName,
            gateName: saveModel.releaseGateName,
        })
            .then((result) => {
                if (result) {
                    let message, title, toastType;
                    let releaseGateLabel = saveModel.productLabel + " " + saveModel.releaseGateLabel;
                    if (result.some((activateResult) => activateResult.status === "inprogress")) {
                        title = this.labelReference.releaseGateInProgress.replace("{0}", releaseGateLabel);
                        message = "";
                        toastType = "info";
                    } else {
                        message = this.labelReference.releaseGateActivateSuccess.replace("{0}", releaseGateLabel);
                        title = this.labelReference.success;
                        toastType = "success";
                    }
                    this.showToast(toastType, title, message);
                } else {
                    //console.log("Activate error: the mapping was not found");
                }
                this.refreshAllApex();
            })
            .catch((error) => {
                //console.log("Inside error");
            });
    }

    refreshAllApex() {
        Promise.all([refreshApex(this.productRegistryReleaseGateWireResult)]).then(() => {
            this.template
                .querySelectorAll("c-release-gate-product")
                .forEach((releaseGateProduct) => releaseGateProduct.refresh());
        });
    }

    showToast(toastType, toastTitle, toastMessage) {
        const showToastEvent = new ShowToastEvent({
            title: toastTitle,
            message: toastMessage,
            variant: toastType,
            mode: "sticky",
        });
        this.dispatchEvent(showToastEvent);
    }
}
