import { LightningElement, api, track, wire } from "lwc";
import getRelationshipLookupNameComboboxVModel from "@salesforce/apex/RelationshipSettingsController.getRelationshipLookupNameComboboxVModel";
import getActiveRelationshipTypesComboboxVModel from "@salesforce/apex/RelationshipSettingsController.getActiveRelationshipTypesComboboxVModel";

import stgColRelationshipName from "@salesforce/label/c.stgColRelationshipName";
import stgColFemale from "@salesforce/label/c.stgColFemale";
import stgColMale from "@salesforce/label/c.stgColMale";
import stgColNeutral from "@salesforce/label/c.stgColNeutral";
import stgColActive from "@salesforce/label/c.stgColActive";

import stgOptSelect from "@salesforce/label/c.stgOptSelect";
import stgReciprocalRelEditModalBody from "@salesforce/label/c.stgReciprocalRelEditModalBody";
import stgReciprocalRelNewModalBody from "@salesforce/label/c.stgReciprocalRelNewModalBody";
import stgReciprocalRelDeleteModalBody from "@salesforce/label/c.stgReciprocalRelDeleteModalBody";

export default class RelationshipMappingModalBody extends LightningElement {
    @api relationshipMappingAction;
    @api oldRelationshipMappingName;
    @api relationshipMappingName;
    @api femaleValue;
    @api maleValue;
    @api neutralValue;
    @api isActive;

    @track relationshipLookupNameComboboxVModel;
    @track relationshipLookupNameComboboxWireResult;

    @track activeRelationshipTypesComboboxVModel;
    @track activeRelationshipTypesComboboxWireResult;

    labelReference = {
        relationshipMappingName: stgColRelationshipName,
        comboboxPlaceholderText: stgOptSelect,
        femaleValue: stgColFemale,
        maleValue: stgColMale,
        neutralValue: stgColNeutral,
        isActive: stgColActive,

        modalBodyEditSave: stgReciprocalRelEditModalBody,
        modalBodyDelete: stgReciprocalRelDeleteModalBody,
        modalBodyCreate: stgReciprocalRelNewModalBody,
    };

    inputAttributeReference = {
        relationshipMappingName: "relationshipMappingName",
        femaleValue: "relationshipMappingFemaleValue",
        maleValue: "relationshipMappingMaleValue",
        neutralValue: "relationshipMappingNeutralValue",
        isActive: "relationshipMappingIsActiveValue",
    };

    @wire(getRelationshipLookupNameComboboxVModel, {
        relationshipLookupName: "$oldRelationshipMappingName",
    })
    relationshipLookupNameComboboxVModelWire(result) {
        this.relationshipLookupNameComboboxWireResult = result;

        if (result.data) {
            this.relationshipLookupNameComboboxVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving relationshipLookupNameComboboxVModel");
        }
    }

    @wire(getActiveRelationshipTypesComboboxVModel)
    activeRelationshipTypesComboboxVModelWire(result) {
        this.activeRelationshipTypesComboboxWireResult = result;

        if (result.data) {
            this.activeRelationshipTypesComboboxVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving activeRelationshipTypesVModel");
        }
    }

    get modifyRecords() {
        return (
            (this.relationshipMappingAction === "edit" || this.relationshipMappingAction === "create") &&
            this.relationshipLookupNameComboboxVModel &&
            this.activeRelationshipTypesComboboxVModel
        );
    }

    get deleteRecords() {
        return this.relationshipMappingAction === "delete";
    }

    handleRelationshipMappingNameChange(event) {
        this.dispatchRelationshipMappingNameChangeEvent(event.detail.value);
    }

    dispatchRelationshipMappingNameChangeEvent(relationshipMappingName) {
        const relationshipMappingNameDetails = {
            relationshipMappingName: relationshipMappingName,
        };

        const relationshipMappingNameChangeEvent = new CustomEvent("relationshipmappingnamechange", {
            detail: relationshipMappingNameDetails,
            bubbles: true,
            composed: true,
        });

        this.dispatchEvent(relationshipMappingNameChangeEvent);
    }

    handleFemaleValueChange(event) {
        this.dispatchFemaleValueChangeEvent(event.detail.value);
    }

    dispatchFemaleValueChangeEvent(femaleValue) {
        const femaleValueDetails = {
            femaleValue: femaleValue,
        };

        const femaleValueChangeEvent = new CustomEvent("femalevaluechange", {
            detail: femaleValueDetails,
            bubbles: true,
            composed: true,
        });

        this.dispatchEvent(femaleValueChangeEvent);
    }

    handleMaleValueChange(event) {
        this.dispatchMaleValueChangeEvent(event.detail.value);
    }

    dispatchMaleValueChangeEvent(maleValue) {
        const maleValueDetails = {
            maleValue: maleValue,
        };

        const maleValueChangeEvent = new CustomEvent("malevaluechange", {
            detail: maleValueDetails,
            bubbles: true,
            composed: true,
        });

        this.dispatchEvent(maleValueChangeEvent);
    }

    handleNeutralValueChange(event) {
        this.dispatchNeutralValueChangeEvent(event.detail.value);
    }

    dispatchNeutralValueChangeEvent(neutralValue) {
        const neutralValueDetails = {
            neutralValue: neutralValue,
        };

        const neutralValueChangeEvent = new CustomEvent("neutralvaluechange", {
            detail: neutralValueDetails,
            bubbles: true,
            composed: true,
        });

        this.dispatchEvent(neutralValueChangeEvent);
    }

    handleIsActiveChange(event) {
        this.dispatchIsActiveChangeEvent(event.detail.checked);
    }

    dispatchIsActiveChangeEvent(isActive) {
        const isActiveDetails = {
            isActive: isActive,
        };

        const isActiveChangeEvent = new CustomEvent("isactivechange", {
            detail: isActiveDetails,
            bubbles: true,
            composed: true,
        });

        this.dispatchEvent(isActiveChangeEvent);
    }

    get relationshipMappingModalBodyDesc() {
        switch (this.relationshipMappingAction) {
            case "edit":
                return this.labelReference.modalBodyEditSave;

            case "create":
                return this.labelReference.modalBodyCreate;

            case "delete":
                return this.labelReference.modalBodyDelete
                    .replace("{0}", this.relationshipMappingName)
                    .replace("{1}", this.femaleValue)
                    .replace("{2}", this.maleValue)
                    .replace("{3}", this.neutralValue);
        }
    }
}
