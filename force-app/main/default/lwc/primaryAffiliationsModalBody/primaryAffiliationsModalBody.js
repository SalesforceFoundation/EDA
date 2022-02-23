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
import stgAffiliationsDeleteModalBody from "@salesforce/label/c.stgAffiliationsDeleteModalBody";
import stgAfflDeleteWithAutoEnrollment from "@salesforce/label/c.stgAfflDeleteWithAutoEnrollment";

export default class PrimaryAffiliationsModalBody extends LightningElement {
    @api affiliationsAction;
    @api accountRecordType;
    @api contactField;
    @api autoEnrollmentEnabled;

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
        modalBodyDelete: stgAffiliationsDeleteModalBody,
        modalBodyDeleteWithAutoEnrollment: stgAfflDeleteWithAutoEnrollment,
        tellMeMoreLink: stgTellMeMoreLink,
        modalBodyCreate: stgAffiliationsNewModalBody,
    };

    affiliationsHyperLink =
        '<a href="https://powerofus.force.com/EDA-Configure-Affiliations-Settings">' +
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
            //console.log("error retrieving accountRecordTypeComboboxVModel");
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

    get deleteRecords() {
        return this.affiliationsAction === "delete";
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
        switch (this.affiliationsAction) {
            case "edit":
                return this.labelReference.modalBodyEditSave + " " + this.affiliationsHyperLink;

            case "create":
                return this.labelReference.modalBodyCreate + " " + this.affiliationsHyperLink;
        }
    }

    get deleteWarning() {
        let deleteWarningText = this.labelReference.modalBodyDelete
            .replace("{0}", this.accountRecordType)
            .replace("{1}", this.contactField);

        if (!this.autoEnrollmentEnabled) {
            return deleteWarningText;
        }

        let autoEnrollmentDeleteWarningText =
            this.labelReference.modalBodyDeleteWithAutoEnrollment.replace("{0}", this.accountRecordType) + " ";

        return autoEnrollmentDeleteWarningText.concat(deleteWarningText);
    }
}
