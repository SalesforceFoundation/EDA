import { LightningElement, track, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getProgramSettingsVModel from "@salesforce/apex/ProgramSettingsController.getProgramSettingsVModel";
import getProgramEnrollmentDeletionSettingsVModel from "@salesforce/apex/ProgramSettingsController.getProgramEnrollmentDeletionSettingsVModel";

//custom labels
import stgProgramsSettingsTitle from "@salesforce/label/c.stgProgramsSettingsTitle";
import stgBtnEdit from "@salesforce/label/c.stgBtnEdit";
import stgBtnDelete from "@salesforce/label/c.stgBtnDelete";
import autoEnrollmentMappingsTitle from "@salesforce/label/c.stgAutoEnrollmentProgramTitle";
import autoEnrollmentMappingsDescription from "@salesforce/label/c.stgAutoEnrollmentProgramDesc";
import stgColAccountRecordType from "@salesforce/label/c.stgColAccountRecordType";
import stgColAutoEnrollmentStatus from "@salesforce/label/c.stgColAutoEnrollmentStatus";
import stgColAutoEnrollmentRole from "@salesforce/label/c.stgColAutoEnrollmentRole";
import stgBtnAddMapping from "@salesforce/label/c.stgBtnAddMapping";
import stgAfflProgEnrollDeleteTitle from "@salesforce/label/c.stgAfflProgEnrollDeleteTitle";
import stgAfflProgEnrollDeleteRelated from "@salesforce/label/c.stgAfflProgEnrollDeleteRelated";
import AfflProgEnrollDeleted from "@salesforce/label/c.AfflProgEnrollDeleted";
import stgAfflDeleteProgramEnrollment from "@salesforce/label/c.stgAfflDeleteProgramEnrollment";

export default class programSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    @track programSettingsVModel;
    @track programSettingsVModelWireResult;

    @track programEnrollmentDeletionSettingsVModel;
    @track programEnrollmentDeletionSettingsVModelWireResult;

    labelReference = {
        programsSettingsTitle: stgProgramsSettingsTitle,
        newButton: stgBtnAddMapping,
        programEnrollmentDeletionHeading: stgAfflProgEnrollDeleteTitle,
        programEnrollmentDeletionSettingTitle: stgAfflProgEnrollDeleteRelated,
        programEnrollmentDeletionSettingDescription: AfflProgEnrollDeleted,
        programEnrollmentDeletionStatusSettingTitle: stgAfflDeleteProgramEnrollment,

        autoEnrollmentMappingsTable: {
            autoEnrollmentMappingsTitle: autoEnrollmentMappingsTitle,
            autoEnrollmentMappingsDescription: autoEnrollmentMappingsDescription,
            accountRecordTypeColumn: stgColAccountRecordType,
            autoEnrollmentStatusColumn: stgColAutoEnrollmentStatus,
            autoEnrollmentRoleColumn: stgColAutoEnrollmentRole,
            editAction: stgBtnEdit,
            deleteAction: stgBtnDelete,
        },
    };

    inputAttributeReference = {
        deleteRelatedAffiliationsWithProgramEnrollmentToggleId: "programEnrollmentDeletions",
    };

    get affordancesDisabled() {
        if (!this.isEditMode || this.affordancesDisabledToggle === true) {
            return true;
        }
        return undefined;
    }

    @wire(getProgramSettingsVModel)
    programSettingsVModelWire(result) {
        this.programSettingsVModelWireResult = result;

        if (result.data) {
            this.programSettingsVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving preferredContactInfoSettingsVModel");
        }
    }

    @wire(getProgramEnrollmentDeletionSettingsVModel)
    programEnrollmentDeletionSettingsVModelWire(result) {
        this.programEnrollmentDeletionSettingsVModelWireResult = result;

        if (result.data) {
            this.programEnrollmentDeletionSettingsVModel = result.data;
        } else if (result.error) {
            console.log("error retrieving ProgramEnrollmentDeletionSettingsVModel");
        }
    }

    get autoEnrollmentMappingsTableColumns() {
        return [
            {
                label: this.labelReference.autoEnrollmentMappingsTable.accountRecordTypeColumn,
                fieldName: "accountRecordTypeLabel",
            },
            {
                label: this.labelReference.autoEnrollmentMappingsTable.autoEnrollmentStatusColumn,
                fieldName: "autoProgramEnrollmentStatus",
            },
            {
                label: this.labelReference.autoEnrollmentMappingsTable.autoEnrollmentRoleColumn,
                fieldName: "autoProgramEnrollmentRole",
            },
            {
                type: "action",
                typeAttributes: {
                    rowActions: [
                        { label: this.labelReference.autoEnrollmentMappingsTable.editAction, name: "edit" },
                        { label: this.labelReference.autoEnrollmentMappingsTable.deleteAction, name: "delete" },
                    ],
                },
            },
        ];
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

    handleProgramEnrollmentDeletionChange(event) {
        console.log("programEnrollmentDeletions toggle selected!");
    }

    refreshAllApex() {
        Promise.all([refreshApex(this.programSettingsVModelWireResult)]).then(() => {
            this.template.querySelectorAll("c-settings-row-input").forEach((input) => {
                input.resetValue();
            });
        });
    }

    get autoEnrollmentMappingsDescriptionRichText() {
        return this.labelReference.autoEnrollmentMappingsTable.autoEnrollmentMappingsDescription;
    }

    handleNewAutoEnrollmentMappingClick(event) {}
    handleAutoEnrollmentMappingRowAction(event) {}
}
