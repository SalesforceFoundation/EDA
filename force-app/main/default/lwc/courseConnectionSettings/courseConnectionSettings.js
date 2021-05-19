import { LightningElement, wire, track, api } from "lwc";
import { refreshApex } from "@salesforce/apex";

//Apex
import getCourseConnectionSettingsVModel from "@salesforce/apex/CourseConnectionSettingsController.getCourseConnectionSettingsVModel";

//Custom Labels
import stgCourseConnectionsTitle from "@salesforce/label/c.stgCourseConnectionsTitle";
import stgEnableCourseConnectionsTitle from "@salesforce/label/c.stgEnableCourseConnectionsTitle";
import stgHelpEnableCourseConnections from "@salesforce/label/c.stgHelpEnableCourseConnections";

export default class CourseConnectionSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;
    @track courseConnectionSettingsVModel;
    @track courseConnectionSettingsWireResult;

    labelReference = {
        stgCourseConnectionsTitle: stgCourseConnectionsTitle,
        stgEnableCourseConnectionsTitle: stgEnableCourseConnectionsTitle,
        stgHelpEnableCourseConnections: stgHelpEnableCourseConnections,
    };

    inputAttributeReference = {
        courseConnectionRecordTypesToggleId: "courseConnectionRecordTypes",
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
        refreshApex(this.courseConnectionSettingsWireResult).then(() => {
            this.template.querySelectorAll("c-settings-row-dual-listbox").forEach((dualListBox) => {
                dualListBox.resetValue();
            });
            this.template.querySelectorAll("c-settings-row-input").forEach((input) => {
                input.resetValue();
            });
        });
    }

    @wire(getCourseConnectionSettingsVModel)
    courseConnectionSettingsWire(result) {
        this.courseConnectionSettingsWireResult = result;
        if (result.data) {
            console.log(result.data);
            this.courseConnectionSettingsVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving accountmodelsettingsvmodel");
        }
    }

    handleCourseConnectionRecordTypesChange(event) {
        let hierarchySettingsChange = {
            settingsType: "boolean",
            settingsName: "Enable_Course_Connections__c",
            settingsValue: event.detail.value,
        };
        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }
}
