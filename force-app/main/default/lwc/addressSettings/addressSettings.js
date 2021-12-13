import { LightningElement, wire, track, api } from "lwc";
import { refreshApex } from "@salesforce/apex";

import getAddressSettingsVModel from "@salesforce/apex/AddressSettingsController.getAddressSettingsVModel";

import stgAddressSettingsTitle from "@salesforce/label/c.stgAddressSettingsNav";
import stgContactMultiAddressesEnabled from "@salesforce/label/c.stgContactMultiAddressesEnabled";
import stgHelpContactAddrs from "@salesforce/label/c.stgHelpContactAddrs";
import stgAccountTypesMultiAddressesEnabled from "@salesforce/label/c.stgAccountTypesMultiAddressesEnabled";
import stgHelpAddressAccRecType from "@salesforce/label/c.stgHelpAddressAccRecType";
import stgAccountRecordTypeGroupLabelTitle from "@salesforce/label/c.stgAccountRecordTypeGroupLabelTitle";
import stgAccountRecordTypeAvailableListTitle from "@salesforce/label/c.stgAccountRecordTypeAvailableListTitle";
import stgAccountRecordTypeSelectedListTitle from "@salesforce/label/c.stgAccountRecordTypeSelectedListTitle";
import stgSimpleAddressChangeUpdate from "@salesforce/label/c.stgSimpleAddressChangeUpdate";
import stgHelpSimpleAddrChangeIsUpdate from "@salesforce/label/c.stgHelpSimpleAddrChangeIsUpdate";

export default class addressSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    @track addressSettingsViewModel;
    @track addressSettingsWireResult;

    labelReference = {
        stgAddressSettingsTitle: stgAddressSettingsTitle,
        stgContactMultiAddressesEnabled: stgContactMultiAddressesEnabled,
        stgHelpContactAddrs: stgHelpContactAddrs,
        stgAccountTypesMultiAddressesEnabled: stgAccountTypesMultiAddressesEnabled,
        stgHelpAddressAccRecType: stgHelpAddressAccRecType,
        stgAccountRecordTypeGroupLabelTitle: stgAccountRecordTypeGroupLabelTitle,
        stgAccountRecordTypeAvailableListTitle: stgAccountRecordTypeAvailableListTitle,
        stgAccountRecordTypeSelectedListTitle: stgAccountRecordTypeSelectedListTitle,
        stgSimpleAddressChangeUpdate: stgSimpleAddressChangeUpdate,
        stgHelpSimpleAddrChangeIsUpdate: stgHelpSimpleAddrChangeIsUpdate,
    };

    inputAttributeReference = {
        multiAddressEnabledToggleId: "multiAddressModel",
        accountRecTypesDualListboxId: "accountRectypeModel",
        simpleAddressChangeTreatedAsUpdateToggleId: "simpleUpdateModel",
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

    @wire(getAddressSettingsVModel)
    addressSettingsViewModelWire(result) {
        this.addressSettingsWireResult = result;
        if (result.data) {
            this.addressSettingsViewModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving accountmodelsettingsvmodel");
        }
    }

    handleMultiAddressEnabledChange(event) {
        let hierarchySettingsChange = {
            settingsType: "boolean",
            settingsName: "Contacts_Addresses_Enabled__c",
            settingsValue: event.detail.value,
        };
        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleAccountRecordTypesChange(event) {
        // add selected values to hierarchySettingsChanges object
        let hierarchySettingsChange = {
            settingsType: "array",
            settingsName: "Accounts_Addresses_Enabled__c",
            settingsValue: event.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleSimpleAddressUpdateChange(event) {
        let hierarchySettingsChange = {
            settingsType: "boolean",
            settingsName: "Simple_Address_Change_Treated_as_Update__c",
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
