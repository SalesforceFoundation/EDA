import { LightningElement, wire, track, api } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

// Controllers
import getRelationshipSettingsVModel from "@salesforce/apex/RelationshipSettingsController.getRelationshipSettingsVModel";
import getRelationshipLookupsVModel from "@salesforce/apex/RelationshipSettingsController.getRelationshipLookupsVModel";
import updateRelationshipLookup from "@salesforce/apex/RelationshipSettingsController.updateRelationshipLookup";
import createRelationshipLookup from "@salesforce/apex/RelationshipSettingsController.createRelationshipLookup";
import deleteRelationshipLookup from "@salesforce/apex/RelationshipSettingsController.deleteRelationshipLookup";

// Reciprocal Method Custom Labels
import stgRelationshipSettingsTitle from "@salesforce/label/c.stgRelationshipSettingsNav";
import stgTitleReciMethod from "@salesforce/label/c.stgTitleReciMethod";
import stgHelpRelReciprocalMethod from "@salesforce/label/c.stgHelpRelReciprocalMethod";
import stgOptSelect from "@salesforce/label/c.stgOptSelect";
import stgTellMeMoreLink from "@salesforce/label/c.stgTellMeMoreLink";
// Allow Duplicates Custom Labels
import stgDuplicateRelationships from "@salesforce/label/c.stgDuplicateRelationships";
import stgDuplicateRelationshipsHelp from "@salesforce/label/c.stgDuplicateRelationshipsHelp";
// Reciprocal Relationship Mappings Labels
import stgTabReciprocalSettings from "@salesforce/label/c.stgTabReciprocalSettings";
import RelationshipsLookupDescription from "@salesforce/label/c.RelationshipsLookupDescription";
import stgBtnAddMapping from "@salesforce/label/c.stgBtnAddMapping";
import stgColRelationshipName from "@salesforce/label/c.stgColRelationshipName";
import stgColFemale from "@salesforce/label/c.stgColFemale";
import stgColMale from "@salesforce/label/c.stgColMale";
import stgColNeutral from "@salesforce/label/c.stgColNeutral";
import stgColActive from "@salesforce/label/c.stgColActive";
import stgBtnEdit from "@salesforce/label/c.stgBtnEdit";
import stgBtnDelete from "@salesforce/label/c.stgBtnDelete";
import stgReciprocalRelEditSuccess from "@salesforce/label/c.stgReciprocalRelEditSuccess";
import stgReciprocalRelNewSuccess from "@salesforce/label/c.stgReciprocalRelNewSuccess";
import stgReciprocalRelDeleteSuccess from "@salesforce/label/c.stgReciprocalRelDeleteSuccess";
import stgSuccess from "@salesforce/label/c.stgSuccess";

// Articles
const relationshipsArticle = '<a href="https://powerofus.force.com/EDA-Config-Relationships-Settings">';
export default class relationshipSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    @track relationshipSettingsVModel;
    @track relationshipSettingsWireResult;

    @track relationshipLookupsVModel;
    @track relationshipLookupsWireResult;

    labelReference = {
        stgRelationshipSettingsTitle: stgRelationshipSettingsTitle,
        reciprocalMethodSettingsName: stgTitleReciMethod,
        reciprocalMethodSettingsDesc: stgHelpRelReciprocalMethod,
        tellMeMore: stgTellMeMoreLink,
        comboboxPlaceholderText: stgOptSelect,
        duplicateRelationshipTitle: stgDuplicateRelationships,
        duplicateRelationshipDesc: stgDuplicateRelationshipsHelp,
        relationshipMappingsTitle: stgTabReciprocalSettings,
        relationshipMappingsDescription: RelationshipsLookupDescription,
        newButton: stgBtnAddMapping,
        newButtonA11y: stgBtnAddMapping,
        createSuccessMessage: stgReciprocalRelNewSuccess,
        editSuccessMessage: stgReciprocalRelEditSuccess,
        deleteSuccessMessage: stgReciprocalRelDeleteSuccess,
        successToast: stgSuccess,
        relationshipMappingsTable: {
            relationshipNameColumn: stgColRelationshipName,
            femaleValueColumn: stgColFemale,
            maleValueColumn: stgColMale,
            neutralValueColumn: stgColNeutral,
            isActiveColumn: stgColActive,
            editAction: stgBtnEdit,
            deleteAction: stgBtnDelete,
        },
    };

    inputAttributeReference = {
        defaultReciprocalComboboxId: "defaultReciprocalMethod",
        allowAutoCreatedDuplicatesId: "allowAutoCreatedDuplicates",
    };

    get relationshipSettingsHyperLink() {
        return relationshipsArticle + this.labelReference.tellMeMore + "</a>";
    }

    get relationshipSettingsDesc() {
        return this.labelReference.reciprocalMethodSettingsDesc + " " + this.relationshipSettingsHyperLink;
    }

    get duplicateRelationshipDesc() {
        return this.labelReference.duplicateRelationshipDesc + " " + this.relationshipSettingsHyperLink;
    }

    get affordancesDisabled() {
        if (!this.isEditMode || this.affordancesDisabledToggle === true) {
            return true;
        }
        return undefined;
    }

    @api
    handleSaveCanvasRender() {
        this.template.querySelector("c-settings-save-canvas").focusOnTitle();
    }

    @wire(getRelationshipSettingsVModel)
    relationshipSettingsVModelWire(result) {
        this.relationshipSettingsWireResult = result;
        if (result.data) {
            this.relationshipSettingsVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving accountModelSettingsVModel");
        }
    }

    handleReciprocalMethodChange(event) {
        // add updated setting to hierarchySettingsChanges object
        let hierarchySettingsChange = {
            settingsType: "string",
            settingsName: "Reciprocal_Method__c",
            settingsValue: event.detail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    // Save the inverse as UI display the inverse value of the settings
    handleAuoCreatedDuplicatesChange(event) {
        const eventDetail = event.detail;
        let hierarchySettingsChange = {
            settingsType: "boolean",
            settingsName: "Allow_AutoCreated_Duplicates__c",
            settingsValue: !eventDetail.value,
        };

        this.template.querySelector("c-settings-save-canvas").handleHierarchySettingsChange(hierarchySettingsChange);
    }

    handleSettingsEditModeChange(event) {
        this.isEditMode = !event.detail;
        this.affordancesDisabledToggle = event.detail;
    }

    handleSettingsSaving(event) {
        this.affordancesDisabledToggle = true;
        this.template.querySelector("c-settings-save-canvas").updateHierarchySettings();
    }

    handleSettingsSaveCancel(event) {
        this.refreshAllApex();
    }

    handleSettingsSaveCompleted(event) {
        this.affordancesDisabledToggle = false;
        this.refreshAllApex();
    }

    refreshAllApex() {
        Promise.all([
            refreshApex(this.relationshipSettingsWireResult),
            refreshApex(this.relationshipLookupsWireResult),
        ]).then(() => {
            this.template.querySelectorAll("c-settings-row-input").forEach((input) => {
                input.resetValue();
            });
        });
    }

    @wire(getRelationshipLookupsVModel)
    relationshipLookupsVModelWire(result) {
        this.relationshipLookupsWireResult = result;
        if (result.data) {
            this.relationshipLookupsVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving relationshipLookupsVModel");
        }
    }

    get relationshipMappingsTableColumns() {
        return [
            {
                label: this.labelReference.relationshipMappingsTable.relationshipNameColumn,
                fieldName: "name",
            },
            {
                label: this.labelReference.relationshipMappingsTable.femaleValueColumn,
                fieldName: "femaleValue",
            },
            {
                label: this.labelReference.relationshipMappingsTable.maleValueColumn,
                fieldName: "maleValue",
            },
            {
                label: this.labelReference.relationshipMappingsTable.neutralValueColumn,
                fieldName: "neutralValue",
            },
            {
                label: this.labelReference.relationshipMappingsTable.isActiveColumn,
                fieldName: "isActive",
                type: "boolean",
            },
            {
                type: "action",
                typeAttributes: {
                    rowActions: [
                        { label: this.labelReference.relationshipMappingsTable.editAction, name: "edit" },
                        { label: this.labelReference.relationshipMappingsTable.deleteAction, name: "delete" },
                    ],
                },
            },
        ];
    }

    handleNewRelationshipMappingClick(event) {
        const relationshipMappingDetail = {
            actionName: "create",
            relationshipMappingName: "",
            femaleValue: "",
            maleValue: "",
            neutralValue: "",
            isActive: true,
        };

        this.dispatchRelationshipMappingModalRequestEvent(relationshipMappingDetail);
    }

    handleRelationshipMappingRowAction(event) {
        const actionName = event.detail.action.name;
        const actionRow = event.detail.row;
        const relationshipMappingDetail = {
            actionName: actionName,
            relationshipMappingName: actionRow.name,
            femaleValue: actionRow.femaleValue,
            maleValue: actionRow.maleValue,
            neutralValue: actionRow.neutralValue,
            isActive: actionRow.isActive,
        };

        this.dispatchRelationshipMappingModalRequestEvent(relationshipMappingDetail);
    }

    dispatchRelationshipMappingModalRequestEvent(relationshipMappingDetail) {
        const relationshipMappingModalRequestEvent = new CustomEvent("relationshipmappingmodalrequest", {
            detail: relationshipMappingDetail,
            bubbles: true,
            composed: true,
        });

        this.dispatchEvent(relationshipMappingModalRequestEvent);
    }

    @api modalSave(saveModel) {
        switch (saveModel.action) {
            case "create":
                this.executeCreateRelationshipMapping(
                    saveModel.relationshipMappingName,
                    saveModel.femaleValue,
                    saveModel.maleValue,
                    saveModel.neutralValue,
                    saveModel.isActive
                );
                break;
            case "edit":
                this.executeUpdateRelationshipMappings(
                    saveModel.oldRelationshipMappingName,
                    saveModel.relationshipMappingName,
                    saveModel.femaleValue,
                    saveModel.maleValue,
                    saveModel.neutralValue,
                    saveModel.isActive
                );
                break;
            case "delete":
                this.executeDeleteRelationshipMappings(saveModel.relationshipMappingName);
                break;
        }
    }

    executeUpdateRelationshipMappings(
        oldRelationshipMappingName,
        relationshipMappingName,
        femaleValue,
        maleValue,
        neutralValue,
        isActive
    ) {
        updateRelationshipLookup({
            oldRelationshipLookupName: oldRelationshipMappingName,
            newRelationshipLookupName: relationshipMappingName,
            femaleValue: femaleValue,
            maleValue: maleValue,
            neutralValue: neutralValue,
            isActive: isActive,
        })
            .then((result) => {
                this.showToast(
                    "success",
                    "Update Complete",
                    this.labelReference.editSuccessMessage.replace("{0}", result)
                );
            })

            .catch((error) => {
                //console.log("Inside error");
            });
        this.refreshAllApex();
    }

    executeCreateRelationshipMapping(relationshipMappingName, femaleValue, maleValue, neutralValue, isActive) {
        createRelationshipLookup({
            relationshipLookupName: relationshipMappingName,
            femaleValue: femaleValue,
            maleValue: maleValue,
            neutralValue: neutralValue,
            isActive: isActive,
        })
            .then((result) => {
                this.showToast(
                    "success",
                    this.labelReference.successToast,
                    this.labelReference.createSuccessMessage.replace("{0}", result)
                );
            })

            .catch((error) => {
                // console.log('Inside error');
            });
        this.refreshAllApex();
    }

    executeDeleteRelationshipMappings(relationshipMappingName) {
        deleteRelationshipLookup({
            relationshipLookupName: relationshipMappingName,
        })
            .then((result) => {
                if (result) {
                    this.showToast(
                        "success",
                        "Delete Complete",
                        this.labelReference.deleteSuccessMessage.replace("{0}", result)
                    );
                } else {
                    //console.log("Delete error: the mapping was not found");
                }
            })

            .catch((error) => {
                //console.log("Inside error");
            });
        this.refreshAllApex();
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
}
