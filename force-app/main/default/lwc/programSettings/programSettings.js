import { LightningElement, track, wire, api } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getAutoEnrollmentMappingsVModel from "@salesforce/apex/ProgramSettingsController.getAutoEnrollmentMappingsVModel";
import updateAutoEnrollmentMappings from "@salesforce/apex/ProgramSettingsController.updateAutoEnrollmentMappings";
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
export default class programSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    @track autoEnrollmentMappingsVModel;
    @track autoEnrollmentMappingsVModelWireResult;

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
        editSuccessMessage: stgAutoEnrollmentEditSuccess,
    };

    inputAttributeReference = {};

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
        Promise.all([refreshApex(this.autoEnrollmentMappingsVModelWireResult)]).then(() => {
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
                console.log(saveModel.mappingName);
                this.updateAutoEnrollmentMappings(
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

    updateAutoEnrollmentMappings(
        mappingName,
        oldAccountRecordType,
        newAccountRecordType,
        autoProgramEnrollmentStatus,
        autoProgramEnrollmentRole
    ) {
        updateAutoEnrollmentMappings({
            mappingName: mappingName,
            oldAccountRecordType: oldAccountRecordType,
            newAccountRecordType: newAccountRecordType,
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
