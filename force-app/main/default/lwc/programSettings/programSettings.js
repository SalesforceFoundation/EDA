import { LightningElement, track, wire, api } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getAutoEnrollmentMappingsVModel from "@salesforce/apex/ProgramSettingsController.getAutoEnrollmentMappingsVModel";
import updateAutoEnrollmentMappings from "@salesforce/apex/ProgramSettingsController.updateAutoEnrollmentMappings";

// Controller for Affiliations created with Program Enrollment
import getAffiliationsWithProgramEnrollmentVModel from "@salesforce/apex/AffiliationsWithProgramEnrollController.getAffiliationsWithProgramEnrollmentVModel";

//Custom labels for Affiliations created with Program Enrollment
import stgHelpAfflCreateFromProgramEnrollmentHeader from "@salesforce/label/c.stgHelpAfflCreateFromProgramEnrollmentHeader";
import stgHelpAfflCreateFromProgramEnrollmentInfo from "@salesforce/label/c.stgHelpAfflCreateFromProgramEnrollmentInfo";
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

//custom labels for Auto Enrollment Mappings
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
import stgAutoEnrollmentEditSuccess from "@salesforce/label/c.stgAutoEnrollmentEditSuccess";
import stgAfflProgEnrollDeleteTitle from "@salesforce/label/c.stgAfflProgEnrollDeleteTitle";
import stgAfflProgEnrollDeleteRelated from "@salesforce/label/c.stgAfflProgEnrollDeleteRelated";
import AfflProgEnrollDeleted from "@salesforce/label/c.AfflProgEnrollDeleted";
import stgAfflDeleteProgramEnrollment from "@salesforce/label/c.stgAfflDeleteProgramEnrollment";
import stgHelpAfflDeleteProgramEnrollment from "@salesforce/label/c.stgHelpAfflDeleteProgramEnrollment";
export default class programSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    @track autoEnrollmentMappingsVModel;
    @track autoEnrollmentMappingsVModelWireResult;
    @track affiliationsWithProgramEnrollmentVModel;
    @track affiliationsWithProgramEnrollVModelWireResult;
    @track programSettingsVModel;
    @track programSettingsVModelWireResult;

    @track programEnrollmentDeletionSettingsVModel;
    @track programEnrollmentDeletionSettingsVModelWireResult;
    @track showProgramEnrollmentDeletionStatus;

    labelReference = {
        programsSettingsTitle: stgProgramsSettingsTitle,
        newButton: stgBtnAddMapping,
        afflCreateFromPrgrmHeading: stgHelpAfflCreateFromProgramEnrollmentHeader,
        afflCreateFromPrgrmInfo: stgHelpAfflCreateFromProgramEnrollmentInfo,
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
        programEnrollmentDeletionHeading: stgAfflProgEnrollDeleteTitle,
        programEnrollmentDeletionSettingTitle: stgAfflProgEnrollDeleteRelated,
        programEnrollmentDeletionSettingDescription: AfflProgEnrollDeleted,
        programEnrollmentDeletionStatusSettingTitle: stgAfflDeleteProgramEnrollment,
        programEnrollmentDeletionStatusSettingDescription: stgHelpAfflDeleteProgramEnrollment,

        autoEnrollmentMappingsTable: {
            autoEnrollmentMappingsTitle: autoEnrollmentMappingsTitle,
            autoEnrollmentMappingsDescription: autoEnrollmentMappingsDescription,
            accountRecordTypeColumn: stgColAccountRecordType,
            autoEnrollmentStatusColumn: stgColAutoEnrollmentStatus,
            autoEnrollmentRoleColumn: stgColAutoEnrollmentRole,
            editAction: stgBtnEdit,
            deleteAction: stgBtnDelete,
        },
        editSuccessMessage: stgAutoEnrollmentEditSuccess,
    };

    inputAttributeReference = {
        createdAfflRoleComboboxId: "createdAfflRole",
        createdAfflStatusComboboxId: "createdAfflStatus",
        copyEndDateComboboxId: "copyEndDate",
        copyStartDateComboboxId: "copyStartDate",
        programEnrollmentDeletionToggleId: "programEnrollmentDeletions",
        programEnrollmentDeletionStatusComboboxId: "programEnrollmentDeletionStatus",
    };

    get affordancesDisabled() {
        if (!this.isEditMode || this.affordancesDisabledToggle === true) {
            return true;
        }
        return undefined;
    }

    @wire(getAutoEnrollmentMappingsVModel)
    autoEnrollmentMappingsVModelWire(result) {
        this.autoEnrollmentMappingsVModelWireResult = result;

        if (result.data) {
            this.autoEnrollmentMappingsVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving preferredContactInfoSettingsVModel");
        }
    }

    @api
    handleSaveCanvasRender() {
        this.template.querySelector("c-settings-save-canvas").focusOnTitle();
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

    @wire(getProgramEnrollmentDeletionSettingsVModel)
    programEnrollmentDeletionSettingsVModelWire(result) {
        this.programEnrollmentDeletionSettingsVModelWireResult = result;

        if (result.data) {
            this.programEnrollmentDeletionSettingsVModel = result.data;

            // program enrollment deletion status visibility dependent on program enrollment deletion setting
            this.showProgramEnrollmentDeletionStatus = !this.programEnrollmentDeletionSettingsVModel
                .programEnrollmentDeletion;
        } else if (result.error) {
            //console.log("error retrieving ProgramEnrollmentDeletionSettingsVModel");
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
        const eventDetail = event.detail;

        // display program enrollment deletion status setting if program enrollment deletion disabled
        this.showProgramEnrollmentDeletionStatus = !eventDetail.value;

        let hierarchySettingsChange = {
            settingsType: "boolean",
            settingsName: "Affl_ProgEnroll_Del__c",
            settingsValue: eventDetail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleProgramEnrollmentDeletionStatusChange(event) {
        let hierarchySettingsChange = {
            settingsType: "string",
            settingsName: "Affl_ProgEnroll_Del_Status__c",
            settingsValue: event.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    refreshAllApex() {
        Promise.all([
            refreshApex(this.autoEnrollmentMappingsVModelWireResult),
            refreshApex(this.programSettingsVModelWireResult),
            refreshApex(this.affiliationsWithProgramEnrollVModelWireResult),
            refreshApex(this.programEnrollmentDeletionSettingsVModelWireResult),
        ]).then(() => {
            this.showProgramEnrollmentDeletionStatus = !this.programEnrollmentDeletionSettingsVModel
                .programEnrollmentDeletion;

            this.template.querySelectorAll("c-settings-row-input").forEach((input) => {
                input.resetValue();
            });
        });
    }

    get autoEnrollmentMappingsDescriptionRichText() {
        return (
            this.labelReference.autoEnrollmentMappingsTable.autoEnrollmentMappingsDescription +
            " " +
            this.autoEnrollmentHyperLink
        );
    }

    handleNewAutoEnrollmentMappingClick(event) {}

    handleAutoEnrollmentMappingRowAction(event) {
        const actionName = event.detail.action.name;
        const actionRow = event.detail.row;
        this.dispatchAutoEnrollmentEditModalRequestEvent(actionName, actionRow);
    }

    dispatchAutoEnrollmentEditModalRequestEvent(actionName, actionRow) {
        const autoEnrollmentEditDetail = {
            actionName: actionName,
            mappingName: actionRow.mappingName,
            accountRecordType: actionRow.accountRecordTypeName,
            autoProgramEnrollmentStatus: actionRow.autoProgramEnrollmentStatus,
            autoProgramEnrollmentRole: actionRow.autoProgramEnrollmentRole,
        };

        const autoEnrollmentEditModalRequestEvent = new CustomEvent("autoenrollmenteditmodalrequest", {
            detail: autoEnrollmentEditDetail,
            bubbles: true,
            composed: true,
        });

        this.dispatchEvent(autoEnrollmentEditModalRequestEvent);
    }

    @api modalSave(saveModel) {
        switch (saveModel.action) {
            /*case "create":
                this.insertAffiliations(saveModel.mappingName, saveModel.accountRecordType, saveModel.contactField);
                break;*/
            case "edit":
                this.executeUpdateAutoEnrollmentMappings(
                    saveModel.mappingName,
                    saveModel.oldAccountRecordType,
                    saveModel.newAccountRecordType,
                    saveModel.autoProgramEnrollmentStatus,
                    saveModel.autoProgramEnrollmentRole
                );
                break;
            /*case "delete":
                this.deleteAffiliation(saveModel.mappingName);
                break;*/
        }
    }

    executeUpdateAutoEnrollmentMappings(
        mappingName,
        oldAccountRecordType,
        newAccountRecordType,
        autoProgramEnrollmentStatus,
        autoProgramEnrollmentRole
    ) {
        updateAutoEnrollmentMappings({
            mappingName: mappingName,
            accountRecordType: oldAccountRecordType,
            newAccountRecordType: newAccountRecordType,
            status: autoProgramEnrollmentStatus,
            role: autoProgramEnrollmentRole,
        })
            .then((result) => {
                this.showToast(
                    "success",
                    "Update Complete",
                    this.labelReference.editSuccessMessage.replace("{0}", result)
                );
            })

            .catch((error) => {
                //console.log("Inside error");
            });
        this.refreshAllApex();
    }

    showToast(toastType, toastTitle, toastMessage) {
        const showToastEvent = new ShowToastEvent({
            title: toastTitle,
            message: toastMessage,
            variant: toastType,
            mode: "dismissable",
        });
        this.dispatchEvent(showToastEvent);
    }
}
