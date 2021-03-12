import { LightningElement, api, track, wire } from "lwc";

import getAccountModelSettingsViewModel from "@salesforce/apex/AccountModelSettingsController.getAccountModelSettingsViewModel";

import stgAccountModelSettingsTitle from "@salesforce/label/c.stgAccountModelSettingsTitle";
import stgAccModelTitle from "@salesforce/label/c.stgAccModelTitle";
import stgHelpAccountModel from "@salesforce/label/c.stgHelpAccountModel";
import stgAdminAccountRecordType from "@salesforce/label/c.stgAdminAccountRecordType";
import stgHelpAdminRecType from "@salesforce/label/c.stgHelpAdminRecType";
import stgAccountRecordTypeSupportsHHAddress from "@salesforce/label/c.stgAccountRecordTypeSupportsHHAddress";
import stgHelpHouseholdRecType from "@salesforce/label/c.stgHelpHouseholdRecType";

export default class AccountModelSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;
    @track accountModelSettingsViewModel;

    get affordancesDisabled() {
        if (!this.isEditMode || this.affordancesDisabledToggle === true) {
            return true;
        }
        return undefined;
    }

    labelReference = {
        stgAccountModelSettingsTitle,
        stgAccModelTitle,
        stgHelpAccountModel,
        stgAdminAccountRecordType,
        stgHelpAdminRecType,
        stgAccountRecordTypeSupportsHHAddress,
        stgHelpHouseholdRecType,
        placeHolderText: "Select an Option",
    };

    @wire(getAccountModelSettingsViewModel)
    accountModelSettingsViewModel({ error, data }) {
        if (data) {
            this.accountModelSettingsViewModel = data;
        } else if (error) {
            console.log("error retrieving accountmodelsettingsvmodel");
        }
    }

    handleDefaultAccountModelChange(event) {
        console.log("Default Account model changed");
    }

    handleHouseholdAccountModelChange(event) {
        console.log("HH Account model changed");
    }

    handleAdministrativeAccountModelChange(event) {
        console.log("Admin Account model changed");
    }

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
