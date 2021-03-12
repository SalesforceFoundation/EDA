import { LightningElement, api, track, wire } from "lwc";

import getAccountModelSettingsViewModel from "@salesforce/apex/AccountModelSettingsController.getAccountModelSettingsViewModel";

import stgAccountModelSettingsTitle from "@salesforce/label/c.stgAccountModelSettingsTitle";
import stgAccModelTitle from "@salesforce/label/c.stgAccModelTitle";
import stgHelpAccountModel from "@salesforce/label/c.stgHelpAccountModel";
import stgAdminAccountRecordType from "@salesforce/label/c.stgAdminAccountRecordType";
import stgHelpAdminRecType from "@salesforce/label/c.stgHelpAdminRecType";
import stgAccountRecordTypeSupportsHHAddress from "@salesforce/label/c.stgAccountRecordTypeSupportsHHAddress";
import stgHelpHouseholdRecType from "@salesforce/label/c.stgHelpHouseholdRecType";
import AfflMappingsDescription from "@salesforce/label/c.AfflMappingsDescription";

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
        // add updated setting to hierarchySettingsChanges object
        let hierarchySettingsChange = {
            settingsType: "string",
            settingsName: "Account_Processor__c".toLowerCase(),
            settingsValue: event.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleHouseholdAccountModelChange(event) {
        // add updated setting to hierarchySettingsChanges object
        let hierarchySettingsChange = {
            settingsType: "string",
            settingsName: "Household_Addresses_RecType__c".toLowerCase(),
            settingsValue: event.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleAdministrativeAccountModelChange(event) {
        // add updated setting to hierarchySettingsChanges object
        let hierarchySettingsChange = {
            settingsType: "string",
            settingsName: "Administrative_Account_Record_Type__c".toLowerCase(),
            settingsValue: event.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
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
