import { LightningElement, api } from "lwc";

export default class SettingsRowInput extends LightningElement {
    @api title;
    @api description;
    @api inputId;
    @api value;
    @api placeholder;
    @api options;
    @api disabled;

    handleComboboxChange(event) {
        const eventDetail = {
            value: event.detail.value,
        };
        const settingsComboboxChange = new CustomEvent("settingscomboboxchange", { detail: eventDetail });
        this.dispatchEvent(settingsComboboxChange);
    }
}
