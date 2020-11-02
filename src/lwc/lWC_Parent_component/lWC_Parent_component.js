import { LightningElement, track } from 'lwc';

export default class LWC_Parent_component extends LightningElement {
    @track selectedPicklistValue = ''; // track this attribute to update parent component upon change
    @track objectApiName = 'Contact';
    @track fieldApiName = 'Citizenship_Status__c';

    handlePicklistItemSelected(event){
        this.selectedPicklistValue = event.detail.selectedItem;
    }
}