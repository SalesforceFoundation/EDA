import { LightningElement, track, wire, api } from 'lwc';

import citizenshipStatusLabelText from '@salesforce/label/c.CitizenshipStatusSelectComboboxLabel';
import citizenshipStatusPlaceholderText from '@salesforce/label/c.objectSelectComboboxPlaceholder';

export default class LWC_Parent_component extends LightningElement {
    @track selectedPicklistValue = ''; // track this attribute to update parent component upon change
    
    contactApiName = 'Contact';
    accountObjectApiName = 'Account';
    affiliationApiName = 'Affiliation__c';

    statusFieldApiName = 'Status__c';
    roleFieldApiName = 'Role__c';
   // fieldApiName = 'Citizenship_Status__c';

    

    // citizenshipStatusLabel = citizenshipStatusLabelText;
    // citizenshipStatusPlaceholder = citizenshipStatusPlaceholderText;

    recordTypeLabel = 'Account Record Type';
    recordTypePlaceholder = 'Select a record type';
    primaryAfflLabel = 'Contact Primary Affl Field';
    primaryAfflPlaceholder = 'Select an affiliation';
    affiliationStatusLabel = 'Auto-Enrollment Status'
    affiliationStatusPlaceholder = 'Select a status';
    affiliationRoleLabel = 'Auto-Enrollment Role'
    affiliationRolePlaceholder = 'Select a role';

    
    handleRecordTypeSelected(event){
        console.log('RT changed to: ' + event.detail.selectedItem);
        this.selectedPicklistValue = event.detail.selectedItem;
    }
}