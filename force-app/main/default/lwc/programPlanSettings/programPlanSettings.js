import { LightningElement, track, wire, api } from "lwc";
import { refreshApex } from "@salesforce/apex";

import getProgramPlanSettingsVModel from "@salesforce/apex/ProgramPlanSettingsController.getProgramPlanSettingsVModel";

//Program Plan Settings Labels
import stgProgramPlanSettingsTitle from "@salesforce/label/c.stgProgramPlanSettingsNav";
import stgNestedPlanRequirementPP from "@salesforce/label/c.stgNestedPlanRequirementPP";
import stgHelpNestedPlanRequirementPP from "@salesforce/label/c.stgHelpNestedPlanRequirementPP";

export default class ProgramPlanSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    @track programPlanSettingsVModel;
    @track programPlanSettingsVModelWireResult;

    inputAttributeReference = {
        validateProgramPlanToggleId: "validateProgramPlan",
    };

    labelReference = {
        programPlanSettingsTitle: stgProgramPlanSettingsTitle,
        validateProgramPlanSettingTitle: stgNestedPlanRequirementPP,
        validateProgramPlanDescription: stgHelpNestedPlanRequirementPP,
    };

    get affordancesDisabled() {
        if (!this.isEditMode || this.affordancesDisabledToggle === true) {
            return true;
        }
        return undefined;
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

    handleValidateProgramPlanChange(event) {
        let hierarchySettingsChange = {
            settingsType: "string",
            settingsName: "Validate_Program_Plan_for_Nested_PR__c",
            settingsValue: event.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    refreshAllApex() {
        Promise.all([refreshApex(this.programPlanSettingsVModelWireResult)]).then(() => {
            this.template.querySelectorAll("c-settings-row-input").forEach((input) => {
                input.resetValue();
            });
        });
    }

    @wire(getProgramPlanSettingsVModel)
    programPlanSettingsVModelWire(result) {
        this.programPlanSettingsVModelWireResult = result;

        if (result.data) {
            this.programPlanSettingsVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving ProgramPlanSettingsVModel");
        }
    }

    @api
    handleSaveCanvasRender() {
        this.template.querySelector("c-settings-save-canvas").focusOnTitle();
    }
}
