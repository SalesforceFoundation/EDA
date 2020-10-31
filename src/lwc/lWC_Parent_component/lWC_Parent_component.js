import { LightningElement, track } from 'lwc';

export default class LWC_Parent_component extends LightningElement {
    selectedPicklistValue;
    @track objectApiName = 'Contact';
    @track fieldApiName = 'Citizenship_Status__c';

    handlePicklistItemSelected(event){
        this.selectedPicklistValue = event.detail;
        console.log('selected item in Parent LWC component: ' + this.selectedPicklistValue);
    }
}