import { LightningElement, api } from "lwc";

import apiNameDisplay from "@salesforce/label/c.stgApiNameLabel";
import accountRecordTypeCombobox from "@salesforce/label/c.stgColAccountRecordType";
import contactFieldCombobox from "@salesforce/label/c.stgColContactPrimaryAfflField";
import comboboxPlaceholderText from "@salesforce/label/c.stgOptSelect";
import modalBodyEditSave from "@salesforce/label/c.stgAffiliationsEditModalBody";

export default class PrimaryAffiliationsModalBody extends LightningElement {
    @api affiliationsAction;
    @api accountRecordType;
    @api contactField;

    accountRecordTypeComboboxVModel = {
        options: [{ label: "test", value: "example" }],
        value: this.accountRecordType,
    };

    contactFieldComboboxVModel = {
        options: [{ label: "test", value: "example" }],
        value: this.contactField,
    };

    labelReference = {
        accountRecordTypeCombobox,
        apiNameDisplay,
        comboboxPlaceholderText,
        contactFieldCombobox,
        modalBodyEditSave,
    };

    inputAttributeReference = {
        accountRecordType: "primaryAffiliationsAccountRecordType",
        contactField: "primaryAffiliationsContactField",
    };

    get modifyRecords() {
        return this.affiliationsAction === "edit" || this.affiliationsAction === "create";
    }

    get accountRecordTypeApiNameLabel() {
        return this.labelReference.apiNameDisplay.replace("{0}", this.accountRecordType);
    }
    /*
    get contactFieldApiNameLabel() {
        return this.labelReference.apiNameDisplay.replace("{0}", this.contactField);
    }*/
}
