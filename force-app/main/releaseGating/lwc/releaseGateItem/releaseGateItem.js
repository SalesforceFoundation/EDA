import { LightningElement, api } from "lwc";
import stgReleaseGateActivateBy from "@salesforce/label/c.stgReleaseGateActivateBy";
import stgReleaseGateActivatedOn from "@salesforce/label/c.stgReleaseGateActivatedOn";
import stgReleaseGateActivate from "@salesforce/label/c.stgReleaseGateActivate";
import stgBtnReleaseGateActivate from "@salesforce/label/c.stgBtnReleaseGateActivate";
import stgReleaseGateInProgress from "@salesforce/label/c.stgReleaseGateInProgress";
import stgNewWindowA11y from "@salesforce/label/c.stgNewWindowA11y";

const ReleaseGateStatus = {
    ACTIVE: "active",
    INACTIVE: "inactive",
    DISABLED: "disabled",
    INPROGRESS: "inprogress",
};

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
        return this.gateStatus === ReleaseGateStatus.ACTIVE;
    }

    get gateInactive() {
        return this.gateStatus === ReleaseGateStatus.INACTIVE;
    }

    get gateDisabled() {
        return this.gateStatus === ReleaseGateStatus.DISABLED;
    }

    get gateInProgress() {
        return this.gateStatus === ReleaseGateStatus.INPROGRESS;
    }

    get gateIconName() {
        let iconName;
        switch (this.gateStatus) {
            case ReleaseGateStatus.ACTIVE:
                iconName = "action:approval";
                break;
            case ReleaseGateStatus.INACTIVE:
                iconName = "action:announcement";
                break;
            case ReleaseGateStatus.INPROGRESS:
                iconName = "action:more";
                break;
            case ReleaseGateStatus.DISABLED:
            default:
                iconName = "action:info";
                break;
        }
        return iconName;
    }

    get progressItemClass() {
        return this.gateActive ? "slds-progress__item slds-is-completed" : "slds-progress__item";
    }

    get progressMarkerClass() {
        return this.gateActive
            ? "slds-icon_container slds-icon-utility-success slds-progress__marker slds-progress__marker_icon slds-progress__marker_icon-success"
            : "slds-progress__marker";
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
