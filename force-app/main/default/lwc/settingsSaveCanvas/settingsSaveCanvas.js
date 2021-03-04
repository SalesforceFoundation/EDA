import { LightningElement, api, track } from "lwc";

import settingsButtonEdit from "@salesforce/label/c.stgBtnEdit";
import settingsButtonCancel from "@salesforce/label/c.stgBtnCancel";
import settingsButtonSave from "@salesforce/label/c.stgBtnSave";

import updateHierarchySettings from "@salesforce/apex/HierarchySettingsChangesController.updateHierarchySettings";

export default class SettingsSaveCanvas extends LightningElement {
    @api componentTitle;

    @track errorMessage = '';
    @track hasErrors = false;

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
                } else {
                    // update failed - DML Exception encountered
                    console.log("Update failed.");
                }
            })
            .catch((error) => {
                // Check the exception type
                let exceptionType = error.body.exceptionType;
                let errorMessage = error.body.message;
                console.log('error json: ' + JSON.stringify(error));
                console.log('error message: ' + errorMessage);

                this.hasErrors = true;
                this.errorMessage = errorMessage;

                if (exceptionType === 'System.NoAccessException') {
                    console.log('TODO: handle NoAccessException');
                    this.errorMessage = errorMessage;
                }

                if (exceptionType === 'HierarchySettingsMapper.InvalidSettingsException') {
                    console.log('TODO: handle HierarchySettingsMapper.InvalidSettingsException');
                    this.errorMessage = errorMessage;
                }
            });

        this.dispatchSettingsSaveCompletedEvent(); // does this event happen even in the case of an error?
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
}
