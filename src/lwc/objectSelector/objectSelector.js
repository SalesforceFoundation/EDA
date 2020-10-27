import { LightningElement, wire } from 'lwc';

import getFieldSelectOptions from '@salesforce/apex/CTRL_FieldSelectOption.getFieldSelectOptions';

import errorToast from 'c/toastHandler';

import errorCannotRetrieveData from '@salesforce/label/c.errorCannotRetrieveData';
import objectSelectComboboxLabel from '@salesforce/label/c.objectSelectComboboxLabel';
import objectSelectComboboxPlaceholder from '@salesforce/label/c.objectSelectComboboxPlaceholder';

export default class ObjectSelector extends LightningElement {
    value = 'settingsValue';

    //This can use an API to pull the information from the parent component
    @wire(getFieldSelectOptions, {
        apiNameList: ['Contact','Account'],
    }) viewModel;

    //This label reference object lets us embed labels
    labelReference = {
        comboboxLabel: objectSelectComboboxLabel,
        comboBoxPlaceHolder: objectSelectComboboxPlaceholder,
        error: errorCannotRetrieveData
    };

    get comboboxOptions() {
        if(!this.viewModel.data) {
            return null;
        }

        return this.viewModel.data.fieldSelectOptions;
    }

    //This would kick off a new event to a parent component.
    handleComboboxChange(event) {
        this.value = event.detail.value;
    }
}