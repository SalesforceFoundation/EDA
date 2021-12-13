import { LightningElement, wire, track, api } from "lwc";
import { refreshApex } from "@salesforce/apex";

//Apex
import getCourseConnectionSettingsVModel from "@salesforce/apex/CourseConnectionSettingsController.getCourseConnectionSettingsVModel";

//Custom Labels
import stgCourseConnectionsTitle from "@salesforce/label/c.stgCourseConnectionsNav";
import stgEnableCourseConnectionsTitle from "@salesforce/label/c.stgEnableCourseConnectionsTitle";
import stgHelpEnableCourseConnections from "@salesforce/label/c.stgHelpEnableCourseConnections";
import stgDefaultStudentTypeTitle from "@salesforce/label/c.stgDefaultStudentTypeTitle";
import stgHelpDefaultStudentType from "@salesforce/label/c.stgHelpDefaultStudentType";
import stgDefaultFacultyTypeTitle from "@salesforce/label/c.stgDefaultFacultyTypeTitle";
import stgHelpDefaultFacultyType from "@salesforce/label/c.stgHelpDefaultFacultyType";
import stgOptSelect from "@salesforce/label/c.stgOptSelect";

export default class CourseConnectionSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;
    @track courseConnectionSettingsVModel;
    @track courseConnectionSettingsWireResult;

    labelReference = {
        stgCourseConnectionsTitle: stgCourseConnectionsTitle,
        stgEnableCourseConnectionsTitle: stgEnableCourseConnectionsTitle,
        stgHelpEnableCourseConnections: stgHelpEnableCourseConnections,
        defaultStudentRecTypeLabel: stgDefaultStudentTypeTitle,
        defaultStudentRecTypeDesc: stgHelpDefaultStudentType,
        defaultFacultyRecTypeLabel: stgDefaultFacultyTypeTitle,
        defaultFacultyRecTypeDesc: stgHelpDefaultFacultyType,
        comboboxPlaceholderText: stgOptSelect,
    };

    inputAttributeReference = {
        courseConnectionRecordTypesToggleId: "courseConnectionRecordTypes",
        studentModelComboboxId: "studentRecordTypes",
        facultyModelComboboxId: "facultyRecordTypes",
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
            this.template.querySelectorAll("c-settings-row-input").forEach((input) => {
                input.resetValue();
            });
        });
    }

    @wire(getCourseConnectionSettingsVModel)
    courseConnectionSettingsWire(result) {
        this.courseConnectionSettingsWireResult = result;
        if (result.data) {
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

    handleDefaultStudentRecTypeChange(event) {
        // add updated setting to hierarchySettingsChanges object
        let hierarchySettingsChange = {
            settingsType: "string",
            settingsName: "Student_RecType__c",
            settingsValue: event.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleDefaultFacultyRecTypeChange(event) {
        // add updated setting to hierarchySettingsChanges object
        let hierarchySettingsChange = {
            settingsType: "string",
            settingsName: "Faculty_RecType__c",
            settingsValue: event.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }
}
