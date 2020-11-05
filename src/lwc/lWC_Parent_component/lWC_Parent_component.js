import { LightningElement, track, wire, api } from 'lwc';

import comboBoxLabelText from '@salesforce/label/c.CitizenshipStatusSelectComboboxLabel';
import comboBoxPlaceholderText from '@salesforce/label/c.objectSelectComboboxPlaceholder';

import getComboBoxLabels from '@salesforce/apex/CTRL_CustomLabels.getComboBoxLabels';

export default class LWC_Parent_component extends LightningElement {
    @track selectedPicklistValue = ''; // track this attribute to update parent component upon change
    
    objectApiName = 'Contact';
    fieldApiName = 'Citizenship_Status__c';

    comboBoxLabelName = 'Hardcoded Label Name';
    comboBoxPlaceholderValue = 'Hardcoded Placeholder Value';
    
    // @wire(getComboBoxLabels) wiredComboBoxLabels({ error, data}){
    //     if (data){
    //         this.comboBoxLabelName = data.labelText;
    //         this.comboBoxPlaceholderValue = data.placeholderText; 
    //     } else if (error){
    //         console.log('error retrieving custom label values');
    //     }
    // };

    handlePicklistItemSelected(event){
        this.selectedPicklistValue = event.detail.selectedItem;
    }
}