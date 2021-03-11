import { LightningElement, api } from "lwc";

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
        this.dispatchSettingsSaveCompletedEvent();
    }

    @api
    handleHierarchySettingsChange(hierarchySettingsChange) {
        if (hierarchySettingsChange.settingsType === "string") {
            hierarchySettingsChanges.settingsSingleValueBySettingsName[hierarchySettingsChange.settingsName] =
                hierarchySettingsChange.settingsValue;
        }
        if (hierarchySettingsChange.settingsType === "array") {
            hierarchySettingsChanges.settingsListSettingsName[hierarchySettingsChange.settingsName] =
                hierarchySettingsChange.settingsValue;
        }
    }

    @api
    updateHierarchySettings() {
        this.dispatchEditModeSwitchEvent(false);

        updateHierarchySettings({
            hierarchySettingsChangesVModel: this.hierarchySettingsChanges,
        })
            .then((result) => {
                if (result === true) {
                    // update successful
                    this.switchEditMode(false);
                    this.dispatchSettingsSaveCompletedEvent();
                }
            })
            .catch((error) => {
                // affordances are re-enabled
                this.switchEditMode(true);

                let exceptionType = error.body.exceptionType;
                let errorMessage = error.body.message;

                if (exceptionType === "System.NoAccessException") {
                    this.displayNoAccessError(exceptionType, errorMessage);
                }

                if (exceptionType === "HierarchySettingsMapper.InvalidSettingsException") {
                    this.displayInvalidSettingsError(exceptionType, errorMessage);
                }
            });
    }

    clearHierarchySettingsChanges() {
        this.hierarchySettingsChanges = {
            settingsSingleValueBySettingsName: {},
            settingsListSettingsName: {},
        };
    }

    handleEditClick(event) {
        this.switchEditMode(true);
        this.dispatchEditModeSwitchEvent();
    }

    handleCancelClick(event) {
        this.switchEditMode(false);
        this.clearHierarchySettingsChanges();
        this.dispatchEditModeSwitchEvent(false);
    }

    handleSaveClick() {
        this.switchEditMode(false);
        this.dispatchSettingsSavingEvent();
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

    showErrorToast(toastTitle, toastMessage) {
        const showToastEvent = new ShowToastEvent({
            title: toastTitle,
            message: toastMessage,
            variant: "error",
            mode: "dismissable",
        });
        this.dispatchEvent(showToastEvent);
    }
}
