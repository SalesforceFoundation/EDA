import { LightningElement, api } from "lwc";

import settingsButtonEdit from "@salesforce/label/c.stgBtnEdit";
import settingsButtonCancel from "@salesforce/label/c.stgBtnCancel";
import settingsButtonSave from "@salesforce/label/c.stgBtnSave";
import stgSaveSettings from "@salesforce/label/c.stgSaveSettings";
import stgSuccess from "@salesforce/label/c.stgSuccess";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

import updateHierarchySettings from "@salesforce/apex/HierarchySettingsChangesController.updateHierarchySettings";

export default class SettingsSaveCanvas extends LightningElement {
    // initialize component
    renderedCallback() {
        if (this.hasRendered) {
            return;
        }

        this.hasRendered = true;

        this.dispatchEvent(
            new CustomEvent("savecanvasrendered", {
                bubbles: true,
                composed: true,
            })
        );
    }

    @api componentTitle;

    hasRendered;
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
        successMessage: stgSaveSettings,
        successToast: stgSuccess,
    };

    @api
    focusOnTitle() {
        this.template.querySelector(".eda-settings-page-title").focus();
    }

    @api
    handleValidationFailure() {
        this.dispatchSettingsSaveCompletedEvent();
    }

    @api
    handleHierarchySettingsChange(hierarchySettingsChange) {
        let hierarchySettingsTypeLowercased = hierarchySettingsChange.settingsType.toLowerCase();

        switch (hierarchySettingsTypeLowercased) {
            case "string":
                this.hierarchySettingsChanges.settingsSingleValueBySettingsName[hierarchySettingsChange.settingsName] =
                    hierarchySettingsChange.settingsValue;
                break;

            case "boolean":
                this.hierarchySettingsChanges.settingsSingleValueBySettingsName[hierarchySettingsChange.settingsName] =
                    hierarchySettingsChange.settingsValue;
                break;

            case "datetime":
                this.hierarchySettingsChanges.settingsSingleValueBySettingsName[hierarchySettingsChange.settingsName] =
                    hierarchySettingsChange.settingsValue;
                break;

            case "array":
                this.hierarchySettingsChanges.settingsListSettingsName[hierarchySettingsChange.settingsName] =
                    hierarchySettingsChange.settingsValue;
                break;
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
                    this.showToast("success", this.labelReference.successToast, this.labelReference.successMessage);
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

                if (exceptionType.includes("HierarchySettingsService.InvalidSettingsException")) {
                    // need to account for namespace in custom error thrown
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
        this.dispatchSettingsSaveCancelEvent();
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

    dispatchSettingsSaveCancelEvent() {
        this.dispatchEvent(new CustomEvent("settingssavecancel"));
    }

    dispatchSettingsSaveCompletedEvent() {
        this.dispatchEvent(new CustomEvent("settingssavecompleted"));
    }

    displayNoAccessError(errorType, errorMessage) {
        this.showToast("error", errorType, errorMessage);
        this.dispatchSettingsSaveCompletedEvent();
    }

    displayInvalidSettingsError(errorType, errorMessage) {
        this.showToast("error", errorType, errorMessage);
        this.dispatchSettingsSaveCompletedEvent();
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
