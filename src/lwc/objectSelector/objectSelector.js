import { LightningElement, wire, api } from 'lwc';

//import getFieldSelectOptions from '@salesforce/apex/CTRL_FieldSelectOption.getFieldSelectOptions';
import getPickListOptions from '@salesforce/apex/CTRL_FieldSelectOption.getPickListOptions';

import errorToast from 'c/toastHandler';

import errorCannotRetrieveData from '@salesforce/label/c.errorCannotRetrieveData';
import objectSelectComboboxLabel from '@salesforce/label/c.objectSelectComboboxLabel';
import objectSelectComboboxPlaceholder from '@salesforce/label/c.objectSelectComboboxPlaceholder';

export default class ObjectSelector extends LightningElement {
    // parameters will be passed in from the parent component - hardcoding for testing only
    @api objectAPIName = 'Contact';
    @api fieldAPIName = 'Country_of_Origin__c';

    value = 'settingsValue';

    // load picklist field options based on object and field API names
    @wire(getPickListOptions, {
        objectAPIName: '$objectAPIName', 
        fieldAPIName: '$fieldAPIName',
    }) wiredPicklistViewModel;
        // ({ error, data}){
        //     if (data){
        //         console.log('picklist values successfully retrieved! Data retrieved: ' + JSON.stringify(data));
        //         //TODO: populate picklistItemsList with values retrieved from data
        //     } else if (error){
        //         console.log('error retrieving picklist values');
        //     }
        // };

    //This can use an API to pull the information from the parent component
    //@wire(getFieldSelectOptions, {apiNameList: ['Contact']}) viewModel;

    //This label reference object lets us embed labels
    labelReference = {
        comboboxLabel: objectSelectComboboxLabel,
        comboBoxPlaceHolder: objectSelectComboboxPlaceholder,
        error: errorCannotRetrieveData
    };

    get comboboxOptions() {
        console.log('Getting picklist for object....... ');

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

    //This would kick off a new event to a parent component.
    handleComboboxChange(event) {
        this.value = event.detail.value;
    }
}