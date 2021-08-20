import { LightningElement, track, wire, api } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//Release gate labels
import stgReleaseGateInProgress from "@salesforce/label/c.stgReleaseGateInProgress";
import stgReleaseGateActivateSuccess from "@salesforce/label/c.stgReleaseGateActivateSuccess";
import stgReleaseGateActivateInProgress from "@salesforce/label/c.stgReleaseGateActivateInProgress";
import stgSuccess from "@salesforce/label/c.stgSuccess";
//Apex methods
import getProductRegistryReleaseGateVModels from "@salesforce/apex/ReleaseGateController.getProductRegistryReleaseGateVModels";
import activateReleaseGate from "@salesforce/apex/ReleaseGateController.activateReleaseGate";

export default class ReleaseGates extends LightningElement {
    @track productRegistryReleaseGateVModels;
    @track productRegistryReleaseGateWireResult;

    labelReference = {
        releaseGateActivateSuccess: stgReleaseGateActivateSuccess,
        releaseGateActivateInProgress: stgReleaseGateActivateInProgress,
        inProgressTitle: stgReleaseGateInProgress,
        successTitle: stgSuccess,
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
        Array.prototype.filter
            .call(
                this.template.querySelectorAll("c-release-gate-product"),
                (product) => product.productRegistryName == saveModel.productRegistryName
            )
            .forEach((releaseGateProduct) => {
                releaseGateProduct.setReleaseGateStatus(saveModel.productName, saveModel.releaseGateName, "inprogress");
            });
        activateReleaseGate({
            productRegistryName: saveModel.productRegistryName,
            productName: saveModel.productName,
            gateName: saveModel.releaseGateName,
        })
            .then((result) => {
                if (result) {
                    let message, title, toastType, toastMode;
                    let releaseGateLabel = saveModel.productLabel + " " + saveModel.releaseGateLabel;
                    let isInProgress = result.some((activateResult) => activateResult.status === "inprogress");
                    if (isInProgress) {
                        title = this.labelReference.inProgressTitle.replace("{0}", releaseGateLabel);
                        message = this.labelReference.releaseGateActivateInProgress.replace("{0}", releaseGateLabel);
                        toastType = "info";
                        toastMode = "sticky";
                    } else {
                        message = this.labelReference.releaseGateActivateSuccess.replace("{0}", releaseGateLabel);
                        title = this.labelReference.successTitle;
                        toastType = "success";
                        toastMode = "sticky";
                    }
                    this.showToast(toastType, title, message, toastMode);
                } else {
                    //console.log("Activate error: the mapping was not found");
                }
                this.refreshAllApex();
            })
            .catch((error) => {
                //console.log("Inside error");
                this.refreshAllApex();
            });
    }

    refreshAllApex() {
        Promise.all([refreshApex(this.productRegistryReleaseGateWireResult)]).then(() => {
            this.template
                .querySelectorAll("c-release-gate-product")
                .forEach((releaseGateProduct) => releaseGateProduct.refresh());
        });
    }

    showToast(toastType, toastTitle, toastMessage, toastMode) {
        const showToastEvent = new ShowToastEvent({
            title: toastTitle,
            message: toastMessage,
            variant: toastType,
            mode: toastMode,
        });
        this.dispatchEvent(showToastEvent);
    }
}
