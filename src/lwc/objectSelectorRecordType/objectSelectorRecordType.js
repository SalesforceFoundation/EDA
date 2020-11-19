import { LightningElement, api, wire } from 'lwc';
import getAccountRecordTypes from '@salesforce/apex/CTRL_AffiliationMappings.getAccountRecordTypes';

export default class ObjectSelectorRecordType extends LightningElement {

    @api comboBoxLabel;
    @api comboBoxPlaceholder;

    @wire(getAccountRecordTypes, {}) wiredRecordTypes;

    get comboboxOptionsForRecordTypes(){
        if (!this.wiredRecordTypes.data){
            return null;
        }

        return this.wiredRecordTypes.data.fieldSelectOptions;

    }

    handleComboboxChange(event) {
        this.selectedComboBoxValue = event.detail.value;

        this.dispatchEvent(new CustomEvent('picklistitemselected', {
            detail: {selectedItem: this.selectedComboBoxValue}
        }));
    }
}