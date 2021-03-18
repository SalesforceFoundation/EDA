import { LightningElement, wire, track } from "lwc";
import { refreshApex } from "@salesforce/apex";

import getContactLanguageSettingsVModel from "@salesforce/apex/ContactInfoSettingsController.getContactLanguageSettingsVModel";

import stgContactInformationSettingsTitle from "@salesforce/label/c.stgContactInformationSettingsTitle";
import stgDefaultContactLanguageFluency from "@salesforce/label/c.stgDefaultContactLanguageFluency";
import stgHelpDefaultContactLanguageFluency from "@salesforce/label/c.stgHelpDefaultContactLanguageFluency";

export default class ContactInformationSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    @track contactLanguageSettingsVModel;

    labelReference = {
        contactInformationSettingsTitle: stgContactInformationSettingsTitle,
        contactLanguageDefaultFluencyTitle: stgDefaultContactLanguageFluency,
        contactLanguageDefaultFluencyDescription: stgHelpDefaultContactLanguageFluency,
    };

    inputAttributeReference = {
        defaultContactLanugageFluencyComboboxId: "defaultContactLanguageFluency",
    };

    get affordancesDisabled() {
        if (!this.isEditMode || this.affordancesDisabledToggle === true) {
            return true;
        }
        return undefined;
    }

    @wire(getContactLanguageSettingsVModel)
    contactLanguageSettingsVModel({ error, data }) {
        if (data) {
            this.contactLanguageSettingsVModel = data;
        } else if (error) {
            console.log("error retrieving contactLanguageSettingsVModel");
        }
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

    handleDefaultContactLanguageFluencyChange(event) {
        console.log("default language changed");
        let hierarchySettingsChange = {
            settingsType: "string",
            settingsName: "Default_Contact_Language_Fluency__c",
            settingsValue: event.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    refreshAllApex() {
        refreshApex(this.contactLanguageSettingsVModel);
    }
}
