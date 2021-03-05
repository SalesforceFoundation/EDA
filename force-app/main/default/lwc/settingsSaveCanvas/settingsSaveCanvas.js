import { LightningElement, api, track } from "lwc";

import settingsButtonEdit from "@salesforce/label/c.stgBtnEdit";
import settingsButtonCancel from "@salesforce/label/c.stgBtnCancel";
import settingsButtonSave from "@salesforce/label/c.stgBtnSave";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

import updateHierarchySettings from "@salesforce/apex/HierarchySettingsChangesController.updateHierarchySettings";

export default class SettingsSaveCanvas extends LightningElement {
    @api componentTitle;

    editButtonShown = true;
    saveCancelDisabled = undefined;

    hierarchySettingsChanges = {
        settingsSingleValueBySettingsName: {},
        settingsListSettingsName: {},
    };

    labelReference = {
        settingsButtonEdit,
        settingsButtonCancel,
        settingsButtonSave,
    };

    @api
    handleValidationFailure() {
        this.clearHierarchySettingsChanges();
        this.switchEditMode(false);
        this.dispatchSettingsSaveCompletedEvent();
    }

    @api
    handleHierarchySettingsChange(hierarchySettingsChange) {
        if (hierarchySettingsChange.settingsType === "string") {
            hierarchySettingsChanges.settingsSingleValueBySettingsName[
                hierarchySettingsChange.settingsName
            ] = hierarchySettingsChange.settingsValue;
        }
        if (hierarchySettingsChange.settingsType === "array") {
            hierarchySettingsChanges.settingsListSettingsName[
                hierarchySettingsChange.settingsName
            ] = hierarchySettingsChange.settingsValue;
        }
    }

    @api
    updateHierarchySettings() {
        this.dispatchEditModeSwitchEvent(false);

        updateHierarchySettings({
            hierarchySettingsChangesModel: this.hierarchySettingsChanges,
        })
            .then((result) => {
                if (result === true) {
                    // update successful
                    console.log("Updated!");
                    this.switchEditMode(false); // turn off edit mode?
                    this.dispatchSettingsSaveCompletedEvent();
                } else {
                    // update failed - DML Exception encountered
                    console.log("Update failed.");
                }
            })
            .catch((error) => {
                let exceptionType = error.body.exceptionType;
                let errorMessage = error.body.message;

                if (exceptionType === "System.NoAccessException") {
                    this.displayNoAccessError(exceptionType, errorMessage);
                }

                if (
                    exceptionType === "HierarchySettingsMapper.InvalidSettingsException"
                ) {
                    this.displayInvalidSettingsError(exceptionType, errorMessage);
                }
            });
    }

    handleEditClick(event) {
        this.switchEditMode(true);
        this.dispatchEditModeSwitchEvent();
    }

    switchEditMode(editMode) {
        this.editButtonShown = !editMode;
        if (this.editMode === true) {
            this.saveCancelDisabled = true;
        } else {
            this.saveCancelDisabled = undefined;
        }
    }

    dispatchEditModeSwitchEvent() {
        this.dispatchEvent(
            new CustomEvent("settingseditmodechange", {
                detail: this.editButtonShown,
            })
        );
    }

    handleCancelClick(event) {
        this.switchEditMode(false);
        this.clearHierarchySettingsChanges();
        this.dispatchEditModeSwitchEvent(false);
    }

    clearHierarchySettingsChanges() {
        this.hierarchySettingsChanges.settingsSingleValueBySettingsName = {};
        this.hierarchySettingsChanges.settingsListSettingsName = {};
    }

    handleSaveClick() {
        this.switchEditMode(false);
        this.dispatchSettingsSavingEvent();
    }

    dispatchSettingsSavingEvent() {
        this.dispatchEvent(
            new CustomEvent("settingssaving", {
                detail: this.editButtonShown,
            })
        );
    }

    dispatchSettingsSaveCompletedEvent() {
        this.dispatchEvent(new CustomEvent("settingssavecompleted"));
    }

    displayNoAccessError(errorType, errorMessage) {
        this.showErrorToast(errorType, errorMessage);
        this.dispatchSettingsSaveCompletedEvent();
    }

    displayInvalidSettingsError(errorType, errorMessage) {
        this.showErrorToast(errorType, errorMessage);
        this.dispatchSettingsSaveCompletedEvent();
    }

    completeSave() {
        // TODO: Update this method
    }

    showErrorToast(toastTitle, toastMessage) {
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: toastMessage,
            variant: "error",
            mode: "dismissable",
        });
        this.dispatchEvent(evt);
    }
}
