import { LightningElement, track, wire, api } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getProgramSettingsVModel from "@salesforce/apex/ProgramSettingsController.getProgramSettingsVModel";
import updateAutoEnrollmentMapping from "@salesforce/apex/ProgramSettingsController.updateAutoEnrollmentMapping";
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
import stgAffiliationsEditSuccess from "@salesforce/label/c.stgAffiliationsEditSuccess";
export default class programSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    @track programSettingsVModel;
    @track programSettingsVModelWireResult;

    labelReference = {
        programsSettingsTitle: stgProgramsSettingsTitle,
        newButton: stgBtnAddMapping,
        autoEnrollmentMappingsTable: {
            autoEnrollmentMappingsTitle: autoEnrollmentMappingsTitle,
            autoEnrollmentMappingsDescription: autoEnrollmentMappingsDescription,
            accountRecordTypeColumn: stgColAccountRecordType,
            autoEnrollmentStatusColumn: stgColAutoEnrollmentStatus,
            autoEnrollmentRoleColumn: stgColAutoEnrollmentRole,
            editAction: stgBtnEdit,
            deleteAction: stgBtnDelete,
        },
        editSuccessMessage: stgAffiliationsEditSuccess,
    };

    inputAttributeReference = {};

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
                this.updateAutoEnrollmentMapping(
                    saveModel.mappingName,
                    saveModel.autoProgramEnrollmentStatus,
                    saveModel.autoProgramEnrollmentRole
                );
                break;
            /*case "delete":
                this.deleteAffiliation(saveModel.mappingName);
                break;*/
        }
    }

    updateAutoEnrollmentMapping(mappingName, autoProgramEnrollmentStatus, autoProgramEnrollmentRole) {
        updateAutoEnrollmentMapping({
            mappingName: mappingName,
            autoProgramEnrollmentStatus: autoProgramEnrollmentStatus,
            autoProgramEnrollmentRole: autoProgramEnrollmentRole,
        })
            .then((result) => {
                this.showToast(
                    "success",
                    "Update Complete",
                    this.labelReference.editSuccessMessage.replace("{0}", result)
                );
            })

            .catch((error) => {
                // console.log('Inside error');
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
