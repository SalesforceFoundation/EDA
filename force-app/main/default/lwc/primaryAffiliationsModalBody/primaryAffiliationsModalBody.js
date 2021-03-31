import { LightningElement, api, track, wire } from "lwc";

import getAccountRecordTypeComboboxVModel from "@salesforce/apex/AffiliationsSettingsController.getAccountRecordTypeComboboxVModel";
import getContactAccountLookupFieldComboboxVModel from "@salesforce/apex/AffiliationsSettingsController.getContactAccountLookupFieldComboboxVModel";

import apiNameDisplay from "@salesforce/label/c.stgApiNameLabel";
import accountRecordTypeCombobox from "@salesforce/label/c.stgColAccountRecordType";
import contactFieldCombobox from "@salesforce/label/c.stgColContactPrimaryAfflField";
import comboboxPlaceholderText from "@salesforce/label/c.stgOptSelect";
import modalBodyEditSave from "@salesforce/label/c.stgAffiliationsEditModalBody";

export default class PrimaryAffiliationsModalBody extends LightningElement {
    @api affiliationsAction;
    @api accountRecordType;
    @api contactField;

    @track accountRecordTypeComboboxVModel;
    @track accountRecordTypeComboboxWireResult;

    @track contactAccountLookupFieldComboboxVModel;
    @track contactAccountLookupFieldComboboxWireResult;

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

    @wire(getAccountRecordTypeComboboxVModel, {
        recordTypeToCheck: "$accountRecordType",
    })
    accountRecordTypeComboboxVModelWire(result) {
        this.accountRecordTypeComboboxWireResult = result;

        if (result.data) {
            this.accountRecordTypeComboboxVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving preferredContactInfoSettingsVModel");
        }
    }

    @wire(getContactAccountLookupFieldComboboxVModel, {
        contactFieldToCheck: "$contactField",
    })
    contactAccountLookupFieldComboboxVModelWire(result) {
        this.contactAccountLookupFieldComboboxWireResult = result;

        if (result.data) {
            this.contactAccountLookupFieldComboboxVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving preferredContactInfoSettingsVModel");
        }
    }

    get modifyRecords() {
        return this.affiliationsAction === "edit" || this.affiliationsAction === "create";
    }

    get accountRecordTypeApiNameLabel() {
        return this.labelReference.apiNameDisplay.replace("{0}", this.accountRecordType);
    }

    get contactFieldApiNameLabel() {
        return this.labelReference.apiNameDisplay.replace("{0}", this.contactField);
    }

    handleAccountRecordTypeChange(event) {
        this.dispatchAccountRecordTypeChangeEvent(event.detail.value);
    }

    dispatchAccountRecordTypeChangeEvent(accountRecordType) {
        const accountRecordTypeDetails = {
            accountRecordType: accountRecordType,
        };

        const accountRecordTypeChangeEvent = new CustomEvent("accountrecordtypechange", {
            detail: accountRecordTypeDetails,
            bubbles: true,
            composed: true,
        });

        this.dispatchEvent(accountRecordTypeChangeEvent);
    }

    handleContactFieldChange(event) {
        this.dispatchContactFieldChangeEvent(event.detail.value);
    }

    dispatchContactFieldChangeEvent(contactField) {
        const contactFieldDetails = {
            contactField: contactField,
        };

        const contactFieldChangeEvent = new CustomEvent("contactfieldchange", {
            detail: contactFieldDetails,
            bubbles: true,
            composed: true,
        });

        this.dispatchEvent(contactFieldChangeEvent);
    }
}
