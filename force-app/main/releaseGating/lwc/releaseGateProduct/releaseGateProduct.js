import { LightningElement, track, wire, api } from "lwc";
import getProductRegistryReleaseGateVModels from "@salesforce/apex/ReleaseGateController.getProductRegistryReleaseGateVModels";

export default class ReleaseGateProduct extends LightningElement {
    @api
    productRegistryName;
}
