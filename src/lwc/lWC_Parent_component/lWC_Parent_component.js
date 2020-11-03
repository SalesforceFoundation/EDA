import { LightningElement, track } from 'lwc';

import comboBoxLabelText from '@salesforce/label/c.CitizenshipStatusSelectComboboxLabel';
import comboBoxPlaceholderText from '@salesforce/label/c.objectSelectComboboxPlaceholder';

export default class LWC_Parent_component extends LightningElement {
    @track selectedPicklistValue = ''; // track this attribute to update parent component upon change
    
    objectApiName = 'Contact';
    fieldApiName = 'Citizenship_Status__c';

    comboBoxLabelName = comboBoxLabelText;
    comboBoxPlaceholderValue = comboBoxPlaceholderText;

    handlePicklistItemSelected(event){
        this.selectedPicklistValue = event.detail.selectedItem;
    }
}