import { LightningElement, api, wire, track } from "lwc";
import { refreshApex } from "@salesforce/apex";

import getAffiliationsSettingsVModel from "@salesforce/apex/AffiliationsSettingsController.getAffiliationsSettingsVModel";

import stgAffiliationsSettingsTitle from "@salesforce/label/c.stgAffiliationsSettingsTitle";
import afflTypeEnforced from "@salesforce/label/c.afflTypeEnforced";
import afflTypeEnforcedDescription from "@salesforce/label/c.afflTypeEnforcedDescription";
import primaryAffiliationsDescription from "@salesforce/label/c.AfflMappingsDescription";
import editAction from "@salesforce/label/c.stgBtnEdit";
import accountRecordTypeColumn from "@salesforce/label/c.stgColAccountRecordType";
import contactFieldColumn from "@salesforce/label/c.stgColContactPrimaryAfflField";
import primaryAffiliationsTitle from "@salesforce/label/c.stgTabAfflMappings";

export default class affiliationSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    @track affiliationsSettingsViewModel;
    @track affiliationsSettingsWireResult;

    labelReference = {
        stgAffiliationsSettingsTitle: stgAffiliationsSettingsTitle,
        afflTypeEnforced: afflTypeEnforced,
        afflTypeEnforcedDescription: afflTypeEnforcedDescription,
        primaryAffiliationsTitle,
        primaryAffiliationsDescription,
        accountRecordTypeColumn,
        contactFieldColumn,
        editAction,
    };

    inputAttributeReference = {
        recordTypeValidation: "recordTypeValidation",
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

    @wire(getAffiliationsSettingsVModel)
    affiliationsSettingsViewModelWire(result) {
        this.affiliationsSettingsWireResult = result;
        if (result.data) {
            this.affiliationsSettingsViewModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving accountmodelsettingsvmodel");
        }
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

    handleRecordtypeValidationChange(event) {
        let hierarchySettingsChange = {
            settingsType: "boolean",
            settingsName: "Affiliation_Record_Type_Enforced__c",
            settingsValue: event.detail.value,
        };
        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handlePrimaryAffiliationsRowAction(event) {
        const actionName = event.detail.action.name;
        const actionRow = event.detail.row;
        this.dispatchPrimaryAffiliationModalEvent(actionName, actionRow);
    }

    dispatchPrimaryAffiliationModalEvent(affiliationsAction, primaryAffiliation) {
        let affiliationsDetail = {
            affiliationsAction: affiliationsAction,
            mappingName: primaryAffiliation.mappingName,
            accountRecordType: primaryAffiliation.accountRecordTypeName,
            contactField: primaryAffiliation.contactFieldName,
        };

        let primaryAffiliationsModalRequestEvent = new CustomEvent("primaryaffiliationmodalrequest", {
            detail: affiliationsDetail,
            bubbles: true,
            composed: true,
        });

        this.dispatchEvent(primaryAffiliationsModalRequestEvent);
    }

    handleSettingsEditModeChange(event) {
        this.isEditMode = !event.detail;
        this.affordancesDisabledToggle = event.detail;
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

    handleSettingsSaveCancel(event) {
        this.refreshAllApex();
    }

    refreshAllApex() {
        Promise.all([
            refreshApex(this.affiliationsSettingsWireResult),
            refreshApex(this.primaryAffiliationsSettingsWireResult),
        ]).then(() => {
            this.template.querySelectorAll("c-settings-row-input").forEach((input) => {
                input.resetValue();
            });
        });
    }
}
