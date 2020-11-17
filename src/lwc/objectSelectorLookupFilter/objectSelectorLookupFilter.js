import { LightningElement, wire, api } from 'lwc';

import getAccountLookupFields from '@salesforce/apex/CTRL_FilteredLookupComboBox.getAccountLookupFields';


export default class ObjectLookupSelector extends LightningElement {

    @api objectApiName;
    @api parentObjectApiName; // API of SObject to filter lookups 
    @api comboBoxLabel;
    @api comboBoxPlaceholder;

    @wire(getAccountLookupFields, {
        objectApiName: '$objectApiName', 
        lookupObjectApiName: '$parentObjectApiName',
    }) wiredLookupViewModel;

    get comboboxOptions(){

        console.log('lookup data: ' + this.wiredLookupViewModel.data);
        if (!this.wiredLookupViewModel.data){
            return null;
        }

        return this.wiredLookupViewModel.data.fieldSelectOptions;
    }
}