import { LightningElement, api } from "lwc";
const LOOKUP_OPTION_CLASS = "slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta";
export default class SingleLookupOption extends LightningElement {
    @api viewModel = {};

    get lookupOptionClass() {
        if (!this.viewModel.active) {
            return LOOKUP_OPTION_CLASS;
        }

        return LOOKUP_OPTION_CLASS + " slds-has-focus";
    }

    handleMouseOver(event) {
        this.dispatchOptionViewEvent();
    }

    handleClick(event) {
        this.dispatchOptionConfirmEvent();
    }

    dispatchOptionSelectionEvent() {
        const optionSelectionEvent = new CustomEvent("optionview", {
            detail: this.viewModel.index,
        });
        this.dispatchEvent(optionSelectionEvent);
    }

    dispatchOptionConfirmEvent() {
        const optionConfirmEvent = new CustomEvent("optionconfirm", {
            detail: this.viewModel.index,
        });
        this.dispatchEvent(optionConfirmEvent);
    }
}
