import { LightningElement, api, track, wire } from "lwc";
import getRelationshipLookupNameComboboxVModel from "@salesforce/apex/RelationshipSettingsController.getRelationshipLookupNameComboboxVModel";
import getRelationshipLookupComboboxVModel from "@salesforce/apex/RelationshipSettingsController.getRelationshipLookupComboboxVModel";

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

    @track oldFemaleValue;
    @track oldMaleValue;
    @track oldNeutralValue;

    @track relationshipLookupNameComboboxVModel;
    @track relationshipLookupNameComboboxWireResult;
    @track femaleValueComboboxVModel;
    @track femaleValueComboboxWireResult;
    @track maleValueComboboxVModel;
    @track maleValueComboboxWireResult;
    @track neutralValueComboboxVModel;
    @track neutralValueComboboxWireResult;

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

    connectedCallback() {
        this.oldFemaleValue = this.femaleValue;
        this.oldMaleValue = this.maleValue;
        this.oldNeutralValue = this.neutralValue;
        getRelationshipLookupNameComboboxVModel({ relationshipLookupName: this.oldRelationshipMappingName })
            .then((result) => {
                this.relationshipLookupNameComboboxVModelWire({ data: result });
            })
            .catch((error) => {
                this.relationshipLookupNameComboboxVModelWire({ error: error });
            });
    }

    relationshipLookupNameComboboxVModelWire(result) {
        this.relationshipLookupNameComboboxWireResult = result;

        if (result.data) {
            this.relationshipLookupNameComboboxVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving relationshipLookupNameComboboxVModel");
        }
    }

    @wire(getRelationshipLookupComboboxVModel, {
        relationshipLookupName: "$oldFemaleValue",
    })
    femaleValueComboboxVModelWire(result) {
        this.femaleValueComboboxWireResult = result;

        if (result.data) {
            this.femaleValueComboboxVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving femaleValueComboboxVModel");
        }
    }

    @wire(getRelationshipLookupComboboxVModel, {
        relationshipLookupName: "$oldMaleValue",
    })
    maleValueComboboxVModelWire(result) {
        this.maleValueComboboxWireResult = result;

        if (result.data) {
            this.maleValueComboboxVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving maleValueComboboxVModel");
        }
    }

    @wire(getRelationshipLookupComboboxVModel, {
        relationshipLookupName: "$oldNeutralValue",
    })
    neutralValueComboboxVModelWire(result) {
        this.neutralValueComboboxWireResult = result;

        if (result.data) {
            this.neutralValueComboboxVModel = result.data;
        } else if (result.error) {
            //console.log("error retrieving neutralValueComboboxVModel");
        }
    }

    get modifyRecords() {
        return (
            (this.relationshipMappingAction === "edit" || this.relationshipMappingAction === "create") &&
            this.relationshipLookupNameComboboxVModel &&
            this.femaleValueComboboxVModel &&
            this.maleValueComboboxVModel &&
            this.neutralValueComboboxVModel
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
