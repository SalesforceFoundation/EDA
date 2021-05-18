import { LightningElement, wire, track, api } from "lwc";
import { refreshApex } from "@salesforce/apex";

//Custom Labels
import stgCourseConnectionsTitle from "@salesforce/label/c.stgCourseConnectionsTitle";

export default class CourseConnectionSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    labelReference = {
        stgCourseConnectionsTitle: stgCourseConnectionsTitle,
    };

    inputAttributeReference = {};

    get affordancesDisabled() {
        if (!this.isEditMode || this.affordancesDisabledToggle === true) {
            return true;
        }
        return undefined;
    }

    @api
    handleSaveCanvasRender() {
        this.template.querySelector("c-settings-save-canvas").focusOnTitle();
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
        refreshApex(this.addressSettingsWireResult).then(() => {
            this.template.querySelectorAll("c-settings-row-dual-listbox").forEach((dualListBox) => {
                dualListBox.resetValue();
            });
            this.template.querySelectorAll("c-settings-row-input").forEach((input) => {
                input.resetValue();
            });
        });
    }
}
