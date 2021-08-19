import { LightningElement, track, wire, api } from "lwc";
import stgReleaseGateActivateBy from "@salesforce/label/c.stgReleaseGateActivateBy";
import stgReleaseGateActivatedOn from "@salesforce/label/c.stgReleaseGateActivatedOn";
import stgReleaseGateActivate from "@salesforce/label/c.stgReleaseGateActivate";
import stgBtnReleaseGateActivate from "@salesforce/label/c.stgBtnReleaseGateActivate";
import stgReleaseGateInProgress from "@salesforce/label/c.stgReleaseGateInProgress";
import stgNewWindowA11y from "@salesforce/label/c.stgNewWindowA11y";

export default class ReleaseGateItem extends LightningElement {
    @api productRegistryName;
    @api product;
    @api get gate() {
        return this.gateInternal;
    }
    set gate(value) {
        this.gateInternal = value;
        this.gateStatusOverride = value ? value.status : undefined;
    }
    @api get gateStatus() {
        return this.gateStatusOverride ? this.gateStatusOverride : this.gate.status;
    }
    set gateStatus(value) {
        this.gateStatusOverride = value;
    }
    gateStatusOverride;
    gateInternal;

    labelReference = {
        releaseGateActivateBy: stgReleaseGateActivateBy,
        releaseGateActivatedOn: stgReleaseGateActivatedOn,
        releaseGateActivate: stgReleaseGateActivate,
        releaseGateActivateButton: stgBtnReleaseGateActivate,
        releaseGateInProgress: stgReleaseGateInProgress,
        newWindowLinkAlt: stgNewWindowA11y,
    };

    get gateActive() {
        return this.gateStatus === "active";
    }

    get gateInactive() {
        return this.gateStatus === "inactive";
    }

    get gateDisabled() {
        return this.gateStatus === "disabled";
    }

    get gateInProgress() {
        return this.gateStatus === "inprogress";
    }

    get gateIconName() {
        let iconName;
        switch (this.gateStatus) {
            case "active":
                iconName = "action:approval";
                break;
            case "inactive":
                iconName = "action:announcement";
                break;
            case "inprogress":
                iconName = "action:more";
                break;
            case "disabled":
            default:
                iconName = "action:info";
                break;
        }
        return iconName;
    }

    get activatedOnLabel() {
        return this.labelReference.releaseGateActivatedOn.replace(
            "{0}",
            new Date(this.gate.activationDate).toLocaleString()
        );
    }

    get inProgressLabel() {
        return this.labelReference.releaseGateInProgress.replace("{0}", this.gate.label);
    }

    get activateLabel() {
        return this.labelReference.releaseGateActivate.replace("{0}", this.gate.label);
    }

    get approvedAltText() {
        return this.activatedOnLabel;
    }

    get hasDueDate() {
        return this.gate.dueDate && this.gateInactive;
    }

    get hasActivationDate() {
        return this.gate.activationDate && this.gateActive;
    }

    handleEnableGate(event) {
        event.stopPropagation();
        let payload = {
            releaseGateAction: "activate",
            productRegistryName: this.productRegistryName,
            productName: this.product.name,
            productLabel: this.product.label,
            releaseGateName: this.gate.name,
            releaseGateLabel: this.gate.label,
        };

        const releaseGateModalConfirmEvent = new CustomEvent("releasegatemodalrequest", {
            detail: payload,
            bubbles: true,
            composed: true,
        });

        this.dispatchEvent(releaseGateModalConfirmEvent);
    }
}
