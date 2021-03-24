import { LightningElement, wire, track } from "lwc";
import { refreshApex } from "@salesforce/apex";

import getAddressSettingsVModel from "@salesforce/apex/AddressSettingsController.getAddressSettingsVModel";

import stgAddressSettingsTitle from "@salesforce/label/c.stgAddressSettingsTitle";
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
        stgHelpSimpleAddrChangeIsUpdate: stgHelpSimpleAddrChangeIsUpdate
    }

    inputAttributeReference = {
        multiAddressEnabledToggleId: "multiAddressModel",
        accountRecTypesDualListboxId: "accountRectypeModel",
        simpleAddressChangeTreatedAsUpdateToggleId : "simpleUpdateModel"

    };

    get affordancesDisabled() {
        if (!this.isEditMode || this.affordancesDisabledToggle === true) {
            return true;
        }
        return undefined;
    }

    @wire(getAddressSettingsVModel)
    addressSettingsViewModel({ error, data }) {
        if (data) {
            this.addressSettingsViewModel = data;
            
        } else if (error) {
            //console.log("error retrieving accountmodelsettingsvmodel");
        }
    }

    handleMultiAddressEnabledChange(event) {

        let hierarchySettingsChange = {
            settingsType: "boolean",
            settingsName: "Contacts_Addresses_Enabled__c",
            settingsValue: event.detail.checked,
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
            settingsValue: event.detail.checked,
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

    refreshAllApex() {
        refreshApex(this.addressSettingsViewModel);
    }
}