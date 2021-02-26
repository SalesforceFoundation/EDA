import { LightningElement, api, track } from 'lwc';
import stgAccountModelSettingsTitle from '@salesforce/label/c.stgAccountModelSettingsTitle';

export default class AccountModelSettings extends LightningElement {
    @track isEditMode = false;
    @track affordancesDisabledToggle = true;

    get affordancesDisabled() {
        if (this.isEditMode == true || this.affordancesDisabledToggle == true) {
            return true;
        } 
        return undefined;
    }

    labelReference = {
        stgAccountModelSettingsTitle
    }

    handleSettingsEditModeChange(event) { 
        //edit button shown == false on save
        // edit button shown == true on cancel
        this.isEditMode =!event.detail;
        this.affordancesDisabledToggle = !event.detail;

        this.refreshAllApex();
    }

    handleSettingsSaving(event) { 
        this.affordancesDisabledToggle = true;
        this.template.querySelector('c-settings-save-canvas').updateHierarchySettings();
    }
    
    handleSettingsSaveCompleted(event) {
        this.affordancesDisabledToggle = false;
    }

    refreshAllApex() {
    }
}