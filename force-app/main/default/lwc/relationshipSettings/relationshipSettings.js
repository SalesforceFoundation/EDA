import { LightningElement, wire, track, api } from "lwc";
import { refreshApex } from "@salesforce/apex";

import stgRelationshipSettingsTitle from "@salesforce/label/c.stgRelationshipSettingsTitle";

export default class relationshipSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    labelReference = {
        stgRelationshipSettingsTitle: stgRelationshipSettingsTitle,
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
        this.template.querySelector("c-settings-save-canvas").updateHierarchySettings();
    }

    handleSettingsSaveCompleted(event) {
        this.affordancesDisabledToggle = false;
        this.refreshAllApex();
    }

    handleSettingsSaveCancel(event) {
        this.refreshAllApex();
    }

    refreshAllApex() {}

    @api
    handleSaveCanvasRender() {
        this.template.querySelector("c-settings-save-canvas").focusOnTitle();
    }
}
