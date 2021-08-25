import { LightningElement, api } from "lwc";
import stgReleaseGateActivateModalBody from "@salesforce/label/c.stgReleaseGateActivateModalBody";

export default class ReleaseGateModalBody extends LightningElement {
    @api releaseGateAction;
    @api productRegistryName;
    @api productName;
    @api productLabel;
    @api releaseGateName;
    @api releaseGateLabel;

    labelReference = {
        releaseGateActivateModalBody: stgReleaseGateActivateModalBody,
    };

    get activateReleaseGate() {
        return this.releaseGateAction === "activate";
    }

    get releaseGateModalBodyDesc() {
        return this.labelReference.releaseGateActivateModalBody.replace(
            "{0}",
            this.productLabel + " " + this.releaseGateLabel
        );
    }
}
