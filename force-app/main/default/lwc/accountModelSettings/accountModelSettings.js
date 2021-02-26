import { LightningElement, api, track } from 'lwc';
import stgAccountModelSettingsTitle from '@salesforce/label/c.stgAccountModelSettingsTitle';

export default class AccountModelSettings extends LightningElement {
    @track isEditMode = false;
    @track affordancesDisabledToggle = true;

    get affordancesDisabled() {
        if (affordancesDisabledToggle === true) {
            return true;
        } 
        return undefined;
    }

    labelReference = {
        stgAccountModelSettingsTitle
    }

    handleSettingsEditModeChange(event) {
        this.isEditMode =!event.detail;
        this.affordancesDisabledToggle = !event.detail;
        this.refreshAllApex();
    }

    handleSettingsSaving(event) {
        this.affordancesDisabledToggle = true;
        this.template.querySelector('c-settings-save-canvas').updateHierarchySettings();
    }
    
    handleSettingsSaveCompleted(event) {
        console.log('Settings save completed!');

        this.affordancesDisabledToggle = false;
    }

    refreshAllApex() {
        console.log('refreshAllApex called');
    }
}