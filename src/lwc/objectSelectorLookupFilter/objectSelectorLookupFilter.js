import { LightningElement, wire, api, track } from 'lwc';

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

    @wire(getAffiliationMappingFields, {}) wiredAfflMappingFields;

    get comboboxOptionsForLookups(){
        if (!this.wiredLookupViewModel.data){
            return null;
            // this.comboBoxSelectOptions.push.apply(this.comboBoxSelectOptions, this.wiredLookupViewModel.data.fieldSelectOptions);
            // console.log('this.comboBoxSelectOptions after lookups: ' + JSON.stringify(this.comboBoxSelectOptions));
        }

        // if (this.wiredAfflMappingFields.data){
        //     //return null;
        //     this.comboBoxSelectOptions.push.apply(this.comboBoxSelectOptions, this.wiredAfflMappingFields.data.fieldSelectOptions);
        //     console.log('this.comboBoxSelectOptions after affiliations: ' + JSON.stringify(this.comboBoxSelectOptions));
        // }

        // for (var i=0; i<this.comboBoxSelectOptions.length; i++){
        //     console.log('list item: ' + JSON.stringify(this.comboBoxSelectOptions[i]));
        // }

        // console.log('comboBoxSelectOptions size: ' + this.comboBoxSelectOptions.length);
        // console.log('comboBoxSelectOptions content: ' + JSON.stringify(this.comboBoxSelectOptions));

        console.log('this.wiredLookupViewModel.data: ' + this.wiredLookupViewModel.data);
        return this.wiredLookupViewModel.data.fieldSelectOptions;
    }

    get affiliationMappingFields(){
        if (!this.wiredAfflMappingFields.data){
            return null;
        }
        return this.wiredAfflMappingFields.data.fieldSelectOptions;
    }

    handleComboboxChange(event) {
        this.selectedComboBoxValue = event.detail.value;

        this.dispatchEvent(new CustomEvent('picklistitemselected', {
            detail: {selectedItem: this.selectedComboBoxValue}
        }));
    }
}