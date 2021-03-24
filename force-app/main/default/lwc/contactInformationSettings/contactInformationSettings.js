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

    @track contactLanguageSettingsWireResult;
    @track contactLanguageSettingsVModel;

    @track preferredContactInfoSettingsWireResult;
    @track preferredContactInfoSettingsVModel;
    @track showPreferredPhoneEnforcement;

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
        preferredPhoneEnforcementDescription: stgHelpContactPreferredPhone,
        defaultPreferredPhoneTitle: stgPreferredPhoneDefault,
        defaultPreferredPhoneDescription: stgPreferredPhoneSelectionDesc,
        enabledText: "Active",
        disabledText: "Inactive",
    };

    inputAttributeReference = {
        defaultContactLanugageFluencyComboboxId: "defaultContactLanguageFluency",
        requirePreferredEmailToggleId: "requirePreferredEmail",
        enhancedPhoneFunctionalityToggleId: "enhancedPhoneFunctionality",
        preferredPhoneEnforcementToggleId: "preferredPhoneEnforcement",
        defaultPreferredPhoneComboboxId: "defaultPreferredPhone",
    };

    get affordancesDisabled() {
        if (!this.isEditMode || this.affordancesDisabledToggle === true) {
            return true;
        }
        return undefined;
    }

    @wire(getContactLanguageSettingsVModel)
    contactLanguageSettingsVModelWire(result) {
        this.contactLanguageSettingsWireResult = result;

        if (result.data) {
            this.contactLanguageSettingsVModel = JSON.parse(JSON.stringify(result.data));

            console.log("contactLanguageSettingsVModel BEFORE: " + JSON.stringify(this.contactLanguageSettingsVModel));
        } else if (result.error) {
            //console.log("error retrieving contactLanguageSettingsVModel");
        }
    }

    @wire(getPreferredContactInfoSettingsVModel)
    preferredContactInfoSettingsVModelWire(result) {
        this.preferredContactInfoSettingsWireResult = result;

        if (result.data) {
            this.preferredContactInfoSettingsVModel = result.data;

            // preferred phone visibility dependent on enhanced phone functionality setting
            this.showPreferredPhoneEnforcement = this.preferredContactInfoSettingsVModel.enhancedPhoneFunctionality;
        } else if (result.error) {
            console.log("error retrieving preferredContactInfoSettingsVModel");
        }
    }

    handleSettingsEditModeChange(event) {
        this.isEditMode = !event.detail;
        this.affordancesDisabledToggle = event.detail;

        //this.refreshAllApex();
    }

    handleSettingsSaving(event) {
        this.affordancesDisabledToggle = true;
        // TODO: perform client side validation

        // if validation fails, call this.handleValidationFailure()
        //this.template.querySelector("c-settings-save-canvas").handleValidationFailure();

        // else, update hierarchy settings
        this.template.querySelector("c-settings-save-canvas").updateHierarchySettings();
    }

    handleSettingsSaveCancel(event) {
        this.refreshAllApex();
    }

    handleSettingsSaveCompleted(event) {
        this.affordancesDisabledToggle = false;
        this.refreshAllApex();
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
        // display preferred phone setting if enhanced phone functionality selected
        this.showPreferredPhoneEnforcement = event.target.checked;

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
        var defaultPreferredPhoneValue = event.detail.value;

        if (event.detail.value === '""') {
            // set Hierarchy Settings field to a blank value (not "")
            defaultPreferredPhoneValue = "";
        }

        let hierarchySettingsChange = {
            settingsType: "string",
            settingsName: "Preferred_Phone_Selection__c",
            settingsValue: defaultPreferredPhoneValue,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    refreshAllApex() {
        refreshApex(this.contactLanguageSettingsWireResult).then(() => {
            this.template.querySelectorAll("lightning-combobox").forEach((combobox) => {
                if (
                    combobox.dataset["qaLocator"] ===
                    this.inputAttributeReference.defaultContactLanugageFluencyComboboxId
                ) {
                    combobox.value = this.contactLanguageSettingsVModel.defaultContactLanguageFluency.value;
                }
            });
        });

        refreshApex(this.preferredContactInfoSettingsWireResult).then(() => {
            // this.template.querySelectorAll("lightning-combobox").forEach((combobox) => {
            //     if (combobox.dataset["qaLocator"] === this.inputAttributeReference.defaultPreferredPhoneComboboxId) {
            //         combobox.value = this.contactLanguageSettingsVModel.defaultPreferredPhone.value;
            //     }
            // });

            console.log("toggles..");
            this.template.querySelectorAll("lightning-input").forEach((toggle) => {
                if (toggle.dataset["qaLocator"] === this.inputAttributeReference.requirePreferredEmailToggleId) {
                    toggle.checked = this.contactLanguageSettingsVModel.requirePreferredEmail;
                }

                if (toggle.dataset["qaLocator"] === this.inputAttributeReference.enhancedPhoneFunctionalityToggleId) {
                    toggle.checked = this.contactLanguageSettingsVModel.enhancedPhoneFunctionality;
                }

                if (toggle.dataset["qaLocator"] === this.inputAttributeReference.preferredPhoneEnforcementToggleId) {
                    toggle.checked = this.contactLanguageSettingsVModel.preferredPhoneEnforcement;
                }
            });
        });
    }
}
