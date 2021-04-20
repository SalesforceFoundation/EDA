import { LightningElement } from "lwc";

import stgErrorSettingsTitle from "@salesforce/label/c.stgErrorSettingsTitle";

export default class ErrorSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    labelReference = {
        errorSettingsTitle: stgErrorSettingsTitle,
    };

    get affordancesDisabled() {
        if (!this.isEditMode || this.affordancesDisabledToggle === true) {
            return true;
        }
        return undefined;
    }

    handleSettingsEditModeChange(event) {
        this.isEditMode = !event.detail;
        this.affordancesDisabledToggle = event.detail;
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
        this.refreshAllApex();
    }

    refreshAllApex() {
        // Promise.all([
        //     refreshApex(this.contactLanguageSettingsWireResult),
        //     refreshApex(this.preferredContactInfoSettingsWireResult),
        // ]).then(() => {
        //     this.showPreferredPhoneEnforcement = this.preferredContactInfoSettingsVModel.enhancedPhoneFunctionality;
        //     this.template.querySelectorAll("c-settings-row-dual-listbox").forEach((dualListBox) => {
        //         dualListBox.resetValue();
        //     });
        //     this.template.querySelectorAll("c-settings-row-input").forEach((input) => {
        //         input.resetValue();
        //     });
        // });
    }
}
