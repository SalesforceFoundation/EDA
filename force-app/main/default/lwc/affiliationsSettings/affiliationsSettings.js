import { LightningElement, api, track, wire } from "lwc";

export default class AffiliationsSettings extends LightningElement {
    isEditMode = false;
    affordancesDisabledToggle = false;

    @track primaryAffiliationsSettingsWireResult;
    @track primaryAffiliationsSettingsVModel;
    @track showPreferredPhoneEnforcement;

    labelReference = {
        title: "title",
        description: "description",
        accountRecordTypeColumn: "Account Record Type",
        contactFieldColumn: "Primary Affiliation Field",
        editAction: "Edit",
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
            { type: "action", typeAttributes: { rowActions: this.primaryAffiliationsActions } },
        ];
    }

    get primaryAffiliationsActions() {
        return [{ label: this.labelReference.editAction, name: "edit" }];
    }

    get data() {
        return [
            {
                name: "item1",
                accountRecordTypeLabel: "Academic Program",
                accountRecordType: "Academic_Program",
                contactFieldLabel: "Primary Academic Program",
                contactField: "Primary_Academic_Program__c",
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
        switch (actionName) {
            case "edit":
                console.log(JSON.stringify(actionRow));
                this.editPrimaryAffiliation(actionRow);
                break;
        }
    }

    editPrimaryAffiliation(primaryAffiliationRow) {}

    refreshAllApex() {
        Promise.all([refreshApex(this.primaryAffiliationsSettingsWireResult)]).then(() => {});
    }
}
