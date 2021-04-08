import { LightningElement, api, wire, track } from "lwc";
import { refreshApex } from "@salesforce/apex";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getAffiliationsSettingsVModel from "@salesforce/apex/AffiliationsSettingsController.getAffiliationsSettingsVModel";
import getPrimaryAffiliationsSettingsVModel from "@salesforce/apex/AffiliationsSettingsController.getPrimaryAffiliationsSettingsVModel";
import updateAffiliationMappings from "@salesforce/apex/AffiliationsSettingsController.updateAffiliationMappings";

import stgAffiliationsSettingsTitle from "@salesforce/label/c.stgAffiliationsSettingsTitle";
import afflTypeEnforced from "@salesforce/label/c.afflTypeEnforced";
import afflTypeEnforcedDescription from "@salesforce/label/c.afflTypeEnforcedDescription";
import AfflMappingsDescription from "@salesforce/label/c.AfflMappingsDescription";
import stgBtnEdit from "@salesforce/label/c.stgBtnEdit";
import stgColAccountRecordType from "@salesforce/label/c.stgColAccountRecordType";
import stgColContactPrimaryAfflField from "@salesforce/label/c.stgColContactPrimaryAfflField";
import stgTabAfflMappings from "@salesforce/label/c.stgTabAfflMappings";
import stgAffiliationsEditSuccess from "@salesforce/label/c.stgAffiliationsEditSuccess";
import stgTellMeMoreLink from "@salesforce/label/c.stgTellMeMoreLink";

export default class affiliationSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    @track affiliationsSettingsViewModel;
    @track affiliationsSettingsWireResult;

    @track primaryAffiliationsSettingsVModel;
    @track primaryAffiliationsSettingsWireResult;

    labelReference = {
        afflTypeEnforced: afflTypeEnforced,
        afflTypeEnforcedDescription: afflTypeEnforcedDescription,
        stgAffiliationsSettingsTitle: stgAffiliationsSettingsTitle,
        primaryAffiliationMappingsTable: {
            accountRecordTypeColumn: stgColAccountRecordType,
            contactFieldColumn: stgColContactPrimaryAfflField,
            editAction: stgBtnEdit,
            primaryAffiliationsDescription: AfflMappingsDescription,
            primaryAffiliationsTitle: stgTabAfflMappings,
        },
        successMessage: stgAffiliationsEditSuccess,
        tellMeMoreLink: stgTellMeMoreLink,
    };

    affiliationsHyperLink =
        '<a href="https://powerofus.force.com/s/article/EDA-Configure-Affiliations-Settings">' +
        this.labelReference.tellMeMoreLink +
        "</a>";

    inputAttributeReference = {
        recordTypeValidation: "recordTypeValidation",
        affiliationMappings: "affiliationMappings",
    };

    get affordancesDisabled() {
        if (!this.isEditMode || this.affordancesDisabledToggle === true) {
            return true;
        }
        return undefined;
    }

    get primaryAffiliationMappingsTableColumns() {
        return [
            {
                label: this.labelReference.primaryAffiliationMappingsTable.accountRecordTypeColumn,
                fieldName: "accountRecordTypeLabel",
            },
            {
                label: this.labelReference.primaryAffiliationMappingsTable.contactFieldColumn,
                fieldName: "contactFieldLabel",
            },
            {
                type: "action",
                typeAttributes: {
                    rowActions: [
                        { label: this.labelReference.primaryAffiliationMappingsTable.editAction, name: "edit" },
                    ],
                },
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

    @wire(getPrimaryAffiliationsSettingsVModel)
    primaryAffiliationsSettingsVModelWire(result) {
        this.primaryAffiliationsSettingsWireResult = result;

        if (result.data) {
            this.primaryAffiliationsSettingsVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving preferredContactInfoSettingsVModel");
        }
    }

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
        this.dispatchPrimaryAffiliationModalRequestEvent(actionName, actionRow);
    }

    dispatchPrimaryAffiliationModalRequestEvent(affiliationsAction, primaryAffiliation) {
        const affiliationsDetail = {
            affiliationsAction: affiliationsAction,
            mappingName: primaryAffiliation.mappingName,
            accountRecordType: primaryAffiliation.accountRecordTypeName,
            contactField: primaryAffiliation.contactFieldName,
        };

        const primaryAffiliationsModalRequestEvent = new CustomEvent("primaryaffiliationmodalrequest", {
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

    @api modalSave(saveModel) {
        switch (saveModel.action) {
            case "edit":
                this.updateAffiliation(saveModel.mappingName, saveModel.accountRecordType, saveModel.contactField);
                break;
        }
    }

    updateAffiliation(mappingName, accountRecordType, contactField) {
        updateAffiliationMappings({
            mappingName: mappingName,
            accRecordType: accountRecordType,
            conPrimaryAfflField: contactField,
        })
            .then((result) => {
                this.showToast("success", "Save Complete", this.labelReference.successMessage.replace("{0}", result));
            })

            .catch((error) => {
                // console.log('Inside error');
            });
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

    showToast(toastType, toastTitle, toastMessage) {
        const showToastEvent = new ShowToastEvent({
            title: toastTitle,
            message: toastMessage,
            variant: toastType,
            mode: "dismissable",
        });
        this.dispatchEvent(showToastEvent);
    }

    get affiliationsDesc() {
        return (
            this.labelReference.primaryAffiliationMappingsTable.primaryAffiliationsDescription +
            " " +
            this.affiliationsHyperLink
        );
    }
}
