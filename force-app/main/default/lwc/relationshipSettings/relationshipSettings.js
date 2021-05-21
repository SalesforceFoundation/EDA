import { LightningElement, wire, track, api } from "lwc";
import { refreshApex } from "@salesforce/apex";

// Controllers
import getRelationshipSettingsVModel from "@salesforce/apex/RelationshipSettingsController.getRelationshipSettingsVModel";
// Reciprocal Method Custom Labels
import stgRelationshipSettingsTitle from "@salesforce/label/c.stgRelationshipSettingsTitle";
import stgTitleReciMethod from "@salesforce/label/c.stgTitleReciMethod";
import stgHelpRelReciprocalMethod from "@salesforce/label/c.stgHelpRelReciprocalMethod";
import stgOptSelect from "@salesforce/label/c.stgOptSelect";
import stgTellMeMoreLink from "@salesforce/label/c.stgTellMeMoreLink";
// Allow Duplicates Custom Labels
import stgDuplicateRelationships from "@salesforce/label/c.stgDuplicateRelationships";
import stgDuplicateRelationshipsHelp from "@salesforce/label/c.stgDuplicateRelationshipsHelp";
// Articles
const relationshipsArticle = '<a href="https://powerofus.force.com/EDA-Config-Relationships-Settings">';
export default class relationshipSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    @track relationshipSettingsVModel;
    @track relationshipSettingsWireResult;

    labelReference = {
        stgRelationshipSettingsTitle: stgRelationshipSettingsTitle,
        reciprocalMethodSettingsName: stgTitleReciMethod,
        reciprocalMethodSettingsDesc: stgHelpRelReciprocalMethod,
        tellMeMore: stgTellMeMoreLink,
        comboboxPlaceholderText: stgOptSelect,
        duplicateRelationshipTitle: stgDuplicateRelationships,
        duplicateRelationshipDesc: stgDuplicateRelationshipsHelp,
    };

    inputAttributeReference = {
        defaultReciprocalComboboxId: "defaultReciprocalMethod",
        allowAutoCreatedDuplicatesId: "allowAutoCreatedDuplicates",
    };

    get relationshipSettingsHyperLink() {
        return relationshipsArticle + this.labelReference.tellMeMore + "</a>";
    }

    get relationshipSettingsDesc() {
        return this.labelReference.reciprocalMethodSettingsDesc + " " + this.relationshipSettingsHyperLink;
    }

    get duplicateRelationshipDesc() {
        return this.labelReference.duplicateRelationshipDesc + " " + this.relationshipSettingsHyperLink;
    }

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

    @wire(getRelationshipSettingsVModel)
    relationshipSettingsVModelWire(result) {
        this.relationshipSettingsWireResult = result;
        if (result.data) {
            this.relationshipSettingsVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving accountModelSettingsVModel");
        }
    }

    handleReciprocalMethodChange(event) {
        // add updated setting to hierarchySettingsChanges object
        let hierarchySettingsChange = {
            settingsType: "string",
            settingsName: "Reciprocal_Method__c",
            settingsValue: event.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleAuoCreatedDuplicatesChange(event) {
        const eventDetail = event.detail;
        let hierarchySettingsChange = {
            settingsType: "boolean",
            settingsName: "Allow_AutoCreated_Duplicates__c",
            settingsValue: !eventDetail.value, // Save the inverse as UI display the inverse value of the settings
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleSettingsEditModeChange(event) {
        this.isEditMode = !event.detail;
        this.affordancesDisabledToggle = event.detail;
    }

    handleSettingsSaving(event) {
        this.affordancesDisabledToggle = true;
        this.template.querySelector("c-settings-save-canvas").updateHierarchySettings();
    }

    handleSettingsSaveCancel(event) {
        this.refreshAllApex();
    }

    handleSettingsSaveCompleted(event) {
        this.affordancesDisabledToggle = false;
        this.refreshAllApex();
    }

    refreshAllApex() {
        Promise.all([refreshApex(this.relationshipSettingsWireResult)]).then(() => {
            this.template.querySelectorAll("c-settings-row-input").forEach((input) => {
                input.resetValue();
            });
        });
    }
}
