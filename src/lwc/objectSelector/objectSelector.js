import { LightningElement, wire, api } from 'lwc';

//import getFieldSelectOptions from '@salesforce/apex/CTRL_FieldSelectOption.getFieldSelectOptions';
import getPickListOptions from '@salesforce/apex/CTRL_FieldSelectOption.getPickListOptions';

import errorToast from 'c/toastHandler';

import errorCannotRetrieveData from '@salesforce/label/c.errorCannotRetrieveData';
import objectSelectComboboxLabel from '@salesforce/label/c.objectSelectComboboxLabel';
import objectSelectComboboxPlaceholder from '@salesforce/label/c.objectSelectComboboxPlaceholder';

export default class ObjectSelector extends LightningElement {
    // parameters will be passed in from the parent component - hardcoding for testing only
    @api objectApiName = 'Contact';
    @api fieldApiName = 'Country_of_Origin__c';

    selectedComboBoxValue = 'settingsValue';

    // load picklist field options based on object and field API names
    @wire(getPickListOptions, {
        objectAPIName: '$objectApiName', 
        fieldAPIName: '$fieldApiName',
    }) wiredPicklistViewModel;
        // ({ error, data}){
        //     if (data){
        //         console.log('picklist values successfully retrieved! Data retrieved: ' + JSON.stringify(data));
        //         //TODO: populate picklistItemsList with values retrieved from data
        //     } else if (error){
        //         console.log('error retrieving picklist values');
        //     }
        // };

    //This label reference object lets us embed labels
    labelReference = {
        comboboxLabel: objectSelectComboboxLabel,
        comboBoxPlaceHolder: objectSelectComboboxPlaceholder,
        error: errorCannotRetrieveData
    };

    get comboboxOptions() {
        if(!this.wiredPicklistViewModel.data) {
            return null;
        }

        return this.wiredPicklistViewModel.data.fieldSelectOptions;

        // let fieldSelectModels = data[0].fieldSelectOptions;
        // for (i=0; i<fieldSelectModels.length; i++){
        //     console.log('picklist field name: ' + fieldSelectModels[i].value);
        // }

        // if (!this.wiredPicklistViewModel.data){
        //     console.log('wiredPicklistViewModel null');
        // }

        // return this.wiredPicklistViewModel.data.fieldSelectOptions;
    }

    //pass the selected combobox value to the parent component
    handleComboboxChange(event) {
        this.selectedComboBoxValue = event.detail.value;

        this.dispatchEvent(new CustomEvent('picklistitemselected', {
            detail: {selectedItem: this.selectedComboBoxValue}
        }));
    }
}