import { LightningElement, wire, api } from 'lwc';

import getActivePickListOptions from '@salesforce/apex/CTRL_PicklistFieldEntry.getActivePickListOptions';

import errorToast from 'c/toastHandler';

import errorCannotRetrieveData from '@salesforce/label/c.errorCannotRetrieveData';

export default class ObjectSelector extends LightningElement {
    // parameters will be passed in from the parent component
    @api objectApiName;
    @api fieldApiName;
    @api comboBoxLabel;
    @api comboBoxPlaceholder;

    selectedComboBoxValue = 'settingsValue';

    // load picklist field options based on object and field API names
    @wire(getActivePickListOptions, {
        objectAPIName: '$objectApiName', 
        fieldAPIName: '$fieldApiName',
    }) wiredPicklistViewModel;

    get comboboxOptions() {
        if(!this.wiredPicklistViewModel.data) {
            return null;
        }

        return this.wiredPicklistViewModel.data.fieldSelectOptions;
    }

    //pass the selected combobox value to the parent component
    handleComboboxChange(event) {
        this.selectedComboBoxValue = event.detail.value;

        this.dispatchEvent(new CustomEvent('picklistitemselected', {
            detail: {selectedItem: this.selectedComboBoxValue}
        }));
    }
}