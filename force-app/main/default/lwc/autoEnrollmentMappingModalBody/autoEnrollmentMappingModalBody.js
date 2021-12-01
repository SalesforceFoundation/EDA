import { LightningElement, api, track, wire } from "lwc";
//labels
import stgColAccountRecordType from "@salesforce/label/c.stgColAccountRecordType";
import stgColAutoEnrollmentStatus from "@salesforce/label/c.stgColAutoEnrollmentStatus";
import stgColAutoEnrollmentRole from "@salesforce/label/c.stgColAutoEnrollmentRole";
import stgOptSelect from "@salesforce/label/c.stgOptSelect";
import stgAutoEnrollmentEditModalBody from "@salesforce/label/c.stgAutoEnrollmentEditModalBody";
import stgApiNameLabel from "@salesforce/label/c.stgApiNameLabel";
import stgTellMeMoreLink from "@salesforce/label/c.stgTellMeMoreLink";
import stgAutoEnrollmentNewModalBody from "@salesforce/label/c.stgAutoEnrollmentNewModalBody";
import stgAccountRecordTypeHelp from "@salesforce/label/c.stgAccountRecordTypeHelp";
import stgAutoEnrollmentDeleteModalBody from "@salesforce/label/c.stgAutoEnrollmentDeleteModalBody";
//apex
import getAccountRecordTypeComboboxVModel from "@salesforce/apex/ProgramSettingsController.getAccountRecordTypeComboboxVModel";
import getAutoEnrollmentMappingStatusComboboxVModel from "@salesforce/apex/ProgramSettingsController.getAutoEnrollmentMappingStatusComboboxVModel";
import getAutoEnrollmentMappingRoleComboboxVModel from "@salesforce/apex/ProgramSettingsController.getAutoEnrollmentMappingRoleComboboxVModel";

export default class autoEnrollmentMappingModalBody extends LightningElement {
    @api actionName;
    @api oldAccountRecordType;
    @api newAccountRecordType;
    @api autoProgramEnrollmentStatus;
    @api autoProgramEnrollmentRole;

    @track accountRecordTypeComboboxVModel;
    @track accountRecordTypeComboboxWireResult;

    @track autoEnrollmentMappingStatusComboboxVModel;
    @track autoEnrollmentMappingStatusComboboxVModelWireResult;

    @track autoEnrollmentMappingRoleComboboxVModel;
    @track autoEnrollmentMappingRoleComboboxVModelWireResult;

    labelReference = {
        accountRecordTypeCombobox: stgColAccountRecordType,
        statusCombobox: stgColAutoEnrollmentStatus,
        roleCombobox: stgColAutoEnrollmentRole,
        comboboxPlaceholderText: stgOptSelect,
        modalBodyEdit: stgAutoEnrollmentEditModalBody,
        modalBodyCreate: stgAutoEnrollmentNewModalBody,
        modalBodyDelete: stgAutoEnrollmentDeleteModalBody,
        apiNameDisplay: stgApiNameLabel,
        tellMeMoreLink: stgTellMeMoreLink,
        stgAccountRecordTypeHelp: stgAccountRecordTypeHelp,
    };

    inputAttributeReference = {
        accountRecordType: "accountRecordType",
        autoProgramEnrollmentStatus: "autoProgramEnrollmentStatus",
        autoProgramEnrollmentRole: "autoProgramEnrollmentRole",
    };

    connectedCallback(){
        getAccountRecordTypeComboboxVModel({ accountRecordType: this.newAccountRecordType })
        .then((result) => {
            this.accountRecordTypeComboboxVModel = result;
        })
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

    handleAccountRecordTypeChange(event) {
        this.accountRecordTypeComboboxVModel.value = event.detail.value;
        this.dispatchAccountRecordTypeChangeEvent(event.detail.value);
    }

    dispatchAccountRecordTypeChangeEvent(newAccountRecordType) {
        const accountRecordTypeDetails = {
            newAccountRecordType: newAccountRecordType,
        };

        const accountRecordTypeChangeEvent = new CustomEvent("autoenrollmentmappingaccountrecordtypechange", {
            detail: accountRecordTypeDetails,
            bubbles: true,
            composed: true,
        });

        this.dispatchEvent(accountRecordTypeChangeEvent);
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
                return this.labelReference.modalBodyEdit + " " + this.autoEnrollmentHyperLink;

            case "create":
                return this.labelReference.modalBodyCreate + " " + this.autoEnrollmentHyperLink;

            case "delete":
                return this.labelReference.modalBodyDelete
                    .replace("{0}", this.oldAccountRecordType)
                    .replace("{1}", this.autoProgramEnrollmentStatus)
                    .replace("{2}", this.autoProgramEnrollmentRole);
        }
    }

    get modifyRecords() {
        return this.actionName === "edit" || this.actionName === "create";
    }

    get deleteRecords() {
        return this.actionName === "delete";
    }

    get autoEnrollmentHyperLink() {
        return (
            '<a href="https://powerofus.force.com/EDA-Configure-Affiliations-Settings">' +
            this.labelReference.tellMeMoreLink +
            "</a>"
        );
    }

    get accountRecordTypeApiNameLabel() {
        return this.labelReference.apiNameDisplay.replace("{0}", this.accountRecordTypeComboboxVModel.value);
    }
}
