import { LightningElement, api, track, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";

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

// import Account Naming Settings labels
import stgAdminAccountNamingTitle from "@salesforce/label/c.stgAdminAccountNamingTitle";
import adminAccNameFormat from "@salesforce/label/c.adminAccNameFormat";
import adminAccNameFormatHelpText from "@salesforce/label/c.adminAccNameFormatHelpText";

import stgAdminAccountCustomName from "@salesforce/label/c.stgAdminAccountCustomName";
import stgCustomAdminAccountNamingHelp from "@salesforce/label/c.stgCustomAdminAccountNamingHelp";
import stgHHAccountNamingTitle from "@salesforce/label/c.stgHHAccountNamingTitle";
import hhAccNameFormat from "@salesforce/label/c.hhAccNameFormat";
import hhAccNameFormatHelpText from "@salesforce/label/c.hhAccNameFormatHelpText";

import stgHHAccountCustomName from "@salesforce/label/c.stgHHAccountCustomName";
import stgHHAccountCustomNameHelp from "@salesforce/label/c.stgHHAccountCustomNameHelp";
import automaticHHNaming from "@salesforce/label/c.automaticHHNaming";
import automaticHHNamingHelpText from "@salesforce/label/c.automaticHHNamingHelpText";

export default class AccountModelSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    @track accountModelSettingsWireResult;
    @track accountModelSettingsVModel;

    @track accountAutoDeletionSettingsWireResult;
    @track accountAutoDeletionSettingsVModel;

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

        adminAccountNamingTitle: stgAdminAccountNamingTitle,
        adminAccountNameFormatHeading: adminAccNameFormat,
        adminAccountNameFormatDescription: adminAccNameFormatHelpText,
        adminAccountCustomNameFormatHeading: stgAdminAccountCustomName,
        adminAccountCustomNameFormatDescription: stgCustomAdminAccountNamingHelp,

        hhAccountNamingTitle: stgHHAccountNamingTitle,
        hhAccountNameFormatHeading: hhAccNameFormat,
        hhAccountNameFormatDescription: hhAccNameFormatHelpText,
        hhAccountCustomNameFormatHeading: stgHHAccountCustomName,
        hhAccountCustomNameFormatDescription: stgHHAccountCustomNameHelp,
        hhAutomaticAccountNamingTitle: automaticHHNaming,
        hhAutomaticAccountNamingDescription: automaticHHNamingHelpText,
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
    accountModelSettingsViewModelWire(result) {
        this.accountModelSettingsWireResult = result;

        if (result.data) {
            this.accountModelSettingsVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving accountmodelsettingsvmodel");
        }
    }

    @wire(getAccountAutoDeletionSettingsViewModel)
    accountAutoDeletionSettingsViewModelWire(result) {
        this.accountAutoDeletionSettingsWireResult = result;

        if (result.data) {
            this.accountAutoDeletionSettingsVModel = result.data;
        } else if (result.error) {
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
    }

    handleSettingsSaveCancel(event) {
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
        this.refreshAllApex();
    }

    refreshAllApex() {
        Promise.all([
            refreshApex(this.accountModelSettingsWireResult),
            refreshApex(this.accountAutoDeletionSettingsWireResult),
        ]).then(() => {
            this.template.querySelectorAll("c-settings-row-dual-listbox").forEach((dualListBox) => {
                dualListBox.resetValue();
            });
            this.template.querySelectorAll("c-settings-row-input").forEach((input) => {
                input.resetValue();
            });
        });
    }
}
