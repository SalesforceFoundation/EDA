import { LightningElement, api } from "lwc";

export default class SettingsRowDualListbox extends LightningElement {
    @api title;
    @api label;
    @api description;
    @api dualListboxId;
    @api sourceLabel;
    @api selectedLabel;
    @api options;
    @api value;
    @api disabled;

    handleDualListBoxChange(event) {
        const eventDetail = {
            value: event.detail.value,
        };
        const settingsDualListboxChange = new CustomEvent("settingsduallistboxchange", { detail: eventDetail });
        this.dispatchEvent(settingsDualListboxChange);
    }

    @api
    resetValue() {
        this.template.querySelector("lightning-dual-listbox").value = this.value;
    }
}
