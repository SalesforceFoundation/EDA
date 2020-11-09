import { LightningElement, track, wire, api } from 'lwc';

import citizenshipStatusLabelText from '@salesforce/label/c.CitizenshipStatusSelectComboboxLabel';
import citizenshipStatusPlaceholderText from '@salesforce/label/c.objectSelectComboboxPlaceholder';

export default class LWC_Parent_component extends LightningElement {
    @track selectedPicklistValue = ''; // track this attribute to update parent component upon change
    
    objectApiName = 'Contact';
    fieldApiName = 'Citizenship_Status__c';

    citizenshipStatusLabel = citizenshipStatusLabelText;
    citizenshipStatusPlaceholder = citizenshipStatusPlaceholderText;
    
    handlePicklistItemSelected(event){
        this.selectedPicklistValue = event.detail.selectedItem;
    }
}