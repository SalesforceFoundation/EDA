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
    @api gate;

    labelReference = {
        releaseGateActivateBy: stgReleaseGateActivateBy,
        releaseGateActivatedOn: stgReleaseGateActivatedOn,
        releaseGateActivate: stgReleaseGateActivate,
        releaseGateActivateButton: stgBtnReleaseGateActivate,
        releaseGateInProgress: stgReleaseGateInProgress,
        newWindowLinkAlt: stgNewWindowA11y,
    };

    get gateActive() {
        return this.gate.status === "active";
    }

    get gateInactive() {
        return this.gate.status === "inactive";
    }

    get gateDisabled() {
        return this.gate.status === "disabled";
    }

    get gateInProgress() {
        return this.gate.status === "inprogress";
    }

    get gateIconName() {
        let iconName;
        switch (this.gate.status) {
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
        let payload = {
            productRegistryName: this.productRegistryName,
            product: this.product,
            gate: this.gate,
        };

        const enableEvent = new CustomEvent("enablegate", {
            detail: payload,
        });

        this.dispatchEvent(enableEvent);
    }
}
