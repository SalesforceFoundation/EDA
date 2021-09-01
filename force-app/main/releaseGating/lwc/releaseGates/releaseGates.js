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
    releaseGateLoadCount;
    releaseGateErrorList;

    labelReference = {
        releaseGateActivateSuccess: stgReleaseGateActivateSuccess,
        releaseGateActivateInProgress: stgReleaseGateActivateInProgress,
        inProgressTitle: stgReleaseGateInProgress,
        successTitle: stgSuccess,
    };

    @wire(getProductRegistryReleaseGateVModels)
    productRegistryReleaseGateWire(result) {
        this.releaseGateLoadCount = 0;
        this.releaseGateErrorList = [];
        this.productRegistryReleaseGateWireResult = result;
        if (result.data) {
            this.productRegistryReleaseGateVModels = result.data;
        } else if (result.error) {
            this.sendErrorMessage(result.error);
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
                let message, title, toastType, toastMode;
                let releaseGateLabel = saveModel.productLabel + " " + saveModel.releaseGateLabel;
                let isInProgress = !result || result.some((activateResult) => activateResult.status === "inprogress");
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
                this.refreshAllApex(saveModel.productRegistryName, false);
            })
            .catch((error) => {
                this.sendErrorMessage(error);
                this.refreshAllApex(saveModel.productRegistryName, true);
            });
    }

    handleReleaseGateLoadSuccess(event) {
        this.releaseGateLoadCount++;
        this.showErrorsIfLoadComplete();
    }

    handleReleaseGateLoadError(event) {
        this.releaseGateLoadCount++;
        if (event && event.detail) {
            this.releaseGateErrorList.push(event.detail);
        }
        this.showErrorsIfLoadComplete();
    }

    showErrorsIfLoadComplete() {
        if (
            this.releaseGateLoadCount == this.productRegistryReleaseGateVModels.length &&
            this.releaseGateErrorList &&
            this.releaseGateErrorList.length > 0
        ) {
            this.sendErrorMessage(this.releaseGateErrorList);
        }
    }

    refreshAllApex(productRegistryName, resetGateStatus) {
        Promise.all([refreshApex(this.productRegistryReleaseGateWireResult)]).then(() => {
            this.template.querySelectorAll("c-release-gate-product").forEach((releaseGateProduct) => {
                if (releaseGateProduct.productRegistryName == productRegistryName) {
                    releaseGateProduct.refresh(resetGateStatus);
                }
            });
        });
    }

    sendErrorMessage(error) {
        const errorMessageEvent = new CustomEvent("errormessage", { detail: error });
        this.dispatchEvent(errorMessageEvent);
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
