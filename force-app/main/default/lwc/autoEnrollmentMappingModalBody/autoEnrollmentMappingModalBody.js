import { LightningElement, api, track, wire } from "lwc";
import stgColAccountRecordType from "@salesforce/label/c.stgColAccountRecordType";
import stgOptSelect from "@salesforce/label/c.stgOptSelect";
import stgAffiliationsEditModalBody from "@salesforce/label/c.stgAffiliationsEditModalBody";
import stgApiNameLabel from "@salesforce/label/c.stgApiNameLabel";

import getAutoEnrollmentMappingStatusComboboxVModel from "@salesforce/apex/ProgramSettingsController.getAutoEnrollmentMappingStatusComboboxVModel";
import getAutoEnrollmentMappingRoleComboboxVModel from "@salesforce/apex/ProgramSettingsController.getAutoEnrollmentMappingRoleComboboxVModel";

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
        autoProgramEnrollmentStatus: "autoProgramEnrollmentStatus",
        autoProgramEnrollmentRole: "autoProgramEnrollmentRole",
    };

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

    @wire(getAutoEnrollmentMappingRoleComboboxVModel, {
        autoProgramEnrollmentRole: "$autoProgramEnrollmentRole",
    })
    autoEnrollmentMappingRoleComboboxVModelWire(result) {
        this.autoEnrollmentMappingRoleComboboxVModelWireResult = result;

        if (result.data) {
            this.autoEnrollmentMappingRoleComboboxVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving autoEnrollmentMappingStatusComboboxVModel");
        }
    }

    get modifyRecords() {
        return this.actionName === "edit" || this.actionName === "create";
    }

    handleAutoEnrollmentMappingStatusChange(event) {
        this.dispatchAutoEnrollmentMappingStatusChangeEvent(event.detail.value);
    }

    dispatchAutoEnrollmentMappingStatusChangeEvent(autoProgramEnrollmentStatus) {
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

    handleAutoEnrollmentMappingRoleChange(event) {
        this.dispatchAutoEnrollmentMappingRoleChangeEvent(event.detail.value);
    }

    dispatchAutoEnrollmentMappingRoleChangeEvent(autoProgramEnrollmentRole) {
        const autoEnrollmentMappingRoleDetails = {
            autoProgramEnrollmentRole: autoProgramEnrollmentRole,
        };

        const autoEnrollmentMappingRoleChangeEvent = new CustomEvent("autoenrollmentmappingrolechange", {
            detail: autoEnrollmentMappingRoleDetails,
            bubbles: true,
            composed: true,
        });

        this.dispatchEvent(autoEnrollmentMappingRoleChangeEvent);
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
