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
    @api autoEnrollmentMappingStatus;
    @api autoEnrollmentMappingRole;

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
        autoEnrollmentMappingStatus: "autoEnrollmentMappingStatus",
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
        autoEnrollmentMappingStatus: "$autoProgramEnrollmentStatus",
    })
    autoEnrollmentMappingStatusComboboxVModelWire(result) {
        console.log("hello");

        this.autoEnrollmentMappingStatusComboboxVModelWireResult = result;

        if (result.data) {
            this.autoEnrollmentMappingStatusComboboxVModel = result.data;
        } else if (result.error) {
            console.log("error retrieving autoEnrollmentMappingStatusComboboxVModel");
        }
    }

    get modifyRecords() {
        return this.actionName === "edit" || this.actionName === "create";
    }

    handleAutoEnrollmentMappingStatusChange(event) {
        //this.dispatchAutoEnrollmentMappingStatusChangeEvent(event.detail.value);
    }

    dispatchAutoEnrollmentMappingStatusChangeEvent(autoEnrollmentMappingStatus) {
        const autoEnrollmentMappingStatusDetails = {
            autoEnrollmentMappingStatus: autoEnrollmentMappingStatus,
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
