import { LightningElement, api, track, wire } from "lwc";

import primaryAffiliationsDescription from "@salesforce/label/c.AfflMappingsDescription";
import editAction from "@salesforce/label/c.stgBtnEdit";
import accountRecordTypeColumn from "@salesforce/label/c.stgColAccountRecordType";
import contactFieldColumn from "@salesforce/label/c.stgColContactPrimaryAfflField";
import primaryAffiliationsTitle from "@salesforce/label/c.stgTabAfflMappings";
export default class AffiliationsSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    @track primaryAffiliationsSettingsWireResult;
    @track primaryAffiliationsSettingsVModel;
    @track showPreferredPhoneEnforcement;

    labelReference = {
        primaryAffiliationsTitle,
        primaryAffiliationsDescription,
        accountRecordTypeColumn,
        contactFieldColumn,
        editAction,
    };

    inputAttributeReference = {
        affiliationsTableId: "TODO",
    };

    get affordancesDisabled() {
        if (!this.isEditMode || this.affordancesDisabledToggle === true) {
            return true;
        }
        return undefined;
    }

    get columns() {
        return [
            { label: this.labelReference.accountRecordTypeColumn, fieldName: "accountRecordTypeLabel" },
            { label: this.labelReference.contactFieldColumn, fieldName: "contactFieldLabel" },
            {
                type: "action",
                typeAttributes: { rowActions: [{ label: this.labelReference.editAction, name: "edit" }] },
            },
        ];
    }

    get data() {
        return [
            {
                mappingName: "item1",
                accountRecordTypeName: "Academic_Program",
                accountRecordTypeLabel: "Academic Program",
                contactFieldName: "Primary_Academic_Program__c",
                contactFieldLabel: "Primary Academic Program",
            },
        ];
    }

    /*@wire(getPrimaryAffiliationsSettingsVModel)
    primaryAffiliationsSettingsVModelWire(result) {
        this.primaryAffiliationsSettingsWireResult = result;

        if (result.data) {
            this.primaryAffiliationsSettingsVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving preferredContactInfoSettingsVModel");
        }
    }*/

    handleSettingsEditModeChange(event) {
        this.isEditMode = !event.detail;
        this.affordancesDisabledToggle = event.detail;
    }

    handleSettingsSaveCancel(event) {
        this.refreshAllApex();
    }

    handleSettingsSaving(event) {
        this.affordancesDisabledToggle = true;
        // TODO: perform client side validation

        // if validation fails, call this.handleValidationFailure()
        //this.template.querySelector("c-settings-save-canvas").handleValidationFailure();

        // else, update hierarchy settings
        this.template.querySelector("c-settings-save-canvas").updateHierarchySettings();
    }

    handleSettingsSaveCompleted(event) {
        this.affordancesDisabledToggle = false;
        this.refreshAllApex();
    }

    handlePrimaryAffiliationsRowAction(event) {
        const actionName = event.detail.action.name;
        const actionRow = event.detail.row;
        this.dispatchPrimaryAffiliationModalEvent(actionName, actionRow);
    }

    dispatchPrimaryAffiliationModalEvent(eventAction, primaryAffiliation) {
        const eventDetail = {
            action: eventAction,
            mappingName: primaryAffiliation.mappingName,
            accountRecordTypeLabel: primaryAffiliation.accountRecordTypeLabel,
            accountRecordTypeName: primaryAffiliation.accountRecordTypeName,
            contactFieldLabel: primaryAffiliation.contactFieldLabel,
            contactFieldName: primaryAffiliation.contactFieldName,
        };
        this.dispatchEvent(
            new CustomEvent("primaryaffiliationmodalrequest", {
                detail: eventDetail,
                bubbles: true,
                composed: true,
            })
        );
    }

    refreshAllApex() {
        Promise.all([refreshApex(this.primaryAffiliationsSettingsWireResult)]).then(() => {});
    }
}
