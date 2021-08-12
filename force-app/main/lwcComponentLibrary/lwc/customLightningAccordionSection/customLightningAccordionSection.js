import { LightningElement, api } from "lwc";

const SECTION_CLOSED_CLASS = "slds-accordion__section";
const SECTION_OPEN_CLASS = "slds-accordion__section  slds-is-open";

export default class CustomLightningAccordionSection extends LightningElement {
    expanded;
    @api label;
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

    get sectionIcon() {
        if (!this.expanded) {
            return this.iconReference.collapsedIcon;
        }

        return this.iconReference.expandedIcon;
    }

    handleSectionHeaderClick() {
        this.expanded = !this.expanded;
    }
}
