import { LightningElement, wire, api, track } from "lwc";
import { refreshApex } from "@salesforce/apex";

import getApplicationSettingsVModel from "@salesforce/apex/ApplicationSettingsController.getApplicationSettingsVModel";

// Label imports
import stgApplicationSettingsTitle from "@salesforce/label/c.stgApplicationSettingsTitle";
import stgApplicationWindowValidation from "@salesforce/label/c.stgApplicationWindowValidation";
import stgApplicationWindowValidationDescription from "@salesforce/label/c.stgApplicationWindowValidationDescription";

export default class ApplicationSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    @track applicationSettingsVModel;
    @track _wiredApplicationSettings;

    labelReference = {
        applicationPageTitle: stgApplicationSettingsTitle,
        applicationWindowValidationTitle: stgApplicationWindowValidation,
        applicationWindowValidationDescription: stgApplicationWindowValidationDescription,
    };

    inputAttributeReference = {
        enableApplicationWindowValidationId: "enableApplicationWindowValidation",
    };

    @wire(getApplicationSettingsVModel)
    wiredApplicationSettings(response) {
        this._wiredApplicationSettings = response;
        if (response.data) {
            this.applicationSettingsVModel = response.data;
        }
        if (response.error) {
            //console.error(response.error);
        }
    }

    @api
    handleSaveCanvasRender() {
        this.template.querySelector("c-settings-save-canvas").focusOnTitle();
    }

    get affordancesDisabled() {
        if (!this.isEditMode || this.affordancesDisabledToggle === true) {
            return true;
        }
        return undefined;
    }

    handleWindowValidationTriggerChanged(evt) {
        // add updated setting to hierarchySettingsChanges object
        let hierarchySettingsChange = {
            settingsType: "boolean",
            settingsName: "Application_Window_Validation__c",
            settingsValue: evt.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleSettingsEditModeChange(event) {
        this.isEditMode = !event.detail;
        this.affordancesDisabledToggle = event.detail;
    }

    handleSettingsSaving(event) {
        this.affordancesDisabledToggle = true;
        this.template.querySelector("c-settings-save-canvas").updateHierarchySettings();
    }

    handleSettingsSaveCancel(event) {
        this.refreshAllApex();
    }

    handleSettingsSaveCompleted(event) {
        this.affordancesDisabledToggle = false;
        this.refreshAllApex();
    }

    refreshAllApex() {
        Promise.all([refreshApex(this._wiredApplicationSettings)]).then(() => {
            this.template.querySelectorAll("c-settings-row-input").forEach((input) => {
                input.resetValue();
            });
        });
    }
}
