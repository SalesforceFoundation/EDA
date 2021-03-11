import { LightningElement, api, track } from "lwc";
import stgAccountModelSettingsTitle from "@salesforce/label/c.stgAccountModelSettingsTitle";

export default class AccountModelSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    get affordancesDisabled() {
        if (!this.isEditMode || this.affordancesDisabledToggle === true) {
            return true;
        }
        return undefined;
    }

    labelReference = {
        stgAccountModelSettingsTitle,
    };

    handleSettingsEditModeChange(event) {
        this.isEditMode = !event.detail;
        this.affordancesDisabledToggle = event.detail;

        this.refreshAllApex();
    }

    handleSettingsSaving(event) {
        this.affordancesDisabledToggle = true;
        // TODO: perform client side validation

        // if validation fails, call this.handleValidationFailure()
        //this.template.querySelector("c-settings-save-canvas").handleValidationFailure();

        // else, update hierarchy settings
        this.template.querySelector("c-settings-save-canvas").updateHierarchySettings();
    }

    handleSettingsSaveCompleted(event) {
        this.affordancesDisabledToggle = false;
    }

    refreshAllApex() {}
}
