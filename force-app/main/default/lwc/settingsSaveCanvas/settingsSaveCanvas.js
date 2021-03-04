import { LightningElement, api } from "lwc";

import settingsButtonEdit from "@salesforce/label/c.stgBtnEdit";
import settingsButtonCancel from "@salesforce/label/c.stgBtnCancel";
import settingsButtonSave from "@salesforce/label/c.stgBtnSave";

import updateHierarchySettingsServerSide from "@salesforce/apex/HierarchySettingsChangesController.updateHierarchySettings";

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

        updateHierarchySettingsServerSide({
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
                // TODO: handle catch (System.NoAccessException e)
                // TODO: handle catch (HierarchySettingsMapper.InvalidSettingsException e)
                console.log("Error: " + JSON.stringify(error));
            });

        this.dispatchSettingsSaveCompletedEvent();
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
