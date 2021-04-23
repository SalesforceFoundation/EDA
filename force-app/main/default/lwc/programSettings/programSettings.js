import { LightningElement, api } from "lwc";
import { refreshApex } from "@salesforce/apex";

import stgProgramsSettingsTitle from "@salesforce/label/c.stgProgramsSettingsTitle";

export default class programSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    labelReference = {
        programsSettingsTitle: stgProgramsSettingsTitle,
    };

    inputAttributeReference = {};

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

    handleSettingsSaveCancel(event) {
        this.refreshAllApex();
    }

    refreshAllApex() {
        /*Promise.all([
            refreshApex(this.affiliationsSettingsWireResult),
            refreshApex(this.primaryAffiliationsSettingsWireResult),
        ]).then(() => {
            this.template.querySelectorAll("c-settings-row-input").forEach((input) => {
                input.resetValue();
            });
        });*/
    }

    @api
    handleSaveCanvasRender() {
        this.template.querySelector("c-settings-save-canvas").focusOnTitle();
    }
}
