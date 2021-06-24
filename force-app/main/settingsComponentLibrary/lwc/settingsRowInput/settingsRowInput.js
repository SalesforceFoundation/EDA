import { LightningElement, api } from "lwc";

export default class SettingsRowInput extends LightningElement {
    @api title;
    @api description;
    @api inputId;
    @api label; // optional
    @api helpText;
    @api value;
    @api placeholder;
    @api options;
    @api disabled;
    @api type;
    @api variant = "label-hidden";

    // overide label to use title

    handleInputChange(event) {
        let eventDetail = {};
        let typeLowercased = this.type.toLowerCase();

        switch (typeLowercased) {
            case "toggle":
                eventDetail = {
                    // event.detail.value is undefined for a toggle
                    value: event.detail.checked,
                };
                break;

            default:
                eventDetail = {
                    value: event.detail.value,
                };
        }

        const settingsInputChange = new CustomEvent("settingsinputchange", { detail: eventDetail });
        this.dispatchEvent(settingsInputChange);
    }

    @api
    resetValue() {
        let typeLowercased = this.type.toLowerCase();

        switch (typeLowercased) {
            case "toggle":
                this.template.querySelector("lightning-input").checked = this.value;
                break;
            case "text":
                this.template.querySelector("lightning-input").value = this.value;
                break;
            case "combobox":
                this.template.querySelector("lightning-combobox").value = this.value;
                break;
        }
    }

    get checked() {
        if (this.type === "toggle") {
            return this.value;
        }
        return undefined;
    }

    get isCombobox() {
        return this.type === "combobox";
    }

    get isInput() {
        return this.type !== "combobox";
    }

    get comboboxStyling() {
        return "slds-size_3-of-3 ";
    }

    get inputStyling() {
        switch (this.type) {
            case "text":
                return "slds-size_3-of-3 slds-p-bottom_large";

            default:
                return undefined;
        }
    }

    get inputLabel() {
        if (!this.label) {
            return this.title;
        }
        return this.label;
    }
}
