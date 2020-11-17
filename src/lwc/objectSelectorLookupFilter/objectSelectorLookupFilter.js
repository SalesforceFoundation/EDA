import { LightningElement, wire, api } from 'lwc';

import getLookupFields from '@salesforce/apex/CTRL_FilteredLookupComboBox.getLookupFields';
import getAffiliationMappingFields from '@salesforce/apex/CTRL_FilteredLookupComboBox.getAffiliationMappingFields';


export default class ObjectLookupSelector extends LightningElement {

    @api objectApiName;
    @api parentObjectApiName; // API of SObject to filter lookups 
    @api comboBoxLabel;
    @api comboBoxPlaceholder;

    @wire(getLookupFields, {
        objectApiName: '$objectApiName', 
        lookupObjectApiName: '$parentObjectApiName',
    }) wiredLookupViewModel;

    get comboboxOptions(){
        if (!this.wiredLookupViewModel.data){
            return null;
        }

        return this.wiredLookupViewModel.data.fieldSelectOptions;
    }
}