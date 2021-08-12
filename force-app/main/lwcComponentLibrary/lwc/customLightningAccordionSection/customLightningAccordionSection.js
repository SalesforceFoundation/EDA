import { LightningElement, api } from "lwc";

const SECTION_CLOSED_CLASS = "slds-accordion__section";
const SECTION_OPEN_CLASS = "slds-accordion__section  slds-is-open";

export default class CustomLightningAccordionSection extends LightningElement {
    expanded;
    @api label;
    @api menuActions;
    @api menuAlternativeText;
    @api title;

    get sectionIsHidden() {
        if (!this.expanded) {
            return true;
        }

        return undefined;
    }

    get sectionClass() {
        if (!this.expanded) {
            return SECTION_CLOSED_CLASS;
        }

        return SECTION_OPEN_CLASS;
    }

    handleSectionHeaderClick() {
        this.expanded = !this.expanded;
    }

    handleMenuSelect(event) {
        this.dispatchMenuSelectEvent(event.detail.value);
    }

    dispatchMenuSelectEvent(selectedValue) {
        const menuSelectEvent = new CustomEvent("menuselect", {
            detail: { value: selectedValue },
        });
        this.dispatchEvent(menuSelectEvent);
    }
}
