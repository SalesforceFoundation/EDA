import { LightningElement, track, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getProgramSettingsVModel from "@salesforce/apex/ProgramSettingsController.getProgramSettingsVModel";

// Controller for Affiliations created with Program Enrollment
import getAffiliationsWithProgramEnrollmentVModel from "@salesforce/apex/AffiliationsWithProgramEnrollController.getAffiliationsWithProgramEnrollmentVModel";

//Custom labels for Affiliations created with Program Enrollment
import stgAfflProgramEnrollmentSettingsTitle from "@salesforce/label/c.stgAfflProgramEnrollmentSettingsTitle";
import stgAfflProgEnrollSetRoleValue from "@salesforce/label/c.stgAfflProgEnrollSetRoleValue";
import stgHelpAfflProgEnrollSetRoleValue from "@salesforce/label/c.stgHelpAfflProgEnrollSetRoleValue";
import stgAfflProgEnrollSetStatusValue from "@salesforce/label/c.stgAfflProgEnrollSetStatusValue";
import stgHelpAfflProgEnrollSetStatusValue from "@salesforce/label/c.stgHelpAfflProgEnrollSetStatusValue";
import stgAfflCopyProgramEnrollmentEndDate from "@salesforce/label/c.stgAfflCopyProgramEnrollmentEndDate";
import stgHelpAfflCopyProgramEnrollmentEndDate from "@salesforce/label/c.stgHelpAfflCopyProgramEnrollmentEndDate";
import stgAfflCopyProgramEnrollmentStartDate from "@salesforce/label/c.stgAfflCopyProgramEnrollmentStartDate";
import stgHelpAfflCopyProgramEnrollmentStartDate from "@salesforce/label/c.stgHelpAfflCopyProgramEnrollmentStartDate";
import stgOptSelect from "@salesforce/label/c.stgOptSelect";

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
export default class programSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    @track affiliationsWithProgramEnrollmentVModel;
    @track affiliationsWithProgramEnrollVModelWireResult;
    @track programSettingsVModel;
    @track programSettingsVModelWireResult;

    labelReference = {
        programsSettingsTitle: stgProgramsSettingsTitle,
        newButton: stgBtnAddMapping,
        afflProgramEnrollmentSettingsTitle: stgAfflProgramEnrollmentSettingsTitle,
        afflProgEnrollSetRoleValue: stgAfflProgEnrollSetRoleValue,
        helpAfflProgEnrollSetRoleValue: stgHelpAfflProgEnrollSetRoleValue,
        afflProgEnrollSetStatusValue: stgAfflProgEnrollSetStatusValue,
        helpAfflProgEnrollSetStatusValue: stgHelpAfflProgEnrollSetStatusValue,
        afflCopyProgramEnrollmentEndDate: stgAfflCopyProgramEnrollmentEndDate,
        helpAfflCopyProgramEnrollmentEndDate: stgHelpAfflCopyProgramEnrollmentEndDate,
        afflCopyProgramEnrollmentStartDate: stgAfflCopyProgramEnrollmentStartDate,
        helpAfflCopyProgramEnrollmentStartDate: stgHelpAfflCopyProgramEnrollmentStartDate,
        placeHolderText: stgOptSelect,
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
        createdAfflRoleComboboxId: "createdAfflRole",
        createdAfflStatusComboboxId: "createdAfflStatus",
        copyEndDateComboboxId: "copyEndDate",
        copyStartDateComboboxId: "copyStartDate",
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

    @wire(getAffiliationsWithProgramEnrollmentVModel)
    affiliationsWithProgramEnrollmentVModelWire(result) {
        this.affiliationsWithProgramEnrollVModelWireResult = result;

        if (result.data) {
            this.affiliationsWithProgramEnrollmentVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving preferredContactInfoSettingsVModel");
        }
    }

    handleRoleForCreatedAfflChange(event) {
        this.handleSpecifyRoleForCreatedAffiliaitons(event);
        var affiliationRole = event.detail.value;
        if (event.detail.value === '""') {
            // set Hierarchy Settings field to a blank value (not "")
            affiliationRole = "";
        }
        // add updated setting to hierarchySettingsChanges object
        let hierarchySettingsChange = {
            settingsType: "string",
            settingsName: "Affl_ProgEnroll_Role_Map__c",
            settingsValue: affiliationRole,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleSpecifyRoleForCreatedAffiliaitons(event) {
        var specifyRoleForCreatedAffl = event.detail.value;
        if (event.detail.value === '""') {
            // set Hierarchy Settings field to a blank value (not "")
            specifyRoleForCreatedAffl = false;
        } else {
            specifyRoleForCreatedAffl = true;
        }
        // add updated setting to hierarchySettingsChanges object
        let hierarchySettingsChange = {
            settingsType: "boolean",
            settingsName: "Affl_ProgEnroll_Set_Role__c",
            settingsValue: specifyRoleForCreatedAffl,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleStatusForCreatedAfflChange(event) {
        var affiliationStatus = event.detail.value;
        if (event.detail.value === '""') {
            // set Hierarchy Settings field to a blank value (not "")
            affiliationStatus = "";
        }
        // add updated setting to hierarchySettingsChanges object
        let hierarchySettingsChange = {
            settingsType: "string",
            settingsName: "Affl_ProgEnroll_Status_Map__c",
            settingsValue: affiliationStatus,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleCopyEndDateChange(event) {
        // add updated setting to hierarchySettingsChanges object
        let hierarchySettingsChange = {
            settingsType: "boolean",
            settingsName: "Affl_ProgEnroll_Copy_End_Date__c",
            settingsValue: event.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleCopyStartDateChange(event) {
        // add updated setting to hierarchySettingsChanges object
        let hierarchySettingsChange = {
            settingsType: "boolean",
            settingsName: "Affl_ProgEnroll_Copy_Start_Date__c",
            settingsValue: event.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
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

    refreshAllApex() {
        Promise.all([
            refreshApex(this.programSettingsVModelWireResult),
            refreshApex(this.affiliationsWithProgramEnrollVModelWireResult),
        ]).then(() => {
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
