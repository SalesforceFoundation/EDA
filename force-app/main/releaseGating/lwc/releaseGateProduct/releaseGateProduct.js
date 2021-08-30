import { LightningElement, track, wire, api } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getReleaseGateVModel from "@salesforce/apex/ReleaseGateController.getReleaseGateVModel";

export default class ReleaseGateProduct extends LightningElement {
    @api productRegistryName;

    @track releaseGateVModel;
    @track releaseGateVModelWireResult;

    @wire(getReleaseGateVModel, { productRegistryName: "$productRegistryName" })
    releaseGateVModelWire(result) {
        this.releaseGateVModelWireResult = result;
        if (result.data) {
            this.releaseGateVModel = result.data;
            this.dispatchEvent(new CustomEvent("releasegateloadsuccess"));
        } else if (result.error) {
            this.dispatchEvent(new CustomEvent("releasegateloaderror", { detail: result.error }));
        }
    }

    @api refresh() {
        this.refreshAllApex();
    }

    @api setReleaseGateStatus(productName, gateName, status) {
        Array.prototype.filter
            .call(
                this.template.querySelectorAll("c-release-gate-item"),
                (releaseGateItem) =>
                    releaseGateItem.product.name == productName && releaseGateItem.gate.name == gateName
            )
            .forEach((releaseGateItem) => {
                releaseGateItem.gateStatus = status;
            });
    }

    refreshAllApex() {
        Promise.all([refreshApex(this.releaseGateVModelWireResult)]).then(() => {});
    }
}
