import { LightningElement, wire, track } from "lwc";
import { refreshApex } from "@salesforce/apex";

import getAffiliationsSettingsVModel from "@salesforce/apex/AffiliationsSettingsController.getAffiliationsSettingsVModel";

import stgAffiliationsSettingsTitle from "@salesforce/label/c.stgAffiliationsSettingsTitle";
import afflTypeEnforced from "@salesforce/label/c.afflTypeEnforced";
import afflTypeEnforcedDescription from "@salesforce/label/c.afflTypeEnforcedDescription";

export default class affiliationSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    @track affiliationsSettingsViewModel;
    @track affiliationsSettingsWireResult;

    labelReference = {
        stgAffiliationsSettingsTitle: stgAffiliationsSettingsTitle,
        afflTypeEnforced: afflTypeEnforced,
        afflTypeEnforcedDescription: afflTypeEnforcedDescription,
    };

    inputAttributeReference = {
        recordTypeValidation: "recordTypeValidation",
    };

    get affordancesDisabled() {
        if (!this.isEditMode || this.affordancesDisabledToggle === true) {
            return true;
        }
        return undefined;
    }

    @wire(getAffiliationsSettingsVModel)
    affiliationsSettingsViewModelWire(result) {
        this.affiliationsSettingsWireResult = result;
        if (result.data) {
            this.affiliationsSettingsViewModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving accountmodelsettingsvmodel");
        }
    }

    handleRecordtypeValidationChange(event) {
        let hierarchySettingsChange = {
            settingsType: "boolean",
            settingsName: "Affiliation_Record_Type_Enforced__c",
            settingsValue: event.detail.value,
        };
        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
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
        refreshApex(this.affiliationsSettingsWireResult).then(() => {
            this.template.querySelectorAll("c-settings-row-input").forEach((input) => {
                input.resetValue();
            });
        });
    }
}
