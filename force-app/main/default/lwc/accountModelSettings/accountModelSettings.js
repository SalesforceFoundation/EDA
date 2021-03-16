import { LightningElement, api, track, wire } from "lwc";

import getAccountModelSettingsViewModel from "@salesforce/apex/AccountModelSettingsController.getAccountModelSettingsViewModel";
import getAccountAutoDeletionSettingsViewModel from "@salesforce/apex/AccountModelSettingsController.getAccountAutoDeletionSettingsViewModel";

import stgAccountModelSettingsTitle from "@salesforce/label/c.stgAccountModelSettingsTitle";
import stgAccModelTitle from "@salesforce/label/c.stgAccModelTitle";
import stgHelpAccountModel from "@salesforce/label/c.stgHelpAccountModel";
import stgAdminAccountRecordType from "@salesforce/label/c.stgAdminAccountRecordType";
import stgHelpAdminRecType from "@salesforce/label/c.stgHelpAdminRecType";
import stgAccountRecordTypeSupportsHHAddress from "@salesforce/label/c.stgAccountRecordTypeSupportsHHAddress";
import stgHelpHouseholdRecType from "@salesforce/label/c.stgHelpHouseholdRecType";
import stgOptSelect from "@salesforce/label/c.stgOptSelect";
import stgAccoutTypesWithoutContactsDelete from "@salesforce/label/c.stgAccoutTypesWithoutContactsDelete";
import stgHelpAccoutsDeletedIfChildContactsDeleted from "@salesforce/label/c.stgHelpAccoutsDeletedIfChildContactsDeleted";
import stgAccountRecordTypeGroupLabelTitle from "@salesforce/label/c.stgAccountRecordTypeGroupLabelTitle";
import stgAccountRecordTypeAvailableListTitle from "@salesforce/label/c.stgAccountRecordTypeAvailableListTitle";
import stgAccountRecordTypeSelectedListTitle from "@salesforce/label/c.stgAccountRecordTypeSelectedListTitle";

export default class AccountModelSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    @track accountModelSettingsViewModel;
    @track accountAutoDeletionSettingsViewModel;

    labelReference = {
        accountModelSettingsTitle: stgAccountModelSettingsTitle,
        defaultAccountModelTitle: stgAccModelTitle,
        defaultAccountModelDescription: stgHelpAccountModel,
        adminAccountModelTitle: stgAdminAccountRecordType,
        adminAccountModelDescription: stgHelpAdminRecType,
        hhAccountModelTitle: stgAccountRecordTypeSupportsHHAddress,
        hhAccountModelDescription: stgHelpHouseholdRecType,
        comboboxPlaceholderText: stgOptSelect,
        accountAutoDeletionTitle: stgAccoutTypesWithoutContactsDelete,
        accountAutoDeletionDescription: stgHelpAccoutsDeletedIfChildContactsDeleted,
        accountAutoDeletionLisboxGroupHeading: stgAccountRecordTypeGroupLabelTitle,
        accountAutoDeletionSelectedValuesHeading: stgAccountRecordTypeSelectedListTitle,
        accountAutoDeletionAvailableValuesHeading: stgAccountRecordTypeAvailableListTitle,
    };

    inputAttributeReference = {
        defaultAccountModelComboboxId: "defaultAccountModel",
        adminAccountModelComboboxId: "adminAccountModel",
        hhAccountModelComboboxId: "hhAccountModel",
        accountAutoDeletionDualListboxId: "accountAutoDeletionModel",
    };

    get affordancesDisabled() {
        if (!this.isEditMode || this.affordancesDisabledToggle === true) {
            return true;
        }
        return undefined;
    }

    @wire(getAccountModelSettingsViewModel)
    accountModelSettingsViewModel({ error, data }) {
        if (data) {
            this.accountModelSettingsViewModel = data;
        } else if (error) {
            //console.log("error retrieving accountmodelsettingsvmodel");
        }
    }

    @wire(getAccountAutoDeletionSettingsViewModel)
    accountAutoDeletionSettingsViewModel({ error, data }) {
        if (data) {
            this.accountAutoDeletionSettingsViewModel = data;
            console.log("selected values: " + JSON.stringify(this.accountAutoDeletionSettingsViewModel.value));
        } else if (error) {
            //console.log("error retrieving accountAutoDeletionSettingsViewModel");
        }
    }

    handleDefaultAccountModelChange(event) {
        // add updated setting to hierarchySettingsChanges object
        let hierarchySettingsChange = {
            settingsType: "string",
            settingsName: "Account_Processor__c",
            settingsValue: event.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleHouseholdAccountModelChange(event) {
        // add updated setting to hierarchySettingsChanges object
        let hierarchySettingsChange = {
            settingsType: "string",
            settingsName: "Household_Addresses_RecType__c",
            settingsValue: event.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleAdministrativeAccountModelChange(event) {
        // add updated setting to hierarchySettingsChanges object
        let hierarchySettingsChange = {
            settingsType: "string",
            settingsName: "Administrative_Account_Record_Type__c",
            settingsValue: event.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleAccountAutoDeletionChange(event) {
        console.log("auto deletion change: " + event.detail.value);
        // add selected values to hierarchySettingsChanges object
        let hierarchySettingsChange = {
            settingsType: "array",
            settingsName: "Accounts_to_Delete__c",
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
