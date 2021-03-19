import { LightningElement, wire, track } from "lwc";
import { refreshApex } from "@salesforce/apex";

import getContactLanguageSettingsVModel from "@salesforce/apex/ContactInfoSettingsController.getContactLanguageSettingsVModel";
import getPreferredContactInfoSettingsVModel from "@salesforce/apex/ContactInfoSettingsController.getPreferredContactInfoSettingsVModel";

import stgContactInformationSettingsTitle from "@salesforce/label/c.stgContactInformationSettingsTitle";
import stgDefaultContactLanguageFluency from "@salesforce/label/c.stgDefaultContactLanguageFluency";
import stgHelpDefaultContactLanguageFluency from "@salesforce/label/c.stgHelpDefaultContactLanguageFluency";
import stgOptSelect from "@salesforce/label/c.stgOptSelect";
import stgDisablePreferredEmailEnforcement from "@salesforce/label/c.stgDisablePreferredEmailEnforcement";
import stgHelpContactPreferredEmail from "@salesforce/label/c.stgHelpContactPreferredEmail";
import stgEnablePreferredPhoneSync from "@salesforce/label/c.stgEnablePreferredPhoneSync";
import stgHelpContactPreferredPhoneSync from "@salesforce/label/c.stgHelpContactPreferredPhoneSync";
import stgDisablePreferredPhoneEnforcement from "@salesforce/label/c.stgDisablePreferredPhoneEnforcement";
import stgHelpContactPreferredPhone from "@salesforce/label/c.stgHelpContactPreferredPhone";
import stgPreferredPhoneDefault from "@salesforce/label/c.stgPreferredPhoneDefault";
import stgPreferredPhoneSelectionDesc from "@salesforce/label/c.stgPreferredPhoneSelectionDesc";

export default class ContactInformationSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;
    showPreferredPhoneEnforcement = false; //?

    @track contactLanguageSettingsVModel;
    @track preferredContactInfoSettingsVModel;

    labelReference = {
        contactInformationSettingsTitle: stgContactInformationSettingsTitle,
        contactLanguageDefaultFluencyTitle: stgDefaultContactLanguageFluency,
        contactLanguageDefaultFluencyDescription: stgHelpDefaultContactLanguageFluency,
        comboboxPlaceholderText: stgOptSelect,
        requirePreferredEmailTitle: stgDisablePreferredEmailEnforcement,
        requirePreferredEmailDescription: stgHelpContactPreferredEmail,
        enhancedPhoneFunctionalityTitle: stgEnablePreferredPhoneSync,
        enhancedPhoneFunctionalityDescription: stgHelpContactPreferredPhoneSync,
        preferredPhoneEnforcementTitle: stgDisablePreferredPhoneEnforcement,
        enhancedPhoneFunctionalityDescritpion: stgHelpContactPreferredPhone,
        defaultPreferredPhoneTitle: stgPreferredPhoneDefault,
        defaultPreferredPhoneDescription: stgPreferredPhoneSelectionDesc,
    };

    inputAttributeReference = {
        defaultContactLanugageFluencyComboboxId: "defaultContactLanguageFluency",
        requirePreferredEmailToggleId: "requirePreferredEmail",
        enhancedPreferredPhoneToggleId: "enhancedPreferredPhone",
        defaultPreferredPhoneComboboxId: "defaultPreferredPhone",
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
            //console.log("error retrieving contactLanguageSettingsVModel");
        }
    }

    @wire(getPreferredContactInfoSettingsVModel)
    preferredContactInfoSettingsVModel({ error, data }) {
        if (data) {
            this.preferredContactInfoSettingsVModel = data;
        } else if (error) {
            console.log("error retrieving preferredContactInfoSettingsVModel");
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
        let hierarchySettingsChange = {
            settingsType: "string",
            settingsName: "Default_Contact_Language_Fluency__c",
            settingsValue: event.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleRequirePreferredEmailChange(event) {
        let hierarchySettingsChange = {
            settingsType: "boolean",
            settingsName: "Disable_Preferred_Email_Enforcement__c",
            settingsValue: !event.target.checked, // UI input should display inverse of value specified in hierarchy settings for this field
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleEnhancedPhoneFunctionalityChange(event) {
        let hierarchySettingsChange = {
            settingsType: "boolean",
            settingsName: "Enable_New_Preferred_Phone_Sync__c",
            settingsValue: event.target.checked,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handlePreferredPhoneEnforcementChange(event) {
        let hierarchySettingsChange = {
            settingsType: "boolean",
            settingsName: "Disable_Preferred_Phone_Enforcement__c",
            settingsValue: !event.target.checked, // UI input should display inverse of value specified in hierarchy settings for this field
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleDefaultPreferredPhoneChange(event) {
        let hierarchySettingsChange = {
            settingsType: "string",
            settingsName: "Preferred_Phone_Selection__c",
            settingsValue: event.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    refreshAllApex() {
        refreshApex(this.contactLanguageSettingsVModel);
        refreshApex(this.preferredContactInfoSettingsVModel);
    }
}
