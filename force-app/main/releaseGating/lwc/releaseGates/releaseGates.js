import { LightningElement, track, wire } from "lwc";
import getProductRegistryReleaseGateVModels from "@salesforce/apex/ReleaseGateController.getProductRegistryReleaseGateVModels";

export default class ReleaseGates extends LightningElement {
    @track productRegistryReleaseGateVModels;
    @track productRegistryReleaseGateWireResult;

    @wire(getProductRegistryReleaseGateVModels)
    productRegistryReleaseGateWire(result) {
        this.productRegistryReleaseGateWireResult = result;
        if (result.data) {
            this.productRegistryReleaseGateVModels = result.data;
        } else if (result.error) {
            //console.log("error retrieving productRegistryReleaseGateVModels");
        }
    }
}
