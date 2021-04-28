import { LightningElement, api, track, wire } from "lwc";
import stgColAccountRecordType from "@salesforce/label/c.stgColAccountRecordType";
import stgOptSelect from "@salesforce/label/c.stgOptSelect";
import stgAffiliationsEditModalBody from "@salesforce/label/c.stgAffiliationsEditModalBody";
import stgApiNameLabel from "@salesforce/label/c.stgApiNameLabel";

import getAccountRecordTypeComboboxVModel from "@salesforce/apex/ProgramSettingsController.getAccountRecordTypeComboboxVModel";

export default class autoEnrollmentMappingModalBody extends LightningElement {
    @api actionName;
    @api accountRecordType;
    @api autoEnrollmentEnabledStatus;
    @api autoEnrollmentEnabledRole;

    @track accountRecordTypeComboboxVModel;
    @track accountRecordTypeComboboxWireResult;

    labelReference = {
        accountRecordTypeCombobox: stgColAccountRecordType,
        comboboxPlaceholderText: stgOptSelect,
        modalBodyEdit: stgAffiliationsEditModalBody,
        apiNameDisplay: stgApiNameLabel,
    };

    inputAttributeReference = {
        accountRecordType: "primaryAffiliationsAccountRecordType",
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

    get modifyRecords() {
        return this.actionName === "edit" || this.actionName === "create";
    }

    get accountRecordTypeApiNameLabel() {
        return this.labelReference.apiNameDisplay.replace("{0}", this.accountRecordTypeComboboxVModel.value);
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

    get autoEnrollmentMappingModalDesc() {
        switch (this.actionName) {
            case "edit":
                return this.labelReference.modalBodyEdit;

            case "create":
                return this.labelReference.modalBodyCreate;
        }
    }
}
