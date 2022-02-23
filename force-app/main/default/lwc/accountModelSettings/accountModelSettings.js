import { LightningElement, api, track, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";

import getAccountModelSettingsViewModel from "@salesforce/apex/AccountModelSettingsController.getAccountModelSettingsViewModel";
import getAccountAutoDeletionSettingsViewModel from "@salesforce/apex/AccountModelSettingsController.getAccountAutoDeletionSettingsViewModel";
import getLeadConversionAccountNamingSettingsViewModel from "@salesforce/apex/AccountModelSettingsController.getLeadConversionAccountNamingViewModel";
import getAccountNamingSettingsViewModel from "@salesforce/apex/AccountNamingSettingsController.getAccountNamingSettingsViewModel";

import stgAccountModelSettingsTitle from "@salesforce/label/c.stgAccountModelNav";
import stgAccModelTitle from "@salesforce/label/c.stgAccModelTitle";
import stgHelpAccountModel from "@salesforce/label/c.stgHelpAccountModel";
import stgAdminAccountRecordType from "@salesforce/label/c.stgAdminAccountRecordType";
import stgHelpAdminRecType from "@salesforce/label/c.stgHelpAdminRecType";
import stgAccountRecordTypeSupportsHHAddress from "@salesforce/label/c.stgAccountRecordTypeSupportsHHAddress";
import stgHelpHouseholdRecType from "@salesforce/label/c.stgHelpHouseholdRecType";
import stgOptSelect from "@salesforce/label/c.stgOptSelect";
import stgAccoutTypesWithoutContactsDelete from "@salesforce/label/c.stgAccoutTypesWithoutContactsDelete";
import stgLeadConversionAccountNaming from "@salesforce/label/c.stgLeadConversionAccountNaming";
import stgLeadConversionAccountNamingDesc from "@salesforce/label/c.stgLeadConversionAccountNamingDesc";
import stgLeadConversionAccountNamingTitle from "@salesforce/label/c.stgLeadConversionAccountNamingTitle";
import stgHelpAccoutsDeletedIfChildContactsDeleted from "@salesforce/label/c.stgHelpAccoutsDeletedIfChildContactsDeleted";
import stgAccountRecordTypeGroupLabelTitle from "@salesforce/label/c.stgAccountRecordTypeGroupLabelTitle";
import stgAccountRecordTypeAvailableListTitle from "@salesforce/label/c.stgAccountRecordTypeAvailableListTitle";
import stgAccountRecordTypeSelectedListTitle from "@salesforce/label/c.stgAccountRecordTypeSelectedListTitle";
import stgAdminAccountNamingTitle from "@salesforce/label/c.stgAdminAccountNamingTitle";
import adminAccNameFormat from "@salesforce/label/c.adminAccNameFormat";
import adminAccNameFormatHelpText from "@salesforce/label/c.adminAccNameFormatHelpText";
import stgAdminAccountCustomName from "@salesforce/label/c.stgAdminAccountCustomName";
import stgAdminAccountCustomNameHelp from "@salesforce/label/c.stgAdminAccountCustomNameHelp";
import stgHHAccountNamingTitle from "@salesforce/label/c.stgHHAccountNamingTitle";
import hhAccNameFormat from "@salesforce/label/c.hhAccNameFormat";
import hhAccNameFormatHelpText from "@salesforce/label/c.hhAccNameFormatHelpText";
import stgHHAccountCustomName from "@salesforce/label/c.stgHHAccountCustomName";
import stgHHAccountCustomNameHelp from "@salesforce/label/c.stgHHAccountCustomNameHelp";
import automaticHHNaming from "@salesforce/label/c.automaticHHNaming";
import automaticHHNamingHelpText from "@salesforce/label/c.automaticHHNamingHelpText";
import acctNamingOther from "@salesforce/label/c.acctNamingOther";
import stgTellMeMoreLink from "@salesforce/label/c.stgTellMeMoreLink";

const DELAY_INTERVAL = 500; // 0.5 second delay

export default class AccountModelSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;
    inputVariant = "standard";

    @track accountModelSettingsWireResult;
    @track accountModelSettingsVModel;

    @track accountAutoDeletionSettingsWireResult;
    @track accountAutoDeletionSettingsVModel;

    @track leadConversionAccountNamingSettingsWireResult;
    @track leadConversionAccountNamingSettingsVModel;

    @track accountNamingSettingsWireResult;
    @track accountNamingSettingsVModel;
    @track showCustomAdministrativeAccountNaming;
    @track showCustomHouseholdAccountNaming;

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
        leadConversionAccountNaming: stgLeadConversionAccountNaming,
        leadConversionAccountNamingDescription: stgLeadConversionAccountNamingDesc,
        leadConversionAccountNamingTitle: stgLeadConversionAccountNamingTitle,
        adminAccountNamingTitle: stgAdminAccountNamingTitle,
        adminAccountNameFormatHeading: adminAccNameFormat,
        adminAccountNameFormatDescription: adminAccNameFormatHelpText,
        adminAccountCustomNameFormatHeading: stgAdminAccountCustomName,
        adminAccountCustomNameFormatDescription: stgAdminAccountCustomNameHelp,
        hhAccountNamingTitle: stgHHAccountNamingTitle,
        hhAccountNameFormatHeading: hhAccNameFormat,
        hhAccountNameFormatDescription: hhAccNameFormatHelpText,
        hhAccountCustomNameFormatHeading: stgHHAccountCustomName,
        hhAccountCustomNameFormatDescription: stgHHAccountCustomNameHelp,
        hhAutomaticAccountNamingTitle: automaticHHNaming,
        hhAutomaticAccountNamingDescription: automaticHHNamingHelpText,
        accountNamingComboboxCustomOption: acctNamingOther,
        tellMeMoreLink: stgTellMeMoreLink,
    };

    accNamingHyperLink =
        '<a href="https://powerofus.force.com/EDA-Customize-Admin-and-HH-Acct-Names">' +
        this.labelReference.tellMeMoreLink +
        "</a>";

    inputAttributeReference = {
        defaultAccountModelComboboxId: "defaultAccountModel",
        adminAccountModelComboboxId: "adminAccountModel",
        hhAccountModelComboboxId: "hhAccountModel",
        accountAutoDeletionDualListboxId: "accountAutoDeletionModel",
        leadAccountNamingDualListboxId: "leadConversionAccountNaming",
        adminAccountNamingFormatComboboxId: "adminAccountNaming",
        adminAccountCustomNamingFormatTextBoxId: "adminAccountCustomNaming",
        hhAccountNamingFormatComboboxId: "hhAccountNaming",
        hhAccountCustomNamingFormatTextBoxId: "hhAccountCustomNaming",
        autoHHAccountNamingToggleId: "autoHHAccountNaming",
    };

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

    @wire(getAccountModelSettingsViewModel)
    accountModelSettingsViewModelWire(result) {
        this.accountModelSettingsWireResult = result;

        if (result.data) {
            this.accountModelSettingsVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving accountModelSettingsVModel");
        }
    }

    @wire(getAccountAutoDeletionSettingsViewModel)
    accountAutoDeletionSettingsViewModelWire(result) {
        this.accountAutoDeletionSettingsWireResult = result;

        if (result.data) {
            this.accountAutoDeletionSettingsVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving accountAutoDeletionSettingsVModel");
        }
    }

    @wire(getLeadConversionAccountNamingSettingsViewModel)
    leadConversionAccountNamingSettingsViewModelWire(result) {
        this.leadConversionAccountNamingSettingsWireResult = result;

        if (result.data) {
            this.leadConversionAccountNamingSettingsVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving accountAutoDeletionSettingsViewModel");
        }
    }

    @wire(getAccountNamingSettingsViewModel)
    accountNamingSettingsViewModelWire(result) {
        this.accountNamingSettingsWireResult = result;

        if (result.data) {
            this.accountNamingSettingsVModel = result.data;

            // hide/show custom Admin Account naming input field
            this.showCustomAdministrativeAccountNaming =
                this.accountNamingSettingsVModel.administrativeAccountNameFormat.value ===
                this.labelReference.accountNamingComboboxCustomOption;

            // hide/show custom HH Account naming input field
            this.showCustomHouseholdAccountNaming =
                this.accountNamingSettingsVModel.householdAccountNameFormat.value ===
                this.labelReference.accountNamingComboboxCustomOption;
        } else if (result.error) {
            //console.log("error retrieving accountNamingSettingsVModel");
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

    handleAdministrativeAccountNamingChange(event) {
        // hide/show custom Admin Account naming input field
        this.showCustomAdministrativeAccountNaming =
            event.detail.value === this.labelReference.accountNamingComboboxCustomOption;

        // add updated setting to hierarchySettingsChanges object
        let hierarchySettingsChange = {
            settingsType: "string",
            settingsName: "Admin_Account_Naming_Format__c",
            settingsValue: event.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleLeadNamingAccountChange(event) {
        // add selected values to hierarchySettingsChanges object
        let hierarchySettingsChange = {
            settingsType: "array",
            settingsName: "Lead_Converted_Account_RTypes__c",
            settingsValue: event.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleAdministrativeAccountCustomNamingChange(event) {
        let adminAccountCustomNamingFormat = event.detail.value;

        if (event.detail.value === '""') {
            // set Hierarchy Settings field to a blank value (not "")
            adminAccountCustomNamingFormat = "";
        }

        // Wait a period of time determined by DELAY_INTERVAL before calling handleHierarchySettingsChange
        // prevents multiple calls while user is typing
        window.clearTimeout(this.delayTimeout);

        this.delayTimeout = setTimeout(() => {
            // add updated setting to hierarchySettingsChanges object
            let hierarchySettingsChange = {
                settingsType: "string",
                settingsName: "Admin_Other_Name_Setting__c",
                settingsValue: adminAccountCustomNamingFormat,
            };

            this.template
                .querySelector("c-settings-save-canvas")
                .handleHierarchySettingsChange(hierarchySettingsChange);
        }, DELAY_INTERVAL);
    }

    handleHouseholdAccountNamingChange(event) {
        // hide/show custom HH Account naming input field
        this.showCustomHouseholdAccountNaming =
            event.detail.value === this.labelReference.accountNamingComboboxCustomOption;

        // add updated setting to hierarchySettingsChanges object
        let hierarchySettingsChange = {
            settingsType: "string",
            settingsName: "Household_Account_Naming_Format__c",
            settingsValue: event.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleHouseholdAccountCustomNamingChange(event) {
        let hhAccountCustomNamingFormat = event.detail.value;

        if (event.detail.value === '""') {
            // set Hierarchy Settings field to a blank value (not "")
            hhAccountCustomNamingFormat = "";
        }

        // Wait a period of time determined by DELAY_INTERVAL before calling handleHierarchySettingsChange
        // prevents multiple calls while user is typing
        window.clearTimeout(this.delayTimeout);

        this.delayTimeout = setTimeout(() => {
            // add updated setting to hierarchySettingsChanges object
            let hierarchySettingsChange = {
                settingsType: "string",
                settingsName: "Household_Other_Name_Setting__c",
                settingsValue: hhAccountCustomNamingFormat,
            };

            this.template
                .querySelector("c-settings-save-canvas")
                .handleHierarchySettingsChange(hierarchySettingsChange);
        }, DELAY_INTERVAL);
    }

    handleHouseholdAccountAutoNamingChange(event) {
        const eventDetail = event.detail;

        let hierarchySettingsChange = {
            settingsType: "boolean",
            settingsName: "Automatic_Household_Naming__c",
            settingsValue: eventDetail.value,
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
            refreshApex(this.leadConversionAccountNamingSettingsWireResult),
            refreshApex(this.accountNamingSettingsWireResult),
        ]).then(() => {
            // hide/show custom Admin Account naming input field
            this.showCustomAdministrativeAccountNaming =
                this.accountNamingSettingsVModel.administrativeAccountNameFormat.value ===
                this.labelReference.accountNamingComboboxCustomOption;

            // hide/show custom HH Account naming input field
            this.showCustomHouseholdAccountNaming =
                this.accountNamingSettingsVModel.householdAccountNameFormat.value ===
                this.labelReference.accountNamingComboboxCustomOption;

            this.template.querySelectorAll("c-settings-row-dual-listbox").forEach((dualListBox) => {
                dualListBox.resetValue();
            });
            this.template.querySelectorAll("c-settings-row-input").forEach((input) => {
                input.resetValue();
            });
        });
    }

    get adminAccDesc() {
        return this.labelReference.adminAccountNameFormatDescription + " " + this.accNamingHyperLink;
    }

    get hhAccDesc() {
        return this.labelReference.hhAccountNameFormatDescription + " " + this.accNamingHyperLink;
    }
}
