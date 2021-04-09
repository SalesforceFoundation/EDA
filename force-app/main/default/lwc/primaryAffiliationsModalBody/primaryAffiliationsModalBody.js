import { LightningElement, api, track, wire } from "lwc";

import getAccountRecordTypeComboboxVModel from "@salesforce/apex/AffiliationsSettingsController.getAccountRecordTypeComboboxVModel";
import getContactAccountLookupFieldComboboxVModel from "@salesforce/apex/AffiliationsSettingsController.getContactAccountLookupFieldComboboxVModel";

import stgApiNameLabel from "@salesforce/label/c.stgApiNameLabel";
import stgColAccountRecordType from "@salesforce/label/c.stgColAccountRecordType";
import stgColContactPrimaryAfflField from "@salesforce/label/c.stgColContactPrimaryAfflField";
import stgOptSelect from "@salesforce/label/c.stgOptSelect";
import stgAffiliationsEditModalBody from "@salesforce/label/c.stgAffiliationsEditModalBody";
import stgAffiliationsNewModalBody from "@salesforce/label/c.stgAffiliationsNewModalBody";
import stgTellMeMoreLink from "@salesforce/label/c.stgTellMeMoreLink";

export default class PrimaryAffiliationsModalBody extends LightningElement {
    @api affiliationsAction;
    @api accountRecordType;
    @api contactField;

    @track accountRecordTypeComboboxVModel;
    @track accountRecordTypeComboboxWireResult;

    @track contactAccountLookupFieldComboboxVModel;
    @track contactAccountLookupFieldComboboxWireResult;

    labelReference = {
        accountRecordTypeCombobox: stgColAccountRecordType,
        apiNameDisplay: stgApiNameLabel,
        comboboxPlaceholderText: stgOptSelect,
        contactFieldCombobox: stgColContactPrimaryAfflField,
        modalBodyEditSave: stgAffiliationsEditModalBody,
        tellMeMoreLink: stgTellMeMoreLink,
        modalBodyCreate: stgAffiliationsNewModalBody,
    };

    affiliationsHyperLink =
        '<a href="https://powerofus.force.com/s/article/EDA-Configure-Affiliations-Settings">' +
        this.labelReference.tellMeMoreLink +
        "</a>";

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
        return this.labelReference.apiNameDisplay.replace("{0}", this.accountRecordTypeComboboxVModel.value);
    }

    get contactFieldApiNameLabel() {
        return this.labelReference.apiNameDisplay.replace("{0}", this.contactAccountLookupFieldComboboxVModel.value);
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

    get affiliationsDesc() {
        if (this.affiliationsAction === "edit") {
            return this.labelReference.modalBodyEditSave + " " + this.affiliationsHyperLink;
        }
        if (this.affiliationsAction === "create") {
            return this.labelReference.modalBodyCreate + " " + this.affiliationsHyperLink;
        }
    }
}
