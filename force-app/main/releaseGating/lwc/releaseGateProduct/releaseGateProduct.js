import { LightningElement, track, wire, api } from "lwc";
import getReleaseGateVModel from "@salesforce/apex/ReleaseGateController.getReleaseGateVModel";

export default class ReleaseGateProduct extends LightningElement {
    @api
    productRegistryName;

    @track releaseGateVModel;
    @track releaseGateVModelWireResult;

    @wire(getReleaseGateVModel, { productRegistryName: "$productRegistryName" })
    releaseGateVModelWire(result) {
        this.releaseGateVModelWireResult = result;
        if (result.data) {
            this.releaseGateVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving releaseGateVModel");
        }
    }
}
