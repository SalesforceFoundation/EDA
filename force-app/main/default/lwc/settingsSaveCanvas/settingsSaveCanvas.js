import { LightningElement, api } from 'lwc';

import settingsButtonEdit from '@salesforce/label/c.stgBtnEdit';
import settingsButtonCancel from '@salesforce/label/c.stgBtnCancel';
import settingsButtonSave from '@salesforce/label/c.stgBtnSave';

export default class SettingsSaveCanvas extends LightningElement {

    @api componentTitle;

    editButtonShown = true;
    saveCancelDisabled = undefined;

    hierarchySettingsChanges = {
        settingsSingleValueBySettingsName: {},
        settingsListSettingsName: {}
    }

    labelReference = {
        settingsButtonEdit,
        settingsButtonCancel,
        settingsButtonSave
    }

    @api
    handleHierarchySettingsChange(hierarchySettingsChange) {
        if (hierarchySettingsChange.settingsType === 'string') {
            hierarchySettingsChanges.settingsSingleValueBySettingsName[hierarchySettingsChange.settingsName] = hierarchySettingsChange.settingsValue;
        }
        if (hierarchySettingsChange.settingsType === 'array') {
            hierarchySettingsChanges.settingsListSettingsName[hierarchySettingsChange.settingsName] = hierarchySettingsChange.settingsValue;
        }
    }

    @api updateHierarchySettings() {
        this.dispatchSettingsSaveCompletedEvent();
    }

    handleEditClick(event) {
        this.switchEditMode(false);
        this.dispatchEditModeSwitchEvent();
    }

    switchEditMode(editMode) {
        this.editButtonShown = editMode;
        if (this.editMode === true) {
            this.saveCancelDisabled = true;
        } else {
            this.saveCancelDisabled = undefined;
        }
    }

    dispatchEditModeSwitchEvent() {
        this.dispatchEvent(
            new CustomEvent(
                'settingseditmodechange', 
                { 
                    detail: this.editButtonShown 
                }
            )
        );
    }

    handleCancelClick(event) {
        this.switchEditMode(true);
        this.clearHierarchySettingsChanges();
    }

    clearHierarchySettingsChanges() {
        this.hierarchySettingsChanges.settingsSingleValueBySettingsName = {};
        this.hierarchySettingsChanges.settingsListSettingsName = {};
    }

    handleSaveClick() {
        this.switchEditMode(true);
        this.dispatchSettingsSavingEvent();
    }

    dispatchSettingsSavingEvent() {
        this.dispatchEvent(
            new CustomEvent(
                'settingssaving', 
                { 
                    detail: this.editButtonShown 
                }
            )
        );
    }

    dispatchSettingsSaveCompletedEvent() {
        console.log('dispatchSettingsSaveCompletedEvent called');
        this.dispatchEvent(
            new CustomEvent('settingssavecompleted')
        );
    }
}