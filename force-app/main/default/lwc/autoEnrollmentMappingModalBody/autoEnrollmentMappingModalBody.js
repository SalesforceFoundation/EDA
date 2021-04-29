import { LightningElement, api, track, wire } from "lwc";
import stgColAccountRecordType from "@salesforce/label/c.stgColAccountRecordType";
import stgOptSelect from "@salesforce/label/c.stgOptSelect";
import stgAffiliationsEditModalBody from "@salesforce/label/c.stgAffiliationsEditModalBody";
import stgApiNameLabel from "@salesforce/label/c.stgApiNameLabel";

import getAccountRecordTypeComboboxVModel from "@salesforce/apex/ProgramSettingsController.getAccountRecordTypeComboboxVModel";
import getAutoEnrollmentMappingStatusComboboxVModel from "@salesforce/apex/ProgramSettingsController.getAutoEnrollmentMappingStatusComboboxVModel";

export default class autoEnrollmentMappingModalBody extends LightningElement {
    @api actionName;
    @api accountRecordType;
    @api autoProgramEnrollmentStatus;
    @api autoProgramEnrollmentRole;

    @track accountRecordTypeComboboxVModel;
    @track accountRecordTypeComboboxWireResult;

    @track autoEnrollmentMappingStatusComboboxVModel;
    @track autoEnrollmentMappingStatusComboboxVModelWireResult;

    labelReference = {
        accountRecordTypeCombobox: stgColAccountRecordType,
        comboboxPlaceholderText: stgOptSelect,
        modalBodyEdit: stgAffiliationsEditModalBody,
        apiNameDisplay: stgApiNameLabel,
    };

    inputAttributeReference = {
        accountRecordType: "autoEnrollmentMappingAccountRecordType",
        autoProgramEnrollmentStatus: "autoProgramEnrollmentStatus",
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

    @wire(getAutoEnrollmentMappingStatusComboboxVModel, {
        autoProgramEnrollmentStatus: "$autoProgramEnrollmentStatus",
    })
    autoEnrollmentMappingStatusComboboxVModelWire(result) {
        this.autoEnrollmentMappingStatusComboboxVModelWireResult = result;

        if (result.data) {
            this.autoEnrollmentMappingStatusComboboxVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving autoEnrollmentMappingStatusComboboxVModel");
        }
    }

    get modifyRecords() {
        return this.actionName === "edit" || this.actionName === "create";
    }

    handleAutoEnrollmentMappingStatusChange(event) {
        console.log("body " + event.detail.value);
        this.dispatchAutoEnrollmentMappingStatusChangeEvent(event.detail.value);
    }

    dispatchAutoEnrollmentMappingStatusChangeEvent(autoProgramEnrollmentStatus) {
        console.log("body dispatch " + autoProgramEnrollmentStatus);
        const autoEnrollmentMappingStatusDetails = {
            autoProgramEnrollmentStatus: autoProgramEnrollmentStatus,
        };

        const autoEnrollmentMappingStatusChangeEvent = new CustomEvent("autoenrollmentmappingstatuschange", {
            detail: autoEnrollmentMappingStatusDetails,
            bubbles: true,
            composed: true,
        });

        this.dispatchEvent(autoEnrollmentMappingStatusChangeEvent);
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
